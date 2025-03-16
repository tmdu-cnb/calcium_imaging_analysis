% all_ampデータの読み込み
all_amp_data = readmatrix('result/all_amp.csv');  % 事前に保存したall_amp.csvを読み込む

% データの範囲を取得
bin_interval_amp = 5;  % ビン間隔
max_value_amp = 55;  % 最大値
min_value_amp = 2.5;  % 最小値

data_max = max(all_amp_data);  % データの最大値

% ビンの境界を5スタートで5単位で設定
bin_edges = min_value_amp:bin_interval_amp:max_value_amp;  % 最大値を5の倍数に切り上げる

% ビンの境界を5スタートで5単位で設定
% bin_edges = min_value:bin_interval:(ceil(data_max / 5) * 5);  % 最大値を5の倍数に切り上げる

% 度数分布を計算
[counts, edges] = histcounts(all_amp_data, bin_edges);

% 相対度数を計算
total_counts = sum(counts);  % データの総数
relative_counts = counts / total_counts * 100;  % 相対度数（パーセント）

% 結果を度数分布表として表示
disp('度数分布表Amplitude:');
disp(table(edges(1:end-1)', edges(2:end)', counts', relative_counts', 'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'}));

% 度数分布表をCSVファイルとして保存
frequency_table = table(edges(1:end-1)', edges(2:end)', counts', relative_counts', 'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'});
writetable(frequency_table, 'result/amp_frequency_distribution.csv');

% 度数分布を図として表示（相対度数を縦軸に）
figure;
scatter(edges(1:end-1) + diff(edges)/2, relative_counts, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');  % 黒四角で点をプロット
xlabel('Amplitude');
ylabel('%');
%title('度');
xlim([0, 50]);  % x軸の範囲を設定
ylim([0, 100]);  % y軸を0から100%に設定
set(gca, 'LineWidth', 1.5);  % 軸の線を太くする
grid off;  % グリッドをオフ

% 図の縦横比を1:0.7に設定
pbaspect([1, 0.6, 1]);  % アスペクト比を1:0.7に設定







% all_areaデータの読み込み
all_area_data = readmatrix('result/all_area.csv');  % 事前に保存したall_area.csvを読み込む

% ビンの間隔を設定
bin_interval_area = 30;  % ビン間隔
max_value_area = 320;  % 最大値
min_value_area = 15;  % 最小値

% データの最大値を取得
data_max = max(all_area_data);  % データの最大値

% ビンの境界を設定（0からデータの最大値を超えるまで30間隔で）
bin_edges = min_value_area:bin_interval_area:max_value_area;

% ビンの境界を設定（0からデータの最大値を超えるまで30間隔で）
% bin_edges = 0:bin_interval:ceil(data_max/bin_interval)*bin_interval;

% 度数分布を計算
[counts, edges] = histcounts(all_area_data, bin_edges);

% 相対度数を計算
total_counts = sum(counts);  % データの総数
relative_counts = counts / total_counts * 100;  % 相対度数（パーセント）

% 結果を度数分布表として表示
disp('度数分布表Area:');
disp(table(edges(1:end-1)', edges(2:end)', counts', relative_counts', 'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'}));

% 度数分布表をCSVファイルとして保存
frequency_table = table(edges(1:end-1)', edges(2:end)', counts', relative_counts', 'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'});
writetable(frequency_table, 'result/area_frequency_distribution.csv');

