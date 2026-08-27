# トリバース — コード引き継ぎ書

**対象**: MVP 実装フェーズ開始者  
**作成日**: 2026-08-27  
**ステータス**: 企画・設計フェーズ完了 → **実装ゴー（⭐4.5/5）**

---

## 🎯 実装者が最初にやること（優先度順）

### ステップ 1-A: ローカル環境セットアップ（1-2 時間）

```bash
# 1. ブランチ確認
git checkout claude/triverse-development-r2e05a

# 2. Flutter プロジェクト初期化（ローカル必須 - リモート環境では flutter コマンド使用不可）
flutter create --org com.petitworks --project-name toriverse .

# 3. 依存関係インストール
flutter pub get

# 4. 環境変数準備
cp .env.example .env
# → Firebase 認証情報・RevenueCat API キーを手動設定

# 5. コード生成（Freezed, Riverpod）
flutter pub run build_runner build

# 6. デバッグビルド確認
flutter run
```

### ステップ 1-B: 依存関係の追加（pubspec.yaml）

下記を参考に `flutter pub add` または `pubspec.yaml` 直編で追加：

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状態管理
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  riverpod_generator: ^2.3.0
  
  # Firebase
  firebase_core: ^2.24.0
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.17.0
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.0
  firebase_remote_config: ^4.3.0
  
  # 課金 & 広告
  purchases_flutter: ^7.0.0  # RevenueCat
  google_mobile_ads: ^3.0.0
  
  # UI/UX
  lottie: ^2.6.0
  cached_network_image: ^3.3.0
  
  # その他
  freezed_annotation: ^2.4.0
  json_serializable: ^6.7.0
  go_router: ^12.1.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.4.0
  riverpod_generator: ^2.3.0
  json_serializable: ^6.7.0
```

### ステップ 1-C: .env テンプレート作成

`.env.example` を作成してリポジトリに追加（機密情報は記載しない）：

```bash
# Firebase (local instance / emulator)
FIREBASE_API_KEY=
FIREBASE_AUTH_DOMAIN=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_APP_ID=

# RevenueCat
REVENUECAT_API_KEY=

# Google Mobile Ads
ADMOB_APP_ID=
ADMOB_BANNER_AD_UNIT_ID=
ADMOB_REWARD_AD_UNIT_ID=
```

**ローカル用 .env（開発者が .gitignore で管理）**:
```bash
cp .env.example .env
# → 実際の API キーをセット
```

### ステップ 2-A: プロジェクト構造初期化（2-3 時間）

以下のファイル・フォルダを手動作成（スケルトン）：

```bash
# lib/ ディレクトリ構造
mkdir -p lib/{config,features,shared,l10n}
mkdir -p lib/features/{auth,home,match,results,shop,analytics}
mkdir -p lib/features/match/{domain,application,presentation,data}
mkdir -p lib/shared/{models,services,widgets,utils}
mkdir -p test/{unit,widget,integration}
```

### ステップ 2-B: main.dart & 基本設定（1 時間）

**lib/main.dart** — エントリーポイント＋ Riverpod セットアップ：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: ToriverseApp(),
    ),
  );
}

class ToriverseApp extends StatelessWidget {
  const ToriverseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'トリバース',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

// 仮の HomePage（あとで置換）
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('トリバース')),
      body: const Center(child: Text('開発中...')),
    );
  }
}
```

### ステップ 2-C: Firebase 初期設定（1-2 時間）

1. **Firebase Console で新規プロジェクト作成**
   - プロジェクト名: `toriverse` または `toriverse-dev`
   - 地域: `asia-northeast1`（東京）

2. **FlutterFire CLI で自動生成**
   ```bash
   curl -sL https://firebase.flutter.dev/install.sh | bash
   flutterfire configure
   ```
   → `lib/firebase_options.dart` が自動生成

3. **Firestore 初期化**
   - Collections: `users`, `matches`, `roundResults`, `rescueCardStates`, `weakBonusStates`, `clipAssets`, `cosmeticItems`
   - セキュリティルール: 後続ステップで設定

4. **Firebase Authentication 設定**
   - Anonymous, Google, Apple ログイン有効化

---

## 🕹️ オセロロジック実装（最優先 - 1-2 日）

### 注意事項 ⚠️
**弱者ボーナスと処理順抽選は完全に独立**。混同すると重大バグ。

### Phase 1: Board モデル & 挟み判定

**lib/features/match/domain/entities/board.dart**

