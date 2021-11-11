% wavelet update panel B: wavelet spectrum
%
% Designed for Acycle: wavelet analysis
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

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
    Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
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
if plot_sl
    if plot_linelog
        if plot_2d == 1
            contour(datax,period,sig95,[-99,1],'k');
        elseif plot_2d == 0
            contour3(datax,period,sig95,[-99,1],'k');
        end
    else
        if plot_2d == 1
            contour(datax,log2(period),sig95,[-99,1],'k');
        elseif plot_2d == 0
            contour3(datax,log2(period),sig95,[-99,1],'k');

        end
    end
end
if plot_coi
    % cone-of-influence, anything "below" is dubious
    if plot_linelog  % linear y axis
        if plot_2d == 1
            plot(datax,coi,'k')
        elseif plot_2d == 0
            if plot_log2pow
                plot3(datax,coi,max(log2(power)),'k')
            else
                plot3(datax,coi,max(power),'k')
            end
        end
    else   % log y axis
        if plot_2d == 1
            plot(datax,log2(coi),'k')
        elseif plot_2d == 0
            if plot_log2pow
                plot3(datax,log2(coi),max(log2(power)),'k')
            else
                plot3(datax,log2(coi),max(power),'k')
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
else
    set(gca,'YLim',log2([pt1,pt2]), ...
    'YDir','reverse', ...
    'YTick',log2(Yticks(:)), ...
    'YTickLabel',Yticks)
end

set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');