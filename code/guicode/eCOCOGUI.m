function varargout = eCOCOGUI(varargin)
% ECOCOGUI MATLAB code for eCOCOGUI.fig
%      ECOCOGUI, by itself, creates a new ECOCOGUI or raises the existing
%      singleton*.
%
%      H = ECOCOGUI returns the handle to a new ECOCOGUI or the handle to
%      the existing singleton*.
%
%      ECOCOGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ECOCOGUI.M with the given input arguments.
%
%      ECOCOGUI('Property','Value',...) creates a new ECOCOGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eCOCOGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eCOCOGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eCOCOGUI

% Last Modified by GUIDE v2.5 06-Nov-2021 23:13:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eCOCOGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @eCOCOGUI_OutputFcn, ...
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


% --- Executes just before eCOCOGUI is made visible.
function eCOCOGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eCOCOGUI (see VARARGIN)

% Choose default command line output for eCOCOGUI
handles.output = hObject;

%
handles.hmain = gcf;
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;

%
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

set(handles.hmain,'position',[0.38,0.2,0.4,0.75] * handles.MonZoom) % set position
set(handles.uibuttongroup7,'position',[0.04,0.915,0.45,0.08]) % Power spectrum
set(handles.radiobutton1,'position',[0.083,0.138,0.388,0.793]) % COCO
set(handles.radiobutton2,'position',[0.508,0.138,0.388,0.793]) % eCOCO

set(handles.uibuttongroup1,'position',[0.04,0.809,0.923,0.106]) % Data
set(handles.text2,'position',[0.023,0.5,0.083,0.352])
set(handles.text3,'position',[0.121,0.5,0.863,0.352])
set(handles.checkbox6,'position',[0.023,0.042,0.2,0.562])
set(handles.edit12,'position',[0.206,0.083,0.1,0.45])

set(handles.checkbox1,'position',[0.333,0.042,0.24,0.562])
set(handles.popupmenu1,'position',[0.53,0.001,0.214,0.5])
set(handles.checkbox5,'position',[0.738,0.042,0.29,0.562])

set(handles.uibuttongroup2,'position',[0.04,0.692,0.923,0.106]) % Power spectrum
set(handles.checkbox2,'position',[0.023,0.311,0.242,0.511])
set(handles.text8,'position',[0.222,0.2,0.13,0.6])
set(handles.edit4,'position',[0.355,0.311,0.084,0.489])
set(handles.text18,'position',[0.441,0.2,0.12,0.6])
set(handles.edit13,'position',[0.552,0.356,0.064,0.489])
set(handles.checkbox4,'position',[0.618,0.55,0.35,0.45])
set(handles.popupmenu3,'position',[0.618,0.02,0.35,0.5])

set(handles.uipanel1,'position',[0.04,0.531,0.923,0.153]) % test sed. rate
set(handles.text4,'position',[0.023,0.526,0.132,0.295])
set(handles.text5,'position',[0.288,0.526,0.14,0.295])
set(handles.text6,'position',[0.553,0.526,0.1,0.295])
set(handles.edit1,'position',[0.165,0.6,0.104,0.28])
set(handles.edit2,'position',[0.436,0.6,0.104,0.28])
set(handles.edit3,'position',[0.632,0.6,0.085,0.28])
set(handles.text19,'position',[0.735,0.529,0.076,0.324])
set(handles.text7,'position',[0.1,0.132,0.865,0.294])

set(handles.uibuttongroup3,'position',[0.04,0.316,0.923,0.205]) % target cycles
set(handles.radiobutton6,'position',[0.023,0.486,0.335,0.248])
set(handles.radiobutton7,'position',[0.023,0.294,0.335,0.248])
set(handles.radiobutton8,'position',[0.023,0.083,0.335,0.248])
set(handles.edit5,'position',[0.3,0.734,0.112,0.229])
set(handles.edit11,'position',[0.3,0.083,0.5,0.229])
set(handles.edit7,'position',[0.74,0.734,0.112,0.229])
set(handles.text9,'position',[0.421,0.761,0.083,0.138])
set(handles.text10,'position',[0.537,0.761,0.195,0.138])
set(handles.text11,'position',[0.855,0.761,0.08,0.138])
set(handles.text20,'position',[0.3,0.523,0.653,0.12])
set(handles.text21,'position',[0.3,0.36,0.653,0.12])
set(handles.text22,'position',[0.023,0.73,0.24,0.12])

set(handles.uibuttongroup4,'position',[0.04,0.233,0.923,0.07]) % correlation method
set(handles.radiobutton9,'position',[0.023,0.107,0.229,0.893])
set(handles.radiobutton10,'position',[0.389,0.143,0.229,0.893])

set(handles.uibuttongroup5,'position',[0.04,0.1,0.17,0.121]) % MC
set(handles.edit8,'position',[0.1,0.42,0.8,0.38])
set(handles.text13,'position',[0.1,0.15,0.8,0.22])

set(handles.uibuttongroup6,'position',[0.244,0.1,0.327,0.113]) % Sliding window
set(handles.text14,'position',[0.023,0.7,0.2,0.25])
set(handles.text15,'position',[0.023,0.2,0.2,0.35])
set(handles.text16,'position',[0.54,0.7,0.3,0.25])
set(handles.text17,'position',[0.54,0.24,0.3,0.25])
set(handles.edit9,'position',[0.237,0.574,0.3,0.4])
set(handles.edit10,'position',[0.237,0.14,0.3,0.4])
set(handles.pushbutton1,'position',[0.83,0.118,0.09,0.08]) % Sliding window

set(handles.pushbutton2,'position',[0.58,0.153,0.23,0.058]) % ecoco plot
set(handles.pushbutton2,'Visible','off','Enable','off') % 
set(handles.pushbutton3,'position',[0.58,0.1,0.23,0.058]) % track sed. rates
set(handles.pushbutton3,'Visible','off','Enable','off') %
set(handles.pushbutton4,'position',[0.82,0.083,0.15,0.229]) %

% language
lang_choice = varargin{1}.lang_choice;
handles.lang_choice = lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;
if lang_choice>0
    [~, locb] = ismember('ec00',lang_id);
    set(gcf,'Name',lang_var{locb})  % GUI title
    [~, locb] = ismember('ec02',lang_id);
    set(handles.uibuttongroup7,'title',lang_var{locb})
    [~, locb] = ismember('ec03',lang_id);
    set(handles.radiobutton1,'string',lang_var{locb})
    [~, locb] = ismember('ec04',lang_id);
    set(handles.radiobutton2,'string',lang_var{locb})
    [~, locb] = ismember('main02',lang_id);
    set(handles.uibuttongroup1,'title',lang_var{locb})
    set(handles.text2,'string',lang_var{locb})
    set(handles.text3,'string',lang_var{locb})
    [~, locb] = ismember('ec05',lang_id);
    set(handles.checkbox1,'string',lang_var{locb})
    [~, locb1] = ismember('ec06',lang_id);
    [~, locb2] = ismember('dd39',lang_id);
    [~, locb3] = ismember('dd40',lang_id);
    [~, locb4] = ismember('dd41',lang_id);
    set(handles.popupmenu1,'string',{lang_var{locb1},lang_var{locb2},lang_var{locb3},lang_var{locb4}})
    [~, locb] = ismember('ec07',lang_id);
    set(handles.checkbox5,'string',lang_var{locb})
    [~, locb] = ismember('ec08',lang_id);
    set(handles.checkbox6,'string',lang_var{locb})
    %
    [~, locb] = ismember('ec09',lang_id);
    set(handles.uibuttongroup2,'title',lang_var{locb})
    [~, locb] = ismember('ec10',lang_id);
    set(handles.checkbox2,'string',lang_var{locb})
    [~, locb] = ismember('main06',lang_id);
    set(handles.text8,'string',lang_var{locb})
    [~, locb] = ismember('ec11',lang_id);
    set(handles.checkbox4,'string',lang_var{locb})
    [~, locb12] = ismember('ec12',lang_id);
    [~, locb13] = ismember('ec13',lang_id);
    [~, locb14] = ismember('ec14',lang_id);
    set(handles.popupmenu3,'string',{lang_var{locb12};lang_var{locb13};lang_var{locb14}})
    [~, locb] = ismember('a209',lang_id);
    set(handles.text18,'string',lang_var{locb})
    %
    [~, locb] = ismember('ec01',lang_id);
    set(handles.uipanel1,'title',lang_var{locb})
    [~, locb] = ismember('main05',lang_id);
    set(handles.text4,'string',lang_var{locb})
    [~, locb] = ismember('main06',lang_id);
    set(handles.text5,'string',lang_var{locb})
    [~, locb] = ismember('main32',lang_id);
    set(handles.text6,'string',lang_var{locb})
    set(handles.text19,'string',lang_var{locb})
    %
    [~, locb] = ismember('ec15',lang_id);
    set(handles.uibuttongroup3,'title',lang_var{locb})
    [~, locb] = ismember('ec16',lang_id);
    set(handles.radiobutton6,'string',lang_var{locb})
    [~, locb] = ismember('ec17',lang_id);
    set(handles.radiobutton7,'string',lang_var{locb})
    [~, locb] = ismember('ec18',lang_id);
    set(handles.radiobutton8,'string',lang_var{locb})
    [~, locb] = ismember('ec19',lang_id);
    set(handles.text10,'string',lang_var{locb})
    [~, locb] = ismember('ec20',lang_id);
    set(handles.text22,'string',lang_var{locb})
    %
    [~, locb] = ismember('ec21',lang_id);
    set(handles.uibuttongroup4,'title',lang_var{locb})
    %
    [~, locb] = ismember('main39',lang_id);
    set(handles.uibuttongroup5,'title',lang_var{locb})
    [~, locb] = ismember('ec22',lang_id);
    set(handles.text13,'string',lang_var{locb})
    %
    [~, locb] = ismember('main07',lang_id);
    set(handles.uibuttongroup6,'title',lang_var{locb})
    [~, locb] = ismember('c39',lang_id);
    set(handles.text14,'string',lang_var{locb})
    [~, locb] = ismember('main32',lang_id);
    set(handles.text15,'string',lang_var{locb})
    [~, locb] = ismember('main34',lang_id);
    set(handles.text16,'string',lang_var{locb})
    set(handles.text17,'string',lang_var{locb})
    [~, locb] = ismember('ec23',lang_id);
    set(handles.pushbutton2,'string',lang_var{locb})
    [~, locb] = ismember('ec67',lang_id);
    set(handles.pushbutton3,'string',lang_var{locb})
    %
    [~, locb] = ismember('ec24',lang_id);
    ec24 = lang_var{locb};
    [~, locb] = ismember('ec25',lang_id);
    ec25 = lang_var{locb};
    [~, locb] = ismember('ec26',lang_id);
    ec26 = lang_var{locb};
    [~, locb] = ismember('ec27',lang_id);
    ec27 = lang_var{locb};
    [~, locb] = ismember('ec28',lang_id);
    ec28 = lang_var{locb};
    [~, locb] = ismember('ec29',lang_id);
    ec29 = lang_var{locb};
    [~, locb] = ismember('ec30',lang_id);
    ec30 = lang_var{locb};
    [~, locb] = ismember('ec31',lang_id);
    ec31 = lang_var{locb};
    [~, locb] = ismember('ec32',lang_id);
    ec32 = lang_var{locb};
    [~, locb] = ismember('ec33',lang_id);
    ec33 = lang_var{locb};
    [~, locb] = ismember('ec34',lang_id);
    ec34 = lang_var{locb};
    [~, locb] = ismember('ec35',lang_id);
    ec35 = lang_var{locb};
    [~, locb] = ismember('ec36',lang_id);
    ec36 = lang_var{locb};
