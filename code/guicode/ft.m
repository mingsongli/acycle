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

if ismac
    set(gcf,'position',[0.4,0.5,0.55,0.4]) % set position
elseif ispc
    set(gcf,'position',[0.4,0.5,0.65,0.58]) % set position
    set(h1,'FontUnits','points','FontSize',11);  % set as norm
    set(h2,'FontUnits','points','FontSize',11);  % set as norm
end
set(handles.text10,'position',[0.413,0.903,0.12,0.05])
set(handles.text12,'position',[0.531,0.903,0.415,0.05])
set(handles.ft_axes3,'position',[0.411,0.523,0.546,0.364])
set(handles.ft_axes4,'position',[0.411,0.084,0.546,0.367])
set(handles.ft_uipanel2,'position',[0.022,0.51,0.18,0.438])
set(handles.uipanel6,'position',[0.205,0.51,0.149,0.438])
set(handles.uibuttongroup2,'position',[0.022,0.084,0.18,0.425])
set(handles.pushbutton26,'position',[0.236,0.156,0.093,0.256])

set(handles.text1,'position',[0.054,0.8,0.415,0.122])
set(handles.text2,'position',[0.054,0.591,0.415,0.122])
set(handles.text3,'position',[0.054,0.417,0.415,0.122])
set(handles.popupmenu4,'position',[0.061,0.053,0.83,0.256])
set(handles.filt_fmin_edit1,'position',[0.503,0.791,0.395,0.159])
set(handles.filt_fmid_edit2,'position',[0.503,0.574,0.395,0.159])
set(handles.filt_fmax_edit3,'position',[0.503,0.391,0.395,0.159])

set(handles.text16,'position',[0.074,0.754,0.27,0.094])
set(handles.text15,'position',[0.074,0.58,0.27,0.094])
set(handles.text18,'position',[0.074,0.4,0.27,0.094])
set(handles.text17,'position',[0.074,0.22,0.27,0.094])

set(handles.edit11,'position',[0.369,0.717,0.574,0.159])
set(handles.edit10,'position',[0.369,0.536,0.574,0.159])
set(handles.edit13,'position',[0.369,0.362,0.574,0.159])
set(handles.edit12,'position',[0.369,0.181,0.574,0.159])

set(handles.radiobutton6,'position',[0.049,0.759,0.634,0.205])
set(handles.radiobutton7,'position',[0.049,0.562,0.634,0.205])
set(handles.radiobutton8,'position',[0.049,0.366,0.634,0.205])

set(handles.edit16,'position',[0.626,0.768,0.35,0.159])
set(handles.edit17,'position',[0.626,0.554,0.35,0.159])
set(handles.popupmenu5,'position',[0.024,0.054,0.976,0.259])

handles.output = hObject;
set(gcf,'Name','Acycle: Filtering')
% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
data_s = varargin{1}.current_data;
handles.current_data = data_s;
handles.data_name = varargin{1}.data_name;
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
[~,handles.dat_name,handles.ext] = fileparts(handles.data_name);
xmin = min(data_s(:,1));
xmax = max(data_s(:,1));
npts = length(data_s(:,1));
set(handles.text12, 'String', handles.dat_name); % f max

handles.index_selected = 0;
handles.cycle = 41;
% Choose default command line output for ft
% Update handles structure
handles.step = data_s(2,1)-data_s(1,1);
sample_rate = mean(diff(data_s(:,1)));
datax = data_s(:,1);
[po2,w2] = pmtm(data_s(:,2),2,5*length(datax));
fd2 = w2/(2*pi*handles.step);
[po,fd1] = periodogram(data_s(:,2),[],5*length(datax),1/sample_rate);
handles.curvepmtm = [fd1,po];   % 
    %
handles.x_1 = 0;
handles.x_2 = max(fd1);
handles.y_1 = 0;
handles.y_2 = max(po);
set(handles.edit10,'String',num2str(handles.x_1))
set(handles.edit12,'String',num2str(handles.y_1))
set(handles.edit11,'String',num2str(0.5*handles.x_2))
set(handles.edit13,'String',num2str(handles.y_2))

