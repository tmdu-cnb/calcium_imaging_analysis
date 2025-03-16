for fff=1:size(F_signal2_2,1)
%'MinPeakProminence',0.01 threthold 0.01 relativepeak
% 'MinPeakHeight',0.01, more than 0.01 absolute amplitude
% 'MinPeakDistance', 4
   
   %for z=1:fix(n_f/200)
    %Mean(k,z)=mean(F_signal2(k,1+200*(z-1):200*z)); % Change 1:200 by feature of Sample
    %Standard(k,z)=std(F_signal2(k,1+200*(z-1):200*z)); % Change 1:200 by feature of Sample
    %Th(k,z)=Mean(k,z)+0.5*Standard(k,z);
   
    %size_peak(k,z)=size(findpeaks(F_signal2(k,1+200*(z-1):200*z),'MinPeakProminence',Th(k,z),'MinPeakHeight',Th(k,z),'MinPeakDistance',4),2);
    %[PeakAmp(k,1:size_peak(k,z)),location(k,1:size_peak(k,z)),wid(k,1:size_peak(k,z)),RelativeAmp(k,1:size_peak(k,z))]=findpeaks(F_signal2(k,1+200*(z-1):200*z),'MinPeakProminence',Th(k,z),'MinPeakHeight',Th(k,z),'MinPeakDistance',4);

   %end

   % 221126 How can we analyze signals during remaining time?
   % 221126 calculate width

    Mean(fff)=mean(F_signal2_2(fff,1:size(F_signal2_2,2)-3)); 
    Standard(fff)=std(F_signal2_2(fff,1:size(F_signal2_2,2)-3)); 
    Th(fff)=Mean(fff)+1*Standard(fff);
  
    [PeakAmp{fff},location{fff},wid{fff},RelativeAmp{fff}]=findpeaks(F_signal2_2(fff,1:size(F_signal2_2,2)-3),'MinPeakProminence',Th(fff),'MinPeakHeight',0.2*Th(fff),'MinPeakDistance',4);
    [pp{fff},ll{fff},w{fff},aa{fff}]=findpeaks(F_signal2_2(fff,1:size(F_signal2_2,2)-3),'MinPeakProminence',0.2*Th(fff),'MinPeakHeight',0.2*Th(fff),'MinPeakDistance',100);

     
end

% 列数が5未満の場合、iiの最大値を列数に設定する
maxIndex = min(5, n_R4);

for ii = 1:maxIndex   % Save figure in which trance and peal are described.
        findpeaks(F_signal2_2(ii,1:size(F_signal2_2,2)-3),'MinPeakProminence',0.2*Th(1,ii),'MinPeakHeight', 0.2*Th(1,ii),'MinPeakDistance',100);
         filename_head = 'peaks';
        filename = strcat( filename_head, num2str(ii) ); 
          saveas(gcf,filename,'png')
end
 close;
for aaa=1:size(F_signal2_2,1)
    r=randi([1 size(w{1,aaa},2)]);
    width_all(aaa,1)=w{1,aaa}(r);
 
end

%for iii=1:n_R4
 %   number_peak(iii,1)=size(location{1,iii},2);
  %  for jjj=1:number_peak(iii,1)
   % t(jjj)=location{1,iii}(jjj);

    %        while F_signal2(iii,t(jjj))>0.2*Th(1,iii)
      %          t(jjj)=t(jjj)+1;
     %      end
    %decayT(iii,jjj)=t(jjj)-location{1,iii}(jjj);

    %end

%end
if maxIndex < 5
    % maxIndexが5未満の場合、width_allのすべての列の平均値をM_widthに保存
    M_width = width_all; % 列ごとの平均
else
for ccc=1:maxIndex
    r=randi(fix(n_R4/10));
    %r=randi(fix(25));
M_width(ccc,1)=mean(width_all(1+10*(r-1):10*r,1));
end
end
writematrix(M_width,'Width.csv');


Total_T=(size(F_signal2_2,2)-3)/freq;

for bbb=1:size(F_signal2_2,1)
Number_transients(1,bbb)=size(location{1,bbb},2);
Fre_all(1,bbb)=Number_transients(1,bbb)/Total_T;
end

if maxIndex < 5
    % maxIndexが5未満の場合、width_allのすべての列の平均値をM_widthに保存
    M_freq = Fre_all; % 列ごとの平均
else

for ddd=1:maxIndex
    r=randi(fix(n_R4/10));
    %r=randi(fix(25));
M_freq(ddd,1)=mean(Fre_all(1,1+10*(r-1):10*r));
end
end
writematrix(M_freq,'Freq.csv');

for ddd=1:size(F_signal2_2,1)
    r=randi([1 size(PeakAmp{1,ddd},2)]);
    Amp_all(ddd,1)=PeakAmp{1,ddd}(r);
 
end

if maxIndex < 5
    % maxIndexが5未満の場合、width_allのすべての列の平均値をM_widthに保存
    M_amp = Amp_all; % 列ごとの平均
else
for eee=1:maxIndex
   r=randi(fix(n_R4/10));
    %r=randi(fix(25));
M_amp(eee,1)=mean(Amp_all(1+10*(r-1):10*r,1));
end
end
writematrix(M_amp,'amp.csv');



%積分値を得るために加筆
[num_ROI, num_frames] = size(F_signal2_2);

% area_Allを初期化（各ROIについて積分値を保存）
area_All = cell(num_ROI, 1);

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
end

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
writematrix(Max_area, 'Max_area.csv');


% 新しい部分: area_Allの各ROIの積分値について最大値を選択
max_values = zeros(num_ROI, 1);
for i = 1:num_ROI
    max_values(i, 1) = max(area_All{i});
end

% 値の大きいものから5つ選択し、MAX_5_areaに格納
sorted_values = sort(max_values, 'descend');
MAX_5_area = sorted_values(1:maxIndex);

% MAX_5_areaをMAX_5_area.csvとして書き出す
writematrix(MAX_5_area, 'MAX_5_area.csv');

movefile freq.csv DTA
movefile amp.csv DTA
movefile area.csv DTA
movefile Max_area.csv DTA
movefile MAX_5_area.csv DTA
movefile Width.csv DTA
movefile peaks1.png DTA
movefile peaks2.png DTA
% peaks2.pngが存在するか確認し、存在すれば移動
if exist('peaks2.png', 'file')
    movefile peaks2.png DTA
end
% peaks3.pngが存在するか確認し、存在すれば移動
if exist('peaks3.png', 'file')
    movefile peaks3.png DTA
end
% peaks4.pngが存在するか確認し、存在すれば移動
if exist('peaks4.png', 'file')
    movefile peaks4.png DTA
end

% peaks3.pngが存在するか確認し、存在すれば移動
if exist('peaks5.png', 'file')
    movefile peaks5.png DTA
end

movefile presentation.csv DTA
movefile correlation_fig.svg DTA