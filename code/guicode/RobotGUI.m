% Mini-robot function
function RobotGUI(varargin)

%% read data and unit type
data = varargin{1}.data_filterout;
dat_name = varargin{1}.dat_name;
unit = varargin{1}.unit;
unit_type = varargin{1}.unit_type;
listbox_acmain = varargin{1}.listbox_acmain;
edit_acfigmain_dir= varargin{1}.edit_acfigmain_dir;
MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
%%
x = data(:,1);
y = data(:,2);
dtmean = nanmean(diff(sort(x)));
robot_sr = dtmean;
dtmedian = nanmedian(diff(sort(x)));
dtmax = nanmax(diff(sort(x)));
dtmin = nanmin(diff(sort(x)));
fnyq = 1/(2*dtmean);
winevofft = 0.35 * (nanmax(x)-nanmin(x));
wavep1 = 2*dtmean;  % default wavelet period 1
wavep2 = nanmax(x) - nanmin(x);  % default wavelet period 2
%% Open function
h_robot = figure('MenuBar','none','Name','Mini-Robot','NumberTitle','off');
set(h_robot,'units','norm') % set location
set(0,'Units','normalized') % set units as normalized
set(h_robot,'position',[0.4,0.2,0.3,0.6] * MonZoom,'Color','white') % set position

% data preparation
panel_prep = uipanel(h_robot,'Title','Prepare Data','FontSize',12,...
    'Position',[0.05 0.85 0.9 0.12],'BackgroundColor','white');
