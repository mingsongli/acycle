function varargout = ft(varargin)
% FT MATLAB code for ft.fig
%      FT, by itself, creates a new FT or raises the existing
%      singleton*.
%
%      H = FT returns the handle to a new FT or the handle to
%      the existing singleton*.
%
%      FT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FT.M with the given input arguments.
%
%      FT('Property','Value',...) creates a new FT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ft_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ft_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ft

% Last Modified by GUIDE v2.5 31-Dec-2017 16:01:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ft_OpeningFcn, ...
                   'gui_OutputFcn',  @ft_OutputFcn, ...
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

% --- Executes just before ft is made visible.
function ft_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ft (see VARARGIN)
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',12);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',12);  % set as norm
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;
% language
lang_choice = varargin{1}.lang_choice;
handles.lang_choice = lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;
handles.lang_id = lang_id;
handles.lang_var = lang_var;
handles.main_unit_selection = varargin{1}.main_unit_selection;
if ismac
    set(gcf,'position',[0.3,0.2,0.65,0.4]* handles.MonZoom) % set position
elseif ispc
    set(gcf,'position',[0.3,0.2,0.65,0.4]* handles.MonZoom) % set position
    set(h1,'FontUnits','points','FontSize',11);  % set as norm
    set(h2,'FontUnits','points','FontSize',11);  % set as norm
end
set(handles.text10,'position',[0.45,0.903,0.12,0.05])
set(handles.text12,'position',[0.57,0.903,0.415,0.05])
set(handles.ft_axes3,'position',[0.411,0.523,0.546,0.364])
set(handles.ft_axes4,'position',[0.411,0.084,0.546,0.367])
set(handles.ft_uipanel2,'position',[0.02,0.45,0.19,0.53])
set(handles.uipanel6,'position',[0.215,0.45,0.149,0.53])
set(handles.uibuttongroup2,'position',[0.02,0.05,0.19,0.4])
set(handles.pushbutton26,'position',[0.236,0.156,0.093,0.256])

set(handles.text1,'position',[0.054,0.8,0.415,0.122])
set(handles.text2,'position',[0.054,0.591,0.415,0.122])
set(handles.text3,'position',[0.054,0.417,0.95,0.122])
set(handles.text21,'position',[0.054,0.21,0.55,0.122])
set(handles.popupmenu4,'position',[0.061,0.005,0.83,0.2])
set(handles.edit1,'position',[0.503,0.791,0.395,0.15])
set(handles.edit2,'position',[0.503,0.574,0.395,0.15])
set(handles.edit18,'position',[0.59,0.26,0.28,0.1])
set(handles.edit18,'string','12')

set(handles.text16,'position',[0.074,0.754,0.4,0.094])
set(handles.text15,'position',[0.074,0.58,0.4,0.094])
set(handles.text18,'position',[0.074,0.4,0.4,0.094])
set(handles.text17,'position',[0.074,0.22,0.4,0.094])

set(handles.edit11,'position',[0.5,0.717,0.426,0.159])
set(handles.edit10,'position',[0.5,0.536,0.426,0.159])
set(handles.edit13,'position',[0.5,0.362,0.426,0.159])
set(handles.edit12,'position',[0.5,0.181,0.426,0.159])

set(handles.radiobutton6,'position',[0.049,0.759,0.634,0.205])
set(handles.radiobutton7,'position',[0.049,0.562,0.634,0.205])
set(handles.radiobutton8,'position',[0.049,0.366,0.634,0.205])

set(handles.edit16,'position',[0.626,0.768,0.35,0.159])
set(handles.edit17,'position',[0.626,0.554,0.35,0.159])
set(handles.popupmenu5,'position',[0.024,0.054,0.976,0.259])

handles.output = hObject;
if handles.lang_choice == 0
    set(gcf,'Name','Acycle: Filtering')
else
    [~, menu113] = ismember('menu113',lang_id);
    set(gcf,'Name',['Acycle: ',lang_var{menu113}])
end
% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
data_s = varargin{1}.current_data;
data_s = sortrows(data_s);
data_s(:,2) = data_s(:,2) - mean(data_s(:,2));
handles.current_data = data_s;
handles.data_name = varargin{1}.data_name;
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
[~,handles.dat_name,handles.ext] = fileparts(handles.data_name);
set(handles.text12, 'String', handles.dat_name); % f max

