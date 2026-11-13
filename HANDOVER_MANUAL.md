# LumaLock Studio Suite — 開発引き継ぎマニュアル & 3点セット設計書

本ドキュメントは、**「画像ファーストレタッチ（LumaLock Pro）」「はむはむ画像圧縮くん」「かんたんZIP圧縮くん」** の3アプリを、統一ブランドのプロ仕様ユーティリティ・スイートとして開発・リリースするための **1つの統合ワークスペース一式** と、**別マシンの Antigravity へシームレスに作業を引き継ぐための完全マニュアル** です。

---

## 1. 別マシン（Mac / Windows）での環境構築・引き継ぎ手順（3ステップ）

別マシンでは、これまでの作業場所（`/Users/r-site/Pictures/土壌の写真`）から完全に切り離し、この統合ワークスペース単体で開発を進めます。

### 方法 A：GitHub から取得する（推奨・USB不要）

1. **統合ワークスペースをクローンしてセットアップスクリプトを実行**

   **macOS (Apple Silicon / macOS 15 以降推奨) の場合:**
   ```bash
   cd ~/Documents
   git clone https://github.com/mixography-max/lumalock-suite-workspace.git LumaLock_Suite_Workspace
   cd LumaLock_Suite_Workspace
   chmod +x setup_mac.sh
   ./setup_mac.sh
   ```

   **Windows (PowerShell) の場合:**
   ```powershell
   cd $HOME\Documents
   git clone https://github.com/mixography-max/lumalock-suite-workspace.git LumaLock_Suite_Workspace
   cd LumaLock_Suite_Workspace
   .\setup_windows.ps1
   ```

2. **GitHub CLI (`gh`) のログイン確認**（新規リポジトリ作成・リリース用）
   ```bash
   gh auth status
   # 未ログインの場合:
   gh auth login
   ```
   アカウント `mixography-max`（`repo` / `workflow` スコープ）で認証されていることを確認してください。

3. **Antigravity で開く**
   - Antigravity IDE を起動し、フォルダとして **`LumaLock_Suite_Workspace`** を開くか、`File` → `Open Workspace from File...` から **`LumaLock_Suite.code-workspace`** を開いてください。

### 方法 B：フォルダ丸ごとコピーして移行する場合

この `LumaLock_Suite_Workspace` フォルダを丸ごと新マシンの `~/Documents/` にコピーし、ターミナルで `./setup_mac.sh`（または `.\setup_windows.ps1`）を1回実行すれば、`npm install` と Antigravity カスタムスキル（`~/.gemini/config/skills/scientific-photo-harmonizer/`）の配置まで完了します。

---

## 2. 別マシンの Antigravity に最初に貼り付ける「引き継ぎプロンプト」

別マシンで Antigravity を開き、最初のチャットに以下を **そのままコピー＆ペースト** してください。これにより、別マシンの Antigravity が即座に全設計・技術知見・進捗を把握して作業を続行できます。

```text
このワークスペース（LumaLock_Suite_Workspace）の HANDOVER_MANUAL.md を読み込んでください。
現在、以下の3アプリを統一ブランド「LumaLock Studio Suite」プロ仕様3点セットとして仕上げてリリースするプロジェクトを進めています。

1. apps/lumalock-pro（LumaLock Pro — 完了済・v1.0.0 リリース済・リファレンス実装）
2. apps/kantan-image-compression（旧「はむはむ画像圧縮くん」→ プロ仕様へリネーム・リデザイン予定）
3. apps/KantanZIP（旧「かんたんZIP圧縮くん」→ プロ仕様へリネーム・リデザイン・Tauri統一予定）

HANDOVER_MANUAL.md に記載された共通デザインシステム・Tauri v2 設定・TypeScript 7.0.2 対応・GitHub Actions（macos-15 + windows-latest）の仕様を踏襲し、まずは第2弾（画像圧縮アプリ）のプロ仕様化（リネーム・UI刷新・6言語対応・CI/CD整備）の設計から相談・着手したいです。現状の各アプリの構成を確認して準備ができたら教えてください。
```

---

