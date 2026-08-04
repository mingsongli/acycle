classdef ft < matlab.apps.AppBase
    % App Designer style migration of legacy GUIDE ft (Filtering).

    properties (Access = public)
        UIFigure matlab.ui.Figure

        PanelBand matlab.ui.container.Panel
        LabelFlow matlab.ui.control.Label
        LabelFhigh matlab.ui.control.Label
        LabelFcenter matlab.ui.control.Label
        LabelRoll matlab.ui.control.Label
        EditFlow matlab.ui.control.EditField
        EditFhigh matlab.ui.control.EditField
        EditTaner matlab.ui.control.EditField
        DropBandFilter matlab.ui.control.DropDown

        PanelPower matlab.ui.container.Panel
        LabelFmax matlab.ui.control.Label
        LabelFmin matlab.ui.control.Label
        LabelPmax matlab.ui.control.Label
        LabelPmin matlab.ui.control.Label
        EditXmax matlab.ui.control.EditField
        EditXmin matlab.ui.control.EditField
        EditYmax matlab.ui.control.EditField
        EditYmin matlab.ui.control.EditField

        PanelHL matlab.ui.container.Panel
        GroupPass matlab.ui.container.ButtonGroup
        RadioHigh matlab.ui.control.RadioButton
        RadioLow matlab.ui.control.RadioButton
        RadioStop matlab.ui.control.RadioButton
        EditPass1 matlab.ui.control.EditField
        EditPass2 matlab.ui.control.EditField
        DropHLFilter matlab.ui.control.DropDown

        ButtonSave matlab.ui.control.Button

        LabelSpec matlab.ui.control.Label
        LabelName matlab.ui.control.Label

        AxesTop matlab.ui.control.UIAxes
        AxesBottom matlab.ui.control.UIAxes
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
        main_unit_selection double = 0

        current_data double = zeros(0,2)
        data_name char = ''
        dat_name char = ''
        ext char = ''
        unit char = ''
        unit_type double = 0

        step double = 0
        x_1 double = 0
        x_2 double = 0
        y_1 double = 0
        y_2 double = 0
        y_3 double = 0

        filter char = 'Gaussian'
        filt_flow double = 0
        filt_fhigh double = 0
        filt_fmid double = 0
        taner_c double = 1e12

        f_fft double = zeros(0,1)
        P1 double = zeros(0,1)
        f_mtm double = zeros(0,1)
        p_mtm double = zeros(0,1)

        add_list char = ''
        data_filterout double = zeros(0,2)
        ifaze double = zeros(0,1)
        ifreq double = zeros(0,1)
        add_list_am char = ''
        add_list_ufaze char = ''
        add_list_ufazedet char = ''
        add_list_ifaze char = ''
        add_list_ifreq char = ''

        UIBg double = [0.94 0.94 0.94]
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
            w = max(1050, normPos(3)*screen(3));
            h = max(570, normPos(4)*screen(4));
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
            app.UIFigure = uifigure('Name','Acycle: Filtering', ...
                'Color',app.UIBg, 'Resize','on', ...
                'Position',app.normalizedToPixelPosition([0.3,0.2,0.4875,0.3]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.PanelBand = uipanel(app.UIFigure,'Title','Bandpass filter: frequency', ...
                'BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.LabelFlow = uilabel(app.PanelBand,'Text','f lower','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize);
            app.LabelFhigh = uilabel(app.PanelBand,'Text','f upper','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize);
            app.EditFlow = uieditfield(app.PanelBand,'text','FontSize',app.UIFontSize, ...
                'HorizontalAlignment','center','ValueChangedFcn',@(~,~)app.onBandChanged());
            app.EditFhigh = uieditfield(app.PanelBand,'text','FontSize',app.UIFontSize, ...
                'HorizontalAlignment','center','ValueChangedFcn',@(~,~)app.onBandChanged());
            app.LabelFcenter = uilabel(app.PanelBand,'Text','f center: 0', ...
                'BackgroundColor',app.UIBg,'FontSize',app.UIFontSize,'FontWeight','bold','FontColor',[0 0 0.8]);
            app.LabelRoll = uilabel(app.PanelBand,'Text','Roll-off: 10^','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize);
            app.EditTaner = uieditfield(app.PanelBand,'text','Value','12','FontSize',app.UIFontSize, ...
                'HorizontalAlignment','center','ValueChangedFcn',@(~,~)app.onBandChanged());
            app.DropBandFilter = uidropdown(app.PanelBand,'Items',{'Gaussian','Taner-Hilbert','Cheby1','Ellip','Butter'}, ...
                'Value','Gaussian','FontSize',app.UIFontSize,'ValueChangedFcn',@(~,~)app.onBandFilterChanged());

            app.PanelPower = uipanel(app.UIFigure,'Title','Power spectra plot', ...
                'BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.LabelFmax = uilabel(app.PanelPower,'Text','f max','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize);
            app.LabelFmin = uilabel(app.PanelPower,'Text','f min','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize);
            app.LabelPmax = uilabel(app.PanelPower,'Text','Power max','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize);
            app.LabelPmin = uilabel(app.PanelPower,'Text','Power min','BackgroundColor',app.UIBg,'FontSize',app.UIFontSize);
            app.EditXmax = uieditfield(app.PanelPower,'text','FontSize',app.UIFontSize,'HorizontalAlignment','center', ...
                'ValueChangedFcn',@(~,~)app.onAxisRangeChanged());
            app.EditXmin = uieditfield(app.PanelPower,'text','FontSize',app.UIFontSize,'HorizontalAlignment','center', ...
                'ValueChangedFcn',@(~,~)app.onAxisRangeChanged());
            app.EditYmax = uieditfield(app.PanelPower,'text','FontSize',app.UIFontSize,'HorizontalAlignment','center', ...
                'ValueChangedFcn',@(~,~)app.onAxisRangeChanged());
            app.EditYmin = uieditfield(app.PanelPower,'text','FontSize',app.UIFontSize,'HorizontalAlignment','center', ...
                'ValueChangedFcn',@(~,~)app.onAxisRangeChanged());

            app.PanelHL = uipanel(app.UIFigure,'Title','Highpass and lowpass', ...
                'BackgroundColor',app.UIBg,'FontSize',app.UIFontSize+1);
            app.GroupPass = uibuttongroup(app.PanelHL,'BorderType','none','BackgroundColor',app.UIBg, ...
                'SelectionChangedFcn',@(~,~)app.onPassModeChanged());
            app.RadioHigh = uiradiobutton(app.GroupPass,'Text','Highpass','Value',true,'FontSize',app.UIFontSize);
            app.RadioLow = uiradiobutton(app.GroupPass,'Text','Lowpass','FontSize',app.UIFontSize);
            app.RadioStop = uiradiobutton(app.GroupPass,'Text','Bandstop','FontSize',app.UIFontSize);
            app.EditPass1 = uieditfield(app.PanelHL,'text','FontSize',app.UIFontSize,'HorizontalAlignment','center', ...
                'ValueChangedFcn',@(~,~)app.onHighLowChanged());
            app.EditPass2 = uieditfield(app.PanelHL,'text','FontSize',app.UIFontSize,'HorizontalAlignment','center', ...
                'Visible','off','ValueChangedFcn',@(~,~)app.onHighLowChanged());
            app.DropHLFilter = uidropdown(app.PanelHL,'Items',{'Butter','Cheby1','Ellip'}, ...
                'Value','Butter','FontSize',app.UIFontSize,'ValueChangedFcn',@(~,~)app.onHighLowChanged());

            app.ButtonSave = uibutton(app.UIFigure,'push','Text','Save Data', ...
                'FontSize',app.UIFontSize+2,'ButtonPushedFcn',@(~,~)app.onSave());

            app.LabelSpec = uilabel(app.UIFigure,'Text','FFT & 2π MTM','BackgroundColor',app.UIBg, ...
                'FontSize',app.UIFontSize+1,'HorizontalAlignment','center');
            app.LabelName = uilabel(app.UIFigure,'Text','', 'BackgroundColor',app.UIBg, ...
                'FontSize',app.UIFontSize+1,'HorizontalAlignment','left');

            app.AxesTop = uiaxes(app.UIFigure);
            app.AxesBottom = uiaxes(app.UIFigure);

            app.applyLayout();
        end

        function applyLayout(app)
            r = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];
            app.LabelSpec.Position = app.childPos(r,[0.45,0.903,0.12,0.05]);
            app.LabelName.Position = app.childPos(r,[0.57,0.903,0.415,0.05]);

            app.AxesTop.Position = app.childPos(r,[0.411,0.523,0.546,0.364]);
            app.AxesBottom.Position = app.childPos(r,[0.411,0.084,0.546,0.367]);

            app.PanelBand.Position = app.childPos(r,[0.02,0.45,0.19,0.53]);
            app.LabelFlow.Position = app.childPos(app.PanelBand.Position,[0.054,0.73,0.415,0.122]);
            app.LabelFhigh.Position = app.childPos(app.PanelBand.Position,[0.054,0.535,0.415,0.122]);
            app.LabelFcenter.Position = app.childPos(app.PanelBand.Position,[0.054,0.365,0.95,0.122]);
            app.LabelRoll.Position = app.childPos(app.PanelBand.Position,[0.054,0.21,0.55,0.122]);
            app.DropBandFilter.Position = app.childPos(app.PanelBand.Position,[0.09,0.015,0.77,0.12]);
            app.EditFlow.Position = app.childPos(app.PanelBand.Position,[0.503,0.725,0.395,0.145]);
            app.EditFhigh.Position = app.childPos(app.PanelBand.Position,[0.503,0.53,0.395,0.145]);
            app.EditTaner.Position = app.childPos(app.PanelBand.Position,[0.59,0.26,0.28,0.1]);

            app.PanelPower.Position = app.childPos(r,[0.215,0.45,0.149,0.53]);
            app.LabelFmax.Position = app.childPos(app.PanelPower.Position,[0.074,0.754,0.4,0.094]);
            app.LabelFmin.Position = app.childPos(app.PanelPower.Position,[0.074,0.58,0.4,0.094]);
            app.LabelPmax.Position = app.childPos(app.PanelPower.Position,[0.074,0.4,0.4,0.094]);
            app.LabelPmin.Position = app.childPos(app.PanelPower.Position,[0.074,0.22,0.4,0.094]);
            app.EditXmax.Position = app.childPos(app.PanelPower.Position,[0.5,0.717,0.426,0.159]);
            app.EditXmin.Position = app.childPos(app.PanelPower.Position,[0.5,0.536,0.426,0.159]);
            app.EditYmax.Position = app.childPos(app.PanelPower.Position,[0.5,0.362,0.426,0.159]);
            app.EditYmin.Position = app.childPos(app.PanelPower.Position,[0.5,0.181,0.426,0.159]);

            app.PanelHL.Position = app.childPos(r,[0.02,0.05,0.19,0.4]);
            app.GroupPass.Position = app.childPos(app.PanelHL.Position,[0.04,0.26,0.62,0.62]);
            app.RadioHigh.Position = app.childPos(app.GroupPass.Position,[0.02,0.68,0.95,0.25]);
            app.RadioLow.Position = app.childPos(app.GroupPass.Position,[0.02,0.38,0.95,0.25]);
            app.RadioStop.Position = app.childPos(app.GroupPass.Position,[0.02,0.08,0.95,0.25]);
            app.EditPass1.Position = app.childPos(app.PanelHL.Position,[0.626,0.70,0.35,0.145]);
            app.EditPass2.Position = app.childPos(app.PanelHL.Position,[0.626,0.495,0.35,0.145]);
            app.DropHLFilter.Position = app.childPos(app.PanelHL.Position,[0.06,0.064,0.88,0.14]);

            app.ButtonSave.Position = app.childPos(r,[0.236,0.156,0.093,0.256]);
        end

        function initializeState(app)
            c = app.Context;
            if isfield(c,'MonZoom'), app.MonZoom = c.MonZoom; end
            if isfield(c,'val1'), app.val1 = c.val1; end
            if isfield(c,'lang_choice'), app.lang_choice = c.lang_choice; end
            if isfield(c,'lang_id'), app.lang_id = c.lang_id; end
            if isfield(c,'lang_var'), app.lang_var = c.lang_var; end
            if isfield(c,'main_unit_selection'), app.main_unit_selection = c.main_unit_selection; end

            if isfield(c,'acfigmain'), app.acfigmain = c.acfigmain; end
            if isfield(c,'listbox_acmain'), app.listbox_acmain = c.listbox_acmain; end
            if isfield(c,'edit_acfigmain_dir'), app.edit_acfigmain_dir = c.edit_acfigmain_dir; end

            if isfield(c,'current_data'), app.current_data = c.current_data; end
            if isfield(c,'data_name'), app.data_name = c.data_name; end
            if isfield(c,'unit'), app.unit = c.unit; end
            if isfield(c,'unit_type'), app.unit_type = c.unit_type; end

            [~, app.dat_name, app.ext] = fileparts(app.data_name);
            app.LabelName.Text = app.dat_name;

            app.UIFigure.Name = app.getLang('menu113','Acycle: Filtering');
            app.PanelBand.Title = app.getLang('ft01','Bandpass filter: frequency');
            app.PanelPower.Title = app.getLang('ft02','Power spectra plot');
            app.PanelHL.Title = app.getLang('ft03','Highpass and lowpass');
            app.LabelSpec.Text = app.getLang('ft04','FFT & 2π MTM');
            app.LabelFlow.Text = app.getLang('ft05','f lower');
            app.LabelFhigh.Text = app.getLang('ft06','f upper');
            app.LabelRoll.Text = app.getLang('ft08','Roll-off: 10^');
            app.LabelFmax.Text = app.getLang('ft09','f max');
            app.LabelFmin.Text = app.getLang('ft10','f min');
            app.LabelPmax.Text = app.getLang('ft11','Power max');
            app.LabelPmin.Text = app.getLang('ft12','Power min');
            app.RadioHigh.Text = app.getLang('ft13','Highpass');
            app.RadioLow.Text = app.getLang('ft14','Lowpass');
            app.RadioStop.Text = app.getLang('ft15','Bandstop');
            app.ButtonSave.Text = app.getLang('main01','Save Data');

            if isempty(app.current_data)
                error('ft requires current_data in handles struct.');
            end
            if size(app.current_data,2) < 2
                error('ft:InsufficientColumns', ...
                    'Filtering requires at least two numeric columns.');
            end

            finiteRows = all(isfinite(app.current_data(:,1:2)),2);
            app.current_data = app.current_data(finiteRows,:);
            app.current_data = sortrows(app.current_data,1);
            app.current_data = findduplicate(app.current_data);
            if size(app.current_data,1) < 2
                error('ft:InsufficientFiniteData', ...
                    'Filtering requires at least two finite unique samples.');
            end
            app.current_data(:,2) = app.current_data(:,2) - mean(app.current_data(:,2));

            diffx = diff(app.current_data(:,1));
            if acycleSamplingIsUneven(app.current_data(:,1))
                warndlg(app.getLang('ec25','Warning: the data may not be evenly spaced.'));
                app.current_data = interpolate( ...
                    app.current_data,median(diffx));
                diffx = diff(app.current_data(:,1));
            end

            app.step = median(diffx);
            [app.f_fft, app.P1, app.f_mtm, app.p_mtm] = app.computeSpectra(app.current_data);

            app.x_1 = 0;
            app.x_2 = 0.5 * max(app.f_fft);
            app.y_1 = 0;
            app.y_2 = max(app.P1);
            app.y_3 = max(app.p_mtm);

            app.EditXmin.Value = num2str(app.x_1);
            app.EditXmax.Value = num2str(app.x_2);
            app.EditYmin.Value = num2str(app.y_1);
            app.EditYmax.Value = num2str(app.y_2);

            [~,idx] = max(app.P1);
            fq = app.f_fft(idx);
            app.filt_fmid = fq;
            app.filt_flow = fq*0.8;
            app.filt_fhigh = fq*1.2;
            app.EditFlow.Value = num2str(app.filt_flow);
            app.EditFhigh.Value = num2str(app.filt_fhigh);
            app.EditPass1.Value = num2str(fq);

            app.DropBandFilter.Value = 'Gaussian';
            app.LabelRoll.Visible = 'off';
            app.EditTaner.Visible = 'off';
            app.EditTaner.Editable = 'off';
            app.DropHLFilter.Value = 'Butter';
            app.GroupPass.SelectedObject = app.RadioHigh;
            app.EditPass2.Visible = 'off';

            app.updateBottomMtmPlot();
            app.updateBandpassPreview();
        end

        function [f,P1,fd2,po2] = computeSpectra(app, data)
            L = length(data(:,2));
            dt = mean(diff(data(:,1)));
            try
                [po2,w2] = pmtm(data(:,2),2,5*length(data(:,1)));
                fd2 = w2/(2*pi*app.step);
            catch
                % fallback if pmtm unavailable
                Y0 = fft(data(:,2),L);
                P20 = abs(Y0/L);
                po2 = P20(1:floor(L/2)+1);
                po2(2:end-1) = 2*po2(2:end-1);
                fd2 = (1/dt) * (0:(L/2))/L;
            end
            Y = fft(data(:,2),L);
            P2 = abs(Y/L);
            P1 = P2(1:floor(L/2)+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = (1/dt) * (0:(L/2))/L;
        end

        function updateBottomMtmPlot(app)
            plot(app.AxesBottom, app.f_mtm, app.p_mtm, 'Color', [0.2 0.65 0.95]);
            xlim(app.AxesBottom, [app.x_1 app.x_2]);
            ylim(app.AxesBottom, [app.y_1 app.y_3]);
            xlabel(app.AxesBottom, ['Frequency (cycles/',app.unit,')']);
            app.AxesBottom.Box = 'on';
        end

        function onBandFilterChanged(app)
            app.filter = app.DropBandFilter.Value;
            if strcmp(app.filter,'Taner-Hilbert')
                app.EditTaner.Editable = 'on';
                app.LabelRoll.Visible = 'on';
                app.EditTaner.Visible = 'on';
            else
                app.EditTaner.Editable = 'off';
                app.LabelRoll.Visible = 'off';
                app.EditTaner.Visible = 'off';
            end
            app.updateBandpassPreview();
        end

        function onBandChanged(app)
            app.updateBandpassPreview();
        end

        function onAxisRangeChanged(app)
            app.updateBandpassPreview();
        end

        function onPassModeChanged(app)
            if app.RadioStop.Value
                app.EditPass2.Visible = 'on';
            else
                app.EditPass2.Visible = 'off';
            end
            app.updateHighLowPreview();
        end

        function onHighLowChanged(app)
            app.updateHighLowPreview();
        end

        function updateBandpassPreview(app)
            app.DropHLFilter.Value = 'Butter';

            data = app.current_data;
            time = data(:,1);
            datax = data(:,2);
            dt = mean(diff(time));
            nyquist = 1/(2*dt);

            flow = str2double(app.EditFlow.Value);
            fhigh = str2double(app.EditFhigh.Value);
            if isnan(flow) || isnan(fhigh)
                return
            end
            if fhigh <= flow
                fc = (fhigh + flow)/2;
                flow = 0.8*fc;
                fhigh = 1.2*fc;
                app.EditFlow.Value = num2str(flow);
                app.EditFhigh.Value = num2str(fhigh);
            end
            fc = (flow + fhigh)/2;
            flch = sort([flow fc fhigh]);
            app.filt_flow = flch(1); app.filt_fmid = flch(2); app.filt_fhigh = flch(3);
            app.LabelFcenter.Text = [app.getLang('ft07','f center'),': ',num2str(fc)];

            app.x_1 = str2double(app.EditXmin.Value);
            app.x_2 = str2double(app.EditXmax.Value);
            app.y_1 = str2double(app.EditYmin.Value);
            app.y_2 = str2double(app.EditYmax.Value);
            if any(isnan([app.x_1,app.x_2,app.y_1,app.y_2]))
                return
            end

            f = app.f_fft; P1 = app.P1;
            plot(app.AxesTop, f, P1, 'Color', [0.2 0.65 0.95]); hold(app.AxesTop,'on');

            app.filter = app.DropBandFilter.Value;
            taner_c = 10^str2double(app.EditTaner.Value);
            add_list = '';
            data_filterout = [];

            if strcmp(app.filter,'Gaussian')
                [gaussbandx,filter1,f1] = gaussfilter(datax,dt,flch(2),flch(1),flch(3));
                gaussbandxAM = abs(hilbert(gaussbandx));
                plot(app.AxesTop, f1, max(P1)*filter1, 'r-');
                data_filterout = [time,gaussbandx,gaussbandxAM];
                add_list = [app.dat_name,'-Gau-flow-',num2str(flch(1)),'-fhigh-',num2str(flch(3)),'.txt'];

            elseif strcmp(app.filter,'Taner-Hilbert')
                [tanhilb,app.ifaze,app.ifreq] = tanerhilbertML(data,flch(2),flch(1),flch(3),taner_c);
                tanerfilterenv = evalin('base','tanerfilterenv');
                tf = tanerfilterenv(1:floor(length(P1))) ./ max(tanerfilterenv(1:floor(length(P1)))) .* max(P1);
                plot(app.AxesTop, f, tf, 'r-');
                data_filterout = tanhilb;
                add_list = [app.dat_name,'-Tan-flow-',num2str(flch(1)),'-fhigh-',num2str(flch(3)),'-e',num2str(log10(taner_c)),'.txt'];
                app.add_list_am = [app.dat_name,'-Tan-flow-',num2str(flch(1)),'-fhigh-',num2str(flch(3)),'-e',num2str(log10(taner_c)),'-AM.txt'];
                app.add_list_ufaze = [app.dat_name,'-Tan-flow-',num2str(flch(1)),'-fhigh-',num2str(flch(3)),'-e',num2str(log10(taner_c)),'-ufaze.txt'];
                app.add_list_ufazedet = [app.dat_name,'-Tan-flow-',num2str(flch(1)),'-fhigh-',num2str(flch(3)),'-e',num2str(log10(taner_c)),'-ufazedet.txt'];
                app.add_list_ifaze = [app.dat_name,'-Tan-flow-',num2str(flch(1)),'-fhigh-',num2str(flch(3)),'-e',num2str(log10(taner_c)),'-ifaze.txt'];
                app.add_list_ifreq = [app.dat_name,'-Tan-flow-',num2str(flch(1)),'-fhigh-',num2str(flch(3)),'-e',num2str(log10(taner_c)),'-ifreq.txt'];

            elseif any(strcmp(app.filter,{'Cheby1','Ellip','Butter'}))
                flowN = flch(1)/nyquist;
                fhighN = flch(3)/nyquist;
                if strcmp(app.filter,'Cheby1')
                    d = designfilt('bandpassiir','FilterOrder',6,'PassbandFrequency1',flowN,'PassbandFrequency2',fhighN,'PassbandRipple',1,'DesignMethod','cheby1');
                elseif strcmp(app.filter,'Ellip')
                    d = designfilt('bandpassiir','FilterOrder',6,'PassbandFrequency1',flowN,'PassbandFrequency2',fhighN,'StopbandAttenuation1',20,'PassbandRipple',1,'StopbandAttenuation2',20,'DesignMethod','ellip');
                else
                    d = designfilt('bandpassiir','FilterOrder',6,'HalfPowerFrequency1',flowN,'HalfPowerFrequency2',fhighN,'DesignMethod','butter');
                end
                yb = filtfilt(d,datax);
                ybam = abs(hilbert(yb));
                data_filterout = [time,yb,ybam];
                add_list = [app.dat_name,'-',app.filter,'-flow-',num2str(flch(1)),'-fhigh-',num2str(flch(3)),'.txt'];
            end

            xlim(app.AxesTop,[app.x_1 app.x_2]);
            ylim(app.AxesTop,[app.y_1 app.y_2]);
            hold(app.AxesTop,'off');

            xlim(app.AxesBottom,[app.x_1 app.x_2]);
            app.add_list = add_list;
            app.data_filterout = data_filterout;
        end

        function updateHighLowPreview(app)
            app.DropBandFilter.Value = 'Gaussian';
            app.LabelRoll.Visible = 'off';
            app.EditTaner.Visible = 'off';
            app.EditTaner.Editable = 'off';
            app.filter = app.DropHLFilter.Value;

            data = app.current_data;
            time = data(:,1);
            datax = data(:,2);
            dt = mean(diff(time));
            L = length(datax);
            nyquist = 1/(2*dt);
            rayleigh = 1/(dt*L);

            x1 = str2double(app.EditXmin.Value);
            x2 = str2double(app.EditXmax.Value);
            y1 = str2double(app.EditYmin.Value);
            y2 = str2double(app.EditYmax.Value);
            if any(isnan([x1,x2,y1,y2]))
                return
            end

            plot(app.AxesTop, app.f_fft, app.P1, 'Color',[0.2 0.65 0.95]); hold(app.AxesTop,'on');

            f11 = str2double(app.EditPass1.Value);
            f12 = str2double(app.EditPass2.Value);
            if isnan(f11), hold(app.AxesTop,'off'); return; end

            if app.RadioHigh.Value
                passtype = 'highpassiir';
                f1 = f11/nyquist;
                plot(app.AxesTop,[f11 f11],[y1 y2],'r-');
                plot(app.AxesTop,[f11 max(app.f_fft)],[y2 y2],'r-');
            elseif app.RadioLow.Value
                passtype = 'lowpassiir';
                f1 = f11/nyquist;
                plot(app.AxesTop,[f11 f11],[y1 y2],'r-');
                plot(app.AxesTop,[0 f11],[y2 y2],'r-');
            else
                passtype = 'bandstopiir';
                if isnan(f12), hold(app.AxesTop,'off'); return; end
                ff = sort([f11 f12]);
                f11 = ff(1); f12 = ff(2);
                flow = f11/nyquist; fhigh = f12/nyquist;
                passband1 = flow + 2*rayleigh/nyquist;
                passband2 = fhigh - 2*rayleigh/nyquist;
                f1 = [flow fhigh];
                plot(app.AxesTop,[f11 f11],[y1 y2],'r-');
                plot(app.AxesTop,[f12 f12],[y1 y2],'r-');
                plot(app.AxesTop,[0 f11],[y2 y2],'r-');
                plot(app.AxesTop,[f12 max(app.f_fft)],[y2 y2],'r-');
            end

            xlim(app.AxesTop,[x1 x2]); ylim(app.AxesTop,[y1 y2]); hold(app.AxesTop,'off');
            xlim(app.AxesBottom,[x1 x2]);

            add_list = '';
            if any(strcmp(passtype,{'highpassiir','lowpassiir'}))
                if strcmp(app.filter,'Butter')
                    d = designfilt(passtype,'FilterOrder',6,'HalfPowerFrequency',f1,'DesignMethod','butter');
                    add_list = [app.dat_name,passtype,'butter-',num2str(f11),'.txt'];
                elseif strcmp(app.filter,'Cheby1')
                    d = designfilt(passtype,'FilterOrder',6,'PassbandFrequency',f1,'PassbandRipple',1,'DesignMethod','cheby1');
                    add_list = [app.dat_name,passtype,'cheby1-',num2str(f11),'.txt'];
                else
                    d = designfilt(passtype,'FilterOrder',6,'PassbandFrequency',f1,'PassbandRipple',1,'StopbandAttenuation',20,'DesignMethod','ellip');
                    add_list = [app.dat_name,passtype,'ellip-',num2str(f11),'.txt'];
                end
            else
                if strcmp(app.filter,'Butter')
                    d = designfilt(passtype,'FilterOrder',6,'HalfPowerFrequency1',f1(1),'HalfPowerFrequency2',f1(2),'DesignMethod','butter');
                    add_list = [app.dat_name,passtype,'butter-',num2str(f1(1)*nyquist),'-',num2str(f1(2)*nyquist),'.txt'];
                elseif strcmp(app.filter,'Cheby1')
                    d = designfilt(passtype,'PassbandFrequency1',f1(1),'StopbandFrequency1',passband1,'StopbandFrequency2',passband2,'PassbandFrequency2',f1(2), ...
                        'PassbandRipple1',1,'PassbandRipple2',1,'StopbandAttenuation',20,'DesignMethod','cheby1','MatchExactly','both');
                    add_list = [app.dat_name,passtype,'cheby1-',num2str(f1(1)*nyquist),'-',num2str(f1(2)*nyquist),'.txt'];
                else
                    d = designfilt(passtype,'PassbandFrequency1',f1(1),'StopbandFrequency1',passband1,'StopbandFrequency2',passband2,'PassbandFrequency2',f1(2), ...
                        'PassbandRipple1',1,'PassbandRipple2',1,'StopbandAttenuation',20,'DesignMethod','ellip','MatchExactly','both');
                    add_list = [app.dat_name,passtype,'ellip-',num2str(f1(1)*nyquist),'-',num2str(f1(2)*nyquist),'.txt'];
                end
            end

            yb = filtfilt(d,datax);
            app.data_filterout = [time,yb];
            app.add_list = add_list;
        end

        function onSave(app)
            if isempty(app.add_list)
                errordlg(app.getLang('ft16','Select filtering method'));
                return
            end

            figft = app.UIFigure;
            data_filterout = app.data_filterout;
            filter = app.filter;

            pre_dirML = pwd;
            CDac_pwd;
            saveDir = pwd;
            cleanupObj = onCleanup(@()cd(pre_dirML)); %#ok<NASGU>
            dlmwrite(app.add_list, data_filterout, 'delimiter',' ', 'precision', 9);

            figdata = figure;
            data = app.current_data;
            plot(data(:,1),data(:,2),'k'); hold on;
            plot(data_filterout(:,1),data_filterout(:,2),'r');
            xlim([min(data(:,1)),max(data(:,1))]);
            title(app.add_list,'Interpreter','none');

            if app.main_unit_selection == 0 || app.lang_choice == 0
                if app.unit_type == 0
                    xlabel(['Unit (',app.unit,')']);
                elseif app.unit_type == 1
                    xlabel(['Depth (',app.unit,')']);
                else
                    xlabel(['Time (',app.unit,')']);
                end
            else
                if app.unit_type == 0
                    xlabel([app.getLang('main34','Unit'),' (',app.unit,')']);
                elseif app.unit_type == 1
                    xlabel([app.getLang('main23','Depth'),' (',app.unit,')']);
                else
                    xlabel([app.getLang('main21','Time'),' (',app.unit,')']);
                end
            end
            set(gca,'XMinorTick','on','YMinorTick','on');

            if strcmp(filter,'Taner-Hilbert')
                ampmod = [data_filterout(:,1),data_filterout(:,3)];
                ifaze = [data_filterout(:,1),app.ifaze];
                ifreq = [data_filterout(1:end-1,1),app.ifreq];
                dlmwrite(app.add_list, data_filterout(:,1:2), 'delimiter', ' ', 'precision', 9);
                dlmwrite(app.add_list_am, ampmod, 'delimiter', ' ', 'precision', 9);
                dlmwrite(app.add_list_ufaze,[data_filterout(:,1),data_filterout(:,4)], 'delimiter', ' ', 'precision', 9);
                dlmwrite(app.add_list_ifaze, ifaze, 'delimiter', ' ', 'precision', 9);
                dlmwrite(app.add_list_ifreq, ifreq, 'delimiter', ' ', 'precision', 9);

                plot(data_filterout(:,1),data_filterout(:,3),'b');

                figure;
                t = data_filterout(:,1);
                xx = data_filterout(:,2);
                subplot(4,1,1); plot(t,xx); hold on; plot(t,data_filterout(:,3)); hold off;
                title(app.getLang('ft17','Modulated signal & Instantaneous amplitude'));
                xlim([min(data(:,1)),max(data(:,1))]); set(gca,'XMinorTick','on','YMinorTick','on');

                subplot(4,1,2); plot(t,data_filterout(:,4));
                title(app.getLang('ft18','Unrolled instantaneous phase'));
                xlim([min(data(:,1)),max(data(:,1))]); set(gca,'XMinorTick','on','YMinorTick','on');

                sdat = polyfit(t,data_filterout(:,4),1);
                iphasedet = data_filterout(:,4) - (t-t(1))*sdat(1);
                subplot(4,1,3); plot(t,iphasedet);
                title(app.getLang('ft19','Instantaneous phase'));
                ylabel(app.getLang('ft20','phase (radians)'));
                xlim([min(data(:,1)),max(data(:,1))]); set(gca,'XMinorTick','on','YMinorTick','on');

                subplot(4,1,4); plot(t(1:end-1),app.ifreq);
                title(app.getLang('ft21','Instantaneous frequency'));
                xlim([min(data(:,1)),max(data(:,1))]); set(gca,'XMinorTick','on','YMinorTick','on');

                if app.unit_type == 0
                    xlabel(['Unit (',app.unit,')']);
                elseif app.unit_type == 1
                    xlabel(['Depth (',app.unit,')']);
                else
                    xlabel(['Time (',app.unit,')']);
                end

                dlmwrite(app.add_list_ufazedet, [t,iphasedet], 'delimiter', ' ', 'precision', 9);
            end

            app.refreshMainListbox(saveDir);
            disp(app.getLang('ft22','>> Done. See AC main window for the filtered output file(s)'));
            try figure(figft); catch, end
            try figure(figdata); catch, end
        end

        function refreshMainListbox(app,dirpath)
            if isempty(app.listbox_acmain) || ~isgraphics(app.listbox_acmain)
                return
            end
            if nargin < 2 || isempty(dirpath) || exist(dirpath,'dir') ~= 7
                dirpath = pwd;
            end
            if ac_refresh_main_list(app.listbox_acmain,dirpath)
                return
            end
            try
                d = dir(dirpath);
                if numel(d) >= 2
                    d = d(~ismember({d.name},{'.','..'}));
                end
                names = {};
                isDir = false(0,1);
                if ~isempty(d)
                    sortMode = app.getSortMode();
                    sd = ac_sort_dir_entries(d,sortMode);
                    names = {sd.name};
                    isDir = [sd.isdir];
                end
                if ~isempty(app.edit_acfigmain_dir) && isgraphics(app.edit_acfigmain_dir)
                    set(app.edit_acfigmain_dir,'String',dirpath);
                end
                app.syncAcPwd(dirpath);
                ac_update_listbox_acmain(app.listbox_acmain,names,isDir);
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
                ac_working_directory('set',dirpath);
            catch
            end
        end
    end

    methods (Access = public)
        function app = ft(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context,'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('ft requires a handles/context struct input.');
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
