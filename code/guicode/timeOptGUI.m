function varargout = timeOptGUI(varargin)
% TIMEOPTGUI MATLAB code for timeOptGUI.fig
%      TIMEOPTGUI, by itself, creates a new TIMEOPTGUI or raises the existing
%      singleton*.
%
%      H = TIMEOPTGUI returns the handle to a new TIMEOPTGUI or the handle to
%      the existing singleton*.
%
%      TIMEOPTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIMEOPTGUI.M with the given input arguments.
%
%      TIMEOPTGUI('Property','Value',...) creates a new TIMEOPTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before timeOptGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to timeOptGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help timeOptGUI

% Last Modified by GUIDE v2.5 10-Jan-2019 18:07:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @timeOptGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @timeOptGUI_OutputFcn, ...
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


% --- Executes just before timeOptGUI is made visible.
function timeOptGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to timeOptGUI (see VARARGIN)

% Choose default command line output for timeOptGUI
handles.output = hObject;
%
handles.hmain = gcf;
%
handles.MonZoom = varargin{1}.MonZoom;

set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

set(handles.hmain,'position',[0.2,0.3,0.35,0.6]* handles.MonZoom) % set position

set(handles.text2,'position',[0.044,0.92,0.1,0.05])
set(handles.text3,'position',[0.16,0.92,0.6,0.05])
set(handles.checkbox2,'position',[0.77,0.92,0.159,0.05])

set(handles.panel_sedrate,'position',[0.05,0.71,0.9,0.194])
set(handles.radiobutton1,'position',[0.023,0.515,0.162,0.338])
set(handles.radiobutton2,'position',[0.023,0.147,0.132,0.338])
set(handles.text4,'position',[0.185,0.618,0.132,0.191])
set(handles.edit1,'position',[0.325,0.55,0.1,0.3])
set(handles.text5,'position',[0.439,0.618,0.14,0.191])
set(handles.edit2,'position',[0.596,0.55,0.1,0.3])
set(handles.text6,'position',[0.713,0.618,0.132,0.191])
set(handles.edit3,'position',[0.845,0.55,0.1,0.3])
set(handles.text7,'position',[0.185,0.13,0.764,0.3])

set(handles.uipanelfreq,'position',[0.05,0.185,0.9,0.527])
set(handles.radiobutton3,'position',[0.023,0.85,0.281,0.112])
set(handles.edit4,'position',[0.32,0.849,0.117,0.112])
set(handles.text8,'position',[0.44,0.84,0.1,0.112])

set(handles.radiobutton4,'position',[0.023,0.7,0.25,0.112])
set(handles.edit5,'position',[0.27,0.7,0.7,0.1])
set(handles.text10,'position',[0.07,0.58,0.283,0.07])
set(handles.edit6,'position',[0.27,0.566,0.7,0.1])

set(handles.radiobutton5,'position',[0.023,0.41,0.48,0.112])
set(handles.radiobutton6,'position',[0.51,0.41,0.48,0.112])
set(handles.text11,'position',[0.05,0.32,0.513,0.07])
set(handles.text12,'position',[0.07,0.2,0.1,0.07])
set(handles.text13,'position',[0.324,0.2,0.1,0.07])
set(handles.text14,'position',[0.58,0.2,0.1,0.07])
set(handles.edit7,'position',[0.171,0.19,0.12,0.09])
set(handles.edit8,'position',[0.43,0.19,0.12,0.09])
set(handles.edit9,'position',[0.7,0.19,0.28,0.09])

set(handles.text15,'position',[0.05,0.05,0.281,0.08])
set(handles.radiobutton7,'position',[0.37,0.05,0.24,0.08])
set(handles.radiobutton8,'position',[0.67,0.05,0.24,0.08])

set(handles.uipanelMC,'position',[0.05,0.06,0.5,0.124])
set(handles.checkbox1,'position',[0.07,0.18,0.595,0.59])
set(handles.edit10,'position',[0.7,0.18,0.25,0.564])
set(handles.pushbutton1,'position',[0.8,0.06,0.15,0.1])
set(handles.checkbox3,'position',[0.6,0.12,0.2,0.056])
set(handles.checkbox4,'position',[0.6,0.06,0.2,0.056])

