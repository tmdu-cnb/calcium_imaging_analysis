% TIFファイルを読み込む
tifFile = 'MAX_C1.tif';  % 現在のフォルダ内にあるCSVファイルの名前を指定
img = imread(tifFile);       % TIFファイルの読み込み

% 現在のフォルダ内のCSVファイルを読み込む
csvFile = 'presentation.csv';  % 現在のフォルダ内にあるCSVファイルの名前を指定
data = readmatrix(csvFile);    % CSVファイルの読み込み

% 3列目をx座標、その次の列（4列目）をy座標として取得
x_coords = data(3:end, end-1);  % 最後の前の列がx座標
y_coords = data(3:end, end);    % 最後の列がy座標

% 画像を表示
imshow(img);
hold on;

% マゼンタ色の円を画像上に描画
plot(x_coords, y_coords, 'mo', 'MarkerSize', 10, 'LineWidth', 2);  % マゼンタの円形マーカーを描画

% グラフを保持して表示
hold off;

% 必要に応じて画像を保存
outputFile = 'output_image_with_points.tif';  % 出力ファイルの名前
saveas(gcf, outputFile);