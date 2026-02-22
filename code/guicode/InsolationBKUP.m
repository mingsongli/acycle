function varargout = Insolation(varargin)
% INSOLATION MATLAB code for Insolation.fig
%      INSOLATION, by itself, creates a new INSOLATION or raises the existing
%      singleton*.
%
%      H = INSOLATION returns the handle to a new INSOLATION or the handle to
%      the existing singleton*.
%
%      INSOLATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSOLATION.M with the given input arguments.
%
%      INSOLATION('Property','Value',...) creates a new INSOLATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Insolation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Insolation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Insolation

% Last Modified by GUIDE v2.5 27-Feb-2018 03:36:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Insolation_OpeningFcn, ...
                   'gui_OutputFcn',  @Insolation_OutputFcn, ...
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


% --- Executes just before Insolation is made visible.
function Insolation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Insolation (see VARARGIN)
% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;

set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',12);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',12);  % set as norm

set(gcf,'position',[0.4,0.1,0.35,0.65]* handles.MonZoom)

% language
lang_choice = varargin{1}.lang_choice;
handles.lang_choice = lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;
handles.lang_id = lang_id;
handles.lang_var = lang_var;
handles.main_unit_selection = varargin{1}.main_unit_selection;
if handles.lang_choice == 0
    set(gcf,'Name','Acycle: Insolation')
else
    [~, menu50] = ismember('menu50',lang_id);
    set(gcf,'Name',['Acycle: ',lang_var{menu50}])
end

% language
if handles.lang_choice > 0
    [~, insol01] = ismember('insol01',handles.lang_id);
    [~, insol02] = ismember('insol02',handles.lang_id);
    [~, insol03] = ismember('insol03',handles.lang_id);
    [~, insol04] = ismember('insol04',handles.lang_id);
    [~, insol05] = ismember('insol05',handles.lang_id);
    [~, insol06] = ismember('insol06',handles.lang_id);
    [~, insol07] = ismember('insol07',handles.lang_id);
    [~, insol08] = ismember('insol08',handles.lang_id);
    %[~, insol09] = ismember('insol09',handles.lang_id);
    [~, insol10] = ismember('insol10',handles.lang_id);
    [~, insol11] = ismember('insol11',handles.lang_id);
    [~, insol12] = ismember('insol12',handles.lang_id);
    [~, insol13] = ismember('insol13',handles.lang_id);
    [~, insol14] = ismember('insol14',handles.lang_id);
    [~, insol15] = ismember('insol15',handles.lang_id);
    [~, insol16] = ismember('insol16',handles.lang_id);
    [~, insol17] = ismember('insol17',handles.lang_id);
    [~, insol18] = ismember('insol18',handles.lang_id);
    [~, insol19] = ismember('insol19',handles.lang_id);
    [~, insol20] = ismember('insol20',handles.lang_id);
    [~, main01] = ismember('main01',handles.lang_id); % OK
    [~, main16] = ismember('main16',handles.lang_id); % from
    [~, main17] = ismember('main17',handles.lang_id); % to
    [~, main32] = ismember('main32',handles.lang_id); % step
    
    set(handles.uibuttongroup1,'Title',lang_var{insol01})
    set(handles.radiobutton1,'String',lang_var{insol02})
    set(handles.radiobutton2,'String',lang_var{insol03})    
    set(handles.uibuttongroup2,'Title',lang_var{insol04})
    set(handles.uibuttongroup3,'Title',lang_var{insol05})
    set(handles.text2,'String',lang_var{insol06})  
    set(handles.text3,'String',lang_var{main16})  
    set(handles.text4,'String',lang_var{main17})  
    set(handles.text5,'String',lang_var{main32})  
    set(handles.text6,'String',lang_var{insol07})  
    set(handles.text19,'String',lang_var{insol08})  
    set(handles.text21,'String',' ') 
    set(handles.uibuttongroup4,'Title',lang_var{insol10})
    set(handles.text8,'String',lang_var{insol11})  
    set(handles.text11,'String',lang_var{insol14})   % starting day
    set(handles.text12,'String',lang_var{insol15})  
    set(handles.text13,'String',lang_var{insol16})  
    set(handles.text14,'String',lang_var{insol15})  
    set(handles.radiobutton5,'String',lang_var{insol12})  
    set(handles.radiobutton6,'String',lang_var{insol13})  
    set(handles.uibuttongroup5,'Title',lang_var{insol17}) 
    set(handles.radiobutton3,'String',[lang_var{insol18},' ',lang_var{insol17}]) 
    set(handles.radiobutton4,'String',[lang_var{insol17},' ',lang_var{insol19}]) 
    set(handles.text15,'String',lang_var{insol20}) 
    set(handles.text16,'String',lang_var{main32})  % step
    set(handles.text17,'String',lang_var{main17}) 
    set(handles.text18,'String',lang_var{main16}) 
    set(handles.push_OK,'String',lang_var{main01}) 