```dart
enum Stone { black, white, red, empty }

// 内部では 0=黒, 1=白, 2=赤, 3=空 で管理（混同防止）
class Board {
  late List<List<int>> _grid;  // 8x8
  
  Board.initial() {
    _grid = List.generate(8, (_) => List.filled(8, 3)); // 3=empty
    // 初期配置
    _grid[3][3] = 1; // 白
    _grid[3][4] = 0; // 黒
    _grid[4][3] = 0; // 黒
    _grid[4][4] = 1; // 白
  }
  
  // 挟み判定（8方向）
  bool isValidMove(int row, int col, int player) {
    if (_grid[row][col] != 3) return false; // 空マスでない
    
    // 8方向チェック（上下左右+斜め4方向）
    final directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1],
      [-1, -1], [-1, 1], [1, -1], [1, 1],
    ];
    
    for (var dir in directions) {
      if (_hasFlippableInDirection(row, col, player, dir[0], dir[1])) {
        return true;
      }
    }
    return false;
  }
  
  bool _hasFlippableInDirection(
    int startRow, int startCol, int player, int dr, int dc
  ) {
    int r = startRow + dr;
    int c = startCol + dc;
    int opponent = player == 0 ? 1 : 0; // 簡略化（赤は後述）
    
    // 最低1つの相手石を通す
    bool found = false;
    while (r >= 0 && r < 8 && c >= 0 && c < 8) {
      if (_grid[r][c] == 3) return false; // 空マス → 挟めない
      if (_grid[r][c] == opponent) {
        found = true;
      } else if (_grid[r][c] == player) {
        return found; // 自分色で閉じた → OK
      } else {
        return false; // 別の色 → NG
      }
      r += dr;
      c += dc;
    }
    return false; // 盤の端まで到達 → NG
  }
  
  // 手を確定（全8方向で反転処理）
  void placeStone(int row, int col, int player) {
    _grid[row][col] = player;
    
    final directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1],
      [-1, -1], [-1, 1], [1, -1], [1, 1],
    ];
    
    for (var dir in directions) {
      _flipInDirection(row, col, player, dir[0], dir[1]);
    }
  }
  
  void _flipInDirection(int startRow, int startCol, int player, int dr, int dc) {
    // 上述の _hasFlippableInDirection と同じロジックで反転対象を特定
    // すべての相手石を player の色に変更
  }
  
  // 盤面読み取り
  int getStone(int row, int col) => _grid[row][col];
}
```

### Phase 2: ゲームロジック（Riverpod + 弱者ボーナス）

**lib/features/match/application/game_state.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 弱者ボーナス判定
class BonusCalculator {
  static bool shouldActivateBonus({
    required int roundsLeft,        // 残りラウンド数
    required List<int> stoneCount,  // [player0石数, player1石数, player2石数]
    required int previousActivations, // この対局での発動回数
  }) {
    // 条件1: 残り11手まで有効（8x8 盤面で合計64手。11手 = 終盤の目安）
    if (roundsLeft > 11) return false;
    
    // 条件2: 石差が下位20%以下
    final maxStones = stoneCount.reduce((a, b) => a > b ? a : b);
    final minStones = stoneCount.reduce((a, b) => a < b ? a : b);
    final player = stoneCount.indexOf(minStones);
    
    if ((maxStones - minStones) < stoneCount.length * 2.5) return false;
    
    // 条件3: 1局最大2回発動
    if (previousActivations >= 2) return false;
    
    return true;
  }
}

// 同マス被り抽選
class CollisionResolver {
  static String resolveCollision(List<String> players) {
    // ランダムに1人選出（他は救済カード付与）
    players.shuffle();
    return players.first;
  }
}

// 処理順ランダム抽選
class ProcessOrderRanomizer {
  static List<String> randomizeOrder(List<String> players) {
    List<String> order = List.from(players);
    order.shuffle();
    return order;
  }
}
```

### Phase 3: テスト（重点項目）

**test/unit/board_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

void main() {
  group('Board', () {
    late Board board;
    
    setUp(() {
      board = Board.initial();
    });
    
    test('初期配置が正しい', () {
      expect(board.getStone(3, 3), 1); // 白
      expect(board.getStone(3, 4), 0); // 黒
      expect(board.getStone(4, 3), 0); // 黒
      expect(board.getStone(4, 4), 1); // 白
    });
    
    test('合法手が正しく判定される', () {
      // 黒(0)の初期合法手: (2,3), (3,2), (4,5), (5,4)
      expect(board.isValidMove(2, 3, 0), true);
      expect(board.isValidMove(0, 0, 0), false);
    });
    
    test('手を置くと正しく反転する', () {
      board.placeStone(2, 3, 0); // 黒
      expect(board.getStone(3, 3), 0); // 反転
    });
  });
  
  group('BonusCalculator', () {
    test('終盤かつ劣勢ならボーナス対象', () {
      bool canActivate = BonusCalculator.shouldActivateBonus(
        roundsLeft: 5,
        stoneCount: [10, 30, 25],
        previousActivations: 0,
      );
      expect(canActivate, true);
    });
    
    test('11手以上残っていればボーナス不可', () {
      bool canActivate = BonusCalculator.shouldActivateBonus(
        roundsLeft: 15,
        stoneCount: [10, 30, 25],
        previousActivations: 0,
      );
      expect(canActivate, false);
    });
  });
}
```