% PLOT: linear | MTM  in axes 3
axes(handles.ft_axes3);
plot(fd1,po);   % plot power spectrum of data
xlim([0 0.5*max(fd1)])
% PLOT: log | MTM  in axes 4
axes(handles.ft_axes4);
% semilogy(fd2,po2);
plot(fd2,po2);
xlim([0 0.5*max(fd2)])
xlabel(['Cycles/' handles.unit])
% Set frequency which has (the 1st) maximum power as default frequencies
fd1index = find(po == max(po), 1, 'first');
fq_deft = fd1(fd1index);   % find f with max power
handles.fd1index = fd1index;
handles.filt_fmid = fq_deft;
handles.filt_fmin = fq_deft * 0.8;
set(handles.filt_fmid_edit2, 'String', num2str(fq_deft)); % f center
set(handles.filt_fmin_edit1, 'String', num2str((0.8*fq_deft))); % f min
set(handles.filt_fmax_edit3, 'String', num2str(1.2*fq_deft)); % f max
% plot cutoff frequencies in axes of power spectrum
axes(handles.ft_axes3);
hold on      
gauss_mf = max(po)*gaussmf(fd1,[0.2*fq_deft fq_deft]);
plot(fd1,gauss_mf,'r-')
hold off
handles.add_list = '';
guidata(hObject,handles)


% --- Outputs from this function are returned to the command line.
function varargout = ft_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function filt_fmin_edit1_Callback(hObject, eventdata, handles)
% hObject    handle to filt_fmin_edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filt_fmin_edit1 as text
%        str2double(get(hObject,'String')) returns contents of filt_fmin_edit1 as a double
%%
handles.filt_fmin = str2double(get(hObject,'String'));
curvepmtm = handles.curvepmtm;
pomax = max(curvepmtm(:,2));
fwidth = abs(handles.filt_fmid - handles.filt_fmin);
gauss_mf = pomax*gaussmf(curvepmtm(:,1),[fwidth handles.filt_fmid]);
      
axes(handles.ft_axes3);
plot(curvepmtm(:,1),curvepmtm(:,2))
hold on
plot(curvepmtm(:,1),gauss_mf,'r-')
axis([handles.x_1 handles.x_2 handles.y_1 handles.y_2])
hold off

set(handles.filt_fmax_edit3,'String',num2str(fwidth+handles.filt_fmid))
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function filt_fmin_edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filt_fmin_edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function filt_fmid_edit2_Callback(hObject, eventdata, handles)
% hObject    handle to filt_fmid_edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filt_fmid_edit2 as text
%        str2double(get(hObject,'String')) returns contents of filt_fmid_edit2 as a double
%%
handles.filt_fmid = str2double(get(hObject,'String'));
curvepmtm = handles.curvepmtm;
pomax = max(curvepmtm(:,2));
fwidth = abs(handles.filt_fmid - handles.filt_fmin);
gauss_mf = pomax*gaussmf(curvepmtm(:,1),[fwidth handles.filt_fmid]);
      
axes(handles.ft_axes3);
plot(curvepmtm(:,1),curvepmtm(:,2))
hold on
plot(curvepmtm(:,1),gauss_mf,'r-')
axis([handles.x_1 handles.x_2 handles.y_1 handles.y_2])
hold off
set(handles.filt_fmax_edit3,'String',num2str(fwidth+handles.filt_fmid))
guidata(hObject, handles);
%%

% --- Executes during object creation, after setting all properties.
function filt_fmid_edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filt_fmid_edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function filt_fmax_edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filt_fmax_edit3 (see GCBO)
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
function logo_axes5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logo_axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate logo_axes5


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
data = handles.current_data;
datax=data(:,2);
time = data(:,1);
npts = length(time);
dt=mean(diff(time));
nyquist = 1/(2*dt);
rayleigh = 1/(dt*npts);

f1 = str2double(get(handles.filt_fmin_edit1,'string'));
f2 = str2double(get(handles.filt_fmid_edit2,'string'));
f3 = str2double(get(handles.filt_fmax_edit3,'string'));
flch = [f1 f2 f3];
flch = sort(flch);
handles.flch = flch;
handles.ftmin = flch(1);
handles.ftmid = flch(2);
handles.ftmax = flch(3);
flow = flch(1)/nyquist; % lowpass
fcenter = flch(2)/nyquist;
fhigh = flch(3)/nyquist; % highpass
fweight = (fcenter - flow)* 1.05;  % 20% extension
stopband1 = fcenter - fweight;
% stopband1 = flow - 2*rayleigh;
if stopband1 < 0;
    stopband1 = rayleigh;
end
% stopband2 = fhigh + 2*rayleigh;
stopband2 = fcenter + fweight;

