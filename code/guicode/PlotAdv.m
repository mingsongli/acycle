function varargout = PlotAdv(varargin)
% PLOTADV MATLAB code for PlotAdv.fig
%      PLOTADV, by itself, creates a new PLOTADV or raises the existing
%      singleton*.
%
%      H = PLOTADV returns the handle to a new PLOTADV or the handle to
%      the existing singleton*.
%
%      PLOTADV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTADV.M with the given input arguments.
%
%      PLOTADV('Property','Value',...) creates a new PLOTADV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotAdv_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotAdv_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlotAdv

% Last Modified by GUIDE v2.5 20-Mar-2018 06:17:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotAdv_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotAdv_OutputFcn, ...
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


% --- Executes just before PlotAdv is made visible.
function PlotAdv_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotAdv (see VARARGIN)
set(gcf,'Name','Plot PLUS')
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','points');  % find all font units as points
set(h1,'FontUnits','norm');  % set as norm

plot_s = varargin{1}.plot_s;
handles.plot_s = plot_s;
handles.nplot = varargin{1}.nplot;
handles.unit = varargin{1}.unit;
% Choose default command line output for PlotAdv
handles.output = hObject;
handles.setseq = 1; % setting sequence, default from the first one
handles.swapxy = 0; 

% Settings for plot: 
%   1 = line plots, 
%   2 = line style, 
%   3 = line size, 
%   4 = line color
%   5 = marker style, 
%   6 = marker size, 
%   7 = marker fill color, 
%   8 = maker show?, 
%   9 = marker edge color, 
%   10 = marker edge show?
colordef = [0 0 0]; % default color for 1st line
colordef_list = [1 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 1; 1 1 0]; % default color for 2-7 lines

%                 1  2   3      4      5   6      7     8     9    10
matrix_setting = {1, 1, 1.0, colordef, 3, 6.0, colordef, 1, colordef, 0};
matrix_set = repmat(matrix_setting,handles.nplot,1);

if handles.nplot > 1
    for i = 2 : handles.nplot
        if i < 8
            matrix_set{i,4} = colordef_list(i-1,:);
            matrix_set{i,7} = colordef_list(i-1,:);
            matrix_set{i,9} = colordef_list(i-1,:);
        else 
            matrix_set{i,4} = rand(1,3);
            matrix_set{i,7} = matrix_set{i,4};
            matrix_set{i,9} = matrix_set{i,4};
        end
    end
end
handles.matrix_set = matrix_set;

% settings for x-axis 1st row and y-axis 2nd row
% 1 column = start; 2 = end; 3 = linear1/log0; 4 = set x or y
% 5 column = start; 6 = end; 7 = linear1/log0; 8 = set x or y
%           1  2  3  4  5  6  7  8
axis_set = {0, 0, 1, 1, 0, 0, 1, 0};
axis_setting = repmat(axis_set,1,1);
handles.flipxy = [0, 0];   % flip axis 0 = no; 1 = yes; 1st = x; 2nd = y;
% line size list
pop_type_list = get(handles.pop_type, 'String');
pop_linestyle_list = get(handles.pop_linestyle, 'String');
pop_linesize_list = get(handles.pop_linesize, 'String');
pop_markerstyle_list = get(handles.pop_markerstyle, 'String');
pop_markersize_list = get(handles.pop_markersize, 'String');
% get order
pop_linesize_ii = getlisti(pop_linesize_list,num2str(matrix_setting{3},'%2.1f'));
pop_markersize_ii = getlisti(pop_markersize_list,num2str(matrix_setting{6},'%2.1f'));
%
for i = 1: handles.nplot
        plot_no = plot_s{i};
        plot_no = strrep2(plot_no, '<HTML><FONT color="blue">', '</FONT></HTML>');
        if isdir(plot_no)
            return
        end
        [~,plotseries,ext] = fileparts(plot_no);
        handles.plot_list{i} = plotseries;
        handles.plot_list_ext{i} = [plotseries,ext];
        try dat = load(plot_no);
        catch
            errordlg([[plotseries,ext],' Error! try "Math -> Sort/Unique/Delete-empty" first'],'Data Error')
        end
        dat = dat(~any(isnan(dat),2),:);
        if i == 1
            axis_setting{1,1} = min(dat(:,1));
            axis_setting{1,2} = max(dat(:,1));
            axis_setting{1,5} = min(dat(:,2));
            axis_setting{1,6} = max(dat(:,2));
        end
        % update plot value
        axis_setting{1,1} = min(min(dat(:,1)), axis_setting{1,1});
        axis_setting{1,2} = max(max(dat(:,1)), axis_setting{1,2});
        axis_setting{1,5} = min(min(dat(:,2)), axis_setting{1,5});
        axis_setting{1,6} = max(max(dat(:,2)), axis_setting{1,6});
