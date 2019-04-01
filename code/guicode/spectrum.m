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
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
if ismac
    set(gcf,'position',[0.45,0.5,0.28,0.3]) % set position
elseif ispc
    set(gcf,'position',[0.45,0.5,0.4,0.4]) % set position
end
set(handles.text7,'position', [0.05,0.875,0.235,0.06])
set(handles.popupmenu2,'position', [0.3,0.823,0.62,0.12])

set(handles.uipanel2,'position', [0.05,0.41,0.445,0.37])
set(handles.text3,'position', [0.04,0.8,0.483,0.176])
set(handles.popupmenu_tapers,'position', [0.523,0.635,0.443,0.365])
set(handles.text5,'position', [0.055,0.486,0.436,0.176])
set(handles.radiobutton3,'position', [0.503,0.405,0.195,0.311])
set(handles.edit3,'position', [0.664,0.419,0.154,0.23])
set(handles.text6,'position', [0.859,0.446,0.081,0.176])
set(handles.radiobutton4,'position', [0.503,0.054,0.195,0.365])
set(handles.edit4,'position', [0.664,0.089,0.3,0.23])

set(handles.uipanel3,'position', [0.05,0.082,0.445,0.32])
set(handles.checkbox_robust,'position', [0.2,0.516,0.75,0.37])
set(handles.checkbox_tabtchi,'position', [0.2,0.177,0.75,0.37])

set(handles.uibuttongroup1,'position', [0.5,0.31,0.45,0.47])
set(handles.radiobutton_fmax,'position', [0.089,0.638,0.473,0.324])
set(handles.text_nyquist,'position', [0.541,0.723,0.356,0.183])
set(handles.radiobutton_input,'position', [0.089,0.349,0.4,0.325])
set(handles.edit_fmax_input,'position', [0.541,0.384,0.356,0.267])
set(handles.checkbox4,'position', [0.089,0.07,0.507,0.267])
set(handles.checkbox5,'position', [0.541,0.07,0.507,0.267])

set(handles.pushbutton17,'position', [0.5,0.082,0.166,0.12])
set(handles.pushbutton3,'position', [0.67,0.082,0.282,0.12])

set(handles.checkbox_tabtchi,'String','Classical AR(1)')
% Choose default command line output for spectrum
handles.output = hObject;

set(gcf,'Name','Acycle: Spectral Analysis')
set(handles.checkbox_robust,'Value',1)
set(handles.checkbox_tabtchi,'Value',0)
set(handles.radiobutton4,'Value',1)
set(handles.radiobutton3,'Value',0)
set(handles.checkbox4,'Value',0)
set(handles.checkbox5,'Value',1)
set(handles.radiobutton_fmax,'Value',1)
set(handles.radiobutton_input,'Value',0)
% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
data_s = varargin{1}.current_data;
handles.current_data = data_s;
handles.filename = varargin{1}.data_name;
handles.unit = varargin{1}.unit;
handles.path_temp = varargin{1}.path_temp;
handles.linlogY = 1;
handles.pad = 1;
handles.checkbox_tabtchi_v = 0;
handles.checkbox_robustAR1_v = 1;
handles.ntapers = 2;
handles.datasample = 0;  % warning of sampling rate: uneven = 1
Dt = diff(data_s(:,1));
if max(Dt) - min(Dt) > 10 * eps('single')
    handles.datasample = 1;
    handles.method ='Lomb-Scargle spectrum';
    set(handles.popupmenu2, 'Value', 2);
    set(handles.popupmenu_tapers,'Enable','off')
    set(handles.checkbox_robust,'Enable','off')
    set(handles.checkbox_robust,'Value',0)
    set(handles.checkbox_tabtchi,'Value',0)
    set(handles.checkbox_tabtchi,'String','White noise')
else
    handles.method ='Multi-taper method';
    set(handles.popupmenu2, 'Value', 1);
    set(handles.popupmenu_tapers, 'Value', 1);
end

handles.mean = mean(Dt);
handles.nyquist = 1/(2*handles.mean);     % prepare nyquist
set(handles.text_nyquist, 'String', num2str(handles.nyquist));
set(handles.edit4, 'String', num2str(length(data_s(:,1))));
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
figspectrum = gcf;
data = handles.current_data; % load current_data
data_name = handles.filename;
[~,dat_name,ext] = fileparts(data_name);
% set redconf input
datax = data(:,2);
timex = data(:,1);
diffx = diff(timex);

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

