function varargout = DYNOS(varargin)
% DYNOS MATLAB code for DYNOS.fig
%      DYNOS, by itself, creates a new DYNOS or raises the existing
%      singleton*.
%
%      H = DYNOS returns the handle to a new DYNOS or the handle to
%      the existing singleton*.
%
%      DYNOS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYNOS.M with the given input arguments.
%
%      DYNOS('Property','Value',...) creates a new DYNOS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DYNOS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DYNOS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DYNOS

% Last Modified by GUIDE v2.5 04-May-2017 22:34:18

% The original script is by Mingsong Li, Jan 2015, China Univ. Geoscience; George Mason Univ
% The GUI is by Mingsong Li, Dec 2016, China Univ. Geoscience; George Mason Univ
% The GUI is updated by Mingsong Li, May 2017, Penn State Univ

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DYNOS_OpeningFcn, ...
                   'gui_OutputFcn',  @DYNOS_OutputFcn, ...
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


% --- Executes just before DYNOS is made visible.
function DYNOS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DYNOS (see VARARGIN)
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;

set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
if ismac
    fontsize = 12;
elseif ispc
    fontsize = 11;
end
set(h1,'FontUnits','points','FontSize',fontsize);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',fontsize);  % set as norm

set(gcf,'Name','Acycle: Sedimentary Noise Model - DYNOT')

% Choose default command line output for DYNOS
set(gcf,'position',[0.05,0.05,0.85,0.85] * handles.MonZoom) % set position
% uipanels
set(handles.uipanel6,'position', [0.015,0.9,0.124,0.076])
set(handles.uipanel7,'position', [0.14,0.9,0.167,0.076])
set(handles.uipanel8,'position', [0.015,0.776,0.291,0.12])
set(handles.uipanel9,'position', [0.015,0.592,0.291,0.18])
set(handles.uipanel10,'position', [0.015,0.344,0.291,0.245])
set(handles.uipanel11,'position', [0.015,0.179,0.291,0.145])
set(handles.uipanel12,'position', [0.014,0.005,0.291,0.175])
% plot area
set(handles.text2,'position', [0.36,0.914,0.588,0.052],'FontSize',16)
set(handles.edit30,'position', [0.36,0.902,0.588,0.025],'FontSize',12)
set(handles.uipanel2,'position', [0.321,0.47,0.669,0.43])
set(handles.uipanel3,'position', [0.321,0.012,0.669,0.43])
set(handles.axes1,'position', [0.1,0.159,0.94,0.8])
set(handles.axes2,'position', [0.1,0.159,0.94,0.8])
% data/dynot
set(handles.pushbutton4,'position', [0.2,0.15,0.65,0.7])
set(handles.pushbutton5,'position', [0.15,0.15,0.7,0.7])
% interpolation
set(handles.text45,'position', [0.035,0.627,0.249,0.237])
set(handles.text8,'position', [0.035,0.22,0.249,0.237])
set(handles.text44,'position', [0.455,0.627,0.078,0.237])
set(handles.text10,'position', [0.455,0.22,0.078,0.237])
set(handles.text46,'position', [0.716,0.22,0.08,0.237])
set(handles.edit26,'position', [0.28,0.559,0.156,0.288])
set(handles.edit25,'position', [0.529,0.559,0.156,0.288])
set(handles.edit_sampa,'position', [0.28,0.153,0.156,0.288])
set(handles.edit_sampb,'position', [0.529,0.153,0.156,0.288])
set(handles.pushbutton_cut,'position', [0.712,0.559,0.233,0.288])
% MC
set(handles.text11,'position', [0.035,0.747,0.265,0.179])
set(handles.edit6,'position', [0.366,0.747,0.163,0.179])
set(handles.text13,'position', [0.545,0.747,0.062,0.179])
set(handles.edit7,'position', [0.615,0.747,0.2,0.179])
set(handles.text14,'position', [0.852,0.747,0.09,0.179])

set(handles.text15,'position', [0.035,0.526,0.521,0.179])
set(handles.edit8,'position', [0.568,0.526,0.117,0.179])
set(handles.text17,'position', [0.7,0.526,0.062,0.179])
set(handles.edit9,'position', [0.774,0.526,0.117,0.179])

