% TIFファイルを読み込む
tifFile = ['MAX_240920_AldoCP13_2b.tif'];  % 読み込むTIFファイル名
img = imread(tifFile); % TIFファイルの読み込み

% 現在のフォルダ内のCSVファイルを読み込む
csvFile = 'presentation.csv';  % CSVファイル名
data = readmatrix(csvFile);    % CSVファイルの読み込み

% CSVデータからROI番号を取得
roi_numbers = data(3:end, end-3);  % 最終列ROI番号が格納されている

% 画像を表示
figure; % 新しいFigureを作成
imshow(img, []);

hold on;

% 3列目をx座標、その次の列（4列目）をy座標として取得
x_coords = data(3:end, end);  % 最後の前の列がx座標
y_coords = data(3:end, end-1);  % 最後の列がy座標


% % マゼンタ色の円を画像上に描画
% plot(x_coords, y_coords, 'mo', 'MarkerSize', 10, 'LineWidth', 2);  % マゼンタの円形マーカーを描画


% カラーマップを生成（ROIの数だけ）
num_rois = length(roi_numbers);  % ROIの数
colors = lines(num_rois);  % 'lines'カラーマップで色を生成


% 各ROIに対して処理を実行
for i = 1:num_rois
    roi_num = roi_numbers(i);  % 現在のROI番号を取得

    % ROI番号に対応するstatの座標情報を取得
    roi_x = double(stat{roi_num}.xpix);  % x座標を数値型に変換
    roi_y = double(stat{roi_num}.ypix);  % y座標を数値型に変換

    % 座標を元にアウトラインを滑らかに生成（boundary関数を使用）
    points = [roi_x(:), roi_y(:)];  % x, y 座標を組み合わせて点群を作成
    k = boundary(points(:,1), points(:,2), 0.8);  % アルファ値を調整（0.8で滑らか度を調整）

    % 塗りつぶし色を設定（カラーマップの色を使用）
    fill_color = colors(i, :);  % カラーマップから色を取得

    % ROIのアウトラインを描画 (透明度50%)
    fill(points(k,1), points(k,2), fill_color, 'EdgeColor', fill_color, 'LineWidth', 1.2, 'FaceAlpha', 0.2);


    % ROI番号を黒色で表示（ROIの中心に配置）
    original_roi_num = stat{roi_num}.original_roi_number;
    center_x = mean(roi_x);  % x座標の中心
    center_y = mean(roi_y);  % y座標の中心
    text(center_x, center_y, num2str(original_roi_num), 'Color', 'k', 'FontSize', 5 ...
        , 'HorizontalAlignment', 'center');

end



% % 各ROIに対して処理を実行
% for i = 1:num_rois
%     roi_num = roi_numbers(i);  % 現在のROI番号を取得
% 
%     % ROI番号に対応するstatの座標情報を取得
%     roi_x = double(stat{roi_num}.xpix);  % x座標を数値型に変換
%     roi_y = double(stat{roi_num}.ypix);  % y座標を数値型に変換
% 
%     % 座標を元にアウトラインを滑らかに生成（boundary関数を使用）
%     points = [roi_x(:), roi_y(:)];  % x, y 座標を組み合わせて点群を作成
%     k = boundary(points(:,1), points(:,2), 0.8);  % アルファ値を調整（0.8で滑らか度を調整）
% 
%     % 塗りつぶし色を設定（カラーマップの色を使用）
%     fill_color = colors(i, :);  % カラーマップから色を取得
% 
%     % ROIのアウトラインを描画
%     fill(points(k,1), points(k,2), fill_color, 'EdgeColor', fill_color, 'LineWidth', 1.2);
% end


% 
% 
% % 各ROIに対して処理を実行
% for i = 1:num_rois
%     roi_num = roi_numbers(i);  % 現在のROI番号を取得
% 
%     % ROI番号に対応するstatの座標情報を取得
%     roi_x = stat{roi_num}.xpix;  % x座標 (例: [x1, x2, ...])
%     roi_y = stat{roi_num}.ypix;  % y座標 (例: [y1, y2, ...])
% 
%     % 塗りつぶし色を設定（カラーマップの色を使用）
%     fill_color = colors(i, :);  % カラーマップから色を取得
% 
%     % ROIの範囲を塗りつぶし（エッジ色も同じ色）
%     fill(roi_x, roi_y, fill_color, 'EdgeColor', fill_color);  % 塗りつぶし色とエッジ色を一致させる
% end

% グラフを保持して表示
hold off;

% 必要に応じて画像を保存
outputFile = 'output_image_with_ROI_colored.tif';  % 出力ファイルの名前
exportgraphics(gca, outputFile, 'Resolution', 300);  % 高解像度で画像を保存

% 結果フォルダにファイルを移動
destinationFolder = 'result';  % 移動先のフォルダ名
movefile(outputFile, fullfile(destinationFolder, outputFile));  % ファイルを移動
