classdef agescale < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE agescale GUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure

        ButtonUp matlab.ui.control.Button
        ButtonOpen matlab.ui.control.Button
        EditPath matlab.ui.control.EditField
        ListFiles matlab.ui.control.ListBox

        ButtonSetAgeModel matlab.ui.control.Button
        ButtonSetSeries matlab.ui.control.Button

        LabelAgeModel matlab.ui.control.Label
        EditAgeModel matlab.ui.control.EditField
        LabelSeries matlab.ui.control.Label
        ListSeries matlab.ui.control.ListBox

        ButtonShowAgeModel matlab.ui.control.Button
        ButtonPreviewTime matlab.ui.control.Button
        ButtonPreviewDepth matlab.ui.control.Button
        ButtonTuning matlab.ui.control.Button
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

        agemodelname char = ''
        seriesNames cell = {}

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
            w = max(1500, normPos(3)*screen(3));
            h = max(650, normPos(4)*screen(4));
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
            app.UIFigure = uifigure('Name','Acycle: Age Scale', ...
                'Color',app.UIColorBg, ...
                'Resize','on', ...
                'Position',app.normalizedToPixelPosition([0.05,0.4,0.9,0.4]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.ButtonUp = uibutton(app.UIFigure,'push','Text','<--', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onUpDir());
            app.ButtonOpen = uibutton(app.UIFigure,'push','Text','-->', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onOpenDir());

            app.EditPath = uieditfield(app.UIFigure,'text', ...
                'BackgroundColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onPathChanged());

            app.ListFiles = uilistbox(app.UIFigure,'Multiselect','on', ...
                'BackgroundColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onListFilesChanged());

            app.ButtonSetAgeModel = uibutton(app.UIFigure,'push','Text','==>', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onSetAgeModel());
            app.ButtonSetSeries = uibutton(app.UIFigure,'push','Text','==>', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onSetSeries());

            app.LabelAgeModel = uilabel(app.UIFigure,'Text','Age Model', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditAgeModel = uieditfield(app.UIFigure,'text','Editable','off', ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);

            app.LabelSeries = uilabel(app.UIFigure,'Text','Series', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.ListSeries = uilistbox(app.UIFigure, ...
                'Items',{}, ...
                'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);

            app.ButtonShowAgeModel = uibutton(app.UIFigure,'push','Text','Show Age Model', ...
                'BackgroundColor',[0.45 0.45 0.45],'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onShowAgeModel());
            app.ButtonPreviewTime = uibutton(app.UIFigure,'push','Text','Tuning Preview Time', ...
                'BackgroundColor',[0.45 0.45 0.45],'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onPreviewTime());
            app.ButtonPreviewDepth = uibutton(app.UIFigure,'push','Text','Tuning Preview Depth', ...
                'BackgroundColor',[0.45 0.45 0.45],'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onPreviewDepth());
            app.ButtonTuning = uibutton(app.UIFigure,'push','Text','Tuning', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1], ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ButtonPushedFcn',@(~,~)app.onTuning());

            app.applyLayout();
        end

        function applyLayout(app)
            fr = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];

            app.ButtonUp.Position = app.childPos(fr,[0.034,0.84,0.06,0.06]);
            app.ButtonOpen.Position = app.childPos(fr,[0.10,0.84,0.06,0.06]);

            app.EditPath.Position = app.childPos(fr,[0.018,0.748,0.436,0.06]);
            app.ListFiles.Position = app.childPos(fr,[0.018,0.114,0.436,0.634]);

            app.ButtonSetAgeModel.Position = app.childPos(fr,[0.485,0.732,0.06,0.06]);
            app.ButtonSetSeries.Position = app.childPos(fr,[0.485,0.527,0.06,0.06]);

            app.LabelAgeModel.Position = app.childPos(fr,[0.58,0.84,0.15,0.06]);
            app.EditAgeModel.Position = app.childPos(fr,[0.58,0.738,0.4,0.06]);
            app.LabelSeries.Position = app.childPos(fr,[0.58,0.606,0.1,0.06]);
            app.ListSeries.Position = app.childPos(fr,[0.58,0.114,0.4,0.476]);

            app.ButtonShowAgeModel.Position = app.childPos(fr,[0.465,0.366,0.11,0.06]);
            app.ButtonPreviewTime.Position = app.childPos(fr,[0.465,0.293,0.11,0.06]);
            app.ButtonPreviewDepth.Position = app.childPos(fr,[0.465,0.221,0.11,0.06]);
            app.ButtonTuning.Position = app.childPos(fr,[0.465,0.114,0.10,0.06]);
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

            app.UIFigure.Name = app.getLang('a00','Acycle: Age Scale');
            app.LabelAgeModel.Text = app.getLang('main27','Age Model');
            app.LabelSeries.Text = app.getLang('a02','Series');
            app.ButtonShowAgeModel.Text = app.getLang('a03','Show Age Model');
            app.ButtonPreviewTime.Text = app.getLang('a04','Tuning Preview Time');
            app.ButtonPreviewDepth.Text = app.getLang('a05','Tuning Preview Depth');
            app.ButtonTuning.Text = app.getLang('a06','Tuning');

            pre_dirML = pwd;
            CDac_pwd;
            app.workingDir = pwd;
            cd(pre_dirML);
            app.loadDirectory(app.workingDir);

            app.UIFigure.Position = app.normalizedToPixelPosition([0.05,0.4,0.9,0.4]);
            app.applyLayout();
        end

        function loadDirectory(app, address)
            if ~isfolder(address)
                return
            end
            app.workingDir = address;
            d = dir(address);
            names = {d.name};
            names = names(~ismember(names,{'.','..'}));
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
            elseif isstring(vals)
                vals = cellstr(vals);
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

        function onUpDir(app)
            if isempty(app.workingDir)
                return
            end
            parentDir = fileparts(app.workingDir);
            if isempty(parentDir)
                parentDir = app.workingDir;
            end
            app.loadDirectory(parentDir);
        end

        function onOpenDir(app)
            if isempty(app.selectedFileIndices) || numel(app.selectedFileIndices) ~= 1
                helpdlg('Tips: Select 1 folder','Tips: Close');
                return
            end
            idx = app.selectedFileIndices(1);
            if idx < 1 || idx > numel(app.fileList)
                return
            end
            candidate = app.fileList{idx};
            fullCandidate = fullfile(app.workingDir, candidate);
            if ~isfolder(fullCandidate)
                helpdlg('This is not a folder','Tips: Close');
                return
            end
            app.loadDirectory(fullCandidate);
        end

        function onSetAgeModel(app)
            if isempty(app.selectedFileIndices) || numel(app.selectedFileIndices) ~= 1
                return
            end
            idx = app.selectedFileIndices(1);
            if idx < 1 || idx > numel(app.fileList)
                return
            end
            name = app.fileList{idx};
            if isfolder(fullfile(app.workingDir,name))
                return
            end
            app.agemodelname = name;
            app.EditAgeModel.Value = name;
        end

        function onSetSeries(app)
            if isempty(app.selectedFileIndices)
                return
            end
            s = {};
            for i = 1:numel(app.selectedFileIndices)
                idx = app.selectedFileIndices(i);
                if idx >= 1 && idx <= numel(app.fileList)
                    name = app.fileList{idx};
                    if ~isfolder(fullfile(app.workingDir,name))
                        s{end+1} = name; %#ok<AGROW>
                    end
                end
            end
            app.seriesNames = s;
            app.ListSeries.Items = s;
            if ~isempty(s)
                app.ListSeries.Value = s{1};
            end
        end

        function onTuning(app)
            if isempty(app.agemodelname) || isempty(app.seriesNames)
                return
            end
            pre_dirML = pwd;
            CDac_pwd;
            saveDir = pwd;
            agemodel = load(fullfile(app.workingDir, app.agemodelname));

            figagescale = app.UIFigure;
            figdata = figure;
            xmax1 = nan; xmin1 = nan; xmax2 = nan; xmin2 = nan;

            for i = 1:numel(app.seriesNames)
                data_name = app.seriesNames{i};
                data = load(fullfile(app.workingDir, data_name));
                [~,dat_name,~] = fileparts(data_name);
                subplot(2,1,1);
                plot(data(:,1),data(:,2)); hold on;
                set(gca,'XMinorTick','on','YMinorTick','on');
                xmin1 = nanmin(xmin1,min(data(:,1))); xmax1 = nanmax(xmax1,max(data(:,1)));
                if app.lang_choice == 0
                    title('Origin data');
                else
                    title(app.getLang('a41','Origin data'));
                end
                xlim([xmin1,xmax1]);

                [time,~] = depthtotime(data(:,1),agemodel);
                tunedseries = [time,data(:,2)];
                subplot(2,1,2);
                plot(time,data(:,2)); hold on;
                set(gca,'XMinorTick','on','YMinorTick','on');
                if app.lang_choice == 0
                    title('Tuned data');
                else
                    title(app.getLang('a42','Tuned data'));
                end
                xmin2 = nanmin(xmin2,min(time)); xmax2 = nanmax(xmax2,max(time));
                xlim([xmin2,xmax2]);

                add_list = [dat_name,'-TD-',app.agemodelname];
                dlmwrite(add_list,tunedseries,'delimiter',' ','precision',9);
            end

            app.refreshMainListbox(saveDir);
            cd(pre_dirML);
            figure(figagescale);
            figure(figdata);
        end

        function onShowAgeModel(app)
            if isempty(app.agemodelname)
                return
            end
            pre_dirML = pwd;
            CDac_pwd;
            tiepoints = load(fullfile(app.workingDir, app.agemodelname));
            x1 = min(tiepoints(:,1)); x2 = max(tiepoints(:,1));
            y1 = min(tiepoints(:,2)); y2 = max(tiepoints(:,2));

            figure('Position',[100 800 500 500],'Color',[1 1 1]);
            axes('Position',[0.2 0.2 0.7 0.7], ...
                'XLim',[y1 y2],'YLim',[x1 x2],'YDir','Reverse','Box','On','FontSize',14);
            line(tiepoints(:,2),tiepoints(:,1),'LineWidth',1);
            if app.lang_choice == 0
                xlabel('Age'); ylabel(['Depth (',app.unit,')']); title('Age Model');
            else
                xlabel(app.getLang('main22','Age'));
                ylabel([app.getLang('main23','Depth'),' (',app.unit,')']);
                title(app.getLang('main27','Age Model'));
            end
            set(gca,'XMinorTick','on','YMinorTick','on');
            cd(pre_dirML);
        end

        function onPreviewTime(app)
            if isempty(app.agemodelname) || isempty(app.seriesNames)
                return
            end
            pre_dirML = pwd;
            CDac_pwd;
            tiepoints = load(fullfile(app.workingDir, app.agemodelname));

            for i = 1:numel(app.seriesNames)
                data_name = app.seriesNames{i};
                data = load(fullfile(app.workingDir, data_name));
                [~,dat_name,~] = fileparts(data_name);
                [time,~] = depthtotime(data(:,1),tiepoints);

                t1 = min(time); t2 = max(time);
                y1 = min(data(:,2)); y2 = max(data(:,2));
                d1 = min(data(:,1)); d2 = max(data(:,1));
                t = time; rec = data(:,2);

                lenexp = fix(log10(t2-t1));
                if lenexp >= 0
                    XTickStep = 0.05 * round(fix((t2-t1)/10^lenexp)) * 10^lenexp;
                    t1r = round(fix(t1/10^lenexp)) * 10^lenexp;
                    age = t1r:XTickStep:t2;
                    depthint = interp1(tiepoints(:,2),tiepoints(:,1),age,'linear','extrap');
                    depthintlabels = num2str(depthint,'%.0f\n');
                else
                    XTickStep = (t2-t1)/20;
                    age = t1:XTickStep:t2;
                    depthint = interp1(tiepoints(:,2),tiepoints(:,1),age,'linear','extrap');
                    depthintlabels = num2str(depthint,'%.3f\n');
                end

                figure('Position',[50 50 1000 400],'Color',[1 1 1]);
                ax1 = axes('Position',[0.1 0.4 0.8 0.4],'Color','None','XTick',age,'XLim',[t1 t2],'YLim',[y1 y2],'FontSize',14);
                line(t,rec,'LineWidth',1);
                if app.lang_choice==0
                    xlabel(ax1,'Age'); ylabel(ax1,'Proxy Value'); title(ax1,[dat_name,': Tuned'],'Interpreter','none');
                else
                    xlabel(ax1,app.getLang('main22','Age')); ylabel(ax1,app.getLang('main24','Proxy Value'));
                    title(ax1,[dat_name,': ',app.getLang('a42','Tuned')],'Interpreter','none');
                end
                set(gca,'XMinorTick','on','YMinorTick','on');

                ax2 = axes('Position',[0.1 0.25 0.8 0.4],'Color','None','XLim',[t1 t2], ...
                    'XTickMode','Manual','XTick',age,'XTickLabels',depthintlabels,'YLim',[y1 y2], ...
                    'YTick',[],'YColor','None','FontSize',14);
                if app.lang_choice == 0
                    xlabel(ax2,['Depth (',app.unit,')']);
                else
                    xlabel(ax2,[app.getLang('main23','Depth'),' (',app.unit,')']);
                end
                set(gca,'XMinorTick','on','YMinorTick','on');

                lenexp = fix(log10(d2-d1));
                if lenexp >= 0
                    XTickStep = 0.05 * round(fix((d2-d1)/10^lenexp)) * 10^lenexp;
                    if d1>=0, d1r = round(fix(d1/10^lenexp)) * 10^lenexp; else, d1r = round(d1); end
                    depth = d1r:XTickStep:d2;
                    ageint = interp1(depthint,age,depth,'linear','extrap');
                    depthlabels = num2str(depth,'%.0f\n');
                else
                    XTickStep = (d2-d1)/20;
                    depth = d1:XTickStep:d2;
                    ageint = interp1(depthint,age,depth,'linear','extrap');
                    depthlabels = num2str(depth,'%.3f\n');
                end

                figure('Position',[50 500 1000 400],'Color',[1 1 1]);
                ax1 = axes('Position',[0.1 0.4 0.8 0.4],'Color','None','XLim',[t1 t2],'XTick',age,'YLim',[y1 y2],'FontSize',14);
                line(t,rec,'LineWidth',1);
                if app.lang_choice==0
                    xlabel(ax1,'Age'); ylabel(ax1,'Proxy Value'); title(ax1,[dat_name,': Tuned'],'Interpreter','none');
                else
                    xlabel(ax1,app.getLang('main22','Age')); ylabel(ax1,app.getLang('main24','Proxy Value'));
                    title(ax1,[dat_name,': ',app.getLang('a42','Tuned')],'Interpreter','none');
                end
                set(gca,'XMinorTick','on','YMinorTick','on');

                try
                    ax2 = axes('Position',[0.1 0.25 0.8 0.4],'Color','None','XLim',[t1 t2], ...
                        'XTickMode','Manual','XTick',ageint,'XTickLabels',depthlabels,'YLim',[y1 y2], ...
                        'YTick',[],'YColor','None','FontSize',14);
                catch
                    ageint = fliplr(ageint);
                    depth = d2:-1*XTickStep:d1r;
                    depthlabels = num2str(depth,'%.0f\n');
                    ax2 = axes('Position',[0.1 0.25 0.8 0.4],'Color','None','XLim',[t1 t2], ...
                        'XTickMode','Manual','XTick',ageint,'XTickLabels',depthlabels,'YLim',[y1 y2], ...
                        'YTick',[],'YColor','None','FontSize',14);
                end
                if app.lang_choice == 0
                    xlabel(ax2,['Depth (',app.unit,')']);
                else
                    xlabel(ax2,[app.getLang('main23','Depth'),' (',app.unit,')']);
                end
                set(gca,'XMinorTick','on','YMinorTick','on');
            end
            cd(pre_dirML);
        end

        function onPreviewDepth(app)
            if isempty(app.agemodelname) || isempty(app.seriesNames)
                return
            end
            pre_dirML = pwd;
            CDac_pwd;
            tiepoints = load(fullfile(app.workingDir, app.agemodelname));

            for i = 1:numel(app.seriesNames)
                data_name = app.seriesNames{i};
                data = load(fullfile(app.workingDir, data_name));
                [~,dat_name,~] = fileparts(data_name);
                [time,~] = depthtotime(data(:,1),tiepoints);

                t1 = min(time); t2 = max(time);
                y1 = min(data(:,2)); y2 = max(data(:,2));
                d1 = min(data(:,1)); d2 = max(data(:,1));
                rec = data(:,2);

                lenexp = fix(log10(d2-d1));
                if lenexp >= 0
                    XTickStep = 0.1 * round(fix((d2-d1)/10^lenexp)) * 10^lenexp;
                    if d1>=0, d1r = round(fix(d1/10^lenexp)) * 10^lenexp; else, d1r = round(d1); end
                    XTickListDepth = d1r:XTickStep:d2;
                    timeint = interp1(tiepoints(:,1),tiepoints(:,2),XTickListDepth,'linear','extrap');
                    timeintlabels = num2str(timeint,'%.0f\n');
                else
                    XTickStep = (d2-d1)/20;
                    XTickListDepth = d1:XTickStep:d2;
                    timeint = interp1(tiepoints(:,1),tiepoints(:,2),XTickListDepth,'linear','extrap');
                    timeintlabels = num2str(timeint,'%3.3f\n');
                end

                figure('Position',[50 50 1000 400],'Color',[1 1 1]);
                ax1 = axes('Position',[0.1 0.4 0.8 0.4],'Color','None','XTick',XTickListDepth,'XLim',[d1 d2],'YLim',[y1 y2],'FontSize',14);
                line(data(:,1),rec,'LineWidth',1);
                if app.lang_choice==0
                    xlabel(ax1,['Depth (',app.unit,')']); ylabel(ax1,'Proxy Value'); title(ax1,[dat_name,': Depth'],'Interpreter','none');
                else
                    xlabel(ax1,[app.getLang('main23','Depth'),' (',app.unit,')']); ylabel(ax1,app.getLang('main24','Proxy Value'));
                    title(ax1,[dat_name,': ',app.getLang('main23','Depth')],'Interpreter','none');
                end
                set(gca,'XMinorTick','on','YMinorTick','on');

                ax2 = axes('Position',[0.1 0.25 0.8 0.4],'Color','None','XLim',[d1 d2], ...
                    'XTickMode','Manual','XTick',XTickListDepth,'XTickLabels',timeintlabels,'YLim',[y1 y2], ...
                    'YTick',[],'YColor','None','FontSize',14);
                if app.lang_choice==0
                    xlabel(ax2,'Age');
                else
                    xlabel(ax2,app.getLang('main22','Age'));
                end
                set(gca,'XMinorTick','on','YMinorTick','on');

                lenexp = fix(log10(t2-t1));
                if lenexp >= 0
                    XTickStep = 0.05 * round(fix((t2-t1)/10^lenexp)) * 10^lenexp;
                    t1r = round(fix(t1/10^lenexp)) * 10^lenexp;
                    age = t1r:XTickStep:t2;
                    depthint = interp1(tiepoints(:,2),tiepoints(:,1),age,'linear','extrap');
                    depthintlabels = num2str(age,'%.0f\n');
                else
                    XTickStep = (t2-t1)/20;
                    age = t1:XTickStep:t2;
                    depthint = interp1(tiepoints(:,2),tiepoints(:,1),age,'linear','extrap');
                    depthintlabels = num2str(age,'%.3f\n');
                end

                figure('Position',[50 500 1000 400],'Color',[1 1 1]);
                ax1 = axes('Position',[0.1 0.4 0.8 0.4],'Color','None','XTick',XTickListDepth,'XLim',[d1 d2],'YLim',[y1 y2],'FontSize',14);
                line(data(:,1),rec,'LineWidth',1);
                if app.lang_choice==0
                    xlabel(ax1,['Depth (',app.unit,')']); ylabel(ax1,'Proxy Value'); title(ax1,[dat_name,': Depth'],'Interpreter','none');
                else
                    xlabel(ax1,[app.getLang('main23','Depth'),' (',app.unit,')']); ylabel(ax1,app.getLang('main24','Proxy Value'));
                    title(ax1,[dat_name,': ',app.getLang('main23','Depth')],'Interpreter','none');
                end
                set(gca,'XMinorTick','on','YMinorTick','on');

                try
                    ax2 = axes('Position',[0.1 0.25 0.8 0.4],'Color','None','XLim',[d1 d2], ...
                        'XTickMode','Manual','XTick',depthint,'XTickLabels',depthintlabels,'YLim',[y1 y2], ...
                        'YTick',[],'YColor','None','FontSize',14);
                catch
                    depthint = fliplr(depthint);
                    age = t2:-1*XTickStep:t1r;
                    depthintlabels = num2str(age,'%.3f\n');
                    ax2 = axes('Position',[0.1 0.25 0.8 0.4],'Color','None','XLim',[d1 d2], ...
                        'XTickMode','Manual','XTick',depthint,'XTickLabels',depthintlabels,'YLim',[y1 y2], ...
                        'YTick',[],'YColor','None','FontSize',14);
                end
                if app.lang_choice==0
                    xlabel(ax2,'Age');
                else
                    xlabel(ax2,app.getLang('main22','Age'));
                end
                set(gca,'XMinorTick','on','YMinorTick','on');
            end

            cd(pre_dirML);
        end

        function refreshMainListbox(app,dirpath)
            if isempty(app.listbox_acmain) || ~isgraphics(app.listbox_acmain)
                return
            end
            if nargin < 2 || isempty(dirpath) || exist(dirpath,'dir') ~= 7
                dirpath = pwd;
            end
            try
                d = dir(dirpath);
                if numel(d) >= 2
                    d = d(~ismember({d.name},{'.','..'}));
                end
                names = {};
                isDir = false(0,1);
                if ~isempty(d)
                    T = struct2table(d);
                    switch app.getSortMode()
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
                            sortedT = sortrows(T,'date','descend');
                    end
                    sd = table2struct(sortedT);
                    names = {sd.name};
                    isDir = [sd.isdir];
                end
                if ~isempty(app.edit_acfigmain_dir) && isgraphics(app.edit_acfigmain_dir)
                    set(app.edit_acfigmain_dir,'String',dirpath);
                end
                app.syncAcPwd(dirpath);
                if exist('ac_update_listbox_acmain','file') == 2
                    ac_update_listbox_acmain(app.listbox_acmain,names,isDir);
                elseif isempty(names)
                    set(app.listbox_acmain,'String',{},'Value',[]);
                else
                    set(app.listbox_acmain,'String',names,'Value',1);
                end
                drawnow limitrate;
            catch
            end
        end

        function val1 = getSortMode(app)
            val1 = app.val1;
            try
                mainFig = ancestor(app.listbox_acmain,'figure');
                mainHandles = guidata(mainFig);
                if isstruct(mainHandles) && isfield(mainHandles,'val1') && ~isempty(mainHandles.val1)
                    val1 = mainHandles.val1;
                end
            catch
            end
        end

        function syncAcPwd(~,dirpath)
            try
                acPwdFile = which('ac_pwd.txt');
                if isempty(acPwdFile)
                    return
                end
                fid = fopen(acPwdFile,'w');
                if fid == -1
                    return
                end
                fprintf(fid,'%s',dirpath);
                fclose(fid);
            catch
            end
        end
    end

    methods (Access = public)
        function app = agescale(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context,'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('agescale requires a handles/context struct input.');
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
