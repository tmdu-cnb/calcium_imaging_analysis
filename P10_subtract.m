

mkdir DTA 100% folder name DTA
freq=5; %Change to your frequency

rows_to_delete = [];
% statセル配列の各要素について処理
for i = 1:numel(stat)
    % npixが30未満の場合、対応するFの行を削除するためにrows_to_deleteに追加
    if stat{i}.npix < 30
        rows_to_delete = [rows_to_delete, i];
    end
end

% 対応するFの行を削除する
F(rows_to_delete, :) = [];

for i = numel(rows_to_delete):-1:1;
end

nR_pre = size(F, 1);  % FのROIの数
nF_pre = size(F, 2);  % Fのフレームの数

size2 = size(F(:,1));
size3 = minus(size2(1),1);

for k = 1:size2(1)
  Y{k} = stat{k}.med(1);
end
Y2=Y.';
Y3=double(cell2mat(Y2));
%Y3=vertcat('y',Y2);
%Y4=cell2table(Y3);

for i = 1:size2(1)
  X{i} = stat{i}.med(2); 
end
X2=X.';
X3=double(cell2mat(X2));
%X3=vertcat('x',X2);
%X4=cell2table(X3);

a=(1:size3+1)';
b=zeros(size2(1),1);
%size_x=size(F(1,:));
%size_x2=size_x(2);
%c=1:1:size_x2;
%F1=vertcat(c,F);
F2=horzcat(a,b,F);

cell_1=iscell(:,1);
%cell_pre3=num2cell(cell_1);
cell_pre1=ones(size2(1),1);
%cell_pre2=num2cell(cell_pre1);
%cell_2=vertcat('is_cell',cell_pre2);
%cell_2_zero=vertcat('is_cell',cell_pre3);
%cell_3_zero=table(cell_2_zero);
%cell_3=table(cell_2);
%F3pre=table(F2);
%F3=horzcat(F3pre,cell_3);
%F3_zero=horzcat(F3pre,cell_3_zero);
F3=horzcat(F2,cell_pre1);
%F3cell=num2cell(F3);
%F3cell_zero=num2cell(F3_zero);
F4=horzcat(X3,Y3);
size10 = size(F4, 1);
%F5=table(F4);
F6=horzcat(F3,F4);

% 列を削除するためのインデックスを作成
rows_to_remove2 = false(size(F,1), 1);  % 削除するROIを識別する論理配列

for j = 1:nR_pre % 各ROIについて
first_50_mean = mean(F6(j, 3:52), 'omitnan');
    last_50_mean = mean(F6(j, end-52:end-3), 'omitnan');

    if first_50_mean >= 2 * last_50_mean
        rows_to_remove2(j) = true;  % このROIを削除
    end
end

% 条件に合致する列を削除
F_filtered = F6(~rows_to_remove2, :);
F=F_filtered(:, 3:nF_pre+2);

nR_pre = size(F, 1);  % 新しいFのROIの数
nF_pre = size(F, 2);  % 新しいFのフレームの数

for i=1:nR_pre
min_F(i,1)=min(F(i,1:nF_pre));
end

min_F2=repmat(min_F,1,nF_pre);
F0_pre=F-min_F2;  %すべてのフレームで最も小さいシグナル値を引く。

Frame_Size=50*freq;

for i = 1:nR_pre % 各ROIについて
    signal_pre = F0_pre(i, 1:nF_pre);

    for k = 1:fix(nF_pre/Frame_Size)  % 各開始フレームについて
        T_pre = mean(signal_pre((k-1)*Frame_Size+1:k*Frame_Size))+std(signal_pre((k-1)*Frame_Size+1:k*Frame_Size));  % 現在のフレームからFsizeフレーム分の信号の閾値
        T2_pre=repmat(T_pre,1, Frame_Size);
        signal_1=signal_pre((k-1)*Frame_Size+1:k*Frame_Size);
        signal_2=signal_1;
        signal_1(signal_1>T2_pre)=NaN;
        T3=mean(signal_1, 'omitnan');
        T4=repmat(T3,1,Frame_Size);
        signal_3=signal_2-T4;
        F_pre(i,(k-1)*Frame_Size+1:k*Frame_Size)=signal_3;
    end
  % F_pre(i,Frame_Size*k+1:nF_pre)= F0_pre(i,Frame_Size*k+1:nF_pre);
end

F_pre2=F_pre+min_F2(:,1:size(F_pre,2));

F6=horzcat(F_filtered(:,1:2), F_pre2,F_filtered(:,nF_pre+3:nF_pre+5));
% for k=1:10
% 
%     subplot(10,1,k);
%     axis([0 nF_pre -0.5 10])
%     plot(F_pre(k,1:nF_pre))
%     grid off
%     axis off
% 
% end
% filename_head = 'wave';
% filename = strcat( filename_head, num2str(i) ); 
% saveas(gcf,filename,'jpg')
% close(gcf);
