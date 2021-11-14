% wavelet update panel A: time series

% Designed for Acycle: wavelet analysis
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

%--- Plot time series

plot(datax,datay,'k');
set(gca,'XLim',xlim(:))

if plot_swap == 0
    ax1.XAxis.Visible = 'off'; % remove x-axis
end

if handles.unit_type == 0
    xlabel(['Unit (',handles.unit,')'])
elseif handles.unit_type == 1
    xlabel(['Depth (',handles.unit,')'])
else
    xlabel(['Time (',handles.unit,')'])
end
ylabel('Value')
%title('A) series')
if plot_flipx
    set(gca,'Xdir','reverse')
else
    set(gca,'Xdir','normal')
end
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');