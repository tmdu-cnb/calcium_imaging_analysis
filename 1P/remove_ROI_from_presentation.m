% presentation.csvから選択したROI_numberを除去する処理
% 
% このスクリプトは、presentation.csvファイルを読み込み、
% ユーザーが選択したoriginal_roi_number（画像に表示される番号）に対応する
% roi_numの行を削除して、更新されたCSVファイルを保存します。
% 
% 注意: stat変数がワークスペースに存在する必要があります。

% stat変数の存在確認
if ~exist('stat', 'var')
    error('stat変数がワークスペースに見つかりません。stat変数を読み込んでから実行してください。');
end

% CSVファイルを読み込む
csvFile = 'presentation.csv';  % CSVファイル名

% ファイルの存在確認
if ~exist(csvFile, 'file')
    error('presentation.csvファイルが見つかりません。');
end

% テーブルとして読み込む（ヘッダー行を保持）
data_table = readtable(csvFile, 'ReadVariableNames', false);

% ROI番号の列を特定
% presentation.csvの構造: 最後から3列目がROI_number
num_cols = width(data_table);
roi_col_idx = num_cols - 3;  % 最後から3列目

% データ行を取得（ヘッダー行を除く）
% 最初の2行がヘッダー行の可能性があるため、ROI番号が数値かどうかで判定
data_rows = 3:height(data_table);  % 3行目以降がデータ行と仮定

% presentation.csvからroi_numを取得
roi_numbers = [];
for i = data_rows
    roi_val = data_table{i, roi_col_idx};
    if isnumeric(roi_val) || (ischar(roi_val) && ~isempty(str2num(roi_val)))
        roi_num = roi_val;
        if isnumeric(roi_num)
            roi_numbers = [roi_numbers; roi_num];
        elseif ischar(roi_num) || isstring(roi_num)
            roi_numbers = [roi_numbers; str2double(roi_num)];
        end
    end
end

% 各roi_numに対応するoriginal_roi_numberを取得
original_roi_list = [];
roi_num_to_original_map = containers.Map('KeyType', 'double', 'ValueType', 'double');
original_to_roi_num_map = containers.Map('KeyType', 'double', 'ValueType', 'double');

for i = 1:length(roi_numbers)
    roi_num = roi_numbers(i);
    % stat配列の範囲チェック
    if roi_num > 0 && roi_num <= length(stat) && ~isempty(stat{roi_num})
        if isfield(stat{roi_num}, 'original_roi_number')
            original_roi = stat{roi_num}.original_roi_number;
            original_roi_list = [original_roi_list; original_roi];
            roi_num_to_original_map(roi_num) = original_roi;
            original_to_roi_num_map(original_roi) = roi_num;
        end
    end
end

% ユニークなoriginal_roi_numberを取得してソート
unique_original_rois = unique(original_roi_list);
unique_original_rois = sort(unique_original_rois);

% original_roi_numberが存在しない場合
if isempty(unique_original_rois)
    error('original_roi_numberが見つかりませんでした。stat変数にoriginal_roi_numberフィールドが存在するか確認してください。');
end

% カスタムダイアログでROI選択（リスト選択と番号入力の両方を表示）
list_items = cellstr(num2str(unique_original_rois));

% ダイアログの作成
dlg_width = 400;
dlg_height = 500;
screen_size = get(0, 'ScreenSize');
dlg_pos = [(screen_size(3)-dlg_width)/2, (screen_size(4)-dlg_height)/2, dlg_width, dlg_height];

dlg = dialog('Position', dlg_pos, 'Name', 'ROI番号の選択（画像に表示される番号）');

% 結果格納用（appdataを使用）
setappdata(dlg, 'result_ok', false);
setappdata(dlg, 'result_list_selection', []);
setappdata(dlg, 'result_input_text', '');

% リストボックスのラベル
uicontrol('Parent', dlg, ...
    'Style', 'text', ...
    'Position', [20, dlg_height-40, 360, 20], ...
    'String', 'リストから選択（Ctrl+クリックで複数選択可）:', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 10);

% リストボックス
listbox = uicontrol('Parent', dlg, ...
    'Style', 'listbox', ...
    'Position', [20, dlg_height-320, 360, 270], ...
    'String', list_items, ...
    'Max', 2, ...  % 複数選択を有効化
    'Min', 0, ...
    'Value', [], ...  % 初期選択なし
    'FontSize', 10, ...
    'Tag', 'roi_listbox');

% 番号入力のラベル
uicontrol('Parent', dlg, ...
    'Style', 'text', ...
    'Position', [20, dlg_height-355, 360, 20], ...
    'String', '番号を直接入力（カンマまたはスペース区切り）:', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 10);

% 番号入力フィールド
editbox = uicontrol('Parent', dlg, ...
    'Style', 'edit', ...
    'Position', [20, dlg_height-385, 360, 25], ...
    'String', '', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 10, ...
    'Tag', 'roi_editbox');

% 説明テキスト
uicontrol('Parent', dlg, ...
    'Style', 'text', ...
    'Position', [20, dlg_height-430, 360, 35], ...
    'String', '※ リスト選択と番号入力の両方を使用できます。両方指定した場合は統合されます。', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9, ...
    'ForegroundColor', [0.4, 0.4, 0.4]);

% OKボタン（無名関数でコールバック）
uicontrol('Parent', dlg, ...
    'Style', 'pushbutton', ...
    'Position', [90, 20, 100, 35], ...
    'String', 'OK', ...
    'FontSize', 10, ...
    'Callback', @(src,evt) roi_dialog_ok(dlg));

% キャンセルボタン
uicontrol('Parent', dlg, ...
    'Style', 'pushbutton', ...
    'Position', [210, 20, 100, 35], ...
    'String', 'キャンセル', ...
    'FontSize', 10, ...
    'Callback', @(src,evt) roi_dialog_cancel(dlg));

