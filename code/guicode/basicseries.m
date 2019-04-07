function varargout = basicseries(varargin)
% BASICSERIES MATLAB code for basicseries.fig
%      BASICSERIES, by itself, creates a new BASICSERIES or raises the existing
%      singleton*.
%
%      H = BASICSERIES returns the handle to a new BASICSERIES or the handle to
%      the existing singleton*.
%
%      BASICSERIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICSERIES.M with the given input arguments.
%
%      BASICSERIES('Property','Value',...) creates a new BASICSERIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basicseries_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basicseries_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basicseries

% Last Modified by GUIDE v2.5 14-May-2017 01:31:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @basicseries_OpeningFcn, ...
                   'gui_OutputFcn',  @basicseries_OutputFcn, ...
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


% --- Executes just before basicseries is made visible.
function basicseries_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to basicseries (see VARARGIN)
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;

set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
set(gcf,'Name','Acycle: Astronomical Solutions')

h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

set(gcf,'position',[0.45,0.55,0.4,0.3]) % set position
set(handles.text2,'position', [0.064,0.84,0.2,0.06])
set(handles.text4,'position', [0.47,0.84,0.2,0.06])
set(handles.popupmenu1,'position', [0.043,0.67,0.3,0.1])
set(handles.text3,'position', [0.043,0.568,0.2,0.06])
set(handles.popupmenu3,'position', [0.043,0.407,0.3,0.1])

set(handles.text5,'position', [0.4,0.707,0.07,0.06])
set(handles.text6,'position', [0.4,0.619,0.07,0.06])
set(handles.text7,'position', [0.628,0.707,0.07,0.06])
set(handles.text9,'position', [0.628,0.619,0.07,0.06])
set(handles.edit1,'position', [0.48,0.69,0.13,0.09])
set(handles.edit2,'position', [0.48,0.585,0.13,0.09])
set(handles.pushbutton1,'position', [0.4,0.407,0.25,0.1])
set(handles.textref,'position', [0.064,0.013,0.915,0.35])

set(handles.uipanel_ETP,'position', [0.717,0.407,0.226,0.466])
set(handles.text13,'position', [0.043,0.735,0.5,0.133])
set(handles.text14,'position', [0.043,0.439,0.5,0.133])
set(handles.text15,'position', [0.043,0.143,0.5,0.133])

set(handles.edit3,'position', [0.6,0.735,0.3,0.222])
set(handles.edit4,'position', [0.6,0.439,0.3,0.222])
set(handles.edit5,'position', [0.6,0.143,0.3,0.222])

% Choose default command line output for basicseries
handles.output = hObject;

% existdata = evalin('base','who');
% 
% if ismember('filename',existdata)
%     handles.filename = evalin('base','filename');
% else
%     handles.filename = 'filename';
% end
% 
% if ismember('path_temp',existdata)
%     handles.path_temp = evalin('base','path_temp');
% else
%     temp_dir = what('temp');
%     handles.path_temp = temp_dir.path;
% end
% handles.working_folder = [handles.path_temp,'/',handles.filename];

%
handles.solution = 'La2004';
handles.parameter = 'ETP';
handles.t1 = 1;
handles.t2 = 1000;
handles.notela04 = ['Laskar, J., Robutel, P., Joutel, F., Gastineau, M.,',...
    ' Correia, A.C.M., Levrard, B., 2004. A long-term numerical solution',...
    ' for the insolation quantities of the Earth. Astronomy & Astrophysics',...
    ' 428, 261-285.'];
handles.notela10 = ['Laskar, J., Fienga, A., Gastineau, M., Manche, H., 2011.',...
    ' La2010: a new orbital solution for the long-term motion of the Earth.',...
    ' Astronomy & Astrophysics 532. doi: 10.1051/0004-6361/201116836'];
handles.notewu13 = ['Wu, H., Zhang, S., Jiang, G., Hinnov, L., Yang, T., Li, H.',...
    ', Wan, X., Wang, C., 2013. Astrochronology of the Early Turonian?Early',...
    'Campanian terrestrial succession in the Songliao Basin, northeastern ',...
    'China and its implication for long-period behavior of the Solar System.'...
    ' Palaeogeography, Palaeoclimatology, Palaeoecology 385, 55-70.'];
handles.noteZB17 = ['Zeebe, R.E., 2017. Numerical Solutions for the ',...
    'orbital motion of the Solar System over the Past 100 Myr: ',...
    'Limits and new results. The Astronomical Journal 154:193'];
set(handles.textref,'String',char(handles.notela04),'Value',1)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes basicseries wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = basicseries_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String'));
solution = contents{get(hObject,'Value')};
parameters_list0 = {''};
parameters_list1 = {'ETP';'Eccentricity';'Obliquity';'Precession'};
parameters_list2 = {'Eccentricity';'Inclination'};
handles.solution = solution;

if strcmp(solution,'')
    handles.basicseries = [];
    ref = 0;
elseif strcmp(solution,'La2004')
    basicseries = load('La04.mat');
    basicseries=basicseries.data;
    handles.basicseries = basicseries;
    ref = 1;
elseif strcmp(solution,'La2010a')
    basicseries = load('La10a.mat');
    handles.basicseries=basicseries.data;
    ref = 2;
elseif strcmp(solution,'La2010b')
    basicseries = load('La10b.mat');
    handles.basicseries=basicseries.data;
    ref = 2;
