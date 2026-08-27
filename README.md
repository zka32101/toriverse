# トリバース — 3色オセロ × 非同期同時公開制

> じっくり読み合い、同時公開の瞬間にドキドキする3色オセロ

![Status](https://img.shields.io/badge/Status-MVP%20Development-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.4%2B-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-Private-red)

---

## 📱 プロジェクト概要

**トリバース**は、従来の2色オセロを3人対戦に進化させたモバイルゲームです。

### 主な特徴
- **3色オセロ**: 黒・白・赤の3色で戦略性が大幅向上
- **非同期同時公開制**: 各プレイヤーが手を提出 → 全員揃ったら一斉公開・反転
- **弱者ボーナス**: 劣勢者が終盤に逆転できる機会を用意
- **救済カード**: 連続で攻撃されたプレイヤーに2手連続実行権
- **AI自動引き継ぎ**: 途中離脱してもAIが代打・対局継続

---

## 🎯 Vision & OKR

### Vision
- **MVP**: じっくり読み合い、同時公開の瞬間にドキドキする3色オセロ
- **Phase 2**: 頭脳戦に「観る楽しさ」を持ち込み、3人対戦オセロを配信文化の定番にする

### 目標メトリクス
| KPI | 目標 |
|-----|------|
| Day 7 リテンション | 15-20% |
| Day 30 リテンション | 8-10% |
| 有料転換率 | 3-4% |
| Viral Coefficient | 0.3-0.5 |

---

## 🛠️ 技術スタック

| 領域 | 選択肢 |
|------|--------|
| **UI フレームワーク** | Flutter 3.4+ |
| **言語** | Dart 3.2+ |
| **状態管理** | Riverpod 2.4+ |
| **バックエンド** | Firebase (Firestore / Auth / Analytics / Crashlytics / Remote Config) |
| **課金** | RevenueCat |
| **広告** | Google Mobile Ads |
| **アニメ** | Lottie |
| **アーキテクチャ** | MVVM |

---

## 📋 必須機能（Must 8個）

- [x] 3色オセロ本体（非同期・同時提出制）
- [x] 弱者ボーナス機構
- [x] 連続被弾救済カード
- [x] AI自動引き継ぎ
- [x] 同マス被り時のランダム抽選＋救済カード付与
- [x] 処理順ランダム抽選＋くじ引き演出
- [x] 同時公開リプレイ演出＋クリップ自動生成
- [x] 完走ストリーク・盤面コレクション

---

## 🚀 クイックスタート

### 前提条件
- Flutter 3.4+
- Dart 3.2+
- Xcode 15.0+（iOS）
- Android Studio 2023.1+（Android）

### セットアップ手順

```bash
# 1. リポジトリをクローン
git clone https://github.com/zka32101/toriverse.git
cd toriverse

# 2. 開発ブランチに切り替え
git checkout claude/triverse-development-r2e05a

# 3. 依存関係をインストール
flutter pub get

# 4. 環境変数を設定
cp .env.example .env
# .env に Firebase API キーと RevenueCat キーを記入

# 5. Firebase 初期化（初回のみ）
flutterfire configure
# → lib/firebase_options.dart が自動生成

# 6. コード生成（Freezed, Riverpod）
flutter pub run build_runner build

# 7. iOS セットアップ（macOS のみ）
cd ios && pod install && cd ..

# 8. アプリを起動
flutter run
```

---

## 📚 ドキュメント

| ドキュメント | 説明 |
|-------------|------|
| **[CLAUDE.md](./CLAUDE.md)** | プロジェクト概要・技術仕様・開発ガイド |
| **[CODE_HANDOVER.md](./CODE_HANDOVER.md)** | コード引き継ぎ書・実装タスク・チェックリスト |
| **[企画・設計書](./docs/toriverse_kikaku_sekkei_v1_0.md)** | 企画フェーズ・設計フェーズの完全ドキュメント |

---

## 📁 プロジェクト構造

```
toriverse/
├── lib/
│   ├── main.dart                      # エントリーポイント
│   ├── config/                        # 設定・定数
│   ├── features/
│   │   ├── auth/                      # 認証機能
│   │   ├── home/                      # ホーム画面
│   │   ├── match/
│   │   │   ├── domain/                # ビジネスロジック（オセロ判定等）
│   │   │   ├── application/           # ゲーム状態管理（Riverpod）
│   │   │   ├── presentation/          # UI・画面
│   │   │   └── data/                  # Firestore 連携
│   │   ├── results/                   # リザルト画面
│   │   ├── shop/                      # ショップ（課金）
│   │   └── analytics/                 # 計測
│   ├── shared/
│   │   ├── models/                    # 共有データモデル
│   │   ├── services/                  # Firebase, Analytics 等
│   │   ├── widgets/                   # 共有 UI コンポーネント
│   │   └── utils/                     # ユーティリティ関数
│   └── l10n/                          # 国際化（日本語優先）
├── test/
│   ├── unit/                          # ユニットテスト
│   ├── widget/                        # ウィジェットテスト
│   └── integration/                   # 統合テスト
├── android/                           # Android ネイティブ
├── ios/                               # iOS ネイティブ
├── pubspec.yaml                       # 依存関係・バージョン
├── analysis_options.yaml              # Dart lint 設定
├── CLAUDE.md                          # プロジェクト文書
├── CODE_HANDOVER.md                   # コード引き継ぎ書
└── README.md                          # このファイル
```

---

## 🎮 ゲームフロー

```
起動
 ↓
オンボーディング（3色ルール・救済カード・弱者ボーナス説明）
 ↓
ホーム画面
 ├── [マッチング開始] → 待機 → 対局開始
 ├── [フレンド対戦] → 専用ルーム
 └── [ショップ] → 盤面・石デザイン購入

対局フロー（ラウンド制）
 1. 自分の手を提出（他者の手は非公開）
 2. 全員提出 or タイムアウト
 3. くじ引き演出（処理順抽選）
 4. 反転アニメーション
 5. ボーナス・救済カード発動チェック
 ↓
終局
 ↓
リザルト（順位・ストリーク・クリップ）
 ↓
シェア（任意）
```

---

## 🔧 開発ガイド

### テスト実行

```bash
# 全テスト
flutter test

# ユニットテストのみ
flutter test test/unit/

# カバレッジ計測
flutter test --coverage

# コード分析
flutter analyze
```

### ビルド

```bash
# デバッグビルド
flutter build apk --debug      # Android
flutter build ios --debug      # iOS (Xcode が必要)

# リリースビルド
flutter build apk --release    # Android
flutter build ios --release    # iOS
```

### Firebase セットアップ

```bash
# Firebase CLI インストール
npm install -g firebase-tools

# ログイン
firebase login

# エミュレータ起動
firebase emulators:start
```

---

## 🐛 トラブルシューティング

### Firebase に接続できない
- `firebaseOptions.dart` が正しく生成されたか確認
- `.env` に正しい API キーが設定されているか確認
- Firestore セキュリティルールが許可していないか確認

### オセロ判定がおかしい
- 境界値テスト（盤の隅・端）を実行
- 8方向すべてで反転処理が走っているか確認
- 内部値（0/1/2/3）と表示色が混同していないか確認

### マッチング成立しない
- Firestore に `match` document が生成されているか確認
- リアルタイムリスナーが動作しているか Firebase Console で確認
- AI インスタンス化のタイミングを調整（1秒遅延）

---

## 📊 計測・分析

### Firebase Analytics KPI（5個）
- `match_completed` — マッチ完了
- `full_human_match_started` — 3人フル人間戦開始
- `weak_bonus_triggered` — 弱者ボーナス発動
- `rescue_card_used` — 救済カード使用
- `clip_shared` — クリップシェア

### Remote Config
- 弱者ボーナス閾値
- 救済カード発動条件
- 提出ウィンドウ時間
- 広告視聴無料枠回数

---

## ⚠️ 致命的リスク & 対策

| リスク | 対策 |
|--------|------|
| 3人マッチング成立性（cold-start） | MVP を非同期対戦に変更 + AI 補完 |
| リアルタイム同期の複雑性 | Firestore リアルタイムリスナー採用 |
| ルール上の穴（同マス被り・処理順） | ランダム抽選 + 救済カード付与で解決 |
| 弱者ボーナス → タンク戦略・膠着 | 終盤除外・閾値制・回数上限で対処 |

---

## 📅 ロードマップ

### MVP（Q3-Q4 2026）
- ✅ 3色オセロ本体
- ✅ 非同期同時公開制
- ✅ ボーナス・救済カード機構
- ✅ ソフトローンチ

### Phase 2（Q4 2026-Q1 2027）
- リアルタイム観戦モード
- 配信連携（OBS/YouTube Live）
- リーダーボード・シーズンランク

### Phase 3（Q1-Q2 2027以降）
- トーナメント機能
- クラン・ギルド
- グローバル展開

---

## 👥 開発チーム

| 役割 | 担当者 |
|------|--------|
| **PM/企画** | zka32101 |
| **実装（リード）** | Claude |
| **テスト・QA** | TBD |

---

## 📄 ライセンス

**Private（非公開）**  
このプロジェクトの無断複製・利用を禁止します。

---

## 🤝 コントリビューション

現在、プライベートプロジェクトのため外部からのコントリビューションは受け付けていません。

---

## 📞 サポート

質問や問題がある場合は、GitHub Issues から報告してください。

---

**最終更新**: 2026-08-27  
**プロジェクトステータス**: 🚀 MVP 実装フェーズ  
**目標リリース**: 2026年Q4（ソフトローンチ）