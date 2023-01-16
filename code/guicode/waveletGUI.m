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

% Last Modified by GUIDE v2.5 12-Dec-2021 00:16:20

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
handles.val1 = varargin{1}.val1;

handles.waveletGUIfig = gcf;
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
set(gcf,'position',[0.25,0.2,0.5,0.35]* handles.MonZoom) % set position

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
set(handles.text11,'position',[0.06,0.12,0.2,0.15])
set(handles.edit7,'position',[0.28,0.1,0.1,0.2])
set(handles.text13,'position',[0.4,0.12,0.2,0.15])  % MC for wavelet coherence
set(handles.edit11,'position',[0.6,0.1,0.1,0.2])

set(handles.uipanel2,'position',[0.02,0.02,0.78,0.36])
set(handles.checkbox2,'position',[0.02,0.75,0.2,0.2])
set(handles.checkbox3,'position',[0.02,0.5,0.2,0.2])
set(handles.edit10,'position',[0.22,0.5,0.05,0.2])
set(handles.checkbox8,'position',[0.02,0.25,0.2,0.2])
set(handles.checkbox10,'position',[0.02,0.02,0.12,0.2])
set(handles.edit9,'position',[0.125,0.02,0.04,0.2])
set(handles.checkbox12,'position',[0.17,0.02,0.08,0.2],'value',0)

set(handles.checkbox4,'position',[0.3,0.75,0.2,0.2])
set(handles.checkbox5,'position',[0.3,0.5,0.2,0.2])
set(handles.checkbox6,'position',[0.3,0.25,0.2,0.2])
set(handles.checkbox9,'position',[0.3,0.05,0.2,0.2])

set(handles.text9,'position',[0.5,0.75,0.1,0.15])
set(handles.popupmenu3,'position',[0.62,0.72,0.2,0.2])
set(handles.text10,'position',[0.5,0.55,0.1,0.15])
set(handles.edit6,'position',[0.62,0.55,0.07,0.15])

set(handles.text12,'position',[0.5,0.35,0.1,0.15])
set(handles.edit8,'position',[0.62,0.35,0.32,0.15])
set(handles.pushbutton3,'position',[0.955,0.35,0.035,0.15])

set(handles.radiobutton3,'position',[0.65,0.1,0.1,0.2])
set(handles.radiobutton4,'position',[0.75,0.1,0.1,0.2])

set(handles.uipanel3,'position',[0.82,0.02,0.14,0.36])
set(handles.checkbox7,'position',[0.03,0.6,0.95,0.2])
set(handles.pushbutton2,'position',[0.2,0.1,0.6,0.4])

% read selected file
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
handles.data_name = varargin{1}.data_name;
data_name = handles.data_name;
[lengthdata,~] = size(data_name);

handles.path_temp = varargin{1}.path_temp;
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
handles.lengthdata = lengthdata;
handles.wavehastorerun = 1;
handles.switchdata = 0;
% language
lang_choice = varargin{1}.lang_choice;
handles.lang_choice = lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;
handles.lang_id = lang_id;
handles.lang_var = lang_var;
handles.main_unit_selection = varargin{1}.main_unit_selection;

set(handles.edit9,'string','2')

if lengthdata == 1
    % wavelet
    if handles.lang_choice == 0
        set(gcf,'Name','Acycle: Wavelet')
    else
        [~, menu109] = ismember('menu109',lang_id);
        set(gcf,'Name',['Acycle: ',lang_var{menu109}])
    end
    data = varargin{1}.current_data;
    handles.current_data = data;
    [dat_dir,handles.filename1,exten] = fileparts(data_name);
    
    set(handles.text3,'enable','off')
    set(handles.edit2,'enable','off')
    set(handles.pushbutton1,'visible','off')
    set(handles.edit1,'string',[handles.filename1,exten])
    set(handles.edit5,'string','0.1')
    set(handles.popupmenu2,'enable','on')
    set(handles.edit7,'enable','on')
    set(handles.edit10,'visible','off')
    set(handles.checkbox1,'Value',1,'enable','on')
    if handles.lang_choice == 0
        set(handles.checkbox3,'Value',0,'enable','on','string','plot spectrum')
    else
        [~, menu03] = ismember('menu03',lang_id);
        [~, wave06] = ismember('wave06',lang_id);
        set(handles.checkbox3,'Value',0,'enable','on','string',[lang_var{menu03},' ', lang_var{wave06}])
    end
    set(handles.checkbox9,'Value',1,'enable','on')
    set(handles.checkbox10,'Value',1,'enable','on')
    method_list = {'Wavelet';'Continous Wavelet Transform';'Wavelet (Torrence & Compo, 1998)'};
    set(handles.popupmenu1,'Value',2,'enable','on','string',method_list)
    
    set(handles.text13,'Visible','off')
    set(handles.edit11,'Visible','off')
