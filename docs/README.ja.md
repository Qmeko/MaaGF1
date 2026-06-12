# MaaGF1 ドキュメント

**作業フォルダ（日本語化・MFAAvalonia）の正本は `MaaGF1/` です。**

## ドキュメント一覧

| ドキュメント | 内容 |
|---|---|
| **[STRUCTURE.ja.md](./STRUCTURE.ja.md)** | ファイル構成の正本 |
| **[USAGE.ja.md](./USAGE.ja.md)** | セットアップ・実行・日本語化（**まずここ**） |
| **[ARCHITECTURE.ja.md](./ARCHITECTURE.ja.md)** | pipeline・連携構成 |
| **[ROADMAP.ja.md](./ROADMAP.ja.md)** | 開発ロードマップ |
| **[TEMPLATE_CHECKLIST.ja.md](./TEMPLATE_CHECKLIST.ja.md)** | テンプレ撮影チェックリスト |
| **[FLOWCHART_SYSTEM.ja.md](./FLOWCHART_SYSTEM.ja.md)** | 座標ピッカー JSON 構造（GflAssistant） |
| [disclaimer.md](./disclaimer.md) | 免責事項 |
| [maagf1-docs/](../maagf1-docs/) | 公式マニュアル日中对訳 |

## GflAssistant（兄弟フォルダ）

| ドキュメント | 内容 |
|---|---|
| [../NewMaaGfl1/gfl-assistant/README.ja.md](../NewMaaGfl1/gfl-assistant/README.ja.md) | GflAssistant 概要 |
| [../NewMaaGfl1/gfl-assistant/docs/DORMITORY_TOUR.ja.md](../NewMaaGfl1/gfl-assistant/docs/DORMITORY_TOUR.ja.md) | 宿巡回 |
| [../NewMaaGfl1/gfl-assistant/docs/MaaGfl1_DORMITORY_TOUR.ja.md](../NewMaaGfl1/gfl-assistant/docs/MaaGfl1_DORMITORY_TOUR.ja.md) | Maa パイプライン宿巡回 |
| [../NewMaaGfl1/gfl-assistant/docs/MaaGfl1_TEMPLATE_CAPTURE.ja.md](../NewMaaGfl1/gfl-assistant/docs/MaaGfl1_TEMPLATE_CAPTURE.ja.md) | テンプレ撮影 |

## クイックスタート（MFAAvalonia）

```powershell
cd <リポジトリルート>
.\tools\setup.ps1
.\tools\build_jp_ui.ps1
.\scripts\run-maafavalonia.bat
```

GflAssistant:

```powershell
cd ..\NewMaaGfl1\gfl-assistant
dotnet build
..\scripts\run-dormitory.bat
```
