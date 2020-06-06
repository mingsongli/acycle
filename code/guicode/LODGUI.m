function varargout = LODGUI(varargin)
% LODGUI MATLAB code for LODGUI.fig
%      LODGUI, by itself, creates a new LODGUI or raises the existing
%      singleton*.
%
%      H = LODGUI returns the handle to a new LODGUI or the handle to
%      the existing singleton*.
%
%      LODGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LODGUI.M with the given input arguments.
%
%      LODGUI('Property','Value',...) creates a new LODGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LODGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LODGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LODGUI

% Last Modified by GUIDE v2.5 11-Mar-2020 14:07:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LODGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LODGUI_OutputFcn, ...
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


% --- Executes just before LODGUI is made visible.
function LODGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LODGUI (see VARARGIN)
set(gcf,'Name','Acycle: Lenght-of-day & Day-of-year')
set(gcf,'position',[0.4,0.55,0.313,0.289]) % set position
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11);  % set as norm

set(handles.uibuttongroup1, 'Position',[0.05, 0.65, 0.26, 0.3])
set(handles.uipanel1, 'Position',[0.33, 0.65, 0.33, 0.3])
set(handles.uipanel2, 'Position',[0.05, 0.22, 0.9, 0.39])
set(handles.uipanel3, 'Position',[0.05, 0.03, 0.9, 0.19])

set(handles.radiobutton1, 'Position',[0.1, 0.55, 0.9, 0.35])
set(handles.radiobutton1, 'value',0)
set(handles.radiobutton2, 'Position',[0.1, 0.1, 0.9, 0.35])
set(handles.radiobutton2, 'value',1)
set(handles.popupmenu1, 'Position',[0.05, 0.3, 0.9, 0.41])
set(handles.text2, 'Position',[0.01, 0.6, 0.12, 0.2])
set(handles.text3, 'Position',[0.4, 0.6, 0.07, 0.2])
set(handles.text4, 'Position',[0.7, 0.6, 0.13, 0.2])
set(handles.text5, 'Position',[0.3, 0.6, 0.055, 0.2])
set(handles.text6, 'Position',[0.64, 0.6, 0.055, 0.2])
set(handles.text7, 'Position',[0.93, 0.6, 0.055, 0.2])
set(handles.edit1, 'Position',[0.13, 0.56, 0.17, 0.25])
set(handles.edit1, 'String','-10')
set(handles.edit2, 'Position',[0.47, 0.56, 0.17, 0.25])
set(handles.edit2, 'String','250')  
set(handles.edit3, 'Position',[0.806, 0.56, 0.11, 0.25])
set(handles.edit3, 'String','10')
set(handles.text8, 'Position',[0.03, 0.2, 0.94, 0.2])
set(handles.edit4, 'Position',[0.03, 0.25, 0.94, 0.6])
set(handles.pushbutton1, 'Position',[0.71, 0.7, 0.2, 0.2])

set(handles.text2, 'String','From')
set(handles.edit2, 'Visible','on')
set(handles.edit3, 'Visible','on')
set(handles.text3, 'Visible','on')
set(handles.text4, 'Visible','on')
set(handles.text6, 'Visible','on')
set(handles.text7, 'Visible','on')

set(handles.text8, 'String','will calculate length of day and days in a year: -10, 0, 10, ... , 250 Ma')

handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;

% Choose default command line output for LODGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LODGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LODGUI_OutputFcn(hObject, eventdata, handles) 
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
single0 = get(handles.radiobutton1,'Value');
single1 = get(handles.radiobutton2,'Value');
if single0 == 1
    T = str2double(get(handles.edit1,'string'));
    if T >=4500 || T<=-4500
        if T >=4500
            errordlg('Given age is too large')
        else
            errordlg('Given age is too small')
        end
    else
        
        [lod, doy] = lodla04(T/-1000);
        
        name1 = ['LOD_',num2str(T),'Ma.txt'];
        name2 = ['LOD_DOY_',num2str(T),'Ma.txt'];
        CDac_pwd
        dlmwrite(name1, [T,lod], 'delimiter', ',', 'precision', 9);
        dlmwrite(name2, [T,doy], 'delimiter', ',', 'precision', 9);
        d = dir; %get files
        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
        refreshcolor;
        cd(pre_dirML); % return to matlab view folder

        figure;
        set(gcf,'Name','Acycle: Lenght-of-day & Day-of-year | plot')
        set(gcf,'color','w');
        subplot(2,1,1)
        plot(T,lod,'-ko')
        ylabel('length of day (hour)')
        subplot(2,1,2)
        plot(T,doy,'-ko')
        xlabel('Age (Ma)')
        ylabel('stellar day of year')
    end