else
    % wcoherence
    if handles.lang_choice == 0
        set(gcf,'Name','Acycle: Wavelet coherence and cross-spectrum')
    else
        [~, wave15] = ismember('wave15',lang_id);
        set(gcf,'Name',['Acycle: ',lang_var{wave15}])
    end
    
    [handles.dat_dir,handles.filename1,handles.exten] = fileparts(data_name(1,:));
    [handles.dat_dir,handles.filename2,handles.exten] = fileparts(data_name(2,:));
    set(handles.text3,'enable','on')
    set(handles.edit2,'enable','on')
    set(handles.pushbutton1,'visible','on')
    set(handles.edit1,'string',[handles.filename1,handles.exten])
    set(handles.edit2,'string',[handles.filename2,handles.exten])
    set(handles.popupmenu1, 'Value', 3);
    set(handles.popupmenu2,'enable','off')
    set(handles.edit7,'enable','on')
    set(handles.edit5,'string','0.1')
    set(handles.edit10,'visible','on')
    set(handles.checkbox1,'Value',1,'enable','on')
    if handles.lang_choice == 0
        set(handles.checkbox3,'Value',0,'enable','on','string','phase, wtc threshold')
    else
        [~, wave16] = ismember('wave16',lang_id);
        set(handles.checkbox3,'Value',0,'enable','on','string',lang_var{wave16})
    end
    set(handles.checkbox9,'Value',1,'enable','on')
    set(handles.checkbox10,'Value',0,'enable','off')
    set(handles.checkbox12,'Value',0,'enable','off')
    set(handles.edit9,'enable','off')
    method_list = {'Wavelet coherence (MatLab)';'Wavelet Coherence (Grinsted2014)'};
    set(handles.popupmenu1,'Value',2,'enable','on','string',method_list)
    
    set(handles.text13,'Visible','on')
    set(handles.edit11,'Visible','on')
end


