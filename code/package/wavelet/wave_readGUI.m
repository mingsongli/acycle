% wavelet read gui settings

% Designed for Acycle: wavelet analysis
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

% read data and settings
dat_name = handles.filename1;
data = handles.current_data;
data_standardize = get(handles.checkbox11,'value');
% read settings from GUI
pt1 = str2double(get(handles.edit3,'string'));
pt2 = str2double(get(handles.edit4,'string'));
dss = str2double(get(handles.edit5,'string'));
if get(handles.radiobutton1,'value');
    plot_linelog = 1;
else
    plot_linelog = 0;
end
pad = get(handles.checkbox1,'value');
method_list= get(handles.popupmenu1,'string');
method_sel = get(handles.popupmenu1,'value');
method = method_list{method_sel};
mother_list= get(handles.popupmenu2,'string');
mother_sel = get(handles.popupmenu2,'value');
mother = mother_list{mother_sel};
param = str2double(get(handles.edit7,'string'));
if param <= 0; param =-1; end
plot_series = get(handles.checkbox2,'value');
plot_spectrum = get(handles.checkbox3,'value');
plot_coi = get(handles.checkbox8,'value');
plot_flipx = get(handles.checkbox4,'value');
plot_flipy = get(handles.checkbox5,'value');
plot_swap = get(handles.checkbox6,'value');
plot_sl = get(handles.checkbox9,'value');
plot_log2pow = get(handles.checkbox10,'value');
plot_z = get(handles.checkbox12,'value');
colormap_list= get(handles.popupmenu3,'string');
colormap_sel = get(handles.popupmenu3,'value');
plot_colormap = colormap_list{colormap_sel};
plot_colorgrid = str2double(get(handles.edit6,'string'));
if plot_colorgrid > 0
    if ~isinteger(plot_colorgrid)
        plot_colorgrid = round(plot_colorgrid);
        set(handles.edit6,'string',num2str(plot_colorgrid))
    end
else
    plot_colorgrid = [];
    set(handles.edit6,'string','')
end

try
    Yticks = strread(get(handles.edit8,'String'));
    Yticks = sort(Yticks);
catch
    Yticks = [];
    msgbox({'User defined tick labels, space delimited values, e.g.,';'10 20 41 100 405 1200 2400'},'Help: format')
end

if get(handles.radiobutton3,'value')
    plot_2d = 1;  % 2d
else
    plot_2d = 0;  % 3d
end
plot_save = get(handles.checkbox7,'value');

