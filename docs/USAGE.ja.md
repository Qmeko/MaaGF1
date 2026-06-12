# MaaGF1 使い方

## 1. 初回セットアップ

```powershell
cd <リポジトリルート>
.\tools\setup.ps1
```

- MFAAvalonia v2.12.1 を `install/` に展開
- `assets/` を `install/` に同期
- OCR モデル（`fetch_ocr_model.ps1`）を取得

起動に失敗する場合: `install\DependencySetup_依赖库安装_win.bat`（.NET 10 / VC++）

## 2. 起動

scripts\run-maafavalonia.bat

## 3. MFAAvalonia 設定

| 項目 | 値 |
|------|-----|
| 言語 | ja-JP |
| リソース | 日本語版 (Steam) |
| コントローラー | バックグラウンド高性能 |

## 4. 接続テスト

1. ゲームを **1280×720** ウィンドウで起動
2. **基地画面**（開発/後方/工廠/宿舎タブ）まで進む
3. MFAAvalonia で **0.接続テスト** を実行

ログ: `install/debug/maafw.log`

## 5. リソース更新

**MFAAvalonia 内の「リソースパッケージをダウンロード」は使わないでください。**  
公式 MaaGF1 v2（中国語）で `install/` が上書きされ、UI が zh-CN に戻ります。

中国語版 MFA に戻ってしまったときは、公式 MFAAvalonia を復元してから日本語化をやり直します。

```powershell
.\tools\restore_official_mfa.ps1   # 公式 v2.12.1 の exe/DLL のみ差し替え
.\tools\build_jp_ui.ps1            # 翻訳同期 + ja-JP 設定（推奨・一括）
```

正本は `assets/` です。変更後は次だけ実行します。

```powershell
.\tools\sync_assets.ps1
.\tools\apply_jp_config.ps1   # CurrentLanguage を ja-JP に戻す
```

`run-maafavalonia.bat` は起動前に自動で `apply_jp_config.ps1` を実行します。

MFAAvalonia を再起動する。

### MaaGF1 公式マニュアル（日中对訳フォーク）

中国語の [公式マニュアル](https://maagf1.github.io/docs/) を、行の下に日本語を追記したフォークを `maagf1-docs/` で管理しています。

```powershell
# ローカルプレビュー
.\tools\serve_maagf1_docs.ps1

# GitHub にフォークして push（初回のみ gh auth login）
.\tools\fork_maagf1_docs.ps1
```

翻訳済み: **全18ページ**（`maagf1-docs\README.ja.md` 参照）。

### 段階 C: UI 全文日本語化

一括実行:

```powershell
.\tools\build_jp_ui.ps1
```

個別実行:

```powershell
.\tools\translate_phase_c.ps1
.\tools\sync_assets.ps1
.\tools\apply_jp_config.ps1
```

- タスク名・説明・オプション・選択肢に日本語 `label` を付与
- `lang/ja-JP.json` を拡張（50項目以上）
- 接続設定: `Win32_Background` / `Resource_JP` / `ja-JP`

**ゲームに接続できないとき**

1. ゲームを **1280×720** で起動（ウィンドウ名: `ドールズフロントライン`）
2. MFAAvalonia で **接続先を更新**（リフレッシュ）し、ゲームウィンドウを選択
3. コントローラー: **バックグラウンド高性能**、リソース: **日本語版 (Steam)**
4. リソースパッケージの DL/更新は使わない

### 段階 B: MaaGF1 v2 追加分を日本語に統合済み

すでに CN パッケージを DL してしまった場合（`install/interface.json` が `MaaGF1` / `Resource_CN` のとき）:

```powershell
.\tools\merge_maagf1_jp.ps1   # install/resource を assets/resource_jp にマージ
.\tools\sync_assets.ps1
.\tools\apply_jp_config.ps1
```

- JP 専用タスク（接続テスト・宿舎いいね・13-4 JP 校正・主画面へ戻る）は保護されます
- CN 追加分タスクは一覧に日本語名で統合されます（計 25 タスク）
- CN 由来のテンプレ画像は JP クライアントではそのまま使えない場合があります。座標ピッカーで撮り直してください

## 6. テンプレ確認

```bat
scripts\check-templates.bat
```

座標ピッカー（NewMaaGfl1 側）:

```bat
..\NewMaaGfl1\gfl-assistant\scripts\coord-picker.bat
```