end
%axis_setting
set(handles.pop_data,'String', handles.plot_list_ext);
set(handles.pop_linestyle, 'Value', matrix_setting{2});
set(handles.pop_linesize, 'Value', pop_linesize_ii);
set(handles.pop_markerstyle, 'Value', matrix_setting{5});
set(handles.pop_markersize, 'Value', pop_markersize_ii);
set(handles.push_makerface,'BackgroundColor',colordef);
set(handles.push_markeredge,'BackgroundColor', colordef);
%if axis_setting{1,4} == 1
set(handles.axis_start, 'String', axis_setting{1,1});
set(handles.axis_end, 'String', axis_setting{1,2});

%end
handles.basevalue = axis_setting{1,5}; %
handles.basevalue_check = 0;
handles.pop_type_list = pop_type_list;
handles.pop_linestyle_list = pop_linestyle_list;
handles.pop_linesize_list = pop_linesize_list;
handles.pop_markerstyle_list = pop_markerstyle_list;
handles.pop_markersize_list = pop_markersize_list;
handles.axis_setting = axis_setting;
% Update handles structure
guidata(hObject, handles);
%end
% UIWAIT makes PlotAdv wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PlotAdv_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in pop_data.
function pop_data_Callback(hObject, eventdata, handles)
% hObject    handle to pop_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_data

% Settings for plot: 1 = line plots, 2 = line style, 3 = line size, 4 = line color
%                   5 = marker style, 6 = marker size, 7 = marker fill
%                   color, 8 = maker show?, 9 = marker edge color, 10 = marker edge
%                   show?

str = get(hObject, 'String');
val = get(hObject,'Value');
matrix_set = handles.matrix_set;  % plot style setting
%axis_setting = handles.axis_setting;  % axis setting
plot_s = handles.plot_s;
nplot = handles.nplot;
for i = 1: nplot
    [~,name,ext] = fileparts(plot_s{i});
    selected_data = [name,ext];
    switch str{val};
    case selected_data % set selected.
        disp(['Set style for data: ',selected_data]);
        handles.setseq = i;
        pop_linesize_ii = getlisti(handles.pop_linesize_list,num2str(matrix_set{i,3},'%2.1f'));
        pop_markersize_ii = getlisti(handles.pop_markersize_list,num2str(matrix_set{i,6},'%2.1f'));
        %class(matrix_set{i,5})

        
        set(handles.pop_linestyle,'Value', matrix_set{i,2});
        set(handles.push_linecolor,'BackgroundColor', matrix_set{i,4});
        set(handles.pop_markerstyle,'Value', matrix_set{i,5});
        set(handles.push_makerface,'BackgroundColor', matrix_set{i,7});
        set(handles.push_markeredge,'BackgroundColor', matrix_set{i,9});
        set(handles.pop_linesize, 'Value', pop_linesize_ii);
        set(handles.pop_markersize, 'Value', pop_markersize_ii);
        set(handles.pop_type,'Value', matrix_set{i,1});
        
        if matrix_set{i,8} == 1
            set(handles.push_face, 'String', 'Face');
        elseif matrix_set{i,8} == 0
            set(handles.push_face, 'String', 'none');
        end
        if matrix_set{i,10} == 1
            set(handles.push_edge, 'String', 'Edge');
        elseif matrix_set{i,10} == 0
            set(handles.push_edge, 'String', 'none');
        end
    end
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in pop_type.
function pop_type_Callback(hObject, eventdata, handles)
% hObject    handle to pop_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_type
matrix_set_temp = handles.matrix_set;
axis_setting = handles.axis_setting;

% Read plot type
str = get(hObject, 'String');
val = get(hObject,'Value');
%str = get(handles.pop_type, 'String');
%val = get(handles.pop_type, 'Value');
ii = getlisti(handles.pop_type_list,str{val});
matrix_set_temp{handles.setseq,1} = ii;
% save handles

