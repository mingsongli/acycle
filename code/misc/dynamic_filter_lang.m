% 2019: Dynamic filtering of a frequency in the depth domain with user-defined 
% lower boundary, average frequency, and upper boundary.
% written by Nicolas Thibault and Giovanni Rizzi
%
% Calls for
%   zeropad2.m
%   evofftML.m
%   
% Modified by Mingsong Li, June 2020 for Acycle's "Frequency Stabilization"
%

function [xdata_filtered,time,freqboundlow,freqboundhigh,cancelled]=dynamic_filter_lang(data,window,step,fmin,fmax,unit,norm,padding)
    xdata_filtered = [];
    freqboundlow = [];
    freqboundhigh = [];
    cancelled = false;
    lang_choice = ac_user_settings('getLanguage');
    langdict = readtable('langdict.xlsx','VariableNamingRule','preserve');
    lang_id = langdict.ID;
    lang_var = table2cell(langdict(:,2+lang_choice));
    if lang_choice > 0
        % menu
        [~, locb] = ismember('dd53',lang_id);
        dd53 = lang_var{locb};
        [~, locb] = ismember('dd54',lang_id);
        dd54 = lang_var{locb};
        [~, locb] = ismember('dd55',lang_id);
        dd55 = lang_var{locb};
        [~, locb] = ismember('dd56',lang_id);
        dd56 = lang_var{locb};
        [~, locb] = ismember('dd57',lang_id);
        dd57 = lang_var{locb};
        [~, locb] = ismember('menu114',lang_id);
        menu114 = lang_var{locb};
        [~, locb] = ismember('dd30',lang_id);
        dd30 = lang_var{locb};
        [~, locb] = ismember('main23',lang_id);
        main23 = lang_var{locb};
    end
    
    time=data(:,1);
    %s=evofft18(data,window,step,dt,fmin,fmax,unit,norm,padding);
    % Bug detected. Use Acycle's version evofft with zeropad2.m function
    % ML
    % zero-padding
    [dataX] = zeropad2(data,window,padding);
    % evoFFT
    [s,x_grid,y_grid]=evofftML(dataX,window,step,fmin,fmax,norm);
    % 2-D plot (color contour)
    
    evofftfig = figure;
    set(evofftfig,'units','norm') % set location
    set(evofftfig,'position',[0.05,0.4,0.9,0.55]) % set position
    if lang_choice == 0
        set(evofftfig,'Name','Acycle: Dynamic Filtering | Frequency Stabilization') % set position
    else
        set(evofftfig,'Name',dd30) % set position
    end
    
    pcolor(x_grid,y_grid,s)
    % adjust color and add basic annotations
    colormap(jet)
    set(gca,'TickDir','out')
    shading interp 
    if lang_choice == 0
        str=sprintf('Window = %d %s',window,unit);
        title(str);
        xlabel(['Frequency (cycles/',unit,')']) 
        ylabel(['Depth (',unit,')'])
    else
        str=sprintf(dd53,window,unit);
        title(str);
        xlabel([dd54,unit,')']) 
        ylabel([main23,' (',unit,')'])
    end
    %colorbar
    % EOF
    view([90 -90]); %used to swap the view at 90 degrees. 
    %
    figure(evofftfig)
    % get user-defined frequency boundaries
    % lower boundary
    if lang_choice == 0
        msg1 = '\fontsize{16}\color{blue}Select \color{red}lower \color{blue}frequency boundary; right click to stop';
    else
        msg1 = dd55;
    end
    title(msg1);
    con = 1;
    i = 1;
    x_min = [];
    y_min = [];
    while con == 1   
        [x, y, con] = ginput(1);
        if con == 1
            x_min(i,1) = x; %#ok<AGROW>
            y_min(i,1) = y; %#ok<AGROW>
            i = i + 1;
            figure(evofftfig)
            hold on
            plot(x,y,'ok','markersize', 8)
            set(gcf,'Pointer','arrow');
        end
    end
    if isempty(y_min)
        cancelled = true;
        if isgraphics(evofftfig)
            close(evofftfig);
        end
        return
    end
    [y_min,I] = sort(y_min);
    x_min=x_min(I);
    figure(evofftfig)
    hold on
    plot(x_min,y_min,'-k')
    freqboundlow = [y_min,x_min];
    
    % upper boundary
    if lang_choice == 0
        msg2 = '\fontsize{16}\color{blue}Select \color{red}higher \color{blue}frequency boundary; right click to stop';
    else
        msg2 = dd56;
    end
    
    title(msg2);
    con = 1;
    i = 1;
    x_max = [];
    y_max = [];
    while con == 1   
        [x, y, con] = ginput(1);
        if con == 1
            x_max(i,1) = x; %#ok<AGROW>
            y_max(i,1) = y; %#ok<AGROW>
            i = i + 1;
            figure(evofftfig)
            hold on
            plot(x,y,'ok','markersize', 8)
            set(gcf,'Pointer','arrow');
        end
    end
    if isempty(y_max)
        cancelled = true;
        if isgraphics(evofftfig)
            close(evofftfig);
        end
        return
    end
    [y_max,I] = sort(y_max);
    x_max=x_max(I);
    figure(evofftfig)
    hold on
    plot(x_max,y_max,'-k')
    freqboundhigh = [y_max,x_max];
    if lang_choice == 0
        msgbox1 = msgbox({'Dynamic Filtering';'Please wait ...'});
    else
        msgbox1 = msgbox({menu114;dd57});
    end
    figure(evofftfig)
    title(str);
    
    % Keep the interactive spectrum solely as a GUI for acquiring explicit
    % control points. Numerical filtering is delegated to the strict,
    % side-effect-free core. This removes the legacy dense
    % windows-by-samples matrix, off-by-one window placement, and the use of
    % nonzero filtered values as a proxy for sample coverage.
    coreOptions = struct( ...
        'window_length',window, ...
        'step_length',step);
    [coreResult,coreWindows] = acycleDynamicFilter( ...
        data,freqboundlow,freqboundhigh,coreOptions);
    time = coreResult(:,1);
    xdata_filtered = coreResult(:,2).';
    figure(evofftfig)
    hold on
    plot(coreWindows(:,2),coreWindows(:,1),'o-g')
    plot(coreWindows(:,3),coreWindows(:,1),'o-g')
    plot(coreWindows(:,4),coreWindows(:,1),'-r')
    hold off
    % close msgbox
    try close(msgbox1)
    catch
    end
end
