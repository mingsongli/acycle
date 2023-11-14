function datatransformationsGUI(varargin)
    % Check for existence of figure, if not, create one
    fig_handle1 = findobj('Type', 'figure', 'Tag', 'figdatatransfGUI');
    
    if isempty(fig_handle1)
        fig_handle1 = figure('Tag', 'figdatatransfGUI',...
                 'Name', 'Acycle: Data Transformations', ...
                 'NumberTitle', 'off', ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Position', [100, 100, 800, 600]);
    else
        figure(fig_handle1);
        clf;
    end
    
    set(fig_handle1,'units','norm') % set location
    set(0,'Units','normalized') % set units as normalized
    
    %% Read handles
    % read data and unit type
    data = varargin{1}.current_data;
    handles.data_name = varargin{1}.data_name;
    handles.dat_name = varargin{1}.dat_name;   % short name with no extension
    handles.listbox_acmain = varargin{1}.listbox_acmain;
    handles.edit_acfigmain_dir= varargin{1}.edit_acfigmain_dir;
    handles.val1 = varargin{1}.val1;
    handles.slash_v = varargin{1}.slash_v;
    filename = handles.data_name;
    data_name = handles.dat_name;
    checkmaxn = 20;
    
    ncol = size(data, 2);
    
    fnt = '';   % claim a variable
    t=[];
    yt = [];    % claim a variable
    lambda = []; % box-cox parameters
    j=[];  % number of selection
    edit1 = [];edit1find=[];
    edit2=[];
    edit3=[];
    nCheckbox = min(checkmaxn, ncol); % max number of checkbox    
    nRows = ceil(nCheckbox/10);  
    
    panel1height = 0.06*nRows+0.1;
    
    % 1st Panel
    panel1 = uipanel('Title', 'Columns',  ...
                     'FontSize', 12, ...
                     'Units', 'normalized', ...
                     'Position', [0.05, 0.97-panel1height, 0.9,panel1height]);
    
    for i = 1:nCheckbox
        str = num2str(i);
        if i == nCheckbox-1 && ncol > checkmaxn
            str = '...';
        elseif i == nCheckbox && ncol > checkmaxn
            str = num2str(ncol);
        end
        row = ceil(i/10);
        col = i - (row-1)*10;
        checkBoxes(i) = uicontrol(panel1, 'Style', 'checkbox', ...
                  'String', str, ...
                  'Units', 'normalized', ...
                  'Position', [(col-1)*0.1, 1-row*0.5, 0.1, 0.5], ...
                  'Tag', ['checkbox' num2str(i)], ...
                  'FontSize', 12,...
                  'Callback',@editcallback);
        % 2 checkbox default
        if i == 2
            set(checkBoxes(i), 'Value', 1);
        end
    end

    % 2nd Panel - Data Transformation Radiobuttons
    panel2 = uipanel('Title', 'Data Transformation Options', ...
                     'FontSize', 12, ...
                     'Units', 'normalized', ...
                     'Position', [0.05 0.4 0.9 0.97-panel1height-0.42]);
    radioStrs = {'Standardize', 'Normalize', 'Logarithm', 'Exponential', 'Reciprocal (1/x)', 'Root'};
    
    for i = 1:6
        radioButtons(i) = uicontrol(panel2, ...
                'Style', 'radiobutton', ...
                'String', radioStrs{i}, ...
                'Units', 'normalized', ...
                'Position', [0.05, 1-i*0.1667, 0.25, 0.1667], ...
                'FontSize', 12, ...
                'Tag', ['radio' num2str(i)],...
                'Value',0,...
                'Callback',{@checkradio});
    end
    %set(radioButtons(1),'Value',1)
    
    % special in line 2
    uicontrol(panel2, 'Style', 'text', 'String', 'Min','HorizontalAlignment', 'left', ...
              'Units', 'normalized', 'Position', [0.3, 1-2*0.1667, 0.1, 0.12], ...
              'FontSize', 12);
    editText(1) = uicontrol(panel2, 'Style', 'edit', 'String', '0', ...
              'Units', 'normalized', 'Position', [0.4, 1-2*0.1667, 0.1, 0.1667], ...
              'FontSize', 12,'Callback',@getedit);
    uicontrol(panel2, 'Style', 'text', 'String', 'Max','HorizontalAlignment', 'left',...
              'Units', 'normalized', 'Position', [0.6, 1-2*0.1667, 0.1, 0.12], ...
              'FontSize', 12);
    editText(2) = uicontrol(panel2, 'Style', 'edit', 'String', '1', ...
              'Units', 'normalized', 'Position', [0.7, 1-2*0.1667, 0.1, 0.1667], ...
              'FontSize', 12,'Callback',@getedit);
          
    % special in line 3
    radioButtons(7) = uicontrol(panel2, 'Style', 'radiobutton', 'String', 'log', ...
              'Units', 'normalized', 'Position', [0.3, 1-3*0.1667, 0.1, 0.1667], ...
              'FontSize', 12, 'Tag', 'radio7',...
                'Callback',{@checkradio});
    editText(3) = uicontrol(panel2, 'Style', 'edit', 'String', '10', ...
              'Units', 'normalized', 'Position', [0.37, 1-3*0.1667, 0.05, 0.12], ...
              'FontSize', 12, 'Tag', 'edit3','Callback',@getedit3);
    radioButtons(8) = uicontrol(panel2, 'Style', 'radiobutton', 'String', 'Ln', ...
              'Units', 'normalized', 'Position', [0.6, 1-3*0.1667, 0.1, 0.1667], ...
              'FontSize', 12, 'Tag', 'radio8',...
                'Callback',{@checkradio});
    
    % special in line 4
    radioButtons(9) = uicontrol(panel2, 'Style', 'radiobutton', 'String', 'exp(x)', ...
              'Units', 'normalized', 'Position', [0.3, 1-4*0.1667, 0.1, 0.1667], ...
              'FontSize', 12, 'Tag', 'radio9',...
                'Callback',{@checkradio});
    radioButtons(10) = uicontrol(panel2, 'Style', 'radiobutton', 'String', '', ...
              'Units', 'normalized', 'Position', [0.6, 1-4*0.1667, 0.1, 0.1667], ...
              'FontSize', 12, 'Tag', 'radio10',...
                'Callback',{@checkradio});
    editText(4) = uicontrol(panel2, 'Style', 'edit', 'String', '2', ...
              'Units', 'normalized', 'Position', [0.65, 1-4*0.1667, 0.04, 0.11], ...
              'FontSize', 12, 'Tag', 'edit4','Callback',@getedit4);
    uicontrol(panel2, 'Style', 'text', 'String', 'x', ... % Assuming '^x' to be a placeholder for some exponent value.
              'Units', 'normalized', 'Position', [0.69, 1-4*0.1667, 0.04, 0.1667], ...
              'FontSize', 12);
    
    % special in line 6
    radioButtons(11) = uicontrol(panel2, 'Style', 'radiobutton', 'String', 'Square', ...
              'Units', 'normalized', 'Position', [0.3, 1-6*0.1667, 0.1, 0.1667], ...
              'FontSize', 12, 'Tag', 'radio11',...
                'Callback',{@checkradio});
    radioButtons(12) = uicontrol(panel2, 'Style', 'radiobutton', 'String', 'Cube', ...
              'Units', 'normalized', 'Position', [0.6, 1-6*0.1667, 0.1, 0.1667], ...
              'FontSize', 12, 'Tag', 'radio12',...
                'Callback',{@checkradio});
    radioButtons(13) = uicontrol(panel2, 'Style', 'radiobutton', 'String', 'Box-Cox', ...
              'Units', 'normalized', 'Position', [0.8, 1-6*0.1667, 0.18, 0.1667], ...
              'FontSize', 12, 'Tag', 'radio13',...
                'Callback',{@checkradio});

    % 3rd Panel - Angular Transformation Radiobuttons
    panel3 = uipanel('Title', 'Angular Transformation Options', ...
                     'FontSize', 12, ...
                     'Units', 'normalized', ...
                     'Position', [0.05 0.2 0.9 0.15]);
    % Assuming 'panel3' is the handle of the third panel

    % Left radiobutton
    radioButtons(20) = uicontrol(panel3, 'Style', 'radiobutton', 'String', 'Angular', ...
              'Units', 'normalized', 'Position', [0.05, 0.5, 0.2, 0.4], ...
              'FontSize', 12, 'Tag', 'radio20',...
                'Callback',{@checkradio});

    % Right radiobuttons in a 2x3 grid
    angularStrs = {'sin(x)', 'cos(x)', 'tan(x)', 'cot(x)', 'sec(x)', 'csc(x)'};
    for i = 1:6
        row = 1 + floor((i-1)/3);  % Determine the row of the button
        col = mod(i-1, 3) + 1;  % Determine the column of the button

        % Positions may need adjustment to fit properly
        x = 0.3 + (col-1)*0.2;  
        y = 1 - row*0.5;  
        w = 0.2;  
        h = 0.5;

        radioButtons(20+i) = uicontrol(panel3, 'Style', 'radiobutton', 'String', angularStrs{i}, ...
                  'Units', 'normalized', 'Position', [x, y, w, h], ...
                  'FontSize', 12, 'Tag', ['radio', num2str(20+i)],...
                'Callback',{@checkradio});
    end

    % 4th Panel - OK and Save Button
    panel4 = uipanel('Title', 'Save Data', ...
                     'FontSize', 12, ...
                     'Units', 'normalized', ...
                     'Position', [0.05 0.05 0.9 0.1]);
    uicontrol(panel4, 'Style', 'pushbutton', ...
              'String', 'OK and Save Data', ...
              'FontSize', 12, ...
              'Units', 'normalized', ...
              'Position', [0.4 0.1 0.2 0.8],...
              'CallBack',{@btn_handle_Callback});


    % Check for existence of figure, if not, create one
    fig_handle = findobj('Type', 'figure', 'Tag', 'fig_data_transf','Name', 'Acycle: Data Transformations | Plot');
    if isempty(fig_handle)
        fig_handle = figure('Tag', 'fig_data_transf', 'Color', [1 1 1],'Name', 'Acycle: Data Transformations | Plot');
    else
        figure(fig_handle);
    end
    clf; % Clear the figure content

    % Fetch the selected checkbox string and convert to index
    coli = 0;
    for i = 1: ncol
        vi = checkBoxes(i);
        viv = vi.Value;
        if viv == 1
            try
                coli = str2double(checkBoxes(i).String);
            catch
                error('Must select a valid column number!')
            end
            break
        end
    end

    if coli > 0
        x = data(:, 1);
        y = data(:, coli);

        subplot('Position', [0.05, 0.55, 0.6, 0.4]);
        plot(x, y);
        xlim([min(x), max(x)]);
        ylim([min(y), max(y)]);
        title('Raw data');

        subplot('Position', [0.7, 0.55, 0.25, 0.4]);
        histfit(y, [], 'kernel');
        title('Raw data histogram');
    end


%% save data button
    function btn_handle_Callback(src, event)
        % Callback for Pushbutton 1
        save_data(yt, fnt, data_name);
    end

%% save data
    function save_data(yt, fnt, data_name)
        
        % refresh main window
        pre_dirML = pwd;
        ac_pwd = fileread('ac_pwd.txt');
        if isdir(ac_pwd)
            cd(ac_pwd)
            disp([' Working Dir: ', ac_pwd])
        else
            disp([' Data in Working Dir: ', pre_dirML])
        end
        
        % Exporting the data to a text file
        % Save the transformed data
        file_name = [data_name,'-',fnt,'.txt'];
        %dlmwrite(name1, yt, 'delimiter', ' ', 'precision', 9);
        file_id = fopen(file_name, 'wt'); % Open the file for writing text
        fprintf(file_id, '%% Raw data: %s\n', filename);
        if j == 1
            fprintf(file_id, '%% Standardization or z-score normalization\n');
        end
        if j == 2
            fprintf(file_id, '%% Normalization\n');
            edit1 = str2double(get(editText(1),'String'));
            edit2 = str2double(get(editText(2),'String'));
            min_val = min(edit1, edit2);
            max_val = max(edit1, edit2);
            fprintf(file_id, '%% Min: %7.5f; Max: %7.5f\n', min_val,max_val);
        end
        if j == 5
            fprintf(file_id, '%% Reciprocal\n');
            fprintf(file_id, '%% 1/x\n');
        end
        if j == 7
            fprintf(file_id, '%% Logarithm\n');
            edit3 = str2double(get(editText(3),'String'));
            fprintf(file_id, '%% Base: %f\n', edit3);
        end
        if j == 8
            fprintf(file_id, '%% Logarithm\n');
            fprintf(file_id, '%% Base: e\n');
        end
        if j == 9
            fprintf(file_id, '%% Exponential function e^x, \n');
            fprintf(file_id, '%% where e is the base of the natural logarithm, approximately equal to 2.71828\n');
        end
        if j == 10
            edit3 = str2double(get(editText(4),'String'));
            fprintf(file_id, '%% Exponential function n^x, where n is %f\n',edit3);
        end
        if j == 11 % sqrt
            fprintf(file_id, '%% Square root\n');
        end
        if j == 12 % cube root
            fprintf(file_id, '%% Cube root\n');
        end
        if j==13  % used box-cox
            fprintf(file_id, '%% BOX-COX transformation\n');
            fprintf(file_id, '%% Best lambda: %f\n', lambda);
        end
        
        if j == 21 % 
            fprintf(file_id, '%% Sine: sin(x)\n');
        end
        
        if j == 22 % 
            fprintf(file_id, '%% Cosine: cos(x)\n');
        end
        
        if j == 23 % 
            fprintf(file_id, '%% Tangent: tan(x)\n');
        end

        if j == 24 % 
            fprintf(file_id, '%% Cotangent: cot(x)\n');
        end
        if j == 25 % 
            fprintf(file_id, '%% Secant: sec(x)\n');
        end
        if j == 26 % 
            fprintf(file_id, '%% Cosecant: csc(x)\n');
        end
        fprintf(file_id, '%% \n');
        t = yt(:,1);
        y = yt(:,2);
        for ki = 1:length(t)
            fprintf(file_id, '%7.9f\t%7.9f\n', t(ki), y(ki)); % Transpose for column-wise writing
        end
        fclose(file_id);
        
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
    
%% get edit text strings, convert to numbers and get callback results
    function getedit(src,event)
        % prep for norm
        for i =1:26
            try
                set(radioButtons(i),'Value', 0)   % avoid error for empty radioButtons(i)
            end
        end
        radioButtons(2).Value = 1;
        editcallback(src);
    end

    function getedit3(src,event)
        % prep for norm
        for i =1:26
            try
                set(radioButtons(i),'Value', 0)   % avoid error for empty radioButtons(i)
            end
        end
        radioButtons(3).Value = 1;
        radioButtons(7).Value = 1;
        editcallback(src);
    end

    function getedit4(src,event)
        % prep for norm
        for i =1:26
            try
                set(radioButtons(i),'Value', 0)   % avoid error for empty radioButtons(i)
            end
        end
        radioButtons(4).Value = 1;
        radioButtons(10).Value = 1;
        editcallback(src);
    end

%% call back of edit texts and update plot
    function editcallback(src,event)
        j = [];
        % prep for norm
        if radioButtons(2).Value == 1
            j = 2;
        end
        if radioButtons(7).Value == 1
            j = 7;
        end
        if radioButtons(10).Value == 1
            j = 10;
        end
        % check selected checkboxes
        checkid = NaN;
        checkn = 0;
        ncolmin = min(ncol, checkmaxn);
        for i = 1: ncolmin
            vi = checkBoxes(i);
            viv = vi.Value;
            if viv == 1
                checkn = checkn + 1;
                checkid(checkn) = str2double(checkBoxes(i).String); % save col ID
                if isnan(checkid(checkn))  % ...
                    checkid(checkn : checkn+ncol-20) = 19:(ncol-1);  
                    checkn = checkn + ncol-19-1;
                end
            end
        end
        
        %checkid
        if length(checkid) > 0  && ~isnan(checkid(1))
            % calculation
            dat = data(:,checkid);
            yt = data;
            if j == 2 % normalize
                edit1 = str2double(get(editText(1),'String'));  % Fetch min value
                edit2 = str2double(get(editText(2),'String'));  % Fetch max value
                min_val = min(edit1, edit2);
                max_val = max(edit1, edit2);
                dat = (dat - min(dat)) ./ (max(dat) - min(dat)) * (max_val - min_val) + min_val;
                fnt = ['norm-',num2str(min_val), '-',num2str(max_val)];
            end
            if j == 7 % log
                edit3 = str2double(get(editText(3),'String')); 
                dat = log10(dat)./log10(edit3);
                fnt = ['log',findobj('Tag', 'edit3').String];
            end
            if j == 10
                edit4 = str2double(get(editText(4),'String')); 
                dat = edit4.^dat;
                fnt = [findobj('Tag', 'edit4').String,'^x'];
            end
            % update demo
            updateplot1(src,dat);
            
            % put back to yt
            for k = 1: length(checkid)
                yt(:, checkid(k)) = dat(:,k);
            end
        end
    end

%% Callback of radiobuttons

    function checkradio(src, ~)
        % prep for norm
        edit1 = str2double(get(editText(1),'String'));  % Fetch min value
        edit2 = str2double(get(editText(2),'String'));  % Fetch max value
        % check selected checkboxes
        checkid = NaN;
        checkn = 0;
        ncolmin = min(ncol, checkmaxn);
        for i = 1: ncolmin
            vi = checkBoxes(i);
            viv = vi.Value;
            if viv == 1
                checkn = checkn + 1;
                checkid(checkn) = str2double(checkBoxes(i).String); % save col ID
                if isnan(checkid(checkn))  % ...
                    checkid(checkn : checkn+ncol-20) = 19:(ncol-1);  
                    checkn = checkn + ncol-19-1;
                end
            end
        end
        %checkid
        radioID = get(src,'Tag');
        j = str2double(radioID(6:end));  % read radio ID number

        for i =1:26
            try
                set(radioButtons(i),'Value', 0)   % avoid error for empty radioButtons(i)
            end
        end
        
        set(radioButtons(j),'Value', 1) 
        % set related radio to 1
        if j == 3 % log
            set(radioButtons(7),'Value', 1)
            j=7;
        end
        if j == 4 % log
            set(radioButtons(9),'Value', 1)
            j=9;
        end
        if j == 6 % log
            set(radioButtons(11),'Value', 1)
            j=11;
        end
        if j == 20 % log
            set(radioButtons(21),'Value', 1)
        end
        if j == 7 || j == 8 % log
            set(radioButtons(3),'Value', 1)
        end

        if j == 9 || j == 10%ln
            set(radioButtons(4),'Value', 1)
        end

        if j == 11 || j==12  %ln
            set(radioButtons(6),'Value', 1)
        end
        if j == 13 %
            set(radioButtons(6),'Value', 1)
        end
        if j >= 21 %ln
            set(radioButtons(20),'Value', 1)
        end
        
        if length(checkid) > 0 && ~isnan(checkid(1))
            % calculation
            dat = data(:,checkid);
            yt = data;
            lambda = [];
            if j == 1  % Zscore
                dat = zscore(dat);
                fnt = 'standardized';
            end
            if j == 2 % normalize
                min_val = min(edit1, edit2);
                max_val = max(edit1, edit2);
                dat = (dat - min(dat)) ./ (max(dat) - min(dat)) * (max_val - min_val) + min_val;
                fnt = ['norm-',num2str(min_val), '-',num2str(max_val)];
            end
            if j == 7 % logB
                edit3 = str2double(findobj('Tag', 'edit3').String); 
                if edit3 == 10
                    dat = log10(dat);
                elseif edit3 == 2
                    dat = log2(dat);
                else
                    dat = log10(dat)./log10(edit3);
                end
                fnt = ['log',findobj('Tag', 'edit3').String];
            end
            if j == 8 % ln
                dat = log(dat);
                fnt = 'ln';
            end
            if j == 9 % exp(x)
                dat = exp(dat);
                fnt = 'exp';
            end
            if j == 10 % n^x
                edit4 = str2double(findobj('Tag', 'edit4').String); 
                dat = edit4.^dat;
                fnt = [findobj('Tag', 'edit4').String,'^x'];
            end
            if j == 5 % 1/x
                dat = 1./dat;
                fnt = 'reciprocal';
            end

            if j == 11 % sqrt
                dat = sqrt(dat);
                fnt = 'sqrt';
            end
            if j == 12 % cube
                dat = nthroot(dat,3);
                fnt = 'cube';
            end
            if j == 13 % box-cox
                if any(dat <= 0)
                    warndlg('All elements of data must be positive for Box-Cox transformation.')
                    dat = dat + abs(min(dat)) + eps;
                end
                [dat, lambda] = boxcox(dat);
                fnt = 'box-cox';
            end
            if j == 21 % sine
                dat = sin(dat);
                fnt = 'sin';
            end
            if j == 22 % cos
                dat = cos(dat);
                fnt = 'cos';
            end
            if j == 23 % sine
                dat = tan(dat);
                fnt = 'tan';
            end
            if j == 24 % sine
                dat = cot(dat);
                fnt = 'cot';
            end
            if j == 25 % sine
                dat = sec(dat);
                fnt = 'sec';
            end
            if j == 26 % sine
                dat = csc(dat);
                fnt = 'csc';
            end

            % put back to yt
            for k = 1: length(checkid)
                yt(:, checkid(k)) = dat(:,k);
            end
            
            updateplot1(src,dat);
        end
    end

%% Update plot figures only by using given transformed dat
    function updateplot1(src,dat)
        
            % check selected checkboxes
            checkid = NaN;
            checkn = 0;
            ncolmin = min(ncol, checkmaxn);
            for i = 1: ncolmin
                vi = checkBoxes(i);
                viv = vi.Value;
                if viv == 1
                    checkn = checkn + 1;
                    checkid(checkn) = str2double(checkBoxes(i).String); % save col ID
                    if isnan(checkid(checkn))  % ...
                        checkid(checkn : checkn+ncol-20) = 19:(ncol-1);  
                        checkn = checkn + ncol-19-1;
                    end
                end
            end
            
            % subplot
            % Check for existence of figure, if not, create one
            fig_handle = findobj('Type', 'figure', 'Tag', 'fig_data_transf');
            if isempty(fig_handle)
                fig_handle = figure('Tag', 'fig_data_transf', 'Color', [1 1 1],'Name', 'Acycle: Data Transformations | Plot');
            else
                figure(fig_handle);
            end            
            
            coli = checkid(1); % use the first for plot
            % plot the raw data 
            if coli > 0
                x = data(:, 1);
                y = data(:, coli);

                subplot('Position', [0.05, 0.55, 0.6, 0.4]);
                plot(x, y);
                xlim([min(x), max(x)]);
                ylim([min(y), max(y)]);
                title('Raw data');
                ax = gca; 
                ax.XMinorTick = 'on'; 
                ax.YMinorTick = 'on';

                subplot('Position', [0.7, 0.55, 0.25, 0.4]);
                histfit(y, [], 'kernel');
                title('Raw data histogram');
                ax = gca; 
                ax.XMinorTick = 'on'; 
                ax.YMinorTick = 'on';
            end
            % transformed data
            subplot('Position', [0.05, 0.05, 0.6, 0.4]);
            plot(x,dat(:,1));
            xlim([min(x), max(x)]);
            try
                ylim([min(dat(:,1)), max(dat(:,1))]);
            catch
                error('Error using ylim in subplot(2,2,3). Results may have complex values???')
            end
            title('New data');
            if j == 13 % box-cox
                title(['BOX-COX Transformed Data. Best lambda: ', num2str(lambda)]);
            end
            ax = gca; 
            ax.XMinorTick = 'on'; 
            ax.YMinorTick = 'on';
            
            subplot('Position', [0.7, 0.05, 0.25, 0.4]);
            histfit(dat(:,1), [], 'kernel');
            title('Transformed data histogram');
            ax = gca; 
            ax.XMinorTick = 'on'; 
            ax.YMinorTick = 'on';
    end

end