end
%type
set(handles.uibuttongroup1,'position',[0.03,0.852,0.386,0.107])
set(handles.radiobutton1,'position',[0.089,0.244,0.384,0.561])
set(handles.radiobutton1,'value',1)
set(handles.radiobutton2,'position',[0.502,0.244,0.399,0.561])
set(handles.radiobutton2,'value',0)
% solution
set(handles.uibuttongroup2,'position',[0.46,0.852,0.48,0.107])
set(handles.pop_solutions,'position',[0.083,0.075,0.888,0.675])
set(handles.pop_solutions,'value',1)
%time
set(handles.uibuttongroup3,'position',[0.03,0.6,0.91,0.235])
set(handles.text2,'position',[0.033,0.74,0.495,0.17])

set(handles.text3,'position',[0.033,0.5,0.094,0.216])
set(handles.edit1,'position',[0.143,0.52,0.179,0.216])
set(handles.edit1,'string','1')
set(handles.text5,'position',[0.51,0.5,0.089,0.216])
set(handles.edit3,'position',[0.62,0.52,0.179,0.216])
set(handles.edit3,'string','1')
%
set(handles.text4,'position',[0.033,0.22,0.054,0.216])
set(handles.edit2,'position',[0.143,0.244,0.179,0.216])
set(handles.edit2,'string','1000')
set(handles.text6,'position',[0.439,0.22,0.161,0.216])
set(handles.pop_unit,'position',[0.605,0.244,0.25,0.216])
set(handles.pop_unit,'value',1)
%
set(handles.text19,'position',[0.033,0.033,0.296,0.15])
set(handles.text20,'position',[0.324,0.033,0.133,0.15])
set(handles.text20,'string','999')
set(handles.text21,'position',[0.446,0.033,0.133,0.15])
%parameters
set(handles.uibuttongroup4,'position',[0.03,0.263,0.91,0.312])
set(handles.text8,'position',[0.033,0.725,0.22,0.15])
set(handles.edit_solconstant,'position',[0.26,0.725,0.129,0.15])
set(handles.edit_solconstant,'string','1365')
set(handles.text9,'position',[0.4,0.725,0.131,0.15])
set(handles.radiobutton5,'position',[0.54,0.725,0.226,0.15])
set(handles.radiobutton5,'value',1)
set(handles.radiobutton6,'position',[0.789,0.725,0.208,0.15])
set(handles.radiobutton6,'value',0)
%
set(handles.text11,'position',[0.033,0.465,0.22,0.15])
set(handles.edit_dayi1,'position',[0.26,0.465,0.129,0.15])
set(handles.edit_dayi1,'string','80')
set(handles.text12,'position',[0.4,0.465,0.131,0.15])
set(handles.pop_month1,'position',[0.54,0.465,0.26,0.15])
set(handles.pop_month1,'value',3)
set(handles.pop_days1,'position',[0.812,0.465,0.17,0.15])
set(handles.pop_days1,'value',21)
%
set(handles.text13,'position',[0.033,0.2,0.22,0.15])
set(handles.edit_dayi2,'position',[0.26,0.2,0.129,0.15])
set(handles.edit_dayi2,'string','266')
set(handles.edit_dayi2,'enable','off')
set(handles.text14,'position',[0.4,0.2,0.131,0.15])
set(handles.pop_month2,'position',[0.54,0.2,0.26,0.15])
set(handles.pop_month2,'value',9)
set(handles.pop_month2,'enable','off')
set(handles.pop_days2,'position',[0.812,0.2,0.17,0.15])
set(handles.pop_days2,'value',23)
set(handles.pop_days2,'enable','off')
%latitude
set(handles.uibuttongroup5,'position',[0.03,0.085,0.91,0.172])
set(handles.radiobutton3,'position',[0.033,0.521,0.3,0.3])
set(handles.radiobutton3,'value',1)
set(handles.text18,'position',[0.364,0.49,0.1,0.3])
set(handles.edit7,'position',[0.47,0.521,0.13,0.3])
set(handles.edit7,'string','65')
set(handles.text15,'position',[0.63,0.49,0.3,0.3])
%
set(handles.radiobutton4,'position',[0.033,0.192,0.3,0.3])
set(handles.radiobutton4,'value',0)
set(handles.text17,'position',[0.364,0.16,0.1,0.3])
set(handles.edit8,'position',[0.47,0.192,0.13,0.3])
set(handles.edit8,'string','80')
set(handles.edit8,'enable','off')
set(handles.text16,'position',[0.63,0.16,0.1,0.3])
set(handles.edit9,'position',[0.744,0.192,0.15,0.3])
set(handles.edit9,'string','1')
set(handles.edit9,'enable','off')
%ok
set(handles.push_OK,'position',[0.772,0.02,0.161,0.047])

