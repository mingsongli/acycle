function varargout = RecPlotGUI(varargin)
% RECPLOTGUI MATLAB code for RecPlotGUI.fig
%      RECPLOTGUI, by itself, creates a new RECPLOTGUI or raises the existing
%      singleton*.
%
%      H = RECPLOTGUI returns the handle to a new RECPLOTGUI or the handle to
%      the existing singleton*.
%
%      RECPLOTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECPLOTGUI.M with the given input arguments.
%
%      RECPLOTGUI('Property','Value',...) creates a new RECPLOTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RecPlotGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RecPlotGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RecPlotGUI

% Last Modified by GUIDE v2.5 12-Dec-2022 13:56:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RecPlotGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @RecPlotGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before RecPlotGUI is made visible.
function RecPlotGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RecPlotGUI (see VARARGIN)

set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;

data_s = varargin{1}.current_data;
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
handles.current_data = data_s;
handles.data_name = varargin{1}.data_name;
handles.path_temp = varargin{1}.path_temp;
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
[dat_dir,handles.filename,exten] = fileparts(handles.data_name);

set(gcf,'position',[0.35,0.4,0.45,0.35]* handles.MonZoom) % set position

set(handles.text2,'position',[0.05,0.82,0.09,0.064])
set(handles.edit1,'position',[0.145,0.8,0.5,0.1])
set(handles.edit7,'position',[0.67,0.8,0.13,0.1])

set(handles.text3,'position',[0.05,0.6,0.09,0.064])
set(handles.edit2,'position',[0.145,0.58,0.13,0.1])
set(handles.checkbox1,'position',[0.105,0.4,0.15,0.15],'Value',1)
set(handles.checkbox2,'position',[0.105,0.25,0.15,0.15],'Value',0)
set(handles.checkbox3,'position',[0.105,0.1,0.11,0.15],'Value',0)
set(handles.checkbox4,'position',[0.22,0.1,0.11,0.15],'Value',0)

set(handles.uipanel1,'position',[0.36,0.1,0.5,0.5])
set(handles.text4,'position',[0.03,0.7,0.24,0.12])
set(handles.edit3,'position',[0.27,0.65,0.1,0.18])
set(handles.text5,'position',[0.03,0.4,0.24,0.12])
set(handles.edit4,'position',[0.27,0.35,0.1,0.18])
set(handles.text6,'position',[0.55,0.7,0.27,0.12])
set(handles.edit5,'position',[0.83,0.65,0.11,0.18])
set(handles.text7,'position',[0.55,0.4,0.27,0.12])
set(handles.edit6,'position',[0.83,0.35,0.11,0.18])
set(handles.text9,'position',[0.4,0.7,0.13,0.12],'String',handles.unit)
set(handles.text10,'position',[0.4,0.4,0.13,0.12],'String',handles.unit)

%% ===== 2026-01-24 add: shift existing 6 controls up, add dimension/delay =====
% We will have 8 controls in the sliding-window panel:
%   w, ws, theiler_window, lmin, method, normFlag, dimension(m), delay(tau)

% ---- shift existing rows up to make room for 2 new rows at bottom ----
dy = 0.14;  % upward shift (tune if needed)

% labels + edits that already exist in panel
move_up = @(h) set(h,'Position', get(h,'Position') + [0 dy 0 0]);

move_up(handles.text4);  move_up(handles.edit3);   % w
move_up(handles.text5);  move_up(handles.edit4);   % ws
move_up(handles.text6);  move_up(handles.edit5);   % theiler
move_up(handles.text7);  move_up(handles.edit6);   % lmin
move_up(handles.text9);  % unit label for w
move_up(handles.text10); % unit label for ws

% ---- create a NEW bottom row for dimension / delay (edit boxes) ----
fs = 11.5;

% use the *current* positions (after move) as reference widths
pos_text_ws = get(handles.text5,'Position');   % left label reference
pos_edit_ws = get(handles.edit4,'Position');   % left edit reference
pos_text_lm = get(handles.text7,'Position');   % right label reference
pos_edit_lm = get(handles.edit6,'Position');   % right edit reference

hLabel = pos_text_ws(4);
hCtrl  = pos_edit_ws(4);

