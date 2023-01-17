function varargout = prewhitenGUI(varargin)
% PREWHITENGUI MATLAB code for prewhitenGUI.fig
%      PREWHITENGUI, by itself, creates a new PREWHITENGUI or raises the existing
%      singleton*.
%
%      H = PREWHITENGUI returns the handle to a new PREWHITENGUI or the handle to
%      the existing singleton*.
%
%      PREWHITENGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREWHITENGUI.M with the given input arguments.
%
%      PREWHITENGUI('Property','Value',...) creates a new PREWHITENGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prewhitenGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prewhitenGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prewhitenGUI

% Last Modified by GUIDE v2.5 17-Sep-2019 07:58:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prewhitenGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @prewhitenGUI_OutputFcn, ...
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


% --- Executes just before prewhitenGUI is made visible.
function prewhitenGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prewhitenGUI (see VARARGIN)

% Choose default command line output for prewhitenGUI
handles.output = hObject;
handles.hmain = gcf;
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
handles.val1 = varargin{1}.val1;

set(handles.hmain,'position',[0.15,0.75,0.15,0.15] * handles.MonZoom) % set position
set(handles.uibuttongroup1,'position',[0.08,0.08,0.82,0.82]) % Power spectrum

set(handles.radiobutton1,'position',[0.02,0.721,0.65,0.207]) % COCO
set(handles.radiobutton2,'position',[0.02,0.495,0.65,0.207]) % COCO
set(handles.radiobutton3,'position',[0.02,0.243,0.65,0.207]) % COCO

set(handles.edit1,'position',[0.68,0.721,0.331,0.18]) % COCO
set(handles.edit2,'position',[0.68,0.477,0.331,0.18]) % COCO
set(handles.edit3,'position',[0.68,0.243,0.331,0.18]) % COCO

set(handles.pushbutton1,'position',[0.3,0.005,0.442,0.23]) % COCO

set(handles.radiobutton1,'Value',0) % model = 2
set(handles.radiobutton2,'Value',1) % model = 2
set(handles.radiobutton3,'Value',0) % model = 2
% language
lang_choice = varargin{1}.lang_choice;
handles.lang_choice = lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;
handles.lang_id = lang_id;
handles.lang_var = lang_var;
[~, a177] = ismember('a177',lang_id);
[~, a173] = ismember('a173',lang_id);
[~, a174] = ismember('a174',lang_id);
[~, a175] = ismember('a175',lang_id);
[~, a176] = ismember('a176',lang_id);
[~, a178] = ismember('a178',lang_id);
[~, ec25] = ismember('ec25',lang_id);
set(gcf,'Name',['Acycle: ',lang_var{a177}])
set(handles.uibuttongroup1,'Title',lang_var{a173})
set(handles.radiobutton1,'String',lang_var{a174})
set(handles.radiobutton2,'String',lang_var{a175})
set(handles.radiobutton3,'String',lang_var{a176})
set(handles.pushbutton1,'String',lang_var{a177})

dat = varargin{1}.current_data;  % data

diffx = diff(dat(:,1));
% check data
if sum(diffx <= 0) > 0
    disp(lang_var{a178})
    dat = sortrows(dat);
end

% check data
if abs((max(diffx)-min(diffx))/2) > 10*eps('single')
    hwarn1 = warndlg(lang_var{ec25});
end
% convential rho1 (lag-1 autocorrelation coefficient)
[rho]=rhoAR1ML(dat(:,2));

% robust AR1: rho1
dt = median(diff(dat(:,1)));
[po,w]=periodogram(dat(:,2));
fd1=w/(2*pi*dt);
poc = cumsum(po); % cumsum of power
pocnorm = 100*poc/max(poc); % normalized
% the first elements at which the cumulated power exceed 99%
poc1 = find( pocnorm > 99, 1);
% if the frequency detected is smaller than 85% of nyquist frequency
% suggest a new input max freq.
if fd1(poc1)/fd1(end) <= 0.85
    ValidNyqFreq = fd1(poc1);
else
    ValidNyqFreq = fd1(end);
end
% mean power of spectrum
fmax = ValidNyqFreq;
% Nyquist frequency
fn = 1/(2*dt);
% Multi-taper method power spectrum
[pxx,f] = pmtm(dat(:,2),2,length(dat(:,2)));
ft = f/pi*fn;
ft = ft(ft<=fmax);
pxx = pxx(ft<=fmax);
% median-smoothing data numbers
smoothn = round(0.2 * length(pxx));
% median-smoothing
pxxsmooth = moveMedian(pxx,smoothn);  % valid data; for rho evaluation
s0 = mean(pxxsmooth);
[rhoM, ~] = minirhos0(s0,fmax,ft,pxxsmooth,2);

set(handles.edit1,'String',num2str(rho))
set(handles.edit2,'String',num2str(rhoM))
set(handles.edit3,'String','1')

handles.slash_v = varargin{1}.slash_v;
handles.acfigmain = varargin{1}.acfigmain;
handles.filename = varargin{1}.data_name; % save dataname
handles.dat_name = varargin{1}.dat_name; % save dataname
handles.path_temp = varargin{1}.path_temp; % save path
handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
[~,~,ext] = fileparts(handles.filename);
handles.ext = ext;
%

handles.ar1model = 2;% 1 = classic; 2 = robust; 3 = user-defined
handles.rho = rho;
handles.rhoM = rhoM;
handles.dat = dat; % save data
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prewhitenGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prewhitenGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lang_id = handles.lang_id;
lang_var = handles.lang_var;
[~, main21] = ismember('main21',lang_id); % time
[~, main23] = ismember('main23',lang_id); % depth
[~, main24] = ismember('main24',lang_id); % value
[~, main01] = ismember('main01',lang_id); % save data

if get(handles.radiobutton1,'Value')
    rho1 = handles.rho;
end
if get(handles.radiobutton2,'Value')
    rho1 = handles.rhoM;
  
end
if get(handles.radiobutton3,'Value')
    rho1 = str2double( get(handles.edit3,'String'));
end

data = handles.dat;
datp = prewhitening(data,rho1);

% plot data
figure;
plot(datp(:,1),datp(:,2),'k','LineWidth',1);

xlabel([lang_var{main23},'/',lang_var{main21}]);
ylabel(lang_var{main24});
%title('Prewhiten')
xlim([min(datp(:,1)) max(datp(:,1))])

% write data
name0 = [handles.dat_name,'-','prewhiten-',num2str(rho1)];
name1 = [name0,handles.ext];
CDac_pwd
dlmwrite(name1, datp, 'delimiter', ' ', 'precision', 9);

disp(['>> ',lang_var{main01},' : ',name1])

d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder
% Update handles structure
guidata(hObject, handles);
