function SmoothBootGUI(varargin)

%% read data and unit type
data = varargin{1}.current_data;
dat_name = varargin{1}.data_name;
unit = varargin{1}.unit;
unit_type = varargin{1}.unit_type;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir= varargin{1}.edit_acfigmain_dir;
MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.lang_choice = varargin{1}.lang_choice;
handles.lang_id = varargin{1}.lang_id;
handles.lang_var = varargin{1}.lang_var;
handles.val1 = varargin{1}.val1;
%%
%language
lang_id = handles.lang_id;
if handles.lang_choice > 0
    [~, locb1] = ismember('menu102',lang_id);
    menu102 = handles.lang_var{locb1};
    [~, locb1] = ismember('a70',lang_id);
    a70 = handles.lang_var{locb1};
    [~, locb1] = ismember('a71',lang_id);
    a71 = handles.lang_var{locb1};
    [~, locb1] = ismember('a72',lang_id);
    a72 = handles.lang_var{locb1};
    [~, locb1] = ismember('a73',lang_id);
    a73 = handles.lang_var{locb1};
    [~, locb1] = ismember('a74',lang_id);
    a74 = handles.lang_var{locb1};
    [~, locb1] = ismember('a75',lang_id);
    a75 = handles.lang_var{locb1};
    [~, locb1] = ismember('a76',lang_id);
    a76 = handles.lang_var{locb1};
    [~, locb1] = ismember('a77',lang_id);
    a77 = handles.lang_var{locb1};
end
%%
x = data(:,1);
y = data(:,2);

xlen = max(x) - min(x);

% Create figure and panels
figure('Name', 'Acycle: Bootstrap Smoothing');

% Create panel "span" (40% height)
panel1 = uipanel('Title', 'span', 'Position', [0.1 0.55 0.8 0.4]);

% Create the first row components
textWindow = uicontrol('Parent', panel1, 'Style', 'text', 'String', 'window', 'Units', 'normalized', 'Position', [0.05 0.7 0.18 0.1]);
editWindow = uicontrol('Parent', panel1, 'Style', 'edit', 'String', num2str(xlen*.3), 'Units', 'normalized', 'Position', [0.24 0.7 0.15 0.15]);
textOr = uicontrol('Parent', panel1, 'Style', 'text', 'String', 'or', 'Units', 'normalized', 'Position', [0.5 0.7 0.05 0.1]);
editOr = uicontrol('Parent', panel1, 'Style', 'edit', 'String', '30', 'Units', 'normalized', 'Position', [0.6 0.7 0.1 0.15]);
textPercent = uicontrol('Parent', panel1, 'Style', 'text', 'String', '%', 'Units', 'normalized', 'Position', [0.7 0.7 0.05 0.1]);
buttonBest = uicontrol('Parent', panel1, 'Style', 'pushbutton', 'String', 'best', 'Units', 'normalized', 'Position', [0.85 0.7 0.1 0.1]);

% Create the second row components
slider = uicontrol('Parent', panel1, 'Style', 'slider', 'Value', 0.3, 'Units', 'normalized', 'Position', [0.05 0.2 0.9 0.2]);

% Create radiobutton group (25% height)
panel2 = uibuttongroup('Title', 'Method', 'Position', [0.1 0.3 0.8 0.2]);

% Create radio buttons within the group
radioLowess = uicontrol('Parent', panel2, 'Style', 'radiobutton', 'String', 'lowess', 'Units', 'normalized', 'Position', [0.05 0.5 0.2 0.4]);
radioLoess = uicontrol('Parent', panel2, 'Style', 'radiobutton', 'String', 'loess', 'Units', 'normalized', 'Position', [0.3 0.5 0.2 0.4]);
radioRLowess = uicontrol('Parent', panel2, 'Style', 'radiobutton', 'String', 'rlowess', 'Units', 'normalized', 'Position', [0.55 0.5 0.2 0.4]);
radioRLoess = uicontrol('Parent', panel2, 'Style', 'radiobutton', 'String', 'rloess', 'Units', 'normalized', 'Position', [0.8 0.5 0.2 0.4]);

% Create panel "Estimation" (25% height)
panel3 = uipanel('Title', 'Estimation', 'Position', [0.1 0.05 0.8 0.2]);

% Create static text for "bootstrap number"
textBootstrap = uicontrol('Parent', panel3, 'Style', 'text', 'String', 'bootstrap number', 'Units', 'normalized', 'Position', [0.05 0.4 0.4 0.4]);

% Create edit text for user-defined value (default: 1000)
editBootstrap = uicontrol('Parent', panel3, 'Style', 'edit', 'String', '1000', 'Units', 'normalized', 'Position', [0.5 0.4 0.2 0.4]);

% Create push button "OK"
buttonOK = uicontrol('Parent', panel3, 'Style', 'pushbutton', 'String', 'OK', 'Units', 'normalized', 'Position', [0.8 0.4 0.15 0.4]);

% Set font units and size for all components
h = get(gcf, 'Children');
set(0, 'Units', 'normalized')
set(gcf, 'Units', 'normalized')
h1 = findobj(h, 'FontUnits', 'norm');
set(h1, 'FontUnits', 'points', 'FontSize', 12);
h2 = findobj(h, 'FontUnits', 'points');
set(h2, 'FontUnits', 'points', 'FontSize', 12);

