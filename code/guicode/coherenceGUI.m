classdef coherenceGUI < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE coherenceGUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure

        EditPath matlab.ui.control.EditField
        ListFiles matlab.ui.control.ListBox
        ButtonRef matlab.ui.control.Button
        ButtonSeries matlab.ui.control.Button

        LabelReference matlab.ui.control.Label
        EditReference matlab.ui.control.EditField
        LabelSeries matlab.ui.control.Label
        ListSeries matlab.ui.control.ListBox

        LabelDepthTime matlab.ui.control.Label
        DropDepthTime matlab.ui.control.DropDown

        PanelParams matlab.ui.container.Panel
        LabelMethod matlab.ui.control.Label
        DropMethod matlab.ui.control.DropDown

        LabelCohP matlab.ui.control.Label
        EditCohP matlab.ui.control.EditField

        LabelWindow matlab.ui.control.Label
        EditWindow matlab.ui.control.EditField
        LabelUnit1 matlab.ui.control.Label

        LabelOverlap matlab.ui.control.Label
        EditOverlap matlab.ui.control.EditField
        LabelUnit2 matlab.ui.control.Label

        PanelXRange matlab.ui.container.ButtonGroup
        RadioFreq matlab.ui.control.RadioButton
        RadioPeriod matlab.ui.control.RadioButton
        LabelFrom matlab.ui.control.Label
        LabelTo matlab.ui.control.Label
        EditFrom matlab.ui.control.EditField
        EditTo matlab.ui.control.EditField

        LabelPlotStyle matlab.ui.control.Label
        CheckPlotCoh matlab.ui.control.CheckBox
        CheckPlotPhase matlab.ui.control.CheckBox
        PreviewAxes matlab.ui.control.UIAxes
        PreviewPolar matlab.graphics.axis.PolarAxes

        CheckSave matlab.ui.control.CheckBox
        ButtonRun matlab.ui.control.Button
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1
        val1 double = 1

        acfigmain
        listbox_acmain
        edit_acfigmain_dir
        unit char = ''

        lang_choice double = 0
        lang_id = {}
        lang_var = {}

        workingDir char = ''
        fileList cell = {}
        selectedFileIndices = []

        targetName char = ''
        seriesNames cell = {}

        subfigure
        polarfigure

        UIColorBg double = [0.94 0.94 0.94]
        UIColorBlue double = [0.08 0.02 0.95]
        UIFontSize double = 11.5
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
            w = max(1160, normPos(3)*screen(3));
            h = max(576, normPos(4)*screen(4));
            x = screen(1) + normPos(1)*screen(3);
            y = screen(2) + normPos(2)*screen(4);
            x = min(max(x,screen(1)), screen(1)+screen(3)-w);
            y = min(max(y,screen(2)), screen(2)+screen(4)-h);
            pos = round([x y w h]);
        end

        function p = childPos(~, parentPos, rel)
            p = round([rel(1)*parentPos(3), rel(2)*parentPos(4), rel(3)*parentPos(3), rel(4)*parentPos(4)]);
        end

        function createComponents(app)
            app.UIFigure = uifigure('Name','Acycle: Coherence & Phase Analysis', ...
                'Color',app.UIColorBg, ...
                'Resize','on', ...
                'Position',app.normalizedToPixelPosition([0.03,0.03,0.56,0.32]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.EditPath = uieditfield(app.UIFigure,'text','BackgroundColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'ValueChangedFcn',@(~,~)app.onPathChanged());
            app.ListFiles = uilistbox(app.UIFigure,'Multiselect','on', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onListFilesChanged());
            app.ButtonRef = uibutton(app.UIFigure,'push','Text','==>', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onAddReference());
            app.ButtonSeries = uibutton(app.UIFigure,'push','Text','==>', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onAddSeries());

            app.LabelReference = uilabel(app.UIFigure,'Text','Reference', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditReference = uieditfield(app.UIFigure,'text','Editable','off', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);

            app.LabelSeries = uilabel(app.UIFigure,'Text','Series', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.ListSeries = uilistbox(app.UIFigure,'BackgroundColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1);

            app.LabelDepthTime = uilabel(app.UIFigure,'Text','Depth/Time', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.DropDepthTime = uidropdown(app.UIFigure,'Items',{'Small=Young','Small=Old'}, ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.safeUpdate());

            app.PanelParams = uipanel(app.UIFigure,'Title','Parameters', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');

            app.LabelMethod = uilabel(app.PanelParams,'Text','Method', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.DropMethod = uidropdown(app.PanelParams,'Items',{'Welch'}, ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.safeUpdate());

            app.LabelCohP = uilabel(app.PanelParams,'Text','Coherence p-value', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue);
            app.EditCohP = uieditfield(app.PanelParams,'text','Value','0.05', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'HorizontalAlignment','center','FontColor',app.UIColorBlue, ...
                'ValueChangedFcn',@(~,~)app.onCohPChanged());

            app.LabelWindow = uilabel(app.PanelParams,'Text','Window size', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditWindow = uieditfield(app.PanelParams,'text','Value','', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'HorizontalAlignment','center','ValueChangedFcn',@(~,~)app.safeUpdate());
            app.LabelUnit1 = uilabel(app.PanelParams,'Text','unit', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);

            app.LabelOverlap = uilabel(app.PanelParams,'Text','Number of overlap', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditOverlap = uieditfield(app.PanelParams,'text','Value','', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'HorizontalAlignment','center','ValueChangedFcn',@(~,~)app.safeUpdate());
            app.LabelUnit2 = uilabel(app.PanelParams,'Text','unit', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);

            app.PanelXRange = uibuttongroup(app.PanelParams,'Title','Plot X range', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1, ...
                'SelectionChangedFcn',@(~,~)app.onRangeModeChanged());
            app.RadioFreq = uiradiobutton(app.PanelXRange,'Text','Frequency', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'Value',true);
            app.RadioPeriod = uiradiobutton(app.PanelXRange,'Text','Period', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'Value',false);
            app.LabelFrom = uilabel(app.PanelXRange,'Text','From', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue);
            app.LabelTo = uilabel(app.PanelXRange,'Text','To', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue);
            app.EditFrom = uieditfield(app.PanelXRange,'text','Value','0', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'HorizontalAlignment','center','FontColor',app.UIColorBlue, ...
                'ValueChangedFcn',@(~,~)app.safeUpdate());
            app.EditTo = uieditfield(app.PanelXRange,'text','Value','0', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'HorizontalAlignment','center','FontColor',app.UIColorBlue, ...
                'ValueChangedFcn',@(~,~)app.safeUpdate());

            app.LabelPlotStyle = uilabel(app.PanelParams,'Text','Plot Style', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');
            app.CheckPlotCoh = uicheckbox(app.PanelParams,'Text','', ...
                'Value',true,'ValueChangedFcn',@(~,~)app.safeUpdate());
            app.CheckPlotPhase = uicheckbox(app.PanelParams,'Text','', ...
                'Value',true,'ValueChangedFcn',@(~,~)app.safeUpdate());

            app.PreviewAxes = uiaxes(app.PanelParams);
            app.PreviewAxes.Box = 'on';
            app.PreviewAxes.XMinorTick = 'on';
            app.PreviewAxes.YMinorTick = 'on';

            app.PreviewPolar = polaraxes('Parent',app.PanelParams);
            app.PreviewPolar.Units = 'pixels';

            app.CheckSave = uicheckbox(app.UIFigure,'Text','Save Data', ...
                'Value',true,'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue);
            app.ButtonRun = uibutton(app.UIFigure,'push','Text','Coherence Plot', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+2,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onRun());

            app.applyLayout();
        end

        function applyLayout(app)
            fr = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];

            app.EditPath.Position = app.childPos(fr,[0.018,0.858,0.454,0.06]);
            app.ListFiles.Position = app.childPos(fr,[0.018,0.426,0.454,0.432]);
            app.ButtonRef.Position = app.childPos(fr,[0.496,0.776,0.06,0.06]);
            app.ButtonSeries.Position = app.childPos(fr,[0.496,0.653,0.06,0.06]);

            app.LabelReference.Position = app.childPos(fr,[0.586,0.84,0.12,0.05]);
            app.EditReference.Position = app.childPos(fr,[0.58,0.778,0.404,0.06]);
            app.LabelSeries.Position = app.childPos(fr,[0.586,0.724,0.074,0.05]);
            app.ListSeries.Position = app.childPos(fr,[0.58,0.426,0.404,0.29]);

            app.LabelDepthTime.Position = app.childPos(fr,[0.49,0.51,0.09,0.05]);
            app.DropDepthTime.Position = app.childPos(fr,[0.485,0.45,0.088,0.05]);

            app.PanelParams.Position = app.childPos(fr,[0.016,0.037,0.84,0.366]);

            app.LabelMethod.Position = app.childPos(app.PanelParams.Position,[0.012,0.76,0.089,0.14]);
            app.DropMethod.Position = app.childPos(app.PanelParams.Position,[0.111,0.70,0.21,0.125]);

            app.LabelCohP.Position = app.childPos(app.PanelParams.Position,[0.012,0.553,0.173,0.15]);
            app.EditCohP.Position = app.childPos(app.PanelParams.Position,[0.215,0.493,0.089,0.188]);

            app.LabelWindow.Position = app.childPos(app.PanelParams.Position,[0.012,0.308,0.16,0.15]);
            app.EditWindow.Position = app.childPos(app.PanelParams.Position,[0.185,0.282,0.12,0.188]);
            app.LabelUnit1.Position = app.childPos(app.PanelParams.Position,[0.316,0.333,0.089,0.15]);

            app.LabelOverlap.Position = app.childPos(app.PanelParams.Position,[0.012,0.125,0.19,0.15]);
            app.EditOverlap.Position = app.childPos(app.PanelParams.Position,[0.185,0.057,0.12,0.188]);
            app.LabelUnit2.Position = app.childPos(app.PanelParams.Position,[0.316,0.108,0.089,0.15]);

            app.PanelXRange.Position = app.childPos(app.PanelParams.Position,[0.362,0.07,0.193,0.78]);
            app.RadioFreq.Position = app.childPos(app.PanelXRange.Position,[0.064,0.67,0.862,0.22]);
            app.RadioPeriod.Position = app.childPos(app.PanelXRange.Position,[0.064,0.46,0.862,0.22]);
            app.LabelFrom.Position = app.childPos(app.PanelXRange.Position,[0.119,0.27,0.339,0.18]);
            app.LabelTo.Position = app.childPos(app.PanelXRange.Position,[0.119,0.08,0.339,0.18]);
            app.EditFrom.Position = app.childPos(app.PanelXRange.Position,[0.514,0.28,0.44,0.20]);
            app.EditTo.Position = app.childPos(app.PanelXRange.Position,[0.514,0.03,0.44,0.20]);

            app.LabelPlotStyle.Position = app.childPos(app.PanelParams.Position,[0.576,0.79,0.18,0.12]);
            app.CheckPlotCoh.Position = app.childPos(app.PanelParams.Position,[0.576,0.63,0.022,0.18]);
            app.CheckPlotPhase.Position = app.childPos(app.PanelParams.Position,[0.788,0.63,0.03,0.18]);
            app.PreviewAxes.Position = app.childPos(app.PanelParams.Position,[0.603,0.16,0.166,0.56]);
            app.PreviewPolar.Position = app.childPos(app.PanelParams.Position,[0.814,0.16,0.166,0.56]);

            app.CheckSave.Position = app.childPos(fr,[0.86,0.25,0.12,0.15]);
            app.ButtonRun.Position = app.childPos(fr,[0.86,0.05,0.12,0.15]);
        end

        function initializeState(app)
            c = app.Context;
            if isfield(c,'acfigmain'), app.acfigmain = c.acfigmain; end
            if isfield(c,'listbox_acmain'), app.listbox_acmain = c.listbox_acmain; end
            if isfield(c,'edit_acfigmain_dir'), app.edit_acfigmain_dir = c.edit_acfigmain_dir; end
            if isfield(c,'unit'), app.unit = c.unit; end
            if isfield(c,'MonZoom'), app.MonZoom = c.MonZoom; end
            if isfield(c,'val1'), app.val1 = c.val1; end
            if isfield(c,'lang_choice'), app.lang_choice = c.lang_choice; end
            if isfield(c,'lang_id'), app.lang_id = c.lang_id; end
            if isfield(c,'lang_var'), app.lang_var = c.lang_var; end

            app.UIFigure.Name = app.getLang('c30','Acycle: Coherence & Phase Analysis');
            app.LabelReference.Text = app.getLang('main11','Reference');
            app.LabelSeries.Text = app.getLang('c32','Series');
            app.LabelDepthTime.Text = app.getLang('c33','Depth/Time');
            app.DropDepthTime.Items = {app.getLang('c34','Small=Young'), app.getLang('c35','Small=Old')};
            app.PanelParams.Title = app.getLang('c36','Parameters');
            app.LabelMethod.Text = app.getLang('c37','Method');
            app.LabelCohP.Text = app.getLang('c38','Coherence p-value');
            app.LabelWindow.Text = app.getLang('c39','Window size');
            app.LabelOverlap.Text = app.getLang('c40','Number of overlap');
            app.PanelXRange.Title = app.getLang('c41','Plot X range');
            app.RadioFreq.Text = app.getLang('main14','Frequency');
            app.RadioPeriod.Text = app.getLang('main15','Period');
            app.LabelFrom.Text = app.getLang('main16','From');
            app.LabelTo.Text = app.getLang('main17','To');
            app.LabelPlotStyle.Text = app.getLang('c46','Plot Style');
            app.CheckSave.Text = app.getLang('main01','Save Data');
            app.ButtonRun.Text = app.getLang('c48','Coherence Plot');

            app.LabelUnit1.Text = app.unit;
            app.LabelUnit2.Text = app.unit;
            app.RadioFreq.Value = true;
            app.RadioPeriod.Value = false;
            app.PanelXRange.SelectedObject = app.RadioFreq;

            app.EditReference.Value = '';
            app.seriesNames = {};
            app.ListSeries.Items = {};

            CDac_pwd;
            app.workingDir = pwd;
            cd(pre_dirML);
            app.EditPath.Value = app.workingDir;
            app.loadDirectory(app.workingDir);

            app.UIFigure.Position = app.normalizedToPixelPosition([0.03,0.03,0.56,0.32]);
            app.applyLayout();
            app.plotPreviewFallback();
        end

        function loadDirectory(app, address)
            if ~isfolder(address)
                return
            end
            app.workingDir = address;
            d = dir(address);
            names = {d.name};
            app.fileList = names;
            app.ListFiles.Items = names;
            if ~isempty(names)
                app.ListFiles.Value = names{1};
            end
            app.EditPath.Value = address;
            app.selectedFileIndices = [];
        end

        function onPathChanged(app)
            address = strtrim(app.EditPath.Value);
            if isfolder(address)
                app.loadDirectory(address);
            else
                app.EditPath.Value = app.workingDir;
            end
        end

        function onListFilesChanged(app)
            vals = app.ListFiles.Value;
            if ischar(vals)
                vals = {vals};
            end
            idx = [];
            for i = 1:numel(vals)
                j = find(strcmp(app.fileList, vals{i}), 1, 'first');
                if ~isempty(j)
                    idx(end+1) = j; %#ok<AGROW>
                end
            end
            app.selectedFileIndices = idx;
        end

        function tf = isValidDataIndex(~, idx)
            tf = ~isempty(idx) && idx > 2;
        end

        function onAddReference(app)
            if isempty(app.selectedFileIndices) || numel(app.selectedFileIndices) ~= 1
                return
            end
            idx = app.selectedFileIndices(1);
            if ~app.isValidDataIndex(idx)
                return
            end
            app.targetName = app.fileList{idx};
            if isfolder(fullfile(app.workingDir, app.targetName))
                return
            end
            app.EditReference.Value = app.targetName;

            try
                target = load(fullfile(app.workingDir, app.targetName));
                target = datapreproc(target,0);
                t1 = target(:,1);
                sr_target = median(diff(t1));
                windowsize = round(abs(t1(end)-t1(1))/2);
                nooverlap = round(windowsize * 0.5);
                app.EditWindow.Value = num2str(windowsize);
                app.EditOverlap.Value = num2str(nooverlap);
                app.EditFrom.Value = num2str(0);
                app.EditTo.Value = num2str(1/(2*sr_target));
            catch
            end

            app.safeUpdate();
        end

        function onAddSeries(app)
            if isempty(app.selectedFileIndices)
                return
            end
            s = {};
            for i = 1:numel(app.selectedFileIndices)
                idx = app.selectedFileIndices(i);
                if app.isValidDataIndex(idx)
                    cand = app.fileList{idx};
                    if ~isfolder(fullfile(app.workingDir, cand))
                        s{end+1} = cand; %#ok<AGROW>
                    end
                end
            end
            app.seriesNames = s;
            app.ListSeries.Items = s;
            if ~isempty(s)
                app.ListSeries.Value = s{1};
                try
                    target = load(fullfile(app.workingDir, s{1}));
                    target = datapreproc(target,0);
                    t1 = target(:,1);
                    sr_target = median(diff(t1));
                    windowsize = round(abs(t1(end)-t1(1))/2);
                    nooverlap = round(windowsize * 0.5);
                    app.EditWindow.Value = num2str(windowsize);
                    app.EditOverlap.Value = num2str(nooverlap);
                    app.EditFrom.Value = num2str(0);
                    app.EditTo.Value = num2str(1/(2*sr_target));
                catch
                end
            end
            app.safeUpdate();
        end

        function onCohPChanged(app)
            v = str2double(app.EditCohP.Value);
            if ~isfinite(v)
                app.EditCohP.Value = '0.05';
                return
            end
            if v > 1, v = 1; end
            if v < 0, v = 0; end
            app.EditCohP.Value = num2str(v);
            app.safeUpdate();
        end

        function onRangeModeChanged(app)
            if isempty(app.targetName)
                return
            end
            try
                target = load(fullfile(app.workingDir, app.targetName));
                target = datapreproc(target,0);
                sr_target = median(diff(target(:,1)));
                t = target(:,1);
                if app.PanelXRange.SelectedObject == app.RadioFreq
                    app.EditFrom.Value = num2str(0);
                    app.EditTo.Value = num2str(1/(2*sr_target));
                else
                    app.EditFrom.Value = num2str(2*sr_target);
                    app.EditTo.Value = num2str(0.5*abs(t(1)-t(end)));
                end
            catch
            end
            app.safeUpdate();
        end

        function safeUpdate(app)
            try
                app.updateCoherence();
            catch
            end
        end

        function onRun(app)
            app.updateCoherence();
        end

        function updateCoherence(app)
            if isempty(app.targetName) || isempty(app.seriesNames)
                return
            end

            target = load(fullfile(app.workingDir, app.targetName));
            target = datapreproc(target,0);
            sr_target = median(diff(target(:,1)));
            tar1 = min(target(:,1));
            tar2 = max(target(:,1));
            target1 = target;

            timedir = app.DropDepthTime.Value;
            cohthreshold = str2double(app.EditCohP.Value);
            windowsize1 = str2double(app.EditWindow.Value);
            nooverlap1 = str2double(app.EditOverlap.Value);
            plotx1 = str2double(app.EditFrom.Value);
            plotx2 = str2double(app.EditTo.Value);
            if ~isfinite(cohthreshold), cohthreshold = 0.05; end
            if ~isfinite(windowsize1) || windowsize1 <= 0, windowsize1 = abs(tar2-tar1)/2; end
            if ~isfinite(nooverlap1) || nooverlap1 < 0, nooverlap1 = windowsize1 * 0.5; end
            if ~isfinite(plotx1), plotx1 = 0; end
            if ~isfinite(plotx2), plotx2 = 1/(2*sr_target); end

            windowsize = round(windowsize1/sr_target);
            nooverlap = round(nooverlap1/sr_target);
            if windowsize < 2, windowsize = 2; end
            if nooverlap < 0, nooverlap = 0; end

            forp = 1;
            if app.PanelXRange.SelectedObject == app.RadioPeriod
                forp = 2;
            end

            qplot1 = app.CheckPlotCoh.Value;
            qplot2 = app.CheckPlotPhase.Value;
            save1 = app.CheckSave.Value;

            last = struct();

            for i = 1:numel(app.seriesNames)
                data_name = app.seriesNames{i};
                [~,dat_name,~] = fileparts(data_name);
                if isfolder(fullfile(app.workingDir,data_name))
                    continue
                end
                data = load(fullfile(app.workingDir,data_name));
                data = sortrows(data);
                data = findduplicate(data);
                data(any(isinf(data),2),:) = [];
                ser1 = min(data(:,1));
                ser2 = max(data(:,1));

                series2int = interp1(data(:,1),data(:,2),target1(:,1));
                data2 = [target1(:,1),series2int];

                sel1 = max(ser1, tar1);
                sel2 = min(ser2, tar2);
                if sel1 >= sel2
                    error('Error: no overlap');
                end

                if (sel2 - sel1)/2 < windowsize1
                    windowsize1 = (sel2-sel1)/2;
                    windowsize = round(windowsize1/sr_target);
                    nooverlap1 = round(windowsize1*0.5);
                    nooverlap = round(nooverlap1/sr_target);
                    app.EditWindow.Value = num2str(windowsize1);
                    app.EditOverlap.Value = num2str(nooverlap1);
                end

                series3 = select_interval(data2,sel1,sel2);
                target2 = select_interval(target1,sel1,sel2);
                y = (series3(:,2)-mean(series3(:,2)))./std(series3(:,2));
                x = (target2(:,2)-mean(target2(:,2)))./std(target2(:,2));

                [Cxy,F1,MSC_critical,significant_freqs,significant_Cxy,phase_diff_deg,F2,phase_uncertainty_deg] = ...
                    cohac(x,y,sr_target,'hamming',windowsize,nooverlap,cohthreshold,0);

                if save1
                    pre_dirML = pwd;
                    CDac_pwd;
                    add_list = [dat_name,'-COH-',app.targetName];
                    dlmwrite(add_list,[F1,Cxy],'delimiter',' ','precision',9);
                    add_list = [dat_name,'-COH-sig-',app.targetName];
                    dlmwrite(add_list,[significant_freqs,significant_Cxy],'delimiter',' ','precision',9);
                    add_list2 = [dat_name,'-Phase-',app.targetName];
                    dlmwrite(add_list2,[F2,phase_diff_deg,phase_uncertainty_deg],'delimiter',' ','precision',9);
                    app.refreshMainListbox();
                    cd(pre_dirML);
                end

                if qplot1
                    try
                        figure(app.subfigure);
                    catch
                        app.subfigure = figure;
                        set(app.subfigure,'units','norm','position',[0.005,0.45,0.38,0.45]);
                    end
                    set(app.subfigure,'color','w','Name','Acycle: coherence and phase | coherence');

                    subplot(3,1,1);
                    if forp == 1
                        plot(F1,Cxy,'k-o','LineWidth',2); xlabel('Frequency');
                    else
                        plot(1./F1(2:end),Cxy(2:end),'k-o','LineWidth',2); xlabel('Period');
                    end
                    xlim([plotx1,plotx2]); ylim([0 1]); hold on;
                    plot(xlim,[1 1]*MSC_critical,'-.b');
                    title(['Magnitude-Squared Coherence. Critical Coherence = ',num2str(MSC_critical),' @ p-value = ',num2str(cohthreshold)]);
                    ylabel('Coherence'); set(gca,'XMinorTick','on','YMinorTick','on'); hold off;

                    Cxyp = Cxy(Cxy>MSC_critical);
                    F2p = F2(Cxy>MSC_critical);
                    phasep = phase_diff_deg(Cxy>MSC_critical);
                    uncp = phase_uncertainty_deg(Cxy>MSC_critical);

                    subplot(3,1,2);
                    if forp == 1
                        h1 = errorbar(F2p, phasep, uncp);
                        xlabel('Frequency');
                    else
                        try
                            h1 = errorbar(1./F2p,1./phasep,1./uncp);
                        catch
                            h1 = errorbar(1./F2p(2:end),1./phasep(2:end),1./uncp(2:end));
                        end
                        xlabel('Period');
                    end
                    h1.LineWidth = 1.5; h1.Color = 'k'; h1.CapSize = 6; h1.LineStyle = 'none'; h1.Marker = 'o'; h1.MarkerSize = 8;
                    xlim([plotx1,plotx2]); ylim([-180 180]); hold on;
                    plot(xlim,[1 1]*90,'--k'); plot(xlim,[1 1]*45,':k'); plot(xlim,[1 1]*0,'-k');
                    plot(xlim,[1 1]*-45,':k'); plot(xlim,[1 1]*-90,'--k');
                    title('Cross Spectrum Phase and 1 standard deviation (in degree)');
                    if strcmp(timedir,app.DropDepthTime.Items{1})
                        ylabel(['Series lead (',char(176),')']);
                    else
                        ylabel(['Series lag (',char(176),')']);
                    end
                    set(gca,'XMinorTick','on','YMinorTick','on'); hold off;

                    subplot(3,1,3);
                    if ~isempty(F2p) && F2p(1) ~= 0
                        F3 = F2p;
                    else
                        F3 = F2p(2:end);
                    end
                    if ~isempty(F3)
                        h2 = errorbar(F3, phasep(1:numel(F3))./F3/360, uncp(1:numel(F3))./F3/360);
                        h2.LineWidth = 1.5; h2.Color = 'k'; h2.CapSize = 6; h2.LineStyle = 'none'; h2.Marker = 'o'; h2.MarkerSize = 8;
                    end
                    hold on; plot(xlim,[1 1]*0,'-k'); xlabel('Frequency');
                    if strcmp(timedir,app.DropDepthTime.Items{1})
                        ylabel('Series lead (unit)');
                    else
                        ylabel('Series lag (unit)');
                    end
                    title('Cross Spectrum Phase and 1 standard deviation (in unit)');
                    set(gca,'XMinorTick','on','YMinorTick','on'); xlim([plotx1,plotx2]); hold off;
                else
                    try close(app.subfigure); catch, end
                end

                if qplot2
                    Cxyp = Cxy(Cxy>MSC_critical);
                    F2p = F2(Cxy>MSC_critical);
                    phasep = phase_diff_deg(Cxy>MSC_critical);
                    try
                        figure(app.polarfigure);
                    catch
                        app.polarfigure = figure;
                        set(app.polarfigure,'units','norm','position',[0.385,0.45,0.38,0.45]);
                    end
                    set(app.polarfigure,'color','w','Name','Acycle: coherence and phase | phase');
                    if forp == 1
                        polarscatter(deg2rad(phasep),F2p,Cxyp.^2*500,'filled','MarkerFaceAlpha',.5);
                    else
                        if numel(F2p) > 1 && numel(phasep) > 1
                            polarscatter(deg2rad(phasep(2:end)),1./F2p(2:end),2.^(Cxyp(2:end).^2*100),'filled','MarkerFaceAlpha',.5);
                        else
                            polarscatter(deg2rad(phasep),1./F2p,2.^(Cxyp.^2*100),'filled','MarkerFaceAlpha',.5);
                        end
                    end
                    hold on; rlim([plotx1,plotx2]);
                    if strcmp(timedir,app.DropDepthTime.Items{1})
                        title(['Series leads (0-180',char(176),') or lags behind (180-360',char(176),') the reference']);
                    else
                        title(['Series lags behind (0-180',char(176),') or leads (180-360',char(176),') the reference']);
                    end
                    hold off;
                else
                    try close(app.polarfigure); catch, end
                end

                last.F1 = F1; last.Cxy = Cxy; last.phase = phase_diff_deg; last.F2 = F2; last.MSC = MSC_critical;
            end

            if ~isempty(fieldnames(last))
                cla(app.PreviewAxes);
                plot(app.PreviewAxes,last.F1,last.Cxy,'LineWidth',1.2);
                hold(app.PreviewAxes,'on');
                plot(app.PreviewAxes,app.PreviewAxes.XLim,[last.MSC last.MSC],'--');
                hold(app.PreviewAxes,'off');
                if forp == 1
                    app.PreviewAxes.XLabel.String = 'Frequency';
                else
                    app.PreviewAxes.XLabel.String = 'Period';
                end
                app.PreviewAxes.YLabel.String = 'Coherence';

                cla(app.PreviewPolar);
                polarscatter(app.PreviewPolar,deg2rad(last.phase),last.F2,50,'filled','MarkerFaceAlpha',0.5);
            end
        end

        function plotPreviewFallback(app)
            plot(app.PreviewAxes,rand(20,2));
            polarscatter(app.PreviewPolar,deg2rad(45),10,50,'filled','MarkerFaceAlpha',0.5);
        end

        function refreshMainListbox(app)
            pre = '<HTML><FONT color="blue">';
            post = '</FONT></HTML>';
            d = dir;
            if numel(d) >= 2, d(1:2) = []; end
            address = pwd;

            if ~isempty(app.edit_acfigmain_dir) && isgraphics(app.edit_acfigmain_dir)
                set(app.edit_acfigmain_dir, 'String', address);
            end

            ac_pwd_str = which('ac_pwd.txt');
            if ~isempty(ac_pwd_str)
                [ac_pwd_dir,~,~] = fileparts(ac_pwd_str);
                fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
                if fileID ~= -1
                    fprintf(fileID,'%s',address);
                    fclose(fileID);
                end
            end

            if isempty(d) || isempty(app.listbox_acmain) || ~isgraphics(app.listbox_acmain)
                return
            end

            T = struct2table(d);
            switch app.val1
                case 1
                    sortedT = sortrows(T,'name','ascend');
                case 2
                    sortedT = sortrows(T,'name','descend');
                case 3
                    sortedT = sortrows(T,'date','ascend');
                case 4
                    sortedT = sortrows(T,'date','descend');
                case 5
                    sortedT = sortrows(T,'bytes','ascend');
                case 6
                    sortedT = sortrows(T,'bytes','descend');
                otherwise
                    sortedT = sortrows(T,'name','ascend');
            end
            sd = table2struct(sortedT);
            listboxStr = cell(numel(sd),1);
            for i = 1:numel(sd)
                if isdir(sd(i).name)
                    listboxStr{i} = [pre, sd(i).name, post];
                else
                    listboxStr{i} = sd(i).name;
                end
            end
            set(app.listbox_acmain,'String',listboxStr,'Value',[]);
        end
    end

    methods (Access = public)
        function app = coherenceGUI(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context,'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('coherenceGUI requires a handles/context struct input.');
            end

            app.createComponents();
            app.initializeState();
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            try close(app.subfigure); catch, end
            try close(app.polarfigure); catch, end
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end
end
