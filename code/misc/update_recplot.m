
data_s = handles.current_data;
[N, ncol] = size(data_s);
S = handles.S;

if ncol == 1
    x = data_s;
    t = 1:N;
else
    x = data_s(:,2);
    t = data_s(:,1);
end

%% ---- normalization ----
if isfield(handles,'normFlag') && strcmpi(handles.normFlag,'nonorm')
    x0 = x(:);
    mu = mean(x0,'omitnan');
    sig = std(x0,'omitnan');

    if sig > 0
        x = (x - mu) ./ sig;
    else
        warning('std(x) = 0, skip normalization');
    end
end

%% ---- Get input parameters ----
showseries = get(handles.checkbox1,'Value');
showdet    = get(handles.checkbox2,'Value');
fliptime   = get(handles.checkbox3,'Value');
flipseries = get(handles.checkbox4,'Value');

ylabeli = get(handles.edit7,'String');

% ---- enable/disable DET-related inputs ----
if showdet == 1
    set(handles.edit3,'Enable','on')
    set(handles.edit4,'Enable','on')
    set(handles.edit5,'Enable','on')
    set(handles.edit6,'Enable','on')
    % new controls
    if isfield(handles,'popup_method') && isgraphics(handles.popup_method)
        set(handles.popup_method,'Enable','on')
    end
    if isfield(handles,'popup_norm') && isgraphics(handles.popup_norm)
        set(handles.popup_norm,'Enable','on')
    end
       if isfield(handles,'edit_dim') && isgraphics(handles.edit_dim)
        set(handles.edit_dim,'Enable','on');
    end
    if isfield(handles,'edit_tau') && isgraphics(handles.edit_tau)
        set(handles.edit_tau,'Enable','on');
    end
else
    set(handles.edit3,'Enable','off')
    set(handles.edit4,'Enable','off')
    set(handles.edit5,'Enable','off')
    set(handles.edit6,'Enable','off')
    % new controls
    if isfield(handles,'popup_method') && isgraphics(handles.popup_method)
        set(handles.popup_method,'Enable','off')
    end
    if isfield(handles,'popup_norm') && isgraphics(handles.popup_norm)
        set(handles.popup_norm,'Enable','off')
    end
    if isfield(handles,'edit_dim') && isgraphics(handles.edit_dim)
        set(handles.edit_dim,'Enable','off');
    end
    if isfield(handles,'edit_tau') && isgraphics(handles.edit_tau)
        set(handles.edit_tau,'Enable','off');
    end
end

% ---- method_use + normFlag defaults (if older handles) ----
if ~isfield(handles,'method_use') || isempty(handles.method_use)
    handles.method_use = 'rr';
end
if ~isfield(handles,'normFlag') || isempty(handles.normFlag)
    handles.normFlag = 'nonorm';
end
if ~isfield(handles,'embed_m') || isempty(handles.embed_m), handles.embed_m = 1; end
if ~isfield(handles,'embed_tau') || isempty(handles.embed_tau), handles.embed_tau = 1; end

threshold = str2double(get(handles.edit2,'String'));
if isnan(threshold)
    errordlg('Threshold should be a number');
    return
end

% --- interpret threshold for RP plotting (METHOD-AWARE, consistent with crp_pdist) ---
% Goal: always produce a valid eps_plot so that RP = (S < eps_plot) has no issues.
%   - rr/fa/in : threshold means RR (0..1) or percent (0..100), convert -> eps_plot from S distribution
%   - others   : threshold means eps (distance), clamp to valid distance range
[eps_plot, rr_plot, threshold_plot_used] = local_threshold_to_eps_for_plot(threshold, handles.method_use, S);

% if GUI needs to reflect corrected value (optional but safer)
if threshold_plot_used ~= threshold
    set(handles.edit2, 'String', num2str(threshold_plot_used));
end


