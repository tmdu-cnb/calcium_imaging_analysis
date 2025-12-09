%% ==== 基本設定 ====
X          = F_signal2_2;              % [nROI x nFramesAll]
nROI       = size(X,1);
nFramesAll = size(X,2);
trimTail   = 3;                        % 末尾3列は無視
nFrames    = nFramesAll - trimTail;    % 解析対象フレーム数
Fs         = freq;                     % サンプリング周波数 [Hz]（既存変数を利用）
Total_T    = nFrames / Fs;

maxIndex   = min(5, nROI);

%% ==== しきい値の事前計算 ====
Xmain   = X(:,1:nFrames);                         
mu      = mean(Xmain, 2);
sigma   = std(Xmain, 0, 2);
Th      = mu + 1.*sigma;                          
xmax    = max(Xmain, [], 2);
xmin    = min(Xmain, [], 2);
drange  = max(xmax - xmin, eps);                  

MinProm = min(Th, 0.5*drange);
MinH    = 0.2*Th;

PeakAmp = cell(nROI,1);
location = cell(nROI,1);
wid = cell(nROI,1);
RelativeAmp = cell(nROI,1);

%% ==== 行ごとのピーク検出 ====
for r = 1:nROI
    x = Xmain(r,:);
    mp = max(MinProm(r), 0);                  
    useHeight = xmax(r) > MinH(r);

    if useHeight
        [PeakAmp{r}, location{r}, wid{r}, RelativeAmp{r}] = ...
            findpeaks(x, 'MinPeakProminence', mp, 'MinPeakHeight', MinH(r), 'MinPeakDistance', 4);
    else
        [PeakAmp{r}, location{r}, wid{r}, RelativeAmp{r}] = ...
            findpeaks(x, 'MinPeakProminence', mp, 'MinPeakDistance', 4);
    end
end

all_amp   = cell2mat(PeakAmp(:)');
all_width = cell2mat(wid(:)');

%% ==== 発火頻度 ====
Number_transients = cellfun(@numel, location);              
Fre_all           = Number_transients ./ Total_T;           
NOF               = sum(Fre_all > 0.0033);                  

%% ==== 積分（正値区間の面積） ====
area_All = cell(nROI,1);
all_area = [];

for r = 1:nROI
    sig = X(r,:);
    pos = sig > 0;
    if ~any(pos)
        area_All{r} = [];
        continue
    end
    d      = diff([false, pos, false]);     
    starts = find(d == 1);
    stops  = find(d == -1) - 1;
    A = zeros(1, numel(starts));
    for j = 1:numel(starts)
        A(j) = sum(sig(starts(j):stops(j))); 
    end
    area_All{r} = A;
    all_area    = [all_area, A];
end

%% ==== 60列ごとの最大振幅 ====
step60       = 60;
nInt60       = floor(nFrames / step60);
Amplitude_max_60cols = cell(nROI,1);

for r = 1:nROI
    x  = Xmain(r,:);
    mp = max(MinProm(r), 0);
    mh = MinH(r);
    Am = nan(1, nInt60);
    for k = 1:nInt60
        s = (k-1)*step60 + 1; e = k*step60;
        xi = x(s:e);
        if max(xi) > mh
            pk = findpeaks(xi, 'MinPeakProminence', mp, 'MinPeakHeight', mh, 'MinPeakDistance', 4);
        else
            pk = findpeaks(xi, 'MinPeakProminence', mp, 'MinPeakDistance', 4);
        end
        if ~isempty(pk), Am(k) = max(pk); end
    end
    Amplitude_max_60cols{r} = Am;
end

% ランダム 10 行を抽出して保存
rows10            = randperm(nROI, min(10,nROI));
Amplitude_selected = cell2mat(Amplitude_max_60cols(rows10));
writematrix(Amplitude_selected, 'Amplitude_selected.csv');
movefile('Amplitude_selected.csv', 'result');

%% ==== 保存 (必要なものだけ) ====
writematrix(all_width, 'Width.csv');
writematrix(Fre_all,   'Freq.csv');
writematrix(all_amp(:),'all_amp.csv');
writematrix(all_area(:),'all_area.csv');

if ~exist('result','dir'), mkdir result; end
movefile('Width.csv',   'result');
movefile('Freq.csv',    'result');
movefile('all_amp.csv', 'result');
movefile('all_area.csv','result');

% その他のファイル移動
safeMove = @(f) (exist(f,'file') && movefile(f,'result'));
safeMove('F_signal2_3.eps');
safeMove('F_signal2_2.eps');
safeMove('F_signal2_1.eps');
safeMove('presentation.csv');
safeMove('correlation_fig.svg');
