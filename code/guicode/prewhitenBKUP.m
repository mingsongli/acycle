function varargout = prewhiten(varargin)
% PREWHITEN MATLAB code for prewhiten.fig
%      PREWHITEN, by itself, creates a new PREWHITEN or raises the existing
%      singleton*.
%
%      H = PREWHITEN returns the handle to a new PREWHITEN or the handle to
%      the existing singleton*.
%
%      PREWHITEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREWHITEN.M with the given input arguments.
%
%      PREWHITEN('Property','Value',...) creates a new PREWHITEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prewhiten_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prewhiten_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prewhiten

% Last Modified by GUIDE v2.5 12-Jun-2017 22:45:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prewhiten_OpeningFcn, ...
                   'gui_OutputFcn',  @prewhiten_OutputFcn, ...
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


% --- Executes just before prewhiten is made visible.
function prewhiten_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prewhiten (see VARARGIN)
% language
handles.lang_choice = varargin{1}.lang_choice;
handles.lang_id = varargin{1}.lang_id;
handles.lang_var = varargin{1}.lang_var;
handles.main_unit_selection = varargin{1}.main_unit_selection;

h=get(gcf,'Children');  % get all content
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location

h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',12);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',12);  % set as norm

if handles.lang_choice == 0
    set(gcf,'Name','Acycle: Curve Fitting | Detrending | Smoothing')
else
    [~, locb] = ismember('menu100',handles.lang_id);
    lang_var = handles.lang_var;
    set(gcf,'Name',['Acycle: ',lang_var{locb}])
end
% language
lang_id = handles.lang_id;
lang_var = handles.lang_var;
if handles.lang_choice > 0
    [~, locb] = ismember('Fitting01',lang_id);
    set(handles.uipanel6,'Title',lang_var{locb})
    [~, locb] = ismember('main41',lang_id);
    set(handles.text21,'string',lang_var{locb})
    [~, locb] = ismember('main47',lang_id);
    set(handles.text20,'string',lang_var{locb})
    [~, locb] = ismember('Fitting06',lang_id);
    set(handles.uipanel8,'Title',lang_var{locb})
    [~, locb] = ismember('Fitting07',lang_id);
    set(handles.prewhiten_mean_checkbox,'string',lang_var{locb})
    [~, locb] = ismember('Fitting08',lang_id);
    set(handles.prewhiten_linear_checkbox,'string',lang_var{locb})
    [~, locb] = ismember('Fitting09',lang_id);
    set(handles.checkbox11,'string',lang_var{locb})
    [~, locb] = ismember('Fitting10',lang_id);
    set(handles.text25,'string',lang_var{locb})
    [~, locb] = ismember('Fitting11',lang_id);
    set(handles.prewhiten_all_checkbox,'string',lang_var{locb})
    [~, locb] = ismember('Fitting12',lang_id);
    set(handles.prewhiten_clear_pushbutton,'string',lang_var{locb})
    [~, locb] = ismember('Fitting13',lang_id);
    set(handles.uipanel7,'Title',lang_var{locb})
    [~, locb] = ismember('menu03',lang_id);
    set(handles.prewhiten_pushbutton,'string',lang_var{locb})
end

handles.MonZoom = varargin{1}.MonZoom;
set(gcf,'position',[0.45,0.3,0.25,0.5]* handles.MonZoom) % set position
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;

set(handles.uipanel6,'position',[0.025,0.254,0.95,0.666])
set(handles.text21,'position',[0.021,0.862,0.2,0.07])
set(handles.edit10,'position',[0.23,0.852,0.2,0.1])
set(handles.text20,'position',[0.45,0.862,0.11,0.07])
set(handles.edit11,'position',[0.57,0.852,0.15,0.1])
set(handles.text23,'position',[0.73,0.852,0.08,0.07])
set(handles.pushbutton12,'position',[0.82,0.852,0.13,0.1])

