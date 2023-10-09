function varargout = undatableGUI(varargin)
% UNDATABLEGUI MATLAB code for undatableGUI.fig
%      UNDATABLEGUI, by itself, creates a new UNDATABLEGUI or raises the existing
%      singleton*.
%
%      H = UNDATABLEGUI returns the handle to a new UNDATABLEGUI or the handle to
%      the existing singleton*.
%
%   6   UNDATABLEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNDATABLEGUI.M with the given input arguments.
%
%      UNDATABLEGUI('Property','Value',...) creates a new UNDATABLEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before undatableGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to undatableGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help undatableGUI

% Last Modified by GUIDE v2.5 23-Oct-2018 16:51:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @undatableGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @undatableGUI_OutputFcn, ...
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


% --- Executes just before undatableGUI is made visible.
function undatableGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to undatableGUI (see VARARGIN)
global udinstallpath
[udinstallpath, ~, ~ ] = fileparts(mfilename('fullpath'));
%cd(udinstallpath);
delete([udinstallpath,'/guitemp/*.*'])
mkdir([udinstallpath,'/guitemp/']); % in case user deleted it
set(handles.speccombine,'value',1) % default

% acycle
set(gcf,'Name','Undatable for Acycle')
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm

% get pwd
GETac_pwd;
% save acycle config for refresh acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
handles.val1 = varargin{1}.val1;
handles.slash_v = varargin{1}.slash_v;
try
    % load selected data file
    udinputfile = varargin{1}.dat_name;
    udinputpath = [ac_pwd,varargin{1}.slash_v];
    handles.udinputfile = udinputfile;
    save([udinstallpath,'/guitemp/filename.mat'], 'udinputfile', 'udinputpath');
    [tabdatelabel, tabdepth1, tabdepth2, tabdepth, tabage, tabageerr, tabdatetype, tabcalcurve, tabresage, tabreserr, tabdateboot] = udgetdata([udinputpath,udinputfile]);

    tabdatetype = lower(tabdatetype);
    tabcalcurve = lower(tabcalcurve);
    tabcalcurve = strrep(tabcalcurve,'intcal','IntCal');
    tabcalcurve = strrep(tabcalcurve,'marine','Marine');
    tabcalcurve = strrep(tabcalcurve,'shcal','SHCal');
    tabcalcurve = strrep(tabcalcurve,'none','None');

    tp = cell(length(tabdepth1),11);
    tp(:,1) = num2cell(true(size(tabdepth1,1),1));
    tp(:,2) = tabdatelabel;
    tp(:,3) = num2cell(tabdepth1);
    tp(:,4) = num2cell(tabdepth2);
    tp(:,5) = num2cell(tabage);
    tp(:,6) = num2cell(tabageerr);
    tp(:,7) = tabdatetype;
    tp(:,8) = tabcalcurve;
    tp(:,9) = num2cell(tabresage);
    tp(:,10) = num2cell(tabreserr);
    tp(:,11) = num2cell(logical(tabdateboot));
    set(handles.bigtable,'data',tp)
catch
    disp('Select input file. Input file format see manual')
end
%
CDac_pwd; % cd ac_pwd dir
d = dir; %get files
%set(handles.listbox1,'String',{d.name},'Value',1) %set string
%set(handles.edit1,'String',pwd) % set position
cd(pre_dirML); % return to matlab view folder
% Choose default command line output for undatableGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes undatableGUI wait for user response (see UIRESUME)
% uiwait(handles.udguiwindow);


% --- Outputs from this function are returned to the command line.
function varargout = undatableGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadinput.
function loadinput_Callback(hObject, eventdata, handles)
% hObject    handle to loadinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global udinstallpath
[udinputfile, udinputpath, ~] = uigetfile('*.txt','Load Undatable input file');
if udinputfile == 0
	return
end
handles.udinputfile = udinputfile;
save([udinstallpath,'/guitemp/filename.mat'], 'udinputfile', 'udinputpath');
[tabdatelabel, tabdepth1, tabdepth2, tabdepth, tabage, tabageerr, tabdatetype, tabcalcurve, tabresage, tabreserr, tabdateboot] = udgetdata([udinputpath,udinputfile]);

tabdatetype = lower(tabdatetype);
tabcalcurve = lower(tabcalcurve);
tabcalcurve = strrep(tabcalcurve,'intcal','IntCal');
tabcalcurve = strrep(tabcalcurve,'marine','Marine');
tabcalcurve = strrep(tabcalcurve,'shcal','SHCal');
tabcalcurve = strrep(tabcalcurve,'none','None');

