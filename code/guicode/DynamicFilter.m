function varargout = DynamicFilter(varargin)
% DYNAMICFILTER MATLAB code for DynamicFilter.fig
%      DYNAMICFILTER, by itself, creates a new DYNAMICFILTER or raises the existing
%      singleton*.
%
%      H = DYNAMICFILTER returns the handle to a new DYNAMICFILTER or the handle to
%      the existing singleton*.
%
%      DYNAMICFILTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYNAMICFILTER.M with the given input arguments.
%
%      DYNAMICFILTER('Property','Value',...) creates a new DYNAMICFILTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DynamicFilter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DynamicFilter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DynamicFilter

% Last Modified by GUIDE v2.5 29-Jun-2020 01:00:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DynamicFilter_OpeningFcn, ...
                   'gui_OutputFcn',  @DynamicFilter_OutputFcn, ...
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


% --- Executes just before DynamicFilter is made visible.
function DynamicFilter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DynamicFilter (see VARARGIN)
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;

set(gcf,'Name','Acycle: Dynamic Filtering | Frequency Stabilization')
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
set(gcf,'position',[0.63,0.4,0.35,0.22]* handles.MonZoom) % set position

set(handles.uibuttongroup1,'position',[0.05,0.35,0.38,0.55])
set(handles.uipanel1,'position',[0.45,0.35,0.25,0.55])
set(handles.text3,'position',[0.05,0.7,0.4,0.24])
set(handles.radiobutton2,'position',[0.05,0.4,0.6,0.24])
set(handles.radiobutton1,'position',[0.05,0.1,0.5,0.24])
set(handles.edit2,'position',[0.65,0.7,0.3,0.27])
set(handles.text2,'position',[0.65,0.4,0.3,0.22])
set(handles.edit1,'position',[0.65,0.1,0.3,0.27])

set(handles.uipanel2,'position',[0.73,0.35,0.22,0.55])
set(handles.edit3,'position',[0.1,0.55,0.4,0.27])
set(handles.pushbutton1,'position',[0.55,0.55,0.4,0.27])
set(handles.edit4,'position',[0.1,0.1,0.4,0.27])
set(handles.text4,'position',[0.55,0.1,0.4,0.27])

set(handles.uipanel3,'Units','normalized','position',[0.05,0.05,0.77,0.25])
set(handles.edit5,'position',[0.1,0.55,0.75,0.27])
set(handles.pushbutton2,'position',[0.1,0.1,0.75,0.27])

set(handles.pushbutton4,'Units','normalized','position',[0.85,0.05,0.1,0.25])
set(handles.checkbox1,'position',[0.03,0.2,0.45,0.7])
set(handles.checkbox2,'position',[0.5,0.2,0.275,0.7])
set(handles.popupmenu1,'position',[0.75,0.2,0.23,0.7])

data_s = varargin{1}.current_data;
% remove mean value
data_s(:,2) = data_s(:,2) - mean(data_s(:,2));
%
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
handles.current_data = data_s;
handles.filename = varargin{1}.filename;
handles.data_name = varargin{1}.data_name; % save dataname
handles.path_temp = varargin{1}.path_temp;
handles.ext = varargin{1}.ext;
handles.slash_v = varargin{1}.slash_v;

xmin = min(data_s(:,1));
xmax = max(data_s(:,1));
mean1 = median(diff(data_s(:,1)));
handles.mean = mean1;
handles.step = 4*mean1;
handles.nyquist = 1/(2*handles.mean);     % prepare nyquist
handles.window = 0.2*(xmax-xmin);

handles.normal = 1;
handles.lenthx = xmax-xmin;
handles.time_0pad = 1;
handles.padtype = 1;
% if number of calculations is larger than 500;
% then, a large step is recommended. This way, the ncal is ~500.
ncal = (xmax-xmin - handles.window)/mean1;
if ncal > 500
    handles.step = abs(xmax - xmin - handles.window)/500;
end
set(handles.edit2, 'String', '0');
set(handles.edit4, 'String', handles.unit);
set(handles.text2, 'String', num2str(handles.nyquist));
set(handles.edit1, 'String', num2str(0.5*handles.nyquist));
set(handles.edit3, 'String', num2str(handles.step),'Value',1);
set(handles.edit5, 'String', num2str(handles.window));
set(handles.radiobutton2, 'Value',1);
set(handles.radiobutton1, 'Value',0);
set(handles.checkbox2, 'Value',1);
set(handles.checkbox1, 'Value',1);
set(handles.popupmenu1, 'Value',1);

% Choose default command line output for DynamicFilter
handles.output = hObject;

diffx = diff(data_s(:,1));
if max(diffx) - min(diffx) > 2*eps('single')
    hwarn = warndlg('Not equally spaced data. Interpolated using mean sampling rate!');
    interpolate_rate = mean(diffx);
    handles.current_data = interpolate(data_s,interpolate_rate);
    %set(0,'Units','normalized') % set units as normalized
    set(gcf,'units','norm') % set location
    set(gcf,'position',[0.15,0.6,0.25,0.1])
    figure(hwarn);
end

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes DynamicFilter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DynamicFilter_OutputFcn(hObject, eventdata, handles) 
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
handles.normal = get(handles.checkbox1,'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
handles.time_0pad = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};
if strcmp(val,'zero')
    %disp('zero')
    handles.padtype = 1;
elseif strcmp(val,'mirror')
    %disp('mirror')
    handles.padtype = 2;
elseif strcmp(val,'mean')
    %disp('mean')
    handles.padtype = 3;
