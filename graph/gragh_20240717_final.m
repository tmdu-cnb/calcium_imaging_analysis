% Load data
csv_fname = 'presentation.csv';
img_fname = 'MAX_c_a.tif';

data = readtable(csv_fname);

% Display column names to verify 'is_cell' is present
disp(data.Properties.VariableNames);

% Display first few rows to inspect data
disp(head(data, 5));

% Filter all segmented ROIs by is_cell value
if ismember('Var1501', data.Properties.VariableNames)
    cells = data(data.Var1501 == 1, :);
else
    error('The column "Var1501" does not exist in the data table.');
end

% Extract activity columns into separate matrix
cells_activity = cells{:, 2:1500};

% Extract coordinates of cells
xs = cells.Var1503;
ys = cells.Var1502;

% Plot all locations of cells as points
figure;
plot(ys, xs, '.');

% Set aspect ratio 1:1
ax = gca;
ax.DataAspectRatio = [1 1 1];

% Normalize function for fluorescence traces
function norm_trace = norm(f)
    norm_trace = (f - min(f)) / max(f - min(f));
end

% Cluster cells based on coordinates
num_clusters = 4;
coordinates = cells{:, end-1:end}; % Assuming the last two columns are coordinates
[idx, C] = kmeans(coordinates, num_clusters);

% Sort cells by cluster ID
[sorted_idx, sorted_indices] = sort(idx);

% Reorder the activity data based on the sorted indices
reordered_activity = cells_activity(sorted_indices, :);

% Plotting clusters on the image
figure('Position', [100, 100, 1800, 1000]);

% Show original data image
subplot(1, 2, 1);
imshow(imread(img_fname), []);
hold on;

% Plot locations of cells with different colors based on cluster ID
cmap = colormap('parula');  % Use 'parula' colormap
cmap = cmap(round(linspace(1, size(cmap, 1), num_clusters)), :);
scatter(ys, xs, 30, cmap(idx, :), 'MarkerEdgeColor', 'flat', 'MarkerFaceColor', 'none');  % Open circles with colored edges

% Label clusters with numbers
for Ki = 1:num_clusters
    cluster_indices = find(idx == Ki);
    text(mean(ys(cluster_indices)), mean(xs(cluster_indices)), num2str(Ki), 'FontSize', 15, 'Color', 'w', 'FontWeight', 'bold');
end

% Create colorbar without value numbers
cb = colorbar('eastoutside');
cb.Label.String = 'Fluorescence, a.u.';
set(cb, 'XTick', []);  % Remove numbers from the color bar

saveas(gcf, 'dotted_map', 'svg');
close;


% Correlation heatmap using reordered cell sequence
n = size(reordered_activity, 1);
cormat = zeros(n, n);
Dis_Cor = cell(1, 161);  % Update to 161 to include 0 to 160

for i = 1:n
    sub1 = bsxfun(@minus, reordered_activity(i, :), mean(reordered_activity(i, :)));
    a1 = sum(sub1 .* sub1);

    for j = 1:n
        sub2 = bsxfun(@minus, reordered_activity(j, :), mean(reordered_activity(j, :)));
        a2 = sum(sub2 .* sub2);
        
        cormat(i, j) = sum(sub1 .* sub2) / sqrt(a1 * a2);
        dx = bsxfun(@minus, cells.Var1503(sorted_indices(i)), cells.Var1503(sorted_indices(j)));
        dy = bsxfun(@minus, cells.Var1502(sorted_indices(i)), cells.Var1502(sorted_indices(j)));
        dis = sqrt(dx.^2 + dy.^2);

        bin = min(floor(dis / 5), 160);  % Update to 160

        Dis_Cor{bin + 1}(end + 1, :) = [i, j, cormat(i, j)];  % Store indices and correlation
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

writematrix(CrossCorrelation_all, 'Correlation_index_reordered.csv');
movefile('Correlation_index_reordered.csv', 'result');

% Create a new figure with correlation heatmap and cluster color bar on the left
figure('Position', [100, 100, 1200, 1000]);

% Create left color bar for clusters
ax1 = subplot('Position', [0.05 0.1 0.05 0.8]);
Koffset = 0;
yticks = zeros(1, num_clusters);
for Ki = 1:num_clusters
    Nk = sum(sorted_idx == Ki);
    rectangle('Position', [0 Koffset 1 Nk], 'FaceColor', cmap(Ki, :), 'EdgeColor', 'none');
    yticks(Ki) = Koffset + Nk / 2;
    Koffset = Koffset + Nk;
end
set(ax1, 'YDir', 'reverse', 'YTick', yticks, 'YTickLabel', arrayfun(@num2str, 1:num_clusters, 'UniformOutput', false));
axis off;

% Adjust the height of the cluster color bar to match the heatmap
ax1.Position = [0.05 0.1 0.05 0.8];
ax2 = subplot('Position', [0.15 0.1 0.8 0.8]);
pcolor(ax2, cormat);
axis ij;
axis off;
grid off;
shading flat;
colorbar('location', 'eastoutside');
caxis([0 1]);  % Set colorbar limits to 0-1

% Adjust the aspect ratio to make the heatmap square
ax2.DataAspectRatio = [1 1 1];

saveas(gcf, 'cluster_labels', 'svg');
close;

% Create figure 4: Correlation heatmap without the cluster label color bar
figure;
pcolor(cormat);
axis ij;
axis off;
grid off;
shading flat;
colorbar('location', 'eastoutside');
caxis([0 1]);  % Set colorbar limits to 0-1
saveas(gcf, 'correlation_fig_without_cluster_labels', 'svg');
close;
