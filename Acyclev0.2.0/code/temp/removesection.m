function varargout = removesection(varargin)

removesection_OpeningFcn(varargin);



function removesection_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles1 = hObject{1,1};

data = handles1.current_data;
name = handles1.dat_name;
ext = handles1.ext;
figure; plot(data(:,1),data(:,2),'ko-')

f = figure;
set(gcf,'Name','Remove sections')

n = 20; % n lines of sections
n_sec = cell(n,3);
n_sec(:,1:2) = {''};
n_sec(:,3) = {false};

t = uitable(f,...
        'Position', [20 20 300 320],...
        'ColumnName',{'Start','End','Check'},...
        'ColumnEditable',true,...
        'Data',n_sec);

txt = uicontrol('Style','text',...
        'Position',[20 380 120 20],...
        'String','Input sections');

btn = uicontrol('Style', 'pushbutton', ...
        'String', 'Remove',...
        'Position', [180 380 40 20],...
        'Callback', @removess);

handles.data = data;

% Update handles structure
hObject = t;
assignin('base','hObject',hObject)
assignin('base','handles',handles)
guidata(hObject, handles);
% 
% function tablecallback(hObject, event, handles)
% x= t.Data
% tab_string = hObject.String
% tab_val = hObject.Value
% t.Data = tab_string;
% guidata(hObject, handles);

function varargout = removesection_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function removess(hObject, event, handles)
assignin('base','hObject1',hObject)
data = handles.data
[x,y,z] = size(data);
j = 1;
for i = 1:x
    if data(i,3) == 1
        if str2double(data(i,1)) ~= 0 && str2double(data(i,2)) ~= 0
            section_interval = 0; % new vector store sections
        end
    end
end