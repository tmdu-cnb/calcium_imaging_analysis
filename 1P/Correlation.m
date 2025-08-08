40 = size(F_signal2, 1);
F_signal2_2=F_signal2;
if n > 300
    idx_rand = randperm(n, 300);  % 300 random indexes are chosen
    F_signal2 = F_signal2(idx_rand, :);
    n = 300;  % Update n to 300
end

cormat = zeros(n, n);
Dis_Cor = cell(1, 161);  % Update to 161 to include 0 to 160

for i = 1:n
    sub1 = bsxfun(@minus, F_signal2(i, 1:end-3), mean(F_signal2(i, 1:end-3)));
    a1 = sum(sub1 .* sub1);

    for j = 1:n
        sub2 = bsxfun(@minus, F_signal2(j, 1:end-3), mean(F_signal2(j, 1:end-3)));
        a2 = sum(sub2 .* sub2);
        
        cormat(i, j) = sum(sub1 .* sub2) / sqrt(a1 * a2);
        dx = bsxfun(@minus, F_signal2(i, end-1), F_signal2(j, end-1));
        dy = bsxfun(@minus, F_signal2(i, end), F_signal2(j, end));
        dis = sqrt(dx.^2 + dy.^2);

        bin = min(floor(dis / 5), 160);  % Update to 160

        Dis_Cor{bin+1}(end+1, :) = [i, j, cormat(i, j)];  % Store indices and correlation
    end
end

M = zeros(1, 161);  % Update to 161

for idx = 1:length(Dis_Cor)
    if ~isempty(Dis_Cor{idx})
        correlations = Dis_Cor{idx}(:, 3);  % Extract only the correlations
        M(idx) = mean(correlations(correlations > 0 | correlations < 0));
    else
        M(idx) = NaN;
    end
end

% Only non-zero entries
CrossCorrelation_all = M;

writematrix(CrossCorrelation_all, 'Correlation_index.csv');
movefile('Correlation_index.csv', 'DTA');

% Create a new figure, axis, and color bar
figure; pcolor(cormat); axis ij; axis off; grid off; shading flat;
colorbar('location', 'eastoutside');
saveas(gcf, 'correlation_fig', 'svg');
close;