%% ---- DET calculation ----
if showdet == 1
    if ncol == 1
        winN = N;
        wsN  = 1;
    else
        winN = max(data_s(:,1)) - min(data_s(:,1));
        wsN  = median(diff(data_s(:,1)));
    end

    % read window size
    w = str2double(get(handles.edit3,'String'));
    if ~isnan(w)
        if w > winN
            w = winN;
            set(handles.edit3,'String',num2str(w))
            warning(['Window size is too big. Must be smaller than ', num2str(winN)])
        elseif w <= 0
            w = winN;
            set(handles.edit3,'String',num2str(w))
            warning(['Window size is too small. Must be bigger than 0'])
        end
        if ncol > 1
            w = round(N * w / winN);  % force integer
        end
    else
        errordlg('Window size should be a number')
        return
    end

    % read sliding step
    ws = str2double(get(handles.edit4,'String'));
    if ~isnan(ws)
        if ws > w
            ws = w;
            set(handles.edit4,'String',num2str(ws))
            warning('Sliding step is too big. Clamped to window size.')
        elseif ws < wsN
            ws = wsN;
            set(handles.edit4,'String',num2str(ws))
            warning(['Sliding step is too small. Must be larger than ', num2str(wsN)])
        end
        if ncol > 1
            ws = round(N * ws / winN);  % force integer
        end
    else
        errordlg('Sliding step should be a number')
        return
    end

    % read theiler window
    theiler_window = str2double(get(handles.edit5,'String'));
    if isnan(theiler_window)
        errordlg('Theiler window should be a number')
        return
    end

    % read lmin
    lmin = str2double(get(handles.edit6,'String'));
    if isnan(lmin)
        errordlg('Minimal length of diagonal line structure should be a number')
        return
    end

    if N > 300
        hwarn = warndlg('Warning: long time series. Please wait. Up to several minutes','DET calculation');
    end

    % ---- NEW: read dimension(m) and delay(tau) ----
    m = handles.embed_m;
    tau = handles.embed_tau;
    
    if isfield(handles,'edit_dim') && isgraphics(handles.edit_dim)
        mv = str2double(get(handles.edit_dim,'String'));
        if isfinite(mv), m = max(1, round(mv)); end
    end
    if isfield(handles,'edit_tau') && isgraphics(handles.edit_tau)
        tv = str2double(get(handles.edit_tau,'String'));
        if isfinite(tv), tau = max(1, round(tv)); end
    end
    
    % sync back to GUI and handles (keep consistent)
    handles.embed_m = m;
    handles.embed_tau = tau;
    if isfield(handles,'edit_dim') && isgraphics(handles.edit_dim)
        set(handles.edit_dim,'String',num2str(m));
    end
    if isfield(handles,'edit_tau') && isgraphics(handles.edit_tau)
        set(handles.edit_tau,'String',num2str(tau));
    end

    % ---- NEW: pass method_use + normFlag into crp_pdist ----
    
    [DETy, testi] = crp_pdist(x, w, ws, theiler_window, lmin, 0, threshold, handles.method_use, handles.normFlag, m, tau);


    DETx = round(t(testi) + 1/2 * winN * w / N);
end

%% ---- Plot ----
try
    figure(handles.hrp)
catch
    handles.hrp = figure;
end
clf(handles.hrp,'reset')
set(gcf,'Color','w')
set(gcf,'Name','Recurrence Plot')
axis square;

if showseries == 1
    if showdet == 1
        % recurrence plot + series + DET
        subplot('position',[0.15 0.86 0.7 0.11]);
        plot(t,x,'k','LineWidth',1)
        set(gca,'XMinorTick','on','YMinorTick','on','TickDir','out');
        xlim([min(t), max(t)])
        ylabel(ylabeli)
        set(gca,'xticklabel',{[]})
        set(gca,'xdir', ternary(fliptime==1,'reverse','normal'));
        set(gca,'ydir', ternary(flipseries==1,'reverse','normal'));

        subplot('position',[0.15 0.75 0.7 0.11]);
        plot(DETx,DETy,'k','LineWidth',2)
        xlim([min(t), max(t)])
        ylabel('DET')
        set(gca,'xticklabel',{[]})
        set(gca,'XMinorTick','on','YMinorTick','on','TickDir','out');
        set(gca,'xdir', ternary(fliptime==1,'reverse','normal'));

        subplot('position',[0.15 0.05 0.7 0.7]);
        imagesc(t, t, S < eps_plot);
        axis square;
        set(gca,'XMinorTick','on','YMinorTick','on','TickDir','out');
        colormap([1 1 1;0 0 0]);

        if handles.unit_type == 0
            xlabel(''); ylabel('');
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
            ylabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
            ylabel(['Time (',handles.unit,')'])
        end

        if fliptime == 1
            set(gca,'xdir','reverse','ydir','reverse')
        else
            set(gca,'xdir','normal','ydir','normal')
        end

    else
        % recurrence plot + series
        subplot('position',[0.15 0.75 0.7 0.2]);
        plot(t,x,'k','LineWidth',1)
        xlim([min(t), max(t)])
        set(gca,'XMinorTick','on','YMinorTick','on','TickDir','out');
        ylabel(ylabeli)
        set(gca,'xticklabel',{[]})
        set(gca,'xdir', ternary(fliptime==1,'reverse','normal'));
        set(gca,'ydir', ternary(flipseries==1,'reverse','normal'));

        subplot('position',[0.15 0.05 0.7 0.7]);
        imagesc(t, t, S < eps_plot);
        axis square;
        set(gca,'XMinorTick','on','YMinorTick','on','TickDir','out');
        colormap([1 1 1;0 0 0]);

        if handles.unit_type == 0
            xlabel(''); ylabel('');
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
            ylabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
            ylabel(['Time (',handles.unit,')'])
        end

        if fliptime == 1
            set(gca,'xdir','reverse','ydir','reverse')
        else
            set(gca,'xdir','normal','ydir','normal')
        end
    end