tp = cell(length(tabdepth1),11);
tp(:,1) = num2cell(true(size(tabdepth1,1),1));
tp(:,2) = tabdatelabel;
tp(:,3) = num2cell(tabdepth1);
tp(:,4) = num2cell(tabdepth2);
tp(:,5) = num2cell(tabage);
tp(:,6) = num2cell(tabageerr);
tp(:,7) = tabdatetype;
tp(:,8) = tabcalcurve;
tp(:,9) = num2cell(tabresage);
tp(:,10) = num2cell(tabreserr);
tp(:,11) = num2cell(logical(tabdateboot));
set(handles.bigtable,'data',tp)
% Update handles structure
guidata(hObject, handles);

function specnsim_Callback(hObject, eventdata, handles)
% hObject    handle to specnsim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of specnsim as text
%        str2double(get(hObject,'String')) returns contents of specnsim as a double


% --- Executes during object creation, after setting all properties.
function specnsim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specnsim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function specxfactor_Callback(hObject, eventdata, handles)
% hObject    handle to specxfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of specxfactor as text
%        str2double(get(hObject,'String')) returns contents of specxfactor as a double


% --- Executes during object creation, after setting all properties.
function specxfactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specxfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function specbootpc_Callback(hObject, eventdata, handles)
% hObject    handle to specbootpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of specbootpc as text
%        str2double(get(hObject,'String')) returns contents of specbootpc as a double


% --- Executes during object creation, after setting all properties.
function specbootpc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specbootpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runundatable.
function runundatable_Callback(hObject, eventdata, handles)
% hObject    handle to runundatable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figundatable = gcf;

hwb = waitbar(0.5,'Running Undatable... please wait');

