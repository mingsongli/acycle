function varargout = waveletGUI(varargin)
% WAVELETGUI MATLAB code for waveletGUI.fig
%      WAVELETGUI, by itself, creates a new WAVELETGUI or raises the existing
%      singleton*.
%
%      H = WAVELETGUI returns the handle to a new WAVELETGUI or the handle to
%      the existing singleton*.
%
%      WAVELETGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAVELETGUI.M with the given input arguments.
%
%      WAVELETGUI('Property','Value',...) creates a new WAVELETGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before waveletGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to waveletGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help waveletGUI

% Last Modified by GUIDE v2.5 11-Nov-2021 01:51:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @waveletGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @waveletGUI_OutputFcn, ...
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


% --- Executes just before waveletGUI is made visible.
function waveletGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to waveletGUI (see VARARGIN)

set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
if ismac
    set(gcf,'position',[0.45,0.2,0.4,0.35]* handles.MonZoom) % set position
elseif ispc
    set(gcf,'position',[0.45,0.2,0.4,0.35]* handles.MonZoom) % set position
end

set(handles.text2,'position',[0.02,0.85,0.1,0.06])
set(handles.edit1,'position',[0.13,0.85,0.65,0.06])
set(handles.text3,'position',[0.02,0.77,0.1,0.06])
set(handles.edit2,'position',[0.13,0.77,0.65,0.06])
set(handles.pushbutton1,'position',[0.79,0.77,0.2,0.06])
set(handles.checkbox11,'position',[0.79,0.86,0.12,0.06])

set(handles.uibuttongroup1,'position',[0.02,0.4,0.46,0.35])
set(handles.text4,'position',[0.04,0.8,0.2,0.15])
set(handles.edit3,'position',[0.3,0.75,0.3,0.2])
set(handles.text5,'position',[0.04,0.5,0.2,0.15])
set(handles.edit4,'position',[0.3,0.45,0.3,0.2])
set(handles.text6,'position',[0.04,0.15,0.4,0.15])
set(handles.edit5,'position',[0.45,0.1,0.15,0.2])
set(handles.radiobutton1,'position',[0.7,0.75,0.25,0.2])
set(handles.radiobutton2,'position',[0.7,0.45,0.25,0.2])
set(handles.checkbox1,'position',[0.7,0.15,0.25,0.2])

set(handles.uipanel1,'position',[0.5,0.4,0.46,0.35])
set(handles.text7,'position',[0.06,0.75,0.2,0.15])
set(handles.popupmenu1,'position',[0.28,0.65,0.68,0.2])
set(handles.text8,'position',[0.06,0.45,0.2,0.15])
set(handles.popupmenu2,'position',[0.28,0.35,0.68,0.2])
set(handles.text11,'position',[0.06,0.15,0.2,0.15])
set(handles.edit7,'position',[0.28,0.1,0.1,0.2])

set(handles.uipanel2,'position',[0.02,0.02,0.78,0.36])
set(handles.checkbox2,'position',[0.02,0.75,0.25,0.2])
set(handles.checkbox3,'position',[0.02,0.5,0.25,0.2])
set(handles.checkbox8,'position',[0.02,0.25,0.25,0.2])
set(handles.checkbox10,'position',[0.02,0.02,0.25,0.2])
set(handles.checkbox4,'position',[0.3,0.75,0.25,0.2])
set(handles.checkbox5,'position',[0.3,0.5,0.25,0.2])
set(handles.checkbox6,'position',[0.3,0.25,0.25,0.2])
set(handles.checkbox9,'position',[0.3,0.05,0.25,0.2])

set(handles.text9,'position',[0.58,0.75,0.12,0.15])
set(handles.popupmenu3,'position',[0.71,0.73,0.26,0.2])
set(handles.text10,'position',[0.58,0.55,0.12,0.15])
set(handles.edit6,'position',[0.73,0.55,0.15,0.15])

set(handles.radiobutton3,'position',[0.65,0.15,0.1,0.2])
set(handles.radiobutton4,'position',[0.75,0.15,0.1,0.2])