% bar
if ii == 3
    set(handles.text4, 'String', 'Bar');
    set(handles.pop_markerstyle, 'Visible', 'Off');
    set(handles.push_linecolor, 'Visible', 'Off');
    set(handles.pop_markersize, 'Visible', 'Off');
    set(handles.checkbox_basevalue, 'String', 'Width');
    set(handles.edit_basevalue, 'String', '0.5');
else
    set(handles.text4, 'String', 'Marker');
    set(handles.pop_markerstyle, 'Visible', 'On');
    set(handles.push_linecolor, 'Visible', 'On');
    set(handles.pop_markersize, 'Visible', 'On');
    set(handles.checkbox_basevalue, 'String', 'Basevalue');
end
% area
if ii == 5
    set(handles.edit_basevalue, 'String', axis_setting{1,5});
    set(handles.pop_linesize, 'Enable', 'Off');
    set(handles.pop_markerstyle, 'Enable', 'Off');
    set(handles.pop_markersize, 'Enable', 'Off');
    set(handles.push_face, 'Enable', 'Off');
    set(handles.push_makerface, 'Enable', 'Off');
    set(handles.push_edge, 'Enable', 'Off');
    set(handles.push_markeredge, 'Enable', 'Off');
else
    set(handles.pop_linesize, 'Enable', 'On');
    set(handles.pop_markerstyle, 'Enable', 'On');
    set(handles.pop_markersize, 'Enable', 'On');
    set(handles.push_face, 'Enable', 'On');
    set(handles.push_makerface, 'Enable', 'On');
    set(handles.push_edge, 'Enable', 'On');
    set(handles.push_markeredge, 'Enable', 'On');
end
if ismember(ii,[3,5])
    set(handles.checkbox_basevalue, 'Visible', 'On');
    set(handles.edit_basevalue, 'Visible', 'On');
else
    set(handles.checkbox_basevalue, 'Visible', 'Off');
    set(handles.edit_basevalue, 'Visible', 'Off');
end
handles.matrix_set = matrix_set_temp;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_linestyle.
function pop_linestyle_Callback(hObject, eventdata, handles)
% hObject    handle to pop_linestyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_linestyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_linestyle
matrix_set_temp = handles.matrix_set;
% Read Line Style
str = get(handles.pop_linestyle, 'String');
val = get(handles.pop_linestyle, 'Value');
ii = getlisti(handles.pop_linestyle_list,str{val});
matrix_set_temp{handles.setseq,2} = ii;
% save handles
handles.matrix_set = matrix_set_temp;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_linestyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_linestyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_markerstyle.
function pop_markerstyle_Callback(hObject, eventdata, handles)
% hObject    handle to pop_markerstyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_markerstyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_markerstyle
matrix_set_temp = handles.matrix_set;
% Read Marker Style
str = get(handles.pop_markerstyle, 'String');
val = get(handles.pop_markerstyle, 'Value');
ii = getlisti(handles.pop_markerstyle_list,str{val});
matrix_set_temp{handles.setseq,5} = ii;
% save handles
handles.matrix_set = matrix_set_temp;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_markerstyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_markerstyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_linesize.
function pop_linesize_Callback(hObject, eventdata, handles)
% hObject    handle to pop_linesize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_linesize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_linesize
matrix_set_temp = handles.matrix_set;
% Read Line Size
str = get(handles.pop_linesize, 'String');
val = get(handles.pop_linesize, 'Value');
matrix_set_temp{handles.setseq,3} = str2double(str{val});
% save handles
handles.matrix_set = matrix_set_temp;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_linesize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_linesize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_markersize.
function pop_markersize_Callback(hObject, eventdata, handles)
% hObject    handle to pop_markersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_markersize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_markersize
matrix_set_temp = handles.matrix_set;
% Read Marker Size
str = get(handles.pop_markersize, 'String');
val = get(handles.pop_markersize, 'Value');
matrix_set_temp{handles.setseq,6} = str2double(str{val});
% save handles
handles.matrix_set = matrix_set_temp;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_markersize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_markersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_linecolor.
function push_linecolor_Callback(hObject, eventdata, handles)
% hObject    handle to push_linecolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c = uisetcolor([0 0 0],'Select a color');
matrix_set_temp = handles.matrix_set;
matrix_set_temp{handles.setseq,4} = c;
handles.matrix_set = matrix_set_temp;
set(handles.push_linecolor, 'BackgroundColor', c);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in push_makerface.
function push_makerface_Callback(hObject, eventdata, handles)
% hObject    handle to push_makerface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c = uisetcolor([1 0 0],'Select a color');
matrix_set_temp = handles.matrix_set;
matrix_set_temp{handles.setseq,7} = c;
handles.matrix_set = matrix_set_temp;
set(handles.push_makerface, 'BackgroundColor', c);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in push_markeredge.
function push_markeredge_Callback(hObject, eventdata, handles)
% hObject    handle to push_markeredge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c = uisetcolor([0 0 1],'Select a color');
matrix_set_temp = handles.matrix_set;
matrix_set_temp{handles.setseq,9} = c;
handles.matrix_set = matrix_set_temp;
set(handles.push_markeredge, 'BackgroundColor', c);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_done.
function plot_done_Callback(hObject, eventdata, handles)
% hObject    handle to plot_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Settings for plot: 1 = line plots, 2 = line style, 3 = line size, 4 = line color
%                   5 = marker style, 6 = marker size, 7 = marker fill
%                   color, 8 = maker show?, 9 = marker edge color, 10 = marker edge
%                   show?

