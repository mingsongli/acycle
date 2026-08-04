classdef evofftGUI < matlab.apps.AppBase
    % App Designer style migration of legacy GUIDE evofftGUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure

        LabelMethod matlab.ui.control.Label
        DropMethod matlab.ui.control.DropDown

        PanelMain matlab.ui.container.Panel
        PanelFmax matlab.ui.container.Panel
        PanelStep matlab.ui.container.Panel
        PanelWindow matlab.ui.container.Panel
        PanelDim matlab.ui.container.Panel
        PanelCmap matlab.ui.container.Panel

        LabelFmin matlab.ui.control.Label
        EditFmin matlab.ui.control.EditField
        GroupFmax matlab.ui.container.ButtonGroup
        RadioNyquist matlab.ui.control.RadioButton
        RadioInput matlab.ui.control.RadioButton
        LabelNyquist matlab.ui.control.Label
        EditFmax matlab.ui.control.EditField

        EditStep matlab.ui.control.EditField
        ButtonStepTips matlab.ui.control.Button
        EditUnit matlab.ui.control.EditField
        LabelUnit matlab.ui.control.Label

        EditWindow matlab.ui.control.EditField
        ButtonWinTips matlab.ui.control.Button

        CheckPlotSeries matlab.ui.control.CheckBox
        CheckMTMRed matlab.ui.control.CheckBox
        CheckNormalize matlab.ui.control.CheckBox
        CheckFlipY matlab.ui.control.CheckBox
        CheckLogFreq matlab.ui.control.CheckBox
        CheckLogPower matlab.ui.control.CheckBox
        CheckXPadding matlab.ui.control.CheckBox

        GroupDim matlab.ui.container.ButtonGroup
        Radio2D matlab.ui.control.RadioButton
        Radio3D matlab.ui.control.RadioButton
        CheckRotation matlab.ui.control.CheckBox

        DropCmap matlab.ui.control.DropDown
        LabelGrid matlab.ui.control.Label
        EditGrid matlab.ui.control.EditField

        CheckSave matlab.ui.control.CheckBox
        ButtonOK matlab.ui.control.Button
        DropPadType matlab.ui.control.DropDown
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1

        lang_choice double = 0
        lang_id = {}
        lang_var = {}
        main_unit_selection double = 0

        listbox_acmain
        edit_acfigmain_dir

        current_data double = zeros(0,2)
        data_name char = ''
        filename char = ''
        unit char = 'unit'
        unit_type double = 0

        plot_2d double = 1
        plot_log double = 0
        freq_log double = 0
        normal double = 1
        flipy double = 0
        color char = 'parula'
        colorgrid = []

        mean_step double = 1
        step double = 1
        nyquist double = 0.5
        window double = 1
        rotate double = 0
        method char = 'Evolutionary FFT'
        lenthx double = 1
        time_0pad double = 1
        padtype double = 1
        fmingrid double = 0

        evofftfig = []

        UIBg double = [0.94 0.94 0.94]
        UIFontSize double = 11.5
        Blue double = [0.1137 0.0235 0.9725]
    end

    methods (Access = private)
        function txt = getLang(app, key, fallback)
            txt = fallback;
            if app.lang_choice <= 0 || isempty(app.lang_id) || isempty(app.lang_var)
                return
            end
            [~, idx] = ismember(key, app.lang_id);
            if idx > 0 && idx <= numel(app.lang_var)
                txt = app.lang_var{idx};
            end
        end

        function screenSize = getScreenSizePixels(~)
            oldUnits = get(groot,'Units');
            set(groot,'Units','pixels');
            screenSize = get(groot,'ScreenSize');
            set(groot,'Units',oldUnits);
        end

        function pos = normalizedToPixelPosition(app, normPos)
            screen = app.getScreenSizePixels();
            zoom = app.MonZoom;
            if isnumeric(zoom)
                if isscalar(zoom)
                    normPos = normPos * zoom;
                elseif numel(zoom) >= 4
                    normPos = normPos .* zoom(1:4);
                end
            end
            w = max(885, normPos(3) * screen(3));
            h = max(458, normPos(4) * screen(4));
            x = screen(1) + normPos(1) * screen(3);
            y = screen(2) + normPos(2) * screen(4);
            x = min(max(x,screen(1)), screen(1)+screen(3)-w);
            y = min(max(y,screen(2)), screen(2)+screen(4)-h);
            pos = round([x y w h]);
        end

        function p = childPos(~, parentPos, rel)
            p = round([rel(1)*parentPos(3), rel(2)*parentPos(4), rel(3)*parentPos(3), rel(4)*parentPos(4)]);
        end

        function createComponents(app)
            app.UIFigure = uifigure('Name','Acycle: Evolutionary Spectral Analysis', ...
                'Color',app.UIBg, 'Resize','on', ...
                'Position',app.normalizedToPixelPosition([0.45,0.4,0.3,0.2625]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();
            app.UIFigure.KeyPressFcn = @(src,evt)app.onKeyPress(src,evt);
            try
                app.UIFigure.WindowKeyPressFcn = @(src,evt)app.onKeyPress(src,evt);
            catch
            end

            app.LabelMethod = uilabel(app.UIFigure,'Text','Select method', ...
                'BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.DropMethod = uidropdown(app.UIFigure, ...
                'Items',{'Evolutionary FFT','Periodogram','Lomb-Scargle periodogram','Multi-taper method'}, ...
                'Value','Evolutionary FFT','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onMethodChanged());

            app.PanelMain = uipanel(app.UIFigure,'Title','Input for Evolutive FFT', ...
                'BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);

            app.PanelFmax = uipanel(app.PanelMain,'Title','Plot: Maximum Frequency', ...
                'BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.LabelFmin = uilabel(app.PanelFmax,'Text','Freq. min.','BackgroundColor',app.UIBg, ...
                'FontSize',app.UIFontSize,'FontColor',[0 0 0]);
            app.EditFmin = uieditfield(app.PanelFmax,'text','Value','0', ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+1,'ValueChangedFcn',@(~,~)app.onFminChanged());
            app.GroupFmax = uibuttongroup(app.PanelFmax,'BorderType','none','BackgroundColor',app.UIBg, ...
                'SelectionChangedFcn',@(~,~)app.onFmaxModeChanged());
            app.RadioNyquist = uiradiobutton(app.GroupFmax,'Text','Use Nyquist','Value',true,'FontSize',app.UIFontSize+1);
            app.RadioInput = uiradiobutton(app.GroupFmax,'Text','Use Input','FontSize',app.UIFontSize+1);
            app.LabelNyquist = uilabel(app.PanelFmax,'Text','0','BackgroundColor',app.UIBg, ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+1,'FontColor',[0.45 0.45 0.45]);
            app.EditFmax = uieditfield(app.PanelFmax,'text','Value','0', ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+1,'FontColor',app.Blue, ...
                'ValueChangedFcn',@(~,~)app.onFmaxEditChanged());

            app.PanelStep = uipanel(app.PanelMain,'Title','Step','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.EditStep = uieditfield(app.PanelStep,'text','HorizontalAlignment','center','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onStepChanged());
            app.ButtonStepTips = uibutton(app.PanelStep,'push','Text','Tips','FontSize',app.UIFontSize+2, ...
                'ButtonPushedFcn',@(~,~)app.onStepTips());
            app.EditUnit = uieditfield(app.PanelStep,'text','HorizontalAlignment','center','Editable','off', ...
                'FontSize',app.UIFontSize+1,'BackgroundColor',[1 1 1]);
            app.LabelUnit = uilabel(app.PanelStep,'Text','Unit','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+2);

            app.PanelWindow = uipanel(app.PanelMain,'Title','Sliding Window','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.EditWindow = uieditfield(app.PanelWindow,'text','Value','0','BackgroundColor',[1 1 1], ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+2,'FontWeight','bold','FontColor',app.Blue, ...
                'ValueChangedFcn',@(~,~)app.onWindowChanged());
            app.ButtonWinTips = uibutton(app.PanelWindow,'push','Text','Tips','FontSize',app.UIFontSize+2, ...
                'ButtonPushedFcn',@(~,~)app.onWindowTips());

            app.CheckPlotSeries = uicheckbox(app.PanelMain,'Text','Plot series','Value',true,'FontSize',app.UIFontSize+2);
            app.CheckMTMRed = uicheckbox(app.PanelMain,'Text','2pi MTM + red','Value',false,'FontSize',app.UIFontSize+2);
            app.CheckNormalize = uicheckbox(app.PanelMain,'Text','Normalize each window','Value',true,'FontSize',app.UIFontSize+2, ...
                'ValueChangedFcn',@(~,~)app.onNormalizeChanged());
            app.CheckFlipY = uicheckbox(app.PanelMain,'Text','Flip Y-axis','Value',false,'FontSize',app.UIFontSize+2, ...
                'ValueChangedFcn',@(~,~)app.onFlipYChanged());
            app.CheckLogFreq = uicheckbox(app.PanelMain,'Text','Log(frequency)','Value',false,'FontSize',app.UIFontSize+2, ...
                'ValueChangedFcn',@(~,~)app.onLogFreqChanged());
            app.CheckLogPower = uicheckbox(app.PanelMain,'Text','Log(power)','Value',false,'FontSize',app.UIFontSize+2, ...
                'ValueChangedFcn',@(~,~)app.onLogPowerChanged());
            app.CheckXPadding = uicheckbox(app.PanelMain,'Text','x padding','Value',true,'FontSize',app.UIFontSize+2, ...
                'ValueChangedFcn',@(~,~)app.onXPaddingChanged());

            app.DropPadType = uidropdown(app.PanelMain,'Items',{'zero','mirror','mean','random'}, ...
                'Value','zero','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onPadTypeChanged());

            app.PanelDim = uipanel(app.PanelMain,'Title','Plot-dimension','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.GroupDim = uibuttongroup(app.PanelDim,'BorderType','none','BackgroundColor',app.UIBg, ...
                'SelectionChangedFcn',@(~,~)app.onDimChanged());
            app.Radio2D = uiradiobutton(app.GroupDim,'Text','2D','Value',true,'FontSize',app.UIFontSize+2);
            app.Radio3D = uiradiobutton(app.GroupDim,'Text','3D','FontSize',app.UIFontSize+2);
            app.CheckRotation = uicheckbox(app.PanelDim,'Text','Rotation','Value',false,'FontSize',app.UIFontSize+2, ...
                'ValueChangedFcn',@(~,~)app.onRotationChanged());

            app.PanelCmap = uipanel(app.PanelMain,'Title','Colormap','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.DropCmap = uidropdown(app.PanelCmap, ...
                'Items',{'Default','parula','jet','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink','lines','colorcube','prism','flag','white'}, ...
                'FontSize',app.UIFontSize+1,'ValueChangedFcn',@(~,~)app.onCmapChanged());
            app.DropCmap.Value = 'Default';
            app.LabelGrid = uilabel(app.PanelCmap,'Text','Grid #','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+2);
            app.EditGrid = uieditfield(app.PanelCmap,'text','Value','', ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+1,'ValueChangedFcn',@(~,~)app.onGridChanged());

            app.CheckSave = uicheckbox(app.PanelMain,'Text','Save data','Value',false,'FontSize',app.UIFontSize+2);
            app.ButtonOK = uibutton(app.PanelMain,'push','Text','OK','FontSize',app.UIFontSize+4,'FontWeight','bold', ...
                'BackgroundColor',app.Blue,'FontColor',[1 1 1],'ButtonPushedFcn',@(~,~)app.onOK());

            app.applyLayout();
        end

        function applyLayout(app)
            r = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];

            app.LabelMethod.Position = app.childPos(r,[0.065,0.858,0.2,0.06]);
            app.DropMethod.Position = app.childPos(r,[0.267,0.858,0.66,0.06]);
            app.PanelMain.Position = app.childPos(r,[0.034,0.037,0.906,0.73]);

            pm = app.PanelMain.Position;
            app.PanelFmax.Position = app.childPos(pm,[0.03,0.54,0.454,0.35]);
            app.PanelStep.Position = app.childPos(pm,[0.496,0.545,0.239,0.345]);
            app.PanelWindow.Position = app.childPos(pm,[0.74,0.545,0.255,0.345]);

            pf = app.PanelFmax.Position;
            app.LabelFmin.Position = app.childPos(pf,[0.14,0.62,0.40,0.12]);
            app.EditFmin.Position = app.childPos(pf,[0.65,0.60,0.30,0.14]);
            app.GroupFmax.Position = app.childPos(pf,[0.10,0.08,0.42,0.44]);
            app.RadioNyquist.Position = app.childPos(app.GroupFmax.Position,[0.02,0.55,0.95,0.28]);
            app.RadioInput.Position = app.childPos(app.GroupFmax.Position,[0.02,0.11,0.95,0.28]);
            app.LabelNyquist.Position = app.childPos(pf,[0.63,0.35,0.30,0.14]);
            app.EditFmax.Position = app.childPos(pf,[0.64,0.10,0.31,0.22]);

            ps = app.PanelStep.Position;
            app.EditStep.Position = app.childPos(ps,[0.10,0.45,0.38,0.30]);
            app.ButtonStepTips.Position = app.childPos(ps,[0.54,0.50,0.36,0.24]);
            app.EditUnit.Position = app.childPos(ps,[0.10,0.14,0.38,0.30]);
            app.LabelUnit.Position = app.childPos(ps,[0.61,0.18,0.28,0.18]);

            pw = app.PanelWindow.Position;
            app.EditWindow.Position = app.childPos(pw,[0.13,0.47,0.72,0.30]);
            app.ButtonWinTips.Position = app.childPos(pw,[0.10,0.10,0.80,0.24]);

            app.CheckPlotSeries.Position = app.childPos(pm,[0.029,0.45,0.25,0.08]);
            app.CheckMTMRed.Position = app.childPos(pm,[0.029,0.35,0.25,0.08]);
            app.CheckNormalize.Position = app.childPos(pm,[0.293,0.45,0.36,0.1]);
            app.CheckFlipY.Position = app.childPos(pm,[0.293,0.35,0.36,0.1]);
            app.CheckLogFreq.Position = app.childPos(pm,[0.293,0.25,0.36,0.1]);
            app.CheckLogPower.Position = app.childPos(pm,[0.293,0.15,0.36,0.1]);
            app.CheckXPadding.Position = app.childPos(pm,[0.293,0.045,0.2,0.1]);
            app.DropPadType.Position = app.childPos(pm,[0.425,0.04,0.19,0.07]);

            app.PanelDim.Position = app.childPos(pm,[0.029,0.048,0.251,0.28]);
            pd = app.PanelDim.Position;
            app.GroupDim.Position = app.childPos(pd,[0.04,0.28,0.90,0.42]);
            app.Radio2D.Position = app.childPos(app.GroupDim.Position,[0.05,0.12,0.44,0.70]);
            app.Radio3D.Position = app.childPos(app.GroupDim.Position,[0.52,0.12,0.44,0.70]);
            app.CheckRotation.Position = app.childPos(pd,[0.06,0.04,0.84,0.20]);

            app.PanelCmap.Position = app.childPos(pm,[0.628,0.08,0.245,0.38]);
            pc = app.PanelCmap.Position;
            app.DropCmap.Position = app.childPos(pc,[0.06,0.64,0.84,0.17]);
            app.LabelGrid.Position = app.childPos(pc,[0.16,0.23,0.30,0.18]);
            app.EditGrid.Position = app.childPos(pc,[0.42,0.20,0.40,0.22]);

            app.CheckSave.Position = app.childPos(pm,[0.882,0.405,0.11,0.08]);
            app.ButtonOK.Position = app.childPos(pm,[0.888,0.082,0.108,0.20]);
        end

        function initializeState(app)
            c = app.Context;
            if isfield(c,'MonZoom'), app.MonZoom = c.MonZoom; end
            if isfield(c,'lang_choice'), app.lang_choice = c.lang_choice; end
            if isfield(c,'lang_id'), app.lang_id = c.lang_id; end
            if isfield(c,'lang_var'), app.lang_var = c.lang_var; end
            if isfield(c,'main_unit_selection'), app.main_unit_selection = c.main_unit_selection; end
            if isfield(c,'listbox_acmain'), app.listbox_acmain = c.listbox_acmain; end
            if isfield(c,'edit_acfigmain_dir'), app.edit_acfigmain_dir = c.edit_acfigmain_dir; end

            if isfield(c,'current_data'), app.current_data = c.current_data; end
            if isfield(c,'data_name'), app.data_name = c.data_name; end
            if isfield(c,'unit'), app.unit = c.unit; end
            if isfield(c,'unit_type'), app.unit_type = c.unit_type; end
            stepUnitLabel = app.unit;
            if isfield(c,'popupmenu1') && isgraphics(c.popupmenu1)
                unitItems = get(c.popupmenu1,'String');
                unitIndex = get(c.popupmenu1,'Value');
                if ischar(unitItems)
                    unitItems = cellstr(unitItems);
                elseif isstring(unitItems)
                    unitItems = cellstr(unitItems);
                end
                if iscell(unitItems) && unitIndex >= 1 && unitIndex <= numel(unitItems)
                    stepUnitLabel = char(unitItems{unitIndex});
                end
            end
            if isfield(c,'path_temp')
                % no-op; preserved for compatibility
            end
            [~,app.filename,~] = fileparts(app.data_name);

            app.UIFigure.Name = app.getLang('menu108','Acycle: Evolutionary Spectral Analysis');
            app.LabelMethod.Text = app.getLang('main49','Select method');
            app.PanelMain.Title = app.getLang('evofft01','Input for Evolutive FFT');
            app.PanelFmax.Title = app.getLang('evofft02','Plot: Maximum Frequency');
            app.LabelFmin.Text = app.getLang('evofft03','Freq. min.');
            app.RadioNyquist.Text = app.getLang('evofft04','Use Nyquist');
            app.RadioInput.Text = app.getLang('spectral14','Use Input');
            app.PanelStep.Title = app.getLang('main32','Step');
            app.ButtonStepTips.Text = app.getLang('main33','Tips');
            app.LabelUnit.Text = stepUnitLabel;
            app.PanelWindow.Title = app.getLang('main07','Sliding Window');
            app.CheckPlotSeries.Text = app.getLang('evofft05','Plot series');
            app.CheckMTMRed.Text = app.getLang('evofft06','2pi MTM + red');
            app.PanelDim.Title = app.getLang('evofft07','Plot-dimension');
            app.CheckRotation.Text = app.getLang('evofft08','Rotation');
            app.CheckNormalize.Text = app.getLang('evofft09','Normalize each window');
            app.CheckFlipY.Text = app.getLang('main10','Flip Y-axis');
            app.CheckLogPower.Text = app.getLang('evofft10','Log(power)');
            app.CheckLogFreq.Text = app.getLang('evofft11','Log(frequency)');
            app.CheckXPadding.Text = ['x ',app.getLang('main43','padding')];
            app.PanelCmap.Title = app.getLang('main50','Colormap');
            app.LabelGrid.Text = app.getLang('evofft12','Grid #');
            app.CheckSave.Text = app.getLang('main01','Save Data');
            app.ButtonOK.Text = app.getLang('main00','OK');

            if isempty(app.current_data) || size(app.current_data,2) < 2
                error('evofftGUI requires current_data in handles struct.');
            end

            data_s = app.current_data;
            diffx = diff(data_s(:,1));
            if acycleSamplingIsUneven(data_s(:,1))
                warndlg(app.getLang('evofft14','Not equally spaced data. Interpolated using mean sampling rate!'));
                interpolate_rate = mean(diffx);
                app.current_data = interpolate(data_s,interpolate_rate);
                data_s = app.current_data;
            end
            xmin = min(data_s(:,1));
            xmax = max(data_s(:,1));
            app.mean_step = median(diff(data_s(:,1)));
            app.step = app.mean_step;
            app.nyquist = 1/(2*app.mean_step);
            app.window = 0.2*(xmax-xmin);
            app.method = 'Evolutionary FFT';
            app.lenthx = xmax-xmin;
            app.time_0pad = 1;
            app.padtype = 1;

            ncal = (xmax-xmin - app.window)/app.mean_step;
            if ncal > 500
                app.step = abs(xmax - xmin - app.window)/500;
            end

            app.LabelNyquist.Text = num2str(app.nyquist);
            app.EditFmax.Value = num2str(app.nyquist);
            app.EditWindow.Value = num2str(app.window);
            app.EditFmin.Value = '0';
            app.EditUnit.Value = app.unit;
            app.EditStep.Value = num2str(app.step);
            app.DropMethod.Value = app.method;

            app.GroupFmax.SelectedObject = app.RadioNyquist;
            app.RadioNyquist.Enable = 'off';
            app.RadioInput.Enable = 'off';
            app.Radio2D.Value = true;
            app.Radio3D.Value = false;
            app.CheckRotation.Value = false;
            app.CheckNormalize.Value = true;
            app.CheckFlipY.Value = false;
            app.flipy = 0;
            app.CheckLogPower.Value = false;
            app.CheckLogFreq.Value = false;
            app.CheckXPadding.Value = true;
            app.DropCmap.Value = 'Default';
            app.EditGrid.Value = '';
            app.CheckSave.Value = false;

            app.onDimChanged();
        end

        function onMethodChanged(app)
            app.method = app.DropMethod.Value;
        end

        function onKeyPress(app,src,evt)
            try
                key = lower(string(evt.Key));
                mods = lower(string(evt.Modifier));
                isMacClose = key == "w" && any(mods == "command");
                isOtherClose = key == "w" && any(mods == "control");
                if isMacClose || isOtherClose
                    if ~isempty(app) && ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                        delete(app.UIFigure);
                    else
                        delete(src);
                    end
                end
            catch
            end
        end

        function onNormalizeChanged(app)
            app.normal = double(app.CheckNormalize.Value);
        end

        function onFlipYChanged(app)
            app.flipy = double(app.CheckFlipY.Value);
            app.applyAxisFlags();
        end

        function onLogPowerChanged(app)
            app.plot_log = double(app.CheckLogPower.Value);
        end

        function onLogFreqChanged(app)
            app.freq_log = double(app.CheckLogFreq.Value);
            if app.freq_log == 1
                if app.fmingrid > 0
                    app.EditFmin.Value = num2str(app.fmingrid);
                end
            end
            app.applyAxisFlags();
        end

        function onXPaddingChanged(app)
            app.time_0pad = double(app.CheckXPadding.Value);
        end

        function onPadTypeChanged(app)
            switch app.DropPadType.Value
                case 'zero'
                    app.padtype = 1;
                case 'mirror'
                    app.padtype = 2;
                case 'mean'
                    app.padtype = 3;
                case 'random'
                    app.padtype = 4;
            end
        end

        function onGridChanged(app)
            colorgrid = str2double(app.EditGrid.Value);
            if isnan(colorgrid) || colorgrid <= 0
                app.colorgrid = [];
            else
                app.colorgrid = colorgrid;
            end
            app.applyColormap();
        end

        function onCmapChanged(app)
            app.color = app.DropCmap.Value;
            if strcmp(app.color,'Default')
                app.EditGrid.Value = '';
                app.colorgrid = [];
            end
            app.applyColormap();
        end

        function onFmaxModeChanged(app)
            if app.GroupFmax.SelectedObject == app.RadioNyquist
                app.EditFmax.Value = num2str(app.nyquist);
            end
            app.applyAxisLimitsOnly();
        end

        function onFmaxEditChanged(app)
            app.GroupFmax.SelectedObject = app.RadioInput;
            app.applyAxisLimitsOnly();
        end

        function onFminChanged(app)
            app.applyAxisLimitsOnly();
        end

        function onStepChanged(app)
            app.step = str2double(app.EditStep.Value);
            if isnan(app.step) || app.step <= 0
                return
            end
            ncal = (app.lenthx - app.window)/app.step;
            if ncal > 500
                warndlg('Step is too small. Close this warning box and revise, OR come back after a cup of coffee ...');
            end
        end

        function onWindowChanged(app)
            newWindow = str2double(app.EditWindow.Value);
            if isnan(newWindow) || ~isfinite(newWindow) || newWindow <= 0 || newWindow > app.lenthx
                app.EditWindow.Value = num2str(app.window);
                errordlg(sprintf('Sliding window must be positive and no larger than %g.',app.lenthx));
                return
            end
            app.window = newWindow;
            ncal = (app.lenthx - app.window)/app.step;
            if ncal > 500
                warndlg('The selected window and step produce more than 500 sliding windows.');
            end
        end

        function onStepTips(app)
            warndlg(app.getLang('dd45','For long series, use larger step to reduce calculations.'), ...
                app.getLang('dd46','Tips: step'));
        end

        function onWindowTips(app)
            warndlg(app.getLang('evofft16','Window controls frequency resolution and temporal sensitivity.'), ...
                app.getLang('evofft15','Tips: window length'));
        end

        function onDimChanged(app)
            app.plot_2d = double(app.GroupDim.SelectedObject == app.Radio2D);
            if app.plot_2d == 1
                app.CheckMTMRed.Enable = 'on';
                app.CheckPlotSeries.Enable = 'on';
                app.CheckRotation.Value = false;
            else
                app.CheckMTMRed.Enable = 'off';
                app.CheckPlotSeries.Enable = 'off';
                app.CheckRotation.Value = true;
            end
            app.rotate = double(app.CheckRotation.Value);
        end

        function onRotationChanged(app)
            app.rotate = double(app.CheckRotation.Value);
        end

        function applyAxisLimitsOnly(app)
            try
                if isempty(app.evofftfig) || ~isvalid(app.evofftfig)
                    return
                end
                figure(app.evofftfig);
                fmin = str2double(app.EditFmin.Value);
                if isnan(fmin), fmin = 0; end
                fmax = app.getFmaxValue();
                axs = findobj(app.evofftfig,'Type','axes');
                for i = 1:numel(axs)
                    try
                        xlim(axs(i),[fmin fmax]);
                    catch
                    end
                end
            catch
            end
        end

        function applyAxisFlags(app)
            try
                if isempty(app.evofftfig) || ~isvalid(app.evofftfig)
                    return
                end
                axs = findobj(app.evofftfig,'Type','axes');
                for i = 1:numel(axs)
                    role = get(axs(i),'Tag');
                    isFrequencyAxis = any(strcmp(role,{'evofft-spectrum','evofft-top'}));
                    isDepthAxis = any(strcmp(role,{'evofft-spectrum','evofft-series'}));
                    if isFrequencyAxis && app.freq_log == 1
                        set(axs(i),'XScale','log');
                    elseif isFrequencyAxis
                        set(axs(i),'XScale','linear');
                    end
                    if isDepthAxis && app.flipy == 1
                        set(axs(i),'YDir','reverse');
                    elseif isDepthAxis
                        set(axs(i),'YDir','normal');
                    end
                end
            catch
            end
        end

        function applyColormap(app)
            try
                if isempty(app.evofftfig) || ~isvalid(app.evofftfig)
                    return
                end
                figure(app.evofftfig);
                if isempty(app.colorgrid)
                    setcolor = app.color;
                else
                    setcolor = [app.color,'(',round(num2str(app.colorgrid)),')'];
                end
                try
                    colormap(setcolor);
                catch
                    colormap default;
                end
            catch
            end
        end

        function fmax = getFmaxValue(app)
            if app.GroupFmax.SelectedObject == app.RadioNyquist
                fmax = app.nyquist;
            else
                fmax = str2double(app.EditFmax.Value);
                if isnan(fmax) || fmax <= 0
                    fmax = app.nyquist;
                end
            end
        end

        function onOK(app)
            data = app.current_data;
            dataraw = data;
            window = str2double(app.EditWindow.Value);
            if isnan(window) || ~isfinite(window) || window <= 0 || window > app.lenthx
                errordlg(sprintf('Sliding window must be positive and no larger than %g.',app.lenthx));
                app.EditWindow.Value = num2str(app.window);
                return
            end
            app.window = window;
            step = str2double(app.EditStep.Value);
            if isnan(step) || step <= 0
                errordlg('Step must be positive.');
                return
            end
            fmax = app.getFmaxValue();
            fmin = str2double(app.EditFmin.Value);
            if isnan(fmin), fmin = 0; end
            unit = app.EditUnit.Value;
            if isempty(unit), unit = app.unit; end

            if app.time_0pad == 1
                data = zeropad2(data,window,app.padtype);
            else
                data(:,2) = data(:,2) - mean(data(:,2));
            end

            if strcmp(app.method,'Periodogram')
                [s,x_grid,y_grid] = evoperiodogram(data,window,step,fmin,app.nyquist,app.normal);
            elseif strcmp(app.method,'Lomb-Scargle periodogram')
                [s,x_grid,y_grid] = evoplomb(data,window,step,fmin,app.nyquist,app.normal);
            elseif strcmp(app.method,'Multi-taper method')
                [s,x_grid,y_grid] = evopmtm(data,window,step,fmin,app.nyquist,app.normal);
            else
                dt = data(2,1)-data(1,1);
                [s,x_grid,y_grid] = evofft(data,window,step,dt,fmin,app.nyquist,app.normal);
            end
            if numel(x_grid) > 1
                app.fmingrid = x_grid(2)-x_grid(1);
            end

            assignin('base','s',s);
            assignin('base','x',x_grid);
            assignin('base','y',y_grid);

            evofig = figure;
            set(evofig,'Color','white');
            app.evofftfig = evofig;

            % language labels
            l_power = app.getLang('spectral30','Power');
            l_rar1 = app.getLang('spectral06','Robust AR(1)');
            l_median = app.getLang('main40','median');
            l_freq = app.getLang('main14','Frequency');
            l_unit = app.getLang('main34','Unit');
            l_depth = app.getLang('main23','Depth');
            l_time = app.getLang('main21','Time');
            l_title = app.getLang('menu108','Evolutionary Spectral Analysis');
            l_window = app.getLang('main41','Window');
            l_step = app.getLang('main32','Step');

            MTMred = app.CheckMTMRed.Value;
            plotseries = app.CheckPlotSeries.Value;
            plot2d = app.Radio2D.Value;
            rotateNow = app.CheckRotation.Value;
            axSeries = [];
            axRight = [];
            axTop = [];

            if plot2d == 1
                if MTMred && ~plotseries
                    dt = median(diff(data(:,1)));
                    nfft = length(data(:,1));
                    [~,~,~,redconf] = redconfML(data(:,2),dt,2,5*nfft,2,0.25,fmax,0);
                    subplot(4,1,1);
                    axTop = gca;
                    if app.plot_log == 1
                        semilogy(redconf(:,1),redconf(:,2),'k'); hold on;
                        semilogy(redconf(:,1),redconf(:,3),'m-.');
                        semilogy(redconf(:,1),redconf(:,5),'r--','LineWidth',2);
                        semilogy(redconf(:,1),redconf(:,6),'b-.');
                    else
                        plot(redconf(:,1),redconf(:,2),'k'); hold on;
                        plot(redconf(:,1),redconf(:,3),'m-.');
                        plot(redconf(:,1),redconf(:,5),'r--','LineWidth',2);
                        plot(redconf(:,1),redconf(:,6),'b-.');
                        ylabel(l_power);
                        legend(l_power,[l_rar1,' ',l_median],[l_rar1,' 95%'],[l_rar1,' 99%']);
                    end
                    xlim([fmin fmax]);

                    subplot(4,1,[2 3 4]);
                    axRight = gca;
                    if app.plot_log == 0
                        pcolor(x_grid,y_grid,s);
                    else
                        pcolor(x_grid(2:end),y_grid,log10(s(:,2:end)));
                    end
                    shading interp;
                    xlim([fmin fmax]);
                    xlabel([l_freq,' (1/',unit,')']);
                elseif MTMred && plotseries
                    dt = median(diff(dataraw(:,1)));
                    nfft = length(dataraw(:,1));
                    [~,~,~,redconf] = redconfML(data(:,2),dt,2,5*nfft,2,0.25,fmax,0);
                    subplot(4,4,[2 3 4]);
                    axTop = gca;
                    if app.plot_log == 1
                        semilogy(redconf(:,1),redconf(:,2),'k'); hold on;
                        semilogy(redconf(:,1),redconf(:,3),'m-.');
                        semilogy(redconf(:,1),redconf(:,5),'r--','LineWidth',2);
                        semilogy(redconf(:,1),redconf(:,6),'b-.');
                    else
                        plot(redconf(:,1),redconf(:,2),'k'); hold on;
                        plot(redconf(:,1),redconf(:,3),'m-.');
                        plot(redconf(:,1),redconf(:,5),'r--','LineWidth',2);
                        plot(redconf(:,1),redconf(:,6),'b-.');
                        ylabel(l_power);
                    end
                    xlim([fmin fmax]);

                    subplot(4,4,[5 9 13]);
                    axSeries = gca;
                    plot(dataraw(:,2),dataraw(:,1),'k');
                    ylim([dataraw(1,1) dataraw(end,1)]);
                    xlim([min(dataraw(:,2)) max(dataraw(:,2))]);

                    subplot(4,4,[6,7,8,10,11,12,14,15,16]);
                    axRight = gca;
                    if app.plot_log == 0
                        pcolor(x_grid,y_grid,s);
                    else
                        pcolor(x_grid,y_grid,log10(s));
                    end
                    shading interp;
                    ylim([dataraw(1,1) dataraw(end,1)]);
                    xlim([fmin fmax]);
                    xlabel([l_freq,' (1/',unit,')']);
                elseif ~MTMred && plotseries
                    subplot(1,4,1);
                    axSeries = gca;
                    plot(dataraw(:,2),dataraw(:,1),'k');
                    ylim([dataraw(1,1) dataraw(end,1)]);
                    xlim([min(dataraw(:,2)) max(dataraw(:,2))]);

                    subplot(1,4,[2 3 4]);
                    axRight = gca;
                    if app.plot_log == 0
                        pcolor(x_grid,y_grid,s);
                    else
                        pcolor(x_grid(2:end),y_grid,log10(s(:,2:end)));
                    end
                    shading interp;
                    xlabel([l_freq,' (1/',unit,')']);
                    xlim([fmin fmax]);
                    ylim([dataraw(1,1) dataraw(end,1)]);
                else
                    axRight = gca;
                    if app.plot_log == 0
                        pcolor(x_grid,y_grid,s);
                    else
                        pcolor(x_grid(2:end),y_grid,log10(s(:,2:end)));
                    end
                    shading interp;
                    xlabel([l_freq,' (1/',unit,')']);
                    xlim([fmin fmax]);
                end

                if or(app.lang_choice == 0, app.main_unit_selection == 0)
                    if app.unit_type == 0
                        yLabelText = ['Unit (',app.unit,')'];
                    elseif app.unit_type == 1
                        yLabelText = ['Depth (',app.unit,')'];
                    else
                        yLabelText = ['Time (',app.unit,')'];
                    end
                else
                    if app.unit_type == 0
                        yLabelText = [l_unit,' (',app.unit,')'];
                    elseif app.unit_type == 1
                        yLabelText = [l_depth,' (',app.unit,')'];
                    else
                        yLabelText = [l_time,' (',app.unit,')'];
                    end
                end

                plotTitle = [app.method,'; ',l_window,' = ',num2str(window),' ',unit,'; ',l_step,' = ',num2str(step),' ',unit];
                if plotseries && isgraphics(axSeries,'axes')
                    ylabel(axSeries,yLabelText);
                    if isgraphics(axRight,'axes')
                        ylabel(axRight,'');
                    end
                elseif isgraphics(axRight,'axes')
                    ylabel(axRight,yLabelText);
                end

                if MTMred && isgraphics(axTop,'axes')
                    title(axTop,plotTitle);
                    if isgraphics(axRight,'axes')
                        title(axRight,'');
                    end
                elseif isgraphics(axRight,'axes')
                    title(axRight,plotTitle);
                end
            else
                if app.plot_log == 1
                    surf(x_grid(2:end),y_grid,log10(s(:,2:end)));
                else
                    surf(x_grid,y_grid,s);
                end
                ax3d = gca;
                shading interp;
                xlabel([l_freq,' (1/',unit,')']);
                xlim([fmin fmax]);
                if ~rotateNow
                    if isgraphics(ax3d,'axes')
                        view(ax3d,10,70);
                    end
                else
                    for i = 1:360
                        if ~isvalid(evofig) || ~isgraphics(ax3d,'axes')
                            return
                        end
                        view(ax3d,i,70);
                        drawnow;
                    end
                end
            end

            if isgraphics(axTop,'axes'), set(axTop,'Tag','evofft-top'); end
            if isgraphics(axSeries,'axes'), set(axSeries,'Tag','evofft-series'); end
            if isgraphics(axRight,'axes'), set(axRight,'Tag','evofft-spectrum'); end
            if exist('ax3d','var') && isgraphics(ax3d,'axes')
                set(ax3d,'Tag','evofft-spectrum');
            end

            if ~isvalid(evofig)
                return
            end
            figure(evofig);
            if app.freq_log == 1 && app.fmingrid > 0 && isgraphics(axRight,'axes')
                xlim(axRight,[app.fmingrid fmax]);
            end
            app.applyAxisFlags();
            set(gca,'TickDir','out');
            set(gca,'XMinorTick','on','YMinorTick','on');

            app.applyColormap();
            set(gcf,'Name',[app.filename,': ',l_title]);

            if app.CheckSave.Value
                pre_dirML = pwd;
                CDac_pwd;
                cleanupObj = onCleanup(@()cd(pre_dirML));
                outputFile = app.nextIndexedFile( ...
                    [app.filename,'-evofft'],'.xlsx');
                params = app.buildEvofftParameterTable( ...
                    fmin,fmax,window,step,outputFile,s,x_grid,y_grid);
                redNoiseResult = [];
                if exist('redconf','var') && isnumeric(redconf)
                    redNoiseResult = redconf;
                end
                saveEvofftWorkbook( ...
                    outputFile,params,s,x_grid,y_grid,redNoiseResult);
                fprintf('>> saved evolutionary spectrum: %s\n',outputFile);
                ac_refresh_main_list(app.listbox_acmain,pwd);
            end
        end

        function params = buildEvofftParameterTable( ...
                app,fmin,fmax,window,step,outputFile,s,xGrid,yGrid)
            params = repmat({''},29,6);
            params(1,2) = {'Detailed Parameters Used in Data Processing by Acycle'};
            params(2,2:6) = {'Version','Designed by','Institute','E-mail','Date'};
            params(3,2:6) = {'v1.1','Mingsong Li','Peking University','msli@pku.edu.cn',datestr(now,'yyyy-mm-dd HH:MM:SS')};
            params(5,2:5) = {'Tools','Items','Parameters','Explanations'};

            [~,inputBase,inputExt] = fileparts(app.data_name);
            params(7,:) = {'','Evolutionary FFT','Input file name',[inputBase,inputExt],'',''};
            params(8,:) = {'','','Method',app.method,'',''};
            params(9,:) = {'','','Frequency minimum',fmin,'',''};
            params(10,:) = {'','','Displayed frequency maximum',fmax,'',''};
            params(11,:) = {'','','Sliding window size',window,'',''};
            params(12,:) = {'','','Sliding window step',step,'',''};
            params(13,:) = {'','','Normalize each window',app.yesNo(app.CheckNormalize.Value),'Select Yes or No',''};
            params(14,:) = {'','','Plot input series',app.yesNo(app.CheckPlotSeries.Value),'Display only',''};
            params(15,:) = {'','','MTM red-noise overlay',app.yesNo(app.CheckMTMRed.Value),'Display only',''};
            params(16,:) = {'','','Log(frequency)',app.yesNo(app.CheckLogFreq.Value),'Display only',''};
            params(17,:) = {'','','Log(power)',app.yesNo(app.CheckLogPower.Value),'Display only',''};
            params(18,:) = {'','','Flip Y axis',app.yesNo(app.CheckFlipY.Value),'Display only',''};
            params(19,:) = {'','','Plot dimension',app.plotDimensionName(),'2D or 3D',''};
            params(20,:) = {'','','Rotation',app.yesNo(app.CheckRotation.Value),'3D display only',''};
            params(21,:) = {'','','X padding',app.yesNo(app.CheckXPadding.Value),'Select Yes or No',''};
            params(22,:) = {'','','Padding edge method',app.padMethodName(),'Select zero/mirror/mean/random',''};
            params(23,:) = {'','','Colormap',app.DropCmap.Value,'Display only',''};
            params(24,:) = {'','','Grid number',app.naIfEmpty(app.EditGrid.Value),'Display only',''};
            params(25,:) = {'','','Input unit',app.EditUnit.Value,'',''};
            params(26,:) = {'','','Calculation frequency maximum',app.nyquist,'Nyquist frequency',''};
            params(27,:) = {'','','Output workbook',outputFile,'',''};
            params(28,:) = {'','','Power matrix size',mat2str(size(s)),'Rows=time; columns=frequency',''};
            params(29,:) = {'','','Frequency / time coordinates', ...
                sprintf('%d / %d',numel(xGrid),numel(yGrid)), ...
                'Stored in separate sheets',''};
        end

        function filename = nextIndexedFile(~, baseName, ext)
            for ii = 1:9999
                filename = sprintf('%s-%d%s',baseName,ii,ext);
                if ~exist(filename,'file')
                    return
                end
            end
            filename = sprintf('%s-%s%s',baseName,datestr(now,'yyyymmddTHHMMSS'),ext);
        end

        function s = padMethodName(app)
            if app.CheckXPadding.Value
                s = app.DropPadType.Value;
            else
                s = 'No';
            end
        end

        function s = plotDimensionName(app)
            if app.Radio2D.Value
                s = '2D';
            else
                s = '3D';
            end
        end

        function s = yesNo(~, tf)
            if tf
                s = 'Yes';
            else
                s = 'No';
            end
        end

        function s = naIfEmpty(~, v)
            s = strtrim(char(v));
            if isempty(s)
                s = 'NA';
            end
        end
    end

    methods (Access = public)
        function app = evofftGUI(varargin)
            if nargin >= 1 && isstruct(varargin{1})
                app.Context = varargin{1};
            end
            createComponents(app);
            initializeState(app);
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