handles.index_selected = 0;
handles.cycle = 41;
% Choose default command line output for ft
% Update handles structure
handles.step = data_s(2,1)-data_s(1,1);
datax = data_s(:,1);
[po2,w2] = pmtm(data_s(:,2),2,5*length(datax));
fd2 = w2/(2*pi*handles.step);
L = length(data_s(:,2));
dt = mean(diff(data_s(:,1)));
Y = fft(data_s(:,2),L);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = 1/dt * (0:(L/2))/L;

handles.x_1 = 0;
handles.x_2 = 0.5*max(f);
handles.y_1 = 0;
handles.y_2 = max(P1);
handles.y_3 = max(po2);
set(handles.edit10,'String',num2str(handles.x_1))
set(handles.edit12,'String',num2str(handles.y_1))
set(handles.edit11,'String',num2str(handles.x_2))
set(handles.edit13,'String',num2str(handles.y_2))

set(handles.radiobutton6,'Value',1)
set(handles.radiobutton7,'Value',0)
set(handles.radiobutton8,'Value',0)
% PLOT: log | MTM  in axes 4
axes(handles.ft_axes4);
plot(fd2,po2);
xlim([handles.x_1 handles.x_2])
ylim([handles.y_1 handles.y_3])
% language
if handles.lang_choice == 0
    xlabel(['Frequency (cycles/' handles.unit,')'])
else
    [~, main14] = ismember('main14',handles.lang_id);
    xlabel([lang_var{main14},'(1/' handles.unit,')'])
end
% Set frequency which has (the 1st) maximum power as default frequencies
fd1index = find(P1 == max(P1), 1, 'first');
fq_deft = f(fd1index);   % find f with max power
handles.fd1index = fd1index;
handles.filt_fmid = fq_deft;
handles.filt_flow = fq_deft * 0.8; % 40%
handles.filt_fhigh = fq_deft * 1.2; % 40%
handles.taner_c = 10^12;
set(handles.edit1, 'String', num2str(handles.filt_flow)); % f low
set(handles.edit2, 'String', num2str(handles.filt_fhigh)); % f high
handles.add_list = '';
handles.filter = 'Gaussian';
% update axes 3
update_filter_axes

% language
if handles.lang_choice > 0
    [~, ft01] = ismember('ft01',handles.lang_id);
    set(handles.ft_uipanel2,'Title',lang_var{ft01})
    
    [~, ft02] = ismember('ft02',handles.lang_id);
    set(handles.uipanel6,'Title',lang_var{ft02})
    
    [~, ft03] = ismember('ft03',handles.lang_id);
    set(handles.uibuttongroup2,'Title',lang_var{ft03})
    
    [~, ft04] = ismember('ft04',handles.lang_id);
    set(handles.text10,'String',lang_var{ft04})
    
    [~, ft05] = ismember('ft05',handles.lang_id);
    set(handles.text1,'String',lang_var{ft05})
    
    [~, ft06] = ismember('ft06',handles.lang_id);
    set(handles.text2,'String',lang_var{ft06})
    
    [~, ft08] = ismember('ft08',handles.lang_id);
    set(handles.text21,'String',lang_var{ft08})
    
    [~, ft09] = ismember('ft09',handles.lang_id);
    set(handles.text16,'String',lang_var{ft09})
    
    [~, ft10] = ismember('ft10',handles.lang_id);
    set(handles.text15,'String',lang_var{ft10})
    
    [~, ft11] = ismember('ft11',handles.lang_id);
    set(handles.text18,'String',lang_var{ft11})
    
    [~, ft12] = ismember('ft12',handles.lang_id);
    set(handles.text17,'String',lang_var{ft12})
    
    [~, ft13] = ismember('ft13',handles.lang_id);
    set(handles.radiobutton6,'String',lang_var{ft13})
    
    [~, ft14] = ismember('ft14',handles.lang_id);
    set(handles.radiobutton7,'String',lang_var{ft14})
    
    [~, ft15] = ismember('ft15',handles.lang_id);
    set(handles.radiobutton8,'String',lang_var{ft15})
    
    [~, main01] = ismember('main01',handles.lang_id);
    set(handles.pushbutton26,'String',lang_var{main01})
end
%
set(handles.popupmenu4,'Value',5)
set(handles.popupmenu5,'Value',2)
guidata(hObject,handles)

diffx = diff(data_s(:,1));
if max(diffx) - min(diffx) > 10 * eps('single')
    if handles.lang_choice == 0
        hwarn = warndlg('Warning: the data may not be evenly spaced.');
    else
        [~, ec25] = ismember('ec25',handles.lang_id);
        hwarn = warndlg(lang_var{ec25});
    end
    %set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'position',[0.2,0.6,0.2,0.1])
    figure(hwarn);
end

% --- Outputs from this function are returned to the command line.
function varargout = ft_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
%%

