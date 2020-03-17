function varargout = AC(varargin)
%% ACYCLE
%% time-series analysis software for paleoclimate projects and education
%%
%
% AC MATLAB code for AC.fig
%
%      This is the main function of the Acycle software.
%
%% ************************************************************************
% Please acknowledge the program author on any publication of scientific 
% results based in part on use of the program and cite the following
% article in which the program was described:
%
%       Mingsong Li, Linda Hinnov, Lee Kump. Acycle: Time-series analysis
%       software for paleoclimate projects and education, Computers & Geosciences,
%       127: 12-22. https://doi.org/10.1016/j.cageo.2019.02.011
%
% If you publish results using techniques such as correlation coefficient,
% sedimentary noise model, power decomposition analysis, evolutionary fast
% Fourier transform, wavelet transform, Bayesian changepoint, (e)TimeOpt,
% or other approaches, please also cite original publications,
% as detailed in "AC_Users_Guide.pdf" file at
% 
% https://github.com/mingsongli/acycle/wiki
% https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
%
% Program Author:
%           Mingsong Li, PhD
%           Department of Geosciences
%           Pennsylvania State University
%           410 Deike Bldg, 
%           University Park, PA 16801, USA
%
% Email:    mul450@psu.edu; limingsonglms@gmail.com
% Website:  https://github.com/mingsongli/acycle
%           https://github.com/mingsongli/acycle/wiki
%           http://mingsongli.com
%
% Copyright (C) 2017-2020
%
% This program is a free software; you can redistribute it and/or modify it
% under the terms of the GNU GENERAL PUBLIC LICENSE as published by the 
% Free Software Foundation.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.
%
% You should have received a copy of the GNU General Public License. If
% not, see < https://www.gnu.org/licenses/ >
%
%**************************************************************************
%%
%      AC, by itself, creates a new AC or raises the existing
%      singleton*.
%
%      H = AC returns the handle to a new AC or the handle to
%      the existing singleton*.
%
%      AC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AC.M with the given input arguments.
%
%      AC('Property','Value',...) creates a new AC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AC

% Last Modified by GUIDE v2.5 17-Mar-2020 14:25:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AC_OpeningFcn, ...
                   'gui_OutputFcn',  @AC_OutputFcn, ...
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


% --- Executes just before AC is made visible.
function AC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AC (see VARARGIN)
set(gcf,'position',[0.5,0.1,0.45,0.8]) % set position
set(gcf,'Name','Acycle v2.1.1')
set(gcf,'DockControls', 'off')
set(gcf,'Color', 'white')
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location

%% push_up
h_push_up = uicontrol('Style','pushbutton','Tag','push_up');%,'BackgroundColor','white','ForegroundColor','white');  % set style, Tag
%jEdit = findjobj(h_push_up);   % find java
%jEdit.Border = [];  % hide border
set(h_push_up,'Units','normalized') % set units as normalized
set(h_push_up,'Position', [0.02,0.945,0.06,0.05]) % set position
tooltip = '<html>Up<br>one level';  % tooltip
set(h_push_up,'tooltip',tooltip,'CData',imread('menu_up.jpg'))  % set tooltip and button image
set(h_push_up,'Callback',@push_up_clbk)  % set callback function

%% push_folder
h_push_folder = uicontrol('Style','pushbutton','Tag','push_folder');%,'BackgroundColor','white');  % set style, Tag
% jEdit = findjobj(h_push_folder);   % find java
% jEdit.Border = [];  % hide border
set(h_push_folder,'Units','normalized') % set units as normalized
set(h_push_folder,'Position', [0.106,0.945,0.065,0.05]) % set position
tooltip = '<html>Open<br>working folder';  % tooltip
set(h_push_folder,'tooltip',tooltip,'CData',imread('menu_folder.jpg'))  % set tooltip and button image
set(h_push_folder,'Callback',@push_folder_clbk)  % set callback function

%% push_plot
h_push_plot = uicontrol('Style','pushbutton','Tag','push_plot');%,'BackgroundColor','white');  % set style, Tag
% jEdit = findjobj(h_push_plot);   % find java
% jEdit.Border = [];  % hide border
set(h_push_plot,'Units','normalized') % set units as normalized
set(h_push_plot,'Position', [0.2,0.945,0.06,0.05]) % set position
tooltip = '<html>Plot Pro';  % tooltip
set(h_push_plot,'tooltip',tooltip,'CData',imread('menu_plot.jpg'))  % set tooltip and button image
set(h_push_plot,'Callback',@push_plot_clbk)  % set callback function

%% push_refresh
h_push_refresh = uicontrol('Style','pushbutton','Tag','push_refresh');%,'BackgroundColor','white');  % set style, Tag
% jEdit = findjobj(h_push_refresh);   % find java
% jEdit.Border = [];  % hide border
set(h_push_refresh,'Units','normalized') % set units as normalized
set(h_push_refresh,'Position', [0.28,0.945,0.06,0.05]) % set position
tooltip = '<html>Refresh<br>list box';  % tooltip
set(h_push_refresh,'tooltip',tooltip,'CData',imread('menu_refresh.jpg'))  % set tooltip and button image
set(h_push_refresh,'Callback',@push_refresh_clbk)  % set callback function

%% push_robot
h_push_robot = uicontrol('Style','pushbutton','Tag','push_robot');%,'BackgroundColor','white');  % set style, Tag
% jEdit = findjobj(h_push_robot);   % find java
% jEdit.Border = [];  % hide border
set(h_push_robot,'Units','normalized') % set units as normalized
set(h_push_robot,'Position', [0.36,0.945,0.06,0.05]) % set position
tooltip = '<html>Mini-robot';  % tooltip
set(h_push_robot,'tooltip',tooltip,'CData',imread('menu_robot.jpg'))  % set tooltip and button image
set(h_push_robot,'Callback',@push_robot_clbk)  % set callback function

%% push_openfolder
h_push_openfolder = uicontrol('Style','pushbutton','Tag','push_openfolder');%,'BackgroundColor','white');  % set style, Tag
% jEdit = findjobj(h_push_openfolder);   % find java
% jEdit.Border = [];  % hide border
set(h_push_openfolder,'Units','normalized') % set units as normalized
set(h_push_openfolder,'Position', [0.02,0.9,0.06,0.04]) % set position
tooltip = '<html>Change<br>directory';  % tooltip
set(h_push_openfolder,'tooltip',tooltip,'CData',imread('menu_open.jpg'))  % set tooltip and button image
set(h_push_openfolder,'Callback',@push_openfolder_clbk)  % set callback function
%%
if ispc
    set(h_push_folder,'BackgroundColor','white') % 
    set(h_push_up,'BackgroundColor','white') % 
    set(h_push_plot,'BackgroundColor','white') % 
    set(h_push_refresh,'BackgroundColor','white') % 
    set(h_push_robot,'BackgroundColor','white') % 
    set(h_push_openfolder,'BackgroundColor','white') % 
end

set(handles.popupmenu1,'position', [0.75,0.945,0.24,0.04])
set(handles.edit_acfigmain_dir,'position',       [0.081,0.9,0.91,0.04])
set(handles.listbox_acmain,'position',    [0.02,0.008,0.96,0.884])

if ismac
    handles.slash_v = '/';
elseif ispc
    handles.slash_v = '\';
end

handles.acfigmain = gcf;  %handles of the ac main window
figure(handles.acfigmain)
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',12);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

% Choose default command line output for AC
handles.output = hObject;
path_root = pwd;
set(handles.edit_acfigmain_dir,'String',path_root);
handles.foldname = 'foldname'; % default file name

handles.path_temp = [path_root,handles.slash_v,'temp'];
handles.working_folder = [handles.path_temp,handles.slash_v,handles.foldname];
% if ad_pwd.txt exist; then go to this folder
if exist('ac_pwd.txt', 'file') == 2
    GETac_pwd;
    if isdir(ac_pwd)
        cd(ac_pwd)
    end
else
    ac_pwd_str = which('refreshcolor.m');
    [ac_pwd_dir,~,~] = fileparts(ac_pwd_str);
    fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
    fprintf(fileID,'%s',pwd);
    fclose(fileID);
end

refreshcolor;
cd(path_root) %back to root path

handles.doubleclick = 0;
handles.unit = 'unit'; % default file name
handles.unit_type = 0;
handles.t1 = 55;
handles.f1 = 0.0;
handles.f2 = 0.06;
handles.sr1 = 1;
handles.sr2 = 30;
handles.srstep = .1;
handles.nsim = 2000;
handles.red = 2;
handles.adjust = 0;
handles.slices = 1;
handles.index_selected = 1;
handles.pad = 50000;
handles.prewhiten_linear = 'notlinear';
handles.prewhiten_lowess = 'notlowess';
handles.prewhiten_rlowess = 'notrlowess';
handles.prewhiten_loess = 'notloess';
handles.prewhiten_rloess = 'notloess';
handles.prewhiten_polynomial2 = 'not2nd';
handles.prewhiten_polynomialmore = 'notmore';
handles.MTMtabtchi = 'notabtchi';
handles.nw = 2;
handles.copycut = 'copy';
handles.nplot = 0;
handles.filetype = {'.txt','.csv','','.res'};
handles.acfig = gcf;
handles.math_sort = 1;
handles.math_unique = 1;
handles.math_deleteempty = 1;
handles.math_derivative = 1;
assignin('base','unit',handles.unit)
assignin('base','unit_type',handles.unit_type)

% Update handles structure
guidata(hObject, handles);
% Update reminder
pause(0.0001);%
% if isdeployed
%     copyright;
% end
try 
    % If the software has not been used for 30 days, checking updates
    ac_check_opendate;
catch
end
% bug fixed: window system32 may be the default working folder, but not
% writable.
try
    tempname1 = 'temp_test_acycle.txt';
    fileID = fopen(fullfile(pwd,tempname1),'w+');
    fprintf(fileID,'%s\n',datestr(datetime('now')));
    fclose(fileID);
    delete(tempname1)
catch
    msgbox(['Change working folder. ','Current working folder may be not writable!'],'Folder');
end

% --- Outputs from this function are returned to the command line.
function varargout = AC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function push_up_clbk(hObject, handles)
handles = guidata(hObject);
CDac_pwd; % cd working dir
cd ..;
refreshcolor;
cd(pre_dirML); % return view dir
guidata(hObject,handles)


function push_folder_clbk(hObject, handles)
GETac_pwd;
if ismac
    system(['open ',ac_pwd]);
elseif ispc
    winopen(ac_pwd);
end


function push_plot_clbk(hObject, handles)
handles = guidata(hObject);

contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            elseif sum(strcmp(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})) > 0
                try 
                    hwarn = warndlg('Wait, large image? can be very slow ...');

                    im_name = imread(plot_filter_s);
                    hFig1 = figure;
                    lastwarn('') % Clear last warning message
                    imshow(im_name);
                    [warnMsg, warnId] = lastwarn;
                    if ~isempty(warnMsg)
                        close(hFig1)
                        imscrollpanel_ac(plot_filter_s);
                    end
                    try close(hwarn)
                    catch
                    end
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
            end
        end
    else
        return
    end
end

if check == 1
    for i = 1: nplot
        plot_no = plot_selected(i);
        handles.plot_s{i} = fullfile(ac_pwd,char(contents(plot_no)));
    end
    handles.nplot = nplot;
    guidata(hObject, handles);
    PlotAdv(handles);
end

% --- Executes on button press in push_refresh.
function push_refresh_clbk(hObject, handles)
handles = guidata(hObject);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir

% --- Executes on button press in push_openfolder.
function push_openfolder_clbk(hObject, eventdata, handles)
handles = guidata(hObject);
pre_dirML = pwd;
GETac_pwd;
selpath = uigetdir(ac_pwd);
if selpath == 0
else
    if isdir(selpath)
        disp(['>>  Change working folder to ',selpath])
        cd(selpath)
        refreshcolor;
        cd(pre_dirML); % return view dir
    end
end


% --- Executes on button press in push_robot.
function push_robot_clbk(hObject, eventdata, handles)
% hObject    handle to push_robot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
unit = handles.unit;
unit_type = handles.unit_type;
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
check = 0;
% check

% fix a bug in wavelet ...
%
%#function fminbnd
%#function chisquare_solve

for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
        else
            [~,dat_name,ext] = fileparts(plot_filter_s);
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            end
        end
    else
    end
end

if check == 1
    for i = 1:nplot
        plot_no = plot_selected(i);
        plot_filter_s1 = char(contents(plot_no));
        GETac_pwd; 
        plot_filter_s = fullfile(ac_pwd,plot_filter_s1);
        try
            data_filterout = load(plot_filter_s);
        catch       
            fid = fopen(plot_filter_s);
            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
            fclose(fid);
            if iscell(data_ft)
                try
                    data_filterout = cell2mat(data_ft);
                catch
                    fid = fopen(plot_filter_s,'at');
                    fprintf(fid,'%d\n',[]);
                    fclose(fid);
                    fid = fopen(plot_filter_s);
                    data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                    disp(['>>  Read data: ', dat_name, '. Okay!'])
                    fclose(fid);
                    try
                        data_filterout = cell2mat(data_ft);
                    catch
                        warndlg(['Check selected data: ',dat_name],'Data Error!')
                    end
                end
            end
        end
        handles.data_filterout = data_filterout;
        handles.dat_name = dat_name;
        guidata(hObject, handles);
        RobotGUI(handles)
        
    end
else
    warndlg({'No selected data';'';...
        'Please first select at leaset one *.txt data file.';...
        '';'FORMAT:';'';'<No header>';'';...
        '1st column: depth or time';'';'2nd column: value';''})
end


% --- Executes on selection change in listbox_acmain.
function listbox_acmain_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_acmain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_acmain contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_acmain

persistent chk
if isempty(chk)
      chk = 1;
      pause(0.35); %Add a delay to distinguish single click from a double click
      if chk == 1
          chk = [];
          handles.doubleclick = 0;
      end
else
      chk = [];
      handles.doubleclick = 1;
