---
name: scientific-photo-harmonizer
description: >-
  科学写真・学術標本・資料アーカイブ・商品写真向けに、色相・色温度・マンセル表色系を100%完全保全しながら、明るさ（露出）のばらつき、黒つぶれ、白飛び、コントラスト不足を調和・最適化する画像補正スキル・ワークフロー。「ファーストレタッチして」「ファーストレタッチ」「一次レタッチして」などのシンプルな指示で自動起動する。
metadata:
  publisher: local
---

# Scientific Photo Harmonizer (科学写真・標本記録 色相保全明度調和スキル)

> **主なトリガー命令**:
> - 「**ファーストレタッチして**」
> - 「**ファーストレタッチ**」
> - 「**一次レタッチして**」
>
> 上記のシンプルな指示を受けると、対象フォルダまたは指定された写真群に対し、色味・色相を一切変えずに露出調和・コントラスト最適化・Exif同期・Before/After比較レポート生成までを一気通貫で自動実行します。

## 推奨実行方法: 「画像ファーストレタッチくん」CLI を優先 (Preferred: use the app's CLI)
同アルゴリズムを実装した独立アプリ（純Rust、外部ランタイム不要）が存在する場合は、Pythonスクリプトより **CLI を優先** して使うこと。

```bash
# ソース/ビルド: /Users/r-site/Documents/画像ファーストレタッチくん/image_first_retouch_kun
CLI="/Users/r-site/Documents/画像ファーストレタッチくん/image_first_retouch_kun/src-tauri/target/release/first-retouch"
"$CLI" <フォルダまたはファイル...>   # 出力: 入力フォルダ内 first_retouched/ （元ファイルは上書きしない）
"$CLI" <dir> -o <出力先> -t 122      # 出力先・目標L*中央値を指定
```
- 出力フォルダに二言語（日英）の `comparison_viewer.html` が自動生成される。
- CLIが見つからない場合のみ、下記の `scripts/harmonize.py` を使う。

## 概要 (Overview)
土壌写真、地質・鉱物標本、生物・病理写真、文化財・絵画記録などの学術写真では、**「色の情報（マンセル表色系の色相・明度・彩度、酸化還元状態、鉱物組成）」が極めて重要な科学的診断根拠**となります。
一般的な画像補正ソフトの自動ホワイトバランスやRGB個別トーンカーブ、AIフィルターを適用すると、色相（Hue）が歪んでしまい、学術的・法的な証拠能力が失われます。

本スキルは、**CIE $L^*a^*b^*$ 色空間** を活用し、**色彩チャネル（$a^*, b^*$）に一切手を触れず、明度チャネル（$L^*$）のみを適応型ガンマおよび適応型局所コントラスト（CLAHE＋ロールオフ圧縮）で補正**することで、色味・色温度・マンセル色相を100%完全保持したまま、写真群全体の露出・立体感・微細陰影テクスチャを鮮明に調和・最適化します。

---

## 適用場面 (When to Use)
- **土壌写真・断面トレンチ写真**: 黒色綿花土（Vertisol）や赤黄色土など、トレンチ内の日陰・直射日光による明暗差が激しく、亀裂やすべり面、構造単位（ペド）が潰れているとき。
- **地質・鉱物・化石標本**: 微細な条線・劈開・結晶構造を明瞭にしつつ、鉱物固有の色味を保全したいとき。
- **生物・病理・解剖写真**: 組織・細胞の境界コントラストを高めつつ、染色標本や生体組織の正確な色彩を担保したいとき。
- **美術品・文化財・古文書アーカイブ**: 経年変色や保存状態の記録において、撮影時の露出ムラ・影をフラットに調和させたいとき。
- **商品・EC撮影**: 実物の正確な色味を変えずに、ディテールや質感をくっきり際立たせたいとき。

---

## 核となる技術的原則 (Core Technical Principles)

### 1. 色相・色温度の完全不変 (Strict Color & Hue Fidelity)
- RGB色空間で各色成分を個別にガンマ補正やトーンカーブ調整すると、各画素の $R:G:B$ 比率が崩れ、色相シフト（変色）が生じます。
- 本ワークフローでは、測色学的に色差と明度が完全に分離された **CIE $L^*a^*b^*$ 色空間** を使用します。
- $a^*$（緑-赤軸）および $b^*$（青-黄軸）は **一切無改変（$\Delta a^* = 0, \Delta b^* = 0$）** でバイパスし、明度 $L^*$ のみを操作することで、幾何学的にも測色学的にも色相角 $\theta = \arctan(b^*/a^*)$ および彩度 $C^* = \sqrt{{a^*}^2 + {b^*}^2}$ を完全保全します。

### 2. 目標明度の中央値調和 (Target Median Luminance Alignment)
- 日陰・アンダーな写真（$L^* < 90$）や白飛び気味の写真（$L^* > 150$）に対し、一連のシリーズ中で最も自然な標準写真の中央値（例: $L^* \approx 120 \sim 125$）を統一基準ターゲット $L_{target}$ に設定します。
- 局所的な白飛び領域（空や直接反射光など $L^* > 240$）を除外した被写体領域の中央値 $L_{med}$ から、適応型ガンマを自動算出します：
  $$\gamma = \text{clip}\left(\frac{\log(L_{target} / 255)}{\log(L_{med} / 255)}, 0.65, 1.35\right)$$