xL_label = pos_text_ws(1);   wL_label = pos_text_ws(3);
xL_ctrl  = pos_edit_ws(1);   wL_ctrl  = pos_edit_ws(3);

xR_label = pos_text_lm(1);   wR_label = pos_text_lm(3);
xR_ctrl  = pos_edit_lm(1);   wR_ctrl  = pos_edit_lm(3);

% put this new row at the very bottom of panel
yCtrl_dim  = 0.02;
yLabel_dim = yCtrl_dim + (hCtrl - hLabel);

handles.text_dim = uicontrol('Parent',handles.uipanel1,'Style','text','Units','normalized', ...
    'Position',[xL_label, yLabel_dim, wL_label, hLabel], ...
    'String','dimension', ...
    'HorizontalAlignment', get(handles.text5,'HorizontalAlignment'), ...
    'FontUnits','points','FontSize',fs);

handles.edit_dim = uicontrol('Parent',handles.uipanel1,'Style','edit','Units','normalized', ...
    'Position',[xL_ctrl, yCtrl_dim, wL_ctrl, hCtrl], ...
    'String','1', ...
    'BackgroundColor','white', ...
    'Callback',@edit_dim_Callback, ...
    'FontUnits','points','FontSize',fs);

handles.text_tau = uicontrol('Parent',handles.uipanel1,'Style','text','Units','normalized', ...
    'Position',[xR_label, yLabel_dim, wR_label, hLabel], ...
    'String','delay', ...
    'HorizontalAlignment', get(handles.text7,'HorizontalAlignment'), ...
    'FontUnits','points','FontSize',fs);

handles.edit_tau = uicontrol('Parent',handles.uipanel1,'Style','edit','Units','normalized', ...
    'Position',[xR_ctrl, yCtrl_dim, wR_ctrl, hCtrl], ...
    'String','1', ...
    'BackgroundColor','white', ...
    'Callback',@edit_tau_Callback, ...
    'FontUnits','points','FontSize',fs);

set(handles.edit_dim,'Enable','off');
set(handles.edit_tau,'Enable','off');

% store defaults into handles for passing downstream
handles.embed_m   = 1;
handles.embed_tau = 1;

%% --- Added in 2026-01: method + normFlag controls (for DET / sliding-window) ---
handles.method_display = {'maxnorm','euclidean','minnorm','nrmnorm','fixed recurrence rate','fan','inter','omatrix','opattern'};
handles.method_code    = {'max','eu','min','nr','rr','fa','in','om','op'};
handles.norm_display   = {'nonorm','narow'};

% defaults (match crp_pdist defaults)
handles.method_use = 'rr';
handles.normFlag   = 'nonorm';

% ---- match font with existing controls ----
fs = 11.5;

% ---- read reference positions from existing panel controls ----
pos_text_ws = get(handles.text5,'Position');   % "sliding step" label (ws)
pos_edit_ws = get(handles.edit4,'Position');   % ws edit box
pos_text_lm = get(handles.text7,'Position');   % "lmin" label
pos_edit_lm = get(handles.edit6,'Position');   % lmin edit box

% ---- make a new bottom row (below ws/lmin row) ----
hLabel = pos_text_ws(4);         
hCtrl  = pos_edit_ws(4);         

xL_label = pos_text_ws(1);
wL_label = pos_text_ws(3);
xL_ctrl  = pos_edit_ws(1);

xR_label = pos_text_lm(1);
wR_label = pos_text_lm(3);
xR_ctrl  = pos_edit_lm(1);

% ---- make method/norm row above dimension/delay row ----
yCtrl  = 0.24;              % row for method/norm
yLabel = yCtrl + (hCtrl - hLabel);


wPopupMethod = max(pos_edit_ws(3), 0.18);   
wPopupNorm   = max(pos_edit_lm(3), 0.12);   

ha_ws = get(handles.text5,'HorizontalAlignment');
ha_lm = get(handles.text7,'HorizontalAlignment');

% ===== method =====
handles.text_method = uicontrol('Parent',handles.uipanel1,'Style','text','Units','normalized', ...
    'Position',[xL_label, yLabel, wL_label, hLabel], ...
    'String','method','HorizontalAlignment',ha_ws, ...
    'FontUnits','points','FontSize',fs);