set(handles.text18,'position', [0.035,0.3,0.253,0.179])
set(handles.edit10,'position', [0.323,0.3,0.163,0.179])
set(handles.text16,'position', [0.615,0.3,0.148,0.179])
set(handles.edit21,'position', [0.735,0.3,0.117,0.179])
set(handles.text43,'position', [0.868,0.3,0.09,0.179])
set(handles.text40,'position', [0.035,0.08,0.665,0.179])
set(handles.edit24,'position', [0.712,0.08,0.253,0.179])
% frequency
set(handles.radiobutton1,'position', [0.03,0.774,0.541,0.14])
set(handles.edit29,'position', [0.584,0.774,0.187,0.14])
set(handles.text49,'position', [0.848,0.774,0.089,0.14])

set(handles.radiobutton2,'position', [0.03,0.594,0.934,0.128])
set(handles.edit11,'position', [0.1,0.444,0.85,0.128])
set(handles.text23,'position', [0.03,0.241,0.436,0.128])
set(handles.edit13,'position', [0.45,0.241,0.109,0.128])
set(handles.text25,'position', [0.584,0.241,0.062,0.128])
set(handles.edit14,'position', [0.642,0.241,0.109,0.128])
set(handles.text27,'position', [0.76,0.241,0.226,0.128])

set(handles.text26,'position', [0.03,0.07,0.374,0.128])
set(handles.edit15,'position', [0.393,0.07,0.14,0.128])
set(handles.text28,'position', [0.549,0.07,0.062,0.128])
set(handles.edit12,'position', [0.619,0.07,0.14,0.128])
set(handles.text47,'position', [0.755,0.07,0.226,0.128])
%Plot
set(handles.text30,'position', [0.03,0.77,0.43,0.176])
set(handles.checkbox1median,'position', [0.521,0.73,0.268,0.25])
set(handles.checkbox50,'position', [0.755,0.73,0.214,0.25])
set(handles.checkbox68,'position', [0.07,0.473,0.214,0.25])
set(handles.checkbox80,'position', [0.296,0.473,0.214,0.25])
set(handles.checkbox90,'position', [0.521,0.473,0.214,0.25])
set(handles.checkbox95,'position', [0.755,0.473,0.214,0.25])
set(handles.text29,'position', [0.03,0.12,0.42,0.25])
set(handles.edit22,'position', [0.428,0.12,0.163,0.25])
set(handles.text36,'position', [0.607,0.12,0.268,0.25])
set(handles.edit23,'position', [0.875,0.12,0.11,0.25])
% process
set(handles.text48,'position', [0.03,0.75,0.659,0.185])
set(handles.edit27,'position', [0.717,0.75,0.163,0.185])
set(handles.text37,'position', [0.03,0.511,0.953,0.185])
set(handles.edit28,'position', [0.202,0.511,0.128,0.185])
set(handles.text50,'position', [0.337,0.511,0.636,0.185])
set(handles.text41,'position', [0.03,0.03,0.926,0.446],'FontSize',fontsize-1)

handles.output = hObject;
% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
data_s = varargin{1}.current_data;
handles.data = data_s;
assignin('base','data',data_s)

handles.filename = varargin{1}.data_name;
handles.dat_name = varargin{1}.dat_name;
handles.unit = varargin{1}.unit;
handles.path_temp = varargin{1}.path_temp;
handles.slash_v = varargin{1}.slash_v;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DYNOS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DYNOS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
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


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
numcore = handles.numcore;
numcorereal = feature('numCores');
numcore(numcore>numcorereal) = numcorereal;
useparpool = handles.useparpool;
itinerary = handles.itinerary;
data = handles.data;
sampa = handles.sampa;
sampb = handles.sampb;
parmhat = handles.parmhat;
unit = handles.unit;
window1 = handles.window1;
window2 = handles.window2;
nw1 = handles.nw1;
nw2 = handles.nw2;
pad = handles.pad;
step = handles.step;
nout = handles.nout;
shiftwin = handles.shiftwin;
f = handles.f;
fza = handles.fza;
fzb = handles.fzb;
ftmin = handles.ftmin;
ftmax = handles.ftmax;
nmc = handles.nmc;
checkbox1median= handles.checkbox1median_v;
checkbox50 = handles.checkbox50_v;
checkbox68 = handles.checkbox68_v;
checkbox80 = handles.checkbox80_v;
checkbox90 = handles.checkbox90_v;
checkbox95 = handles.checkbox95_v;
percent = [checkbox1median, checkbox50, checkbox68, ...
    checkbox80,checkbox90, checkbox95];
% npercentage
percent = sort(unique(percent));
percent = percent(percent~=0);
if isempty(percent)
    percent = 50;
end
%
%% Set random parameters

if nw2==nw1
    randnw = 0*rand(nmc,1);
else
    randnw = randi(2*(nw2-nw1),[nmc 1]);