end

        
if handles.doubleclick
    index_selected = get(hObject,'Value');
    file_list = get(hObject,'String');
    filename = file_list{index_selected};
    try
        % if selected item is a folder, try to open the folder.
        CDac_pwd; % cd working dir
        filename1 = strrep2(filename, '<HTML><FONT color="blue">', '</FONT></HTML>');
        filename = fullfile(ac_pwd,filename1);
        cd(filename)
        refreshcolor;
        cd(pre_dirML);
        disp(['>>  Change directory to < ', filename1, ' >'])
    catch
        [~,dat_name,ext] = fileparts(filename);
        filetype = handles.filetype;
        %disp(ext)
        if isdeployed
            % bug start:   Warning: The Open function cannot be used in compiled applications.
            if strcmp(ext,'.fig')
                try openfig(filename)
                catch
                    GETac_pwd;
                    if ispc
                        winopen(ac_pwd);
                    elseif ismac
                        system(['open ',ac_pwd]);
                    end
                end
            elseif ismember(ext,{'.txt','.csv'})
                [data1,~] = importdata(filename);
                nlen = length(data1(:,1));
                if nlen > 15
                    msgbox('See Terminal/Command Window for details')
                    disp(['>> Total rows: ', num2str(nlen)])
                    disp('>> First 10 and last 5 rows of data:')
                    disp(data1(1:10,:))
                    disp('       ... ...')
                    disp(data1(end-4:end,:))
                else
                    msgbox('See Terminal/Command Window for details')
                    disp('>> Data:')
                    disp(data1)
                end
            elseif ismember(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})
                try
                    hwarn = warndlg('Wait, large image? can be very slow ...');
                    im_name = imread(filename);
                    hFig1 = figure;
                    lastwarn('') % Clear last warning message
                    imshow(im_name);
                    set(gcf,'Name',[dat_name,ext])
                    [warnMsg, warnId] = lastwarn;
                    if ~isempty(warnMsg)
                        close(hFig1)
                        imscrollpanel_ac(filename);
                    end
                    try close(hwarn)
                    catch
                    end
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
            elseif ismember(ext,{'.pdf'})
                openpdf(filename)
            else
                if ispc
                    winopen(ac_pwd);
                elseif ismac
                    system(['open ',ac_pwd]);
                else
                end
            end
            % bug end:   Warning: The Open function cannot be used in compiled applications.
        else
            if strcmp(ext,'.fig')
                try
                    openfig(filename);
                    set(gcf,'Name',[dat_name,ext])
                catch
                end
            elseif ismember(ext,{'.txt','.csv'})
                [data1,~] = importdata(filename);
                nlen = length(data1(:,1));
                if nlen> 15
                    msgbox('See Terminal/Command Window for details')
                    disp(['>> Total rows: ', num2str(nlen)])
                    disp('>> First 10 and last 5 rows of data:')
                    disp(data1(1:10,:))
                    disp('                  ... ...')
                    disp(data1(end-4:end,:))
                    
                else
                    msgbox('See Terminal/Command Window for details')
                    disp('>> Data:')
                    disp(data1)
                end
            elseif ismember(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})
                try 
                    hwarn = warndlg('Wait, large image? can be very slow ...');
                    im_name = imread(filename);
                    hFig1 = figure;
                    lastwarn('') % Clear last warning message
                    imshow(im_name);
                    set(gcf,'Name',[dat_name,ext])
                    [warnMsg, warnId] = lastwarn;
                    if ~isempty(warnMsg)
                        close(hFig1)
                        imscrollpanel_ac(filename);
                    end
                    %hwarn = warndlg('Wait, large image? can be very slow ...');
                    try close(hwarn)
                    catch
                    end
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
            elseif ismember(ext,{'.pdf','.ai','.ps'})
                try
                    uiopen(filename,1);
                catch
                end
            elseif ismember(ext,{'.doc','.docx','.ppt','.pptx','.xls','.xlsx'})
                try
                    uiopen(filename,1);
                catch
                end
            else
                GETac_pwd;
                if ispc
                    winopen(ac_pwd);
                elseif ismac
                    system(['open ',ac_pwd]);
                else
                end
            end
        end
    end
else
    handles.index_selected  = get(hObject,'Value');
end
guidata(hObject,handles)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listbox_acmain.
function listbox_acmain_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to listbox_acmain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function listbox_acmain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_acmain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_acfigmain_dir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_acfigmain_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_acfigmain_dir as text
%        str2double(get(hObject,'String')) returns contents of edit_acfigmain_dir as a double
address = get(hObject,'String');
CDac_pwd;
if isdir(address);
    cd(address)
else
    errordlg('Error: address not exist')
end
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit_acfigmain_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_acfigmain_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function menu_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function menu_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function menu_plotall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function menu_plotall_Callback(hObject, eventdata, handles)
% hObject    handle to menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function menu_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        if isdir(plot_filter_s)
            return
        else
            [~,dat_name,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            elseif strcmp(ext,'.fig')
                plot_filter_s = char(contents(plot_selected(1)));
                try openfig(plot_filter_s);
                catch
                end
            elseif strcmp(ext,{'.pdf','.ai','.ps'})
                plot_filter_s = char(contents(plot_selected(1)));
                open(plot_filter_s);
            elseif sum(strcmp(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})) > 0
                try 
                    hwarn = warndlg('Wait, large image? can be very slow ...');
                    
                    im_name = imread(plot_filter_s);
                    hFig1 = figure;
                    lastwarn('') % Clear last warning message
                    imshow(im_name);
                    set(gcf,'Name',[dat_name,ext])
                    [warnMsg, warnId] = lastwarn;
                    if ~isempty(warnMsg)
                        close(hFig1)
                        imscrollpanel_ac(plot_filter_s);
                    end
                    try close(hwarn)
                    catch
                    end
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
            end
        end
    else
        return
    end
end
plotsucess = 0;
if check == 1;
    figf = figure;
    hold on;
    for i = 1:nplot
        plot_no = plot_selected(i);
        plot_filter_s1 = char(contents(plot_no));
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s1);
    try
        data_filterout = load(plot_filter_s);
    catch       
        fid = fopen(plot_filter_s);
        try data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
            fclose(fid);
            if iscell(data_ft)
                try
                    data_filterout = cell2mat(data_ft);
                catch
                    fid = fopen(plot_filter_s,'at');
                    fprintf(fid,'%d\n',[]);
                    fclose(fid);
                    fid = fopen(plot_filter_s);
                    data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                    fclose(fid);
                    try
                        data_filterout = cell2mat(data_ft);
                    catch
                        warndlg(['Check data: ',dat_name],'Data Error!')
                    end
                end
            end
        catch
            warndlg({'Cannot find the data.'; 'Folder Name may contain NO language other than ENGLISH'})
            try
                close(figf);
            catch
            end
        end
        
    end     

        data_filterout = data_filterout(~any(isnan(data_filterout),2),:);
        
        try plot(data_filterout(:,1),data_filterout(:,2:end),'LineWidth',1)
            plotsucess = 1;
            % save current data for R 
            assignin('base','currentdata',data_filterout);
            datar = num2str(data_filterout(1,2));
            for ii=2:length(data_filterout(:,1));
                r1 =data_filterout(ii,2); 
                datar = [datar,',',num2str(r1)];
            end
            assignin('base','currentdataR',datar);
            %
        catch
            errordlg([plot_filter_s1,' : data error. Check data'],'Data Error')
            if plotsucess > 0
            else
                close(figf)
                continue
            end   
        end
    end
    set(gca,'XMinorTick','on','YMinorTick','on')
    if handles.unit_type == 0;
        xlabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1;
        xlabel(['Depth (',handles.unit,')'])
    else
        xlabel(['Time (',handles.unit,')'])
    end
    title(plot_filter_s1, 'Interpreter', 'none')
    hold off
    set(gcf,'color','w');
end
guidata(hObject,handles)


% --------------------------------------------------------------------
function menu_SwapPlot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_SwapPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s1 = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s1, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            elseif strcmp(ext,'.fig')
                plot_filter_s = char(contents(plot_selected(1)));
                openfig(plot_filter_s);
            elseif strcmp(ext,{'.pdf','.ai','.ps'})
                plot_filter_s = char(contents(plot_selected(1)));
                open(plot_filter_s);
            end
        end
    else
        return
    end
end

if check == 1;
    figure;
    hold on;
    for i = 1:nplot
        plot_no = plot_selected(i);
        plot_filter_s = char(contents(plot_no));
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
    try
        fid = fopen(plot_filter_s);
        data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
        fclose(fid);
        if iscell(data_ft)
            try
                data_filterout = cell2mat(data_ft);
            catch
                fid = fopen(plot_filter_s,'at');
                fprintf(fid,'%d\n',[]);
                fclose(fid)
                fid = fopen(plot_filter_s);
                data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                fclose(fid);
                data_filterout = cell2mat(data_ft);
            end
        end
    catch
        data_filterout = load(plot_filter_s);
    end
            
            data_filterout = data_filterout(~any(isnan(data_filterout),2),:);
            plot(data_filterout(:,2),data_filterout(:,1),'LineWidth',1);
    end
    if handles.unit_type == 0;
        ylabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1;
        ylabel(['Depth (',handles.unit,')'])
    else
        ylabel(['Time (',handles.unit,')'])
    end
    title(plot_filter_s1, 'Interpreter', 'none')
    set(gca,'XMinorTick','on','YMinorTick','on')
    hold off
