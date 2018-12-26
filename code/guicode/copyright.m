function varargout = copyright(varargin)
% COPYRIGHT MATLAB code for copyright.fig
%      COPYRIGHT, by itself, creates a new COPYRIGHT or raises the existing
%      singleton*.
%
%      H = COPYRIGHT returns the handle to a new COPYRIGHT or the handle to
%      the existing singleton*.
%
%      COPYRIGHT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COPYRIGHT.M with the given input arguments.
%
%      COPYRIGHT('Property','Value',...) creates a new COPYRIGHT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before copyright_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to copyright_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help copyright

% Last Modified by GUIDE v2.5 27-Feb-2018 20:14:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @copyright_OpeningFcn, ...
                   'gui_OutputFcn',  @copyright_OutputFcn, ...
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


% --- Executes just before copyright is made visible.
function copyright_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to copyright (see VARARGIN)
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','points');  % find all font units as points
set(h1,'FontUnits','norm');  % set as norm
set(gcf,'Name','Acycle: Copyright')

[I,m] = imread('acycle_logo.png');
imshow(I,m,'parent',handles.logo_axes1);
% imshow(I,'Colormap',m,'parent',handles.logo_axes1);
% Choose default command line output for copyright
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes copyright wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = copyright_OutputFcn(hObject, eventdata, handles) 
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
