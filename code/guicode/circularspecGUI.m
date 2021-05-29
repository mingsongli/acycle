function varargout = circularspecGUI(varargin)
% CIRCULARSPECGUI MATLAB code for circularspecGUI.fig
%      CIRCULARSPECGUI, by itself, creates a new CIRCULARSPECGUI or raises the existing
%      singleton*.
%
%      H = CIRCULARSPECGUI returns the handle to a new CIRCULARSPECGUI or the handle to
%      the existing singleton*.
%
%      CIRCULARSPECGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CIRCULARSPECGUI.M with the given input arguments.
%
%      CIRCULARSPECGUI('Property','Value',...) creates a new CIRCULARSPECGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before circularspecGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to circularspecGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help circularspecGUI

% Last Modified by GUIDE v2.5 27-Apr-2021 18:25:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @circularspecGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @circularspecGUI_OutputFcn, ...
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


% --- Executes just before circularspecGUI is made visible.
function circularspecGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to circularspecGUI (see VARARGIN)

% Choose default command line output for circularspecGUI
handles.output = hObject;
%
handles.hmain = gcf;
%
handles.MonZoom = varargin{1}.MonZoom;
%
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
set(handles.hmain,'position',[0.2,0.3,0.35,0.2] * handles.MonZoom) % set position
set(gcf,'Name','Acycle: Circular spectral analysis')
dat =varargin{1}.current_data;  % data
handles.dat = dat;
handles.unit = varargin{1}.unit; % unit
handles.unit_type = varargin{1}.unit_type; % unit type
handles.slash_v = varargin{1}.slash_v;
handles.acfigmain = varargin{1}.acfigmain;

handles.data_name = varargin{1}.data_name; % save dataname
%handles.dat_name = varargin{1}.dat_name; % save dataname
handles.path_temp = varargin{1}.path_temp; % save path
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
set(handles.text2,'position',[0.05,0.85,0.1,0.075])
set(handles.text3,'position',[0.15,0.85,0.8,0.075])
set(handles.uipanel1,'position',[0.05,0.365,0.9,0.46])
set(handles.radiobutton1,'position',[0.025,0.5,0.12,0.34])
set(handles.radiobutton2,'position',[0.025,0.15,0.12,0.34])
set(handles.text4,'position',[0.18,0.5,0.12,0.19])
set(handles.edit1,'position',[0.325,0.5,0.1,0.324])
set(handles.text5,'position',[0.45,0.5,0.12,0.19])
set(handles.edit2,'position',[0.6,0.5,0.1,0.324])
set(handles.text6,'position',[0.72,0.5,0.13,0.19])
set(handles.edit3,'position',[0.85,0.5,0.1,0.324])
set(handles.text7,'position',[0.18,0.05,0.76,0.34])

set(handles.uipanel2,'position',[0.05,0.05,0.6,0.3])
set(handles.text8,'position',[0.015,0.376,0.2,0.35])
set(handles.edit5,'position',[0.22,0.376,0.2,0.4])
set(handles.radiobutton3,'position',[0.5,0.58,0.45,0.4])
set(handles.radiobutton4,'position',[0.5,0.1,0.45,0.4])
set(handles.checkbox1,'position',[0.66,0.155,0.15,0.14])
set(handles.checkbox2,'position',[0.66,0.055,0.15,0.14])
set(handles.pushbutton1,'position',[0.83,0.055,0.12,0.23])


[~, ncol] = size(dat);
if ncol == 1
else
    msgbox('More than 2 columns detected. 2nd column data was used','Info')
    dat = dat(:,2); % 
end

datx = dat(:,1);
datx = sort(datx);
diffx = diff(datx);
handles.dt = min(diffx)/2;
handles.fh = (max(datx) - min(datx))/2;
handles.sedmin = handles.dt;
handles.sedmax = handles.fh;
handles.numsed = 100;
handles.linLog = 2;

sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
sedinfo = ['test periods of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
    ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
set(handles.text7,'String',sedinfo)
set(handles.edit1,'string',num2str(handles.sedmin))
set(handles.edit2,'string',num2str(handles.sedmax))
set(handles.edit3,'string',num2str(handles.numsed))
set(handles.radiobutton1,'value',1)
set(handles.radiobutton2,'value',0)

[dat_dir,handles.filename,exten] = fileparts(handles.data_name);
set(handles.text3,'string',handles.filename)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes circularspecGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p1 = handles.sedmin;
p2 = handles.sedmax;
pn = handles.numsed;
mcn = str2double(get(handles.edit5,'String'));

savedata = get(handles.checkbox1,'value');
flipx = get(handles.checkbox2,'value');

if get(handles.radiobutton3,'Value') == 1
    clmodel = 2;
else
    clmodel = 1;
end

data = handles.dat;

[~, ncol] = size(data);
if ncol == 1
else
    data = data(:,2); % 
end
% User defined parameters

%%
% start
RR = zeros(mcn,pn);
plotn = 0;  % no plot for the Monte Carlo simulations

% Monte Carlo
if clmodel == 1
    for i = 1:mcn
        t2 = diff(data);
        tn3 = randperm(length(t2));
        tn4= [0;cumsum(t2(tn3))];
        [~,Ri,~] = circularspec(tn4,p1,p2,pn,handles.linLog,plotn);
        RR(i,:) = Ri;
    end
elseif clmodel == 2
    a = rand(length(data),mcn)*max(data);
    for i = 1:mcn    
        [~,Ri,~] = circularspec(a(:,i),p1,p2,pn,handles.linLog,plotn);
        RR(i,:) = Ri;
    end
end

% percentile
prt = [50,90,95,99,99.5];
Y = prctile(RR,prt,1);

% real power spectrum
[P,R,t0] = circularspec(data,p1,p2,pn,handles.linLog,0);

% confidence levels
cl = zeros(1,pn);
for j = 1: length(cl)
    percj = [RR(:,j);R(j)];
    cl(j) = length(percj(percj<R(j)))/(1+mcn);
end

% plot
plotn = 1;
if plotn
    figure;set(gcf,'Color', 'white')
    subplot(2,1,1)
    xlabel(['Period (',handles.unit,')'])
    ylabel('Power')
    hold on;
    plot(P,Y(5,:),'c-','LineWidth',1)
    plot(P,Y(4,:),'g-','LineWidth',1)
    plot(P,Y(3,:),'r-','LineWidth',3)
    plot(P,Y(2,:),'b-','LineWidth',1)
    plot(P,Y(1,:),'k-','LineWidth',1)
    plot(P,R,'LineWidth',1,'color',[0.9290, 0.6940, 0.1250])
    hold off
    xlim([p1,p2])
    legend('99.9%','99%','95%','90%','50%','power')
    if flipx; set(gca, 'XDir','reverse'); end
    
    subplot(2,1,2)
    hold on
    plot(P,ones(1,pn)*95,'r-','LineWidth',3)
    plot(P,ones(1,pn)*99,'g-','LineWidth',1)
    plot(P,ones(1,pn)*99.9,'c-','LineWidth',1)
    plot(P,cl*100,'LineWidth',1,'color',[0.9290, 0.6940, 0.1250])
    hold off
    ylim([90,100])
    xlabel(['Period (',handles.unit,')'])
    ylabel('Confidence level (%)')
    xlim([p1,p2])
    if flipx; set(gca, 'XDir','reverse'); end
end
if savedata ==1
    xx = [P',R',Y',cl'];
    name1 = [handles.filename,'-CSA','.txt'];
    CDac_pwd
    dlmwrite(name1, xx, 'delimiter', ',', 'precision', 9); 
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
    disp(['>> saved data: ',name1])
    disp(' Col  #1      #2    #3   #4   #5   #6    #7    #8')
    disp('    period, power, 50%, 90%, 95%, 99%, 99.5%, Conf.Level')
end

% --- Outputs from this function are returned to the command line.
function varargout = circularspecGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


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


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
val = get(handles.radiobutton3,'Value');
if val == 1
    set(handles.radiobutton4, 'Value', 0);
else
    set(handles.radiobutton4, 'Value', 1);
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
else
    set(handles.radiobutton3, 'Value', 1);
end

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
if handles.sedmin < handles.sedmax
    if handles.sedmin < handles.dt
        sedmin = handles.dt;
        msgbox(['Minimum is beyond the detection limit ', num2str(sedmin)],'Warning')
    end
    sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
    sedinfo = ['test periods of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' ',handles.unit];
    set(handles.text7,'String',sedinfo)
else
    msgbox(['Minimum is larger than maximum'],'Warning')
end
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
if handles.sedmax > handles.sedmin    
    if handles.sedmax > handles.fh
        msgbox(['Maximum is beyond the detection limit ', num2str(handles.fh),' ',handles.unit],'Warning')
    end
    % display
    sr = linspace(handles.sedmin,handles.sedmax,handles.numsed);
    sedinfo = ['test sed. rates of ',num2str(sr(1),'% 3.3f'),', ', num2str(sr(2),'% 3.3f'),...
        ', ',num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' cm/kyr'];
    set(handles.text7,'String',sedinfo)
else
    msgbox(['Maximum is smaller than minimum'],'Warning')
end
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
if handles.numsed > 0
    if rem(handles.numsed,1)
        handles.numsed = round(handles.numsed);
        set(handles.edit3,'string',num2str(handles.numsed))
    end
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
    
else
    msgbox('Number should be large than 0','Warning')
end
if handles.numsed > 2000
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
