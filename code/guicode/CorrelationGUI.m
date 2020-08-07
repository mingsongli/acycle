function varargout = CorrelationGUI(varargin)
% CORRELATIONGUI MATLAB code for CorrelationGUI.fig
%      CORRELATIONGUI, by itself, creates a new CORRELATIONGUI or raises the existing
%      singleton*.
%
%      H = CORRELATIONGUI returns the handle to a new CORRELATIONGUI or the handle to
%      the existing singleton*.
%
%      CORRELATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CORRELATIONGUI.M with the given input arguments.
%
%      CORRELATIONGUI('Property','Value',...) creates a new CORRELATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CorrelationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CorrelationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CorrelationGUI

% Last Modified by GUIDE v2.5 06-Aug-2020 22:15:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CorrelationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CorrelationGUI_OutputFcn, ...
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


% --- Executes just before CorrelationGUI is made visible.
function CorrelationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CorrelationGUI (see VARARGIN)

% Choose default command line output for CorrelationGUI
handles.output = hObject;

handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.unit = varargin{1}.unit;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;

handles.hmain = gcf;
set(handles.hmain,'Name', 'Acycle: Stratigraphic Correlation')
% GUI settings
set(0,'Units','normalized') % set units as normalized
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

set(handles.hmain,'position',[0.38,0.05,0.6,0.3]) % set position
set(handles.uipanel1,'position',[0.025,0.476,0.947,0.475]) % Data
set(handles.text2,'position',[0.015,0.849,0.24,0.15])
set(handles.text3,'position',[0.015,0.28,0.24,0.15])
set(handles.edit1,'position',[0.125,0.547,0.87,0.208])
set(handles.edit2,'position',[0.125,0.03,0.87,0.208])

set(handles.pushbutton3,'position',[0.015,0.557,0.1,0.208]) % plot
set(handles.pushbutton4,'position',[0.015,0.03,0.1,0.208]) % plot
% go and save data
set(handles.pushbutton1,'position',[0.8,0.1,0.16,0.168]) % plot
set(handles.checkbox1,'position',[0.8,0.3,0.13,0.1])
set(handles.checkbox1,'value',0)

% setting panel
set(handles.uipanel2,'position',[0.025,0.076,0.75,0.36]) % Data

set(handles.text6,'position',[0.015,0.6,0.27,0.26])
set(handles.text4,'position',[0.26,0.6,0.17,0.26])
set(handles.edit3,'position',[0.44,0.58,0.155,0.286])
set(handles.text5,'position',[0.6,0.6,0.1,0.26])
set(handles.edit4,'position',[0.7,0.58,0.155,0.286])

set(handles.text9,'position',[0.015,0.2,0.27,0.26])
set(handles.text7,'position',[0.26,0.2,0.17,0.26])
set(handles.edit5,'position',[0.44,0.18,0.155,0.286])
set(handles.text8,'position',[0.6,0.2,0.1,0.26])
set(handles.edit6,'position',[0.7,0.18,0.155,0.286])


% Read list
GETac_pwd;
set(handles.edit1,'string',ac_pwd)
set(handles.edit2,'string',ac_pwd)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CorrelationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CorrelationGUI_OutputFcn(hObject, eventdata, handles) 
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
rawref = handles.referencedata;
refxmin = str2double(get(handles.edit3,'String'));
refxmax = str2double(get(handles.edit4,'String'));
rawser = handles.seriesdata;
serxmin = str2double(get(handles.edit5,'String'));
serxmax = str2double(get(handles.edit6,'String'));
% segment
rawref = rawref(rawref(:,1)>refxmin & rawref(:,1)<refxmax,:);
rawser = rawser(rawser(:,1)>serxmin & rawser(:,1)<serxmax,:);
% initial plot
CorrFig = figure;
set(CorrFig,'units','norm') % set units as normalized
set(CorrFig,'position',[0.05,0.3,0.95,0.65]) % set position
set(CorrFig,'Color','white')
set(CorrFig,'Name','Acycle: Stratigraphic Correlation')
subplot(3,1,1)
plot(rawref(:,1),rawref(:,2),'k-')
xlim([refxmin, refxmax])
xlabel('Depth/Time')
ylabel('Value')
msg1 = '\fontsize{16}\color{blue}Select a tie point in the \color{red}reference \color{blue}plot; right click to stop';
title(msg1)
legend('Reference')

