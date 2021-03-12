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

% Last Modified by GUIDE v2.5 10-Dec-2020 21:31:32

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
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11.5);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11.5);  % set as norm
if ismac
    set(gcf,'position',[0.45,0.5,0.3,0.33]) % set position
elseif ispc
    set(gcf,'position',[0.45,0.5,0.3,0.33]) % set position
end
set(handles.text7,'position', [0.05,0.875,0.235,0.06])
set(handles.popupmenu2,'position', [0.3,0.823,0.62,0.12])

set(handles.uipanel2,'position', [0.05,0.41,0.445,0.37])
set(handles.text3,'position', [0.04,0.6,0.6,0.38])
set(handles.popupmenu_tapers,'position', [0.6,0.635,0.38,0.365])
set(handles.text5,'position', [0.055,0.38,0.436,0.176])
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
set(handles.check_ftest,'position', [0.05,0.05,0.9,0.3])
set(handles.check_ftest,'Value', 0, 'tooltip','F-test and amplitude spectrum')
set(handles.checkbox9,'position',  [0.65,0.65,0.35,0.3])
set(handles.checkbox10,'position', [0.65,0.35,0.35,0.3])
%
set(handles.checkbox9,'tooltip','Power Law')
set(handles.checkbox10,'tooltip','Bending Power Law')

set(handles.uibuttongroup1,'position', [0.5,0.25,0.45,0.52])
set(handles.radiobutton_fmax,'position', [0.089,0.75,0.473,0.2])
set(handles.text_nyquist,'position', [0.541,0.76,0.356,0.13])
set(handles.radiobutton_input,'position', [0.089,0.5,0.4,0.2])
set(handles.edit_fmax_input,'position', [0.541,0.52,0.356,0.2])

set(handles.checkbox4,'position', [0.089,0.25,0.507,0.2])
set(handles.checkbox5,'position', [0.5,0.25,0.507,0.2])
set(handles.checkbox6,'position', [0.089,0.05,0.4,0.2])
set(handles.checkbox6,'String', 'log(freq.)')
set(handles.checkbox8,'position', [0.5,0.05,0.48,0.2])
set(handles.checkbox8,'value', 0)

set(handles.pushbutton17,'position', [0.5,0.082,0.166,0.12])
set(handles.pushbutton3,'position', [0.67,0.082,0.282,0.12])

set(handles.checkbox_ar1_check,'String','Classic AR(1)')
% Choose default command line output for spectrum
handles.output = hObject;

set(gcf,'Name','Acycle: Spectral Analysis')
set(handles.checkbox_robust,'Value',1)
set(handles.checkbox_ar1_check,'Value',0)
set(handles.radiobutton4,'Value',1)
set(handles.radiobutton3,'Value',0)
set(handles.checkbox4,'Value',0)
set(handles.checkbox5,'Value',1)
set(handles.checkbox6,'Value', 0)
set(handles.checkbox9,'Value', 0)
set(handles.checkbox10,'Value', 0)
set(handles.radiobutton_fmax,'Value',1)
set(handles.radiobutton_input,'Value',0)
% contact with acycle main window
handles.acfigmain = varargin{1}.acfigmain;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;
%
data_s = varargin{1}.current_data;
data_s = sortrows(data_s);
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
    set(handles.checkbox_robust,'Enable','off')
    set(handles.checkbox_robust,'Value',0)
    set(handles.checkbox_ar1_check,'Value',0)
    set(handles.checkbox_ar1_check,'String','White noise')
    set(handles.check_ftest,'Visible', 'off')
else
    handles.method ='Multi-taper method';
    set(handles.popupmenu2, 'Value', 1);
    set(handles.popupmenu_tapers, 'Value', 1);
    set(handles.check_ftest,'Visible', 'on')
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
        figwarn = warndlg({'Data may be interpolated to an uniform sampling interval';...
            '';'    Or select : Lomb-Scargle spectrum'});
        set(figwarn,'units','norm') % set location
        set(figwarn,'position',[0.5,0.8,0.225,0.09]) % set position
    end
    
    if handles.checkbox_robustAR1_v == 1
        dlg_title = 'Robust AR(1) Estimation';
        prompt = {'Median smoothing window: default 0.2 = 20%';...
            'AR1 best fit model? 1 = linear; 2 = log power (default)';...
            'Bias correction for ultra-high resolution data'};
        num_lines = 1;
        if BiasCorr == 0
            defaultans = {num2str(0.2),num2str(2),num2str(0)};
        else
            defaultans = {num2str(0.2),num2str(2),num2str(1)};
        end
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);

        if ~isempty(answer)
            smoothwin = str2double(answer{1});
            linlog = str2double(answer{2});
            biascorr = str2double(answer{3});
            
            if length(datax)>2000
                hwarn = warndlg('Large dataset, wait ...');
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
            
