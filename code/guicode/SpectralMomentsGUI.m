function varargout = SpectralMomentsGUI(varargin)
% SPECTRALMOMENTSGUI MATLAB code for SpectralMomentsGUI.fig
%      SPECTRALMOMENTSGUI, by itself, creates a new SPECTRALMOMENTSGUI or raises the existing
%      singleton*.
%
%      H = SPECTRALMOMENTSGUI returns the handle to a new SPECTRALMOMENTSGUI or the handle to
%      the existing singleton*.
%
%      SPECTRALMOMENTSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTRALMOMENTSGUI.M with the given input arguments.
%
%      SPECTRALMOMENTSGUI('Property','Value',...) creates a new SPECTRALMOMENTSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpectralMomentsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpectralMomentsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpectralMomentsGUI

% Last Modified by GUIDE v2.5 28-Aug-2019 15:30:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpectralMomentsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SpectralMomentsGUI_OutputFcn, ...
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


% --- Executes just before SpectralMomentsGUI is made visible.
function SpectralMomentsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpectralMomentsGUI (see VARARGIN)

% Choose default command line output for SpectralMomentsGUI
handles.output = hObject;

%
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
if ismac
    fontsizeall = 12;
elseif ispc
    fontsizeall = 8.0;
end

h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',fontsizeall);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',fontsizeall);  % set as norm

set(handles.uipanel1,'position',[0.04,0.664,0.918,0.327]) % data
set(handles.text2,'position',[0.04,0.614,0.94,0.246]) % ref
set(handles.checkbox1,'position',[0.04,0.105,0.332,0.456]) % ref
set(handles.popupmenu1,'position',[0.4,0.123,0.284,0.456]) % ref

set(handles.uipanel2,'position',[0.396,0.227,0.4,0.382]) % sed. rate
set(handles.text3,'position',[0.127,0.716,0.424,0.159]) % ref
set(handles.text6,'position',[0.127,0.432,0.424,0.159]) % ref
set(handles.text7,'position',[0.127,0.136,0.424,0.159]) % ref
set(handles.edit2,'position',[0.627,0.7,0.323,0.25]) % ref
set(handles.edit3,'position',[0.627,0.4,0.323,0.25]) % ref
set(handles.edit4,'position',[0.627,0.1,0.323,0.25]) % ref

set(handles.checkbox2,'position',[0.4,0.55,0.34,0.105]) % ref

set(handles.uipanel3,'position',[0.04,0.227,0.322,0.459]) % settings window
set(handles.text8,'position',[0.01,0.69,0.513,0.197]) % ref
set(handles.text9,'position',[0.01,0.24,0.513,0.197]) % ref
set(handles.edit5,'position',[0.538,0.676,0.26,0.31]) % ref
set(handles.popupmenu2,'position',[0.533,0.239,0.452,0.282]) % ref
set(handles.text11,'position',[0.802,0.746,0.178,0.197]) % ref

set(handles.pushbutton2,'position',[0.819,0.273,0.129,0.25]) % OK

set(handles.text10,'position',[0.04,0.01,0.94,0.191]) % ref

set(gcf,'Name','Acycle: Spectral Moments')
dat = varargin{1}.current_data;  % data
diffx = diff(dat(:,1));
% check data
if sum(diffx <= 0) > 0
    disp('>>  Waning: data has to be in ascending order, no duplicated number allowed')
    dat = sortrows(dat);
end

% check data
if abs((max(diffx)-min(diffx))/2) > 10*eps('single')
    hwarn1 = warndlg('Data may not be evenly spaced!');
end
handles.unit = varargin{1}.unit; % unit
handles.unit_type = varargin{1}.unit_type; % unit type
handles.slash_v = varargin{1}.slash_v;
handles.acfigmain = varargin{1}.acfigmain;

handles.filename = varargin{1}.data_name; % save dataname
handles.dat_name = varargin{1}.dat_name; % save dataname
handles.path_temp = varargin{1}.path_temp; % save path
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;