subplot(3,1,2)
plot(rawser(:,1),rawser(:,2),'b-')
xlim([serxmin, serxmax])
xlabel('Depth/Time')
ylabel('Value')
title('Series')

subplot(3,1,3)
xlabel('Depth/Time')
ylabel('Value')
title('Reference vs. Tuned Series')
handles.CorrFig = gcf;

% update
data1 = rawser;
i = 1;
con = 1;
while con == 1
    figure(handles.CorrFig)
    subplot(3,1,1)
    msg1 = '\fontsize{16}\color{blue}Select a tie point in the \color{red}reference \color{blue}plot; right click to stop';
    title(msg1)
    xlabel('Depth/Time')
    ylabel('Value')
    [x1, y1, con] = myginput(1,'crosshair');
    if con == 1
        tiepoints1(i,1) = x1;
        tiepoints1(i,2) = y1;
        % plot
        plot(rawref(:,1),rawref(:,2),'k-')
        xlim([refxmin, refxmax])
        hold on
        plot(tiepoints1(:,1),tiepoints1(:,2),'r*')
        hold off
        msg2 = '\fontsize{16}\color{blue}Select a tie point in the \color{red}series \color{blue}plot; right click to stop';
        title(msg2)
        [x2, y2, con] = myginput(1,'crosshair');
        if con == 1
            % record the pair
            tiepoints2(i,1) = x2;
            tiepoints2(i,2) = y2;
            % show results
            disp(['Tie Point ',num2str(i),' completed: series @ ',num2str(x2),' -> ref. @ ',num2str(x1),'.'])
            subplot(3,1,2)
            plot(rawser(:,1),rawser(:,2),'b-')
            xlim([serxmin, serxmax])
            hold on
            plot(tiepoints2(:,1),tiepoints2(:,2),'r*')
            hold off
            xlabel('Depth/Time')
            ylabel('Value')
            title('Series')
            
            % tuning
            agemodel = [tiepoints2(:,1),tiepoints1(:,1)]; % [series reference]
            agemodel = sortrows(agemodel);
            [time,~] = depthtotime(data1(:,1),agemodel);
            % sr
            sedrate = zeros(i+2,2);
            sedrate(1,1) = data1(1,1);
            sedrate(2:end-1,1) = tiepoints2(:,1);
            sedrate(end,1) = data1(end,1);
            sedrate0 = diff(agemodel(:,1))./diff(agemodel(:,2));
            sedrate(2:end-2,2) = sedrate0;
            sedrate(1,2) = sedrate(2,2);
            sedrate(end-1,2) = sedrate(end-2,2);
            sedrate(end,2) = sedrate(end-2,2);
            % tuning series
            data1t(:,1) = time;
            data1t(:,2) = data1(:,2);
            
            [tie2t,~] = depthtotime(tiepoints2(:,1),agemodel);
            
            subplot(3,1,3)
            plot(rawref(:,1),(rawref(:,2)-mean(rawref(:,2)))/std(rawref(:,2)),'k-')
            hold on
            plot(tiepoints1(:,1),(tiepoints1(:,2)-mean(rawref(:,2)))/std(rawref(:,2)),'r*')
            plot(data1t(:,1),(data1t(:,2)- mean(data1t(:,2)))/std(data1t(:,2)),'b-')
            plot(tie2t,(tiepoints2(:,2)-mean(rawser(:,2)))/std(rawser(:,2)),'r*')
            
            xlim([min(refxmin,min(time)), max(refxmax,max(time))])
            hold off
            xlabel('Depth/Time')
            ylabel('Value')
            title('Reference vs. Tuned Series')
            % Sed Rate
            try figure(handles.CorrSR)
                %if i==2;sr = [sr;sr];stairs(sr(:,1),sr(:,2));end
                stairs(sedrate(:,1),sedrate(:,2));
                xlim([serxmin, serxmax])
                xlabel('Depth/Time')
                ylabel('Sedimentation Rate')
            catch
                CorrSR = figure;
                set(CorrSR,'units','norm') % set units as normalized
                set(CorrSR,'position',[0.05,0.03,0.95,0.2]) % set position
                set(CorrSR,'Color','white')
                set(CorrSR,'Name','Acycle: Stratigraphic Correlation | Sedimentation Rate')
                stairs(sedrate(:,1),sedrate(:,2));
                xlim([serxmin, serxmax])
                xlabel('Depth/Time')
                ylabel('Sedimentation Rate')
                handles.CorrSR = gcf;
            end
            % age model
            try figure(handles.CorrAgeMod)
                plot(agemodel(:,1),agemodel(:,2),'ko-')
                xlabel('Depth')
                ylabel('Time')
                title('Age Model')
            catch
                CorrAgeMod = figure;
                set(CorrAgeMod,'units','norm') % set units as normalized
                set(CorrAgeMod,'position',[0.05,0.5,0.5,0.45]) % set position
                set(CorrAgeMod,'Color','white')
                set(CorrAgeMod,'Name','Acycle: Age Model')
                plot(agemodel(:,1),agemodel(:,2),'ko-')
                xlabel('Depth')
                ylabel('Time')
                title('Age Model')
                handles.CorrAgeMod = gcf;
                try figure(handles.CorrSR)
                catch
                end
                try figure(handles.CorrFig)
                catch
                end
            end
            %
            i = i + 1;
        else
            % delete the tie points in the reference
            tiepoints1(i,:) = [];
            subplot(3,1,1)
            % plot
            plot(rawref(:,1),rawref(:,2),'k-')
            xlim([refxmin, refxmax])
            hold on
            plot(tiepoints1(:,1),tiepoints1(:,2),'r*')
            hold off
        end
    end