end
set(gcf,'color','w');
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function menu_basic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_basic_Callback(hObject, eventdata, handles)
% hObject    handle to menu_basic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function menu_math_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_math_Callback(hObject, eventdata, handles)
% hObject    handle to menu_math (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function menu_help_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
case 'unit' % User selects unit.
   handles.unit = 'unit';
   handles.unit_type = 0;
case 'm' % User selects m.
   handles.unit = 'm';
   handles.unit_type = 1;
case 'dm' % User selects dm.
   handles.unit = 'dm';
   handles.unit_type = 1;
case 'cm' % User selects cm.
    handles.unit = 'cm';
    handles.unit_type = 1;
case 'mm' % User selects mm.
   handles.unit = 'mm';
   handles.unit_type = 1;
case 'ft' % User selects ft.
   handles.unit = 'ft';
   handles.unit_type = 1;
case 'km' % User selects km.
   handles.unit = 'km';
   handles.unit_type = 1;
case 'yr' % User selects year.
   handles.unit = 'yr';
   handles.unit_type = 2;
case 'kyr' % User selects kilo-year.
   handles.unit = 'kyr';
   handles.unit_type = 2;
case 'myr' % User selects million years.
   handles.unit = 'myr';
   handles.unit_type = 2;
end
assignin('base','unit',handles.unit)
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


% --------------------------------------------------------------------
function menu_read_Callback(hObject, eventdata, handles)
% hObject    handle to menu_read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
filename = 'UpdateLog.txt';
url = 'https://github.com/mingsongli/acycle/blob/master/doc/UpdateLog.txt';
if isdeployed
    web(url,'-browser')
else
    try uiopen(filename,1);
    catch
        if ispc
            try open(filename)
            catch
                try winopen(filename)
                catch
                    try web(url,'-browser')
                    catch
                    end
                end
            end
        elseif ismac
                try system(['open ',filename]);
                catch
                    try web(url,'-browser')
                    catch
                    end
                end
        else
            web(url,'-browser')
        end
    end
end

% --------------------------------------------------------------------
function menu_manuals_Callback(hObject, eventdata, handles)
% hObject    handle to menu_manuals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%filename = which('AC_Users_Guide.pdf');
%openpdf(filename);
url2 = 'https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf';
web(url2,'-browser')
url = 'https://github.com/mingsongli/acycle/wiki';
web(url,'-browser')


% --------------------------------------------------------------------
function menu_findupdates_Callback(hObject, eventdata, handles)
% hObject    handle to menu_findupdates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
url = 'https://mingsongli.com/acycle';
web(url,'-browser')
url = 'https://github.com/mingsongli/acycle';
web(url,'-browser')

% --------------------------------------------------------------------
function menu_contact_Callback(hObject, eventdata, handles)
% hObject    handle to menu_contact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
copyright

% --------------------------------------------------------------------
function menu_selectinterval_Callback(hObject, eventdata, handles)
% hObject    handle to menu_selectinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if min(plot_selected) > 2
    for i = 1:nplot
        data_name = char(contents(plot_selected(i)));
        data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            GETac_pwd; data_name = fullfile(ac_pwd,data_name);
            data = load(data_name);
            time = data(:,1);
            value = data(:,2);
            npts = length(time);

            prompt = {'Enter the START of interval:','Enter the END of interval:','Apply to ALL? (1 = yes)'};
            dlg_title = 'Input Select interval';
            num_lines = 1;
            defaultans = {num2str(time(1)),num2str(time(npts)),'0'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                xmin_cut = str2double(answer{1});
                xmax_cut = str2double(answer{2});
                ApplyAll = str2double(answer{3});
                
                if ApplyAll == 1
                    for ii = 1:nplot
                        data_name = char(contents(plot_selected(ii)));
                        data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
                        if isdir(data_name) == 1
                        else
                            [~,dat_name,ext] = fileparts(data_name);
                            disp(['>>  Processing ',data_name])
                            if sum(strcmp(ext,handles.filetype)) > 0
                                GETac_pwd; data_name = fullfile(ac_pwd,data_name);
                                data = load(data_name);
                                time = data(:,1);
                                if or (max(time) < xmin_cut, min(time) > xmax_cut)
                                    errordlg(['No overlap between selected interval and ',dat_name],'Error')
                                    disp('      Error, no overlap')
                                    continue
                                end
                                if and (min(time) > xmin_cut, max(time) < xmax_cut)
                                    disp('      Selected interval too large, skipped')
                                    continue
                                end
                                [current_data] = select_interval(data,xmin_cut,xmax_cut); 
                                name1 = [dat_name,'_',num2str(xmin_cut),'_',num2str(xmax_cut),ext];  % New name
                                CDac_pwd; % cd ac_pwd dir
                                dlmwrite(name1, current_data, 'delimiter', ',', 'precision', 9);
                            end
                        end
                    end
                    d = dir; %get files
                    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                    refreshcolor;
                    cd(pre_dirML); % return to matlab view folder
                    return
                else
                    
                    if or (max(time) < xmin_cut, min(time) > xmax_cut)
                        errordlg(['No overlap between selected interval and ',dat_name],'Error')
                        disp('      Error, no overlap')
                        return
                    end
                    if and (min(time) > xmin_cut, max(time) < xmax_cut)
                        disp('Selected interval too large, skipped')
                        return
                    end
                    [current_data] = select_interval(data,xmin_cut,xmax_cut); 
                    name1 = [dat_name,'_',num2str(xmin_cut),'_',num2str(xmax_cut),ext];  % New name

                    CDac_pwd; % cd ac_pwd dir
                    dlmwrite(name1, current_data, 'delimiter', ',', 'precision', 9);
                    d = dir; %get files
                    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                    refreshcolor;
                    cd(pre_dirML); % return to matlab view folder
                end
            end
        end
        end
    end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_oversampling_Callback(hObject, eventdata, handles)
% hObject    handle to menu_interp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
        if isdir(data_name) == 1
        else
        [~,~,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            GETac_pwd; data_name = fullfile(ac_pwd,data_name);
            data = load(data_name);
            time = data(:,1);
            %dt = median(diff(time));
            dtmin = min(diff(time));
            dtmax = max(diff(time));
            dlg_title = 'Interpolation';
            prompt = {'Tested sampling rate 1:','Tested sampling rate 2:',...
                'Number of tested sampling rates','Number of simulation'};
            num_lines = 1;
            defaultans = {num2str(0.5*dtmin),num2str(5*dtmax),'100','1000'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            
            if ~isempty(answer)
                sr1 = str2double(answer{1});
                sr2 = str2double(answer{2});
                raten = str2double(answer{3});
                nsim = str2double(answer{4});
                [sr_sh_5] = OversamplingTest(data,sr1,sr2,raten,nsim);
            end
        end
        end
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function menu_interp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_interp_Callback(hObject, eventdata, handles)
% hObject    handle to menu_interp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
disp(['Select ',num2str(nplot),' data'])
    
for nploti = 1:nplot
    if plot_selected > 2
    data_name_all = (contents(plot_selected));
    data_name = char(data_name_all{nploti});
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
        [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0

        try
            fid = fopen(data_name);
            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
            fclose(fid);
            if iscell(data_ft)
                try
                    data = cell2mat(data_ft);
                catch
                    fid = fopen(data_name,'at');
                    fprintf(fid,'%d\n',[]);
                    fclose(fid)
                    fid = fopen(data_name);
                    data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                    fclose(fid);
                    data = cell2mat(data_ft);
                end
            end
        catch
            data = load(data_name);
        end 
            time = data(:,1);
            srmedian = median(diff(time));
            dlg_title = 'Interpolation';
            prompt = {'New sample rate (default = median):'};
            num_lines = 1;
            defaultans = {num2str(srmedian)};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            
            if ~isempty(answer)
                interpolate_rate = str2double(answer{1});
                data_interp = interpolate(data,interpolate_rate);
                name1 = [dat_name,'-rsp',num2str(interpolate_rate),ext];  % New name
                CDac_pwd
                dlmwrite(name1, data_interp, 'delimiter', ',', 'precision', 9); 
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
            end
        end
        end
    end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_norm_Callback(hObject, eventdata, handles)
% hObject    handle to menu_norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
        [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            data = load(data_name);
            time = data(:,1);
            value = (data(:,2)-mean(data(:,2)))/std(data(:,2));
            data1 = [time,value];
            name1 = [dat_name,'-stand',ext];
            CDac_pwd
            dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9); 
            d = dir; %get files
            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
            refreshcolor;
            cd(pre_dirML); % return to matlab view folder
        end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_clip_Callback(hObject, eventdata, handles)
% hObject    handle to menu_clip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
disp(['Select ',num2str(nplot),' data'])
for nploti = 1:nplot
    if plot_selected > 2
        data_name_all = (contents(plot_selected));
        data_name = char(data_name_all{nploti});
        data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
        disp(['>>  Processing clipping:', data_name]);
        GETac_pwd; 
        data_name = fullfile(ac_pwd,data_name);
    
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                try
                    fid = fopen(data_name);
                    data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
                    fclose(fid);
                    if iscell(data_ft)
                        try
                            data = cell2mat(data_ft);
                        catch
                            fid = fopen(data_name,'at');
                            fprintf(fid,'%d\n',[]);
                            fclose(fid);
                            fid = fopen(data_name);
                            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                            fclose(fid);
                            data = cell2mat(data_ft);
                        end
                    end
                catch
                    data = load(data_name);
                end

                prompt = {'Threshold value'; 'Keep high/low? (1=high; 0=low)'};
                dlg_title = 'Clipping:';
                num_lines = 1;
                defaultans = {num2str(nanmean(data(:,2))), '1'};
                options.Resize='on';
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                    if ~isempty(answer)

                        clip_value = str2double(answer{1});
                        clip_high  = str2double(answer{2});

                        time = data(:,1);
                        y = data(:,2);
                        n = length(time);
                        if clip_high == 1
                            for i = 1:n
                                if y(i) > clip_value
                                    y(i) = y(i) - clip_value;
                                else
                                    y(i) = 0;
                                end
                            end
                            name1 = [dat_name,'-clip',num2str(clip_value),'+',ext];
                        else
                            for i = 1:n
                                if y(i) > clip_value
                                    y(i) = 0;
                                else
                                    y(i) = y(i) - clip_value;
                                end
                            end
                            name1 = [dat_name,'-clip<',num2str(clip_value),'-',ext];
                        end

                            data1 = [time,y];
                            CDac_pwd
                            dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
                            d = dir; %get files
                            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                            refreshcolor;
                            cd(pre_dirML); % return to matlab view folder
                    else
                        errordlg('Error, input must be a positive integer')
                    end
                end
        end
    end
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_log10_Callback(hObject, eventdata, handles)
% hObject    handle to menu_log10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
        [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            data = load(data_name);
            time = data(:,1);
            value = log10(data(:,2));
            data1 = [time,value];
            name1 = [dat_name,'-log10',ext];
            %csvwrite(name1,data1)
            % cd ac_pwd dir
            CDac_pwd
            dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9); 
            d = dir; %get files
            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
            refreshcolor;
            cd(pre_dirML); % return to matlab view folder
        end
        end
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to menu_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0

            try
                fid = fopen(data_name);
                data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
                fclose(fid);
                if iscell(data_ft)
                    data = cell2mat(data_ft);
                end
            catch
                data = load(data_name);
            end 

            time = data(:,1);
            value = data(:,2);
            npts = length(time);
            dlg_title = 'Smooth';
            prompt = {'Number of points (3, 5, 7, ...):'};
            num_lines = 1;
            defaultans = {'3'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                smooth_v = str2double(answer{1});
                data(:,2) = movemean(data(:,2),smooth_v,'omitnan');
                name1 = [dat_name,'_',num2str(smooth_v),'ptsm',ext];  % New name
                CDac_pwd
                dlmwrite(name1, data, 'delimiter', ',', 'precision', 9); 
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
                figure;
                plot(time,value,'k')
                hold on;
                plot(time,data(:,2),'r','LineWidth',2.5)
                title([dat_name,ext], 'Interpreter', 'none')
                xlabel(handles.unit)
                ylabel('Value')
                legend('Raw',[num2str(smooth_v),'points-smoothed'])
                hold off;
            end
        end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_bootstrap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0

        try
            fid = fopen(data_name);
            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
            fclose(fid);
            if iscell(data_ft)
                data = cell2mat(data_ft);
            end
        catch
            data = load(data_name);
        end 

            time = data(:,1);
            value = data(:,2);
            span_d = (time(end)-time(1))* 0.1;
            dlg_title = 'Bootstrap';
            prompt = {'Window (unit)','Method: "loess/lowess/rloess/rlowess"',...
                'Number of bootstrap'};
            num_lines = 1;
            defaultans = {num2str(span_d),'loess','1000'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                span_v = str2double(answer{1});
                method = (answer{2});
                bootn = str2double(answer{3});
%                 if bootn*length(time) >= 100000
%                     warndlg('Large number of bootstrap simulations. Please Wait ...','Bootstrap');
%                 end
                
                span = span_v/(time(end)-time(1));
                hwarn1 = warndlg('Slow process. Wait ...','Smoothing');
                [meanboot,bootstd,bootprt] = smoothciML(time,value,method,span,bootn);
                try close(hwarn1)
                catch
                end
                data(:,4) = meanboot;
                data(:,2) = meanboot - 2*bootstd;
                data(:,3) = meanboot - bootstd;
                data(:,5) = meanboot + bootstd;
                data(:,6) = meanboot + 2*bootstd;
                data1 = [time,bootprt];
                name = [dat_name,'_',num2str(span_v),'_',method,'_',num2str(bootn),'_bootstp_meanstd',ext];  % New name
                name1 = [dat_name,'_',num2str(span_v),'_',method,'_',num2str(bootn),'_bootstp_percentile',ext];
                
                disp(['>>  Save [time, mean-2std, mean-std, mean, mean+std, mean+2std] as :',name])
                disp(['>>  Save [time, percentiles] as :',name1])
                disp('>>        Percentiles are ')
                disp('>>        [0.5,2.5,5,25,50,75,95,97.5,99.5]')
                CDac_pwd
                dlmwrite(name, data, 'delimiter', ',', 'precision', 9); 
                dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9); 
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
            end
        end
        end
end
guidata(hObject, handles);



% --------------------------------------------------------------------
function menu_derivative_Callback(hObject, eventdata, handles)
% hObject    handle to menu_derivative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
disp(['Select ',num2str(nplot),' data'])
%if and ((min(plot_selected) > 2), (nplot == 1))
for nploti = 1:nplot
if plot_selected > 2
    data_name_all = (contents(plot_selected));
    data_name = char(data_name_all{nploti});
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    disp(['>>  Processing derivative:', data_name]);
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            try
                fid = fopen(data_name);
                data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
                fclose(fid);
                if iscell(data_ft)
                    try
                        data = cell2mat(data_ft);
                    catch
                        fid = fopen(data_name,'at');
                        fprintf(fid,'%d\n',[]);
                        fclose(fid);
                        fid = fopen(data_name);
                        data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                        fclose(fid);
                        data = cell2mat(data_ft);
                    end
                end
            catch
                data = load(data_name);
            end

            prompt = {'Derivative (1=1st, 2=2nd ...)'};
            dlg_title = 'Approximate Derivatives:';
            num_lines = 1;
            defaultans = {num2str(handles.math_derivative)};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                derivative_n = str2double(answer{1});
                % check
                int_gt_0 = @(n) (rem(n,1) == 0) & (n > 0);
                math_derivative = int_gt_0(derivative_n);
                
                if math_derivative == 1
                    data = data(~any(isnan(data),2),:); % remove NaN values
                    data = sortrows(data);
                    time  = data(:,1);
                    value = data(:,2);
                    for i=1:derivative_n
                        value= diff(value)./diff(time);
                        time = time(1:length(time)-1,1);
                    end
                    data1 = [time,value];
                    % remember settings
                    handles.math_derivative = derivative_n;
                    name1 = [dat_name,'_',num2str(derivative_n),'derv',ext];
                    CDac_pwd
                    dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
                    d = dir; %get files
                    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                    refreshcolor;
                    cd(pre_dirML); % return to matlab view folder
                else
                    errordlg('Error, input must be a positive integer')
                end
            end
        end
        end
end
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function menu_period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_period_Callback(hObject, eventdata, handles)
% hObject    handle to menu_period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,~,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                guidata(hObject, handles);
                evofftGUI(handles);
            end
        end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function menu_power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_power_Callback(hObject, eventdata, handles)
% hObject    handle to menu_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,~,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                guidata(hObject, handles);
                spectrum(handles);
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_wavelet_Callback(hObject, eventdata, handles)
% hObject    handle to menu_clip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This menu doesn't work in a standalone application
%
% Error message:
% Undefined function or variable "chisquare_solve"
% Error in fminbnd (lin 34)
%
% Potential solution is to add %#function fminbnd
% Read more: https://www.mathworks.com/help/compiler/limitations-about-what-may-be-compiled.html

%#function fminbnd
%#function chisquare_solve

contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
disp(['Select ',num2str(nplot),' data'])
%if and ((min(plot_selected) > 2), (nplot == 1))
for nploti = 1:nplot
    if plot_selected > 2
        data_name_all = (contents(plot_selected));
        data_name = char(data_name_all{nploti});
        data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
        disp(['>>  Processing clipping:', data_name]);
        GETac_pwd; 
        data_name = fullfile(ac_pwd,data_name);
    
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                try
                    fid = fopen(data_name);
                    data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
                    fclose(fid);
                    if iscell(data_ft)
                        try
                            data = cell2mat(data_ft);
                        catch
                            fid = fopen(data_name,'at');
                            fprintf(fid,'%d\n',[]);
                            fclose(fid);
                            fid = fopen(data_name);
                            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                            fclose(fid);
                            data = cell2mat(data_ft);
                        end
                    end
                catch
                    data = load(data_name);
                end
                
                time = data(:,1);
                timelen = 0.5 * (time(end)-time(1));
                sst = data(:,2);
                dt = mean(diff(time));
                prompt = {['Period range from (',handles.unit,')']; ['Period range to (',handles.unit,')'];...
                    'Pad (1=yes,0=no)'; 'Discrete scale spacing (default)'};
                dlg_title = '1D Wavelet transform';
                num_lines = 1;
                defaultans = {num2str(2*dt),num2str(timelen), '1', '0.1'};
                options.Resize='on';
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                    if ~isempty(answer)
                        figwarnwave = warndlg('Wavelet may take a few minutes ...','Warning: Slow Process!');
                        pt1 = str2double(answer{1});
                        pt2 = str2double(answer{2});
                        pad  = str2double(answer{3});
                        dss  = str2double(answer{4});
                        figwave = figure;
                        [~,~,~]= waveletML(sst,time,pad,dss,pt1,pt2);
                        name1 = [dat_name,'-wavelet.fig'];
                        
                        CDac_pwd
                        try savefig(figwave,name1)
                            disp(['>>  Save as: ',name1, '. Folder: '])
                            disp(pwd)
                        catch
                            disp('>>  Wavelet figure unsaved ...')
                        end
                        try close(figwarnwave)
                        catch
                        end
                        
                        d = dir; %get files
                        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                        refreshcolor;
                        cd(pre_dirML); % return to matlab view folder
                    else
                        
                    end
                end
        end
    end
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function menu_filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_filter_Callback(hObject, eventdata, handles)
% hObject    handle to menu_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                handles.dat_name = dat_name;
                guidata(hObject, handles);
                ft(handles);
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_AM_Callback(hObject, eventdata, handles)
% hObject    handle to menu_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length

if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    dat_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,dat_name);
        if isdir(data_name) == 1
            disp('>>  Error: select the data file not a folder')
        else
            [~,~,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                data = load(data_name);
                
                t=data(:,1);
                dt=t(2)-t(1);
                nyquist = 1/(2*dt);
                fl = 0;
                fh = nyquist;
                fc = 1/2*nyquist;

                [tanhilb,~,~] = tanerhilbertML(data,fc,fl,fh);

                data_am = [tanhilb(:,1), tanhilb(:,3)];
                
                name1 = [dat_name,'-AM',ext];
                name2 = [dat_name,'-AMf',ext];
                CDac_pwd
                dlmwrite(name1, data_am, 'delimiter', ',', 'precision', 9);
                dlmwrite(name2, [tanhilb(:,1), tanhilb(:,2)], 'delimiter', ',', 'precision', 9);
                disp('>>  See main window for amplitude modulation')
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
            
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_age_Callback(hObject, eventdata, handles)
% hObject    handle to menu_age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
agescale(handles)


% --------------------------------------------------------------------
function menu_dynos_Callback(hObject, eventdata, handles)
% hObject    handle to menu_dynos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0

                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                handles.dat_name = dat_name;
                guidata(hObject, handles);
                DYNOS(handles);
            end
        end
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_ecoco_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ecoco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                handles.dat_name = dat_name;
                guidata(hObject, handles);
                eCOCOGUI(handles);
            end
        end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function menu_laskar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function menu_laskar_Callback(hObject, eventdata, handles)
% hObject    handle to menu_laskar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
basicseries(handles);


% --- Executes during object creation, after setting all properties.
function menu_LR04_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_LR04_Callback(hObject, eventdata, handles)
% hObject    handle to menu_LR04 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Start Age in k.a. (>= 0):',...
                'End Age in k.a. (<= 5320):'};
dlg_title = 'LR04 stack: Plio-Pleistocene d18O_ben)';
num_lines = 1;
defaultans = {'0','5320'};
options.Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
if ~isempty(answer)
    t1 = str2double(answer{1});
    t2 = str2double(answer{2});
    LR04stack = load('LR04stack5320ka.txt');
    LR04stack_s = select_interval(LR04stack,t1,t2);
    figure;
    plot(LR04stack_s(:,1),LR04stack_s(:,2),'LineWidth',1);
    xlabel('Time (kyr)')
    ylabel('Global Benthic \delta^{18}O')
    title(['LR04 Stack: ',num2str(t1),'_',num2str(t2),' ka'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    filename = ['LR04_Stack_',num2str(t1),'_',num2str(t2),'ka.txt'];
    % cd ac_pwd dir
    CDac_pwd
    dlmwrite(filename, LR04stack_s, 'delimiter', ',', 'precision', 9);
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_plotn_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            else
                return
            end
        end
    else
        return
    end
end

if check == 1;
    figure;
    hold on;
    for i = 1:nplot
        plot_no = plot_selected(i);
            plot_filter_s = char(contents(plot_no));
            GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
    try
        fid = fopen(plot_filter_s);
        data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
        fclose(fid);
        if iscell(data_ft)
            dat = cell2mat(data_ft);
        end
    catch
        dat = load(plot_filter_s);
    end
            
            
            dat = dat(~any(isnan(dat),2),:);
            dat(:,2) = (dat(:,2)-mean(dat(:,2)))/std(dat(:,2));
            plot(dat(:,1),dat(:,2),'LineWidth',1);
    end
    set(gca,'XMinorTick','on','YMinorTick','on')
    hold off
    title(contents(plot_selected), 'Interpreter', 'none')
    if handles.unit_type == 0;
        xlabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1;
        xlabel(['Depth (',handles.unit,')'])
    else
        xlabel(['Time (',handles.unit,')'])
    end
end
guidata(hObject,handles)

% --------------------------------------------------------------------
function menu_plotn2_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotn2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            else
                return
            end
        end
    else
        return
    end
end

if check == 1
    xlimit = zeros(nplot,2);
    figure;
    hold on;
    for i = 1:nplot
        plot_no = plot_selected(i);
            plot_filter_s = char(contents(plot_no));
            GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
         try
            fid = fopen(plot_filter_s);
            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
            fclose(fid);
            if iscell(data_ft)
                dat = cell2mat(data_ft);
            end
        catch
            dat = load(plot_filter_s);
         end 
            
        dat = dat(~any(isnan(dat),2),:);
        dat(:,2) = (dat(:,2)-mean(dat(:,2)))/std(dat(:,2));
        plot(dat(:,1),dat(:,2) - 2*(i-1),'LineWidth',1);  % modify to fit with the order of title
        xlimit(i,:) = [dat(1,1) dat(length(dat(:,1)),1)];
    end
    set(gca,'XMinorTick','on','YMinorTick','on')
    hold off
    title(contents(plot_selected), 'Interpreter', 'none')
    xlim([min(xlimit(:,1)) max(xlimit(:,2))])
    if handles.unit_type == 0
        xlabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1
        xlabel(['Depth (',handles.unit,')'])
    else
        xlabel(['Time (',handles.unit,')'])
    end

end
guidata(hObject,handles)

% --------------------------------------------------------------------
function menu_rename_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
if nplot == 1
    if plot_selected > 2
        CDac_pwd;
        plot_filter_s = char(contents(plot_selected));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        prompt = {'Enter new file name:'};
        dlg_title = 'Rename                           ';
        num_lines = 1;
        defaultans = {plot_filter_s};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
        newname = char(answer);
        if ~isempty(newname)
            try
                movefile(plot_filter_s,newname)
            catch
                disp('Error: Cannot copy or move a file or directory onto itself.')
            end
            d = dir; %get files
            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
            refreshcolor;
            cd(pre_dirML);
        end
    end
end

% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_import_Callback(hObject, eventdata, handles)
% hObject    handle to menu_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.txt;*.csv','Files (*.txt;*.csv)'},...
    'Import data (*.csv,*.txt)');
if filename == 0
    open_data = 'Tips: open 2 colume data';
    h = helpdlg(open_data,'Tips: Close');
    uiwait(h); 
else
    aaa = [pathname,filename];
    data=load(aaa);
    
    CDac_pwd % cd ac_pwd dir
    dlmwrite(handles.foldname, data, 'delimiter', ',', 'precision', 9); 
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
    handles.current_data = data;
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function menu_savefig_Callback(hObject, eventdata, handles)
% hObject    handle to menu_savefig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Name of ACYCLE figure:'};
        dlg_title = 'Filename';
        num_lines = 1;
        defaultans = {'.AC.fig'};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
        newname = char(answer);
        if ~isempty(newname)
            CDac_pwd % cd ac_pwd dir
            savefig(newname)
            refreshcolor;
            cd(pre_dirML); % return to matlab view folder
        end


% --------------------------------------------------------------------
function menu_depeaks_Callback(hObject, eventdata, handles)
% hObject    handle to menu_depeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
        [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            
            data = load(data_name);
            time = data(:,1);
            value = data(:,2);
            npts = length(time);

            prompt = {'Enter Mininum value:','Enter Maximum value:'};
            dlg_title = 'Input MIN and MAX value';
            num_lines = 1;
            defaultans = {num2str(min(value)),num2str(max(value))};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                ymin_cut = str2double(answer{1});
                ymax_cut = str2double(answer{2});
                [current_data]=depeaks(data,ymin_cut,ymax_cut); 

                name1 = [dat_name,'-dpks',num2str(ymin_cut),'_',num2str(ymax_cut),ext];  % New name
                CDac_pwd
                dlmwrite(name1, current_data, 'delimiter', ',', 'precision', 9); 
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
            end
        end
        end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function menuac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menuac_Callback(hObject, eventdata, handles)
% hObject    handle to menuac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function menu_prewhiten_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_prewhiten_Callback(hObject, eventdata, handles)
% hObject    handle to menu_prewhiten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,~,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0

                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                guidata(hObject, handles);
                prewhiten(handles);
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_agebuild_Callback(hObject, eventdata, handles)
% hObject    handle to menu_agebuild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
    if isdir(data_name) == 1
    else
        [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0

            data = load(data_name);

            prompt = {'Enter period (kyr):','Use 1 = peak; 0 = trough:'};
            dlg_title = 'Input period';
            num_lines = 1;
            defaultans = {'41','1'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                period = str2double(answer{1});
                pkstrough = str2double(answer{2});
                %
                data = data(~any(isnan(data),2),:); % remove NaN values
                data = sortrows(data);  % sort first column
                data=findduplicate(data); % remove duplicate number
                data(any(isinf(data),2),:) = []; % remove empty
                %
                if pkstrough == 1
                    [datapks,~] = getpks(data);
                    plot_filter_s ='max';
                else
                    data(:,2) = -1*data(:,2);
                    [datapks,~] = getpks(data);
                    plot_filter_s ='min';
                end

                [nrow, ~] = size(datapks);
                
                % age model
                datapksperiod = 1:nrow;
                datapksperiod = datapksperiod*period;
                datapksperiod = datapksperiod';
                agemodel = [datapks(:,1),datapksperiod];
                
                % sed. rate 
                sedrate = zeros(nrow+2,2);
                sedrate(1,1) = data(1,1);
                sedrate(2:end-1,1) = datapks(:,1);
                sedrate(end,1) = data(end,1);
                sedrate0 = diff(agemodel(:,1))./diff(agemodel(:,2));
                sedrate(2:end-2,2) = sedrate0;
                sedrate(1,2) = sedrate(2,2);
                sedrate(end-1,2) = sedrate(end-2,2);
                sedrate(end,2) = sedrate(end-2,2);
                % full age model
                agemodelfull = zeros(nrow+2,2);
                agemodelfull(2:end-1,:) = agemodel;
                agemodelfull(1,1) = data(1,1);
                agemodelfull(1,2) = datapksperiod(1) - (agemodelfull(2,1)-agemodelfull(1,1)) * sedrate(1,2);
                agemodelfull(end,1) = data(end,1);
                agemodelfull(end,2) = datapksperiod(end) + (agemodelfull(end,1)-agemodelfull(end-1,1)) * sedrate(end,2);

                name1 = [dat_name,'-agemodel-',num2str(period),'_',plot_filter_s,ext];
                name2 = [dat_name,'-sed.rate-',num2str(period),'_',plot_filter_s,ext];

                CDac_pwd
                dlmwrite(name1, agemodel, 'delimiter', ',', 'precision', 9);
                dlmwrite(name2, sedrate,  'delimiter', ',', 'precision', 9);
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
                
                figure;
                set(gcf,'units','norm') % set location
                set(gcf,'position',[0.01,0.55,0.45,0.4]) % set position
                set(gcf,'Name','Acycle: Build Age Model | Age Model')
                set(gcf,'color','w');
                plot(agemodelfull(:,1), agemodelfull(:,2),'k','LineWidth',1)
                xlabel(['Depth (',handles.unit,')'])
                ylabel('Time (kyr)')
                title(['Age Model: ', num2str(period), ' kyr cycle: ', plot_filter_s])
                set(gca,'XMinorTick','on','YMinorTick','on')
                xlim([agemodelfull(1,1), agemodelfull(end,1)])
                ylim([agemodelfull(1,2), agemodelfull(end,2)])
                
                figure;
                set(gcf,'color','w');
                set(gcf,'Name','Acycle: Build Age Model | Sedimentation Rate')
                set(gcf,'units','norm') % set location
                set(gcf,'position',[0.01,0.05,0.45,0.4]) % set position
                stairs(sedrate(:,1), sedrate(:,2),'k','LineWidth',1)
                xlabel(['Depth (',handles.unit,')'])
                ylabel(['Sedimentation rate (',handles.unit,'/kyr)'])
                xlim([sedrate(1,1), sedrate(end,1)])
                ylim([0, max(sedrate(:,2)) * 2])
                title(['Sedimentation rate: ', num2str(period), ' kyr cycle: ', plot_filter_s])
                set(gca,'XMinorTick','on','YMinorTick','on')
            end
        end
    end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_function_Callback(hObject, eventdata, handles)
% hObject    handle to menu_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
        [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            
            data = load(data_name);

            prompt = {'a for the 1st column: x(i) = a * x(i) + b',...
                'b for the 1st column: x(i) = a * x(i) + b',...
                'c for the 2nd column: y(i) = c * y(i) + d',...
                'd for the 2nd column: y(i) = c * y(i) + d'};
            dlg_title = 'Input parameters';
            num_lines = 1;
            defaultans = {'1','0','1','0'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
            a = str2double(answer{1});
            b = str2double(answer{2});
            c = str2double(answer{3});
            d = str2double(answer{4});

            data(:,1) = a * data(:,1) + b;
            data(:,2) = c * data(:,2) + d;
            if and(and(a == 1, b==0), and(c==1, d==0))
            else
                CDac_pwd
                dlmwrite([dat_name,'-new',ext], data, 'delimiter', ',', 'precision', 9);
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
            end
            end
        end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_maxmin_Callback(hObject, eventdata, handles)
% hObject    handle to menu_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0

        try
            fid = fopen(data_name);
            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
            fclose(fid);
            if iscell(data_ft)
                data = cell2mat(data_ft);
            end
        catch
            data = load(data_name);
        end 
        
            x = data(:,1);
            dlg_title = 'Find Max/Min value and indice';
            prompt = {'Interval start','Interval end','Max or Min (1 = max, else = min)','Tested column'};
            num_lines = 1;
            defaultans = {num2str(min(x)),num2str(max(x)),'1','2'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                t1 = str2double(answer{1});
                t2 = str2double(answer{2});
                maxmin = str2double(answer{3});
                ind = str2double(answer{4});
                [dat] = select_interval(data,t1,t2);
                y = dat(:,ind);
                if maxmin == 1  
                    [m,i] = max(y);
                else
                    [m,i] = min(y);
                end
                disp(dat(i,:))
            end
        end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_cpt_Callback(hObject, eventdata, handles)
% hObject    handle to menu_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Function of Bayesian changepoint technique

contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0

        try
            fid = fopen(data_name);
            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
            fclose(fid);
            if iscell(data_ft)
                data = cell2mat(data_ft);
            end
        catch
            data = load(data_name);
        end 
        
            x = data(:,1);
            dlg_title = 'Ruggieri (2013) Bayesian Changepoint';
            prompt = {...
                'k_max, max no. of change points allowed',...
                'd_min, min distance between consecutive change points',...
                'k_0, variance scaling hyperparameter',...
                'v_0,  pseudo data point',...
                'sig_0, pseudo data variance (maybe halved)',...
                'n, number of sampled solutions',...
                'Save data? (1 = yes, 0 = no)'};
            num_lines = 1;
            sig_0 = var(data(:,2));
            k_0 = ceil( abs(x(end)-x(1))/44 ); % default value, 1/sub-interval*25%
            defaultans = {'10','1','0.01',num2str(k_0),num2str(sig_0),'500','1'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                if length(x)> 500
                    warndlg('Large dataset, wait...')
                end
                k_max = str2double(answer{1}); % default is 10
                d_min = str2double(answer{2}); % at least twice as many data points as free parameters
                    % in the regression model. Ensure enough data is
                    % available to estimate the parameters of the model
                    % accurately
                k_0 = str2double(answer{3}); % set k0 to be small, yielding a wide prior distribution
                    % on the regression coefficients
                v_0 = str2double(answer{4}); % may be <25% of the size of the minimum allowed sub-interval
                sig_0 = str2double(answer{5}); %  this will not be larger than the overall variance of the
                    % data set, one option is to conservatively set the
                    % prior variance sig_0^2, equal to the variance of the
                    % data set being used
                num_samp = str2double(answer{6});
                savedata = str2double(answer{7});
                % 
                [mod,cpt,R_2] = bayes_cpt(data,k_max,d_min,k_0,v_0,sig_0,num_samp);
                if savedata == 1
                    CDac_pwd
                    dlmwrite([dat_name,'-BayesRegModel',ext], mod, 'delimiter', ',', 'precision', 9);
                    dlmwrite([dat_name,'-BayesChangepoint',ext], cpt, 'delimiter', ',', 'precision', 9);
                    disp(['>> ',dat_name,ext,' Bayesian change points output saved. R_2 is ',num2str(R_2)])
                    
                    d = dir; %get files
                    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                    refreshcolor;
                    cd(pre_dirML); % return to matlab view folder
                end
            end
        end
        end
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_imshow_Callback(hObject, eventdata, handles)
% hObject    handle to menu_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
            
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})) > 0
                try
                    % GRB and Grayscale supported here
                    hwarn = warndlg('Wait, large image? can be very slow ...');
                    im_name = imread(data_name);
                    hFig1 = figure;
                    lastwarn('') % Clear last warning message
                    imshow(im_name);
                    set(gcf,'Name',[dat_name,ext])
                    [warnMsg, warnId] = lastwarn;
                    if ~isempty(warnMsg)
                        close(hFig1)
                        imscrollpanel_ac(data_name);
                    end
                    try close(hwarn)
                    catch
                    end
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_rgb2gray_Callback(hObject, eventdata, handles)
% hObject    handle to menu_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
            
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})) > 0
                try
                    im_name = imread(data_name);

                    try I = rgb2gray(im_name);
                        figure
                        imshow(I)
                        dat_name = [dat_name,'-gray',ext];
                        set(gcf,'Name',dat_name)
                        CDac_pwd;
                        imwrite(I,dat_name)
                        d = dir; %get files
                        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                        refreshcolor;
                        cd(pre_dirML); % return to matlab view folder
                    catch
                        warndlg('This is not a RGB image')
                    end
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_improfile_Callback(hObject, eventdata, handles)
% hObject    handle to menu_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})) > 0
                try
                    hwarn = warndlg('Wait, large image? can be very slow ...');
                    I = imread(data_name);
                    figI = figure;
                    lastwarn('') % Clear last warning message
                    imshow(I);

                    [warnMsg, warnId] = lastwarn;
                    
                    if ~isempty(warnMsg)
                        close(figI)
                        imscrollpanel_ac(data_name);
                        figI = gcf;
                    end
                    try close(hwarn)
                    catch
                    end
                    
                    set(gcf,'Name',[dat_name,ext,': Press "SHIFT"or"ALT" & select cursors now'])

                    choice = questdlg('Steps: 1) click the "DataCursor" tool; 2) select two cursors; 3) press "Enter" in the COMMAND window', ...
                        'Press "SHIFT"or"ALT" key & select 2 cursors', 'Continue','Cancel','Continue');

                    switch choice
                        case 'Continue'
                            figure(figI)
                            
                            dcm_obj = datacursormode(figI);
                            set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','off','Enable','on')
                            Sure = input('>>  Press "Enter"');
                            c_info = getCursorInfo(dcm_obj);
                            m = length(c_info);
                            CursorInfo_value = zeros(m,2);
                            if m == 2
                                for i = 1 : m
                                   CursorInfo_value(i,1)=c_info(i).Position(:,1);
                                   CursorInfo_value(i,2)=c_info(i).Position(:,2);
                                end
                            end
                            hold on; plot( CursorInfo_value(:,1), CursorInfo_value(:,2), 'g-','LineWidth',3)

                            if m > 2
                                warndlg('More than 2 cursors selected, only first 2 used!')
                            end

                            if m >= 2
                                [cx,cy,c,xi,yi] = improfile(I,CursorInfo_value(:,1),CursorInfo_value(:,2));
                                cx = sort(cx - min(cx));
                                cy = sort(cy - min(cy));
                                cz = sqrt(cx.^2 + cy.^2);

                                try data = [cz,c];
                                catch
                                    warndlg('This is not a grayscale image!')
                                    try c = reshape(c,[],3);
                                    catch
                                        warndlg('Looks like a cymk image, right?')
                                        c = reshape(c,[],4);
                                    end
                                    data = [cz,c];
                                end
                                name = [dat_name,'-profile.txt'];
                                name1= [dat_name,'-controlpoints.txt'];
                                data1 = [xi,yi];

                                CDac_pwd
                                dlmwrite(name , data, 'delimiter', ',', 'precision', 9);
                                dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
                                disp(['>>  save profile data as   ',name1])
                                disp(['>>  save control points as ',name1])
                                d = dir; %get files
                                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                                refreshcolor;
                                cd(pre_dirML); % return to matlab view folder

                                figure;plot(cz,c);
                                title(name, 'Interpreter', 'none'); 
                                xlabel('Pixels'); 
                                set(gca,'XMinorTick','on','YMinorTick','on')
                                if m == 2
                                    ylabel('Grayscale')
                                else
                                    ylabel('Value')
                                end
                            end
                        case 'Cancel'
                            try close(figI)
                            catch
                            end
                    end
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
                    
            end
        end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function menu_cut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_refresh

% --------------------------------------------------------------------
function menu_cut_Callback(hObject, eventdata, handles)
% hObject    handle to menu_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
CDac_pwd;
handles.nplot = nplot;
if  min(plot_selected) > 2
    handles.data_name = {};
    handles.file = {};
    for i = 1 : nplot
       filename = char(contents(plot_selected(i)));
       handles.data_name{i} = strrep2(filename, '<HTML><FONT color="blue">', '</FONT></HTML>');
       handles.file{i} = [ac_pwd,handles.slash_v,handles.data_name{i}];
    end
end
handles.copycut = 'cut';
cd(pre_dirML);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function menu_copy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to menu_copy

% --------------------------------------------------------------------
function menu_copy_Callback(hObject, eventdata, handles)
% hObject    handle to menu_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
CDac_pwd;
handles.nplot = nplot;
if  min(plot_selected) > 2
    handles.data_name = {};
    handles.file = {};
    for i = 1 : nplot
       filename = char(contents(plot_selected(i)));
       handles.data_name{i} = strrep2(filename, '<HTML><FONT color="blue">', '</FONT></HTML>');
       handles.file{i} = [ac_pwd,handles.slash_v,handles.data_name{i}];
    end
end
handles.copycut = 'copy';
cd(pre_dirML);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function menu_paste_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to menu_copy

% --------------------------------------------------------------------
function menu_paste_Callback(hObject, eventdata, handles)
% hObject    handle to menu_paste (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CDac_pwd;
copycut = handles.copycut; % cut or copy
nplot = handles.nplot; % number of selected files
if nplot == 0
    return
end
for i = 1:nplot
    if strcmp(copycut,'cut')
        new_name = handles.data_name{i};
        new_name_w_dir = [ac_pwd,handles.slash_v,new_name];
        if exist(new_name_w_dir)
            answer = questdlg(['Cover existed file ',new_name,'?'],...
                'Warning',...
                'Yes','No','No');
            % Handle response
            switch answer
                case 'Yes'
                    movefile(handles.file{i}, ac_pwd)
                case 'No'
            end
        else
            movefile(handles.file{i}, ac_pwd)
        end
    elseif strcmp(copycut,'copy')
        % paste copied files
        try
            new_name = handles.data_name{i};
            new_name_w_dir = [ac_pwd,handles.slash_v,new_name];
            if exist(new_name_w_dir)
                [~,dat_name,ext] = fileparts(new_name);
                for i = 1:100
                    new_name = [dat_name,'_copy',num2str(i),ext];
                    if exist([ac_pwd,handles.slash_v,new_name])
                    else
                        break
                    end
                end
            end
            new_file = [ac_pwd,handles.slash_v,new_name];
            file_list = handles.file;
            copyfile(file_list{i}, new_file)
        catch
            disp('No data copied')
        end
    end
end
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
if isdir(pre_dirML)
    cd(pre_dirML);
end
guidata(hObject,handles)

% --------------------------------------------------------------------
function menu_delete_Callback(hObject, eventdata, handles)
% hObject    handle to menu_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deletefile = 0;

choice = questdlg('You are going to DELETE the selected file(s)', ...
	'Warning', 'Yes','No','No');
% Handle response
switch choice
    case 'No'
        deletefile = 0;
    case 'Yes'
        deletefile = 1;
end

if deletefile == 1
    list_content = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
    selected = handles.index_selected;  % read selection in listbox 1; minus 2 for listbox
    nplot = length(selected);   % length
    CDac_pwd; % cd working dir
    % handles.listnumber = handles.listnumber - nplot;
    if selected > 2
        
        for i = 1:nplot
            plot_no = selected(i);
            plot_filter_selection = char(list_content(plot_no));
            
            if plot_no > 2
                file_type = exist(plot_filter_selection);
                    if file_type == 0
                        plot_filter_selection = strrep2(plot_filter_selection, '<HTML><FONT color="blue">', '</FONT></HTML>');
                    end
                if isdir(plot_filter_selection)
                    choice = questdlg('DELETE selected folder and files within it', ...
                        'Warning', 'Yes','No','No');
                    % Handle response
                    switch choice
                        case 'No'
                        case 'Yes'
                            status = rmdir(plot_filter_selection,'s');
                    end
                else
                    recycle on;
                    delete(plot_filter_selection);
                end
            end
        end
        d = dir; %get files
        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
        refreshcolor;
        cd(pre_dirML);
    end
    guidata(hObject,handles)
end


% --------------------------------------------------------------------
function menu_add_Callback(hObject, eventdata, handles)
% hObject    handle to menu_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
check = 0;
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            if sum(strcmp(ext,handles.filetype)) > 0
                if nplot >1
                check = 1; % selection can be executed 
                end
            else
                return
            end
        end
    else
        return
    end
end

if check == 1;
    plot_filter_s2 = char(contents(plot_selected(1)));
    GETac_pwd; plot_filter_s2 = fullfile(ac_pwd,plot_filter_s2);
    dat_new = load(plot_filter_s2);
    if i > 1
        for i = 2:nplot
            plot_no = plot_selected(i);
            plot_filter_s = char(contents(plot_no));
            data_filterout = load(fullfile(ac_pwd,plot_filter_s));
            dat_new = [dat_new; data_filterout];
            dat_merge = sortrows(dat_new);
        end
    else
    end
    dat_merge = findduplicate(dat_merge);
    CDac_pwd
    dlmwrite('mergedseries.txt', dat_merge, 'delimiter', ',', 'precision', 9);
    d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder
end
guidata(hObject,handles)


% --------------------------------------------------------------------
function menu_multiply_Callback(hObject, eventdata, handles)
% hObject    handle to menu_multiply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
check = 0;
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            if sum(strcmp(ext,handles.filetype)) > 0
                if nplot == 2
                check = 1; % selection can be executed 
                end
            else
                return
            end
        end
    else
        return
    end
end

if check == 1
    plot_filter_s2 = char(contents(plot_selected(1)));
    GETac_pwd; plot_filter_s2 = fullfile(ac_pwd,plot_filter_s2);
    dat_new = load(plot_filter_s2);
    dat_new1 = dat_new;
    dat_new2 = dat_new;
    if i > 1
        for i = 2:nplot
            plot_no = plot_selected(i);
            plot_filter_s = char(contents(plot_no));
            data_filterout = load(fullfile(ac_pwd,plot_filter_s));
            dat_new1 = [dat_new(:,1),  dat_new1(:,2).* data_filterout(:,2)];
            dat_new2 = [data_filterout(:,1),  dat_new2(:,2).* data_filterout(:,2)];
        end
    else
    end
    CDac_pwd
    dlmwrite('multipliedseries1.txt', dat_new1, 'delimiter', ',', 'precision', 9);
    dlmwrite('multipliedseries2.txt', dat_new2, 'delimiter', ',', 'precision', 9);
    d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function menu_sort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --------------------------------------------------------------------
function menu_sort_Callback(hObject, eventdata, handles)
% hObject    handle to menu_sort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
disp(['Select ',num2str(nplot),' data'])
for nploti = 1:nplot
if plot_selected > 2
    prompt = {'Sort data in ascending order?','Unique values in data?','Remove empty row?','Apply to ALL'};
        dlg_title = 'Sort, Unique & Remove empty (1 = yes)';
        num_lines = 1;
        defaultans = {num2str(handles.math_sort),num2str(handles.math_unique),num2str(handles.math_deleteempty),'0'};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
        if ~isempty(answer)
            datasort = str2double(answer{1});
            dataunique = str2double(answer{2});
            dataempty = str2double(answer{3});
            dataApply2ALL = str2double(answer{4});
            
            if dataApply2ALL == 1
                for nploti = 1:nplot
                % Apply settings to all data
                    data_name_all = (contents(plot_selected));
                    data_name = char(data_name_all{nploti});
                    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
                    GETac_pwd; 
                    data_name = fullfile(ac_pwd,data_name);
                    disp(['>>  Processing ', data_name]);
                    data_error = 0;
                    if isdir(data_name) == 1
                    else
                        [~,dat_name,ext] = fileparts(data_name);
                        if sum(strcmp(ext,handles.filetype)) > 0
                            try
                                fid = fopen(data_name);
                                data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
                                fclose(fid);
                                if iscell(data_ft)
                                    try
                                        data = cell2mat(data_ft);
                                    catch
                                        fid = fopen(data_name,'at');
                                        fprintf(fid,'%d\n',[]);
                                        fclose(fid);
                                        fid = fopen(data_name);
                                        data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                                        fclose(fid);
                                        try
                                            data = cell2mat(data_ft);
                                        catch
                                            warndlg(['Check data file: ', dat_name],'Data Error!')
                                            disp(['      Error! Skipped. Check the data file:', dat_name]);
                                            data_error = 1;
                                        end
                                    end
                                end
                            catch
                                data = load(data_name);
                            end
                            if data_error ==1
                            else
                                data = data(~any(isnan(data),2),:); % remove NaN values
                                if datasort == 1
                                    data = sortrows(data);
                                    name1 = [dat_name,'-so'];
                                end
                                if dataunique == 1
                                    data=findduplicate(data);
                                    name1 = [dat_name,'-u'];  % New name
                                end
                                if (datasort + dataunique) == 2
                                    name1 = [dat_name,'-su'];  % New name
                                end
                                if dataempty == 1
                                    data(any(isinf(data),2),:) = [];
                                    if (datasort + dataunique) > 0
                                        name1 = [name1,'e'];  % New name
                                    else
                                        name1 = [dat_name,'-e'];  % New name
                                    end
                                end
                                if (datasort + dataunique + dataempty) > 0
                                    name2 = [name1,ext];
                                else
                                    name2 = [dat_name,ext];
                                end
                                % remember settings
                                handles.math_sort = datasort;
                                handles.math_unique = dataunique;
                                handles.math_deleteempty = dataempty;

                                CDac_pwd
                                dlmwrite(name2, data, 'delimiter', ',', 'precision', 9);
                            end
                        end
                    end
                end
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
                return
            else
                data_name_all = (contents(plot_selected));
                data_name = char(data_name_all{nploti});
                data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
                GETac_pwd;
                data_name = fullfile(ac_pwd,data_name);
                disp(['>>  Processing ', data_name]);
                data_error = 0;
                if isdir(data_name) == 1
                else
                    [~,dat_name,ext] = fileparts(data_name);
                    if sum(strcmp(ext,handles.filetype)) > 0
                        try
                            fid = fopen(data_name);
                            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
                            fclose(fid);
                            if iscell(data_ft)
                                try
                                    data = cell2mat(data_ft);
                                catch
                                    fid = fopen(data_name,'at');
                                    fprintf(fid,'%d\n',[]);
                                    fclose(fid);
                                    fid = fopen(data_name);
                                    data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                                    fclose(fid);
                                    try
                                        data = cell2mat(data_ft);
                                    catch
                                        % length of 2 columns are not equal
                                        lengthmin = min(length(data_ft{1,1}), length(data_ft{1,2}));
                                        data_ft1 = data_ft{1,1};
                                        data_ft2 = data_ft{1,2};
                                        data_ft_new{1,1} = data_ft1(1:lengthmin);
                                        data_ft_new{1,2} = data_ft2(1:lengthmin);
                                        try 
                                            data = cell2mat(data_ft_new);
                                        catch
                                            warndlg(['Check data file: ', dat_name],'Data Error!')
                                            disp(['      Error! Check the data file:', dat_name]);
                                            data_error = 1;
                                        end
                                    end
                                end
                            end
                        catch
                            data = load(data_name);
                        end
                        if data_error == 1
                        else
                            data = data(~any(isnan(data),2),:); % remove NaN values
                            if datasort == 1
                                data = sortrows(data);
                                name1 = [dat_name,'-so'];
                            end
                            if dataunique == 1
                                data=findduplicate(data);
                                name1 = [dat_name,'-u'];  % New name
                            end
                            if (datasort + dataunique) == 2
                                name1 = [dat_name,'-su'];  % New name
                            end
                            if dataempty == 1
                                data(any(isinf(data),2),:) = [];
                                if (datasort + dataunique) > 0
                                    name1 = [name1,'e'];  % New name
                                else
                                    name1 = [dat_name,'-e'];  % New name
                                end
                            end
                            if (datasort + dataunique + dataempty) > 0
                                name2 = [name1,ext];
                            else
                                name2 = [dat_name,ext];
                            end
                            % remember settings
                            handles.math_sort = datasort;
                            handles.math_unique = dataunique;
                            handles.math_deleteempty = dataempty;

                            CDac_pwd
                            dlmwrite(name2, data, 'delimiter', ',', 'precision', 9);
                            d = dir; %get files
                            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                            refreshcolor;
                            cd(pre_dirML); % return to matlab view folder
                        end
                    end
                end
            end
        end
end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_sr2age_Callback(hObject, eventdata, handles)
% hObject    handle to menu_sr2age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
        [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            
            data = load(data_name);
            data = data(~any(isnan(data),2),:);
            data = sortrows(data);
            
            time = data(:,1);
            value = data(:,2);
            npts = length(time);
            agemodel = zeros(npts,2);
            agemodel(:,1) = time;
            for i = 2:npts
                agemodel(i,2) = 100*(time(i)-time(i-1))/value(i-1)+agemodel(i-1,2);
            end
            name1 = [dat_name,'-agemod',ext];  % New name
                CDac_pwd
            dlmwrite(name1, agemodel, 'delimiter', ',', 'precision', 9);
            d = dir; %get files
            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
            refreshcolor;
            cd(pre_dirML); % return to matlab view folder
        end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function munu_plot_stairs_Callback(hObject, eventdata, handles)
% hObject    handle to munu_plot_stairs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            end
        end
    else
        return
    end
end

if check == 1
        
        figure;
        hold on;
        for j = 1: nplot
            plot_no = plot_selected(j);
            plot_filter_s = char(contents(plot_no));
            GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
     try
        fid = fopen(plot_filter_s);
        data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
        fclose(fid);
        if iscell(data_ft)
            data = cell2mat(data_ft);
        end
    catch
        data = load(plot_filter_s);
    end 

            data = data(~any(isnan(data),2),:);
            stairs(data(:,1),data(:,2),'LineWidth',1,'Color','k');
        end
        set(gca,'XMinorTick','on','YMinorTick','on')
        if handles.unit_type == 0;
            xlabel(['Unit (',handles.unit,')'])
        elseif handles.unit_type == 1;
            xlabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
        end
        title(plot_filter_s, 'Interpreter', 'none')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function menu_plotplus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to menu_plotplus

% --------------------------------------------------------------------
function menu_plotplus_Callback(hObject, eventdata, handles)
% hObject    handle to menu_plotplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length

% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            elseif sum(strcmp(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})) > 0
                try 
                    hwarn = warndlg('Wait, large image? can be very slow ...');
                    im_name = imread(plot_filter_s);
                    hFig1 = figure;
                    lastwarn('') % Clear last warning message
                    imshow(im_name);
                    set(gcf,'Name',[dat_name,ext])
                    [warnMsg, warnId] = lastwarn;
                    if ~isempty(warnMsg)
                        close(hFig1)
                        imscrollpanel_ac(plot_filter_s);
                    end
                    try close(hwarn)
                    catch
                    end
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
            end
        end
    else
        return
    end
end
if check == 1
    GETac_pwd; 
    for i = 1: nplot
        plot_no = plot_selected(i);
        handles.plot_s{i} = fullfile(ac_pwd,char(contents(plot_no)));
    end
    handles.nplot = nplot;
    guidata(hObject, handles);
    PlotAdv(handles);
end


% --------------------------------------------------------------------
function menu_rho_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nsim_yes = 0;

choice = questdlg('Single run or Monte Carlo Simulation', ...
	'Select', 'Single','Monte Carlo','Cancel','Single');
% Handle response
switch choice
    case 'Single'
        nsim_yes = 0;
    case 'Monte Carlo'
        %disp([choice ' coming right up.'])
        nsim_yes = 1;
    case 'Cancel'
        nsim_yes = 2;
end
if nsim_yes < 2
    contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
    plot_selected = get(handles.listbox_acmain,'Value');
    nplot = length(plot_selected);   % length
if nplot > 1
    warndlg('Select 1 data only','Error');
end
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                data = load(data_name);
                samplerate = diff(data(:,1));
                ndata = length(data(:,1));
                datalength = data(length(data(:,1)),1)-data(1,1);
                %samp1 = min(samplerate);  % old version
                %samp2 = max(samplerate);  % old version
                samp95 = prctile(samplerate,95);  % new version; 1-2 * sample 95% percentile
                %sampmedian = median(samplerate);

                if nsim_yes == 0
                    
                    if .3 * datalength > 400
                        window1 = 400;
                    else
                        window1 = .3 * datalength;
                    end
                    
                    prompt = {'Window',...
                    'Sample rate (Default = 95% percentile)'};
                    dlg_title = 'Evolutionary RHO in AR(1)';
                    num_lines = 1;
                    defaultans = {num2str(window1),num2str(samp95)};
                    options.Resize='on';
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                    if ~isempty(answer)
                        window = str2double(answer{1});
                        interpolate_rate= str2double(answer{2});
                        [data_even] = interpolate(data,interpolate_rate);
                        [rhox] = erhoAR1(data_even,window);

                        figure; plot(rhox(:,1),rhox(:,2),'LineWidth',1)
                            if handles.unit_type == 0;
                                xlabel(['Unit (',handles.unit,')'])
                            elseif handles.unit_type == 1;
                                xlabel(['Depth (',handles.unit,')'])
                            else
                                xlabel(['Time (',handles.unit,')'])
                            end
                        set(gca,'XMinorTick','on','YMinorTick','on')
                        ylabel('RHO in AR(1)')
                        title(['Window = ',num2str(window),'. Sample rate = ',num2str(interpolate_rate)])

                        name1 = [dat_name,'-rho1.txt'];
                        CDac_pwd
                        if exist([pwd,handles.slash_v,name1])
                            for i = 1:100
                                name1 = [dat_name,'-rho1-',num2str(i),'.txt'];
                                if exist([pwd,handles.slash_v,name1])
                                else
                                     break
                                end
                            end
                        end
                        dlmwrite(name1, rhox, 'delimiter', ',', 'precision', 9); 
                        disp(['>>  Save rho1    : ',name1])   
                        cd(pre_dirML); % return to matlab view folder
                    end
                else
                    prompt = {'Monte Carlo simulations',...
                    'Window ranges from',...
                    'Window ranges to',...
                    'Sample rate from',...
                    'Sample rate to',...
                    'Plot: interpolation',...
                    'Plot: shift grids (Default = 15; no shift = 1)'};
                dlg_title = 'Monte Carlo Simulation of eRHO in AR(1)';
                num_lines = 1;
                if ndata > 1000;
                    interpn = 1000;
                else
                    interpn = ndata;
                end
                
                if .3 * datalength > 400
                    window1 = 400;
                    window2 = 500;
                else
                    window1 = .3 * datalength;
                    window2 = .4 * datalength;
                end
                
                defaultans = {'1000',num2str(window1),num2str(window2),...
                    num2str(samp95),num2str(2*samp95),num2str(interpn),'15'};
                options.Resize='on';
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                if ~isempty(answer)
                    nsim = str2double(answer{1});
                    window1 = str2double(answer{2});
                    window2 = str2double(answer{3});
                    samprate1 = str2double(answer{4});
                    samprate2 = str2double(answer{5});
                    nout = str2double(answer{6});
                    shiftwin = str2double(answer{7});

                    % Waitbar
                    hwaitbar = waitbar(0,'Noise estimation - rho1: Monte Carlo processing ...',...    
                       'WindowStyle','modal');
                    hwaitbar_find = findobj(hwaitbar,'Type','Patch');
                    set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
                    steps = 100;
                    % step estimation for waitbar
                    nmc_n = round(nsim/steps);
                    waitbarstep = 1;
                    waitbar(waitbarstep / steps)
                    %
                  if nsim >= 50
                    samplez = samprate1+(samprate2-samprate1)*rand(1,nsim);
                    window_sim = window1 + (window2-window1) * rand(1,nsim);
                    y_grid = linspace(data(1,1),data(length(data(:,1)),1),nout);
                    y_grid = y_grid';
                    powy = zeros(nout,nsim);
                    if shiftwin > 1
                        for i=1:nsim
                            window = window_sim(i);
                            interpolate_rate= samplez(i);
                            [data_even] = interpolate(data,interpolate_rate);
                            [rhox] = erhoAR1(data_even,window);
                            y_grid_rand = -1*window/2 + window * rand(1);
                            % interpolation
                            powy(:,i)=interp1((rhox(:,1)+y_grid_rand),rhox(:,2),y_grid);
                            disp(['Simulation step = ',num2str(i),' / ',num2str(nsim)]);
                            
                            if rem(i,nmc_n) == 0
                                waitbarstep = waitbarstep+1; 
                                if waitbarstep > steps; waitbarstep = steps; end
                                pause(0.001);%
                                waitbar(waitbarstep / steps)
                            end
                        end
                    elseif shiftwin == 1
                        for i=1:nsim
                            window = window_sim(i);
                            interpolate_rate= samplez(i);
                            [data_even] = interpolate(data,interpolate_rate);
                            [rhox] = erhoAR1(data_even,window);
                            % interpolation
                            powy(:,i)=interp1(rhox(:,1),rhox(:,2),y_grid);
                            disp(['Simulation step = ',num2str(i),' / ',num2str(nsim)]);
                            if rem(i,nmc_n) == 0
                                waitbarstep = waitbarstep+1; 
                                if waitbarstep > steps; waitbarstep = steps; end
                                pause(0.001);%
                                waitbar(waitbarstep / steps)
                            end
                        end
                    end  
                    
                    if ishandle(hwaitbar); 
                        close(hwaitbar);
                    end
                    
                    percent =[2.5,5,10,15.865,25,50,75,84.135,90,95,97.5];
                    npercent  = length(percent);
                    npercent2 = (length(percent)-1)/2;
                    powyp = prctile(powy, percent,2);

                    for i = 1: npercent
                        powyadjustp1=powyp(:,i);
                        powyad_p_nan(:,i) = powyadjustp1(~isnan(powyadjustp1));
                    end
                    y_grid_nan = y_grid(~isnan(powyp(:,1)));

                    figure;hold all
                    colorcode = [221/255,234/255,224/255; ...
                    201/255,227/255,209/255; ...
                    176/255,219/255,188/255;...
                    126/255,201/255,146/255;...
                    67/255,180/255,100/255];
                    for i = 1:npercent2
                        fill([y_grid_nan; (fliplr(y_grid_nan'))'],[powyad_p_nan(:,npercent+1-i);...
                        (fliplr(powyad_p_nan(:,i)'))'],colorcode(i,:),'LineStyle','none');
                    end
                    plot(y_grid,powyp(:,npercent2+1),'Color',[0,120/255,0],'LineWidth',1.5,'LineStyle','--')
                    hold off
                    if handles.unit_type == 0;
                        xlabel(['Unit (',handles.unit,')'])
                    elseif handles.unit_type == 1;
                        xlabel(['Depth (',handles.unit,')'])
                    else
                        xlabel(['Time (',handles.unit,')'])
                    end
                    set(gca,'XMinorTick','on','YMinorTick','on')
                    ylabel('RHO in AR(1)')
                    legend('2.5% - 97.5%', '5% - 95%', '10% - 90%','15.87% - 84.14%', '25% - 75%', 'Median')
                    title(['Window: ',num2str(window1),'_',num2str(window2),...
                        '. Sample rate: ',num2str(samprate1),'_',num2str(samprate2)])

                    name1 = [dat_name,'-rho1-median.txt'];
                    data1 = [y_grid_nan,powyad_p_nan(:,npercent2+1)];
                    name2 = [dat_name,'-rho1-percentile.txt'];
                    data2 = [y_grid_nan,powyad_p_nan];
                    CDac_pwd
                    if exist([pwd,handles.slash_v,name1]) || exist([pwd,handles.slash_v,name2])
                        for i = 1:100
                            name1 = [dat_name,'-rho1-median-',num2str(i),'.txt'];
                            name1 = [dat_name,'-rho1-percentile-',num2str(i),'.txt'];
                            if exist([pwd,handles.slash_v,name1]) || exist([pwd,handles.slash_v,name2])
                            else
                                 break
                            end
                        end
                    end
                    dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9); 
                    dlmwrite(name2, data2, 'delimiter', ',', 'precision', 9); 
                    disp(['>>  Save rho1 median    : ',name1])   
                    disp(['>>  Save rho1 percentile: ',name2])  
                    
                    d = dir; %get files
                    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                    refreshcolor;
                    cd(pre_dirML);
                else
                    errordlg('Number simulations is too few, try 1000','Error');
                end
                end
                end
            end
        end
end
guidata(hObject, handles);
end

% --------------------------------------------------------------------
function menu_folder_Callback(hObject, eventdata, handles)
% hObject    handle to menu_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Type name of the folder'};
dlg_title = 'Create a Folder in the working directory';
num_lines = 1;
defaultans = {'newfolder'};
options.Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
if ~isempty(answer)
    foldername = (answer{1});
    
    CDac_pwd;   
    mkdir([ac_pwd,handles.slash_v,foldername]);
    if ~isdeployed
        % add path for MatLab version
        addpath(genpath([ac_pwd,handles.slash_v,foldername]));
    end  
    cd(ac_pwd);
    refreshcolor;
    cd(pre_dirML);
end


% --------------------------------------------------------------------
function menu_email_Callback(hObject, eventdata, handles)
% hObject    handle to menu_email (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
email


% --------------------------------------------------------------------
function menu_samplerate_Callback(hObject, eventdata, handles)
% hObject    handle to menu_samplerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,dat_name,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            end
        end
    else
        return
    end
end

if check == 1;
    for i = 1:nplot
        plot_no = plot_selected(i);
            plot_filter_s = char(contents(plot_no));
            GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
            
     try
        fid = fopen(plot_filter_s);
        data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
        fclose(fid);
        if iscell(data_ft)
            data_filterout = cell2mat(data_ft);
        end
    catch
        data_filterout = load(plot_filter_s);
    end 
            
            t = data_filterout(:,1);
            dt = diff(t);
            len_t = length(t);
            figure;
            datasamp = [t(1:len_t-1),dt];
            datasamp = datasamp(~any(isnan(datasamp),2),:);
            stairs(datasamp(:,1),datasamp(:,2),'LineWidth',1,'Color','k');
            set(gca,'XMinorTick','on','YMinorTick','on')
            set(gcf,'Color', 'white')
            set(0,'Units','normalized') % set units as normalized
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.1,0.4,0.45,0.45]) % set position
            set(gcf,'Name', 'Sampling rate (original domain)')
            if handles.unit_type == 0;
                xlabel(['Unit (',handles.unit,')'])
                ylabel('Unit')
            elseif handles.unit_type == 1;
                xlabel(['Depth (',handles.unit,')'])
                ylabel(handles.unit)
            else
                xlabel(['Time (',handles.unit,')'])
                ylabel(handles.unit)
            end
            
            title([[dat_name,ext],': sampling rate'], 'Interpreter', 'none')
            xlim([min(datasamp(:,1)),max(datasamp(:,1))])
            ylim([0.9*min(dt) max(dt)*1.1])
            
            figure;
            histfit(dt,[],'kernel')
            set(gcf,'Color', 'white')
            set(0,'Units','normalized') % set units as normalized
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.55,0.4,0.45,0.45]) % set position
            title([[dat_name,ext],': kernel fit of sampling rates'], 'Interpreter', 'none')
            set(gcf,'Name', 'Sampling rate: distribution')
            if handles.unit_type == 0;
                xlabel(['Sampling rate (',handles.unit,')'])
            elseif handles.unit_type == 1;
                xlabel(['Sampling rate (',handles.unit,')'])
            else
                xlabel(['Sampling rate (',handles.unit,')'])
            end
            ylabel('Number')
            note = ['max: ',num2str(max(dt)),'; mean: ',num2str(mean(dt)),...
                '; median: ',num2str(median(dt)),'; min: ',num2str(min(dt)),...
                '; variance: ',num2str(var(dt))];
            legend(note)
            %text(mean(dt),len_t/10,note);
    end
end
guidata(hObject,handles)

% --------------------------------------------------------------------
function menu_datadistri_Callback(hObject, eventdata, handles)
% hObject    handle to menu_datadistri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,dat_name,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            end
        end
    else
        return
    end
end

if check == 1;
    for i = 1:nplot
        plot_no = plot_selected(i);
            plot_filter_s = char(contents(plot_no));
            GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
    try
        fid = fopen(plot_filter_s);
        data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
        fclose(fid);
        if iscell(data_ft)
            data_filterout = cell2mat(data_ft);
        end
    catch
        data_filterout = load(plot_filter_s);
    end 

            datax = data_filterout(:,2);
            figure;
            histfit(datax,[],'kernel')
            set(gcf,'Name', 'Data Distribution')
            title([[dat_name,ext],': kernel fit of the data'], 'Interpreter', 'none')
            xlabel('Data')
            note = ['max: ',num2str(max(datax)),'; mean: ',num2str(mean(datax)),...
                '; median: ',num2str(median(datax)),'; min: ',num2str(min(datax)),...
                '; variance: ',num2str(var(datax))];
            legend(note)
    end
end
guidata(hObject,handles)


% --------------------------------------------------------------------
function menu_pda_Callback(hObject, eventdata, handles)
% hObject    handle to menu_pda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            else
                errordlg('Error: Selected file must be a supported type (*.txt,*.csv).');
            end
        end
    else
        return
    end
end

if check == 1;
    prompt = {'Paired frequency bands (space delimited):',...
        'Window (kyr):',...
        'Time-bandwidth product, nw:',...
        'Lower cutoff frequency (>= 0)',...
        'Upper cutoff frequency (<= nyquist)',...
        'Step of calculations:',...
        'Zero-padding number:',...
        'Save Results (1 = Yes; 0 = No):',...
        'Padding Depth: 0=No, 1=zero, 2=mirror; 3=mean; 4=random'};
    dlg_title = 'Power Decomposition analysis';
    num_lines = 1;
    defaultans = {'1/45 1/25','500','2',num2str(handles.f1),num2str(handles.f2),'1','5000','0','0'};
    options.Resize='on';
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
    if ~isempty(answer)
        f3 = str2num(answer{1});
        window = str2double(answer{2});
        nw = str2double(answer{3});
        ftmin = str2double(answer{4});
        fterm = str2double(answer{5});
        step = str2double(answer{6});
        pad = str2double(answer{7});
        savedata = str2double(answer{8});
        padtype = str2double(answer{9});
        for i = 1:nplot
            
            figure;
            plot_no = plot_selected(i);
            plot_filter_s = char(contents(plot_no));
            plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
            GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
            [~,dat_name,ext] = fileparts(plot_filter_s);
            data = load(plot_filter_s);
            
            data = data(~any(isnan(data),2),:);
            diffx = diff(data(:,1));
            if any(diffx(:) < 0)
                 warndlg('Warning: data not sorted. Now sorting ... ')
                 disp('>>  ==========        sorting')
                 data = sortrows(data); % sort data
            end
            if any(diffx(:) == 0)
                warndlg('Warning: duplicated numbers are replaced with the mean')
                data=findduplicate(data); % find duplicate
            end
            if max(diffx)-min(diffx) <= eps(5)
                warndlg('Warning: Data may not be evenly spaced. Interpolation using median sampling rate')
                data = interpolate(data,median(diffx));
            end
            if padtype > 0
                data = zeropad2(data,window,padtype);
            end
            
            disp1 = ['Data: ',plot_filter_s, 'Window = ',num2str(window),' kyr; NW =',num2str(nw)];
            disp2 = ['    cutoff freqency:',num2str(ftmin),'_',num2str(fterm),'; Step =',num2str(step),'; Pad = ',num2str(pad)];
            disp3 = ['    pairs of frequency bands:'];
            disp(disp1)
            disp(disp2)
            disp(disp3)
            disp(f3)
            disp('Wait ... ...')
            [pow]=pdan(data,f3,window,nw,ftmin,fterm,step,pad);
            plot(pow(:,1),pow(:,2),'k','LineWidth',1);
            set(gca,'XMinorTick','on','YMinorTick','on')
            xlabel('Time (kyr)')
            ylabel('Power ratio')
            title(plot_filter_s, 'Interpreter', 'none')
            if savedata == 1
                name1 = [dat_name,'-win',num2str(window),'-pda',ext];
                CDac_pwd  % cd ac_pwd dir
                dlmwrite(name1, pow, 'delimiter', ',', 'precision', 9); 
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
            end
            
        end
        disp('Done')
    end
end
%end
guidata(hObject,handles)


% --------------------------------------------------------------------
function menu_desection_Callback(hObject, eventdata, handles)
% hObject    handle to menu_desection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                
                dat = load(data_name);
                dat = sortrows(dat);
                xmin = dat(1);
                xmax = dat(length(dat(:,1)));
                
                prompt = {'Start and End point(s) of section(s):'};
                    dlg_title = 'Remove Section(s)';
                    num_lines = 1;
                    defaultans = {''};
                    options.Resize='on';
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                    if ~isempty(answer)
                        answer = answer{1};
                        answer1 = textscan(answer,'%f','Delimiter',{';','*',',','\t','\b',' '},'Delimiter',',');
                        sec = answer1{1};
                        n_sec = length(sec);
                        if mod(n_sec,2) == 1
                            errordlg('Error: must be 2x points')
                        else
                            
                            [data0] = select_interval(dat,xmin,sec(1));
                            data_mer = data0;
                            d_accum = 0;
                            for i = 1: n_sec/2
                                d = sec(2*i) - sec(2*i-1);
                                d_accum = d + d_accum;
                                if i == n_sec/2
                                    [data1] = select_interval(dat,sec(2*i),xmax);
                                    data1(:,1) = data1(:,1) - d_accum;
                                    data_mer = [data_mer;data1];
                                else
                                    [data2] = select_interval(dat,sec(2*i),sec(2*i+1));
                                    data2(:,1) = data2(:,1) - d_accum;
                                    data_mer = [data_mer;data2];
                                end    
                            end
                            name1 = [dat_name,'-desec',ext];
                            disp(['>> Removed sections are ',answer])
                            CDac_pwd  % cd ac_pwd dir
                            dlmwrite(name1, data_mer, 'delimiter', ',', 'precision', 9); 
                            refreshcolor;
                            cd(pre_dirML); % return to matlab view folder
                        end
                    end
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_gap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_gap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                
                dat = load(data_name);
                dat = sortrows(dat);
                xmin = dat(1);
                xmax = dat(length(dat(:,1)));
                
                prompt = {'Location and duration of the gap(s): (comma-separated)'};
                    dlg_title = 'Add Gap(s)';
                    num_lines = 1;
                    defaultans = {''};
                    options.Resize='on';
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                    if ~isempty(answer)
                        answer = answer{1};
                        answer1 = textscan(answer,'%f','Delimiter',{';','*',',','\t','\b',' '},'Delimiter',',');
                        sec = answer1{1};
                        n_sec = length(sec);
                        if mod(n_sec,2) == 1
                            errordlg('Error: 1 location must have 1 duration')
                        else
                            [data0] = select_interval(dat,xmin,sec(1));
                            data_mer = data0;
                            d_accum = 0;
                            for i = 1: n_sec/2
                                d = sec(2*i);
                                d_accum = d + d_accum;
                                if i == n_sec/2
                                    [data1] = select_interval(dat,sec(2*i-1),xmax);
                                    data1(:,1) = data1(:,1) + d_accum;
                                    data_mer = [data_mer;data1];
                                else
                                    [data2] = select_interval(dat,sec(2*i-1),sec(2*i+1));
                                    data2(:,1) = data2(:,1) + d_accum;
                                    data_mer = [data_mer;data2];
                                end    
                            end
                            name1 = [dat_name,'-wgap',ext];
                            disp(['>> Gap location and duration are ',answer])
                            CDac_pwd  % cd ac_pwd dir
                            dlmwrite(name1, data_mer, 'delimiter', ',', 'precision', 9); 
                            refreshcolor;
                            cd(pre_dirML); % return to matlab view folder
                        end
                    end
            end
        end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function menu_insol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to menu_copy
% --------------------------------------------------------------------
function menu_insol_Callback(hObject, eventdata, handles)
% hObject    handle to menu_insol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
Insolation(handles);


% --------------------------------------------------------------------
function Official_Callback(hObject, eventdata, handles)
% hObject    handle to Official (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function github_Callback(hObject, eventdata, handles)
% hObject    handle to github (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function menu_newtxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to menu_copy

% --------------------------------------------------------------------
function menu_newtxt_Callback(hObject, eventdata, handles)
% hObject    handle to menu_newtxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Name of the new text file'};
dlg_title = 'New text file';
num_lines = 1;
defaultans = {'untitled.txt'};
options.Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
if ~isempty(answer)
    
    CDac_pwd;
    filename = answer{1};
    if length(filename) < 4
        filename = [filename,'.txt'];
    else
        if strcmp(filename(end-3:end),'.txt')
        else
            filename = [filename,'.txt'];
        end
    end
    
    if exist([ac_pwd,handles.slash_v,filename])
        warndlg('File name exists. An alternative name used','File Name Warning')
        
        for i = 1:100
            filename = [filename(1:end-4),'_',num2str(i),'.txt'];
            if exist([ac_pwd,handles.slash_v,filename])
            else
                break
            end
        end
    end
    
    disp(['>>  Create a new data file entitled: ',filename])
    fid = fopen([ac_pwd,handles.slash_v,filename], 'wt' );
    fclose(fid);
    cd(ac_pwd);
    refreshcolor;
    cd(pre_dirML);
end


% --------------------------------------------------------------------
function menu_open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.fig','Files (*.fig)'},...
    'Open *.fig file');
if filename == 0
else
    aaa = [pathname,filename];
    openfig(aaa)
end

% --- Executes during object creation, after setting all properties.
function menu_refreshlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_refresh
% --- Executes on mouse press over axes background.
function menu_refreshlist_Callback(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir

% --- Executes during object creation, after setting all properties.
function menu_opendir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function menu_opendir_Callback(hObject, eventdata, handles)
% hObject    handle to menu_opendir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CDac_pwd; % cd working dir
if ismac
    system(['open ',ac_pwd]);
elseif ispc
    winopen(ac_pwd);
end
cd(pre_dirML); % return view dir


% removed?????

% --- Executes on mouse press over axes background.
function axes_plot_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);

contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length

% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            elseif sum(strcmp(ext,{'.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.TIF'})) > 0
                try 
                    im_name = imread(plot_filter_s);
                    figure;
                    imshow(im_name)
                    set(gcf,'Name',[dat_name,ext])
                catch
                end
            end
        end
    else
        return
    end
end

if check == 1
    for i = 1: nplot
        plot_no = plot_selected(i);
        handles.plot_s{i} = fullfile(ac_pwd,char(contents(plot_no)));
    end
    handles.nplot = nplot;
    guidata(hObject, handles);
    PlotAdv(handles);
end


% --------------------------------------------------------------------
function menu_extract_Callback(hObject, eventdata, handles)
% hObject    handle to menu_extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            else
                errordlg('Error: unsupported file type')
            end
        end
    else
        return
    end
end

if check == 1;
    for i = 1:nplot
        plot_no = plot_selected(i);
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        [~,dat_name,ext] = fileparts(plot_filter_s);
        
        prompt = {'new 1st column = old column #',...
            'new 2nd column = old column #'};
        dlg_title = 'Extract data';
        num_lines = 1;
        defaultans = {'1','2'};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
        if ~isempty(answer)
            c1 = str2double(answer{1});
            c2 = str2double(answer{2});
            c0 = c2;
            if or(c1> c0, c2> c0)
                errordlg('Error: column is too large')
            elseif or(c1<1, c2<1)
                errordlg('Error: column is no less than 1')
            else
                try
                    data = load(plot_filter_s);
                catch       
                    fid = fopen(plot_filter_s);
                    data_ft = textscan(fid,'%f',c0,'Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                    %size(data_ft)
                    fclose(fid);
                    if iscell(data_ft)
                        data = cell2mat(data_ft);
                    end
                end
                [~, ncol] = size(data);

                data = data(~any(isnan(data),2),:);

                data_new(:,1) = data(:,c1);
                data_new(:,2) = data(:,c2);
                CDac_pwd  % cd ac_pwd dir
                % save data
                name1 = [dat_name,'-c',num2str(c1),'-c',num2str(c2),ext];  % New name
                dlmwrite(name1, data_new, 'delimiter', ',', 'precision', 9);
                disp(['Extract data from columns ',num2str(c1),' & ',num2str(c2),' : ',dat_name,ext])
                d = dir; %get files
                set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                refreshcolor;
                cd(pre_dirML); % return to matlab view folder
            end
        end
    end
end

guidata(hObject,handles)


% --------------------------------------------------------------------
function menu_pca_Callback(hObject, eventdata, handles)
% hObject    handle to menu_pca (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = handles.index_selected;  % read selection in listbox 1
nplot = length(plot_selected);   % length
% check
for i = 1:nplot
    plot_no = plot_selected(i);
    if plot_no > 2
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
        GETac_pwd; plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        if isdir(plot_filter_s)
            return
        else
            [~,~,ext] = fileparts(plot_filter_s);
            check = 0;
            if sum(strcmp(ext,handles.filetype)) > 0
                check = 1; % selection can be executed 
            end
        end
    else
        return
    end
end

if check == 1;
    data_new = [];
    nrow = [];
    data_pca = [];
    disp('>>  Principal component analysis of ')
    for i = 1:nplot
        plot_no = plot_selected(i);
        plot_filter_s = char(contents(plot_no));
        plot_filter_s = fullfile(ac_pwd,plot_filter_s);
        % read data
        try
            data_filterout = load(plot_filter_s);
        catch       
            fid = fopen(plot_filter_s);
            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
            fclose(fid);
            if iscell(data_ft)
                data_filterout = cell2mat(data_ft);
            end
        end
        data_filterout = data_filterout(~any(isnan(data_filterout),2),:); %remove empty
        
        if nplot == 1
            data_new = data_filterout;
        else
            if i == 1
                data_new(:,i) = data_filterout(:,2);
                data_pca = data_filterout(:,1);
                disp(['>>   ',plot_filter_s]);
            else
                [nrow(i-1),~] = size(data_new);
                if nrow(i-1) ~= length(data_filterout(:,2))
                    errordlg('Error: number of rows of series must be the same')
                else
                    data_new(:,i) = data_filterout(:,2);
                    data_pca = data_filterout(:,1);
                    disp(['>>   ',plot_filter_s]);
                end
            end
        end
    end
    disp('>>  Principal component analysis: Done')
    % pca
    [coeff, pc] = pca(data_new); 
    [~,dat_name,ext] = fileparts(char(contents(plot_selected(1))));% first file name
    if nplot == 1
        name1 = [dat_name,'-PCA',ext];
        name2 = [dat_name,'-PCA-coeff',ext];
    else
        name1 = [dat_name,'-w-others-PCA',ext];  % New name
        name2 = [dat_name,'-w-others-PCA-coeff',ext];
    end

    CDac_pwd; % cd ac_pwd dir
    dlmwrite(name1, [data_pca,pc], 'delimiter', ',', 'precision', 9);
    dlmwrite(name2, coeff, 'delimiter', ',', 'precision', 9);
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    refreshcolor;
    cd(pre_dirML); % return to matlab view folder
end
guidata(hObject,handles)



% --------------------------------------------------------------------
function menu_smooth1_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_utilities_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_image_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_menu_utilities_Callback(hObject, eventdata, handles)
% hObject    handle to menu_utilities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_whiten_Callback(hObject, eventdata, handles)
% hObject    handle to menu_utilities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                handles.dat_name = dat_name;
                guidata(hObject, handles);
                prewhitenGUI(handles);
            end
        end
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function menu_sednoise_Callback(hObject, eventdata, handles)
% hObject    handle to menu_utilities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_timeOpt_Callback(hObject, eventdata, handles)
% hObject    handle to menu_timeOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                handles.dat_name = dat_name;
                guidata(hObject, handles);
                timeOptGUI(handles);
                h=warndlg(['(e)TimeOpt may have advanced version in astrochron. ',...
                'Visit https://cran.r-project.org/package=astrochron',' for more infomation'],...
                '(e)TimeOpt');
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_movmedian_Callback(hObject, eventdata, handles)
% hObject    handle to menu_movmedian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
        try
            fid = fopen(data_name);
            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', NaN);
            fclose(fid);
            if iscell(data_ft)
                data = cell2mat(data_ft);
            end
        catch
            data = load(data_name);
        end 

            time = data(:,1);
            value = data(:,2);
            npts = length(time);
            dlg_title = 'Moving Median';
            prompt = {'Moving median window: (0.2 = 20%)'};
            num_lines = 1;
            defaultans = {'0.2'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                smooth_v = str2double(answer{1});
                % median-smoothing data numbers
                smoothn = round(smooth_v * npts);
                % median-smoothing
                try data(:,2) = moveMedian(data(:,2),smoothn);
                    name1 = [dat_name,'_',num2str(smooth_v*100),'%-median',ext];  % New name
                    CDac_pwd
                    dlmwrite(name1, data, 'delimiter', ',', 'precision', 9); 
                    d = dir; %get files
                    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                    refreshcolor;
                    cd(pre_dirML); % return to matlab view folder
                    mvmedianfig = figure;
                    plot(time,value,'k')
                    hold on;
                    plot(time,data(:,2),'r','LineWidth',2.5)
                    title([dat_name,ext], 'Interpreter', 'none')
                    xlabel(handles.unit)
                    ylabel('Value')
                    legend('Raw',[num2str(smooth_v*100),'%-median smoothed'])
                    hold off;
                catch
                    msgbox('Data error, empty value?','Error')
                end
            end
        end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_examples_Callback(hObject, eventdata, handles)
% hObject    handle to menu_examples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_example_PETM_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_PETM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-SvalbardPETM-logFe.txt');

[~,dat_name,ext] = fileparts(data_name);
data = load(data_name);
time = data(:,1);
value = data(:,2);
figure;
plot(time,value)
title([dat_name,ext], 'Interpreter', 'none')
xlabel('Depth (m)')
ylabel('Log(Fe)')
CDac_pwd
copyfile(data_name,pwd);
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder


% --------------------------------------------------------------------
function menu_example_GD2GR_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_GD2GR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-Guandao2AnisianGR.txt');

[~,dat_name,ext] = fileparts(data_name);
data = load(data_name);

time = data(:,1);
value = data(:,2);
figure;
plot(time,value)
title([dat_name,ext], 'Interpreter', 'none')
xlabel('Depth (m)')
ylabel('Gamma ray (cpm)')
CDac_pwd
copyfile(data_name,pwd);
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder


% --------------------------------------------------------------------
function menu_example_inso2Ma_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_inso2Ma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-Insol-t-0-2000ka-day-80-lat-65-meandaily-La04.txt');

[~,dat_name,ext] = fileparts(data_name);
data = load(data_name);

time = data(:,1);
value = data(:,2);
figure;
plot(time,value)
title([dat_name,ext], 'Interpreter', 'none')
xlabel('Time (kyr)')
ylabel('Insolation (W/m^{2})')
CDac_pwd
copyfile(data_name,pwd);
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder


% --------------------------------------------------------------------
function menu_example_la04etp_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_la04etp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-La2004-1E.5T-1P-0-2000.txt');

[~,dat_name,ext] = fileparts(data_name);
data = load(data_name);
time = data(:,1);
value = data(:,2);
figure;
plot(time,value)
title([dat_name,ext], 'Interpreter', 'none')
xlabel('Age (ka)')
ylabel('ETP')
CDac_pwd
copyfile(data_name,pwd);
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder

% --------------------------------------------------------------------
function menu_example_redp7_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_redp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-Rednoise0.7-2000.txt');

[~,dat_name,ext] = fileparts(data_name);
data = load(data_name);

time = data(:,1);
value = data(:,2);
figure;
plot(time,value)
title([dat_name,ext], 'Interpreter', 'none')
xlabel('Number (#)')
ylabel('Value')
CDac_pwd
copyfile(data_name,pwd);
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder

% --------------------------------------------------------------------
function menu_example_wayao_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_wayao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-WayaoCarnianGR0.txt');

[~,dat_name,ext] = fileparts(data_name);
data = load(data_name);

time = data(:,1);
value = data(:,2);
figure;
plot(time,value)
title([dat_name,ext], 'Interpreter', 'none')
xlabel('Depth (m)')
ylabel('Gamma ray (cpm)')
CDac_pwd
copyfile(data_name,pwd);
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder


% --------------------------------------------------------------------
function menu_example_Newark_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_Newark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-LateTriassicNewarkDepthRank.txt');

[~,dat_name,ext] = fileparts(data_name);
data = load(data_name);

time = data(:,1);
value = data(:,2);
figure;
plot(time,value)
title([dat_name,ext], 'Interpreter', 'none')
xlabel('Depth (m)')
ylabel('Depth Rank')
CDac_pwd
copyfile(data_name,pwd);
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder


% --------------------------------------------------------------------
function menu_example_marsimage_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_marsimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-HiRISE-PSP_002733_1880_RED.jpg');
[loc,dat_name,ext] = fileparts(data_name);
if sum(strcmp(ext,{'.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.TIF'})) > 0
    im_name = imread(data_name);
    figure;
    imshow(im_name)
    set(gcf,'Name',[dat_name,ext])
end

CDac_pwd
copyfile(data_name,pwd)
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder

% --------------------------------------------------------------------
function menu_example_hawaiiCO2_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_hawaiiCO2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-LaunaLoa-Hawaii-CO2-monthly-mean.txt');

% url = 'https://www.esrl.noaa.gov/gmd/ccgg/trends/data.html'
% Dr. Pieter Tans, NOAA/ESRL (www.esrl.noaa.gov/gmd/ccgg/trends/) and 
% Dr. Ralph Keeling, Scripps Institution of Oceanography (scrippsco2.ucsd.edu/).

[~,dat_name,ext] = fileparts(data_name);
data = load(data_name);

time = data(:,1);
value = data(:,2);
figure;
plot(time,value)
title([dat_name,ext], 'Interpreter', 'none')
xlabel('Year')
ylabel('pCO_2 (ppm)')

CDac_pwd
copyfile(data_name,pwd);
disp(['>> Data saved: ',[dat_name,ext]])
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder


% --------------------------------------------------------------------
function menu_digitizer_Callback(hObject, eventdata, handles)
% hObject    handle to menu_digitizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
            
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,{'.bmp','.BMP','.gif','.GIF','.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.tiff','.TIF','.TIFF'})) > 0
                try
                    handles.figname = data_name;
                    guidata(hObject, handles);
                    DataExtractML(handles);
                catch
                    warndlg('Image color space not supported. Convert to RGB or Grayscale')
                end
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_example_plotdigitizer_Callback(hObject, eventdata, handles)
% hObject    handle to menu_example_plotdigitizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_name = which('Example-PlotDigitizer.jpg');
[loc,dat_name,ext] = fileparts(data_name);
if sum(strcmp(ext,{'.jpg','.jpeg','.JPG','.JPEG','.png','.PNG','.tif','.TIF'})) > 0
    im_name = imread(data_name);
    figure;
    imshow(im_name)
    set(gcf,'Name',[dat_name,ext])
end

CDac_pwd
copyfile(data_name,pwd)
d = dir; %get files
set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
refreshcolor;
cd(pre_dirML); % return to matlab view folder


% --------------------------------------------------------------------
function menu_eTimeOpt_Callback(hObject, eventdata, handles)
% hObject    handle to menu_eTimeOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                handles.dat_name = dat_name;
                guidata(hObject, handles);
                eTimeOptGUI(handles);
                h=warndlg(['(e)TimeOpt may have advanced version in astrochron. ',...
                'Visit https://cran.r-project.org/package=astrochron',' for more infomation'],...
                '(e)TimeOpt');
            end
        end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function linegenerator_Callback(hObject, eventdata, handles)
% hObject    handle to linegenerator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
    if isdir(data_name) == 1
        handles.current_data = [];
        guidata(hObject, handles);
        linegenerator(handles);
    else
        [~,~,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0

            current_data = load(data_name);
            handles.current_data = current_data;
            handles.data_name = data_name;
            guidata(hObject, handles);

            linegenerator(handles);
        end
    end        
else
    handles.current_data = [];
    guidata(hObject, handles);
    linegenerator(handles);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_specmoments_Callback(hObject, eventdata, handles)
% hObject    handle to menu_specmoments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%#function bsxfun
contents = cellstr(get(handles.listbox_acmain,'String')); % read contents of listbox 1 
plot_selected = get(handles.listbox_acmain,'Value');
nplot = length(plot_selected);   % length
if and ((min(plot_selected) > 2), (nplot == 1))
    data_name = char(contents(plot_selected));
    data_name = strrep2(data_name, '<HTML><FONT color="blue">', '</FONT></HTML>');
    GETac_pwd; data_name = fullfile(ac_pwd,data_name);
        if isdir(data_name) == 1
        else
            [~,dat_name,ext] = fileparts(data_name);
            if sum(strcmp(ext,handles.filetype)) > 0
                
                current_data = load(data_name);
                handles.current_data = current_data;
                handles.data_name = data_name;
                handles.dat_name = dat_name;
                guidata(hObject, handles);
                SpectralMomentsGUI(handles);
            end
        end
end
guidata(hObject, handles);



% --------------------------------------------------------------------
function menu_interpseries_Callback(hObject, eventdata, handles)
% hObject    handle to menu_interpseries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
InterplationSeries(handles)


% --------------------------------------------------------------------
function menu_LOD_Callback(hObject, eventdata, handles)
% hObject    handle to menu_LOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LODGUI(handles)


% --------------------------------------------------------------------
function menu_coh_Callback(hObject, eventdata, handles)
% hObject    handle to menu_coh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
coherenceGUI(handles)