set(handles.uipanel3,'position',[0.82,0.02,0.14,0.36])
set(handles.checkbox7,'position',[0.03,0.6,0.95,0.2])
set(handles.pushbutton2,'position',[0.2,0.1,0.6,0.4])

% read selected file

data = varargin{1}.current_data;
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
handles.current_data = data;
handles.data_name = varargin{1}.data_name;
data_name = handles.data_name;
[lengthdata,~] = size(data_name);
handles.path_temp = varargin{1}.path_temp;
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
handles.lengthdata = lengthdata;
handles.wavehastorerun = 1;
handles.switchdata = 0;

if lengthdata == 1
    % wavelet
    set(gcf,'Name','Acycle: Wavelet')
    [dat_dir,handles.filename1,exten] = fileparts(data_name);
    
    set(handles.text3,'enable','off')
    set(handles.edit2,'enable','off')
    set(handles.pushbutton1,'visible','off')
    set(handles.edit1,'string',[handles.filename1,exten])
    set(handles.text6,'string','Discrete scale spacing')
    set(handles.edit5,'string','0.1')
    set(handles.popupmenu1, 'Value', 1);
    set(handles.popupmenu2,'enable','on')
    set(handles.edit7,'enable','on')
    set(handles.checkbox1,'Value',0,'enable','on')
    set(handles.checkbox3,'Value',0,'enable','on','string','plot spectrum')
    set(handles.checkbox9,'Value',1,'enable','on')
else
    % wcoherence
    set(gcf,'Name','Acycle: Wavelet coherence and cross-spectrum')
    [handles.dat_dir,handles.filename1,handles.exten] = fileparts(data_name(1,:));
    [handles.dat_dir,handles.filename2,handles.exten] = fileparts(data_name(2,:));
    set(handles.text3,'enable','on')
    set(handles.edit2,'enable','on')
    set(handles.pushbutton1,'visible','on')
    set(handles.edit1,'string',[handles.filename1,handles.exten])
    set(handles.edit2,'string',[handles.filename2,handles.exten])
    set(handles.popupmenu1, 'Value', 3);
    set(handles.popupmenu2,'enable','off')
    set(handles.edit7,'enable','off')
    set(handles.text6,'string','Phase threshold')
    set(handles.edit5,'string','0.7')
    set(handles.checkbox1,'Value',0,'enable','off')
    %set(handles.checkbox3,'Value',0,'enable','off','string','cross-spectrum')
    set(handles.checkbox3,'Value',0,'enable','on','string','cross-spectrum')
    set(handles.checkbox9,'Value',0,'enable','off')
end

time = data(:,1);
timelen = 0.5 * (time(end)-time(1));
Dti = diff(time);
dt = mean(Dti);

set(handles.edit3,'string',num2str(2*dt))
set(handles.edit4,'string',num2str(timelen))
set(handles.popupmenu1,'value',1,'enable','off')
set(handles.popupmenu2,'value',1)
set(handles.checkbox2,'value',1)
set(handles.checkbox8,'value',1)
set(handles.checkbox4,'value',0)
set(handles.checkbox5,'value',1)
set(handles.checkbox6,'value',0)
set(handles.checkbox7,'value',0)
set(handles.checkbox10,'value',0)
% value
set(handles.radiobutton1,'value',0)
set(handles.radiobutton2,'value',1)

set(handles.radiobutton3,'value',1)
set(handles.radiobutton4,'value',0)
set(handles.checkbox8,'value',1)

set(handles.checkbox1,'value',0)
set(handles.edit6,'string','')
set(handles.edit7,'string','6')
set(handles.popupmenu3,'value',1)
set(handles.checkbox11,'value',0)
% Choose default command line output for waveletGUI
handles.output = hObject;


if lengthdata == 1
    if max(Dti) - min(Dti) > 10 * eps('single')
        f = warndlg('Interpolation needed?','Warning');
    end
