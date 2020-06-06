function varargout = agescale(varargin)
% AGESCALE MATLAB code for agescale.fig
%      AGESCALE, by itself, creates a new AGESCALE or raises the existing
%      singleton*.
%
%      H = AGESCALE returns the handle to a new AGESCALE or the handle to
%      the existing singleton*.
%
%      AGESCALE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AGESCALE.M with the given input arguments.
%
%      AGESCALE('Property','Value',...) creates a new AGESCALE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before agescale_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to agescale_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help agescale

% Last Modified by GUIDE v2.5 24-Feb-2020 11:34:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @agescale_OpeningFcn, ...
                   'gui_OutputFcn',  @agescale_OutputFcn, ...
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


% --- Executes just before agescale is made visible.
function agescale_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to agescale (see VARARGIN)
% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
handles.unit = varargin{1}.unit;
%
% Choose default command line output for agescale
handles.output = hObject;
set(gcf,'Name','Acycle: Age Scale')
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

set(gcf,'position',[0.05,0.4,0.9,0.4]) % set position

set(handles.pushbutton2,'position',[0.034,0.84,0.06,0.06]) % set position
set(handles.pushbutton3,'position',[0.1,0.84,0.06,0.06]) % set position
set(handles.pushbutton4,'position',[0.485,0.732,0.06,0.06]) % set position
set(handles.pushbutton7,'position',[0.485,0.527,0.06,0.06]) % set position
set(handles.pushbutton8,'position',[0.465,0.114,0.1,0.06]) % set position

set(handles.pushbutton11,'position',[0.465,0.366,0.11,0.06]) % set position
set(handles.pushbutton12,'position',[0.465,0.293,0.11,0.06]) % set position
set(handles.pushbutton13,'position',[0.465,0.221,0.11,0.06]) % set position

set(handles.edit1,'position',[0.018,0.748,0.436,0.06]) % set position
set(handles.edit2,'position',[0.58,0.738,0.4,0.06]) % set position
set(handles.listbox1,'position',[0.018,0.114,0.436,0.634]) % set position
set(handles.listbox2,'position',[0.58,0.114,0.4,0.476]) % set position
set(handles.text3,'position',[0.58,0.84, 0.15,0.06]) % set position
set(handles.text4,'position',[0.58,0.606,0.1,0.06]) % set position