elseif strcmp(solution,'La2010c')
    basicseries = load('La10c.mat');
    handles.basicseries=basicseries.data;
    ref = 2;
elseif strcmp(solution,'La2010d')
    basicseries = load('La10d.mat');
    handles.basicseries=basicseries.data;
    ref = 2;
elseif strcmp(solution, 'ZB17a')
    handles.basicseries = load('ZB17a.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17b')
    handles.basicseries = load('ZB17b.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17c')
    handles.basicseries = load('ZB17c.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17d')
    handles.basicseries = load('ZB17d.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17e')
    handles.basicseries = load('ZB17e.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17f')
    handles.basicseries = load('ZB17f.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17h')
    handles.basicseries = load('ZB17h.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17i')
    handles.basicseries = load('ZB17i.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17j')
    handles.basicseries = load('ZB17j.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17k')
    handles.basicseries = load('ZB17k.dat');
    ref = 3;
elseif strcmp(solution, 'ZB17p')
    handles.basicseries = load('ZB17p.dat');
    ref = 3;
end

if ref == 1
    set(handles.textref,'String',char(handles.notela04),'Value',1)
    set(handles.popupmenu3,'String',parameters_list1,'Value',1);
elseif ref == 2
    textref = ['1.',handles.notela10,'; 2.',handles.notewu13];
    set(handles.textref,'String',textref,'Value',1)
    set(handles.popupmenu3,'String',parameters_list1,'Value',1);
elseif ref == 3
    handles.parameter = 'Eccentricity';
    set(handles.textref,'String',char(handles.noteZB17),'Value',1)
    set(handles.popupmenu3,'String',parameters_list2,'Value',1);
elseif ref == 0
    set(handles.popupmenu3,'String',parameters_list0,'Value',1);
    set(handles.textref,'String','','Value',1)
end
handles.ref = ref;
guidata(hObject, handles);

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



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.t1 = str2double(get(hObject,'String'));
if (handles.t1 < 0 || handles.t1>249000)
    tips = 'Must be a number between 0 and 249000';
    helpdlg(tips,'Tips')
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


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.t2 = str2double(get(hObject,'String'));
if (handles.t2 < 0 || handles.t2 > 249000)
    tips = 'Must be a number larger than t1 and between 0 and 249000';
    helpdlg(tips,'Tips')
end
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


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
% handles.parameter = 'ETP';
contents = cellstr(get(hObject,'String'));
handles.parameter = contents{get(hObject,'Value')};

if strcmp(handles.parameter,'ETP')
    set(handles.uipanel_ETP,'Visible','on')
else
    set(handles.uipanel_ETP,'Visible','off')
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
t1=min(handles.t1,handles.t2);
t2=max(handles.t1,handles.t2);
parameter=handles.parameter;
dat = handles.basicseries;
ref = handles.ref;
% Error msg
if t1 < 0
    error('Error: t1 must be no less than 0')
    return;
end
if t2 <= t1
    error('Error: t2 must be larger than t1')
    return;
end
if ref == 3 && t2 > 1.0e+05
    error('Error: t2 must be less than 100,000')
    return;
end
if (ref == 1 || ref == 2) && t2 >= 249000
    error('Error: t2 must be less than 249,000')
    return;
end

data = select_interval(dat,t1,t2);
%data = dat(t1:t2,:);
clear dat
if strcmp(parameter,'ETP')
    % get weight
    wE = str2double(get(handles.edit3,'String'));
    wT = str2double(get(handles.edit4,'String'));
    wP = str2double(get(handles.edit5,'String'));
    %data(:,5)=zscore(data(:,2))+.75*zscore(data(:,3))-zscore(data(:,4));
    %data(:,5)=zscore(data(:,2))+.4*zscore(data(:,3))-.5*zscore(data(:,4));
    data(:,5)=wE * zscore(data(:,2))+ wT * zscore(data(:,3)) + wP * zscore(data(:,4));
    dat(:,1)=data(:,1);
    dat(:,2)=data(:,5);
    if wE ~= 1 || wT~= 1 || wP ~= 1
        parameter = [get(handles.edit3,'String'),'E',get(handles.edit4,'String'),'T',get(handles.edit5,'String'),'P'];
    end
elseif strcmp(parameter,'Eccentricity')
    dat=[data(:,1),data(:,2)];
elseif strcmp(parameter,'Obliquity')
    dat=[data(:,1),data(:,3)];
elseif strcmp(parameter,'Precession')
    dat=[data(:,1),data(:,4)];
elseif strcmp(parameter,'Inclination')
    dat=[data(:,1),data(:,3)];
end

name = [handles.solution,'-',parameter,'-',num2str(t1),'-',num2str(t2),'.txt'];
%csvwrite(name,dat)
CDac_pwd; % cd ac_pwd dir
dlmwrite(name, dat, 'delimiter', ',', 'precision', 9);
cd(pre_dirML); % return to matlab view folder
% close
figdata = figure; 
plot(dat(:,1),dat(:,2));
set(gca,'XMinorTick','on','YMinorTick','on')
xlim([min(dat(:,1)),max(dat(:,1))]);
xlabel('Time (kyr)')
title(name)
% refresh AC main window
figure(handles.acfigmain);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir
figure(figdata); % return plot