% Write an undatable input file in the guitemp folder
global udinstallpath udinputpath %ax1 ax2
tp = get(handles.bigtable, 'data');
tp = tp(cat(1,tp{:,1}) > 0,:); % https://fr.mathworks.com/matlabcentral/answers/128787-how-do-i-extract-a-row-of-data-from-a-cell-array
bh = fopen([udinstallpath,'/guitemp/guitempinput.txt'],'w');
fprintf(bh,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s','Sample ID','Depth 1','Depth 2','Age','Age error','Date type','Calibration','Resage','Reserr','Bootstrap');
for i = 1:size(tp,1)
	if tp{i,11} == 1 
		bnow = 'Yes'; % bootstrap yes or no
	else
		bnow = 'No';
	end
	fprintf(bh,'\r\n%s\t%f\t%f\t%f\t%f\t%s\t%s\t%f\t%f\t%s', tp{i,2}, tp{i,3}, tp{i,4}, tp{i,5}, tp{i,6}, tp{i,7}, tp{i,8}, tp{i,9}, tp{i,10}, bnow);
end
fclose(bh);

% Run undatable
nsim = str2double(strrep(get(handles.specnsim,'String'),',',''));
xfactor = str2double(get(handles.specxfactor,'String'));
bootpc = str2double(strrep(get(handles.specbootpc,'String'),'%',''));
undatable([udinstallpath,'/guitemp/guitempinput.txt'],nsim,xfactor,bootpc,'writedir',[udinstallpath,'/guitemp/'],'plotme',0,'combine',get(handles.speccombine,'Value'),'savemat',get(handles.specmatfile,'Value'),'guimode',1);

% Prep Figure window
waitbar(0.8,hwb,'Plotting results')
figundatablePDF = figure;
box on
title('undatable run')
set(gca,'ydir','reverse')
load([udinstallpath,'/guitemp/guitemp.mat']) % load age model stuff to plot

%---PLOTTING SCRIPT FROM UNDATABLE.M
% Plot density cloud
for i = 1:49
	
	hi1sig=shadingmat(:,99-i);
	lo1sig=shadingmat(:,i);
	
	confx=[
		%right to left at top
		lo1sig(1); hi1sig(1);
		%down to bottom
		hi1sig(2:end);
		%left to right at bottom
		lo1sig(end);
		%up to top
		flipud(lo1sig(1:end-1))];
	
	confy=[
		%right to left at top
		depthrange(1,1); depthrange(1,1);
		%down to bottom
		depthrange(2:end,1);
		%left to right at bottom
		depthrange(end,1);
		%up to top
		flipud(depthrange(1:end-1,1))];
	
	patch(confx/1000,confy,[1-(i/49) 1-(i/49) 1-(i/49)],'edgecolor','none')
	hold on
end
plot(summarymat(:,2)/1000,depthrange,'k--') % 94.5 range
plot(summarymat(:,5)/1000,depthrange,'k--') % 94.5 range
plot(summarymat(:,3)/1000,depthrange,'b--') % 68.2 range
plot(summarymat(:,4)/1000,depthrange,'b--') % 68.2 range
plot(summarymat(:,1)/1000,depthrange,'r')

% PLOT PDFs
% Colour schemes
%                  1                   2                       3               4           5        6
datetypes = {'14C marine fossil'; '14C terrestrial fossil'; '14C sediment'; 'Tephra'; 'Tie point'; 'Other'};
colours(:,:,1) = [41  128  185 ; 166 208 236]; % dark blue  ; light blue
colours(:,:,2) = [34  153 85   ; 166 219 175]; % dark green ; light green
colours(:,:,3) = [83 57  47    ; 191 156 145]; % dark brown ; light brown
colours(:,:,4) = [192 57   43  ; 228 148 139]; % dark red   ; light red
colours(:,:,5) = [254 194 0    ; 241 234 143]; % dark yellow; light yellow
colours(:,:,6) = [64  64  64   ; 160 160 160]; % dark grey  ; light grey
colours = colours/255; % RGB to Matlab

d=ylim;
probscale=.015;
usedcolours = NaN(size(depth));

% set up order in which to plot dates so that a clould of bulk dates with large uncertainty doesn't obsure tephras etc.
plotorder=[];
plotorder=[plotorder; find(strcmpi(datetype,'14C sediment'))];
plotorder=[plotorder; find(strcmpi(datetype,'14C marine fossil'))];
plotorder=[plotorder; find(strcmpi(datetype,'14C terrestrial fossil'))];
plotorder=[plotorder; find(strcmpi(datetype,'tephra'))];
plotorder=[plotorder; find(strcmpi(datetype,'tie point'))];
plotorder=[plotorder; find(strcmpi(datetype,'other'))];
% in case user made a typo
ndepth = 1:length(depth);
typofields = ndepth(~ismember(ndepth,plotorder));
plotorder = [plotorder; typofields'];

delete(hwb);

for i = 1:length(depth)
	
	colourind = find(strcmpi(datetype{plotorder(i)},datetypes)==1);
	if isempty(colourind) == 1
		warning(['Date type "',datetype{plotorder(i)},'" unknown. Will use grey for plot colour.'])
		colourind = 6;
	end
	
	usedcolours(i) = colourind; % for legend later
	
	probnow = probtoplot{plotorder(i)};
	
	if ageerr(plotorder(i)) > 0
		
		% 2 sigma shading
		for j=1:size(p95_4{plotorder(i)},1)
			probindtemp=probnow(probnow(:,1)>p95_4{plotorder(i)}(j,2) & probnow(:,1)<p95_4{plotorder(i)}(j,1),:);
			probx=[probindtemp(:,1)/1000; flipud(probindtemp(:,1)/1000)];
			proby=[probindtemp(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1); flipud(-1*probindtemp(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1))];
			h1=patch(probx,proby,colours(2,:,colourind),'edgecolor','none');
		end
		
		% 1 sigma shading
		for j=1:size(p68_2{plotorder(i)},1)
			probindtemp=probnow(probnow(:,1)>p68_2{plotorder(i)}(j,2) & probnow(:,1)<p68_2{plotorder(i)}(j,1),:);
			probx=[probindtemp(:,1)/1000; flipud(probindtemp(:,1)/1000)];
			proby=[probindtemp(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1); flipud(-1*probindtemp(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1))];
			h1=patch(probx,proby,colours(1,:,colourind),'edgecolor','none');
		end
		
		% Outline
		probx=[probnow(:,1)/1000; flipud(probnow(:,1)/1000)];
		proby=[probnow(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1); flipud(-1*probnow(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1))];
		h1=patch(probx,proby,[1 1 1],'edgecolor','k','facecolor','none','linewidth',.2);
		
	elseif ageerr(plotorder(i)) == 0
		plot(age(i)/1000,depth(i),'kd','markeredgecolor',colours(1,:,colourind),'markerfacecolor',colours(1,:,colourind));
	end
	
end
plot(summarymat(:,1)/1000,depthrange,'r-') % median of age model runs (plot again on top of PDFs)
grid on

% plot the depth error bars
for i = 1:length(depth)
	if depth1(i) <= depth2(i)
		plot( [medians(i)/1000 medians(i)/1000] , [depth1(i) depth2(i)], 'k-' )
	elseif depth1(i) > depth2(i)
		plot( [medians(i)/1000 medians(i)/1000] , [depth1(i)+depth2(i) depth1(i)-depth2(i)], 'k-' )
	end
end

% automatic legend (do last so that it appears in the correct place)
usedcolours = unique(usedcolours);
txtxpos = min(xlim) + 0.97 * abs((max(xlim)-min(xlim)));
txtypos = min(ylim) + 0.03 * abs((max(ylim)-min(ylim)));
txtyinc = 0.04 * abs((max(ylim)-min(ylim)));
if length(usedcolours) > 1
	for i = 1:length(usedcolours)
		if i > 1; txtypos = txtypos + txtyinc; end
		h = text(txtxpos, txtypos, strrep(datetypes{usedcolours(i)},'14C','^1^4C'),'horizontalalignment','right','color',colours(1,:,usedcolours(i)));
		set(h,'fontweight','bold')
	end
end

% print the xfactor and bootpc to the bottom left corner
txtxpos = min(xlim) + 0.03 * abs((max(xlim)-min(xlim)));
txtypos = min(ylim) + 0.97 * abs((max(ylim)-min(ylim)));
txtyinc = 0.04 * abs((max(ylim)-min(ylim)));
text(txtxpos,txtypos-txtyinc,['xfactor = ',num2str(xfactor,'%.2g')])
text(txtxpos,txtypos,['bootpc = ',num2str(bootpc,'%.2g')])

set(gca, 'Layer', 'Top')
xlabel('Age (ka)')
ylabel('Depth (cm)')
% / END OF PLOTTING SCRIPT FROM UNDATABLE.M

run([udinstallpath,'/udplotoptions.m']);
set(findall(gcf,'-property','FontSize'),'FontSize',textsize)
% save pdf
% make background white
set(gcf,'InvertHardcopy','on');
set(gcf,'color',[1 1 1]);

udinputfile = handles.udinputfile;

% refresh main window
ac_pwd = fileread('ac_pwd.txt');
if isdir(ac_pwd)
    cd(ac_pwd)
end

date = datestr(now,30);
%savename = [udinputpath, strrep(udinputfile, '.txt',''), ' adplot', ' (',date,').pdf'];
savename = [ac_pwd, handles.slash_v, strrep(udinputfile, '.txt',''), ' adplot', ' (',date,').pdf'];
print(gcf, '-dpdf', '-painters', savename);

disp(['  Figure saved : ', savename])

% refresh AC main window
figure(handles.acfigmain);
refreshcolor;
%cd(pre_dirML); % return view dir
figure(figundatable);
figure(figundatablePDF);


% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figundatable = gcf;

global udinstallpath% ax1 ax2
if isempty(dir([udinstallpath,'/guitemp/filename.mat'])) ~= 1
	load([udinstallpath,'/guitemp/filename.mat'])
else
	error('No age-depth model run could be found')
end

date = datestr(now,30);


% refresh main window
ac_pwd = fileread('ac_pwd.txt');
if isdir(ac_pwd)
    cd(ac_pwd)
end


% (1) copy of input dates used
savename = [ac_pwd, handles.slash_v,  strrep(udinputfile, '.txt',''), ' inputfile', ' (',date,').txt'];
copyfile([udinstallpath,'/guitemp/guitempinput.txt'],savename);

% (2) copy of age-depth model output
savename = [ac_pwd, handles.slash_v,  strrep(udinputfile, '.txt',''), ' admodel', ' (',date,').txt'];
copyfile([udinstallpath,'/guitemp/guitempinput_admodel.txt'],savename);

% (3) copy of .mat file output (if wanted)
if get(handles.specmatfile,'Value') == 1
	savename = [ac_pwd, handles.slash_v,  strrep(udinputfile, '.txt',''), '_workspace', '_',date,'.mat'];
	copyfile([udinstallpath,'/guitemp/guitemp.mat'],savename);
end

% refresh AC main window
figure(handles.acfigmain);
refreshcolor;
%cd(pre_dirML); % return view dir
figure(figundatable);

% --- Executes on button press in bootall.
function bootall_Callback(hObject, eventdata, handles)
% hObject    handle to bootall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tp = get(handles.bigtable, 'data');
tp(:,11) = {logical(get(handles.bootall,'Value'))};
set(handles.bigtable,'data',tp)

% Hint: get(hObject,'Value') returns toggle state of bootall


% --- Executes on button press in incall.
function incall_Callback(hObject, eventdata, handles)
% hObject    handle to incall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tp = get(handles.bigtable, 'data');
tp(:,1) = {logical(get(handles.incall,'Value'))};
set(handles.bigtable,'data',tp)



% Hint: get(hObject,'Value') returns toggle state of incall


% --- Executes on button press in speccombine.
function speccombine_Callback(hObject, eventdata, handles)
% hObject    handle to speccombine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of speccombine


% --- Executes when user attempts to close udguiwindow.
function udguiwindow_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to udguiwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
global udinstallpath
fclose('all');
if exist([udinstallpath,'/guitemp'],'dir') ~= 0
	delete([udinstallpath,'/guitemp/*'])
	rmdir([udinstallpath,'/guitemp/'])
end
try
	close(822)
end
delete(hObject);


% --- Executes on button press in specmatfile.
function specmatfile_Callback(hObject, eventdata, handles)
% hObject    handle to specmatfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of specmatfile
