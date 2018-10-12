function varargout = spectrum(varargin)
% SPECTRUM MATLAB code for spectrum.fig
%      SPECTRUM, by itself, creates a new SPECTRUM or raises the existing
%      singleton*.
%
%      H = SPECTRUM returns the handle to a new SPECTRUM or the handle to
%      the existing singleton*.
%
%      SPECTRUM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTRUM.M with the given input arguments.
%
%      SPECTRUM('Property','Value',...) creates a new SPECTRUM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spectrum_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spectrum_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spectrum

% Last Modified by GUIDE v2.5 01-Jan-2018 16:12:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spectrum_OpeningFcn, ...
                   'gui_OutputFcn',  @spectrum_OutputFcn, ...
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


% --- Executes just before spectrum is made visible.
function spectrum_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spectrum (see VARARGIN)
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','points');  % find all font units as points
set(h1,'FontUnits','norm');  % set as norm

% Choose default command line output for spectrum
handles.output = hObject;

set(gcf,'Name','Spectral Analysis')

data_s = varargin{1}.current_data;
handles.current_data = data_s;
handles.filename = varargin{1}.data_name;
handles.unit = varargin{1}.unit;
handles.path_temp = varargin{1}.path_temp;

handles.pad = 1;
handles.checkbox_tabtchi = 0;
handles.ntapers= 2;

xmin = min(data_s(:,1));
xmax = max(data_s(:,1));

handles.mean = mean(diff(data_s(:,1)));
handles.nyquist = 1/(2*handles.mean);     % prepare nyquist
handles.method ='Multi-taper method';
set(handles.text_nyquist, 'String', num2str(handles.nyquist));
%set(handles.checkbox_tabtchi,'enable','on')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spectrum wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spectrum_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on selection change in popupmenu_tapers.
function popupmenu_tapers_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_tapers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_tapers contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_tapers
contents = cellstr(get(hObject,'String'));
handles.ntapers = str2num(contents{get(hObject,'Value')});
% handles.ntapers = str2num(get(hObject, 'String'));
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_tapers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_tapers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_fmax_input_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fmax_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fmax_input as text
%        str2double(get(hObject,'String')) returns contents of edit_fmax_input as a double
basevalue = str2double(get(handles.edit_fmax_input, 'String'));
if isnan(basevalue)
    set(handles.radiobutton_input, 'Value', 0);
    set(handles.radiobutton_fmax, 'Value', 1);
else
    set(handles.radiobutton_input, 'Value', 1);
    set(handles.radiobutton_fmax, 'Value', 0);
end

% --- Executes during object creation, after setting all properties.
function edit_fmax_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fmax_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    data = handles.current_data; % load current_data
    data_name = handles.filename;
    [~,dat_name,ext] = fileparts(data_name);
% set redconf input
    datax = data(:,2);
    timex = data(:,1);
    % dt = handles.mean;
    dt = median(diff(timex));
    unit = handles.unit;
    filename = handles.filename;
    nlength = length(datax);
    method = handles.method;
    df = 1/(timex(nlength)-timex(1));
    check_plot_fmax = get(handles.radiobutton_fmax,'Value');
    plot_fmax_input = str2double(get(handles.edit_fmax_input,'String'));
    nw = handles.ntapers;
    bw=2*nw*df;
if handles.pad > 0
    padtimes = str2double(get(handles.edit3,'String'));
    nzeropad = nlength*padtimes;
else
    nzeropad = str2double(get(handles.edit4,'String'));
end

if check_plot_fmax >0
    fmax = handles.nyquist;
else
    fmax = plot_fmax_input;
end

