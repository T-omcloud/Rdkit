function hotmap()
    % 选择文件
    [fname, pname] = uigetfile({'*.xlsx;*.xls;*.csv;*.txt', '数据文件'}, '请选择数据文件');
    if isequal(fname,0), return; end
    filepath = fullfile(pname, fname);
    [~,~,ext] = fileparts(fname);

    % 初始化
    rowLabels = [];
    colLabels = [];
    data = [];

    % 自动尝试读取标签
    try
        if any(strcmpi(ext, {'.xlsx','.xls'}))
            % Excel，获取原始数据
            [~, ~, raw] = xlsread(filepath);
            if size(raw,1) >= 2 && size(raw,2) >= 2
                % 提取行标签（第一列，从第二行开始）
                rowLabels = raw(2:end, 1);
                rowLabels = cellfun(@num2str, rowLabels, 'UniformOutput', false);
                % 提取列标签（第一行，从第二列开始）
                colLabels = raw(1, 2:end);
                colLabels = cellfun(@num2str, colLabels, 'UniformOutput', false);
                % 提取数值数据（第二行起，第二列起）
                data = cell2mat(raw(2:end, 2:end));
            else
                % 文件行列不足，直接读数值
                data = xlsread(filepath);
            end
        else
            % 文本文件（csv/txt），使用 readtable 读取
            T = readtable(filepath);
            if width(T) >= 2
                % 第一列作为行标签
                rowLabels = T{:, 1};
                if isnumeric(rowLabels)
                    rowLabels = cellstr(num2str(rowLabels));
                else
                    rowLabels = cellstr(rowLabels);
                end
                % 剩余列作为数据，变量名作为列标签
                data = T{:, 2:end};
                colLabels = T.Properties.VariableNames(2:end);
            else
                % 只有一列，直接读数值
                data = readmatrix(filepath);
            end
        end
    catch
        % 读取标签失败，回退到纯数值读取
        if any(strcmpi(ext, {'.xlsx','.xls'}))
            data = xlsread(filepath);
        else
            data = readmatrix(filepath);
        end
        rowLabels = [];
        colLabels = [];
    end

    % 清理无效数据
    data = data(:, all(~isnan(data),1));
    data = data(all(~isnan(data),2), :);
    if isempty(data)
        errordlg('无有效数据'); return;
    end

    % 生成默认标签
    nRows = size(data,1);
    nCols = size(data,2);
    if isempty(rowLabels) || length(rowLabels) ~= nRows
        rowLabels = cellstr(num2str((1:nRows)'));
    end
    if isempty(colLabels) || length(colLabels) ~= nCols
        colLabels = cellstr(num2str((1:nCols)'));
    end

    % Y轴倒序
    data_rev = flipud(data);
    rowLabels_rev = flipud(rowLabels);

    % 创建图形
    fig = figure('Position', [100 100 800 600]);
    h = heatmap(data_rev);
    h.XDisplayLabels = colLabels;          % 列标签正序
    h.YDisplayLabels = rowLabels_rev;      % 行标签倒序

    % 淡紫色系颜色映射
    nColors = 256;
    cmap = zeros(nColors,3);
    for i = 1:nColors
        t = (i-1)/(nColors-1);
        if t < 0.5
            cmap(i,:) = [0.85 - t*0.4, 0.75 - t*0.6, 0.95 - t*0.2];
        else
            t2 = (t-0.5)/0.5;
            cmap(i,:) = [0.65 - t2*0.45, 0.45 - t2*0.35, 0.85 - t2*0.5];
        end
    end
    colormap(cmap);
    h.Colormap = cmap;

    % 设置颜色轴范围
    clim([min(data(:)), max(data(:))]);

    % 美化
    h.ColorbarVisible = 'on';
    h.GridVisible = 'off';
    h.CellLabelColor = 'k';
    h.FontSize = 10;
    h.Title = '热图 (Y轴倒序)';
    title(h.Parent, '热图 (Y轴倒序)', 'FontSize', 12);

    fprintf('数据大小: %d x %d, 范围: %.2f ~ %.2f\n', nRows, nCols, min(data(:)), max(data(:)));
end