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
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
set(handles.hmain,'position',[0.2,0.3,0.35,0.2]) % set position


set(gcf,'Name','Acycle: Circular spectral analysis')
handles.dat = varargin{1}.current_data;  % data
handles.unit = varargin{1}.unit; % unit
handles.unit_type = varargin{1}.unit_type; % unit type
handles.slash_v = varargin{1}.slash_v;
handles.acfigmain = varargin{1}.acfigmain;

handles.filename = varargin{1}.data_name; % save dataname
%handles.dat_name = varargin{1}.dat_name; % save dataname
handles.path_temp = varargin{1}.path_temp; % save path
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes circularspecGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p1 = str2double(get(handles.edit1,'String'));
p2 = str2double(get(handles.edit2,'String'));
pt = str2double(get(handles.edit3,'String'));
mcn = str2double(get(handles.edit5,'String'));

if get(handles.radiobutton3,'Value') == 1
    clmodel = 2;
else
    clmodel = 1;
end

data = handles.dat;

[nrow, ncol] = size(data);
if ncol == 1
else
    data = data(:,2); % 
end
% User defined parameters

%%
% start
P = p1:pt:p2;
Pn = length(P);
RR = zeros(mcn,Pn);
plotn = 0;  % no plot for the Monte Carlo simulations

% Monte Carlo
if clmodel == 1
    for i = 1:mcn
        t2 = diff(data);
        tn3 = randperm(length(t2));
        tn4= [0;cumsum(t2(tn3))];
        [~,Ri,~] = circularspec(tn4,pt,p1,p2,plotn);
        RR(i,:) = Ri;
    end
elseif clmodel == 2
    a = rand(length(data),mcn)*max(data);
    for i = 1:mcn    
        [~,Ri,~] = circularspec(a(:,i),pt,p1,p2,plotn);
        RR(i,:) = Ri;
    end
end

% percentile
prt = [50,90,95,99,99.5];
Y = prctile(RR,prt,1);

% real power spectrum
[P,R,t0] = circularspec(data,pt,p1,p2,0);

% confidence levels
cl = zeros(1,Pn);
for j = 1: length(cl)
    percj = [RR(:,j);R(j)];
    cl(j) = length(percj(percj<R(j)))/(1+mcn);
end

% plot
plotn = 1;
if plotn
    figure;
    subplot(2,1,1)
    xlabel('period')
    ylabel('power')
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
    subplot(2,1,2)
    hold on
    plot(P,ones(1,Pn)*95,'r-','LineWidth',3)
    plot(P,ones(1,Pn)*99,'g-','LineWidth',1)
    plot(P,ones(1,Pn)*99.9,'c-','LineWidth',1)
    plot(P,cl*100,'LineWidth',1,'color',[0.9290, 0.6940, 0.1250])
    hold off
    ylim([90,100])
    xlabel('period')
    ylabel('confidence level (%)')
    xlim([p1,p2])
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


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4


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
