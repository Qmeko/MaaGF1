# MaaGF1 — 本家 MFAAvalonia（日本語 UI 試用）

ドールズフロントライン **Steam 日本語版** 向けの **MaaFramework / MFAAvalonia** 専用フォルダです。

| 兄弟フォルダ | 役割 |
|-------------|------|
| **MaaGF1**（本フォルダ） | 本家 GUI・`assets/` パイプライン・`install/MFAAvalonia.exe` |
| [NewMaaGfl1](../NewMaaGfl1/) | GflAssistant・座標ピッカー・フローチャート（SendInput 主系） |
| [MaaNX](../MaaNX/) | 前身（参照のみ） |

## クイックスタート

```powershell
cd <リポジトリルート>   # 例: Desktop\MaaGF1
.\tools\setup.ps1
.\scripts\run-maafavalonia.bat
```

| 設定 | 値 |
|------|-----|
| 言語 | **ja-JP** |
| リソース | **日本語版 (Steam)** |
| コントローラー | **バックグラウンド高性能** |

初回確認タスク: **0.接続テスト**（基地画面・1280×720）

詳細: [docs/USAGE.ja.md](docs/USAGE.ja.md)