## 3. ワークスペース構成

```text
LumaLock_Suite_Workspace/
├── HANDOVER_MANUAL.md                  # 本ドキュメント（引き継ぎマニュアル）
├── README.md                           # 概要・クイックスタート
├── LumaLock_Suite.code-workspace       # マルチルートワークスペース設定
├── setup_mac.sh                        # macOS 用自動セットアップ
├── setup_windows.ps1                   # Windows 用自動セットアップ
├── assets/
│   └── lumalock_pro_icon_reference.jpg # LumaLock Pro アプリアイコン参考画像
├── skills/
│   └── scientific-photo-harmonizer/    # 学術写真ハーモナイザー用カスタムスキル
│       └── SKILL.md
└── apps/                               # 3アプリのリポジトリ（独立した Git 管理）
    ├── lumalock-pro/                   # 【第1弾・完成】mixography-max/lumalock-pro
    ├── kantan-image-compression/       # 【第2弾・改修対象】mixography-max/kantan-image-compression
    └── KantanZIP/                      # 【第3弾・改修対象】mixography-max/KantanZIP
```

> **注意**: 親フォルダ（`LumaLock_Suite_Workspace`）は `.gitignore` で `apps/` を除外しています。各アプリのソースコードの変更・コミット・プッシュは、それぞれ `apps/lumalock-pro/`・`apps/kantan-image-compression/`・`apps/KantanZIP/`（または新リポジトリ）の配下で行ってください。

---

## 4. プロ仕様 3点セット「LumaLock Studio Suite」全体設計

3アプリとも「親しみやすい個人向け日本語版」は現行リポジトリに残しつつ、プロ仕様スイートでは **クールなダーク・スタジオ UI＋英語圏を含む世界市場向け6言語（EN / JA / ZH / ES / DE / FR）＋ Mac / Windows 両対応＋ CLI 同梱** に統一します。

| # | 現行名 / 現行リポジトリ | 推奨プロ版名称・新リポジトリ案 | コア価値（プロ訴求） | アクセントカラー | CLI バイナリ名 | 状態 |
|---|---|---|---|---|---|---|
| **1** | （旧：`image-first-retouch-kun`）<br>`mixography-max/lumalock-pro` | **LumaLock Pro**<br>`mixography-max/lumalock-pro` | CIE $L^*a^*b^*$ 色彩100%保全（$\Delta a^*=0, \Delta b^*=0$）露出・コントラスト調和スタジオ | Optical Cyan `#06b6d4` | `lumalock` | ✅ **v1.0.0 公開済** |
| **2** | はむはむ画像圧縮くん<br>`mixography-max/kantan-image-compression` | **OptiLock Pro** 候補（または CrunchLock Pro / PixelPress Pro）<br>新: `mixography-max/optilock-pro` | Google Jpegli + Oxipng + WebP/AVIF/JXL + SSIM/CIEDE2000 自動品質制御スタジオ | Precision Emerald `#10b981` | `optilock` | 🟡 **改修予定** |
| **3** | かんたんZIP圧縮くん<br>`mixography-max/KantanZIP` | **ArcLock Pro** 候補（または VaultLock Pro / BridgeZip Pro）<br>新: `mixography-max/arclock-pro` | Mac↔Win 文字化けゼロ（NFD→NFC + UTF-8）・パス長検証・禁止文字検査・`.DS_Store`完全除去 | Archive Violet `#8b5cf6` | `arclock` | 🟡 **改修予定** |

### 価格・バンドル戦略（参考）
- **単体ライセンス（買い切り）**: \$24〜\$29（日本円 3,600〜4,400円前後）
- **3点セット「LumaLock Studio Suite」バンドル**: \$59（日本円 8,800円前後 / 約30%オフ）
- **販売チャネル**: Gumroad / Lemon Squeezy / Booth（Windows + macOS クロスOSライセンスキーまたはインストーラ直販）＋ GitHub Releases による配布パイプライン

---

## 5. 各アプリの現状詳細と改修設計

### 5.1 【第1弾・完成済】LumaLock Pro (`apps/lumalock-pro`)

