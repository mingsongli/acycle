classdef RecPlotGUI < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE RecPlotGUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure

        LabelSeries matlab.ui.control.Label
        EditSeries matlab.ui.control.EditField
        EditYLabel matlab.ui.control.EditField

        LabelThreshold matlab.ui.control.Label
        EditThreshold matlab.ui.control.EditField

        CheckShowSeries matlab.ui.control.CheckBox
        CheckShowDET matlab.ui.control.CheckBox
        CheckFlipTime matlab.ui.control.CheckBox
        CheckFlipY matlab.ui.control.CheckBox

        PanelSliding matlab.ui.container.Panel
        LabelWindowSize matlab.ui.control.Label
        EditWindowSize matlab.ui.control.EditField
        LabelWindowUnit matlab.ui.control.Label
        LabelSlidingStep matlab.ui.control.Label
        EditSlidingStep matlab.ui.control.EditField
        LabelStepUnit matlab.ui.control.Label
        LabelTheiler matlab.ui.control.Label
        EditTheiler matlab.ui.control.EditField
        LabelDiagMin matlab.ui.control.Label
        EditDiagMin matlab.ui.control.EditField

        ButtonSave matlab.ui.control.Button
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1

        lang_choice double = 0
        lang_id = {}
        lang_var = {}

        unit = ''
        unit_type double = 0
        current_data
        data_name = ''
        path_temp = ''
        listbox_acmain
        edit_acfigmain_dir
        val1 double = 1

        filename = ''
        fileext = ''

        S
        threshold double = 0
        w double = 30
        ws double = 1
        theiler_window double = 1
        lmin double = 2
        St
        DET

        method_use char = 'rr'
        normFlag char = 'nonorm'
        embed_m double = 1
        embed_tau double = 1

        hrp = []

        UIFontSize double = 11.5
        UIBgColor double = [0.94 0.94 0.94]
        EditEnabledColor double = [1 1 1]
        EditDisabledColor double = [0.90 0.90 0.90]
    end

    methods (Access = private)
        function screenSize = getScreenSizePixels(~)
            oldUnits = get(groot, 'Units');
            set(groot, 'Units', 'pixels');
            screenSize = get(groot, 'ScreenSize');
            set(groot, 'Units', oldUnits);
        end

        function pos = normalizedToPixelPosition(app, normPos)
            screenSize = app.getScreenSizePixels();
            zoom = app.MonZoom;
            if isnumeric(zoom)
                if isscalar(zoom)
                    normPos = normPos * zoom;
                elseif numel(zoom) >= 4
                    normPos = normPos .* zoom(1:4);
                end
            end
            w = max(760, normPos(3) * screenSize(3));
            h = max(520, normPos(4) * screenSize(4));
            x = screenSize(1) + normPos(1) * screenSize(3);
            y = screenSize(2) + normPos(2) * screenSize(4);
            x = min(max(x, screenSize(1)), screenSize(1) + screenSize(3) - w);
            y = min(max(y, screenSize(2)), screenSize(2) + screenSize(4) - h);
            pos = round([x, y, w, h]);
        end

        function p = childPos(~, parentPos, rel)
            p = round([ ...
                rel(1) * parentPos(3), ...
                rel(2) * parentPos(4), ...
                rel(3) * parentPos(3), ...
                rel(4) * parentPos(4)]);
        end

        function txt = getLang(app, key, defaultText)
            txt = defaultText;
            if isempty(app.lang_id) || isempty(app.lang_var)
                return
            end
            [~, idx] = ismember(key, app.lang_id);
            if idx > 0 && idx <= numel(app.lang_var)
                txt = app.lang_var{idx};
            end
        end

        function applyLayout(app)
            fw = app.UIFigure.Position(3);
            fh = app.UIFigure.Position(4);
            figRect = [0, 0, fw, fh];

            app.LabelSeries.Position = app.childPos(figRect, [0.06,0.79,0.08,0.07]);
            app.EditSeries.Position = app.childPos(figRect, [0.145,0.77,0.50,0.095]);
            app.EditYLabel.Position = app.childPos(figRect, [0.67,0.77,0.13,0.095]);

            app.LabelThreshold.Position = app.childPos(figRect, [0.05,0.58,0.10,0.07]);
            app.EditThreshold.Position = app.childPos(figRect, [0.145,0.56,0.13,0.095]);

            app.CheckShowSeries.Position = app.childPos(figRect, [0.105,0.40,0.17,0.12]);
            app.CheckShowDET.Position = app.childPos(figRect, [0.105,0.25,0.15,0.12]);
            app.CheckFlipTime.Position = app.childPos(figRect, [0.105,0.10,0.11,0.12]);
            app.CheckFlipY.Position = app.childPos(figRect, [0.22,0.10,0.11,0.12]);

            app.PanelSliding.Position = app.childPos(figRect, [0.36,0.10,0.50,0.50]);
            app.LabelWindowSize.Position = app.childPos(app.PanelSliding.Position, [0.07,0.70,0.23,0.13]);
            app.EditWindowSize.Position = app.childPos(app.PanelSliding.Position, [0.27,0.65,0.10,0.18]);
            app.LabelWindowUnit.Position = app.childPos(app.PanelSliding.Position, [0.40,0.70,0.13,0.12]);

            app.LabelSlidingStep.Position = app.childPos(app.PanelSliding.Position, [0.07,0.40,0.23,0.13]);
            app.EditSlidingStep.Position = app.childPos(app.PanelSliding.Position, [0.27,0.35,0.10,0.18]);
            app.LabelStepUnit.Position = app.childPos(app.PanelSliding.Position, [0.40,0.40,0.13,0.12]);

            app.LabelTheiler.Position = app.childPos(app.PanelSliding.Position, [0.55,0.70,0.27,0.13]);
            app.EditTheiler.Position = app.childPos(app.PanelSliding.Position, [0.83,0.65,0.11,0.18]);
            app.LabelDiagMin.Position = app.childPos(app.PanelSliding.Position, [0.55,0.40,0.27,0.13]);
            app.EditDiagMin.Position = app.childPos(app.PanelSliding.Position, [0.83,0.35,0.11,0.18]);

            app.ButtonSave.Position = app.childPos(figRect, [0.87,0.10,0.12,0.12]);
        end

        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Acycle: Recurrence Plot', ...
                'Color', app.UIBgColor, ...
                'Resize', 'on', ...
                'Position', app.normalizedToPixelPosition([0.35,0.4,0.45,0.35]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.LabelSeries = uilabel(app.UIFigure, 'Text', 'Series', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);
            app.EditSeries = uieditfield(app.UIFigure, 'text', 'Editable', 'off', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.EditDisabledColor);
            app.EditYLabel = uieditfield(app.UIFigure, 'text', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.EditEnabledColor, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());

            app.LabelThreshold = uilabel(app.UIFigure, 'Text', 'Threshold', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);
            app.EditThreshold = uieditfield(app.UIFigure, 'text', ...
                'FontSize', app.UIFontSize, 'HorizontalAlignment', 'center', ...
                'BackgroundColor', app.EditEnabledColor, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());

            app.CheckShowSeries = uicheckbox(app.UIFigure, 'Text', 'Show series', 'Value', true, ...
                'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());
            app.CheckShowDET = uicheckbox(app.UIFigure, 'Text', 'Show DET', 'Value', false, ...
                'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());
            app.CheckFlipTime = uicheckbox(app.UIFigure, 'Text', 'Flip time', 'Value', false, ...
                'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());
            app.CheckFlipY = uicheckbox(app.UIFigure, 'Text', 'Flip Y axis', 'Value', false, ...
                'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());

            app.PanelSliding = uipanel(app.UIFigure, 'Title', 'Sliding window', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);
            app.LabelWindowSize = uilabel(app.PanelSliding, 'Text', 'Window size', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);
            app.EditWindowSize = uieditfield(app.PanelSliding, 'text', ...
                'FontSize', app.UIFontSize, 'HorizontalAlignment', 'center', 'BackgroundColor', app.EditDisabledColor, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());
            app.LabelWindowUnit = uilabel(app.PanelSliding, 'Text', 'unit', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);

            app.LabelSlidingStep = uilabel(app.PanelSliding, 'Text', 'Sliding step', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);
            app.EditSlidingStep = uieditfield(app.PanelSliding, 'text', ...
                'FontSize', app.UIFontSize, 'HorizontalAlignment', 'center', 'BackgroundColor', app.EditDisabledColor, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());
            app.LabelStepUnit = uilabel(app.PanelSliding, 'Text', 'unit', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);

            app.LabelTheiler = uilabel(app.PanelSliding, 'Text', 'Theiler window', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);
            app.EditTheiler = uieditfield(app.PanelSliding, 'text', ...
                'FontSize', app.UIFontSize, 'HorizontalAlignment', 'center', 'BackgroundColor', app.EditDisabledColor, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());

            app.LabelDiagMin = uilabel(app.PanelSliding, 'Text', 'diagonal line min', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.UIBgColor);
            app.EditDiagMin = uieditfield(app.PanelSliding, 'text', ...
                'FontSize', app.UIFontSize, 'HorizontalAlignment', 'center', 'BackgroundColor', app.EditDisabledColor, ...
                'ValueChangedFcn', @(~,~)app.updateRecplot());

            app.ButtonSave = uibutton(app.UIFigure, 'push', 'Text', 'Save data', ...
                'FontSize', app.UIFontSize, 'ButtonPushedFcn', @(~,~)app.onSaveData());

            app.applyLayout();
        end

        function initializeState(app)
            if isfield(app.Context, 'MonZoom'), app.MonZoom = app.Context.MonZoom; end
            if isfield(app.Context, 'lang_choice'), app.lang_choice = app.Context.lang_choice; end
            if isfield(app.Context, 'lang_id'), app.lang_id = app.Context.lang_id; end
            if isfield(app.Context, 'lang_var'), app.lang_var = app.Context.lang_var; end
            if isfield(app.Context, 'unit'), app.unit = app.Context.unit; end
            if isfield(app.Context, 'unit_type'), app.unit_type = app.Context.unit_type; end
            if isfield(app.Context, 'current_data'), app.current_data = app.Context.current_data; end
            if isfield(app.Context, 'data_name'), app.data_name = app.Context.data_name; end
            if isfield(app.Context, 'path_temp'), app.path_temp = app.Context.path_temp; end
            if isfield(app.Context, 'listbox_acmain'), app.listbox_acmain = app.Context.listbox_acmain; end
            if isfield(app.Context, 'edit_acfigmain_dir'), app.edit_acfigmain_dir = app.Context.edit_acfigmain_dir; end
            if isfield(app.Context, 'val1'), app.val1 = app.Context.val1; end

            [~, app.filename, app.fileext] = fileparts(app.data_name);

            if app.lang_choice == 0
                app.UIFigure.Name = 'Acycle: Recurrence Plot';
            else
                app.UIFigure.Name = ['Acycle: ', app.getLang('menu128', 'Recurrence Plot')];
            end

            if app.lang_choice > 0
                app.LabelSeries.Text = app.getLang('main12', 'Series');
                app.EditYLabel.Value = app.unit;
                app.LabelThreshold.Text = app.getLang('main53', 'Threshold');
                app.CheckShowSeries.Text = [app.getLang('main54', 'Show '), app.getLang('main12', 'Series')];
                app.CheckShowDET.Text = [app.getLang('main54', 'Show '), 'DET'];
                app.CheckFlipTime.Text = app.getLang('recPlot03', 'Flip time');
                app.CheckFlipY.Text = app.getLang('main10', 'Flip Y axis');
                app.PanelSliding.Title = app.getLang('main07', 'Sliding window');
                app.LabelWindowSize.Text = app.getLang('c39', 'Window size');
                app.LabelTheiler.Text = [app.getLang('recPlot01', 'Theiler '), app.getLang('main41', 'window')];
                app.LabelSlidingStep.Text = [app.getLang('main55', 'Sliding'), ' ', app.getLang('main32', 'step')];
                app.LabelDiagMin.Text = app.getLang('recPlot02', 'diagonal line min');
                app.ButtonSave.Text = app.getLang('main01', 'Save data');
            else
                app.EditYLabel.Value = app.unit;
            end

            data_s = app.current_data;
            [N, ncol] = size(data_s);

            if ncol == 1
                x = data_s;
                ws = 1;
                w = round(0.3 * N);
                if w/ws > 500
                    ws = round(w/300);
                end
            else
                diffx = diff(data_s(:,1));
                if max(diffx) - min(diffx) > 10*eps('single')
                    if app.lang_choice == 0
                        hwarn = warndlg('Not equally spaced data. Interpolated using mean sampling rate!');
                    else
                        hwarn = warndlg(app.getLang('dd37', 'Not equally spaced data. Interpolated using mean sampling rate!'));
                    end
                    interpolate_rate = mean(diffx);
                    app.current_data = interpolate(data_s, interpolate_rate);
                    data_s = app.current_data;
                    try figure(hwarn); catch, end
                    diffx = diff(data_s(:,1));
                end
                x = data_s(:,2);
                ws = median(diffx);
                wmax = abs(max(data_s(:,1)) - min(data_s(:,1)));
                w = ws * 30;
                if w > wmax, w = wmax; end
            end

            [~, app.S, app.threshold] = app.localBuildSAndThreshold(x, app.normFlag);

            app.w = w;
            app.ws = ws;
            app.theiler_window = 1;
            app.lmin = 2;

            app.EditSeries.Value = [app.filename, app.fileext];
            app.EditThreshold.Value = num2str(app.threshold);
            app.EditWindowSize.Value = num2str(app.w);
            app.EditSlidingStep.Value = num2str(app.ws);
            app.EditTheiler.Value = num2str(app.theiler_window);
            app.EditDiagMin.Value = num2str(app.lmin);
            app.LabelWindowUnit.Text = app.unit;
            app.LabelStepUnit.Text = app.unit;

            app.CheckShowSeries.Value = true;
            app.CheckShowDET.Value = false;
            app.CheckFlipTime.Value = false;
            app.CheckFlipY.Value = false;

            app.UIFigure.Position = app.normalizedToPixelPosition([0.35,0.4,0.45,0.35]);
            app.applyLayout();

            app.updateRecplot();
            try
                if isgraphics(app.hrp)
                    set(app.hrp, 'Units', 'normalized', 'Position', [0.05,0.05,0.3,0.6]);
                end
            catch
            end
        end

        function onSaveData(app)
            CDac_pwd;
            add_list1 = [app.filename, '-RP.txt'];
            add_list2 = [app.filename, '-RP-DET.txt'];
            try
                if ~isempty(app.St)
                    dlmwrite(add_list1, app.St, 'delimiter', ' ', 'precision', 9);
                end
                if ~isempty(app.DET)
                    dlmwrite(add_list2, app.DET, 'delimiter', ' ', 'precision', 9);
                end
            catch
            end

            app.refreshMainListbox();
            cd(pre_dirML);

            try figure(app.hrp); catch, end
            try figure(app.UIFigure); catch, end
        end

        function refreshMainListbox(app)
            workDir = pwd;
            if ac_refresh_main_list(app.listbox_acmain,workDir)
                return
            end
            if isempty(app.listbox_acmain) || ~isgraphics(app.listbox_acmain)
                return
            end
            d = dir(workDir);
            d = d(~ismember({d.name},{'.','..'}));
            sortMode = app.val1;
            try
                mainHandles = guidata(app.listbox_acmain);
                if isstruct(mainHandles) && isfield(mainHandles,'val1') && ...
                        ~isempty(mainHandles.val1)
                    sortMode = mainHandles.val1;
                end
            catch
            end
            switch sortMode
                case {1,2,3,4,5,6}
                otherwise
                    sortMode = 1;
            end
            sd = ac_sort_dir_entries(d,sortMode);
            ac_update_listbox_acmain(app.listbox_acmain, ...
                {sd.name},[sd.isdir]);
            if ~isempty(app.edit_acfigmain_dir) && isgraphics(app.edit_acfigmain_dir)
                set(app.edit_acfigmain_dir,'String',workDir);
            end
            ac_working_directory('set',workDir);
            drawnow limitrate;
        end

        function updateRecplot(app)
            data_s = app.current_data;
            [N, ncol] = size(data_s);
            S = app.S;

            if ncol == 1
                x = data_s;
                t = (1:N)';
            else
                x = data_s(:,2);
                t = data_s(:,1);
            end

            if strcmpi(app.normFlag, 'norm')
                x0 = x(:);
                mu = mean(x0, 'omitnan');
                sig = std(x0, 'omitnan');
                if sig > 0
                    x = (x - mu) ./ sig;
                end
            end

            showseries = app.CheckShowSeries.Value;
            showdet = app.CheckShowDET.Value;
            fliptime = app.CheckFlipTime.Value;
            flipseries = app.CheckFlipY.Value;
            ylabeli = app.EditYLabel.Value;

            if showdet
                app.EditWindowSize.Enable = 'on';
                app.EditSlidingStep.Enable = 'on';
                app.EditTheiler.Enable = 'on';
                app.EditDiagMin.Enable = 'on';
                app.EditWindowSize.BackgroundColor = app.EditEnabledColor;
                app.EditSlidingStep.BackgroundColor = app.EditEnabledColor;
                app.EditTheiler.BackgroundColor = app.EditEnabledColor;
                app.EditDiagMin.BackgroundColor = app.EditEnabledColor;
            else
                app.EditWindowSize.Enable = 'off';
                app.EditSlidingStep.Enable = 'off';
                app.EditTheiler.Enable = 'off';
                app.EditDiagMin.Enable = 'off';
                app.EditWindowSize.BackgroundColor = app.EditDisabledColor;
                app.EditSlidingStep.BackgroundColor = app.EditDisabledColor;
                app.EditTheiler.BackgroundColor = app.EditDisabledColor;
                app.EditDiagMin.BackgroundColor = app.EditDisabledColor;
            end

            threshold = str2double(app.EditThreshold.Value);
            if isnan(threshold)
                errordlg('Threshold should be a number');
                return
            end

            [eps_plot, ~, threshold_plot_used] = app.localThresholdToEpsForPlot(threshold, app.method_use, S);
            if threshold_plot_used ~= threshold
                app.EditThreshold.Value = num2str(threshold_plot_used);
            end

            if showdet
                if ncol == 1
                    winN = N;
                    wsN = 1;
                else
                    winN = max(data_s(:,1)) - min(data_s(:,1));
                    wsN = median(diff(data_s(:,1)));
                end

                w = str2double(app.EditWindowSize.Value);
                if isnan(w)
                    errordlg('Window size should be a number');
                    return
                end
                if w > winN
                    w = winN;
                    app.EditWindowSize.Value = num2str(w);
                elseif w <= 0
                    w = winN;
                    app.EditWindowSize.Value = num2str(w);
                end
                if ncol > 1
                    w = round(N * w / winN);
                end

                ws = str2double(app.EditSlidingStep.Value);
                if isnan(ws)
                    errordlg('Sliding step should be a number');
                    return
                end
                if ws > w
                    ws = w;
                    app.EditSlidingStep.Value = num2str(ws);
                elseif ws < wsN
                    ws = wsN;
                    app.EditSlidingStep.Value = num2str(ws);
                end
                if ncol > 1
                    ws = round(N * ws / winN);
                end

                theiler_window = str2double(app.EditTheiler.Value);
                lmin = str2double(app.EditDiagMin.Value);
                if isnan(theiler_window)
                    errordlg('Theiler window should be a number');
                    return
                end
                if isnan(lmin)
                    errordlg('Minimal length of diagonal line structure should be a number');
                    return
                end

                if N > 300
                    hwarn = warndlg('Warning: long time series. Please wait. Up to several minutes', 'DET calculation');
                else
                    hwarn = [];
                end

                [DETy, testi] = crp_pdist(x, w, ws, theiler_window, lmin, 0, threshold, app.method_use, app.normFlag, app.embed_m, app.embed_tau);
                DETx = round(t(testi) + 1/2 * winN * w / N);
            else
                hwarn = [];
            end

            try
                if isempty(app.hrp) || ~isgraphics(app.hrp)
                    error('new');
                end
                figure(app.hrp);
            catch
                app.hrp = figure;
                figure(app.hrp);
            end

            clf(app.hrp, 'reset');
            set(app.hrp, 'Color', 'w', 'Name', 'Recurrence Plot');
            axis square;

            if showseries
                if showdet
                    subplot('position', [0.15 0.86 0.7 0.11]);
                    plot(t, x, 'k', 'LineWidth', 1);
                    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
                    xlim([min(t), max(t)]);
                    ylabel(ylabeli);
                    set(gca, 'xticklabel', {[]});
                    set(gca, 'xdir', app.ternary(fliptime, 'reverse', 'normal'));
                    set(gca, 'ydir', app.ternary(flipseries, 'reverse', 'normal'));

                    subplot('position', [0.15 0.75 0.7 0.11]);
                    plot(DETx, DETy, 'k', 'LineWidth', 2);
                    xlim([min(t), max(t)]);
                    ylim([0.9*min(DETy), 1.1*max(DETy)]);
                    ylabel('DET');
                    set(gca, 'xticklabel', {[]});
                    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
                    set(gca, 'xdir', app.ternary(fliptime, 'reverse', 'normal'));

                    subplot('position', [0.15 0.05 0.7 0.7]);
                    imagesc(t, t, S < eps_plot);
                    axis square;
                    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
                    colormap([1 1 1; 0 0 0]);
                    app.setAxisLabels();
                    if fliptime
                        set(gca, 'xdir', 'reverse', 'ydir', 'reverse');
                    else
                        set(gca, 'xdir', 'normal', 'ydir', 'normal');
                    end
                else
                    subplot('position', [0.15 0.75 0.7 0.2]);
                    plot(t, x, 'k', 'LineWidth', 1);
                    xlim([min(t), max(t)]);
                    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
                    ylabel(ylabeli);
                    set(gca, 'xticklabel', {[]});
                    set(gca, 'xdir', app.ternary(fliptime, 'reverse', 'normal'));
                    set(gca, 'ydir', app.ternary(flipseries, 'reverse', 'normal'));

                    subplot('position', [0.15 0.05 0.7 0.7]);
                    imagesc(t, t, S < eps_plot);
                    axis square;
                    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
                    colormap([1 1 1; 0 0 0]);
                    app.setAxisLabels();
                    if fliptime
                        set(gca, 'xdir', 'reverse', 'ydir', 'reverse');
                    else
                        set(gca, 'xdir', 'normal', 'ydir', 'normal');
                    end
                end
            else
                if showdet
                    subplot('position', [0.15 0.75 0.7 0.2]);
                    plot(DETx, DETy, 'k', 'LineWidth', 2);
                    xlim([min(t), max(t)]);
                    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
                    ylabel('DET');
                    set(gca, 'xticklabel', {[]});
                    set(gca, 'xdir', app.ternary(fliptime, 'reverse', 'normal'));

                    subplot('position', [0.15 0.05 0.7 0.7]);
                    imagesc(t, t, S < eps_plot);
                    axis square;
                    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
                    colormap([1 1 1; 0 0 0]);
                    app.setAxisLabels();
                    if fliptime
                        set(gca, 'xdir', 'reverse', 'ydir', 'reverse');
                    else
                        set(gca, 'xdir', 'normal', 'ydir', 'normal');
                    end
                else
                    imagesc(t, t, S < eps_plot);
                    axis square;
                    colormap([1 1 1; 0 0 0]);
                    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'TickDir', 'out');
                    app.setAxisLabels();
                    if fliptime
                        set(gca, 'xdir', 'reverse', 'ydir', 'reverse');
                    else
                        set(gca, 'xdir', 'normal', 'ydir', 'normal');
                    end
                end
            end

            try
                if ~isempty(hwarn), close(hwarn); end
            catch
            end

            if showdet
                app.DET = [DETx, DETy];
            else
                app.DET = [];
            end

            St = S;
            St(St >= eps_plot) = nan;
            app.St = St;
        end

        function setAxisLabels(app)
            if app.unit_type == 0
                xlabel(''); ylabel('');
            elseif app.unit_type == 1
                xlabel(['Depth (', app.unit, ')']);
                ylabel(['Depth (', app.unit, ')']);
            else
                xlabel(['Time (', app.unit, ')']);
                ylabel(['Time (', app.unit, ')']);
            end
        end

        function out = ternary(~, cond, a, b)
            if cond
                out = a;
            else
                out = b;
            end
        end

        function [x_use, S, threshold] = localBuildSAndThreshold(~, x, normFlag)
            x_use = double(x(:));
            if nargin < 3 || isempty(normFlag), normFlag = 'nonorm'; end
            nf = lower(strtrim(string(normFlag)));
            if nf == "narow", nf = "nonorm"; end
            if nf == "normalize" || nf == "zscore", nf = "norm"; end
            if nf == "norm"
                mu = mean(x_use,'omitnan');
                sig = std(x_use,'omitnan');
                if isfinite(sig) && sig > 0
                    x_use = (x_use - mu) ./ sig;
                end
            end
            N = numel(x_use);
            S = zeros(N,N);
            for i = 1:N
                S(:,i) = abs(x_use(i) - x_use);
            end
            d = S(:);
            d = d(isfinite(d));
            if isempty(d)
                threshold = 0.1;
            else
                threshold = median(d) - 0.5 * std(d);
            end
            dmin = min(d); dmax = max(d);
            if ~isfinite(threshold), threshold = 0.1; end
            threshold = max(dmin, min(dmax, threshold));
        end

        function [eps_plot, rr_plot, thr_used] = localThresholdToEpsForPlot(app, threshold, method_use, S)
            thr_used = threshold;
            if nargin < 3 || isempty(method_use), method_use = 'rr'; end
            if nargin < 2 || isempty(threshold) || ~isfinite(threshold)
                threshold = 0.10; thr_used = threshold;
            end
            method_use = lower(string(method_use));
            rr_methods = ["rr","fa","in"];
            d = app.localOffdiagDistvec(S);
            if isempty(d)
                eps_plot = 0; rr_plot = NaN; return
            end
            dmin = min(d); dmax = max(d);

            if any(method_use == rr_methods)
                if threshold <= 0
                    rr = 0.10; thr_used = rr;
                elseif threshold <= 1
                    rr = threshold;
                elseif threshold <= 100
                    rr = threshold/100;
                else
                    rr = 1.0; thr_used = 100;
                end
                rr = max(0,min(1,rr));
                rr_plot = rr;
                eps_plot = app.localEpsFromRrForPlot(S, rr_plot);
                eps_plot = max(dmin, min(dmax, eps_plot));
            else
                rr_plot = NaN;
                eps_plot = double(threshold);
                if eps_plot > dmax
                    eps_plot = dmax; thr_used = eps_plot;
                elseif eps_plot < dmin
                    eps_plot = dmin; thr_used = eps_plot;
                end
            end
        end

        function d = localOffdiagDistvec(~, D)
            n = size(D,1);
            mask = triu(true(n), 1);
            d = D(mask);
            d = d(isfinite(d));
            d = double(d(:));
        end

        function epsk = localEpsFromRrForPlot(app, D, rr)
            d = app.localOffdiagDistvec(D);
            if isempty(d)
                epsk = 0;
                return
            end
            rr = max(0,min(1,rr));
            d = sort(d);
            K = max(1, min(numel(d), round(rr * numel(d))));
            epsk = d(K);
        end
    end

    methods (Access = public)
        function app = RecPlotGUI(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context, 'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('RecPlotGUI requires a handles/context struct input.');
            end

            app.createComponents();
            app.initializeState();
            registerApp(app, app.UIFigure);

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end
end
