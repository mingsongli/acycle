if plot_phase
    
    figure(handles.figwave)
    if plot_series == 1
        if plot_swap == 0
            subplot('position',[0.1 0.1 0.8 0.45])
        else
            subplot('position',[0.45 0.1 0.5 0.8])
        end
    elseif plot_series == 0
        if plot_swap == 0
            subplot('position',[0.1 0.1 0.8 0.8])
        else
            subplot('position',[0.1 0.1 0.8 0.8])
        end
    end
    
    dt = mean(diff(datax));
    wcoherence(dat1y,dat2y,seconds(dt),'PhaseDisplayThreshold',wtcthreshold);
    colorbar('off')
    set(gca,'XMinorTick','on')
    set(gca,'TickDir','out');
    set(gcf, 'color','white')
    if plot_flipx
        set(gca,'Xdir','reverse')
    else
        set(gca,'Xdir','normal')
    end
    if plot_flipy
        set(gca,'Ydir','normal')
    else
        set(gca,'Ydir','reverse')
    end
    set(gca,'YLim',log2([pt1,pt2]))
    
    % force to use the same axis
    xtick = xticklabels;
    for i = 1:length(xtick)
        Xticks_raw(i,1) = str2double(xtick{i});
        Xticks(i,1) = str2double(xtick{i}) + datax(1); 
    end
    set(gca,'XTick',Xticks_raw, ...
    'XTickLabel',Xticks)

    set(gca,'YLim',log2([pt1,pt2]), ...
        'YTick',log2(Yticks(:)),'YTickLabel',Yticks)
    
    if plot_swap == 0
        if handles.unit_type == 0
           xlabel(['Unit (',handles.unit,')'])
        elseif handles.unit_type == 1
           xlabel(['Depth (',handles.unit,')'])
        else
           xlabel(['Time (',handles.unit,')'])
        end
    else
        xlabel([])
    end
    
    ylabel(['Period (',handles.unit,')'])
    title('phase')
    
    if isempty(plot_colorgrid)
        try
            colormap(plot_colormap)
        catch
            colormap(parula)
        end
    else
        try
            colormap([plot_colormap,'(',num2str(plot_colorgrid),')'])
        catch
            try colormap(['parula(',num2str(plot_colorgrid),')'])
            catch
                colormap(parula)
            end
        end
    end
    
else
    
    power = wcoh;
    period = 1./period;  % convert freq to period
    if plot_linelog
        if plot_2d == 1
            if plot_log2pow
                pcolor(datax,period,log2(power))
            else
                pcolor(datax,period,power)
            end
        elseif plot_2d == 0
            if plot_log2pow
                surf(datax,period,log2(power))
            else
                surf(datax,period,power)
            end
        end
        set(gca,'YLim',[pt1,pt2])
    else
        if plot_2d == 1
            if plot_log2pow
                pcolor(datax,log2(period),log2(power))
            else
                pcolor(datax,log2(period),power)
            end
        elseif plot_2d == 0
            if plot_log2pow
                surf(datax,log2(period),log2(power))
            else
                surf(datax,log2(period),power)
            end
        end
    end
    shading interp
    if isempty(plot_colorgrid)
        try
            colormap(plot_colormap)
        catch
            colormap(parula)
        end
    else
        try
            colormap([plot_colormap,'(',num2str(plot_colorgrid),')'])
        catch
            try colormap(['parula(',num2str(plot_colorgrid),')'])
            catch
                colormap(parula)
            end
        end
    end
    if handles.unit_type == 0
        xlabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1
        xlabel(['Depth (',handles.unit,')'])
    else
        xlabel(['Time (',handles.unit,')'])
    end
    ylabel(['Period (',handles.unit,')'])
    set(gca,'XLim',xlim(:))

    % 95% significance contour, levels at -99 (fake) and 1 (95% signif)
    hold on
    if plot_coi
        % cone-of-influence, anything "below" is dubious
        if plot_linelog  % linear y axis
            if plot_2d == 1
                plot(datax,1./coi,'k')
            elseif plot_2d == 0
                if plot_log2pow
                    plot3(datax,1./coi,max(log2(power)),'w--','LineWidth',2)
                else
                    plot3(datax,1./coi,max(power),'w--','LineWidth',2)
                end
            end
        else   % log y axis
            if plot_2d == 1
                %tt=[datax([1 1])-dt*.5;datax;datax([end end])+dt*.5];
                %hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
                %set(hcoi,'alphadatamapping','direct','facealpha',.4)
                plot(datax,log2(1./coi),'w--','LineWidth',2)
            elseif plot_2d == 0
                if plot_log2pow
                    plot3(datax,log2(1./coi),max(log2(power)),'w--','LineWidth',2)
                else
                    plot3(datax,log2(1./coi),max(power),'w--','LineWidth',2)
                end
            end
        end
    end

    hold off
    if plot_flipx
        set(gca,'Xdir','reverse')
    else
        set(gca,'Xdir','normal')
    end
    if plot_flipy
        figure(handles.figwave)
    else
        figure(handles.figwave)
        set(gca,'Ydir','reverse')
    end
    if plot_linelog
        set(gca,'YLim',[pt1,pt2])
    else
        set(gca,'YLim',log2([pt1,pt2]), ...
        'YTick',log2(Yticks(:)), ...
        'YTickLabel',Yticks)
    end
    %if plot_series == 1
    %    set(gca,'XTickLabel',[])
    %end
    set(gca,'XMinorTick','on')
    set(gca,'TickDir','out');

    if plot_swap == 1
        if plot_series == 1
            xlabel([])
        end
    end

end
if plot_swap == 1
    view([-90 90])
end