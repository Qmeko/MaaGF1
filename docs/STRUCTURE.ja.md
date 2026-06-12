# MaaGF1 ファイル構成（正本）

## ディレクトリ

```
MaaGF1/
├── README.ja.md
├── docs/
│   ├── STRUCTURE.ja.md    # 本ファイル
│   ├── USAGE.ja.md
│   └── TEMPLATE_CHECKLIST.ja.md
├── assets/                # MaaFramework ソース（編集はここ）
│   ├── interface.json
│   ├── lang/ja-JP.json
│   └── resource_jp/
├── install/               # MFAAvalonia 実行環境（setup.ps1・gitignore 想定）
├── tools/
│   ├── setup.ps1
│   ├── sync_assets.ps1
│   ├── fetch_ocr_model.ps1
│   ├── check_templates.ps1
│   └── init_image_dirs.ps1
└── scripts/
    ├── run-maafavalonia.bat
    ├── setup.bat
    └── check-templates.bat
```

## データの流れ

```
[開発]  assets/ を編集
           ↓ tools/sync_assets.ps1
[実行]  install/ ← MFAAvalonia

[画像]  assets/resource_jp/image/dormitory/
           ↓ NewMaaGfl1 の sync-dormitory-templates.ps1
[連携]  NewMaaGfl1/gfl-assistant/Assets/templates/dormitory/
```

## 名称対応

| 呼び名 | 実体 |
|--------|------|
| MaaGF1 | `Desktop\MaaGF1\` |
| NewMaaGfl1 | `Desktop\NewMaaGfl1\` |
| MFAAvalonia | `install\MFAAvalonia.exe` |
