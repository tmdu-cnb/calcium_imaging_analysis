
% ---------------------- 改善後のコード ---------------------- %
% 全体の処理開始時間を記録
overallTimer = tic;

% TIF動画ファイルを読み込む
tifFile = 'MAX_MAG1_2nd.tif';  % 読み込むTIF動画ファイル名
info = imfinfo(tifFile);  % TIFファイル情報の取得
numFrames = numel(info);  % フレーム数

% 対象フレームの選択（連続した1/3）
startFrame = 1;  % 開始フレーム
%endFrame = floor(numFrames / 3);  % 終了フレーム（1/3のフレーム数）
endFrame = numFrames; %全フレーム
selectedFrames = startFrame:endFrame;  % 連続したフレーム範囲を選択

% CSVファイルの読み込み
csvFile = 'presentation.csv';  % CSVファイル名
data = readmatrix(csvFile);    % CSVファイルの読み込み

% CSVデータからROI番号を取得
roi_numbers = data(3:end, end-3);  % 最終列ROI番号が格納されている

% カラーマップを生成（ROIの数だけ）
num_rois = length(roi_numbers);
colors = lines(num_rois);  % カラーマップ（RGB形式）

% ROIのアウトラインを事前に計算
roi_outlines = cell(num_rois, 1);  % ROIのアウトライン座標を格納
for i = 1:num_rois
    roi_num = roi_numbers(i);  % 現在のROI番号を取得
    roi_x = double(stat{roi_num}.xpix);  % x座標
    roi_y = double(stat{roi_num}.ypix);  % y座標
    points = [roi_x(:), roi_y(:)];
    k = boundary(points(:,1), points(:,2), 0.8);
    roi_outlines{i} = points(k, :);  % アウトラインを格納
end

% 出力用の新しいTIFファイル名
outputTifFile = 'output_with_ROI.tif';

% TIFFファイルの初期化
t = Tiff(outputTifFile, 'w');

% 選択されたフレームに対して処理を実行
frameTimes = zeros(1, length(selectedFrames));  % フレーム処理時間の記録




for idx = 1:length(selectedFrames)
    frameIdx = selectedFrames(idx);  % 現在のフレーム番号

    % フレーム処理開始時間を記録
    frameTimer = tic;

    % フレームを読み込む
    % img = imread(tifFile, frameIdx);
    % img_rgb = repmat(img, [1, 1, 3]);  % グレースケールをRGBに変換

% ---- 変更後 ----
img16   = imread(tifFile, frameIdx);      % uint16 で読み込まれる
img8    = uint8( double(img16) ./ 65535 * 255 );  % 0-65535 → 0-255 に線形スケール
img_rgb = repmat(img8, [1, 1, 3]);        % uint8 の RGB 配列を作成


    % ROIを描画
    for i = 1:num_rois
        outline = roi_outlines{i};  % アウトラインの取得
        % ROIの境界線を描画
        mask = poly2mask(outline(:,1), outline(:,2), size(img, 1), size(img, 2));
        boundaryMask = bwperim(mask);  % 境界線の取得
        % for c = 1:3
        %     img_rgb(:,:,c) = img_rgb(:,:,c) + uint8(boundaryMask) * uint8(255 * colors(i, c));
        % end
        for c = 1:3
    % ---- 変更後 ----
addLayer = uint8(boundaryMask) .* ...
           uint8( round(255 * colors(i,c)) );  % 端数を四捨五入で整数化
img_rgb(:,:,c) = min(img_rgb(:,:,c) + addLayer, 255);   % 同じ uint8 同士なので OK

        end

    end



    
    % TIFFタグを設定
    tagstruct.ImageLength = size(img_rgb, 1);
    tagstruct.ImageWidth = size(img_rgb, 2);
    tagstruct.Photometric = Tiff.Photometric.RGB;
    tagstruct.BitsPerSample = 8;
    tagstruct.SamplesPerPixel = 3;
    tagstruct.RowsPerStrip = 16;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software = 'MATLAB';
    tagstruct.Compression = Tiff.Compression.None;

    % フレームを書き込み
    t.setTag(tagstruct);
    t.write(img_rgb);

    % 次のフレームのためにディレクトリを作成
    if idx < length(selectedFrames)
        t.writeDirectory();
    end

    % フレーム処理時間を記録
    frameTimes(idx) = toc(frameTimer);
    fprintf('フレーム %d の処理時間: %.2f 秒\n', frameIdx, frameTimes(idx));