set(handles.text16,'position',[0.05,0.01,0.9,0.04])
set(handles.text16,'FontSize',10);  % set as norm

set(gcf,'Name','Acycle: TimeOpt')
dat = varargin{1}.current_data;  % data
handles.unit = varargin{1}.unit; % unit
handles.unit_type = varargin{1}.unit_type; % unit type

handles.filename = varargin{1}.data_name; % save dataname
handles.dat_name = varargin{1}.dat_name; % save dataname
handles.unit = varargin{1}.unit; % save unit
handles.path_temp = varargin{1}.path_temp; % save path
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;

% check unit
if handles.unit_type == 0
    hwarn = warndlg('Unit is assumed to be m. If not, choose correct unit');
    dat(:,1) = dat(:,1)*100;
elseif handles.unit_type == 2
    hwarn = warndlg('Unit type is Time! Make sure the unit should be m');
else
    if strcmp(handles.unit,'m')
        dat(:,1) = dat(:,1)*100;
        %msgbox('Unit is m, now changes to cm','Unit transform')
    elseif strcmp(handles.unit,'dm')
        dat(:,1) = dat(:,1)*10;
        msgbox('Unit is dm, now changes to cm','Unit transform')
    elseif strcmp(handles.unit,'mm')
        dat(:,1) = dat(:,1)/10;
        msgbox('Unit is mm, now changes to cm','Unit transform')
    elseif strcmp(handles.unit,'km')
        dat(:,1) = dat(:,1)* 1000 * 100;
        msgbox('Unit is km, now changes to cm','Unit transform')
    elseif strcmp(handles.unit,'ft')
        dat(:,1) = dat(:,1)* 30.48;
        msgbox('Unit is ft, now changes to cm','Unit transform')
    end
end
%
set(handles.text3,'String',handles.dat_name)
set(handles.radiobutton1,'Value',1)
set(handles.radiobutton2,'Value',0)
set(handles.radiobutton3,'Value',1)
set(handles.edit4,'Enable','on')
set(handles.edit5,'Enable','off')
set(handles.edit6,'Enable','off')
set(handles.radiobutton4,'Value',0)
set(handles.radiobutton5,'Value',1)
set(handles.radiobutton6,'Value',0)
set(handles.radiobutton7,'Value',1)
set(handles.radiobutton8,'Value',0)
set(handles.checkbox1,'Value',0)
set(handles.checkbox2,'Value',1)
set(handles.checkbox3,'Value',0)
set(handles.checkbox4,'Value',0)
set(handles.edit10,'Enable','off')
%
datx = dat(:,1);  % unit should be cm
daty = dat(:,2);
diffx = diff(datx);
npts = length(datx);
% check data
if sum(diffx <= 0) > 0
    disp('>>  Waning: data has to be in ascending order, no duplicated number allowed')
    dat = sortrows(dat);
end
% check data
if abs((max(diffx)-min(diffx))/2) > eps('single');
    hwarn1 = warndlg('Data may not be evenly spaced!');
end
%
handles.dat = dat; % save data
% set default sedmin, sedmax
handles.sedmin = 0;
handles.sedmax = 100;
handles.numsed = 200;
handles.fl = 0.035;
handles.fh = 0.065;
handles.targetE = [405.6795,130.719,123.839,98.86307,94.87666];
handles.targetP = [23.62069,22.31868,19.06768,18.91979];

dt = median(diff(dat(:,1)));
fnyq = handles.sedmin/(2*dt);
if handles.fh > fnyq
    sedmin = 2 * dt * handles.fh;
    handles.sedmin = sedmin;
end
set(handles.edit1,'String',num2str(handles.sedmin))

fray = handles.sedmax/(npts * dt);
flow = 1/max(handles.targetE);
if fray > flow
    sedmax = npts * dt * flow;
    handles.sedmax = sedmax;
end
set(handles.edit2,'String',num2str(handles.sedmax))
%
sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
    ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
