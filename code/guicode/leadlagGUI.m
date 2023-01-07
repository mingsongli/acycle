function varargout = leadlagGUI(varargin)
% LEADLAGGUI MATLAB code for leadlagGUI.fig
%      LEADLAGGUI, by itself, creates a new LEADLAGGUI or raises the existing
%      singleton*.
%
%      H = LEADLAGGUI returns the handle to a new LEADLAGGUI or the handle to
%      the existing singleton*.
%
%      LEADLAGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEADLAGGUI.M with the given input arguments.
%
%      LEADLAGGUI('Property','Value',...) creates a new LEADLAGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before leadlagGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to leadlagGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help leadlagGUI

% Last Modified by GUIDE v2.5 06-Aug-2020 16:45:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @leadlagGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @leadlagGUI_OutputFcn, ...
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


% --- Executes just before leadlagGUI is made visible.
function leadlagGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to leadlagGUI (see VARARGIN)

% Choose default command line output for leadlagGUI
handles.output = hObject;
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.unit = varargin{1}.unit;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;

handles.hmain = gcf;
set(handles.hmain,'Name', 'Acycle: Lead-lag relationship')
% GUI settings
set(0,'Units','normalized') % set units as normalized
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

set(handles.hmain,'position',[0.38,0.2,0.6,0.25]* handles.MonZoom) % set position
set(handles.uipanel1,'position',[0.025,0.286,0.947,0.649]) % Data
set(handles.text2,'position',[0.015,0.849,0.24,0.15])
set(handles.text3,'position',[0.015,0.28,0.24,0.15])
set(handles.edit1,'position',[0.125,0.547,0.87,0.208])
set(handles.edit2,'position',[0.125,0.03,0.87,0.208])

set(handles.text6,'position',[0.015,0.125,0.1,0.1])
set(handles.popupmenu1,'position',[0.12,0.125,0.17,0.1])
set(handles.popupmenu1,'Value',1)
set(handles.text4,'position',[0.3,0.125,0.1,0.1])
set(handles.edit3,'position',[0.4,0.125,0.08,0.1])
set(handles.text5,'position',[0.48,0.125,0.1,0.1])
set(handles.edit4,'position',[0.58,0.125,0.06,0.1])
set(handles.checkbox1,'position',[0.67,0.125,0.1,0.1])
set(handles.pushbutton1,'position',[0.8,0.1,0.16,0.168]) % plot

set(handles.pushbutton3,'position',[0.015,0.557,0.1,0.208]) % plot
set(handles.pushbutton4,'position',[0.015,0.03,0.1,0.208]) % plot

% Read list
GETac_pwd;
set(handles.edit1,'string',ac_pwd)
set(handles.edit2,'string',ac_pwd)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes leadlagGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = leadlagGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_dirML = pwd;
CDac_pwd; % cd ac_pwd dir
[file,path] = uigetfile({'*.*',  'All Files (*.*)'},...
                        'Select a Reference Series');
if isequal(file,0)
    disp('User selected Cancel')
else
    set(handles.edit1,'string',fullfile(path,file))
end
cd(pre_dirML); 

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton3.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_dirML = pwd;
handles.plot_s{1} = get(handles.edit1,'string');
handles.plot_s{2} = get(handles.edit2,'string');
% dat1: reference
% dat2: series
try
    dat1 = load(handles.plot_s{1});
    dat2 = load(handles.plot_s{2});
catch
    fid = fopen(handles.plot_s{1});
    data_ft = textscan(fid,'%f%f','EmptyValue', Inf);
    dat1 = cell2mat(data_ft);
    fclose(fid);
    fid = fopen(handles.plot_s{2});
    data_ft = textscan(fid,'%f%f','EmptyValue', Inf);
    dat2 = cell2mat(data_ft);
    fclose(fid);
end

% sort
dat1 = sortrows(dat1);
dat2 = sortrows(dat2);
% unique
dat1=findduplicate(dat1);
dat2=findduplicate(dat2);
% remove empty
dat1(any(isinf(dat1),2),:) = [];
dat2(any(isinf(dat2),2),:) = [];
%
ll = str2double(get(handles.edit3,'string'));
step = str2double(get(handles.edit4,'string'));
plotn = 1; % plot
timedir = get(handles.popupmenu1,'Value'); % 1: small=young; 2: small=old 
try
    [llgrid,RMSE] = rmse4leadlag(dat1,dat2,ll,step,timedir,plotn);
catch
    errordlg('Error. Check selected datasets and settings','Acycle: lead/lag')
end

% save data or not
savedatayn = get(handles.checkbox1,'value');
if savedatayn == 1
    CDac_pwd; % cd ac_pwd dir
    [~,name1,~] = fileparts(handles.plot_s{1});
    [~,name2,ext2] = fileparts(handles.plot_s{2});
    name1 = [name2,'-LeadLag-',name1,ext2];
    try
        dlmwrite(name1, [llgrid',RMSE'], 'delimiter', ' ', 'precision', 9);
    catch
    end
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_dirML = pwd;
CDac_pwd; % cd ac_pwd dir
[file,path] = uigetfile({'*.*',  'All Files (*.*)'},...
                        'Select a Target Series');
if isequal(file,0)
    disp('User selected Cancel')
else
    set(handles.edit2,'string',fullfile(path,file))
end
cd(pre_dirML); 

handles.plot_s{2} = get(handles.edit2,'string');
% dat1: reference
% dat2: series
try
    dat2 = load(handles.plot_s{2});
catch
    fid = fopen(handles.plot_s{2});
    data_ft = textscan(fid,'%f%f','EmptyValue', Inf);
    dat2 = cell2mat(data_ft);
    fclose(fid);
end

xmax = nanmax(dat2(:,1));
xmin = nanmin(dat2(:,1));

ll = (xmax-xmin)/10;
%step = (xmax-xmin)/200;
step = mean(diff(dat2(:,1)),'omitnan')/2;

set(handles.edit3,'String',num2str(ll))
set(handles.edit4,'String',num2str(step))
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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


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

% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)

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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
