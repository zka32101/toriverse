# トリバース — プロジェクト概要 & 開発ガイド

**プロジェクト名**: トリバース（Tri-Verse）  
**技術スタック**: Flutter/Dart 3.x + Riverpod + Firebase + RevenueCat  
**ステータス**: MVP 実装フェーズ（2026年8月開始）  
**目標リリース**: 2026年Q4 ソフトローンチ

---

## 1. プロジェクト概要

### Vision & ミッション
- **Vision (MVP)**: じっくり読み合い、同時公開の瞬間にドキドキする3色オセロ
- **Vision (Phase2)**: 頭脳戦に「観る楽しさ」を持ち込み、3人対戦オセロを配信文化の定番にする
- **Mission**: 眠っていた良ゲームを、今の技術と運用で再定義する

### OKR（ベンチマーク範囲内・非同期化対応版）
- Day7 リテンション: 15-20%
- Day30 リテンション: 8-10%
- 有料転換率: 3-4%
- Viral Coefficient: 0.3-0.5

### 重要な設計転換
1. **3人マッチングの cold-start 問題**を受け、MVP を**非同期対戦**に変更
2. 緊張感低下を補うため**同時提出制（Simultaneous Reveal）**を採用
   - 全員が1手を提出 → 時間切れ or 全員提出で同時公開
   - くじ引き演出（処理順抽選） → 反転アニメ順次再生
3. リアルタイム観戦・配信連携は Phase2 へ先送り

---

## 2. 技術スタック

| レイヤー | 選択肢 | 理由 |
|---------|--------|------|
| UI フレームワーク | **Flutter 3.x + Dart** | iOS/Android 単一コード、パフォーマンス |
| 状態管理 | **Riverpod 2.x** | Provider より型安全、キャッシング効率 |
| バックエンド | **Firebase** | リアルタイムリスナー、Firestore（非同期ターン制向け） |
| 認証 | Firebase Authentication | OAuth/Apple/Google 対応 |
| 課金 | **RevenueCat** | App Store/Play Store 統一管理 |
| アナリティクス | Firebase Analytics | KPI 計測・Remote Config |
| クラッシュ報告 | Firebase Crashlytics | 本番エラートラッキング |
| 動画/アニメ | **Lottie** | 弱者ボーナス・救済カード・くじ引き演出 |
| 広告（リワード） | **Google Mobile Ads** | ランクマ無料枠の報酬動画 |
| アーキテクチャ | **MVVM** | 画面数 10 前後に適正 |
| 同期方式 | **Firestore リアルタイムリスナー** | WebSocket 自前実装不要、7日プロト可能性向上 |

---

## 3. 必須機能一覧（Must 8個）

> ⚠️ Vision 直結のため通常上限 5 個を超えて許容

| # | 機能 | 説明 |
|---|------|------|
| 1 | 3色オセロ本体 | 非同期・同時提出制、1ラウンド=各プレイヤー1手、全員提出/時間切れで同時公開 |
| 2 | 弱者ボーナス | 発動条件: 残り11手目まで有効 / 石差が下位20%以下 / 1局最大2回 |
| 3 | 連続被弾救済カード | 同一相手から2ラウンド連続攻撃で2手連続実行権を自動付与 |
| 4 | AI自動引き継ぎ | 離脱者をAIで代打・対局継続、離脱側ペナルティなし |
| 5 | 同マス被り処理 | 複数プレイヤーが同じマスに着手 → ランダム抽選 + 外れた側に救済カード1枚付与 |
| 6 | 処理順ランダム抽選 | ラウンドごと、演出は「くじ引き → 順番発表 → 反転再生」 |
| 7 | 同時公開リプレイ演出 | 逆転・演出強調 + クリップ自動生成（SNS映え対策） |
| 8 | 完走ストリーク・盤面コレクション | 初日リテンション対策・資産化 |

---

## 4. グロース設計（RARRA）

### R① Retention
- **Aha Moment**: 初回対戦で「同時公開 → 逆転」を体験する瞬間
- **ストリーク**: 3人対戦の"完走"回数を資産化
- **復帰ナッジ**: 「あなたの番が来ました」「3人の手が出揃いました、結果を見る」の 2 段階通知
- **通知プレプロンプト**: 「結果が出たらすぐ通知します」の価値説明後に OS 許可

