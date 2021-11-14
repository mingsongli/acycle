% wavelet read gui settings

% Designed for Acycle: wavelet analysis coherence
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

% read data and settings
dat_name = handles.filename1;
data_name = handles.data_name;
%data = handles.current_data;
s2 = data_name(1,:);
s2(s2 == ' ') = [];
dat1 = load(s2);
s2 = data_name(2,:);
s2(s2 == ' ') = [];
dat2 = load(s2);

data_standardize = get(handles.checkbox11,'value');
% read settings from GUI
pt1 = str2double(get(handles.edit3,'string'));
pt2 = str2double(get(handles.edit4,'string'));
dss = str2double(get(handles.edit5,'string'));  % dss or phase limit
if get(handles.radiobutton1,'value')
    plot_linelog = 1;
else
    plot_linelog = 0;
end
param = str2double(get(handles.edit7,'string'));
if param <= 0; param =-1; end
plot_series = get(handles.checkbox2,'value');
plot_spectrum = get(handles.checkbox3,'value');
plot_coi = get(handles.checkbox8,'value');
plot_flipx = get(handles.checkbox4,'value');
plot_flipy = get(handles.checkbox5,'value');
plot_swap = get(handles.checkbox6,'value');
plot_log2pow = get(handles.checkbox10,'value');
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
    disp('  Key parameters updated/changed. Re-run Wavelet coherence and cross-spectrum : done')
    datax = dat1(:,1);
    dat1y = dat1(:,2);
    dat2y = dat2(:,2);
    variance = std(dat1y)^2;
    variance2 = std(dat2y)^2;
    if data_standardize
        dat1y = (dat1y - mean(dat1y))/sqrt(variance);
        dat2y = (dat2y - mean(dat2y))/sqrt(variance2);
    end
    dt = mean(diff(datax));
    fs = 1/dt;
    [wcoh,wcs,period,coi] = wcoherence(dat1y,dat2y,fs,'PhaseDisplayThreshold',dss);
    % save output into memory
    handles.datax = datax;
    handles.dat1y = dat1y;
    handles.dat2y = dat2y;
    handles.period = period;
    handles.wcoh = wcoh;
    handles.wcs = wcs;
    handles.coi = coi;
    
    assignin('base','datax',datax)
    assignin('base','dat1y',dat1y)
    assignin('base','dat2y',dat2y)
    assignin('base','period',period)
    assignin('base','wcoh',wcoh)
    assignin('base','wcs',wcs)
    assignin('base','coi',coi)
    
    handles.wavehastorerun = 0;
    
    if plot_save 
        
        name1 = [dat_name,'-wcoh.fig'];
        name4 = [dat_name,'-wcoh-wcs.txt'];
        name5 = [dat_name,'-wcoh-wcoh.txt'];
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
        wcoh_mat =  [[nan;datax],[period';wcoh']];
        wcs_mat   = wcs';
        dlmwrite(name4, wcs_mat, 'delimiter', ',', 'precision', 9);
        dlmwrite(name5, wcoh_mat, 'delimiter', ',', 'precision', 9);
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
    dat1y = handles.dat1y ;
    dat2y = handles.dat2y ;
    period = handles.period;
    wcoh = handles.wcoh;
    wcs = handles.wcs;
    coi = handles.coi;
end

% plot
xlim = [min(datax),max(datax)];