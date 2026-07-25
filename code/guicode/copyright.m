classdef copyright < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE copyright dialog.

    properties (Access = public)
        UIFigure         matlab.ui.Figure
        MainGrid         matlab.ui.container.GridLayout
        HeaderGrid       matlab.ui.container.GridLayout
        LogoAxes         matlab.ui.control.UIAxes
        HeaderLabel      matlab.ui.control.Label
        DetailsTextArea  matlab.ui.control.TextArea
    end

    properties (Access = private)
        Context struct = struct()
        LangChoice double = 0
        LangID = {}
        LangVar = {}
    end

    methods (Access = private)
        function screenSize = getScreenSizePixels(~)
            oldUnits = get(groot, 'Units');
            set(groot, 'Units', 'pixels');
            screenSize = get(groot, 'ScreenSize');
            set(groot, 'Units', oldUnits);
        end

        function p = locateResource(app, filename)
            p = which(filename);
            if ~isempty(p)
                return
            end

            guiDir = fileparts(mfilename('fullpath'));
            candidates = { ...
                fullfile(guiDir, filename), ...
                fullfile(guiDir, '..', 'icons', filename), ...
                fullfile(guiDir, '..', 'bin', filename), ...
                fullfile(guiDir, '..', '..', filename), ...
                fullfile(guiDir, '..', '..', 'doc', filename) ...
                };

            p = '';
            for i = 1:numel(candidates)
                if exist(candidates{i}, 'file') == 2
                    p = candidates{i};
                    return
                end
            end
            p = filename;
        end

        function lines = fallbackCopyrightText(~)
            lines = {
                'Copyright (C) 2017-2023';
                'Copyright text file is missing.';
                'Expected: acycle/doc/copyright_text.txt'
                };
        end

        function lines = loadCopyrightLines(app)
            lines = {};
            textPath = app.locateResource('copyright_text.txt');
            try
                if exist(textPath, 'file') == 2
                    fid = fopen(textPath, 'r');
                    if fid ~= -1
                        data = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
                        fclose(fid);
                        if ~isempty(data) && ~isempty(data{1})
                            lines = data{1};
                        end
                    end
                end
            catch
                try
                    fclose(fid);
                catch
                end
            end

            if isempty(lines)
                lines = app.fallbackCopyrightText();
            end
        end

        function applyLocalizedTexts(app)
            if app.LangChoice > 0 && ~isempty(app.LangID) && ~isempty(app.LangVar)
                [~, locName] = ismember('c60', app.LangID);
                if locName > 0
                    app.UIFigure.Name = app.LangVar{locName};
                else
                    app.UIFigure.Name = 'Acycle: Copyright';
                end

                [~, loc1] = ismember('c61', app.LangID);
                [~, loc2] = ismember('c65', app.LangID);
                [~, loc3] = ismember('c62', app.LangID);
                [~, loc4] = ismember('c63', app.LangID);
                [~, loc5] = ismember('c64', app.LangID);

                headerLines = {''; 'Acycle'; ''; 'Time-Series Analysis Software'; ''; 'Copyright'};
                if loc1 > 0 && loc2 > 0 && loc3 > 0 && loc4 > 0 && loc5 > 0
                    headerLines = {''; [app.LangVar{loc1}, ' (', app.LangVar{loc2}, ') ']; ''; app.LangVar{loc3}; ''; [app.LangVar{loc4}, app.LangVar{loc5}]};
                end
                app.HeaderLabel.Text = strjoin(headerLines, newline);
            else
                app.UIFigure.Name = 'Acycle: Copyright';
            end
        end

        function createComponents(app)
            monZoom = 1;
            if isfield(app.Context, 'MonZoom')
                monZoom = app.Context.MonZoom;
            end

            baseNorm = [0.5, 0.1, 0.45, 0.5];
            if isnumeric(monZoom)
                if isscalar(monZoom)
                    normPos = baseNorm * monZoom;
                elseif numel(monZoom) >= 4
                    normPos = baseNorm .* monZoom(1:4);
                else
                    normPos = baseNorm;
                end
            else
                normPos = baseNorm;
            end

            screenSize = app.getScreenSizePixels();
            figW = max(320, normPos(3) * screenSize(3));
            figH = max(220, normPos(4) * screenSize(4));
            figX = screenSize(1) + normPos(1) * screenSize(3);
            figY = screenSize(2) + normPos(2) * screenSize(4);

            % Keep window fully inside current screen work area.
            figX = min(max(figX, screenSize(1)), screenSize(1) + screenSize(3) - figW);
            figY = min(max(figY, screenSize(2)), screenSize(2) + screenSize(4) - figH);
            figPos = [figX, figY, figW, figH];

            app.UIFigure = uifigure( ...
                'Name', 'Acycle: Copyright', ...
                'Position', round(figPos), ...
                'Color', [1 1 1]);

            app.MainGrid = uigridlayout(app.UIFigure, [2 1]);
            app.MainGrid.RowHeight = {110, '1x'};
            app.MainGrid.ColumnWidth = {'1x'};
            app.MainGrid.Padding = [14 12 14 12];
            app.MainGrid.RowSpacing = 8;

            app.HeaderGrid = uigridlayout(app.MainGrid, [1 2]);
            app.HeaderGrid.RowHeight = {'1x'};
            app.HeaderGrid.ColumnWidth = {120, '1x'};
            app.HeaderGrid.Padding = [0 0 0 0];
            app.HeaderGrid.ColumnSpacing = 10;
            app.HeaderGrid.Layout.Row = 1;

            app.LogoAxes = uiaxes(app.HeaderGrid);
            app.LogoAxes.Layout.Row = 1;
            app.LogoAxes.Layout.Column = 1;
            app.LogoAxes.Visible = 'off';

            app.HeaderLabel = uilabel(app.HeaderGrid, ...
                'Text', sprintf('%s\n%s\n%s\n%s', ...
                'Acycle v3.0 (Feb 21, 2026)', ...
                'Mingsong Li (Peking University) & Linda A. Hinnov (George Mason)', ...
                'Website: acycle.org', ...
                'github.com/mingsongli/acycle'), ...
                'FontSize', 12, ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center');
            app.HeaderLabel.Layout.Row = 1;
            app.HeaderLabel.Layout.Column = 2;

            detailsValue = app.fallbackCopyrightText();
            try
                detailsValue = app.loadCopyrightLines();
            catch
            end

            app.DetailsTextArea = uitextarea(app.MainGrid, ...
                'Editable', 'off', ...
                'Value', detailsValue, ...
                'FontSize', 12, ...
                'BackgroundColor', [1 1 1]);
            app.DetailsTextArea.Layout.Row = 2;

            logoPath = app.locateResource('acycle_logo.png');
            if exist(logoPath, 'file') == 2
                try
                    [I, map] = imread(logoPath);
                    if isempty(map)
                        imshow(I, 'Parent', app.LogoAxes);
                    else
                        imshow(I, map, 'Parent', app.LogoAxes);
                    end
                    axis(app.LogoAxes, 'off');
                catch
                end
            end
        end
    end

    methods (Access = public)
        function app = copyright(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
            end

            if isfield(app.Context, 'lang_choice')
                app.LangChoice = app.Context.lang_choice;
            end
            if isfield(app.Context, 'lang_id')
                app.LangID = app.Context.lang_id;
            end
            if isfield(app.Context, 'lang_var')
                app.LangVar = app.Context.lang_var;
            end

            app.createComponents();
            app.applyLocalizedTexts();

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
