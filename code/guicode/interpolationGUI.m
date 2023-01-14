function varargout = interpolationGUI(varargin)
% INTERPOLATIONGUI MATLAB code for interpolationGUI.fig
%      INTERPOLATIONGUI, by itself, creates a new INTERPOLATIONGUI or raises the existing
%      singleton*.
%
%      H = INTERPOLATIONGUI returns the handle to a new INTERPOLATIONGUI or the handle to
%      the existing singleton*.
%
%      INTERPOLATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERPOLATIONGUI.M with the given input arguments.
%
%      INTERPOLATIONGUI('Property','Value',...) creates a new INTERPOLATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interpolationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interpolationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interpolationGUI

% Last Modified by GUIDE v2.5 29-Dec-2021 10:56:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interpolationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @interpolationGUI_OutputFcn, ...
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


% --- Executes just before interpolationGUI is made visible.
function interpolationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interpolationGUI (see VARARGIN)
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
handles.MonZoom = varargin{1}.MonZoom;
data = varargin{1}.current_data;
handles.data_name = varargin{1}.data_name;
handles.dat_name = varargin{1}.dat_name; % save dataname
handles.ext = varargin{1}.ext;
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
handles.interpGUI = gcf; 
set(gcf,'position',[0.4,0.55,0.4,0.4] * handles.MonZoom) % set position

% language
lang_choice = varargin{1}.lang_choice;
handles.lang_choice = lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;
handles.lang_id = lang_id;
handles.lang_var = lang_var;
handles.main_unit_selection = varargin{1}.main_unit_selection;

if handles.lang_choice == 0
    set(gcf,'Name','Acycle: Interpolation Pro')
else
    [~, menu93] = ismember('menu93',lang_id);
    set(gcf,'Name',['Acycle: ',lang_var{menu93}])
end

% language
if handles.lang_choice > 0
    [~, menu46] = ismember('menu46',handles.lang_id);
    [~, menu71] = ismember('menu71',handles.lang_id);
    [~, c37] = ismember('c37',handles.lang_id);
    [~, main52] = ismember('main52',handles.lang_id);
    [~, interpGUI02] = ismember('interpGUI02',handles.lang_id);
    [~, interpGUI03] = ismember('interpGUI03',handles.lang_id);
    
    set(handles.uipanel,'Title',lang_var{menu71})
    set(handles.text3,'String',lang_var{menu46})
    set(handles.text4,'String',lang_var{c37})
    set(handles.pushbutton1,'String',lang_var{main52})
    set(handles.checkbox3,'String',[lang_var{interpGUI02},'('])
    set(handles.text9,'String',[' x ',lang_var{interpGUI03},') = 0'])
end

set(handles.uipanel,'position', [0.05,0.75,0.9,0.2])
set(handles.text2,'position', [0.01,0.6,0.46,0.2])
set(handles.text3,'position', [0.01,0.2,0.15,0.2])
set(handles.edit1,'position', [0.16,0.15,0.078,0.3])
set(handles.text4,'position', [0.25,0.2,0.08,0.2])
set(handles.popupmenu1,'position', [0.32,0.15,0.15,0.3])
set(handles.text5,'position', [0.5,0.6,0.06,0.2])
set(handles.edit2,'position', [0.56,0.55,0.11,0.3])
set(handles.text6,'position', [0.5,0.2,0.06,0.2])
set(handles.edit3,'position', [0.56,0.15,0.11,0.3])

set(handles.text7,'position', [0.7,0.6,0.06,0.2])
set(handles.edit4,'position', [0.76,0.55,0.11,0.3])
set(handles.text8,'position', [0.7,0.2,0.06,0.2])
set(handles.edit5,'position', [0.76,0.15,0.11,0.3])

set(handles.pushbutton1,'position', [0.9,0.3,0.08,0.4])
set(handles.axes1,'position', [0.05,0.1,0.9,0.6])

set(handles.checkbox3,'position', [0.5,0.02,0.15,0.045],'value',0)
set(handles.edit6,'position', [0.65,0.02,0.035,0.04],'string','10')
set(handles.text9,'position', [0.69,0.02,0.3,0.04])

data = sortrows(data);

dt = median(diff(data(:,1)));
xq = data(1,1):dt:data(end,1);
vq = interp1(data(:,1),data(:,2),xq);

set(handles.text2,'string', [handles.dat_name,handles.ext])

set(handles.edit1,'string', dt)
set(handles.edit2,'string', min(data(:,1)))
set(handles.edit3,'string', max(data(:,1)))
set(handles.edit4,'string', min(data(:,2)))
set(handles.edit5,'string', max(data(:,2)))

plot(handles.axes1,data(:,1),data(:,2),'o')
hold on
plot(handles.axes1,xq,vq,':.')
% language
if handles.lang_choice == 0
    title('(Default) Linear Interpolation');
    legend('raw','linear interpolation')
else
    [~, interpGUI04] = ismember('interpGUI04',handles.lang_id); % default
    [~, interpGUI05] = ismember('interpGUI05',handles.lang_id); % linear
    [~, interpGUI06] = ismember('interpGUI06',handles.lang_id); % interpolation
    [~, a281] = ismember('a281',handles.lang_id); % raw
    title(['(',lang_var{interpGUI04},') ',lang_var{interpGUI05},lang_var{interpGUI06}]);
    legend(lang_var{a281},[lang_var{interpGUI05},lang_var{interpGUI06}]);
end
xlim([min(data(:,1)), max(data(:,1))])
ylim([min(data(:,2)), max(data(:,2))])
hold off
handles.data = data;
% Choose default command line output for interpolationGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes interpolationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = interpolationGUI_OutputFcn(hObject, eventdata, handles) 
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
update_interpolationGUI
name = [handles.dat_name,'-rsp',num2str(dt),'-',legendi,'.txt'];
CDac_pwd; % cd ac_pwd dir
dlmwrite(name, [xq',vq'], 'delimiter', ' ', 'precision', 9);
refreshcolor;
cd(pre_dirML); % return to matlab view folder
figure(handles.interpGUI); % return
disp('Interpolated data:')
disp(name)

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
update_interpolationGUI

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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
update_interpolationGUI

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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
update_interpolationGUI

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
update_interpolationGUI

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
update_interpolationGUI

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
update_interpolationGUI

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


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
update_interpolationGUI


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
update_interpolationGUI

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
