function varargout = linegenerator(varargin)
% LINEGENERATOR MATLAB code for linegenerator.fig
%      LINEGENERATOR, by itself, creates a new LINEGENERATOR or raises the existing
%      singleton*.
%
%      H = LINEGENERATOR returns the handle to a new LINEGENERATOR or the handle to
%      the existing singleton*.
%
%      LINEGENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LINEGENERATOR.M with the given input arguments.
%
%      LINEGENERATOR('Property','Value',...) creates a new LINEGENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before linegenerator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to linegenerator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help linegenerator

% Last Modified by GUIDE v2.5 16-May-2019 16:58:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @linegenerator_OpeningFcn, ...
                   'gui_OutputFcn',  @linegenerator_OutputFcn, ...
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


% --- Executes just before linegenerator is made visible.
function linegenerator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to linegenerator (see VARARGIN)

% Choose default command line output for linegenerator
handles.output = hObject;

handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
set(gcf,'Name','Acycle: Signal Noise Generator')
% set x axis position
set(handles.text2,'Position',[0.013, 0.933, 0.069, 0.029])  % X axis:
set(handles.text3,'Position',[0.013, 0.858, 0.05, 0.029])  % From
set(handles.text4,'Position',[0.013, 0.807, 0.05, 0.029])  % to
set(handles.text5,'Position',[0.013, 0.747, 0.05, 0.029])  % step
set(handles.text33,'Position',[0.013, 0.641, 0.12, 0.07])  % selected data
set(handles.edit1,'Position',[0.06, 0.847, 0.075, 0.049])  % 0
set(handles.edit2,'Position',[0.06, 0.792, 0.075, 0.049])  % 1000
set(handles.edit3,'Position',[0.06, 0.736, 0.075, 0.049])  % 1
set(handles.text34,'Position',[0.173, 0.933, 0.069, 0.029])  % X axis:
% set y axis position
set(handles.radiobutton1,'Position',[0.173, 0.87, 0.125, 0.05])  % poly
set(handles.radiobutton2,'Position',[0.173, 0.772, 0.125, 0.05])  % 
set(handles.radiobutton3,'Position',[0.173, 0.7, 0.125, 0.05])  % 
set(handles.radiobutton4,'Position',[0.173, 0.65, 0.125, 0.05])  % 
% poly
set(handles.popupmenu1,'Position',[0.3, 0.887, 0.1, 0.06])  % poly
set(handles.text8,'Position',[0.398, 0.918, 0.056, 0.029])  % y =
set(handles.text9,'Position',[0.489, 0.918, 0.029, 0.029])  % +
set(handles.text10,'Position',[0.569, 0.918, 0.029, 0.029])  % x
set(handles.text11,'Position',[0.598, 0.918, 0.029, 0.029])  % + 
set(handles.text12,'Position',[0.678, 0.918, 0.029, 0.029])  %
set(handles.text13,'Position',[0.715, 0.918, 0.029, 0.029])  %
set(handles.text14,'Position',[0.795, 0.918, 0.029, 0.029])  %
set(handles.text15,'Position',[0.836, 0.918, 0.029, 0.029])  %
set(handles.text16,'Position',[0.916, 0.918, 0.029, 0.029])  %
set(handles.text17,'Position',[0.489, 0.858, 0.029, 0.029])  % +
set(handles.text18,'Position',[0.569, 0.858, 0.029, 0.029])  % x
set(handles.text19,'Position',[0.598, 0.858, 0.029, 0.029])  % + 
set(handles.text20,'Position',[0.678, 0.858, 0.029, 0.029])  %
set(handles.text21,'Position',[0.715, 0.858, 0.029, 0.029])  %
set(handles.text22,'Position',[0.795, 0.858, 0.029, 0.029])  %
set(handles.text23,'Position',[0.836, 0.858, 0.029, 0.029])  %
set(handles.text24,'Position',[0.916, 0.858, 0.029, 0.029])  %
set(handles.edit5,'Position',[0.441, 0.902, 0.044, 0.049])  %
set(handles.edit6,'Position',[0.518, 0.902, 0.044, 0.049])  %
set(handles.edit7,'Position',[0.627, 0.902, 0.044, 0.049])  %
set(handles.edit8,'Position',[0.744, 0.902, 0.044, 0.049])  %
set(handles.edit9,'Position',[0.866, 0.902, 0.044, 0.049])  %
set(handles.edit10,'Position',[0.518, 0.849, 0.044, 0.049])  %
set(handles.edit11,'Position',[0.627, 0.849, 0.044, 0.049])  %
set(handles.edit12,'Position',[0.744, 0.849, 0.044, 0.049])  %
set(handles.edit13,'Position',[0.866, 0.849, 0.044, 0.049])  %
% sine
set(handles.text26,'Position',[0.398, 0.783, 0.056, 0.029])  % y =
set(handles.text27,'Position',[0.489, 0.783, 0.108, 0.029])  %
set(handles.text28,'Position',[0.644, 0.783, 0.02, 0.029])  %
set(handles.text29,'Position',[0.715, 0.783, 0.02, 0.029])  %
set(handles.edit14,'Position',[0.441, 0.774, 0.044, 0.049])  %
set(handles.edit15,'Position',[0.603, 0.774, 0.044, 0.049])  %
set(handles.edit16,'Position',[0.666, 0.774, 0.044, 0.049])  %
set(handles.edit17,'Position',[0.739, 0.774, 0.044, 0.049])  %
% noise
set(handles.text30,'Position',[0.302, 0.687, 0.056, 0.029])  % mean
set(handles.text31,'Position',[0.406, 0.687, 0.123, 0.029])  % 
set(handles.text32,'Position',[0.586, 0.687, 0.045, 0.029],'Visible','off')  % 
set(handles.edit18,'Position',[0.358, 0.678, 0.044, 0.049])  %
set(handles.edit19,'Position',[0.531, 0.678, 0.044, 0.049])  %
set(handles.edit20,'Position',[0.636, 0.678, 0.044, 0.049],'Visible','off')  %
set(handles.radiobutton5,'Position',[0.586, 0.701, 0.162, 0.05],'Visible','off')  % 
set(handles.radiobutton6,'Position',[0.586, 0.652, 0.162, 0.05],'Visible','off')  % 
% pushbutton and axes
set(handles.pushbutton1,'Position',[0.868, 0.665, 0.1, 0.085])  % 
set(handles.line_axes1,'Position',[0.065, 0.065, 0.897, 0.557])  % 
% set values
set(handles.popupmenu1, 'Value', 1)
set(handles.edit1, 'String', 0)
set(handles.edit2, 'String', 1000)
set(handles.edit3, 'String', 1)

