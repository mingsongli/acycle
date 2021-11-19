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

function [xdata_filtered,time,freqboundlow,freqboundhigh]=dynamic_filter_lang(data,window,step,fmin,fmax,unit,norm,padding)
    lang_choice = load('ac_lang.txt');
    langdict = readtable('langdict.csv');
    lang_id = langdict.x_ID;
    if lang_choice == 0
        % English
        lang_var = langdict.en;
    elseif lang_choice == 1
        % Chinese
        lang_var = langdict.cn;
    end
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
    xdata=data(:,2);
    dt = mean(diff(time)); % sampling rate
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
    while con == 1   
        [x, y, con] = ginput(1);
        if con == 1
            x_min(i,1) = x;
            y_min(i,1) = y;
            i = i + 1;
            figure(evofftfig)
            hold on
            plot(x,y,'ok','markersize', 8)
            set(gcf,'Pointer','arrow');
        end
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
    while con == 1   
        [x, y, con] = ginput(1);
        if con == 1
            x_max(i,1) = x;
            y_max(i,1) = y;
            i = i + 1;
            figure(evofftfig)
            hold on
            plot(x,y,'ok','markersize', 8)
            set(gcf,'Pointer','arrow');
        end
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
    
    inc=step/dt;
    inc=floor(inc);
    mpts=window/dt;
    mpts=floor(mpts);
    igrid=floor(0.5*mpts);
    y_min=[y_grid(1);y_min;y_grid(end)];
    y_max=[y_grid(1);y_max;y_grid(end)];
    x_min=[x_min(1);x_min;x_min(end)];
    x_max=[x_max(1);x_max;x_max(end)];
    f_min = interp1(y_min,x_min,y_grid,'linear');
    f_max = interp1(y_max,x_max,y_grid,'linear');
    figure(evofftfig)
    hold on
    plot(f_min,y_grid,'o-g')
    plot(f_max,y_grid,'o-g')
    
    output=zeros(length(y_grid),length(time));
    fc=zeros(length(y_grid),1);
    for n=1:length(y_grid)
        m1=max(((n*inc)-igrid),1);
        m2=min(((n*inc)+igrid),length(xdata));
        tmp_data=xdata(m1:m2);
        fc(n)=(f_min(n)+f_max(n))/2;
        %gaussbandx=gaussfilter18(tmp_data,dt,(f_min(n)+f_max(n))/2,min(f_min(n),f_max(n)),max(f_min(n),f_max(n)));
        [gaussbandx,~,~]=gaussfilter(tmp_data,dt,(f_min(n)+f_max(n))/2,min(f_min(n),f_max(n)),max(f_min(n),f_max(n)));
        output(n,m1:m2)=gaussbandx;
    end
    plot(fc,y_grid,'-r')
    hold off
    
    count=sum(output~=0,1);
    xdata_filtered=sum(output,1)./count;
    % close msgbox
    try close(msgbox1)
    catch
    end
end
