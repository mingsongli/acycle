% update recurrence plot
data_s = handles.current_data ;
[N, ncol] = size(data_s);
S = handles.S;

if ncol == 1
    x = data_s;
    t = 1:N;
else
    x = data_s(:,2);
    t = data_s(:,1);
end

%% Get input parameters

showseries = get(handles.checkbox1,'Value');
showdet = get(handles.checkbox2,'Value');
fliptime = get(handles.checkbox3,'Value');
flipseries = get(handles.checkbox4,'Value');

ylabeli = get(handles.edit7,'String');
if showdet == 1
    set(handles.edit3,'Enable','on')
    set(handles.edit4,'Enable','on')
    set(handles.edit5,'Enable','on')
    set(handles.edit6,'Enable','on')
else
    
    set(handles.edit3,'Enable','off')
    set(handles.edit4,'Enable','off')
    set(handles.edit5,'Enable','off')
    set(handles.edit6,'Enable','off')
end
threshold = str2double( get(handles.edit2,'String') );
if ~isnan(threshold)
    if threshold > max(S(:))
        threshold = max(S(:));
        set(handles.edit2,'String',num2str(threshold))
        warning(['Threshold is too big. Must be smaller than ', num2str(max(S(:)))])
    elseif threshold < min(S(:))
        threshold = min(S(:));
        set(handles.edit2,'String',num2str(threshold))
        warning(['Threshold is too small. Must be larger than ', num2str(min(S(:)))])
    end
    else
    errordlg('Threshold should be a number')
end

if showdet == 1
    if ncol==1
        winN = N;
        wsN = 1;
    else
        % use the first two columns
        winN = max(data_s(:,1)) - min(data_s(:,1));
        wsN = median(diff(data_s(:,1)));
    end
    % read window size
    w = str2double( get(handles.edit3,'String') );
    if ~isnan(w)
        if w > winN
            w = winN;
            set(handles.edit3,'String',num2str(w))
            warning(['Window size is too big. Must be smaller than ', num2str(winN)])
        elseif w<=0
           w = winN;
           set(handles.edit3,'String',num2str(w))
           warning(['Window size is too small. Must be bigger than ', num2str(0)])
        end
        if ncol > 1
            w = round(N * w/winN);  % force integer
        end
    else
        errordlg(' Window size should be a number ')
        return
    end
    % read sliding step
    ws = str2double( get(handles.edit4,'String') );
    if ~isnan(ws)
        if ws > w
            ws = w;
            set(handles.edit4,'String',num2str(ws))
            warning(['Sliding step is too big. Must be smaller than ', num2str(ws)])
        elseif ws < wsN
            ws = wsN;
            set(handles.edit4,'String',num2str(ws))
            warning(['Sliding step is too small. Must be larger than ', num2str(ws)])
        end
        if ncol > 1
            ws = ceil(N * ws/winN);  % force integer
        end
    else
        errordlg(' Sliding step should be a number ')
        return
    end
    % read theiler window
    theiler_window = str2double( get(handles.edit5,'String'));
    if isnan(theiler_window)
        errordlg('Theiler window should be a number')
        return
    end
    % read lmin
    lmin = str2double( get(handles.edit6,'String'));
    if isnan(lmin)
        error('Minimal length of diagonal line structure should be a number')
        return
    end
    %
    % DET
    if N > 300
        hwarn = warndlg('Warning: long time series. Please wait. Up to several minutes','DET calculation');
    end
    [DETy,testi] = crp_pdist(x,w,ws,theiler_window, lmin, 0);
    DETx = t(testi) + 1/2 * winN * w/N;
end

%% Plot
try figure(handles.hrp)
catch
    handles.hrp = figure;
end
clf(handles.hrp,'reset')
set (gcf,'Color','w')
set (gcf,'Name','Recurrence Plot')
axis square; 