第2弾・第3弾のリファレンス実装です。迷ったらまず `apps/lumalock-pro/` のソースコードを参照してください。

- **リポジトリ**: https://github.com/mixography-max/lumalock-pro
- **リリース**: https://github.com/mixography-max/lumalock-pro/releases/tag/v1.0.0
- **技術スタック**:
  - Tauri v2 (`@tauri-apps/api` `^2.10.1`, `@tauri-apps/plugin-dialog` `^2.6.0`, `@tauri-apps/plugin-opener` `^2.5.3`)
  - React `^19.1.0` + TypeScript `^7.0.2` + Vite `^7.0.4`（Dev port: `15200`）
  - Pure Rust バックエンド + スタンドアロン CLI (`lumalock`)
- **実装済プロ機能**:
  - JPEG / PNG / **TIFF** 対応
  - 3プリセット（`Standard L*=122`, `Dark Specimen L*=110`, `Bright Studio L*=136`）＋ Target $L^*$ カスタムスライダー（90〜160）
  - アプリ内 **Before / After スプリット比較モーダル**（`get_preview_pair` コマンドで TIFF も JPEG Base64 変換して即時表示）
  - **`lumalock_metrics.csv`** 自動出力（UTF-8 BOM付）
  - **Academic Methods 引用文ワンクリックコピー**
  - **6言語対応**（`src/i18n.ts`: `en`, `ja`, `zh`, `es`, `de`, `fr`）＋ `comparison_viewer.html` 生成

---

### 5.2 【第2弾・改修対象】はむはむ画像圧縮くん → OptiLock Pro (`apps/kantan-image-compression`)

- **現行リポジトリ**: https://github.com/mixography-max/kantan-image-compression （最新タグ `v1.4.4`、ロードマップ追記済み `8c371de`）
- **現行技術スタック**:
  - Tauri v2 + React `^19.1.0` + TypeScript `~5.8.3` + Vite `^7.0.4`（Dev port: `15000`）
  - Rust バックエンド（`oxipng`, `image`, `rayon`, `clap`）＋同梱バイナリ（`cjpegli`, `pngquant`, `ect`, `gs`, `cwebp`, `cjxl`, `avifenc` 等）
  - CLI バイナリ: `hamham-compress`
- **プロ仕様化・改修チェックリスト**:
  1. **ブランディング＆アイコン刷新**:
     - 「はむはむ」「ハムスター」「もぐもぐゲージ」などの可愛い演出を完全撤廃し、LumaLock Pro と統一されたクールなスタジオ名称（例: **OptiLock Pro**）と幾何学アイコンを設計（`image-generator` サブエージェント等で作成、`npx tauri icon` で一括生成）。
  2. **UI デザイン統一（LumaLock Design System 適用）**:
     - `apps/lumalock-pro/src/styles.css`・`App.css` をベースに、ダークスタジオ配色（背景 `#0d0f12`、カード `#14181d`、アクセント `#10b981` Emerald）へ刷新。
     - 等幅フォント（`tabular-nums`）で Before/After 容量・削減率・SSIM・CIEDE2000 ΔE をプロ用計測器のように表示。
  3. **多言語化（6言語対応）**:
     - `lumalock-pro/src/i18n.ts` と同じ構成で `en`, `ja`, `zh`, `es`, `de`, `fr` の言語切替を搭載。
  4. **ビフォーアフター比較ビューア追加**:
     - LumaLock Pro と同様にスライダーで原画像と圧縮後をピクセル比較できるモーダルを追加（`CIEDE2000` / `SSIM` スコア表示付き）。
  5. **TypeScript 7.0.2 & Tauri v2 Drag&Drop 確認**:
     - `"typescript": "^7.0.2"` へアップグレードし `src/vite-env.d.ts` を追加。
     - `src-tauri/capabilities/default.json` と `onDragDropEvent` が macOS 15 / Windows 両方で確実に動くよう統一。
  6. **CI/CD 更新（`macos-15` 対応）**:
     - `.github/workflows/build.yml` の `macos-14` を `macos-15`（`aarch64-apple-darwin`）へ更新し、`minimumSystemVersion: "15.0"` を設定。CLI バイナリ名も `optilock` へ変更。
  7. **別リポジトリとして分離リリース**:
     - 既存の「はむはむ画像圧縮くん」を破壊しないよう、新リポジトリ（例: `mixography-max/optilock-pro`）を作成してプッシュ＆ `v1.0.0` リリースを推奨。

