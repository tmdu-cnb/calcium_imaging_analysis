
%FBackをひいてしまうとシグナルのドリフトや細かいピークもキャンセルされてしまうのでなくした
%43行目の条件でほとんど引っかかって消えてしまうのでなくした
%どこかで位置情報がおかしくなっている

% 元の配列のサイズを取得
nR = size(F6, 1);  % FneuのROIの数
nF = size(F6, 2);  % Fneuのフレームの数

% 各行の平均値を計算
mean_values = mean(F6(:, 3:nF-3), 2);

% 平均値が100以下の行を特定
rows_to_remove = mean_values <=10; %データによって変更する

% 条件に合致する行を削除
F6(rows_to_remove, :) = [];

% 初期設定とサイズ計算
n_f = size(F6, 2) - 3;
n_R = size(F6, 1);
file_2 = F6(:, 3:end);
n_f2 = size(file_2, 2);
file_3 = file_2(:, 1:n_f2 - 3);

% TとT2の計算
T = mean(file_3, 2) + 5*std(file_3, 0, 2);
T2 = repmat(T, 1, n_f2 - 3);

% NaNで置き換え
file_3(file_3 > T2) = NaN;

% M_file_3, S_file_3, FBackを計算
M_file_3 = mean(file_3, 2, 'omitnan');
S_file_3 = std(file_3, 0, 2, 'omitnan');
FBack = M_file_3 + S_file_3;

F_Thre= M_file_3 + 5 * S_file_3;
% 各行でその値を超す値があるか確認
rows_to_keep = any(file_2(:, 1:end-3) > F_Thre, 2);
FBack = FBack(rows_to_keep, :);

% 行を削除
%file_2 = file_2(rows_to_keep, :);

% % F_signalの計算
%F_signal = bsxfun(@minus, file_2(:, 1:n_f2 - 3), FBack);
%F_signal_zero=F_signal;
F_signal = file_2;
F_signal_zero=F_signal;

% % F_signal内の負の値を0に置き換え
F_signal(F_signal < 0) = 0;

% F_signal2の計算
F_signal2 = horzcat(F_signal, file_2(:, n_f2 - 2:n_f2));

% サイズ情報を取得
n_R3 = size(F_signal2, 1);
n_f_minus_2 = n_f2 - 2;

% 各行について処理
for i = 1:n_R3
    % 現在の行のデータを取得
    signal = F_signal2(i, :);
    
    % 条件1: 0より大きい値が1列のみで前後の列が0の場合
    for j = 2:n_f_minus_2
        if signal(j) > 0 && signal(j-1) <= 0 && signal(j+1) <= 0
            signal(j) = 0;
        end
    end
    
    % 条件2: 連続する2列の値がどちらも0より大きい値で前後の列が0の場合
    for j = 2:n_f_minus_2-1
        if signal(j) > 0 && signal(j+1) > 0 && signal(j-1) <= 0 && signal(j+2) <= 0
            signal(j) = 0;
            signal(j+1) = 0;
        end
    end
    
    % 処理した結果をF_signal2に反映
    F_signal2(i, :) = signal;
end

% widthの平均値が低いROIを最低から20%まで削除
nR1_3 = size(F_signal2, 1);
w_size = round(nR1_3 * 0.2);
A = zeros(nR1_3, 1); % Aを初期化
for i = 1:nR1_3  % 各ROIについて
    signal3 = F_signal2(i, 1:end-3);
    [~, ~, width] = findpeaks(signal3);
    A(i, 1) = mean(width); 
end

[~, sortedIndices] = sort(A, 'ascend');
rowsToDelete = sortedIndices(1:w_size); % 該当列の最も低い1番目からw_size番目の値のインデックスを取得

% 行を削除
F_signal2(rowsToDelete, :) = [];

% 任意の数だけすべて列が0の行を作成する数を指定
num_zero_columns = 0; % ここで任意の数を指定

% Figure作成
min_value = min(120, nF_pre); % 60とnF_preの小さい方を選択
ranges = {[1:1798], [1:1798], [1:1798]}; % 任意のframe数の範囲を指定
%ranges = {[1:min_value], [121:min_value+120], [181:min_value+180]}; % 任意のframe数の範囲を指定
titles = {'Columns 1', 'Columns 2', 'Columns 3'};
file_names = {'F_signal2_1.eps', 'F_signal2_2.eps', 'F_signal2_3.eps'};

total_lines = 10; % 合計の行数を計算
colors = lines(total_lines); % 必要な行数の異なる色を取得