% Choose default command line output for Insolation
handles.output = hObject;
handles.type = 0; % 0 = daily; 1 = mean
handles.author = 1; % 1= la04; 2 = la10a; 3 = la10b; 4 = la10c; 5 = la10d; 6 = BergerLoutre91
handles.t1 = 1;   % starting time
handles.t2 = 1000;  % ending time
handles.dt = 1;  % step time
handles.res = 1;
handles.unit_t = 1;  % unit time 1 = kyr; 2 = myr; 3 = year
handles.solarconstant = 1365;  % solar constant
handles.qinso = -2;  % -2 = mean; -1 = max daily
handles.season1 = 90; % season day starting
handles.season2 = 180;  % season day ending
handles.month1 = 1;
handles.month2 = 2;
handles.dayi1 = 80; % starting date
handles.dayi2 = 264; % ending date (unable)
handles.lat1 = 65;  % latitude default
handles.lat2 = 80;  % latitude range from lat1 to lat2
handles.dlat = 1;  % latitude resolution
handles.latrange = 0;  % 0 = single latitude; 1 = latitude range
% save list
handles.pop_solutions_list = get(handles.pop_solutions, 'String');
handles.pop_units_list = get(handles.pop_unit, 'String');
handles.pop_months_list = get(handles.pop_month1, 'String');
for i = 1:31; x1{i} = num2str(i); end
handles.pop_31days_list = x1;
for i = 1:30; x2{i} = num2str(i); end
handles.pop_30days_list = x2;
for i = 1:28; x3{i} = num2str(i); end
handles.pop_28days_list = x3;
set(handles.pop_days1,'String',handles.pop_31days_list)
set(handles.pop_days2,'String',handles.pop_31days_list)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Insolation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes on button press in push_OK.
function push_OK_Callback(hObject, eventdata, handles)
% hObject    handle to push_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
t1 = handles.t1;
t2 = handles.t2;
dt = handles.dt;
%dayi1 = handles.dayi1;
%dayi2 = handles.dayi2;
dayi1 = str2double(get(handles.edit_dayi1,'String'));
dayi2 = str2double(get(handles.edit_dayi2,'String'));
lat1 = handles.lat1;
lat2 = handles.lat2;
dlat = handles.dlat;
type = handles.type;
author = handles.author; % 1= la04; 2 = la10a; 3 = la10b; 4 = la10c; 5 = la10d;
res = handles.res;
L = handles.solarconstant;
unit_t = handles.unit_t; % unit time 1 = kyr; 2 = myr; 3 = year
lang_var = handles.lang_var;

