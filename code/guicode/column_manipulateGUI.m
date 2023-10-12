function column_manipulateGUI(varargin)  
%% Acycle column manipulate
% read selected data files
% add selected columns using user-defined weight
% Mingsong Li
% Peking University
% Oct. 12, 2023

    % read data
    plot_selected = varargin{1}.plot_selected;
    n = varargin{1}.nplot;
    contents = varargin{1}.contents;   % short name with no extension
    handles.listbox_acmain = varargin{1}.listbox_acmain;
    handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
    handles.val1 = varargin{1}.val1;
    
    % prepare data
    dataCell = cell(1, n);
    ncol = zeros(1, n);
    colhead = [];
    % get working directory
    
    ac_pwd = fileread('ac_pwd.txt');
    disp(' ')
    disp(' Column Manipulate ...')
    
    for i = 1:n
        plot_no = plot_selected(i);
        plot_filter_s = char(contents(plot_no));
        dataCell{i} = load(fullfile(ac_pwd,plot_filter_s));
        ncol(i) = size(dataCell{i}, 2);
        disp(plot_filter_s)  % show data files in the command window
        colhead = [colhead, 1:ncol(1), nan];
    end
    disp(' ')
    %ncol
    ncolcumsum = cumsum(ncol);
    ncolsum = sum(ncol);
        
    % Merge data and insert blank columns
    mergedData = [];
    dataMan = [];
    for i = 1:n
        mergedData = [mergedData, dataCell{i}, nan(size(dataCell{i}, 1), 1)];  % Add a column of NaNs as blank
    end
    
    % Create GUI Figure
    fig_handle1 = figure('Units', 'normalized', ...
                        'Position', [0.2, 0.2, 0.6, 0.6], ...
                        'MenuBar', 'none', ...
                        'ToolBar', 'none', ...
                        'Name', 'Data Processing GUI', ...
                        'NumberTitle', 'off');
    set(fig_handle1,'units','norm') % set location
    set(0,'Units','normalized') % set units as normalized
    
    % create edit text for showing file names
    ncolcumsum1 = 2:(2+n-1);
    ncolcumsum2 = ncolcumsum + ncolcumsum1;
    ncolcumsum2 = [1,  ncolcumsum2];

    jj = 0;
    
    uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0.01,0.86,0.05,0.03], ...
        'String', 'Select', 'FontSize', 12,...
        'HorizontalAlignment', 'left');
    uicontrol('Style', 'text', 'Units', 'normalized', ...
                'Position', [0.01,0.82,0.05,0.03], ...
                'String', 'Weight', 'FontSize', 12,...
                'HorizontalAlignment', 'left');
    uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0.01,0.9,0.04,0.03], ...
        'String', 'Data', 'FontSize', 12,...
        'HorizontalAlignment', 'left');
    % Create UIControls
    for i = 1: ncolsum + n - 1
        if ~all(isnan(mergedData(:,i)))
            % Checkboxes
            checkBoxes(i) = uicontrol('Style', 'checkbox', 'Units', 'normalized', ...
                'Position', [(i-1)*0.7/(ncolsum+n-1)+.05, 0.86, 0.7/(ncolsum+n-1), 0.03], ...
                'String', num2str(i), 'FontSize', 12,'HorizontalAlignment', 'left',...
                'Value',0,'Callback',@checkCall);
            % Edit texts
            editText(i) = uicontrol('Style', 'edit', 'Units', 'normalized', ...
                'Position', [(i-1)*0.7/(ncolsum+n-1)+.05, 0.82, 0.5/(ncolsum+n-1), 0.03], ...
                'String', '1',  'FontSize', 12,'HorizontalAlignment', 'center',...
                'Enable','Off','Callback',@checkCall);
        end
        
        if i == 2
            set(checkBoxes(i),'Value',1)
            set(editText(i),'Enable','on')
        end
        
        % show file names
        if ismember(i, ncolcumsum2)
            jj = jj + 1;
            plot_no = plot_selected(jj);
            plot_filter_s = char(contents(plot_no));
            editTitle(jj) = uicontrol('Style', 'edit', ...
                    'Units', 'normalized', ...
                    'Position', [(i-1)*0.7/(ncolsum+n-1)+.05, 0.9, 0.7*(ncol(jj)+1)/(ncolsum + n - 1), 0.03], ...
                    'String', plot_filter_s,  ...
                    'FontSize', 12, ...
                    'HorizontalAlignment', 'right');
        end
    end
    
    % hide NaN columns
    data = mergedData(:,1:end-1);
    data_for_uitable = arrayfun(@num2str, data, 'UniformOutput', false);
    is_nan_cell = cellfun(@(x) strcmp(x, 'NaN'), data_for_uitable);
    data_for_uitable(is_nan_cell) = {''};
    
    % Data left side Table
    dataTable = uitable(fig_handle1,'Data', data_for_uitable, ...
        'Units', 'normalized', ...
        'Position', [0.035, 0.05, 0.7, 0.75], ...
        'FontSize', 12,...
        'ColumnName', cellstr(string(colhead(1:end-1))));
    % resize table
    %updateColumnWidth(dataTable, fig_handle1.Position(3) * 0.7);
    %addlistener(fig_handle1, 'SizeChanged', @(src, event) updateColumnWidth(dataTable, fig_handle1.Position(3) * 0.7));
    
    % Right Side Table
    dataTable2 = uitable(fig_handle1,'Units', 'normalized', 'Position', [0.75, 0.05, 0.2, 0.75], 'FontSize', 12);
    mergedData2 = dataCell{1}(:,1:2);
    dataTable2.ColumnName = cellstr(string(1:2));
    dataTable2.Data = mergedData2;
    
    % OK Button
    uicontrol(fig_handle1,'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.85, 0.81, 0.1, 0.05], ...
        'String', 'OK', 'FontSize', 12, ...
        'Callback', @onOKButtonPressed);
    %%
    %function onOKButtonPressed(yt, fnt, data_name)
    function onOKButtonPressed(~,~)
        % Callback function code here
        disp('OK Button Pressed');
        
        % refresh main window
        pre_dirML = pwd;
        ac_pwd = fileread('ac_pwd.txt');
        if isdir(ac_pwd)
            cd(ac_pwd)
            disp([' Working Dir: ', ac_pwd])
        else
            disp([' Data in Working Dir: ', pre_dirML])
        end
        
        date = datestr(now,30);
        
        % Save the transformed data
        plot_no = plot_selected(1);
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        [~,plot_filter_s,~] = fileparts(plot_filter_s);
        name1 = [plot_filter_s,'-ColManip-',date,'.txt'];
        dlmwrite(name1, [mergedData(:,1), dataMan], 'delimiter', ' ', 'precision', 9);
        
        disp(name1)
        
        % refresh main window
        d = dir; %get files
        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
        % define some nested parameters
        pre  = '<HTML><FONT color="blue">';
        post = '</FONT></HTML>';
        address = pwd;
        d = dir; %get files
        d(1)=[];
        d(1)=[];
        listboxStr = cell(numel(d),1);
        ac_pwd_str = which('ac_pwd.txt');
        [ac_pwd_dir,ac_pwd_name, ext] = fileparts(ac_pwd_str);
        fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
        T = struct2table(d);
        sortedT = [];
        sd = [];
        str=[];
        i=[];
        refreshcolor;
        cd(pre_dirML); % return to matlab view folder
    end
%%
% 
function updateColumnWidth(dataTable, figWidth)
    % get number of columns
    numColumns = width(dataTable.Data);
    % set width for each column
    newWidth = figWidth / numColumns * ones(1, numColumns);
    dataTable.ColumnWidth = mat2cell(newWidth, 1, ones(1, numColumns));
end
%%
    function checkCall(~,~)
        colman1 = [];   % save checkbox string or id or column number of mergedData
        dataMan = zeros(length(mergedData),1);
        k = 0;
        % checkboxes call back
        for i = 1: ncolsum + n - 1
            try
                vi = checkBoxes(i);
                viv = vi.Value;
                if viv == 1
                    k = k+1;   % number of selected checkboxes
                    set(editText(i),'Enable','on')
                    colman1(k,1) = i;   % save ID
                    colman1(k,2) = str2double(get(editText(i),'String'));  % save weight
                else
                    set(editText(i),'Enable','off')
                end
            catch
            end
        end
        %
        if k > 0
            % add col * weight
            for j = 1:k
                dataMan1 = mergedData(:, colman1(j,1)) .* colman1(j,2);
                dataMan = dataMan + dataMan1;
            end
            % update right side table
            
            dataTable2.Data = [mergedData(:,1), dataMan];
        end
    end
end