update_filter_axes
guidata(hObject,handles)


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
%%
update_filter_axes
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


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
%%
update_filter_axes
guidata(hObject,handles)

%%

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

% --- Executes during object creation, after setting all properties.
function ft_axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ft_axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ft_axes3


% --- Executes during object creation, after setting all properties.
function ft_axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ft_axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ft_axes4


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2



function period_edit4_Callback(hObject, eventdata, handles)
% hObject    handle to period_edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of period_edit4 as text
%        str2double(get(hObject,'String')) returns contents of period_edit4 as a double


% --- Executes during object creation, after setting all properties.
function period_edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to period_edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function getpks_popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to getpks_popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
contents = cellstr(get(hObject,'String'));
filter = contents{get(hObject,'Value')};
handles.filter = filter;

if strcmp(filter,'Taner-Hilbert')
    data = handles.current_data;
    L = length(data(:,2));
    dt = mean(diff(data(:,1)));
    Y = fft(data(:,2),L);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    set(handles.edit13,'string',num2str(max(P1)))
else
    set(handles.edit13,'string',num2str(handles.y_2))
end
update_filter_axes
guidata(hObject,handles)
try
    handles.add_list = add_list;
    handles.data_filterout = data_filterout;
catch
end
%disp(' Ready to save')
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double

update_filter_axes
guidata(hObject,handles)

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

update_filter_axes
guidata(hObject,handles)


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



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double

update_filter_axes
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double

update_filter_axes
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
handles.index_selected = get(hObject,'Value');
guidata(hObject,handles)


function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
handles.cycle = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ft_figure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ft_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double
update_filter_axes4
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double
update_filter_axes4
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
% read pop-up menu

update_filter_axes4

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8
if get(hObject,'Value')
    set(handles.edit17,'Visible','On');
else
    set(handles.edit17,'Visible','Off');
end
update_filter_axes4
guidata(hObject,handles)

% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7
if get(hObject,'Value')
    set(handles.edit17,'Visible','Off');
end
update_filter_axes4
guidata(hObject,handles)

% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
if get(hObject,'Value')
    set(handles.edit17,'Visible','Off');
end
update_filter_axes4
guidata(hObject,handles)

% --- Executes when ft_uipanel2 is resized.
function ft_uipanel2_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to ft_uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when uibuttongroup2 is resized.
function uibuttongroup2_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when uipanel6 is resized.
function uipanel6_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%a = handles.add_list
add_list = handles.add_list;
lang_var = handles.lang_var;

if isempty(add_list)
    if handles.lang_choice == 0
        errordlg('Select filtering method')
    else
        [~, ft16] = ismember('ft16',handles.lang_id);
        errordlg(lang_var{ft16})
    end