prep_NaN = uicontrol('Style','checkbox','String','Remove NaN',...
    'units','norm','Position',[0.07 0.86 0.25 0.08],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
prep_remempty = uicontrol('Style','checkbox','String','Remove Empty',...
    'units','norm','Position',[0.34 0.86 0.25 0.08],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
prep_sort = uicontrol('Style','checkbox','String','Sort',...
    'units','norm','Position',[0.62 0.86 0.12 0.08],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
prep_unique = uicontrol('Style','checkbox','String','Unique',...
    'units','norm','Position',[0.77 0.86 0.15 0.08],'Value',1,...
    'FontSize',11,'BackgroundColor','white');

% Interpolation
panel_interp = uipanel(h_robot,'Title','Interpolation','FontSize',12,...
    'Position',[0.05 0.7 0.9 0.12],'BackgroundColor','white');
interp_check = uicontrol('Style','checkbox','String','Yes',...
    'units','norm','Position',[0.07 0.71 0.1 0.08],'Value',1,...
    'FontSize',11,'Callback',@interp_check_Callback,'BackgroundColor','white');
interp_option = uicontrol('Style','popupmenu',...
    'String',{'mean','median','max','min','value'},...
    'units','norm','Position',[0.25 0.71 0.25 0.06],'Value',1,...
    'FontSize',11,'Callback',@popup_interp_Callback,'BackgroundColor','white');
interp_value = uicontrol('Style','edit','String',num2str(robot_sr),...
    'units','norm','Position',[0.6 0.72 0.15 0.06],...
    'Value',1,'Visible','off','FontSize',11,'Callback',@interp_v_Callback...
    ,'BackgroundColor','white');

% detrending
panel_detrend = uipanel(h_robot,'Title','Detrending','FontSize',12,...
    'Position',[0.05 0.55 0.9 0.12],'BackgroundColor','white');
detrend_check = uicontrol('Style','checkbox','String','Yes',...
    'units','norm','Position',[0.07 0.56 0.1 0.08],'Value',1,...
    'FontSize',11,'Callback',@detrend_check_Callback,'BackgroundColor','white');
detrend_option = uicontrol('Style','popupmenu',...
    'String',{'mean','linear','lowess','rlowess','loess','rloess'},...
    'units','norm','Position',[0.25 0.56 0.25 0.06],'Value',3,...
    'FontSize',11,'Callback',@popup_detrend_Callback,'BackgroundColor','white');
detrend_window = uicontrol('Style','text','String','Window size:',...
    'units','norm','Position',[0.5 0.56 0.2 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
detrend_windowedit = uicontrol('Style','edit','String','35',...
    'units','norm','Position',[0.71 0.57 0.1 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');  
detrend_windowp = uicontrol('Style','text','String',' %',...
    'units','norm','Position',[0.81 0.56 0.04 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');

% Power spectral analysis
panel_spectral = uipanel(h_robot,'Title','Spectral Analysis','FontSize',12,...
    'Position',[0.05 0.4 0.9 0.12],'BackgroundColor','white');
spectral_check = uicontrol('Style','checkbox','String','Yes',...
    'units','norm','Position',[0.07 0.405 0.1 0.08],'Value',1,...
    'FontSize',11,'Callback',@spectral_check_Callback,'BackgroundColor','white');
spectral_option = uicontrol('Style','popupmenu',...
    'String',{'Multi-taper','Peridogram'},'BackgroundColor','white',...
    'units','norm','Position',[0.18 0.405 0.26 0.06],'Value',1,...
    'FontSize',11,'Callback',@popup_spectral_Callback);
spectral_fmax = uicontrol('Style','text','String','Max Frequency',...
    'units','norm','Position',[0.45 0.415 0.14 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
spectral_fmaxedit = uicontrol('Style','edit','String',num2str(fnyq),...
    'units','norm','Position',[0.60 0.41 0.1 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
spectral_noise = uicontrol('Style','checkbox','String','red noise',...
    'units','norm','Position',[0.72 0.405 0.18 0.08],'Value',1,...
    'FontSize',11,'BackgroundColor','white');

% Evolutionary FFT
panel_evofft = uipanel(h_robot,'Title','Evolutionary spectral','FontSize',12,...
    'Position',[0.05 0.2 0.42 0.17],'BackgroundColor','white');
evofft_check = uicontrol('Style','checkbox','String','Yes',...
    'units','norm','Position',[0.07 0.23 0.1 0.08],'Value',1,...
    'FontSize',11,'Callback',@evofft_check_Callback,'BackgroundColor','white');
evofft_window = uicontrol('Style','text','String','Sliding window',...
    'units','norm','Position',[0.17 0.23 0.19 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
evofft_windowedit = uicontrol('Style','edit','String',num2str(winevofft),...
    'units','norm','Position',[0.36 0.24 0.1 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
% Wavelet
panel_wavelet = uipanel(h_robot,'Title','Wavelet','FontSize',12,...
    'Position',[0.5 0.2 0.45 0.17],'BackgroundColor','white');
wavelet_check = uicontrol('Style','checkbox','String','Yes',...
    'units','norm','Position',[0.51 0.23 0.1 0.08],'Value',1,...
    'FontSize',11,'Callback',@wavelet_check_Callback,'BackgroundColor','white');
wavelet_periodt1 = uicontrol('Style','text','String','Period from',...
    'units','norm','Position',[0.61 0.23 0.14 0.055],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
wavelet_period1 = uicontrol('Style','edit','String',num2str(wavep1),...
    'units','norm','Position',[0.75 0.24 0.08 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
wavelet_periodt2 = uicontrol('Style','text','String','to',...
    'units','norm','Position',[0.83 0.23 0.03 0.055],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
wavelet_period2 = uicontrol('Style','edit','String',num2str(wavep2),...
    'units','norm','Position',[0.86 0.24 0.08 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');

% Setting
panel_set = uipanel(h_robot,'Title','Settings','FontSize',12,...
    'Position',[0.05 0.05 0.62 0.12],'BackgroundColor','white');
set_pause = uicontrol('Style','text','String','Pause',...
    'units','norm','Position',[0.07 0.06 0.1 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
set_pauseedit = uicontrol('Style','edit','String','0.5',...
    'units','norm','Position',[0.18 0.07 0.1 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
set_second= uicontrol('Style','text','String','second',...
    'units','norm','Position',[0.29 0.06 0.1 0.06],'Value',1,...
    'FontSize',11,'BackgroundColor','white');
save_check = uicontrol('Style','checkbox','String','Save data',...
    'units','norm','Position',[0.42 0.06 0.17 0.08],'Value',1,...
    'FontSize',11,'BackgroundColor','white');

runbt = uicontrol('Style','pushbutton',...
    'units','norm','Position',[0.7 0.055 0.2 0.1],'Value',1,...
    'FontSize',12,'BackgroundColor','white','ForegroundColor','white',...
    'FontWeight','bold','Callback',@robot_Callback);
set(runbt,'CData',imread('menu_robot.jpg'))

%% callback functions
    function interp_check_Callback(source,eventdata)
        val = get(source,'Value');
        if val == 1
            set(interp_option,'Enable','on')
        else
            set(interp_option,'Enable','off')
        end
    end
    function interp_v_Callback(source,eventdata)
        str = get(source, 'String');
        robot_sr = str2double(str);
        if isnan(robot_sr)
            warndlg('Invalid Interpolation Rate!')
        end
    end
    function detrend_check_Callback(source,eventdata)
        val = get(source,'Value');
        if val == 1
            set(detrend_option,'Enable','on')
            set(detrend_windowedit,'Enable','on')
        else
            set(detrend_option,'Enable','off')
            set(detrend_windowedit,'Enable','off')
        end
    end
    function spectral_check_Callback(source,eventdata)
        val = get(source,'Value');
        if val == 1
            set(spectral_option,'Enable','on')
            set(spectral_fmaxedit,'Enable','on')
            set(spectral_noise,'Enable','on')
        else
            set(spectral_option,'Enable','off')
            set(spectral_fmaxedit,'Enable','off')
            set(spectral_noise,'Enable','off')
        end
    end
    function evofft_check_Callback(source,eventdata)
        val = get(source,'Value');
        if val == 1
            set(evofft_windowedit,'Enable','on')
        else
            set(evofft_windowedit,'Enable','off')
        end
    end
    function wavelet_check_Callback(source,eventdata)
        val = get(source,'Value');
        if val == 1
            set(wavelet_period1,'Enable','on')
            set(wavelet_period2,'Enable','on')
        else
            set(wavelet_period1,'Enable','off')
            set(wavelet_period2,'Enable','off')
        end
    end
    function popup_interp_Callback(source,eventdata)
    % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        switch str{val};
            case 'mean' % User selects mean.
                set(interp_value,'Visible','off')
                robot_sr = dtmean;
            case 'median' % User selects Membrane.
                set(interp_value,'Visible','off')
                robot_sr = dtmedian;
            case 'max' % User selects Sinc.
                set(interp_value,'Visible','off')
                robot_sr = dtmax;
            case 'min'
                set(interp_value,'Visible','off')
                robot_sr = dtmin;
            case 'value'
                set(interp_value,'Visible','on')
                robot_sr = [];
        end
    end
    function popup_detrend_Callback(source,eventdata)
        % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        switch str{val};
            case 'mean' % User selects mean.
                set(detrend_windowedit,'Visible','off')
                set(detrend_window,'Visible','off')
                set(detrend_windowp,'Visible','off')
                
            case 'linear' % User selects Membrane.
                set(detrend_windowedit,'Visible','off')
                set(detrend_window,'Visible','off')
                set(detrend_windowp,'Visible','off')
            case 'lowess' % User selects Sinc.
                set(detrend_windowedit,'Visible','on')
                set(detrend_window,'Visible','on')
                set(detrend_windowp,'Visible','on')
            case 'rlowess'
                set(detrend_windowedit,'Visible','on')
                set(detrend_window,'Visible','on')
                set(detrend_windowp,'Visible','on')
            case 'loess'
                set(detrend_windowedit,'Visible','on')
                set(detrend_window,'Visible','on')
                set(detrend_windowp,'Visible','on')
            case 'rloess'
                set(detrend_windowedit,'Visible','on')
                set(detrend_window,'Visible','on')
                set(detrend_windowp,'Visible','on')
        end
    end


%%
    function robot_Callback(source,eventdata)
        set(gcf,'Units','normalized','position',[0.66,0.05,0.3,0.6])
        
        check_nan = get(prep_NaN,'Value');
        check_sort = get(prep_sort,'Value');
        check_unique = get(prep_unique,'Value');
        check_empty = get(prep_remempty,'Value');
        check_interp_v = get(interp_check,'Value');
        check_detrend_v = get(detrend_check,'Value');
        check_spectral_v = get(spectral_check,'Value');
        check_evofft_v = get(evofft_check,'Value');
        check_wavelet_v = get(wavelet_check,'Value');
        
        robot_sr = robot_sr;
        robot_savedata  = get(save_check,'Value');
        robot_pause  = str2double(get(set_pauseedit,'String'));
        str1 = get(detrend_option,'String');
        val1 = get(detrend_option,'Value');
        robot_detrend = str1{val1};
        robot_detrendwin = str2double(get(detrend_windowedit,'String'));
        fmax = str2double(get(spectral_fmaxedit,'String'));
        robot_spectralmethod = get(spectral_option,'Value');
        winevofft = str2double(get(evofft_windowedit,'String'));
        ext = '.txt';
        wavep1 = str2double(get(wavelet_period1,'String'));
        wavep2 = str2double(get(wavelet_period2,'String'));
             
        if unit_type == 0
            warndlg(['Waning: Unit is "',unit,'". You may choose the correct unit.'])
        end
        name1 = dat_name;
        
%% Prepare
        dat = data(~any(isnan(data),2),:);
        % check NaN
        datx = dat(:,1); 
        daty = dat(:,2);
        if check_nan == 1
            if length(data(:,1)) > length(datx)
                warndlg('Data: NaN numbers removed.')
                disp('>>  ==========        removing NaNs')
                name1 = [name1,'NaN'];  % New name
            end
        end

        % check empty
        if check_empty == 1
            dat(any(isinf(dat),2),:) = [];
            if length(dat(:,1)) < length(datx)
                warndlg('Data: Empty numbers removed.')
                disp('>>  ==========        removing Empty numbers')
                name1 = [name1,'e'];  % New name
            end
        end

        % check order
        diffx = diff(dat(:,1));
        if check_sort == 1
            if any(diffx(:) < 0)
                 warndlg('Data: Not sorted. Now sorting ... ')
                 disp('>>  ==========        sorting')
                 dat = sortrows(dat);
                 name1 = [name1,'s'];  % New name
            end
        end
        
        % duplicate
        diffx = diff(dat(:,1));
        if check_unique == 1
            if any(diffx(:) == 0)
                 warndlg('Data: duplicated numbers are replaced with the mean')
                 disp('>>  ==========        duplicate numbers are replaced by the mean')
                 name1 = [name1,'u'];  % New name
                 dat=findduplicate(dat);
            end
        end

        %% save data
        if robot_savedata == 1
            pre_dirML = pwd;
            ac_pwd = fileread('ac_pwd.txt');
            if isdir(ac_pwd)
                cd(ac_pwd)
            end
            dlmwrite([name1,ext], dat, 'delimiter', ' ', 'precision', 9);
            disp(['>>  Saving data. See main window: ', name1,ext])
            d = dir; %get files
            set(listbox_acmain,'String',{d.name},'Value',1) %set string
            
            pre  = '<HTML><FONT color="blue">';
            post = '</FONT></HTML>';
            d = dir; %get files
            address = pwd;
            set(edit_acfigmain_dir,'String',address);
            listboxStr = cell(numel(d),1);
            % Save pwd into a text file
            ac_pwd_str = which('ac_pwd.txt');
            [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
            fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
            fprintf(fileID,'%s',address);
            fclose(fileID);
            %
            for i = 1:numel( d )
                if isdir(d(i).name)
                    str = [pre d(i).name post];
                    listboxStr{i} = str;
                else
                    listboxStr{i} = d(i).name;
                end
            end
            set(listbox_acmain,'String',listboxStr,'Value',1) %set string
            
            
            cd(pre_dirML); % return to matlab view folder
        end
%% Plot & Interpolation
        % plot data
        disp('>>')
        figf = figure;
        set(figf,'Units','normalized','position',[0.0,0.5,0.33,0.4])
        disp('>>  Plot data')
        subplot(3,1,1)
        try plot(dat(:,1),dat(:,2:end),'LineWidth',1,'Color','k')
            plotsucess = 1;
            set(gca,'XMinorTick','on','YMinorTick','on')
            if unit_type == 0;
                xlabel(['Unit (',unit,')'])
            elseif unit_type == 1;
                xlabel(['Depth (',unit,')'])
            else
                xlabel(['Time (',unit,')'])
            end
            title(['Data:', name1], 'Interpreter', 'none')
            xlim([min(dat(:,1)),max(dat(:,1))])
        catch
            plotsucess = 0;
            errordlg([name1,': data error.'],'Data Error')
            if plotsucess > 0
            else
                close(figf)
            end   
        end

        % Sampling rate
        datx = dat(:,1);
        daty = dat(:,2);
        diffx = diff(datx);
        len_x = length(datx);
        datasamp = [datx(1:len_x-1),diffx];
        datasamp = datasamp(~any(isnan(datasamp),2),:);
        % Plot sampling rate
        subplot(3,1,2)
        stairs(datasamp(:,1),datasamp(:,2),'LineWidth',1,'Color','k');
        set(gca,'XMinorTick','on','YMinorTick','on')
        if unit_type == 0;
            xlabel(['Unit (',unit,')'])
            ylabel('Unit')
        elseif unit_type == 1;
            xlabel(['Depth (',unit,')'])
            ylabel(unit)
        else
            xlabel(['Time (',unit,')'])
            ylabel(unit)
        end
        title([name1,': sampling rate'], 'Interpreter', 'none')
        xlim([min(datasamp(:,1)),max(datasamp(:,1))])
        ylim([0.9*min(diffx) max(diffx)*1.1])

        subplot(3,1,3)
        histfit(diffx,[],'kernel')
        title([name1,': kernel fit of the sampling rate'], 'Interpreter', 'none')
        if unit_type == 0;
            xlabel(['Sampling rate (',unit,')'])
        elseif unit_type == 1;
            xlabel(['Sampling rate (',unit,')'])
        else
            xlabel(['Sampling rate (',unit,')'])
        end
        ylabel('Number')
        note = ['max: ',num2str(max(diffx)),'; mean: ',num2str(mean(diffx)),...
            '; median: ',num2str(median(diffx)),'; min: ',num2str(min(diffx))];
        text(mean(diffx),len_x/10,note);
        % pause
        pause(robot_pause);
        
        % interpolation
        if check_interp_v == 1
            if nanmax(diffx) - nanmin(diffx) > eps('single')
                warndlg('Warning: Data may not be evenly spaced. Interpolation ...')
                disp('>>')
                disp('>>  ==========    Step 2: Interpolation    ==========')
                disp('>>')
                disp('>>  ==========        Sampling rates are not even')
                dati = interpolate(dat,robot_sr);
                name1 = [name1,'-rsp',num2str(robot_sr)];
                clear dat; 
                dat = dati;
                disp(['>>  ==========        interpolating using ', num2str(robot_sr),' sampling rate'])
                % save data
                if robot_savedata == 1
                    pre_dirML = pwd;
                    ac_pwd = fileread('ac_pwd.txt');
                    if isdir(ac_pwd)
                        cd(ac_pwd)
                    end
                    dlmwrite([name1,ext], dati, 'delimiter', ' ', 'precision', 9);
                    disp(['>>  Saving data. See main window: ', name1,ext])
                    d = dir; %get files
                    set(listbox_acmain,'String',{d.name},'Value',1) %set string
                    
                    pre  = '<HTML><FONT color="blue">';
                    post = '</FONT></HTML>';
                    d = dir; %get files
                    address = pwd;
                    set(edit_acfigmain_dir,'String',address);
                    listboxStr = cell(numel(d),1);
                    % Save pwd into a text file
                    ac_pwd_str = which('ac_pwd.txt');
                    [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
                    fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
                    fprintf(fileID,'%s',address);
                    fclose(fileID);
                    %
                    for i = 1:numel( d )
                        if isdir(d(i).name)
                            str = [pre d(i).name post];
                            listboxStr{i} = str;
                        else
                            listboxStr{i} = d(i).name;
                        end
                    end
                    set(listbox_acmain,'String',listboxStr,'Value',1) %set string
                    cd(pre_dirML); % return to matlab view folder
            
                end
            else
            end
        end
% 
%%             % detrend

        pause(robot_pause);
        
        if check_detrend_v == 1
            disp('>>')
            disp('>>  ==========    Step 3: Detrend    ==========')
            disp('>>')
            datx = dat(:,1);
            daty = dat(:,2);
            if strcmp(robot_detrend,'mean')
                name1 = [name1,'-',robot_detrend];
                dats(:,1) = datx;
                dats(:,2) = daty - mean(daty);
            elseif strcmp(robot_detrend,'linear')
                name1 = [name1,'-',robot_detrend];
                sdat=polyfit(datx,daty,1);
                datalinear = datx * sdat(1) + sdat(2);
                dats = [datx,daty-datalinear];
            else
                name1 = [name1,'-',num2str(robot_detrendwin),'%',robot_detrend];
                datxsmth = smooth(datx,daty, robot_detrendwin/100,robot_detrend);
                dats = [datx,daty-datxsmth];
            end
            % plot
            figure; 
            set(gcf,'Units','normalized','position',[0.33,0.5,0.33,0.4])
            plot(dat(:,1),dat(:,2));hold on;
            plot(dats(:,1),dats(:,2));
            plot(dats(:,1),daty-dats(:,2));
            set(gca,'XMinorTick','on','YMinorTick','on')
            if strcmp(robot_detrend,'mean')
                legend('Raw data','Demean data','Mean')
            elseif strcmp(robot_detrend,'linear')
                legend('Raw data','Demean data','Linear trend')
            else
                legend('Raw data','detrended data',[num2str(robot_detrendwin),'% ',robot_detrend,' trend'])
            end

            clear dat;
            dat = dats;
            datx = dat(:,1);
            daty = dat(:,2);
            dt = median(diff(datx));

            % save data
            if robot_savedata == 1
                pre_dirML = pwd;
                ac_pwd = fileread('ac_pwd.txt');
                if isdir(ac_pwd)
                    cd(ac_pwd)
                end
                dlmwrite([name1,ext], dat, 'delimiter', ' ', 'precision', 9);
                disp(['>>  Saving data. See main window: ', name1,ext])
                d = dir; %get files
                set(listbox_acmain,'String',{d.name},'Value',1) %set string
                pre  = '<HTML><FONT color="blue">';
                post = '</FONT></HTML>';
                d = dir; %get files
                address = pwd;
                set(edit_acfigmain_dir,'String',address);
                listboxStr = cell(numel(d),1);
                % Save pwd into a text file
                ac_pwd_str = which('ac_pwd.txt');
                [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
                fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
                fprintf(fileID,'%s',address);
                fclose(fileID);
                %
                for i = 1:numel( d )
                    if isdir(d(i).name)
                        str = [pre d(i).name post];
                        listboxStr{i} = str;
                    else
                        listboxStr{i} = d(i).name;
                    end
                end
                set(listbox_acmain,'String',listboxStr,'Value',1) %set string
                cd(pre_dirML); % return to matlab view folder
            end
        end
        % pause
        pause(robot_pause);

%% power spectrum
        if check_spectral_v == 1
            dt = median(diff(dat(:,1)));
            if robot_spectralmethod == 1
                disp('>>')
                disp('>>  ==========    Step 4: Power spctra & robustAR(1) noise   ==========')
                disp('>>')

                try
                    [rhoM, s0M,redconfAR1,redconfML96]=redconfML(dat(:,2),dt,2,5*length(dat(:,2)),2,0.25,fmax);
                    
                catch
                    [rhoM, s0M,redconfAR1,redconfML96]=redconfML(dat(:,2),dt,2);
                end
                xlim([0,fmax])
                set(gcf,'Units','normalized','position',[0.66,0.5,0.33,0.4])
                % save data
                if robot_savedata == 1
                    name11 = [name1,'-',num2str(2),'piMTM-RobustAR1.txt'];
                    data11 = redconfML96;
                    name2 = [name1,'-',num2str(2),'piMTM-ClassicAR1.txt'];
                    data2 = redconfAR1;

                    pre_dirML = pwd;
                    ac_pwd = fileread('ac_pwd.txt');
                    if isdir(ac_pwd)
                        cd(ac_pwd)
                    end
                    dlmwrite(name11, data11, 'delimiter', ' ', 'precision', 9);
                    dlmwrite(name2, data2, 'delimiter', ' ', 'precision', 9);
                    disp(['>>  Saving data. See main window: ', name11,ext])
                    disp(['>>  Saving data. See main window: ', name2,ext])
                    d = dir; %get files
                    set(listbox_acmain,'String',{d.name},'Value',1) %set string
                    pre  = '<HTML><FONT color="blue">';
                    post = '</FONT></HTML>';
                    d = dir; %get files
                    address = pwd;
                    set(edit_acfigmain_dir,'String',address);
                    listboxStr = cell(numel(d),1);
                    % Save pwd into a text file
                    ac_pwd_str = which('ac_pwd.txt');
                    [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
                    fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
                    fprintf(fileID,'%s',address);
                    fclose(fileID);
                    %
                    for i = 1:numel( d )
                        if isdir(d(i).name)
                            str = [pre d(i).name post];
                            listboxStr{i} = str;
                        else
                            listboxStr{i} = d(i).name;
                        end
                    end
                    set(listbox_acmain,'String',listboxStr,'Value',1) %set string
                    cd(pre_dirML); % return to matlab view folder
                end
                
            else
                disp('>>')
                disp('>>  ==========    Step 4: Power spctra & noise   ==========')
                disp('>>')
                %[f,p,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconftabtchi(dat(:,2),2,dt);
                [f,p,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconfchi2(dat(:,2),2,dt);
                figure; semilogy(f,p,'k')
                set(gcf,'Units','normalized','position',[0.66,0.5,0.33,0.4])
                hold on; 
                semilogy(ft,theored,'k-','LineWidth',2);
                semilogy(ft,tabtchi90,'r-');
                semilogy(ft,tabtchi95,'r--','LineWidth',2);
                semilogy(ft,tabtchi99,'b-.');
                semilogy(ft,tabtchi999,'g.');
                xlabel('Frequency')
                ylabel('Power')
                xlim([0,fmax])
                legend('Power','Median','AR(1) 90%','AR(1) 95%','AR(1) 99%','AR(1) 99.9%')
                % save data
                if robot_savedata == 1
                    name11 = [name1,'-peirodogram-AR1.txt'];
                    data11 = [f,p,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999];
                    pre_dirML = pwd;
                    ac_pwd = fileread('ac_pwd.txt');
                    if isdir(ac_pwd)
                        cd(ac_pwd)
                    end
                    dlmwrite(name11, data11, 'delimiter', ' ', 'precision', 9);
                    disp(['>>  Saving data. See main window: ', name11,ext])
                    d = dir; %get files
                    set(listbox_acmain,'String',{d.name},'Value',1) %set string
                    pre  = '<HTML><FONT color="blue">';
                    post = '</FONT></HTML>';
                    d = dir; %get files
                    address = pwd;
                    set(edit_acfigmain_dir,'String',address);
                    listboxStr = cell(numel(d),1);
                    % Save pwd into a text file
                    ac_pwd_str = which('ac_pwd.txt');
                    [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
                    fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
                    fprintf(fileID,'%s',address);
                    fclose(fileID);
                    %
                    for i = 1:numel( d )
                        if isdir(d(i).name)
                            str = [pre d(i).name post];
                            listboxStr{i} = str;
                        else
                            listboxStr{i} = d(i).name;
                        end
                    end
                    set(listbox_acmain,'String',listboxStr,'Value',1) %set string
                    cd(pre_dirML); % return to matlab view folder
                end
            end
        end
        % pause
        pause(robot_pause);
        
%% evofft
        if check_evofft_v == 1
            
            disp('>>')
            disp('>>  ==========    Step 5: Evolutionary FFT   ==========')
            disp('>>')
            datraw = dat;
            dat = zeropad2(dat,winevofft);
            dt = median(diff(dat(:,1)));
            fn = 1/(2*dt);
            npts = length(dat(:,1));
            if npts < 300
                step = dt;
            else
                step = round(npts/300)*dt;
            end
            [s,x_grid,y_grid] = evofft(dat,winevofft,step,dt,0,fn,1);
            % plot

            figure
            set(gcf,'Units','normalized','position',[0.0,0.05,0.33,0.4])
            subplot(2,1,1)
            whitebg('white');
            plot(datraw(:,1),datraw(:,2));
            ylim([0.9* min(datraw(:,2)), 1.1*max(datraw(:,2))])
            xlim([min(datraw(:,1)),max(datraw(:,1))])
            ylabel('Value')
            if unit_type == 0;
                xlabel(['Unit (',unit,')'])
            elseif unit_type == 1;
                xlabel(['Depth (',unit,')'])
            else
                xlabel(['Time (',unit,')'])
            end
            set(gca,'XMinorTick','on','YMinorTick','on')
            subplot(2,1,2)
            whitebg('white');
            try pcolor(y_grid,x_grid,s')
                colormap(jet)
                shading interp
                title(['EvoFFT. Window',' = ',num2str(winevofft),' ',unit,'; step = ',num2str(step),' ', unit], 'Interpreter', 'none')
                ylabel(['Frequency ( cycles per ',unit,' )'])
                if unit_type == 0;
                    xlabel(['Unit (',unit,')'])
                elseif unit_type == 1;
                    xlabel(['Depth (',unit,')'])
                else
                    xlabel(['Time (',unit,')'])
                end
                set(gcf,'Name',[num2str(name1),': Running Periodogram'])
                %ylim([0 fn])
                ylim([0 fmax])
                xlim([min(datraw(:,1)),max(datraw(:,1))])
                set(gca,'XMinorTick','on','YMinorTick','on')
                set(gca, 'TickDir', 'out')
            catch
                errordlg('EvoFFT: Sampling rate or something else is incorrect.')
            end
        end
        % pause
        pause(robot_pause);
        
%% wavelet
        if check_wavelet_v == 1
            disp('>>')
            disp('>>  ==========    Step 6: Wavelet transform   ==========')
            disp('>>')
            figwave = figure;
            set(gcf,'Units','normalized','position',[0.33,0.05,0.33,0.4])
            try [~,~,~]= waveletML(daty,datx,1,0.1,wavep1,wavep2);
                set(gca,'XMinorTick','on','YMinorTick','on')
            catch
                try [~,~,~]= waveletML(daty,datx,1,0.1,wavep1,1/2*wavep2);
                    set(gca,'XMinorTick','on','YMinorTick','on')
                catch
                    errordlg('Error. Please try with other parameters')
                    disp('>>  ==========    Error in wavelet transform')
                end
            end
        end
        disp('')
        disp('>>  ==========    Done   ==========')
        disp('>>  ==================================================')
    end
end