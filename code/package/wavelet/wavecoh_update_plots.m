% wavelet update plots


% Designed for Acycle: wavelet analysis coherence
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021
if plot_series ==1
    try figure(handles.figwave)
        
    catch
        
        handles.figwave = figure;
        set(gcf,'Name','Acycle: Wavelet coherence and cross-spectrum plot')
        set(gcf,'units','norm') % set location
        set(gcf, 'color','white')

    end
    
    % update panel A: time series  
    %--- Plot time series
    for ploti = 1:2
        if ploti == 1
            if plot_swap == 0
                %--- Plot time series 1
                ax1 = subplot('position',[0.1 0.75 0.8 0.2]);
                plot(datax,dat1y,'k')
                ax1.XAxis.Visible = 'off'; % remove x-axis
            else
                ax1 = subplot('position',[0.05 0.1 0.15 0.8]);
                plot(datax,dat1y,'k')
                view([90 -90])
                %ax1.XAxis.Visible = 'off'; % remove x-axis
                
                if handles.unit_type == 0
                    xlabel(['Unit (',handles.unit,')'])
                elseif handles.unit_type == 1
                    xlabel(['Depth (',handles.unit,')'])
                else
                    xlabel(['Time (',handles.unit,')'])
                end
            end
            ylabel('Value of series #1')
        elseif ploti == 2
            if plot_swap == 0
                %--- Plot time series 2
                ax2 = subplot('position',[0.1 0.5 0.8 0.2]);
                plot(datax,dat2y,'k')
                ax2.XAxis.Visible = 'off'; % remove x-axis
                
                if handles.unit_type == 0
                    xlabel(['Unit (',handles.unit,')'])
                elseif handles.unit_type == 1
                    xlabel(['Depth (',handles.unit,')'])
                else
                    xlabel(['Time (',handles.unit,')'])
                end
            else
                ax2 = subplot('position',[0.25 0.1 0.15 0.8]);
                ax2.XAxis.Visible = 'off'; % remove x-axis
                plot(datax,dat2y,'k')
                view([90 -90])
            end
            ylabel('Value of series #2')
            
        end
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'TickDir','out');
        set(gca,'XLim',xlim(:))
        if plot_flipx
            set(gca,'Xdir','reverse')
        else
            set(gca,'Xdir','normal')
        end
    end
    
    %--- Contour plot wavelet power spectrum
    if plot_swap == 0
        subplot('position',[0.1 0.08 0.8 0.4])
    else
        subplot('position',[0.45 0.1 0.5 0.8])
    end
    wavecoh_update_wavecoh

%%
elseif plot_series == 0
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
    else
        subplot('position',[0.1 0.1 0.8 0.8])
    end
        wavecoh_update_wavecoh
end