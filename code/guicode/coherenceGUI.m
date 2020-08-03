function varargout = coherenceGUI(varargin)
% COHERENCEGUI MATLAB code for coherenceGUI.fig
%      COHERENCEGUI, by itself, creates a new COHERENCEGUI or raises the existing
%      singleton*.
%
%      H = COHERENCEGUI returns the handle to a new COHERENCEGUI or the handle to
%      the existing singleton*.
%
%      COHERENCEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COHERENCEGUI.M with the given input arguments.
%
%      COHERENCEGUI('Property','Value',...) creates a new COHERENCEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before coherenceGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to coherenceGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help coherenceGUI

% Last Modified by GUIDE v2.5 16-Mar-2020 15:43:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @coherenceGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @coherenceGUI_OutputFcn, ...
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


% --- Executes just before coherenceGUI is made visible.
function coherenceGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to coherenceGUI (see VARARGIN)

%
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
handles.unit = varargin{1}.unit;
%
% Choose default command line output for agescale
handles.output = hObject;
handles.cohgui = gcf;
set(gcf,'Name','Acycle: Coherence & Phase Analysis')
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

set(gcf,'position',[0.03,0.03,0.7,0.4]) % set position
set(handles.pushbutton4,'position',[0.496,0.776,0.06,0.06]) % set position
set(handles.pushbutton7,'position',[0.496,0.653,0.06,0.06]) % set position
set(handles.pushbutton8,'position',[0.86,0.05,0.12,0.15]) % set position
set(handles.checkbox3,'position',[0.86,0.25,011812,0.15]) % set position

set(handles.edit1,'position',[0.018,0.858,0.454,0.06]) % set position
set(handles.edit2,'position',[0.58,0.778,0.404,0.06]) % set position
set(handles.edit2,'string','') % set position

set(handles.listbox1,'position',[0.018,0.426,0.454,0.432]) % set position
set(handles.listbox2,'position',[0.58,0.426,0.404,0.29]) % set position
set(handles.text3,'position',[0.586,0.84, 0.074,0.05]) % set position
set(handles.text4,'position',[0.586,0.724, 0.074,0.05]) % set position
set(handles.uibuttongroup1,'position',[0.016,0.037, 0.84,0.366]) % set position
set(handles.text1,'position',[0.012,0.838, 0.089,0.15]) % set position
set(handles.popupmenu1,'position',[0.111,0.726, 0.21,0.231]) % set position
set(handles.text11,'position',[0.012,0.573, 0.173,0.15]) % set position
set(handles.text7,'position',[0.012,0.308, 0.121,0.15]) % set position
set(handles.text8,'position',[0.012,0.145, 0.152,0.15]) % set position
set(handles.text9,'position',[0.316,0.333, 0.089,0.15]) % set position
set(handles.text10,'position',[0.316,0.128, 0.089,0.15]) % set position
set(handles.edit7,'position',[0.215,0.513, 0.089,0.188]) % set position
set(handles.edit5,'position',[0.185,0.282, 0.12,0.188]) % set position
set(handles.edit6,'position',[0.185,0.077, 0.12,0.188]) % set position
set(handles.uibuttongroup2,'position',[0.362,0.06, 0.193,0.915]) % set position
set(handles.radiobutton1,'position',[0.064,0.768,0.862,0.242]) % set position
set(handles.radiobutton1,'value',1) % set position
set(handles.radiobutton2,'position',[0.064,0.505,0.862,0.242]) % set position
set(handles.radiobutton2,'value',0) % set position
set(handles.text12,'position',[0.119,0.295,0.339,0.211]) % set position
set(handles.text13,'position',[0.119,0.105,0.339,0.211]) % set position
set(handles.edit8,'position',[0.514,0.305,0.44,0.232]) % set position
set(handles.edit9,'position',[0.514,0.042,0.44,0.232]) % set position
set(handles.text14,'position',[0.576,0.915,0.089,0.14]) % set position
set(handles.axes1,'position',[0.603,0.15,0.166,0.6]) % set position
set(handles.axes2,'position',[0.814,0.15,0.166,0.6]) % set position
set(handles.checkbox1,'position',[0.576,0.675,0.03,0.2]) % set position
set(handles.checkbox2,'position',[0.788,0.675,0.03,0.2]) % set position
axes(handles.axes2);
polarscatter(45,10,50,'filled','MarkerFaceAlpha',.5)
axes(handles.axes1);
plot(rand(20,2))

