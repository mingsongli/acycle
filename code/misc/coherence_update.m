
%% read target data
targetdir = char(get(handles.edit1,'String'));
targetname = char(get(handles.edit2,'String'));
target    = load(fullfile(targetdir,targetname));
target = datapreproc(target,0);
sr_target = median(diff(target(:,1)));  % sampling rate; using median of diff x

% start and end of the 1st column of the target
tar1 = min(target(:,1));
tar2 = max(target(:,1));
target1 = target;
%% read series datasets
list_content = cellstr(get(handles.listbox2,'String')); % read contents of listbox 2
nrow = length(list_content);
% time direction
timedir = get(handles.popupmenu2,'Value');
%% read parameters
methodstr = get(handles.popupmenu1, 'String');
methodval = get(handles.popupmenu1,'Value');
% threshold
cohthreshold = str2double(get(handles.edit7,'string'));
windowsize1 = str2double(get(handles.edit5,'string'));
windowsize = round(windowsize1/sr_target);  % window size
nooverlap1 = str2double(get(handles.edit6,'string'));
nooverlap = round(nooverlap1/sr_target); % number of overlap

if get(handles.radiobutton1,'value') == 1
    forp = 1; % plot freq
end
if get(handles.radiobutton2,'value') == 1
    forp = 2; % plot period
end

plotx1 = str2double(get(handles.edit8,'string'));
plotx2 = str2double(get(handles.edit9,'string'));
if get(handles.checkbox1,'value') == 1
    qplot1 = 1; % plot freq
else
    qplot1 = 0;
end
if get(handles.checkbox2,'value') == 1
    qplot2 = 1; % plot freq
else
    qplot2 = 0;
end
if get(handles.checkbox3,'value') == 1
    save1 = 1; % plot freq
else
    save1 = 0; % plot freq
