function varargout = evofftGUI(varargin)
% evofftGUI MATLAB code for evofftGUI.fig
%      evofftGUI, by itself, creates a new evofftGUI or raises the existing
%      singleton*.
%
%      H = evofftGUI returns the handle to a new evofftGUI or the handle to
%      the existing singleton*.
%
%      evofftGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in evofftGUI.M with the given input arguments.
%
%      evofftGUI('Property','Value',...) creates a new evofftGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before evofftGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evofftGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help evofftGUI

% Last Modified by GUIDE v2.5 31-Dec-2017 15:50:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @evofftGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @evofftGUI_OutputFcn, ...
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


% --- Executes just before evofftGUI is made visible.
function evofftGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to evofftGUI (see VARARGIN)
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','points');  % find all font units as points
set(h1,'FontUnits','norm');  % set as norm
set(gcf,'position',[0.5,0.2,0.4,0.4]) % set position

% Choose default command line output for evofftGUI
handles.output = hObject;

set(gcf,'Name','Acycle: Evolutionary Spectral Analysis')
data_s = varargin{1}.current_data;
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
handles.current_data = data_s;
handles.filename = varargin{1}.data_name;
handles.unit = varargin{1}.unit;
handles.path_temp = varargin{1}.path_temp;

handles.plot_2d = 1;
handles.plot_log = 0;
handles.normal = 1;
handles.flipy = 1;
xmin = min(data_s(:,1));
xmax = max(data_s(:,1));
mean1 = median(diff(data_s(:,1)));
handles.mean = mean1;
handles.step = handles.mean;
handles.nyquist = 1/(2*handles.mean);     % prepare nyquist
handles.window = 0.2*(xmax-xmin);
handles.rotate = 0;
handles.method = 'Fast Fourier transform (LAH)';
handles.lenthx = xmax-xmin;
% if number of calculations is larger than 500;
% then, a large step is recommended. This way, the ncal is ~500.
ncal = (xmax-xmin - handles.window)/mean1;
if ncal > 500
    handles.step = abs(xmax - xmin - handles.window)/500;
