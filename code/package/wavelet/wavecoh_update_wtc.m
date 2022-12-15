% size
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

%dt = mean(diff(datax));
%wcoherence(dat1y,dat2y,seconds(dt),'PhaseDisplayThreshold',dss);

% plot
pcolor(datax,log2(period),Rsq);
shading interp
set(gca,'clim',[0 1])
% plot settings
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

% % force to use the same axis
% xtick = xticklabels;
% for i = 1:length(xtick)
%     Xticks_raw(i,1) = str2double(xtick{i});
%     Xticks(i,1) = str2double(xtick{i}) + datax(1); 
% end
% set(gca,'XTick',Xticks_raw, ...
% 'XTickLabel',Xticks)

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
title('WTC')

% colormap and grid
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

% plot phase
if plot_phase
    hold on
    
    %phase plot
    aWxy=angle(Wxy);
    aaa=aWxy;
    aaa(Rsq<wtcthreshold) = NaN; %remove phase indication where Rsq is low
    %[xx,yy]=meshgrid(t(1:5:end),log2(period));

    phs_dt=round(length(t)/ArrowDensity(1)); 
    tidx=max(floor(phs_dt/2),1):phs_dt:length(t);
    
    phs_dp=round(length(period)/ArrowDensity(2)); 
    pidx=max(floor(phs_dp/2),1):phs_dp:length(period);
    
    phaseplot(t(tidx),log2(period(pidx)),aaa(pidx,tidx),ArrowSize,ArrowHeadSize);
    hold off
end

% plot coi
if plot_coi
    hold on
    tt=[t([1 1])-dt*.5;t;t([end end])+dt*.5];
    hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
    set(hcoi,'alphadatamapping','direct','facealpha',.4)
    hold off
end

if plot_sl
    hold on
    if ~all(isnan(wtcsig))
        [c,h] = contour(t,log2(period),wtcsig,[1 1],'k');
        set(h,'linewidth',1)
    end
    hold off
end
    %if plot_linelog
    %    if plot_2d == 1
    %        if plot_log2pow
    %            pcolor(datax,period,log2(power))
    
    
if plot_swap == 1
    view([-90 90])
end