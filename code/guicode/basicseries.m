classdef basicseries < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE basicseries GUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure

        LabelSolution matlab.ui.control.Label
        DropSolution matlab.ui.control.DropDown

        LabelParam matlab.ui.control.Label
        DropParam matlab.ui.control.DropDown

        LabelTime matlab.ui.control.Label
        LabelFrom matlab.ui.control.Label
        LabelTo matlab.ui.control.Label
        LabelKA1 matlab.ui.control.Label
        LabelKA2 matlab.ui.control.Label
        EditT1 matlab.ui.control.EditField
        EditT2 matlab.ui.control.EditField

        ButtonOK matlab.ui.control.Button

        PanelETP matlab.ui.container.Panel
        LabelEcc matlab.ui.control.Label
        LabelObl matlab.ui.control.Label
        LabelPre matlab.ui.control.Label
        EditEcc matlab.ui.control.EditField
        EditObl matlab.ui.control.EditField
        EditPre matlab.ui.control.EditField

        TextRef matlab.ui.control.TextArea
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

        solution char = 'La2004'
        parameterKey char = 'ETP'
        refType double = 1
        t1 double = 0
        t2 double = 1000
        basicdata = []

        noteLa04 char
        noteLa10 char
        noteWu13 char
        noteZB18a char

        solutionItems cell = {}
        paramDisplayToKey
        dataDir char = ''

        UIColorBg double = [0.94 0.94 0.94]
        UIColorBlue double = [0.08 0.02 0.95]
        UIFontSize double = 11.5
    end

    methods (Access = private)
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
            w = max(1150, normPos(3)*screen(3));
            h = max(520, normPos(4)*screen(4));
            x = screen(1) + normPos(1)*screen(3);
            y = screen(2) + normPos(2)*screen(4);
            x = min(max(x,screen(1)), screen(1)+screen(3)-w);
            y = min(max(y,screen(2)), screen(2)+screen(4)-h);
            pos = round([x y w h]);
        end

        function p = childPos(~, parentPos, rel)
            p = round([rel(1)*parentPos(3), rel(2)*parentPos(4), rel(3)*parentPos(3), rel(4)*parentPos(4)]);
        end

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

        function txt = parameterLabel(app, key)
            switch key
                case 'ETP'
                    txt = app.getLang('b06','ETP');
                case 'Eccentricity'
                    txt = app.getLang('b08','Eccentricity');
                case 'Obliquity'
                    txt = app.getLang('b09','Obliquity');
                case 'Precession'
                    txt = app.getLang('b10','Precession');
                case 'Inclination'
                    txt = app.getLang('b11','Inclination');
                otherwise
                    txt = key;
            end
        end

        function createComponents(app)
            app.UIFigure = uifigure('Name','Acycle: Astronomical Solutions', ...
                'Color',app.UIColorBg, ...
                'Resize','on', ...
                'Position', app.normalizedToPixelPosition([0.25,0.25,0.5,0.3]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.LabelSolution = uilabel(app.UIFigure,'Text','Astronomical solutions', ...
                'FontSize',app.UIFontSize+2,'BackgroundColor',app.UIColorBg);
            app.DropSolution = uidropdown(app.UIFigure, ...
                'FontSize',app.UIFontSize+1,'BackgroundColor',[1 1 1], ...
                'ValueChangedFcn',@(~,~)app.onSolutionChanged());

            app.LabelParam = uilabel(app.UIFigure,'Text','Astronomical parameters', ...
                'FontSize',app.UIFontSize+2,'BackgroundColor',app.UIColorBg);
            app.DropParam = uidropdown(app.UIFigure, ...
                'FontSize',app.UIFontSize+1,'BackgroundColor',[1 1 1], ...
                'ValueChangedFcn',@(~,~)app.onParameterChanged());

            app.LabelTime = uilabel(app.UIFigure,'Text','Time Interval', ...
                'FontSize',app.UIFontSize+2,'BackgroundColor',app.UIColorBg);
            app.LabelFrom = uilabel(app.UIFigure,'Text','From t1', ...
                'FontSize',app.UIFontSize+1,'BackgroundColor',app.UIColorBg);
            app.LabelTo = uilabel(app.UIFigure,'Text','To t2', ...
                'FontSize',app.UIFontSize+1,'BackgroundColor',app.UIColorBg);
            app.LabelKA1 = uilabel(app.UIFigure,'Text','k.a.', ...
                'FontSize',app.UIFontSize+1,'BackgroundColor',app.UIColorBg);
            app.LabelKA2 = uilabel(app.UIFigure,'Text','k.a.', ...
                'FontSize',app.UIFontSize+1,'BackgroundColor',app.UIColorBg);

            app.EditT1 = uieditfield(app.UIFigure,'text','Value','0', ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+1, ...
                'BackgroundColor',[1 1 1], ...
                'ValueChangedFcn',@(~,~)app.onT1Changed());
            app.EditT2 = uieditfield(app.UIFigure,'text','Value','1000', ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+1, ...
                'BackgroundColor',[1 1 1], ...
                'ValueChangedFcn',@(~,~)app.onT2Changed());

            app.ButtonOK = uibutton(app.UIFigure,'push','Text','OK', ...
                'FontSize',app.UIFontSize+3,'FontWeight','bold', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'ButtonPushedFcn',@(~,~)app.onRun());

            app.PanelETP = uipanel(app.UIFigure,'Title','ETP weight', ...
                'FontSize',app.UIFontSize+2,'FontWeight','bold', ...
                'BackgroundColor',app.UIColorBg);
            app.LabelEcc = uilabel(app.PanelETP,'Text','Eccentricity', ...
                'FontSize',app.UIFontSize+2,'BackgroundColor',app.UIColorBg);
            app.LabelObl = uilabel(app.PanelETP,'Text','Obliquity', ...
                'FontSize',app.UIFontSize+2,'BackgroundColor',app.UIColorBg);
            app.LabelPre = uilabel(app.PanelETP,'Text','Precession', ...
                'FontSize',app.UIFontSize+2,'BackgroundColor',app.UIColorBg);

            app.EditEcc = uieditfield(app.PanelETP,'text','Value','1', ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+2, ...
                'BackgroundColor',[1 1 1]);
            app.EditObl = uieditfield(app.PanelETP,'text','Value','1', ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+2, ...
                'BackgroundColor',[1 1 1]);
            app.EditPre = uieditfield(app.PanelETP,'text','Value','-1', ...
                'HorizontalAlignment','center','FontSize',app.UIFontSize+2, ...
                'BackgroundColor',[1 1 1]);

            app.TextRef = uitextarea(app.UIFigure, ...
                'Editable','off','FontSize',app.UIFontSize+1, ...
                'BackgroundColor',app.UIColorBg,'Value',{' '});

            app.applyLayout();
        end

        function applyLayout(app)
            fr = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];

            app.LabelSolution.Position = app.childPos(fr,[0.064,0.84,0.24,0.06]);
            app.LabelTime.Position = app.childPos(fr,[0.47,0.84,0.2,0.06]);

            app.DropSolution.Position = app.childPos(fr,[0.043,0.67,0.3,0.1]);
            app.LabelParam.Position = app.childPos(fr,[0.043,0.568,0.3,0.06]);
            app.DropParam.Position = app.childPos(fr,[0.043,0.407,0.3,0.1]);

            app.LabelFrom.Position = app.childPos(fr,[0.4,0.707,0.09,0.06]);
            app.LabelTo.Position = app.childPos(fr,[0.4,0.619,0.09,0.06]);
            app.LabelKA1.Position = app.childPos(fr,[0.628,0.707,0.07,0.06]);
            app.LabelKA2.Position = app.childPos(fr,[0.628,0.619,0.07,0.06]);
            app.EditT1.Position = app.childPos(fr,[0.48,0.69,0.13,0.09]);
            app.EditT2.Position = app.childPos(fr,[0.48,0.585,0.13,0.09]);

            app.ButtonOK.Position = app.childPos(fr,[0.4,0.407,0.25,0.1]);

            app.PanelETP.Position = app.childPos(fr,[0.717,0.407,0.226,0.466]);
            app.LabelEcc.Position = app.childPos(app.PanelETP.Position,[0.043,0.635,0.5,0.133]);
            app.LabelObl.Position = app.childPos(app.PanelETP.Position,[0.043,0.339,0.5,0.133]);
            app.LabelPre.Position = app.childPos(app.PanelETP.Position,[0.043,0.043,0.5,0.133]);
            app.EditEcc.Position = app.childPos(app.PanelETP.Position,[0.6,0.635,0.3,0.222]);
            app.EditObl.Position = app.childPos(app.PanelETP.Position,[0.6,0.339,0.3,0.222]);
            app.EditPre.Position = app.childPos(app.PanelETP.Position,[0.6,0.043,0.3,0.222]);

            app.TextRef.Position = app.childPos(fr,[0.064,0.013,0.915,0.35]);
        end

        function initializeState(app)
            c = app.Context;
            if isfield(c,'MonZoom'), app.MonZoom = c.MonZoom; end
            if isfield(c,'val1'), app.val1 = c.val1; end
            if isfield(c,'acfigmain'), app.acfigmain = c.acfigmain; end
            if isfield(c,'listbox_acmain'), app.listbox_acmain = c.listbox_acmain; end
            if isfield(c,'edit_acfigmain_dir'), app.edit_acfigmain_dir = c.edit_acfigmain_dir; end
            if isfield(c,'lang_choice'), app.lang_choice = c.lang_choice; end
            if isfield(c,'lang_id'), app.lang_id = c.lang_id; end
            if isfield(c,'lang_var'), app.lang_var = c.lang_var; end

            app.dataDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'data');

            app.noteLa04 = ['Laskar, J., Robutel, P., Joutel, F., Gastineau, M.,', ...
                ' Correia, A.C.M., Levrard, B., 2004. A long-term numerical solution', ...
                ' for the insolation quantities of the Earth. Astronomy & Astrophysics', ...
                ' 428, 261-285.'];
            app.noteLa10 = ['Laskar, J., Fienga, A., Gastineau, M., Manche, H., 2011.', ...
                ' La2010: a new orbital solution for the long-term motion of the Earth.', ...
                ' Astronomy & Astrophysics 532. doi: 10.1051/0004-6361/201116836'];
            app.noteWu13 = ['Wu, H., Zhang, S., Jiang, G., Hinnov, L., Yang, T., Li, H.', ...
                ', Wan, X., Wang, C., 2013. Astrochronology of the Early Turonian?Early', ...
                'Campanian terrestrial succession in the Songliao Basin, northeastern ', ...
                'China and its implication for long-period behavior of the Solar System.', ...
                ' Palaeogeography, Palaeoclimatology, Palaeoecology 385, 55-70.'];
            app.noteZB18a = ['Zeebe, R.E., Lourens, L.J. (2019)', ...
                ' Solar System chaos and the Paleocene?Eocene boundary age ', ...
                'constrained by geology and astronomy. Science 365, 926-929.'];

            app.solutionItems = {'La2004','La2010a','La2010b','La2010c','La2010d','ZB18a'};
            app.DropSolution.Items = app.solutionItems;
            app.DropSolution.Value = 'La2004';

            app.UIFigure.Name = app.getLang('b00','Acycle: Astronomical Solutions');
            app.LabelSolution.Text = app.getLang('b01','Astronomical solutions');
            app.LabelParam.Text = app.getLang('b02','Astronomical parameters');
            app.LabelTime.Text = app.getLang('b03','Time Interval');
            app.LabelFrom.Text = app.getLang('b04','From t1');
            app.LabelTo.Text = app.getLang('b05','To t2');
            app.ButtonOK.Text = app.getLang('main00','OK');
            app.PanelETP.Title = app.getLang('b07','ETP weight');
            app.LabelEcc.Text = app.getLang('b08','Eccentricity');
            app.LabelObl.Text = app.getLang('b09','Obliquity');
            app.LabelPre.Text = app.getLang('b10','Precession');

            app.EditT1.Value = '0';
            app.EditT2.Value = '1000';
            app.t1 = 0;
            app.t2 = 1000;

            app.updateParameterItems(1);
            app.loadSolutionAndReference('La2004');

            app.UIFigure.Position = app.normalizedToPixelPosition([0.25,0.25,0.5,0.3]);
            app.applyLayout();
        end

        function onT1Changed(app)
            v = str2double(app.EditT1.Value);
            if isfinite(v)
                app.t1 = v;
            else
                app.EditT1.Value = num2str(app.t1);
            end
        end

        function onT2Changed(app)
            v = str2double(app.EditT2.Value);
            if isfinite(v)
                app.t2 = v;
            else
                app.EditT2.Value = num2str(app.t2);
            end
        end

        function onSolutionChanged(app)
            app.loadSolutionAndReference(app.DropSolution.Value);
        end

        function loadSolutionAndReference(app, solution)
            app.solution = solution;
            ref = 0;
            dat = [];

            switch solution
                case 'La2004'
                    dat = app.loadDataFile('La04.mat');
                    ref = 1;
                case 'La2010a'
                    dat = app.loadDataFile('La10a.mat');
                    ref = 2;
                case 'La2010b'
                    dat = app.loadDataFile('La10b.mat');
                    ref = 2;
                case 'La2010c'
                    dat = app.loadDataFile('La10c.mat');
                    ref = 2;
                case 'La2010d'
                    dat = app.loadDataFile('La10d.mat');
                    ref = 2;
                case 'ZB18a'
                    dat = app.loadDataFile('ZB18a.dat');
                    ref = 4;
            end

            if isempty(dat)
                app.basicdata = [];
                app.refType = 0;
                app.updateParameterItems(0);
                app.TextRef.Value = {''};
                return
            end

            app.basicdata = dat;
            app.refType = ref;
            app.updateParameterItems(ref);

            if ref == 1
                app.TextRef.Value = app.wrapText(app.noteLa04);
            elseif ref == 2
                app.TextRef.Value = app.wrapText(['1. ',app.noteLa10,'  2. ',app.noteWu13]);
            elseif ref == 4
                app.TextRef.Value = app.wrapText(app.noteZB18a);
            end
        end

        function dat = loadDataFile(app, fileName)
            dat = [];
            fullName = fullfile(app.dataDir, fileName);
            if ~isfile(fullName)
                warning(['Missing file: ', fullName]);
                return
            end

            [~,~,ext] = fileparts(fullName);
            if strcmpi(ext,'.mat')
                s = load(fullName);
                if isfield(s,'data')
                    dat = s.data;
                else
                    fns = fieldnames(s);
                    if ~isempty(fns)
                        dat = s.(fns{1});
                    end
                end
            else
                dat = load(fullName);
            end
        end

        function lines = wrapText(~, txt)
            if isempty(txt)
                lines = {''};
            else
                lines = {txt};
            end
        end

        function updateParameterItems(app, ref)
            if ref == 1 || ref == 2
                keys = {'ETP','Eccentricity','Obliquity','Precession'};
            elseif ref == 4
                keys = {'Eccentricity','Inclination'};
            else
                keys = {''};
            end

            app.paramDisplayToKey = containers.Map('KeyType','char','ValueType','char');
            items = cell(size(keys));
            for i = 1:numel(keys)
                if isempty(keys{i})
                    items{i} = '';
                else
                    items{i} = app.parameterLabel(keys{i});
                    app.paramDisplayToKey(items{i}) = keys{i};
                end
            end

            app.DropParam.Items = items;
            app.DropParam.Value = items{1};

            if isempty(items{1})
                app.parameterKey = '';
            else
                app.parameterKey = app.paramDisplayToKey(items{1});
            end
            app.PanelETP.Visible = strcmp(app.parameterKey,'ETP');
        end

        function onParameterChanged(app)
            if isKey(app.paramDisplayToKey, app.DropParam.Value)
                app.parameterKey = app.paramDisplayToKey(app.DropParam.Value);
            else
                app.parameterKey = '';
            end
            app.PanelETP.Visible = strcmp(app.parameterKey,'ETP');
        end

        function onRun(app)
            if isempty(app.basicdata)
                errordlg('No astronomical solution data loaded.','Error');
                return
            end

            app.onT1Changed();
            app.onT2Changed();

            t1 = min(app.t1, app.t2);
            t2 = max(app.t1, app.t2);

            if t1 < 0
                error('Error: t1 must be no less than 0');
            end
            if t2 <= t1
                error('Error: t2 must be larger than t1');
            end
            if app.refType == 4 && t2 > 1.0e5
                error('Error: t2 must be less than 100,000');
            end
            if (app.refType == 1 || app.refType == 2) && t2 >= 249000
                error('Error: t2 must be less than 249,000');
            end

            data = select_interval(app.basicdata, t1, t2);

            if strcmp(app.parameterKey,'ETP')
                wE = str2double(app.EditEcc.Value);
                wT = str2double(app.EditObl.Value);
                wP = str2double(app.EditPre.Value);
                data(:,5) = wE * zscore(data(:,2)) + wT * zscore(data(:,3)) + wP * zscore(data(:,4));
                dat = [data(:,1), data(:,5)];

                parameterName = app.parameterLabel('ETP');
                if wE ~= 1 || wT ~= 1 || wP ~= 1
                    parameterName = [app.EditEcc.Value,'E',app.EditObl.Value,'T',app.EditPre.Value,'P'];
                end
            elseif strcmp(app.parameterKey,'Eccentricity')
                dat = [data(:,1), data(:,2)];
                parameterName = app.parameterLabel('Eccentricity');
            elseif strcmp(app.parameterKey,'Obliquity')
                dat = [data(:,1), data(:,3)];
                parameterName = app.parameterLabel('Obliquity');
            elseif strcmp(app.parameterKey,'Precession')
                dat = [data(:,1), data(:,4)];
                parameterName = app.parameterLabel('Precession');
            elseif strcmp(app.parameterKey,'Inclination')
                dat = [data(:,1), data(:,3)];
                parameterName = app.parameterLabel('Inclination');
            else
                errordlg('No astronomical parameter selected.','Error');
                return
            end

            name = [app.solution,'-',parameterName,'-',num2str(t1),'-',num2str(t2),'.txt'];

            CDac_pwd;
            dlmwrite(name, dat, 'delimiter', ' ', 'precision', 9);
            cd(pre_dirML);

            figdata = figure;
            plot(dat(:,1), dat(:,2));
            set(gca,'XMinorTick','on','YMinorTick','on');
            xlim([min(dat(:,1)),max(dat(:,1))]);
            if app.lang_choice == 0
                xlabel('Time (kyr)');
            else
                xlabel(app.getLang('a231','Time (kyr)'));
            end
            title(name, 'Interpreter', 'none');

            if ~isempty(app.acfigmain) && isgraphics(app.acfigmain)
                figure(app.acfigmain);
            end
            CDac_pwd;
            app.refreshMainListbox();
            cd(pre_dirML);
            figure(figdata);
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
        function app = basicseries(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context,'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('basicseries requires a handles/context struct input.');
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
