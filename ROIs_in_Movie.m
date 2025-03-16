% TIF動画ファイルを読み込む
tifFile = 'Drd1_1_AAV-L7-RFP_L7-j7s_P9.tif';  % 読み込むTIF動画ファイル名
info = imfinfo(tifFile);  % TIFファイル情報の取得
numFrames = numel(info);  % フレーム数

% CSVファイルの読み込み
csvFile = 'presentation.csv';  % CSVファイル名
data = readmatrix(csvFile);    % CSVファイルの読み込み

% CSVデータからROI番号を取得
roi_numbers = data(3:end, end-3);  % 最終列ROI番号が格納されている

% ROI座標データ（例: ROIごとのx, y座標をstat構造体として用意）
% このデータはユーザーが用意する必要があります。
% stat構造体には以下のフィールドが必要:
% stat{i}.xpix, stat{i}.ypix, stat{i}.original_roi_number

% カラーマップを生成（ROIの数だけ）
num_rois = length(roi_numbers);
colors = lines(num_rois);  % 'lines'カラーマップで色を生成

% 出力用の新しいTIFファイル名
outputTifFile = 'output_with_ROI.tif';

% 各フレームに対して処理を実行
for frameIdx = 1:numFrames
    % フレームを読み込む
    img = imread(tifFile, frameIdx);

    % フレームを表示
    figure('Visible', 'off');
    imshow(img, []);
    hold on;

    % 各ROIを描画
    for i = 1:num_rois
        roi_num = roi_numbers(i);  % 現在のROI番号を取得

        % ROI番号に対応するstatの座標情報を取得
        roi_x = double(stat{roi_num}.xpix);  % x座標を数値型に変換
        roi_y = double(stat{roi_num}.ypix);  % y座標を数値型に変換

        % 座標を元にアウトラインを滑らかに生成
        points = [roi_x(:), roi_y(:)];
        k = boundary(points(:,1), points(:,2), 0.8);

        % 塗りつぶし色を設定
        fill_color = colors(i, :);

        % ROIのアウトラインを描画 (透明度50%)
        fill(points(k,1), points(k,2), fill_color, 'EdgeColor', fill_color, 'LineWidth', 1.2, 'FaceAlpha', 0.2);

        % ROI番号を描画
        center_x = mean(roi_x);
        center_y = mean(roi_y);
        text(center_x, center_y, num2str(stat{roi_num}.original_roi_number), ...
             'Color', 'k', 'FontSize', 1, 'HorizontalAlignment', 'center');
    end

    hold off;

    % フレームを画像として取得
    frame = getframe(gca);
    imgWithROI = frame.cdata;

    % 新しいTIFファイルに書き込み
    if frameIdx == 1
        imwrite(imgWithROI, outputTifFile, 'WriteMode', 'overwrite', 'Compression', 'none');
    else
        imwrite(imgWithROI, outputTifFile, 'WriteMode', 'append', 'Compression', 'none');
    end

    close;  % 図を閉じる
end

% 終了メッセージ
disp(['ROIを描画したTIF動画を保存しました: ', outputTifFile]);