%             %theored1 = s0M * (1-rhoM^2)./(1-(2.*rhoM.*cos(pi.*f0./fmax))+rhoM^2);
%             theored1 = s0M * (1-rhoM^2)./(1-(2.*rhoM.*cos(pi.*f0./ValidNyqFreq))+rhoM^2);
%             K = 2*nw -1;
%             nw2 = 2*(K);
%             % Chi-square inversed distribution
%             chi90 = theored1 * chi2inv(0.90,nw2)/nw2;
%             chi95 = theored1 * chi2inv(0.95,nw2)/nw2;
%             chi99 = theored1 * chi2inv(0.99,nw2)/nw2;
%             f=f0;
            
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
            ylabel('Power')
            smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
            legend('Power',smthwin,'Robust AR(1) median',...
                'Robust AR(1) 90%','Robust AR(1) 95%','Robust AR(1) 99%')
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.0,0.45,0.45,0.45]) % set position
            
            if plot_x_period
                update_spectral_x_period_mtm
            else
                xlim([0 fmax]);
                xlabel(['Frequency (cycles/',num2str(unit),')']) 
                title([num2str(nw),'\pi-MTM-Robust-AR(1): \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M),'; bw = ',num2str(bw)])                
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
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        %legend('Power','95% global','99% local','95% local','90% local','Power law')
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
        ylabel('Power')
        title([num2str(nw),'\pi MTM & power law','; bw = ',num2str(bw)])        
        set(gcf,'Name',[num2str(nw),'\pi MTM & power law: ',dat_name,ext])
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
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,theored1,'k-','LineWidth',2)
        end
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','BPL')
        ylabel('Power')
        title([num2str(nw),'\pi MTM & bending power law','; bw = ',num2str(bw)])
        set(gcf,'Name',[num2str(nw),'\pi MTM & bending power law: ',dat_name,ext])
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
    if and(get(handles.checkbox_ar1_check,'value') == 0, get(handles.checkbox_robust,'value') == 0)
        figdata = figure;
        set(gcf,'Color', 'white')
        plot(fd1,po,'LineWidth',1); 
        line([0.7*fmax, 0.7*fmax+bw],[0.8*max(po), 0.8*max(po)],'Color','r')
        xlabel(['Frequency (cycles/',num2str(unit),')']) 
        ylabel('Power ')
        legend('Power','bw')
        title([num2str(nw),' \pi MTM method; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(bw)])
        set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
        set(gca,'XMinorTick','on','YMinorTick','on')
        xlim([0 fmax]);
        if handles.linlogY == 1;
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
        hwaitbar = waitbar(0,'Classic red noise estimation may take a few minutes...',...    
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
        [fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconftabtchi(datax,nw,dt,nzeropad,2);
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
        xlim([0 fmax]);
        xlabel(['Frequency (cycles/',num2str(unit),')'])
        ylabel('Power ')
        title([num2str(nw),'\pi MTM classic AR1: \rho = ',num2str(rho),'; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(bw)])
        
        legend('Power','AR1','90%','95%','99%','99.9%')
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
            subplot(3,1,1); xlim([0 fmax])
            subplot(3,1,2); xlim([0 fmax])
            subplot(3,1,3); xlim([0 fmax])
            set(gcf,'color','white');
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.0,0.05,0.45,0.45])
            
            fig2 = figure;
            set(gcf,'color','white');
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.2,0.05,0.45,0.45])
            subplot(2,1,1); 
            plot(freq,dof,'color','k','LineWidth',1)
            xlim([0 fmax])
            title('Adaptive weighted degrees of freedom')
            subplot(2,1,2); 
            plot(freq,Faz,'color','k','LineWidth',1)
            xlim([0 fmax])
            title('Harmonic phase')
            ylabel('Frequency')
        end
    end
    
elseif strcmp(method,'Lomb-Scargle spectrum')
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
        xlabel(['Period (',num2str(unit),')']) 
        xlim([1/fmax, pt1(3)]);
        set(gca, 'XDir','reverse')
    else
        if handles.checkbox_ar1_v == 1
            plot(fd1,po,fd1,pth*ones(size(fd1')),'LineWidth',1); 
            text(0.3*fmax*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
        else
            plot(fd1,po,'k-','LineWidth',1); 
        end

        xlabel(['Frequency (cycles/',num2str(unit),')']) 
        xlim([0 fmax]);
    end
    
    ylabel('Power ')
    title(['Lomb-Scargle spectrum','; bw = ',num2str(df)])
    set(gcf,'Name',[dat_name,ext,': Lomb-Scargle spectrum'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    if handles.linlogY == 1
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
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        %legend('Power','95% global','99% local','95% local','90% local','Power law')
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
        ylabel('Power')
        title(['Lomb-Scargle spectrum & power law','; bw = ',num2str(df)])
        set(gcf,'Name',['Lomb-Scargle spectrum & power law: ',dat_name,ext])
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
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','BPL')
        ylabel('Power')
        title(['Lomb-Scargle spectrum & bending power law','; bw = ',num2str(df)])
        set(gcf,'Name',['Lomb-Scargle spectrum & bending power law: ',dat_name,ext])
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
    
    if plot_x_period
        pt1 = 1./fd1;
        plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
        xlabel(['Period (',num2str(unit),')']) 
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
            %plot(pt1,tabtchired999,'g--','LineWidth',1)
            %legend('Power','Mean','90%','95%','99%','99.9')
            legend('Power','Mean','90%','95%','99%')
        end
    else
        plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
        xlabel(['Frequency (cycles/',num2str(unit),')']) 
        xlim([0 fmax]);
        if handles.checkbox_ar1_v == 1
            [theored]=theoredar1ML(datax,fd1,mean(po),dt);
            tabtchired90 = theored * chi2inv(90/100,2)/2;
            tabtchired95 = theored * chi2inv(95/100,2)/2;
            tabtchired99 = theored * chi2inv(99/100,2)/2;
            %tabtchired999 = theored * chi2inv(99.9/100,2)/2;
            hold on
            plot(fd1,theored,'k-','LineWidth',2)
            plot(fd1,tabtchired90,'r-','LineWidth',1)
            plot(fd1,tabtchired95,'r--','LineWidth',2)
            plot(fd1,tabtchired99,'b-.','LineWidth',1)
            %plot(fd1,tabtchired999,'g--','LineWidth',1)
            %legend('Power','Mean','90%','95%','99%','99.9%')
            legend('Power','Mean','90%','95%','99%')
        end
    end
    
    ylabel('Power ')
    title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
    set(gcf,'Name',['Periodogram & AR1: ',dat_name,ext])
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
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        %legend('Power','95% global','99% local','95% local','90% local','Power law')
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
        ylabel('Power')
        title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
        set(gcf,'Name',['Periodogram & power law: ',dat_name,ext])
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
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','BPL')
        ylabel('Power')
        title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
        set(gcf,'Name',['Periodogram & bending power law: ',dat_name,ext])
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
        figwarn = warndlg({'Data may be interpolated to an uniform sampling interval';...
            '';'    Or select : Lomb-Scargle spectrum'});
        set(figwarn,'units','norm') % set location
        set(figwarn,'position',[0.5,0.8,0.225,0.09]) % set position
    end
    if handles.checkbox_robustAR1_v == 1
        dlg_title = 'Robust AR(1) Estimation';
        prompt = {'Median smoothing window: default 0.2 = 20%';...
            'AR1 best fit model? 1 = linear; 2 = log power (default)';...
            'Bias correction for ultra-high resolution data'};
        num_lines = 1;
        if BiasCorr == 0
            defaultans = {num2str(0.2),num2str(2),num2str(0)};
        else
            defaultans = {num2str(0.2),num2str(2),num2str(1)};
        end
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);

        if ~isempty(answer)
            smoothwin = str2double(answer{1});
            linlog = str2double(answer{2});
            biascorr = str2double(answer{3});
            
            if length(datax)>2000
                hwarn = warndlg('Large dataset, wait ...');
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
            ylabel('Power')
            smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
            legend('Power',smthwin,'Robust AR(1) median',...
                'Robust AR(1) 90%','Robust AR(1) 95%','Robust AR(1) 99%')
            set(gcf,'units','norm') % set location
            set(gcf,'position',[0.0,0.45,0.45,0.45]) % set position
            %end
            
            if plot_x_period
                update_spectral_x_period_mtm
            else
                title([dat_name,'-',num2str(nw),'\pi-MTM-Robust-AR1: \rho = ',num2str(rhoM),'. S0 =',num2str(s0M),'; bw = ',num2str(bw)])
                
                xlabel(['Frequency (cycles/',num2str(unit),')']) 
                set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
                set(gca,'XMinorTick','on','YMinorTick','on')
                xlim([0 fmax]);
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
        dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ',', 'precision', 9);
        disp('>>  Refresh main window to see red noise estimation data files: ')
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
        ylabel('Power')
        title([num2str(nw),'\pi MTM & power law','; bw = ',num2str(bw)])
        set(gcf,'Name',[num2str(nw),'\pi MTM & power law: ',dat_name,ext])
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
        dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ',', 'precision', 9);
        disp('>>  Refresh main window to see red noise estimation data files: ')
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,theored1,'k-','LineWidth',2)
        end
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','BPL')
        ylabel('Power')
        title([num2str(nw),'\pi MTM & bending power law','; bw = ',num2str(bw)])
        set(gcf,'Name',[num2str(nw),'\pi MTM & bending power law: ',dat_name,ext])
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
        
    if and( handles.checkbox_robustAR1_v == 0, handles.checkbox_ar1_v == 0)
        if plot_x_period
            update_spectral_x_period_mtm
        else
            figdata = figure;
            figHandle = gcf;
            set(gcf,'Color', 'white')
            plot(fd1,po,'LineWidth',1); 
            line([0.7*fmax, 0.7*fmax+bw],[0.8*max(po), 0.8*max(po)],'Color','r')
            xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
            ylabel('Power ')
            legend('Power','bw')
            title([num2str(nw),' \pi MTM method; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(bw)])
            set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
            xlim([0 fmax]);
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
        hwaitbar = waitbar(0,'Classic red noise estimation may take a few minutes...',...    
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
    %     if strcmp(handles.checkbox_ar1_check,'tabtchi')
            step = 2.5;
            waitbar(step / steps)
            [fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconftabtchi(datax,nw,dt,nzeropad,2);
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            ylabel('Power ')
            title([num2str(nw),'\pi MTM classic AR1: \rho = ',num2str(rho),'; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(bw)])
            
    step = 5.5;
        waitbar(step / steps)
        delete(hwaitbar)
        xlim([0 fmax]);
        if handles.linlogY == 1;
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
        dlmwrite(filename_mtm_cl, [fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999], 'delimiter', ',', 'precision', 9);
        disp('>>  Refresh the Main Window to see output data')
        %disp(filename_mtm)
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
            %xlim([0 fmax]);
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
            title('Adaptive weighted degrees of freedom')
            subplot(2,1,2); 
            plot(freq,Faz,'color','k','LineWidth',1)
            xlim([0 fmax])
            title('Harmonic phase')
            ylabel('Frequency')
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
        dlmwrite(nameftest, dataftest, 'delimiter', ',', 'precision', 9);
        dlmwrite(namefsig, datafsig, 'delimiter', ',', 'precision', 9);
        dlmwrite(namefamp, dataamp, 'delimiter', ',', 'precision', 9);
        dlmwrite(namefrest, datarest, 'delimiter', ',', 'precision', 9);
        %disp('>>  Refresh main window to see red noise estimation data files: ')
        disp(nameftest)
        disp(namefsig)
        disp(namefamp)
        cd(pre_dirML);
    
    end
    
elseif strcmp(method,'Lomb-Scargle spectrum')
    
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
        xlabel(['Period (',num2str(unit),')']) 
        xlim([1/fmax, pt1(3)]);
        set(gca, 'XDir','reverse')
    else
        if handles.checkbox_ar1_v == 1
            plot(fd1,po,fd1,pth*ones(size(fd1')),'LineWidth',1); 
            text(0.3*fmax*[1 1 1 1],pth-.5,[repmat('P_{fa} = ',[4 1]) num2str(pfa')])
        else
            plot(fd1,po,'LineWidth',1); 
        end
        xlabel(['Frequency (cycles/',num2str(unit),')']) 
        xlim([0 fmax]);
    end
    ylabel('Power ')
    title(['Lomb-Scargle spectrum','; bw = ',num2str(df)])
    set(gcf,'Name',[dat_name,ext,': Lomb-Scargle spectrum'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    if handles.linlogY == 1
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
        name1 = [dat_name,'-Lomb-PL-local',ext];
        data1 = [fd1,po,pl,red90,red95,red99];
        name2 = [dat_name,'-Lomb-PL-global',ext];
        data2 = [fd1,po,pl,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ',', 'precision', 9);
        disp('>>  Refresh main window to see red noise estimation data files: ')
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
        ylabel('Power')
        title(['Lomb-Scargle spectrum & power law','; bw = ',num2str(df)])
        set(gcf,'Name',['Lomb-Scargle spectrum & power law: ',dat_name,ext])
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
            
        name1 = [dat_name,'-Lomb-BPL-local',ext];
        data1 = [fd1,po,pl,red90,red95,red99];
        name2 = [dat_name,'-Lomb-BPL-global',ext];
        data2 = [fd1,po,pl,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ',', 'precision', 9);
        disp('>>  Refresh main window to see red noise estimation data files: ')
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','BPL')
        ylabel('Power')
        title(['Lomb-Scargle spectrum & bending power law','; bw = ',num2str(df)])
        set(gcf,'Name',['Lomb-Scargle spectrum & bending power law: ',dat_name,ext])
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
    plot(fd1(2:end),po(2:end),'k-','LineWidth',1);
    xlabel(['Frequency ( cycles/ ',num2str(unit),' )']) 
    ylabel('Power ')
    title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
    set(gcf,'Name',[dat_name,ext,': periodogram'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([0 fmax]);
    if handles.linlogY == 1;
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
        legend('Power','Mean','90%','95%','99%','99.9')
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
        dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ',', 'precision', 9);
        disp('>>  Refresh main window to see red noise estimation data files: ')
        disp(name1)
        disp(name2)
        cd(pre_dirML);
            
        figpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        %legend('Power','95% global','99% local','95% local','90% local','Power law')
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','Power law')
        ylabel('Power')
        title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
        set(gcf,'Name',['Periodogram & power law: ',dat_name,ext])
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
        name1 = [dat_name,'-Periodogram-BPL-local',ext];
        data1 = [fd1,po,pl,red90,red95,red99];
        name2 = [dat_name,'-Periodogram-BPL-global',ext];
        data2 = [fd1,po,pl,red90global,red95global,red99global];
        CDac_pwd;
        dlmwrite(name1, data1, 'delimiter', ',', 'precision', 9);
        dlmwrite(name2, data2, 'delimiter', ',', 'precision', 9);
        disp('>>  Refresh main window to see red noise estimation data files: ')
        disp(name1)
        disp(name2)
        cd(pre_dirML);
        
        figbpl = figure;
        set(gcf,'Color', 'white')
        if plot_x_period
            pt1 = 1./fd1;
            plot(pt1(2:end),po(2:end),'k-','LineWidth',1);
            xlabel(['Period (',num2str(unit),')']) 
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
            xlim([0 fmax]);
            xlabel(['Frequency (cycles/',num2str(unit),')']) 
            hold on
            plot(fd1,red99global,'r-.','LineWidth',1)
            plot(fd1,red95global,'r--','LineWidth',2)
            plot(fd1,red90global,'r-','LineWidth',1)
            plot(fd1,red99,'b-.','LineWidth',1)
            plot(fd1,red95,'b--','LineWidth',2)
            plot(fd1,red90,'b-','LineWidth',1)
            plot(fd1,pl,'k-','LineWidth',2)
        end
        legend('Power','99% global','95% global','90% global','99% local','95% local','90% local','BPL')
        ylabel('Power')
        title(['Periodogram; Sampling rate = ',num2str(dt),' ', unit,'; bw = ',num2str(df)])
        set(gcf,'Name',['Periodogram & bending power law: ',dat_name,ext])
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
            'delimiter', ',', 'precision', 9);
    catch
        filename_Periodogram = [dat_name,'-Periodogram.txt'];
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
if strcmp(method,'Multi-taper method')
    if handles.datasample == 1
        msgbox('Sampling rate may not be uneven! Ignore if this is not ture.','Waning')
    end
    set(handles.popupmenu_tapers,'Enable','on')
    set(handles.checkbox_robust,'Enable','on')
    set(handles.checkbox_ar1_check,'Enable','on')
    set(handles.checkbox_ar1_check,'String','Classical AR(1)')
    set(handles.check_ftest,'Value', handles.check_ftest_value)
    set(handles.check_ftest,'Visible','on')
elseif strcmp(method,'Periodogram')
    if handles.datasample == 1
        msgbox('Sampling rate may not be uneven! Ignore if this is not ture.','Waning')
    end
    set(handles.popupmenu_tapers,'Enable','off')
    set(handles.checkbox_robust,'Enable','off')
    set(handles.checkbox_ar1_check,'Enable','on')
    set(handles.checkbox_ar1_check,'String','Classical AR(1)')
    set(handles.check_ftest,'Visible','off')
elseif strcmp(method,'Lomb-Scargle spectrum')
    set(handles.popupmenu_tapers,'Enable','off')
    set(handles.checkbox_robust,'Enable','off')
    set(handles.checkbox_robust,'Value',1)
    set(handles.checkbox_ar1_check,'Value',0)
    set(handles.checkbox_ar1_check,'String','White noise')
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