set(handles.slider4,'position',[0.03,0.729,0.94,0.09])
set(handles.uipanel8,'position',[0.3,0.249,0.4,0.485])

set(handles.prewhiten_lowess_checkbox,'position',[0.043,0.61,0.4,0.1])
set(handles.prewhiten_rlowess_checkbox,'position',[0.043,0.51,0.4,0.1])
set(handles.prewhiten_loess_checkbox,'position',[0.043,0.41,0.4,0.1])
set(handles.prewhiten_rloess_checkbox,'position',[0.043,0.31,0.4,0.1])
set(handles.checkbox34,'position',[0.043,0.21,0.4,0.1])
set(handles.prewhiten_all_checkbox,'position',[0.043,0.11,0.38,0.1])
set(handles.prewhiten_clear_pushbutton,'position',[0.375,0.11,0.285,0.1])
set(handles.prewhiten_pushbutton,'position',[0.673,0.11,0.235,0.1])
set(handles.checkboxEMDres,'position',[0.7,0.61,0.29,0.1])

set(handles.prewhiten_mean_checkbox,'position',  [0.057,0.737,0.533,0.212])
set(handles.prewhiten_linear_checkbox,'position',[0.057,0.535,0.92,0.212])
set(handles.checkbox11,'position',[0.057,0.333,0.607,0.212])
set(handles.checkbox13,'position',[0.057,0.071,0.2,0.212])
set(handles.edit23,'position',[0.18,0.071,0.214,0.208])
set(handles.text25,'position',[0.4,0.123,0.321,0.123])

set(handles.uipanel7,'position',[0.025,0.03,0.95,0.213])
set(handles.prewhiten_select_popupmenu,'position',[0.043,0.2,0.9,0.5])
set(handles.prewhiten_select_popupmenu,'String','Raw','Value',1);

% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
handles.val1 = varargin{1}.val1;

current_data = varargin{1}.current_data;
handles.current_data = current_data;
handles.data_name = varargin{1}.data_name;
xmin = min(handles.current_data(:,1));
xmax = max(handles.current_data(:,1));
handles.xrange = xmax -xmin; % length of data
prewhiten={};
prewhiten(1,1) = {'Raw'};
handles.prewhiten_popupmenu_selection = prewhiten;

handles.smooth_win = 0.35;  % windows for smooth 
handles.prewhiten_win = (xmax-xmin) * handles.smooth_win;
set(handles.edit10,'String', num2str(handles.prewhiten_win));
set(handles.edit11,'String', num2str(handles.smooth_win*100));
set(handles.slider4, 'Value', handles.smooth_win);
set(handles.prewhiten_lowess_checkbox,'Value', 0);
set(handles.prewhiten_rlowess_checkbox,'Value', 0);
set(handles.prewhiten_loess_checkbox,'Value', 0);
set(handles.prewhiten_rloess_checkbox,'Value', 0);
set(handles.checkboxEMDres,'Value', 0);
set(handles.checkbox34,'Value', 0);
set(handles.prewhiten_mean_checkbox,'Value', 0);
set(handles.prewhiten_linear_checkbox,'Value', 0);
set(handles.prewhiten_all_checkbox,'Value', 0);
set(handles.checkbox11,'Value', 0);
set(handles.checkbox13,'Value', 0);
set(handles.edit23,'String', '3');

% Choose default command line output for prewhiten
handles.output = hObject;
handles.prewhiten_mean = 'notmean';
handles.prewhiten_linear = 'notlinear';
handles.prewhiten_lowess = 'notlowess';
handles.prewhiten_rlowess = 'notrlowess';
handles.prewhiten_loess = 'notloess';
handles.prewhiten_rloess = 'notloess';
handles.prewhiten_sgolay = 'notsgolay';
handles.prewhiten_polynomial2 = 'not2nd';
handles.prewhiten_polynomialmore = 'notmore';
handles.prewhiten_emdres = 'noteemdres';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prewhiten wait for user response (see UIRESUME)
% uiwait(handles.gui2);


