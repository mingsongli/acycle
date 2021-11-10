% wavelet update panel A: time series


%--- Plot time series

plot(datax,datay,'k')
set(gca,'XLim',xlim(:))
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