end
%
set(handles.evofft_nyquist_text, 'String', num2str(handles.nyquist));
set(handles.evofft_fmax_edit, 'String', num2str(handles.nyquist));
set(handles.evofft_win_text, 'String', num2str(handles.window));
set(handles.edit8, 'String', handles.unit);
set(handles.edit_step, 'String', num2str(handles.step),'Value',1);
set(handles.evofft_Nyquist_radiobutton, 'Value',0,'Enable','Off');
set(handles.radiobutton2, 'Value',1,'Enable','Off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes evofftGUI wait for user response (see UIRESUME)
% uiwait(handles.evofftGUI_figure);


% --- Outputs from this function are returned to the command line.
function varargout = evofftGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = 0;
varargout{1} = handles.output;

guidata(hObject, handles);



function evofft_win_text_Callback(hObject, eventdata, handles)
% hObject    handle to evofft_win_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of evofft_win_text as text
%        str2double(get(hObject,'String')) returns contents of evofft_win_text as a double
handles.window = str2double(get(hObject,'String'));

% if number of calculations is larger than 500;
% then, a large step is recommended. This way, the ncal is ~500.
ncal = (handles.lenthx - handles.window)/handles.mean;
if ncal > 500
    handles.step = abs(handles.lenthx - handles.window)/500;
end
set(handles.edit_step, 'String', num2str(handles.step),'Value',1);

guidata(hObject,handles)


function edit_step_Callback(hObject, eventdata, handles)
% hObject    handle to edit_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_step as text
%        str2double(get(hObject,'String')) returns contents of edit_step as a double
content = get(hObject,'String');
handles.step = str2double(content);

% if number of calculations is larger than 500;
% then, a large step is recommended. This way, the ncal is ~500.
ncal = (handles.lenthx - handles.window)/handles.step;
if ncal > 500
    warndlg('Step is too small. Close this warning box and revise, OR come back after a cup of coffee ...')
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function munuPlot_Callback(hObject, eventdata, handles)
% hObject    handle to munuPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuEvofft_Callback(hObject, eventdata, handles)
% hObject    handle to menuEvofft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function evofft_win_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function evofft_fmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to evofft_fmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of evofft_fmax_edit as text
%        str2double(get(hObject,'String')) returns contents of evofft_fmax_edit as a double
fmax = str2double(get(handles.evofft_fmax_edit,'String'));
if isnan(fmax)
    set(handles.radiobutton2, 'Value', 0);
    set(handles.evofft_Nyquist_radiobutton, 'Value', 1);
    handles.evofft_fmax = handles.nyquist;
else
    set(handles.radiobutton2, 'Value', 1);
    set(handles.evofft_Nyquist_radiobutton, 'Value', 0);
    handles.evofft_fmax = fmax;
end

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function evofft_fmax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to evofft_fmax_edit (see GCBO)
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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uipanel2.
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel2 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
evofft_fmax = get(eventdata.NewValue, 'Tag');
if strcmp(evofft_fmax,'Use Nyquist')
    handles.evofft_fmax = handles.nyquist;
    set(handles.evofft_nyquist_text, 'String', num2str(handles.nyquist));
elseif strcmp(evofft_fmax,'Use Input')
    handles.evofft_fmax = handles.evofft_fmax_edit;
    set(handles.evofft_nyquist_text, 'String', num2str(handles.nyquist));
else
   % warndlg('Input maximum frequency for plot','Tips: window length')
end
guidata(hObject,handles)

% --- Executes on button press in evofft_Nyquist_radiobutton.
function evofft_Nyquist_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to evofft_Nyquist_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of evofft_Nyquist_radiobutton
% val = get(handles.evofft_Nyquist_radiobutton,'Value')
% if val > 0
%     set(handles.evofft_fmax_edit, 'Enable', 'off');
%     handles.evofft_fmax = handles.nyquist;
%     set(handles.radiobutton2, 'Value', 0);
% else
%     set(handles.evofft_Nyquist_radiobutton,'Value',1)
%     set(handles.radiobutton2, 'Value', 0);
%     handles.evofft_fmax = handles.nyquist;
% end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
% val = get(handles.radiobutton2,'Value')
% if val > 0
%     set(handles.evofft_Nyquist_radiobutton,'Value',0)
%     set(handles.radiobutton2, 'Value', 1);
%     handles.evofft_fmax = str2double(get(handles.evofft_fmax_edit, 'String'));
% else 
%     set(handles.evofft_Nyquist_radiobutton,'Value',0)
%     handles.evofft_fmax = handles.nyquist;
% end

% --- Executes on button press in evofft_tips_win_pushbutton.
function evofft_tips_win_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to evofft_tips_win_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evofft_tips_win = 'Tips: window  << total data length; window ~ = 1 - 1.5 x aimed cycle. i.e. 500 kyr for a 400 kyr cycles';
warndlg(evofft_tips_win,'Tips: window length')


% --- Executes during object creation, after setting all properties.
function evofft_nyquist_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to evofft_nyquist_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);

function evofft_nyquist_text_Callback(hObject, eventdata, handles)
evofft_nyquist_text = get(hObject, 'String');
handles.evofft_nyquist_text = evofft_nyquist_text; % This overwrites the object's handle!
guidata(hObject, handles);

% --- Executes on button press in evofft_ok_pushbutton.
function evofft_ok_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to evofft_ok_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles = findobj('Tag','AutoC_main_figure');
data =  handles.current_data;
window = handles.window;
step = str2double(get(handles.edit_step,'String'));
fmax_select = get(handles.evofft_Nyquist_radiobutton,'Value');
method = handles.method;
if fmax_select == 1
    fmax = handles.nyquist;
else
    fmax = str2double(get(handles.evofft_fmax_edit,'String'));
end
fmin = str2double(get(handles.edit7,'String'));
unit = get(handles.edit8,'String');
filename =  handles.filename;
norm = get(handles.radiobutton5,'Value');
% Evofft Plot
if strcmp(method,'Periodogram')
    [s,x_grid,y_grid]=evoperiodogram(data,window,step,fmin,fmax,norm);
elseif strcmp(method,'Lomb-Scargle periodogram')
    [s,x_grid,y_grid]=evoplomb(data,window,step,fmin,fmax,norm);
elseif strcmp(method,'Multi-taper method')
    [s,x_grid,y_grid] = evopmtm(data,window,step,fmin,fmax,norm);
