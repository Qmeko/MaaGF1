# MaaGF1 ファイル構成（正本）

**日本語化・MFAAvalonia の作業ルートはこのフォルダです。**

## ディレクトリ

```
MaaGF1/                          # 本作業フォルダ（Git: Qmeko/MaaGF1）
├── README.ja.md
├── memo.md                      # 作業メモ（ローカル）
├── .cursor/rules/               # Cursor ルール
├── docs/                        # 日本語ドキュメント正本
│   ├── STRUCTURE.ja.md          # 本ファイル
│   ├── USAGE.ja.md
│   ├── ARCHITECTURE.ja.md
│   ├── ROADMAP.ja.md
│   └── ...
├── assets/                      # MaaFramework ソース（編集はここ）
│   ├── interface.json
│   ├── lang/ja-JP.json
│   └── resource_jp/
├── install/                     # MFAAvalonia 実行環境（gitignore）
├── maagf1-docs/                 # 公式 docs 日中对訳（別 git）
├── tools/
│   ├── setup.ps1
│   ├── build_jp_ui.ps1          # 日本語 UI 一括ビルド
│   ├── merge_maagf1_jp.ps1
│   ├── sync_assets.ps1
│   └── migrate_jp_from_newmaagfl1.ps1
└── scripts/
    └── run-maafavalonia.bat

../NewMaaGfl1/                   # 兄弟フォルダ（GflAssistant 主系）
├── gfl-assistant/
├── agent/
└── scripts/                     # MFA 起動は ../MaaGF1 へ委譲
```

## データの流れ

```
[日本語化]  assets/ を編集
              ↓ tools/sync_assets.ps1
[実行]      install/ ← MFAAvalonia

[画像]      assets/resource_jp/image/dormitory/
              ↓ NewMaaGfl1/gfl-assistant/scripts/sync-dormitory-templates.ps1
[連携]      NewMaaGfl1/gfl-assistant/Assets/templates/dormitory/
```

## 名称対応

| 呼び名 | 実体 |
|--------|------|
| MaaGF1 | `Desktop\MaaGF1\`（本作業フォルダ） |
| NewMaaGfl1 | `Desktop\NewMaaGfl1\`（GflAssistant） |
| MFAAvalonia 表示名 | **MaaGfl1**（`interface.json`） |
| 旧名 MaaNX | 前身（参照のみ） |

## パス変更時に更新するファイル

1. `docs/STRUCTURE.ja.md`（本ファイル）
2. `docs/USAGE.ja.md`, `docs/README.ja.md`, `README.ja.md`
3. `.cursor/rules/maagfl1-structure.mdc`
4. `../NewMaaGfl1/.cursor/rules/maagfl1-structure.mdc`