% 度数分布を図として表示（相対度数を縦軸に）
figure;
scatter(edges(1:end-1) + diff(edges)/2, relative_counts, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');  % 黒四角で点をプロット
xlabel('Area of Ca2+ transient');
ylabel('%');
%title('度');
xlim([min(edges), max(edges)]);  % x軸の範囲を設定
ylim([0, 100]);  % y軸を0から100%に設定
set(gca, 'LineWidth', 1.5);  % 軸の線を太くする
grid off;  % グリッドをオフ

% 図の縦横比を1:0.7に設定
pbaspect([1, 0.6, 1]);  % アスペクト比を1:0.7に設定







% Freqデータの読み込み
all_freq_data = readmatrix('result/Freq.csv');  % 事前に保存したFreq.csvを読み込む

% ビンの間隔を設定
bin_interval_fre = 0.05;  % ビン間隔
max_value_fre = 0.55;  % 最大値
min_value_fre = 0.025;  % 最小値



% データの最大値を取得
data_max = max(all_freq_data);  % データの最大値

% ビンの境界を設定（0からデータの最大値を超えるまで0.05間隔で）
bin_edges = min_value_fre:bin_interval_fre:max_value_fre;
% ビンの境界を設定（0からデータの最大値を超えるまで0.05間隔で）
% bin_edges = 0:bin_interval:ceil(data_max/bin_interval)*bin_interval;

% 度数分布を計算
[counts, edges] = histcounts(all_freq_data, bin_edges);

% 相対度数を計算
total_counts = sum(counts);  % データの総数
relative_counts = counts / total_counts * 100;  % 相対度数（パーセント）

% 結果を度数分布表として表示
disp('度数分布表freq:');
disp(table(edges(1:end-1)', edges(2:end)', counts', relative_counts', 'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'}));

% 度数分布表をCSVファイルとして保存
frequency_table = table(edges(1:end-1)', edges(2:end)', counts', relative_counts', 'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'});
writetable(frequency_table, 'result/frequency_distribution.csv');

% 度数分布を図として表示（相対度数を縦軸に）
figure;
scatter(edges(1:end-1) + diff(edges)/2, relative_counts, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');  % 黒四角で点をプロット
xlabel('Frequency (Hz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Relative Frequency (%)', 'FontSize', 12, 'FontWeight', 'bold');
xlim([min(edges), max(edges)]);  % x軸の範囲を設定
ylim([0, 100]);  % y軸を0から100%に設定
set(gca, 'LineWidth', 1.5);  % 軸の線を太くする
grid off;  % グリッドをオフ

% 図の縦横比を1:0.6に設定
pbaspect([1, 0.6, 1]);  % アスペクト比を1:0.6に設定





% widthデータの読み込み
all_width_data = readmatrix('result/Width.csv');  % 事前に保存したWidth.csvを読み込む

% ビンの間隔と最大値を設定
bin_interval_wid = 1;  % ビン間隔
max_value_wid = 10.5;  % 最大値
min_value_wid = 0.5;  % 最小値

% ビンの境界を設定（0.5から最大値まで1間隔で）
bin_edges = min_value_wid:bin_interval_wid:max_value;

% 度数分布を計算
[counts, edges] = histcounts(all_width_data, bin_edges);

% 相対度数を計算
total_counts = sum(counts);  % データの総数
relative_counts = counts / total_counts * 100;  % 相対度数（パーセント）

% 結果を度数分布表として表示
disp('度数分布表width:');
disp(table(edges(1:end-1)', edges(2:end)', counts', relative_counts', 'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'}));

% 度数分布表をCSVファイルとして保存
frequency_table = table(edges(1:end-1)', edges(2:end)', counts', relative_counts', 'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'});
writetable(frequency_table, 'result/frequency_distribution.csv');

% 度数分布を図として表示（相対度数を縦軸に）
figure;
scatter(edges(1:end-1) + diff(edges)/2, relative_counts, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');  % 黒四角で点をプロット
xlabel('Width', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Relative Frequency (%)', 'FontSize', 12, 'FontWeight', 'bold');
xlim([0, max_value]);  % x軸の範囲を設定
ylim([0, 100]);  % y軸を0から100%に設定
set(gca, 'LineWidth', 1.5);  % 軸の線を太くする
grid off;  % グリッドをオフ

% 図の縦横比を1:0.6に設定
pbaspect([1, 0.6, 1]);  % アスペクト比を1:0.6に設定