end
%
samplez = wblrnd(parmhat(1),parmhat(2),[nmc 1]);
samplez(samplez<sampa) = sampa+(sampb-sampa)*rand(1);
samplez(samplez>sampb) = sampa+(sampb-sampa)*rand(1);
randwindow=rand(nmc,1);
windowz = window1+(window2-window1)*randwindow; % windowz range from window1 to window2
nwz = nw1 + randnw/2;                       % nw range from nw1 to nw2
bw = nwz./windowz;
ncol = length(f);
f3m =[];
for i=1:ncol
    fz = fza+(fzb-fza)*rand(nmc,1);
    f3m(:,2*i-1) = f(i)-fz.*bw;
    fz = fza+(fzb-fza)*rand(nmc,1);
    f3m(:,2*i)   = f(i)+fz.*bw;
end
f3m(f3m < ftmin) = ftmin;
f3m(f3m > ftmax) = ftmax;
%% Set plot y axis grid and a empty powy 
y_grid = linspace(data(1,1),data(length(data(:,1)),1),nout);
y_grid = y_grid';
powy = zeros(nout,nmc);  % for interpolated series
powmean = zeros(1,nmc);
%% Main function. Very heavy loads
tic;
dispstat('','init'); % One time only initialization
dispstat(sprintf(' Begin the process ...'),'keepthis','timestamp');
%%
if shiftwin == 1
    shiftwin1 = 0;
else
    shiftwin1 = shiftwin;
end

% Waitbar
hwaitbar = waitbar(0,'Very heavy loads, may take several hours ...',...    
   'WindowStyle','modal');
hwaitbar_find = findobj(hwaitbar,'Type','Patch');
set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
setappdata(hwaitbar,'canceling',0)
steps = 100;
% step estimation for waitbar
nmc_n = round(nmc/steps);
waitbarstep = 1;
waitbar(waitbarstep / steps)
    
if nmc > 199
    % Check for clicked Cancel button
    
  if numcore == 1  % can not use parpool or matlabpool
    for i=1:nmc
        if getappdata(hwaitbar,'canceling')
            break
        end
        dat = [];
        dat(:,1) = data(1,1):samplez(i):data(length(data(:,1)),1);
        dat(:,2) = interp1(data(:,1),data(:,2),dat(:,1),'pchip'); 
        f3=f3m(i,:);
        window = windowz(i);
        y_grid_rand=randi([-1*shiftwin1,shiftwin1])*window/2;   % shift y_grid1
        nw = nwz(i);
        [power]=pdan(dat,f3,window,nw,ftmin,ftmax,step,pad); % power ratio of data series
        powy(:,i)=interp1((power(:,1)+y_grid_rand/shiftwin),power(:,2),y_grid);
        power2=power(:,2); %
        powmean(1,i)=mean(power2(~isnan(power2))); % mean power of each calculation

        time = toc; t_rem = (time*nmc/i)-time;
        hh = fix(t_rem/3600); mm = fix((t_rem-hh*3600)/60); sec = t_rem-hh*3600-mm*60;
        dispstat(sprintf(' Progress %.1f%%. Remain %d:%d:%.0f',100*i/nmc,hh,mm,sec),'timestamp')
        % waitbar
        if rem(i,nmc_n) == 0
            waitbarstep = waitbarstep+1; 
            if waitbarstep > steps; waitbarstep = steps; end
            pause(0.001);%
            waitbar(waitbarstep / steps)
        end
    end
    if ishandle(hwaitbar); 
        close(hwaitbar);
    end
    
  else  % ready to use parpool or matlabpool
      % run first 50 times to estimate total computation time
    
        for i=1:itinerary
            if getappdata(hwaitbar,'canceling')
                break
            end
            dat = [];
            dat(:,1) = data(1,1):samplez(i):data(length(data(:,1)),1);
            dat(:,2) = interp1(data(:,1),data(:,2),dat(:,1),'pchip'); 
            f3=f3m(i,:);
            window = windowz(i);
            y_grid_rand=randi([-1*shiftwin1,shiftwin1])*window/2;   % shift y_grid1
            nw = nwz(i);
            [power]=pdan(dat,f3,window,nw,ftmin,ftmax,step,pad); % power ratio of data series
            powy(:,i)=interp1((power(:,1)+y_grid_rand/shiftwin),power(:,2),y_grid);
            power2=power(:,2); %
            powmean(1,i)=mean(power2(~isnan(power2))); % mean power of each calculation

            time = toc; t_rem = (time*nmc/i)-time;
            hh = fix(t_rem/3600); mm = fix((t_rem-hh*3600)/60); sec = t_rem-hh*3600-mm*60;
            dispstat(sprintf(' Progress %.2f%%. Remain %d:%d:%.0f',100*i/nmc,hh,mm,sec),'timestamp')
            % waitbar
            if rem(i,nmc_n) == 0
                waitbarstep = waitbarstep+1; 
                if waitbarstep > steps; waitbarstep = steps; end
                pause(0.001);%
                waitbar(waitbarstep / steps)
            end
        end
            t_rem = t_rem/numcore;
            hh = fix(t_rem/3600); 
            mm = fix((t_rem-hh*3600)/60); 
            sec = round(t_rem-hh*3600-mm*60);
            dispstat(sprintf(' First %d iterations suggest: remain >= %dh:%dm:%dsec',itinerary,hh,mm,sec),'timestamp')
  %end   
            if ishandle(hwaitbar); close(hwaitbar);end
            msgbox_v = {'Remaining time is likely:';...
                [num2str(hh),' hr ',num2str(mm),' min ', num2str(sec), ' sec'];...
                ['Come back at ~ ',datestr(now + t_rem/86400,'dd-mm-yyyy HH:MM:SS FFF')]};
            msgbox1 = msgbox(msgbox_v,'Wait ...');