handles.xfixed = 0;  % x axis is determined by selected data? 0 = no, 1 = yes
try
    % detect selected data
    data = varargin{1}.current_data;
    handles.xfixed = 1;  % x axis is determined by selected data? 0 = no, 1 = yes
    x = data(:,1); % read first column
    set(handles.edit1, 'Enable', 'off')
    set(handles.edit2, 'Enable', 'off')
    set(handles.edit3, 'Enable', 'off')
    handles.x1 = min(x);
    handles.x2 = max(x);
    set(handles.edit1, 'String', num2str(handles.x1))
    set(handles.edit2, 'String', num2str(handles.x2))
    set(handles.edit3, 'String', '')
    handles.x = x;
catch
    % no data selected
    handles.x1 = str2double(get(handles.edit1, 'String'));
    handles.x2 = str2double(get(handles.edit2, 'String'));
    handles.x_step = str2double(get(handles.edit3, 'String'));
    x = handles.x1 : handles.x_step : handles.x2;
    x = x';
    set(handles.text33, 'Visible', 'off')
end

handles.poly = str2double(get(handles.popupmenu1, 'Value'));
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
set(handles.edit6, 'Enable', 'off')
set(handles.edit7, 'Enable', 'off')
set(handles.edit8, 'Enable', 'off')
set(handles.edit9, 'Enable', 'off')
set(handles.edit10, 'Enable', 'off')
set(handles.edit11, 'Enable', 'off')
set(handles.edit12, 'Enable', 'off')
set(handles.edit13, 'Enable', 'off')
set(handles.edit14,'Enable','off')
set(handles.edit15,'Enable','off')
set(handles.edit16,'Enable','off')
set(handles.edit17,'Enable','off')
set(handles.radiobutton1, 'Value',1)
set(handles.radiobutton2, 'Value',0)
set(handles.popupmenu1, 'Enable','on')
set(handles.edit5, 'Enable','on')
% plot
y = zeros(length(x),1) + handles.b;
axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
handles.genwhite = 0;
handles.genred = 0;
handles.filename = 'SigGen-linear-1.txt';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes linegenerator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = linegenerator_OutputFcn(hObject, eventdata, handles) 
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

if get(handles.radiobutton2,'Value')
    A = str2double(get(handles.edit14,'String'));
    T = str2double(get(handles.edit15,'String'));
    Ph = str2double(get(handles.edit16,'String'));
    B = str2double(get(handles.edit17,'String'));
    handles.filename = ['SigGen-sineA',num2str(A),'T',num2str(T),'Ph',num2str(Ph),'B',num2str(B),'.txt'];