end

% TIFFファイルを閉じる
t.close();

% 全体の処理時間を記録
overallElapsedTime = toc(overallTimer);

% 結果を表示
disp(['ROIを描画したTIF動画を保存しました: ', outputTifFile]);
fprintf('全体の処理時間: %.2f 秒\n', overallElapsedTime);



% % ---------------------- 改善後のコード ---------------------- %
% % 全体の処理開始時間を記録
% overallTimer = tic;
% 
% % TIF動画ファイルを読み込む
% tifFile = 'Drd1_1_AAV-L7-RFP_L7-j7s_P9.tif';  % 読み込むTIF動画ファイル名
% info = imfinfo(tifFile);  % TIFファイル情報の取得
% numFrames = numel(info);  % フレーム数
% 
% % 対象フレームの選択（連続した1/3）
% startFrame = 1;  % 開始フレーム
% endFrame = floor(numFrames / 3);  % 終了フレーム（1/3のフレーム数）
% selectedFrames = startFrame:endFrame;  % 連続したフレーム範囲を選択
% 
% % CSVファイルの読み込み
% csvFile = 'presentation.csv';  % CSVファイル名
% data = readmatrix(csvFile);    % CSVファイルの読み込み
% 
% % CSVデータからROI番号を取得
% roi_numbers = data(3:end, end-3);  % 最終列ROI番号が格納されている
% 
% % カラーマップを生成（ROIの数だけ）
% num_rois = length(roi_numbers);
% colors = uint8(255 * lines(num_rois));  % カラーマップをuint8形式に変換
% 
% % ROIのアウトラインを事前に計算
% roi_outlines = cell(num_rois, 1);  % ROIのアウトライン座標を格納
% for i = 1:num_rois
%     roi_num = roi_numbers(i);  % 現在のROI番号を取得
%     roi_x = double(stat{roi_num}.xpix);  % x座標
%     roi_y = double(stat{roi_num}.ypix);  % y座標
%     points = [roi_x(:), roi_y(:)];
%     k = boundary(points(:,1), points(:,2), 0.8);
%     roi_outlines{i} = points(k, :);  % アウトラインを格納
% end
% 
% % 出力用の新しいTIFファイル名
% outputTifFile = 'output_with_ROI.tif';
% 
% % TIFFファイルの初期化
% t = Tiff(outputTifFile, 'w');
% 
% % 選択されたフレームに対して処理を実行
% frameTimes = zeros(1, length(selectedFrames));  % フレーム処理時間の記録
% 
% for idx = 1:length(selectedFrames)
%     frameIdx = selectedFrames(idx);  % 現在のフレーム番号
% 
%     % フレーム処理開始時間を記録
%     frameTimer = tic;
% 
%     % フレームを読み込む
%     img = imread(tifFile, frameIdx);
%     img = repmat(img, [1, 1, 3]);  % グレースケールをRGBに変換
% 
%     % ROIを描画
%     for i = 1:num_rois
%         outline = roi_outlines{i};  % アウトラインの取得
%         img = insertShape(img, 'Polygon', outline(:)', ...
%             'Color', colors(i, :), 'LineWidth', 2);  % ROIを描画
%     end
% 
%     % TIFFタグを設定
%     tagstruct.ImageLength = size(img, 1);
%     tagstruct.ImageWidth = size(img, 2);
%     tagstruct.Photometric = Tiff.Photometric.RGB;
%     tagstruct.BitsPerSample = 8;
%     tagstruct.SamplesPerPixel = 3;
%     tagstruct.RowsPerStrip = 16;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Software = 'MATLAB';
%     tagstruct.Compression = Tiff.Compression.None;
% 
%     % フレームを書き込み
%     t.setTag(tagstruct);
%     t.write(img);
% 
%     % 次のフレームのためにディレクトリを作成
%     if idx < length(selectedFrames)
%         t.writeDirectory();
%     end
% 
%     % フレーム処理時間を記録
%     frameTimes(idx) = toc(frameTimer);
%     fprintf('フレーム %d の処理時間: %.2f 秒\n', frameIdx, frameTimes(idx));
% end
% 
% % TIFFファイルを閉じる
% t.close();
% 
% % 全体の処理時間を記録
% overallElapsedTime = toc(overallTimer);
% 
% % 結果を表示
% disp(['ROIを描画したTIF動画を保存しました: ', outputTifFile]);
% fprintf('全体の処理時間: %.2f 秒\n', overallElapsedTime);
% 
% % フレームごとの処理時間を保存
% writematrix(frameTimes, 'frame_processing_times.csv');
% disp('フレームごとの処理時間を frame_processing_times.csv に保存しました。');