set(handles.text7,'String',sedinfo)
%
handles.npts = npts;
handles.dt = dt;
handles.nsim = 0;
handles.linLog = 2;
handles.fit = 1;
handles.roll = 10^12;
handles.detrend = 1;
handles.cormethod = 2;
%handles.genplot = 1; % multiple plots
handles.genplot = 2; % single plot with multi-panels
handles.saveplot = 0;
handles.savedata = 0;
handles.age = 0;
%
try figure(hwarn)
catch
end
try figure(hwarn1)
catch
end
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes timeOptGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sedmin = str2double(get(handles.edit1,'String'));
sedmax = str2double(get(handles.edit2,'String'));
numsed = str2double(get(handles.edit3,'String'));

fl = str2double(get(handles.edit7,'String'));
fh = str2double(get(handles.edit8,'String'));

targetE = strread(get(handles.edit5,'String'));
targetP = strread(get(handles.edit6,'String'));

dat= handles.dat;  
%sedmin = handles.sedmin;
%sedmax = handles.sedmax;
%numsed = handles.numsed;
nsim = handles.nsim;
if handles.nsim > 0
    nsim = str2double(get(handles.edit10,'String'));
    hwarn = msgbox('Monte Carlo simulations can be very slow, please wait','Wait');
end

linLog = handles.linLog; 
fit = handles.fit;
%fl = handles.fl; 
%fh = handles.fh;
roll = handles.roll;
%targetE = handles.targetE;
%targetP = handles.targetP;

detrend = handles.detrend;
cormethod = handles.cormethod;
genplot = handles.genplot;

[xx,datopt,xcl,sr_p]=...
    timeOptAc(dat,sedmin,sedmax,numsed,nsim,linLog,fit,fl,fh,roll,...
    targetE,targetP,detrend,cormethod,genplot);