end
%%
for i = 1:nrow
    data_name = char(list_content(i,1));
    [~,dat_name,~] = fileparts(data_name);
    data = load(fullfile(targetdir,data_name));
    % sort
    data = sortrows(data);
    % unique
    data=findduplicate(data);
    % remove empty
    data(any(isinf(data),2),:) = [];
    % start and end of the 1st column of the series
    ser1 = min(data(:,1));
    ser2 = max(data(:,1));
    
    series = data;
    %
    % interpolate series to reference
    series2int = interp1(series(:,1),series(:,2),target1(:,1));
    data  = [target1(:,1),series2int];
    
    % common interval
    sel1 = max(ser1, tar1); % lower bound
    sel2 = min(ser2, tar2); % upper bound
    if sel1 >= sel2
        error('Error: no overlap')
    else
        sel21 = sel2 - sel1;
        if sel21/2 < windowsize1
            warning('Window size is too large. Reset it... Done.')
            windowsize1 = sel21/2;
            windowsize = round(windowsize1/sr_target);
            nooverlap1 = round(windowsize1 * 0.5);
            nooverlap = round(nooverlap1/sr_target);
            set(handles.edit5,'string',num2str(windowsize1))
            set(handles.edit6,'string',num2str(nooverlap1))
        end
    end

    % Select the common interval for both target and series
    [series3] = select_interval(data,sel1,sel2);
    [target2] = select_interval(target1,sel1,sel2);
    
    % series selection and normalize
    y = series3(:,2);
    y = (y - mean(y))/std(y);
    % target selection and normalize
    x = target2(:,2);
    x = (x - mean(x))/std(x);
    
    if methodval == 1
        % mscohere estimates the magnitude-squared coherence function
        % using Welch’s overlapped averaged periodogram method 
        % https://www.mathworks.com/help/signal/ref/mscohere.html
        [Cxy,F1, MSC_critical,significant_freqs,significant_Cxy, phase_diff_deg,F2,phase_uncertainty_deg] ...
            = cohac(x,y,sr_target,'hamming',windowsize,nooverlap,cohthreshold,0);

        if save1 == 1
            %assignin('base','Cxy',Cxy)
            %assignin('base','F1',F1)
            %assignin('base','Pxy',Pxy)
            %assignin('base','F2',F2)
            pre_dirML = pwd;
            CDac_pwd; % cd working dir
            add_list = [dat_name,'-COH-',targetname];
            dlmwrite(add_list, [F1,Cxy], 'delimiter', ' ', 'precision', 9);
            add_list = [dat_name,'-COH-sig-',targetname];
            dlmwrite(add_list, [significant_freqs,significant_Cxy], 'delimiter', ' ', 'precision', 9);
            add_list2 = [dat_name,'-Phase-',targetname];
            dlmwrite(add_list2, [F2,phase_diff_deg,phase_uncertainty_deg], 'delimiter', ' ', 'precision', 9);
            d = dir; %get files
            set(handles.listbox1,'String',{d.name},'Value',1) %set string
            %
            % refresh AC main window
            figure(handles.acfigmain);
            refreshcolor;
            cd(pre_dirML); % return view dir
        end
        
        % coherence_update
        if qplot1 == 1
            % plot subplot
            try figure(handles.subfigure)
                %clf;
                %clf('reset')
            catch
                handles.subfigure = figure;
                set(gcf,'units','norm') % set location
                set(gcf,'position',[0.005,0.45,0.38,0.45]) % set position
            end
            set(gcf,'color','w');
            set(gcf,'Name','Acycle: coherence and phase | coherence');

            %% first plot
            subplot(3,1,1)
            if forp == 1
                plot(F1,Cxy,'k-o','LineWidth',2)
                xlabel('Frequency')
            else
                plot(1./F1(2:end),Cxy(2:end),'k-o','LineWidth',2)
                xlabel('Period')
            end
            xlim([plotx1, plotx2])
            ylim([0 1])
            hold on
            plot(xlim, [1 1]*MSC_critical, '-.b')
            title(['Magnitude-Squared Coherence. Critical Coherence = ',num2str(MSC_critical),' @ p-value = ',num2str(cohthreshold)])
            ylabel('Coherence')
            set(gca,'XMinorTick','on','YMinorTick','on')
            hold off

            %% second plot
            % for plot only
            Cxyp = Cxy(Cxy>MSC_critical);
            F2 = F2(Cxy>MSC_critical);
            phase_diff_deg = phase_diff_deg(Cxy>MSC_critical);
            phase_uncertainty_deg = phase_uncertainty_deg(Cxy>MSC_critical);

            subplot(3,1,2)
            if forp == 1
                h1 = errorbar(F2, phase_diff_deg, phase_uncertainty_deg);
                %plot(F2,phase_diff_deg,'r-o','LineWidth',2)
                xlabel('Frequency')
            else
                %plot(1./F2(2:end),phase_diff_deg(2:end),'r','LineWidth',2)
                try  
                    h1 = errorbar(1./F2, 1./phase_diff_deg, 1./phase_uncertainty_deg);  % if F2(1) ~= 0
                catch
                    h1 = errorbar(1./F2(2:end), 1./phase_diff_deg(2:end), 1./phase_uncertainty_deg(2:end));
                end
                xlabel('Period')
            end
            h1.LineWidth = 1.5;      % Set the line width
            h1.Color = 'k'; 
            h1.CapSize = 6; % Adjust cap size
            h1.LineStyle = 'none';   % Set the line style
            h1.Marker = 'o';                % Circle marker
            h1.MarkerSize = 8;              % Size of the marker

            xlim([plotx1, plotx2])
            ylim([-180 180])
            hold on
            plot(xlim, [1 1]*90, '--k')
            plot(xlim, [1 1]*45, ':k')
            plot(xlim, [1 1]*0, '-k')
            plot(xlim, [1 1]*-45, ':k')
            plot(xlim, [1 1]*-90, '--k')
            title('Cross Spectrum Phase and 1 standard deviation (in degree)')
            if timedir == 1
                ylabel(['Series lead (',char(176),')'])
            else
                ylabel(['Series lag (',char(176),')'])
            end
            set(gca,'XMinorTick','on','YMinorTick','on')
            hold off
            
            % third plot
            subplot(3,1,3)
            if F2(1) ~= 0
                F3 = F2;
            else
                F3 = F2(2:end);
            end
            h1 = errorbar(F3, phase_diff_deg./F3/360, phase_uncertainty_deg./F3/360);
            hold on
            plot(xlim, [1 1]*0, '-k')
            xlabel('Frequency')
            if timedir == 1
                ylabel('Series lead (unit)')
            else
                ylabel('Series lag (unit)')
            end
            title('Cross Spectrum Phase and 1 standard deviation (in unit)')
            set(gca,'XMinorTick','on','YMinorTick','on')
            h1.LineWidth = 1.5;      % Set the line width
            h1.Color = 'k'; 
            h1.CapSize = 6; % Adjust cap size
            h1.LineStyle = 'none';   % Set the line style
            h1.Marker = 'o';                % Circle marker
            h1.MarkerSize = 8;              % Size of the marker
            xlim([plotx1, plotx2])
            hold off
        else
            try close handles.subfigure
            catch
            end
        end
%% polarscatter

        if qplot2 == 1
            try figure(handles.polarfigure)
                %clf;
            catch
                handles.polarfigure = figure;
                set(gcf,'units','norm') % set location
                set(gcf,'position',[0.385,0.45,0.38,0.45]) % set position
            end
            set(gcf,'color','w');
            set(gcf,'Name','Acycle: coherence and phase | phase');
            if forp == 1
                polarscatter(deg2rad(phase_diff_deg),F2,Cxyp.^2*500,'filled','MarkerFaceAlpha',.5)
            else
                polarscatter(deg2rad(phase_diff_deg(2:end)),1./F2(2:end),2.^(Cxyp.^2*100),'filled','MarkerFaceAlpha',.5)
            end
            hold on
            rlim([plotx1, plotx2])
            if timedir == 1
                title(['Series leads (0-180',char(176),') or lags behind (180-360',char(176),') the reference'])
            else
                title(['Series lags behind (0-180',char(176),') or leads (180-360',char(176),') the reference'])
            end
            hold off
        else
            try close handles.polarfigure
            catch
            end
        end
    end
end
%% Plot
figure(handles.cohgui)