classdef languageGUI < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE language dialog.

    properties (Access = public)
        UIFigure              matlab.ui.Figure
        PromptLabel           matlab.ui.control.Label
        LanguageDropDown      matlab.ui.control.DropDown
        OKButton              matlab.ui.control.Button
    end

    properties (Access = private)
        Context struct = struct()
        LangChoice double = 0
        LangID
        LangVar
    end

    methods (Access = private)
        function closeMainACFigure(app)
            % 1) Prefer the original main-figure handle passed from AC.m.
            if isfield(app.Context, 'acfigmain')
                hMain = app.Context.acfigmain;
                if ~isempty(hMain) && all(isgraphics(hMain))
                    try
                        close(hMain);
                    catch
                        try
                            delete(hMain);
                        catch
                        end
                    end
                end
            end

            % 2) Fallback: close GUIDE figure instances loaded from AC.fig.
            figs = findall(groot, 'Type', 'figure');
            for k = 1:numel(figs)
                h = figs(k);
                try
                    figFile = get(h, 'FileName');
                catch
                    figFile = '';
                end

                if ischar(figFile) && ~isempty(figFile)
                    [~, fn, ext] = fileparts(figFile);
                    if strcmpi([fn, ext], 'AC.fig')
                        try
                            close(h);
                        catch
                            try
                                delete(h);
                            catch
                            end
                        end
                    end
                end
            end
        end

        function restartAcycle(app)
            closeMainACFigure(app);
            pause(0.1);

            % Run startup entry first (equivalent to rerun ac.m).
            try
                ac;
            catch
                % Backward-compatible fallback.
                AC;
            end
        end

        function p = locateResource(app, filename)
            p = which(filename);
            if ~isempty(p)
                return
            end

            guiDir = fileparts(mfilename('fullpath'));
            candidate = fullfile(guiDir, '..', 'bin', filename);
            if exist(candidate, 'file') == 2
                p = candidate;
            else
                p = filename;
            end
        end

        function val = mapLanguageToValue(~, languageChoice)
            switch languageChoice
                case 'English'
                    val = 0;
                case '中文简体'
                    val = 1;
                case '中文繁體'
                    val = 2;
                case 'हिंदी'
                    val = 3;
                case 'Español'
                    val = 4;
                case 'Français'
                    val = 5;
                case 'عربي'
                    val = 6;
                case 'বাংলা'
                    val = 7;
                case 'Русский'
                    val = 8;
                case 'Português'
                    val = 9;
                case 'Deutsch'
                    val = 10;
                case 'やまと'
                    val = 11;
                case 'Italiano'
                    val = 12;
                case 'Türk'
                    val = 13;
                case 'українська'
                    val = 14;
                case 'Polski'
                    val = 15;
                case 'rumuński'
                    val = 16;
                case 'Nederlands'
                    val = 17;
                case '한국인'
                    val = 18;
                case 'Português do Brasil'
                    val = 19;
                otherwise
                    val = 0;
            end
        end

        function languageChoice = mapValueToLanguage(~, val)
            switch val
                case 0
                    languageChoice = 'English';
                case 1
                    languageChoice = '中文简体';
                case 2
                    languageChoice = '中文繁體';
                case 3
                    languageChoice = 'हिंदी';
                case 4
                    languageChoice = 'Español';
                case 5
                    languageChoice = 'Français';
                case 6
                    languageChoice = 'عربي';
                case 7
                    languageChoice = 'বাংলা';
                case 8
                    languageChoice = 'Русский';
                case 9
                    languageChoice = 'Português';
                case 10
                    languageChoice = 'Deutsch';
                case 11
                    languageChoice = 'やまと';
                case 12
                    languageChoice = 'Italiano';
                case 13
                    languageChoice = 'Türk';
                case 14
                    languageChoice = 'українська';
                case 15
                    languageChoice = 'Polski';
                case 16
                    languageChoice = 'rumuński';
                case 17
                    languageChoice = 'Nederlands';
                case 18
                    languageChoice = '한국인';
                case 19
                    languageChoice = 'Português do Brasil';
                otherwise
                    languageChoice = 'English';
            end
        end

        function applyLocalizedTexts(app, langVar)
            [~, locb] = ismember('l00', app.LangID);
            [~, locb1] = ismember('l01', app.LangID);
            [~, locb2] = ismember('main00', app.LangID);

            if locb > 0
                app.UIFigure.Name = langVar{locb};
            else
                app.UIFigure.Name = 'Acycle: Language';
            end

            if locb1 > 0
                app.PromptLabel.Text = langVar{locb1};
            else
                app.PromptLabel.Text = 'Select language';
            end

            if locb2 > 0
                app.OKButton.Text = langVar{locb2};
            else
                app.OKButton.Text = 'OK';
            end
        end

        function onOKButtonPushed(app, ~, ~)
            languageChoice = app.LanguageDropDown.Value;
            langChoice = mapLanguageToValue(app, languageChoice);

            acLangPath = locateResource(app, 'ac_lang.txt');
            if exist(acLangPath, 'file') == 2
                acLangIni = load(acLangPath);
            else
                acLangIni = 0;
            end

            if langChoice == acLangIni
                return
            end

            langdictPath = locateResource(app, 'langdict.xlsx');
            langdict = readtable(langdictPath);
            langVar2 = table2cell(langdict(:, 2 + langChoice));

            [~, msg1] = ismember('msg1', app.LangID);
            if msg1 > 0
                s = msgbox(langVar2{msg1}, 'Acycle');
            else
                s = msgbox('Language has been updated. Please restart Acycle.', 'Acycle');
            end

            fid = fopen(acLangPath, 'wt');
            if fid ~= -1
                fprintf(fid, '%d', langChoice);
                fclose(fid);
            end

            app.LangVar = table2cell(langdict(:, 2 + langChoice));
            applyLocalizedTexts(app, app.LangVar);
            app.LangChoice = langChoice;

            restartAcycle(app);

            try
                close(s);
                pause(0.5);
            catch
            end
            delete(app);
        end

        function createComponents(app)
            monZoom = 1;
            if isfield(app.Context, 'MonZoom')
                monZoom = app.Context.MonZoom;
            end

            baseNorm = [0.5, 0.7, 0.15, 0.15];
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

            screenSize = get(groot, 'ScreenSize');
            figPos = [ ...
                max(1, screenSize(1) + normPos(1) * screenSize(3)), ...
                max(1, screenSize(2) + normPos(2) * screenSize(4)), ...
                max(320, normPos(3) * screenSize(3)), ...
                max(180, normPos(4) * screenSize(4)) ...
                ];

            app.UIFigure = uifigure( ...
                'Name', 'Acycle: Language', ...
                'Position', round(figPos), ...
                'Resize', 'on', ...
                'Color', [1 1 1]);

            grid = uigridlayout(app.UIFigure, [3 1]);
            grid.RowHeight = {'1x', '1x', 'fit'};
            grid.ColumnWidth = {'1x'};
            grid.Padding = [20 18 20 16];
            grid.RowSpacing = 8;

            app.PromptLabel = uilabel(grid, ...
                'Text', 'Select language', ...
                'FontSize', 12, ...
                'HorizontalAlignment', 'center');
            app.PromptLabel.Layout.Row = 1;

            app.LanguageDropDown = uidropdown(grid, ...
                'Items', {'English', '中文简体', '中文繁體', 'Deutsch', 'Español', ...
                'Français', 'Italiano', 'Nederlands', 'rumuński', 'Polski', ...
                'Português', 'Português do Brasil', 'Русский', 'Türk', ...
                'українська', 'हिंदी', 'عربي', 'やまと', 'বাংলা', '한국인'}, ...
                'Value', 'English', ...
                'FontSize', 12);
            app.LanguageDropDown.Layout.Row = 2;

            app.OKButton = uibutton(grid, 'push', ...
                'Text', 'OK', ...
                'FontSize', 12, ...
                'ButtonPushedFcn', @(src, event)onOKButtonPushed(app, src, event));
            app.OKButton.Layout.Row = 3;
        end
    end

    methods (Access = public)
        function app = languageGUI(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
            end

            if isfield(app.Context, 'lang_choice')
                app.LangChoice = app.Context.lang_choice;
            end
            if isfield(app.Context, 'lang_id')
                app.LangID = app.Context.lang_id;
            else
                app.LangID = {};
            end
            if isfield(app.Context, 'lang_var')
                app.LangVar = app.Context.lang_var;
            else
                app.LangVar = {};
            end

            createComponents(app);

            if app.LangChoice > 0 && ~isempty(app.LangVar) && ~isempty(app.LangID)
                applyLocalizedTexts(app, app.LangVar);
            end

            selected = mapValueToLanguage(app, app.LangChoice);
            if ismember(selected, app.LanguageDropDown.Items)
                app.LanguageDropDown.Value = selected;
            end

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