matrix_set = handles.matrix_set;
axis_setting = handles.axis_setting;
flipxy = handles.flipxy;
figure;
hold on
for i = 1: handles.nplot
    
    try
        dat = load(handles.plot_s{i});
    catch
        fid = fopen(handles.plot_s{i});
        data_ft = textscan(fid,'%f%f','EmptyValue', Inf);
        dat = cell2mat(data_ft);
        fclose(fid);
    end
        dat = dat(~any(isnan(dat),2),:);
        linestyle_list = handles.pop_linestyle_list;
        markerstyle_list = handles.pop_markerstyle_list;
% settings for x-axis 1st row and y-axis 2nd row
% 1st column = start; 2nd = end; 3nd = linear1/log0; 4th = set x or y
% %          1  2  3  4  5  6  7  8
%axis_set = {0, 0, 1, 1, 0, 0, 1, 0};
        if matrix_set{i,1} == 2
            pp = stairs(dat(:,1),dat(:,2));  % stairs plot
        elseif matrix_set{i,1} == 1
            pp = plot(dat(:,1),dat(:,2));  % line plot
        elseif matrix_set{i,1} == 4
            pp = stem(dat(:,1),dat(:,2));  % stem plot
        end
        if ismember(matrix_set{i,1}, [1, 2, 4])
            pp.LineStyle = linestyle_list{matrix_set{i,2}};
            pp.LineWidth = matrix_set{i,3};
            pp.Color = matrix_set{i,4};
            pp.Marker = markerstyle_list{matrix_set{i,5}};
            pp.MarkerSize = matrix_set{i,6};
            if matrix_set{i,8} == 1
                pp.MarkerFaceColor = matrix_set{i,7};
            else
                pp.MarkerEdgeColor = 'none';
            end
            if matrix_set{i,10} == 1
                pp.MarkerEdgeColor = matrix_set{i,9};
            else
                pp.MarkerEdgeColor = 'none';
            end
        end
        if matrix_set{i,1} == 3
            if handles.basevalue_check == 0
                pp = bar(dat(:,1),dat(:,2));  % bar plot
            else
                pp = bar(dat(:,1),dat(:,2),handles.basevalue);  % bar plot
            end
            pp.LineStyle = linestyle_list{matrix_set{i,2}};
            pp.LineWidth = matrix_set{i,3};
%            pp.Color = matrix_set{i,4};
%            pp.width = matrix_set{i,6};

            if matrix_set{i,8} == 1
                pp.FaceColor = matrix_set{i,7};
            else
                pp.FaceColor = 'none';
            end
            if matrix_set{i,10} == 1
                pp.EdgeColor = matrix_set{i,9};
            else
                pp.EdgeColor = 'none';
            end
        end
        if matrix_set{i,1} == 5
            if handles.basevalue_check == 0
                pp = area(dat(:,1),dat(:,2));  % area plot
            elseif handles.basevalue_check == 1
                pp = area(dat(:,1),dat(:,2),handles.basevalue);  % area plot
            end
            pp.FaceColor = matrix_set{i,4};
            pp.LineStyle = linestyle_list{matrix_set{i,2}};
        end