end

% save data
savedatayn = get(handles.checkbox1,'value');
if savedatayn == 1
    CDac_pwd; % cd ac_pwd dir
    [~,name1,~] = fileparts(handles.plot_s{1}); % reference
    [~,name2,ext2] = fileparts(handles.plot_s{2}); % series
    name1 = [name2,'-TD-',name1,ext2];
    namesr = [name2,'-TD-',name1,'-SAR',ext2];
    nameagemodel = [name2,'-TD-',name1,'-AgeMod',ext2];
    try
        dlmwrite(name1, data1t, 'delimiter', ',', 'precision', 9);
        dlmwrite(namesr,sedrate, 'delimiter', ',', 'precision', 9);
        dlmwrite(nameagemodel,agemodel, 'delimiter', ',', 'precision', 9);
    catch
    end
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton1.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
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

handles.plot_s{1} = get(handles.edit1,'string');
% dat1: reference
% dat2: series
try
    dat2 = load(handles.plot_s{1});
catch
    fid = fopen(handles.plot_s{1});
    data_ft = textscan(fid,'%f%f','EmptyValue', Inf);
    dat2 = cell2mat(data_ft);
    fclose(fid);
end

% sort
dat2 = sortrows(dat2);
% unique
dat2=findduplicate(dat2);
% remove empty 
dat2(any(isinf(dat2),2),:) = [];

xmax = nanmax(dat2(:,1));
xmin = nanmin(dat2(:,1));

set(handles.edit3,'String',num2str(xmin))
set(handles.edit4,'String',num2str(xmax))

handles.referencedata = dat2;
handles.refxmax = xmax;
handles.refxmin = xmin;

try figure(handles.RawDataFig)
    subplot(2,1,1)
    plot(dat2(:,1),dat2(:,2),'r-')
    xlim([xmin,xmax])
    xlabel('Depth/Time')
    ylabel('Value')
    title('Reference')
    subplot(2,1,2)
    try
        dat1 = handles.seriesdata;
        plot(dat1(:,1),dat1(:,2),'b-')
        xlim([min(dat1(:,1)),max(dat1(:,1))])
    catch
    end
    xlabel('Depth/Time')
    ylabel('Value')
    title('Series')