%           use parpool when version of matlab is higher than 8.2, else use matlabpool
        if useparpool
            poolobj = parpool('local',numcore);
        else
             if matlabpool('size')<=0
                 matlabpool('open','local',numcore); 
             else
             end
        end
        % Parallel computing
        parfor i = itinerary+1:nmc
            tic;
            dat = [];
            dat(:,1) = data(1,1):samplez(i):data(length(data(:,1)),1);
            dat(:,2) = interp1(data(:,1),data(:,2),dat(:,1),'pchip'); 
            f3=f3m(i,:);
            window = windowz(i);
            y_grid_rand=randi([-1*shiftwin1,shiftwin1])*window/2;   % shift y_grid1
            nw = nwz(i);
            [power]=pdan(dat,f3,window,nw,ftmin,ftmax,step,pad); % power ratio of data series
            powy(:,i)=interp1((power(:,1)+y_grid_rand/shiftwin),power(:,2),y_grid);
            power2=power(:,2); %
            powmean(1,i)=mean(power2(~isnan(power2))); % mean power of each calculation
            dispstat(sprintf(' Current iteration takes %.2f seconds',toc),'timestamp')
            %
%             if rem(i,nmc_n) == 0
%                 waitbarstep1 = round(i/nmc_n); 
%                 if waitbarstep1 > steps; waitbarstep1 = steps; end
%                 pause(0.001);%
%                 waitbar(waitbarstep1 / steps)
%             end
        end
        if useparpool
              delete(poolobj);
        else
              matlabpool close
        end
        if ishandle(hwaitbar); close(hwaitbar);end
        if ishandle(msgbox1); close(msgbox1);end
  end
else
    %figdat = msgbox('Heavy loads, please wait','Wait ...');
    for i=1:nmc
        if getappdata(hwaitbar,'canceling')
            break
        end
        dat = [];
        dat(:,1) = data(1,1):samplez(i):data(length(data(:,1)),1);
        dat(:,2) = interp1(data(:,1),data(:,2),dat(:,1),'pchip'); 
        f3=f3m(i,:);
        window = windowz(i);
        y_grid_rand=randi([-1*shiftwin1,shiftwin1])*window/2;   % shift y_grid1
        nw = nwz(i);
        [power]=pdan(dat,f3,window,nw,ftmin,ftmax,step,pad); % power ratio of data series
        powy(:,i)=interp1((power(:,1)+y_grid_rand/shiftwin),power(:,2),y_grid);
        power2=power(:,2); %
        powmean(1,i)=mean(power2(~isnan(power2))); % mean power of each calculation

        time = toc; t_rem = (time*nmc/i)-time;
        hh = fix(t_rem/3600); mm = fix((t_rem-hh*3600)/60); sec = t_rem-hh*3600-mm*60;
        dispstat(sprintf(' Progress %.1f%%. Remain %d:%d:%.0f',100*i/nmc,hh,mm,sec),'timestamp')
        %
        %
        if rem(i,nmc_n) == 0
            waitbarstep = waitbarstep+1; 
            if waitbarstep > steps; waitbarstep = steps; end
            pause(0.001);%
            waitbar(waitbarstep / steps)
        end
    end
    if ishandle(hwaitbar); close(hwaitbar);end
end

