# 構造詳細

正本: [STRUCTURE.ja.md](./STRUCTURE.ja.md)  
使い方: [USAGE.ja.md](./USAGE.ja.md)  
計画: [ROADMAP.ja.md](./ROADMAP.ja.md)

---

## 1. 全体像

```
ドールズフロントライン Steam (Unity / 日本語)
         │
    ┌────┴────────────┐
    ▼                 ▼
 install/         ../NewMaaGfl1/gfl-assistant/
(MFAAvalonia)     (C# SendInput・推奨)
    ▲                 ▲
 assets/          ../NewMaaGfl1/agent/ (Python・暫定)
```

| コンポーネント | パス | 役割 |
|---|---|---|
| MaaGfl1 リソース | `assets/` | pipeline・画像・OCR |
| 実行環境 | `install/` | MFAAvalonia |
| GflAssistant | `../NewMaaGfl1/gfl-assistant/` | SendInput 自動化（主系） |
| Python Agent | `../NewMaaGfl1/agent/` | 暫定 BT 実装 |

---

## 2. 二系統の自動化

### MFAAvalonia（MaaFramework pipeline）

- OCR + TemplateMatch で画面を認識
- Win32 入力（Unity ではクリックが効かない場合あり）
- 設定: `assets/interface.json` + `assets/resource_jp/pipeline/`

### GflAssistant（SendInput）

- WGC キャプチャ + OpenCV テンプレートマッチ
- SendInput で実カーソル操作（Unity 対応）
- 設定: `../NewMaaGfl1/gfl-assistant/Assets/screens.json` + `templates/`

| タスク | 推奨実行 |
|---|---|
| 接続テスト / 13-4 / 戻る | MFAAvalonia |
| 宿巡回 / 後方支援 | **gfl-assistant** |

---

## 3. assets/ と pipeline

```
assets/
├── interface.json
├── lang/ja-JP.json
└── resource_jp/
    ├── model/ocr/          # det.onnx, rec.onnx, keys.txt
    ├── image/
    │   ├── dormitory/      # 宿舎いいね用 PNG
    │   └── combat/levelUp/13-4/
    └── pipeline/
        ├── public/         # 共通ナビ
        └── tasks/          # タスク別 JSON
```

### 日本語 OCR ノード例

```json
{
  "jp_dorm_フレンドタブ": {
    "recognition": "OCR",
    "roi": [571, 597, 209, 123],
    "expected": "フレンド",
    "action": "Click"
  }
}
```

---

## 4. gfl-assistant 構成

```
../NewMaaGfl1/gfl-assistant/
├── GflAssistant/
│   ├── Tasks/
│   │   ├── DormitoryLikeTask.cs      # HOME から宿巡回
│   │   ├── MaaGfl1DormitoryTask.cs    # Maa パイプライン準拠
│   │   └── LogisticsWatchTask.cs      # 後方支援
│   └── Core/
│       ├── Capture/   # WGC
│       ├── Vision/    # OpenCV
│       └── Input/     # SendInput
└── Assets/
    ├── screens.json
    ├── nav_steps.json
    ├── maagfl1_nav_steps.json
    └── templates/
```

---

## 5. テンプレート画像の流れ

```
[撮影] coord-picker.bat (F8/F10)
         ↓
../NewMaaGfl1/gfl-assistant/Assets/templates/dormitory/
         ↓ sync-dormitory-templates.ps1
assets/resource_jp/image/dormitory/
         ↓ sync_assets.ps1
install/resource_jp/image/dormitory/
```

不足確認: `.\tools\check_templates.ps1`

---

## 6. 日本語化のポイント（MaaNX 参考）

| 層 | 内容 |
|---|---|
| GUI | `assets/lang/ja-JP.json` |
| ウィンドウ | `ドールズフロントライン` in window_regex |
| OCR expected | 開発・宿舎・いいね・参観 等 |
| テンプレート | 日本語版ゲーム画面から撮影（中国語版は不可） |
