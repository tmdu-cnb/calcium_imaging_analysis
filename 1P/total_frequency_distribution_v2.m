%% ---------------------- 設定 ---------------------- %%
clear; clc; close all;

% 入力ポップアップの設定
prompt = {
    'Amplitude: ビン間隔', 'Amplitude: 最大値', 'Amplitude: 最小値', ...
    'Area: ビン間隔', 'Area: 最大値', 'Area: 最小値', ...
    'Frequency: ビン間隔', 'Frequency: 最大値', 'Frequency: 最小値', ...
    'Width: ビン間隔', 'Width: 最大値', 'Width: 最小値'
};
dlgtitle = '設定値を入力してください';
dims = [1 35]; % 入力ボックスのサイズ
default_input = {'5', '55', '2.5', '30', '320', '15', '0.05', '0.55', '0.025', '1', '10.5', '0.5'};
user_input = inputdlg(prompt, dlgtitle, dims, default_input);

% 入力値の取得と変換
if isempty(user_input)
    error('キャンセルされました。プログラムを終了します。');
end
bin_params = struct(...
    'amp', struct('interval', str2double(user_input{1}), 'max', str2double(user_input{2}), 'min', str2double(user_input{3})), ...
    'area', struct('interval', str2double(user_input{4}), 'max', str2double(user_input{5}), 'min', str2double(user_input{6})), ...
    'freq', struct('interval', str2double(user_input{7}), 'max', str2double(user_input{8}), 'min', str2double(user_input{9})), ...
    'width', struct('interval', str2double(user_input{10}), 'max', str2double(user_input{11}), 'min', str2double(user_input{12})) ...
);

% 統合データの出力フォルダ作成
output_folder = 'total_frequency_distribution';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% ---------------------- データ統合 ---------------------- %%
% フォルダごとにデータを統合
data_types = {'amp', 'area', 'freq', 'width'};
data_dirs = {'amp_result', 'area_result', 'freq_result', 'width_result'};

% 各タイプのデータを統合し、度数分布を作成
for i = 1:length(data_types)
    type = data_types{i};
    data_dir = data_dirs{i};
    bin_interval = bin_params.(type).interval;
    max_value = bin_params.(type).max;
    min_value = bin_params.(type).min;
    
    % フォルダ内のすべてのCSVファイルを取得
    files = dir(fullfile(data_dir, '*.csv'));
    
    % 統合データ用の配列
    all_data = [];
    
    for file = files'
        filepath = fullfile(file.folder, file.name);
        data = readmatrix(filepath);
        
        % freq と width の場合は横向きデータの可能性があるため転置処理
        if strcmp(type, 'freq') || strcmp(type, 'width')
            if size(data, 1) == 1  % 1行データ（横向き）の場合
                data = data';  % 転置して縦向きにする
            end
        end
        
        all_data = [all_data; data];  % データを統合
    end
    
    % 統合データの度数分布を作成
    bin_edges = min_value:bin_interval:max_value;
    [counts, edges] = histcounts(all_data, bin_edges);
    relative_counts = counts / sum(counts) * 100;
    
    % 度数分布表を作成
    frequency_table = table(edges(1:end-1)', edges(2:end)', counts', relative_counts', ...
        'VariableNames', {'範囲開始', '範囲終了', '度数', '相対度数'});

    % 結果を保存（UTF-8 エンコーディングで書き出し）
    output_file = fullfile(output_folder, sprintf('total_%s_frequency_distribution.csv', type));
    writetable(frequency_table, output_file, 'Encoding', 'Shift-JIS');
    fprintf('%s の統合度数分布を保存: %s\n', type, output_file);
    
    % 度数分布をプロット
    figure;
    scatter(edges(1:end-1) + diff(edges)/2, relative_counts, 's', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    xlabel(upper(type), 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Relative Frequency (%)', 'FontSize', 12, 'FontWeight', 'bold');
    xlim([min(edges), max(edges)]);
    ylim([0, 100]);
    set(gca, 'LineWidth', 1.5);
    grid off;
    
    % 図の縦横比を調整
    pbaspect([1, 0.6, 1]);
    
    % プロットの保存
    saveas(gcf, fullfile(output_folder, sprintf('total_%s_distribution.png', type)));
    close;
end