% % ---------------------- 改善後のコード ---------------------- %
% % 全体の処理開始時間を記録
% overallTimer = tic;
% 
% % TIF動画ファイルを読み込む
% tifFile = 'Drd1_1_AAV-L7-RFP_L7-j7s_P9.tif';  % 読み込むTIF動画ファイル名
% info = imfinfo(tifFile);  % TIFファイル情報の取得
% numFrames = numel(info);  % フレーム数
% 
% % 対象フレームの選択（連続した1/3）
% startFrame = 1;  % 開始フレーム
% endFrame = floor(numFrames / 3);  % 終了フレーム（1/3のフレーム数）
% selectedFrames = startFrame:endFrame;  % 連続したフレーム範囲を選択
% 
% % CSVファイルの読み込み
% csvFile = 'presentation.csv';  % CSVファイル名
% data = readmatrix(csvFile);    % CSVファイルの読み込み
% 
% % CSVデータからROI番号を取得
% roi_numbers = data(3:end, end-3);  % 最終列ROI番号が格納されている
% 
% % カラーマップを生成（ROIの数だけ）
% num_rois = length(roi_numbers);
% colors = lines(num_rois);  % 'lines'カラーマップで色を生成
% 
% % ROIのアウトラインを事前に計算
% roi_outlines = cell(num_rois, 1);  % ROIのアウトライン座標を格納
% for i = 1:num_rois
%     roi_num = roi_numbers(i);  % 現在のROI番号を取得
%     roi_x = double(stat{roi_num}.xpix);  % x座標
%     roi_y = double(stat{roi_num}.ypix);  % y座標
%     points = [roi_x(:), roi_y(:)];
%     k = boundary(points(:,1), points(:,2), 0.8);
%     roi_outlines{i} = points(k, :);  % アウトラインを格納
% end
% 
% % 出力用の新しいTIFファイル名
% outputTifFile = 'output_with_ROI.tif';
% 
% % フレームごとの処理時間を記録する配列
% frameTimes = zeros(1, length(selectedFrames));
% 
% % 選択されたフレームに対して処理を実行
% parfor idx = 1:length(selectedFrames)
%     frameIdx = selectedFrames(idx);  % 現在のフレーム番号
% 
%     % フレーム処理開始時間を記録
%     frameTimer = tic;
% 
%     % フレームを読み込む
%     img = imread(tifFile, frameIdx);
% 
%     % フレームサイズを取得
%     [rows, cols] = size(img);
%     img_rgb = repmat(img, [1, 1, 3]);  % グレースケールをRGBに変換
% 
%     % ROIを描画
%     for i = 1:num_rois
%         outline = roi_outlines{i};  % アウトラインの取得
%         mask = poly2mask(outline(:,1), outline(:,2), rows, cols);  % ROIマスク生成
%         boundaryMask = bwperim(mask);  % 境界線の取得
%         for c = 1:3
%             img_rgb(:,:,c) = img_rgb(:,:,c) + uint8(boundaryMask) * uint8(255 * colors(i, c));
%         end
%     end
% 
%     % 新しいTIFファイルに書き込み
%     if idx == 1
%         imwrite(img_rgb, outputTifFile, 'WriteMode', 'overwrite', 'Compression', 'none');
%     else
%         imwrite(img_rgb, outputTifFile, 'WriteMode', 'append', 'Compression', 'none');
%     end
% 
%     % フレーム処理時間を記録
%     frameTimes(idx) = toc(frameTimer);
%     fprintf('フレーム %d の処理時間: %.2f 秒\n', frameIdx, frameTimes(idx));
% end
% 
% % 全体の処理時間を記録
% overallElapsedTime = toc(overallTimer);
% 
% % 結果を表示
% disp(['ROIを描画したTIF動画を保存しました: ', outputTifFile]);
% fprintf('全体の処理時間: %.2f 秒\n', overallElapsedTime);
% 
% % フレームごとの処理時間を保存
% writematrix(frameTimes, 'frame_processing_times.csv');
% disp('フレームごとの処理時間を frame_processing_times.csv に保存しました。');