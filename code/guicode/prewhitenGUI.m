classdef prewhitenGUI < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE prewhitenGUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure
        MainButtonGroup matlab.ui.container.ButtonGroup
        RadioClassic matlab.ui.control.RadioButton
        RadioRobust matlab.ui.control.RadioButton
        RadioUser matlab.ui.control.RadioButton
        EditClassic matlab.ui.control.EditField
        EditRobust matlab.ui.control.EditField
        EditUser matlab.ui.control.EditField
        RunButton matlab.ui.control.Button
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1

        lang_choice double = 0
        lang_id = {}
        lang_var = {}

        val1 double = 1
        slash_v
        acfigmain

        filename = ''
        dat_name = ''
        path_temp = ''
        listbox_acmain
        edit_acfigmain_dir
        ext = ''

        dat
        rho double = 0
        rhoM double = 0

        UIFontSize double = 11.5
        UIBgColor double = [0.94 0.94 0.94]
        EditEnabledColor double = [1 1 1]
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
            % Keep closer to the original GUIDE compact dialog size.
            w = max(230, normPos(3) * screenSize(3));
            h = max(165, normPos(4) * screenSize(4));
            x = screenSize(1) + normPos(1) * screenSize(3);
            y = screenSize(2) + normPos(2) * screenSize(4);
            x = min(max(x, screenSize(1)), screenSize(1) + screenSize(3) - w);
            y = min(max(y, screenSize(2)), screenSize(2) + screenSize(4) - h);
            pos = round([x, y, w, h]);
        end

        function p = childPos(~, parentPos, rel)
            p = round([rel(1)*parentPos(3), rel(2)*parentPos(4), rel(3)*parentPos(3), rel(4)*parentPos(4)]);
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
            fr = [0, 0, app.UIFigure.Position(3), app.UIFigure.Position(4)];
            app.MainButtonGroup.Position = app.childPos(fr, [0.08,0.08,0.82,0.82]);

            app.RadioClassic.Position = app.childPos(app.MainButtonGroup.Position, [0.02,0.68,0.65,0.207]);
            app.RadioRobust.Position = app.childPos(app.MainButtonGroup.Position, [0.02,0.45,0.65,0.207]);
            app.RadioUser.Position = app.childPos(app.MainButtonGroup.Position, [0.02,0.22,0.65,0.207]);

            app.EditClassic.Position = app.childPos(app.MainButtonGroup.Position, [0.68,0.68,0.331,0.18]);
            app.EditRobust.Position = app.childPos(app.MainButtonGroup.Position, [0.68,0.45,0.331,0.18]);
            app.EditUser.Position = app.childPos(app.MainButtonGroup.Position, [0.68,0.22,0.331,0.18]);

            % In the original GUIDE dialog, button is visually inside the panel.
            app.RunButton.Position = app.childPos(app.MainButtonGroup.Position, [0.31,0.05,0.38,0.16]);
        end

        function onRun(app, ~, ~)
            if app.RadioClassic.Value
                options = struct('rho_source','classic');
            elseif app.RadioRobust.Value
                options = struct('rho_source','robust');
            else
                options = struct( ...
                    'rho_source','user', ...
                    'rho',str2double(app.EditUser.Value));
            end

            try
                [datp,audit] = acyclePrewhitenSeries(app.dat,options);
            catch analysisError
                errordlg(analysisError.message,'Pre-whitening error');
                return
            end
            rho1 = audit.rho;

            [~, main21] = ismember('main21', app.lang_id);
            [~, main23] = ismember('main23', app.lang_id);
            [~, main24] = ismember('main24', app.lang_id);
            [~, main01] = ismember('main01', app.lang_id);

            figure;
            plot(datp(:,1), datp(:,2), 'k', 'LineWidth', 1);
            if main23 > 0 && main21 > 0
                xlabel([app.lang_var{main23}, '/', app.lang_var{main21}]);
            else
                xlabel('Depth/Time');
            end
            if main24 > 0
                ylabel(app.lang_var{main24});
            else
                ylabel('Value');
            end
            xlim([min(datp(:,1)), max(datp(:,1))]);

            name0 = [app.dat_name, '-', 'prewhiten-', num2str(rho1)];
            name1 = [name0, app.ext];
            CDac_pwd;
            dlmwrite(name1, datp, 'delimiter', ' ', ...
                'precision', 9); %#ok<DLMWT>

            if main01 > 0
                disp(['>> ', app.lang_var{main01}, ' : ', name1]);
            else
                disp(['>> save data: ', name1]);
            end

            app.refreshMainListbox();
            cd(pre_dirML);
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

        function createComponents(app)
            app.UIFigure = uifigure('Name', 'Acycle: prewhiten', ...
                'Color', app.UIBgColor, ...
                'Resize', 'on', ...
                'Position', app.normalizedToPixelPosition([0.15,0.75,0.15,0.15]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.MainButtonGroup = uibuttongroup(app.UIFigure, ...
                'Title', 'AR1 model', ...
                'BackgroundColor', app.UIBgColor, ...
                'FontSize', app.UIFontSize);

            app.RadioClassic = uiradiobutton(app.MainButtonGroup, 'Text', 'Classic AR1', 'FontSize', app.UIFontSize);
            app.RadioRobust = uiradiobutton(app.MainButtonGroup, 'Text', 'Robust AR1', 'FontSize', app.UIFontSize);
            app.RadioUser = uiradiobutton(app.MainButtonGroup, 'Text', 'User defined', 'FontSize', app.UIFontSize);

            app.EditClassic = uieditfield(app.MainButtonGroup, 'text', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.EditEnabledColor, ...
                'HorizontalAlignment', 'center', 'Editable', 'off');
            app.EditRobust = uieditfield(app.MainButtonGroup, 'text', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.EditEnabledColor, ...
                'HorizontalAlignment', 'center', 'Editable', 'off');
            app.EditUser = uieditfield(app.MainButtonGroup, 'text', ...
                'FontSize', app.UIFontSize, 'BackgroundColor', app.EditEnabledColor, ...
                'HorizontalAlignment', 'center');

            app.RunButton = uibutton(app.MainButtonGroup, 'push', 'Text', 'Prewhiten', ...
                'FontSize', app.UIFontSize, ...
                'ButtonPushedFcn', @(s,e)app.onRun(s,e));

            app.applyLayout();
        end

        function initializeState(app)
            if isfield(app.Context, 'MonZoom'), app.MonZoom = app.Context.MonZoom; end
            if isfield(app.Context, 'sortdata'), end
            if isfield(app.Context, 'val1'), app.val1 = app.Context.val1; end
            if isfield(app.Context, 'lang_choice'), app.lang_choice = app.Context.lang_choice; end
            if isfield(app.Context, 'lang_id'), app.lang_id = app.Context.lang_id; end
            if isfield(app.Context, 'lang_var'), app.lang_var = app.Context.lang_var; end

            if isfield(app.Context, 'slash_v'), app.slash_v = app.Context.slash_v; end
            if isfield(app.Context, 'acfigmain'), app.acfigmain = app.Context.acfigmain; end
            if isfield(app.Context, 'data_name'), app.filename = app.Context.data_name; end
            if isfield(app.Context, 'dat_name'), app.dat_name = app.Context.dat_name; end
            if isfield(app.Context, 'path_temp'), app.path_temp = app.Context.path_temp; end
            if isfield(app.Context, 'listbox_acmain'), app.listbox_acmain = app.Context.listbox_acmain; end
            if isfield(app.Context, 'edit_acfigmain_dir'), app.edit_acfigmain_dir = app.Context.edit_acfigmain_dir; end

            [~,~,ext] = fileparts(app.filename);
            app.ext = ext;

            [~, a177] = ismember('a177',app.lang_id);
            [~, a173] = ismember('a173',app.lang_id);
            [~, a174] = ismember('a174',app.lang_id);
            [~, a175] = ismember('a175',app.lang_id);
            [~, a176] = ismember('a176',app.lang_id);
            [~, a178] = ismember('a178',app.lang_id);

            app.UIFigure.Name = ['Acycle: ', app.getLang('a177', 'Prewhiten')];
            app.MainButtonGroup.Title = app.getLang('a173', 'AR1 model');
            app.RadioClassic.Text = app.getLang('a174', 'Classic AR1');
            app.RadioRobust.Text = app.getLang('a175', 'Robust AR1');
            app.RadioUser.Text = app.getLang('a176', 'User defined');
            app.RunButton.Text = app.getLang('a177', 'Prewhiten');

            dat = app.Context.current_data;
            dat = dat(all(isfinite(dat(:,1:2)),2),:);
            if size(dat,1) < 2
                error('prewhitenGUI:InsufficientFiniteData', ...
                    ['Pre-whitening requires at least two finite ', ...
                     'unique samples.']);
            end
            diffx = diff(dat(:,1));
            if sum(diffx <= 0) > 0
                if a178 > 0
                    disp(app.lang_var{a178});
                end
                dat = sortrows(dat);
            end
            dat = findduplicate(dat);
            if size(dat,1) < 2
                error('prewhitenGUI:InsufficientUniqueData', ...
                    ['Pre-whitening requires at least two finite ', ...
                     'unique samples.']);
            end
            if acycleSamplingIsUneven(dat(:,1))
                warndlg(app.getLang('ec25', ...
                    'Input data should be equally spaced.'));
                dat = interpolate(dat,median(diff(dat(:,1))));
            end

            app.dat = dat;
            [~,classicAudit] = acyclePrewhitenSeries( ...
                app.dat,struct('rho_source','classic'));
            [~,robustAudit] = acyclePrewhitenSeries( ...
                app.dat,struct('rho_source','robust'));
            app.rho = classicAudit.rho;
            app.rhoM = robustAudit.rho;

            app.EditClassic.Value = num2str(app.rho);
            app.EditRobust.Value = num2str(app.rhoM);
            app.EditUser.Value = '1';

            app.RadioClassic.Value = false;
            app.RadioRobust.Value = true;
            app.RadioUser.Value = false;

            app.UIFigure.Position = app.normalizedToPixelPosition([0.15,0.75,0.15,0.15]);
            app.applyLayout();
        end
    end

    methods (Access = public)
        function app = prewhitenGUI(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
            else
                error('prewhitenGUI requires a handles/context struct input.');
            end

            app.createComponents();
            try
                app.initializeState();
            catch initializationError
                delete(app);
                rethrow(initializationError);
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