end
if get(handles.radiobutton1,'Value')
    contents = cellstr(get(handles.popupmenu1,'String'));
    handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
    handles.b = str2double(get(handles.edit5, 'String'));
    handles.a1 = str2double(get(handles.edit6, 'String'));
    handles.a2 = str2double(get(handles.edit7, 'String'));
    handles.a3 = str2double(get(handles.edit8, 'String'));
    handles.a4 = str2double(get(handles.edit9, 'String'));
    handles.a5 = str2double(get(handles.edit10, 'String'));
    handles.a6 = str2double(get(handles.edit11, 'String'));
    handles.a7 = str2double(get(handles.edit12, 'String'));
    handles.a8 = str2double(get(handles.edit13, 'String'));
    if handles.poly == 0
        handles.filename = ['SigGen-linear-0-',get(handles.edit5, 'String'),'.txt'];
    elseif  handles.poly ==1
        handles.filename = ['SigGen-linear-1-',get(handles.edit5, 'String'),'+',get(handles.edit6, 'String'),'x.txt'];
    elseif  handles.poly ==2
        handles.filename = ['SigGen-linear-2-',get(handles.edit5, 'String'),'+',...
            get(handles.edit6, 'String'),'x+',get(handles.edit7, 'String'),'x2.txt'];
    else
        handles.filename = ['SigGen-poly-',num2str(handles.poly),'-',get(handles.edit5, 'String'),'+',...
            get(handles.edit6, 'String'),'x+',get(handles.edit7, 'String'),'x2+more.txt'];
    end
end
if get(handles.radiobutton3,'Value')
    % white noise
    mean = str2double(get(handles.edit18, 'String'));
    std = str2double(get(handles.edit19, 'String'));
    if get(handles.radiobutton5,'Value')
        dist = 'normdist';
    else
        dist = 'randdist';
    end
    handles.filename = ['SigGen-whitenoise-',num2str(std),'std-',num2str(mean),'mean-',dist,'.txt'];
end
if get(handles.radiobutton4,'Value')
    % red noise
    mean = str2double(get(handles.edit18, 'String'));
    std = str2double(get(handles.edit19, 'String'));
    alpha = str2double(get(handles.edit20, 'String'));
    handles.filename = ['SigGen-rednoise-',num2str(std),'std-',num2str(mean),'mean-',num2str(alpha),'alpha.txt'];
end

