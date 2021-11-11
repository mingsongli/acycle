
power = wcoh;
period = 1./period;  % convert freq to period
%period = seconds(period);
%coi = seconds(coi);
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
    Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
end
ax = gca;
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
%imagesc(time,log2(period),log2(power));  %*** uncomment for 'image' plot
if handles.unit_type == 0
    xlabel(['Unit (',handles.unit,')'])
elseif handles.unit_type == 1
    xlabel(['Depth (',handles.unit,')'])
else
    xlabel(['Time (',handles.unit,')'])
end
ylabel(['Period (',handles.unit,')'])
%title('B) Wavelet Power Spectrum')
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
                plot3(datax,1./coi,max(log2(power)),'k')
            else
                plot3(datax,1./coi,max(power),'k')
            end
        end
    else   % log y axis
        if plot_2d == 1
            plot(datax,log2(1./coi),'k')
        elseif plot_2d == 0
            if plot_log2pow
                plot3(datax,log2(1./coi),max(log2(power)),'k')
            else
                plot3(datax,log2(1./coi),max(power),'k')
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
    set(gca,'Ydir','reverse')
else
    set(gca,'Ydir','normal')
end
if plot_linelog
    %set(gca,'YLim',[fs1,fs2])
    set(gca,'YLim',[pt1,pt2])
else
    set(gca,'YLim',log2([pt1,pt2]), ...
    'YDir','reverse', ...
    'YTick',log2(Yticks(:)), ...
    'YTickLabel',Yticks)

    %set(gca,'YLim',log2([pt1,pt2]), ...
    %'YDir','reverse')
end

set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');

if plot_swap == 1
    view([90 -90])
    if plot_series == 0
        xlabel([])
    end
end


if plot_spectrum
    dt = mean(diff(datax));
    fs = 1/(2*dt);
    figure;
    %wcoherence(dat1y,dat2y,fs,'PhaseDisplayThreshold',dss);
    wcoherence(dat1y,dat2y,seconds(dt),'PhaseDisplayThreshold',dss);
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gca,'TickDir','out');

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

    if handles.unit_type == 0
        xlabel(['Unit (',handles.unit,') (start = 0)'])
    elseif handles.unit_type == 1
        xlabel(['Depth (',handles.unit,') (start = 0)'])
    else
        xlabel(['Time (',handles.unit,') (start = 0)'])
    end
    ylabel(['Period (',handles.unit,')'])
end
if plot_swap == 1
    view([90 -90])
end