---

## 🔥 Firebase セットアップ（1-2 日）

### Phase 1: Firestore セキュリティルール

**firestore.rules**（Firebase Console で設定）

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ユーザー: 自分のドキュメントのみアクセス可
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // マッチ: 参加プレイヤーのみアクセス可
    match /matches/{matchId} {
      allow read: if request.auth.uid in resource.data.players;
      allow create: if request.auth.uid != null;
      allow update: if request.auth.uid in resource.data.players;
    }
    
    // ラウンド結果: マッチ参加者のみ読み取り
    match /roundResults/{document=**} {
      allow read: if request.auth.uid != null;
      allow write: if false; // サーバーのみ書き込み
    }
  }
}
```

### Phase 2: Cloud Functions スケルトン

後続ステップで実装。以下をドキュメント化：

**functions/src/validateMove.ts** （擬似コード）

```typescript
export const validateMove = functions.firestore
  .document('matches/{matchId}')
  .onWrite(async (change, context) => {
    const matchId = context.params.matchId;
    const newMatch = change.after.data();
    
    // 1. 手の合法性チェック
    // 2. ボーナス判定
    // 3. 処理順抽選（全員提出時）
    // 4. 反転処理
    // 5. イベント記録
    
    // すべてサーバー側で確定
    return firestore.collection('roundResults').add({...});
  });
```

---

## 🎮 マッチング & AI 実装（2-3 日）

### Priority 1: マッチング状態管理

**lib/features/match/application/matching_provider.dart**

```dart
final matchingProvider = StateNotifierProvider<MatchingNotifier, MatchingState>(
  (ref) => MatchingNotifier(ref),
);

class MatchingNotifier extends StateNotifier<MatchingState> {
  MatchingNotifier(this.ref) : super(const MatchingState.waiting());
  
  final Ref ref;
  
  Future<void> startMatching() async {
    state = const MatchingState.waiting();
    
    // 1. Firestore に "waiting" マッチを作成
    // 2. 5秒ごとにチェック：3人集まったか？
    // 3. 集まらなかったら AI を補完して開始
    
    // リアルタイムリスナー設定
    ref.listen(currentMatchProvider, (_, match) {
      if (match != null && match.status == MatchStatus.playing) {
        state = MatchingState.joined(match);
      }
    });
  }
}
```

### Priority 2: AI ロジック（簡易ミニマックス）

**lib/features/match/domain/ai/ai_player.dart**

```dart
class AIPlayer {
  static int? suggestMove(Board board, int aiPlayer) {
    // 簡易ミニマックス（深さ3-4）
    int bestScore = -1000;
    int? bestMove;
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board.isValidMove(row, col, aiPlayer)) {
          // テスト盤面で手を置く
          Board testBoard = _cloneBoard(board);
          testBoard.placeStone(row, col, aiPlayer);
          
          int score = _minimax(testBoard, 3, aiPlayer, false);
          if (score > bestScore) {
            bestScore = score;
            bestMove = row * 8 + col;
          }
        }
      }
    }
    
    return bestMove;
  }
  
  static int _minimax(Board board, int depth, int aiPlayer, bool isMaximizing) {
    // ベースケース
    if (depth == 0) {
      return _evaluateBoard(board, aiPlayer);
    }
    
    // 最大化 or 最小化
    int currentPlayer = isMaximizing ? aiPlayer : (aiPlayer + 1) % 3;
    int score = isMaximizing ? -1000 : 1000;
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board.isValidMove(row, col, currentPlayer)) {
          Board testBoard = _cloneBoard(board);
          testBoard.placeStone(row, col, currentPlayer);
          
          int newScore = _minimax(testBoard, depth - 1, aiPlayer, !isMaximizing);
          score = isMaximizing ? max(score, newScore) : min(score, newScore);
        }
      }
    }
    
    return score;
  }
  
  static int _evaluateBoard(Board board, int aiPlayer) {
    // スコア評価: AIの石数 - 敵の石数
    // 隅を重視するなら重み付け
    int aiStones = 0, enemyStones = 0;
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        int stone = board.getStone(row, col);
        if (stone == aiPlayer) aiStones++;
        else if (stone != 3) enemyStones++;
      }
    }
    
    return aiStones - enemyStones;
  }
}
```

---

## 📊 計測・分析（1-2 日）

### Firebase Analytics イベント

**lib/shared/services/analytics_service.dart**

```dart
class AnalyticsService {
  Future<void> logMatchCompleted({
    required String matchId,
    required List<String> players,
    required List<int> finalStones,
    required bool wasAhaExperienced,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'match_completed',
      parameters: {
        'match_id': matchId,
        'player_count_human': players.where((p) => p != 'AI').length,
        'aha_moment': wasAhaExperienced,
        'winning_player': players[finalStones.indexOf(finalStones.reduce(max))],
      },
    );
  }
  