if strcmp(filter,'Butter')
    d = designfilt('bandpassiir', ...
        'FilterOrder',6, ...
    'HalfPowerFrequency1',flow,...
    'HalfPowerFrequency2',fhigh,...
    'DesignMethod','butter');
    yb = filtfilt(d,datax);  % filtfilt is okay. but it may not be included in some version of Matlab
    data_filterout = [time,yb];
    add_list = [handles.dat_name,'-butter-',num2str(flch(1)),'-',num2str(flch(3)),'.txt'];
elseif strcmp(filter,'Cheby1')
    d = designfilt('bandpassiir', ...
        'FilterOrder',6, ...
    'PassbandFrequency1',flow,...
    'PassbandFrequency2',fhigh,...
    'PassbandRipple',1,...
    'DesignMethod','cheby1');
    yb = filtfilt(d,datax);
    data_filterout = [time,yb];
    add_list = [handles.dat_name,'-cheby1-',num2str(flch(1)),'-',num2str(flch(3)),'.txt'];
elseif strcmp(filter,'Ellip')
    d = designfilt('bandpassiir', ...
        'FilterOrder',6, ...
    'PassbandFrequency1',flow,...
    'PassbandFrequency2',fhigh,...
    'StopbandAttenuation1',20,...
    'PassbandRipple',1,...
    'StopbandAttenuation2',20,...
    'DesignMethod','ellip');
    yb = filtfilt(d,datax);
    data_filterout = [time,yb];
    add_list = [handles.dat_name,'-ellip-',num2str(flch(1)),'-',num2str(flch(3)),'.txt'];
elseif strcmp(filter,'Gaussian')
    [gaussbandx,filter,f]=gaussfilter(datax,dt,flch(2),flch(1),flch(3));
    data_filterout = [time,gaussbandx];
    add_list = [handles.dat_name,'-gaus-',num2str(flch(2)),'+-',num2str(abs(flch(2)-flch(3))),'.txt'];
elseif strcmp(filter,'Taner-Hilbert')
    % TANER-Hilbert Transformation
    [tanhilb,handles.ifaze,handles.ifreq] = ...
    tanerhilbertML(data,flch(2),flch(1),flch(3));
    handles.filterdd = tanhilb;
    add_list = [handles.dat_name,'-Tan-',num2str(flch(2)),'+-',num2str(abs(flch(2)-flch(3))),'.txt'];
    add_list_am = [handles.dat_name,'-Tan-',num2str(flch(2)),'+-',num2str(abs(flch(2)-flch(3))),'-AM.txt'];
    add_list_ufaze = [handles.dat_name,'-Tan-',num2str(flch(2)),'+-',num2str(abs(flch(2)-flch(3))),'-ufaze.txt'];
    add_list_ufazedet = [handles.dat_name,'-Tan-',num2str(flch(2)),'+-',num2str(abs(flch(2)-flch(3))),'-ufazedet.txt'];
    add_list_ifaze = [handles.dat_name,'-Tan-',num2str(flch(2)),'+-',num2str(abs(flch(2)-flch(3))),'-ifaze.txt'];
    add_list_ifreq = [handles.dat_name,'-Tan-',num2str(flch(2)),'+-',num2str(abs(flch(2)-flch(3))),'-ifreq.txt'];
    data_filterout = tanhilb;
    handles.add_list_am = add_list_am;
    handles.add_list_ufaze = add_list_ufaze;
    handles.add_list_ufazedet = add_list_ufazedet;
    handles.add_list_ifaze = add_list_ifaze;
    handles.add_list_ifreq = add_list_ifreq;
else
    add_list = '';
    data_filterout = '';
end

handles.add_list = add_list;

handles.data_filterout = data_filterout;
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
handles.x_1 = str2double(get(hObject,'String'));

axes(handles.ft_axes3);
xlim([handles.x_1 handles.x_2]);
axes(handles.ft_axes4);
xlim([handles.x_1 handles.x_2]);

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
handles.x_2 = str2double(get(hObject,'String'));

axes(handles.ft_axes3);
xlim([handles.x_1 handles.x_2]);
axes(handles.ft_axes4);
xlim([handles.x_1 handles.x_2]);
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
handles.y_1 = str2double(get(hObject,'String'));
axes(handles.ft_axes3);
ylim([handles.y_1 handles.y_2]);
axes(handles.ft_axes4);
ylim([handles.y_1 handles.y_2]);
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
handles.y_2 = str2double(get(hObject,'String'));
axes(handles.ft_axes3);
ylim([handles.y_1 handles.y_2]);
% axes(handles.ft_axes4);
% ylim([handles.y_1 handles.y_2]);
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


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4

