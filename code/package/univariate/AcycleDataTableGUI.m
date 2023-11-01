function AcycleDataTableGUI(varargin)
% a graphic user interface for Acycle
%   allows users to copy, paste, cut and select data (must be numerical values)
%   selected data will be transferred to Acycle
%   
%   Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   Oct. 20, 2023
%   Assisted by GPT-4
   
    %% Read handles
    % default number of rows and columns
    nrow = 45;  
    ncol = 12;
    data = cell(nrow, ncol);
    data(:) = {[]};  % Fill in all cells with an empty string
    
    try
        nplot = varargin{1}.nplot;
        plot_s = varargin{1}.plot_s;
        
        colstart = 1;
        
        for i = 1:nplot
            try
                datai = load(plot_s{i});
            catch

                T = readtable(plot_s{i}); % Adjust the 'HeaderLines' if more than one header line
                % If T contains different data types per column, this step might not be straightforward
                if all(varfun(@isnumeric, T, 'OutputFormat', 'uniform'))
                    datai = table2array(T);
                    disp(['Load data ',plot_s{i},' with header ...'])
                else
                    disp('Data contains non-numeric values or multiple data types.');
                end

            end
            [nrowi, ncoli] = size(datai);
            for j = 1: nrowi
                for k = 1:ncoli
                    data{j, colstart+k-1} = num2str(datai(j,k));
                end
            end
            % add additional empty row or column
            data{nrowi + 1, ncoli+1} = num2str([]);
            colstart = colstart + ncoli +1; % leave a empty column
        end
    catch
        % Create an empty cell array for 99 rows and 26 columns
        
    end
    % Look for an existing figure with the name 'sf'
    f = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');
    % If no such figure exists, create a new one
    if isempty(f)
        % Create a figure
        f = uifigure('Name', 'Acycle: Data Table', ...
            'Position', [100, 100, 1000, 800],...
            'NumberTitle', 'off','MenuBar', 'none');
        
        set(f,'units','norm') % set location
        set(f,'Units','normalized') % set units as normalized
        

        
         % Generate column names from 'A' to 'Z'
        %colNames = arrayfun(@(x) {char(x)}, 65:90); % Creates a cell array with individual cells for 'A', 'B', ..., 'Z'

    %%   % Create a uitable in the figure
        t = uitable(f, 'Data', data,...
                    'Units', 'normalized',...
                    'FontSize', 12, ...
                    'Position', [0.0, 0., 1, 1],...
                    'CellEditCallback', @cellEditCallback);
                
        % Initially, set all columns to be non-editable
        t.ColumnEditable = false(1, ncol); % Assuming there are ncol columns
        % Set the CellSelectionCallback for the table
        t.CellSelectionCallback = @cellSelectionCallback;
        % Variable to keep track of the last selected cell
        lastSelectedCell = [];
        
        % Set the key press function for the figure
        f.WindowKeyPressFcn = @keyPressCallback;
    
    else
        figure(f)
    end
    
    % Variable to store selected data
     selectedData = [];
     select_id1=1;  % selected cell row id first one
     select_id2=1;  % selected cell col id first one
    %selectedData

    
    % Cell selection callback function
    function cellSelectionCallback(src, event)
        selectedData = [];
        % If no cell is selected, do nothing
        if isempty(event.Indices)
            return;
        end
        
        select_id = event.Indices;  % ID for selected cells
        select_id1 = unique(select_id(:,1));  % row id
        select_id2 = unique(select_id(:,2));  % col id
        newdatasize = [length(select_id1), length(select_id2)];
        for i = 1: newdatasize(1) % row
            for j = 1: newdatasize(2)  % col
                cellArray = src.Data(select_id1(i), select_id2(j));
                selectedData(i,j) = str2double(cellArray{1});
            end
        end
        
        % If a cell was previously selected, make its column non-editable again
        if ~isempty(lastSelectedCell)
            src.ColumnEditable(lastSelectedCell(2)) = false;
        end

        % Get the currently selected cell
        row = event.Indices(1);
        col = event.Indices(2);

        % Make the column of the selected cell editable
        src.ColumnEditable(col) = true;

        % Save the currently selected cell
        lastSelectedCell = [row, col];
        % 'selectedData' is the variable I want to share
        f.UserData = selectedData;
        
    end

    % This callback function will execute when the cell is edited
    function cellEditCallback(src, event)
        selectedData = get(t, 'Data'); % Get the updated data from the uitable
    end

   
    % This function is called when the 'cut' menu item is selected
    function cutCallback(src, event)
        
        % get all data shown in table
        tdata = get(t, 'Data');
        for i = 1: length(select_id1)
            for j = 1: length(select_id2)
                tdata{select_id1(i), select_id2(j)} = num2str([]);
            end
        end

        %tdata
        t.Data = tdata;
        
        % save data in clipboard
        data = selectedData;
        [nrow, ncol] = size(data);
        % Convert the data matrix to a string format
        dataString = [];
        for i = 1:nrow
            % Concatenating each number in a row with a tab delimiter, and at the end of the row, a newline
            rowString = sprintf('%g\t', data(i,:));

            % Removing the trailing tab character at the end of each row
            rowString = rowString(1:end-1);

            % Adding a newline character at the end of each row, building the final string
            dataString = [dataString, rowString, char(10)]; % char(10) is the newline character
        end

        % Copying the resulting string to the clipboard
        clipboard('copy', dataString);
    end


    % This function is called when the 'delete' menu item is selected
    function deleteCallback(src, event)
        
        % get all data shown in table
        tdata = get(t, 'Data');
        for i = 1: length(select_id1)
            for j = 1: length(select_id2)
                tdata{select_id1(i), select_id2(j)} = num2str([]);
            end
        end

        %tdata
        t.Data = tdata;
        
    end
    
    % This function is called when the 'paste' menu item is selected
    function pasteCallback(src, event)
        
        clipboardData = clipboard('paste');
        clipboardData = strtrim(clipboardData); % Remove any trailing newline
        rows = strsplit(clipboardData, '\n'); % Split into rows
        dataMatrix = cellfun(@(r) str2double(strsplit(r, '\t')), rows, 'UniformOutput', false);
        dataMatrix = vertcat(dataMatrix{:}); % Convert cell array to matrix
        %cellstr(string(dataMatrix))
        [dataMatrixRow, dataMatrixCol] = size(dataMatrix);  % size of copied data
        % get all data shown in table
        tdata = get(t, 'Data');
        [nrow, ncol] = size(tdata); % size of whole table
        
        %event.Indices
        if isnan(dataMatrix)
            return;
        end
        
        for i = 1:dataMatrixRow
            for j = 1:dataMatrixCol
                tdata{select_id1(1)+i-1, select_id2(1)+j-1} = num2str(dataMatrix(i,j));
            end
        end
        % add additional empty row or column
        tdata{select_id1(1)+ i, select_id2(1)+j} = num2str([]);

        t.Data = tdata;
        
    end

    % This function is called when the 'Copy' menu item is selected
    function copyCallback(src, event)

        data = selectedData;
        [nrow, ncol] = size(data);
        % Convert the data matrix to a string format
        dataString = [];
        for i = 1:nrow
            % Concatenating each number in a row with a tab delimiter, and at the end of the row, a newline
            rowString = sprintf('%g\t', data(i,:));

            % Removing the trailing tab character at the end of each row
            rowString = rowString(1:end-1);

            % Adding a newline character at the end of each row, building the final string
            dataString = [dataString, rowString, char(10)]; % char(10) is the newline character
        end

        % Copying the resulting string to the clipboard
        clipboard('copy', dataString);
    end

    % This function is called whenever a key is pressed in the figure
    function keyPressCallback(~, event)
        % Check if 'c' was pressed along with Ctrl or Cmd
        if strcmp(event.Key, 'c') && (ismember('control', event.Modifier) || ismember('command', event.Modifier))
            copyCallback();
        elseif strcmp(event.Key, 'v') && (ismember('control', event.Modifier) || ismember('command', event.Modifier))
            pasteCallback();
        elseif strcmp(event.Key, 'x') && (ismember('control', event.Modifier) || ismember('command', event.Modifier))
            cutCallback();
        elseif strcmp(event.Key,'backspace')
            deleteCallback();
        end
    end
    
end