### A② Activation
- **初回起動 → Aha**: ゲストマッチング即開始、3 タップ以内で対局へ
- **チュートリアル**: 3 色ルール + 救済カード + 弱者ボーナスの 3 点のみ
- **初回対局**: AI 2体 + 本人のイージーマッチで弱者ボーナス体験を保証

### R③ Referral
- **同時公開リプレイのクリップ自動生成・シェア**
- **フレンド招待で専用ルーム作成**
- **目標**: Viral Coefficient 0.3-0.5

### R④ Revenue
- **ランクマ参加権**: 通常は広告視聴で 1 日 1 回無料 / 月額 ¥300 で無制限
- **石・盤面デザイン**: 買い切り課金（¥120-300）で補完
- **ペイウォール**: 無料枠消化後、リワード広告 or 月額提案の 2 択 UI

### A⑤ Acquisition
- **ASO**: 「3人 オセロ」「3色 リバーシ」「オセロ 対戦」
- **スクショ 1 枚目**: 3 色盤面の同時公開・逆転シーン
- **配信者への企画提供**（Phase2 観戦機能を訴求）

---

## 5. 画面フロー

```
起動
  → オンボ(3枚・3色ルール+救済カード+弱者ボーナスのみ説明)
  → 通知許可プレプロンプト
  → ホーム(マッチング開始／フレンド対戦／ショップ)
    ├─ [マッチング] → 待機(2/3人集まるまでAI即席補完)
    │   → 対局(ラウンド制)
    │     → 各ラウンド:
    │        1. 自分の手を提出(他者の手は非公開)
    │        2. 全員提出/時間切れで同時公開
    │        3. くじ引き演出(処理順抽選)
    │        4. 反転アニメ順次再生
    │        5. 弱者ボーナス/救済カード発動演出
    │     → 終局
    │     → リザルト(順位・獲得石・完走ストリーク+1)
    │     → クリップ自動生成プレビュー → シェア(任意)
    └─ 途中離脱時: AI引き継ぎ → 他2人には「席替わりました」表示のみ
```

**最短経路**: 起動 → ホーム → マッチング → 対局開始 = **3 タップ以内で Aha Moment**

---

## 6. データモデル（Firestore）

```dart
// ユーザー
User {
  uid: string,
  rankPoints: int,
  completedMatchStreak: int,
  freeMatchUsedToday: int,
  subscriptionStatus: enum(trial, active, cancelled),
  createdAt: timestamp
}

// マッチ（対局）
Match {
  id: string,
  players: [3]{ uid or "AI" },
  boardState: 8x8 board representation,
  roundIndex: int,
  status: enum(waiting, playing, finished),
  createdAt: timestamp
}

// ラウンド結果
RoundResult {
  matchId: string,
  roundIndex: int,
  submittedMoves: [
    { playerId, position, submittedAt }
  ],
  collisionResolved: [
    { position, winnerPlayerId, losers[], rescueCardGranted }
  ],
  processOrder: [playerId1, playerId2, playerId3],  // ランダム抽選
  replayEvents: [...]  // アニメ再生用シーケンス
}

// 救済カード状態
RescueCardState {
  matchId: string,
  playerId: string,
  consecutiveAttackedCount: int,
  cardAvailable: bool
}

// 弱者ボーナス状態
WeakBonusState {
  matchId: string,
  remainingActivations: int(=2),
  lastActivatedRound: int
}

// クリップ資産
ClipAsset {
  id: string,
  matchId: string,
  generatedAt: timestamp,
  videoUrl: string,
  shareCount: int
}

// コスメティックアイテム
CosmeticItem {
  id: string,
  type: enum(board, stone),
  price: int,  // JPY
  ownedByUid: [string]
}
```

**注**: 弱者ボーナスの発動条件（劣勢者優先）と処理順抽選（完全ランダム）は独立したロジック。混同しないこと。

---

## 7. API 設計（Cloud Functions）