end

xlim([axis_setting{1,1} axis_setting{1,2}])
ylim([axis_setting{1,5} axis_setting{1,6}])
xlabel(handles.unit)
ylabel('Value')
%title('Plot')
set(gca,'XMinorTick','on','YMinorTick','on')
legend(handles.plot_list)

if and(axis_setting{1,3} == 1, axis_setting{1,7} == 1)
%    disp('plot')
elseif and(axis_setting{1,3} == 0, axis_setting{1,7} == 1)
    set(gca,'xscale','log')
%     disp('semilogx')
elseif and(axis_setting{1,3} == 1, axis_setting{1,7} == 0)
    set(gca,'yscale','log')
%     disp('semilogy')
else
    set(gca,'xscale','log')
    set(gca,'yscale','log')
%     disp('loglog')
end
hold off

if flipxy(1) == 1
    set(gca,'Xdir','reverse')
end
if flipxy(2) == 1
    set(gca,'Ydir','reverse')
end

if handles.swapxy == 1
    view([90 -90])
end
set(gcf,'color','w');


% --- Executes on button press in push_face.
function push_face_Callback(hObject, eventdata, handles)
% hObject    handle to push_face (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Settings for plot: 1 = line plots, 2 = line style, 3 = line size, 4 = line color
%                   5 = marker style, 6 = marker size, 7 = marker fill
%                   color, 8 = maker show?, 9 = marker edge color, 10 = marker edge
%                   show?

matrix_set_temp = handles.matrix_set;
if matrix_set_temp{handles.setseq,8} == 1
    set(handles.push_face, 'String', 'none');
    matrix_set_temp{handles.setseq,8} = 0;    
elseif matrix_set_temp{handles.setseq,8} == 0;
    set(handles.push_face, 'String', 'Face');
    matrix_set_temp{handles.setseq,8} = 1;
    matrix_set_temp{handles.setseq,7} = get(handles.push_makerface,'BackgroundColor');
end

handles.matrix_set = matrix_set_temp;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in push_edge.
function push_edge_Callback(hObject, eventdata, handles)
% hObject    handle to push_edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
matrix_set_temp = handles.matrix_set;
if matrix_set_temp{handles.setseq,10} == 1
    set(handles.push_edge, 'String', 'none');
    matrix_set_temp{handles.setseq,10} = 0;
elseif matrix_set_temp{handles.setseq,10} == 0;
    set(handles.push_edge, 'String', 'Edge');
    matrix_set_temp{handles.setseq,10} = 1;
    matrix_set_temp{handles.setseq,9} = get(handles.push_markeredge,'BackgroundColor');
end
handles.matrix_set = matrix_set_temp;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in push_axis.
function push_axis_Callback(hObject, eventdata, handles)
% hObject    handle to push_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axis_setting = handles.axis_setting;
flipxy = handles.flipxy;
if axis_setting{1,4} == 0
    axis_setting{1,4} = 1;
    axis_setting{1,8} = 0;
    set(handles.push_axis,'String','X')
    set(handles.axis_start,'String',axis_setting{1,1})
    set(handles.axis_end,'String',axis_setting{1,2})
    % normal or fliped
    if flipxy(1) == 0
        set(handles.pushbutton_flipxy,'String','Normal')
    else 
        set(handles.pushbutton_flipxy,'String','Reverse')
    end
else
    axis_setting{1,4} = 0;
    axis_setting{1,8} = 1;
    set(handles.push_axis,'String','Y')
    set(handles.axis_start,'String',axis_setting{1,5})
    set(handles.axis_end,'String',axis_setting{1,6})
    % normal or fliped
    if flipxy(2) == 0
        set(handles.pushbutton_flipxy,'String','Normal')
    else 
        set(handles.pushbutton_flipxy,'String','Reverse')
    end
end
handles.axis_setting = axis_setting;
% Update handles structure
guidata(hObject, handles);

function axis_start_Callback(hObject, eventdata, handles)
% hObject    handle to axis_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axis_start as text
%        str2double(get(hObject,'String')) returns contents of axis_start as a double
axis_setting = handles.axis_setting;
if axis_setting{1,4} == 1  % setting for X axis
    axis_setting{1,1} = str2double(get(handles.axis_start, 'String'));
elseif axis_setting{1,4} == 0  % setting for Y axis
    axis_setting{1,5} = str2double(get(handles.axis_start, 'String'));
end

handles.axis_setting = axis_setting;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function axis_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axis_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axis_end_Callback(hObject, eventdata, handles)
% hObject    handle to axis_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axis_end as text
%        str2double(get(hObject,'String')) returns contents of axis_end as a double
axis_setting = handles.axis_setting;
if axis_setting{1,4} == 1  % setting for X axis
    axis_setting{1,2} = str2double(get(handles.axis_end, 'String'));
elseif axis_setting{1,4} == 0  % setting for Y axis
    axis_setting{1,6} = str2double(get(handles.axis_end, 'String'));
end

handles.axis_setting = axis_setting;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function axis_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axis_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_axis_log.
function push_axis_log_Callback(hObject, eventdata, handles)
% hObject    handle to push_axis_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axis_setting = handles.axis_setting;
if axis_setting{1,4} == 1  % setting for X axis
    if axis_setting{1,3} == 1  % linear
        axis_setting{1,3} = 0; % change to log
        set(handles.push_axis_log,'String','Log');
    elseif axis_setting{1,3} == 0  % log
        axis_setting{1,3} = 1; % change to linear
        set(handles.push_axis_log,'String','Linear');
    end
elseif axis_setting{1,4} == 0  % setting for Y axis
    if axis_setting{1,7} == 1  % linear
        axis_setting{1,7} = 0; % change to log
        set(handles.push_axis_log,'String','Log');
    elseif axis_setting{1,7} == 0  % log
        axis_setting{1,7} = 1; % change to linear
        set(handles.push_axis_log,'String','Linear');
    end
end

handles.axis_setting = axis_setting;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_flipxy.
function pushbutton_flipxy_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_flipxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flipxy = handles.flipxy;
axis_setting = handles.axis_setting;

if axis_setting{1,4} == 1  % setting for X axis
    
    if flipxy(1) == 0  % normal
        flipxy(1) = 1 ; % change to reverse
        set(handles.pushbutton_flipxy,'String','Reverse');
    elseif flipxy(1) == 1  % reversed
        flipxy(1) = 0 ; % change to normal
        set(handles.pushbutton_flipxy,'String','Normal');
    end
    
elseif axis_setting{1,4} == 0  % setting for Y axis
    
    if flipxy(2) == 0  % normal
        flipxy(2) = 1 ; % change to reverse
        set(handles.pushbutton_flipxy,'String','Reverse');
    elseif flipxy(2) == 1  % reversed
        flipxy(2) = 0 ; % change to normal
        set(handles.pushbutton_flipxy,'String','Normal');
    end
    
end

handles.flipxy = flipxy;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in push_swap.
function push_swap_Callback(hObject, eventdata, handles)
% hObject    handle to push_swap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
swapxy_str = (get(handles.push_swap, 'String')); 
if strcmp(swapxy_str,'Swap')  % to no swap
    set(handles.push_swap,'String','--');
    handles.swapxy = 0;
else % to swap
    set(handles.push_swap,'String','Swap');
    handles.swapxy = 1;
end

% Update handles structure
guidata(hObject, handles);


function edit_basevalue_Callback(hObject, eventdata, handles)
% hObject    handle to edit_basevalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_basevalue as text
%        str2double(get(hObject,'String')) returns contents of edit_basevalue as a double
basevalue = str2double(get(handles.edit_basevalue, 'String'));
axis_setting = handles.axis_setting;
matrix_set_temp = handles.matrix_set;
if isnan(basevalue)
    handles.basevalue_check = 0;
    set(handles.checkbox_basevalue, 'Value', 0);
else
    handles.basevalue = basevalue;
    if matrix_set_temp{1,1} == 5
        axis_setting{1,5} = basevalue; % set this as y min axis value for bar plot
    end
    handles.basevalue_check = 1;
    set(handles.checkbox_basevalue, 'Value', 1);
end
% Update handles structure
handles.axis_setting = axis_setting;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_basevalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_basevalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_basevalue.
function checkbox_basevalue_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_basevalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_basevalue
handles.basevalue_check = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);
