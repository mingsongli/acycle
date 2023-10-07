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

% Last Modified by GUIDE v2.5 07-Oct-2023 22:36:48

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

%% LOG
%

% --- Executes just before spectrum is made visible.
function spectrum_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spectrum (see VARARGIN)
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.lang_choice = varargin{1}.lang_choice;
handles.lang_id = varargin{1}.lang_id;
handles.lang_var = varargin{1}.lang_var;
lang_id = handles.lang_id;
lang_var = handles.lang_var;
handles.main_unit_selection = varargin{1}.main_unit_selection;

set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
if ismac
    set(gcf,'position',[0.45,0.5,0.3,0.33]* handles.MonZoom) % set position
elseif ispc
    set(gcf,'position',[0.45,0.5,0.3,0.33]* handles.MonZoom) % set position
end
set(handles.text7,'position', [0.05,0.875,0.235,0.06])
set(handles.popupmenu2,'position', [0.3,0.823,0.62,0.12])

set(handles.uipanel2,'position', [0.05,0.41,0.445,0.37])
set(handles.text3,'position', [0.04,0.6,0.6,0.38])
set(handles.popupmenu_tapers,'position', [0.6,0.635,0.38,0.365])
set(handles.text5,'position', [0.055,0.4,0.436,0.176])
set(handles.radiobutton5,'position', [0.503,0.5,0.12,0.2])
set(handles.radiobutton5,'Value', 0)
set(handles.edit7,'position', [0.664,0.5,0.3,0.2])
set(handles.edit7,'String', '2.0')
set(handles.edit7,'Enable', 'off')

set(handles.radiobutton3,'position', [0.05,0.054,0.14,0.311])
set(handles.edit3,'position', [0.19,0.089,0.154,0.23])
set(handles.text6,'position', [0.35,0.12,0.081,0.176])
set(handles.radiobutton4,'position', [0.503,0.054,0.195,0.365])
set(handles.edit4,'position', [0.664,0.089,0.3,0.23])

set(handles.uipanel3,'position', [0.05,0.082,0.445,0.32])
set(handles.checkbox_robust,'position', [0.05,0.65,0.7,0.3])
set(handles.checkbox_ar1_check,'position', [0.05,0.35,0.7,0.3])
set(handles.check_ftest,'position', [0.05,0.05,0.5,0.3])
set(handles.check_ftest,'Value', 0, 'tooltip','F-test and amplitude spectrum')
set(handles.checkbox9,'position',  [0.65,0.65,0.35,0.3])
set(handles.checkbox10,'position', [0.65,0.35,0.35,0.3])
set(handles.checkboxSWA,'position', [0.65,0.05,0.35,0.3],'Value',1)
%
set(handles.checkbox9,'tooltip','Power Law')
set(handles.checkbox10,'tooltip','Bending Power Law')
set(handles.checkboxSWA,'tooltip','Smoothed Window Averages')

set(handles.uibuttongroup1,'position', [0.5,0.25,0.45,0.52])

set(handles.text8,'position', [0.02,0.8,0.473,0.15],'String','Freq. min')  % f min
set(handles.edit8,'position', [0.541,0.82,0.356,0.15],'String','0')  % f min

set(handles.radiobutton_fmax,'position', [0.089,0.6,0.473,0.2])
set(handles.text_nyquist,'position', [0.541,0.62,0.356,0.13])
set(handles.radiobutton_input,'position', [0.089,0.4,0.4,0.2])
set(handles.edit_fmax_input,'position', [0.541,0.42,0.356,0.15],'Enable','off')

set(handles.checkbox4,'position', [0.089,0.2,0.507,0.15])
set(handles.checkbox5,'position', [0.5,0.2,0.507,0.15])
set(handles.checkbox6,'position', [0.089,0.05,0.4,0.15])
set(handles.checkbox6,'String', 'log(freq.)')
set(handles.checkbox8,'position', [0.5,0.05,0.48,0.15])
set(handles.checkbox8,'value', 0)

set(handles.pushbutton17,'position', [0.5,0.082,0.166,0.12])
set(handles.pushbutton3,'position', [0.67,0.082,0.282,0.12])

set(handles.checkbox_ar1_check,'String','Classic AR(1)')
% Choose default command line output for spectrum
handles.output = hObject;
if handles.lang_choice == 0
    set(gcf,'Name','Acycle: Spectral Analysis')
else
    [~, locb] = ismember('menu107',handles.lang_id);
    set(gcf,'Name',['Acycle: ',lang_var{locb}])
end
set(handles.checkbox_robust,'Value',1)
set(handles.checkbox_ar1_check,'Value',0)
set(handles.radiobutton4,'Value',1)
set(handles.radiobutton3,'Value',0)
set(handles.checkbox4,'Value',0)
set(handles.checkbox5,'Value',1)
set(handles.checkbox6,'Value', 0)
set(handles.checkbox9,'Value', 0)
set(handles.checkbox10,'Value', 0)
set(handles.checkboxSWA,'Value', 0)
set(handles.radiobutton_fmax,'Value',1)
set(handles.radiobutton_input,'Value',0)
% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
data_s = varargin{1}.current_data;
data_s = sortrows(data_s);
handles.val1 = varargin{1}.val1;

%
data_s(:,2) = data_s(:,2) - mean(data_s(:,2));
handles.current_data = data_s;
handles.filename = varargin{1}.data_name;
handles.unit = varargin{1}.unit;
handles.path_temp = varargin{1}.path_temp;
handles.linlogY = 1;
handles.logfreq = 0;
handles.pad = 1;
handles.checkbox_ar1_v = 0;
handles.checkbox_robustAR1_v = 1;
handles.check_ftest_value = 0;
handles.checkPL = 0;
handles.checkBPL= 0;

handles.timebandwidth = 2;
handles.datasample = 0;  % warning of sampling rate: uneven = 1
Dt = diff(data_s(:,1));

if max(Dt) - min(Dt) > 10 * eps('single')
    handles.datasample = 1;
    handles.method ='Lomb-Scargle spectrum';
    set(handles.popupmenu2, 'Value', 2);
    set(handles.popupmenu_tapers,'Enable','off')
    set(handles.checkbox_robust,'Enable','on')
    set(handles.checkbox_robust,'Value',1)
    set(handles.checkbox_ar1_check,'Value',0)
    set(handles.checkbox_ar1_check,'String','White noise')
    set(handles.check_ftest,'Visible', 'off')
    set(handles.checkboxSWA,'Visible', 'off')
else
    handles.method ='Multi-taper method';
    set(handles.popupmenu2, 'Value', 1);
    set(handles.popupmenu_tapers, 'Value', 1);
    set(handles.check_ftest,'Visible', 'on')
    set(handles.checkboxSWA,'Visible', 'on','Value',1)
end

handles.mean = mean(Dt);
handles.nyquist = 1/(2*handles.mean);     % prepare nyquist
set(handles.text_nyquist, 'String', num2str(handles.nyquist));
set(handles.edit4, 'String', num2str(length(data_s(:,1))));

%  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %
% Oct, 15, 2019
% Mingsong Li
% Add some tricks for ultra-high resolution dataset, 
% which suggest an inappropriate maximum frequency
% Now only considers frequencies that contribute to 99.5% of the total power
% But if the suggested max frequency is very similar to the default Nyquist
% frequency, then the default Nyquist frequency is used.

[po,w]=periodogram(data_s(:,2));
fd1=w/(2*pi*handles.mean); 
handles.ValidNyqFreq = fd1(end);

poc = cumsum(po); % cumsum of power
pocnorm = 100*poc/max(poc); % normalized
% the first elements at which the cumulated power exceed 99%
poc1 = find( pocnorm >= 99, 1);
% if the frequency detected is smaller than 85% of nyquist frequency
% suggest a new input max freq.
if fd1(poc1)/fd1(end) <= 0.85
    handles.ValidNyqFreqR = fd1(poc1);
    handles.BiasCorr = 1;
    set(handles.edit_fmax_input,'String', num2str(fd1(poc1)))
    set(handles.radiobutton_fmax,'Value',0)
    set(handles.radiobutton_input,'Value',1)
else
    handles.BiasCorr = 0;