% --- Outputs from this function are returned to the command line.
function varargout = prewhiten_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function prewhiten_select_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prewhiten_select_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in prewhiten_lowess_checkbox.
function prewhiten_lowess_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_lowess_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of prewhiten_lowess_checkbox
handles.prewhiten_lowess = get(handles.prewhiten_lowess_checkbox,'string');

prewhitenok = get(handles.prewhiten_lowess_checkbox,'Value');
if prewhitenok == 1
    set(handles.prewhiten_lowess_checkbox,'Enable','on')
else
    handles.prewhiten_lowess = 'notlowess';
end

update_detrend_plot_fig

guidata(hObject, handles);

% --- Executes on button press in prewhiten_rlowess_checkbox.
function prewhiten_rlowess_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_rlowess_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of prewhiten_rlowess_checkbox
handles.prewhiten_rlowess = get(handles.prewhiten_rlowess_checkbox,'string');

prewhitenok = get(handles.prewhiten_rlowess_checkbox,'Value');
if prewhitenok == 1
    set(handles.prewhiten_linear_checkbox,'Enable','on')
else
    handles.prewhiten_rlowess = 'notrlowess';
end
update_detrend_plot_fig
guidata(hObject, handles);

% --- Executes on button press in prewhiten_loess_checkbox.
function prewhiten_loess_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_loess_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of prewhiten_loess_checkbox
handles.prewhiten_loess = get(handles.prewhiten_loess_checkbox,'string');

prewhitenok = get(handles.prewhiten_loess_checkbox,'Value');
if prewhitenok == 1
    set(handles.prewhiten_linear_checkbox,'Enable','on')
else
    handles.prewhiten_loess = 'notloess';
end
update_detrend_plot_fig
guidata(hObject, handles);


% --- Executes on button press in prewhiten_rloess_checkbox.
function prewhiten_rloess_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_rloess_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of prewhiten_rloess_checkbox
handles.prewhiten_rloess = get(handles.prewhiten_rloess_checkbox,'string');

prewhitenok = get(handles.prewhiten_rloess_checkbox,'Value');
if prewhitenok == 1
    set(handles.prewhiten_linear_checkbox,'Enable','on')
else
    handles.prewhiten_rloess = 'notloess';
end
update_detrend_plot_fig
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function checkboxEMDres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in prewhiten_rloess_checkbox.
function checkboxEMDres_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_rloess_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of prewhiten_rloess_checkbox
handles.prewhiten_emdres = get(handles.checkboxEMDres,'string');
prewhitenok = get(handles.checkboxEMDres,'Value');

if prewhitenok == 1
    set(handles.checkboxEMDres,'Enable','on')
else
    handles.prewhiten_emdres = '';
end

update_detrend_plot_fig

guidata(hObject, handles);

% --- Executes on button press in prewhiten_rloess_checkbox.
function checkbox34_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_rloess_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of prewhiten_rloess_checkbox
handles.prewhiten_sgolay = get(handles.checkbox34,'string');

prewhitenok = get(handles.checkbox34,'Value');
if prewhitenok == 1
    set(handles.checkbox34,'Enable','on')
else
    handles.prewhiten_sgolay = 'notsgolay';
end
update_detrend_plot_fig
guidata(hObject, handles);


% --- Executes on button press in prewhiten_mean_checkbox.
function prewhiten_mean_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_linear_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.prewhiten_mean = get(hObject,'string');
prewhitenok = get(hObject,'Value');
if prewhitenok == 1
    set(handles.prewhiten_pushbutton,'Enable','on')
else
    handles.prewhiten_mean = 'notmean';
end
update_detrend_plot_fig
guidata(hObject, handles);


