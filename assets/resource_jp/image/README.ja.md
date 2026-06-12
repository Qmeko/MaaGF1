# テンプレート画像（日本語クライアント用）

MaaGfl1 の画像認識タスクには、**日本語版ゲーム画面**から撮影した PNG が必要です。

> **現状**: MaaNX から `dormitory/` 画像は同期済みです。`btn_enter_dorm.png`（参観）のみ撮り直し推奨。  
> 確認: `.\scripts\check-templates.bat` / [docs/TEMPLATE_CHECKLIST.ja.md](../../../docs/TEMPLATE_CHECKLIST.ja.md)

> 詳細な撮影一覧・手順: [gfl-assistant/docs/MaaGfl1_TEMPLATE_CAPTURE.ja.md](../../../gfl-assistant/docs/MaaGfl1_TEMPLATE_CAPTURE.ja.md)

## 前提

| 項目 | 値 |
|---|---|
| ゲーム | ドールズフロントライン（Steam 日本語） |
| 解像度 | **1280 × 720 ウィンドウモード** |
| 撮影 | ゲーム内の実画面から切り出し（中国語版 MaaGF1 の画像は使えません） |

## 必要なフォルダ

### 宿舎いいね（`dormitory/`）

| ファイル名 | 用途 |
|---|---|
| `Gvisit.png` | 訪問ボタン |
| `Gbattery1.png` | バッテリー（緑マスク用） |
| `Gback1.png` / `Gback2.png` | 戻るボタン |
| `Gheart.png` | ハート（いいね） |
| `dianzan.png` | いいねボタン |
| `battery.png` | バッテリー回収 |
| `next.png` | 次の宿舎 |
| `message.png` | コメント欄 |

### 13-4 周回（`combat/levelUp/13-4/`）

| ファイル名 | 用途 |
|---|---|
| `run134.png` | 13-4 ステージ選択 |
| `init.png` | マップ初期位置 |
| `map_team1.png` / `map_team2.png` | 部隊配置確認 |
| `Gnoammo.png` / `Gfullammo.png` | 弾薬チェック |
| `G_team1.png` | 編成スロット |
| `back2map.png` | マップへ戻る |
| `Gap0.png` / `Gap3.png` / `Gap-5.png` | 戦闘移動確認 |

## 撮影ツール（gfl-assistant）

```powershell
cd gfl-assistant
.\scripts\coord-picker.bat
```

| 操作 | 機能 |
|---|---|
| F8 | 座標記録 + アイコン切り出し |
| F9 → ROI② → 切り出し | 手動 ROI 切り出し |
| F10 | アイコン自動切り出し |

## 同期

画像を `assets/resource_jp/image/` に配置したあと:

```powershell
# MFAAvalonia 用
.\tools\sync_assets.ps1

# gfl-assistant 用
cd gfl-assistant
.\scripts\sync-dormitory-templates.ps1
```

## 参考

- 公式 MaaGF1 中国語版: `.\tools\fetch_maagf1_reference.ps1`（参考のみ、画像は流用不可）
- MaaNX での日本語化パイプライン: `assets/resource_jp/pipeline/tasks/dormitory_like.json`
