classdef SpectralMomentsGUI < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE SpectralMomentsGUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure
        PanelData matlab.ui.container.Panel
        LabelDataTitle matlab.ui.control.Label
        LabelDataName matlab.ui.control.Label
        CheckPadEdge matlab.ui.control.CheckBox
        DropPadType matlab.ui.control.DropDown

        PanelWindow matlab.ui.container.Panel
        LabelWindow matlab.ui.control.Label
        LabelStep matlab.ui.control.Label
        LabelPad matlab.ui.control.Label
        EditWindow matlab.ui.control.EditField
        EditStep matlab.ui.control.EditField
        EditPad matlab.ui.control.EditField

        CheckSedRate matlab.ui.control.CheckBox

        PanelSettings matlab.ui.container.Panel
        LabelSettingsTitle matlab.ui.control.Label
        LabelSrMean matlab.ui.control.Label
        LabelSmooth matlab.ui.control.Label
        EditSrMean matlab.ui.control.EditField
        DropSmooth matlab.ui.control.DropDown
        LabelSrUnit matlab.ui.control.Label

        RunButton matlab.ui.control.Button
        RefTextArea matlab.ui.control.TextArea
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1

        lang_choice double = 0
        lang_id = {}
        lang_var = {}

        unit = ''
        unit_type
        slash_v
        acfigmain

        filename = ''
        dat_name = ''
        path_temp = ''
        listbox_acmain
        edit_acfigmain_dir
        val1 double = 1

        dat
        datbackup
        window double = 0
        step double = 0
        pad double = 0
        sedrate double = 0
        srmean double = 5
        smoothmodel double = 1
        padedge double = 0
        padtype double = 1

        spectralmomentsFig = []
        UIFontSize double = 12
        UIBgColor double = [0.94 0.94 0.94]
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

            w = max(420, normPos(3) * screenSize(3));
            h = max(280, normPos(4) * screenSize(4));
            x = screenSize(1) + normPos(1) * screenSize(3);
            y = screenSize(2) + normPos(2) * screenSize(4);
            x = min(max(x, screenSize(1)), screenSize(1) + screenSize(3) - w);
            y = min(max(y, screenSize(2)), screenSize(2) + screenSize(4) - h);
            pos = round([x, y, w, h]);
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

            % Calibrated to match the user-provided reference screenshot.
            app.PanelData.Position = app.childPos(figRect, [0.04,0.6,0.92,0.328]);
            app.LabelDataTitle.Position = app.childPos(figRect, [0.045,0.85,0.1,0.15]);
            app.LabelDataName.Position = app.childPos(app.PanelData.Position, [0.04,0.55,0.90,0.28]);
            app.CheckPadEdge.Position = app.childPos(app.PanelData.Position, [0.04,0.30,0.34,0.24]);
            app.DropPadType.Position = app.childPos(app.PanelData.Position, [0.41,0.31,0.27,0.20]);

            app.PanelSettings.Position = app.childPos(figRect, [0.04,0.205,0.322,0.365]);
            app.LabelSettingsTitle.Position = app.childPos(figRect, [0.045,0.555,0.18,0.04]);
            app.LabelWindow.Position = app.childPos(app.PanelSettings.Position, [0.16,0.66,0.35,0.14]);
            app.LabelStep.Position = app.childPos(app.PanelSettings.Position, [0.16,0.39,0.35,0.14]);
            app.LabelPad.Position = app.childPos(app.PanelSettings.Position, [0.11,0.12,0.40,0.14]);
            app.EditWindow.Position = app.childPos(app.PanelSettings.Position, [0.62,0.60,0.32,0.22]);
            app.EditStep.Position = app.childPos(app.PanelSettings.Position, [0.62,0.33,0.32,0.22]);
            app.EditPad.Position = app.childPos(app.PanelSettings.Position, [0.62,0.06,0.32,0.22]);

            app.PanelWindow.Position = app.childPos(figRect, [0.396,0.205,0.40,0.30]);
            app.CheckSedRate.Position = app.childPos(figRect, [0.405,0.515,0.34,0.075]);
            app.LabelSrMean.Position = app.childPos(app.PanelWindow.Position, [0.13,0.66,0.40,0.16]);
            app.EditSrMean.Position = app.childPos(app.PanelWindow.Position, [0.54,0.64,0.25,0.28]);
            app.LabelSrUnit.Position = app.childPos(app.PanelWindow.Position, [0.82,0.70,0.16,0.14]);
            app.LabelSmooth.Position = app.childPos(app.PanelWindow.Position, [0.13,0.24,0.40,0.16]);
            app.DropSmooth.Position = app.childPos(app.PanelWindow.Position, [0.55,0.30,0.40,0.20]);

            app.RunButton.Position = app.childPos(figRect, [0.825,0.255,0.13,0.225]);
            app.RefTextArea.Position = app.childPos(figRect, [0.04,0.04,0.92,0.13]);
        end

        function p = childPos(~, parentPos, rel)
            % Child controls in MATLAB are positioned in the parent's local
            % coordinate system, not in figure-global coordinates.
            p = [ ...
                rel(1) * parentPos(3), ...
                rel(2) * parentPos(4), ...
                rel(3) * parentPos(3), ...
                rel(4) * parentPos(4) ...
                ];
            p = round(p);
        end

        function updatePreviewPlot(app)
            dat = app.dat;
            if isempty(dat)
                return
            end

            try
                if isempty(app.spectralmomentsFig) || ~isgraphics(app.spectralmomentsFig)
                    error('Missing figure');
                end
                figure(app.spectralmomentsFig);
            catch
                app.spectralmomentsFig = figure('Color', 'w');
                set(app.spectralmomentsFig, 'Position', app.normalizedToPixelPosition([0.2,0.4,0.2,0.4]));
            end

            plot(dat(:,1), dat(:,2));
            xlabel(app.unit);
            ylabel('Value');
            title(app.dat_name, 'Interpreter', 'none');
            xlim([min(dat(:,1)), max(dat(:,1))]);
        end

        function onWindowChanged(app, ~, ~)
            app.window = str2double(app.EditWindow.Value);
        end

        function onStepChanged(app, ~, ~)
            app.step = str2double(app.EditStep.Value);
        end

        function onPadChanged(app, ~, ~)
            app.pad = str2double(app.EditPad.Value);
        end

        function onSrMeanChanged(app, ~, ~)
            app.srmean = str2double(app.EditSrMean.Value);
        end

        function onSedRateChanged(app, ~, ~)
            app.sedrate = double(app.CheckSedRate.Value);
            if app.CheckSedRate.Value
                app.EditSrMean.Enable = 'on';
                app.DropSmooth.Enable = 'on';
            else
                app.EditSrMean.Enable = 'off';
                app.DropSmooth.Enable = 'off';
                app.DropSmooth.Value = 1;
            end
            app.EditSrMean.Value = num2str(app.srmean);
        end

        function onPadEdgeChanged(app, ~, ~)
            app.dat = app.datbackup;
            if app.CheckPadEdge.Value
                app.DropPadType.Enable = 'on';
                dat = zeropad2(app.datbackup, app.window, app.padtype);
                app.pad = length(dat(:,1));
                app.EditPad.Value = num2str(app.pad);
                app.dat = dat;
            else
                app.DropPadType.Enable = 'off';
                app.pad = length(app.datbackup(:,1));
                app.EditPad.Value = num2str(app.pad);
            end
            app.updatePreviewPlot();
        end

        function onPadTypeChanged(app, ~, ~)
            app.padtype = app.DropPadType.Value;
            app.dat = zeropad2(app.datbackup, app.window, app.padtype);
            app.updatePreviewPlot();
        end

        function onSmoothChanged(app, ~, ~)
            app.smoothmodel = app.DropSmooth.Value;
        end

        function onRun(app, ~, ~)
            app.window = str2double(app.EditWindow.Value);
            app.step = str2double(app.EditStep.Value);
            app.pad = str2double(app.EditPad.Value);
            app.srmean = str2double(app.EditSrMean.Value);

            data = app.dat;
            window = app.window;
            step = app.step;
            pad = app.pad;
            srmean = app.srmean;

            switch app.smoothmodel
                case 1
                    smoothmodel = 'poly';
                case 2
                    smoothmodel = 'lowess';
                case 3
                    smoothmodel = 'rlowess';
                case 4
                    smoothmodel = 'loess';
                otherwise
                    smoothmodel = 'rloess';
            end

            hwarn = warndlg('Please wait, this may take a couple of minutes ...','Warning: Spectral Moments: slow process');

            if app.sedrate == 0
                [depth, uf, Bw] = spectralmoments(data, window, step, pad);
                figure;
                set(gcf, 'color', 'w');
                plot(depth, uf, 'r-', depth, Bw, 'b-.');
                xlabel(app.unit); ylabel('Frequency (cycles/m)'); legend('\mu_f', 'B');

                name1 = [app.dat_name, '-SpecMoments-depth-uf-bw-win', num2str(window), '.txt'];
                CDac_pwd;
                dlmwrite(name1, [depth, uf, Bw], 'delimiter', ' ', 'precision', 9);
                d = dir;
                set(app.listbox_acmain, 'String', {d.name}, 'Value', 1);
                app.refreshMainListbox();
                cd(pre_dirML);
            else
                [depth, uf, Bw, Bwtrend, sr] = spectralmoments(data, window, step, pad, srmean, smoothmodel, 0);
                figure;
                set(gcf, 'color', 'w');
                plot(depth, uf, 'r-', depth, Bw, 'b-.', depth, Bwtrend, 'g');
                xlabel(app.unit); ylabel('Frequency (cycles/m)'); legend('\mu_f', 'B', 'B trend');
                figure;
                set(gcf, 'color', 'w');
                plot(depth, sr); xlabel('Depth (m)'); ylabel('Sed. rate (cm/kyr)');

                name1 = [app.dat_name, '-SpecMoments-depth-uf-Bw-Btrend-win', num2str(window), '.txt'];
                name2 = [app.dat_name, '-SpecMoments-sedrate-win', num2str(window), smoothmodel, '-SR', num2str(srmean), '.txt'];
                CDac_pwd;
                dlmwrite(name1, [depth, uf, Bw, Bwtrend], 'delimiter', ' ', 'precision', 9);
                dlmwrite(name2, [depth, sr], 'delimiter', ' ', 'precision', 9);
                d = dir;
                set(app.listbox_acmain, 'String', {d.name}, 'Value', 1);
                app.refreshMainListbox();
                cd(pre_dirML);
            end
            try
                close(hwarn);
            catch
            end
        end

        function refreshMainListbox(app)
            pre = '<HTML><FONT color="blue">';
            post = '</FONT></HTML>';
            d = dir;
            if numel(d) >= 2
                d(1:2) = [];
            end

            address = pwd;
            if ~isempty(app.edit_acfigmain_dir) && isgraphics(app.edit_acfigmain_dir)
                set(app.edit_acfigmain_dir, 'String', address);
            end

            ac_pwd_str = which('ac_pwd.txt');
            if ~isempty(ac_pwd_str)
                [ac_pwd_dir, ~, ~] = fileparts(ac_pwd_str);
                fileID = fopen(fullfile(ac_pwd_dir, 'ac_pwd.txt'), 'w');
                if fileID ~= -1
                    fprintf(fileID, '%s', address);
                    fclose(fileID);
                end
            end

            if isempty(d)
                if ~isempty(app.listbox_acmain) && isgraphics(app.listbox_acmain)
                    set(app.listbox_acmain, 'String', {}, 'Value', []);
                end
                return
            end

            T = struct2table(d);
            switch app.val1
                case 1
                    sortedT = sortrows(T, 'name', 'ascend');
                case 2
                    sortedT = sortrows(T, 'name', 'descend');
                case 3
                    sortedT = sortrows(T, 'date', 'ascend');
                case 4
                    sortedT = sortrows(T, 'date', 'descend');
                case 5
                    sortedT = sortrows(T, 'bytes', 'ascend');
                case 6
                    sortedT = sortrows(T, 'bytes', 'descend');
                otherwise
                    sortedT = sortrows(T, 'name', 'ascend');
            end
            sd = table2struct(sortedT);

            listboxStr = cell(numel(sd), 1);
            for i = 1:numel(sd)
                if isdir(sd(i).name)
                    listboxStr{i} = [pre, sd(i).name, post];
                else
                    listboxStr{i} = sd(i).name;
                end
            end

            if ~isempty(app.listbox_acmain) && isgraphics(app.listbox_acmain)
                set(app.listbox_acmain, 'String', listboxStr, 'Value', []);
            end
        end

        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Acycle: Spectral Moments', ...
                'Color', app.UIBgColor, ...
                'Resize', 'on', ...
                'Position', app.normalizedToPixelPosition([0.5,0.5,0.4,0.28]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            if ismac
                app.UIFontSize = 12;
            elseif ispc
                app.UIFontSize = 8.0;
            else
                app.UIFontSize = 11;
            end

            app.PanelData = uipanel(app.UIFigure, 'Title', '', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelDataTitle = uilabel(app.UIFigure, 'Text', 'Data', 'FontSize', app.UIFontSize + 1, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelDataName = uilabel(app.PanelData, 'Text', 'data', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);
            app.CheckPadEdge = uicheckbox(app.PanelData, 'Text', 'Zero padding edge', 'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(s,e)app.onPadEdgeChanged(s,e));
            app.DropPadType = uidropdown(app.PanelData, ...
                'Items', {'zero', 'mirror', 'mean', 'random'}, ...
                'ItemsData', [1 2 3 4], ...
                'Value', 1, ...
                'Enable', 'off', ...
                'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(s,e)app.onPadTypeChanged(s,e));

            app.PanelSettings = uipanel(app.UIFigure, 'Title', 'Settings', 'FontSize', app.UIFontSize + 1, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelSettingsTitle = uilabel(app.UIFigure, 'Text', 'Settings', 'FontSize', app.UIFontSize + 1, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelWindow = uilabel(app.PanelSettings, 'Text', 'Window', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelStep = uilabel(app.PanelSettings, 'Text', 'step', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelPad = uilabel(app.PanelSettings, 'Text', 'Zero padding', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelWindow.HorizontalAlignment = 'center';
            app.LabelStep.HorizontalAlignment = 'center';
            app.LabelPad.HorizontalAlignment = 'center';

            app.EditWindow = uieditfield(app.PanelSettings, 'text', 'Value', '0', 'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(s,e)app.onWindowChanged(s,e));
            app.EditStep = uieditfield(app.PanelSettings, 'text', 'Value', '0', 'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(s,e)app.onStepChanged(s,e));
            app.EditPad = uieditfield(app.PanelSettings, 'text', 'Value', '0', 'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(s,e)app.onPadChanged(s,e));
            app.EditWindow.HorizontalAlignment = 'center';
            app.EditStep.HorizontalAlignment = 'center';
            app.EditPad.HorizontalAlignment = 'center';

            app.CheckSedRate = uicheckbox(app.UIFigure, 'Text', 'Absolute Sedimentation Rate', ...
                'FontSize', app.UIFontSize, 'Value', false, ...
                'ValueChangedFcn', @(s,e)app.onSedRateChanged(s,e));

            app.PanelWindow = uipanel(app.UIFigure, 'Title', '', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelSrMean = uilabel(app.PanelWindow, 'Text', 'Mean sed. rate', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);
            app.LabelSmooth = uilabel(app.PanelWindow, 'Text', 'Smooth model', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);
            app.EditSrMean = uieditfield(app.PanelWindow, 'text', 'Value', num2str(app.srmean), 'Enable', 'off', ...
                'FontSize', app.UIFontSize, 'ValueChangedFcn', @(s,e)app.onSrMeanChanged(s,e));
            app.DropSmooth = uidropdown(app.PanelWindow, ...
                'Items', {'Polynomial', 'LOWESS', 'rLOWESS', 'LOESS', 'rLOESS'}, ...
                'ItemsData', [1 2 3 4 5], ...
                'Value', 1, 'Enable', 'off', 'FontSize', app.UIFontSize, ...
                'ValueChangedFcn', @(s,e)app.onSmoothChanged(s,e));
            app.LabelSrUnit = uilabel(app.PanelWindow, 'Text', 'cm/kyr', 'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);

            app.RunButton = uibutton(app.UIFigure, 'push', 'Text', 'OK', ...
                'FontSize', app.UIFontSize, ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [0.08 0.02 0.95], ...
                'FontColor', [1 1 1], ...
                'ButtonPushedFcn', @(s,e)app.onRun(s,e));

            app.RefTextArea = uitextarea(app.UIFigure, ...
                'Value', { ...
                'Ref: Sinnesael, M., Zivanovic, M., De Vleeschouwer, D., & Claeys, P. (2018). Spectral moments in cyclostratigraphy:'; ...
                'Advantages and disadvantages compared to more classic approaches. Paleoceanography and Paleoclimatology, 33, 493-510.'; ...
                'doi: 10.1029/2017PA003293' ...
                }, ...
                'Editable', 'off', ...
                'FontSize', app.UIFontSize, ...
                'BackgroundColor', app.UIBgColor);

            app.applyLayout();
        end

        function initializeState(app)
            if isfield(app.Context, 'MonZoom')
                app.MonZoom = app.Context.MonZoom;
            end
            app.lang_choice = app.Context.lang_choice;
            app.lang_id = app.Context.lang_id;
            app.lang_var = app.Context.lang_var;

            app.unit = app.Context.unit;
            app.unit_type = app.Context.unit_type;
            app.slash_v = app.Context.slash_v;
            app.acfigmain = app.Context.acfigmain;

            app.filename = app.Context.data_name;
            app.dat_name = app.Context.dat_name;
            app.path_temp = app.Context.path_temp;
            app.listbox_acmain = app.Context.listbox_acmain;
            app.edit_acfigmain_dir = app.Context.edit_acfigmain_dir;
            if isfield(app.Context, 'val1')
                app.val1 = app.Context.val1;
            end

            dat = app.Context.current_data;
            diffx = diff(dat(:,1));
            if sum(diffx <= 0) > 0
                disp(app.getLang('a178', 'Input data not in ascending order; sorted automatically.'));
                dat = sortrows(dat);
            end
            if abs((max(diffx)-min(diffx))/2) > 10*eps('single')
                warndlg(app.getLang('ec25', 'Input data should be equally spaced.'));
            end

            datx = dat(:,1);
            npts = length(datx);
            dt = median(diff(dat(:,1)));

            app.window = 0.25 * abs(datx(end) - datx(1));
            app.step = dt;
            app.pad = npts;

            app.dat = dat;
            app.datbackup = dat;
            app.sedrate = 0;
            app.srmean = 5;
            app.smoothmodel = 1;
            app.padedge = 0;
            app.padtype = 1;

            app.LabelDataName.Text = app.dat_name;
            app.CheckPadEdge.Value = false;
            app.DropPadType.Value = 1;
            app.DropPadType.Enable = 'off';

            app.EditWindow.Value = num2str(app.window);
            app.EditStep.Value = num2str(app.step);
            app.EditPad.Value = num2str(app.pad);

            app.EditSrMean.Value = num2str(app.srmean);
            app.EditSrMean.Enable = 'off';
            app.DropSmooth.Value = 1;
            app.DropSmooth.Enable = 'off';

            app.UIFigure.Name = 'Acycle: Spectral Moments';
            app.LabelDataTitle.Text = app.getLang('main02', 'Data');
            app.CheckPadEdge.Text = app.getLang('specm04', 'Zero padding edge');
            app.PanelSettings.Title = app.getLang('specm05', 'Settings');
            app.LabelSettingsTitle.Visible = 'off';
            app.LabelWindow.Text = app.getLang('main41', 'Window');
            app.LabelStep.Text = app.getLang('main32', 'step');
            app.LabelPad.Text = app.getLang('dynot06', 'Zero padding');
            app.CheckSedRate.Text = app.getLang('specm01', 'Absolute Sedimentation Rate');
            app.LabelSrMean.Text = app.getLang('specm02', 'Mean sed. rate');
            app.LabelSmooth.Text = app.getLang('specm03', 'Smooth model');
            app.RunButton.Text = app.getLang('main00', 'OK');

            app.UIFigure.Position = app.normalizedToPixelPosition([0.5,0.5,0.4,0.28]);
            app.applyLayout();
            app.updatePreviewPlot();
        end
    end

    methods (Access = public)
        function app = SpectralMomentsGUI(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context, 'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('SpectralMomentsGUI requires a handles/context struct input.');
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
