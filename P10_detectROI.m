% 元の配列のサイズを取得
nR = size(F6, 1);  % FneuのROIの数
nF = size(F6, 2);  % Fneuのフレームの数

% 各行の平均値を計算
mean_values = mean(F6(:, 3:nF-3), 2);

% 平均値が100以下の行を特定
rows_to_remove = mean_values <= 100; %データによって変更する


% 条件に合致する行を削除
F6(rows_to_remove, :) = [];



% % number of frames
% n_f=size(F6,2)-3;
% 
% % number of ROIs
% n_R=size(F6,1);
% 
% file_2=F6(:,3:n_f+3);
% 
% % number of frames for file_2
% n_f2=size(file_2,2);
% 
% file_2pre=file_2;
% 
% n_R2=size(file_2,1);
% 
% file_3=file_2(:,1:n_f2-3);
% 
% for j=1:n_R2
%     T(j,1)=mean(file_3(j,:))+std(file_3(j,:));
%     T2(j,:)=repmat(T(j,1),n_f2-3,1);
% 
% end
% 
% file_3(file_3>T2)=NaN;
% 
% for i=1:n_R2
% M_file_3(i,:)=mean(file_3(i,:),'omitnan');
% S_file_3(i,:)=std(file_3(i,:),'omitnan');
% FBack(i,:)=M_file_3(i,:)+S_file_3(i,:);
% F_signal(i,:)=file_2(i,1:n_f2-3)-FBack(i,:);
% 
%     for pks=1:n_f2-3
%         if F_signal(i,pks)<0
%        F_signal(i,pks)=0;
%         end
%     end
% 
% end
% 
% F_signal2=horzcat(F_signal,file_2(:,n_f2-2:n_f2));

% 初期設定とサイズ計算
n_f = size(F6, 2) - 3;
n_R = size(F6, 1);
file_2 = F6(:, 3:end);
n_f2 = size(file_2, 2);
file_3 = file_2(:, 1:n_f2 - 3);

% TとT2の計算
T = mean(file_3, 2) + std(file_3, 0, 2);
T2 = repmat(T, 1, n_f2 - 3);

% NaNで置き換え
file_3(file_3 > T2) = NaN;

% M_file_3, S_file_3, FBackを計算
M_file_3 = mean(file_3, 2, 'omitnan');
S_file_3 = std(file_3, 0, 2, 'omitnan');
FBack = M_file_3 + S_file_3;

% F_signalの計算
F_signal = bsxfun(@minus, file_2(:, 1:n_f2 - 3), FBack);

% F_signal内の負の値を0に置き換え
F_signal(F_signal < 0) = 0;

% F_signal2の計算
F_signal2 = horzcat(F_signal, file_2(:, n_f2 - 2:n_f2));

% サイズ情報を取得
n_R3 = size(F_signal2, 1);
n_f_minus_2 = n_f - 2;

% 条件に一致するインデックスを見つける
cond1 = F_signal2(:, 1:n_f_minus_2) == 0;
cond2 = F_signal2(:, 3:n_f) == 0;

% cond1とcond2を適切にシフトして、条件を適用する
set_to_zero = circshift(cond1, [0, 1]) & circshift(cond2, [0, -1]);

% 条件に一致する要素を0に設定
F_signal2(set_to_zero) = 0;


 % 30秒以上signalがあるものを取り除く
% frame_count = freq * 50;  % 5フレームで1秒
% n_R3 = size(F_signal2, 1);
% n_frames = size(F_signal2, 2);
% 
% % 列方向に連続値がframe_count以上存在する場合にtrueとする論理配列を初期化
% remove_signal = false(n_R3, 1);
% 
% % 各ROIに対して計算
% for i = 1:n_R3
%     % 現在のROIで信号が存在するフレームを検出
%     current_signal = F_signal2(i, :) > 0;
% 
%     % 各フレームに対してframe_count以上連続して信号が存在するかチェック
%     for r = 1:n_frames - frame_count
%         if all(current_signal(r:r + frame_count))
%             remove_signal(i) = true;
%             break;  % 一度でも条件にマッチしたらこのROIは削除対象
%         end
%     end
% end
% 
% % remove_signalがtrueのROIを削除
% F_signal2(remove_signal, :) = [];