contents = cellstr(get(handles.listbox1,'String')); % read contents of listbox 1
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
axes(handles.ft_axes1);
if nplot == 1
    plot_filter = contents(plot_selected);
    plot_filter_s = char(plot_filter);
    data_filterout = load(plot_filter_s);
    plot(data_filterout(:,1),data_filterout(:,2)); hold on;
    [datapks,~] = getpks(data_filterout);
    scatter(datapks(:,1),datapks(:,2),'filled','r','o','sizedata', 10);
    handles.datapks = datapks;
axis([min(data_filterout(:,1)) max(data_filterout(:,1)) min(data_filterout(:,2)) max(data_filterout(:,2))])
    d = dir; %get files
    set(handles.listbox1,'String',{d.name},'Value',1) %set string
end
hold off
%%
guidata(hObject, handles);


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5

contents = cellstr(get(handles.listbox1,'String')); % read contents of listbox 1
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
axes(handles.ft_axes1);

if nplot == 1
    plot_filter = contents(plot_selected);
    plot_filter_s = char(plot_filter);
    data_filterout = load(plot_filter_s);
    data_filterout(:,2) = -1*data_filterout(:,2);
    [datapks,~] = getpks(data_filterout);
    scatter(datapks(:,1),-1*datapks(:,2),'filled','r','d','sizedata', 8);hold on;
    plot(data_filterout(:,1),-1*data_filterout(:,2));
    handles.datapks = datapks;
    d = dir; %get files
    set(handles.listbox1,'String',{d.name},'Value',1) %set string
    axis([min(data_filterout(:,1)) max(data_filterout(:,1)) min(data_filterout(:,2)) max(data_filterout(:,2))])
    hold off
end
guidata(hObject, handles);



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
contents = cellstr(get(hObject,'String'));
filter = contents{get(hObject,'Value')};
handles.filter = filter;
data = handles.current_data;
datax=data(:,2);
time = data(:,1);
dt=time(2)-time(1);
nyquist = 1/(2*dt);
rayleigh = 1/(length(time)*dt);
%read pass type
if (get(handles.radiobutton6,'Value'))
    type = 'highpassiir';
    f11 = str2double(get(handles.edit16,'string'));
    f1 = f11/nyquist;
end
if (get(handles.radiobutton7,'Value'))
    type = 'lowpassiir';
    f11 = str2double(get(handles.edit16,'string'));
    f1 = f11/nyquist;
end
if (get(handles.radiobutton8,'Value'))
    type = 'bandstopiir';
    fhigh1 = str2double(get(handles.edit16,'string'));
    flow1 = str2double(get(handles.edit17,'string'));
    flow = min(flow1,fhigh1)/nyquist; % lowpass
    fhigh = max(flow1,fhigh1)/nyquist; % highpass
    passband1 = flow + 2*rayleigh/nyquist;
    passband2 = fhigh - 2*rayleigh/nyquist;
    f1 = [flow fhigh];
end

handles.filename = handles.dat_name;

if sum(strcmp(type, {'highpassiir', 'lowpassiir'})) > 0
    if strcmp(filter,'Butter')
        d = designfilt(type, ...
        'FilterOrder',6, ...
        'HalfPowerFrequency',f1,...
        'DesignMethod','butter');
        add_list = [handles.filename,type,'butter-',num2str(f11),'.txt'];
    elseif strcmp(filter,'Cheby1')
        d = designfilt(type, ...
        'FilterOrder',6, ...
        'PassbandFrequency',f1,...
        'PassbandRipple',1,...
        'DesignMethod','cheby1');
        add_list = [handles.filename,type,'cheby1-',num2str(f11),'.txt'];
    elseif strcmp(filter,'Ellip')
        d = designfilt(type, ...
        'FilterOrder',6, ...
        'PassbandFrequency',f1,...
        'PassbandRipple',1,...
        'StopbandAttenuation',20,...
        'DesignMethod','ellip');
        add_list = [handles.filename,type,'ellip-',num2str(f11),'.txt'];
    end