% language
if handles.lang_choice > 0
    [~, main12] = ismember('main12',handles.lang_id);
    set(handles.text2,'String',[lang_var{main12},'1']) %  series 1
    set(handles.text3,'String',[lang_var{main12},'2'])%  series 2
    
    [~, wave01] = ismember('wave01',handles.lang_id);
    set(handles.pushbutton1,'String',lang_var{wave01})
    
    [~, menu81] = ismember('menu81',handles.lang_id);
    set(handles.checkbox11,'String',lang_var{menu81})
    
    [~, main51] = ismember('main51',handles.lang_id); % set
    [~, main15] = ismember('main15',handles.lang_id); % period
    set(handles.uibuttongroup1,'Title',[lang_var{main51}, lang_var{main15}])
    
    [~, wave02] = ismember('wave02',handles.lang_id);
    set(handles.text4,'String',lang_var{wave02})
    
    [~, wave03] = ismember('wave03',handles.lang_id);
    set(handles.text5,'String',lang_var{wave03})
    
    [~, wave04] = ismember('wave04',handles.lang_id);
    set(handles.text6,'String',lang_var{wave04})
    
    [~, wave05] = ismember('wave05',handles.lang_id);
    set(handles.text8,'String',lang_var{wave05})
    
    [~, wave06] = ismember('wave06',handles.lang_id);
    set(handles.checkbox3,'String',lang_var{wave06})
    
    [~, wave07] = ismember('wave07',handles.lang_id);
    set(handles.checkbox8,'String',lang_var{wave07})
    
    [~, wave08] = ismember('wave08',handles.lang_id);
    set(handles.checkbox4,'String',lang_var{wave08})
    
    [~, wave09] = ismember('wave09',handles.lang_id);
    set(handles.checkbox5,'String',lang_var{wave09})
    
    [~, wave10] = ismember('wave10',handles.lang_id);
    set(handles.checkbox6,'String',lang_var{wave10})
    
    [~, wave11] = ismember('wave11',handles.lang_id);
    set(handles.checkbox9,'String',lang_var{wave11})
    
    [~, wave12] = ismember('wave12',handles.lang_id);
    set(handles.checkbox10,'String',lang_var{wave12})
    
    [~, wave13] = ismember('wave13',handles.lang_id);
    set(handles.checkbox12,'String',lang_var{wave13})
    
    [~, wave14] = ismember('wave14',handles.lang_id);
    set(handles.text12,'String',lang_var{wave14})
    
    [~, main03] = ismember('main03',handles.lang_id);
    set(handles.radiobutton1,'String',lang_var{main03})
    
    [~, main04] = ismember('main04',handles.lang_id);
    set(handles.radiobutton2,'String',[lang_var{main04},'2']) % log2
    
    [~, main43] = ismember('main43',handles.lang_id);
    set(handles.checkbox1,'String',lang_var{main43}) % padding
    
    [~, menu03] = ismember('menu03',handles.lang_id);
    set(handles.uipanel2,'Title',lang_var{menu03})
    
    [~, main12] = ismember('main12',handles.lang_id);
    set(handles.checkbox2,'String',[lang_var{menu03}, lang_var{main12}]) % plot series
    
    [~, wave06] = ismember('wave06',handles.lang_id);
    set(handles.checkbox3,'String',[lang_var{menu03}, lang_var{wave06}]) % plot spectrum
    
    [~, main50] = ismember('main50',handles.lang_id);
    set(handles.text9,'String',lang_var{main50})  % colormap
    
    [~, evofft12] = ismember('evofft12',handles.lang_id);
    set(handles.text10,'String',lang_var{evofft12}) % grid #
    
    [~, main01] = ismember('main01',handles.lang_id);
    set(handles.uipanel3,'Title',lang_var{main01}) % save data

    set(handles.checkbox7,'String',lang_var{main01}) % save data
    
    [~, main00] = ismember('main00',handles.lang_id);
     set(handles.pushbutton2,'String',lang_var{main00})
     
    [~, c37] = ismember('c37',handles.lang_id);
    set(handles.text7,'String',lang_var{c37})
    set(handles.uipanel1,'Title',lang_var{c37})
    
    [~, c36] = ismember('c36',handles.lang_id);
    set(handles.text11,'String',lang_var{c36})
%     
%     [~, mainxx] = ismember('mainxx',handles.lang_id);
%     set(handles.mainxx,'String',lang_var{mainxx})
%     
%     [~, mainxx] = ismember('mainxx',handles.lang_id);
%     set(handles.mainxx,'String',lang_var{mainxx})
    
end

if lengthdata == 1
    time = data(:,1);
    timelen = (time(end)-time(1));
    Dti = diff(time);
    dt = mean(Dti);
    if max(Dti) - min(Dti) > 10 * eps('single')
        if handles.lang_choice == 0
            f = warndlg('Interpolation needed. Mean sampling rate was used.','Warning');
        else
            [~, evofft14] = ismember('evofft14',lang_id);
            [~, main29] = ismember('main29',lang_id);
            f = warndlg(lang_var{evofft14},lang_var{main29});
        end
        [data]=interpolate(data,dt);
        handles.current_data = data;
    end
else
    data_name = handles.data_name;
    %data = handles.current_data;
    s2 = data_name(1,:);
    s2(s2 == ' ') = [];
    dat1 = load(s2);
    dat1 = sortrows(dat1);

    s2 = data_name(2,:);
    s2(s2 == ' ') = [];
    dat2 = load(s2);
    dat2 = sortrows(dat2);

    xmin = max( min(dat1(:,1), min(dat2(:,1))));
    xmax = min( max(dat1(:,1), max(dat2(:,1))));
    dat1 = select_interval(dat1,xmin,xmax);
    
    Dti1 = diff(dat1(:,1));
    dt = mean(Dti1);
    
    if max(Dti1) - min(Dti1) > 10 * eps('single')
        if handles.lang_choice == 0
            f = warndlg('Series 1: Interpolation needed! Done!','Warning');
        else
            [~, wave17] = ismember('wave17',lang_id);
            [~, main29] = ismember('main29',lang_id);
            f = warndlg(lang_var{wave17},lang_var{main29});
        end
        [dat1]=interpolate(dat1,dt);
    end
    if isequal(dat1(:,1),dat2(:,1))
        
    else
        if handles.lang_choice == 0
            f2 = warndlg('Time ranges are not equal. Inerpolation series applied.','Warning');
        else
            [~, wave18] = ismember('wave18',lang_id);
            [~, main29] = ismember('main29',lang_id);
            f2 = warndlg(lang_var{wave18},lang_var{main29});
        end
        dat2int2 = interp1(dat2(:,1),dat2(:,2),dat1(:,1));
        dat2  = [dat1(:,1),dat2int2];
    end
    data = dat1;
    time = data(:,1);
    timelen = (time(end)-time(1));