### 挟み判定・ボーナス判定など
- **すべてクライアント改ざん防止のため Cloud Functions 側で確定**
- AI 代打ちロジック: Cloud Functions 内蔵の簡易ミニマックス AI（3 色対応版）

### 主要エンドポイント（予定）
- `submitMove()` — ターンの手を提出
- `validateMove()` — 合法性チェック（サーバー確定）
- `processBonusLogic()` — 弱者ボーナス・救済カード発動
- `resolveCollision()` — 同マス被り抽選
- `getReplayEvents()` — リプレイ用シーケンス取得
- `generateClip()` — 自動クリップ生成

---

## 8. 計測・分析設計

### 必須 3 点セット
- Firebase Analytics
- Firebase Crashlytics
- Firebase Remote Config

### KPI イベント（5 個以内）
```
match_completed          // マッチ完了（初回逆転体験フラグ付き）
full_human_match_started // 3人フル人間戦開始（致命的リスク①対策）
weak_bonus_triggered     // 弱者ボーナス発動
rescue_card_used         // 救済カード使用
clip_shared              // クリップシェア
rankpass_converted       // ランクマ課金転換
```

### リテンション追跡
- Day 1 / 7 / 30 + 完走ストリーク別コホート比較

### Remote Config 値
- 弱者ボーナス閾値（デフォルト: 石差下位 20%）
- 救済カード発動条件（デフォルト: 連続被弾 2 ラウンド）
- 提出ウィンドウ時間（デフォルト: 30 秒 / 自動公開）
- 広告視聴無料枠回数（デフォルト: 1 回 / 日）
- min_supported_version

---

## 9. セキュリティ・パフォーマンス要件

| 項目 | 対策 |
|------|------|
| API キー | 環境変数 + Firestore セキュリティルール |
| 通信 | HTTPS（Firebase 標準） |
| タイムアウト | 10 秒 + リトライ 3 回 |
| 切断時 | ローカルキャッシュから自動再接続 |
| レート制限 | Cloud Functions（ユーザー単位・ラウンド単位） |

---

## 10. UI/UX クオリティ設計

- **3 色ロッティアニメ**: 黒=重厚感、白=清涼、赤=派手め
- **ボーナス・救済カード**: 専用エフェクト + SE で視認性最大化
- **同時公開くじ引き演出**: "開封の快感" として作り込み
- **基本設計**: 44pt+ タップ / ハプティクス / 二度押し防止 / ダークモード必須 / WCAG AA

---

## 11. テスト戦略（カバレッジ 50%+）

### Unit Tests
- 挟み判定（全 8 方向・複数挟み・エッジケース）
- 弱者ボーナス発動条件（劣勢度・ラウンド・回数上限）
- 救済カード発動条件（連続被弾カウント）
- 同マス抽選（均等分布）

### Widget Tests
- 対局画面（ボード描画・操作可能）
- リザルト画面（順位・ストリーク表示）

### Integration Tests
- マッチング → 対局 → 離脱 → AI 引き継ぎ → 終局の一連フロー（1-2 本）

### CI/CD
- GitHub Actions: analyze → test → ビルド → TestFlight / Firebase App Distribution

---

## 12. リリース・運用設計

### ソフトローンチゲート条件
- Day 1 リテンション: **25% 以上**
- クラッシュフリーレート: **99.5% 以上**
- 初回逆転体験到達率: **60% 以上**
- **3 人フル人間戦成立率: 40% 以上**（致命的リスク①対策・追加ゲート）

### LiveOps
- 季節限定盤面デザイン
- 週末ダブルランクポイント（Remote Config 発火）

### Phase 2 ロードマップ
- DAU 確保後にリアルタイム観戦モード追加
- 配信連携機能（OBS/YouTube Live 等）

---

## 13. 致命的リスク & 対策

| リスク | 対策 | 状態 |
|--------|------|------|
| 3人マッチング cold-start | MVP を非同期対戦に転換 + AI 補完 | ✅ 対策済み |
| リアルタイム同期の技術複雑性 | Firestore リアルタイムリスナー採用（WebSocket 不要） | ✅ 対策済み |
| 同マス被り・処理順未定義 | ランダム抽選 + 救済カード付与で解決 | ✅ 対策済み |
| 弱者ボーナス→タンク/膠着 | 終盤除外・閾値制・回数上限で対処 | ✅ 要テスト |
| Phase 2 実装延長 | MVP 単体での差別化軸（同時公開演出）で補強 | ✅ 対策済み |