else
    if strcmp(filter,'Butter')
        d = designfilt(type, ...
        'FilterOrder',6, ...
        'HalfPowerFrequency1',flow,...
        'HalfPowerFrequency2',fhigh,...
        'DesignMethod','butter');
        add_list = [handles.filename,type,'butter-',num2str(flow1*nyquist),'-',num2str(fhigh1*nyquist),'.txt'];
    elseif strcmp(filter,'Cheby1')
        d = designfilt(type, ...
        'PassbandFrequency1',flow,...
        'StopbandFrequency1',passband1,...
        'StopbandFrequency2',passband2,...
        'PassbandFrequency2',fhigh,...
        'PassbandRipple1',1,...
        'PassbandRipple2',1,...
        'StopbandAttenuation',20,...
        'DesignMethod','cheby1',...
        'MatchExactly','both');
        add_list = [handles.filename,type,'cheby1-',num2str(flow1*nyquist),'-',num2str(fhigh1*nyquist),'.txt'];
    elseif strcmp(filter,'Ellip')
        d = designfilt(type, ...
        'PassbandFrequency1',flow,...
        'StopbandFrequency1',passband1,...
        'StopbandFrequency2',passband2,...
        'PassbandFrequency2',fhigh,...
        'PassbandRipple1',1,...
        'PassbandRipple2',1,...
        'StopbandAttenuation',20,...
        'DesignMethod','ellip',...
        'MatchExactly','both');
        add_list = [handles.filename,type,'ellip-',num2str(flow1*nyquist),'-',num2str(fhigh1*nyquist),'.txt'];
    else
        add_list = '';
    end

end

yb = filtfilt(d,datax);  % filtfilt is okay. but it may not be included in some version of Matlab
data_filterout = [time,yb];
handles.add_list = add_list;
handles.data_filterout = data_filterout;
%disp(' Ready to save')
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


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7
if get(hObject,'Value')
    set(handles.edit17,'Visible','Off');
end


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
if get(hObject,'Value')
    set(handles.edit17,'Visible','Off');
end

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
if isempty(add_list)
    errordlg('Select filtering method')
else
    figft = gcf;
    data_filterout = handles.data_filterout;
    filter = handles.filter;
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(add_list, data_filterout, 'delimiter', ',', 'precision', 9);
    figdata = figure;
    data = handles.current_data;
    plot(data(:,1),data(:,2),'k');hold on
    plot(data_filterout(:,1),data_filterout(:,2),'r')
    xlim([min(data(:,1)),max(data(:,1))])
    title(add_list)
    if handles.unit_type == 0;
        xlabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1;
        xlabel(['Depth (',handles.unit,')'])
    else
        xlabel(['Time (',handles.unit,')'])
    end
    if strcmp(filter,'Taner-Hilbert')
        add_list_am = handles.add_list_am;
        ampmod = [data_filterout(:,1),data_filterout(:,3)];
        ifaze = [data_filterout(:,1),handles.ifaze];
        ifreq = [data_filterout(1:end-1,1),handles.ifreq];
        dlmwrite(add_list, data_filterout(:,1:2), 'delimiter', ',', 'precision', 9);
        dlmwrite(add_list_am, ampmod, 'delimiter', ',', 'precision', 9);
        dlmwrite(handles.add_list_ufaze,[data_filterout(:,1),data_filterout(:,4)], 'delimiter', ',', 'precision', 9);
        dlmwrite(handles.add_list_ufazedet, [data_filterout(:,1),data_filterout(:,5)], 'delimiter', ',', 'precision', 9);
        dlmwrite(handles.add_list_ifaze, ifaze, 'delimiter', ',', 'precision', 9);
        dlmwrite(handles.add_list_ifreq, ifreq, 'delimiter', ',', 'precision', 9);
        disp(['>>  Save as: ', handles.add_list_am])
        disp(['>>  Save as: ', handles.add_list_ufaze])
        disp(['>>  Save as: ', handles.add_list_ufazedet])
        disp(['>>  Save as: ', handles.add_list_ifaze])
        disp(['>>  Save as: ', handles.add_list_ifreq])
        plot(data_filterout(:,1),data_filterout(:,3),'b')
    end
    cd(pre_dirML); % return to matlab view folder
    
    disp('>> Done. See AC main window for the filtered output file(s)')
    % refresh AC main window
    figure(handles.acfigmain);
    CDac_pwd; % cd working dir
    refreshcolor;
    cd(pre_dirML); % return view dir
    figure(figft);
    figure(figdata); % return plot
end