if t1<0
    if handles.lang_choice == 0
        warndlg('time scale must be NO less than 0')
    else
        [~, insol21] = ismember('insol21',handles.lang_id);
        warndlg(lang_var{insol21})
    end
    return
end
if ismember(author,[1,2,3,4,5])
    if (and(unit_t==1,t2>249000) + and(unit_t==2,t2>249) + and(unit_t==3,t2>249000000) ) > 0
        
        if handles.lang_choice == 0
            warndlg('time scale must be NO larger than 249 000 ka')
        else
            [~, insol22] = ismember('insol22',handles.lang_id);
            warndlg(lang_var{insol22})
        end
        return
    end
end
%
t0 = max(t1,t2):-abs(dt):min(t1,t2);
t= t0;
unit_t_r = 'ka';
if unit_t == 2
    t = t0*1000;
    unit_t_r = 'Ma';
elseif unit_t == 3
    t = t0/1000;
    unit_t_r = 'yr';
end
if type == 1
    if dayi1 < dayi2
        day = dayi1 : dayi2;
    else
        dayi2 = dayi2+365;
        day = dayi1 : dayi2;
    end
else
    day = dayi1;
end
if handles.latrange == 1
    lat = min(lat1,lat2):abs(dlat):max(lat1,lat2);
else
    lat = lat1;
end
qinso = handles.qinso;
if handles.lang_choice == 0
    figmsgbox = msgbox('Please wait','Wait');
else
    [~, dd57] = ismember('dd57',handles.lang_id);
    [~, main44] = ismember('main44',handles.lang_id);
    figmsgbox = msgbox(lang_var{dd57},lang_var{main44});
end
try
    [I, ~, xorb, yorb, veq, Insol_a_m, Ix,II]=insoML(t,day,lat,qinso,author,res, L);
catch
    if handles.lang_choice == 0
        warndlg('Check time scale input, t must be larger than 0 and less than 249000 ka')
    else
        [~, insol24] = ismember('insol24',handles.lang_id);
        warndlg(lang_var{insol24})
    end
    
    return
end
%
assignin('base','insol_t',t0)
assignin('base','insol_I',I)
%assignin('base','insol_T',T)
assignin('base','insol_xorb',xorb)
assignin('base','insol_yorb',yorb)
assignin('base','insol_veq',veq)
assignin('base','insol_a_m',Insol_a_m)
assignin('base','insol_Ix',Ix)
assignin('base','insol_II',II)
% name with age
name_insold = ['Insol-t-',num2str(t1),'-',num2str(t2),unit_t_r,'-day-',num2str(dayi1),'-'];
if type == 1
    name_insold = [name_insold,num2str(dayi2),'-'];
end
% name with latitude
name_insol = [name_insold,'lat-(',num2str(lat1),')-'];
if handles.latrange == 1
    name_insol = [name_insol,'(',num2str(lat2),')-'];
end
% name with type
if qinso == -1
    name_insol = [name_insol,'maxdaily-'];
elseif qinso == -2
    name_insol = [name_insol,'meandaily-'];
end
auth_list = {'La04','La10a','La10b','La10c','La10d'};
name_insol = [name_insol,auth_list{author}];
name_insol_all = [name_insol,'.txt'];
%name_insol_annual = [name_insold, auth_list{author},'-FullEarth.txt'];

%close msgbox
if ishandle(figmsgbox); close(figmsgbox); end
% save data
CDac_pwd; % cd ac_pwd dir
dlmwrite(name_insol_all, [t0',Ix'], 'delimiter', ' ', 'precision', 9);
% plot data
figdata = figure; 
plot(t0',Ix');
xlim([min(t0),max(t0)]);
if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
    xlabel(['Time (', unit_t_r,')'])
    ylabel('Insolation (W/m^2)')
    title(name_insol)