else
    if showdet == 1
        % recurrence plot + DET
        subplot('position',[0.15 0.75 0.7 0.2]);
        plot(DETx,DETy,'k','LineWidth',2)
        xlim([min(t), max(t)])
        set(gca,'XMinorTick','on','YMinorTick','on','TickDir','out');
        ylabel('DET')
        set(gca,'xticklabel',{[]})
        set(gca,'xdir', ternary(fliptime==1,'reverse','normal'));

        subplot('position',[0.15 0.05 0.7 0.7]);
        imagesc(t, t, S < eps_plot);
        axis square;
        set(gca,'XMinorTick','on','YMinorTick','on','TickDir','out');
        colormap([1 1 1;0 0 0]);

        if handles.unit_type == 0
            xlabel(''); ylabel('');
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
            ylabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
            ylabel(['Time (',handles.unit,')'])
        end

        if fliptime == 1
            set(gca,'xdir','reverse','ydir','reverse')
        else
            set(gca,'xdir','normal','ydir','normal')
        end
    else
        % recurrence plot only
        imagesc(t, t, S < eps_plot);
        axis square;
        colormap([1 1 1;0 0 0]);
        set(gca,'XMinorTick','on','YMinorTick','on','TickDir','out');

        if handles.unit_type == 0
            xlabel(''); ylabel('');
        elseif handles.unit_type == 1
            xlabel(['Depth (',handles.unit,')'])
            ylabel(['Depth (',handles.unit,')'])
        else
            xlabel(['Time (',handles.unit,')'])
            ylabel(['Time (',handles.unit,')'])
        end

        if fliptime == 1
            set(gca,'xdir','reverse','ydir','reverse')
        else
            set(gca,'xdir','normal','ydir','normal')
        end
    end
end

try
    close(hwarn)
catch
end

% ---- save data ----
if showdet == 1
    handles.DET = [DETx, DETy];
end

% IMPORTANT: use eps_plot (distance threshold) to mask St for saving/plotting
St = S;
St(St >= eps_plot) = nan;
handles.St = St;

% keep latest
guidata(handles.RecPlotGUI, handles);

% helper: simple ternary for property values
function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end

function [eps_plot, rr_plot, thr_used] = local_threshold_to_eps_for_plot(threshold, method_use, S)
% Convert GUI "threshold" into eps_plot for RP visualization, consistent with crp_pdist semantics.
% Returns:
%   eps_plot : distance threshold used for RP image (S < eps_plot)
%   rr_plot  : RR used when method is rr/fa/in, else NaN
%   thr_used : possibly corrected threshold value for GUI display

thr_used = threshold;

% basic check
if nargin < 2 || isempty(method_use), method_use = 'rr'; end
if nargin < 1 || isempty(threshold) || ~isfinite(threshold)
    threshold = 0.10;
    thr_used  = threshold;
end

method_use = lower(string(method_use));
rr_methods = ["rr","fa","in"];

% get finite off-diagonal distances for robust stats/clamping
d = local_offdiag_distvec(S);
if isempty(d)
    % fallback: avoid crash; RP will be empty
    eps_plot = 0;
    rr_plot  = NaN;
    return;
end
dmin = min(d);
dmax = max(d);

if any(method_use == rr_methods)
    % RR mode: threshold should be RR (0..1) or percent (0..100)
    if threshold <= 0
        rr = 0.10;
        thr_used = rr;
        warning('Threshold <= 0 in RR mode. Reset to 0.10.');
    elseif threshold <= 1
        rr = threshold;
    elseif threshold <= 100
        rr = threshold/100;
    else
        % >100 is nonsensical for RR/percent; clamp to 100%
        rr = 1.0;
        thr_used = 100;
        warning('Threshold > 100 in RR mode. Clamped to 100%% (RR=1).');
    end

    % keep rr strictly inside [0,1]
    rr = max(0, min(1, rr));
    rr_plot = rr;

    % convert RR -> eps on S distribution
    eps_plot = local_eps_from_rr_for_plot(S, rr_plot);

    % safety clamp to [dmin,dmax] (should already be, but keep it robust)
    eps_plot = max(dmin, min(dmax, eps_plot));
else
    % EPS mode: threshold is a distance (even if <=1)
    rr_plot = NaN;
    eps_plot = double(threshold);

    % clamp eps to distance range
    if eps_plot > dmax
        eps_plot = dmax;
        thr_used = eps_plot;
        warning(['Threshold is too big for eps-mode. Clamped to max distance = ', num2str(dmax)]);
    elseif eps_plot < dmin
        eps_plot = dmin;
        thr_used = eps_plot;
        warning(['Threshold is too small for eps-mode. Clamped to min distance = ', num2str(dmin)]);
    end
end

end

function d = local_offdiag_distvec(D)
% Extract finite upper-triangular off-diagonal distances as a vector.
n = size(D,1);
mask = triu(true(n), 1);      % exclude diagonal
d = D(mask);
d = d(isfinite(d));
d = double(d(:));
end

function epsk = local_eps_from_rr_for_plot(D, rr)
% RR -> eps using the upper-triangle distance distribution.
% rr in [0,1]. epsk is the rr-quantile point (discrete).
d = local_offdiag_distvec(D);
if isempty(d)
    epsk = 0;
    return;
end

rr = max(0, min(1, rr));

d = sort(d);
K = max(1, min(numel(d), round(rr * numel(d))));
epsk = d(K);
end
