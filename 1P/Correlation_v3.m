% ---------------------- 相関処理開始 ---------------------- %

n = size(F_signal2, 1);
if n > 300
    idx_rand = randperm(n, 300);  % 300個のランダムなインデックスを選択
    F_signal2 = F_signal2(idx_rand, :);
    n = 300;  % nを300に更新
end

% 初期化
cormat = zeros(n, n);
Dis_Cor = cell(1, 161);
Dis_Cor_x = cell(1, 161);
Dis_Cor_y = cell(1, 161);
Dis_Cor_x_75 = cell(1, 161);
Dis_Cor_y_75 = cell(1, 161);

% 相関係数計算ループ
for i = 1:n
    sub1 = bsxfun(@minus, F_signal2(i, 1:end-4), mean(F_signal2(i, 1:end-4)));
    a1 = sum(sub1 .* sub1);

    for j = 1:n
        sub2 = bsxfun(@minus, F_signal2(j, 1:end-4), mean(F_signal2(j, 1:end-4)));
        a2 = sum(sub2 .* sub2);
        
        cormat(i, j) = sum(sub1 .* sub2) / sqrt(a1 * a2);
        dx = abs(F_signal2(i, end-2) - F_signal2(j, end-2)); % x方向距離
        dy = abs(F_signal2(i, end-1) - F_signal2(j, end-1)); % y方向距離
        dis = sqrt(dx.^2 + dy.^2); % 全方向距離

        % 距離範囲（ビン）ごとにデータを格納
        bin = min(floor(dis / 5), 160);
        bin_x = min(floor(dx / 5), 160);
        bin_y = min(floor(dy / 5), 160);

        Dis_Cor{bin+1}(end+1, :) = [i, j, cormat(i, j)];
        Dis_Cor_x{bin_x+1}(end+1, :) = [i, j, cormat(i, j)];
        Dis_Cor_y{bin_y+1}(end+1, :) = [i, j, cormat(i, j)];

        % x方向±75px範囲の相関を格納
        if dx <= 75
            bin_x_75 = min(floor(dx / 5), 160);
            Dis_Cor_x_75{bin_x_75 + 1}(end+1, :) = [i, j, cormat(i, j)];
        end

        % y方向±75px範囲の相関を格納
        if dy <= 75
            bin_y_75 = min(floor(dy / 5), 160);
            Dis_Cor_y_75{bin_y_75 + 1}(end+1, :) = [i, j, cormat(i, j)];
        end
    end
end

% 各ビンごとの相関係数平均を計算
M = calculateBinAverages(Dis_Cor);
Mx = calculateBinAverages(Dis_Cor_x);
My = calculateBinAverages(Dis_Cor_y);
Mx_75 = calculateBinAverages(Dis_Cor_x_75);
My_75 = calculateBinAverages(Dis_Cor_y_75);

% 結果を保存
saveAndPlotResults(M, 'Correlation_index.csv', 'correlation_all_fig', 'All');
saveAndPlotResults(Mx, 'Correlation_x_index.csv', 'correlation_x_fig', 'X-direction');
saveAndPlotResults(My, 'Correlation_y_index.csv', 'correlation_y_fig', 'Y-direction');
saveAndPlotResults(Mx_75, 'Correlation_x_75_index.csv', 'correlation_x_75_fig', 'X-direction (±75px)');
saveAndPlotResults(My_75, 'Correlation_y_75_index.csv', 'correlation_y_75_fig', 'Y-direction (±75px)');

% ---------------------- 関数定義 ---------------------- %

% 各ビンの相関係数平均を計算
function M = calculateBinAverages(Dis_Cor)
    M = zeros(1, 161);
    for idx = 1:length(Dis_Cor)
        if ~isempty(Dis_Cor{idx})
            correlations = Dis_Cor{idx}(:, 3);
            M(idx) = mean(correlations);
        else
            M(idx) = NaN;
        end
    end
end

% 結果を保存し、プロットする
function saveAndPlotResults(data, csvFilename, figFilename, titleText)
    % データをCSVに保存
    writematrix(data, csvFilename);
    movefile(csvFilename, 'result');
    
    % プロットして保存
    figure;
    plot(1:161, data, 'LineWidth', 2);
    xlabel('Bin');
    ylabel('Average Correlation');
    title(['Correlation: ', titleText]);
    saveas(gcf, figFilename, 'png');
    close;
end
