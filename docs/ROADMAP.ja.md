# 開発ロードマップ

構成: [STRUCTURE.ja.md](./STRUCTURE.ja.md)  
手順: [USAGE.ja.md](./USAGE.ja.md)

---

## 方針

| 軸 | 内容 |
|---|---|
| 短期 | `gfl-assistant` で宿舎いいね・後方支援を安定化 |
| 中期 | Maa OCR + SendInput 統合 |
| 長期 | ObjectCatalog + BehaviorTree + LLM |

**確定事項**: Unity は Win32 入力無効 → `../NewMaaGfl1/gfl-assistant/`（C# SendInput）が主系

---

## Phase

### Phase 0 ✅ 基盤

MaaGfl1 リポジトリ（MaaNX 参考）、`assets/resource_jp`、MFAAvalonia、`../NewMaaGfl1/gfl-assistant/`、`../NewMaaGfl1/agent/` Core

### Phase 1 🔄 宿舎いいね（gfl-assistant 再構築）

| # | 内容 | 状態 |
|---|---|---|
| 1-0 | newproject1 → gfl-assistant 統合 | ✅ |
| 1-1 | DormitoryLikeTask.cs | ✅ |
| 1-2 | 訪問→戦友タブ→リスト | ✅ コード済 |
| 1-3 | テンプレート（dormitory/） | 🔄 プレースホルダー |
| 1-4 | 実機座標調整 | ⏳ |
| 1-5 | いいねループ | ✅ コード済 |
| 1-6 | 電力盗み | ⏳ |

**次の作業:**

1. `gfl-assistant\scripts\run-dormitory.bat` 実機テスト
2. `capture` / `crop` で tab_comrade 等を本番テンプレに差し替え
3. 電力盗みを `DormitoryLikeTask.cs` に追加

### Phase 1b ✅ 後方支援（newproject1 移植）

| # | 内容 | 状態 |
|---|---|---|
| L-1 | LogisticsWatchTask | ✅ |
| L-2 | LogisticsPanelReader / 時計パネル | ✅ |
| L-3 | run-logistics CLI / GUI | ✅ |

### Phase 2 ⏳ ObjectCatalog（YAML）

### Phase 3 ⏳ Maa OCR 統合

### Phase 4 ⏳ 人形回収・灰域（後方支援は Phase 1b で着手済み）

### Phase 5 ⏳ LLM 補助（任意）

---

## マイルストーン

| Ver | 内容 |
|---|---|
| v0.1.0 ✅ | MaaNX 初版 |
| v0.2.0 🔄 | gfl-assistant 宿舎いいね安定版 |
| v0.3.0 ⏳ | ObjectCatalog |
| v1.0.0 ⏳ | 主要デイリー一式 |

---

## 既知の問題

| 問題 | 対策 |
|---|---|
| MFAAvalonia 入力無効 | `../NewMaaGfl1/agent/run.bat` |
| テンプレずれ | マルチスケール + `nav_coords.py` |
| install 同期漏れ | `tools/sync_assets.ps1` |