% If has to rerun wavelet
if handles.wavehastorerun
    disp('  Key parameters updated/changed. Re-run wavelet : done')
    
    % Continous Wavelet Transform by (C) Aslak Grinsted 2002-2014
    if method_sel == 2
        %dss = 1/12;
        % ------validate and reformat timeseries.
        [data,dt]=formatts(data);
        datax = data(:,1);
        datay = data(:,2);
        variance = std(datay)^2;
        n=size(data,1);
        sigma2=var(data(:,2));
        s0 = 2*dt;
        MaxScale=(n*.17)*2*dt; %automaxscale
        j1=round(log2(MaxScale/s0)/dss);
        lag1 = ar1nv(data(:,2));
        if any(isnan(lag1))
            error('Automatic AR1 estimation failed. Specify it manually (use arcov or arburg).')
        end
    else
        datax = data(:,1);
        datay = data(:,2);
        variance = std(datay)^2;
        if data_standardize
            datay = (datay - mean(datay))/sqrt(variance);
        end
        n = length(datax);
        dt = mean(diff(datax));
        s0 = 2*dt;    %
        j1 = round(log2(pt2))/dss; % end
        lag1 = rhoAR1ML(datay);
    end
    % Wavelet transform:
    [wave,period,scale,coi] = wavelet(datay,dt,pad,dss,s0,j1,mother,param);
    power = (abs(wave)).^2 ;        % compute wavelet power spectrum
    
    % Significance levels: (variance=1 for the normalized datay)
    if method_sel == 2
        [signif,fft_theor] = wave_signif(1.0,dt,scale,0,lag1,-1,-1,mother,param);
        sig95 = (signif')*(ones(1,n));  % expand signif --> (J+1)x(N) array
        sig95 = power ./ (sigma2*sig95);
    else
        [signif,fft_theor] = wave_signif(datay,dt,scale,0,lag1,-1,-1,mother,param);
        sig95 = (signif')*(ones(1,n));  % expand signif --> (J+1)x(N) array
        sig95 = power ./ sig95;         % where ratio > 1, power is significant
    end
    
    % Global wavelet spectrum & significance levels:
    global_ws = variance*(sum(power')/n);   % time-average over all times
    dof = n - scale;  % the -scale corrects for padding at edges
    global_signif = wave_signif(variance,dt,scale,1,lag1,-1,dof,mother,param);
    
    if method_sel <3
        % Rectification of the bias in the Wavelet power spectrum with the data set
        % (Nino3.dat) given by Torrence and Compo (1998).  This code is modified
        % from wavetest.m, the example script provided by Torrence and Compo
        % (1998), to demonstrate how to rectify the bias in wavelet power spectrum.
        % This code generates Figure 4 of Liu et al. (2007).
        %
        % Yonggang Liu, 2006.4.12
        %
        % E-mail:  yliu18@gmail.com
        % http://ocgweb.marine.usf.edu/~liu/wavelet.html
        %
        % References:
        %
        % Liu, Y., X.S. Liang, and R.H. Weisberg, 2007: Rectification of the bias
        % in the wavelet power spectrum. Journal of Atmospheric and Oceanic 
        % Technology, 24(12), 2093-2102.
        %==================  Bias rectification start  =========================
         %--- divided by scales:
           for k=1:length(scale)
             powers(k,:) = power(k,:)/scale(k);
           end
           global_ws = global_ws./scale;
          power = powers;
        %==================  Bias rectification end  =========================
    end
    
    % save output into memory
    handles.datax = datax;
    handles.datay = datay;
    handles.dt = dt;
    handles.period = period;
    handles.power = power;
    handles.sig95 = sig95;
    handles.coi = coi;
    handles.global_ws = global_ws;
    handles.global_signif = global_signif;
    if method_sel == 2
        handles.sigma2 = sigma2;
    end
    
    handles.wavehastorerun = 0;
    
    if plot_save 
        
        name1 = [dat_name,'-wavelet.fig'];
        name4 = [dat_name,'-wavelet-power.txt'];
        name5 = [dat_name,'-wavelet-siglev.txt'];
        CDac_pwd
        try savefig(handles.figwave,name1)
            disp(['>>  Save as: ',name1, '. Folder: '])
            disp(pwd)
        catch
            disp('>>  Error. Wavelet figure unsaved. Save manually if needed ...')
        end
        try close(figwarnwave)
        catch
        end
        power_mat = [nan,period;datax,power'];
        sig_mat   = [nan,period;datax,sig95'];
        dlmwrite(name4, power_mat, 'delimiter', ',', 'precision', 9);
        dlmwrite(name5, sig_mat, 'delimiter', ',', 'precision', 9);
        d = dir; %get files
        set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
        refreshcolor;
        cd(pre_dirML); % return to matlab view folder
        
    end
    
else
    disp('  Wavelet: Parameters unchanged. Use existing analysis for plots')
    % read memory to save time because wavelet analysis can be time
    % consuming
    datax = handles.datax;
    datay = handles.datay ;
    dt = handles.dt ;
    period = handles.period;
    power = handles.power;
    sig95 = handles.sig95;
    coi = handles.coi;
    global_ws = handles.global_ws;
    global_signif = handles.global_signif;
    if method_sel == 2
        sigma2  = handles.sigma2;
    end
end

% levels
plot_base = str2double(get(handles.edit9,'string'));
if method_sel == 3
    powermax = floor(log2(max(power(:))));
    % levels
    plot_level_vector = -1*powermax:powermax;
    power(power< plot_base^(-1*powermax)) = plot_base^(-1*powermax);
elseif method_sel < 3
    powermax = floor(log2(max(power(:))));
    powermin = floor(log2(min(power(:))));
    plot_level_vector = powermin:powermax;
end
%plot_level_vector = -1:powermax;
levels = plot_base.^plot_level_vector;
% plot
xlim = [min(datax),max(datax)];