else
    data_name = handles.data_name;
    %data = handles.current_data;
    s2 = data_name(1,:);
    s2(s2 == ' ') = [];
    dat1 = load(s2);
    s2 = data_name(2,:);
    s2(s2 == ' ') = [];
    dat2 = load(s2);
    
    Dti1 = diff(dat1(:,1));
    Dti2 = diff(dat2(:,1));
    
    if max(Dti1) - min(Dti1) > 10 * eps('single')
        if max(Dti2) - min(Dti2) > 10 * eps('single')
            f = warndlg('Series 1 AND 2: Interpolation needed?','Warning');
        else
            f = warndlg('Series 1: Interpolation needed?','Warning');
        end
    else
        if max(Dti2) - min(Dti2) > 10 * eps('single')
            f = warndlg('Series 2: Interpolation needed?','Warning');
        else
            if length(Dti1) == length(Dti2)
                if dat1(1,1) - dat2(1,1) > 100 * eps('single')
                    f3 = warndlg('Starting point of the series must be the same. Try <Interpolate Series>','Warning');
                end
            else
                f2 = warndlg('Series length must be equal','Warning');
            end
        end
    end
   
end
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes waveletGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% switch data
handles.wavehastorerun = 1;

if handles.switchdata == 0
    data_name = handles.data_name;
    [handles.dat_dir,handles.filename1,handles.exten] = fileparts(data_name(2,:));
    [handles.dat_dir,handles.filename2,handles.exten] = fileparts(data_name(1,:));
    set(handles.edit1,'string',[handles.filename1,handles.exten])
    set(handles.edit2,'string',[handles.filename2,handles.exten])
    
    handles.data_name = [data_name(2,:);data_name(1,:)];
    
    handles.switchdata = 1;
    
elseif handles.switchdata == 1
    
    data_name = handles.data_name;
    [handles.dat_dir,handles.filename1,handles.exten] = fileparts(data_name(2,:));
    [handles.dat_dir,handles.filename2,handles.exten] = fileparts(data_name(1,:));
    set(handles.edit1,'string',[handles.filename1,handles.exten])
    set(handles.edit2,'string',[handles.filename2,handles.exten])
    
    handles.data_name = [data_name(2,:);data_name(1,:)];
    
    handles.switchdata = 0;
end

% coherence
wavecoh_readGUI
% update plot
wavecoh_update_plots

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end

handles.wavehastorerun = 0;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = waveletGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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



% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
handles.wavehastorerun = 1;
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    handles.wavehastorerun = 1;
    if get(hObject,'Value')
        set(handles.radiobutton1,'enable','off','value',0)
        set(handles.radiobutton2,'enable','off','value',1)
        set(handles.checkbox8,'enable','off')
        set(handles.checkbox8,'value',1)
        % coherence
        wavecoh_readGUI
        % update plot
        wavecoh_update_plots
    else
        set(handles.checkbox2,'value',0)
        set(handles.radiobutton1,'enable','on','value',0)
        set(handles.radiobutton2,'enable','on','value',1)
        set(handles.checkbox8,'enable','on')
        % coherence
        wavecoh_readGUI
        % update plot
        wavecoh_update_plots
    end
end
guidata(hObject, handles);

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
if get(hObject,'Value')
    set(handles.radiobutton4,'value',0)
else
    set(handles.radiobutton4,'value',1)
end
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
if get(hObject,'Value')
    set(handles.radiobutton3,'value',0)
else
    set(handles.radiobutton3,'value',1)
end
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
contents = cellstr(get(hObject,'String'));
mother = contents{get(hObject,'Value')};
if strcmp(mother, 'MORLET')
    set(handles.edit7,'string','6')
elseif strcmp(mother, 'PAUL')
    set(handles.edit7,'string','4')
elseif strcmp(mother, 'DOG')
    set(handles.edit7,'string','2')
end

handles.wavehastorerun = 1;
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
handles.wavehastorerun = 1;
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
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
handles.wavehastorerun = 1;
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
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
handles.wavehastorerun = 1;
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
handles.wavehastorerun = 1;
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
handles.wavehastorerun = 1;
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
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


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);

% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
handles.wavehastorerun = 1;

if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end

handles.wavehastorerun = 0;
guidata(hObject, handles);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1

if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
guidata(hObject, handles);