set(handles.edit7,'string',num2str(0.1))
handles.cohthreshold = 0.1;
% Choose default command line output for coherenceGUI
handles.output = hObject;

CDac_pwd; % cd ac_pwd dir
d = dir; %get files
set(handles.listbox1,'String',{d.name},'Value',1) %set string
set(handles.edit1,'String',pwd) % set position
cd(pre_dirML); % return to matlab view folder

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes coherenceGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = coherenceGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
plot_selected = get(hObject,'Value');
handles.index_selected  = plot_selected;
handles.nplot = length(plot_selected);   % length
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
address = get(hObject,'String');
cd(address)
d = dir; %get files
set(handles.listbox1,'String',{d.name},'Value',1) %set string
guidata(hObject,handles)

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


% --- Executes on button press in pushbutton7.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


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


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_content = cellstr(get(handles.listbox1,'String')); % read contents of listbox 1 
index_selected = handles.index_selected;
nplot = handles.nplot;
if index_selected > 2
    if nplot == 1
        handles.targetname = list_content(index_selected,1);
        set(handles.edit2,'String',handles.targetname,'Value',1);
        targetname = char(get(handles.edit2,'String'));
        targetdir = char(get(handles.edit1,'String'));
        target    = load(fullfile(targetdir,targetname));
        target = datapreproc(target);
        t1 = target(:,1);
        segs = 2;  % 2 segements
        winoverlap = 0.5; % 50% overlap
        sr_target = median(diff(target(:,1)));
        windowsize = round(abs(t1(end)-t1(1))/segs);
        nooverlap = round(windowsize * winoverlap);
        set(handles.edit5,'string',num2str(windowsize))
        set(handles.edit6,'string',num2str(nooverlap))
        set(handles.edit8,'string',num2str(0))
        set(handles.edit9,'string',num2str(1/(2*sr_target)))
    end
end
guidata(hObject,handles)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_content = cellstr(get(handles.listbox1,'String')); % read contents of listbox 1 
index_selected = handles.index_selected;
nplot = handles.nplot;
series_num = 0;
if index_selected > 2
    for i=1:nplot
        seriesname = char(list_content(index_selected(i),1));
        series_num = series_num + 1;
        series(series_num,1) = {seriesname};
    end
end
set(handles.listbox2,'String',char(series),'Value',1);
guidata(hObject,handles)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
coherence_update;
guidata(hObject,handles)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
coherence_update;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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
coherence_update;
guidata(hObject,handles)

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
coherence_update;
guidata(hObject,handles)

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

function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
if str2double(get(hObject,'String')) > 1
    set(handles.edit7,'string','1')
elseif str2double(get(hObject,'String')) < 0
    set(handles.edit7,'string','0')
end
coherence_update;
guidata(hObject,handles)

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



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
if str2double(get(hObject,'String')) < 0
    set(handles.edit7,'string','0')
end
coherence_update;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
coherence_update;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
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
coherence_update;
guidata(hObject,handles)

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
coherence_update;
guidata(hObject,handles)

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
if get(hObject,'Value') == 1
    targetdir = char(get(handles.edit1,'String'));
    targetname = char(get(handles.edit2,'String'));
    target    = load(fullfile(targetdir,targetname));
    target = datapreproc(target,0);
    sr_target = median(diff(target(:,1)));
    set(handles.edit8,'string',num2str(0))
    set(handles.edit9,'string',num2str(1/(2*sr_target)))
end
coherence_update;
guidata(hObject,handles)

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
if get(hObject,'Value') == 1
    targetdir = char(get(handles.edit1,'String'));
    targetname = char(get(handles.edit2,'String'));
    target    = load(fullfile(targetdir,targetname));
    target = datapreproc(target,0);
    t = target(:,1);
    sr_target = median(diff(target(:,1)));
    set(handles.edit8,'string',num2str(2*sr_target))
    set(handles.edit9,'string',num2str(0.5* abs(t(1) - t(end))))
end
coherence_update;
guidata(hObject,handles)