catch
    handles.RawDataFig = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gca,'position',[0.6,0.5,0.4,0.4]) % set position
    set(gcf,'Color','white')
    subplot(2,1,1)
    plot(dat2(:,1),dat2(:,2),'r-')
    xlim([xmin,xmax])
    xlabel('Depth/Time')
    ylabel('Value')
    title('Reference')
    subplot(2,1,2)
    try
        dat1 = handles.seriesdata;
        plot(dat1(:,1),dat1(:,2),'b-')
        xlim([min(dat1(:,1)),max(dat1(:,1))])
    catch
    end
    xlabel('Depth/Time')
    ylabel('Value')
    title('Series')
end
% Update handles structure
guidata(hObject, handles);


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
xmin = str2double(get(handles.edit3,'String'));
xmax = str2double(get(handles.edit4,'String'));
if xmin < handles.refxmin
    warndlg('Value is too small')
    set(handles.edit3,'String',num2str(handles.refxmin))
else
    try figure(handles.RawDataFig)
        subplot(2,1,1)
        xlim([xmin,xmax])
        figure(handles.hmain)
    catch
    end
end


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
xmin = str2double(get(handles.edit3,'String'));
xmax = str2double(get(handles.edit4,'String'));
if xmax > handles.refxmax
    warndlg('Value is too large')
    set(handles.edit4,'String',num2str(handles.refxmax))
else
    try figure(handles.RawDataFig)
        subplot(2,1,1)
        xlim([xmin,xmax])
        figure(handles.hmain)
    catch
    end
end

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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_dirML = pwd;
CDac_pwd; % cd ac_pwd dir
[file,path] = uigetfile({'*.*',  'All Files (*.*)'},...
                        'Select a Reference Series');
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

% sort
dat2 = sortrows(dat2);
% unique
dat2=findduplicate(dat2);
% remove empty 
dat2(any(isinf(dat2),2),:) = [];

xmax = nanmax(dat2(:,1));
xmin = nanmin(dat2(:,1));

set(handles.edit5,'String',num2str(xmin))
set(handles.edit6,'String',num2str(xmax))

handles.seriesdata = dat2;
handles.serxmax = xmax;
handles.serxmin = xmin;

try figure(handles.RawDataFig)
    subplot(2,1,1)
    try
        dat1 = handles.referencedata;
        plot(dat1(:,1),dat1(:,2),'r-')
        xlim([min(dat1(:,1)),max(dat1(:,1))])
    catch
    end
    xlabel('Depth/Time')
    ylabel('Value')
    title('Reference')
    subplot(2,1,2)
    plot(dat2(:,1),dat2(:,2),'b-')
    xlim([xmin,xmax])
    xlabel('Depth/Time')
    ylabel('Value')
    title('Series')
catch
    handles.RawDataFig = figure;
    set(0,'Units','normalized') % set units as normalized
    set(gca,'position',[0.6,0.5,0.4,0.4]) % set position
    set(gcf,'Color','white')
    subplot(2,1,1)
    try
        dat1 = handles.referencedata;
        plot(dat1(:,1),dat1(:,2),'r-')
        xlim([min(dat1(:,1)),max(dat1(:,1))])
    catch
    end
    xlabel('Depth/Time')
    ylabel('Value')
    title('Reference')
    subplot(2,1,2)
    plot(dat2(:,1),dat2(:,2),'b-')
    xlim([xmin,xmax])
    xlabel('Depth/Time')
    ylabel('Value')
    title('Series')
end

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



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
xmin = str2double(get(handles.edit5,'String'));
xmax = str2double(get(handles.edit6,'String'));
if xmin < handles.serxmin
    warndlg('Value is too small')
    set(handles.edit5,'String',num2str(handles.serxmin))
else
    try figure(handles.RawDataFig)
        subplot(2,1,2)
        xlim([xmin,xmax])
        figure(handles.hmain)
    catch
    end
end

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
xmin = str2double(get(handles.edit5,'String'));
xmax = str2double(get(handles.edit6,'String'));
if xmax > handles.serxmax
    warndlg('Value is too large')
    set(handles.edit6,'String',num2str(handles.serxmax))
else
    try figure(handles.RawDataFig)
        subplot(2,1,2)
        xlim([xmin,xmax])
        figure(handles.hmain)
    catch
    end
end

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
