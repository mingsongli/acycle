classdef DynamicFilter < matlab.apps.AppBase
    % App Designer style migration of legacy GUIDE DynamicFilter.

    properties (Access = public)
        UIFigure matlab.ui.Figure

        PanelFreq matlab.ui.container.Panel
        GroupFreqMax matlab.ui.container.ButtonGroup
        LabelFreqMin matlab.ui.control.Label
        EditFreqMin matlab.ui.control.EditField
        RadioUseNyquist matlab.ui.control.RadioButton
        RadioUseInput matlab.ui.control.RadioButton
        LabelNyquist matlab.ui.control.Label
        EditFreqMax matlab.ui.control.EditField

        PanelStep matlab.ui.container.Panel
        EditStep matlab.ui.control.EditField
        ButtonStepTips matlab.ui.control.Button
        EditUnit matlab.ui.control.EditField
        LabelUnit matlab.ui.control.Label

        PanelWindow matlab.ui.container.Panel
        EditWindow matlab.ui.control.EditField
        ButtonWindowTips matlab.ui.control.Button

        PanelPlot matlab.ui.container.Panel
        CheckNormalize matlab.ui.control.CheckBox
        LabelPadding matlab.ui.control.Label
        DropPadding matlab.ui.control.DropDown

        ButtonOK matlab.ui.control.Button
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1
        val1 double = 1

        acfigmain
        listbox_acmain
        edit_acfigmain_dir
        unit char = ''
        unit_type
        current_data = []
        filename char = ''
        data_name char = ''
        path_temp char = ''
        ext char = ''
        slash_v char = filesep

        lang_choice double = 0
        lang_id = {}
        lang_var = {}

        meanStep double = 0
        step double = 0
        nyquist double = 0
        window double = 0
        normal double = 1
        lenthx double = 0
        time_0pad double = 1
        padtype double = 1

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
            w = max(1080, normPos(3)*screen(3));
            h = max(410, normPos(4)*screen(4));
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
            app.UIFigure = uifigure('Name','Acycle: Dynamic Filtering | Frequency Stabilization', ...
                'Color',app.UIColorBg, ...
                'Resize','on', ...
                'Position',app.normalizedToPixelPosition([0.63,0.4,0.35,0.22]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.PanelFreq = uipanel(app.UIFigure,'Title','Plot: Maximum Frequency', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');
            app.LabelFreqMin = uilabel(app.PanelFreq,'Text','Freq. min.', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.EditFreqMin = uieditfield(app.PanelFreq,'text','Value','0', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onFreqMinChanged());
            app.GroupFreqMax = uibuttongroup(app.PanelFreq, ...
                'BorderType','none','BackgroundColor',app.UIColorBg, ...
                'SelectionChangedFcn',@(~,~)app.onFreqModeChanged());
            app.RadioUseNyquist = uiradiobutton(app.GroupFreqMax,'Text','Use Nyquist', ...
                'Value',true,'FontSize',app.UIFontSize+1);
            app.LabelNyquist = uilabel(app.PanelFreq,'Text','0', ...
                'HorizontalAlignment','center','BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.RadioUseInput = uiradiobutton(app.GroupFreqMax,'Text','Use Input', ...
                'Value',false,'FontSize',app.UIFontSize+1);
            app.EditFreqMax = uieditfield(app.PanelFreq,'text','Value','0', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontColor',[0 0 0.8], ...
                'FontWeight','bold','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onFreqMaxChanged());

            app.PanelStep = uipanel(app.UIFigure,'Title','Step', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');
            app.EditStep = uieditfield(app.PanelStep,'text','Value','1', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onStepChanged());
            app.ButtonStepTips = uibutton(app.PanelStep,'push','Text','Tips', ...
                'FontSize',app.UIFontSize+1,'ButtonPushedFcn',@(~,~)app.onStepTips());
            app.EditUnit = uieditfield(app.PanelStep,'text','Editable','off','Value','unit', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1);
            app.LabelUnit = uilabel(app.PanelStep,'Text','Unit', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);

            app.PanelWindow = uipanel(app.UIFigure,'Title','Sliding Window', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');
            app.EditWindow = uieditfield(app.PanelWindow,'text','Value','1', ...
                'HorizontalAlignment','center','BackgroundColor',[1 1 1],'FontColor',[0 0 0.8], ...
                'FontWeight','bold','FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onWindowChanged());
            app.ButtonWindowTips = uibutton(app.PanelWindow,'push','Text','Tips', ...
                'FontSize',app.UIFontSize+1,'ButtonPushedFcn',@(~,~)app.onWindowTips());

            app.PanelPlot = uipanel(app.UIFigure,'Title','Plot', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1,'FontWeight','bold');
            app.CheckNormalize = uicheckbox(app.PanelPlot,'Text','Normalize each window', ...
                'Value',true,'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onNormalizeChanged());
            app.LabelPadding = uilabel(app.PanelPlot,'Text','Padding X', ...
                'BackgroundColor',app.UIColorBg,'FontSize',app.UIFontSize+1);
            app.DropPadding = uidropdown(app.PanelPlot,'Items',{'zero','mirror','periodic','none'}, ...
                'ItemsData',[1 2 3 4], ...
                'Value',1,'BackgroundColor',[1 1 1],'FontSize',app.UIFontSize+1, ...
                'ValueChangedFcn',@(~,~)app.onPaddingChanged());

            app.ButtonOK = uibutton(app.UIFigure,'push','Text','OK', ...
                'BackgroundColor',app.UIColorBlue,'FontColor',[1 1 1],'FontWeight','bold', ...
                'FontSize',app.UIFontSize+2,'ButtonPushedFcn',@(~,~)app.onOK());

            app.applyLayout();
        end

        function applyLayout(app)
            fr = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];

            app.PanelFreq.Position = app.childPos(fr,[0.05,0.35,0.38,0.55]);
            app.LabelFreqMin.Position = app.childPos(app.PanelFreq.Position,[0.05,0.62,0.40,0.22]);
            app.EditFreqMin.Position = app.childPos(app.PanelFreq.Position,[0.65,0.62,0.30,0.24]);
            app.GroupFreqMax.Position = app.childPos(app.PanelFreq.Position,[0.03,0.02,0.6,0.58]);
            app.RadioUseNyquist.Position = app.childPos(app.GroupFreqMax.Position,[0.02,0.56,0.96,0.34]);
            app.LabelNyquist.Position = app.childPos(app.PanelFreq.Position,[0.65,0.37,0.3,0.20]);
            app.RadioUseInput.Position = app.childPos(app.GroupFreqMax.Position,[0.02,0.08,0.96,0.34]);
            app.EditFreqMax.Position = app.childPos(app.PanelFreq.Position,[0.65,0.08,0.30,0.25]);

            app.PanelStep.Position = app.childPos(fr,[0.45,0.35,0.25,0.55]);
            app.EditStep.Position = app.childPos(app.PanelStep.Position,[0.1,0.50,0.4,0.25]);
            app.ButtonStepTips.Position = app.childPos(app.PanelStep.Position,[0.55,0.50,0.4,0.25]);
            app.EditUnit.Position = app.childPos(app.PanelStep.Position,[0.1,0.08,0.4,0.25]);
            app.LabelUnit.Position = app.childPos(app.PanelStep.Position,[0.55,0.08,0.4,0.25]);

            app.PanelWindow.Position = app.childPos(fr,[0.73,0.35,0.22,0.55]);
            app.EditWindow.Position = app.childPos(app.PanelWindow.Position,[0.1,0.50,0.75,0.25]);
            app.ButtonWindowTips.Position = app.childPos(app.PanelWindow.Position,[0.1,0.08,0.75,0.25]);

            app.PanelPlot.Position = app.childPos(fr,[0.05,0.05,0.77,0.25]);
            app.CheckNormalize.Position = app.childPos(app.PanelPlot.Position,[0.03,0.14,0.45,0.6]);
            app.LabelPadding.Position = app.childPos(app.PanelPlot.Position,[0.58,0.14,0.2,0.6]);
            app.DropPadding.Position = app.childPos(app.PanelPlot.Position,[0.76,0.14,0.22,0.6]);

            app.ButtonOK.Position = app.childPos(fr,[0.85,0.05,0.1,0.25]);
        end

        function initializeState(app)
            c = app.Context;
            if isfield(c,'MonZoom'), app.MonZoom = c.MonZoom; end
            if isfield(c,'val1'), app.val1 = c.val1; end

            if isfield(c,'acfigmain'), app.acfigmain = c.acfigmain; end
            if isfield(c,'listbox_acmain'), app.listbox_acmain = c.listbox_acmain; end
            if isfield(c,'edit_acfigmain_dir'), app.edit_acfigmain_dir = c.edit_acfigmain_dir; end
            if isfield(c,'unit'), app.unit = c.unit; end
            if isfield(c,'unit_type'), app.unit_type = c.unit_type; end
            if isfield(c,'current_data'), app.current_data = c.current_data; end
            if isfield(c,'filename'), app.filename = c.filename; end
            if isfield(c,'data_name'), app.data_name = c.data_name; end
            if isfield(c,'path_temp'), app.path_temp = c.path_temp; end
            if isfield(c,'ext'), app.ext = c.ext; end
            if isfield(c,'slash_v'), app.slash_v = c.slash_v; end

            if isfield(c,'lang_choice'), app.lang_choice = c.lang_choice; end
            if isfield(c,'lang_id'), app.lang_id = c.lang_id; end
            if isfield(c,'lang_var'), app.lang_var = c.lang_var; end

            app.UIFigure.Name = app.getLang('dd30','Acycle: Dynamic Filtering | Frequency Stabilization');
            app.PanelFreq.Title = app.getLang('dd31','Plot: Maximum Frequency');
            app.LabelFreqMin.Text = app.getLang('dd32','Freq. min.');
            app.RadioUseNyquist.Text = app.getLang('dd33','Use Nyquist');
            app.RadioUseInput.Text = app.getLang('dd34','Use Input');

            app.PanelStep.Title = app.getLang('main32','Step');
            app.ButtonStepTips.Text = app.getLang('main33','Tips');
            app.PanelWindow.Title = app.getLang('main07','Sliding Window');
            app.ButtonWindowTips.Text = app.getLang('main33','Tips');

            app.PanelPlot.Title = app.getLang('menu03','Plot');
            app.CheckNormalize.Text = app.getLang('dd35','Normalize each window');
            app.LabelPadding.Text = app.getLang('dd36','Padding X');
            app.ButtonOK.Text = app.getLang('main00','OK');

            if isempty(app.current_data)
                error('DynamicFilter requires current_data from AC handles.');
            end

            data_s = app.current_data;
            data_s(:,2) = data_s(:,2) - mean(data_s(:,2));
            app.current_data = data_s;

            xmin = min(data_s(:,1));
            xmax = max(data_s(:,1));
            app.meanStep = median(diff(data_s(:,1)));
            app.step = 4*app.meanStep;
            app.nyquist = 1/(2*app.meanStep);
            app.window = 0.2*(xmax-xmin);
            app.normal = 1;
            app.lenthx = xmax - xmin;
            app.time_0pad = 1;
            app.padtype = 1;

            ncal = (xmax - xmin - app.window) / app.meanStep;
            if ncal > 500
                app.step = abs(xmax - xmin - app.window) / 500;
            end

            app.EditFreqMin.Value = '0';
            app.EditUnit.Value = app.unit;
            app.LabelNyquist.Text = num2str(app.nyquist);
            app.EditFreqMax.Value = num2str(0.5*app.nyquist);
            app.EditStep.Value = num2str(app.step);
            app.EditWindow.Value = num2str(app.window);
            app.RadioUseNyquist.Value = true;
            app.RadioUseInput.Value = false;
            app.GroupFreqMax.SelectedObject = app.RadioUseNyquist;
            app.CheckNormalize.Value = true;
            app.DropPadding.Value = 1;

            app.EditFreqMax.Editable = 'off';
            app.EditFreqMax.BackgroundColor = app.UIColorBg;

            if app.lang_choice > 0
                app.DropPadding.Items = { ...
                    app.getLang('dd38','zero'), ...
                    app.getLang('dd39','mirror'), ...
                    app.getLang('dd40','periodic'), ...
                    app.getLang('dd41','none')};
                app.DropPadding.ItemsData = [1 2 3 4];
                app.DropPadding.Value = 1;
            end

            diffx = diff(data_s(:,1));
            if max(diffx) - min(diffx) > 2*eps('single')
                hwarn = warndlg(app.getLang('dd37','Not uniformly spaced data. Interpolated using mean sampling rate!'));
                interpolate_rate = mean(diffx);
                app.current_data = interpolate(data_s,interpolate_rate);
                try
                    set(hwarn,'Units','normalized');
                    set(hwarn,'Position',[0.15,0.6,0.25,0.1]);
                catch
                end
            end

            app.UIFigure.Position = app.normalizedToPixelPosition([0.63,0.4,0.35,0.22]);
            app.applyLayout();
        end

        function onNormalizeChanged(app)
            app.normal = double(app.CheckNormalize.Value);
        end

        function onPaddingChanged(app)
            app.padtype = app.DropPadding.Value;
        end

        function onFreqModeChanged(app)
            if app.RadioUseNyquist.Value
                app.GroupFreqMax.SelectedObject = app.RadioUseNyquist;
                app.EditFreqMax.Value = num2str(0.5*app.nyquist);
                app.EditFreqMax.Editable = 'off';
                app.EditFreqMax.BackgroundColor = app.UIColorBg;
            else
                app.GroupFreqMax.SelectedObject = app.RadioUseInput;
                app.EditFreqMax.Editable = 'on';
                app.EditFreqMax.BackgroundColor = [1 1 1];
            end
        end

        function onStepTips(app)
            if app.lang_choice == 0
                warndlg('Tips: Step  >= mean sample rate','Tips: Step length');
            else
                warndlg(app.getLang('dd45','Tips: Step  >= mean sample rate'), app.getLang('dd46','Tips: Step length'));
            end
        end

        function onWindowTips(app)
            if app.lang_choice == 0
                warndlg('Tips: window  < total data length; window ~= 2x aimed cycle. i.e. 20 m for a 10-m cycles','Tips: window length');
            else
                warndlg(app.getLang('dd43','Tips: window < total data length; window ~= 2x aimed cycle'), app.getLang('dd44','Tips: window length'));
            end
        end

        function onWindowChanged(app)
            w = str2double(app.EditWindow.Value);
            if isnan(w) || w <= 0
                app.EditWindow.Value = num2str(app.window);
                return
            end
            app.window = w;
            ncal = (app.lenthx - app.window)/app.meanStep;
            if ncal > 500
                app.step = abs(app.lenthx - app.window)/500;
                app.EditStep.Value = num2str(app.step);
            end
        end

        function onStepChanged(app)
            v = str2double(app.EditStep.Value);
            if isnan(v)
                app.EditStep.Value = num2str(app.step);
                return
            end
            if v < app.meanStep
                warndlg(app.getLang('dd47','Step must be no smaller than the mean sampling rate'), app.getLang('main29','Warning'));
                app.EditStep.Value = num2str(app.meanStep);
                return
            end
            if v > 0.5 * app.lenthx
                warndlg(app.getLang('dd48','Step is too large'), app.getLang('main29','Warning'));
                app.EditStep.Value = num2str(app.meanStep*5);
                return
            end
            app.step = v;
        end

        function onFreqMaxChanged(app)
            v = str2double(app.EditFreqMax.Value);
            if isnan(v)
                app.EditFreqMax.Value = num2str(0.5*app.nyquist);
                return
            end
            fmin = str2double(app.EditFreqMin.Value);
            if v <= fmin
                warndlg(app.getLang('dd49','Maximum Freq. must be larger than freq. min'), app.getLang('main29','Warning'));
                app.EditFreqMax.Value = num2str(app.nyquist*0.5);
                return
            end
            if v > app.nyquist
                warndlg(app.getLang('dd50','Maximum Freq. must be no larger than the Nyquist frequency'), app.getLang('main29','Warning'));
                app.EditFreqMax.Value = num2str(app.nyquist);
                return
            end
            app.RadioUseInput.Value = true;
            app.RadioUseNyquist.Value = false;
            app.GroupFreqMax.SelectedObject = app.RadioUseInput;
            app.EditFreqMax.Editable = 'on';
            app.EditFreqMax.BackgroundColor = [1 1 1];
        end

        function onFreqMinChanged(app)
            v = str2double(app.EditFreqMin.Value);
            if isnan(v)
                app.EditFreqMin.Value = '0';
                return
            end
            if v >= app.nyquist
                warndlg(app.getLang('dd51','Freq. min must be smaller than the Nyquist frequency'), app.getLang('main29','Warning'));
                app.EditFreqMin.Value = '0';
                return
            end
            if v < 0
                warndlg(app.getLang('dd52','Freq. min must be no less than 0'), app.getLang('main29','Warning'));
                app.EditFreqMin.Value = '0';
                return
            end
        end

        function refreshMainListbox(app)
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

        function onOK(app)
            figft = app.UIFigure;
            data = app.current_data;
            window = str2double(app.EditWindow.Value);
            fmin = str2double(app.EditFreqMin.Value);
            if app.RadioUseNyquist.Value
                fmax = app.nyquist;
            else
                fmax = str2double(app.EditFreqMax.Value);
            end
            unitv = app.EditUnit.Value;
            stepv = str2double(app.EditStep.Value);
            normv = app.normal;
            padding = app.padtype;

            if isnan(window) || isnan(fmin) || isnan(fmax) || isnan(stepv)
                warndlg('Invalid numeric input.');
                return
            end

            lang_main23 = app.getLang('main23','Depth');
            lang_main24 = app.getLang('main24','Value');
            lang_main02 = app.getLang('main02','Data');
            lang_dd42 = app.getLang('dd42','Data & dynamic filtered output');

            figdata = figure;
            plot(data(:,1),data(:,2),'k-');
            xlim([min(data(:,1)),max(data(:,1))]);
            xlabel([lang_main23,' (',unitv,')']);
            ylabel(lang_main24);
            title(lang_main02);
            set(gca,'TickDir','out');
            set(figdata,'Units','normalized','Position',[0.05,0.02,0.9,0.3]);
            set(figdata,'Name',['Acycle: ',lang_main02]);

            [xdata_filtered,time,freqboundlow,freqboundhigh] = dynamic_filter_lang(data,window,stepv,fmin,fmax,unitv,normv,padding);
            figdynfilter = gcf;

            pre_dirML = pwd;
            CDac_pwd;
            cleanupObj = onCleanup(@()cd(pre_dirML)); %#ok<NASGU>

            [dat_dir,data_name1,ext1] = fileparts(app.filename);
            name0 = [data_name1,'-','DynFilter'];
            name1 = [name0,ext1];
            log_name = [data_name1,'-','DynFilter-log',ext1];
            dynfilfigname = [data_name1,'-','DynFilter'];
            dynfilfigname1 = [dynfilfigname,'.fig'];

            if exist(fullfile(pwd,log_name),'file') || exist(fullfile(pwd,name1),'file') || exist(fullfile(pwd,dynfilfigname1),'file')
                for i = 1:100
                    name1 = [name0,'-',num2str(i),ext1];
                    log_name = [data_name1,'-','DynFilter-',num2str(i),'-log',ext1];
                    dynfilfigname1 = [dynfilfigname,'-',num2str(i),'.fig'];
                    if ~(exist(fullfile(pwd,log_name),'file') || exist(fullfile(pwd,name1),'file') || exist(fullfile(pwd,dynfilfigname1),'file'))
                        break
                    end
                end
            end

            dlmwrite(name1, [time,xdata_filtered'], 'delimiter', ' ', 'precision', 9);
            figure(figdynfilter); savefig(dynfilfigname1);

            figure(figdata); hold on;
            plot(time,xdata_filtered,'r-');
            title(lang_dd42);
            hold off;

            fileID = fopen(fullfile(dat_dir,log_name),'w+');
            if fileID ~= -1
                fprintf(fileID,'%s\n','% - - - - - - - - - - - - - Summary - - - - - - - - - - -');
                fprintf(fileID,'%s\n',datestr(datetime('now')));
                fprintf(fileID,'%s\n',log_name);
                fprintf(fileID,'\n');
                fprintf(fileID,'%s\n','%lower frequency boundary');
                fprintf(fileID,'\n');
                for ii = 1:size(freqboundlow,1)
                    fprintf(fileID,'%f\t',freqboundlow(ii,:));
                    fprintf(fileID,'\n');
                end
                fprintf(fileID,'\n');
                fprintf(fileID,'%s\n','%higher frequency boundary');
                fprintf(fileID,'\n');
                for ii = 1:size(freqboundhigh,1)
                    fprintf(fileID,'%f\t',freqboundhigh(ii,:));
                    fprintf(fileID,'\n');
                end
                fclose(fileID);
            end

            app.refreshMainListbox();
            try
                figure(figft);
            catch
            end
            try
                figure(figdynfilter);
            catch
            end
            try
                figure(figdata);
            catch
            end
        end
    end

    methods (Access = public)
        function app = DynamicFilter(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context,'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('DynamicFilter requires a handles/context struct input.');
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