else
    figft = gcf;
    data_filterout = handles.data_filterout;
    filter = handles.filter;
    CDac_pwd;
    dlmwrite(add_list, data_filterout, 'delimiter', ' ', 'precision', 9);
    figdata = figure;
    data = handles.current_data;
    plot(data(:,1),data(:,2),'k');hold on
    plot(data_filterout(:,1),data_filterout(:,2),'r')
    xlim([min(data(:,1)),max(data(:,1))])
    title(add_list, 'Interpreter', 'none')
    
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        if handles.unit_type == 0
            xlabel(['Unit (',handles.unit,')'])
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
        end
    else
        [~, main34] = ismember('main34',handles.lang_id); % unit
        [~, main23] = ismember('main23',handles.lang_id);
        [~, main21] = ismember('main21',handles.lang_id);
        
        if handles.unit_type == 0
            xlabel([lang_var{main34},' (',handles.unit,')'])
        elseif handles.unit_type == 1
            xlabel([lang_var{main23},' (',handles.unit,')'])
        else
            xlabel([lang_var{main21},' (',handles.unit,')'])
        end
    end
    
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    if strcmp(filter,'Taner-Hilbert')
        
        add_list_am = handles.add_list_am;
        ampmod = [data_filterout(:,1),data_filterout(:,3)];
        ifaze = [data_filterout(:,1),handles.ifaze];
        ifreq = [data_filterout(1:end-1,1),handles.ifreq];
        dlmwrite(add_list, data_filterout(:,1:2), 'delimiter', ' ', 'precision', 9);
        dlmwrite(add_list_am, ampmod, 'delimiter', ' ', 'precision', 9);
        dlmwrite(handles.add_list_ufaze,[data_filterout(:,1),data_filterout(:,4)], 'delimiter', ' ', 'precision', 9);        
        dlmwrite(handles.add_list_ifaze, ifaze, 'delimiter', ' ', 'precision', 9);
        dlmwrite(handles.add_list_ifreq, ifreq, 'delimiter', ' ', 'precision', 9);
        if handles.lang_choice == 0
            disp(['>>  Save as: ', handles.add_list_am])
            disp(['>>  Save as: ', handles.add_list_ufaze])
            disp(['>>  Save as: ', handles.add_list_ufazedet])
            disp(['>>  Save as: ', handles.add_list_ifaze])
            disp(['>>  Save as: ', handles.add_list_ifreq])
        else
            
            [~, main01] = ismember('main01',handles.lang_id);  % save data
            disp(['>>  ',lang_var{main01},': ', handles.add_list_am])
            disp(['>>  ',lang_var{main01},': ', handles.add_list_ufaze])
            disp(['>>  ',lang_var{main01},': ', handles.add_list_ufazedet])
            disp(['>>  ',lang_var{main01},': ', handles.add_list_ifaze])
            disp(['>>  ',lang_var{main01},': ', handles.add_list_ifreq])
        end
        plot(data_filterout(:,1),data_filterout(:,3),'b')
        % plot
        figure;
        t  = data_filterout(:,1);
        xx = data_filterout(:,2);
        subplot(4,1,1), plot(t,xx),
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            title('Modulated signal & Instantaneous amplitude'); 
        else
            [~, ft17] = ismember('ft17',handles.lang_id);
            title(lang_var{ft17});
        end
        hold on;
        subplot(4,1,1), plot(t,data_filterout(:,3)); hold off;
        xlim([min(data(:,1)),max(data(:,1))])
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        subplot(4,1,2), plot(t,data_filterout(:,4)),
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            title('Unrolled instantaneous phase')
        else
            [~, ft18] = ismember('ft18',handles.lang_id);
            title(lang_var{ft18})
        end
        xlim([min(data(:,1)),max(data(:,1))])
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        % remove the linear trend
        % using linear fit: works well for the filtered curve with
        % many (over 4-6) cycles
        sdat = polyfit(t,data_filterout(:,4),1);
        datalinear = (t-t(1)) * sdat(1);
        iphasedet = data_filterout(:,4) - datalinear;
        subplot(4,1,3), plot(t,iphasedet),
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            title('Instantaneous phase')
            ylabel('phase (radians)')
        else
            [~, ft19] = ismember('ft19',handles.lang_id);
            [~, ft20] = ismember('ft20',handles.lang_id);
            title(lang_var{ft19})
            ylabel(lang_var{ft20})
        end
        %subplot(4,1,3), plot(t,data_filterout(:,5)),title('Detrended instantaneous phase')
        xlim([min(data(:,1)),max(data(:,1))])
        
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        subplot(4,1,4), plot(t(1:(length(t)-1)),handles.ifreq),
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            title('Instantaneous frequency')
        else
            [~, ft21] = ismember('ft21',handles.lang_id);
            title(lang_var{ft21})
        end
        xlim([min(data(:,1)),max(data(:,1))])
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            if handles.unit_type == 0
                xlabel(['Unit (',handles.unit,')'])
            elseif handles.unit_type == 1
                xlabel(['Depth (',handles.unit,')'])
            else
                xlabel(['Time (',handles.unit,')'])
            end
        else
            [~, main34] = ismember('main34',handles.lang_id); % unit
            [~, main23] = ismember('main23',handles.lang_id);
            [~, main21] = ismember('main21',handles.lang_id);

            if handles.unit_type == 0
                xlabel([lang_var{main34},' (',handles.unit,')'])
            elseif handles.unit_type == 1
                xlabel([lang_var{main23},' (',handles.unit,')'])
            else
                xlabel([lang_var{main21},' (',handles.unit,')'])
            end
        end
    
        dlmwrite(handles.add_list_ufazedet, [t,iphasedet], 'delimiter', ' ', 'precision', 9);
        %dlmwrite(handles.add_list_ufazedet, [t,data_filterout(:,5)], 'delimiter', ' ', 'precision', 9);
    end
    cd(pre_dirML); % return to matlab view folder
    if handles.lang_choice == 0
        disp('>> Done. See AC main window for the filtered output file(s)')
    else
        [~, ft22] = ismember('ft22',handles.lang_id);
        disp(lang_var{ft22});
    end
    % refresh AC main window
    figure(handles.acfigmain);
    CDac_pwd; % cd working dir
    refreshcolor;
    cd(pre_dirML); % return view dir
    figure(figft);
    figure(figdata); % return plot
end