datx = dat(:,1);  % unit should be cm
daty = dat(:,2);
npts = length(datx);
dt = median(diff(dat(:,1)));

handles.spectralmomentsFig = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(handles.spectralmomentsFig,'position',[0.2,0.4,0.2,0.4]) % set position
    plot(datx,daty)
    xlabel(handles.unit);ylabel('Value');title(handles.dat_name, 'Interpreter', 'none')
    xlim([min(datx) max(datx)])

% set zeropadding

handles.window = 0.25 * abs(datx(end) - datx(1));
handles.step = dt;
handles.pad = npts;
% if npts > 1000
%     handles.step = dt * ceil(npts/1000);  % keep sliding steps ~1000, if too much data is analyzed
% end

%data,window,step,pad,srmean,smoothmodel,padedge
%
handles.dat = dat; % save data
handles.datbackup = dat;
handles.sedrate = 0; % 0 = no test; 1 = input sed. rate
handles.srmean = 5;
handles.smoothmodel = 1;
handles.padedge = 0;
handles.padtype = 1;

set(handles.text2,'String', handles.dat_name)
set(handles.checkbox1,'Value',0)
set(handles.popupmenu1,'Value',1)
set(handles.popupmenu1,'Enable','off')
set(handles.edit2,'String',num2str(handles.window))
set(handles.edit3,'String',num2str(handles.step))
set(handles.edit4,'String',num2str(handles.pad))

set(handles.checkbox1,'Value',0)
set(handles.edit5,'String',num2str(handles.srmean))
set(handles.edit5,'Enable','off')
set(handles.popupmenu2,'Value',1)
set(handles.popupmenu2,'Enable','off')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpectralMomentsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpectralMomentsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = handles.dat;
window = handles.window;
step = handles.step;
pad = handles.pad;
srmean = handles.srmean;
if handles.smoothmodel == 1
    smoothmodel = 'poly';
elseif handles.smoothmodel == 2
    smoothmodel = 'lowess';
elseif handles.smoothmodel == 3
    smoothmodel = 'rlowess';
elseif handles.smoothmodel == 4
    smoothmodel = 'loess';
elseif handles.smoothmodel == 5
    smoothmodel = 'rloess';
end

hwarn = warndlg('Please wait, this may take a couple of minutes ...','Warning: Spectral Moments: slow process');

if handles.sedrate == 0
    % model without input sed. rate
    [depth,uf,Bw] = spectralmoments(data,window,step,pad);
    figure; plot(depth,uf,'r-',depth,Bw,'b-.');
    xlabel(handles.unit); ylabel('Frequency (cycles/m)'); legend('\mu_f','B')
    
    name1 = [handles.dat_name,'-SpecMoments-depth-uf-bw-win',num2str(window),'.txt'];
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(name1, [depth,uf,Bw], 'delimiter', ',', 'precision', 9);
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
else
    % model with input sed. rate
    [depth,uf,Bw,Bwtrend,sr] = spectralmoments(data,window,step,pad,srmean,smoothmodel,0);
    figure; plot(depth,uf,'r-',depth,Bw,'b-.',depth,Bwtrend,'g');
    xlabel(handles.unit); ylabel('Frequency (cycles/m)'); legend('\mu_f','B','B trend')
    figure; plot(depth, sr); xlabel('Depth (m)'); ylabel('Sed. rate (cm/kyr)');
    
    name1 = [handles.dat_name,'-SpecMoments-depth-uf-Bw-Btrend-win',num2str(window),'.txt'];
    name2 = [handles.dat_name,'-SpecMoments-sedrate-win',num2str(window),smoothmodel,'-SR',num2str(srmean),'.txt'];
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(name1, [depth,uf,Bw,Bwtrend], 'delimiter', ',', 'precision', 9);
    dlmwrite(name2, [depth,sr], 'delimiter', ',', 'precision', 9);
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
end
try close(hwarn)
catch
end
% Update handles structure
guidata(hObject, handles);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.window = str2double(get(hObject,'String'));

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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
handles.step = str2double(get(hObject,'String'));

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
handles.pad = str2double(get(hObject,'String'));

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


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

