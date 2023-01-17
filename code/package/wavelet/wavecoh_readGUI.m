% wavelet read gui settings

% Designed for Acycle: wavelet analysis coherence
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

% read data and settings
data_name = handles.data_name;
%data = handles.current_data;
s2 = data_name(1,:);
s2(s2 == ' ') = [];
dat1 = load(s2);
dat1 = sortrows(dat1);
s2 = data_name(2,:);
s2(s2 == ' ') = [];
dat2 = load(s2);
dat2 = sortrows(dat2);

[dat_dir,dn1,exten] = fileparts(data_name(1,:));
[dat_dir,dn2,exten] = fileparts(data_name(2,:));

xmin = max( min(dat1(:,1), min(dat2(:,1))));
xmax = min( max(dat1(:,1), max(dat2(:,1))));
dat1 = select_interval(dat1,xmin,xmax);

% ensure time are equal
Dti1 = diff(dat1(:,1));
dt = mean(Dti1);
if max(Dti1) - min(Dti1) > 10 * eps('single')
    [dat1]=interpolate(dat1,dt);
end
if isequal(dat1(:,1),dat2(:,1))
else
    dat2int2 = interp1(dat2(:,1),dat2(:,2),dat1(:,1));
    dat2  = [dat1(:,1),dat2int2];
end

data_standardize = get(handles.checkbox11,'value');
% read settings from GUI
pt1 = str2double(get(handles.edit3,'string'));
pt2 = str2double(get(handles.edit4,'string'));
pad = get(handles.checkbox1,'value');
method_list= get(handles.popupmenu1,'string');
method_sel = get(handles.popupmenu1,'value');
method = method_list{method_sel};

plot_sl = get(handles.checkbox9,'value');
param = str2double(get(handles.edit7,'string'));
MonteCarloCount = str2double(get(handles.edit11,'string'));
dss = str2double(get(handles.edit5,'string'));  % dss or phase limit
wtcthreshold = str2double(get(handles.edit10,'string'));  % dss or phase limit

if get(handles.radiobutton1,'value')
    plot_linelog = 1;
else
    plot_linelog = 0;
end
param = str2double(get(handles.edit7,'string'));
if param <= 0; param =-1; end
method_i = get(handles.popupmenu1,'value');
plot_series = get(handles.checkbox2,'value');
plot_phase = get(handles.checkbox3,'value');
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

%lang

lang_var = handles.lang_var;
[~, wave19] = ismember('wave19',handles.lang_id);
[~, wave26] = ismember('wave26',handles.lang_id);
[~, wave20] = ismember('wave20',handles.lang_id);
[~, wave21] = ismember('wave21',handles.lang_id);
[~, wave22] = ismember('wave22',handles.lang_id);
[~, wave23] = ismember('wave23',handles.lang_id);
[~, wave24] = ismember('wave24',handles.lang_id);
[~, main01] = ismember('main01',handles.lang_id);

try
    Yticks = strread(get(handles.edit8,'String'));
    Yticks = sort(Yticks);
catch
    Yticks = [];
    msgbox({lang_var{wave19};lang_var{wave26}},lang_var{wave21})
end

if get(handles.radiobutton3,'value')
    plot_2d = 1;  % 2d
else
    plot_2d = 0;  % 3d
end
plot_save = get(handles.checkbox7,'value');

