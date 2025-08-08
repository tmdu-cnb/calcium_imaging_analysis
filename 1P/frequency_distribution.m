% histogram_analysis.m (single‑dialog version)
% -------------------------------------------------------------------------
% This script reads feature vectors (Amplitude, Area, Frequency, Width) from
% CSV files in ./result and plots their histograms.  At startup it opens ONE
% dialog box where you can enter **bin interval / max / min** for every
% feature.  If you cancel, the defaults shown in the dialog are used.
% -------------------------------------------------------------------------
close all; clc;

%% -------- Default parameters -------------------------------------------
defVals = struct( ...
    'amp',  [5   55   2.5 ], ... % [binInterval max min]
    'area', [30  320  15  ], ...
    'freq', [0.05 0.55 0.025], ...
    'wid',  [1   10.5 0.5 ]);

%% -------- Single input dialog ------------------------------------------
prompt = {
    'Amplitude  –  bin interval', 'Amplitude  –  MAX', 'Amplitude  –  MIN', ...
    'Area       –  bin interval', 'Area       –  MAX', 'Area       –  MIN', ...
    'Frequency  –  bin interval', 'Frequency  –  MAX', 'Frequency  –  MIN', ...
    'Width      –  bin interval', 'Width      –  MAX', 'Width      –  MIN'};

defInput = arrayfun(@num2str, [defVals.amp defVals.area defVals.freq defVals.wid], 'UniformOutput', false);
answer   = inputdlg(prompt, 'Histogram settings (all features)', [1 45], defInput);

if isempty(answer)  % user cancelled → keep defaults
    params = [defVals.amp; defVals.area; defVals.freq; defVals.wid];
else
    numAns = cellfun(@str2double, answer);
    params = reshape(numAns, 3, []).';   % each row: [interval max min]
end

%% -------- Helper for histogram -----------------------------------------
function makeHistogram(data, featureName, csvOut, binInt, maxVal, minVal)
    binEdges  = minVal : binInt : maxVal;
    [counts, edges] = histcounts(data, binEdges);
    relCounts = counts / sum(counts) * 100;

    tbl = table(edges(1:end-1)', edges(2:end)', counts', relCounts', ...
                'VariableNames', {'Start', 'End', 'Count', 'RelPercent'});
    fprintf('\nFrequency table — %s\n', featureName);
    disp(tbl);
    writetable(tbl, fullfile('result', csvOut));

    figure;
    scatter(edges(1:end-1)+diff(edges)/2, relCounts, 's', 'MarkerEdgeColor','k', 'MarkerFaceColor','k');
    xlabel(featureName, 'FontSize',12,'FontWeight','bold');
    ylabel('Relative Frequency (%)', 'FontSize',12,'FontWeight','bold');
    xlim([min(binEdges) max(binEdges)]); ylim([0 100]);
    set(gca,'LineWidth',1.5); pbaspect([1 0.6 1]);
end

%% -------- Amplitude -----------------------------------------------------
ampData = readmatrix('result/all_amp.csv');
makeHistogram(ampData, 'Amplitude', 'amp_frequency_distribution.csv', params(1,1), params(1,2), params(1,3));

%% -------- Area ----------------------------------------------------------
areaData = readmatrix('result/all_area.csv');
makeHistogram(areaData, 'Area of Ca2+ transient', 'area_frequency_distribution.csv', params(2,1), params(2,2), params(2,3));

%% -------- Frequency -----------------------------------------------------
freqData = readmatrix('result/Freq.csv');
makeHistogram(freqData, 'Frequency (Hz)', 'freq_frequency_distribution.csv', params(3,1), params(3,2), params(3,3));

%% -------- Width ---------------------------------------------------------
widthData = readmatrix('result/Width.csv');
makeHistogram(widthData, 'Width', 'width_frequency_distribution.csv', params(4,1), params(4,2), params(4,3));