elseif strcmp(val,'random')
    %disp('random')
    handles.padtype = 4;
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

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figft = gcf;
data =  handles.current_data;
window = handles.window;
fmin = str2double(get(handles.edit2,'String'));
fmax_select = get(handles.radiobutton2,'Value');
if fmax_select == 1
    fmax = handles.nyquist;
else
    fmax = str2double(get(handles.edit1,'String'));
end
unit = get(handles.edit4,'String');
step = str2double(get(handles.edit3,'String'));
norm = handles.normal;
padding = handles.padtype;

% plot data
figdata = figure;
plot(data(:,1),data(:,2),'k-')
xlabel(['Depth (',unit,')'])
ylabel('Value')
title('Data')
set(gca,'TickDir','out')
xlim([min(data(:,1)),max(data(:,1))])
set(figdata,'units','norm') % set location
set(figdata,'position',[0.05,0.02,0.9,0.3]) % set position
set(figdata,'Name','Acycle: Data') % set position

[xdata_filtered,time,freqboundlow,freqboundhigh]=dynamic_filter(data,window,step,fmin,fmax,unit,norm,padding);
% save figure handles
figdynfilter = gcf;

% save data
CDac_pwd;
[dat_dir,data_name,ext] = fileparts(handles.filename);
name0 = [data_name,'-','DynFilter'];
name1 = [name0,ext];  % name for file
log_name = [data_name,'-','DynFilter-log',ext];
dynfilfigname = [data_name,'-','DynFilter'];
dynfilfigname1 = [dynfilfigname,'.fig'];

if exist([pwd,handles.slash_v,log_name]) || exist([pwd,handles.slash_v,name1]) || exist([pwd,handles.slash_v,dynfilfigname1])
    for i = 1:100
        name1 = [name0,'-',num2str(i),ext];  % name for file
        log_name = [data_name,'-','DynFilter-',num2str(i),'-log',ext];
        dynfilfigname1 = [dynfilfigname,'-',num2str(i),'.fig'];
        if exist([pwd,handles.slash_v,log_name]) || exist([pwd,handles.slash_v,name1]) || exist([pwd,handles.slash_v,dynfilfigname1])
        else
            break
        end
    end
end

dlmwrite(name1, [time,xdata_filtered'], 'delimiter', ' ', 'precision', 9);

figure(figdynfilter);
savefig(dynfilfigname1) % save ac.fig

figure(figdata);
hold on;
plot(time, xdata_filtered,'r-')
title('Data & dynamic filtered output')
hold off;

% open and write log into log_name file
fileID = fopen(fullfile(dat_dir,log_name),'w+');
fprintf(fileID,'%s\n','% - - - - - - - - - - - - - Summary - - - - - - - - - - -');
fprintf(fileID,'%s\n',datestr(datetime('now')));
fprintf(fileID,'%s\n',log_name);
fprintf(fileID,'\n');
fprintf(fileID,'%s\n','%lower frequency boundary');
fprintf(fileID,'\n');
for ii = 1:size(freqboundlow,1)
    fprintf(fileID,'%f\t',freqboundlow(ii,:));
    fprintf(fileID,'\n');
end
fprintf(fileID,'\n');
fprintf(fileID,'%s\n','%higher frequency boundary');
fprintf(fileID,'\n');
for ii = 1:size(freqboundlow,1)
    fprintf(fileID,'%f\t',freqboundhigh(ii,:));
    fprintf(fileID,'\n');
end
fclose(fileID);
%
cd(pre_dirML); % return to matlab view folder
% refresh AC main window
figure(handles.acfigmain);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir
figure(figft);
figure(figdynfilter);
figure(figdata);

guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evofft_tips_win = 'Tips: window  < total data length; window ~= 2x aimed cycle. i.e. 20 m for a 10-m cycles';
warndlg(evofft_tips_win,'Tips: window length')

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
handles.window = str2double(get(hObject,'String'));

% if number of calculations is larger than 500;
% then, a large step is recommended. This way, the ncal is ~500.
ncal = (handles.lenthx - handles.window)/handles.mean;
if ncal > 500
    handles.step = abs(handles.lenthx - handles.window)/500;
end
set(handles.edit3, 'String', num2str(handles.step),'Value',1);

guidata(hObject,handles)

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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evofft_tips_step = 'Tips: Step  >= mean sample rate';
warndlg(evofft_tips_step,'Tips: Step length')


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
val = str2double(get(hObject,'String'));
if val < handles.mean
    warndlg('Step must be no smaller than the mean sampling rate','Warning')
    set(handles.edit3,'string',num2str(handles.mean))
end
if val > 0.5 * handles.lenthx
    warndlg('Step is too large','Warning')
    set(handles.edit3,'string',num2str(handles.mean * 5))
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



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
val = str2double(get(hObject,'String'));
if val <= str2double(get(handles.edit2,'String'))
    warndlg('Maximum Freq. must be larger than freq. min','Warning')
    set(handles.edit1,'string',num2str(handles.nyquist * 0.5))
end
if val > handles.nyquist
    warndlg('Maximum Freq. must be no larger than the Nyquist frequency','Warning')
    set(handles.edit1,'string',num2str(handles.nyquist))
end
set(handles.radiobutton1,'value',1)
set(handles.radiobutton2,'value',0)


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
val = str2double(get(hObject,'String'));
if val >= handles.nyquist
    warndlg('Freq. min must be smaller than the Nyquist frequency','Warning')
    set(handles.edit2,'string','0')
end
if val < 0
    warndlg('Freq. min must be no less than 0','Warning')
    set(handles.edit2,'string','0')
end

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
