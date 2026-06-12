# テンプレート撮影チェックリスト

MaaNX から同期済みのテンプレートがあります。  
自動確認: `.\scripts\check-templates.bat`

> **注意**: `btn_enter_dorm.png` は `hudong.png`（交流ボタン）由来の可能性があります。  
> 参観ボタンで**撮り直し推奨**（[MaaGfl1_TEMPLATE_CAPTURE.ja.md](../NewMaaGfl1/gfl-assistant/docs/MaaGfl1_TEMPLATE_CAPTURE.ja.md) §0-3）

---

## gfl-assistant（`../NewMaaGfl1/gfl-assistant/Assets/templates/dormitory/`）

| # | ファイル | 状態 |
|---|----------|------|
| 1 | `btn_visit.png` | ✅ |
| 2 | `tab_guest.png` | ✅ |
| 3 | `tab_comrade.png` | ✅ |
| 4 | `btn_enter_dorm.png` | ⚠️ 要確認（参観で撮り直し推奨） |
| 5 | `btn_like.png` | ✅ |
| 6 | `btn_comment.png` | ✅ |
| 7 | `btn_battery_gmask.png` | ✅ |
| 8 | `btn_battery_close.png` | ✅ |
| 9 | `btn_next_dorm.png` | ✅ |
| 10 | `btn_back.png` / `btn_back2.png` | ✅ |
| 11 | `btn_dorm_visit.png` | ✅ |
| 12 | `btn_next_friend_dorm.png` | ✅ |

## HOME 画面用（`Assets/templates/`）

| # | ファイル | 状態 |
|---|----------|------|
| 13 | `btn_clock.png` | ✅ |
| 14 | `btn_clock_open.png` | ✅ |
| 15 | `nav/nav01_battery_button.png` | ✅ |
| 16 | `anchor_home.png` | ✅ |

## Maa pipeline（`assets/resource_jp/image/dormitory/`）

| ファイル | 状態 |
|----------|------|
| `Gvisit.png` / `dianzan.png` / `Gbattery1.png` 等 | ✅ 配置済み |
| `Gheart.png` | ✅ 補助タスク用 |
| `Gbattery2.png` | 📦 将来用（格納庫） |

## 13-4 周回（未配置）

`assets/resource_jp/image/combat/levelUp/13-4/` — **画像なし**（MFAAvalonia の 13-4 タスクには必要）

---

## 撮り直し・追加が必要な場合

```powershell
..\NewMaaGfl1\scripts\coord-picker.bat
cd ..\NewMaaGfl1\gfl-assistant
.\scripts\sync-dormitory-templates.ps1
cd ..\..\MaaGF1
.\tools\sync_assets.ps1
```

---

## 実機テスト結果（2026-06-11）

| テスト | 結果 | 備考 |
|---|---|---|
| `detect` | ✅ | Home / Dormitory 判定成功 |
| `run-dormitory 1` | ✅ | 宿画面から自動開始、いいね1・バッテリー1 |
| `run-maagfl1-dormitory 2` | ✅ | 2室巡回、バッテリー2 |

撮り直し推奨: `tab_comrade.png`, `btn_enter_dorm.png`, `btn_battery_gmask.png`

## テスト手順

```powershell
..\NewMaaGfl1\scripts\test-smoke.bat
..\NewMaaGfl1\scripts\run-maagfl1-dormitory.bat
..\NewMaaGfl1\scripts\run-dormitory.bat
```