% % 高頻度（10秒間で10回以上）の領域が10箇所あるROIを削除する
% nR1_2pre = size(F_signal2, 1);
% nF = size(F_signal2, 2);
% Fsize = freq * 5;  % 検討するフレーム数
% Psize = 5;  % ピーク数の閾値
% Totalsize = 10;
% 
% % 削除するROIを識別する論理配列
% ROIsToRemove = false(nR1_2pre, 1);
% 
% % 各ROIについて
% for i = 1:nR1_2pre
%     signal = F_signal2(i, 1:end-3);
%     count3 = 0;
% 
%     % 50フレームごとにスキップ
%     for j = 1:Fsize:nF - Fsize - 5
%         segment = signal(j:j + Fsize - 1);  % 現在のフレームからFsizeフレーム分の信号
%         numPeaks = numel(findpeaks(segment));  % ピーク数
% 
%         % ピークの数がPsize以上であればカウントアップ
%         if numPeaks >= Psize
%             count3 = count3 + 1;
%         end
%     end
% 
%     % 合計でTotalsize以上カウントされた場合、そのROIは削除する
%     if count3 >= Totalsize
%         ROIsToRemove(i) = true;
%     end
% end
% 
% % フィルタリング処理
% FneuFiltered = F_signal2(~ROIsToRemove, :);
% F_signal2 = FneuFiltered;

%$$$
% peakの1つ前や1つ後の振幅がpeakの振幅とほぼ同じCa transientが多いROIを削除
% nR1_2 = size(F_signal2, 1);
% nF = size(F_signal2, 2) - 3;
% 
% Psize2 = round(nF / 40);  % ピーク数の閾値
% 
% % 削除するROIを識別する論理配列
% ROIsToRemove2 = false(nR1_2, 1);
% 
% % 各ROIについて
% for i = 1:nR1_2
%     signal2 = F_signal2(i, 1:end-3);
%     [peaks, loci2] = findpeaks(signal2);
%     count = 0;  % 条件を満たす要素の数を初期化
% 
%     % すべてのピークに対して
%     for jj = 1:length(loci2)
%         % ピークの前後の振幅と比較
%         condition1 = abs(signal2(loci2(jj)) - signal2(loci2(jj) - 1)) <= 0.1 * signal2(loci2(jj));
%         condition2 = abs(signal2(loci2(jj)) - signal2(loci2(jj) + 1)) <= 0.1 * signal2(loci2(jj));
% 
%         if condition1 || condition2
%             count = count + 1;
%         end
%     end
% 
%     if count >= Psize2
%         ROIsToRemove2(i) = true;
%     end
% end
% 
% % ROIsToRemoveがtrueのROIをFneuから除去
% FneuFiltered2 = F_signal2(~ROIsToRemove2, :);
% F_signal2 = FneuFiltered2;
%%%%%%

%$$$
% widthの平均値が低いROIを最低から5０番目まで削除
 %231222
 nR1_3=size(F_signal2,1);
 w_size=round(nR1_3*0.2);
for i = 1:nR1_3  % 各ROIについて
signal3 = F_signal2(i, 1:end-3);

   [~, ~,width]=findpeaks(signal3);
   A(i,1) = mean(width); 
end

    [~, sortedIndices] = sort(A, 'ascend');
rowsToDelete = sortedIndices(1:w_size); % 該当列の最も低い1番目からw_size番目の値のインデックスを取得

% 行を削除
F_signal2(rowsToDelete,:) = [];




% 
% for jj=1:n_R5
%     N2(jj,1)=nnz(F_signal2(jj,1:n_f2-3));   %N = nnz(X) Count the number of value which is not 0.
% 
%      if N2(jj,1)<0.1*n_f/freq  %Remove no transients 
%         N2(jj,1)=NaN; 
%      end
% end
% 
% s2=isnan(N2(:,1)); %Remove the line if raw 1 is NaM
% F_signal2(s2,:) = [];  

n_R4=size(F_signal2,1);

for n=1:n_R4
 F_2(n,1:n_f2-3)=F_signal2(n,1:n_f2-3)/max(F_signal2(n,1:n_f2-3));
      
end

F_signal3=num2cell(F_signal2);
is_cell=vertcat('is_cell',F_signal3(:,n_f2-2));
is_cellY=vertcat('y',F_signal3(:,n_f2-1));
is_cellX=vertcat('x',F_signal3(:,n_f2));
d=horzcat(is_cell,is_cellY,is_cellX);
d2=table(d);
e=1:1:n_f2-3;
e2=num2cell(e);
F_signal4=vertcat(e2,F_signal3(:,1:n_f2-3));
F_table=table(F_signal4);
F_signal5=horzcat(F_table,d2);
writetable(F_signal5,'presentation.csv');