function varargout = DataExtractTab(varargin)
% DATAEXTRACTTAB MATLAB code for DataExtractTab.fig
%      DATAEXTRACTTAB, by itself, creates a new DATAEXTRACTTAB or raises the existing
%      singleton*.
%
%      H = DATAEXTRACTTAB returns the handle to a new DATAEXTRACTTAB or the handle to
%      the existing singleton*.
%
%      DATAEXTRACTTAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAEXTRACTTAB.M with the given input arguments.
%
%      DATAEXTRACTTAB('Property','Value',...) creates a new DATAEXTRACTTAB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataExtractTab_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataExtractTab_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataExtractTab

% Last Modified by GUIDE v2.5 04-Feb-2019 00:37:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataExtractTab_OpeningFcn, ...
                   'gui_OutputFcn',  @DataExtractTab_OutputFcn, ...
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


% --- Executes just before DataExtractTab is made visible.
function DataExtractTab_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataExtractTab (see VARARGIN)
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
set(handles.uitable1,'position',[0.011,0.012,0.97,0.984])

% Choose default command line output for DataExtractTab
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataExtractTab wait for user response (see UIRESUME)
% uiwait(handles.DataExtractTable1);


% --- Outputs from this function are returned to the command line.
function varargout = DataExtractTab_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