% --- Executes on button press in prewhiten_linear_checkbox.
function prewhiten_linear_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_linear_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.prewhiten_linear = get(hObject,'string');
prewhitenok = get(hObject,'Value');
if prewhitenok == 1
    set(handles.prewhiten_pushbutton,'Enable','on')
else
    handles.prewhiten_linear = 'notlinear';
end
update_detrend_plot_fig
guidata(hObject, handles);


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
handles.prewhiten_polynomial2 = get(hObject,'string');
prewhitenok = get(hObject,'Value');
if prewhitenok == 1
    set(handles.prewhiten_linear_checkbox,'Enable','on')
else
    handles.prewhiten_polynomial2 = 'not2nd';
end
update_detrend_plot_fig
guidata(hObject, handles);

% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox13
handles.prewhiten_polynomialmore = get(handles.edit23,'string');
prewhitenok = get(hObject,'Value');
if prewhitenok == 1
    set(handles.prewhiten_pushbutton,'Enable','on')
else
    handles.prewhiten_polynomialmore = 'notmore';
end
update_detrend_plot_fig
guidata(hObject, handles);



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
% read data
prewhiten_win_edit1 = str2double(get(hObject,'String'));
handles.prewhiten_win = prewhiten_win_edit1;
% smooth win 
handles.smooth_win = prewhiten_win_edit1/handles.xrange;  % windows for smooth 
prewhitenwinpercent = 100*(handles.smooth_win);
set(handles.edit11, 'String', num2str(prewhitenwinpercent));
set(handles.slider4, 'Value', handles.smooth_win);

update_detrend_plot_fig

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
prewhiten_win_edit2 = str2double(get(hObject,'String'));
% smooth win 
handles.smooth_win = prewhiten_win_edit2/100;  % windows for smooth 
handles.prewhiten_win = handles.xrange * prewhiten_win_edit2/100;
set(handles.edit10, 'String', num2str(handles.prewhiten_win));
set(handles.slider4, 'Value', handles.smooth_win);

update_detrend_plot_fig

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in prewhiten_all_checkbox.
function prewhiten_all_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_all_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of prewhiten_all_checkbox
prewhitenok = get(handles.prewhiten_all_checkbox,'Value');

if prewhitenok == 1
    %set(handles.prewhiten_linear_checkbox,'Enable','on')
    set(handles.prewhiten_linear_checkbox,'Value',1)
    set(handles.prewhiten_mean_checkbox,'Value',1)
    set(handles.prewhiten_lowess_checkbox,'Value',1)
    set(handles.prewhiten_rlowess_checkbox,'Value',1)
    set(handles.prewhiten_linear_checkbox,'Value',1)
    set(handles.prewhiten_loess_checkbox,'Value',1)
    set(handles.checkbox34,'Value',1)
    set(handles.prewhiten_rloess_checkbox,'Value',1)
    set(handles.checkbox11,'Value',1)
    set(handles.checkbox13,'Value',1)
    set(handles.checkboxEMDres,'Value',1)
    
    handles.prewhiten_mean = 'Mean';
    handles.prewhiten_linear = '1 order (Linear)';
    handles.prewhiten_polynomial2 = '2 order';
    handles.prewhiten_polynomialmore = 'more order';
    handles.prewhiten_lowess = 'LOWESS';
    handles.prewhiten_rlowess = 'rLOWESS';
    handles.prewhiten_loess = 'LOESS';
    handles.prewhiten_rloess = 'rLOESS';
    handles.prewhiten_emdres = 'eemdres';
    %handles.prewhiten_sgolay = 'Savitzky-Golay';
    
    set(handles.prewhiten_pushbutton,'Enable','on')
end
update_detrend_plot_fig
guidata(hObject, handles);

