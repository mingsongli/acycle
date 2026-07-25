classdef CorrelationGUI < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE CorrelationGUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure

        PanelSelect matlab.ui.container.Panel
        LabelRef matlab.ui.control.Label
        ButtonOpenRef matlab.ui.control.Button
        EditRefPath matlab.ui.control.EditField

        LabelTarget matlab.ui.control.Label
        ButtonOpenTarget matlab.ui.control.Button
        EditTargetPath matlab.ui.control.EditField

        PanelLimits matlab.ui.container.Panel
        LabelRefX matlab.ui.control.Label
        LabelRefMin matlab.ui.control.Label
        LabelRefMax matlab.ui.control.Label
        EditRefMin matlab.ui.control.EditField
        EditRefMax matlab.ui.control.EditField

        LabelSerX matlab.ui.control.Label
        LabelSerMin matlab.ui.control.Label
        LabelSerMax matlab.ui.control.Label
        EditSerMin matlab.ui.control.EditField
        EditSerMax matlab.ui.control.EditField

        CheckSave matlab.ui.control.CheckBox
        ButtonUndo matlab.ui.control.Button
        ButtonClear matlab.ui.control.Button
        ButtonOK matlab.ui.control.Button
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1
        val1 double = 1
        unit char = ''

        listbox_acmain
        edit_acfigmain_dir

        lang_choice double = 0
        lang_id = {}
        lang_var = {}

        referenceData = []
        seriesData = []
        refPath char = ''
        serPath char = ''
        plot_s cell = {}

        refxmin double = 0
        refxmax double = 1
        serxmin double = 0
        serxmax double = 1

        idi double = 1
        tiepoints1 = []
        tiepoints2 = []

        RawDataFig
        CorrFig
        CorrSR
        CorrAgeMod

        IsPicking = false

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
            w = max(1250, normPos(3)*screen(3));
            h = max(560, normPos(4)*screen(4));
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
            app.UIFigure = uifigure('Name','CorrelationGUI', ...
                'Color',app.UIColorBg, ...
                'Resize','on', ...
                'Position',app.normalizedToPixelPosition([0.4,0.01,0.6,0.3]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.PanelSelect = uipanel(app.UIFigure,'Title','Select Reference and Target', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');
            app.LabelRef = uilabel(app.PanelSelect,'Text','Reference', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+2);
            app.ButtonOpenRef = uibutton(app.PanelSelect,'push','Text','Open', ...
                'FontSize',app.UIFontSize+1,'ButtonPushedFcn',@(~,~)app.onOpenReference());
            app.EditRefPath = uieditfield(app.PanelSelect,'text','Value','Edit Text', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);

            app.LabelTarget = uilabel(app.PanelSelect,'Text','Target', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+2);
            app.ButtonOpenTarget = uibutton(app.PanelSelect,'push','Text','Open', ...
                'FontSize',app.UIFontSize+1,'ButtonPushedFcn',@(~,~)app.onOpenTarget());
            app.EditTargetPath = uieditfield(app.PanelSelect,'text','Value','Edit Text', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);

            app.PanelLimits = uipanel(app.UIFigure,'Title','Set limits', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');

            app.LabelRefX = uilabel(app.PanelLimits,'Text','Reference : X limit', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');
            app.LabelRefMin = uilabel(app.PanelLimits,'Text','min', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.LabelRefMax = uilabel(app.PanelLimits,'Text','max', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditRefMin = uieditfield(app.PanelLimits,'text','Value','0', ...
                'BackgroundColor',[1 1 1],'HorizontalAlignment','center','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onRefMinChanged());
            app.EditRefMax = uieditfield(app.PanelLimits,'text','Value','1', ...
                'BackgroundColor',[1 1 1],'HorizontalAlignment','center','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onRefMaxChanged());

            app.LabelSerX = uilabel(app.PanelLimits,'Text','Series : X limit', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');
            app.LabelSerMin = uilabel(app.PanelLimits,'Text','min', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.LabelSerMax = uilabel(app.PanelLimits,'Text','max', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditSerMin = uieditfield(app.PanelLimits,'text','Value','0', ...
                'BackgroundColor',[1 1 1],'HorizontalAlignment','center','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onSerMinChanged());
            app.EditSerMax = uieditfield(app.PanelLimits,'text','Value','1', ...
                'BackgroundColor',[1 1 1],'HorizontalAlignment','center','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onSerMaxChanged());

            app.CheckSave = uicheckbox(app.UIFigure,'Text','Save data','Value',true, ...
                'FontSize',app.UIFontSize+1);
            app.ButtonUndo = uibutton(app.UIFigure,'push','Text','Undo', ...
                'FontSize',app.UIFontSize+2,'ButtonPushedFcn',@(~,~)app.onUndo());
            app.ButtonClear = uibutton(app.UIFigure,'push','Text','Clear', ...
                'FontSize',app.UIFontSize+2,'ButtonPushedFcn',@(~,~)app.onClearAll());
            app.ButtonOK = uibutton(app.UIFigure,'push','Text','OK', ...
                'FontSize',app.UIFontSize+2,'FontWeight','bold', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'ButtonPushedFcn',@(~,~)app.onOK());

            app.applyLayout();
        end

        function applyLayout(app)
            fr = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];

            app.PanelSelect.Position = app.childPos(fr,[0.025,0.476,0.955,0.475]);
            app.LabelRef.Position = app.childPos(app.PanelSelect.Position,[0.015,0.79,0.20,0.10]);
            app.ButtonOpenRef.Position = app.childPos(app.PanelSelect.Position,[0.015,0.557,0.1,0.208]);
            app.EditRefPath.Position = app.childPos(app.PanelSelect.Position,[0.125,0.547,0.87,0.208]);

            app.LabelTarget.Position = app.childPos(app.PanelSelect.Position,[0.015,0.28,0.20,0.15]);
            app.ButtonOpenTarget.Position = app.childPos(app.PanelSelect.Position,[0.015,0.03,0.1,0.208]);
            app.EditTargetPath.Position = app.childPos(app.PanelSelect.Position,[0.125,0.03,0.87,0.208]);

            app.PanelLimits.Position = app.childPos(fr,[0.025,0.076,0.75,0.36]);
            app.LabelRefX.Position = app.childPos(app.PanelLimits.Position,[0.015,0.6,0.27,0.26]);
            app.LabelRefMin.Position = app.childPos(app.PanelLimits.Position,[0.31,0.6,0.12,0.26]);
            app.EditRefMin.Position = app.childPos(app.PanelLimits.Position,[0.44,0.58,0.155,0.286]);
            app.LabelRefMax.Position = app.childPos(app.PanelLimits.Position,[0.625,0.6,0.08,0.26]);
            app.EditRefMax.Position = app.childPos(app.PanelLimits.Position,[0.7,0.58,0.155,0.286]);

            app.LabelSerX.Position = app.childPos(app.PanelLimits.Position,[0.015,0.2,0.27,0.26]);
            app.LabelSerMin.Position = app.childPos(app.PanelLimits.Position,[0.31,0.2,0.12,0.26]);
            app.EditSerMin.Position = app.childPos(app.PanelLimits.Position,[0.44,0.18,0.155,0.286]);
            app.LabelSerMax.Position = app.childPos(app.PanelLimits.Position,[0.625,0.2,0.08,0.26]);
            app.EditSerMax.Position = app.childPos(app.PanelLimits.Position,[0.7,0.18,0.155,0.286]);

            app.CheckSave.Position = app.childPos(fr,[0.8,0.30,0.1,0.1]);
            app.ButtonUndo.Position = app.childPos(fr,[0.9,0.276,0.08,0.168]);
            app.ButtonClear.Position = app.childPos(fr,[0.8,0.076,0.08,0.168]);
            app.ButtonOK.Position = app.childPos(fr,[0.9,0.076,0.08,0.168]);
        end

        function initializeState(app)
            c = app.Context;
            if isfield(c,'listbox_acmain'), app.listbox_acmain = c.listbox_acmain; end
            if isfield(c,'edit_acfigmain_dir'), app.edit_acfigmain_dir = c.edit_acfigmain_dir; end
            if isfield(c,'MonZoom'), app.MonZoom = c.MonZoom; end
            if isfield(c,'val1'), app.val1 = c.val1; end
            if isfield(c,'unit'), app.unit = c.unit; end
            if isfield(c,'lang_choice'), app.lang_choice = c.lang_choice; end
            if isfield(c,'lang_id'), app.lang_id = c.lang_id; end
            if isfield(c,'lang_var'), app.lang_var = c.lang_var; end

            app.UIFigure.Name = app.getLang('c70','CorrelationGUI');
            app.PanelSelect.Title = app.getLang('c71','Select Reference and Target');
            app.LabelRef.Text = app.getLang('main11','Reference');
            app.LabelTarget.Text = app.getLang('main13','Target');
            app.ButtonOpenRef.Text = app.getLang('main18','Open');
            app.ButtonOpenTarget.Text = app.getLang('main18','Open');

            app.PanelLimits.Title = app.getLang('c72','Set limits');
            app.LabelRefX.Text = app.getLang('c73','Reference : X limit');
            app.LabelSerX.Text = app.getLang('c74','Series : X limit');
            app.LabelRefMin.Text = app.getLang('main05','min');
            app.LabelSerMin.Text = app.getLang('main05','min');
            app.LabelRefMax.Text = app.getLang('main06','max');
            app.LabelSerMax.Text = app.getLang('main06','max');

            app.CheckSave.Text = app.getLang('main01','Save data');
            app.ButtonUndo.Text = app.getLang('main19','Undo');
            app.ButtonClear.Text = app.getLang('c90','Clear All');
            app.ButtonOK.Text = app.getLang('main00','OK');

            app.ButtonUndo.Enable = 'off';
            app.ButtonClear.Enable = 'off';
            app.ButtonOK.Enable = 'on';

            try
                GETac_pwd;
                app.refPath = ac_pwd;
                app.serPath = ac_pwd;
                app.EditRefPath.Value = ac_pwd;
                app.EditTargetPath.Value = ac_pwd;
            catch
            end

            app.idi = 1;
            app.tiepoints1 = [];
            app.tiepoints2 = [];

            app.UIFigure.Position = app.normalizedToPixelPosition([0.4,0.01,0.6,0.3]);
            app.applyLayout();
        end

        function data = loadTwoColData(~, filepath)
            try
                data = load(filepath);
            catch
                fid = fopen(filepath);
                if fid ~= -1
                    data_ft = textscan(fid,'%f%f','EmptyValue',Inf);
                    data = cell2mat(data_ft);
                    fclose(fid);
                else
                    error('Cannot open file');
                end
            end
            data = sortrows(data);
            data = findduplicate(data);
            data(any(isinf(data),2),:) = [];
            if size(data,2) > 2
                data = data(:,1:2);
            end
        end

        function [x,y,btn] = onePointInput(~)
            if exist('myginput','file') == 2
                [x,y,btn] = myginput(1,'crosshair');
            else
                [x,y,btn] = ginput(1);
            end
        end

        function onOpenReference(app)
            if app.IsPicking
                return
            end
            pre_dirML = pwd;
            CDac_pwd;
            if app.lang_choice == 0
                [file,path] = uigetfile({'*.*','All Files (*.*)'},'Select a Reference Series');
            else
                [file,path] = uigetfile({'*.*',app.getLang('c92','All Files')},app.getLang('c86','Select a Reference Series'));
            end
            cd(pre_dirML);
            if isequal(file,0)
                return
            end

            fp = fullfile(path,file);
            app.EditRefPath.Value = fp;
            app.plot_s{1} = fp;
            app.refPath = fp;

            dat = app.loadTwoColData(fp);
            app.referenceData = dat;
            app.refxmin = min(dat(:,1));
            app.refxmax = max(dat(:,1));
            app.EditRefMin.Value = num2str(app.refxmin);
            app.EditRefMax.Value = num2str(app.refxmax);
            app.plotRawData();
        end

        function onOpenTarget(app)
            if app.IsPicking
                return
            end
            pre_dirML = pwd;
            CDac_pwd;
            if app.lang_choice == 0
                [file,path] = uigetfile({'*.*','All Files (*.*)'},'Select a Target Series');
            else
                [file,path] = uigetfile({'*.*',app.getLang('c92','All Files')},app.getLang('c86','Select a Target Series'));
            end
            cd(pre_dirML);
            if isequal(file,0)
                return
            end

            fp = fullfile(path,file);
            app.EditTargetPath.Value = fp;
            app.plot_s{2} = fp;
            app.serPath = fp;

            dat = app.loadTwoColData(fp);
            app.seriesData = dat;
            app.serxmin = min(dat(:,1));
            app.serxmax = max(dat(:,1));
            app.EditSerMin.Value = num2str(app.serxmin);
            app.EditSerMax.Value = num2str(app.serxmax);
            app.plotRawData();
        end

        function plotRawData(app)
            try
                figure(app.RawDataFig);
            catch
                app.RawDataFig = figure;
                set(app.RawDataFig,'Color','white','Position',[600 500 700 450]);
            end

            subplot(2,1,1);
            if ~isempty(app.referenceData)
                plot(app.referenceData(:,1),app.referenceData(:,2),'r-');
                xlim([str2double(app.EditRefMin.Value),str2double(app.EditRefMax.Value)]);
            else
                cla;
            end
            xlabel(app.getLang('main28','Depth/Time'));
            ylabel(app.getLang('main24','Value'));
            title(app.getLang('main11','Reference'));

            subplot(2,1,2);
            if ~isempty(app.seriesData)
                plot(app.seriesData(:,1),app.seriesData(:,2),'b-');
                xlim([str2double(app.EditSerMin.Value),str2double(app.EditSerMax.Value)]);
            else
                cla;
            end
            xlabel(app.getLang('main28','Depth/Time'));
            ylabel(app.getLang('main24','Value'));
            title(app.getLang('main12','Series'));
        end

        function onRefMinChanged(app)
            if app.IsPicking
                return
            end
            xmin = str2double(app.EditRefMin.Value);
            xmax = str2double(app.EditRefMax.Value);
            if isnan(xmin)
                app.EditRefMin.Value = num2str(app.refxmin);
                return
            end
            if xmin < app.refxmin
                warndlg(app.getLang('c88','Value is too small'));
                app.EditRefMin.Value = num2str(app.refxmin);
                return
            end
            if xmin >= xmax
                app.EditRefMin.Value = num2str(app.refxmin);
                return
            end
            try
                figure(app.RawDataFig); subplot(2,1,1); xlim([xmin,xmax]); figure(app.UIFigure);
            catch
            end
        end

        function onRefMaxChanged(app)
            if app.IsPicking
                return
            end
            xmin = str2double(app.EditRefMin.Value);
            xmax = str2double(app.EditRefMax.Value);
            if isnan(xmax)
                app.EditRefMax.Value = num2str(app.refxmax);
                return
            end
            if xmax > app.refxmax
                warndlg(app.getLang('c89','Value is too large'));
                app.EditRefMax.Value = num2str(app.refxmax);
                return
            end
            if xmax <= xmin
                app.EditRefMax.Value = num2str(app.refxmax);
                return
            end
            try
                figure(app.RawDataFig); subplot(2,1,1); xlim([xmin,xmax]); figure(app.UIFigure);
            catch
            end
        end

        function onSerMinChanged(app)
            if app.IsPicking
                return
            end
            xmin = str2double(app.EditSerMin.Value);
            xmax = str2double(app.EditSerMax.Value);
            if isnan(xmin)
                app.EditSerMin.Value = num2str(app.serxmin);
                return
            end
            if xmin < app.serxmin
                warndlg(app.getLang('c88','Value is too small'));
                app.EditSerMin.Value = num2str(app.serxmin);
                return
            end
            if xmin >= xmax
                app.EditSerMin.Value = num2str(app.serxmin);
                return
            end
            try
                figure(app.RawDataFig); subplot(2,1,2); xlim([xmin,xmax]); figure(app.UIFigure);
            catch
            end
        end

        function onSerMaxChanged(app)
            if app.IsPicking
                return
            end
            xmin = str2double(app.EditSerMin.Value);
            xmax = str2double(app.EditSerMax.Value);
            if isnan(xmax)
                app.EditSerMax.Value = num2str(app.serxmax);
                return
            end
            if xmax > app.serxmax
                warndlg(app.getLang('c89','Value is too large'));
                app.EditSerMax.Value = num2str(app.serxmax);
                return
            end
            if xmax <= xmin
                app.EditSerMax.Value = num2str(app.serxmax);
                return
            end
            try
                figure(app.RawDataFig); subplot(2,1,2); xlim([xmin,xmax]); figure(app.UIFigure);
            catch
            end
        end

        function [rawref,rawser] = getSegmentedData(app)
            rawref = app.referenceData;
            rawser = app.seriesData;
            refxmin = str2double(app.EditRefMin.Value);
            refxmax = str2double(app.EditRefMax.Value);
            serxmin = str2double(app.EditSerMin.Value);
            serxmax = str2double(app.EditSerMax.Value);
            rawref = rawref(rawref(:,1)>refxmin & rawref(:,1)<refxmax,:);
            rawser = rawser(rawser(:,1)>serxmin & rawser(:,1)<serxmax,:);
        end

        function onOK(app)
            if app.IsPicking
                return
            end
            if isempty(app.referenceData) || isempty(app.seriesData)
                warndlg(app.getLang('c75','reference/series data not ready'));
                return
            end

            [rawref,rawser] = app.getSegmentedData();
            if isempty(rawref) || isempty(rawser)
                warndlg(app.getLang('c75','reference/series data not ready'));
                return
            end

            app.ButtonUndo.Enable = 'on';
            app.ButtonClear.Enable = 'on';

            if isempty(app.tiepoints1)
                app.idi = 1;
                app.tiepoints1 = [];
                app.tiepoints2 = [];
            end

            app.IsPicking = true;
            app.setMainControlsEnabled(false);
            pickGuard = onCleanup(@()app.finishPicking());

            app.drawCorrelationFigures(rawref,rawser,false);
            msgRefPick = app.getLang('c76','Select a tie point in the reference plot; right click to stop');
            msgSerPick = app.getLang('c77','Select a tie point in the series plot; right click to stop');
            ttlRef = app.getLang('c78','Reference');
            ttlSer = app.getLang('c79','Series');
            refxmin = str2double(app.EditRefMin.Value);
            refxmax = str2double(app.EditRefMax.Value);
            shiftv = 0.005;

            con = 1;
            while con == 1
                figure(app.CorrFig);
                subplot(3,1,1);
                title(msgRefPick);
                [x1,y1,con] = app.onePointInput();
                if isempty(con) || con ~= 1
                    break
                end
                y1 = min(max(y1,min(rawref(:,2))),max(rawref(:,2)));

                % Update the top subplot immediately after picking reference point.
                tiepoints1tmp = [app.tiepoints1; x1,y1,app.idi];
                plot(rawref(:,1),rawref(:,2),'-','color',[128 128 128]/255);
                xlim([refxmin,refxmax]); hold on;
                plot(tiepoints1tmp(:,1),tiepoints1tmp(:,2),'*','color',[128 0 0]/255);
                xl = xlim; yl = ylim; sx = shiftv*(xl(2)-xl(1)); sy = shiftv*(yl(2)-yl(1));
                text(tiepoints1tmp(:,1)+sx,tiepoints1tmp(:,2)+sy,num2str(tiepoints1tmp(:,3)));
                hold off;
                xlabel(app.getLang('main21','Time')); ylabel(app.getLang('main24','Value'));
                title(ttlRef);

                subplot(3,1,2);
                title(msgSerPick);
                [x2,y2,con2] = app.onePointInput();
                if isempty(con2) || con2 ~= 1
                    % Revert temporary reference-point preview if user cancels on series panel.
                    app.drawCorrelationFigures(rawref,rawser,false);
                    break
                end
                y2 = min(max(y2,min(rawser(:,2))),max(rawser(:,2)));

                app.tiepoints1(app.idi,:) = [x1,y1,app.idi];
                app.tiepoints2(app.idi,:) = [x2,y2,app.idi];
                app.idi = app.idi + 1;

                app.drawCorrelationFigures(rawref,rawser,false);
                subplot(3,1,2);
                title(ttlSer);
            end

            if size(app.tiepoints1,1) >= 2
                % Update auxiliary figures once after picking finishes,
                % to avoid stealing focus from the interactive picking loop.
                app.plotSedRateAndAgeModel(rawser);
            end

            if app.CheckSave.Value && size(app.tiepoints1,1) >= 2
                app.saveCorrelationData(rawref,rawser);
            end
            clear pickGuard;
        end

        function drawCorrelationFigures(app, rawref, rawser, updateAuxFigures)
            if nargin < 4
                updateAuxFigures = true;
            end
            refxmin = str2double(app.EditRefMin.Value);
            refxmax = str2double(app.EditRefMax.Value);
            serxmin = str2double(app.EditSerMin.Value);
            serxmax = str2double(app.EditSerMax.Value);

            if isempty(app.CorrFig) || ~isgraphics(app.CorrFig)
                app.CorrFig = figure('Units','normalized','Position',[0.01,0.3,0.9,0.65], ...
                    'Color','white','Name',app.getLang('c70','Acycle: Stratigraphic Correlation'));
            else
                figure(app.CorrFig);
            end

            subplot(3,1,1);
            plot(rawref(:,1),rawref(:,2),'-','color',[128 128 128]/255);
            xlim([refxmin,refxmax]); hold on;
            if ~isempty(app.tiepoints1)
                plot(app.tiepoints1(:,1),app.tiepoints1(:,2),'*','color',[128 0 0]/255);
                xl = xlim; yl = ylim; sx = 0.005*(xl(2)-xl(1)); sy = 0.005*(yl(2)-yl(1));
                text(app.tiepoints1(:,1)+sx,app.tiepoints1(:,2)+sy,num2str(app.tiepoints1(:,3)));
            end
            hold off;
            xlabel(app.getLang('main21','Time')); ylabel(app.getLang('main24','Value'));
            title(app.getLang('c78','Reference'));

            subplot(3,1,2);
            plot(rawser(:,1),rawser(:,2),'b-');
            xlim([serxmin,serxmax]); hold on;
            if ~isempty(app.tiepoints2)
                plot(app.tiepoints2(:,1),app.tiepoints2(:,2),'r*');
                xl2 = xlim; yl2 = ylim; sx2 = 0.005*(xl2(2)-xl2(1)); sy2 = 0.005*(yl2(2)-yl2(1));
                text(app.tiepoints2(:,1)+sx2,app.tiepoints2(:,2)+sy2,num2str(app.tiepoints2(:,3)));
            end
            hold off;
            xlabel(app.getLang('main23','Depth')); ylabel(app.getLang('main24','Value'));
            title(app.getLang('c79','Series'));

            subplot(3,1,3);
            cla;
            if size(app.tiepoints1,1) >= 2
                agemodel = [app.tiepoints2(:,1),app.tiepoints1(:,1),app.tiepoints2(:,3)];
                agemodel = sortrows(agemodel);
                data1 = rawser;
                [time1,~] = depthtotime(data1(:,1),agemodel);
                data1t = [time1,data1(:,2)];
                tiepoints2sort = sortrows(app.tiepoints2);
                [tie2t,~] = depthtotime(tiepoints2sort(:,1),agemodel);

                plot(rawref(:,1),(rawref(:,2)-mean(rawref(:,2)))/std(rawref(:,2)),'-','color',[128 128 128]/255); hold on;
                plot(app.tiepoints1(:,1),(app.tiepoints1(:,2)-mean(rawref(:,2)))/std(rawref(:,2)),'*','color',[128 0 0]/255);
                plot(time1,(data1t(:,2)-mean(data1t(:,2)))/std(data1t(:,2)),'b-');
                plot(tie2t,(tiepoints2sort(:,2)-mean(rawser(:,2)))/std(rawser(:,2)),'r*');
                xlim([min(str2double(app.EditRefMin.Value),min(time1)), max(str2double(app.EditRefMax.Value),max(time1))]);
                hold off;
                if updateAuxFigures
                    app.plotSedRateAndAgeModel(rawser);
                end
            else
                plot(rawref(:,1),(rawref(:,2)-mean(rawref(:,2)))/std(rawref(:,2)),'-','color',[128 128 128]/255);
            end
            xlabel(app.getLang('main21','Time')); ylabel(app.getLang('main25','Standardized Value'));
            title(app.getLang('c80','Reference vs. Tuned Series'));
        end

        function plotSedRateAndAgeModel(app, rawser)
            if size(app.tiepoints1,1) < 2 || size(app.tiepoints2,1) < 2
                return
            end
            agemodel = [app.tiepoints2(:,1),app.tiepoints1(:,1),app.tiepoints2(:,3)];
            agemodel = sortrows(agemodel);
            tiepoints2sort = sortrows(app.tiepoints2);
            idi = size(app.tiepoints2,1)+1;
            sedrate = zeros(idi+1,2);
            sedrate(1,1) = rawser(1,1);
            sedrate(2:end-1,1) = tiepoints2sort(:,1);
            sedrate(end,1) = rawser(end,1);
            sedrate0 = diff(agemodel(:,1))./diff(agemodel(:,2));
            if ~isempty(sedrate0)
                sedrate(2:end-2,2) = sedrate0;
                sedrate(1,2) = sedrate(2,2);
                sedrate(end-1,2) = sedrate(end-2,2);
                sedrate(end,2) = sedrate(end-2,2);
            end

            if isempty(app.CorrSR) || ~isgraphics(app.CorrSR)
                app.CorrSR = figure('Units','normalized','Position',[0.01,0.03,0.9,0.22], ...
                    'Color','white','Name',app.getLang('c84','Acycle: Stratigraphic Correlation | Sedimentation Rate'));
            else
                figure(app.CorrSR);
            end
            stairs(sedrate(:,1),sedrate(:,2));
            xlim([str2double(app.EditSerMin.Value), str2double(app.EditSerMax.Value)]);
            xlabel(app.getLang('main23','Depth')); ylabel(app.getLang('main26','Sedimentation Rate'));

            if isempty(app.CorrAgeMod) || ~isgraphics(app.CorrAgeMod)
                app.CorrAgeMod = figure('Units','normalized','Position',[0.55,0.5,0.45,0.45], ...
                    'Color','white','Name',app.getLang('c85','Acycle: Age Model'));
            else
                figure(app.CorrAgeMod);
            end
            plot(agemodel(:,1),agemodel(:,2),'ro-'); hold on;
            xl = xlim; yl = ylim; sx = 0.005*(xl(2)-xl(1)); sy = 0.01*(yl(2)-yl(1));
            text(agemodel(:,1)+sx,agemodel(:,2)-sy,num2str(agemodel(:,3))); hold off;
            xlabel(app.getLang('main23','Depth')); ylabel(app.getLang('main21','Time')); title(app.getLang('main27','Age Model'));
        end

        function saveCorrelationData(app, rawref, rawser)
            pre_dirML = pwd;
            CDac_pwd;
            if numel(app.plot_s) < 2
                cd(pre_dirML);
                return
            end
            [~,name1,~] = fileparts(app.plot_s{1});
            [seriesdir,name2,ext2] = fileparts(app.plot_s{2});
            agemodel = [app.tiepoints2(:,1),app.tiepoints1(:,1),app.tiepoints2(:,3)];
            agemodel = sortrows(agemodel);
            [time1,~] = depthtotime(rawser(:,1),agemodel);
            data1t = [time1,rawser(:,2)];

            tiepoints2sort = sortrows(app.tiepoints2);
            idi = size(app.tiepoints2,1)+1;
            sedrate = zeros(idi+1,2);
            sedrate(1,1) = rawser(1,1);
            sedrate(2:end-1,1) = tiepoints2sort(:,1);
            sedrate(end,1) = rawser(end,1);
            sedrate0 = diff(agemodel(:,1))./diff(agemodel(:,2));
            if ~isempty(sedrate0)
                sedrate(2:end-2,2) = sedrate0;
                sedrate(1,2) = sedrate(2,2);
                sedrate(end-1,2) = sedrate(end-2,2);
                sedrate(end,2) = sedrate(end-2,2);
            end

            namedata = [name2,'-TD-',name1,ext2];
            namesr = [name2,'-TD-',name1,'-SAR',ext2];
            nameagemodel = [name2,'-TD-',name1,'-AgeMod',ext2];
            try
                cd(seriesdir);
                dlmwrite(namedata,data1t,'delimiter',' ','precision',9);
                dlmwrite(namesr,sedrate,'delimiter',' ','precision',9);
                dlmwrite(nameagemodel,agemodel,'delimiter',' ','precision',9);
            catch
            end
            app.refreshMainListbox();
            cd(pre_dirML);
        end

        function onUndo(app)
            if app.IsPicking
                return
            end
            if size(app.tiepoints1,1) < 1
                return
            end
            app.tiepoints1(end,:) = [];
            app.tiepoints2(end,:) = [];
            app.idi = max(1,app.idi-1);
            if isempty(app.tiepoints1)
                app.ButtonUndo.Enable = 'off';
                app.ButtonClear.Enable = 'off';
            end
            if ~isempty(app.referenceData) && ~isempty(app.seriesData)
                [rawref,rawser] = app.getSegmentedData();
                app.drawCorrelationFigures(rawref,rawser,true);
            end
        end

        function onClearAll(app)
            if app.IsPicking
                return
            end
            app.tiepoints1 = [];
            app.tiepoints2 = [];
            app.idi = 1;
            app.ButtonUndo.Enable = 'off';
            if ~isempty(app.referenceData) && ~isempty(app.seriesData)
                [rawref,rawser] = app.getSegmentedData();
                app.drawCorrelationFigures(rawref,rawser,true);
            end
        end

        function setMainControlsEnabled(app, tf)
            state = 'off';
            if tf
                state = 'on';
            end
            app.ButtonOpenRef.Enable = state;
            app.ButtonOpenTarget.Enable = state;
            app.ButtonUndo.Enable = state;
            app.ButtonClear.Enable = state;
            app.ButtonOK.Enable = state;
            app.EditRefPath.Enable = state;
            app.EditTargetPath.Enable = state;
            app.EditRefMin.Enable = state;
            app.EditRefMax.Enable = state;
            app.EditSerMin.Enable = state;
            app.EditSerMax.Enable = state;
            app.CheckSave.Enable = state;
        end

        function finishPicking(app)
            app.IsPicking = false;
            app.setMainControlsEnabled(true);
            if isempty(app.tiepoints1)
                app.ButtonUndo.Enable = 'off';
                app.ButtonClear.Enable = 'off';
            end
        end

        function refreshMainListbox(app)
            if ac_refresh_main_list(app.listbox_acmain)
                return
            end
            pre = '<HTML><FONT color="blue">';
            post = '</FONT></HTML>';
            d = dir;
            if numel(d) >= 2, d(1:2) = []; end
            address = pwd;

            if ~isempty(app.edit_acfigmain_dir) && isgraphics(app.edit_acfigmain_dir)
                set(app.edit_acfigmain_dir,'String',address);
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
                    listboxStr{i} = [pre,sd(i).name,post];
                else
                    listboxStr{i} = sd(i).name;
                end
            end
            set(app.listbox_acmain,'String',listboxStr,'Value',[]);
        end
    end

    methods (Access = public)
        function app = CorrelationGUI(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context,'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('CorrelationGUI requires a handles/context struct input.');
            end

            app.createComponents();
            app.initializeState();
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            try close(app.RawDataFig); catch, end
            try close(app.CorrFig); catch, end
            try close(app.CorrSR); catch, end
            try close(app.CorrAgeMod); catch, end
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end
end