% If has to rerun wavelet
if handles.wavehastorerun
    
    datax = dat1(:,1);
    dat1y = dat1(:,2);
    dat2y = dat2(:,2);

    handles.datax = datax;
    handles.dat1y = dat1y;
    handles.dat2y = dat2y;
    disp(lang_var{wave20})
    if method_sel == 1 
        variance = std(dat1y)^2;
        variance2 = std(dat2y)^2;
        if data_standardize
            dat1y = (dat1y - mean(dat1y))/sqrt(variance);
            dat2y = (dat2y - mean(dat2y))/sqrt(variance2);
        end
        dt = mean(diff(datax));
        fs = 1/dt;
        [wcoh,wcs,period,coi] = wcoherence(dat1y,dat2y,fs,'PhaseDisplayThreshold',wtcthreshold);
        % save output into memory
        handles.period = period;
        handles.wcoh = wcoh;
        handles.wcs = wcs;
        handles.coi = coi;
        handles.dt = dt;

        assignin('base','datax',datax)
        assignin('base','dat1y',dat1y)
        assignin('base','dat2y',dat2y)
        assignin('base','period',period)
        assignin('base','wcoh',wcoh)
        assignin('base','wcs',wcs)
        assignin('base','coi',coi)

        handles.wavehastorerun = 0;

        if plot_save 

            name1 = [dn1,'-',dn2,'-wcoh.fig'];
            name4 = [dn1,'-',dn2,'-wcoh-wcs.txt'];
            name5 = [dn1,'-',dn2,'-wcoh-wcoh.txt'];
            CDac_pwd
            try savefig(handles.figwave,name1)
                
                disp(['>>  ',lang_var{main01},': ',name1, ' @ '])
                disp(pwd)
            catch
                disp(lang_var{wave23})
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
    elseif method_sel == 2
        wtcML;  % main script for wavelet coherence
        handles.Rsq = Rsq;
        handles.Wxy = Wxy;
        handles.wtcsig = wtcsig;
        handles.sig95 = sig95;
        handles.coi = coi;
        handles.t = t;
        handles.dt = dt;
        handles.datax = datax;
        handles.dat1y = dat1y;
        handles.dat2y = dat2y;
        handles.period = period;
        handles.coi = coi;
        handles.ArrowDensity = ArrowDensity;
        handles.ArrowSize = ArrowSize;
        handles.ArrowHeadSize = ArrowHeadSize;
        handles.sigmax = sigmax;
        handles.sigmay = sigmay;
        
        if plot_save 
            
            name1 = [dn1,'-',dn2,'-wct.fig'];
            name2 = [dn1,'-',dn2,'-xwt.fig'];
            name4 = [dn1,'-',dn2,'-wct-wcs.txt'];
            name5 = [dn1,'-',dn2,'-xwt.txt'];
            
            name6 = [dn1,'-',dn2,'-wct-wtcsig.txt'];
            name7 = [dn1,'-',dn2,'-xwt-sig95.txt'];
            name8 = [dn1,'-',dn2,'-wct-coi.txt'];
            CDac_pwd
            try savefig(handles.figwave,name1)
                disp(['>>  ',lang_var{main01},': ',name1, ' @ '])
                disp(pwd)
            catch
                disp(lang_var{wave23})
            end
            try savefig(handles.figxwt,name2)
                disp(['>>  ',lang_var{main01},': ',name2, ' @ '])
                disp(pwd)
            catch
                disp(lang_var{wave23})
            end
            try close(figwarnwave)
            catch
            end
            wcoh_mat =  [[nan,datax'];[period',Rsq]];
            wcs_mat   = Wxy';
            dlmwrite(name4,wcoh_mat , 'delimiter', ',', 'precision', 9);
            dlmwrite(name5, wcs_mat, 'delimiter', ',', 'precision', 9);
            dlmwrite(name6, wtcsig, 'delimiter', ',', 'precision', 9);
            dlmwrite(name7, sig95, 'delimiter', ',', 'precision', 9);
            dlmwrite(name8, coi, 'delimiter', ',', 'precision', 9);
            d = dir; %get files
            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
            refreshcolor;
            cd(pre_dirML); % return to matlab view folder

        end
        
    end
else
    disp(lang_var{wave24})
        
    if method_sel == 1
        % read memory to save time because wavelet analysis can be time
        % consuming
        datax = handles.datax;
        dat1y = handles.dat1y ;
        dat2y = handles.dat2y ;
        period = handles.period;
        coi = handles.coi;
        dt = handles.dt;
        wcoh = handles.wcoh;
        wcs = handles.wcs;
    elseif method_sel == 2
        Rsq = handles.Rsq;
        Wxy = handles.Wxy;
        wtcsig = handles.wtcsig;
        sig95 = handles.sig95;
        t = handles.t;
        dt = handles.dt;
        datax = handles.datax;
        dat1y = handles.dat1y ;
        dat2y = handles.dat2y ;
        period = handles.period;
        coi = handles.coi;
        ArrowDensity = handles.ArrowDensity;
        ArrowSize = handles.ArrowSize;
        ArrowHeadSize = handles.ArrowHeadSize;
        sigmax = handles.sigmax;
        sigmay = handles.sigmay;
    end
end


% plot
xlim = [min(datax),max(datax)];