try close(hwarn)
catch
end
if handles.savedata == 1
    
    log_name = [handles.dat_name,'-timeOpt-log','.txt'];
    name1 = [handles.dat_name,'-timeOpt-r^2env-pow-opt','.txt'];
    name2 = [handles.dat_name,'-timeOpt-opt-bp-env-model','.txt'];
    name3 = [handles.dat_name,'-timeOpt-H0-Sig.Level','.txt'];
    % Find max
    sedrate = xx(:,1);
    r2env = xx(:,2);
    maxr2env = max(r2env);
    locj = find(r2env == maxr2env);
    r2pwr = xx(:,3);
    maxr2pwr = max(r2pwr);
    locm = find(r2pwr == maxr2pwr);
    r2opt = xx(:,4);
    maxr2opt = max(r2opt);
    loci = find(r2opt == maxr2opt);

    CDac_pwd
    dlmwrite(name1, xx, 'delimiter', ',', 'precision', 9); 
    dlmwrite(name2, datopt, 'delimiter', ',', 'precision', 9);
    dlmwrite(name3, xcl, 'delimiter', ',', 'precision', 9); 

    [dat_dir,~,~] = fileparts(handles.filename);
    fileID = fopen(fullfile(dat_dir,log_name),'w+');
    fprintf(fileID,'%s\n',' - - - - - - - - - - - - - Summary - - - - - - - - - - -');
    fprintf(fileID,'%s\n',datestr(datetime('now')));
    fprintf(fileID,'%s\n',log_name);
    fprintf(fileID,'%s\n',['minimum tested sedimentation rate: ',num2str(sedmin)]);
    fprintf(fileID,'%s\n',['maximum tested sedimentation rate: ',num2str(sedmax)]);
    fprintf(fileID,'%s\n',['number of tested sedimentation rate: ',num2str(numsed)]);
    if linLog == 1
    fprintf(fileID,'%s\n',['Scaling for sedimentation rate grid spacing: Log']);
    elseif linLog == 2
    fprintf(fileID,'%s\n',['Scaling for sedimentation rate grid spacing: Linear']);
    end
    if fit == 1
    fprintf(fileID,'%s\n',['Test for (1) precession amplitude modulation']);
    elseif fit == 2
    fprintf(fileID,'%s\n',['Test for (2) short eccentricity amplitude modulation']);
    end
    fprintf(fileID,'%s\n',['Low frequency cut-off for Taner bandpass: ',num2str(fl)]);
    fprintf(fileID,'%s\n',['High frequency cut-off for Taner bandpass: ',num2str(fh)]);
    fprintf(fileID,'%s\n',['Taner filter roll-off rate, in dB/octave: ',num2str(roll)]);
    fprintf(fileID,'%s\n','A vector of eccentricity periods to evaluate (in kyr):');
    fprintf(fileID,'%s\n\n',mat2str(targetE));
    fprintf(fileID,'%s\n','A vector of precession periods to evaluate (in kyr):');
    fprintf(fileID,'%s\n\n',mat2str(targetP));
    if detrend ==1
    fprintf(fileID,'%s\n',['Remove linear trend from data series?: ','Yes']);
    else
    fprintf(fileID,'%s\n',['Remove linear trend from data series?: ','No']);
    end
    if cormethod == 2
    fprintf(fileID,'%s\n',['correlation method: ','Spearman']);
    else
    fprintf(fileID,'%s\n',['correlation method: ','Pearson']);
    end
    fprintf(fileID,'%s\n','RESULTS: ');
    
    % display
    fprintf(fileID,'%s\n',['Maximum envelope r^2 = ',num2str(maxr2env)]);
    fprintf(fileID,'%s\n',['    at sedimentation rate of: ',num2str(sedrate(locj(1))),' cm/kyr']);
    fprintf(fileID,'%s\n',['Maximum power    r^2 = ',num2str(maxr2pwr)]);
    fprintf(fileID,'%s\n',['    at sedimentation rate of: ',num2str(sedrate(locm(1))),' cm/kyr']);
    fprintf(fileID,'%s\n',['Maximum optimal  r^2 = ',num2str(maxr2opt)]);
    fprintf(fileID,'%s\n',['    at sedimentation rate of: ',num2str(sedrate(loci(1))),' cm/kyr']);
    if nsim>1
        [row, ~] = size(xcl);
        if row == 1
            fprintf(fileID,'%s\n','');
            fprintf(fileID,'%s\n',['Number of Monte Carlo simulations: ',num2str(nsim)]);
            fprintf(fileID,'%s\n',['At sedimentation rate of ',num2str(sedrate(loci(1))),' cm/kyr']);
            fprintf(fileID,'%s\n',['    Envelope r^2 p-value = ',num2str(xcl(2),'%.5f')]);
            fprintf(fileID,'%s\n',['    Power    r^2 p-value = ',num2str(xcl(3),'%.5f')]);
            fprintf(fileID,'%s\n',['    Optimal  r^2 p-value = ',num2str(xcl(4),'%.5f')]);
        end
    end
    fprintf(fileID,'%s\n','');
    fprintf(fileID,'%s\n',' - - - - - - - - - - - - - - End - - - - - - - - - - - -');
    fclose(fileID);
    
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
    disp(['>> saved data: ',name1])
    disp(['>> saved data: ',name2])
end
guidata(hObject,handles)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Outputs from this function are returned to the command line.
function varargout = timeOptGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
val = get(handles.radiobutton1,'Value');
if val == 1
    set(handles.radiobutton2, 'Value', 0);
    handles.linLog = 2;
    sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
else
    set (handles.radiobutton2, 'Value', 1);
    handles.linLog = 1;
    sedinc = (log10(handles.sedmax) - log10(handles.sedmin))/(handles.numsed-1);
    sr = zeros(1,handles.numsed);
    for ii = 1: handles.numsed
        sr(ii) = 10^(  log10(handles.sedmin)  +  (ii-1) * sedinc ) ;
    end
end
sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
    ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
set(handles.text7,'String',sedinfo)
guidata(hObject, handles);

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
val = get(handles.radiobutton2,'Value');
if val == 1
    set(handles.radiobutton1, 'Value', 0);
    handles.linLog = 1;
    sedinc = (log10(handles.sedmax) - log10(handles.sedmin))/(handles.numsed-1);
    sr = zeros(1,handles.numsed);
    for ii = 1: handles.numsed
        sr(ii) = 10^(  log10(handles.sedmin)  +  (ii-1) * sedinc ) ;
    end
else
    set (handles.radiobutton1, 'Value', 1);
    handles.linLog = 2;
    sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
end
sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
    ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
