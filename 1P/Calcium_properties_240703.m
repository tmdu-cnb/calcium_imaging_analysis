



% all_amp とall_widthを初期化
all_amp = [];

all_width = [];

for fff=1:size(F_signal2_2,1)
    
    Mean(fff) = mean(F_signal2_2(fff, 1:size(F_signal2_2, 2) - 3)); 
    Standard(fff) = std(F_signal2_2(fff, 1:size(F_signal2_2, 2) - 3)); 
    Th(fff) = Mean(fff) + 1 * Standard(fff);
  
    [PeakAmp{fff}, location{fff}, wid{fff}, RelativeAmp{fff}] = findpeaks(F_signal2_2(fff, 1:size(F_signal2_2, 2) - 3), 'MinPeakProminence', Th(fff), 'MinPeakHeight', 0.2 * Th(fff), 'MinPeakDistance', 4);
    [pp{fff},ll{fff},w{fff},aa{fff}]=findpeaks(F_signal2_2(fff,1:size(F_signal2_2,2)-3),'MinPeakProminence',0.2*Th(fff),'MinPeakHeight',0.2*Th(fff),'MinPeakDistance',100);
    all_amp = [all_amp, PeakAmp{fff}];
    all_width = [all_width, wid{fff}];
end

% 列数が5未満の場合、iiの最大値を列数に設定する
maxIndex = min(5, n_R4);

Total_T = (size(F_signal2_2, 2) - 3) / freq;

for bbb = 1:size(F_signal2_2, 1)
    Number_transients(1, bbb) = size(location{1, bbb}, 2);
    Fre_all(1, bbb) = Number_transients(1, bbb) / Total_T;
end

% Fre_allの値が0.0033より大きい行の数をカウント
NOF = sum(Fre_all > 0.0033);

% Fre_all からランダムに 5 個選んで Fre_5 に格納
%num_to_select = 5;
%random_indices = randperm(length(Fre_all), num_to_select);
%Fre_5 = Fre_all(random_indices);

% for aaa=1:size(F_signal2_2,1)
%     r=randi([1 size(w{1,aaa},2)]);
%     width_all(aaa,1)=w{1,aaa}(r);
% 
% end

% if maxIndex < 5
%     % maxIndexが5未満の場合、width_allのすべての列の平均値をM_widthに保存
%     M_width = width_all; % 列ごとの平均
% else
% for ccc=1:maxIndex
%     r=randi(fix(n_R4/10));
%     %r=randi(fix(25));
% M_width(ccc,1)=mean(width_all(1+10*(r-1):10*r,1));
% end
% end
writematrix(all_width,'Width.csv');

% 各行の30列ごとのピーク頻度を計算
num_cols = size(F_signal2_2, 2) - 3;
num_intervals = floor(num_cols / 30);
Freq_30cols = zeros(size(F_signal2_2, 1), num_intervals);
Class_UP = cell(size(F_signal2_2, 1), 1); %最初の30列の頻度と比べて、頻度が上がっている３０列の番号を出力

for fff = 1:size(F_signal2_2, 1)
    first_interval_freq = 0;
    for interval = 1:num_intervals
        start_col = (interval - 1) * 30 + 1;
        end_col = interval * 30;
        [peaks_in_interval, locs_in_interval] = findpeaks(F_signal2_2(fff, start_col:end_col), 'MinPeakProminence', Th(fff), 'MinPeakHeight', 0.2 * Th(fff), 'MinPeakDistance', 4);
        Freq_30cols(fff, interval) = numel(peaks_in_interval) / 30;
        
        if interval == 1
            first_interval_freq = Freq_30cols(fff, interval);
        elseif Freq_30cols(fff, interval) > first_interval_freq
            Class_UP{fff} = [Class_UP{fff}, interval];
        end
    end
end

% 必要に応じて Fre_5 を保存または処理
%writematrix(Freq_30cols, 'Freq_30cols.csv'); % 100列ごとの周波数を保存
%movefile('Freq_30cols.csv', 'result');  % ファイルを result フォルダに移動

