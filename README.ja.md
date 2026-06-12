# MaaGF1 — Steam 日本語版フォーク（MFAAvalonia）

[MaaGF1/MaaGF1](https://github.com/MaaGF1/MaaGF1) の **Public フォーク**です。  
ドールズフロントライン **Steam 日本語版** 向けに `resource_jp`・`ja-JP` UI・ビルドスクリプトを追加しています。

| 項目 | 内容 |
|------|------|
| 本家 | [MaaGF1/MaaGF1](https://github.com/MaaGF1/MaaGF1) |
| MFAAvalonia 表示名 | **MaaGfl1**（`interface.json`） |
| 兄弟フォルダ | [NewMaaGfl1](../NewMaaGfl1/) — GflAssistant・座標ピッカー |
| 前身 | [MaaNX](../MaaNX/)（参照のみ） |

## クイックスタート

```powershell
cd <リポジトリルート>   # 例: Desktop\MaaGF1
.\tools\setup.ps1
.\tools\build_jp_ui.ps1          # 初回・CN上書き後は必須
.\scripts\run-maafavalonia.bat
```

| 設定 | 値 |
|------|-----|
| 言語 | **ja-JP** |
| リソース | **日本語版 (Steam) / Resource_JP** |
| コントローラー | **バックグラウンド高性能** |

初回確認タスク: **0.接続テスト**（基地画面・1280×720）

**重要:** MFAAvalonia 内の「リソースパッケージをダウンロード」は使わないでください（中国語で上書きされます）。

詳細: [docs/USAGE.ja.md](docs/USAGE.ja.md)

## upstream 同期

```powershell
git fetch upstream
git merge upstream/main    # 競合時は merge_maagf1_jp.ps1 で JP を再適用
```

## ドキュメント（日中对訳）

公式マニュアルの日本語訳は `maagf1-docs/`（別リポジトリ）で管理します。

```powershell
.\tools\serve_maagf1_docs.ps1   # ローカルプレビュー
.\tools\fork_maagf1_docs.ps1    # 自分の docs フォークへ push
```

## ローカル実行環境

`install/` は git 管理外です（`.gitignore`）。clone 後は `setup.ps1` で MFAAvalonia を展開してください。