if check_plot_fmax > 0
    fmax = handles.nyquist;
else
    fmax = plot_fmax_input;
end

if strcmp(method,'Multi-taper method')
    if max(diffx) - min(diffx) > 10 * eps('single')
        figwarn = warndlg({'Data may be interpolated to an uniform sampling interval';...
            '';'    Or select : Lomb-Scargle spectrum'});
        set(figwarn,'units','norm') % set location
        set(figwarn,'position',[0.5,0.8,0.225,0.09]) % set position
    end
    if handles.checkbox_robustAR1_v == 1
        dlg_title = 'Robust AR(1) Estimation';
        prompt = {'Median smoothing window: default 0.2 = 20%';...
            'AR1 best fit model? 1 = linear; 2 = log power'};
        num_lines = 1;
        defaultans = {num2str(0.2),num2str(2)};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
        
        if ~isempty(answer)
            smoothwin = str2double(answer{1});
            linlog = str2double(answer{2});
            if length(datax)>2000
                hwarn = warndlg('Large dataset, wait ...');
            end
            [rhoM, s0M,redconfAR1,redconfML96]=redconfML(datax,dt,nw,nzeropad,linlog,smoothwin,fmax,1);
            try close(hwarn)
            catch
            end
            name1 = [dat_name,'-',num2str(nw),'piMTM-RobustAR1',ext];
            data1 = redconfML96;
            name2 = [dat_name,'-',num2str(nw),'piMTM-ConvenAR1',ext];
            data2 = redconfAR1;
            
            title([dat_name,'-',num2str(nw),'\pi-MTM-Robust-AR1: \rho = ',num2str(rhoM),'. S0 =',num2str(s0M)])
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
            set(gca,'XMinorTick','on','YMinorTick','on')
            xlim([0 fmax]);
            set(gcf,'Color', 'white')
            if handles.linlogY == 1;
                set(gca, 'YScale', 'log')
            else
                set(gca, 'YScale', 'linear')
            end
            figdata = gcf;
            CDac_pwd;
            dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
            dlmwrite(name2, data2, 'delimiter', ',', 'precision', 9);
            disp('>>  Refresh main window to see red noise estimation data files: ')
            disp(name1)
            disp(name2)
            cd(pre_dirML);
        else
            return
        end
    
    end
    
    if padtimes > 1
        [po,w]=pmtm(datax,nw,nzeropad);
    else 
        [po,w]=pmtm(datax,nw);
    end
        fd1=w/(2*pi*dt);
        % Plot figure MTM
        
    if handles.checkbox_robustAR1_v == 0
        figdata = figure;
        figHandle = gcf;
        set(gcf,'Color', 'white')
        plot(fd1,po,'LineWidth',1); 
        line([0.7*fmax, 0.7*fmax+bw],[0.8*max(po), 0.8*max(po)],'Color','r')
        xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
        ylabel('Power ')
        legend('Power','bw')
        title([num2str(nw),'\pi MTM method',' ','; Sampling rate = ',num2str(dt),' ', unit])
        set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
        xlim([0 fmax]);
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1;
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
    end
    
if handles.checkbox_tabtchi_v == 1
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
    xlim([0 fmax]);
    if handles.linlogY == 1;
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    %filename_mtm = [dat_name,'-',num2str(nw),'piMTMspectrum.txt'];
    filename_mtm_cl = [dat_name,'-',num2str(nw),'piMTM-CL.txt'];
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(filename_mtm_cl, [fd,po,theored,tabtchi90,tabtchi95,tabtchi99], 'delimiter', ',', 'precision', 9);
    disp('>>  Refresh the Main Window to see output data')
    %disp(filename_mtm)
    disp(filename_mtm_cl)
    cd(pre_dirML); % return to matlab view folder
    figdata = figHandle;
else
end  

