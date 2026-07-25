classdef plotdigitizer < matlab.apps.AppBase
    % App Designer style migration of plotdigitizer (merged with DataExtractTab logic).

    properties (Access = public)
        UIFigure matlab.ui.Figure

        PanelX matlab.ui.container.Panel
        PanelY matlab.ui.container.Panel

        LabelXStart matlab.ui.control.Label
        LabelXEnd matlab.ui.control.Label
        EditXStart matlab.ui.control.EditField
        EditXEnd matlab.ui.control.EditField
        GroupX matlab.ui.container.ButtonGroup
        RadioXLinear matlab.ui.control.RadioButton
        RadioXLog matlab.ui.control.RadioButton

        LabelYStart matlab.ui.control.Label
        LabelYEnd matlab.ui.control.Label
        EditYStart matlab.ui.control.EditField
        EditYEnd matlab.ui.control.EditField
        GroupY matlab.ui.container.ButtonGroup
        RadioYLinear matlab.ui.control.RadioButton
        RadioYLog matlab.ui.control.RadioButton

        ButtonCalibrate matlab.ui.control.Button
        ButtonDigitize matlab.ui.control.Button
        ButtonUndo matlab.ui.control.Button
        ButtonGrid matlab.ui.control.Button
        ButtonAuto matlab.ui.control.Button
        AutoMode matlab.ui.control.DropDown
        ButtonSave matlab.ui.control.Button

        LabelStatus matlab.ui.control.Label
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1
        val1 double = 1

        acfigmain
        listbox_acmain
        edit_acfigmain_dir

        lang_choice double = 0
        lang_id = {}
        lang_var = {}

        figname char = ''
        DataExtractFig
        warnMsg char = ''

        calibrated logical = false
        srsh double = 10

        x00 double = 0
        x01 double = 1
        x02 double = 0
        x03 double = 0
        y00 double = 0
        y01 double = 0
        y02 double = 0
        y03 double = 1

        % col1=index, col2=value-x, col3=value-y
        tableData double = zeros(0,3)
        % col1=index, col2=pixel-x, col3=pixel-y
        tableDatai double = zeros(0,3)

        YYY0 double = zeros(0,2)
        YYY1 double = zeros(0,2)
        YYYtrue double = zeros(0,2)

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
            w = max(1100, normPos(3)*screen(3));
            h = max(190, normPos(4)*screen(4));
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
            app.UIFigure = uifigure('Name','Acycle: Plot Digitizer', ...
                'Color',app.UIColorBg, ...
                'Resize','on', ...
                'Position',app.normalizedToPixelPosition([0.02,0.80,0.5,0.11]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.PanelX = uipanel(app.UIFigure,'Title','X axis', ...
                'BackgroundColor',app.UIColorBg,'FontWeight','bold','FontSize',app.UIFontSize+1);
            app.PanelY = uipanel(app.UIFigure,'Title','Y axis', ...
                'BackgroundColor',app.UIColorBg,'FontWeight','bold','FontSize',app.UIFontSize+1);

            app.LabelXStart = uilabel(app.PanelX,'Text','Start Point', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.LabelXEnd = uilabel(app.PanelX,'Text','End Point', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditXStart = uieditfield(app.PanelX,'text','Value','0', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);
            app.EditXEnd = uieditfield(app.PanelX,'text','Value','1', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);

            app.GroupX = uibuttongroup(app.PanelX, ...
                'BackgroundColor',app.UIColorBg, ...
                'BorderType','none');
            app.RadioXLinear = uiradiobutton(app.GroupX,'Text','Linear', ...
                'Value',true,'FontSize',app.UIFontSize+1);
            app.RadioXLog = uiradiobutton(app.GroupX,'Text','Logarithmic', ...
                'FontSize',app.UIFontSize+1);

            app.LabelYStart = uilabel(app.PanelY,'Text','Start Point', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.LabelYEnd = uilabel(app.PanelY,'Text','End Point', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditYStart = uieditfield(app.PanelY,'text','Value','0', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);
            app.EditYEnd = uieditfield(app.PanelY,'text','Value','1', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);

            app.GroupY = uibuttongroup(app.PanelY, ...
                'BackgroundColor',app.UIColorBg, ...
                'BorderType','none');
            app.RadioYLinear = uiradiobutton(app.GroupY,'Text','Linear', ...
                'Value',true,'FontSize',app.UIFontSize+1);
            app.RadioYLog = uiradiobutton(app.GroupY,'Text','Logarithmic', ...
                'FontSize',app.UIFontSize+1);

            app.ButtonCalibrate = uibutton(app.UIFigure,'push','Text','Calibrate axis', ...
                'FontWeight','bold','FontSize',app.UIFontSize+1, ...
                'ButtonPushedFcn',@(~,~)app.onCalibrate());
            app.ButtonDigitize = uibutton(app.UIFigure,'push','Text','Digitize', ...
                'FontWeight','bold','FontSize',app.UIFontSize+1, ...
                'ButtonPushedFcn',@(~,~)app.onDigitize());
            app.ButtonUndo = uibutton(app.UIFigure,'push','Text','Undo', ...
                'FontSize',app.UIFontSize+1, ...
                'ButtonPushedFcn',@(~,~)app.onUndo());
            app.ButtonGrid = uibutton(app.UIFigure,'push','Text','Grid Line', ...
                'Enable','off','FontSize',app.UIFontSize+1);
            app.ButtonAuto = uibutton(app.UIFigure,'push','Text','Auto-digitize', ...
                'Enable','on','FontSize',app.UIFontSize+1, ...
                'ButtonPushedFcn',@(~,~)app.onAutoDigitize());
            app.AutoMode = uidropdown(app.UIFigure, ...
                'Items',{'Strict','Loose'}, ...
                'Value','Loose', ...
                'BackgroundColor',[1 1 1], ...
                'FontSize',app.UIFontSize);
            app.ButtonSave = uibutton(app.UIFigure,'push','Text','Save Data', ...
                'FontWeight','bold','FontSize',app.UIFontSize+1, ...
                'ButtonPushedFcn',@(~,~)app.onSave());

            app.LabelStatus = uilabel(app.UIFigure,'Text','', ...
                'BackgroundColor',app.UIColorBg, ...
                'FontSize',app.UIFontSize+1, ...
                'FontWeight','bold', ...
                'FontColor',[0.1 0.1 0.95]);

            app.applyLayout();
        end

        function applyLayout(app)
            fr = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];

            app.PanelX.Position = app.childPos(fr,[0.007,0.208,0.344,0.723]);
            app.PanelY.Position = app.childPos(fr,[0.354,0.208,0.344,0.723]);

            app.LabelXStart.Position = app.childPos(app.PanelX.Position,[0.028,0.692,0.274,0.2]);
            app.LabelXEnd.Position = app.childPos(app.PanelX.Position,[0.028,0.197,0.274,0.2]);
            app.EditXStart.Position = app.childPos(app.PanelX.Position,[0.306,0.615,0.282,0.338]);
            app.EditXEnd.Position = app.childPos(app.PanelX.Position,[0.306,0.108,0.282,0.338]);
            app.GroupX.Position = app.childPos(app.PanelX.Position,[0.597,0.11,0.37,0.86]);
            app.RadioXLinear.Position = app.childPos(app.GroupX.Position,[0.02,0.55,0.95,0.35]);
            app.RadioXLog.Position = app.childPos(app.GroupX.Position,[0.02,0.08,0.95,0.35]);

            app.LabelYStart.Position = app.childPos(app.PanelY.Position,[0.028,0.692,0.274,0.2]);
            app.LabelYEnd.Position = app.childPos(app.PanelY.Position,[0.028,0.197,0.274,0.2]);
            app.EditYStart.Position = app.childPos(app.PanelY.Position,[0.306,0.615,0.282,0.338]);
            app.EditYEnd.Position = app.childPos(app.PanelY.Position,[0.306,0.108,0.282,0.338]);
            app.GroupY.Position = app.childPos(app.PanelY.Position,[0.597,0.11,0.37,0.86]);
            app.RadioYLinear.Position = app.childPos(app.GroupY.Position,[0.02,0.55,0.95,0.35]);
            app.RadioYLog.Position = app.childPos(app.GroupY.Position,[0.02,0.08,0.95,0.35]);

            app.ButtonCalibrate.Position = app.childPos(fr,[0.713,0.683,0.117,0.208]);
            app.ButtonDigitize.Position = app.childPos(fr,[0.713,0.376,0.117,0.208]);
            app.ButtonAuto.Position = app.childPos(fr,[0.713,0.069,0.117,0.208]);
            app.AutoMode.Position = app.childPos(fr,[0.585,0.03,0.105,0.11]);

            app.ButtonUndo.Position = app.childPos(fr,[0.843,0.683,0.096,0.208]);
            app.ButtonGrid.Position = app.childPos(fr,[0.843,0.376,0.096,0.208]);
            app.ButtonSave.Position = app.childPos(fr,[0.843,0.069,0.096,0.208]);

            app.LabelStatus.Position = app.childPos(fr,[0.018,0.03,0.56,0.129]);
        end

        function initializeState(app)
            c = app.Context;
            if isfield(c,'MonZoom'), app.MonZoom = c.MonZoom; end
            if isfield(c,'val1'), app.val1 = c.val1; end
            if isfield(c,'figname'), app.figname = c.figname; end
            if isfield(c,'acfigmain'), app.acfigmain = c.acfigmain; end
            if isfield(c,'listbox_acmain'), app.listbox_acmain = c.listbox_acmain; end
            if isfield(c,'edit_acfigmain_dir'), app.edit_acfigmain_dir = c.edit_acfigmain_dir; end
            if isfield(c,'lang_choice'), app.lang_choice = c.lang_choice; end
            if isfield(c,'lang_id'), app.lang_id = c.lang_id; end
            if isfield(c,'lang_var'), app.lang_var = c.lang_var; end

            app.UIFigure.Name = app.getLang('dd00','Acycle: Plot Digitizer');
            app.PanelX.Title = app.getLang('dd14','X axis');
            app.PanelY.Title = app.getLang('dd15','Y axis');
            app.LabelXStart.Text = app.getLang('dd16','Start Point');
            app.LabelYStart.Text = app.getLang('dd16','Start Point');
            app.LabelXEnd.Text = app.getLang('dd17','End Point');
            app.LabelYEnd.Text = app.getLang('dd17','End Point');
            app.RadioXLinear.Text = app.getLang('main03','Linear');
            app.RadioYLinear.Text = app.getLang('main03','Linear');
            app.RadioXLog.Text = app.getLang('main04','Logarithmic');
            app.RadioYLog.Text = app.getLang('main04','Logarithmic');
            app.ButtonCalibrate.Text = app.getLang('dd04','Calibrate axis');
            app.ButtonDigitize.Text = app.getLang('dd19','Digitize');
            app.ButtonAuto.Text = app.getLang('dd21','Auto-digitize');
            app.ButtonUndo.Text = app.getLang('main19','Undo');
            app.ButtonGrid.Text = app.getLang('dd20','Grid Line');
            app.ButtonSave.Text = app.getLang('main01','Save Data');

            app.setStatus(app.getLang('dd02','Input the values in EditBoxs. Click Calibrate axis to set axis!'));
            app.openImageFigure();
            app.UIFigure.Position = app.normalizedToPixelPosition([0.02,0.80,0.5,0.11]);
            app.applyLayout();
        end

        function setStatus(app, msg)
            app.LabelStatus.Text = msg;
            drawnow;
        end

        function openImageFigure(app)
            if isempty(app.figname)
                return
            end

            if app.lang_choice == 0
                hwarn = warndlg('Wait, large image can be very slow');
            else
                hwarn = warndlg(app.getLang('dd01','Wait, large image can be very slow'));
            end

            try
                if ~isempty(app.DataExtractFig) && isgraphics(app.DataExtractFig)
                    close(app.DataExtractFig);
                end
            catch
            end

            app.warnMsg = '';
            try
                app.DataExtractFig = figure;
                set(app.DataExtractFig,'Name',app.getLang('dd22','Acycle: Original figure'),'NumberTitle','off');
                lastwarn('');
                imshow(app.figname);
                [warnMsg, ~] = lastwarn;
                app.warnMsg = warnMsg;
                if ~isempty(warnMsg)
                    close(app.DataExtractFig);
                    imscrollpanel_acDig(app.figname);
                    app.DataExtractFig = gcf;
                end
            catch
                imscrollpanel_acDig(app.figname);
                app.DataExtractFig = gcf;
            end

            set(app.DataExtractFig,'Units','normalized');
            set(app.DataExtractFig,'Position',[0.0,0.0,0.8,0.75]);
            try close(hwarn); catch, end
        end

        function tf = ensureImageFigure(app)
            tf = ~isempty(app.DataExtractFig) && isgraphics(app.DataExtractFig);
            if ~tf
                app.openImageFigure();
                tf = ~isempty(app.DataExtractFig) && isgraphics(app.DataExtractFig);
            end
        end

        function redrawImageAndOverlays(app)
            if ~app.ensureImageFigure()
                return
            end
            figure(app.DataExtractFig);
            clf(app.DataExtractFig);
            imshow(app.figname);
            hold on;
            if app.calibrated
                line(app.x00, app.y00, 'marker', '.', 'color', 'r', 'markersize', 20);
                line(app.x01, app.y01, 'marker', '.', 'color', 'r', 'markersize', 20);
                line([app.x00, app.x01], [app.y00, app.y01], 'color', 'r');
                line(app.x02, app.y02, 'marker', '.', 'color', 'r', 'markersize', 20);
                line(app.x03, app.y03, 'marker', '.', 'color', 'r', 'markersize', 20);
                line([app.x02, app.x03], [app.y02, app.y03], 'color', 'r');
            end
            for j = 1:size(app.tableDatai,1)
                line(app.tableDatai(j,2), app.tableDatai(j,3), 'marker', '+', 'color', 'r', 'markersize', 10);
            end
            hold off;
            set(app.DataExtractFig,'Units','normalized');
            set(app.DataExtractFig,'Position',[0.0,0.0,0.8,0.75]);
        end

        function [x,y,btn] = onePointInput(~)
            if exist('myginput','file') == 2
                [x,y,btn] = myginput(1,'crosshair');
            else
                [x,y,btn] = ginput(1);
            end
        end

        function [xv,yv] = convertPixelToValue(app, x, y)
            xmin = str2double(app.EditXStart.Value);
            xmax = str2double(app.EditXEnd.Value);
            ymin = str2double(app.EditYStart.Value);
            ymax = str2double(app.EditYEnd.Value);

            if app.RadioXLinear.Value
                xv = (xmax - xmin)*(x - app.x00)/(app.x01 - app.x00) + xmin;
            else
                xv = 10^((log10(xmax) - log10(xmin))*(x - app.x00)/(app.x01 - app.x00) + log10(xmin));
            end

            if app.RadioYLinear.Value
                yv = (ymax - ymin)*(y - app.y02)/(app.y03 - app.y02) + ymin;
            else
                yv = 10^((log10(ymax) - log10(ymin))*(log10(y) - log10(app.y02))/(log10(app.y03) - log10(app.y02)) + log10(ymin));
            end
        end

        function onCalibrate(app)
            if ~app.ensureImageFigure()
                return
            end

            if app.calibrated && size(app.tableData,1) > 0
                choice = questdlg('You are going to clear all points', 'Warning', 'Yes','No','No');
                if ~strcmp(choice,'Yes')
                    return
                end
            end

            app.tableData = zeros(0,3);
            app.tableDatai = zeros(0,3);
            app.YYY0 = zeros(0,2);
            app.YYY1 = zeros(0,2);
            app.YYYtrue = zeros(0,2);

            app.redrawImageAndOverlays();
            figure(app.DataExtractFig);

            app.setStatus(app.getLang('dd05','Locate the X-Axis Start point !!!'));
            [app.x00, app.y00, btn] = app.onePointInput();
            if isempty(btn) || btn ~= 1, return; end
            hold on; line(app.x00, app.y00, 'marker', '.', 'color', 'r', 'markersize', 20); hold off;

            app.setStatus(app.getLang('dd06','Locate the X-Axis End point !!!'));
            [app.x01, app.y01, btn] = app.onePointInput();
            if isempty(btn) || btn ~= 1, return; end
            hold on;
            line(app.x01, app.y01, 'marker', '.', 'color', 'r', 'markersize', 20);
            line([app.x00, app.x01], [app.y00, app.y01], 'color', 'r');
            hold off;

            app.setStatus(app.getLang('dd07','Locate the Y-Axis Start point !!!'));
            [app.x02, app.y02, btn] = app.onePointInput();
            if isempty(btn) || btn ~= 1, return; end
            hold on; line(app.x02, app.y02, 'marker', '.', 'color', 'r', 'markersize', 20); hold off;

            app.setStatus(app.getLang('dd08','Locate the Y-Axis End point !!!'));
            [app.x03, app.y03, btn] = app.onePointInput();
            if isempty(btn) || btn ~= 1, return; end
            hold on;
            line(app.x03, app.y03, 'marker', '.', 'color', 'r', 'markersize', 20);
            line([app.x02, app.x03], [app.y02, app.y03], 'color', 'r');
            hold off;

            app.calibrated = true;
            app.ButtonCalibrate.Text = app.getLang('dd10','Recalibrate axis');
            app.setStatus(app.getLang('dd09','Now Digitize the point, press RightButton to stop'));
        end

        function onDigitize(app)
            if ~app.calibrated
                app.setStatus('Please calibrate axis first.');
                warndlg('Please calibrate axis first.');
                return
            end
            if abs(app.x01-app.x00) < eps || abs(app.y03-app.y02) < eps
                warndlg('Invalid axis calibration. Please recalibrate.');
                return
            end
            if ~app.ensureImageFigure()
                return
            end

            figure(app.DataExtractFig);
            hold on;
            idx = size(app.tableData,1) + 1;
            con = 1;
            while con == 1
                app.setStatus(['Digitizing: point #',num2str(idx),' (Right click to stop)']);
                [x,y,con] = app.onePointInput();
                if isempty(con) || con ~= 1
                    break
                end
                [xv,yv] = app.convertPixelToValue(x,y);
                line(x, y, 'marker', '+', 'color', 'r', 'markersize', 10);

                app.tableData(idx,:) = [idx,xv,yv];
                app.tableDatai(idx,:) = [idx,x,y];
                disp(['>>  data info: i = ',num2str(idx), ', x = ', num2str(x), ', y = ',num2str(y)]);
                idx = idx + 1;
            end
            hold off;
            app.setStatus(['Digitize paused. Total points: ', num2str(size(app.tableData,1))]);
        end

        function onUndo(app)
            n = size(app.tableData,1);
            if n < 1
                return
            end
            app.tableData(end,:) = [];
            app.tableDatai(end,:) = [];
            app.redrawImageAndOverlays();
            app.setStatus(['Undo done. Current points: ',num2str(size(app.tableData,1))]);
        end

        function onSave(app)
            pre_dirML = pwd;
            CDac_pwd;
            cleanupObj = onCleanup(@()cd(pre_dirML)); %#ok<NASGU>

            if isempty(app.tableData)
                warndlg('No digitized points to save.');
                return
            end

            [~,dat_name,~] = fileparts(app.figname);
            name1 = [dat_name,'-Digit.txt'];
            name3 = [dat_name,'-DigitNo.txt'];
            if exist(name1,'file') || exist(name3,'file')
                for i = 1:100
                    name1 = [dat_name,'-Digit-', num2str(i),'.txt'];
                    name3 = [dat_name,'-DigitNo-',num2str(i),'.txt'];
                    if ~(exist(name1,'file') || exist(name3,'file'))
                        break
                    end
                end
            end

            dlmwrite(name1, app.tableData(:,2:3), 'delimiter', ' ', 'precision', 9);
            dlmwrite(name3, app.tableData, 'delimiter', ' ', 'precision', 9);

            if ~isempty(app.YYYtrue)
                dlmwrite('DataExtract-auto.txt', app.YYYtrue, 'delimiter', ' ', 'precision', 9);
            end

            app.refreshMainListbox();
            app.setStatus(['Saved ',num2str(size(app.tableData,1)),' points.']);
        end

        function onAutoDigitize(app)
            if ~app.calibrated
                warndlg('Please calibrate axis first.');
                app.setStatus('Please calibrate axis first.');
                return
            end
            if ~app.ensureImageFigure()
                return
            end
            if abs(app.x01-app.x00) < eps || abs(app.y03-app.y02) < eps
                warndlg('Invalid axis calibration. Please recalibrate.');
                return
            end

            I = imread(app.figname);
            gray = app.toGray(I);
            bw = app.buildCurveMask(gray);

            app.setStatus('Auto-digitize: left click seed(s), right click to stop.');
            figure(app.DataExtractFig);
            totalAdded = 0;
            while true
                [sx,sy,btn] = app.onePointInput();
                if isempty(btn) || btn ~= 1
                    app.setStatus(sprintf('Auto-digitize stopped. Added %d points this run.', totalAdded));
                    return
                end

                % Snap seed to nearest dark-pixel candidate to reduce click error.
                [sx,sy,okSeed] = app.snapSeedToMask(bw,round(sx),round(sy),18);
                if ~okSeed
                    [sx,sy,okSeed] = app.snapSeedToDark(gray,round(sx),round(sy),18);
                end
                if ~okSeed
                    app.setStatus('Seed is not on a detectable line. Try another point.');
                    continue
                end

                [pts, stopReason] = app.traceSeedCurve(bw, gray, sx, sy);
                if isempty(pts) || size(pts,1) < 8
                    app.setStatus('Track too short or unstable. Pick a new seed.');
                    continue
                end

                % Drop duplicates and near-duplicates in this segment.
                pts = unique(pts,'rows','stable');
                if size(pts,1) > 1
                    keep = [true; hypot(diff(pts(:,1)),diff(pts(:,2))) >= 1];
                    pts = pts(keep,:);
                end

                % Remove points already collected in previous runs.
                pts = app.removeExistingPixels(pts,2.0);
                if isempty(pts)
                    app.setStatus('This segment was already digitized. Pick another seed.');
                    continue
                end

                [xv,yv] = app.convertPixelBatchToValue(pts(:,1),pts(:,2));
                n0 = size(app.tableData,1);
                nNew = size(pts,1);
                idx = (n0+1:n0+nNew)';

                app.tableData = [app.tableData; [idx,xv,yv]]; %#ok<AGROW>
                app.tableDatai = [app.tableDatai; [idx,double(pts(:,1)),double(pts(:,2))]]; %#ok<AGROW>

                hold on;
                plot(pts(:,1),pts(:,2),'+','Color',[0 0.7 0],'MarkerSize',6);
                hold off;

                app.YYY0 = app.YYY1;
                app.YYY1 = double(pts);
                app.YYYtrue = [xv,yv];
                totalAdded = totalAdded + nNew;
                app.setStatus(sprintf('Auto +%d pts (total +%d). stop:%s. Mode=%s. Continue clicking seeds, right click to stop.', ...
                    nNew,totalAdded,stopReason,app.AutoMode.Value));
            end
        end

        function gray = toGray(~, I)
            if ndims(I) == 3
                gray = 0.2989*double(I(:,:,1)) + 0.5870*double(I(:,:,2)) + 0.1140*double(I(:,:,3));
            else
                gray = double(I);
            end
            if max(gray(:)) > 0
                gray = gray ./ max(gray(:));
            end
        end

        function bw = buildCurveMask(app, gray)
            % Black-pixel extraction for BW/near-BW plots.
            v = sort(gray(:));
            if strcmpi(app.AutoMode.Value,'Strict')
                q = 0.24;
            else
                q = 0.35;
            end
            idx = max(1, min(numel(v), round(q*numel(v))));
            t = v(idx);
            % Clamp to robust dark threshold range.
            t = min(max(t,0.05),0.45);
            bw = gray <= t;
            bw = app.applyPlotAreaMask(bw);
        end

        function [pts, stopReason] = traceSeedCurve(app, bw, gray, sx, sy)
            % Trace one curve by extracting seed-connected dark component,
            % then selecting one y per x with continuity constraints.
            [comp, okComp] = app.connectedComponentFromSeed(bw, sx, sy);
            if ~okComp
                pts = zeros(0,2);
                stopReason = 'no_component';
                return
            end

            [yy,xx] = find(comp);
            if isempty(xx)
                pts = zeros(0,2);
                stopReason = 'empty_component';
                return
            end

            if strcmpi(app.AutoMode.Value,'Strict')
                maxJump = 5;
                darkW = 0.18;
            else
                maxJump = 7;
                darkW = 0.12;
            end

            rx = max(xx) - min(xx) + 1;
            ry = max(yy) - min(yy) + 1;
            verticalMajor = ry > 1.25 * rx;

            pts = zeros(0,2);
            if verticalMajor
                uy = sort(unique(yy),'ascend');
                prevX = sx;
                lastY = uy(1)-1;
                for i = 1:numel(uy)
                    y = uy(i);
                    if y - lastY > 3 && strcmpi(app.AutoMode.Value,'Strict')
                        break
                    end
                    xs = xx(yy == y);
                    if isempty(xs), continue; end
                    c = abs(double(xs) - double(prevX)) + darkW*255*gray(sub2ind(size(gray),repmat(y,size(xs)),xs));
                    [cMin, kMin] = min(c);
                    xSel = xs(kMin);
                    if i > 1 && abs(double(xSel)-double(prevX)) > maxJump
                        if strcmpi(app.AutoMode.Value,'Strict')
                            break
                        else
                            [~,k2] = min(abs(double(xs)-double(prevX)));
                            xSel = xs(k2);
                        end
                    end
                    if cMin > maxJump*2 && strcmpi(app.AutoMode.Value,'Strict')
                        break
                    end
                    pts(end+1,:) = [xSel,y]; %#ok<AGROW>
                    prevX = xSel;
                    lastY = y;
                end
                stopReason = 'ok_v';
            else
                ux = sort(unique(xx),'ascend');
                prevY = sy;
                lastX = ux(1)-1;
                for i = 1:numel(ux)
                    x = ux(i);
                    if x - lastX > 3 && strcmpi(app.AutoMode.Value,'Strict')
                        break
                    end
                    ys = yy(xx == x);
                    if isempty(ys), continue; end
                    c = abs(double(ys) - double(prevY)) + darkW*255*gray(sub2ind(size(gray),ys,repmat(x,size(ys))));
                    [cMin, kMin] = min(c);
                    ySel = ys(kMin);
                    if i > 1 && abs(double(ySel)-double(prevY)) > maxJump
                        if strcmpi(app.AutoMode.Value,'Strict')
                            break
                        else
                            [~,k2] = min(abs(double(ys)-double(prevY)));
                            ySel = ys(k2);
                        end
                    end
                    if cMin > maxJump*2 && strcmpi(app.AutoMode.Value,'Strict')
                        break
                    end
                    pts(end+1,:) = [x,ySel]; %#ok<AGROW>
                    prevY = ySel;
                    lastX = x;
                end
                stopReason = 'ok_h';
            end

            if size(pts,1) < 3
                stopReason = 'short';
            end
        end

        function [sx,sy,ok] = snapSeedToDark(~, gray, sx, sy, rad)
            [h,w] = size(gray);
            x0 = max(1,sx-rad); x1 = min(w,sx+rad);
            y0 = max(1,sy-rad); y1 = min(h,sy+rad);
            patch = gray(y0:y1,x0:x1);
            if isempty(patch)
                ok = false;
                return
            end
            [v, k] = min(patch(:));
            if isempty(v) || v > 0.55
                ok = false;
                return
            end
            [yy,xx] = ind2sub(size(patch),k);
            sx = x0 + xx - 1;
            sy = y0 + yy - 1;
            ok = true;
        end

        function [comp, ok] = connectedComponentFromSeed(~, bw, sx, sy)
            [h,w] = size(bw);
            comp = false(h,w);
            ok = false;
            if sx < 1 || sx > w || sy < 1 || sy > h || ~bw(sy,sx)
                return
            end

            % BFS flood-fill (8-connected)
            q = zeros(numel(bw),2);
            head = 1; tail = 1;
            q(tail,:) = [sy,sx];
            comp(sy,sx) = true;
            nbr = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
            maxNodes = min(numel(bw), 2e6);
            nNodes = 1;

            while head <= tail
                y = q(head,1); x = q(head,2); head = head + 1;
                for k = 1:8
                    y2 = y + nbr(k,1);
                    x2 = x + nbr(k,2);
                    if y2 >= 1 && y2 <= h && x2 >= 1 && x2 <= w && bw(y2,x2) && ~comp(y2,x2)
                        tail = tail + 1;
                        q(tail,:) = [y2,x2];
                        comp(y2,x2) = true;
                        nNodes = nNodes + 1;
                        if nNodes >= maxNodes
                            ok = true;
                            return
                        end
                    end
                end
            end
            ok = nNodes > 0;
        end

        function [pts, stopReason] = trackDirection(~, bw, gray, sx, sy, dirX, yTol)
            [h,w] = size(bw);
            x = sx;
            y = sy;
            pts = zeros(0,2);
            gap = 0;
            maxGap = 4;
            maxStep = w;
            stopReason = 'edge';
            lambdaDark = 3.0;      % darker pixel preferred
            ambigCost = 0.05;      % if top two costs too close -> ambiguous
            ambigSpread = 2;       % and far apart in Y -> stop
            maxJump = max(2, round(yTol*0.8));
            dyPrev = 0;
            alpha = 0.7;           % slope memory

            for k = 1:maxStep
                x1 = x + dirX;
                if x1 < 1 || x1 > w
                    stopReason = 'edge';
                    break
                end
                yPred = round(y + dyPrev);
                y0 = max(1, yPred - yTol);
                y1 = min(h, yPred + yTol);
                ys = (y0:y1)';
                localMask = bw(y0:y1, x1);
                candYs = ys(localMask);

                if isempty(candYs)
                    gap = gap + 1;
                    if gap >= maxGap
                        stopReason = 'gap';
                        break
                    end
                    x = x1;
                    continue
                end
                gap = 0;

                c = zeros(numel(candYs),1);
                for i = 1:numel(candYs)
                    yy = candYs(i);
                    d1 = abs(yy - yPred)/max(1,yTol);
                    d2 = abs((yy - y) - dyPrev)/max(1,maxJump);
                    c(i) = d1 + 0.8*d2 + lambdaDark*gray(yy,x1);
                end
                [cs,ord] = sort(c,'ascend');
                bestY = candYs(ord(1));
                jump = bestY - y;
                if abs(jump) > maxJump
                    stopReason = 'jump';
                    break
                end

                % Uncertain branch crossing/noise: stop early (conservative).
                if numel(cs) >= 2
                    y2 = candYs(ord(2));
                    if abs(cs(2)-cs(1)) < ambigCost && abs(y2-bestY) >= ambigSpread
                        stopReason = 'ambiguous';
                        break
                    end
                end

                x = x1;
                y = bestY;
                dyPrev = alpha*dyPrev + (1-alpha)*jump;
                pts(end+1,:) = [x,y]; %#ok<AGROW>
            end
        end

        function [sx,sy,ok] = snapSeedToMask(~, bw, sx, sy, rad)
            [h,w] = size(bw);
            x0 = max(1,sx-rad); x1 = min(w,sx+rad);
            y0 = max(1,sy-rad); y1 = min(h,sy+rad);
            [yy,xx] = find(bw(y0:y1,x0:x1));
            if isempty(xx)
                ok = false;
                return
            end
            xx = xx + x0 - 1;
            yy = yy + y0 - 1;
            d2 = (xx-sx).^2 + (yy-sy).^2;
            [~,k] = min(d2);
            sx = xx(k);
            sy = yy(k);
            ok = true;
        end

        function bw = applyPlotAreaMask(app, bw)
            % Use axis calibration to constrain to plotting area and reduce false picks.
            xMin = floor(min([app.x00,app.x01,app.x02,app.x03]));
            xMax = ceil(max([app.x00,app.x01,app.x02,app.x03]));
            yMin = floor(min([app.y00,app.y01,app.y02,app.y03]));
            yMax = ceil(max([app.y00,app.y01,app.y02,app.y03]));
            [h,w] = size(bw);
            pad = 12;
            xMin = max(1,xMin-pad); xMax = min(w,xMax+pad);
            yMin = max(1,yMin-pad); yMax = min(h,yMax+pad);
            mask = false(h,w);
            if xMin < xMax && yMin < yMax
                mask(yMin:yMax,xMin:xMax) = true;
            else
                mask(:) = true;
            end
            bw = bw & mask;
        end

        function pts = removeExistingPixels(app, pts, dMin)
            if isempty(app.tableDatai)
                return
            end
            old = app.tableDatai(:,2:3);
            keep = true(size(pts,1),1);
            for i = 1:size(pts,1)
                dp = old - pts(i,:);
                if any(hypot(dp(:,1),dp(:,2)) <= dMin)
                    keep(i) = false;
                end
            end
            pts = pts(keep,:);
        end

        function [xv,yv] = convertPixelBatchToValue(app, x, y)
            xmin = str2double(app.EditXStart.Value);
            xmax = str2double(app.EditXEnd.Value);
            ymin = str2double(app.EditYStart.Value);
            ymax = str2double(app.EditYEnd.Value);

            x = double(x(:));
            y = double(y(:));

            if app.RadioXLinear.Value
                xv = (xmax - xmin)*(x - app.x00)/(app.x01 - app.x00) + xmin;
            else
                xv = 10.^((log10(xmax) - log10(xmin))*(x - app.x00)/(app.x01 - app.x00) + log10(xmin));
            end

            if app.RadioYLinear.Value
                yv = (ymax - ymin)*(y - app.y02)/(app.y03 - app.y02) + ymin;
            else
                yv = 10.^((log10(ymax) - log10(ymin))*(log10(y) - log10(app.y02))/(log10(app.y03) - log10(app.y02)) + log10(ymin));
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
        function app = plotdigitizer(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context,'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('plotdigitizer requires a handles/context struct input.');
            end

            app.createComponents();
            app.initializeState();
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            try
                if ~isempty(app.DataExtractFig) && isgraphics(app.DataExtractFig)
                    close(app.DataExtractFig);
                end
            catch
            end
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end
end
