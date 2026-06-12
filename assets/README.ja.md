# MaaGF1 assets（日本語リソース正本）

MaaFramework の **日本語版（Steam）** ソースはこの `assets/` が正本です。

## 構成

```
assets/
├── interface.json       # タスク一覧・コントローラー設定（表示名 MaaGfl1）
├── lang/
│   ├── ja-JP.json       # UI 文言
│   └── zh-cn.json       # ja-JP ミラー（MFAAvalonia フォールバック用）
└── resource_jp/
    ├── pipeline/        # タスク JSON
    ├── image/           # テンプレ画像
    └── model/ocr/       # OCR モデル（setup で取得）
```

## 編集後の反映

```powershell
.\tools\sync_assets.ps1
.\tools\apply_jp_config.ps1
```

一括ビルド（CN 上書き後の復旧含む）:

```powershell
.\tools\build_jp_ui.ps1
```

## GflAssistant との連携

宿舎テンプレ画像:

```
assets/resource_jp/image/dormitory/
    ↓ ../NewMaaGfl1/gfl-assistant/scripts/sync-dormitory-templates.ps1
../NewMaaGfl1/gfl-assistant/Assets/templates/dormitory/
```

## 注意

- MFAAvalonia 内のリソース DL は **禁止**（中国語で上書きされます）
- upstream 更新時は `merge_maagf1_jp.ps1` で CN 追加分をマージ