elseif strcmp(method,'Fast Fourier transform')
    fmin = str2double(get(handles.edit7,'String'));
    [s,x_grid,y_grid]=evofftML(data,window,step,fmin,fmax,norm);
elseif strcmp(method,'Fast Fourier transform (LAH)')
    dt = data(2,1)-data(1,1);
    %[s,x_grid,y_grid]=evofftLAH(data,window,step,dt,fmin,fmax,norm);
    [s,x_grid,y_grid]=evofft(data,window,step,dt,fmin,fmax,norm);
end

assignin('base','s',s);
assignin('base','x',x_grid);
assignin('base','y',y_grid);
figure
whitebg('white');

if handles.plot_2d == 1
    if handles.plot_log == 1;
        s = log10(s); 
        pcolor(x_grid(2:end),y_grid,s(:,2:end))
    else
        pcolor(x_grid,y_grid,s)
    end
else
    if handles.plot_log == 1;
        s = log10(s); 
        handles.rotate = get(handles.rotation,'Value');
        surf(x_grid(2:end),y_grid,s(:,2:end))
    else
        handles.rotate = get(handles.rotation,'Value');
        surf(x_grid,y_grid,s)
    end
end 
        colormap(jet)
        shading interp
    title([method,'. Window',' = ',num2str(window),' ',unit,'; step = ',num2str(step),' ', unit])
    xlabel(['Frequency ( cycles per ',unit,' )'])
    if handles.unit_type == 0;
        ylabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1;
        ylabel(['Depth (',handles.unit,')'])
    else
        ylabel(['Time (',handles.unit,')'])
    end
    set(gcf,'Name',[num2str(filename),': Running Periodogram'])
    xlim([fmin fmax])
    
if handles.flipy == 1;
    set(gca,'Ydir','reverse')
end
    if handles.plot_2d == 1
    else
       if handles.rotate == 0
            view(10,70);
        else
            for i = 1: 370; 
                view(i,70); 
                pause(0.05); 
            end
       end
    end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menuOpen_Callback(hObject, eventdata, handles)
% hObject    handle to menuOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in evofft_get_pushbutton.
function evofft_get_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to evofft_get_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in evofft_open_pushbutton.
function evofft_open_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to evofft_open_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiopen;

handles.current_data = data;
handles.step = handles.current_data(2,1)-handles.current_data(1,1);
handles.nyquist = abs(1/(2*handles.step));
handles.evofft_fmax = handles.nyquist;
set(handles.evofft_nyquist_text, 'String', num2str(handles.nyquist));

existdata = evalin('base','who');
if ismember('unit',existdata)
    handles.unit = evalin('base','unit');
else
    handles.unit = 'unit';
end

if ismember('filename',existdata)
    handles.filename = evalin('base','filename');
else
    handles.filename = 'filename';
end