if showseries == 1
    if showdet== 1
    % recurrence plot + series  + DET
        subplot('position',[0.15 0.86 0.7 0.11]);
        plot(t,x,'k','LineWidth',1)
        set(gca,'XMinorTick','on','YMinorTick','on')
        xlim([min(t), max(t)])
        ylabel(ylabeli)
        set(gca,'xticklabel',{[]})
        if fliptime == 1
            set (gca, 'xdir', 'reverse' )
        else
            set (gca, 'xdir', 'normal' )
        end
        if flipseries ==1
            set (gca, 'ydir', 'reverse' )
        else
            set (gca, 'ydir', 'normal' )
        end
        subplot('position',[0.15 0.75 0.7 0.11]);
        plot(DETx,DETy,'k','LineWidth',2)
        xlim([min(t), max(t)])
        ylabel('DET')
        set(gca,'xticklabel',{[]})
        set(gca,'XMinorTick','on','YMinorTick','on')
        if fliptime == 1
            set (gca, 'xdir', 'reverse' )
        else
            set (gca, 'xdir', 'normal' )
        end

        subplot('position',[0.15 0.05 0.7 0.7]);
        imagesc(t, t, S < threshold);
        axis square; 
        set(gca,'XMinorTick','on','YMinorTick','on')
        colormap([1 1 1;0 0 0]); 

        if handles.unit_type == 0
            xlabel('')
            ylabel('')
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
            ylabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
            ylabel(['Time (',handles.unit,')'])
        end

        if fliptime == 1
            set (gca, 'xdir', 'reverse' )
            set (gca, 'ydir', 'reverse' )
        else
            set (gca, 'xdir', 'normal' )
            set (gca, 'ydir', 'normal' )
        end

    else
        % recurrence plot + series
        
        subplot('position',[0.15 0.75 0.7 0.2]);
        plot(t,x,'k','LineWidth',1)
        xlim([min(t), max(t)])
        set(gca,'XMinorTick','on','YMinorTick','on')
        ylabel(ylabeli)
        set(gca,'xticklabel',{[]})
        if fliptime == 1
            set (gca, 'xdir', 'reverse' )
        else
            set (gca, 'xdir', 'normal' )
        end
        
        if flipseries ==1
            set (gca, 'ydir', 'reverse' )
        else
            set (gca, 'ydir', 'normal' )
        end
        
        subplot('position',[0.15 0.05 0.7 0.7]);
        imagesc(t, t, S < threshold);
        set(gca,'XMinorTick','on','YMinorTick','on')
        axis square; 
        colormap([1 1 1;0 0 0]); 

        if handles.unit_type == 0
            xlabel('')
            ylabel('')
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
            ylabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
            ylabel(['Time (',handles.unit,')'])
        end

        if fliptime == 1
            set (gca, 'xdir', 'reverse' )
            set (gca, 'ydir', 'reverse' )
        else
            set (gca, 'xdir', 'normal' )
            set (gca, 'ydir', 'normal' )
        end

    end
else
    if showdet== 1
    % recurrence plot + DET

        subplot('position',[0.15 0.75 0.7 0.2]);
        plot(DETx,DETy,'k','LineWidth',2)
        xlim([min(t), max(t)])
        set(gca,'XMinorTick','on','YMinorTick','on')
        ylabel('DET')
        set(gca,'xticklabel',{[]})
        if fliptime == 1
            set (gca, 'xdir', 'reverse' )
        else
            set (gca, 'xdir', 'normal' )
        end
        
        subplot('position',[0.15 0.05 0.7 0.7]);
        imagesc(t, t, S < threshold);
        axis square; 
        set(gca,'XMinorTick','on','YMinorTick','on')
        colormap([1 1 1;0 0 0]); 

        if handles.unit_type == 0
            xlabel('')
            ylabel('')
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
            ylabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
            ylabel(['Time (',handles.unit,')'])
        end

        if fliptime == 1
            set (gca, 'xdir', 'reverse' )
            set (gca, 'ydir', 'reverse' )
        else
            set (gca, 'xdir', 'normal' )
            set (gca, 'ydir', 'normal' )
        end
        
    else
        % recurrence plot only
        imagesc(t, t, S < threshold);
        axis square; 
        colormap([1 1 1;0 0 0]); 
        set(gca,'XMinorTick','on','YMinorTick','on')
        if handles.unit_type == 0
            xlabel('')
            ylabel('')
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
            ylabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
            ylabel(['Time (',handles.unit,')'])
        end

        if fliptime == 1
            set (gca, 'xdir', 'reverse' )
            set (gca, 'ydir', 'reverse' )
        else
            set (gca, 'xdir', 'normal' )
            set (gca, 'ydir', 'normal' )
        end
    end
end
try close(hwarn)
catch
end
% save data
if showdet== 1
    handles.DET = [DETx, DETy];
end
St = S;
St(St >= threshold)  = nan;
handles.St = St;

figure(handles.RecPlotGUI)