end
% language
if handles.lang_choice > 0
    [~, locb] = ismember('spectral01',lang_id);
    set(handles.text7,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral02',lang_id);
    set(handles.uipanel2,'Title',lang_var{locb})
    
    [~, locb] = ismember('spectral03',lang_id);
    set(handles.text3,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral04',lang_id);
    set(handles.text5,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral05',lang_id);
    set(handles.uipanel3,'Title',lang_var{locb})
    
    [~, locb] = ismember('spectral06',lang_id);
    set(handles.checkbox_robust,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral07',lang_id);
    set(handles.checkbox_ar1_check,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral08',lang_id);
    set(handles.check_ftest,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral09',lang_id);
    set(handles.checkbox9,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral10',lang_id);
    set(handles.checkbox10,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral12',lang_id);
    set(handles.uibuttongroup1,'Title',lang_var{locb})
    
    [~, locb] = ismember('dd32',lang_id);
    set(handles.text8,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral13',lang_id);
    set(handles.radiobutton_fmax,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral14',lang_id);
    set(handles.radiobutton_input,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral15',lang_id);
    set(handles.checkbox4,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral16',lang_id);
    set(handles.checkbox5,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral17',lang_id);
    set(handles.checkbox6,'String',lang_var{locb}) % log(freq.)
    
    [~, locb] = ismember('spectral18',lang_id);
    set(handles.checkbox8,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral19',lang_id);
    set(handles.pushbutton3,'String',lang_var{locb})
    
    [~, locb] = ismember('spectral20',lang_id);
    set(handles.pushbutton17,'String',lang_var{locb})
    
end
%  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %  %
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
handles.timebandwidth = str2num(contents{get(hObject,'Value')});
% handles.timebandwidth = str2num(get(hObject, 'String'));
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

% RUN
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
plot_x_period = get(handles.checkbox8,'Value');
plot_fmax_input = str2double(get(handles.edit_fmax_input,'String'));
nw = handles.timebandwidth;
bw=2*nw*df;
SelectSWA = get(handles.checkboxSWA,'Value');
fmin = str2double(get(handles.edit8,'String'));
if fmin < 0
    fmin = 0;
end

% language
lang_id = handles.lang_id;
lang_var = handles.lang_var;

BiasCorr = handles.BiasCorr;

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
        %figwarn = warndlg({'Data may be interpolated to an uniform sampling interval';...
        %    '';'    Or select : Lomb-Scargle spectrum'});
        %set(figwarn,'units','norm') % set location
        %set(figwarn,'position',[0.5,0.8,0.225,0.09]) % set position
    end
    
    if handles.checkbox_robustAR1_v == 1
        if handles.lang_choice == 0
            dlg_title = 'Robust AR(1) Estimation';
            prompt = {'Median smoothing window: default 0.2 = 20%';...
                'AR1 best fit model? 1 = linear （default）; 2 = log power';...
                'Bias correction for ultra-high resolution data'};
        else
            [~, locb] = ismember('spectral25',lang_id);
            dlg_title = lang_var{locb};
            [~, locb1] = ismember('spectral26',lang_id);
            [~, locb2] = ismember('spectral27',lang_id);
            [~, locb3] = ismember('spectral28',lang_id);
            prompt = {lang_var{locb1};...
                lang_var{locb2};...
                lang_var{locb3}};
        end
        num_lines = 1;
        if BiasCorr == 0
            defaultans = {num2str(0.2),num2str(1),num2str(0)};
        else
            defaultans = {num2str(0.2),num2str(1),num2str(1)};
        end
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);

        if ~isempty(answer)
            smoothwin = str2double(answer{1});
            linlog = str2double(answer{2});
            biascorr = str2double(answer{3});
            
            if length(datax)>2000
                if handles.lang_choice > 0
                    [~, locb] = ismember('spectral29',lang_id);
                    hwarn = warndlg(lang_var{locb});
                else
                    hwarn = warndlg('Large dataset, wait ...');
                end
            end
            if biascorr == 1
                ValidNyqFreq = handles.ValidNyqFreqR;
                [rhoM, s0M,redconfAR1,redconfML96]=redconfML(datax,dt,nw,nzeropad,linlog,smoothwin,ValidNyqFreq,0);
            else
                ValidNyqFreq = handles.ValidNyqFreq;
                [rhoM, s0M,redconfAR1,redconfML96]=redconfML(datax,dt,nw,nzeropad,linlog,smoothwin,ValidNyqFreq,0);
            end
            try close(hwarn)
            catch
            end
            
            % for plot only
            % Multi-taper method power spectrum
            if nw == 1
                [pxx,w] = pmtm(datax,nw,nzeropad,'DropLastTaper',false);
            else
                [pxx,w] = pmtm(datax,nw,nzeropad);
            end
            % Nyquist frequency
            fn = 1/(2*dt);
            % true frequencies
            f0 = w/pi*fn;
            
            f1 = redconfAR1(:,1);
            pxxsmooth0 = redconfAR1(:,3);
            f = redconfML96(:,1);
            theored1 = redconfML96(:,3);
            chi90 = redconfML96(:,4);
            chi95 = redconfML96(:,5);
            chi99 = redconfML96(:,6);
            
            figdata = figure; 
            set(gcf,'Color', 'white')
            semilogy(f0,pxx,'k')
            hold on; 
            semilogy(f1,pxxsmooth0,'m-.');
            semilogy(f,theored1,'k-','LineWidth',2);
            semilogy(f,chi90,'r-');
            semilogy(f,chi95,'r--','LineWidth',2);
            semilogy(f,chi99,'b-.');
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                ylabel('Power')
                smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
                legend('Power',smthwin,'Robust AR(1) median',...
                    'Robust AR(1) 90%','Robust AR(1) 95%','Robust AR(1) 99%')
            else
                [~, locb] = ismember('spectral30',lang_id);
                ylabel(lang_var{locb})
                [~, locb1] = ismember('spectral31',lang_id);
                smthwin = [num2str(smoothwin*100),'% ', lang_var{locb1}];
                [~, locb6] = ismember('spectral06',lang_id);
                [~, locb1] = ismember('spectral32',lang_id);
                legend(lang_var{locb},smthwin,...
                    [lang_var{locb6},lang_var{locb1}],...
                    [lang_var{locb6},'90%'],...
                    [lang_var{locb6},'95%'],...
                    [lang_var{locb6},'99%'])
            end
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.0,0.45,0.45,0.45]) % set position
            
            if plot_x_period
                update_spectral_x_period_mtm
            else
                if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                    xlabel(['Frequency (cycles/',num2str(unit),')']) 
                    title([num2str(nw),'\pi-MTM-Robust-AR(1): \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M),'; bw = ',num2str(bw)])   
                else
                    [~, locb] = ismember('spectral33',lang_id);
                    [~, locb1] = ismember('spectral34',lang_id);
                    xlabel([lang_var{locb},num2str(unit),')']) 
                    title([num2str(nw),'\pi-MTM-',lang_var{locb6},': \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M),'; ',lang_var{locb1},' = ',num2str(bw)])   
                end
                xlim([fmin fmax]);
                set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
                set(gca,'XMinorTick','on','YMinorTick','on')
                set(gcf,'Color', 'white')
                if handles.linlogY == 1
                    set(gca, 'YScale', 'log')
                else
                    set(gca, 'YScale', 'linear')
                end
                if handles.logfreq == 1
                    set(gca,'xscale','log')
                end
            end
            
        else
            return
        end
    end
    
    if padtimes > 1
        if nw == 1
            [po,w]=pmtm(datax,nw,nzeropad,'DropLastTaper',false);
        else
            [po,w]=pmtm(datax,nw,nzeropad);
        end
    else
        if nw == 1
            [po,w]=pmtm(datax,nw,'DropLastTaper',false);
        else
            [po,w]=pmtm(datax,nw);
        end
    end
    fd1=w/(2*pi*dt);
    
    % power law
    if handles.checkPL == 1
        K = 2*nw -1;
        nw2 = 2*(K);
        
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2; 
        pf = polyfit(log(fd1(2:end)),log(po(2:end)),1);
        % Evaluating Coefficients
        a = pf(1);
        % Accounting for the log transformation
        k = exp(pf(2));
        %ezplot(@(X) k*X.^a,[X(1) X(end)])
        pl = k * fd1.^a;
        % local c.l.
        red90 = pl * chi2inv(0.9,nw2)/nw2;
        red95 = pl * chi2inv(0.95,nw2)/nw2;
        red99 = pl * chi2inv(0.99,nw2)/nw2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),nw2)/nw2;
        red95global = pl * chi2inv((1-alpha95),nw2)/nw2;
        red99global = pl * chi2inv((1-alpha99),nw2)/nw2;
        
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            if fmin <= 0 
                fmin_s = pt(3);
            else
                fmin_s = 1/fmin;
            end

            xlim([1/fmax, fmin_s]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')']) 
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
            ylabel('Power')
            title([num2str(nw),'\pi MTM & power law','; bw = ',num2str(bw)])   
            set(gcf,'Name',[num2str(nw),'pi MTM & power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral09',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            title([num2str(nw),'\pi MTM & ',lang_var{locb3},'; ',lang_var{locb0},' = ',num2str(bw)])  
            set(gcf,'Name',[num2str(nw),'pi MTM & ',lang_var{locb3},': ',dat_name,ext])
        end
        
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % bending power law
    if handles.checkBPL == 1
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2;
        pol = log(po);
        pol = real(pol);
        fun = @(v,f)(v(1) * f .^(-1 * v(2)))./(1 + (f / v(4)) .^ (v(3)-v(2)));
        v0 = [100,0.5,3,0.5*fd1(end)];
        x = lsqcurvefit(fun,v0,fd1(2:end),pol(2:end));
        theored1 = exp(fun(x,fd1)); % bending power law fit
        K = 2*nw -1;
        nw2 = 2*(K);
        % Chi-square inversed distribution
        % local c.l.
        red90 = theored1 * chi2inv(0.90,nw2)/nw2;
        red95 = theored1 * chi2inv(0.95,nw2)/nw2;
        red99 = theored1 * chi2inv(0.99,nw2)/nw2;
        
        % periodogram method global
        alpha90 = 0.10/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = theored1 * chi2inv((1-alpha90),nw2)/nw2;
        red95global = theored1 * chi2inv((1-alpha95),nw2)/nw2;
        red99global = theored1 * chi2inv((1-alpha99),nw2)/nw2;
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            
            if fmin <= 0 
                fmin_s = pt(3);
            else
                fmin_s = 1/fmin;
            end

            xlim([1/fmax, fmin_s]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,theored1,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')']) 
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,theored1,'k-','LineWidth',2)
        end
        % language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','bending power law')
            ylabel('Power')
            title([num2str(nw),'\pi MTM & bending power law','; bw = ',num2str(bw)])  
            set(gcf,'Name',[num2str(nw),'pi MTM & bending power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral10',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            title([num2str(nw),'\pi MTM & ',lang_var{locb3},'; ',lang_var{locb0},' = ',num2str(bw)])   
            set(gcf,'Name',[num2str(nw),'pi MTM & ',lang_var{locb3},': ',dat_name,ext])
        end
        
        
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % Plot figure MTM handles.checkbox_robustAR1_v = checkbox_robustAR1;
    % neither robust AR1 nor conventional AR1
    noplot1 = handles.checkbox_robustAR1_v + handles.checkPL + handles.checkBPL ...
        + handles.checkbox_ar1_v + handles.check_ftest_value + SelectSWA;
    if noplot1 == 0
        figdata = figure;
        set(gcf,'Color', 'white')
        plot(fd1,po,'LineWidth',1); 
        line([0.7*fmax, 0.7*fmax+bw],[0.8*max(po), 0.8*max(po)],'Color','r')
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0) % english
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            ylabel('Power')
            legend('Power','bw')
            title([num2str(nw),' \pi MTM method; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(bw)])
        else
            [~, locb] = ismember('spectral33',lang_id);
            [~, locb1] = ismember('spectral30',lang_id);
            [~, locb2] = ismember('spectral34',lang_id);
            [~, locb3] = ismember('spectral37',lang_id);
            
            xlabel([lang_var{locb},num2str(unit),')']) 
            ylabel(lang_var{locb1})
            legend(lang_var{locb1},lang_var{locb2})
            title([num2str(nw),' \pi MTM; ',lang_var{locb3},' = ',num2str(dt),' ', unit,'; ',lang_var{locb2},' = ',num2str(bw)])
        end
        set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
        set(gca,'XMinorTick','on','YMinorTick','on')
        xlim([fmin, fmax]);
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
        if plot_x_period
            update_spectral_x_period_mtm
        end
    end 

    if handles.checkbox_ar1_v == 1
        % Waitbar
        if handles.lang_choice == 0
            hwaitbar = waitbar(0,'Estimation may take a few minutes...',...    
               'WindowStyle','modal');
        else
            [~, locb] = ismember('spectral40',lang_id);
            hwaitbar = waitbar(0,lang_var{locb},...    
               'WindowStyle','modal');
        end
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
        %[fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconftabtchi(datax,nw,dt,nzeropad,2);
        [fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconfchi2(datax,nw,dt,nzeropad,2);
        rho = rhoAR1(datax);
        step = 4.5;
        waitbar(step / steps)
        figdata = figure;  
        set(gcf,'Color', 'white')
        plot(fd,po,'k-','LineWidth',1);
        hold on; 
        plot(fd,theored,'k-','LineWidth',2);
        plot(fd,tabtchi90,'r-','LineWidth',1);
        plot(fd,tabtchi95,'r--','LineWidth',2);
        plot(fd,tabtchi99,'b-.','LineWidth',1);
        plot(fd,tabtchi999,'g--','LineWidth',1);
        xlim([fmin fmax]);
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            xlabel(['Frequency (cycles/',num2str(unit),')'])
            ylabel('Power')
            title([num2str(nw),'\pi MTM classic AR1: \rho = ',num2str(rho),'; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(bw)])
            legend('Power','AR1','90%','95%','99%','99.9%')
        else
            [~, locb] = ismember('spectral33',lang_id);
            xlabel([lang_var{locb},num2str(unit),')']) 
             [~, locb1] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb1})
            legend(lang_var{locb1},'AR1','90%','95%','99%','99.9%')
            [~, locb1] = ismember('spectral34',lang_id);
            [~, locb7] = ismember('spectral07',lang_id);
            [~, locb3] = ismember('spectral37',lang_id);
            title([num2str(nw),'\pi-MTM-',lang_var{locb7},': \rho = ',num2str(rho),'; ',...
                lang_var{locb3},' = ',num2str(dt),'; ',lang_var{locb1},' = ',num2str(bw)])
        end
        
        step = 5.5;
        waitbar(step / steps)
        delete(hwaitbar)
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
        
        if plot_x_period
            update_spectral_x_period_mtm
        end
    else
        figdata = gcf;
    end 
    
    if handles.check_ftest_value
        if plot_x_period
            update_spectral_x_period_mtm
        else
            [freq,ftest,fsig,Amp,Faz,Sig,Noi,dof,wt]=ftestmtmML(data,nw,padtimes,1);
            subplot(3,1,1); xlim([fmin fmax])
            subplot(3,1,2); xlim([fmin fmax])
            subplot(3,1,3); xlim([fmin fmax])
            set(gcf,'color','white');
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.0,0.05,0.45,0.45])
            
            fig2 = figure;
            set(gcf,'color','white');
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.2,0.05,0.45,0.45])
            subplot(2,1,1); 
            plot(freq,dof,'color','k','LineWidth',1)
            xlim([fmin fmax])
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                title('Adaptive weighted degrees of freedom')
            else
                [~, locb] = ismember('spectral38',lang_id);
                title(lang_var{locb})
            end
            subplot(2,1,2); 
            plot(freq,Faz,'color','k','LineWidth',1)
            xlim([fmin fmax])
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                title('Harmonic phase')
                ylabel('Frequency')
            else
                [~, locb] = ismember('spectral39',lang_id);
                [~, locb1] = ismember('main34',lang_id);
                title(lang_var{locb})
                ylabel(lang_var{locb1})
            end
        end
    end
    
    %% SWA method 
    if SelectSWA == 1
        [outputdata] = spectralswafdr(data, 'mtm', nw, padtimes, 0);
        clfdr = outputdata(:, 9:13);
        xvalue = outputdata(:,1);
        pxx = outputdata(:,2);
        swa = outputdata(:,3);
        chi90 = outputdata(:,4);
        chi95 = outputdata(:,5);
        chi99 = outputdata(:,6);
        chi999 = outputdata(:,7);
        chi9999 = outputdata(:,8);
        
        f=figure; 
        set(f,'Name',['Acycle: ',[dat_name,ext],'-',num2str(nw),'pi MTM SWA'])
        set(f,'color','white');
        set(f,'units','norm') % set location
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            xlabel(['Frequency (cycles/',num2str(unit),')'])
            ylabel('Power')
            
            if plot_x_period
                xvalue = 1./xvalue;
                xlabel(['Period (',handles.unit,')']);
                pmin = 1/fmax;
                if fmin <= 0 
                    pmax = xvalue(3);
                else
                    pmax = 1/fmin;
                end
                
                fmax = pmax;
                fmin = pmin;
            end
            
        else
            
            [~, locb] = ismember('spectral33',lang_id);
            xlabel([lang_var{locb},num2str(unit),')']) 
             [~, locb1] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb1})
            
            if plot_x_period
                xvalue = 1./xvalue;
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
                
                pmin = 1/fmax;
                if fmin <= 0 
                    pmax = xvalue(3);
                else
                    pmax = 1/fmin;
                end
                
                fmax = pmax;
                fmin = pmin;
            end
        end
            
        hold on
        % plot FDR
        if ~isnan(clfdr(1,5))  % 0.01% FDR
            plot(xvalue, clfdr(:,5),'k-.','LineWidth',0.5,'DisplayName','0.01% FDR');
        end
        if ~isnan(clfdr(1,4))  % 0.1% FDR
            plot(xvalue, clfdr(:,4),'g-.','LineWidth',0.5,'DisplayName','0.1% FDR'); % 0.1% FDR
        end
        if ~isnan(clfdr(1,3))  % 1% FDR
            plot(xvalue, clfdr(:,3),'b--','LineWidth',0.5,'DisplayName','1% FDR'); % 1% FDR
        end
        if ~isnan(clfdr(1,2))  % 5% FDR
            plot(xvalue, clfdr(:,2),'r--','LineWidth',2,'DisplayName','5% FDR'); % 5% FDR
        end
        %plot(xvalue,chi9999,'g:','LineWidth',0.5,'DisplayName','Chi2 99.99% CL')
        plot(xvalue,chi999,'m-','LineWidth',0.5,'DisplayName','Chi2 99.9% CL')
        plot(xvalue,chi99,'b-','LineWidth',0.5,'DisplayName','Chi2 99% CL')
        plot(xvalue,chi95,'r-','LineWidth',1.5,'DisplayName','Chi2 95% CL')
        plot(xvalue,chi90,'k--','LineWidth',0.5,'DisplayName','Chi2 90% CL')
        plot(xvalue,swa,'k-','LineWidth',1.5,'DisplayName','Backgnd')
        plot(xvalue, pxx,'k-','LineWidth',0.5,'DisplayName','Power'); 
        legend
        set(gca,'YScale','log');
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gcf,'Color', 'white')
        xlim([fmin, fmax])
        if plot_x_period == 1
            set(gca, 'XDir','reverse')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
        % move data file to current working folder
        % refresh main window
        pre_dirML = pwd;
        ac_pwd = fileread('ac_pwd.txt');
        if isdir(ac_pwd)
            cd(ac_pwd)
        end
        
        if isfile( which( 'SWA-Spectrum-background-FDR.dat'))
            date = datestr(now,30);
            curr_dir_full1 = which( 'SWA-Spectrum-background-FDR.dat');
            curr_dir_full2 = which('Spectrum-SWA-Chi2CL.dat');

            curr_dir1 = fullfile(ac_pwd,[dat_name,'-',num2str(nw),'pi-MTM-SWA-Spectrum-FDR-',date,'.dat']);
            curr_dir2 = fullfile(ac_pwd,[dat_name,'-',num2str(nw),'pi-MTM-Spectrum-SWA-Chi2CL-',date,'.dat']);

            movefile(curr_dir_full1,curr_dir1);
            movefile(curr_dir_full2,curr_dir2);
        end
        
        
        % refresh main window
        d = dir; %get files
        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
        % define some nested parameters
        pre  = '<HTML><FONT color="blue">';
        post = '</FONT></HTML>';
        address = pwd;
        d = dir; %get files
        d(1)=[];d(1)=[];
        listboxStr = cell(numel(d),1);
        ac_pwd_str = which('ac_pwd.txt');
        [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
        fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
        T = struct2table(d);
        sortedT = [];
        sd = [];
        str=[];
        i=[];

        refreshcolor;
        cd(pre_dirML); % return to matlab view folder
    end
    
elseif strcmp(method,'Lomb-Scargle spectrum')
    
    if get(handles.checkbox_ar1_check,'value') == 1
        pfa = [50 10 1 0.01]/100;
        pd = 1 - pfa;
        timex = timex + abs(min(timex));
        %[po,fd1,pth] = plomb(datax,timex,fmax,'normalized','Pd',pd);
        [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
        if plot_x_period
            pt1 = 1./fd1;
        end
        figdata = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            if handles.checkbox_ar1_v == 1
                plot(pt1,po,pt1,pth*ones(size(pt1')),'LineWidth',1); 
                text(10*(1/fmax)*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
            else
                plot(pt1,po,'k-','LineWidth',1); 
            end
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            
            if fmin <= 0 
                fmin_s = pt(3);
            else
                fmin_s = 1/fmin;
            end

            xlim([1/fmax, fmin_s]);
            set(gca, 'XDir','reverse')
        else
            if handles.checkbox_ar1_v == 1
                plot(fd1,po,fd1,pth*ones(size(fd1')),'LineWidth',1); 
                text(0.3*fmax*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
            else
                plot(fd1,po,'k-','LineWidth',1); 
            end
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            xlim([fmin fmax]);
        end
        %language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            ylabel('Power')
            title(['Lomb-Scargle spectrum','; bw = ',num2str(df)])
            set(gcf,'Name',[dat_name,ext,': Lomb-Scargle spectrum'])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb] = ismember('spectral41',lang_id);
            [~, locb1] = ismember('spectral34',lang_id);
            title([lang_var{locb},'; ',lang_var{locb1},' = ',num2str(df)])
            set(gcf,'Name',[dat_name,ext,': ',lang_var{locb}])
        end
        set(gca,'XMinorTick','on','YMinorTick','on')

        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % robust AR1
    if get(handles.checkbox_robust,'value') == 1
        plotn =  1; % show result
        %language
        if handles.lang_choice == 0
            dlg_title = 'Robust AR(1)';
            prompt = {'Median smoothing window: default 0.2=20%'};
        else
            [~, locb] = ismember('spectral06',lang_id);
            dlg_title = lang_var{locb};
            [~, locb] = ismember('spectral26',lang_id);
            prompt = {lang_var{locb}};
        end
        num_lines = 1;
        defaultans = {num2str(0.2)};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);

        if ~isempty(answer)
            smoothwin = str2double(answer{1});
            if plot_x_period
                [po,fd1, pth] = plomb_robustar1(datax,timex,fmax,smoothwin,0);   
                figure; 
                set(gcf,'Color', 'white')
                hold on; 
                semilogy(fd1,pth(5,:),'b-.');
                semilogy(fd1,pth(4,:),'r--','LineWidth',2);
                semilogy(fd1,pth(3,:),'r-');
                semilogy(fd1,pth(2,:),'k-','LineWidth',2);
                semilogy(fd1,pth(1,:),'m-.');
                semilogy(fd1,po,'k')
                xlim([fmin,fmax])
                % language
                if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                    xlabel(['Period (',num2str(unit),')']) 
                else
                    [~, locb] = ismember('main15',lang_id);
                    xlabel([lang_var{locb},' (',num2str(unit),')']) 
                end

                if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                    ylabel('Power')
                    smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
                    legend( 'Robust AR(1) 99%', 'Robust AR(1) 95%','Robust AR(1) 90%',...
                        'Robust AR(1) median',smthwin,'Power')
                else
                    [~, locb] = ismember('spectral30',lang_id);
                    ylabel(lang_var{locb})
                    [~, locb1] = ismember('spectral31',lang_id);
                    smthwin = [num2str(smoothwin*100),'% ', lang_var{locb1}];
                    [~, locb6] = ismember('spectral06',lang_id);
                    [~, locb1] = ismember('spectral32',lang_id);
                    legend([lang_var{locb6},'99%'],...
                        [lang_var{locb6},'95%'],...
                        [lang_var{locb6},'90%'],...
                        [lang_var{locb6},lang_var{locb1}],...
                        smthwin,lang_var{locb})
                end
                
                set(gca,'XMinorTick','on','YMinorTick','on')
            else
                [po,fd1, pth] = plomb_robustar1(datax,timex,fmax,smoothwin,plotn);   
            end
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                title(['Lomb-Scargle spectrum','; bw = ',num2str(df)])
                set(gcf,'Name',[dat_name,ext,': Lomb-Scargle spectrum'])
            else
                [~, locb] = ismember('spectral41',lang_id);
                [~, locb1] = ismember('spectral34',lang_id);
                title([lang_var{locb},'; ',lang_var{locb1},' = ',num2str(df)])
                set(gcf,'Name',[dat_name,ext,': ',lang_var{locb}])
            end
            if handles.linlogY == 1
                set(gca, 'YScale', 'log')
            else
                set(gca, 'YScale', 'linear')
            end
            if handles.logfreq == 1
                set(gca,'xscale','log')
                
            end
        end
    end
    % power law
    if handles.checkPL == 1
        
        pfa = [50 10 1 0.01]/100;
        pd = 1 - pfa;
        timex = timex + abs(min(timex));
        %[po,fd1,pth] = plomb(datax,timex,fmax,'normalized','Pd',pd);
        [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
        
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2;
        pf = polyfit(log(fd1(2:end)),log(po(2:end)),1);
        % Evaluating Coefficients
        a = pf(1);
        % Accounting for the log transformation
        k = exp(pf(2));
        %ezplot(@(X) k*X.^a,[X(1) X(end)])
        pl = k * fd1.^a;
        % local c.l.
        red90 = pl * chi2inv(0.9,2)/2;
        red95 = pl * chi2inv(0.95,2)/2;
        red99 = pl * chi2inv(0.99,2)/2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),2)/2;
        red95global = pl * chi2inv((1-alpha95),2)/2;
        red99global = pl * chi2inv((1-alpha99),2)/2;
        
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
            ylabel('Power')
            title(['Lomb-Scargle spectrum & power law','; bw = ',num2str(df)])
            set(gcf,'Name',['Lomb-Scargle spectrum & power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral09',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            [~, locb41] = ismember('spectral41',lang_id);
            [~, locb34] = ismember('spectral34',lang_id);
            title([lang_var{locb41},' & ',lang_var{locb3},'; ',lang_var{locb34},' = ',num2str(df)])
            set(gcf,'Name',[lang_var{locb41},' & ',lang_var{locb3},': ',dat_name,ext])
        end
        
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1;
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % bending power law
    if handles.checkBPL == 1
        pfa = [50 10 1 0.01]/100;
        pd = 1 - pfa;
        timex = timex + abs(min(timex));
        %[po,fd1,pth] = plomb(datax,timex,fmax,'normalized','Pd',pd);
        [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
        
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2;
        pol = log(po);
        pol = real(pol);
        fun = @(v,f)(v(1) * f .^(-1 * v(2)))./(1 + (f / v(4)) .^ (v(3)-v(2)));
        v0 = [100,0.5,3,0.5*fd1(end)];
        x = lsqcurvefit(fun,v0,fd1(2:end),pol(2:end));
        pl = exp(fun(x,fd1));
        % local c.l.
        red90 = pl * chi2inv(0.9,2)/2;
        red95 = pl * chi2inv(0.95,2)/2;
        red99 = pl * chi2inv(0.99,2)/2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),2)/2;
        red95global = pl * chi2inv((1-alpha95),2)/2;
        red99global = pl * chi2inv((1-alpha99),2)/2;
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        
        % language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','bending power law')
            ylabel('Power')
            title(['Lomb-Scargle spectrum & bending power law','; bw = ',num2str(df)])
            set(gcf,'Name',['Lomb-Scargle spectrum & bending power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral10',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            [~, locb41] = ismember('spectral41',lang_id);
            title([lang_var{locb41},' & ',lang_var{locb3},'; ',lang_var{locb0},' = ',num2str(df)])
            set(gcf,'Name',[lang_var{locb41},' & ',lang_var{locb3},': ',dat_name,ext])
        end
                
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
elseif  strcmp(method,'Periodogram')
    
    if padtimes > 1
        [po,fd1] = periodogram(datax,[],nzeropad,1/dt);
    else 
        [po,fd1]=periodogram(datax,[],[],1/dt);
    end
    figdata = figure;  
    set(gcf,'Color', 'white')
    
    if plot_x_period
        pt1 = 1./fd1;
        plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
        
        % language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            xlabel(['Period (',num2str(unit),')']) 
        else
            [~, locb] = ismember('main15',lang_id);
            xlabel([lang_var{locb},' (',num2str(unit),')']) 
        end
        xlim([1/fmax, pt1(3)]);
        set(gca, 'XDir','reverse')
        if handles.checkbox_ar1_v == 1
            [theored]=theoredar1ML(datax,fd1,mean(po),dt);
            tabtchired90 = theored * chi2inv(90/100,2)/2;
            tabtchired95 = theored * chi2inv(95/100,2)/2;
            tabtchired99 = theored * chi2inv(99/100,2)/2;
            %tabtchired999 = theored * chi2inv(99.9/100,2)/2;
            hold on
            plot(pt1,theored,'k-','LineWidth',2)
            plot(pt1,tabtchired90,'r-','LineWidth',1)
            plot(pt1,tabtchired95,'r--','LineWidth',2)
            plot(pt1,tabtchired99,'b-.','LineWidth',1)
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                legend('Power','Mean','90%','95%','99%')
            else
                [~, main46] = ismember('main46',lang_id);
                [~, spectral42] = ismember('spectral42',lang_id);
                legend(lang_var{main46},lang_var{spectral42},'90%','95%','99%')
            end
        end
    else
        plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
        
        %language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            xlabel(['Frequency (cycles/',num2str(unit),')'])
        else
            [~, locb] = ismember('spectral33',lang_id);
            xlabel([lang_var{locb},num2str(unit),')']) 
        end
        xlim([fmin fmax]);
        if handles.checkbox_ar1_v == 1
            [theored]=theoredar1ML(datax,fd1,mean(po),dt);
            tabtchired90 = theored * chi2inv(90/100,2)/2;
            tabtchired95 = theored * chi2inv(95/100,2)/2;
            tabtchired99 = theored * chi2inv(99/100,2)/2;
            hold on
            plot(fd1,theored,'k-','LineWidth',2)
            plot(fd1,tabtchired90,'r-','LineWidth',1)
            plot(fd1,tabtchired95,'r--','LineWidth',2)
            plot(fd1,tabtchired99,'b-.','LineWidth',1)
                
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                legend('Power','Mean','90%','95%','99%')
            else
                [~, main46] = ismember('main46',lang_id);
                [~, spectral42] = ismember('spectral42',lang_id);
                legend(lang_var{main46},lang_var{spectral42},'90%','95%','99%')
            end
        end
    end
    % language
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        ylabel('Power')
        title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
        set(gcf,'Name',['Periodogram & AR1: ',dat_name,ext])
    else
        [~, spectral30] = ismember('spectral30',lang_id);
        ylabel(lang_var{spectral30})
        [~, spectral43] = ismember('spectral43',lang_id);
        [~, spectral37] = ismember('spectral37',lang_id);
        [~, spectral34] = ismember('spectral34',lang_id);
        title([lang_var{spectral43},'; ',lang_var{spectral37},' = ',num2str(dt),' ', unit,'; ',lang_var{spectral34},' = ',num2str(df)])
        set(gcf,'Name',[lang_var{spectral43},' & AR1: ',dat_name,ext])
    end
    
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    if handles.linlogY == 1;
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    
    % power law
    if handles.checkPL == 1
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2; 
        pf = polyfit(log(fd1(2:end)),log(po(2:end)),1);
        % Evaluating Coefficients
        a = pf(1);
        % Accounting for the log transformation
        k = exp(pf(2));
        %ezplot(@(X) k*X.^a,[X(1) X(end)])
        pl = k * fd1.^a;
        % local c.l.
        red90 = pl * chi2inv(0.9,2)/2;
        red95 = pl * chi2inv(0.95,2)/2;
        red99 = pl * chi2inv(0.99,2)/2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),2)/2;
        red95global = pl * chi2inv((1-alpha95),2)/2;
        red99global = pl * chi2inv((1-alpha99),2)/2;
        
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
            ylabel('Power')
            title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
            set(gcf,'Name',['Periodogram & power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral09',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            [~, spectral43] = ismember('spectral43',lang_id);
            [~, spectral37] = ismember('spectral37',lang_id);
            title([lang_var{spectral43},'; ',lang_var{spectral37},' = ',num2str(dt),' ', unit,'; ',lang_var{locb0},' = ',num2str(df)])
            set(gcf,'Name',[lang_var{spectral43},' & ',lang_var{locb3},': ',dat_name,ext])
        end
        
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1;
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % bending power law
    if handles.checkBPL == 1
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2;
        
        pol = log(po);
        pol = real(pol);
        
        fun = @(v,f)(v(1) * f .^(-1 * v(2)))./(1 + (f / v(4)) .^ (v(3)-v(2)));
        v0 = [100,0.5,3,0.5*fd1(end)];
        x = lsqcurvefit(fun,v0,fd1(2:end),pol(2:end));
        pl = exp(fun(x,fd1));
        % local c.l.
        red90 = pl * chi2inv(0.9,2)/2;
        red95 = pl * chi2inv(0.95,2)/2;
        red99 = pl * chi2inv(0.99,2)/2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),2)/2;
        red95global = pl * chi2inv((1-alpha95),2)/2;
        red99global = pl * chi2inv((1-alpha99),2)/2;
        
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','BPL')
            ylabel('Power')
            title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
            set(gcf,'Name',['Periodogram & bending power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral10',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            [~, spectral43] = ismember('spectral43',lang_id);
            [~, spectral37] = ismember('spectral37',lang_id);
            title([lang_var{spectral43},'; ',lang_var{spectral37},' = ',num2str(dt),' ', unit,'; ',lang_var{locb0},' = ',num2str(df)])
            set(gcf,'Name',[lang_var{spectral43},' & ',lang_var{locb3},': ',dat_name,ext])
        end
        
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
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
    set(figdata,'position',[0.0,0.45,0.45,0.45]) % set position
catch
end
try figure(figpl); 
    set(figpl,'units','norm') % set location
    set(figpl,'position',[0.2,0.45,0.45,0.45]) % set position
catch
end
try figure(figbpl); 
    set(figbpl,'units','norm') % set location
    set(figbpl,'position',[0.4,0.45,0.45,0.45]) % set position
catch
end
guidata(hObject,handles);


% --- Executes on button press in pushbutton3.
% RUN & Save
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lang_id = handles.lang_id;
lang_var = handles.lang_var;

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
nw = handles.timebandwidth;
bw=2*nw*df;
BiasCorr = handles.BiasCorr;
SelectSWA = get(handles.checkboxSWA,'Value');
fmin = str2double(get(handles.edit8,'String'));
if fmin < 0
    fmin = 0;
end
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

plot_x_period = get(handles.checkbox8,'value');

if strcmp(method,'Multi-taper method')
    if max(diffx) - min(diffx) > 10 * eps('single')
        %figwarn = warndlg({'Data may be interpolated to an uniform sampling interval';...
        %    '';'    Or select : Lomb-Scargle spectrum'});
        %set(figwarn,'units','norm') % set location
        %set(figwarn,'position',[0.5,0.8,0.225,0.09]) % set position
    end
    if handles.checkbox_robustAR1_v == 1
        if handles.lang_choice == 0
            dlg_title = 'Robust AR(1) Estimation';
            prompt = {'Median smoothing window: default 0.2 = 20%';...
                'AR1 best fit model? 1 = linear （default）; 2 = log power';...
                'Bias correction for ultra-high resolution data'};
        else
            [~, locb] = ismember('spectral25',lang_id);
            dlg_title = lang_var{locb};
            [~, locb1] = ismember('spectral26',lang_id);
            [~, locb2] = ismember('spectral27',lang_id);
            [~, locb3] = ismember('spectral28',lang_id);
            prompt = {lang_var{locb1};...
                lang_var{locb2};...
                lang_var{locb3}};
        end
        num_lines = 1;
        if BiasCorr == 0
            defaultans = {num2str(0.2),num2str(1),num2str(0)};
        else
            defaultans = {num2str(0.2),num2str(1),num2str(1)};
        end
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);

        if ~isempty(answer)
            smoothwin = str2double(answer{1});
            linlog = str2double(answer{2});
            biascorr = str2double(answer{3});
            
            if length(datax)>2000
                if handles.lang_choice > 0
                    [~, locb] = ismember('spectral29',lang_id);
                    hwarn = warndlg(lang_var{locb});
                else
                    hwarn = warndlg('Large dataset, wait ...');
                end
            end

            if biascorr == 1
                ValidNyqFreq = handles.ValidNyqFreqR;
                [rhoM, s0M,redconfAR1,redconfML96]=redconfML(datax,dt,nw,nzeropad,linlog,smoothwin,ValidNyqFreq,0);
            else
                ValidNyqFreq = handles.ValidNyqFreq;
                [rhoM, s0M,redconfAR1,redconfML96]=redconfML(datax,dt,nw,nzeropad,linlog,smoothwin,ValidNyqFreq,1);
            end
            try close(hwarn)
            catch
            end
            
            % for plot only
            % Multi-taper method power spectrum
            if nw == 1
                [pxx,w] = pmtm(datax,nw,nzeropad,'DropLastTaper',false);
            else
                [pxx,w] = pmtm(datax,nw,nzeropad);
            end
            % Nyquist frequency
            fn = 1/(2*dt);
            % true frequencies
            f0 = w/pi*fn;
            
            f1 = redconfAR1(:,1);
            pxxsmooth0 = redconfAR1(:,3);
            f = redconfML96(:,1);
            theored1 = redconfML96(:,3);
            chi90 = redconfML96(:,4);
            chi95 = redconfML96(:,5);
            chi99 = redconfML96(:,6);
            
            figdata = figure; 
            set(gcf,'Color', 'white')
            semilogy(f0,pxx,'k')
            hold on; 
            semilogy(f1,pxxsmooth0,'m-.');
            semilogy(f,theored1,'k-','LineWidth',2);
            semilogy(f,chi90,'r-');
            semilogy(f,chi95,'r--','LineWidth',2);
            semilogy(f,chi99,'b-.');
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                ylabel('Power')
                smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
                legend('Power',smthwin,'Robust AR(1) median',...
                    'Robust AR(1) 90%','Robust AR(1) 95%','Robust AR(1) 99%')
            else
                [~, locb] = ismember('spectral30',lang_id);
                ylabel(lang_var{locb})
                [~, locb1] = ismember('spectral31',lang_id);
                smthwin = [num2str(smoothwin*100),'% ', lang_var{locb1}];
                [~, locb6] = ismember('spectral06',lang_id);
                [~, locb1] = ismember('spectral32',lang_id);
                legend(lang_var{locb},smthwin,...
                    [lang_var{locb6},lang_var{locb1}],...
                    [lang_var{locb6},'90%'],...
                    [lang_var{locb6},'95%'],...
                    [lang_var{locb6},'99%'])
            end
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.0,0.45,0.45,0.45]) % set position
            %end
            
            if plot_x_period
                update_spectral_x_period_mtm
            else
                if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                    xlabel(['Frequency (cycles/',num2str(unit),')']) 
                    title([num2str(nw),'\pi-MTM-Robust-AR(1): \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M),'; bw = ',num2str(bw)])   
                else
                    [~, locb] = ismember('spectral33',lang_id);
                    [~, locb1] = ismember('spectral34',lang_id);
                    xlabel([lang_var{locb},num2str(unit),')']) 
                    title([num2str(nw),'\pi-MTM-',lang_var{locb6},': \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M),'; ',lang_var{locb1},' = ',num2str(bw)])   
                end
                set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
                set(gca,'XMinorTick','on','YMinorTick','on')
                xlim([fmin fmax]);
                set(gcf,'Color', 'white')
                if handles.linlogY == 1
                    set(gca, 'YScale', 'log')
                else
                    set(gca, 'YScale', 'linear')
                end
                if handles.logfreq == 1
                    set(gca,'xscale','log')
                end
            end
            
            name1 = [dat_name,'-',num2str(nw),'piMTM-RobustAR1',ext];
            data1 = redconfML96;
            name2 = [dat_name,'-',num2str(nw),'piMTM-RobustAR1-Med-smooth',ext];
            data2 = [f1,pxxsmooth0];
            
            CDac_pwd;
            dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9);
            dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9);
            if handles.lang_choice == 0
                disp('>>  Refresh main window to see red noise estimation data files: ')
            else
                [~, spectral44] = ismember('spectral44',lang_id);
                disp(lang_var{spectral44})
            end
            disp(name1)
            disp(name2)
            cd(pre_dirML);
        else
            return
        end
    
    end
    
    if padtimes > 1
        if nw == 1
            [po,w]=pmtm(datax,nw,nzeropad,'DropLastTaper',false);
        else
            [po,w]=pmtm(datax,nw,nzeropad);
        end
    else 
        if nw == 1
            [po,w]=pmtm(datax,nw,'DropLastTaper',false);
        else
            [po,w]=pmtm(datax,nw);
        end
    end
    fd1=w/(2*pi*dt);
    
    % power law
    if handles.checkPL == 1
        K = 2*nw -1;
        nw2 = 2*(K);
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2; 
        pf = polyfit(log(fd1(2:end)),log(po(2:end)),1);
        % Evaluating Coefficients
        a = pf(1);
        % Accounting for the log transformation
        k = exp(pf(2));
        %ezplot(@(X) k*X.^a,[X(1) X(end)])
        pl = k * fd1.^a;
        % local c.l.
        red90 = pl * chi2inv(0.9,nw2)/nw2;
        red95 = pl * chi2inv(0.95,nw2)/nw2;
        red99 = pl * chi2inv(0.99,nw2)/nw2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),nw2)/nw2;
        red95global = pl * chi2inv((1-alpha95),nw2)/nw2;
        red99global = pl * chi2inv((1-alpha99),nw2)/nw2;
        
        name1 = [dat_name,'-',num2str(nw),'piMTM-PL-local',ext];
        data1 = [fd1,po,pl,red90,red95,red99];
        name2 = [dat_name,'-',num2str(nw),'piMTM-PL-global',ext];
        data2 = [fd1,po,pl,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9);
        if handles.lang_choice == 0
            disp('>>  Refresh main window to see red noise estimation data files: ')
        else
            [~, spectral44] = ismember('spectral44',lang_id);
            disp(lang_var{spectral44})
        end
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
            ylabel('Power')
            title([num2str(nw),'\pi MTM & power law','; bw = ',num2str(bw)])   
            set(gcf,'Name',[num2str(nw),'pi MTM & power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral09',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            title([num2str(nw),'\pi MTM & ',lang_var{locb3},'; ',lang_var{locb0},' = ',num2str(bw)])  
            set(gcf,'Name',[num2str(nw),'pi MTM & ',lang_var{locb3},': ',dat_name,ext])
        end
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % bending power law
    if handles.checkBPL == 1
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2;
        pol = log(po);
        pol = real(pol);
        fun = @(v,f)(v(1) * f .^(-1 * v(2)))./(1 + (f / v(4)) .^ (v(3)-v(2)));
        v0 = [100,0.5,3,0.5*fd1(end)];
        x = lsqcurvefit(fun,v0,fd1(2:end),pol(2:end));
        theored1 = exp(fun(x,fd1)); % bending power law fit
        K = 2*nw -1;
        nw2 = 2*(K);
        % Chi-square inversed distribution
        % local c.l.
        red90 = theored1 * chi2inv(0.90,nw2)/nw2;
        red95 = theored1 * chi2inv(0.95,nw2)/nw2;
        red99 = theored1 * chi2inv(0.99,nw2)/nw2;
        
        % periodogram method global
        alpha90 = 0.10/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = theored1 * chi2inv((1-alpha90),nw2)/nw2;
        red95global = theored1 * chi2inv((1-alpha95),nw2)/nw2;
        red99global = theored1 * chi2inv((1-alpha99),nw2)/nw2;
        name1 = [dat_name,'-',num2str(nw),'piMTM-BPL-local',ext];
        data1 = [fd1,po,theored1,red90,red95,red99];
        name2 = [dat_name,'-',num2str(nw),'piMTM-BPL-global',ext];
        data2 = [fd1,po,theored1,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9);
        if handles.lang_choice == 0
            disp('>>  Refresh main window to see red noise estimation data files: ')
        else
            [~, spectral44] = ismember('spectral44',lang_id);
            disp(lang_var{spectral44})
        end
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,theored1,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,theored1,'k-','LineWidth',2)
        end
        
        
        % language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','bending power law')
            ylabel('Power')
            title([num2str(nw),'\pi MTM & bending power law','; bw = ',num2str(bw)])  
            set(gcf,'Name',[num2str(nw),'pi MTM & bending power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral10',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            title([num2str(nw),'\pi MTM & ',lang_var{locb3},'; ',lang_var{locb0},' = ',num2str(bw)])   
            set(gcf,'Name',[num2str(nw),'pi MTM & ',lang_var{locb3},': ',dat_name,ext])
        end
        
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % Plot figure MTM
    noplot1 = handles.checkbox_robustAR1_v + handles.checkPL + handles.checkBPL ...
        + handles.checkbox_ar1_v + handles.check_ftest_value + SelectSWA;
    if noplot1 == 0
    %if and( handles.checkbox_robustAR1_v == 0, handles.checkbox_ar1_v == 0)
        if plot_x_period
            update_spectral_x_period_mtm
        else
            figdata = figure;
            figHandle = gcf;
            set(gcf,'Color', 'white')
            plot(fd1,po,'LineWidth',1); 
            line([0.7*fmax, 0.7*fmax+bw],[0.8*max(po), 0.8*max(po)],'Color','r')
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0) % english
                xlabel(['Frequency (cycles/',num2str(unit),')']) 
                ylabel('Power')
                legend('Power','bw')
                title([num2str(nw),' \pi MTM method; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(bw)])
            else
                [~, locb] = ismember('spectral33',lang_id);
                [~, locb1] = ismember('spectral30',lang_id);
                [~, locb2] = ismember('spectral34',lang_id);
                [~, locb3] = ismember('spectral37',lang_id);

                xlabel([lang_var{locb},num2str(unit),')']) 
                ylabel(lang_var{locb1})
                legend(lang_var{locb1},lang_var{locb2})
                title([num2str(nw),' \pi MTM; ',lang_var{locb3},' = ',num2str(dt),' ', unit,'; ',lang_var{locb2},' = ',num2str(bw)])
            end
            set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
            xlim([fmin fmax]);
            set(gca,'XMinorTick','on','YMinorTick','on')

            if handles.linlogY == 1
                set(gca, 'YScale', 'log')
            else
                set(gca, 'YScale', 'linear')
            end
            if handles.logfreq == 1
                set(gca,'xscale','log')
            end
        end
    end
    
    if handles.checkbox_ar1_v == 1
        % Waitbar
        if handles.lang_choice == 0
            hwaitbar = waitbar(0,'Estimation may take a few minutes...',...    
               'WindowStyle','modal');
        else
            [~, locb] = ismember('spectral40',lang_id);
            hwaitbar = waitbar(0,lang_var{locb},...    
               'WindowStyle','modal');
        end
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
    %     if strcmp(handles.checkbox_ar1_check,'tabtchi')
            step = 2.5;
            waitbar(step / steps)
            %[fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconftabtchi(datax,nw,dt,nzeropad,2);
            [fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconfchi2(datax,nw,dt,nzeropad,2);
            rho = rhoAR1(datax);
    step = 4.5;
        waitbar(step / steps)
            figHandle = figure;
            set(gcf,'Color', 'white')
            plot(fd,po,'k-','LineWidth',1);
            hold on; 
            plot(fd,theored,'k-','LineWidth',2);
            plot(fd,tabtchi90,'r-','LineWidth',1);
            plot(fd,tabtchi95,'r--','LineWidth',2);
            plot(fd,tabtchi99,'b-.','LineWidth',1);
            plot(fd,tabtchi999,'g--','LineWidth',1);
            legend('Power','AR1','90%','95%','99%','99.9%')
            set(gca,'XMinorTick','on','YMinorTick','on')
            xlim([fmin fmax]);
            
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
                ylabel('Power')
                title([num2str(nw),'\pi MTM classic AR1: \rho = ',num2str(rho),'; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(bw)])
                legend('Power','AR1','90%','95%','99%','99.9%')
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
                 [~, locb1] = ismember('spectral30',lang_id);
                ylabel(lang_var{locb1})
                legend(lang_var{locb1},'AR1','90%','95%','99%','99.9%')
                [~, locb1] = ismember('spectral34',lang_id);
                [~, locb7] = ismember('spectral07',lang_id);
                [~, locb3] = ismember('spectral37',lang_id);
                title([num2str(nw),'\pi-MTM-',lang_var{locb7},': \rho = ',num2str(rho),'; ',...
                    lang_var{locb3},' = ',num2str(dt),'; ',lang_var{locb1},' = ',num2str(bw)])
            end
            
    step = 5.5;
        waitbar(step / steps)
        delete(hwaitbar)
        xlim([fmin fmax]);
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
        %filename_mtm = [dat_name,'-',num2str(nw),'piMTMspectrum.txt'];
        filename_mtm_cl = [dat_name,'-',num2str(nw),'piMTM-ClassicAR1.txt'];
        CDac_pwd; % cd ac_pwd dir
        dlmwrite(filename_mtm_cl, [fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999], 'delimiter', ' ', 'precision', 9);

        disp(filename_mtm_cl)
        cd(pre_dirML); % return to matlab view folder
        figdata = figHandle;
        
        if plot_x_period
            update_spectral_x_period_mtm
        end
    else
    end  
    
    if handles.check_ftest_value
        if plot_x_period
            update_spectral_x_period_mtm
        else
            [freq,ftest,fsigout,Amp,Faz,Sig,Noi,dof,wt]=ftestmtmML(data,nw,padtimes,1);
            set(gcf,'color','white');
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.0,0.05,0.45,0.45])
            %xlim([fmin fmax]);
            subplot(3,1,1); xlim([0 fmax])
            subplot(3,1,2); xlim([0 fmax])
            subplot(3,1,3); xlim([0 fmax])
            
            fig2 = figure;
            set(gcf,'color','white');
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.2,0.05,0.45,0.45])
            subplot(2,1,1); 
            plot(freq,dof,'color','k','LineWidth',1)
            xlim([0 fmax])
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                title('Adaptive weighted degrees of freedom')
            else
                [~, locb] = ismember('spectral38',lang_id);
                title(lang_var{locb})
            end
            subplot(2,1,2); 
            plot(freq,Faz,'color','k','LineWidth',1)
            xlim([0 fmax])
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                title('Harmonic phase')
                ylabel('Frequency')
            else
                [~, locb] = ismember('spectral39',lang_id);
                [~, locb1] = ismember('main34',lang_id);
                title(lang_var{locb})
                ylabel(lang_var{locb1})
            end
        end
        
        fnyq = 1/(2*dt);
        nameftest = [dat_name,'-',num2str(nw),'piMTM-ftest',ext];
        namefsig = [dat_name,'-',num2str(nw),'piMTM-fsig',ext];
        namefamp = [dat_name,'-',num2str(nw),'piMTM-amp',ext];
        namefrest = [dat_name,'-',num2str(nw),'piMTM-Faz-Sig-Noi-Dof',ext];
        
        CDac_pwd;
        dataftest = [freq',ftest'];
        datafsig  = [freq',fsigout'];
        dataamp  = [freq',Amp'];
        datarest  = [freq',Faz',Sig',Noi',dof'];
        
        [dataftest] = select_interval(dataftest,0,fnyq);
        [datafsig] = select_interval(datafsig,0,fnyq);
        [dataamp] = select_interval(dataamp,0,fnyq);
        dlmwrite(nameftest, dataftest, 'delimiter', ' ', 'precision', 9);
        dlmwrite(namefsig, datafsig, 'delimiter', ' ', 'precision', 9);
        dlmwrite(namefamp, dataamp, 'delimiter', ' ', 'precision', 9);
        dlmwrite(namefrest, datarest, 'delimiter', ' ', 'precision', 9);
        %disp('>>  Refresh main window to see red noise estimation data files: ')
        disp(nameftest)
        disp(namefsig)
        disp(namefamp)
        cd(pre_dirML);
    
    end
    
    
    %% SWA method 
    if SelectSWA == 1
        [outputdata] = spectralswafdr(data, 'mtm', nw, padtimes, 0);
        clfdr = outputdata(:, 9:13);
        xvalue = outputdata(:,1);
        pxx = outputdata(:,2);
        swa = outputdata(:,3);
        chi90 = outputdata(:,4);
        chi95 = outputdata(:,5);
        chi99 = outputdata(:,6);
        chi999 = outputdata(:,7);
        chi9999 = outputdata(:,8);
        
        f=figure; 
        set(f,'Name',['Acycle: ',[dat_name,ext],'-',num2str(nw),'pi MTM SWA'])
        set(f,'color','white');
        set(f,'units','norm') % set location
        
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            xlabel(['Frequency (cycles/',num2str(unit),')'])
            ylabel('Power')
            
            if plot_x_period
                xvalue = 1./xvalue;
                xlabel(['Period (',handles.unit,')']);
                pmin = 1/fmax;
                if fmin <= 0 
                    pmax = xvalue(3);
                else
                    pmax = 1/fmin;
                end
                
                fmax = pmax;
                fmin = pmin;
            end
            
        else
            
            [~, locb] = ismember('spectral33',lang_id);
            xlabel([lang_var{locb},num2str(unit),')']) 
             [~, locb1] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb1})
            
            if plot_x_period
                xvalue = 1./xvalue;
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
                
                pmin = 1/fmax;
                if fmin <= 0 
                    pmax = xvalue(3);
                else
                    pmax = 1/fmin;
                end
                
                fmax = pmax;
                fmin = pmin;
            end
        end
            
        hold on
        % plot FDR
        if ~isnan(clfdr(1,5))  % 0.01% FDR
            plot(xvalue, clfdr(:,5),'k-.','LineWidth',0.5,'DisplayName','0.01% FDR');
        end
        if ~isnan(clfdr(1,4))  % 0.1% FDR
            plot(xvalue, clfdr(:,4),'g-.','LineWidth',0.5,'DisplayName','0.1% FDR'); % 0.1% FDR
        end
        if ~isnan(clfdr(1,3))  % 1% FDR
            plot(xvalue, clfdr(:,3),'b--','LineWidth',0.5,'DisplayName','1% FDR'); % 1% FDR
        end
        if ~isnan(clfdr(1,2))  % 5% FDR
            plot(xvalue, clfdr(:,2),'r--','LineWidth',2,'DisplayName','5% FDR'); % 5% FDR
        end
        %plot(xvalue,chi9999,'g:','LineWidth',0.5,'DisplayName','Chi2 99.99% CL')
        plot(xvalue,chi999,'m-','LineWidth',0.5,'DisplayName','Chi2 99.9% CL')
        plot(xvalue,chi99,'b-','LineWidth',0.5,'DisplayName','Chi2 99% CL')
        plot(xvalue,chi95,'r-','LineWidth',1.5,'DisplayName','Chi2 95% CL')
        plot(xvalue,chi90,'k--','LineWidth',0.5,'DisplayName','Chi2 90% CL')
        plot(xvalue,swa,'k-','LineWidth',1.5,'DisplayName','Backgnd')
        plot(xvalue, pxx,'k-','LineWidth',0.5,'DisplayName','Power'); 
        legend
        set(gca,'YScale','log');
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gcf,'Color', 'white')
        xlim([fmin, fmax])
        if plot_x_period == 1
            set(gca, 'XDir','reverse')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
        % move data file to current working folder
        % refresh main window
        pre_dirML = pwd;
        ac_pwd = fileread('ac_pwd.txt');
        if isdir(ac_pwd)
            cd(ac_pwd)
        end
        
        if isfile( which( 'SWA-Spectrum-background-FDR.dat'))
            date = datestr(now,30);
            curr_dir_full1 = which( 'SWA-Spectrum-background-FDR.dat');
            curr_dir_full2 = which('Spectrum-SWA-Chi2CL.dat');

            curr_dir1 = fullfile(ac_pwd,[dat_name,'-',num2str(nw),'pi-MTM-SWA-Spectrum-FDR-',date,'.dat']);
            curr_dir2 = fullfile(ac_pwd,[dat_name,'-',num2str(nw),'pi-MTM-Spectrum-SWA-Chi2CL-',date,'.dat']);

            movefile(curr_dir_full1,curr_dir1);
            movefile(curr_dir_full2,curr_dir2);
        end
        
        
        % refresh main window
        d = dir; %get files
        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
        % define some nested parameters
        pre  = '<HTML><FONT color="blue">';
        post = '</FONT></HTML>';
        address = pwd;
        d = dir; %get files
        d(1)=[];d(1)=[];
        listboxStr = cell(numel(d),1);
        ac_pwd_str = which('ac_pwd.txt');
        [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
        fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
        T = struct2table(d);
        sortedT = [];
        sd = [];
        str=[];
        i=[];

        refreshcolor;
        cd(pre_dirML); % return to matlab view folder
    end
    
    
elseif strcmp(method,'Lomb-Scargle spectrum')
    
    if get(handles.checkbox_ar1_check,'value') == 1
        pfa = [50 10 1 0.01]/100;
        pd = 1 - pfa;
        timex = timex + abs(min(timex));
        %[po,fd1,pth] = plomb(datax,timex,fmax,'normalized','Pd',pd);
        [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
        if plot_x_period
            pt1 = 1./fd1;
        end
        figdata = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            if handles.checkbox_ar1_v == 1
                plot(pt1,po,pt1,pth*ones(size(pt1')),'LineWidth',1); 
                text(10*(1/fmax)*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
            else
                plot(pt1,po,'LineWidth',1); 
            end
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
        else
            if handles.checkbox_ar1_v == 1
                plot(fd1,po,fd1,pth*ones(size(fd1')),'LineWidth',1); 
                text(0.3*fmax*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
            else
                plot(fd1,po,'LineWidth',1); 
            end
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            xlim([fmin fmax]);
        end
        
        %language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            ylabel('Power')
            title(['Lomb-Scargle spectrum','; bw = ',num2str(df)])
            set(gcf,'Name',[dat_name,ext,': Lomb-Scargle spectrum'])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb] = ismember('spectral41',lang_id);
            [~, locb1] = ismember('spectral34',lang_id);
            title([lang_var{locb},'; ',lang_var{locb1},' = ',num2str(df)])
            set(gcf,'Name',[dat_name,ext,': ',lang_var{locb}])
        end
        
        set(gca,'XMinorTick','on','YMinorTick','on')

        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
        
        
        filename_LS = [dat_name,'-Lomb-Scargle.txt'];
        CDac_pwd; % cd ac_pwd dir
        dlmwrite(filename_LS, [fd1,po,(pth*ones(size(fd1')))'], 'delimiter', ' ', 'precision', 9);
        cd(pre_dirML); % return to matlab view folder
        %disp('Refresh the Main Window:')
        disp(filename_LS)
    
    end
    
    % robust AR1
    if get(handles.checkbox_robust,'value') == 1
        plotn =  1; % show result
        
        %language
        if handles.lang_choice == 0
            dlg_title = 'Robust AR(1)';
            prompt = {'Median smoothing window: default 0.2=20%'};
        else
            [~, locb] = ismember('spectral06',lang_id);
            dlg_title = lang_var{locb};
            [~, locb] = ismember('spectral26',lang_id);
            prompt = {lang_var{locb}};
        end
        
        num_lines = 1;
        defaultans = {num2str(0.2)};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);

        if ~isempty(answer)
            smoothwin = str2double(answer{1});
            if plot_x_period
                timex = timex + abs(min(timex));
                [po,fd1, pth] = plomb_robustar1(datax,timex,fmax,smoothwin,0);   
                figure; 
                set(gcf,'Color', 'white')
                hold on; 
                semilogy(fd1,pth(5,:),'b-.');
                semilogy(fd1,pth(4,:),'r--','LineWidth',2);
                semilogy(fd1,pth(3,:),'r-');
                semilogy(fd1,pth(2,:),'k-','LineWidth',2);
                semilogy(fd1,pth(1,:),'m-.');
                semilogy(fd1,po,'k')
                xlim([fmin,fmax])
                
                % language
                if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                    xlabel(['Period (',num2str(unit),')']) 
                else
                    [~, locb] = ismember('main15',lang_id);
                    xlabel([lang_var{locb},' (',num2str(unit),')']) 
                end
                if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                    ylabel('Power')
                    smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
                    legend( 'Robust AR(1) 99%', 'Robust AR(1) 95%','Robust AR(1) 90%',...
                        'Robust AR(1) median',smthwin,'Power')
                else
                    [~, locb] = ismember('spectral30',lang_id);
                    ylabel(lang_var{locb})
                    [~, locb1] = ismember('spectral31',lang_id);
                    smthwin = [num2str(smoothwin*100),'% ', lang_var{locb1}];
                    [~, locb6] = ismember('spectral06',lang_id);
                    [~, locb1] = ismember('spectral32',lang_id);
                    legend([lang_var{locb6},'99%'],...
                        [lang_var{locb6},'95%'],...
                        [lang_var{locb6},'90%'],...
                        [lang_var{locb6},lang_var{locb1}],...
                        smthwin,lang_var{locb})
                end
                set(gca,'XMinorTick','on','YMinorTick','on')
            else
                [po,fd1, pth] = plomb_robustar1(datax,timex,fmax,smoothwin,plotn);  
            end
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                title(['Lomb-Scargle spectrum','; bw = ',num2str(df)])
                set(gcf,'Name',[dat_name,ext,': Lomb-Scargle spectrum'])
            else
                [~, locb] = ismember('spectral41',lang_id);
                [~, locb1] = ismember('spectral34',lang_id);
                title([lang_var{locb},'; ',lang_var{locb1},' = ',num2str(df)])
                set(gcf,'Name',[dat_name,ext,': ',lang_var{locb}])
            end
            
            set(gca,'XMinorTick','on','YMinorTick','on')
            if handles.linlogY == 1
                set(gca, 'YScale', 'log')
            else
                set(gca, 'YScale', 'linear')
            end
            if handles.logfreq == 1
                set(gca,'xscale','log')
            end
            
            name1 = [dat_name,'-Lomb-robustAR1',ext];
            data1 = [fd1,po,pth'];
            CDac_pwd;
            dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9);
            if handles.lang_choice == 0
                disp('>>  Refresh main window to see red noise estimation data files: ')
            else
                [~, spectral44] = ismember('spectral44',lang_id);
                disp(lang_var{spectral44})
            end
            disp(name1)
            cd(pre_dirML);
        
        end
        
        
        
    end
    
    % power law
    if handles.checkPL == 1
        pfa = [50 10 1 0.01]/100;
        pd = 1 - pfa;
        timex = timex + abs(min(timex));
        %[po,fd1,pth] = plomb(datax,timex,fmax,'normalized','Pd',pd);
        [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
        
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2;
        pf = polyfit(log(fd1(2:end)),log(po(2:end)),1);
        % Evaluating Coefficients
        a = pf(1);
        % Accounting for the log transformation
        k = exp(pf(2));
        %ezplot(@(X) k*X.^a,[X(1) X(end)])
        pl = k * fd1.^a;
        % local c.l.
        red90 = pl * chi2inv(0.9,2)/2;
        red95 = pl * chi2inv(0.95,2)/2;
        red99 = pl * chi2inv(0.99,2)/2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),2)/2;
        red95global = pl * chi2inv((1-alpha95),2)/2;
        red99global = pl * chi2inv((1-alpha99),2)/2;
        name1 = [dat_name,'-Lomb-PL-local',ext];
        data1 = [fd1,po,pl,red90,red95,red99];
        name2 = [dat_name,'-Lomb-PL-global',ext];
        data2 = [fd1,po,pl,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9);
        if handles.lang_choice == 0
            disp('>>  Refresh main window to see red noise estimation data files: ')
        else
            [~, spectral44] = ismember('spectral44',lang_id);
            disp(lang_var{spectral44})
        end
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
            ylabel('Power')
            title(['Lomb-Scargle spectrum & power law','; bw = ',num2str(df)])
            set(gcf,'Name',['Lomb-Scargle spectrum & power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral09',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            [~, locb41] = ismember('spectral41',lang_id);
            [~, locb34] = ismember('spectral34',lang_id);
            title([lang_var{locb41},' & ',lang_var{locb3},'; ',lang_var{locb34},' = ',num2str(df)])
            set(gcf,'Name',[lang_var{locb41},' & ',lang_var{locb3},': ',dat_name,ext])
        end
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % bending power law
    if handles.checkBPL == 1
        pfa = [50 10 1 0.01]/100;
        pd = 1 - pfa;
        timex = timex + abs(min(timex));
        %[po,fd1,pth] = plomb(datax,timex,fmax,'normalized','Pd',pd);
        [po,fd1,pth] = plomb(datax,timex,fmax,'Pd',pd);
        
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2;
        pol = log(po);
        pol = real(pol);
        fun = @(v,f)(v(1) * f .^(-1 * v(2)))./(1 + (f / v(4)) .^ (v(3)-v(2)));
        v0 = [100,0.5,3,0.5*fd1(end)];
        x = lsqcurvefit(fun,v0,fd1(2:end),pol(2:end));
        pl = exp(fun(x,fd1));
        % local c.l.
        red90 = pl * chi2inv(0.9,2)/2;
        red95 = pl * chi2inv(0.95,2)/2;
        red99 = pl * chi2inv(0.99,2)/2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),2)/2;
        red95global = pl * chi2inv((1-alpha95),2)/2;
        red99global = pl * chi2inv((1-alpha99),2)/2;
            
        name1 = [dat_name,'-Lomb-BPL-local',ext];
        data1 = [fd1,po,pl,red90,red95,red99];
        name2 = [dat_name,'-Lomb-BPL-global',ext];
        data2 = [fd1,po,pl,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9);
        if handles.lang_choice == 0
            disp('>>  Refresh main window to see red noise estimation data files: ')
        else
            [~, spectral44] = ismember('spectral44',lang_id);
            disp(lang_var{spectral44})
        end
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        % language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','bending power law')
            ylabel('Power')
            title(['Lomb-Scargle spectrum & bending power law','; bw = ',num2str(df)])
            set(gcf,'Name',['Lomb-Scargle spectrum & bending power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral10',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            [~, locb41] = ismember('spectral41',lang_id);
            title([lang_var{locb41},' & ',lang_var{locb3},'; ',lang_var{locb0},' = ',num2str(df)])
            set(gcf,'Name',[lang_var{locb41},' & ',lang_var{locb3},': ',dat_name,ext])
        end
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    
elseif  strcmp(method,'Periodogram')

    
    if padtimes > 1
        [po,fd1] = periodogram(datax,[],nzeropad,1/dt);
    else 
        [po,fd1]=periodogram(datax,[],[],1/dt);
    end
    figdata = figure;  
    set(gcf,'Color', 'white')
    plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
    %language
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        xlabel(['Frequency (cycles/',num2str(unit),')'])
    else
        [~, locb] = ismember('spectral33',lang_id);
        xlabel([lang_var{locb},num2str(unit),')']) 
    end

    
    
    % language
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        ylabel('Power')
        title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
        set(gcf,'Name',[dat_name,ext,': periodogram'])
    else
        [~, spectral30] = ismember('spectral30',lang_id);
        ylabel(lang_var{spectral30})
        [~, spectral43] = ismember('spectral43',lang_id);
        [~, spectral37] = ismember('spectral37',lang_id);
        [~, spectral34] = ismember('spectral34',lang_id);
        title([lang_var{spectral43},'; ',lang_var{spectral37},' = ',num2str(dt),' ', unit,'; ',lang_var{spectral34},' = ',num2str(df)])
        set(gcf,'Name',[dat_name,ext,': ',lang_var{spectral43}])
    end
    
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([fmin fmax]);
    if handles.linlogY == 1
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    if handles.checkbox_ar1_v == 1
        [theored]=theoredar1ML(datax,fd1,mean(po),dt);
        tabtchired90 = theored * chi2inv(90/100,2)/2;
        tabtchired95 = theored * chi2inv(95/100,2)/2;
        tabtchired99 = theored * chi2inv(99/100,2)/2;
        tabtchired999 = theored * chi2inv(99.9/100,2)/2;
        hold on
        plot(fd1,theored,'k-','LineWidth',2)
        plot(fd1,tabtchired90,'r-','LineWidth',1)
        plot(fd1,tabtchired95,'r--','LineWidth',2)
        plot(fd1,tabtchired99,'b-.','LineWidth',1)
        plot(fd1,tabtchired999,'g--','LineWidth',1)
        % language
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','Mean','90%','95%','99%')
        else
            [~, main46] = ismember('main46',lang_id);
            [~, spectral42] = ismember('spectral42',lang_id);
            legend(lang_var{main46},lang_var{spectral42},'90%','95%','99%')
        end
        hold off
    end
    
    % power law
    if handles.checkPL == 1
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2; 
        pf = polyfit(log(fd1(2:end)),log(po(2:end)),1);
        % Evaluating Coefficients
        a = pf(1);
        % Accounting for the log transformation
        k = exp(pf(2));
        %ezplot(@(X) k*X.^a,[X(1) X(end)])
        pl = k * fd1.^a;
        % local c.l.
        red90 = pl * chi2inv(0.9,2)/2;
        red95 = pl * chi2inv(0.95,2)/2;
        red99 = pl * chi2inv(0.99,2)/2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),2)/2;
        red95global = pl * chi2inv((1-alpha95),2)/2;
        red99global = pl * chi2inv((1-alpha99),2)/2;
        name1 = [dat_name,'-Periodogram-PL-local',ext];
        data1 = [fd1,po,pl,red90,red95,red99];
        name2 = [dat_name,'-Periodogram-PL-global',ext];
        data2 = [fd1,po,pl,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9);
        if handles.lang_choice == 0
            disp('>>  Refresh main window to see red noise estimation data files: ')
        else
            [~, spectral44] = ismember('spectral44',lang_id);
            disp(lang_var{spectral44})
        end
        disp(name1)
        disp(name2)
        cd(pre_dirML);
            
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
            ylabel('Power')
            title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
            set(gcf,'Name',['Periodogram & power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral09',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            [~, spectral43] = ismember('spectral43',lang_id);
            [~, spectral37] = ismember('spectral37',lang_id);
            title([lang_var{spectral43},'; ',lang_var{spectral37},' = ',num2str(dt),' ', unit,'; ',lang_var{locb0},' = ',num2str(df)])
            set(gcf,'Name',[lang_var{spectral43},' & ',lang_var{locb3},': ',dat_name,ext])
        end
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    % bending power law
    if handles.checkBPL == 1
        N = length(datax);
        % With no padding or smoothing applied
        % Number of independent Fourier frequencies
        Nf = N/2;
        
        pol = log(po);
        pol = real(pol);
        
        fun = @(v,f)(v(1) * f .^(-1 * v(2)))./(1 + (f / v(4)) .^ (v(3)-v(2)));
        v0 = [100,0.5,3,0.5*fd1(end)];
        x = lsqcurvefit(fun,v0,fd1(2:end),pol(2:end));
        pl = exp(fun(x,fd1));
        % local c.l.
        red90 = pl * chi2inv(0.9,2)/2;
        red95 = pl * chi2inv(0.95,2)/2;
        red99 = pl * chi2inv(0.99,2)/2;
        % periodogram method global
        alpha90 = 0.1/Nf;
        alpha95 = 0.05/Nf;
        alpha99 = 0.01/Nf;
        red90global = pl * chi2inv((1-alpha90),2)/2;
        red95global = pl * chi2inv((1-alpha95),2)/2;
        red99global = pl * chi2inv((1-alpha99),2)/2;
        name1 = [dat_name,'-Periodogram-BPL-local',ext];
        data1 = [fd1,po,pl,red90,red95,red99];
        name2 = [dat_name,'-Periodogram-BPL-global',ext];
        data2 = [fd1,po,pl,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ' ', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9);
        if handles.lang_choice == 0
            disp('>>  Refresh main window to see red noise estimation data files: ')
        else
            [~, spectral44] = ismember('spectral44',lang_id);
            disp(lang_var{spectral44})
        end
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            
            % language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Period (',num2str(unit),')']) 
            else
                [~, locb] = ismember('main15',lang_id);
                xlabel([lang_var{locb},' (',num2str(unit),')']) 
            end
            xlim([1/fmax, pt1(3)]);
            set(gca, 'XDir','reverse')
            hold on
            plot(pt1,red99global,'r-.','LineWidth',1)
            plot(pt1,red95global,'r--','LineWidth',2)
            plot(pt1,red90global,'r-','LineWidth',1)
            plot(pt1,red99,'b-.','LineWidth',1)
            plot(pt1,red95,'b--','LineWidth',2)
            plot(pt1,red90,'b-','LineWidth',1)
            plot(pt1,pl,'k-','LineWidth',2)
        else
            plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
            xlim([fmin fmax]);
            
            %language
            if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
                xlabel(['Frequency (cycles/',num2str(unit),')'])
            else
                [~, locb] = ismember('spectral33',lang_id);
                xlabel([lang_var{locb},num2str(unit),')']) 
            end
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
            legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','BPL')
            ylabel('Power')
            title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
            set(gcf,'Name',['Periodogram & bending power law: ',dat_name,ext])
        else
            [~, locb] = ismember('spectral30',lang_id);
            ylabel(lang_var{locb})
            [~, locb0] = ismember('spectral34',lang_id);
            [~, locb1] = ismember('spectral35',lang_id);
            [~, locb2] = ismember('spectral36',lang_id);
            [~, locb3] = ismember('spectral10',lang_id);
            legend(lang_var{locb},...
                ['99%',lang_var{locb1}],...
                ['95%',lang_var{locb1}],...
                ['90%',lang_var{locb1}],...
                ['99%',lang_var{locb2}],...
                ['95%',lang_var{locb2}],...
                ['90%',lang_var{locb2}],...
                lang_var{locb3})
            [~, spectral43] = ismember('spectral43',lang_id);
            [~, spectral37] = ismember('spectral37',lang_id);
            title([lang_var{spectral43},'; ',lang_var{spectral37},' = ',num2str(dt),' ', unit,'; ',lang_var{locb0},' = ',num2str(df)])
            set(gcf,'Name',[lang_var{spectral43},' & ',lang_var{locb3},': ',dat_name,ext])
        end
        set(gca,'XMinorTick','on','YMinorTick','on')
        
        if handles.linlogY == 1
            set(gca, 'YScale', 'log')
        else
            set(gca, 'YScale', 'linear')
        end
        if handles.logfreq == 1
            set(gca,'xscale','log')
        end
    end
    
    CDac_pwd; % cd ac_pwd dir
    
    try filename_Periodogram = [dat_name,'-PeriodogramAR1.txt'];   
        dlmwrite(filename_Periodogram, [fd1,po,theored,tabtchired90,tabtchired95,tabtchired99,tabtchired999], ...
            'delimiter', ' ', 'precision', 9);
    catch
        filename_Periodogram = [dat_name,'-Periodogram.txt'];
        dlmwrite(filename_Periodogram, [fd1,po], ...
            'delimiter', ' ', 'precision', 9);
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
    set(figdata,'Units','normalized') % set location
    set(figdata,'position',[0.0,0.5,0.45,0.45]) % set position
catch
end% return plot
try figure(figpl); 
    set(figpl,'units','norm') % set location
    set(figpl,'position',[0.2,0.45,0.45,0.45]) % set position
catch
end
try figure(figbpl); 
    set(figbpl,'units','norm') % set location
    set(figbpl,'position',[0.4,0.45,0.45,0.45]) % set position
catch
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

% --- Executes on button press in checkbox_ar1_check.
function checkbox_ar1_check_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ar1_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ar1_check

handles.checkbox_ar1_v = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox_robustAR1.
function checkbox_robust_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_robust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ar1_check
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
lang_var = handles.lang_var;
lang_id = handles.lang_id;

if strcmp(method,'Multi-taper method')
    if handles.datasample == 1
        if handles.lang_choice > 0
            [~, locb0] = ismember('spectral22',lang_id);
            [~, locb1] = ismember('main29',lang_id);
            msgbox(lang_var{locb0},lang_var{locb1})
        else
            msgbox('Sampling rate may not be uneven! Ignore if this is not ture.','Waning')
        end
    end
    set(handles.popupmenu_tapers,'Enable','on')
    set(handles.checkbox_robust,'Enable','on')
    set(handles.checkbox_ar1_check,'Enable','on')
    if handles.lang_choice > 0
        [~, locb0] = ismember('spectral07',lang_id);
        set(handles.checkbox_ar1_check,'String',lang_var{locb0})
    else
        set(handles.checkbox_ar1_check,'String','Classical AR(1)')
    end
    set(handles.check_ftest,'Value', handles.check_ftest_value)
    set(handles.check_ftest,'Visible','on')
    set(handles.checkboxSWA,'Visible', 'on')
elseif strcmp(method,'Periodogram')
    if handles.datasample == 1
        if handles.lang_choice > 0
            [~, locb0] = ismember('spectral22',lang_id);
            [~, locb1] = ismember('main29',lang_id);
            msgbox(lang_var{locb0},lang_var{locb1})
        else
            msgbox('Sampling rate may not be uneven! Ignore if this is not ture.','Waning')
        end
    end
    set(handles.popupmenu_tapers,'Enable','off')
    set(handles.checkbox_robust,'Enable','off')
    set(handles.checkbox_ar1_check,'Enable','on')
    if handles.lang_choice > 0
        [~, locb0] = ismember('spectral07',lang_id);
        set(handles.checkbox_ar1_check,'String',lang_var{locb0})
    else
        set(handles.checkbox_ar1_check,'String','Classical AR(1)')
    end
    set(handles.checkboxSWA,'Visible', 'off')
    set(handles.check_ftest,'Visible','off')
elseif strcmp(method,'Lomb-Scargle spectrum')
    set(handles.popupmenu_tapers,'Enable','off')
    set(handles.checkbox_robust,'Enable','on')
    set(handles.checkbox_robust,'Value',1)
    set(handles.checkbox_ar1_check,'Value',0)
    set(handles.checkboxSWA,'Visible', 'off')
    if handles.lang_choice > 0
        [~, locb0] = ismember('spectral11',lang_id);
        set(handles.checkbox_ar1_check,'String',lang_var{locb0})
    else
        set(handles.checkbox_ar1_check,'String','White noise')
    end
    set(handles.check_ftest,'Visible','off')
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


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
logfreq = get(handles.checkbox6,'Value');
if logfreq == 1
    handles.logfreq = 1;
    set(handles.checkbox6,'Value',1)
    %disp('yes')
else
    handles.logfreq = 0;
    set(handles.checkbox6,'Value',0)
    %disp('no')
end
guidata(hObject, handles);


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
timebandwidthselection = get(hObject,'Value');
if timebandwidthselection == 1
    handles.timebandwidth = str2num( get(handles.edit7,'String') );
    set(handles.edit7, 'Enable', 'on')
    set(handles.popupmenu_tapers, 'Enable', 'off')
else
    set(handles.edit7, 'Enable', 'off')
    set(handles.popupmenu_tapers, 'Enable', 'on')
    contents = cellstr(get(handles.popupmenu_tapers,'String'));
    handles.timebandwidth = str2num(contents{get(handles.popupmenu_tapers,'Value')});
end
guidata(hObject, handles);


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
handles.timebandwidth = str2num( get(handles.edit7,'String') );
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_ftest.
function check_ftest_Callback(hObject, eventdata, handles)
% hObject    handle to check_ftest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_ftest
handles.check_ftest_value = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
if get(hObject,'Value')
    set(handles.checkbox6, 'value', 1)
    handles.logfreq = 1;
else
end
guidata(hObject, handles);


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
if get(handles.checkbox9,'Value')
    handles.checkPL = 1;
else
    handles.checkPL = 0;
end
guidata(hObject, handles);

% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10
if get(handles.checkbox10,'Value')
    handles.checkBPL = 1;
else
    handles.checkBPL = 0;
end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pushbutton3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nsimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkboxSWA.
function checkboxSWA_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSWA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSWA



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