  Future<void> logWeakBonusTriggered(String matchId) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'weak_bonus_triggered',
      parameters: {'match_id': matchId},
    );
  }
}
```

---

## 🚀 実装ロードマップ（推奨スケジュール）

| 週 | タスク | 優先度 | 期間 |
|----|--------|--------|------|
| W1 | 環境セットアップ + Firebase 初期化 | **P0** | 3-4 日 |
| W1 | オセロロジック + テスト（単体） | **P0** | 2-3 日 |
| W2 | マッチング + AI 実装 | **P0** | 2-3 日 |
| W2 | Firestore データモデル実装 | **P1** | 2-3 日 |
| W3 | UI 画面実装（ホーム・対局・結果） | **P1** | 4-5 日 |
| W3 | 弱者ボーナス・救済カード統合テスト | **P1** | 2 日 |
| W4 | Cloud Functions 実装 | **P2** | 3-4 日 |
| W4 | RevenueCat 統合 + 課金フロー | **P2** | 2 日 |
| W5 | リプレイ・クリップ機能 | **P2** | 3-4 日 |
| W5 | アナリティクス・Remote Config | **P2** | 1-2 日 |
| W6 | テスト全体（Unit/Widget/Integration） | **P1** | 3-4 日 |
| W6 | ビルド・デプロイメント準備 | **P1** | 1-2 日 |
| W7-8 | ソフトローンチテスト（TestFlight）+ 修正 | **P0** | 5-7 日 |

**目標**: **6-8 週で MVP ローンチ**（9月中旬〜10月初旬）

---

## 🔧 トラブルシューティング

### よくある問題

**Q1. Firebase に接続できない**
```
→ firebaseOptions.dart が正しく生成されたか確認
→ .env の API キーが正しいか確認
→ Firestore セキュリティルールが正しいか確認
```

**Q2. オセロ判定がおかしい**
```
→ 境界値テスト（盤の隅・端）を再確認
→ 8方向すべてで反転処理が走っているか確認
→ 内部の 0/1/2/3 値と表示色が混同していないか確認
```

**Q3. マッチング成立しない（AI も呼ばない）**
```
→ Firestore の match document が生成されているか確認
→ リアルタイムリスナーが動作しているか Crashlytics で確認
→ AI インスタンス化のタイミング（1秒遅延で試す）
```

---

## 📋 チェックリスト（実装開始前）

- [ ] ローカル環境：Flutter 3.4+ インストール済み
- [ ] Firebase プロジェクト作成済み（asia-northeast1）
- [ ] FlutterFire CLI で firebaseOptions.dart 生成済み
- [ ] .env.example 作成済み・.gitignore で .env を除外
- [ ] Firestore セキュリティルール設定済み
- [ ] GitHub ブランチ `claude/triverse-development-r2e05a` 確認済み
- [ ] CLAUDE.md & CODE_HANDOVER.md 読了済み
- [ ] 設計書（kikaku_sekkei_v1_0.md）の重要な仕様を理解済み

---

## 📞 実装中のQ&A送信先

- **技術的質問**: このコード引き継ぎ書の該当セクションを再読
- **設計理解**: CLAUDE.md の該当セクション + 企画設計書を参照
- **バグ報告**: GitHub Issues に「[Bug] タイトル」で作成

---

## 🎓 参考資料リンク

- [Flutter 公式ドキュメント](https://flutter.dev/docs)
- [Riverpod 公式ドキュメント](https://riverpod.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [オセロルール](https://www.othellojapan.org/rules.html)

---

**引き継ぎ完了**: 2026-08-27 by Claude  
**次の確認**: ローカル環境セットアップ後、W1 末に進捗チェック