---

### 5.3 【第3弾・改修対象】かんたんZIP圧縮くん → ArcLock Pro (`apps/KantanZIP`)

- **現行リポジトリ**: https://github.com/mixography-max/KantanZIP
- **現行技術スタック（二重実装状態）**:
  - **macOS 版**: SwiftUI / Swift Package (`Package.swift` + `Sources/KantanZIP/` + `ZIPFoundation`)
  - **Windows 版**: C# / .NET 10 / Avalonia (`KantanZIP_Win/KantanZIP_Win.csproj`)
- **なぜプロ仕様化で Tauri v2 + Rust へ統合すべきか**:
  - 現状は macOS (Swift) と Windows (C# Avalonia) でコードベースが完全に分断されており、デザイン統一・6言語化・機能同期に2倍のコストがかかります。
  - **LumaLock Pro と同じ Tauri v2 + React 19 + TypeScript 7.0.2 + Pure Rust に統合** すれば、以下のコア機能を単一コードベースで Mac / Windows / CLI に同時提供できます：
    - `unicode-normalization` クレートによる **NFD → NFC 完全正規化**（Macの濁点・半濁点分離問題をゼロに）
    - `zip` クレートによる **UTF-8 フラグ（GPBF bit 11）完全付与** ＋高効率 DEFLATE / Zstd 圧縮
    - `encoding_rs` クレートによる **Shift_JIS 換算パス長事前検証（260文字制限 / MAX_PATH チェック）**
    - **Windows 禁止文字（`\ / : * ? " < > |`）および予約デバイス名（`CON`, `PRN`, `AUX`, `NUL`, `COM1`..`COM9`, `LPT1`..`LPT9`）事前検出＆サニタイズ提案**
    - **不要ファイル自動除外ルール**（`.DS_Store`, `._*`, `__MACOSX`, `Thumbs.db`, `desktop.ini`, `~$*` 等）＋プリセット（Strict Windows Safe / Mac-Win Balanced / Raw）
    - アーカイブ診断レポート JSON / CSV 出力 ＋ CLI（`arclock`）
- **改修ステップ**:
  1. 新規 Tauri v2 プロジェクト（例: `mixography-max/arclock-pro`）を `apps/lumalock-pro` をテンプレートにして作成。
  2. 現行 `Sources/KantanZIP/Services/`（`ZipService.swift`, `PathValidator.swift`, `FileFilter.swift`）の検証ロジックを Pure Rust へ移植。
  3. ダークスタジオ UI（アクセント `#8b5cf6` Violet）＋ 6言語 i18n ＋「圧縮前プリフライトチェック（警告一覧とワンクリック修正）」画面を実装。
  4. `macos-15` + `windows-latest` GitHub Actions で `.dmg` / `.msi` / `.exe` / `arclock` CLI をリリース。

---

## 6. LumaLock Pro 開発で確立した重要技術知見（必ず踏襲すること）

第1弾の構築中に解決した落とし穴です。第2弾・第3弾では最初から以下を組み込んでください。

### 6.1 Tauri v2 のドラッグ＆ドロップとクリック選択（必須構成）
HTML5 標準の `onDrop` では Tauri v2 ウィンドウで OS ファイルパスが取得できません。必ず以下を設定してください。
1. **`src-tauri/capabilities/default.json`** に権限を明記する:
   ```json
   {
     "$schema": "../gen/schemas/desktop-schema.json",
     "identifier": "default",
     "description": "Capability for the main window",
     "windows": ["main"],
     "permissions": [
       "core:default",
       "core:event:default",
       "core:window:default",
       "core:webview:default",
       "opener:default",
       "opener:allow-open-path",
       "dialog:default",
       "dialog:allow-open"
     ]
   }
   ```
2. **フロントエンド（`App.tsx`）** で `getCurrentWebviewWindow().onDragDropEvent(...)` を購読して `drop` イベントの `event.payload.paths` を取得する。
3. ドロップゾーンのクリック時は `@tauri-apps/plugin-dialog` の `open({ multiple: true, directory: ... })` を呼び出し、ファイル選択とフォルダ選択の両方をサポートする。

### 6.2 TypeScript 7.0.2（`tsgo`）導入ルール
`package.json` で `"typescript": "^7.0.2"` を指定すると、TypeScript 6/7 系でデフォルト有効化される `noUncheckedSideEffectImports` により `import "./App.css";` で `TS2882` エラーが発生します。
- 対策: 必ず **`src/vite-env.d.ts`** を作成し、以下を1行記述してください：
  ```ts
  /// <reference types="vite/client" />
  ```

### 6.3 GitHub Actions と macOS 15 以降限定ビルド
- GitHub Actions の `macos-14` ランナーは廃止（`The configuration 'macos-14-arm64-us-default' is not supported` エラーになる）されているため、必ず **`macos-15`（`aarch64-apple-darwin`）** を使用してください。
- `src-tauri/tauri.conf.json` の `bundle.macOS` に `"minimumSystemVersion": "15.0"` を明記してください。
- Windows は **`windows-latest`（`x86_64-pc-windows-msvc`）** を使用してください。
- 複数アプリを同時起動して比較開発できるよう、Vite 開発ポートをずらしておくと便利です：
  - `lumalock-pro`: `15200`
  - `optilock-pro` (`kantan-image-compression`): `15000`
  - `arclock-pro`: `15300`

### 6.4 ローカル macOS で DMG ビルドがハングした場合の回避策
ローカル環境で `npx tauri build` を実行した際、内部の `bundle_dmg.sh`（Finder の AppleScript 呼び出し）がタイムアウトして止まることがあります。`.app` バンドル生成までは完了しているため、以下のコマンドで手動 `.dmg` 作成が可能です（GitHub Actions の `macos-15` ではハングせず正常に DMG が生成されます）：
```bash
hdiutil create -volname "AppName Pro" \
  -srcfolder "src-tauri/target/release/bundle/macos/AppName Pro.app" \
  -ov -format UDZO "AppName Pro_1.0.0_aarch64.dmg"
```

### 6.5 統一デザインシステム（CSS Variables）
`apps/lumalock-pro/src/styles.css` のトークンを全3アプリで共有し、`--accent` のみ各アプリのテーマカラーに変更します：
- 背景ベース: `--bg: #0d0f12` / `--surface: #14181d` / `--surface2: #1c2229` / `--border: #262d36`
- テキスト: `--text: #eef2f6` / `--text-muted: #8b95a5`
- ステータス: `--green: #10b981` / `--red: #ef4444`
- 各アプリのアクセントカラー:
  - LumaLock Pro: `--accent: #06b6d4` (Cyan)
  - OptiLock Pro (画像圧縮): `--accent: #10b981` (Emerald)
  - ArcLock Pro (ZIP圧縮): `--accent: #8b5cf6` (Violet)

---

## 7. 関連リソース・既存成果物一覧（参考）

別マシンへ移行前の環境にのみ存在していた配布物・既存URLの一覧です。

- **LumaLock Pro GitHub**: https://github.com/mixography-max/lumalock-pro
- **LumaLock Pro Releases (v1.0.0 macOS DMG / Win EXE & MSI / CLI)**: https://github.com/mixography-max/lumalock-pro/releases/tag/v1.0.0
- **画像ファーストレタッチくん（個人向け親しみ版）**: https://github.com/mixography-max/image-first-retouch-kun/releases/tag/v1.0.0
- **はむはむ画像圧縮くん（既存版）**: https://github.com/mixography-max/kantan-image-compression
- **かんたんZIP圧縮くん（既存版）**: https://github.com/mixography-max/KantanZIP
- **Antigravity 統合ワークスペース GitHub**: https://github.com/mixography-max/lumalock-suite-workspace