handles.sedrate = get(hObject,'Value') ; % 0 = no test; 1 = input sed. rate
if get(hObject,'Value')
    set(handles.edit5,'String',num2str(handles.srmean))
    set(handles.edit5,'Enable','on')
    set(handles.popupmenu2,'Value',1)
    set(handles.popupmenu2,'Enable','on')
else
     set(handles.edit5,'String',num2str(handles.srmean))
    set(handles.edit5,'Enable','off')
    set(handles.popupmenu2,'Value',1)
    set(handles.popupmenu2,'Enable','off')
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
dat = handles.datbackup;
handles.dat = dat;

if get(hObject,'Value')
    % paddin edge
    set(handles.popupmenu1,'Enable','on')
    dat = zeropad2(handles.datbackup,handles.window,handles.padtype);
    handles.pad = length(dat(:,1));
    set(handles.edit4,'String',num2str(handles.pad))
    handles.dat = dat;
    try figure( handles.spectralmomentsFig)
        plot(dat(:,1),dat(:,2))
        xlabel(handles.unit);ylabel('Value');title(handles.dat_name, 'Interpreter', 'none')
        xlim([min(dat(:,1)) max(dat(:,1))])
    catch
        handles.spectralmomentsFig = figure;
        set(0,'Units','normalized') % set units as normalized
        set(gcf,'units','norm') % set location
        set(handles.spectralmomentsFig,'position',[0.2,0.4,0.2,0.4]) % set position
        plot(dat(:,1),dat(:,2))
        xlabel(handles.unit);ylabel('Value');title(handles.dat_name, 'Interpreter', 'none')
        xlim([min(dat(:,1)) max(dat(:,1))])
    end
else
    set(handles.popupmenu1,'Enable','off')
    handles.pad = length(dat(:,1));
    set(handles.edit4,'String',num2str(handles.pad))
    try figure( handles.spectralmomentsFig)
        plot(dat(:,1),dat(:,2))
        xlabel(handles.unit);ylabel('Value');title(handles.dat_name, 'Interpreter', 'none')
        xlim([min(dat(:,1)) max(dat(:,1))])
    catch
        handles.spectralmomentsFig = figure;
        set(0,'Units','normalized') % set units as normalized
        set(gcf,'units','norm') % set location
        set(handles.spectralmomentsFig,'position',[0.2,0.4,0.2,0.4]) % set position
        plot(dat(:,1),dat(:,2))
        xlabel(handles.unit);ylabel('Value');title(handles.dat_name, 'Interpreter', 'none')
        xlim([min(dat(:,1)) max(dat(:,1))])
    end
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
handles.padtype = get(hObject,'Value');
dat = zeropad2(handles.datbackup,handles.window,handles.padtype);
handles.dat = dat;

try figure( handles.spectralmomentsFig)
    plot(dat(:,1),dat(:,2))
    xlabel(handles.unit);ylabel('Value');title(handles.dat_name, 'Interpreter', 'none')
    xlim([min(dat(:,1)) max(dat(:,1))])
catch
    handles.spectralmomentsFig = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(handles.spectralmomentsFig,'position',[0.2,0.4,0.2,0.4]) % set position
    plot(dat(:,1),dat(:,2))
    xlabel(handles.unit);ylabel('Value');title(handles.dat_name, 'Interpreter', 'none')
    xlim([min(dat(:,1)) max(dat(:,1))])
end
% Update handles structure
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



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
handles.srmean = str2double(get(hObject,'String'));

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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

handles.smoothmodel = get(hObject,'Value');
% Update handles structure
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
