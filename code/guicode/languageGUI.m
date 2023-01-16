function varargout = languageGUI(varargin)
% LANGUAGEGUI MATLAB code for languageGUI.fig
%      LANGUAGEGUI, by itself, creates a new LANGUAGEGUI or raises the existing
%      singleton*.
%
%      H = LANGUAGEGUI returns the handle to a new LANGUAGEGUI or the handle to
%      the existing singleton*.
%
%      LANGUAGEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LANGUAGEGUI.M with the given input arguments.
%
%      LANGUAGEGUI('Property','Value',...) creates a new LANGUAGEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before languageGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to languageGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help languageGUI

% Last Modified by GUIDE v2.5 18-Nov-2021 01:28:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @languageGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @languageGUI_OutputFcn, ...
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


% --- Executes just before languageGUI is made visible.
function languageGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to languageGUI (see VARARGIN)
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.acfigmain = varargin{1}.acfigmain;
handles.val1 = varargin{1}.val1;

set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',12);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',12);  % set as norm

set(gcf,'position',[0.5,0.7,0.15,0.15]* handles.MonZoom) % set position
set(handles.text1,'position',[0.2,0.6,0.6,0.2]) % set position
set(handles.popupmenu1,'position',[0.2,0.4,0.6,0.2]) % set position
set(handles.pushbutton1,'position',[0.4,0.2,0.2,0.2]) % set position

% language
lang_choice = varargin{1}.lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;

if lang_choice>0
    [~, locb] = ismember('l00',lang_id);
    set(gcf,'Name',lang_var{locb})
    [~, locb1] = ismember('l01',lang_id);
    set(handles.text1,'string',lang_var{locb1})
    [~, locb1] = ismember('main00',lang_id);
    set(handles.pushbutton1,'string',lang_var{locb1})
else
    set(gcf,'Name','Acycle: Language')
end
handles.languageGUIfig = gcf;
% Choose default command line output for languageGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes languageGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = languageGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choices = get(handles.popupmenu1,'string');
language_choice = choices{get(handles.popupmenu1,'value')};
if ismember(language_choice,'English')
    lang_choice = 0;
elseif ismember(language_choice,'中文简体')
    lang_choice = 1;
elseif ismember(language_choice,'中文繁體')
    lang_choice = 2;
else
    lang_choice = 0;
end

ac_lang_ini = load('ac_lang.txt');

if lang_choice ~= ac_lang_ini
    % msg box
    langdlg = readtable('lang.dlg.xlsx');
    lang_id2 = langdlg.ID;
    lang_var2 = table2cell(langdlg(:, 2 + lang_choice));
    [~, locb] = ismember('msg1',lang_id2);
    s = msgbox(lang_var2{locb},'Acycle');
    % new language
    fid = fopen(which('ac_lang.txt'),'wt');
    fprintf(fid, num2str(lang_choice));
    fclose(fid);
    % set default language
    langdict = readtable('langdict.xlsx');
    lang_id = langdict.ID;
    lang_var = table2cell(langdict(:, 2 + lang_choice));

    pause(0.01)

    [~, locb] = ismember('l00',lang_id);
    set(gcf,'Name',lang_var{locb})
    [~, locb1] = ismember('l01',lang_id);
    set(handles.text1,'string',lang_var{locb1})
    [~, locb1] = ismember('main00',lang_id);
    set(handles.pushbutton1,'string',lang_var{locb1})
    
    % restart Acycle GUI
    try close(handles.acfigmain)
        AC
    catch
        
    end
    
    try close(s)
        pause (0.5)
        close(handles.languageGUIfig)
    catch
    end
end
