
% Cross wavelet transform plot

% Please acknowledge the use of this software in any publications:
%   "Crosswavelet and wavelet coherence software were provided by
%   A. Grinsted."
%
% (C) Aslak Grinsted 2002-2014
%
% http://www.glaciology.net/wavelet-coherence

% -------------------------------------------------------------------------
%The MIT License (MIT)
%
%Copyright (c) 2014 Aslak Grinsted
%
%Permission is hereby granted, free of charge, to any person obtaining a copy
%of this software and associated documentation files (the "Software"), to deal
%in the Software without restriction, including without limitation the rights
%to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%copies of the Software, and to permit persons to whom the Software is
%furnished to do so, subject to the following conditions:
%
%The above copyright notice and this permission notice shall be included in
%all copies or substantial portions of the Software.
%
%THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%THE SOFTWARE.
%---------------------------------------------------------------------------

% Revised by Mingsong Li for Acycle v2.4.1
try figure(handles.figxwt)
catch
    handles.figxwt = figure;
    set(gcf,'Name','Acycle: cross wavelet transform plot')
    set(gcf,'units','norm') % set location
    set(gcf, 'color','white')
    set(gcf,'position',[0.1,0.1,0.4,0.3]* handles.MonZoom)
end
    
subplot('position',[0.1 0.1 0.852 0.8]);
H = pcolor(t,log2(period),log2(abs(Wxy/(sigmax*sigmay))));

clim=get(gca,'clim'); %center color limits around log2(1)=0
clim=[-1 1]*max(clim(2),3);
set(gca,'clim',clim)

HCB=colorbar;
set(HCB,'ytick',-7:7);
barylbls=rats(2.^(get(HCB,'ytick')'));
barylbls([1 end],:)=' ';
barylbls(:,all(barylbls==' ',1))=[];
set(HCB,'yticklabel',barylbls);
set(HCB,'visible','off')

shading interp
if plot_phase
    hold on
    aWxy=angle(Wxy);

    phs_dt=round(length(t)/ArrowDensity(1)); 
    tidx=max(floor(phs_dt/2),1):phs_dt:length(t);

    phs_dp=round(length(period)/ArrowDensity(2)); 
    pidx=max(floor(phs_dp/2),1):phs_dp:length(period);

    phaseplot(t(tidx),log2(period(pidx)),aWxy(pidx,tidx),ArrowSize,ArrowHeadSize);
    hold off
end

if plot_coi
    hold on
    tt=[t([1 1])-dt*.5;t;t([end end])+dt*.5];
    hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
    set(hcoi,'alphadatamapping','direct','facealpha',.5)
    hold off
end

if plot_sl
    hold on
    [c,h] = contour(t,log2(period),sig95,[1 1],'k');
    set(h,'linewidth',2)
    hold off
end

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
title('XWT')
if plot_linelog
    set(gca,'YLim',[pt1,pt2],...
    'YTick',Yticks(:), ...
    'YTickLabel',Yticks)
else
    set(gca,'YLim',log2([pt1,pt2]), ...
    'YTick',log2(Yticks(:)), ...
    'YTickLabel',Yticks)
end

if plot_flipx
    set(gca,'Xdir','reverse')
else
    set(gca,'Xdir','normal')
end
if plot_flipy
    %figure(handles.figwave)
    set(gca,'Ydir','normal')
else
    %figure(handles.figwave)
    set(gca,'Ydir','reverse')
end
set(gca,'XMinorTick','on')
set(gca,'TickDir','out');
if plot_swap == 1
    view([-90 90])
end