% --- Executes on button press in prewhiten_clear_pushbutton.
function prewhiten_clear_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_clear_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.prewhiten_mean = '';
handles.prewhiten_linear = '';
handles.prewhiten_lowess = '';
handles.prewhiten_rlowess = '';
handles.prewhiten_loess = '';
handles.prewhiten_rloess = '';
handles.prewhiten_sgolay = '';
handles.prewhiten_polynomial2 = '';
handles.prewhiten_polynomialmore = '';
handles.prewhiten_emdres = '';
% set checkbox
set(handles.prewhiten_lowess_checkbox,'Value',0)
set(handles.prewhiten_loess_checkbox,'Value',0)
set(handles.prewhiten_linear_checkbox,'Value',0)
set(handles.prewhiten_mean_checkbox,'Value',0)
set(handles.prewhiten_rlowess_checkbox,'Value',0)
set(handles.prewhiten_rloess_checkbox,'Value',0)
set(handles.prewhiten_all_checkbox,'Value',0)
set(handles.checkbox11,'Value',0)
set(handles.checkbox13,'Value',0)
set(handles.checkboxEMDres,'Value',0)
%set(handles.prewhiten_pushbutton,'Enable','off')
update_detrend_plot_fig
guidata(hObject, handles);

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
win_ratio = get(hObject,'Value');
handles.prewhiten_win = handles.xrange * win_ratio;
handles.smooth_win = win_ratio;  % windows for smooth 
set(handles.edit10,'String',num2str(handles.prewhiten_win))
set(handles.edit11,'String',num2str(win_ratio*100))

update_detrend_plot_fig

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in prewhiten_pushbutton.
function prewhiten_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% current data for estimate trends
current_data = handles.current_data;
smooth_win = handles.smooth_win;
unit = handles.unit;
datax=current_data(:,1);
datay=current_data(:,2);
dataymean = nanmean(datay);
npts=length(datax);
win = smooth_win * (max(datax)-min(datax));

if npts > 2000
    disp('>> Large dataset, wait ...')
    fwarndlg = warndlg('Large dataset, wait');
end

handles.detrendfig = figure;
set(gcf,'Color', 'white')

update_detrend_plot_fig


guidata(hObject, handles);




% --- Executes on selection change in prewhiten_select_popupmenu.
function prewhiten_select_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to prewhiten_select_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns prewhiten_select_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from prewhiten_select_popupmenu
% lang
lang_id = handles.lang_id;
lang_var = handles.lang_var;
[~, Fitting14] = ismember('Fitting14',lang_id);
[~, Fitting15] = ismember('Fitting15',lang_id);
[~, Fitting16] = ismember('Fitting16',lang_id);
[~, Fitting17] = ismember('Fitting17',lang_id);
[~, Fitting18] = ismember('Fitting18',lang_id);
[~, Fitting19] = ismember('Fitting19',lang_id);
[~, Fitting20] = ismember('Fitting20',lang_id);
[~, Fitting21] = ismember('Fitting21',lang_id);
[~, Fitting22] = ismember('Fitting22',lang_id);

[~, Fitting25] = ismember('Fitting25',lang_id);

handles.prewhiten_popupmenu_selection = 'Raw';

str = get(hObject, 'String');
val = get(hObject,'Value');

% Set current data to the selected data set.
current_data1 = handles.prewhiten_data1(:,1);

switch str{val};
%case 'No_prewhiten (black)' % User selects.
case lang_var{Fitting14} % User selects.
   prewhiten_s = 'No_prewhiten';
   current_data2 = handles.prewhiten_data1(:,2);
   trend = zeros(length(current_data2),1);
   nametype = 0;
case lang_var{Fitting22} % User selects.
   prewhiten_s = 'LOWESS';
   current_data2 = handles.prewhiten_data2(:,1);
   trend = handles.prewhiten_data2(:,2);
   nametype = 1;
case lang_var{Fitting19} % User selects.
   prewhiten_s = 'rLOWESS';
   current_data2 = handles.prewhiten_data2(:,3);
   trend = handles.prewhiten_data2(:,4);
   nametype = 1;
