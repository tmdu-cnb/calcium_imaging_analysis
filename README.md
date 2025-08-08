# calcium_imaging_analysis

MATLAB によるカルシウムイメージング解析用リポジトリです。  
---

## 特徴 / 目的
- 1P / 2P / glia など 用途別ディレクトリ構成
- ROI 検出・ベースライン補正・可視化・頻度解析などの 基本処理を一本化
---

## リポジトリ構成（概要）
calcium_imaging_analysis/
├─ 1P/ # 1光子解析のコアスクリプト
│ ├─ P10_subtract.m # ベースライン補正/フィルタ
│ ├─ P10_detectROI.m # ROI検出（本体）
│ ├─ ROIs_in_Image.m # ROIを画像上に描画/確認
│ ├─ ROIs_in_Movie.m # ROIを動画上に描画/確認
│ ├─ Calcium_properties.m # ROIプロパティ計算
│ └─ frequency_distribution.m# イベント頻度等の集計
├─ 2P/
│ └─ P10_subtract_250402_2P_Soma.m # 2光子（ソーマ）の subtract 派生
├─ glia/
│ ├─ Glia_detectROI.m
│ └─ Glia_subtract.m
├─ graph/ # 図作成/可視化ユーティリティ
│ ├─ Graph_20240716_back.m
│ ├─ Graph_20240717_Slice1500.m
│ ├─ Graph_20240823_Slice600.m
│ ├─ Graph_20240823_Slice1800.m
│ └─ Graph_20240717_final.m # ※旧 gragh_* は Graph_* に整理予定
├─ tanigawa/
│ └─ Detect_ROIs_tanigawa.m
├─ utsumi/
│ ├─ detectROI_utsumi.m
│ ├─ Utsumi.m # ※旧 Dutsumi をリネーム
│ ├─ P10_detectROI_241214_Utsumi.m
│ └─ P10_subtract_250115_Utsumi.m
├─ .gitignore
├─ README.md ←（このファイル）
└─ startup.m ←（任意：パス追加の初期処理）