CDac_pwd; % cd ac_pwd dir
dlmwrite(handles.filename, [handles.x,handles.y], 'delimiter', ',', 'precision', 9);
% refresh AC main window
figure(handles.acfigmain);
%CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir
%
guidata(hObject, handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.x1 = str2double(get(handles.edit1, 'String'));
handles.x2 = str2double(get(handles.edit2, 'String'));
handles.x_step = str2double(get(handles.edit3, 'String'));
x = handles.x1 : handles.x_step : handles.x2;
x = x';

if get(handles.radiobutton1,'Value')
    contents = cellstr(get(handles.popupmenu1,'String'));
    handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
    handles.b = str2double(get(handles.edit5, 'String'));
    handles.a1 = str2double(get(handles.edit6, 'String'));
    handles.a2 = str2double(get(handles.edit7, 'String'));
    handles.a3 = str2double(get(handles.edit8, 'String'));
    handles.a4 = str2double(get(handles.edit9, 'String'));
    handles.a5 = str2double(get(handles.edit10, 'String'));
    handles.a6 = str2double(get(handles.edit11, 'String'));
    handles.a7 = str2double(get(handles.edit12, 'String'));
    handles.a8 = str2double(get(handles.edit13, 'String'));
    % plot

    a1 = handles.a1;
    a2 = handles.a2;
    a3 = handles.a3;
    a4 = handles.a4;
    a5 = handles.a5;
    a6 = handles.a6;
    a7 = handles.a7;
    a8 = handles.a8;

    set(handles.edit13, 'Enable', 'on') % 8
    set(handles.edit12, 'Enable', 'on')
    set(handles.edit11, 'Enable', 'on')
    set(handles.edit10, 'Enable', 'on')
    set(handles.edit9, 'Enable', 'on')
    set(handles.edit8, 'Enable', 'on')
    set(handles.edit7, 'Enable', 'on')
    set(handles.edit6, 'Enable', 'on')

    if handles.poly < 8
        set(handles.edit13, 'Enable', 'off') % 8
        a8 = 0;  
    end
    if handles.poly < 7
        set(handles.edit12, 'Enable', 'off') % 7
        a7 = 0; 
    end
    if handles.poly < 6
        set(handles.edit11, 'Enable', 'off') % 6
        a6 = 0; 
    end
    if handles.poly < 5
        set(handles.edit10, 'Enable', 'off') % 5
        a5 = 0; 
    end
    if handles.poly < 4
        set(handles.edit9, 'Enable', 'off') % 4
        a4 = 0; 
    end
    if handles.poly < 3
        set(handles.edit8, 'Enable', 'off') % 3
        a3 = 0; 
    end
    if handles.poly < 2
        set(handles.edit7, 'Enable', 'off') % 2
        a2 = 0; 
    end
    if handles.poly < 1
        set(handles.edit6, 'Enable', 'off') % 1
        a1 = 0;
    end

    y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end   
if get(handles.radiobutton2,'Value')
    % generate sine wave
    A = str2double(get(handles.edit14,'String'));
    T = str2double(get(handles.edit15,'String'));
    Ph = str2double(get(handles.edit16,'String'));
    B = str2double(get(handles.edit17,'String'));
    y = A * sin(2*pi/T*x + Ph) + B;
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
if get(handles.radiobutton3,'Value')
    % generate white noise
    mean = str2double(get(handles.edit18,'String'));
    std = str2double(get(handles.edit19,'String'));
    if get(handles.radiobutton5,'Value')
        % normal distribution
        y = std * randn(length(x),1) + mean;
    else
        y = std * zscore(rand(length(x),1)) + mean;
    end
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
if get(handles.radiobutton4,'Value')
    % generate red noise
    mean = str2double(get(handles.edit18,'String'));
    std = str2double(get(handles.edit19,'String'));
    alpha = str2double(get(handles.edit20,'String'));
    y = std * zscore(redmark(alpha,length(x))) + mean;
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
% Update handles structure
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
handles.x1 = str2double(get(handles.edit1, 'String'));
handles.x2 = str2double(get(handles.edit2, 'String'));
handles.x_step = str2double(get(handles.edit3, 'String'));
x = handles.x1 : handles.x_step : handles.x2;
x = x';

if get(handles.radiobutton1,'Value')
    contents = cellstr(get(handles.popupmenu1,'String'));
    handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
    handles.b = str2double(get(handles.edit5, 'String'));
    handles.a1 = str2double(get(handles.edit6, 'String'));
    handles.a2 = str2double(get(handles.edit7, 'String'));
    handles.a3 = str2double(get(handles.edit8, 'String'));
    handles.a4 = str2double(get(handles.edit9, 'String'));
    handles.a5 = str2double(get(handles.edit10, 'String'));
    handles.a6 = str2double(get(handles.edit11, 'String'));
    handles.a7 = str2double(get(handles.edit12, 'String'));
    handles.a8 = str2double(get(handles.edit13, 'String'));
    % plot

    a1 = handles.a1;
    a2 = handles.a2;
    a3 = handles.a3;
    a4 = handles.a4;
    a5 = handles.a5;
    a6 = handles.a6;
    a7 = handles.a7;
    a8 = handles.a8;

    set(handles.edit13, 'Enable', 'on') % 8
    set(handles.edit12, 'Enable', 'on')
    set(handles.edit11, 'Enable', 'on')
    set(handles.edit10, 'Enable', 'on')
    set(handles.edit9, 'Enable', 'on')
    set(handles.edit8, 'Enable', 'on')
    set(handles.edit7, 'Enable', 'on')
    set(handles.edit6, 'Enable', 'on')

    if handles.poly < 8
        set(handles.edit13, 'Enable', 'off') % 8
        a8 = 0;  
    end
    if handles.poly < 7
        set(handles.edit12, 'Enable', 'off') % 7
        a7 = 0; 
    end
    if handles.poly < 6
        set(handles.edit11, 'Enable', 'off') % 6
        a6 = 0; 
    end
    if handles.poly < 5
        set(handles.edit10, 'Enable', 'off') % 5
        a5 = 0; 
    end
    if handles.poly < 4
        set(handles.edit9, 'Enable', 'off') % 4
        a4 = 0; 
    end
    if handles.poly < 3
        set(handles.edit8, 'Enable', 'off') % 3
        a3 = 0; 
    end
    if handles.poly < 2
        set(handles.edit7, 'Enable', 'off') % 2
        a2 = 0; 
    end
    if handles.poly < 1
        set(handles.edit6, 'Enable', 'off') % 1
        a1 = 0;
    end

    y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end   
if get(handles.radiobutton2,'Value')
    % generate sine wave
    A = str2double(get(handles.edit14,'String'));
    T = str2double(get(handles.edit15,'String'));
    Ph = str2double(get(handles.edit16,'String'));
    B = str2double(get(handles.edit17,'String'));
    y = A * sin(2*pi/T*x + Ph) + B;
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
if get(handles.radiobutton3,'Value')
    % generate white noise
    mean = str2double(get(handles.edit18,'String'));
    std = str2double(get(handles.edit19,'String'));
    if get(handles.radiobutton5,'Value')
        % normal distribution
        y = std * randn(length(x),1) + mean;
    else
        y = std * zscore(rand(length(x),1)) + mean;
    end
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
if get(handles.radiobutton4,'Value')
    % generate red noise
    mean = str2double(get(handles.edit18,'String'));
    std = str2double(get(handles.edit19,'String'));
    alpha = str2double(get(handles.edit20,'String'));
    y = std * zscore(redmark(alpha,length(x))) + mean;
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
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
handles.x1 = str2double(get(handles.edit1, 'String'));
handles.x2 = str2double(get(handles.edit2, 'String'));
handles.x_step = str2double(get(handles.edit3, 'String'));
x = handles.x1 : handles.x_step : handles.x2;
x = x';

if get(handles.radiobutton1,'Value')
    contents = cellstr(get(handles.popupmenu1,'String'));
    handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
    handles.b = str2double(get(handles.edit5, 'String'));
    handles.a1 = str2double(get(handles.edit6, 'String'));
    handles.a2 = str2double(get(handles.edit7, 'String'));
    handles.a3 = str2double(get(handles.edit8, 'String'));
    handles.a4 = str2double(get(handles.edit9, 'String'));
    handles.a5 = str2double(get(handles.edit10, 'String'));
    handles.a6 = str2double(get(handles.edit11, 'String'));
    handles.a7 = str2double(get(handles.edit12, 'String'));
    handles.a8 = str2double(get(handles.edit13, 'String'));
    % plot

    a1 = handles.a1;
    a2 = handles.a2;
    a3 = handles.a3;
    a4 = handles.a4;
    a5 = handles.a5;
    a6 = handles.a6;
    a7 = handles.a7;
    a8 = handles.a8;

    set(handles.edit13, 'Enable', 'on') % 8
    set(handles.edit12, 'Enable', 'on')
    set(handles.edit11, 'Enable', 'on')
    set(handles.edit10, 'Enable', 'on')
    set(handles.edit9, 'Enable', 'on')
    set(handles.edit8, 'Enable', 'on')
    set(handles.edit7, 'Enable', 'on')
    set(handles.edit6, 'Enable', 'on')

    if handles.poly < 8
        set(handles.edit13, 'Enable', 'off') % 8
        a8 = 0;  
    end
    if handles.poly < 7
        set(handles.edit12, 'Enable', 'off') % 7
        a7 = 0; 
    end
    if handles.poly < 6
        set(handles.edit11, 'Enable', 'off') % 6
        a6 = 0; 
    end
    if handles.poly < 5
        set(handles.edit10, 'Enable', 'off') % 5
        a5 = 0; 
    end
    if handles.poly < 4
        set(handles.edit9, 'Enable', 'off') % 4
        a4 = 0; 
    end
    if handles.poly < 3
        set(handles.edit8, 'Enable', 'off') % 3
        a3 = 0; 
    end
    if handles.poly < 2
        set(handles.edit7, 'Enable', 'off') % 2
        a2 = 0; 
    end
    if handles.poly < 1
        set(handles.edit6, 'Enable', 'off') % 1
        a1 = 0;
    end

    y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end   
if get(handles.radiobutton2,'Value')
    % generate sine wave
    A = str2double(get(handles.edit14,'String'));
    T = str2double(get(handles.edit15,'String'));
    Ph = str2double(get(handles.edit16,'String'));
    B = str2double(get(handles.edit17,'String'));
    y = A * sin(2*pi/T*x + Ph) + B;
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
if get(handles.radiobutton3,'Value')
    % generate white noise
    mean = str2double(get(handles.edit18,'String'));
    std = str2double(get(handles.edit19,'String'));
    if get(handles.radiobutton5,'Value')
        % normal distribution
        y = std * randn(length(x),1) + mean;
    else
        y = std * zscore(rand(length(x),1)) + mean;
    end
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
if get(handles.radiobutton4,'Value')
    % generate red noise
    mean = str2double(get(handles.edit18,'String'));
    std = str2double(get(handles.edit19,'String'));
    alpha = str2double(get(handles.edit20,'String'));
    y = std * zscore(redmark(alpha,length(x))) + mean;
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
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

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
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

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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

contents = cellstr(get(handles.popupmenu1,'String'));
handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
handles.b = str2double(get(handles.edit5, 'String'));
handles.a1 = str2double(get(handles.edit6, 'String'));
handles.a2 = str2double(get(handles.edit7, 'String'));
handles.a3 = str2double(get(handles.edit8, 'String'));
handles.a4 = str2double(get(handles.edit9, 'String'));
handles.a5 = str2double(get(handles.edit10, 'String'));
handles.a6 = str2double(get(handles.edit11, 'String'));
handles.a7 = str2double(get(handles.edit12, 'String'));
handles.a8 = str2double(get(handles.edit13, 'String'));
% plot
x = handles.x;
a1 = handles.a1;
a2 = handles.a2;
a3 = handles.a3;
a4 = handles.a4;
a5 = handles.a5;
a6 = handles.a6;
a7 = handles.a7;
a8 = handles.a8;

set(handles.edit13, 'Enable', 'on') % 8
set(handles.edit12, 'Enable', 'on')
set(handles.edit11, 'Enable', 'on')
set(handles.edit10, 'Enable', 'on')
set(handles.edit9, 'Enable', 'on')
set(handles.edit8, 'Enable', 'on')
set(handles.edit7, 'Enable', 'on')
set(handles.edit6, 'Enable', 'on')

if handles.poly < 8
    set(handles.edit13, 'Enable', 'off') % 8
    a8 = 0;  
end
if handles.poly < 7
    set(handles.edit12, 'Enable', 'off') % 7
    a7 = 0; 
end
if handles.poly < 6
    set(handles.edit11, 'Enable', 'off') % 6
    a6 = 0; 
end
if handles.poly < 5
    set(handles.edit10, 'Enable', 'off') % 5
    a5 = 0; 
end
if handles.poly < 4
    set(handles.edit9, 'Enable', 'off') % 4
    a4 = 0; 
end
if handles.poly < 3
    set(handles.edit8, 'Enable', 'off') % 3
    a3 = 0; 
end
if handles.poly < 2
    set(handles.edit7, 'Enable', 'off') % 2
    a2 = 0; 
end
if handles.poly < 1
    set(handles.edit6, 'Enable', 'off') % 1
    a1 = 0;
end

y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
x = handles.x;
handles.genpoly = get(handles.radiobutton1,'Value');
if handles.genpoly == 1
    % select poly
    set(handles.radiobutton1,'Value',1)
    set(handles.radiobutton2,'Value',0)
    set(handles.radiobutton3,'Value',0)
    set(handles.radiobutton4,'Value',0)
    set(handles.radiobutton5,'Enable','off')
    set(handles.radiobutton6,'Enable','off')
    set(handles.popupmenu1,'Enable','on')
    set(handles.edit5,'Enable','on')
    set(handles.edit13, 'Enable', 'on') % 8
    set(handles.edit12, 'Enable', 'on')
    set(handles.edit11, 'Enable', 'on')
    set(handles.edit10, 'Enable', 'on')
    set(handles.edit9, 'Enable', 'on')
    set(handles.edit8, 'Enable', 'on')
    set(handles.edit7, 'Enable', 'on')
    set(handles.edit6, 'Enable', 'on')
    set(handles.edit14,'Enable','off')
    set(handles.edit15,'Enable','off')
    set(handles.edit16,'Enable','off')
    set(handles.edit17,'Enable','off')
    set(handles.edit18,'Enable','off')
    set(handles.edit19,'Enable','off')
    set(handles.edit20,'Enable','off')
    
    contents = cellstr(get(handles.popupmenu1,'String'));
    handles.poly = str2double(contents{get(handles.popupmenu1,'Value')});
    handles.b = str2double(get(handles.edit5, 'String'));
    handles.a1 = str2double(get(handles.edit6, 'String'));
    handles.a2 = str2double(get(handles.edit7, 'String'));
    handles.a3 = str2double(get(handles.edit8, 'String'));
    handles.a4 = str2double(get(handles.edit9, 'String'));
    handles.a5 = str2double(get(handles.edit10, 'String'));
    handles.a6 = str2double(get(handles.edit11, 'String'));
    handles.a7 = str2double(get(handles.edit12, 'String'));
    handles.a8 = str2double(get(handles.edit13, 'String'));
    % plot
    a1 = handles.a1;
    a2 = handles.a2;
    a3 = handles.a3;
    a4 = handles.a4;
    a5 = handles.a5;
    a6 = handles.a6;
    a7 = handles.a7;
    a8 = handles.a8;
    
    if handles.poly < 8
        set(handles.edit13, 'Enable', 'off') % 8
        a8 = 0;  
    end
    if handles.poly < 7
        set(handles.edit12, 'Enable', 'off') % 7
        a7 = 0; 
    end
    if handles.poly < 6
        set(handles.edit11, 'Enable', 'off') % 6
        a6 = 0; 
    end
    if handles.poly < 5
        set(handles.edit10, 'Enable', 'off') % 5
        a5 = 0; 
    end
    if handles.poly < 4
        set(handles.edit9, 'Enable', 'off') % 4
        a4 = 0; 
    end
    if handles.poly < 3
        set(handles.edit8, 'Enable', 'off') % 3
        a3 = 0; 
    end
    if handles.poly < 2
        set(handles.edit7, 'Enable', 'off') % 2
        a2 = 0; 
    end
    if handles.poly < 1
        set(handles.edit6, 'Enable', 'off') % 1
        a1 = 0;
    end

    y = handles.b + a1 * x + a2*x.^2+ a3*x.^3+ a4*x.^4+ a5*x.^5+ a6*x.^6+ a7*x.^7+ a8*x.^8;

    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

x = handles.x;

handles.gensin = get(handles.radiobutton2,'Value');
if handles.gensin == 1
    % sine plot
    set(handles.radiobutton1,'Value',0)
    set(handles.radiobutton2,'Value',1)
    set(handles.radiobutton3,'Value',0)
    set(handles.radiobutton4,'Value',0)
    set(handles.radiobutton5,'Enable','off')
    set(handles.radiobutton6,'Enable','off')
    set(handles.popupmenu1,'Enable','off')
    set(handles.edit5,'Enable','off')
    set(handles.edit6,'Enable','off')
    set(handles.edit7,'Enable','off')
    set(handles.edit8,'Enable','off')
    set(handles.edit9,'Enable','off')
    set(handles.edit10,'Enable','off')
    set(handles.edit11,'Enable','off')
    set(handles.edit12,'Enable','off')
    set(handles.edit13,'Enable','off')
    set(handles.edit14,'Enable','on')
    set(handles.edit15,'Enable','on')
    set(handles.edit16,'Enable','on')
    set(handles.edit17,'Enable','on')
    set(handles.edit18,'Enable','off')
    set(handles.edit19,'Enable','off')
    set(handles.edit20,'Enable','off')
    
    A = str2double(get(handles.edit14,'String'));
    T = str2double(get(handles.edit15,'String'));
    Ph = str2double(get(handles.edit16,'String'));
    B = str2double(get(handles.edit17,'String'));
    y = A * sin(2*pi/T*x + Ph) + B;
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
% Update handles structure
guidata(hObject, handles);

function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
x = handles.x;

A = str2double(get(handles.edit14,'String'));
T = str2double(get(handles.edit15,'String'));
Ph = str2double(get(handles.edit16,'String'));
B = str2double(get(handles.edit17,'String'));
y = A * sin(2*pi/T*x + Ph) + B;
axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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
x = handles.x;
A = str2double(get(handles.edit14,'String'));
T = str2double(get(handles.edit15,'String'));
Ph = str2double(get(handles.edit16,'String'));
B = str2double(get(handles.edit17,'String'));
y = A * sin(2*pi/T*x + Ph) + B;
axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
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
x = handles.x;
A = str2double(get(handles.edit14,'String'));
T = str2double(get(handles.edit15,'String'));
Ph = str2double(get(handles.edit16,'String'));
B = str2double(get(handles.edit17,'String'));
y = A * sin(2*pi/T*x + Ph) + B;
axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
guidata(hObject, handles);


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
x = handles.x;
A = str2double(get(handles.edit14,'String'));
T = str2double(get(handles.edit15,'String'));
Ph = str2double(get(handles.edit16,'String'));
B = str2double(get(handles.edit17,'String'));
y = A * sin(2*pi/T*x + Ph) + B;
axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
guidata(hObject, handles);


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


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
x = handles.x;

handles.genwhite = get(handles.radiobutton3,'Value');
if handles.genwhite == 1
    set(handles.radiobutton1,'Value',0)
    set(handles.radiobutton2,'Value',0)
    set(handles.radiobutton3,'Value',1)
    set(handles.radiobutton4,'Value',0)
    set(handles.radiobutton5,'Enable','on','Visible','on')
    set(handles.radiobutton6,'Enable','on','Visible','on')
    set(handles.popupmenu1,'Enable','off')
    set(handles.edit5,'Enable','off')
    set(handles.edit6,'Enable','off')
    set(handles.edit7,'Enable','off')
    set(handles.edit8,'Enable','off')
    set(handles.edit9,'Enable','off')
    set(handles.edit10,'Enable','off')
    set(handles.edit11,'Enable','off')
    set(handles.edit12,'Enable','off')
    set(handles.edit13,'Enable','off')
    set(handles.edit14,'Enable','off')
    set(handles.edit15,'Enable','off')
    set(handles.edit16,'Enable','off')
    set(handles.edit17,'Enable','off')
    set(handles.edit18,'Enable','on')
    set(handles.edit19,'Enable','on')
    set(handles.edit20,'Visible','off')
    set(handles.text32,'Visible','off')
    
    mean = str2double(get(handles.edit18,'String'));
    std = str2double(get(handles.edit19,'String'));
    if get(handles.radiobutton5,'Value')
        % normal distribution
        y = std * randn(length(x),1) + mean;
    else
        y = std * zscore(rand(length(x),1)) + mean;
    end
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
x = handles.x;

handles.genred = get(handles.radiobutton4,'Value');
if handles.genred == 1
    set(handles.radiobutton1,'Value',0)
    set(handles.radiobutton2,'Value',0)
    set(handles.radiobutton3,'Value',0)
    set(handles.radiobutton4,'Value',1)
    set(handles.radiobutton5,'Visible','off')
    set(handles.radiobutton6,'Visible','off')
    set(handles.popupmenu1,'Enable','off')
    set(handles.edit5,'Enable','off')
    set(handles.edit6,'Enable','off')
    set(handles.edit7,'Enable','off')
    set(handles.edit8,'Enable','off')
    set(handles.edit9,'Enable','off')
    set(handles.edit10,'Enable','off')
    set(handles.edit11,'Enable','off')
    set(handles.edit12,'Enable','off')
    set(handles.edit13,'Enable','off')
    set(handles.edit14,'Enable','off')
    set(handles.edit15,'Enable','off')
    set(handles.edit16,'Enable','off')
    set(handles.edit17,'Enable','off')
    set(handles.edit18,'Enable','on')
    set(handles.edit19,'Enable','on')
    set(handles.edit20,'Enable','on','Visible','on')
    set(handles.text32,'Enable','on','Visible','on')
    
    mean = str2double(get(handles.edit18,'String'));
    std = str2double(get(handles.edit19,'String'));
    alpha = str2double(get(handles.edit20,'String'));
    y = std * zscore(redmark(alpha,length(x))) + mean;
    axes(handles.line_axes1);
    plot(x,y,'r-o')
    xlim([min(x), max(x)])
    xlabel('x')
    ylabel('y')
    handles.x = x;
    handles.y = y;
end
% Update handles structure
guidata(hObject, handles);

function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double
x = handles.x;
mean = str2double(get(handles.edit18,'String'));
std = str2double(get(handles.edit19,'String'));
if handles.genwhite == 1
    if get(handles.radiobutton5,'Value')
        % normal distribution
        y = std * randn(length(x),1) + mean;
    else
        y = std * zscore(rand(length(x),1)) + mean;
    end
end
if handles.genred == 1
    alpha = str2double(get(handles.edit20,'String'));
    y = std * zscore(redmark(alpha,length(x))) + mean;
end

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
guidata(hObject, handles);

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
x = handles.x;
mean = str2double(get(handles.edit18,'String'));
std = str2double(get(handles.edit19,'String'));
if handles.genwhite == 1
    if get(handles.radiobutton5,'Value')
        % normal distribution
        y = std * randn(length(x),1) + mean;
    else
        y = std * zscore(rand(length(x),1)) + mean;
    end
end
if handles.genred == 1
    alpha = str2double(get(handles.edit20,'String'));
    y = std * zscore(redmark(alpha,length(x))) + mean;
end

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
guidata(hObject, handles);

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


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
x = handles.x;
mean = str2double(get(handles.edit18,'String'));
std = str2double(get(handles.edit19,'String'));

if get(handles.radiobutton5,'Value') == 1
    % normal distribution
    y = std * randn(length(x),1) + mean;
    set(handles.radiobutton6,'Value',0)
    set(handles.radiobutton5,'Value',1)
else
    y = std * zscore(rand(length(x),1)) + mean;
    set(handles.radiobutton6,'Value',1)
    set(handles.radiobutton5,'Value',0)
end

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
x = handles.x;
mean = str2double(get(handles.edit18,'String'));
std = str2double(get(handles.edit19,'String'));

if get(handles.radiobutton6,'Value') == 1
    y = std * zscore(rand(length(x),1)) + mean;
    set(handles.radiobutton6,'Value',1)
    set(handles.radiobutton5,'Value',0)
else
    % normal distribution
    y = std * randn(length(x),1) + mean;
    set(handles.radiobutton6,'Value',0)
    set(handles.radiobutton5,'Value',1)
end

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
guidata(hObject, handles);


function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double
x = handles.x;
mean = str2double(get(handles.edit18,'String'));
std = str2double(get(handles.edit19,'String'));
alpha = str2double(get(handles.edit20,'String'));
y = std * zscore(redmark(alpha,length(x))) + mean;

axes(handles.line_axes1);
plot(x,y,'r-o')
xlim([min(x), max(x)])
xlabel('x')
ylabel('y')
handles.x = x;
handles.y = y;
% Update handles structure
guidata(hObject, handles);

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