elseif strcmp(method,'Lomb-Scargle spectrum')
    pfa = [50 10 1 0.01]/100;
    pd = 1 - pfa;
    % timex must be larger than zero
    timex = timex + abs(min(timex));
    [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
    figdata = figure;  
    set(gcf,'Color', 'white')
    if handles.checkbox_tabtchi_v == 1
        plot(fd1,po,fd1,pth*ones(size(fd1')),'LineWidth',1); 
        text(0.3*fmax*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
    else
        plot(fd1,po,'LineWidth',1); 
    end
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    title(['Lomb-Scargle spectrum; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[dat_name,ext,': Lomb-Scargle spectrum'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([0 fmax]);
    if handles.linlogY == 1;
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    filename_LS = [dat_name,'-Lomb-Scargle.txt'];
    CDac_pwd; % cd ac_pwd dir
    dlmwrite(filename_LS, [fd1,po,(pth*ones(size(fd1')))'], 'delimiter', ',', 'precision', 9);
    cd(pre_dirML); % return to matlab view folder
    disp('Refresh the Main Window:')
    disp(filename_LS)
    
elseif  strcmp(method,'Periodogram')
    if max(diffx) - min(diffx) > 10 * eps('single')
        figwarn = warndlg({'Data may be interpolated to an uniform sampling interval';...
            '';'    Or select : Lomb-Scargle spectrum'});
    end
    if padtimes > 1
        [po,fd1] = periodogram(datax,[],nzeropad,1/dt);
    else 
        [po,fd1]=periodogram(datax,[],[],1/dt);
    end
    figdata = figure;  
    set(gcf,'Color', 'white')
    plot(fd1,po,'k-','LineWidth',1);
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[dat_name,ext,': periodogram'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([0 fmax]);
    if handles.linlogY == 1;
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    if handles.checkbox_tabtchi_v == 1
        [theored]=theoredar1ML(datax,fd1,mean(po),dt);
        tabtchired90 = theored * chi2inv(90/100,2)/2;
        tabtchired95 = theored * chi2inv(95/100,2)/2;
        tabtchired99 = theored * chi2inv(99/100,2)/2;
        tabtchired999 = theored * chi2inv(99.9/100,2)/2;
%         tabtchired90 = theored * 2*gammaincinv(90/100,2)/(2*2);
%         tabtchired95 = theored * 2*gammaincinv(95/100,2)/(2*2);
%         tabtchired99 = theored * 2*gammaincinv(99/100,2)/(2*2);
%         tabtchired999 = theored * 2*gammaincinv(99.9/100,2)/(2*2);
        hold on
        plot(fd1,theored,'k-','LineWidth',2)
        plot(fd1,tabtchired90,'r-','LineWidth',1)
        plot(fd1,tabtchired95,'r--','LineWidth',2)
        plot(fd1,tabtchired99,'b-.','LineWidth',1)
        plot(fd1,tabtchired999,'g:','LineWidth',1)
        legend('Power','Mean','90%','95%','99%','99.9')
        hold off
    end
    filename_Periodogram = [dat_name,'-Periodogram.txt'];
    CDac_pwd; % cd ac_pwd dir
try    dlmwrite(filename_Periodogram, [fd1,po,theored,tabtchired90,tabtchired95,tabtchired99,tabtchired999], ...
        'delimiter', ',', 'precision', 9);
catch
    dlmwrite(filename_Periodogram, [fd1,po], ...
        'delimiter', ',', 'precision', 9);
end
    cd(pre_dirML); % return to matlab view folder
    disp(filename_Periodogram)
else
end

% refresh AC main window
figure(handles.acfigmain);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir
figure(figspectrum);
try figure(figwarn); 
catch
end
try figure(figdata);
    set(figdata,'units','norm') % set location
    set(figdata,'position',[0.05,0.4,0.45,0.45]) % set position
catch
end% return plot
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

checkbox_tabtchi_v = get(hObject,'Value');
handles.checkbox_tabtchi_v = checkbox_tabtchi_v;
guidata(hObject, handles);

% --- Executes on button press in checkbox_robustAR1.
function checkbox_robust_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_robust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_tabtchi
checkbox_robustAR1 = get(hObject,'Value');
handles.checkbox_robustAR1_v = checkbox_robustAR1;
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


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
linY = get(handles.checkbox4,'Value');
if linY > 0
    handles.linlogY = 0;
    set(handles.checkbox5,'Value',0)
else
    handles.linlogY = 1;
    set(handles.checkbox5,'Value',1)
end
guidata(hObject, handles);

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
logY = get(handles.checkbox5,'Value');
if logY > 0
    handles.linlogY = 1;
    set(handles.checkbox4,'Value',0)
else
    handles.linlogY = 0;
    set(handles.checkbox4,'Value',1)
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
method = contents{get(hObject,'Value')};
handles.method = method;
if strcmp(method,'Multi-taper method')
    if handles.datasample == 1
        msgbox('Sampling rate may not be uneven! Ignore if this is not ture.','Waning')
    end
    set(handles.popupmenu_tapers,'Enable','on')
    set(handles.checkbox_robust,'Enable','on')
    set(handles.checkbox_tabtchi,'Enable','on')
    set(handles.checkbox_tabtchi,'String','Classical AR(1)')
elseif strcmp(method,'Periodogram')
    if handles.datasample == 1
        msgbox('Sampling rate may not be uneven! Ignore if this is not ture.','Waning')
    end
    set(handles.popupmenu_tapers,'Enable','off')
    set(handles.checkbox_robust,'Enable','off')
    set(handles.checkbox_tabtchi,'Enable','on')
    set(handles.checkbox_tabtchi,'String','Classical AR(1)')
elseif strcmp(method,'Lomb-Scargle spectrum')
    set(handles.popupmenu_tapers,'Enable','off')
    set(handles.checkbox_robust,'Enable','off')
    set(handles.checkbox_robust,'Value',0)
    set(handles.checkbox_tabtchi,'Value',0)
    set(handles.checkbox_tabtchi,'String','White noise')
else
    
end
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
figspectrum = gcf;
data = handles.current_data; % load current_data
data_name = handles.filename;
[~,dat_name,ext] = fileparts(data_name);
% set redconf input
datax = data(:,2);
timex = data(:,1);
diffx = diff(timex);
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
    if max(diffx) - min(diffx) > 10 * eps('single')
        figwarn = warndlg({'Data may be interpolated to an uniform sampling interval';...
            '';'    Or select : Lomb-Scargle spectrum'});
        set(figwarn,'units','norm') % set location
        set(figwarn,'position',[0.5,0.8,0.225,0.09]) % set position
    end
    if handles.checkbox_robustAR1_v == 1
        dlg_title = 'Robust AR(1) Estimation';
        prompt = {'Median smoothing window: default 0.2 = 20%';...
            'AR1 best fit model? 1 = linear; 2 = log power'};
        num_lines = 1;
        defaultans = {num2str(0.2),num2str(2)};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);

        if ~isempty(answer)
            smoothwin = str2double(answer{1});
            linlog = str2double(answer{2});
            
            if length(datax)>2000
                hwarn = warndlg('Large dataset, wait ...');
            end
                [rhoM, s0M,redconfAR1,redconfML96]=redconfML(datax,dt,nw,nzeropad,linlog,smoothwin,fmax,1);
            try close(hwarn)
            catch
            end
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            title([num2str(nw),'\pi-MTM-Robust-AR(1): \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M)])
            set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
            set(gca,'XMinorTick','on','YMinorTick','on')
            set(gcf,'Color', 'white')
            if handles.linlogY == 1;
                set(gca, 'YScale', 'log')
            else
                set(gca, 'YScale', 'linear')
            end
            figdata = gcf;
        else
            return
        end
    end
    
    if padtimes > 1
        [po,w]=pmtm(datax,nw,nzeropad);
    else 
        [po,w]=pmtm(datax,nw);
    end
        fd1=w/(2*pi*dt);
        % Plot figure MTM handles.checkbox_robustAR1_v = checkbox_robustAR1;
    if handles.checkbox_robustAR1_v == 0
        figdata = figure;  
        figHandle = gcf;
        set(gcf,'Color', 'white')
        plot(fd1,po,'LineWidth',1); 
        line([0.7*fmax, 0.7*fmax+bw],[0.8*max(po), 0.8*max(po)],'Color','r')
        xlabel(['Frequency (cycles/',num2str(unit),')']) 
        ylabel('Power ')
        legend('Power','bw')
        title([num2str(nw),' \pi MTM method',' ','; Sampling rate = ',num2str(dt),' ', unit])
        set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
        set(gca,'XMinorTick','on','YMinorTick','on')
        xlim([0 fmax]);
        if handles.linlogY == 1;
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
    end 

if handles.checkbox_tabtchi_v == 1
    % Waitbar
    hwaitbar = waitbar(0,'Conventional red noise estimation may take a few minutes...',...    
       'WindowStyle','modal');
    hwaitbar_find = findobj(hwaitbar,'Type','Patch');
    set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
    %setappdata(hwaitbar,'canceling',0)
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
if handles.linlogY == 1;
    set(gca, 'YScale', 'log')
else
    set(gca, 'YScale', 'linear')
end
else
    figdata = gcf;
end  

elseif strcmp(method,'Lomb-Scargle spectrum')
    pfa = [50 10 1 0.01]/100;
    pd = 1 - pfa;
    timex = timex + abs(min(timex));
    %[po,fd1,pth] = plomb(datax,timex,fmax,'normalized','Pd',pd);
    [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
    figdata = figure;
    colordef white;
    if handles.checkbox_tabtchi_v == 1
        plot(fd1,po,fd1,pth*ones(size(fd1')),'LineWidth',1); 
        text(0.3*fmax*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
    else
        plot(fd1,po,'LineWidth',1); 
    end
    
    xlabel(['Frequency (cycles/',num2str(unit),')']) 
    ylabel('Power ')
    title(['Lomb-Scargle spectrum; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[dat_name,ext,': Lomb-Scargle spectrum'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([0 fmax]);
    if handles.linlogY == 1;
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
%     filename_mtm = [dat_name,'-Lomb-Scargle.txt'];
%     dlmwrite(filename_mtm, [fd1,po], 'delimiter', ',', 'precision', 9);
elseif  strcmp(method,'Periodogram')
    
    if max(diffx) - min(diffx) > 10 * eps('single')
        figwarn = warndlg({'Data may be interpolated to an uniform sampling interval';...
            '';'    Or select : Lomb-Scargle spectrum'});
    end
    if padtimes > 1
        [po,fd1] = periodogram(datax,[],nzeropad,1/dt);
    else 
        [po,fd1]=periodogram(datax,[],[],1/dt);
    end
    figdata = figure;  
    set(gcf,'Color', 'white')
    plot(fd1,po,'k-','LineWidth',1);
    xlabel(['Frequency (cycles/',num2str(unit),')']) 
    ylabel('Power ')
    title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[dat_name,ext,': periodogram'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([0 fmax]);
    if handles.linlogY == 1;
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    if handles.checkbox_tabtchi_v == 1
        [theored]=theoredar1ML(datax,fd1,mean(po),dt);
        tabtchired90 = theored * chi2inv(90/100,2)/2;
        tabtchired95 = theored * chi2inv(95/100,2)/2;
        tabtchired99 = theored * chi2inv(99/100,2)/2;
        tabtchired999 = theored * chi2inv(99.9/100,2)/2;
%         tabtchired90 = theored * 2*gammaincinv(90/100,2)/(2*2);
%         tabtchired95 = theored * 2*gammaincinv(95/100,2)/(2*2);
%         tabtchired99 = theored * 2*gammaincinv(99/100,2)/(2*2);
%         tabtchired999 = theored * 2*gammaincinv(99.9/100,2)/(2*2);
        hold on
        plot(fd1,theored,'k-','LineWidth',2)
        plot(fd1,tabtchired90,'r-','LineWidth',1)
        plot(fd1,tabtchired95,'r--','LineWidth',2)
        plot(fd1,tabtchired99,'b-.','LineWidth',1)
        plot(fd1,tabtchired999,'g:','LineWidth',1)
        legend('Power','Mean','90%','95%','99%','99.9')
    end
else
end
% refresh AC main window
figure(handles.acfigmain);
CDac_pwd; % cd working dir
refreshcolor;
cd(pre_dirML); % return view dir
figure(figspectrum);

try figure(figwarn);
catch
end
try figure(figdata); 
    set(figdata,'units','norm') % set location
    set(figdata,'position',[0.05,0.4,0.45,0.45]) % set position
catch
end
guidata(hObject,handles);