else
    set(gcf,'Name','Acycle: (Evolutionary) Correlation Coefficient / (e)COCO')
end

%

dat = varargin{1}.current_data;  % data
%
diffx = diff(dat(:,1));
% check data
if sum(diffx <= 0) > 0
    if lang_choice == 0
        disp('>>  Waning: data has to be in ascending order, no duplicated number allowed')
    else
        disp(ec24)
    end
    dat = sortrows(dat);
end

% check data
if abs((max(diffx)-min(diffx))/2) > 10*eps('single')
    if lang_choice == 0
        hwarn1 = warndlg('Data may not be evenly spaced!');
    else
        hwarn1 = warndlg(ec25);
    end
    
end
%
datx = dat(:,1);  % unit should be cm
daty = dat(:,2);
npts = length(datx);
dt = median(diff(dat(:,1)));
dtr = dt;

% set zeropadding
if npts <= 2500
    handles.pad = 5000;
elseif npts <= 5000 && npts > 2500
    handles.pad = 10000;
else
    handles.pad = fix(npts/5000) * 5000 + 5000;
end
%
handles.window = 0.25 * abs(datx(end) - datx(1));
handles.step = dt;
if npts > 300
    handles.step = dt * ceil(npts/300);  % keep sliding steps ~300, if too much data is analyzed
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

%
handles.dat = dat; % save data
handles.datbackup = dat;
% set default sedmin, sedmax
handles.sedmin = 0;
handles.sedmax = 100;
handles.sedstep = 0.1;
handles.numsed = 200;
handles.fh = 0.065;
handles.orbit7 = [405, 125, 95, 41, 22.43, 23.75, 19.18]; % 7 leading orbit periods
handles.nsim = 2000;
handles.age = 0;
handles.f1 = 0;
handles.f2 = 0.06;
handles.slices = 1;
handles.ecocoS = 0; % 0 = COCO; 1 = eCOCO
% check unit, set to cm
if handles.unit_type == 0
    if lang_choice == 0
        hwarn = warndlg('Is the Unit m? If not, set unit in Acycle and restart COCO/eCOCO');
    else
        hwarn = warndlg(ec26);
    end
    dat(:,1) = dat(:,1)*100;
    dt = dt * 100;
    dtr = dt*100;
elseif handles.unit_type == 2
    if lang_choice == 0
        hwarn = warndlg('Unit type is Time! Make sure the unit is m');
    else
        hwarn = warndlg(ec27);
    end
else
    if strcmp(handles.unit,'m')
        dat(:,1) = dat(:,1)*100;
        dtr = dt*100;dt = dt * 100;
        %msgbox('Unit is m, now changes to cm','Unit transform')
    elseif strcmp(handles.unit,'dm')
        dat(:,1) = dat(:,1)*10;
        dtr = dt*10;dt = dt * 10;
        if lang_choice == 0
            msgbox('Unit is dm, now changes to cm','Unit transform')
        else
            msgbox(ec29,ec28)
        end
        
    elseif strcmp(handles.unit,'mm')
        dat(:,1) = dat(:,1)/10;
        dtr = dt/10;dt = dt / 10;
        if lang_choice == 0
            msgbox('Unit is mm, now changes to cm','Unit transform')
        else
            msgbox(ec30,ec28)
        end
        
    elseif strcmp(handles.unit,'km')
        dat(:,1) = dat(:,1)* 1000 * 100;
        dtr = dt*100*1000;dt = dt * 100*1000;
        if lang_choice == 0
            msgbox('Unit is km, now changes to cm','Unit transform')
        else
            msgbox(ec31,ec28)
        end
        
    elseif strcmp(handles.unit,'ft')
        dat(:,1) = dat(:,1)* 30.48;
        dtr = dt * 30.48; dt = dt * 30.48;
        if lang_choice == 0
            msgbox('Unit is ft, now changes to cm','Unit transform')
        else
            msgbox(ec32,ec28)
        end
        
    end
end

% set default values
set(handles.radiobutton1,'Value',1) % select COCO
set(handles.radiobutton2,'Value',0) % not select COCO
set(handles.text3,'String',handles.dat_name)
set(handles.checkbox6,'Value',1) % select zero padding
set(handles.edit12,'String',num2str(handles.pad))

set(handles.checkbox1,'Value',1) % select edge padding
set(handles.checkbox1,'Visible','off') % padding edge invisible for COCO

set(handles.popupmenu1,'Value',1) % padding = zero
set(handles.popupmenu1,'Visible','off') % flip y invisible for COCO
set(handles.checkbox5,'Value',1) % flip y
set(handles.checkbox5,'Visible','off') % flip y invisible for COCO

set(handles.checkbox2,'Value',1) % show power spectrum
set(handles.edit4,'Enable','on')
set(handles.checkbox4,'Value',0) % remove red noise = 0
set(handles.popupmenu3,'Value',1) % remove red noise = no
set(handles.edit13,'Enable','on') % COCO for slices
set(handles.edit13,'String','1')

set(handles.radiobutton6,'Value',0)
set(handles.radiobutton7,'Value',1) % default solution = La04
set(handles.radiobutton8,'Value',0)
set(handles.edit5,'String',num2str(handles.age)) % middle age of data
set(handles.edit7,'String',num2str(handles.f2)) % test max orbit frequency

set(handles.radiobutton9,'Value',0) % correlation method: spearman
set(handles.radiobutton10,'Value',1) % correlation method: pearson

set(handles.edit8,'String',num2str(handles.nsim)) % MC number
set(handles.uibuttongroup6,'Visible','off') % sliding window invisible for COCO

set(handles.edit9,'String',num2str(handles.window)) % window size
%set(handles.edit10,'String',num2str(handles.step)) % step size
set(handles.text16,'String',handles.unit)
set(handles.edit10,'String',num2str(handles.step)) % step
set(handles.text17,'String',handles.unit)
set(handles.text19,'String','cm/kyr')

fnyq = handles.sedmin/(2*dtr);
if handles.fh > fnyq
    sedmin = 2 * dtr * handles.fh;
    if handles.unit_type == 0
        sedmin = sedmin/100;
    end
    handles.sedmin = sedmin;
end
fray = handles.sedmax/(npts * dtr);
flow = 1/max(handles.orbit7);
if fray > flow
    sedmax = npts * dtr * flow;
    handles.sedmax = sedmax;
end
if (handles.sedmax-handles.sedmin)/handles.sedstep > 300
    handles.sedstep = (handles.sedmax-handles.sedmin)/300;
end
set(handles.edit1,'String',num2str(handles.sedmin))
set(handles.edit2,'String',num2str(handles.sedmax))
set(handles.edit3,'String',num2str(handles.sedstep))
% test sed. rate info

