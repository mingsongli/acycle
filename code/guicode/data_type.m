function varargout = data_type(varargin)
% DATA_TYPE MATLAB code for data_type.fig
%      DATA_TYPE, by itself, creates a new DATA_TYPE or raises the existing
%      singleton*.
%
%      H = DATA_TYPE returns the handle to a new DATA_TYPE or the handle to
%      the existing singleton*.
%
%      DATA_TYPE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_TYPE.M with the given input arguments.
%
%      DATA_TYPE('Property','Value',...) creates a new DATA_TYPE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before data_type_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to data_type_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help data_type

% Last Modified by GUIDE v2.5 01-May-2017 21:30:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @data_type_OpeningFcn, ...
                   'gui_OutputFcn',  @data_type_OutputFcn, ...
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


% --- Executes just before data_type is made visible.
function data_type_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to data_type (see VARARGIN)
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',12);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',12);  % set as norm
set(handles.text2,'position',[0.06,0.878, 0.33,0.075]) % set position
set(handles.text3,'position',[0.06,0.146, 0.857,0.707]) % set position

% Choose default command line output for data_type
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes data_type wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = data_type_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