case lang_var{Fitting20} % User selects.
   prewhiten_s = 'LOESS';
   current_data2 = handles.prewhiten_data2(:,5);
   trend = handles.prewhiten_data2(:,6);
   nametype = 1;
case lang_var{Fitting21} % User selects.
   prewhiten_s = 'rLOESS';
   current_data2 = handles.prewhiten_data2(:,7);
   trend = handles.prewhiten_data2(:,8);
   nametype = 1;
case lang_var{Fitting15} % User selects.
   prewhiten_s = 'Mean';
   current_data2 = handles.prewhiten_data1(:,5);
   trend = handles.prewhiten_data1(:,6);
   nametype = 2; % see below
case lang_var{Fitting16} % User selects.
   prewhiten_s = 'Linear';
   current_data2 = handles.prewhiten_data1(:,3);
   trend = handles.prewhiten_data1(:,4);
   nametype = 3;
case lang_var{Fitting17} % User selects.
   prewhiten_s = '2nd';
   current_data2 = handles.prewhiten_data2(:,9);
   trend = handles.prewhiten_data2(:,10);
   nametype = 3;
case lang_var{Fitting18} % User selects.
   prewhiten_s = '3+order';
   current_data2 = handles.prewhiten_data2(:,11);
   trend = handles.prewhiten_data2(:,12);
   nametype = 3;
case lang_var{Fitting25} % User selects.
   prewhiten_s = 'EEMDres';
   current_data2 = handles.prewhiten_data2(:,13);
   trend = handles.prewhiten_data2(:,14);
   nametype = 3;
end

%handles.prewhiten_popupmenu_selection = prewhiten_s;
new_data = [current_data1,current_data2];
handles.new_data = new_data;
current_trend = [current_data1,trend];
win = handles.prewhiten_win;

data_name = handles.data_name;
[~,dat_name,ext] = fileparts(data_name);
if nametype == 1
    handles.name1 = [dat_name,'-',num2str(win),'-',prewhiten_s,ext];
    name2 = [dat_name,'-',num2str(win),'-',prewhiten_s,'trend',ext];
elseif nametype == 2
    handles.name1 = [dat_name,'-demean',ext];
    name2 = [dat_name,'-mean',ext];
elseif nametype == 3
    handles.name1 = [dat_name,'-',prewhiten_s,ext];
    name2 = [dat_name,'-',prewhiten_s,'trend',ext];
end
if nametype > 0
% refresh AC main window
    figure(handles.acfigmain);
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(handles.name1, new_data, 'delimiter', ' ', 'precision', 9); % detrended
    dlmwrite(name2, current_trend, 'delimiter', ' ', 'precision', 9); % trend
    refreshcolor;
    disp('>>  AC main window: see trend and detrended data')
    cd(pre_dirML); % return to matlab view folder
    %figure(figdata); % return plot
end
guidata(hObject,handles)

function pushbutton12_Callback(hObject, eventdata, handles)

% % best span?
% %   method: smooth method
% %   alpha: Penalty parameters
% %   beta: Penalty parameters
current_data = handles.current_data;
t = current_data(:,1);
xmax = max(t);
xmin = min(t);
y = current_data(:,2);
method = 'lowess'; 
num_iterations = 100;
wtb = 1; % waitbar
[bestSpan,bestAlpha, bestBeta] = smoothbestSpanRand(t,y,method,num_iterations,wtb)
if bestSpan <= 0.01; warndlg('Warning: too small, careful'); end
if bestSpan >= 0.99; warndlg('Warning: too big, careful'); end

handles.smooth_win = bestSpan;  % windows for smooth 
handles.prewhiten_win = (xmax-xmin) * handles.smooth_win;
set(handles.edit10,'String', num2str(handles.prewhiten_win));
set(handles.edit11,'String', num2str(handles.smooth_win*100));
set(handles.slider4, 'Value', handles.smooth_win);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function pushbutton12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end