% 必要に応じて Fre_5 を保存または処理
%writematrix(Fre_5', 'Fre_5.csv');  % Fre_5 を CSV ファイルとして保存
%movefile('Fre_5.csv', 'result');  % ファイルを result フォルダに移動
writematrix(Fre_all, 'Freq.csv');

% Class_UPの各値を行列に変換
Class_UP_Matrix = zeros(size(F_signal2_2, 1), num_intervals);
for i = 1:length(Class_UP)
    if ~isempty(Class_UP{i})
        Class_UP_Matrix(i, 1:length(Class_UP{i})) = Class_UP{i};
    end
end

writematrix(Class_UP_Matrix, 'Class_UP.csv'); % Class_UPをCSVファイルとして保存
movefile('Class_UP.csv', 'result');  % ファイルを result フォルダに移動

% 各行の60列ごとの頻度を計算
num_cols = size(F_signal2_2, 2) - 3;
num_intervals = floor(num_cols / 60);
Freq_60cols = zeros(size(F_signal2_2, 1), num_intervals);

for fff = 1:size(F_signal2_2, 1)
    for interval = 1:num_intervals
        start_col = (interval - 1) * 60 + 1;
        end_col = interval * 60;
        [peaks_in_interval, locs_in_interval] = findpeaks(F_signal2_2(fff, start_col:end_col), 'MinPeakProminence', Th(fff), 'MinPeakHeight', 0.2 * Th(fff), 'MinPeakDistance', 4);
        Freq_60cols(fff, interval) = numel(peaks_in_interval) / 60;
    end
end

% 最初の60列の頻度が0.0033より大きい行の数をカウント
Num_first = sum(Freq_60cols(:, 1) > 0.0033);

% 61列以降の60列ごとで0.0033より大きい行の数をカウント
max_count = 0;
for interval = 2:num_intervals
    count = sum(Freq_60cols(:, interval) > 0.0033);
    if count > max_count
        max_count = count;
        max_interval = interval;
    end
end
Num_max = max_count;

% 61列以降の60列ごとで0.0033より大きい行の数をカウント
min_count = inf; % 最小値を無限大で初期化

for interval = 2:num_intervals
   count = sum(Freq_60cols(:, interval) > 0.0033);
    if count < min_count
        min_count = count;
        min_interval = interval;
    end
end

% 結果を表示
fprintf('最小カウント: %d (インターバル: %d)\n', min_count, min_interval);

% 結果を表示
fprintf('Num_first: %d\n', Num_first);
fprintf('Num_max: %d (interval: %d)\n', Num_max, max_interval);

% 最初の60列の頻度を保存
Freq_first = Freq_60cols(:, 1);

% 61列以降の60列ごとで頻度が最も大きい60列の頻度を保存
[Freq_Max, max_interval_indices] = max(Freq_60cols(:, 2:end), [], 2);

% 結果を1つのCSVファイルに保存
Freq_combined = [Freq_first, Freq_Max];
writematrix(Freq_combined, 'Freq_combined.csv');
movefile('Freq_combined.csv', 'result');

% 5つの行をランダムに抽出し、頻度を保存
random_rows = randperm(size(F_signal2_2, 1), 5);
Freq_change = Freq_combined(random_rows, :);
writematrix(Freq_change, 'Freq_change.csv');
movefile('Freq_change.csv', 'result');

% for ddd = 1:size(F_signal2_2, 1)
%     if size(PeakAmp{1, ddd}, 2) > 0
%         r = randi([1 size(PeakAmp{1, ddd}, 2)]);
%         Amp_all(ddd, 1) = PeakAmp{1, ddd}(r);
%     else
%         Amp_all(ddd, 1) = NaN; % または他の適切な値
%     end
% end
% 
% if maxIndex < 5
%     % maxIndexが5未満の場合、width_allのすべての列の平均値をM_widthに保存
%     M_amp = Amp_all; % 列ごとの平均
% else
% for eee=1:maxIndex
%    r=randi(fix(n_R4/10));
%     %r=randi(fix(25));
% M_amp(eee,1)=mean(Amp_all(1+10*(r-1):10*r,1));
% end
% end
% writematrix(M_amp,'amp.csv');

writematrix(all_amp', 'all_amp.csv');  % all_amp を CSV ファイルとして保存
movefile('all_amp.csv', 'result');  % ファイルを result フォルダに移動

%積分値を得るために加筆
[num_ROI, num_frames] = size(F_signal2_2);

% area_Allを初期化（各ROIについて積分値を保存）
area_All = cell(num_ROI, 1);

% すべてのiのarea_listを1列に並べてall_areaに格納するためのリスト
all_area = [];

% 各ROIに対して処理
for i = 1:num_ROI
    signal = F_signal2_2(i, :); % i番目のROIに対するシグナルを取得
    
    start_flag = false; % シグナルの開始フラグ
    area = 0; % 積分値を初期化
    area_list = []; % 各シグナルの積分値を保存するリスト
    
    % 各フレームに対して処理
    for j = 1:num_frames
        if ~start_flag && signal(j) > 0
            % シグナル開始
            start_flag = true;
            area = signal(j);
        elseif start_flag && signal(j) > 0
            % シグナル中
            area = area + signal(j);
        elseif start_flag && signal(j) == 0
            % シグナル終了
            start_flag = false;
            area_list = [area_list, area]; % 積分値をリストに追加
            area = 0; % 積分値をリセット
        end
    end
    
    % 積分値をarea_Allに格納
    area_All{i} = area_list;

    % area_listをall_areaに追加
    all_area = [all_area, area_list];

end

% all_areaを保存
writematrix(all_area', 'all_area.csv');
movefile('all_area.csv', 'result');

%  area_Allからランダムに5つのROIを選択
random_indices = randi([1 num_ROI], 1, maxIndex);

%  それぞれのROIの積分値の平均を M_areaに格納
M_area = zeros(maxIndex, 1); % 初期化
for fff = 1:maxIndex
    r = random_indices(fff);
    M_area(fff, 1) = mean(area_All{r});
end
%  M_areaをarea.csvとして書き出す
writematrix(M_area, 'area.csv');

%　MAXを比較　ver.1
% 1. area_Allからランダムに5つのROIを選択
random_indices_for_max = randi([1 num_ROI], 1, maxIndex);

% 2. それぞれのROIの積分値の最大値を Max_areaに格納
Max_area = zeros(maxIndex, 1); % 初期化
for k = 1:maxIndex
    roi_index_for_max = random_indices_for_max(k);
    Max_area(k, 1) = max(area_All{roi_index_for_max});
end

% 3. Max_areaをMax_area.csvとして書き出す
%writematrix(Max_area, 'Max_area.csv');

% 新しい部分: area_Allの各ROIの積分値について最大値を選択
num_ROI = size(area_All, 1); % `area_All` の行数を `num_ROI` と定義

max_values = zeros(num_ROI, 1);
for i = 1:num_ROI
    if ~isempty(area_All{i})
        max_values(i, 1) = max(area_All{i});
    else
        max_values(i, 1) = NaN; % または他の適切な値
    end
end

% 値の大きいものから5つ選択し、MAX_5_areaに格納
sorted_values = sort(max_values, 'descend', 'MissingPlacement', 'last');
MAX_5_area = sorted_values(1:min(5, sum(~isnan(sorted_values))));

% MAX_5_areaをMAX_5_area.csvとして書き出す
%writematrix(MAX_5_area, 'MAX_5_area.csv');


% 60列ごとのAmplitudeを計算し、その60列で最大のAmplitudeを取得する部分
Amplitude_max_60cols = cell(size(F_signal2_2, 1), 1); % 60列ごとの最大Amplitudeを保存するためのcell配列

for fff = 1:size(F_signal2_2, 1)
    num_60cols_intervals = floor(num_cols / 60);
    Amplitude_max_60cols{fff} = zeros(1, num_60cols_intervals);
    for interval = 1:num_60cols_intervals
        start_col = (interval - 1) * 60 + 1;
        end_col = interval * 60;
        [peaks_in_interval, locs_in_interval] = findpeaks(F_signal2_2(fff, start_col:end_col), 'MinPeakProminence', Th(fff), 'MinPeakHeight', 0.2 * Th(fff), 'MinPeakDistance', 4);
        if ~isempty(peaks_in_interval)
            Amplitude_max_60cols{fff}(interval) = max(peaks_in_interval);
        else
            Amplitude_max_60cols{fff}(interval) = NaN;
        end
    end
end

% ランダムに10行を選択し、CSVに保存
random_10_rows = randperm(size(F_signal2_2, 1), 10);
Amplitude_selected = cell2mat(Amplitude_max_60cols(random_10_rows));
writematrix(Amplitude_selected, 'Amplitude_selected.csv');
movefile('Amplitude_selected.csv', 'result');

movefile Width.csv result
movefile freq.csv result
% movefile amp.csv result
movefile area.csv result
movefile F_signal2_3.eps result
movefile F_signal2_2.eps result
movefile F_signal2_1.eps result
movefile presentation.csv result
movefile correlation_fig.svg result