CDac_pwd; % cd ac_pwd dir
d = dir; %get files
set(handles.listbox1,'String',{d.name},'Value',1) %set string
set(handles.edit1,'String',pwd) % set position
cd(pre_dirML); % return to matlab view folder
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes agescale wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = agescale_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
plot_selected = get(hObject,'Value');
handles.index_selected  = plot_selected;
handles.nplot = length(plot_selected);   % length
guidata(hObject,handles)

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



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
address = get(hObject,'String');
cd(address)
d = dir; %get files
set(handles.listbox1,'String',{d.name},'Value',1) %set string
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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd ..;
address = pwd;
set(handles.edit1,'String',address);
d = dir; %get files
set(handles.listbox1,'String',{d.name},'Value',1) %set string
guidata(hObject,handles)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_content = cellstr(get(handles.listbox1,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1; minus 2 for listbox
nplot = length(plot_selected);   % length
if nplot > 1
    open_data = 'Tips: Select 1 folder';
    h = helpdlg(open_data,'Tips: Close');
    uiwait(h);
else
    
    plot_filter_selection = char(list_content(plot_selected));
    if ~exist(plot_filter_selection,'dir')==1
        h = helpdlg('This is not a folder','Tips: Close');
        uiwait(h);
    else
        cd(plot_filter_selection)
        address = pwd;
        set(handles.edit1,'String',address);
    end
d = dir; %get files
set(handles.listbox1,'String',{d.name},'Value',1) %set string
end
guidata(hObject,handles)

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_content = cellstr(get(handles.listbox1,'String')); % read contents of listbox 1 
index_selected = handles.index_selected;
nplot = handles.nplot;
if index_selected > 2
    if nplot == 1
        handles.agemodelname = list_content(index_selected,1);
        set(handles.edit2,'String',handles.agemodelname,'Value',1);
    end
end
guidata(hObject,handles)


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


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_content = cellstr(get(handles.listbox1,'String')); % read contents of listbox 1 
index_selected = handles.index_selected;
nplot = handles.nplot;
series_num = 0;
if index_selected > 2
    for i=1:nplot
        seriesname = char(list_content(index_selected(i),1));
        series_num = series_num + 1;
        series(series_num,1) = {seriesname};
    end
end
set(handles.listbox2,'String',char(series),'Value',1);
guidata(hObject,handles)

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_dirML = pwd;
CDac_pwd; % cd working dir

agemodelname = char(get(handles.edit2,'String'));
agemodel = load(agemodelname);

list_content = cellstr(get(handles.listbox2,'String')); % read contents of listbox 1 
nrow = length(list_content);

figagescale = gcf;
figdata = figure;
xmax1 = nan;
xmin1 = nan;
xmax2 = nan;
xmin2 = nan;

for i = 1:nrow
    data_name = char(list_content(i,1));
    data = load(data_name);
    [~,dat_name,~] = fileparts(data_name);
    subplot(2,1,1)
    plot(data(:,1),data(:,2)); hold on;
    set(gca,'XMinorTick','on','YMinorTick','on')
    xmin1 = nanmin(xmin1,min(data(:,1)));
    xmax1 = nanmax(xmax1,max(data(:,1)));
    title('Origin data')
    xlim([xmin1,xmax1])
    [time,handles.sr] = depthtotime(data(:,1),agemodel);
    handles.tunedseries = [time,data(:,2)];
    subplot(2,1,2)
    plot(time,data(:,2)); hold on;
    set(gca,'XMinorTick','on','YMinorTick','on')
    title('Tuned data')
    xmin2 = nanmin(xmin2,min(time));
    xmax2 = nanmax(xmax2,max(time));
    xlim([xmin2,xmax2])
    add_list = [dat_name,'-TD-',agemodelname];
    dlmwrite(add_list, handles.tunedseries, 'delimiter', ',', 'precision', 9);
    d = dir; %get files
    set(handles.listbox1,'String',{d.name},'Value',1) %set string
end

% refresh AC main window
figure(handles.acfigmain);
refreshcolor;
cd(pre_dirML); % return view dir
figure(figagescale);
figure(figdata); % return plot
guidata(hObject,handles)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_dirML = pwd;
CDac_pwd; % cd working dir

agemodelname = char(get(handles.edit2,'String'));
tiepoints = load(agemodelname);
x1 = min(tiepoints(:,1));  % depth
x2 = max(tiepoints(:,1));  % depth
y1 = min(tiepoints(:,2));  % time
y2 = max(tiepoints(:,2));  % time

figure('Position',[100 800 500 500],...
  'Color',[1 1 1])
axes('Position',[0.2 0.2 0.7 0.7],...
  'XLim',[y1 y2],...
  'YLim',[x1 x2],...
  'YDir','Reverse',...
  'Box','On',...
  'FontSize',14)
line(tiepoints(:,2),tiepoints(:,1),...
  'LineWidth',1)
xlabel('Age')
ylabel(['Depth (',handles.unit,')'])
set(gca,'XMinorTick','on','YMinorTick','on')
title(['Age Model'])
cd(pre_dirML); % return view dir

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_dirML = pwd;
CDac_pwd; % cd working dir
agemodelname = char(get(handles.edit2,'String'));
tiepoints = load(agemodelname);
list_content = cellstr(get(handles.listbox2,'String')); % read contents of listbox 1 
nrow = length(list_content);
for i = 1:nrow
    data_name = char(list_content(i,1));
    data = load(data_name);
    [~,dat_name,~] = fileparts(data_name);
    [time,handles.sr] = depthtotime(data(:,1),tiepoints);
    
    t1 = min(time);  % time
    t2 = max(time);  % time
    y1 = min(data(:,2));  % value
    y2 = max(data(:,2));  % value
    d1 = min(data(:,1));  % value
    d2 = max(data(:,1));  % value
    
    t = time; 
    rec = data(:,2);

    lenexp = fix(log10(t2-t1));  % exp
    if lenexp >= 0 % length [1 10]
        XTickStep = 0.05 * round(fix((t2-t1)/10^lenexp)) * 10^lenexp;
        t1r = round(fix(t1/10^lenexp)) * 10^lenexp;
        age = t1r:XTickStep:t2;
        depthint = interp1(tiepoints(:,2),tiepoints(:,1),age,'linear','extrap');
        depthintlabels = num2str(depthint,'%.0f\n');
    else
        XTickStep = (t2-t1)/20;
        age = t1:XTickStep:t2;
        depthint = interp1(tiepoints(:,2),tiepoints(:,1),age,'linear','extrap');
        depthintlabels = num2str(depthint,'%.3f\n');
    end
    
    %  display in a first diagram with two axes.
    figure1 = figure('Position',[50 50 1000 400], 'Color',[1 1 1]) ;
    ax(1) = axes('Position',[0.1 0.4 0.8 0.4],...
      'Color','None',...
      'XTick',age,...
      'XLim',[t1 t2],...
      'YLim',[y1 y2],...
      'FontSize',14);
    line1 = line(t,rec,...
      'LineWidth',1);
    xlabel(ax(1),'Age')
    ylabel(ax(1),'Proxy Value')
    title(ax(1),[dat_name,': Tuned'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    ax(2) = axes('Position',[0.1 0.25 0.8 0.4],...
      'Color','None',...
      'XLim',[t1 t2],...
      'XTickMode','Manual',...
      'XTick',age,...
      'XTickLabels',depthintlabels,...
      'YLim',[y1 y2],...
      'YTick',[],...
      'YColor','None',...
      'FontSize',14);
    xlabel(ax(2),['Depth (',handles.unit,')'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    % Then we interpolate the  ages to an evenly-spaced depth scale
    
    lenexp = fix(log10(d2-d1));  % exp
    if lenexp >= 0 % length [1 10]
        XTickStep = 0.05 * round(fix((d2-d1)/10^lenexp)) * 10^lenexp;
        if d1>=0
            d1r = round(fix(d1/10^lenexp)) * 10^lenexp;
        else
            d1r = round(d1);
        end
        depth = d1r:XTickStep:d2;
        ageint = interp1(depthint,age,depth,'linear','extrap');
        depthlabels = num2str(depth,'%.0f\n');
    else
        XTickStep = (d2-d1)/20;
        depth = d1:XTickStep:d2;
        ageint = interp1(depthint,age,depth,'linear','extrap');
        depthlabels = num2str(depth,'%.3f\n');
    end

    figure1 = figure('Position',[50 500 1000 400],...
      'Color',[1 1 1]);
    ax(1) = axes('Position',[0.1 0.4 0.8 0.4],...
      'Color','None',...
      'XLim',[t1 t2],...
      'XTick',age,...
      'YLim',[y1 y2],...
      'FontSize',14);
    line1 = line(t,rec,...
      'LineWidth',1);
    xlabel(ax(1),'Age')
    ylabel(ax(1),'Proxy Value')
    title(ax(1),[dat_name,': Tuned'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    ax(2) = axes('Position',[0.1 0.25 0.8 0.4],...
      'Color','None',...
      'XLim',[t1 t2],...
      'XTickMode','Manual',...
      'XTick',ageint,...
      'XTickLabels',depthlabels,...
      'YLim',[y1 y2],...
      'YTick',[],...
      'YColor','None',...
      'FontSize',14);
    xlabel(ax(2),['Depth (',handles.unit,')'])
    set(gca,'XMinorTick','on','YMinorTick','on')
end
cd(pre_dirML); % return view dir


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_dirML = pwd;
CDac_pwd; % cd working dir
agemodelname = char(get(handles.edit2,'String'));
tiepoints = load(agemodelname);
list_content = cellstr(get(handles.listbox2,'String')); % read contents of listbox 1 
nrow = length(list_content);
for i = 1:nrow
    data_name = char(list_content(i,1));
    data = load(data_name);
    [~,dat_name,~] = fileparts(data_name);
    [time,handles.sr] = depthtotime(data(:,1),tiepoints);
    
    t1 = min(time);  % time
    t2 = max(time);  % time
    y1 = min(data(:,2));  % value
    y2 = max(data(:,2));  % value
    d1 = min(data(:,1));  % value
    d2 = max(data(:,1));  % value
    
    t = time;
    rec = data(:,2);
    
    lenexp = fix(log10(d2-d1));  % exp
    if lenexp >= 0 % length [1 10]
        XTickStep = 0.1 * round(fix((d2-d1)/10^lenexp)) * 10^lenexp;
        if d1>=0
            d1r = round(fix(d1/10^lenexp)) * 10^lenexp;
        else
            d1r = round(d1);
        end
        XTickListDepth = d1r:XTickStep:d2;
        timeint = interp1(tiepoints(:,1),tiepoints(:,2),XTickListDepth,'linear','extrap');
        timeintlabels = num2str(timeint,'%.0f\n');
    else
        XTickStep = (d2-d1)/20;
        XTickListDepth = d1:XTickStep:d2;
        timeint = interp1(tiepoints(:,1),tiepoints(:,2),XTickListDepth,'linear','extrap');
        timeintlabels = num2str(timeint,'%3.3f\n');
    end
    figure1 = figure('Position',[50 50 1000 400], 'Color',[1 1 1]) ;
    ax(1) = axes('Position',[0.1 0.4 0.8 0.4],...
      'Color','None',...
      'XTick',XTickListDepth,...
      'XLim',[d1 d2],...
      'YLim',[y1 y2],...
      'FontSize',14);
    line1 = line(data(:,1),rec,...
      'LineWidth',1);
    xlabel(ax(1),['Depth (',handles.unit,')'])
    ylabel(ax(1),'Proxy Value')
    title(ax(1),[dat_name,': Depth'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    ax(2) = axes('Position',[0.1 0.25 0.8 0.4],...
      'Color','None',...
      'XLim',[d1 d2],...
      'XTickMode','Manual',...
      'XTick',XTickListDepth,...
      'XTickLabels',timeintlabels,...
      'YLim',[y1 y2],...
      'YTick',[],...
      'YColor','None',...
      'FontSize',14);
    xlabel(ax(2),'Age')
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    % Then we interpolate the  ages to an evenly-spaced depth scale
    lenexp = fix(log10(t2-t1));  % exp
    if lenexp >= 0 % length [1 10]
        XTickStep = 0.05 * round(fix((t2-t1)/10^lenexp)) * 10^lenexp;
        t1r = round(fix(t1/10^lenexp)) * 10^lenexp;
        age = t1r:XTickStep:t2;
        depthint = interp1(tiepoints(:,2),tiepoints(:,1),age,'linear','extrap');
        depthintlabels = num2str(age,'%.0f\n');
    else
        XTickStep = (t2-t1)/20;
        age = t1:XTickStep:t2;
        depthint = interp1(tiepoints(:,2),tiepoints(:,1),age,'linear','extrap');
        depthintlabels = num2str(age,'%.3f\n');
    end

    figure1 = figure('Position',[50 500 1000 400],'Color',[1 1 1]);
    ax(1) = axes('Position',[0.1 0.4 0.8 0.4],...
      'Color','None',...
      'XTick',XTickListDepth,...
      'XLim',[d1 d2],...
      'YLim',[y1 y2],...
      'FontSize',14);
    line1 = line(data(:,1),rec,...
      'LineWidth',1);
    xlabel(ax(1),['Depth (',handles.unit,')'])
    ylabel(ax(1),'Proxy Value')
    title(ax(1),[dat_name,': Depth'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    ax(2) = axes('Position',[0.1 0.25 0.8 0.4],...
      'Color','None',...
      'XLim',[d1 d2],...
      'XTickMode','Manual',...
      'XTick',depthint,...
      'XTickLabels',depthintlabels,...
      'YLim',[y1 y2],...
      'YTick',[],...
      'YColor','None',...
      'FontSize',14);
    xlabel(ax(2),'Age')
    set(gca,'XMinorTick','on','YMinorTick','on')
end
cd(pre_dirML); % return view dir