set(handles.text7,'String',sedinfo)
guidata(hObject, handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.sedmin = str2double(get(hObject,'String'));
fnyq = handles.sedmin/(2*handles.dt);
if handles.fh > fnyq
    sedmin = 2 * handles.dt * handles.fh;
    msgbox(['Minimum sed. rate may beyond the detection limit ', num2str(sedmin),' cm/kyr'],'Warning')
end
sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
    ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
set(handles.text7,'String',sedinfo)

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
handles.sedmax = str2double(get(hObject,'String'));
% warning
fray = handles.sedmax/(handles.npts * handles.dt);
flow = 1/max(handles.targetP);
if fray > handles.fl
    sedmax = handles.npts * handles.dt * flow;
    msgbox(['Maximum sed. rate may beyond the detection limit ', num2str(sedmax),' cm/kyr'],'Warning')
end
% display
sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
    ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
set(handles.text7,'String',sedinfo)

guidata(hObject,handles)

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
handles.numsed = str2double(get(hObject,'String'));
sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
if handles.numsed > 3
    sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
    ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
    set(handles.text7,'String',sedinfo)
elseif handles.numsed == 3
    sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
    set(handles.text7,'String',sedinfo)
elseif handles.numsed == 2
    sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),' cm/kyr'];
    set(handles.text7,'String',sedinfo)
else
    msgbox('Number should be no less than 2','Warning')
end

if handles.numsed > 500
    msgbox('Large number, may be very slow','Warning')
end
guidata(hObject,handles)

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


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
val = get(handles.radiobutton3,'Value');
if val == 1
    set(handles.radiobutton4, 'Value', 0);
    handles.EP = 2;
    set(handles.edit4, 'Enable', 'on');
    set(handles.edit5, 'Enable', 'off');
    set(handles.edit6, 'Enable', 'off');
else
    set (handles.radiobutton4, 'Value', 1);
    handles.EP = 1;
    set(handles.edit4, 'Enable', 'off');
    set(handles.edit5, 'Enable', 'on');
    set(handles.edit6, 'Enable', 'on');
end
guidata(hObject, handles);


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
t1 = str2double(get(handles.edit4,'String'));
if t1 < 0
    msgbox('Age cannot < 0 Ma','Error')
elseif t1 > 4500
    msgbox('Age cannot > 4500 Ma','Error')
end
if t1 > 249
    msgbox('Age > 249 Ma, beyond age limit of Laskar solutions','Reminder')
end
handles.age = t1;
t1= 1000 * t1; % Ma to ka
a = load('La04.mat');
a = a.data;
if t1<= 2500
    laecc = a(1:5000,2);
    lapre = a(1:5000,4);
elseif t1>= 249000-2500
    laecc = a(end-5000:end,2);
    lapre = a(end-5000:end,4);
else
    laecc = a(t1-2499:t1+2500,2);
    lapre = a(t1-2499:t1+2500,4);
end
[po1,fd1] = periodogram(laecc-mean(laecc),[],[],1);
po1=po1(fd1 > .002);
fd1=fd1(fd1 > .002);
[pks] = findpeaks(po1);
nn=5; tE =[];[~,val] = findnpk(pks,nn);
for i=1:nn; tE(i) = 1/fd1(po1 == val(i)); end
tE = sort(tE,'descend');
tEin = [num2str(tE(1),'% .4f'),' ',num2str(tE(2),'% .4f'),' ',...
    num2str(tE(3),'% .4f'),' ',num2str(tE(4),'% .4f'),' ',...
    num2str(tE(5),'% .4f')];
[po2,fd2] = periodogram(lapre,[],[],1);
[pks] = findpeaks(po2);
nn=4; tP =[];[~,val] = findnpk(pks,nn);
for i=1:nn; tP(i) = 1/fd2(po2 == val(i)); end
tP = sort(tP,'descend');
tPin = [num2str(tP(1),'% .4f'),' ',num2str(tP(2),'% .4f'),' ',...
    num2str(tP(3),'% .4f'),' ',num2str(tP(4),'% .4f')];
set(handles.edit5,'String',tEin)
set(handles.edit6,'String',tPin)
cP = 1/2 * (1/tP(1) + 1/tP(end));
cP0 = 1/2 * (1/23.6207 + 1/18.9198);
flP = 0.035/cP0*cP;
fhP = 0.065/cP0*cP;
cE = 1/2 * (1/tE(2) + 1/tE(end));
cE0 = 1/2 * (1/130.719 + 1/94.8767);
flE = 0.007/cE0*cE;
fhE = 0.0115/cE0*cE;