for k = 1:3
    range = ranges{k};
    figure;
    hold on;
    
    % データが10行未満の場合はすべての行を使用
    if size(F_signal2, 1) < 10
        randomRows = 1:size(F_signal2, 1);
    else
        % ランダムに10行選択
        randomRows = randperm(size(F_signal2, 1), 10-num_zero_columns);
    end

    % 最大値を取得
    max_value = max(F_signal2(randomRows, range), [], 2);

    offset = 10; % 各グラフをオフセットする量

    % ランダムに選ばれた行と0の列の行を混合するためのインデックス
    allRows = [randomRows, zeros(1, num_zero_columns)]; % 0の行を追加
    allRows = allRows(randperm(length(allRows))); % シャッフル

    for i = 1:length(allRows)
        if allRows(i) == 0
            % 0の行の場合
            plot(zeros(1, length(range)) + (i-1) * offset, 'Color', colors(i, :));
            
            % 縦軸のスケール追加（スケールバーの縦線のみ）
            scale_value = 1; % すべて0の行のスケールは1とする
            plot([0 0], [0 scale_value] + (i-1) * offset, 'Color', colors(i, :), 'LineWidth', 1); % スケールバーの縦線
        else
            % ランダムに選ばれた行の場合
            % 各行の信号を最大値で正規化し、値をオフセットにスケール
            plot(F_signal2(allRows(i), range) + (i-1) * offset, 'Color', colors(i, :));
            
            % 縦軸のスケール追加（スケールバーの縦線のみ）
            scale_value = max_value(find(randomRows == allRows(i))) * 0.2; % 最大値の20%
            plot([0 0], [0 scale_value] + (i-1) * offset, 'Color', colors(i, :), 'LineWidth', 1); % スケールバーの縦線
        end
    end
    
    hold off;

    % 軸を非表示に設定
    set(gca, 'XColor', 'none', 'YColor', 'none');
    title(['Random 10 Rows from F\_signal2 (' titles{k} ')']);
    
    % EPSファイルとして保存
    saveas(gcf, file_names{k}, 'epsc');
end

n_R4 = size(F_signal2, 1);

% for n = 1:n_R4
%     F_2(n, 1:n_f2-3) = F_signal2(n, 1:n_f2-3) / max(F_signal2(n, 1:n_f2-3));
% end

% F_signal2をcell配列に変換
F_signal3 = num2cell(F_signal2);
% 必要な列を抽出
is_cell = vertcat('is_cell', F_signal3(:, n_f2-2));  % is_cell列
is_cellY = vertcat('y', F_signal3(:, n_f2-1));      % y座標列
is_cellX = vertcat('x', F_signal3(:, n_f2));        % x座標列
% 必要なデータを結合
d = horzcat(is_cell, is_cellY, is_cellX);  % is_cell, x, yを結合
d2 = table(d);  % テーブル化
% F_signal3からROI番号列を除去し、残りのデータを整理
F_signal3_cleaned = F_signal3(:, 2:n_f2-3);  % 信号データ部分のみ抽出
% ROI番号を最後の列に移動（1回のみ）
% ROI_numbers取得（今のF_signal3の末尾）
ROI_numbers = cell2mat(F_signal3(:, end));  % ← cell型なら数値化
%ROI_numbers = F_signal3(:, end);  % ROI番号列を抽出
F_signal4 = horzcat(F_signal3_cleaned, ROI_numbers);  % 信号データの最後にROI番号を追加

% ヘッダーを作成（列数を F_signal4 に合わせる）
header = [strcat("Frame_", string(1:(size(F_signal4, 2) - 1))), "ROI_number"];  % ヘッダーを自動調整
F_signal4_with_header = vertcat(header, F_signal4);  % ヘッダーを追加

% % % ヘッダーを作成
% header = [strcat("Frame_", string(1:(n_f2-3))), "ROI_number"];  % ヘッダー（フレーム列 + ROI番号）
% F_signal4_with_header = vertcat(header, F_signal4);  % ヘッダーを追加
% プレゼンテーション用のテーブルを作成
F_table = array2table(F_signal4_with_header);  % 信号データとROI番号を含むデータをテーブル化
F_signal5 = [F_table, d2];  % is_cell, x, y列を結合
% CSVファイルに書き出し
writetable(F_signal5, 'presentation.csv');





% ROI_numbersとoriginal_ROI_numberを連結したデータを作成して格納

% ROI_numbersに対応するoriginal_roi_numberを取得
original_ROI_number_data = cell(length(ROI_numbers), 2);  % 2列のセル配列を初期化

for i = 1:length(ROI_numbers)
    % 現在のROI番号を取得（cellならnum2str不要、数値ならそのまま）
    roi_num = str2double(ROI_numbers{i});  % cellの場合はstr2doubleが安全（数字ならそのまま）

    % 1列目: ROI番号
    original_ROI_number_data{i, 1} = roi_num;

    % Suite2Pのoriginal_roi_numberをstat内から検索
    stat_index = find(arrayfun(@(s) s.original_roi_number, [stat{:}]) == roi_num);

    if ~isempty(stat_index)
        original_ROI_number_data{i, 2} = stat{stat_index}.original_roi_number;
    else
        original_ROI_number_data{i, 2} = NaN;  % 該当するデータがない場合
    end
end


% 結果をoriginal_ROI_numberに代入
original_ROI_number = original_ROI_number_data;

% ヘッダーを追加
header = {'ROI_number', 'Suite2P_ROI_number'};  % ヘッダーを定義

% ヘッダーをoriginal_ROI_numberの上に追加
original_ROI_number = vertcat(header, original_ROI_number);