% ウィンドウが閉じられた場合の処理
set(dlg, 'CloseRequestFcn', @(src,evt) roi_dialog_cancel(dlg));

% ダイアログが閉じられるまで待機
uiwait(dlg);

% 結果を取得
if ishandle(dlg)
    result_ok = getappdata(dlg, 'result_ok');
    result_list_selection = getappdata(dlg, 'result_list_selection');
    result_input_text = getappdata(dlg, 'result_input_text');
    delete(dlg);
else
    result_ok = false;
    result_list_selection = [];
    result_input_text = '';
end

% キャンセルされた場合
if ~result_ok
    disp('処理がキャンセルされました。');
    return;
end

% リストから選択されたROI番号を取得
selected_from_list = [];
if ~isempty(result_list_selection)
    selected_from_list = unique_original_rois(result_list_selection);
end

% 入力フィールドから番号を取得
selected_from_input = [];
if ~isempty(result_input_text)
    input_str = result_input_text;
    input_str = strrep(input_str, ',', ' ');  % カンマをスペースに変換
    input_nums = str2num(input_str);  %#ok<ST2NM>
    
    if ~isempty(input_nums)
        % 入力された番号が有効なROI番号かチェック
        invalid_nums = input_nums(~ismember(input_nums, unique_original_rois));
        if ~isempty(invalid_nums)
            warning('以下の番号は存在しないため無視されます: %s', mat2str(invalid_nums));
        end
        selected_from_input = input_nums(ismember(input_nums, unique_original_rois));
    end
end

% リスト選択と入力を統合
selected_original_rois = unique([selected_from_list(:); selected_from_input(:)]);
selected_original_rois = sort(selected_original_rois);

% 何も選択されていない場合
if isempty(selected_original_rois)
    errordlg('ROI番号が選択されていません。', 'エラー');
    return;
end

% 選択されたoriginal_roi_numberに対応するroi_numを取得
selected_roi_nums = [];
for i = 1:length(selected_original_rois)
    orig_roi = selected_original_rois(i);
    if isKey(original_to_roi_num_map, orig_roi)
        selected_roi_nums = [selected_roi_nums; original_to_roi_num_map(orig_roi)];
    end
end

% 削除する行のインデックスを特定
rows_to_remove = false(height(data_table), 1);
for i = 1:height(data_table)
    roi_val = data_table{i, roi_col_idx};
    % 数値に変換して比較
    if isnumeric(roi_val)
        roi_num = roi_val;
    elseif ischar(roi_val) || isstring(roi_val)
        roi_num = str2double(roi_val);
    else
        roi_num = NaN;
    end
    
    % 選択されたroi_numと一致するかチェック
    if ~isnan(roi_num) && ismember(roi_num, selected_roi_nums)
        rows_to_remove(i) = true;
    end
end

% 削除する行数を表示
num_rows_to_remove = sum(rows_to_remove);
fprintf('削除するoriginal_roi_number（画像に表示される番号）: %s\n', mat2str(selected_original_rois));
fprintf('対応するroi_num: %s\n', mat2str(selected_roi_nums));
fprintf('削除する行数: %d 行\n', num_rows_to_remove);

% 確認ダイアログ
confirm_msg = sprintf('選択したROI番号（画像に表示される番号、%d個）の行を削除しますか？\n削除行数: %d 行\n\n削除する番号: %s', ...
    length(selected_original_rois), num_rows_to_remove, mat2str(selected_original_rois));
confirm_answer = questdlg(confirm_msg, '削除の確認', 'はい', 'いいえ', 'いいえ');

if strcmp(confirm_answer, 'いいえ')
    disp('処理がキャンセルされました。');
    return;
end

% 行を削除
data_table_filtered = data_table(~rows_to_remove, :);

% バックアップファイルを作成（元のファイルを保持）
backupFile = [csvFile(1:end-4), '_backup_', datestr(now, 'yyyymmdd_HHMMSS'), '.csv'];
copyfile(csvFile, backupFile);
fprintf('バックアップファイルを作成しました: %s\n', backupFile);

% 更新されたCSVファイルを保存
writetable(data_table_filtered, csvFile, 'WriteVariableNames', false);

fprintf('処理が完了しました。\n');
fprintf('元のファイル: %s\n', csvFile);
fprintf('バックアップ: %s\n', backupFile);
fprintf('削除されたoriginal_roi_number（画像に表示される番号）: %s\n', mat2str(selected_original_rois));
fprintf('削除されたroi_num（statのインデックス）: %s\n', mat2str(selected_roi_nums));
fprintf('残りのROI数: %d\n', height(data_table_filtered) - 2);  % ヘッダー行を除く

%% ローカル関数定義（ダイアログのコールバック用）

function roi_dialog_ok(dlg)
    % OKボタンが押された時の処理
    if ~ishandle(dlg)
        return;
    end
    
    % リストボックスの値を取得
    listbox_handle = findobj(dlg, 'Tag', 'roi_listbox');
    editbox_handle = findobj(dlg, 'Tag', 'roi_editbox');
    
    if ~isempty(listbox_handle)
        setappdata(dlg, 'result_list_selection', get(listbox_handle, 'Value'));
    end
    
    if ~isempty(editbox_handle)
        setappdata(dlg, 'result_input_text', get(editbox_handle, 'String'));
    end
    
    setappdata(dlg, 'result_ok', true);
    uiresume(dlg);
end

function roi_dialog_cancel(dlg)
    % キャンセルボタンが押された時の処理
    if ~ishandle(dlg)
        return;
    end
    setappdata(dlg, 'result_ok', false);
    uiresume(dlg);
end