else
    [~, main21] = ismember('main21',handles.lang_id);
    [~, menu50] = ismember('menu50',handles.lang_id);
    xlabel([lang_var{main21},' (', unit_t_r,')'])
    ylabel([lang_var{menu50},' (W/m^2)'])
    title(name_insol)
end

%dlmwrite(name_insol_annual, [t0',Insol_a_m'], 'delimiter', ' ', 'precision', 9);
if and((type == 1),(handles.latrange == 1))
    InsolLatDayGif(II,t0,lat,day,unit_t_r,name_insol);
end
cd(pre_dirML); % return to matlab view folder

% refresh AC main window
figure(handles.acfigmain);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir
figure(figdata); % return plot
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Insolation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in pop_solutions.
function pop_solutions_Callback(hObject, eventdata, handles)
% hObject    handle to pop_solutions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_solutions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_solutions
str = get(hObject, 'String');
val = get(hObject,'Value');
handles.author = getlisti(handles.pop_solutions_list,str{val});
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_solutions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_solutions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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
str = get(hObject, 'String');
handles.t1 = str2double(str);
n = (handles.t2 - handles.t1)/handles.dt;
set(handles.text20, 'String', fix(abs(n)))
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
str = get(hObject, 'String');
t2 = str2double(str);
handles.t2 = t2;
n = (handles.t2 - handles.t1)/handles.dt;
set(handles.text20, 'String', fix(abs(n)))
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
str = get(hObject, 'String');
handles.dt = str2double(str);
n = (handles.t2 - handles.t1)/handles.dt;
set(handles.text20, 'String', fix(abs(n)))
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


% --- Executes on selection change in pop_unit.
function pop_unit_Callback(hObject, eventdata, handles)
% hObject    handle to pop_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_unit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_unit
str = get(hObject, 'String');
val = get(hObject,'Value');
handles.unit_t = getlisti(handles.pop_units_list,str{val});
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_unit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_solconstant_Callback(hObject, eventdata, handles)
% hObject    handle to edit_solconstant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_solconstant as text
%        str2double(get(hObject,'String')) returns contents of edit_solconstant as a double
str = get(hObject, 'String');
handles.solarconstant = str2double(str);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_solconstant_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_solconstant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dayi1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dayi1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dayi1 as text
%        str2double(get(hObject,'String')) returns contents of edit_dayi1 as a double
str = get(hObject, 'String');
doy = str2double(str);
[month1,day1] = mmdd2dayi(doy);
handles.month1 = month1;
handles.dayi1 = day1;
set(handles.pop_month1,'Value',month1)
set(handles.pop_days1,'Value',day1)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_dayi1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dayi1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_month1.
function pop_month1_Callback(hObject, eventdata, handles)
% hObject    handle to pop_month1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_month1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_month1
%dayi1 = [];
str = get(hObject, 'String');
val = get(hObject,'Value');
month1 = getlisti(handles.pop_months_list,str{val});
if ismember(month1, [1,3,5,7,8,10,12])
    set(handles.pop_days1,'String',handles.pop_31days_list)
elseif ismember(month1, [4,6,9,11])
    set(handles.pop_days1,'String',handles.pop_30days_list)
elseif month1 == 2
    if handles.dayi1 > 28
        handles.dayi = 28;
        set(handles.edit_dayi1,'Value',handles.dayi)
    end
    set(handles.pop_days1,'String',handles.pop_28days_list)
end
handles.month1 = month1;
% read day of month
val_day = get(handles.pop_days1,'Value');
dayi1 = monthday2dayi(month1,val_day);
set(handles.edit_dayi1,'String',num2str(dayi1))
handles.dayi1 = dayi1;
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in pop_month2.
function pop_month2_Callback(hObject, eventdata, handles)
% hObject    handle to pop_month2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_month2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_month2
str = get(hObject, 'String');
val = get(hObject,'Value');
month2 = getlisti(handles.pop_months_list,str{val});
if ismember(month2, [1,3,5,7,8,10,12])
    set(handles.pop_days2,'String',handles.pop_31days_list)
