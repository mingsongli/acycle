% wavelet update plots


if and(plot_spectrum == 1,plot_series ==1)
    try figure(handles.figwave)
        
    catch
        handles.figwave = figure;
        set(gcf,'Name','Acycle: wavelet plot')
        set(gcf,'units','norm') % set location
        set(gcf, 'color','white')
    end
    
    % update panel A: time series
    if plot_swap == 0
        subplot('position',[0.1 0.65 0.65 0.3])
        wave_update_series
    else
        subplot('position',[0.1 0.1 0.3 0.65])
        wave_update_series
        view([90 -90])
    end

    %--- Contour plot wavelet power spectrum
    if plot_swap == 0
        subplot('position',[0.1 0.1 0.65 0.45])
        wave_update_wavelet
    else
        subplot('position',[0.5 0.1 0.45 0.65])
        wave_update_wavelet
        view([90 -90])
    end

    %--- Plot global wavelet spectrum
    if plot_swap == 0
        subplot('position',[0.77 0.1 0.2 0.45])
        wave_update_global
    else
        subplot('position',[0.5 0.77 0.45 0.2])
        wave_update_global
        view([90 -90])
    end
    
    

elseif and(plot_spectrum == 0,plot_series ==1)
    try figure(handles.figwave)
        
    catch
        
        handles.figwave = figure;
        set(gcf,'Name','Acycle: wavelet plot')
        set(gcf,'units','norm') % set location
        set(gcf, 'color','white')

    end
    
    % update panel A: time series
    if plot_swap == 0
        subplot('position',[0.1 0.65 0.8 0.3])
        wave_update_series
    else
        subplot('position',[0.1 0.1 0.3 0.8])
        wave_update_series
        view([90 -90])
    end

    %--- Contour plot wavelet power spectrum
    if plot_swap == 0
        subplot('position',[0.1 0.1 0.8 0.45])
        wave_update_wavelet
    else
        subplot('position',[0.45 0.1 0.45 0.8])
        wave_update_wavelet
        view([90 -90])
    end

elseif and(plot_spectrum == 1,plot_series == 0)
    try figure(handles.figwave)
        
    catch
        handles.figwave = figure;
        set(gcf,'Name','Acycle: wavelet plot')
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
        view([90 -90])
    end

    %--- Plot global wavelet spectrum
    if plot_swap == 0
        subplot('position',[0.77 0.1 0.2 0.8])
        wave_update_global
    else
        subplot('position',[0.1 0.77 0.8 0.2])
        wave_update_global
        view([90 -90])
    end

elseif and(plot_spectrum == 0,plot_series == 0)
    try figure(handles.figwave)
        
    catch
        handles.figwave = figure;
        set(gcf,'Name','Acycle: wavelet plot')
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
        view([90 -90])
    end
end