%% Adjust each power ratio to a unique ratio
powmean_mean = mean(powmean);  % mean power ratio of each calculation
powmeanadjust = [];  % Make sure each running of this script don't be affected by previous running
powmeanadjust = powmean_mean./powmean;
powmeanadjust = repmat(powmeanadjust,nout,1);
powyadjust = powmeanadjust.*powy;
% Dec 10, 2016 Add by Mingsong Li. To avoid a problem that total power > 1
maxp = max(max(powyadjust));
if maxp > 1
    powyadjust=powyadjust/maxp;
end
% No adjust??
%powyadjust= powy;
%
dispstat('>>  Done.','keepprev');
%%
npercent  = length(percent);
npercent2 = (length(percent)-1)/2;
powyp = prctile(powy, percent,2);
powyadjustp=prctile(powyadjust, percent,2);
powyad_p_nan =[];
y_grid_nan=[];
% Remove NaN within powyadjustp
for i = 1: npercent
    powyadjustp1=powyadjustp(:,i);
    powyad_p_nan(:,i) = powyadjustp1(~isnan(powyadjustp1));
end
y_grid_nan = y_grid(~isnan(powyadjustp(:,1)));
powyad_p_nan = 1 - powyad_p_nan;
powyadjust = 1- powyadjust;
powyadjustp = 1 - powyadjustp;
%% Plot DYNOS
axes(handles.axes2)
cla reset
hold all
% for i = 1: nmc
%     plot(y_grid,powyadjust(:,i),'color',[0,0,0]+0.8);
% end
%
colorcode = [221/255,234/255,224/255; ...
    201/255,227/255,209/255; ...
    176/255,219/255,188/255;...
    126/255,201/255,146/255;...
    67/255,180/255,100/255];