### 3. 微細テクスチャの適応的コントラスト最適化 (Adaptive Contrast & Roll-off)
- 単なる大域トーンカーブでは、眠い写真の立体感復元や、トレンチ深部の陰影復元が不十分になります。
- 適応型ヒストグラム均等化（CLAHE: TileSize $8 \times 8$）を元画像の標準偏差 $\sigma$ に応じて適応的に適用：
  - 低コントラスト（$\sigma < 45$）: `clipLimit = 2.0`（起伏・テクスチャをしっかり強調）
  - 通常コントラスト（$45 \le \sigma \le 65$）: `clipLimit = 1.5`
  - 高コントラスト（$\sigma > 65$）: `clipLimit = 1.2`（白飛び・黒つぶれを抑え階調保護）
- さらに、ハイライト部（$L^* > 225$）にソフトロールオフ関数、シャドウ部（$L^* < 12$）にソフトリフト関数を適用し、不自然な白飛び・ノイズ浮きを防止します。

### 4. 二重回転（Double-Rotation）防止とExif完全同期
- デジタル一眼レフ（Nikon, Canon等）で縦向き撮影された写真は、Exif Orientationタグ（例: 8や6）が付与されています。
- OpenCV等のライブラリはデフォルトでExifを自動回転して読み込むため、処理後に元のExifタグをそのまま埋め込むと、ブラウザやビューアで**「2重に回転して横倒しになる」**重大な不整合が発生します。
- 本ワークフローでは、必ず生センサ配列（`IMREAD_IGNORE_ORIENTATION`）で読み込んで処理を行い、元Exifと 1:1 で完全同期させます。

---

## 実行コマンド・クイックスタート (Quick Start)

### スクリプトの直接実行
付属の自動化スクリプトを使用することで、単一写真またはフォルダ全体を一括処理できます：

```bash
# フォルダ内の全写真を一括調和処理（目標中央値 L*=122）
python3 ~/.gemini/config/skills/scientific-photo-harmonizer/scripts/harmonize.py \
  /path/to/photos \
  -o /path/to/output_folder \
  -t 122.0

# 単一ファイルの処理
python3 ~/.gemini/config/skills/scientific-photo-harmonizer/scripts/harmonize.py \
  /path/to/photo.jpg \
  -o /path/to/enhanced_photo.jpg
```

---

## Python 実装コード（コアロジック）

```python
import cv2
import numpy as np
from PIL import Image

def harmonize_scientific_image(in_path, out_path, target_L=122.0):
    # 1. 元のExifバイナリを取得
    pil_orig = Image.open(in_path)
    exif_bytes = pil_orig.info.get('exif')
    
    # 2. 二重回転を防ぐため生センサ配列で読み込み
    img = cv2.imread(in_path, cv2.IMREAD_COLOR | cv2.IMREAD_IGNORE_ORIENTATION)
    if img is None:
        raise ValueError(f"Failed to read: {in_path}")
        
    # 3. CIE L*a*b* 色空間へ変換
    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    L, A, B = cv2.split(lab)
    
    # 4. 白飛びを除外して被写体領域の中央値・分散を算出
    valid_mask = L < 240
    if np.sum(valid_mask) < L.size * 0.15:
        valid_mask = np.ones_like(L, dtype=bool)
    med_L = float(np.median(L[valid_mask]))
    std_L = float(np.std(L[valid_mask]))
    
    # 5. 適応型ガンマ補正
    ratio = np.clip(med_L / 255.0, 0.15, 0.85)
    gamma = float(np.clip(np.log(target_L / 255.0) / np.log(ratio), 0.65, 1.35))
    L_gamma = np.power(np.maximum(L.astype(np.float32) / 255.0, 1e-6), gamma) * 255.0
    L_gamma_u8 = np.clip(L_gamma, 0, 255).astype(np.uint8)
    
    # 6. コントラスト適応型CLAHE
    clip_lim = 2.0 if std_L < 45.0 else (1.2 if std_L > 65.0 else 1.5)
    clahe = cv2.createCLAHE(clipLimit=clip_lim, tileGridSize=(8, 8))
    L_clahe = clahe.apply(L_gamma_u8).astype(np.float32)
    
    # 7. ブレンド & ロールオフ
    L_out = 0.75 * L_clahe + 0.25 * L_gamma
    high_mask = L_out > 225.0
    L_out[high_mask] = 225.0 + 30.0 * np.tanh((L_out[high_mask] - 225.0) / 30.0)
    low_mask = L_out < 12.0
    L_out[low_mask] = 12.0 * np.sin(L_out[low_mask] / 12.0 * (np.pi / 2))
    
    # 8. 無改変の A, B チャネルと結合（色相・色温度完全不変）
    L_final = np.clip(L_out, 0, 255).astype(np.uint8)
    lab_out = cv2.merge([L_final, A, B])
    bgr_out = cv2.cvtColor(lab_out, cv2.COLOR_LAB2BGR)
    
    # 9. 最高画質・Exif保持で保存
    rgb_out = cv2.cvtColor(bgr_out, cv2.COLOR_BGR2RGB)
    pil_out = Image.fromarray(rgb_out)
    save_kwargs = {"quality": 96, "subsampling": 0}
    if exif_bytes:
        save_kwargs["exif"] = exif_bytes
    pil_out.save(out_path, **save_kwargs)
```

---

## 成果物ドキュメンテーションの標準ワークフロー
研究・出版・クライアント納品時には、以下の3点をセットで提供することが推奨されます：
1. **調整済み画像ファイル**: 元ファイルと同名、最高画質、Exifメタデータ保持。
2. **オリジナルバックアップ**: `_original_backup/` フォルダへの非破壊完全保存。
3. **Before/After 比較HTMLビューア**: 
   - 左右並列表示、日本語・英語バイリンガル解説、明度・コントラスト測定値バッジ付き。
4. **Excel 測定レポート (.xlsx)**:
   - 全写真の $L^*$ 中央値、コントラスト $\sigma$、適用ガンマ値、土壌形態学/学術的所見の日英対訳一覧シート。

