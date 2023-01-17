% wavelet update plots


% Designed for Acycle: wavelet analysis
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

% lang
lang_var = handles.lang_var;
[~, menu109] = ismember('menu109',handles.lang_id);

if and(plot_spectrum == 1,plot_series ==1)
    try figure(handles.figwave)
    catch
        handles.figwave = figure;
        set(gcf,'Name',['Acycle: ',lang_var{menu109}])
        set(gcf,'units','norm') % set location
        set(gcf, 'color','white')
    end
    
    % update panel A: time series
    if plot_swap == 0
        ax1 = subplot('position',[0.1 0.65 0.65 0.3]);
        wave_update_series
    else
        ax1 = subplot('position',[0.1 0.1 0.28 0.65]);
        wave_update_series
        view([-90 90])
    end

    %--- Contour plot wavelet power spectrum
    if plot_swap == 0
        ax2 = subplot('position',[0.1 0.1 0.65 0.5]);
        wave_update_wavelet
    else
        ax2 = subplot('position',[0.45 0.1 0.45 0.65]);
        wave_update_wavelet
        xlabel([])
        view([-90 90])
    end

    %--- Plot global wavelet spectrum
    if plot_swap == 0
        subplot('position',[0.77 0.1 0.2 0.5])
        wave_update_global
    else
        subplot('position',[0.45 0.77 0.45 0.2])
        wave_update_global
        view([-90 90])
    end
    
    

elseif and(plot_spectrum == 0,plot_series ==1)
    try figure(handles.figwave)
    catch
        
        handles.figwave = figure;
        set(gcf,'Name',['Acycle: ',lang_var{menu109}])
        set(gcf,'units','norm') % set location
        set(gcf, 'color','white')

    end
    
    % update panel A: time series
    if plot_swap == 0
        ax1 = subplot('position',[0.1 0.65 0.8 0.3]);
        wave_update_series
    else
        ax1 = subplot('position',[0.1 0.1 0.28 0.8]);
        wave_update_series
        view([-90 90])
    end

    %--- Contour plot wavelet power spectrum
    if plot_swap == 0
        subplot('position',[0.1 0.1 0.8 0.5])
        wave_update_wavelet
    else
        subplot('position',[0.45 0.1 0.5 0.8])
        wave_update_wavelet
        xlabel([])
        view([-90 90])
    end

elseif and(plot_spectrum == 1,plot_series == 0)
    try figure(handles.figwave)
    catch
        handles.figwave = figure;
        set(gcf,'Name',['Acycle: ',lang_var{menu109}])
        set(gcf,'units','norm') % set location
        set(gcf, 'color','white')
    end
    %--- Contour plot wavelet power spectrum
    if plot_swap == 0
        subplot('position',[0.1 0.1 0.65 0.8])
        wave_update_wavelet
    else
        subplot('position',[0.1 0.1 0.8 0.65])
        wave_update_wavelet
        view([-90 90])
    end

    %--- Plot global wavelet spectrum
    if plot_swap == 0
        subplot('position',[0.77 0.1 0.2 0.8])
        wave_update_global
    else
        subplot('position',[0.1 0.77 0.8 0.2])
        wave_update_global
        view([-90 90])
    end

elseif and(plot_spectrum == 0,plot_series == 0)
    try figure(handles.figwave)
    catch
        handles.figwave = figure;
        set(gcf,'Name',['Acycle: ',lang_var{menu109}])
        set(gcf,'units','norm') % set location
        set(gcf, 'color','white')
    end
    %--- Contour plot wavelet power spectrum
    if plot_swap == 0
        subplot('position',[0.1 0.1 0.8 0.8])
        wave_update_wavelet
    else
        subplot('position',[0.1 0.1 0.8 0.8])
        wave_update_wavelet
        view([-90 90])
    end
end

figure(handles.waveletGUIfig)