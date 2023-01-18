% wavelet update panel C: global spectrum


% Designed for Acycle: wavelet analysis
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

%--- Plot global wavelet spectrum

if plot_linelog
    plot(global_ws,period,'k')
    hold on
    %plot(global_signif,period,'--')
    set(gca,'YLim',[pt1,pt2], ...
        'YTickLabel','')
else
    plot(global_ws,log2(period),'k')
    hold on
    %plot(global_signif,log2(period),'--')
    set(gca,'YLim',log2([pt1,pt2]), ...
        'YDir','reverse', ...
        'YTick',log2(Yticks(:)), ...
        'YTickLabel','')
end

hold off
% lang
lang_var = handles.lang_var;
[~, wave25] = ismember('wave25',handles.lang_id);

if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
    xlabel('Power (value^2)')
else
    xlabel(lang_var{wave25})
end
%title('C) Global Wavelet Spectrum')
set(gca,'XLim',[0,1.25*max(global_ws)])
if plot_flipy
    set(gca,'Ydir','reverse')
else
    set(gca,'Ydir','normal')
end
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');