---

## 14. 開発環境セットアップ（ローカル）

### 前提条件
- Flutter 3.4+
- Dart 3.2+
- Xcode 15.0+（iOS）
- Android Studio 2023.1+（Android）

### セットアップ手順

```bash
# 1. リポジトリクローン & ブランチ切り替え
git clone https://github.com/zka32101/toriverse.git
cd toriverse
git checkout claude/triverse-development-r2e05a

# 2. 依存関係インストール
flutter pub get

# 3. 環境変数設定
cp .env.example .env
# .env に Firebase 認証情報・RevenueCat API キーを設定

# 4. コード生成（Freezed, Riverpod など）
flutter pub run build_runner build

# 5. テスト実行
flutter test

# 6. iOS セットアップ（macOS のみ）
cd ios
pod install
cd ..

# 7. デバイス/エミュレータ起動
flutter devices
flutter run
```

---

## 15. ファイル構成

```
toriverse/
├── lib/
│   ├── main.dart                    # エントリーポイント
│   ├── config/
│   │   ├── constants.dart
│   │   ├── routes.dart
│   │   └── firebase_config.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   └── data/
│   │   ├── home/
│   │   ├── match/
│   │   │   ├── domain/             # オセロ判定ロジック等
│   │   │   ├── application/        # ゲームロジック・状態管理
│   │   │   ├── presentation/       # UI・画面
│   │   │   └── data/               # Firestore 連携
│   │   ├── results/
│   │   ├── shop/
│   │   └── analytics/
│   ├── shared/
│   │   ├── models/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── utils/
│   └── l10n/                       # 国際化（日本語優先）
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── android/
├── ios/
├── pubspec.yaml
├── pubspec.lock
├── .env.example
├── analysis_options.yaml
├── CLAUDE.md                       # このファイル
├── CODE_HANDOVER.md                # コード引き継ぎ書
└── README.md
```

---

## 16. 開発時注意点

### オセロロジック
- **黒・白・赤の 3 色は内部で 0, 1, 2 として管理**（混同防止）
- **挟み判定は 8 方向それぞれ独立確認後、一括反転**
- **弱者ボーナスと処理順抽選は完全に独立** — ロジック混同厳禁

### Firebase リアルタイム同期
- **Firestore リスナーは match と roundResult に限定**（課金制限対策）
- **オフライン時もローカルキャッシュで継続可能**
- **ネットワーク復帰時は自動キャッチアップ**

### 計測
- KPI イベント発火は **サーバー側の判定確定後**（クライアント改ざん防止）
- Remote Config は起動時・1 時間ごとに キャッシュ更新

### テスト優先項目
- ✅ 境界値テスト（11 手目以降弱者ボーナス不可など）
- ✅ 連続被弾救済カード発動条件
- ✅ 同マス被り時のランダム抽選（偏りチェック）

---

## 17. 参考資料

- 企画・設計書: `/root/.claude/uploads/.../14a480a4-toriverse_kikaku_sekkei_v1_0.md`
- 競合分析: 「3 人対戦！リバーシ」（暗黒社、2013〜）比較済み
- バイラル設計: 29 点フレーム評価済み（⭐4.5/5）

---

## 18. よくある質問（FAQ）

**Q1. Phase 2 のリアルタイム観戦機能はいつ？**  
A. DAU 確保後の追加。MVP では同時公開演出で補強。

**Q2. AI の難易度調整は？**  
A. 簡易ミニマックス実装。Remote Config で調整可能。

**Q3. オフラインプレイは？**  
A. 非対応。非同期マルチが前提。ローカル 3 人プレイのみ後続検討。

**Q4. 開発者がつまずきそうな部分は？**  
A. 弱者ボーナス条件（劣勢者優先）と処理順抽選（完全ランダム）の混同。テスト重点項目。

---

**作成日**: 2026-08-27  
**最終更新**: —  
**責任者**: Claude / zka32101