% Callback functions for the components
set(editWindow, 'Callback', {@updateEditWindow, editOr, slider});
set(editOr, 'Callback', {@updateEditOr, editWindow, slider});
set(slider, 'Callback', {@updateSlider, editOr, editWindow});
set(buttonOK, 'Callback', {@test111, editOr, slider, radioLowess, radioLoess, radioRLowess, radioRLoess, editBootstrap});
set(buttonBest, 'Callback', {@setBestValues, slider, editWindow, editOr, radioLowess, radioLoess, radioRLowess, radioRLoess});

% Function to update the first edit text, second edit text, and slider based on the first edit text
function updateEditWindow(src, ~, editOr, slider)
    value = str2double(get(src, 'String'));
    if ~isnan(value) && value > 1 && value <= xlen
        set(src, 'String', num2str(value));
        set(editOr, 'String', num2str(value * 100));
        set(slider, 'Value', value / xlen);
    else
        set(src, 'String', '1');
        set(editOr, 'String', '100');
        set(slider, 'Value', 0.3);
        errordlg('Invalid input! The value must be a positive number between 1 and xlen.', 'Error');
    end
end

% Function to update the second edit text, first edit text, and slider based on the second edit text
function updateEditOr(src, ~, editWindow, slider)
    value = str2double(get(src, 'String'));
    if ~isnan(value) && value > 0 && value < 100
        set(src, 'String', num2str(value));
        set(editWindow, 'String', num2str(value * xlen * 100));
        set(slider, 'Value', value / 100);
    else
        set(src, 'String', '0');
        set(editWindow, 'String', '0');
        set(slider, 'Value', 0);
        errordlg('Invalid input! The value must be a number between 0 and 100.', 'Error');
    end
end

% Function to update the slider, second edit text, and first edit text based on the slider
function updateSlider(src, ~, editOr, editWindow)
    value = get(src, 'Value') * 100;
    set(editOr, 'String', num2str(value));
    set(editWindow, 'String', num2str(value * xlen / 100));
end

% Function to be called when the "OK" button is clicked
function test111(~,~, editOr, slider, radioLowess, radioLoess, radioRLowess, radioRLoess, editBootstrap)
    span = str2double(get(editOr, 'String')) / 100;
    method = '';
    if get(radioLowess, 'Value')
        method = 'lowess';
    elseif get(radioLoess, 'Value')
        method = 'loess';
    elseif get(radioRLowess, 'Value')
        method = 'rlowess';
    elseif get(radioRLoess, 'Value')
        method = 'rloess';
    end
    bootn = str2double(get(editBootstrap, 'String'));
    disp(['Span: ', num2str(span)]);
    disp(['Method: ', method]);
    disp(['Bootstrap Number: ', num2str(bootn)]);
    
    %
    [meanboot,bootstd,bootprt] = smoothciML(x,y,method,span,bootn);
    data2(:,4) = meanboot;
    data2(:,2) = meanboot - 2*bootstd;
    data2(:,3) = meanboot - bootstd;
    data2(:,5) = meanboot + bootstd;
    data2(:,6) = meanboot + 2*bootstd;
    data1 = [x,bootprt];
    ext = '.txt';
    name = [dat_name,'_',num2str(span),'_',method,'_',num2str(bootn),'_bootstp_meanstd',ext];  % New name
    name1 = [dat_name,'_',num2str(span),'_',method,'_',num2str(bootn),'_bootstp_percentile',ext];
    if handles.lang_choice == 0
        disp(['>>  Save [time, mean-2std, mean-std, mean, mean+std, mean+2std] as :',name])
        disp(['>>  Save [time, percentiles] as :',name1])
        disp('>>        Percentiles are ')
    else
        disp([a75,name])
        disp([a76,name1])
        disp(a77)
    end
    disp('>>        [0.5,2.5,5,25,50,75,95,97.5,99.5]')
    %CDac_pwd
    pre_dirML = pwd;
    ac_pwd = fileread('ac_pwd.txt');
    if isdir(ac_pwd)
        cd(ac_pwd)
    end
    %
    dlmwrite(name, data2, 'delimiter', ' ', 'precision', 9); 
    dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9); 
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    % define some nested parameters
    pre  = '<HTML><FONT color="blue">';
    post = '</FONT></HTML>';
    address = pwd;
    d = dir; %get files
    d(1)=[];d(1)=[];
    listboxStr = cell(numel(d),1);
    ac_pwd_str = which('ac_pwd.txt');
    [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
    fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
    T = struct2table(d);
    sortedT = [];
    sd = [];
    str=[];
    i=[];
    
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
end

% Function to set the "best" values
function setBestValues(~, ~, slider, editWindow, editOr, radioLowess, radioLoess, radioRLowess, radioRLoess)
    
    method = 'lowess'; 
    num_iterations = 100;
    wtb = 1; % waitbar
    [span,bestAlpha, bestBeta] = smoothbestSpanRand(x,y,method,num_iterations,wtb);
    if span < 0.05; warndlg('Warning: too small, careful'); end
    if span > 0.95; warndlg('Warning: too big, careful'); end

    set(slider, 'Value', span);
    set(editWindow, 'String', num2str(xlen * span));
    set(editOr, 'String', num2str(span * 100));
    set(radioLowess, 'Value', 1);
    set(radioLoess, 'Value', 0);
    set(radioRLowess, 'Value', 0);
    set(radioRLoess, 'Value', 0);
    
    
end

% best button
% ok button
end