end

% ticks
Yticks_default = 2.^(fix(log2(2*dt)):fix(log2(timelen)));
Yticks = mat2str(Yticks_default);
Yticks(1)= [];
Yticks(length(Yticks))=[];
% init period
datax = data(:,1);
datay = data(:,2);
dt = mean(diff(datax));
s0 = 2*dt;    %
pt2 = 2^fix(log2(timelen));
dss = 0.1;
j1 = round(log2(pt2))/dss; % end
pad = 1;
mother = 'MORLET';
param = 6;

[~,period,~,coi] = wavelet(datay,dt,pad,dss,s0,j1,mother,param);
set(handles.edit3,'string',num2str(  min(period) ))
set(handles.edit4,'string',num2str(  max(coi) ))
set(handles.popupmenu2,'value',1)
set(handles.checkbox2,'value',1)
set(handles.checkbox8,'value',1)
set(handles.checkbox4,'value',0)
set(handles.checkbox5,'value',0)
set(handles.checkbox6,'value',0)
set(handles.checkbox7,'value',0)
set(handles.edit8,'string',Yticks)
% value
set(handles.radiobutton1,'value',0)
set(handles.radiobutton2,'value',1)

set(handles.radiobutton3,'value',1)
set(handles.radiobutton4,'value',0)
set(handles.checkbox8,'value',1)

set(handles.edit6,'string','')
set(handles.edit7,'string','6')
set(handles.popupmenu3,'value',1)
set(handles.checkbox11,'value',0)
% Choose default command line output for waveletGUI
handles.output = hObject;

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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;
if handles.lengthdata == 1
    
    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    if get(hObject,'Value')
        set(handles.radiobutton1,'enable','off','value',0)
        set(handles.radiobutton2,'enable','off','value',1)
        set(handles.checkbox8,'enable','on')
        set(handles.edit5,'enable','on')
        set(handles.checkbox8,'value',1)
        % coherence
        wavecoh_readGUI
        % update plot
        wavecoh_update_plots
    else
        %
        set(handles.radiobutton1,'enable','on','value',0)
        set(handles.radiobutton2,'enable','on','value',1)
        set(handles.checkbox8,'enable','on')
        set(handles.edit5,'enable','on')
        try figure(handles.figwave)
            clf
        end
        %set(handles.checkbox2,'value',0)
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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 1;

if handles.lengthdata == 1
    
    if get(hObject,'Value') == 2
        set(handles.edit5,'string',num2str(1/12))
    else
        set(handles.edit5,'string',num2str(0.1))
    end

    % read gui settings
    wave_readGUI
    % update all panels
    wave_update_plots
    
else
    
    if get(hObject,'Value') == 2
        set(handles.edit5,'string',num2str(1/12))
        set(handles.checkbox9,'Value',1,'enable','on')
        set(handles.text13,'Visible','on')
        set(handles.edit11,'Visible','on')
        set(gcf,'Name','Acycle: Wavelet coherence and cross-spectrum')
    else
        set(handles.edit5,'string',num2str(0.1))
        set(handles.checkbox9,'Value',0,'enable','off')
        set(handles.text13,'Visible','off')
        set(handles.edit11,'Visible','off')
        set(gcf,'Name','Acycle: Wavelet coherence')
    end

    % coherence
    wavecoh_readGUI
    % update plot
    wavecoh_update_plots
end
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

handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;
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
handles.wavehastorerun = 0;

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

handles.wavehastorerun = 0;
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

handles.wavehastorerun = 0;
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


function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double

handles.wavehastorerun = 0;
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
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'User defined tick labels, space delimited values, e.g.,';'10 20 41 100 405 1200 2400'},'Help: format')


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
handles.wavehastorerun = 0;
if str2double(get(hObject,'String')) <= 1
    set(hObject,'String','2')
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


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12
handles.wavehastorerun = 0;

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



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double

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
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
