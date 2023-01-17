% wavelet update panel A: time series

% Designed for Acycle: wavelet analysis
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

%--- Plot time series
% lang
lang_var = handles.lang_var;
[~, wave25] = ismember('wave25',handles.lang_id);

plot(datax,datay,'k');
set(gca,'XLim',xlim(:))

if plot_swap == 0
    ax1.XAxis.Visible = 'off'; % remove x-axis
end

if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
    if handles.unit_type == 0
        xlabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1
        xlabel(['Depth (',handles.unit,')'])
    else
        xlabel(['Time (',handles.unit,')'])
    end
    ylabel('Value')
else
    [~, main34] = ismember('main34',handles.lang_id); % Unit
    [~, main23] = ismember('main23',handles.lang_id); % Depth
    [~, main21] = ismember('main21',handles.lang_id); % Time
    [~, main24] = ismember('main24',handles.lang_id); % Value

    if handles.unit_type == 0
        xlabel([lang_var{main34},' (',handles.unit,')'])
    elseif handles.unit_type == 1
        xlabel([lang_var{main23},' (',handles.unit,')'])
    else
        xlabel([lang_var{main21},' (',handles.unit,')'])
    end
    ylabel(lang_var{main24})
end

%title('A) series')
if plot_flipx
    set(gca,'Xdir','reverse')
else
    set(gca,'Xdir','normal')
end
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');