guidata(hObject, handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evofft_tips_step = 'Tips: Step  >= mean sample rate';
warndlg(evofft_tips_step,'Tips: Step length')


% --- Executes during object creation, after setting all properties.
function edit_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_2d.
function radiobutton_2d_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_2d
val = get(handles.radiobutton_2d,'Value');
if val == 1
    set (handles.radiobutton_3d, 'Value', 0);
    set (handles.rotation, 'Value', 0);
    handles.plot_2d = 1;
else
    set (handles.radiobutton_3d, 'Value', 1);
    set (handles.rotation, 'Value', 1);
    handles.plot_2d = 0;
end
guidata(hObject, handles);

% --- Executes on button press in radiobutton_3d.
function radiobutton_3d_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_3d
val = get(handles.radiobutton_3d,'Value');
if val == 1
    set (handles.radiobutton_2d, 'Value', 0);
    handles.plot_2d = 0;
    set (handles.rotation, 'Value', 1);
else
    set (handles.radiobutton_2d, 'Value', 1);
    handles.plot_2d = 1;
    set (handles.rotation, 'Value', 0);
end
guidata(hObject, handles);

% --- Executes on key press with focus on evofft_Nyquist_radiobutton and none of its controls.
function evofft_Nyquist_radiobutton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to evofft_Nyquist_radiobutton (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
handles.index_selected  = get(hObject,'Value');
guidata(hObject,handles)

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


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_content = cellstr(get(handles.listbox2,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1; minus 2 for listbox
nplot = length(plot_selected);   % length
if plot_selected > 2
    if nplot > 1
        open_data = 'Tips: Select ONE folder';
        h = helpdlg(open_data,'Tips: Close');
        uiwait(h);
    else
        plot_filter_selection = char(list_content(plot_selected));
        if ~exist(plot_filter_selection,'dir')==1
            h = helpdlg('This is NOT a folder','Tips: Close');
            uiwait(h);
        else
            cd(plot_filter_selection)
            address = pwd;
            set(handles.edit6,'String',address);
        end
    end
end
guidata(hObject,handles)


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.listbox2,'String')); % read contents of listbox 1 
selected = handles.index_selected;  % read selection in listbox 1
nplot = length(selected);   % length

if selected > 2
if nplot == 1
    data_name = char(contents(selected));  % name of the selected data
    data_s = load(data_name); % load selected data
    handles.filename = data_name;
    xmin = min(data_s(:,1));
    xmax = max(data_s(:,1));
    handles.current_data = data_s;
    check=1;
end
end
if check == 1
    mean1 = median(diff(data_s(:,1)));
    handles.mean = mean1;
    handles.step = handles.mean;
    handles.nyquist = 1/(2*handles.mean);     % prepare nyquist
    handles.window = 0.2*(xmax-xmin);
    handles.rotate = 0;
    handles.method = 'Periodogram';
    set(handles.evofft_nyquist_text, 'String', num2str(handles.nyquist));
    set(handles.evofft_win_text, 'String', num2str(handles.window));
    set(handles.edit_step, 'String', num2str(handles.mean),'Value',1);
end
%%
guidata(hObject,handles)
% 
% % --- Executes on button press in pushbutton23.
% function pushbutton23_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton23 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% contents = cellstr(get(handles.listbox2,'String')); % read contents of listbox 1 
% plot_selected = handles.index_selected;  % read selection in listbox 1
% nplot = length(plot_selected);   % length
% 
% figure;
% for i = 1:nplot
%     plot_no = plot_selected(i);
%     if plot_no > 2
%         plot_filter_s = char(contents(plot_no));
%     %   cd(handles.working_folder)
%         data_filterout = load(plot_filter_s);
%         hold on
%         plot(data_filterout(:,1),data_filterout(:,2));
%         hold off
%     end
% end
% guidata(hObject,handles)


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
val = get(handles.radiobutton6,'Value');
if val == 1
    set (handles.radiobutton5, 'Value', 0);
    handles.normal = 0;
else
    set (handles.radiobutton5, 'Value', 1);
    handles.normal = 1;
end
guidata(hObject, handles);

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
val = get(handles.radiobutton5,'Value');
if val == 1
    set (handles.radiobutton6, 'Value', 0);
    handles.normal = 1;
else
    set (handles.radiobutton6, 'Value', 1);
    handles.normal = 0;
end
guidata(hObject, handles);


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8
val = get(hObject,'Value');
if val == 1
    set (handles.radiobutton7, 'Value', 0);
    handles.flipy = 1;
else
    set (handles.radiobutton7, 'Value', 1);
    handles.flipy = 0;
end
guidata(hObject, handles);

% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7
val = get(hObject,'Value');
if val == 1
    set (handles.radiobutton8, 'Value', 0);
    handles.flipy = 0;
else
    set (handles.radiobutton8, 'Value', 1);
    handles.flipy = 1;
end
guidata(hObject, handles);


% --- Executes on button press in rotation.
function rotation_Callback(hObject, eventdata, handles)
% hObject    handle to rotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotation


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
contents = cellstr(get(hObject,'String'));
handles.method = contents{get(hObject,'Value')};
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



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


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


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10
val = get(hObject,'Value');
if val == 1
    set (handles.radiobutton9, 'Value', 0);
    handles.plot_log = 0;
else
    set (handles.radiobutton10, 'Value', 1);
    handles.plot_log = 1;
end
guidata(hObject, handles);


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9
val = get(hObject,'Value');
if val == 1
    set (handles.radiobutton10, 'Value', 0);
    handles.plot_log = 1;
else
    set (handles.radiobutton9, 'Value', 1);
    handles.plot_log = 0;
end
guidata(hObject, handles);
