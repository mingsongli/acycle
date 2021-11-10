% wavelet update panel C: global spectrum

%--- Plot global wavelet spectrum
hold on
if plot_linelog
    plot(global_ws,period)
    plot(global_signif,period,'--')
    set(gca,'YLim',[pt1,pt2], ...
        'YTickLabel','')
else
    plot(global_ws,log2(period))
    plot(global_signif,log2(period),'--')
    set(gca,'YLim',log2([pt1,pt2]), ...
        'YDir','reverse', ...
        'YTick',log2(Yticks(:)), ...
        'YTickLabel','')
end

hold off
xlabel('Power (value^2)')
%title('C) Global Wavelet Spectrum')
set(gca,'XLim',[0,1.25*max(global_ws)])
if plot_flipy
    set(gca,'Ydir','reverse')
else
    set(gca,'Ydir','normal')
end