handles.popup_method = uicontrol('Parent',handles.uipanel1,'Style','popupmenu','Units','normalized', ...
    'Position',[xL_ctrl, yCtrl, wPopupMethod, hCtrl], ...
    'String',handles.method_display, ...
    'Value',find(strcmp(handles.method_code,handles.method_use),1,'first'), ...
    'Callback',@popup_method_Callback, ...
    'BackgroundColor','white', ...
    'FontUnits','points','FontSize',fs);

% ===== normFlag =====
handles.text_norm = uicontrol('Parent',handles.uipanel1,'Style','text','Units','normalized', ...
    'Position',[xR_label, yLabel, wR_label, hLabel], ...
    'String','normFlag','HorizontalAlignment',ha_lm, ...
    'FontUnits','points','FontSize',fs);

handles.popup_norm = uicontrol('Parent',handles.uipanel1,'Style','popupmenu','Units','normalized', ...
    'Position',[xR_ctrl, yCtrl, wPopupNorm, hCtrl], ...
    'String',handles.norm_display, ...
    'Value',find(strcmp(handles.norm_display,handles.normFlag),1,'first'), ...
    'Callback',@popup_norm_Callback, ...
    'BackgroundColor','white', ...
    'FontUnits','points','FontSize',fs);

set(handles.pushbutton1,'position',[0.87,0.1,0.12,0.12])
% Choose default command line output for RecPlotGUI
handles.output = hObject;
handles.RecPlotGUI = gcf;

% language
lang_choice = varargin{1}.lang_choice;
handles.lang_choice = lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;
handles.lang_id = lang_id;
handles.lang_var = lang_var;
handles.main_unit_selection = varargin{1}.main_unit_selection;
if handles.lang_choice == 0
    set(gcf,'Name','Acycle: Recurrence Plot')
else
    [~, menu128] = ismember('menu128',lang_id);
    set(gcf,'Name',['Acycle: ',lang_var{menu128}])
end

% language
if handles.lang_choice > 0
    [~, main12] = ismember('main12',handles.lang_id);
    [~, main24] = ismember('main24',handles.lang_id);
    [~, main53] = ismember('main53',handles.lang_id);
    [~, main54] = ismember('main54',handles.lang_id);
    [~, recPlot03] = ismember('recPlot03',handles.lang_id);
    [~, main10] = ismember('main10',handles.lang_id);
    [~, main07] = ismember('main07',handles.lang_id);
    
    [~, recPlot01] = ismember('recPlot01',handles.lang_id);
    [~, recPlot02] = ismember('recPlot02',handles.lang_id);
    [~, c39] = ismember('c39',handles.lang_id);
    [~, main55] = ismember('main55',handles.lang_id);
    [~, main32] = ismember('main32',handles.lang_id);
    [~, main41] = ismember('main41',handles.lang_id);
    [~, main01] = ismember('main01',handles.lang_id);
    
    set(handles.text2,'String',lang_var{main12})
    set(handles.edit7,'String',lang_var{main24})
    set(handles.text3,'String',lang_var{main53})
    set(handles.checkbox1,'String',[lang_var{main54},lang_var{main12}])
    set(handles.checkbox3,'String',lang_var{recPlot03})
    set(handles.checkbox2,'String',[lang_var{main54},'DET'])
    set(handles.checkbox4,'String',lang_var{main10})
    set(handles.uipanel1,'Title',lang_var{main07})
    
    set(handles.text4,'String',lang_var{c39})
    set(handles.text6,'String',[lang_var{recPlot01},lang_var{main41}])
    set(handles.text5,'String',[lang_var{main55},' ',lang_var{main32}])
    set(handles.text7,'String',lang_var{recPlot02})
    set(handles.pushbutton1,'String',lang_var{main01})
end

% size of data
[N, ncol] = size(data_s);
S = zeros(N, N);

% sliding window size
win_ratio = 0.3; 
theiler_window = 1;
lmin = 2; 

if ncol == 1
    x = data_s;
    t = 1:N;
    w = round(win_ratio * N);
    ws = 1;
    if w/ws > 500
        ws = round(w/300);
    end