for i = 1:npercent2
    fill([y_grid_nan; (fliplr(y_grid_nan'))'],[powyad_p_nan(:,npercent+1-i);...
        (fliplr(powyad_p_nan(:,i)'))'],colorcode(i,:),'LineStyle','none');
end
plot(y_grid_nan,powyad_p_nan(:,npercent2+1),'Color',[0,120/255,0],'LineWidth',1.5,'LineStyle','--')
axis([data(1,1) data(length(data(:,1)),1) min(powyad_p_nan(:,npercent)) max(powyad_p_nan(:,1))]) 
set(handles.axes2,'Ydir','reverse')
set(gca,'XMinorTick','on','YMinorTick','on')
hold off

set(handles.uipushtool4, 'Enable', 'On');
set(handles.uipushtool5, 'Enable', 'On');
set(handles.uipushtool6, 'Enable', 'On');
set(handles.uipushtool7, 'Enable', 'On');
%% save data in workspace

assignin('base','freqz',f3m)
assignin('base','nwz',nwz)
assignin('base','windowz',windowz)
assignin('base','samplez',samplez)

assignin('base','powy_grid',y_grid)
assignin('base','powy',powyadjust)
assignin('base','powyp',powyadjustp)

assignin('base','powyad_p_grid',y_grid_nan)
assignin('base','powyad_p',powyad_p_nan)

handles.f3m = f3m;
handles.nwz = nwz;
handles.windowz = windowz;
handles.samplez = samplez;
handles.npercent = npercent;
handles.npercent2 = npercent2;
handles.y_grid = y_grid;
handles.powyadjust = powyadjust;
handles.powyadjustp = powyadjustp;
handles.y_grid_nan = y_grid_nan;
handles.powyad_p_nan = powyad_p_nan;
handles.colorcode = colorcode;
% save data
data1 = [y_grid_nan,powyad_p_nan(:,npercent2+1)];
name1 = [handles.dat_name,'-DYNOT-median.txt'];
data2 = [y_grid_nan,powyad_p_nan];
name2 = [handles.dat_name,'-DYNOT-prctile.txt'];
CDac_pwd

if exist([pwd,handles.slash_v,name1]) || exist([pwd,handles.slash_v,name2])
    for i = 1:100
        name1 = [handles.dat_name,'-DYNOT-median-',num2str(i),'.txt'];
        name2 = [handles.dat_name,'-DYNOT-prctile-',num2str(i),'.txt'];
        if exist([pwd,handles.slash_v,name1]) || exist([pwd,handles.slash_v,name2])
        else
            break
        end
    end
end
disp(['>>  Save DYNOT median    : ',name1])
disp(['>>  Save DYNOT percentile: ',name2])
dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9); 
dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9); 
cd(pre_dirML); % return to matlab view folder
%
% refresh AC main window
figure(handles.acfigmain);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir

guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% plot data in axis 1
% estimate matlab version to decide use matlabpool or parpool script
        % use parpool when matlab version is higher than 8.2,else use
        % matlabpool
matlabversion = version;
matversion = str2num(matlabversion(1:3));
if matversion >= 8.2
    useparpool = 1;
    delete(gcp('nocreate')); % clear pool
else
    useparpool = 0;
end

handles.useparpool = useparpool;
existdata = evalin('base','who');
if ismember('data',existdata)
    handles.data = evalin('base','data');

    data = handles.data;
    if data(2,1)<= data(1,1)
        data = flipud(data);
    end
    xmin = min(data(:,1));
    xmax = max(data(:,1));
    ymin = min(data(:,2));
    ymax = max(data(:,2));
    samplerate = diff(data(:,1));
    parmhat = wblfit(samplerate); % estimate weibull a and b
    % plot
    plot(handles.axes1,data(:,1),data(:,2));
    axis(handles.axes1,[xmin xmax ymin ymax])
    set(gca,'XMinorTick','on','YMinorTick','on')
    % plot
    axes(handles.axes2)
    histfit(samplerate,40,'kernel');
    title(handles.axes2,'Sample rates');
    % set default parameters cover 90% sample ranges
    samplerange = prctile(samplerate, [5 95]);
    %
    numcore = feature('numCores');
    % set handles
    handles.numcore = numcore;
    handles.itinerary = 50;
    handles.sampa = samplerange(1);
    handles.sampb = samplerange(2);
    handles.parmhat = parmhat;
    handles.unit = 'ka';
    handles.window1 = 300;
    handles.window2 = 500;
    handles.nw1 = 2;
    handles.nw2 = 2;
    handles.pad = 1000;
    handles.step = 5;
    handles.nout = 1000;
    handles.shiftwin = 15;
    handles.fza = 0.9;
    handles.fzb = 1.2;
    handles.ftmin = 0.001;
    handles.ftmax = 1;
    handles.nmc = 1000;
    handles.age = 0;
    handles.cut1 = data(1,1);
    handles.cut2 = data(length(data(:,1)),1);
    handles.checkbox1median_v = 50;
    handles.checkbox50_v = [25 75];
    handles.checkbox68_v = [15.865 84.135];
    handles.checkbox80_v = [10 90];
    handles.checkbox90_v = [5 95];
    handles.checkbox95_v = [2.5 97.5];
    % set settings in the app
    set(handles.edit6, 'String', num2str(handles.window1));
    set(handles.edit7, 'String', num2str(handles.window2));
    set(handles.edit8, 'String', num2str(handles.nw1));
    set(handles.edit9, 'String', num2str(handles.nw2));
    set(handles.edit10, 'String', num2str(handles.pad));
    c = [405 125 95 40.9 23.6 22.3 19.1];
    set(handles.edit11, 'String', num2str(c,'%1.1f '));
    set(handles.edit13, 'String', num2str(handles.fza));
    set(handles.edit14, 'String', num2str(handles.fzb));
    set(handles.edit15, 'String', num2str(handles.ftmin));
    set(handles.edit12, 'String', num2str(handles.ftmax));
    set(handles.edit21, 'String', num2str(handles.step));
    set(handles.edit22, 'String', num2str(handles.nout));
    set(handles.edit23, 'String', num2str(handles.shiftwin));
    set(handles.edit_sampa, 'String', num2str(samplerange(1)));
    set(handles.edit_sampb, 'String', num2str(samplerange(2)));
    set(handles.edit24, 'String', num2str(handles.nmc));
    set(handles.edit26, 'String', num2str(data(1,1)));
    set(handles.edit25, 'String', num2str(data(length(data(:,1)),1)));
    set(handles.edit27, 'Enable', 'On');
    set(handles.edit27, 'String', num2str(numcore));
    set(handles.edit28, 'String', num2str(handles.itinerary));
    set(handles.pushbutton_cut, 'Enable', 'On');
    set(handles.pushbutton5, 'Enable', 'On');
    set(handles.edit29, 'Enable', 'On');
    set(handles.edit11, 'Enable', 'Off');
    set(handles.radiobutton1, 'Value', 1);
    set(handles.radiobutton2, 'Value', 0);
    guidata(hObject, handles);
else
%    cd doc
    data_type
%    cd ..
end

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
window1 = str2double(get(hObject,'String'));
handles.window1 = window1;
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



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
window2 = str2double(get(hObject,'String'));
handles.window2 = window2;
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



function edit_sampa_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sampa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sampa as text
%        str2double(get(hObject,'String')) returns contents of edit_sampa as a double
sampa = str2double(get(hObject,'String'));
handles.sampa = sampa;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_sampa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sampa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_sampb_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sampb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sampb as text
%        str2double(get(hObject,'String')) returns contents of edit_sampb as a double
sampb = str2double(get(hObject,'String'));
handles.sampb = sampb;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_sampb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sampb (see GCBO)
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
nw1 = str2double(get(hObject,'String'));
handles.nw1 = nw1;
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
nw2 = str2double(get(hObject,'String'));
handles.nw2 = nw2;
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
pad = str2double(get(hObject,'String'));
handles.pad = pad;
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
c = strread(get(hObject,'String'));
f = 1./c;
handles.f = f;
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
c = strread(get(hObject,'String'));
f = 1./c;
handles.f = f;
guidata(hObject, handles);


function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double
ftmax = str2double(get(hObject,'String'));
handles.ftmax = ftmax;
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
fza = str2double(get(hObject,'String'));
handles.fza = fza;
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



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
fzb = str2double(get(hObject,'String'));
handles.fzb = fzb;
guidata(hObject, handles);

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



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double
ftmin = str2double(get(hObject,'String'));
handles.ftmin = ftmin;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double
step = str2double(get(hObject,'String'));
handles.step = step;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
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
% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
case 'ka' % User selects unit.
   handles.unit = 'ka';
case 'ma' % User selects m.
   handles.unit = 'ma';
case 'a' % User selects dm.
   handles.unit = 'a';
end
% Save the handles structure.
guidata(hObject,handles)

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



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double
nout = str2double(get(hObject,'String'));
handles.nout = nout;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double
shiftwin = str2double(get(hObject,'String'));
handles.shiftwin = shiftwin;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1median.
function checkbox1median_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1median (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1median
% checkbox1median_v = get(handles.checkbox1median,'string');
% handles.checkbox1median_v = checkbox1median_v;

checkbox1median = get(handles.checkbox1median,'Value');
if checkbox1median == 1
    handles.checkbox1median_v = 50;
else
    handles.checkbox1median_v = 0;
end

guidata(hObject, handles);

% --- Executes on button press in checkbox50.
function checkbox50_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox50
checkbox50 = get(handles.checkbox50,'Value');

if checkbox50 == 1
    handles.checkbox50_v = [25 75];
else
    handles.checkbox50_v = [0 0];
end

guidata(hObject, handles);

% --- Executes on button press in checkbox68.
function checkbox68_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox68
checkbox68 = get(handles.checkbox68,'Value');
if checkbox68 == 1
%     set(handles.checkbox68,'Enable','on')
    handles.checkbox68_v = [15.865 84.135];
else
    handles.checkbox68_v = [0 0];
end

guidata(hObject, handles);

% --- Executes on button press in checkbox80.
function checkbox80_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox80 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox80
checkbox80 = get(handles.checkbox80,'Value');
if checkbox80 == 1
%     set(handles.checkbox80,'Enable','on')
    handles.checkbox80_v = [10 90];
else
%     set(handles.checkbox80,'Enable','on')
    handles.checkbox80_v = [0 0];
end

guidata(hObject, handles);

% --- Executes on button press in checkbox90.
function checkbox90_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox90
checkbox90 = get(handles.checkbox90,'Value');
if checkbox90 == 1
%     set(handles.checkbox90,'Enable','on')
    handles.checkbox90_v = [5 95];
else
%     set(handles.checkbox90,'Enable','on')
    handles.checkbox90_v = [0 0];
end

guidata(hObject, handles);

% --- Executes on button press in checkbox95.
function checkbox95_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox95 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox95
checkbox95 = get(handles.checkbox95,'Value');
if checkbox95 == 1
%     set(handles.checkbox95,'Enable','on')
    handles.checkbox95_v = [2.5 97.5];
else
%     set(handles.checkbox95,'Enable','on')
    handles.checkbox95_v = [0 0];
end

guidata(hObject, handles);



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double
nmc = str2double(get(hObject,'String'));
handles.nmc = nmc;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_old = gcf;
close(h_old)
run DYNOS



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double
cut2 = str2double(get(hObject,'String'));
handles.cut2 = cut2;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double
cut1 = str2double(get(hObject,'String'));
handles.cut1 = cut1;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_cut.
function pushbutton_cut_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cut1 = handles.cut1;
cut2 = handles.cut2;
cut1 = min(cut1, cut2);
cut2 = max(cut1, cut2);
data = handles.data;
datx = find(data(:,1) >= cut1 & data(:,1)<= cut2);
data = data(datx,1:2);
samplerate = diff(data(:,1));
%
parmhat = wblfit(samplerate); % estimate weibull a and b
% plot
axes(handles.axes1)
cla reset
plot(data(:,1),data(:,2));
axis([data(1,1) data(length(data(:,1)),1) min(data(:,2)) max(data(:,2))])
% plot
axes(handles.axes2)
cla reset
histfit(samplerate,40,'kernel');
title(handles.axes2,'Sample rates');
% set default parameters cover 90% sample ranges
samplerange = prctile(samplerate, [5 95]);
% set handles
handles.sampa = samplerange(1);
handles.sampb = samplerange(2);
handles.parmhat = parmhat;
%
handles.data = data;
set(handles.edit_sampa, 'String', num2str(samplerange(1)));
set(handles.edit_sampb, 'String', num2str(samplerange(2)));
guidata(hObject, handles);


% --------------------------------------------------------------------
function uipushtool4_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figurename=['plots_','.fig'];
saveas(gcf,figurename)


% --------------------------------------------------------------------
function uipushtool5_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = handles.data;
nmc = handles.nmc;
y_grid = handles.y_grid;
powyadjust = handles.powyadjust;
y_grid_nan = handles.y_grid_nan;
powyad_p_nan = handles.powyad_p_nan;
npercent = handles.npercent;
npercent2 = handles.npercent2;
powyadjustp = handles.powyadjustp;
colorcode = handles.colorcode;
figure;
hold all

for i = 1:npercent2
    fill([y_grid_nan; (fliplr(y_grid_nan'))'],[powyad_p_nan(:,i);...
       (fliplr(powyad_p_nan(:,npercent+1-i)'))'],colorcode(i,:),'LineStyle','none');
end
plot(y_grid_nan,powyad_p_nan(:,npercent2+1),'Color',[0,120/255,0],'LineWidth',1.5,'LineStyle','--')
axis([data(1,1) data(length(data(:,1)),1) min(powyad_p_nan(:,npercent)) max(powyad_p_nan(:,1))]) 
set(gca,'Ydir','reverse')
hold off


% --------------------------------------------------------------------
function uipushtool6_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figurename=['plots_','.pdf'];
saveas(gcf,figurename)


% --------------------------------------------------------------------
function uipushtool7_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% use the following script to save workspace
% save ('result_workspace.mat')
save result_handles.mat



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double
numcore = str2double(get(hObject,'String'));
handles.numcore = numcore;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double
itinerary = str2double(get(hObject,'String'));
handles.itinerary = itinerary;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel2 is resized.
function uipanel2_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% cd doc
About
% cd ..

% --------------------------------------------------------------------
function menu_tour_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% cd doc
open('Tour.pdf')
% cd ..

% --------------------------------------------------------------------
function menu_website_Callback(hObject, eventdata, handles)
% hObject    handle to menu_website (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
url = 'https://mingsongli.wixsite.com/home';
web(url,'-browser')


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
set(handles.edit11, 'Enable', 'Off');
set(handles.radiobutton2, 'Value', 0);
set(handles.edit29, 'Enable', 'On');

function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double
age = str2double(get(hObject,'String'));
handles.age = age;
age_obl = 41 - 0.0332*age;
age_p1 = 22.43 - 0.0108*age;
age_p2 = 23.75 - 0.0121*age;
age_p3 = 19.18 - 0.0079*age;
c = [405 125 95 age_obl age_p2 age_p1 age_p3];
f = 1./c;
handles.f = f;
set(handles.edit11, 'String',num2str(c,'%1.1f '));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
set(handles.edit29, 'Enable', 'Off');
set(handles.radiobutton1, 'Value', 0);
set(handles.edit11, 'Enable', 'On');


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over radiobutton2.
function radiobutton2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit29, 'Enable', 'Off');
set(handles.radiobutton1, 'Value', 0);
set(handles.edit11, 'Enable', 'On');


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over radiobutton1.
function radiobutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit11, 'Enable', 'Off');
set(handles.radiobutton2, 'Value', 0);
set(handles.edit29, 'Enable', 'On');


% --------------------------------------------------------------------
function file_loadmat_Callback(hObject, eventdata, handles)
% hObject    handle to file_loadmat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, ~] = uigetfile({'*.mat','MatLab MAT-file (*.mat)'},'Load data (*.mat)');
if filename == 0
else
    data=load(filename);
    assignin('base','data',data)
end

% --------------------------------------------------------------------
function file_import_Callback(hObject, eventdata, handles)
% hObject    handle to file_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.txt;*.csv','Files (*.txt;*.csv)'},...
    'Import data (*.csv,*.txt)');
if filename == 0
else
   aaa = [pathname,filename];
data = load(aaa);
assignin('base','data',data)
% guidata(hObject, handles);
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
