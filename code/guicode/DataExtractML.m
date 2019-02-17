function varargout = DataExtractML(varargin)
% DATAEXTRACTML MATLAB code for DataExtractML.fig
%      DATAEXTRACTML, by itself, creates a new DATAEXTRACTML or raises the existing
%      singleton*.
%
%      H = DATAEXTRACTML returns the handle to a new DATAEXTRACTML or the handle to
%      the existing singleton*.
%
%      DATAEXTRACTML('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAEXTRACTML.M with the given input arguments.
%
%      DATAEXTRACTML('Property','Value',...) creates a new DATAEXTRACTML or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataExtractML_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataExtractML_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataExtractML

% Last Modified by GUIDE v2.5 04-Feb-2019 00:05:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataExtractML_OpeningFcn, ...
                   'gui_OutputFcn',  @DataExtractML_OutputFcn, ...
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


% --- Executes just before DataExtractML is made visible.
function DataExtractML_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataExtractML (see VARARGIN)

% Choose default command line output for DataExtractML
handles.output = hObject;
handles.DataExtractMain = gcf;
set(handles.DataExtractMain,'position',[0,0.95,0.5,0.11]) % set position

handles.x00 = 0;
handles.x01 = 1;
handles.x02 = 2; % 1 = linear; 0 = log
handles.x03 = 3;

handles.y00 = 0;
handles.y01 = 1;
handles.y02 = 0; % 1 = linear; 0 = log
handles.y03 = 1;
handles.i = 1;
handles.srsh = 10;

handles.tableData = cell(0);
handles.tableDatai = cell(0);
handles.recalibrate = 0;
handles.YYY0 = [];
handles.YYY1 = [];

handles.figname = varargin{1}.figname;
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;

%handles.figname = 'testData.jpg';
handles.DataExtractFig = figure;
imshow(handles.figname);
set(handles.DataExtractFig,'units','norm') % set location
set(handles.DataExtractFig,'position',[0.0,0.0,0.8,0.75]) % set position

set(handles.text5, 'string', 'Input the values in EditBoxs. Click Calibrate axis to set axis!');

guidata(hObject, handles);

% UIWAIT makes DataExtractML wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataExtractML_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in push_calibrate.
function push_calibrate_Callback(hObject, eventdata, handles)
% hObject    handle to push_calibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.recalibrate == 1
    choice = questdlg('You are going to Clear all points', ...
	'Warning', 'Yes','No','No');
    % Handle response
    switch choice
        case 'No'
            recalibratePoint = 0;
            return
        case 'Yes'
            recalibratePoint = 1;
    end
    if recalibratePoint == 1
        try figure(handles.DataExtractFig)
        catch
            handles.DataExtractFig = figure;
            imshow(handles.figname);
        end
        close(gcf);
        handles.DataExtractFig = figure;
        imshow(handles.figname);
        set(gcf,'units','norm') % set location
        set(gcf,'position',[0.0,0.0,0.8,0.75]) % set position
        set(handles.text5, 'string', 'Input the values in EditBoxs. Click Calibrate axis to set axis!');
        set(handles.push_calibrate, 'string', 'Calibrate axis');
        handles.recalibrate = 0;
        handles.tableData = cell(0);
        handles.i = 1;
        try
            close(DataExtractTab)
        catch
        end
    end
end
    % #1
    set(handles.text5, 'string', 'Locate the X-Axis Start point !!!');
    figure(handles.DataExtractFig);
    try
        set(handles.DataExtractFig,'WindowButtonMotionFcn', @mouseMove);
    catch
    end
    currPt = ginput(1);
    x00 = currPt(1, 1);
    y00 = currPt(1, 2);
    line(x00, y00, 'marker', '.', 'color', 'r', 'markersize', 20);
    % #2
    figure(handles.DataExtractMain);
    set(handles.text5, 'string', 'Locate the X-Axis End point !!!');
    figure(handles.DataExtractFig);
    currPt = ginput(1);
    x01 = currPt(1, 1);
    y01 = currPt(1, 2);
    line(x01, y01, 'marker', '.', 'color', 'r', 'markersize', 20);
    line([x00, x01], [y00, y01], 'color', 'r');
    % #3
    figure(handles.DataExtractMain);
    set(handles.text5, 'string', 'Locate the Y-Axis Start point !!!');
    figure(handles.DataExtractFig);
    currPt = ginput(1);
    x02 = currPt(1, 1);
    y02 = currPt(1, 2);
    line(x02, y02, 'marker', '.', 'color', 'r', 'markersize', 20);
    % #4
    figure(handles.DataExtractMain);
    set(handles.text5, 'string', 'Locate the Y-Axis End point !!!');
    figure(handles.DataExtractFig);
    currPt = ginput(1);
    x03 = currPt(1, 1);
    y03 = currPt(1, 2);
    line(x03, y03, 'marker', '.', 'color', 'r', 'markersize', 20);
    line([x02, x03], [y02, y03], 'color', 'r');

    set(handles.text5, 'string', 'Now Digitize the point, press RightButton to stop');

    handles.x00 = x00;
    handles.x01 = x01;
    handles.x02 = x02;
    handles.x03 = x03;
    handles.y00 = y00;
    handles.y01 = y01;
    handles.y02 = y02;
    handles.y03 = y03;
%end
if handles.recalibrate == 0
    set(handles.push_calibrate, 'string', 'Recalibrate axis');
    handles.recalibrate = 1;
end
guidata(hObject, handles);


% --- Executes on button press in PushDigitize.
function PushDigitize_Callback(hObject, eventdata, handles)
% hObject    handle to PushDigitize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x00 = handles.x00;
x01 = handles.x01;
y02 = handles.y02;
y03 = handles.y03;

figure(DataExtractTab)
set(gcf,'units','norm') % set location
set(gcf,'position',[0.8,0.0,0.2,1]) % set position
hguiTable = findobj('Tag','DataExtractTable1');
gui1data  = guidata(hguiTable(1));
figure(handles.DataExtractFig)
%tableData = cell(0);
tableData = handles.tableData;
tableDatai = handles.tableDatai;
con = 1;
i = handles.i;

xmin = str2double(get(handles.edit1, 'string'));
xmax = str2double(get(handles.edit2, 'string'));
ymin = str2double(get(handles.edit3, 'string'));
ymax = str2double(get(handles.edit4, 'string'));
scale1 = get(handles.radiobutton1, 'value');
scale2 = get(handles.radiobutton3, 'value');
hold on
while con == 1    
    [x, y, con] = ginput(1);
    if con == 1
        line(x, y, 'marker', '+', 'color', 'r', 'markersize', 10);
        if scale1 == 1
            xx = (xmax - xmin)*(x - x00)/(x01 - x00) + xmin;
        else
            xx = 10^((log10(xmax) - log10(xmin))*(x - x00)/(x01 - x00) + log10(xmin));
        end
        if scale2 == 1
            yy = (ymax - ymin)*(y - y02)/(y03 - y02) + ymin;
        else
            yy = 10^((log10(ymax) - log10(ymin))*(log10(y) - log10(y02))/(log10(y03) - log10(y02)) + log10(ymin));
        end
        tableData{i, 1} = i;
        tableData{i, 2} = xx;
        tableData{i, 3} = yy;
        
        tableDatai{i, 1} = i;
        tableDatai{i, 2} = x;
        tableDatai{i, 3} = y;
        set(gui1data.uitable1, 'data', tableData);
        %plot(tableData{:, 2},tableData{:, 3},'r-');
        i = i + 1;
    end
end
handles.i = i;
handles.tableData = tableData;
handles.tableDatai = tableDatai;
guidata(hObject, handles);

% --- Executes on button press in push_undo.
function push_undo_Callback(hObject, eventdata, handles)
% hObject    handle to push_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = handles.i;
if i > 1
    %i
    i = i - 1;
    tableData = handles.tableData;
    tableData = tableData(1:i-1,:);
    
    tableDatai = handles.tableDatai;
    tableDatai = tableDatai(1:i-1,:);
    
    try figure(handles.DataExtractFig)
        clf('reset')
    catch
        handles.DataExtractFig = figure;
        imshow(handles.figname);
        clf('reset')
    end
    imshow(handles.figname);
    set(gcf,'units','norm') % set location
    set(gcf,'position',[0.0,0.0,0.8,0.75]) % set position
    x00 = handles.x00;
    x01 = handles.x01;
    x02 = handles.x02;
    x03 = handles.x03;
    y00 = handles.y00;
    y01 = handles.y01;
    y02 = handles.y02;
    y03 = handles.y03;

    line(x00, y00, 'marker', '.', 'color', 'r', 'markersize', 20);
    line(x01, y01, 'marker', '.', 'color', 'r', 'markersize', 20);
    line([x00, x01], [y00, y01], 'color', 'r');
    line(x02, y02, 'marker', '.', 'color', 'r', 'markersize', 20);
    line(x03, y03, 'marker', '.', 'color', 'r', 'markersize', 20);
    line([x02, x03], [y02, y03], 'color', 'r');
    set(handles.text5, 'string', 'Now Digitize the point, press RightButton to stop');
    
    hguiTable = findobj('Tag','DataExtractTable1');
    gui1data  = guidata(hguiTable(1));

    for j = 1: i-1
        x = tableDatai{j, 2};
        y = tableDatai{j, 3};
        line(x, y, 'marker', '+', 'color', 'r', 'markersize', 10);
        set(gui1data.uitable1, 'data', tableData);
    end
end
handles.tableData = tableData;
handles.tableDatai = tableDatai;
handles.i = i;
guidata(hObject, handles);


% --- Executes on button press in pushsave.
function pushsave_Callback(hObject, eventdata, handles)
% hObject    handle to pushsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CDac_pwd; % cd working dir

[dat_dir,dat_name,ext] = fileparts(handles.figname);

tableData = handles.tableData;
name1 = [dat_name,'-Digit.txt'];
dlmwrite(name1, tableData(:,2:3), 'delimiter', ',', 'precision', 9);
name1 = [dat_name,'-DigitNo.txt'];
dlmwrite(name1, tableData, 'delimiter', ',', 'precision', 9);

try
    YYYtrue = handles.YYYtrue;
    name2 = 'DataExtract-auto.txt';
    dlmwrite(name2, YYYtrue, 'delimiter', ',', 'precision', 9);
catch
end
cd(pre_dirML); % return to matlab view folder

% refresh AC main window
figure(handles.acfigmain);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir

guidata(hObject, handles);


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
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


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
if get(hObject,'Value') == 1
    set(handles.radiobutton3, 'Value',0)
else
    set(handles.radiobutton3, 'Value',1)
end

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
if get(hObject,'Value') == 1
    set(handles.radiobutton4, 'Value',0)
else
    set(handles.radiobutton4, 'Value',1)
end

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
if get(hObject,'Value') == 1
    set(handles.radiobutton2, 'Value',0)
else
    set(handles.radiobutton2, 'Value',1)
end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
if get(hObject,'Value') == 1
    set(handles.radiobutton1, 'Value',0)
else
    set(handles.radiobutton1, 'Value',1)
end


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



% --- Executes on button press in push_grid.
function push_grid_Callback(hObject, eventdata, handles)
% hObject    handle to push_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_auto.
function push_auto_Callback(hObject, eventdata, handles)
% hObject    handle to push_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I = imread(handles.figname);
shreshn = 255/2; % color grayscale
srsh = handles.srsh; % pixal

if ndims(I) == 3
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);
    Ig = 0.2989 * R + 0.5870 * G + 0.1140 * B;
    figure(handles.DataExtractFig)
    try
        set(handles.DataExtractFig,'WindowButtonMotionFcn', @mouseMove);
    catch
    end
    Ig01 = Ig; 
    Ig01(Ig01<shreshn)  = 0; % data
    Ig01(Ig01>=shreshn) = 255; % white bg
    Ig01(Ig01==0)  = 1; % data
    Ig01(Ig01==255)  = 0; % bg
    Ig01 = double(Ig01);
    hwarn1 = warndlg('Preparing image. Wait ...');
    hwarnfig = gcf;
    [Y] = getPKS(Ig01,2);
    close(hwarnfig)
    %fig1 = figure; pcolor(Y);set(gca,'Ydir','reverse')
    %fig2 = figure; 
    %figure(handles.DataExtractFig)
    shading interp
    % get data
    con = 1;
    [Ym, Yn] = size(Y);
    YYY1 = handles.YYY1;
    YYY0 = handles.YYY0;
    
    x00 = handles.x00;
    x01 = handles.x01;
    x02 = handles.x02;
    x03 = handles.x03;
    y00 = handles.y00;
    y01 = handles.y01;
    y02 = handles.y02;
    y03 = handles.y03;
    
    xmin = str2double(get(handles.edit1, 'string'));
    xmax = str2double(get(handles.edit2, 'string'));
    ymin = str2double(get(handles.edit3, 'string'));
    ymax = str2double(get(handles.edit4, 'string'));
    scale1 = get(handles.radiobutton1, 'value');
    scale2 = get(handles.radiobutton3, 'value');
    
    while con == 1
        [x, y, con] = ginput(1);
        if con == 1
            round(x),round(y)
            [YYY] = trackline(Y',round(x),round(y),srsh);
            if ~isempty(YYY)
                hold on;
                plot(YYY(:,1),YYY(:,2),'ro')
                set(gca,'Ydir','reverse')
                xlim([1,Yn])
                ylim([1,Ym])
                hold off;
            end
            YYY0 = YYY1; % undo-1 step
            YYY1 = [YYY1;YYY];
        end
    end
    
    if scale1 == 1
        xx = (xmax - xmin)*(YYY1(:,1) - x00)/(x01 - x00) + xmin;
    else
        xx = 10^((log10(xmax) - log10(xmin))*(YYY1(:,1) - x00)/(x01 - x00) + log10(xmin));
    end
    if scale2 == 1
        yy = (ymax - ymin)*(YYY1(:,2)  - y02)/(y03 - y02) + ymin;
    else
        yy = 10^((log10(ymax) - log10(ymin))*(log10(YYY1(:,2)) - log10(y02))/(log10(y03) - log10(y02)) + log10(ymin));
    end
    
    handles.YYY1 = YYY1;
    handles.YYY0 = YYY0;
    handles.YYYtrue = [xx,yy];
    handles.srsh = srsh;
end


guidata(hObject, handles);

%function mouseMove (object, eventdata)
function mouseMove (hObject, eventdata, handles)
C = get(gca, 'CurrentPoint');
title(gca, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']);
%srsh = handles.srsh;
srsh = 10;
hl1 = line([C(1,1)-srsh, C(1,1)+srsh], [C(1,2)-srsh, C(1,2)-srsh], 'color', 'k');
hl2 = line([C(1,1)-srsh, C(1,1)+srsh], [C(1,2)+srsh, C(1,2)+srsh], 'color', 'k');
hl3 = line([C(1,1)-srsh, C(1,1)-srsh], [C(1,2)-srsh, C(1,2)+srsh], 'color', 'k');
hl4 = line([C(1,1)+srsh, C(1,1)+srsh], [C(1,2)-srsh, C(1,2)+srsh], 'color', 'k');

pause(.01)
try
    delete(hl1);
    delete(hl2);
    delete(hl3);
    delete(hl4);
catch
end