sr = handles.sedmin:handles.sedstep:handles.sedmax;
if lang_choice == 0
    sedinfo = [num2str(length(sr)),' test sed. rates: ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
else
    sedinfo = [num2str(length(sr)),ec33,num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
end
set(handles.text7,'String',sedinfo)

% tooltips for OK button
if lang_choice == 0
    s_push_ok = sprintf('Check parameters in BLUE\nclick OK to run eTimeOpt');
else
    s_push_ok = sprintf(ec34);
end
set(handles.pushbutton1,'TooltipString',s_push_ok) 
%
%
red = 0;
handles.red = red;
handles.npts = npts;
handles.dt = dt;
handles.dtr = dtr;
handles.sr = sr;
handles.corrmethod = 1; % 1= 'Pearson'; else = 'Spearman'
handles.plotn = 1; % plot data
handles.flipy = 1; % flip y axis
handles.plot_2d = 1;
handles.time_0pad = 1;  % updated acycle v1.2.1
handles.padtype = 1; % updated acycle v1.2.1

%
handles.ecocofigdata = figure;
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
set(gcf,'color','w');
set(handles.ecocofigdata,'position',[0.01,0.01,0.2,0.9]) % set position
if handles.flipy == 1
    plot(fliplr(daty),datx,'k')
else
    plot(daty,datx,'k')
end
if lang_choice == 0
    xlabel('Value'); ylabel(['Depth',' (',handles.unit,')'])
else
    [~, locb] = ismember('main24',lang_id);
    main24 = lang_var{locb};
    [~, locb] = ismember('main23',lang_id);
    main23 = lang_var{locb};
    xlabel(main24); ylabel([main23,' (',handles.unit,')'])
end
%
handles.ecocofigspectrum = figure;
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
set(gcf,'color','w');
set(handles.ecocofigspectrum,'position',[0.2,0.4,0.2,0.4]) % set position
dt = (median(diff(datx)));

[p1,f] = periodogram(daty,[],handles.pad,1/dt);  % power of dat
% remove AR1 noise
if red == 0
    theored = p1;
    p = p1;
elseif red == 2
    [theored]=theoredar1ML(daty,f,mean(p1),dt);
    p = p1 ./ theored;
    p = p - 1;
    p(p<0) = 0;   % power removing AR(1) noise
elseif red == 1
    [theored]=theoredar1ML(daty,f,mean(p1),dt);
    p = p1 - theored;
    p(p<0) = 0;   % power removing AR(1) noise
elseif red == 3
    % robust
    theored = redconf_any(f,p1,dt,0.25,2);
    p = p1 - theored;
    p(p<0) = 0;   % power removing AR(1) noise
end
ax1 = subplot(2,1,1);
plot(ax1,f,p1,'k','LineWidth',1);
hold on;
plot(ax1,f,theored,'r','LineWidth',2)
if lang_choice > 0
    [~, locb] = ismember('main14',lang_id);
    main14 = lang_var{locb};
    [~, locb] = ismember('main46',lang_id);
    main46 = lang_var{locb};
end
if lang_choice == 0
    xlabel(ax1,'Frequency');ylabel(ax1,'Power');title('raw periodogram (& red noise)')
else
    xlabel(ax1,main14);ylabel(ax1,main46);title(ec35)
end
xlim([0 max(f)])
ax2 = subplot(2,1,2);
plot(ax2,f,p,'k','LineWidth',1);
if lang_choice == 0
    xlabel(ax2,'Frequency');ylabel(ax2,'Power');title('red noise removed ?')
else
    xlabel(ax2,main14);ylabel(ax2,main46);title(ec36)
end
xlim([0 max(f)])

handles.fmaxdata = max(f);
set(handles.edit4, 'String', num2str(max(f)))
if lang_choice>0
    % language
    handles.lang_choice = lang_choice;
    handles.lang_id = lang_id;
    handles.lang_var = lang_var;
end
% Update handles structure
guidata(hObject, handles);

% throw out warning window
try figure(hwarn)
catch
end
try figure(hwarn1)
catch
end
% UIWAIT makes eCOCOGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eCOCOGUI_OutputFcn(hObject, eventdata, handles) 
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
if get(hObject,'Value')
    set(handles.radiobutton2,'Value',0)
    
    if handles.lang_choice==0
        set(handles.checkbox6,'String','0 padding')
    else
        [~, locb1] = ismember('ec08',handles.lang_id);
        lang_var = handles.lang_var;
        set(handles.checkbox6,'String',lang_var{locb1})
    end   
    
    
    % adjust padding
    % set zeropadding
    if handles.npts <= 2500
        handles.pad = 5000;
    elseif handles.npts <= 5000 && handles.npts > 2500
        handles.pad = 10000;
    else
        handles.pad = fix(handles.npts/5000) * 5000 + 5000;
        disp(fix(handles.npts/5000) * 5000 + 5000)
    end
    set(handles.edit12,'String',num2str(handles.pad))
    set(handles.checkbox1,'Visible','off')
    set(handles.popupmenu1,'Visible','off')
    set(handles.checkbox5,'Visible','off')
    set(handles.edit13,'Enable','on')
    set(handles.uibuttongroup6,'Visible','off')
    set(handles.pushbutton2,'Visible','off') % 
    set(handles.pushbutton3,'Visible','off') %
end
handles.ecocoS = 0;
guidata(hObject, handles);


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
if get(hObject,'Value')
    set(handles.radiobutton1,'Value',0)
    
    if handles.lang_choice==0
        set(handles.checkbox6,'String','0 padding')
    else
        [~, locb1] = ismember('ec08',handles.lang_id);
        lang_var = handles.lang_var;
        set(handles.checkbox6,'String',lang_var{locb1})
    end   
    nptsi = round(handles.window/handles.dt*100);
    % adjust padding
    % set zeropadding
    if nptsi <= 2500
        handles.pad = 5000;
    elseif nptsi <= 5000 && nptsi > 2500
        handles.pad = 10000;
    else
        handles.pad = fix(nptsi/5000) * 5000 + 5000;
    end
    set(handles.edit12,'String',num2str(handles.pad))
    set(handles.checkbox1,'Visible','on')
    set(handles.popupmenu1,'Visible','on')
    set(handles.checkbox5,'Visible','on')
    set(handles.edit13,'Enable','off')
    set(handles.uibuttongroup6,'Visible','on')
    
    set(handles.pushbutton2,'Visible','on') % 
    set(handles.pushbutton3,'Visible','on') %
end
handles.ecocoS = 1;
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
    handles.time_0pad = 1;
    set(handles.popupmenu1,'Enable','on')
    dat = zeropad2(handles.datbackup,handles.window,handles.padtype);
    handles.dat = dat;
    try figure(handles.ecocofigdata)
        if handles.flipy == 1
            plot(fliplr(dat(:,2)),dat(:,1),'k')
        else
            plot(dat(:,2),dat(:,1),'k')
        end
        xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
        ylim([min(dat(:,1)),max(dat(:,1))]);
    catch
        handles.ecocofigdata = figure;
        set(0,'Units','normalized') % set units as normalized
        set(gcf,'units','norm') % set location
        set(gcf,'color','w');
        set(handles.ecocofigdata,'position',[0.01,0.01,0.2,0.9]) % set position
        if handles.flipy == 1
            plot(fliplr(dat(:,2)),dat(:,1),'k')
        else
            plot(dat(:,2),dat(:,1),'k')
        end
        ylim([min(dat(:,1)),max(dat(:,1))]);
        if handles.lang_choice==0
            xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
        else
            [~, locb1] = ismember('main24',handles.lang_id);
            [~, locb2] = ismember('main23',handles.lang_id);
            lang_var = handles.lang_var;
            xlabel(lang_var{locb1}); ylabel([lang_var{locb2},' (',handles.unit,')'])
        end
    end
else
    handles.time_0pad = 0;
    set(handles.popupmenu1,'Enable','off')
    try figure(handles.ecocofigdata)
        if handles.flipy == 1
            plot(fliplr(dat(:,2)),dat(:,1),'k')
        else
            plot(dat(:,2),dat(:,1),'k')
        end

        if handles.lang_choice==0
            xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
        else
            [~, locb1] = ismember('main24',handles.lang_id);
            [~, locb2] = ismember('main23',handles.lang_id);
            lang_var = handles.lang_var;
            xlabel(lang_var{locb1}); ylabel([lang_var{locb2},' (',handles.unit,')'])
        end
        ylim([min(dat(:,1)),max(dat(:,1))]);
    catch
        handles.ecocofigdata = figure;
        set(0,'Units','normalized') % set units as normalized
        set(gcf,'units','norm') % set location
        set(gcf,'color','w');
        set(handles.ecocofigdata,'position',[0.01,0.01,0.2,0.9]) % set position
        if handles.flipy == 1
            plot(fliplr(dat(:,2)),dat(:,1),'k')
        else
            plot(dat(:,2),dat(:,1),'k')
        end
        ylim([min(dat(:,1)),max(dat(:,1))]);
        if handles.lang_choice==0
            xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
        else
            [~, locb1] = ismember('main24',handles.lang_id);
            [~, locb2] = ismember('main23',handles.lang_id);
            lang_var = handles.lang_var;
            xlabel(lang_var{locb1}); ylabel([lang_var{locb2},' (',handles.unit,')'])
        end
    end

end
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
try figure(handles.ecocofigdata)
    if handles.flipy == 1
        plot(fliplr(dat(:,2)),dat(:,1),'k')
    else
        plot(dat(:,2),dat(:,1),'k')
    end
    
    if handles.lang_choice==0
        xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
    else
        [~, locb1] = ismember('main24',handles.lang_id);
        [~, locb2] = ismember('main23',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(lang_var{locb1}); ylabel([lang_var{locb2},' (',handles.unit,')'])
    end
    ylim([min(dat(:,1)),max(dat(:,1))]);
catch
    handles.ecocofigdata = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'color','w');
    set(handles.ecocofigdata,'position',[0.01,0.01,0.2,0.9]) % set position
    if handles.flipy == 1
        plot(fliplr(dat(:,2)),dat(:,1),'k')
    else
        plot(dat(:,2),dat(:,1),'k')
    end
    ylim([min(dat(:,1)),max(dat(:,1))]);
    if handles.lang_choice==0
        xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
    else
        [~, locb1] = ismember('main24',handles.lang_id);
        [~, locb2] = ismember('main23',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(lang_var{locb1}); ylabel([lang_var{locb2},' (',handles.unit,')'])
    end
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


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.sedmin = str2double(get(hObject,'String'));
set(handles.edit1,'String',num2str(handles.sedmin))
set(handles.edit2,'String',num2str(handles.sedmax))
set(handles.edit3,'String',num2str(handles.sedstep))
% test sed. rate info

sr = handles.sedmin:handles.sedstep:handles.sedmax;
if handles.lang_choice==0
    sedinfo = [num2str(length(sr)),' test sed. rates: ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
else
    [~, locb1] = ismember('ec33',handles.lang_id);
    lang_var = handles.lang_var;
    sedinfo = [num2str(length(sr)),lang_var{locb1},num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
end
    
set(handles.text7,'String',sedinfo)
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
handles.sedmax = str2double(get(hObject,'String'));
set(handles.edit1,'String',num2str(handles.sedmin))
set(handles.edit2,'String',num2str(handles.sedmax))
set(handles.edit3,'String',num2str(handles.sedstep))
% test sed. rate info

sr = handles.sedmin:handles.sedstep:handles.sedmax;
if handles.lang_choice==0
    sedinfo = [num2str(length(sr)),' test sed. rates: ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
else
    [~, locb1] = ismember('ec33',handles.lang_id);
    lang_var = handles.lang_var;
    sedinfo = [num2str(length(sr)),lang_var{locb1},num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
end

set(handles.text7,'String',sedinfo)
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
handles.sedstep = str2double(get(hObject,'String'));
set(handles.edit1,'String',num2str(handles.sedmin))
set(handles.edit2,'String',num2str(handles.sedmax))
set(handles.edit3,'String',num2str(handles.sedstep))
% test sed. rate info

sr = handles.sedmin:handles.sedstep:handles.sedmax;
if handles.lang_choice==0
    sedinfo = [num2str(length(sr)),' test sed. rates: ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
else
    [~, locb1] = ismember('ec33',handles.lang_id);
    lang_var = handles.lang_var;
    sedinfo = [num2str(length(sr)),lang_var{locb1},num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
end

set(handles.text7,'String',sedinfo)

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


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
%
handles.fmaxdata = str2double(get(hObject,'String'));
if get(handles.checkbox4,'Value')
    red = get(handles.popupmenu3,'Value');
else
    red = 0;
end
dat = handles.dat;
datx = dat(:,1);
daty = dat(:,2);
try figure(handles.ecocofigspectrum)
    handles.fmaxdata = str2double(get(hObject,'String'));
    subplot(2,1,1);xlim([0, handles.fmaxdata])
    subplot(2,1,2);xlim([0, handles.fmaxdata])
catch
    handles.ecocofigspectrum = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'color','w');
    set(handles.ecocofigspectrum,'position',[0.2,0.4,0.2,0.4]) % set position
    dt = (median(diff(datx)));
    [p1,f] = periodogram(daty,[],handles.pad,1/dt);  % power of dat
    % remove AR1 noise
    if red == 0
        theored = p1;
        p = p1;
    elseif red == 2
        [theored]=theoredar1ML(daty,f,mean(p1),dt);
        p = p1 ./ theored;
        p = p - 1;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 1
        [theored]=theoredar1ML(daty,f,mean(p1),dt);
        p = p1 - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 3
        % robust
        theored = redconf_any(f,p1,dt,0.25,2);
        p = p1 - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    end
    ax1 = subplot(2,1,1);
    plot(ax1,f,p1,'k','LineWidth',1);
    hold on;
    plot(ax1,f,theored,'r','LineWidth',2)
    
    if handles.lang_choice==0
        xlabel(ax1,'Frequency');ylabel(ax1,'Power');title('raw periodogram (& red noise)')
    else
        [~, locb1] = ismember('main14',handles.lang_id);
        [~, locb2] = ismember('main46',handles.lang_id);
        [~, locb3] = ismember('ec35',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(ax1,lang_var{locb1});ylabel(ax1,lang_var{locb2});title(lang_var{locb3})
    end
        
    xlim([0, handles.fmaxdata])
    ax2 = subplot(2,1,2);
    plot(ax2,f,p,'k','LineWidth',1);
    if handles.lang_choice==0
        xlabel(ax2,'Frequency');ylabel(ax2,'Power');title('red noise removed ?')
    else
        [~, locb1] = ismember('main14',handles.lang_id);
        [~, locb2] = ismember('main46',handles.lang_id);
        [~, locb3] = ismember('ec36',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(ax2,lang_var{locb1});ylabel(ax2,lang_var{locb2});title(lang_var{locb3})
    end
    
    %set(ax2, 'YScale', 'log')
    xlim([0, handles.fmaxdata])
    
end
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


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
handles.red = get(hObject,'Value');
if get(handles.checkbox4,'Value')
    red = get(handles.popupmenu3,'Value');
else
    red = 0;
end
handles.red = red;
if handles.red > 0
    try close(handles.ecocofigspectrum)
    catch
    end
    dat = handles.dat;
    
    datx = dat(:,1);
    daty = dat(:,2);
    handles.ecocofigspectrum = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'color','w');
    set(handles.ecocofigspectrum,'position',[0.2,0.4,0.2,0.4]) % set position
    dt = (median(diff(datx)));
    [p1,f] = periodogram(daty,[],handles.pad,1/dt);  % power of dat
    % remove AR1 noise
    if red == 0
        theored = p1;
        p = p1;
    elseif red == 2
        [theored]=theoredar1ML(daty,f,mean(p1),dt);
        p = p1 ./ theored;
        p = p - 1;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 1
        [theored]=theoredar1ML(daty,f,mean(p1),dt);
        p = p1 - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 3
        % robust
        theored = redconf_any(f,p1,dt,0.25,2);
        p = p1 - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    end
    ax1 = subplot(2,1,1);
    plot(ax1,f,p1,'k','LineWidth',1);
    hold on;
    plot(ax1,f,theored,'r','LineWidth',2)
    
    if handles.lang_choice==0
        xlabel(ax1,'Frequency');ylabel(ax1,'Power');title('raw periodogram (& red noise)')
    else
        [~, locb1] = ismember('main14',handles.lang_id);
        [~, locb2] = ismember('main46',handles.lang_id);
        [~, locb3] = ismember('ec35',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(ax1,lang_var{locb1});ylabel(ax1,lang_var{locb2});title(lang_var{locb3})
    end   
    
    xlim([0, handles.fmaxdata])
    ax2 = subplot(2,1,2);
    plot(ax2,f,p,'k','LineWidth',1);
    if handles.lang_choice==0
        xlabel(ax2,'Frequency');ylabel(ax2,'Power');title('red noise removed ?')
    else
        [~, locb1] = ismember('main14',handles.lang_id);
        [~, locb2] = ismember('main46',handles.lang_id);
        [~, locb3] = ismember('ec36',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(ax2,lang_var{locb1});ylabel(ax2,lang_var{locb2});title(lang_var{locb3})
    end
    xlim([0, handles.fmaxdata])
else
    try close(handles.ecocofigspectrum)
    catch
    end
    dat = handles.dat;
    
    datx = dat(:,1);
    daty = dat(:,2);
    handles.ecocofigspectrum = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'color','w');
    set(handles.ecocofigspectrum,'position',[0.2,0.4,0.2,0.4]) % set position
    dt = (median(diff(datx)));
    [p1,f] = periodogram(daty,[],handles.pad,1/dt);  % power of dat
    % remove AR1 noise
    if red == 0
        theored = p1;
        p = p1;
    elseif red == 2
        [theored]=theoredar1ML(daty,f,mean(p1),dt);
        p = p1 ./ theored;
        p = p - 1;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 1
        [theored]=theoredar1ML(daty,f,mean(p1),dt);
        p = p1 - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 3
        % robust
        theored = redconf_any(f,p1,dt,0.25,2);
        p = p1 - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    end
    ax1 = subplot(2,1,1);
    plot(ax1,f,p1,'k','LineWidth',1);
    hold on;
    plot(ax1,f,theored,'r','LineWidth',2)
    if handles.lang_choice==0
        xlabel(ax1,'Frequency');ylabel(ax1,'Power');
    else
        [~, locb1] = ismember('main14',handles.lang_id);
        [~, locb2] = ismember('main46',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(ax1,lang_var{locb1});ylabel(ax1,lang_var{locb2});
    end

    xlim([0, handles.fmaxdata])

    ax2 = subplot(2,1,2);
    plot(ax2,f,p,'k','LineWidth',1);
    if handles.lang_choice==0
        xlabel(ax2,'Frequency');ylabel(ax2,'Power');
    else
        [~, locb1] = ismember('main14',handles.lang_id);
        [~, locb2] = ismember('main46',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(ax2,lang_var{locb1});ylabel(ax2,lang_var{locb2});
    end
    xlim([0, handles.fmaxdata])
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox4.
function checkbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
if get(handles.checkbox4,'Value')
    red = get(handles.popupmenu3,'Value');
else
    red = 0;
end
handles.red = red;
if handles.red > 0
    try close(handles.ecocofigspectrum)
    catch
    end
    dat = handles.dat;
    
    datx = dat(:,1);
    daty = dat(:,2);
    handles.ecocofigspectrum = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'color','w');
    set(handles.ecocofigspectrum,'position',[0.2,0.4,0.2,0.4]) % set position
    dt = (median(diff(datx)));
    [p1,f] = periodogram(daty,[],handles.pad,1/dt);  % power of dat
    % remove AR1 noise
    if red == 0
        theored = p1;
        p = p1;
    elseif red == 2
        [theored]=theoredar1ML(daty,f,mean(p1),dt);
        p = p1 ./ theored;
        p = p - 1;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 1
        [theored]=theoredar1ML(daty,f,mean(p1),dt);
        p = p1 - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 3
        % robust
        theored = redconf_any(f,p1,dt,0.25,2);
        p = p1 - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    end
    ax1 = subplot(2,1,1);
    plot(ax1,f,p1,'k','LineWidth',1);
    hold on;
    plot(ax1,f,theored,'r','LineWidth',2)
    if handles.lang_choice==0
        xlabel(ax1,'Frequency');ylabel(ax1,'Power');
    else
        [~, locb1] = ismember('main14',handles.lang_id);
        [~, locb2] = ismember('main46',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(ax1,lang_var{locb1});ylabel(ax1,lang_var{locb2});
    end

    xlim([0, handles.fmaxdata])

    ax2 = subplot(2,1,2);
    plot(ax2,f,p,'k','LineWidth',1);
    if handles.lang_choice==0
        xlabel(ax2,'Frequency');ylabel(ax2,'Power');
    else
        [~, locb1] = ismember('main14',handles.lang_id);
        [~, locb2] = ismember('main46',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(ax2,lang_var{locb1});ylabel(ax2,lang_var{locb2});
    end
    %set(ax2, 'YScale', 'log')
    xlim([0, handles.fmaxdata])
    
end
% Update handles structure
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



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
age = str2double(get(hObject,'String'));
if age> 250
    f2  = 0.08;
    handles.f2 = f2;
    set(handles.edit7,'String',num2str(f2))
end
handles.age = age;
if age < 0
    if handles.lang_choice==0
        errordlg('Error: Age of the data must be no smaller than 0')
    else
        [~, locb1] = ismember('ec37',handles.lang_id);
        lang_var = handles.lang_var;
        errordlg(lang_var{locb1})
    end
    return;
elseif age == 0 
    age = .001;
elseif age > 4000
    if handles.lang_choice==0
        errordlg('Error: Age of the data is too large')
    else
        [~, locb1] = ismember('ec38',handles.lang_id);
        lang_var = handles.lang_var;
        errordlg(lang_var{locb1})
    end
    
end
if age > 0
    o7 = getBerger89Period(age);
end
orbit7 = [num2str(o7(1),'% .1f'),' ',num2str(o7(2),'% .1f'),' ',...
    num2str(o7(3),'% .1f'),' ',num2str(o7(4),'% .1f'),' ',...
    num2str(o7(5),'% .1f'),' ',num2str(o7(6),'% .1f'),' ',num2str(o7(7),'% .1f')];
set(handles.text20,'String',orbit7)

if get(handles.radiobutton6,'Value')
    handles.orbit7 = o7;
end

% Ages for orbit7, equations follow Yao et al., 2015
% EPSL and Laskar et al., 2004 A&A
age_obl = 41 - 0.0332 * age;
age_p1 = 22.43 - 0.0108 * age;
age_p2 = 23.75 - 0.0121 * age;
age_p3 = 19.18 - 0.0079 * age;
o7 = [405 125 95 age_obl age_p2 age_p1 age_p3];
orbit7 = [num2str(o7(1),'% .1f'),' ',num2str(o7(2),'% .1f'),' ',...
    num2str(o7(3),'% .1f'),' ',num2str(o7(4),'% .1f'),' ',...
    num2str(o7(5),'% .1f'),' ',num2str(o7(6),'% .1f'),' ',num2str(o7(7),'% .1f')];
set(handles.text21,'String',orbit7)

[daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max, p1min, p1max,...
    p2min, p2max, p3min, p3max, p4min, p4max] = MilankovitchCal(age);
age_obl = 0.5 * (o1min + o1max);
age_p2 = 0.5 * (p1min + p1max); 
age_p1 = 0.5 * (p2min + p2max); 
age_p3 = 0.5 * (p3min + p3max);
o7waltham = [405 125 95 age_obl age_p2 age_p1 age_p3];
orbit7waltham = [num2str(o7waltham(1),'% .1f'),' ',num2str(o7waltham(2),'% .1f'),' ',...
    num2str(o7waltham(3),'% .1f'),' ',num2str(o7waltham(4),'% .1f'),' ',...
    num2str(o7waltham(5),'% .1f'),' ',num2str(o7waltham(6),'% .1f'),' ',num2str(o7waltham(7),'% .1f')];
set(handles.edit11,'String',orbit7waltham)

if get(handles.radiobutton7,'Value')
    handles.orbit7  = o7;    
end

if get(handles.radiobutton8,'Value')
    handles.orbit7 = strread(get(handles.edit11,'String'));
end
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



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
handles.f2 = str2double(get(hObject,'String'));
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



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
handles.nsim = str2double(get(hObject,'String'));
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



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
handles.window = str2double(get(hObject,'String'));

dat = zeropad2(handles.datbackup,handles.window,handles.padtype);
handles.dat = dat;
try figure(handles.ecocofigdata)
    if handles.flipy == 1
        plot(fliplr(dat(:,2)),dat(:,1),'k')
    else
        plot(dat(:,2),dat(:,1),'k')
    end
    if handles.lang_choice==0
        xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
    else
        [~, locb1] = ismember('main24',handles.lang_id);
        [~, locb2] = ismember('main23',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(lang_var{locb1}); ylabel([lang_var{locb2},' (',handles.unit,')'])
    end
    ylim([min(dat(:,1)),max(dat(:,1))]);
catch
    handles.ecocofigdata = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'color','w');
    set(handles.ecocofigdata,'position',[0.01,0.01,0.2,0.9]) % set position
    if handles.flipy == 1
        plot(fliplr(dat(:,2)),dat(:,1),'k')
    else
        plot(dat(:,2),dat(:,1),'k')
    end
    ylim([min(dat(:,1)),max(dat(:,1))]);

    if handles.lang_choice==0
        xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
    else
        [~, locb1] = ismember('main24',handles.lang_id);
        [~, locb2] = ismember('main23',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(lang_var{locb1}); ylabel([lang_var{locb2},' (',handles.unit,')'])
    end
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



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
handles.step = str2double(get(hObject,'String'));
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


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5

handles.flipy = get(hObject,'Value');

dat = handles.dat;
try figure(handles.ecocofigdata)
    if handles.flipy == 0
        set(gca, 'YDir','reverse')
    else
        set(gca, 'YDir','normal')
    end
catch
    handles.ecocofigdata = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'color','w');
    set(handles.ecocofigdata,'position',[0.01,0.01,0.2,0.9]) % set position
    if handles.flipy == 1
        plot(fliplr(dat(:,2)),dat(:,1),'k')
    else
        plot(dat(:,2),dat(:,1),'k')
    end
    ylim([min(dat(:,1)),max(dat(:,1))]);
    
    if handles.lang_choice==0
        xlabel('Value'); ylabel(['Depth (',handles.unit,')'])
    else
        [~, locb1] = ismember('main24',handles.lang_id);
        [~, locb2] = ismember('main23',handles.lang_id);
        lang_var = handles.lang_var;
        xlabel(lang_var{locb1}); ylabel([lang_var{locb2},' (',handles.unit,')'])
    end
end

guidata(hObject, handles);


function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
if get(handles.radiobutton8,'Value')
    handles.orbit7 = strread(get(handles.edit11,'String'));
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


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double
handles.pad = str2double(get(hObject,'String'));
if handles.pad < 2000
    handles.pad = 2000;
    if handles.lang_choice==0
        warndlg('Padding number changed to 2000')
    else
        [~, locb1] = ismember('ec39',handles.lang_id);
        lang_var = handles.lang_var;
        warndlg(lang_var{locb1})
    end
    
    set(handles.edit12,'String',num2str(handles.pad))
end
guidata(hObject, handles);


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
handles.slices = str2double(get(hObject,'String'));
guidata(hObject, handles);

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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = handles.dat;
srm = mean(diff(data(:,1))); % well, might dt
npts = handles.npts;
t1 = 1000 * handles.age;
f1 = 0.0;
f2 = handles.f2;
pad = handles.pad;
p1 = 1;  % weight of eccentricity
p2 = .6;  % weight of obliquity
p3 = .5;  % weight of precession
[dat_dir,dat_name,ext] = fileparts(handles.filename);
handles.ext = ext;
%
orbit7 = handles.orbit7;
target = period2spectrum(orbit7,t1-1000,t1+1000,1,f1,f2,1,pad);
if get(handles.radiobutton6,'Value')
    % berger89
    target = period2spectrumB(orbit7,t1-1000,t1+1000,1,f1,f2,1,pad);
end
if get(handles.radiobutton7,'Value')
    if t1 > 249000
        target = period2spectrum(orbit7,t1-1000,t1+1000,1,f1,f2,1,pad);
    else
        % la04
        if and(t1 <= 248000,t1 > 1000)
            target = gentarget(4,t1-1000,t1+1000,f1,f2,p1,p2,p3,pad,1);
        elseif t1 > 248000
            target = gentarget(4,247000,249000,f1,f2,p1,p2,p3,pad,1);
        elseif t1 <= 1000
            target = gentarget(4,1,2000,f1,f2,p1,p2,p3,pad,1);
        end
    end
end
%
sr1 = handles.sedmin;
sr2 = handles.sedmax;
srstep = handles.sedstep;
adjust = 0; % no adjust weight of etp
nsim = handles.nsim;
red = handles.red;
plotn = 1; % yes, plot figure
slices = handles.slices;
corrmethod = handles.corrmethod;
if corrmethod == 1
    method = 'Pearson';
else
    method = 'Spearman';
end

if handles.lang_choice>0
    lang_var = handles.lang_var;
    [~, locb] = ismember('ec40',handles.lang_id);
    ec40 = lang_var{locb};
    [~, locb] = ismember('ec41',handles.lang_id);
    ec41 = lang_var{locb};
    [~, locb] = ismember('ec42',handles.lang_id);
    ec42 = lang_var{locb};
    [~, locb] = ismember('ec43',handles.lang_id);
    ec43 = lang_var{locb};
    [~, locb] = ismember('ec44',handles.lang_id);
    ec44 = lang_var{locb};
    [~, locb] = ismember('ec45',handles.lang_id);
    ec45 = lang_var{locb};
    [~, locb] = ismember('ec46',handles.lang_id);
    ec46 = lang_var{locb};
    [~, locb] = ismember('main46',handles.lang_id);
    main46 = lang_var{locb};
    
    
    [~, locb] = ismember('dd38',handles.lang_id);
    dd38 = lang_var{locb};
    [~, locb] = ismember('dd39',handles.lang_id);
    dd39 = lang_var{locb};
    [~, locb] = ismember('dd40',handles.lang_id);
    dd40 = lang_var{locb};
    [~, locb] = ismember('dd41',handles.lang_id);
    dd41 = lang_var{locb};
    [~, locb] = ismember('main31',handles.lang_id);
    main31 = lang_var{locb};
end
if handles.lang_choice==0 
    disp('>> Wait ...')
else
    disp(ec40)
end
if handles.ecocoS == 0
    % COCO model
    tic
    f = figure;
    set(gcf,'color','w');
    ax1 = subplot(2,1,1);
    plot(ax1,target(:,1),target(:,2),'LineWidth',1)
    xlim(ax1,[f1 f2])
    set(ax1,'XMinorTick','on','YMinorTick','on')
    if handles.lang_choice==0 
        xlabel(ax1,'Frequency (cycle/kyr)')
        ylabel(ax1,'Power')
        title(ax1,'Target power spectrum')
    else
        xlabel(ax1,ec41)
        ylabel(ax1,main46)
        title(ax1,ec42)
    end
    %
    data = handles.datbackup;
    [corrCI,corr_h0,corry] = corrcoefslices_rank(data,target,orbit7,srm,pad,sr1,sr2,srstep,adjust,red,nsim,plotn,slices,method);
    toc
else
    % eCOCO model
    window = handles.window;
    stepM = handles.step;  % this 
    step = round(stepM/srm); % sliding step in meter to sliding step in number
    delinear = 0;
    slices = 1;
    time_0pad = handles.time_0pad;
    handles.padedgestyle = get(handles.popupmenu1,'Value');
    if handles.lang_choice==0 
        if time_0pad == 1
            if handles.padedgestyle == 1
                padedgemodel = 'zero';
            elseif handles.padedgestyle == 2
                padedgemodel = 'mirror';
            elseif handles.padedgestyle == 3
                padedgemodel = 'mean';
            elseif handles.padedgestyle == 4
                padedgemodel = 'random';
            end
            data = zeropad2(handles.datbackup,handles.window,handles.padtype);
        else
            padedgemodel = 'no';
            data = handles.datbackup;
        end
    else
        if time_0pad == 1
            if handles.padedgestyle == 1
                padedgemodel = dd38;
            elseif handles.padedgestyle == 2
                padedgemodel = dd39;
            elseif handles.padedgestyle == 3
                padedgemodel = dd40;
            elseif handles.padedgestyle == 4
                padedgemodel = dd41;
            end
            data = zeropad2(handles.datbackup,handles.window,handles.padtype);
        else
            padedgemodel = main31;
            data = handles.datbackup;
        end
        
    end
    tic
    [prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,sr_p] = ...
        ecoco(data,target,orbit7,window,srm,step,delinear,red,pad,sr1,sr2,srstep,nsim,adjust,slices,plotn);
    toc
end
if handles.lang_choice==0 
    % for output
    if red == 0
        redmodel = 'no';
    elseif red == 2
        redmodel = 'classic AR1 removed (F./Fred - 1)';
    elseif red == 1
        redmodel = 'classic AR1 removed (F - Fred)';
    elseif red == 3
        redmodel = 'robust AR1 removed (F - Fred)';
    end
else
    if red == 0
        redmodel = main31;
    elseif red == 2
        redmodel = ec43;
    elseif red == 1
        redmodel = ec44;
    elseif red == 3
        redmodel = ec45;
    end
end
if get(handles.radiobutton6,'Value')
    solutionmodel = 'Berger89';
end
if get(handles.radiobutton7,'Value')
    solutionmodel = 'Laskar04';
end
if get(handles.radiobutton8,'Value')
    if handles.lang_choice==0 
        solutionmodel = 'User-defined';
    else
        solutionmodel = ec46;
    end
end
if handles.lang_choice==0 
    param1 = ['Data',': ',num2str(data(1,1)),' to ',num2str(data(end,1)),'m. Sampling rate: ', num2str(srm),'. Number of data points: ', num2str(npts)];
    param2 = ['Data: Number of slices is ', num2str(slices),'. Number of simulations is ',num2str(nsim)];
    param3 = ['Data: Remove red noise model: ',num2str(redmodel),'. Correlation method: ',method];
    param5 = ['Tested sedimentation rate step is ', num2str(srstep),' cm/kyr from ',num2str(sr1),' to ',num2str(sr2),' cm/kyr'];
    param6 = ['Target age is ',num2str(t1),' ka. Zero padding is ',num2str(pad), '. Freq. is ',num2str(f1),'-',num2str(f2),' cycles/kyr'];
    param7 = ['Astronomical solution: ', solutionmodel];
    param8 = ['Astronomical cycles are: ',num2str(orbit7)];

    if handles.ecocoS == 0
        param4 = ['Zero padding for the data is ',num2str(pad)];
    else
        handles.padedgestyle = get(handles.popupmenu1,'Value');
        param4 = ['Zero padding for each window is ',num2str(pad),'; Zero padding for the edge of data: ',padedgemodel];
    end
else

    lang_var = handles.lang_var;
    [~, locb] = ismember('main02',handles.lang_id);
    main02 = lang_var{locb};
    [~, locb] = ismember('main17',handles.lang_id);
    main17 = lang_var{locb};
    [~, locb] = ismember('main16',handles.lang_id);
    main16 = lang_var{locb};
    [~, locb] = ismember('menu46',handles.lang_id);
    menu46 = lang_var{locb};
    [~, locb] = ismember('ec47',handles.lang_id);
    ec47 = lang_var{locb};
    [~, locb] = ismember('ec49',handles.lang_id);
    ec49 = lang_var{locb};
    [~, locb] = ismember('ec48',handles.lang_id);
    ec48 = lang_var{locb};
    [~, locb] = ismember('ec50',handles.lang_id);
    ec50 = lang_var{locb};


    [~, locb] = ismember('ec51',handles.lang_id);
    ec51 = lang_var{locb};
    [~, locb] = ismember('ec52',handles.lang_id);
    ec52 = lang_var{locb};
    [~, locb] = ismember('ec53',handles.lang_id);
    ec53 = lang_var{locb};
    [~, locb] = ismember('ec54',handles.lang_id);
    ec54 = lang_var{locb};
    [~, locb] = ismember('ec55',handles.lang_id);
    ec55 = lang_var{locb};
    [~, locb] = ismember('ec56',handles.lang_id);
    ec56 = lang_var{locb};
    [~, locb] = ismember('ec57',handles.lang_id);
    ec57 = lang_var{locb};
    [~, locb] = ismember('ec58',handles.lang_id);
    ec58 = lang_var{locb};
    [~, locb] = ismember('a222',handles.lang_id);
    a222 = lang_var{locb};
    [~, locb] = ismember('main14',handles.lang_id);
    main14 = lang_var{locb};
    [~, locb] = ismember('menu51',handles.lang_id);
    menu51 = lang_var{locb};


    param1 = [main02,': ',num2str(data(1,1)),main17,num2str(data(end,1)),'m. ',menu46,': ', num2str(srm),ec47, num2str(npts)];
    param2 = [main02,ec48, num2str(slices),'. ',ec49,num2str(nsim)];
    param3 = [main02,': ',ec50,': ',num2str(redmodel),'. ',ec51,': ',method];
    param5 = [ec52, num2str(srstep),' cm/kyr ',main16,num2str(sr1),main17,num2str(sr2),' cm/kyr'];
    param6 = [ec53,num2str(t1),' ka. ',a222,num2str(pad), '. ',main14,num2str(f1),'-',num2str(f2),ec54];
    param7 = [menu51,': ', solutionmodel];
    param8 = [ec55,': ',num2str(orbit7)];

    if handles.ecocoS == 0
        param4 = [ec56,num2str(pad)];
    else
        handles.padedgestyle = get(handles.popupmenu1,'Value');
        param4 = [ec57,num2str(pad),'; ',ec58,': ',padedgemodel];
    end
end
CDac_pwd;
if handles.ecocoS == 0
    
    % Log name
    log_name = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-COCO-log',ext];
    log_name_coco = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-COCO.fig'];
    if exist([pwd,handles.slash_v,log_name]) || exist([pwd,handles.slash_v,log_name_coco])
        for i = 1:100
            log_name = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-COCO-log-',num2str(i),ext];
            log_name_coco = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-COCO-',num2str(i),'.fig'];
            if exist([pwd,handles.slash_v,log_name]) || exist([pwd,handles.slash_v,log_name_coco])
            else
                break
            end
        end
    end
    savefig(log_name_coco) % save ac.fig automatically
    
else
    % Log name
    log_name = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-',num2str(window),'win-ECOCO-log',ext];
    acfig_name = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-',num2str(window),'win-ECOCO.AC.fig'];
    savefile_name =[dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-',num2str(window),'win-ECOCO.Optimal',ext];
    if exist([pwd,handles.slash_v,acfig_name]) || exist([pwd,handles.slash_v,log_name]) || exist([pwd,handles.slash_v,savefile_name])
        for i = 1:100
            acfig_name = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-',num2str(window),'win-ECOCO-',num2str(i),'.AC.fig'];
            log_name   = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-',num2str(window),'win-ECOCO-',num2str(i),'.log',ext];
            savefile_name =[dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-',num2str(window),'win-ECOCO-',num2str(i),'.Optimal',ext];
            if exist([pwd,handles.slash_v,acfig_name]) || exist([pwd,handles.slash_v,log_name]) || exist([pwd,handles.slash_v,savefile_name])
            else
                break
            end
        end
    end
    
    %
    assignin('base','prt_sr',prt_sr)
    assignin('base','out_depth',out_depth)
    assignin('base','out_ecc',out_ecc)
    assignin('base','out_ep',out_ep)
    assignin('base','out_eci',out_eci)
    assignin('base','out_ecoco',out_ecoco)
    assignin('base','out_ecocorb',out_ecocorb)
    assignin('base','out_norbit',out_norbit)
end

% open and write log into log_name file
fileID = fopen(fullfile(dat_dir,log_name),'w+');
if handles.lang_choice==0 
    fprintf(fileID,'%s\n',' - - - - - - - - - - - - - Summary - - - - - - - - - - -');
else
    [~, locb] = ismember('ec59',handles.lang_id);
    ec59 = lang_var{locb};
    fprintf(fileID,'%s\n',ec59);
end
fprintf(fileID,'%s\n',datestr(datetime('now')));
fprintf(fileID,'%s\n',log_name);
fprintf(fileID,'%s\n',param1);
fprintf(fileID,'%s\n',param2);
fprintf(fileID,'%s\n',param3);
fprintf(fileID,'%s\n',param4);
fprintf(fileID,'%s\n',param5);
fprintf(fileID,'%s\n',param6);
fprintf(fileID,'%s\n',param7);
fprintf(fileID,'%s\n',param8);
if handles.lang_choice==0 
    fprintf(fileID,'%s\n',' - - - - - - - - - - - - - - End - - - - - - - - - - - -');
else
    [~, locb] = ismember('ec60',handles.lang_id);
    ec60 = lang_var{locb};
    fprintf(fileID,'%s\n',ec60);
end
fclose(fileID);
if handles.ecocoS == 1
    fileID = fopen(fullfile(dat_dir,savefile_name),'w+');
    if handles.lang_choice==0 
        fprintf(fileID,'%s\n','%location, Optimal Sed.Rate, CorrCoef, H0-SL, #Orbits, COCOxH0x#Orbits');   
    else
        [~, locb] = ismember('ec61',handles.lang_id);
        ec61 = lang_var{locb};
        fprintf(fileID,'%s\n',ec61);
    end
                     
    %fprintf(fileID,'%s\n\n',mat2str(sr_p));
    for row = 1: length(prt_sr)
        try
            fprintf(fileID,'%s, %s, %s, %s, %d, %s\n',sr_p(row,1),sr_p(row,2),sr_p(row,3),sr_p(row,4),sr_p(row,5),sr_p(row,6));
        catch
        end
    end
    fclose(fileID);
    figure(handles.hmain)
    savefig(acfig_name)
end

% update acycle main figure for both COCO and eCOCO
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
if handles.ecocoS == 1
    saveacfigyes = 1;
    figure(handles.acfigmain);
    disp('>>  *ECOCO.AC.fig file:')
    disp(acfig_name)
    disp('>>  *ECOCO-log.txt file:')
    disp(log_name)
    disp('>>  *ECOCO.Optimal.txt file:')
    disp(savefile_name)
end
cd(pre_dirML);

% display info
disp('')
if handles.lang_choice==0 
    disp(' - - - - - - - - - - - - - Summary - - - - - - - - - - -');
else
    [~, locb] = ismember('ec59',handles.lang_id);
    ec59 = lang_var{locb};
    disp(ec59);
end
disp(handles.filename);
disp(param1);
disp(param2);
disp(param3);
disp(param4);
disp(param5);
disp(param6);
disp(param7);
disp(param8);
if handles.lang_choice==0 
    disp(' - - - - - - - - - - - - - - End - - - - - - - - - - - -');
else
    [~, locb] = ismember('ec60',handles.lang_id);
    ec60 = lang_var{locb};
    disp(ec60);
end
if handles.lang_choice==0
    disp('>> Writing log file ...')
    disp('>> Done')
else
    [~, locb] = ismember('ec62',handles.lang_id);
    ec62 = lang_var{locb};
    [~, locb] = ismember('ec63',handles.lang_id);
    ec63 = lang_var{locb};
    disp(ec62)
    disp(ec63)
end

%
handles.t1 = t1/1000;
handles.f1 = f1;
handles.f2 = f2;
handles.sr1 = sr1;
handles.sr2 = sr2;
handles.srm = srm;
handles.srstep = srstep;
handles.nsim = nsim;
handles.red = red;
handles.adjust = adjust;
handles.slices = slices;
handles.target = target;
saveacfigyes = 1;
if handles.ecocoS == 1
    handles.window = window;
    handles.step = step;
    handles.prt_sr = prt_sr;
    handles.out_depth = out_depth;
    handles.out_ecc = out_ecc;
    handles.out_ep = out_ep;
    handles.out_eci = out_eci;
    handles.out_ecoco = out_ecoco;
    handles.out_ecocorb = out_ecocorb;
    handles.out_norbit = out_norbit;
end
set(handles.pushbutton2,'Enable','on') % 
set(handles.pushbutton3,'Enable','on') %

guidata(hObject, handles);


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8
if get(hObject,'Value')
    handles.orbit7 = strread(get(handles.edit11,'String'));
end


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
if get(hObject,'Value')
    if handles.age > 0
        handles.orbit7 = getBerger89Period(handles.age);
    end
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7
% Ages for orbit7, equations follow Yao et al., 2015
    % EPSL and Laskar et al., 2004 A&A      
age = handles.age;
age_obl = 41 - 0.0332 * age;
age_p1 = 22.43 - 0.0108 * age;
age_p2 = 23.75 - 0.0121 * age;
age_p3 = 19.18 - 0.0079 * age;
handles.orbit7 = [405 125 95 age_obl age_p2 age_p1 age_p3];
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9
if get(hObject,'Value')
    handles.corrmethod = 2; % 1= 'Pearson'; else = 'Spearman'
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10
if get(hObject,'Value')
    handles.corrmethod = 1; % 1= 'Pearson'; else = 'Spearman'
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.lang_choice==0 
    prompt = {'Plot: 1 = one fig; 2 = multi-figs; 3 = 3D figs; reverse Y-axis = (-1,-2,or -3)'};
    dlg_title = 'Plot eCOCO results';
else
    lang_var = handles.lang_var;
    [~, locb] = ismember('ec64',handles.lang_id);
    ec64 = lang_var{locb};
    [~, locb] = ismember('ec65',handles.lang_id);
    ec65 = lang_var{locb};
    
    prompt = {ec64};
    dlg_title = ec65;
end

num_lines = 1;
defaultans = {'1'};
options.Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
if ~isempty(answer)
    hwarn = warndlg('Wait, eCOCO plot ...');
    plotn = str2double(answer{1});
    [~] = ecocoplot(handles.prt_sr,handles.out_depth,...
    handles.out_ecc,handles.out_ep,handles.out_eci,handles.out_ecoco,handles.out_ecocorb,handles.out_norbit,plotn);
    try 
        close(hwarn)
    catch
    end
    
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.lang_choice==0 
    prompt = {'How many peaks within each window?',...
        'Threshold H0 significant level',...
        'Threshold correlation coefficient',...
        'Threshold number of orbital parameters',...
        'Threshold sedimentation rate searching radius',...
        'How many intervals to cut the series?',...
        'Plot? 1 = Yes, 0 = No',...
        'Optional: sedimentation rate ranges from',...
        'Optional: sedimentation rate ranges to'};
    dlg_title = 'Track optimal sedimentation rates';
else
    lang_var = handles.lang_var;
    [~, locb] = ismember('ec59',handles.lang_id);
    ec59 = lang_var{locb};
    [~, locb] = ismember('ec60',handles.lang_id);
    ec60 = lang_var{locb};
    [~, locb] = ismember('ec67',handles.lang_id);
    ec67 = lang_var{locb};
    [~, locb] = ismember('ec68',handles.lang_id);
    ec68 = lang_var{locb};
    [~, locb] = ismember('ec69',handles.lang_id);
    ec69 = lang_var{locb};
    [~, locb] = ismember('ec70',handles.lang_id);
    ec70 = lang_var{locb};
    [~, locb] = ismember('ec71',handles.lang_id);
    ec71 = lang_var{locb};
    [~, locb] = ismember('ec72',handles.lang_id);
    ec72 = lang_var{locb};
    [~, locb] = ismember('ec73',handles.lang_id);
    ec73 = lang_var{locb};
    [~, locb] = ismember('ec74',handles.lang_id);
    ec74 = lang_var{locb};
    [~, locb] = ismember('ec75',handles.lang_id);
    ec75 = lang_var{locb};
    [~, locb] = ismember('ec76',handles.lang_id);
    ec76 = lang_var{locb};
    [~, locb] = ismember('ec77',handles.lang_id);
    ec77 = lang_var{locb};
    [~, locb] = ismember('ec78',handles.lang_id);
    ec78 = lang_var{locb};
    
    prompt = {ec68,ec69,ec70,ec71,ec72,ec73,ec74,ec75,ec76};
    dlg_title = ec67;
end
    
num_lines = 1;
defaultans = {'3','5','0.3','4','2','3','1',num2str(handles.sr1),num2str(handles.sr2)};
options.Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
if ~isempty(answer)
    n = str2double(answer{1});
    ci = str2double(answer{2});
    corrcf = str2double(answer{3});
    sh_norb = str2double(answer{4});
    srsh = str2double(answer{5});
    srslice = str2double(answer{6});
    plotn = str2double(answer{7});
    sr1 = str2double(answer{8});
    sr2 = str2double(answer{9});

    %
    ecc = handles.out_ecc;  % matrix
    eci = handles.out_eci;  % matrix
    norbit = handles.out_norbit; % matrix
    ecoco = handles.out_ecoco;
    % cut using given sedimentation range
    srstep = handles.srstep;
    if or(sr1 ~= handles.sr1, sr2~= handles.sr2)
        %srshrange = round((sr1:srsh:sr2)/srstep);
        srsh_1 = round((sr1-handles.sr1)/srstep); % start number of selected sed. rate
        if srsh_1 == 0; srsh_1 = 1; end
        srsh_n = round(abs(sr2-sr1)/srstep); % end number of selected sed. rate
        ecc = ecc(srsh_1:srsh_n,:); % selected data
        eci = eci(srsh_1:srsh_n,:); % selected data
        norbit = norbit(srsh_1:srsh_n,:); % selected data
        ecoco = ecoco(srsh_1:srsh_n,:); % selected data
    end
    [Y] = ebrief(ecc,2,-2); % brief ecoco
    [Ypcc,locatcc] = eccpeaks(Y,ecc,eci,norbit,corrcf,ci,sh_norb,n,1,NaN); % get peaks

    [~,~,srn_best,~] = ecocotrack(locatcc,ecc,eci,ecoco,...
    norbit,handles.out_depth,sr1,sr2,srstep,...
    srsh,srslice,corrcf,ci,plotn,sh_norb);
% 
%     assignin('base','Y',Y)
%     assignin('base','Ypcc',Ypcc)
    
    name0 = [handles.dat_name,'-',num2str(n),'pk-',num2str(ci),'%H0SL',...
        num2str(corrcf),'co-',num2str(srslice),'sl','-SR'];  % New name
    name1 = [name0,handles.ext];  % name for sedrate file
    if exist([pwd,handles.slash_v,name1])
        for i = 1:100
            name1 = [name0,num2str(i),handles.ext];
            if exist([pwd,handles.slash_v,name1])
            else
                break
            end
        end
    end
    srn_map(:,2) = (sr1+handles.srstep*(srn_best(1,:)-1))';
    srn_map(:,1) = handles.out_depth;
    CDac_pwd
    dlmwrite(name1, srn_map, 'delimiter', ' ', 'precision', 9);
    if handles.lang_choice==0 
        disp(['>> Sedimentation rate file: ',name1])
    else
        disp([ec77,name1])
    end

    % Log name
    log_name = [name0,'-log',handles.ext]; 
    if exist([pwd,handles.slash_v,log_name])
        for i = 1:100
            log_name = [name0,'-log',num2str(i),'.txt'];
            if exist([pwd,handles.slash_v,log_name])
            else
                break
            end
        end
    end
    if handles.lang_choice==0 
        disp(['>> Log file: ',log_name])
    else
        disp([ec78,log_name])
    end
    % open and write log into log_name file
    fileID = fopen(fullfile(pwd,handles.slash_v,log_name),'w+');
    if handles.lang_choice==0 
        fprintf(fileID,'%s\n',' - - - - - - - - - - - - - Summary - - - - - - - - - - -');
        fprintf(fileID,'%s\n\n',datestr(datetime('now')));
        fprintf(fileID,'%s\n\n',log_name);
        fprintf(fileID,'%s\n','How many peaks each window?');
        fprintf(fileID,'%s\n',num2str(n));
        fprintf(fileID,'%s\n','Threshold H0 significant level');
        fprintf(fileID,'%s\n',num2str(ci));
        fprintf(fileID,'%s\n','Threshold correlation coefficient');
        fprintf(fileID,'%s\n',num2str(corrcf));
        fprintf(fileID,'%s\n','Threshold number of orbital parameters?');
        fprintf(fileID,'%s\n',num2str(sh_norb));
        fprintf(fileID,'%s\n','Threshold sedimentation rate');
        fprintf(fileID,'%s\n',num2str(srsh));
        fprintf(fileID,'%s\n','How many intervals to cut the series?');
        fprintf(fileID,'%s\n',num2str(srslice));
        fprintf(fileID,'%s\n','Optional: sedimentation rate ranges from');
        fprintf(fileID,'%s\n',num2str(sr1));
        fprintf(fileID,'%s\n','Optional: sedimentation rate ranges to');
        fprintf(fileID,'%s\n',num2str(sr2));
        fprintf(fileID,'%s\n',' - - - - - - - - - - - - - - End - - - - - - - - - - - -');
        fclose(fileID);
    else
        fprintf(fileID,'%s\n',ec59);
        fprintf(fileID,'%s\n\n',datestr(datetime('now')));
        fprintf(fileID,'%s\n\n',log_name);
        fprintf(fileID,'%s\n',ec68);
        fprintf(fileID,'%s\n',num2str(n));
        fprintf(fileID,'%s\n',ec69);
        fprintf(fileID,'%s\n',num2str(ci));
        fprintf(fileID,'%s\n',ec70);
        fprintf(fileID,'%s\n',num2str(corrcf));
        fprintf(fileID,'%s\n',ec71);
        fprintf(fileID,'%s\n',num2str(sh_norb));
        fprintf(fileID,'%s\n',ec72);
        fprintf(fileID,'%s\n',num2str(srsh));
        fprintf(fileID,'%s\n',ec73);
        fprintf(fileID,'%s\n',num2str(srslice));
        fprintf(fileID,'%s\n',ec75);
        fprintf(fileID,'%s\n',num2str(sr1));
        fprintf(fileID,'%s\n',ec76);
        fprintf(fileID,'%s\n',num2str(sr2));
        fprintf(fileID,'%s\n',ec60);
        fclose(fileID);
    end
    
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
end

guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%url = 'https://davidwaltham.com/wp-content/uploads/2014/01/Milankovitch.html';
%web(url,'-browser')
guidata(hObject, handles);
LODGUI(handles);