val = get(handles.radiobutton5,'Value');
if val == 1
    %fit precession
    handles.fl = flP;
    handles.fh = fhP;
else
    % fit short ecc
    handles.fl = flE;
    handles.fh = fhE;
end
set(handles.edit7,'String',num2str(handles.fl,'% .4f'))
set(handles.edit8,'String',num2str(handles.fh,'% .4f'))
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


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
val = get(handles.radiobutton4,'Value');
if val == 1
    set(handles.radiobutton3, 'Value', 0);
    handles.EP = 2;
    set(handles.edit4, 'Enable', 'off');
    set(handles.edit5, 'Enable', 'on');
    set(handles.edit6, 'Enable', 'on');
else
    set (handles.radiobutton3, 'Value', 1);
    handles.EP = 1;
    set(handles.edit4, 'Enable', 'on');
    set(handles.edit5, 'Enable', 'off');
    set(handles.edit6, 'Enable', 'off');
end
guidata(hObject, handles);


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


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


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
val = get(handles.radiobutton5,'Value');
if val == 1
    % fit precession
    set(handles.radiobutton6, 'Value', 0);
    handles.fit = 1;
    handles.fl = 0.035;
    handles.fh = 0.065;
    handles.roll = 10^12;
else
    % fit short eccentricity
    set (handles.radiobutton6, 'Value', 1);
    handles.fit = 2;
    handles.fl = 0.007;
    handles.fh = 0.0115;
    handles.roll = 10^12;
end
set(handles.edit7, 'String', num2str(handles.fl));
set(handles.edit8, 'String', num2str(handles.fh));
set(handles.edit9, 'String', num2str(handles.roll));
guidata(hObject, handles);

% --- Executes on button press in radiobutton5.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
val = get(handles.radiobutton6,'Value');
if val == 1
    set(handles.radiobutton5, 'Value', 0);
    handles.fit = 2;
    handles.fl = 0.007;
    handles.fh = 0.0115;
    handles.roll = 10^12;
else
    set (handles.radiobutton5, 'Value', 1);
    handles.fit = 1;
    handles.fl = 0.035;
    handles.fh = 0.065;
    handles.roll = 10^12;
end
set(handles.edit7, 'String', num2str(handles.fl));
set(handles.edit8, 'String', num2str(handles.fh));
set(handles.edit9, 'String', num2str(handles.roll));
guidata(hObject, handles);


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


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
val = str2num(get(handles.edit9,'String'));
handles.roll = val;
guidata(hObject, handles);

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


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7
val = get(handles.radiobutton7,'Value');
if val == 1
    set(handles.radiobutton8, 'Value', 0);
    handles.cormethod = 2;
else
    set (handles.radiobutton8, 'Value', 1);
    handles.cormethod = 1;
end
guidata(hObject, handles);

% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8
val = get(handles.radiobutton8,'Value');
if val == 1
    set(handles.radiobutton7, 'Value', 0);
    handles.cormethod = 1;
else
    set (handles.radiobutton7, 'Value', 1);
    handles.cormethod = 2;
end
guidata(hObject, handles);

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
val = get(handles.checkbox1,'Value');
if val == 1
    set(handles.edit10, 'Enable', 'on');
    handles.nsim = 2000;
else
    set(handles.edit10, 'Enable', 'off');
    handles.nsim = 0;
end
guidata(hObject, handles);


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


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


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
val = get(handles.checkbox1,'Value');
if val == 1
    handles.detrend = 1;
else
    handles.detrend = 0;
end
guidata(hObject, handles);


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
val = get(handles.checkbox3,'Value');
if val == 1
    handles.savedata = 1;
    %disp('will save data')
else
    handles.savedata = 0;
    %disp('will NOT save data')
end
guidata(hObject,handles)

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
val = get(handles.checkbox4,'Value');
if val == 1
    handles.saveplot = 1;
else
    handles.saveplot = 0;
end
guidata(hObject,handles)