elseif single1 == 1
    age1 = str2double(get(handles.edit1,'string'));
    age2 = str2double(get(handles.edit2,'string'));
    step = str2double(get(handles.edit3,'string'));
    T = age1:step:age2;
    T = T';
    if isempty(T) == 0
        [lod, doy] = lodla04(T/-1000);
        
        name1 = ['LOD_',num2str(age1),'_',num2str(step),'_',num2str(age2),'Ma.txt'];
        name2 = ['LOD_DOY_',num2str(age1),'_',num2str(step),'_',num2str(age2),'Ma.txt'];
        CDac_pwd
        dlmwrite(name1, [T,lod], 'delimiter', ',', 'precision', 9);
        dlmwrite(name2, [T,doy], 'delimiter', ',', 'precision', 9);
        d = dir; %get files
        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
        refreshcolor;
        cd(pre_dirML); % return to matlab view folder
        
        figure;
        set(gcf,'Name','Acycle: Lenght-of-day & Day-of-year | plot')
        set(gcf,'color','w');
        subplot(2,1,1)
        plot(T,lod,'-ko')
        ylabel('length of day (hours)')
        subplot(2,1,2)
        plot(T,doy,'-ko')
        xlabel('Age (Ma)')
        ylabel('stellar day of year')
    else
        errordlg('Input age error !')
    end
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
single0 = get(handles.radiobutton1,'Value');
if single0 == 1
    T = str2double(get(handles.edit1,'string'));
    if T >=4500 || T<=-4500
        if T >=4500
            set(handles.text8, 'String','Given age is too large')
        else
            set(handles.text8, 'String','Given age is too small')
        end
    else
        string0 = ['will calculate length of day and days in a year: ',num2str(T),' Ma'];
        set(handles.text8, 'String',string0)
    end
else
    age1 = str2double(get(handles.edit1,'string'));
    age2 = str2double(get(handles.edit2,'string'));
    step = str2double(get(handles.edit3,'string'));
    T = age1:step:age2;
    if isempty(T) == 0
        if max(T) >=4500 || min(T)<=-4500
            set(handles.text8, 'String','Input time error !')
        end
        if length(T)>3
            string0 = ['will calculate length of day and days in a year: ',num2str(T(1)),', ',...
                num2str(T(2)),', ... , ', num2str(T(end)),' Ma'];
        else
            string0 = ['will calculate length of day and days in a year: ',...
                num2str(T(1)),' - ', num2str(T(end)),' Ma'];
        end
        set(handles.text8, 'String',string0)
    else
        set(handles.text8, 'String','Input time error !')
    end
end

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

age1 = str2double(get(handles.edit1,'string'));
age2 = str2double(get(handles.edit2,'string'));
step = str2double(get(handles.edit3,'string'));
T = age1:step:age2;
if isempty(T) == 0
    if max(T) >=4500 || min(T)<=-4500
        set(handles.text8, 'String','Input time error !')
    end
    if length(T)>3
        string0 = ['will calculate length of day and days in a year: ',num2str(T(1)),', ',...
            num2str(T(2)),', ... , ', num2str(T(end)),' Ma'];
    else
        string0 = ['will calculate length of day and days in a year: ',...
            num2str(T(1)),' - ', num2str(T(end)),' Ma'];
    end
    set(handles.text8, 'String',string0)
else
    set(handles.text8, 'String','Input time error !')
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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
age1 = str2double(get(handles.edit1,'string'));
age2 = str2double(get(handles.edit2,'string'));
step = str2double(get(handles.edit3,'string'));
T = age1:step:age2;
if isempty(T) == 0
    if max(T) >=4500 || min(T)<=-4500
        set(handles.text8, 'String','Input time error !')
    end
    if length(T)>3
        string0 = ['will calculate length of day and days in a year: ',num2str(T(1)),', ',...
            num2str(T(2)),', ... , ', num2str(T(end)),' Ma'];
    else
        string0 = ['will calculate length of day and days in a year: ',...
            num2str(T(1)),' - ', num2str(T(end)),' Ma'];
    end
    set(handles.text8, 'String',string0)
else
    set(handles.text8, 'String','Input time error !')
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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


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


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
if get(hObject,'Value')
    set(handles.text2, 'String','From')
    set(handles.edit2, 'Visible','on')
    set(handles.edit3, 'Visible','on')
    set(handles.text3, 'Visible','on')
    set(handles.text4, 'Visible','on')
    set(handles.text6, 'Visible','on')
    set(handles.text7, 'Visible','on')
    
    age1 = str2double(get(handles.edit1,'string'));
    age2 = str2double(get(handles.edit2,'string'));
    step = str2double(get(handles.edit3,'string'));
    T = age1:step:age2;
    if isempty(T) == 0
        if max(T) >=4500 || min(T)<=-4500
            set(handles.text8, 'String','Input time error !')
        end
        if length(T)>3
            string0 = ['will calculate length of day and days in a year: ',num2str(T(1)),', ',...
                num2str(T(2)),', ... , ', num2str(T(end)),' Ma'];
        else
            string0 = ['will calculate length of day and days in a year: ',...
                num2str(T(1)),' - ', num2str(T(end)),' Ma'];
        end
        set(handles.text8, 'String',string0)
    else
        set(handles.text8, 'String','Input time error !')
    end
end

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
single = get(hObject,'Value');
if single == 1
    set(handles.text2, 'String','Age')
    set(handles.edit2, 'Visible','off')
    set(handles.edit3, 'Visible','off')
    set(handles.text3, 'Visible','off')
    set(handles.text4, 'Visible','off')
    set(handles.text6, 'Visible','off')
    set(handles.text7, 'Visible','off')
    
    T = str2double(get(handles.edit1,'string'));
    if T >=4500 || T<=-4500
        if T >=4500
            set(handles.text8, 'String','Given age is too large')
        else
            set(handles.text8, 'String','Given age is too small')
        end
    else
        string0 = ['will calculate length of day and days in a year: ',num2str(T),' Ma'];
        set(handles.text8, 'String',string0)
    end

end