elseif ismember(month2, [4,6,9,11])
    set(handles.pop_days2,'String',handles.pop_30days_list)
elseif month2 == 2
    set(handles.pop_days2,'String',handles.pop_28days_list)
end
handles.month2 = month2;
% read day of month
val_day = get(handles.pop_days2,'Value');
dayi2 = monthday2dayi(month2,val_day);
set(handles.edit_dayi2,'String',num2str(dayi2))
handles.dayi2 = dayi2;
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pop_month1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_month1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_days1.
function pop_days1_Callback(hObject, eventdata, handles)
% hObject    handle to pop_days1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_days1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_days1
str = get(hObject, 'String');
val = get(hObject,'Value');
handles.days1 = val;

dayi1 = monthday2dayi(handles.month1,handles.days1);
set(handles.edit_dayi1,'String',num2str(dayi1))
handles.dayi1 = dayi1;
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in pop_days2.
function pop_days2_Callback(hObject, eventdata, handles)
% hObject    handle to pop_days2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_days2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_days2
val = get(hObject,'Value');
handles.days2 = val;

dayi2 = monthday2dayi(handles.month2,handles.days2);
set(handles.edit_dayi2,'String',num2str(dayi2))
handles.dayi2 = dayi2;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_days1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_days1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dayi2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dayi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dayi2 as text
%        str2double(get(hObject,'String')) returns contents of edit_dayi2 as a double
str = get(hObject, 'String');
doy = str2double(str);
[month,day] = mmdd2dayi(doy);
handles.month2 = month;
handles.dayi2 = day;
set(handles.pop_month2,'Value',month)
set(handles.pop_days2,'Value',day)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_dayi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dayi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pop_month2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_month2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function pop_days2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_days2 (see GCBO)
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
str = get(hObject, 'String');
handles.lat1 = str2double(str);
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
str = get(hObject, 'String');
handles.lat2 = str2double(str);
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
str = get(hObject, 'String');
handles.dlat = str2double(str);
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

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
if get(hObject,'Value')
    handles.type = 0; % daily
    set(handles.edit_dayi2,'Enable','off')
    set(handles.pop_month2,'Enable','off')
    set(handles.pop_days2, 'Enable','off')
else
    handles.type = 1; % mean
    set(handles.edit_dayi2,'Enable','on')
    set(handles.pop_month2,'Enable','on')
    set(handles.pop_days2, 'Enable','on')
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
if get(hObject,'Value')
    handles.type = 1;  % mean
    set(handles.edit_dayi2,'Enable','on')
    set(handles.pop_month2,'Enable','on')
    set(handles.pop_days2, 'Enable','on')
else
    handles.type = 0;  % daily
    set(handles.edit_dayi2,'Enable','off')
    set(handles.pop_month2,'Enable','off')
    set(handles.pop_days2, 'Enable','off')
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
if get(hObject,'Value')
    handles.latrange = 0; % single latitude
    set(handles.edit8,'Enable','off')
    set(handles.edit9,'Enable','off')
else
    handles.latrange = 1; % latitude range
    set(handles.edit8,'Enable','on')
    set(handles.edit9,'Enable','on')
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
if get(hObject,'Value')
    handles.latrange = 1; % latitude range
    set(handles.edit8,'Enable','on')
    set(handles.edit9,'Enable','on')
else
    handles.latrange = 0; % single latitude
    set(handles.edit8,'Enable','off')
    set(handles.edit9,'Enable','off')
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
if get(hObject,'Value')
    handles.qinso = -2; % mean daily
else
    handles.qinso = -1; % max daily
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
if get(hObject,'Value')
    handles.qinso = -1; % max daily
else
    handles.qinso = -2; % mean daily
end
% Update handles structure
guidata(hObject, handles);