else
    diffx = diff(data_s(:,1));
    if max(diffx) - min(diffx) > 10*eps('single')
        % language
        if handles.lang_choice ==  0
            hwarn = warndlg('Not equally spaced data. Interpolated using mean sampling rate!');
        else
            [~, dd37] = ismember('dd37',handles.lang_id);
            hwarn = warndlg(lang_var{dd37});
        end
        interpolate_rate = mean(diffx);
        handles.current_data = interpolate(data_s,interpolate_rate);
        figure(hwarn);
    end
    data_s = handles.current_data;
    x = data_s(:,2);
    t = data_s(:,1);
    ws = median(diffx);
    wmax = abs((max(t) - min(t)));  % 30%
    w = ws * 30;
    if w > wmax
        w = wmax;
    end
end
for i = 1:N
    S(:,i) = abs( repmat( x(i), N, 1 ) - x(:) );
end

threshold = median(S(:)) - 0.5* std(S(:));
S = recplot(x,threshold,t,0);

handles.S = S;
handles.threshold = threshold;
handles.w = w;
handles.ws = ws;
handles.theiler_window = theiler_window;
handles.lmin = lmin;

%%
set(handles.edit1,'String',[handles.filename,exten])
set(handles.edit2,'String',num2str(threshold))
set(handles.edit3,'String',num2str(w))
set(handles.edit4,'String',num2str(ws))
set(handles.edit5,'String',num2str(theiler_window))
set(handles.edit6,'String',num2str(lmin))

update_recplot
figure(handles.hrp)
set(gcf,'units','norm') % set location
set(gcf,'position',[0.05,0.05,0.3,0.6])

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RecPlotGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RecPlotGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
CDac_pwd; % cd working dir

add_list1 = [handles.filename,'-RP.txt'];
add_list2 = [handles.filename,'-RP-DET.txt'];
try
    dlmwrite(add_list1, handles.St,  'delimiter', ' ', 'precision', 9);
    dlmwrite(add_list2, handles.DET, 'delimiter', ' ', 'precision', 9);
catch
    
end
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return view dir
%%
figure(handles.hrp)
figure(handles.RecPlotGUI)

% Update handles structure
guidata(hObject, handles);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

update_recplot

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

update_recplot

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
update_recplot

% Update handles structure
guidata(hObject, handles);

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

update_recplot

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

update_recplot

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

update_recplot

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

update_recplot

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3

update_recplot

% Update handles structure
guidata(hObject, handles);



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double

update_recplot

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4

update_recplot

% Update handles structure
guidata(hObject, handles);


% --- Added callbacks for new popup menus (method_use + normFlag) ---
function popup_method_Callback(hObject, eventdata)
% hObject: popup menu for method selection
handles = guidata(hObject);
try
    idx = get(hObject,'Value');
    if isfield(handles,'method_code') && idx>=1 && idx<=numel(handles.method_code)
        handles.method_use = handles.method_code{idx}; % pass to downstream code as char
    end
    guidata(hObject, handles);
    % refresh plot if possible
    try update_recplot; catch, end
catch
end

function popup_norm_Callback(hObject, eventdata)
% hObject: popup menu for normFlag selection
handles = guidata(hObject);
try
    idx = get(hObject,'Value');
    if isfield(handles,'norm_display') && idx>=1 && idx<=numel(handles.norm_display)
        handles.normFlag = handles.norm_display{idx}; % 'nonorm' or 'narow'
    end
    guidata(hObject, handles);
    % refresh plot if possible
    try update_recplot; catch, end
catch
end

% --- NEW: dimension edit callback ---
function edit_dim_Callback(hObject, eventdata)
handles = guidata(hObject);

v = str2double(get(hObject,'String'));
if ~isfinite(v)
    v = 1;
end
v = round(v);
if v < 1
    v = 1;
end

handles.embed_m = v;
set(hObject,'String',num2str(v));

guidata(hObject, handles);
try
    update_recplot;
catch
end


% --- NEW: delay edit callback ---
function edit_tau_Callback(hObject, eventdata)
handles = guidata(hObject);

v = str2double(get(hObject,'String'));
if ~isfinite(v)
    v = 1;
end
v = round(v);
if v < 1
    v = 1;
end

handles.embed_tau = v;
set(hObject,'String',num2str(v));

guidata(hObject, handles);
try
    update_recplot;
catch
end