if strcmp(method,'Multi-taper method')
    if padtimes > 1
        [po,w]=pmtm(datax,nw,nzeropad);
    else 
        [po,w]=pmtm(datax,nw);
    end
        fd1=w/(2*pi*dt);
        % Plot figure MTM
    figure;  
    figHandle = gcf;
    colordef white;
    plot(fd1,po,'LineWidth',1); 
    line([0.7*fmax, 0.7*fmax+bw],[0.8*max(po), 0.8*max(po)],'Color','r')
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    legend('Power','bw')
    title([num2str(nw),' PI MTM method',' ','; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[num2str(filename),' ',num2str(nw),'PI MTM'])
    xlim([0 fmax]);
    set(gca,'XMinorTick','on','YMinorTick','on')
    
%    filename_mtm = [dat_name,'-',num2str(nw),'piMTMspectrum.csv'];
%     CDac_pwd; % cd ac_pwd dir
%     dlmwrite(filename_mtm, [fd1,po], 'delimiter', ',', 'precision', 9);
%     cd(pre_dirML); % return to matlab view folder
    
if handles.checkbox_tabtchi == 1
    % Waitbar
    hwaitbar = waitbar(0,'Conventional red noise estimation may take a few minutes...',...    
       'WindowStyle','modal');
    hwaitbar_find = findobj(hwaitbar,'Type','Patch');
    set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
    setappdata(hwaitbar,'canceling',0)
    steps = 6;
    step = 1;
    waitbar(step / steps)

step = 1.5;
    waitbar(step / steps)
    % Prepare redconfidence level data for excel output
    col1='Frequency(cycles/)';
    col2='Power';
    col3='Frequency(cycles/)';
    col4='TheoreticalRed';
    col6='90%tchi2';
    col7='95%tchi2';
    col8='99%tchi2';
    col9='Mean';
    title0 = {col1;col2;col3;col4;col6;col7;col8;col9}';
    Redconf_out1=[fd1,po];

    handles.title0 = title0;
    handles.Redconf_out1 = Redconf_out1;

step = 2;
    waitbar(step / steps)
%     if strcmp(handles.checkbox_tabtchi,'tabtchi')
        step = 2.5;
        waitbar(step / steps)
        [fd,po,theored,tabtchi90,tabtchi95,tabtchi99]=redconftabtchi(datax,nw,dt,nzeropad,2);
           % [Mspecred,~,po,fd,~,tabtchi,theored,rho] = redconf(datax,timex,dt,nsim,nw);
           % Mspecred=Mspecred';
           % theored=theored';
step = 4.5;
    waitbar(step / steps)
        figure(figHandle);
        hold all; plot(fd,theored,'LineWidth',1);
        hold all; plot(fd,[tabtchi90,tabtchi95,tabtchi99],'LineWidth',1);
        legend('Power','bw','Mean','90%','95%','99%')
        set(gca,'XMinorTick','on','YMinorTick','on')
step = 5.5;
    waitbar(step / steps)
    delete(hwaitbar)
    %filename_mtm = [dat_name,'-',num2str(nw),'piMTMspectrum.csv'];
    filename_mtm_cl = [dat_name,'-',num2str(nw),'piMTM-CL.csv'];
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(filename_mtm_cl, [fd,po,theored,tabtchi90,tabtchi95,tabtchi99], 'delimiter', ',', 'precision', 9);
    disp('Refresh the Main Window:')
    %disp(filename_mtm)
    disp(filename_mtm_cl)
    cd(pre_dirML); % return to matlab view folder
else
end  

elseif strcmp(method,'Lomb-Scargle spectrum')
    pfa = [50 10 1 0.01]/100;
    pd = 1 - pfa;
    % timex must be larger than zero
    timex = timex + abs(min(timex));
    [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
    figure;  
    colordef white;
    plot(fd1,po,fd1,pth*ones(size(fd1')),'LineWidth',1); 
    text(0.3*fmax*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    title(['Lomb-Scargle spectrum; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[num2str(filename),': Lomb-Scargle spectrum'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([0 fmax]);
    filename_LS = [dat_name,'-Lomb-Scargle.csv'];
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(filename_LS, [fd1,po,(pth*ones(size(fd1')))'], 'delimiter', ',', 'precision', 9);
    cd(pre_dirML); % return to matlab view folder
    disp('Refresh the Main Window:')
    disp(filename_LS)
    
elseif  strcmp(method,'Periodogram')
    if padtimes > 1
        [po,fd1] = periodogram(datax,[],nzeropad,1/dt);
    else 
        [po,fd1]=periodogram(datax,[],[],1/dt);
    end
    figure;  
    colordef white;
    plot(fd1,po,'LineWidth',1);
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[num2str(filename),': periodogram'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([0 fmax]);
    if handles.checkbox_tabtchi == 1
        [theored]=theoredar1ML(datax,fd1,mean(po),dt);
        tabtchired90 = theored * 2*gammaincinv(90/100,2)/(2*2);
        tabtchired95 = theored * 2*gammaincinv(95/100,2)/(2*2);
        tabtchired99 = theored * 2*gammaincinv(99/100,2)/(2*2);
        tabtchired999 = theored * 2*gammaincinv(99.9/100,2)/(2*2);
        hold on
        plot(fd1,theored,'LineWidth',1)
        plot(fd1,tabtchired90,'LineWidth',1)
        plot(fd1,tabtchired95,'LineWidth',1)
        plot(fd1,tabtchired99,'LineWidth',1)
        plot(fd1,tabtchired999,'LineWidth',1)
        legend('Power','Mean','90%','95%','99%','99.9')
        set(gca,'XMinorTick','on','YMinorTick','on')
        hold off
    end
    filename_Periodogram = [dat_name,'-Periodogram.csv'];
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(filename_Periodogram, [fd1,po,theored,tabtchired90,tabtchired95,tabtchired99,tabtchired999], ...
        'delimiter', ',', 'precision', 9);
    cd(pre_dirML); % return to matlab view folder
    disp('Refresh the Main Window:')
    disp(filename_Periodogram)
else
end
guidata(hObject,handles);
    

% --- Executes on button press in radiobutton_fmax.
function radiobutton_fmax_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_fmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_fmax

val = get(handles.radiobutton_fmax,'Value');
if val > 0
    set(handles.edit_fmax_input, 'Enable', 'off');
    handles.plot_fmax = handles.nyquist;
else
    set(handles.evofft_fmax_edit, 'Enable', 'on');
end

guidata(hObject, handles);


% --- Executes on button press in radiobutton_input.
function radiobutton_input_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_input
val = get(handles.radiobutton_input,'Value');
if val > 0
    set(handles.edit_fmax_input, 'Enable', 'on');
    handles.plot_fmax = str2double(get(handles.edit_fmax_input, 'String'));
else 
    handles.plot_fmax = handles.nyquist;
end
guidata(hObject, handles);


% --- Executes on button press in checkbox_tabtchi.
function checkbox_tabtchi_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tabtchi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_tabtchi

check_checkbox_tabtchi = get(hObject,'Value');
handles.checkbox_tabtchi = check_checkbox_tabtchi;
guidata(hObject, handles);

function edit_nsimulation_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nsimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nsimulation as text
%        str2double(get(hObject,'String')) returns contents of edit_nsimulation as a double


% --- Executes during object creation, after setting all properties.
function edit_nsimulation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nsimulation (see GCBO)
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


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
handles.pad = get(handles.radiobutton3,'Value');
if handles.pad > 0
    set(handles.edit4,'Enable','Off')
    set(handles.edit3,'Enable','On')
    set(handles.radiobutton4,'Value',0)
else
    set(handles.edit4,'Enable','On')
    set(handles.edit3,'Enable','Off')
    set(handles.radiobutton4,'Value',1)
end
guidata(hObject, handles);

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
handles.pad4 = get(handles.radiobutton4,'Value');
if handles.pad4 > 0
    set(handles.edit4,'Enable','On')
    set(handles.edit3,'Enable','Off')
    set(handles.radiobutton3,'Value',0)
else
    set(handles.edit4,'Enable','Off')
    set(handles.edit3,'Enable','On')
    set(handles.radiobutton3,'Value',1)
end
guidata(hObject, handles);

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
handles.index_selected  = get(hObject,'Value');
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
contents = cellstr(get(hObject,'String'));
handles.method = contents{get(hObject,'Value')};
% if strcmp(handles.method, 'Periodogram')
%     set(handles.checkbox_tabtchi,'enable','off')
% else
%     set(handles.checkbox_tabtchi,'enable','on')
% end
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    data = handles.current_data; % load current_data
    data_name = handles.filename;
    [~,dat_name,ext] = fileparts(data_name);
% set redconf input
    datax = data(:,2);
    timex = data(:,1);
    dt = median(diff(timex));
    unit = handles.unit;
    filename = handles.filename;
    nlength = length(datax);
    method = handles.method;
    df = 1/(timex(nlength)-timex(1));
    check_plot_fmax = get(handles.radiobutton_fmax,'Value');
    plot_fmax_input = str2double(get(handles.edit_fmax_input,'String'));
    nw = handles.ntapers;
    bw=2*nw*df;
if handles.pad > 0
    padtimes = str2double(get(handles.edit3,'String'));
    nzeropad = nlength*padtimes;
else
    nzeropad = str2double(get(handles.edit4,'String'));
end

if check_plot_fmax == 1
    fmax = handles.nyquist;
else
    fmax = plot_fmax_input;
end

if strcmp(method,'Multi-taper method')
    if padtimes > 1
        [po,w]=pmtm(datax,nw,nzeropad);
    else 
        [po,w]=pmtm(datax,nw);
    end
        fd1=w/(2*pi*dt);
        % Plot figure MTM
    figure;  
    figHandle = gcf;
    colordef white;
    plot(fd1,po,'LineWidth',1); 
    line([0.7*fmax, 0.7*fmax+bw],[0.8*max(po), 0.8*max(po)],'Color','r')
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    legend('Power','bw')
    title([num2str(nw),' PI MTM method',' ','; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[num2str(filename),' ',num2str(nw),'PI MTM'])
    xlim([0 fmax]);

if handles.checkbox_tabtchi == 1
    % Waitbar
    hwaitbar = waitbar(0,'Conventional red noise estimation may take a few minutes...',...    
       'WindowStyle','modal');
    hwaitbar_find = findobj(hwaitbar,'Type','Patch');
    set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
    setappdata(hwaitbar,'canceling',0)
    steps = 6;
    step = 1;
    waitbar(step / steps)

step = 1.5;
    waitbar(step / steps)
    % Prepare redconfidence level data for excel output
    col1='Frequency(cycles/)';
    col2='Power';
    col3='Frequency(cycles/)';
    col4='TheoreticalRed';
    col6='90%tchi2';
    col7='95%tchi2';
    col8='99%tchi2';
    col9='Mean';
    title0 = {col1;col2;col3;col4;col6;col7;col8;col9}';
    Redconf_out1=[fd1,po];

    handles.title0 = title0;
    handles.Redconf_out1 = Redconf_out1;

step = 2;
    waitbar(step / steps)
        step = 2.5;
        waitbar(step / steps)
        [fd,po,theored,tabtchi90,tabtchi95,tabtchi99]=redconftabtchi(datax,nw,dt,nzeropad,2);
step = 4.5;
    waitbar(step / steps)

        figure(figHandle);
        hold all; plot(fd,theored,'LineWidth',1);
        hold all; plot(fd,[tabtchi90,tabtchi95,tabtchi99],'LineWidth',1);
        legend('Power','bw','Mean','90%','95%','99%')
step = 5.5;
waitbar(step / steps)
delete(hwaitbar)
else
end  

elseif strcmp(method,'Lomb-Scargle spectrum')
    pfa = [50 10 1 0.01]/100;
    pd = 1 - pfa;
    
    timex = timex + abs(min(timex));
    %[po,fd1,pth] = plomb(datax,timex,fmax,'normalized','Pd',pd);
    [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
    figure;  
    colordef white;
    plot(fd1,po,fd1,pth*ones(size(fd1')),'LineWidth',1); 
    text(0.3*fmax*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    title(['Lomb-Scargle spectrum; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[num2str(filename),': Lomb-Scargle spectrum'])
    xlim([0 fmax]);
%     filename_mtm = [dat_name,'-Lomb-Scargle.csv'];
%     dlmwrite(filename_mtm, [fd1,po], 'delimiter', ',', 'precision', 9);
elseif  strcmp(method,'Periodogram')
    if padtimes > 1
        [po,fd1] = periodogram(datax,[],nzeropad,1/dt);
    else 
        [po,fd1]=periodogram(datax,[],[],1/dt);
    end
    figure;  
    colordef white;
    plot(fd1,po,'LineWidth',1);
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[num2str(filename),': periodogram'])
    xlim([0 fmax]);
    if handles.checkbox_tabtchi == 1
        [theored]=theoredar1ML(datax,fd1,mean(po),dt);
        tabtchired90 = theored * 2*gammaincinv(90/100,2)/(2*2);
        tabtchired95 = theored * 2*gammaincinv(95/100,2)/(2*2);
        tabtchired99 = theored * 2*gammaincinv(99/100,2)/(2*2);
        tabtchired999 = theored * 2*gammaincinv(99.9/100,2)/(2*2);
        hold on
        plot(fd1,theored,'LineWidth',1)
        plot(fd1,tabtchired90,'LineWidth',1)
        plot(fd1,tabtchired95,'LineWidth',1)
        plot(fd1,tabtchired99,'LineWidth',1)
        plot(fd1,tabtchired999,'LineWidth',1)
        legend('Power','Mean','90%','95%','99%','99.9')
    end
else
end
guidata(hObject,handles);
