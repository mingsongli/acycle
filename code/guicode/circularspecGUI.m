classdef circularspecGUI < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE circularspecGUI.

    properties (Access = public)
        UIFigure matlab.ui.Figure

        LabelData matlab.ui.control.Label
        LabelDataName matlab.ui.control.Label

        PanelTest matlab.ui.container.Panel
        GroupLinLog matlab.ui.container.ButtonGroup
        RadioLinear matlab.ui.control.RadioButton
        RadioLog matlab.ui.control.RadioButton
        LabelMin matlab.ui.control.Label
        EditMin matlab.ui.control.EditField
        LabelMax matlab.ui.control.Label
        EditMax matlab.ui.control.EditField
        LabelSteps matlab.ui.control.Label
        EditSteps matlab.ui.control.EditField
        LabelInfo matlab.ui.control.Label

        PanelSliding matlab.ui.container.Panel
        LabelMonte matlab.ui.control.Label
        EditMonte matlab.ui.control.EditField

        GroupDistance matlab.ui.container.ButtonGroup
        RadioRandom matlab.ui.control.RadioButton
        RadioFixed matlab.ui.control.RadioButton

        GroupNoise matlab.ui.container.ButtonGroup
        RadioWhite matlab.ui.control.RadioButton
        RadioRed matlab.ui.control.RadioButton

        CheckSave matlab.ui.control.CheckBox
        CheckFlipX matlab.ui.control.CheckBox
        ButtonOK matlab.ui.control.Button
    end

    properties (Access = private)
        Context struct = struct()
        MonZoom double = 1
        sortdata
        val1 double = 1

        dat
        unit = ''
        unit_type double = 0
        slash_v
        acfigmain
        data_name = ''
        path_temp = ''
        listbox_acmain
        edit_acfigmain_dir
        filename = ''

        lang_choice double = 0
        lang_id = {}
        lang_var = {}

        dt double = 0
        fh double = 0
        sedmin double = 0
        sedmax double = 0
        numsed double = 100
        linLog double = 2 % 1=log 2=linear

        UIColorBg double = [0.94 0.94 0.94]
        UIColorBlue double = [0.08 0.12 0.92]
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
            w = max(1100, normPos(3)*screen(3));
            h = max(540, normPos(4)*screen(4));
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
            if isempty(app.lang_id) || isempty(app.lang_var)
                return
            end
            [~, idx] = ismember(key, app.lang_id);
            if idx > 0 && idx <= numel(app.lang_var)
                txt = app.lang_var{idx};
            end
        end

        function applyLayout(app)
            fr = [0 0 app.UIFigure.Position(3) app.UIFigure.Position(4)];

            app.LabelData.Position = app.childPos(fr,[0.05 0.85 0.10 0.075]);
            app.LabelDataName.Position = app.childPos(fr,[0.15 0.85 0.80 0.075]);

            app.PanelTest.Position = app.childPos(fr,[0.05 0.365 0.90 0.46]);
            app.GroupLinLog.Position = app.childPos(app.PanelTest.Position,[0.02 0.10 0.14 0.80]);
            app.RadioLinear.Position = app.childPos(app.GroupLinLog.Position,[0.05 0.55 0.90 0.35]);
            app.RadioLog.Position = app.childPos(app.GroupLinLog.Position,[0.05 0.08 0.90 0.35]);

            app.LabelMin.Position = app.childPos(app.PanelTest.Position,[0.18 0.50 0.12 0.19]);
            app.EditMin.Position = app.childPos(app.PanelTest.Position,[0.325 0.50 0.10 0.324]);
            app.LabelMax.Position = app.childPos(app.PanelTest.Position,[0.45 0.50 0.12 0.19]);
            app.EditMax.Position = app.childPos(app.PanelTest.Position,[0.60 0.50 0.10 0.324]);
            app.LabelSteps.Position = app.childPos(app.PanelTest.Position,[0.72 0.50 0.13 0.19]);
            app.EditSteps.Position = app.childPos(app.PanelTest.Position,[0.85 0.50 0.10 0.324]);

            app.LabelInfo.Position = app.childPos(app.PanelTest.Position,[0.18 0.05 0.76 0.34]);

            app.PanelSliding.Position = app.childPos(fr,[0.05 0.05 0.60 0.30]);
            app.LabelMonte.Position = app.childPos(app.PanelSliding.Position,[0.015 0.376 0.20 0.35]);
            app.EditMonte.Position = app.childPos(app.PanelSliding.Position,[0.22 0.376 0.16 0.40]);

            app.GroupDistance.Position = app.childPos(app.PanelSliding.Position,[0.39 0.02 0.28 0.96]);
            app.RadioRandom.Position = app.childPos(app.GroupDistance.Position,[0.05 0.58 0.90 0.40]);
            app.RadioFixed.Position = app.childPos(app.GroupDistance.Position,[0.05 0.10 0.90 0.40]);

            app.GroupNoise.Position = app.childPos(app.PanelSliding.Position,[0.68 0.02 0.30 0.96]);
            app.RadioWhite.Position = app.childPos(app.GroupNoise.Position,[0.15 0.50 0.82 0.45]);
            app.RadioRed.Position = app.childPos(app.GroupNoise.Position,[0.15 0.05 0.82 0.45]);

            app.CheckSave.Position = app.childPos(fr,[0.66 0.16 0.15 0.14]);
            app.CheckFlipX.Position = app.childPos(fr,[0.66 0.06 0.15 0.14]);
            app.ButtonOK.Position = app.childPos(fr,[0.83 0.055 0.12 0.23]);
        end

        function createComponents(app)
            app.UIFigure = uifigure('Name','Acycle: Circular spectral analysis', ...
                'Color',app.UIColorBg, ...
                'Resize','on', ...
                'Position', app.normalizedToPixelPosition([0.2,0.3,0.45,0.28]));
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(~,~)app.applyLayout();

            app.LabelData = uilabel(app.UIFigure,'Text','Data:', ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold','BackgroundColor',app.UIColorBg);
            app.LabelDataName = uilabel(app.UIFigure,'Text','', ...
                'FontSize',app.UIFontSize+1,'BackgroundColor',app.UIColorBg);

            app.PanelTest = uipanel(app.UIFigure,'Title','Test period', ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold','BackgroundColor',app.UIColorBg);

            app.GroupLinLog = uibuttongroup(app.PanelTest,'Title','', ...
                'BorderType','none','BackgroundColor',app.UIColorBg, ...
                'SelectionChangedFcn',@(~,~)app.onLinLogChanged());
            app.RadioLinear = uiradiobutton(app.GroupLinLog,'Text','Linear', ...
                'FontSize',app.UIFontSize+1,'Value',true);
            app.RadioLog = uiradiobutton(app.GroupLinLog,'Text','Log', ...
                'FontSize',app.UIFontSize+1,'Value',false);

            app.LabelMin = uilabel(app.PanelTest,'Text','Minimum', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'BackgroundColor',app.UIColorBg);
            app.EditMin = uieditfield(app.PanelTest,'text','HorizontalAlignment','center', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'BackgroundColor',[1 1 1], ...
                'ValueChangedFcn',@(~,~)app.onMinChanged());

            app.LabelMax = uilabel(app.PanelTest,'Text','maximum', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'BackgroundColor',app.UIColorBg);
            app.EditMax = uieditfield(app.PanelTest,'text','HorizontalAlignment','center', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'BackgroundColor',[1 1 1], ...
                'ValueChangedFcn',@(~,~)app.onMaxChanged());

            app.LabelSteps = uilabel(app.PanelTest,'Text','Number of steps', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'BackgroundColor',app.UIColorBg);
            app.EditSteps = uieditfield(app.PanelTest,'text','HorizontalAlignment','center', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'BackgroundColor',[1 1 1], ...
                'ValueChangedFcn',@(~,~)app.onStepsChanged());

            app.LabelInfo = uilabel(app.PanelTest,'Text','', ...
                'FontSize',app.UIFontSize+1,'FontAngle','italic','BackgroundColor',app.UIColorBg);

            app.PanelSliding = uipanel(app.UIFigure,'Title','Sliding Window', ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'ForegroundColor',app.UIColorBlue,'BackgroundColor',app.UIColorBg);

            app.LabelMonte = uilabel(app.PanelSliding,'Text','Monte Carlo #', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'BackgroundColor',app.UIColorBg);
            app.EditMonte = uieditfield(app.PanelSliding,'text','HorizontalAlignment','center', ...
                'FontSize',app.UIFontSize+1,'FontColor',app.UIColorBlue,'BackgroundColor',[1 1 1]);

            app.GroupDistance = uibuttongroup(app.PanelSliding,'Title','', ...
                'BorderType','none','BackgroundColor',app.UIColorBg, ...
                'SelectionChangedFcn',@(~,~)app.onDistanceModelChanged());
            app.RadioRandom = uiradiobutton(app.GroupDistance,'Text','Random distance', ...
                'FontSize',app.UIFontSize+1,'Value',false);
            app.RadioFixed = uiradiobutton(app.GroupDistance,'Text','Fixed distance', ...
                'FontSize',app.UIFontSize+1,'Value',true);

            app.GroupNoise = uibuttongroup(app.PanelSliding,'Title','Noise Model', ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'BackgroundColor',app.UIColorBg,'Visible','off');
            app.RadioWhite = uiradiobutton(app.GroupNoise,'Text','White', ...
                'FontSize',app.UIFontSize+1,'Value',true);
            app.RadioRed = uiradiobutton(app.GroupNoise,'Text','Red', ...
                'FontSize',app.UIFontSize+1,'Value',false);

            app.CheckSave = uicheckbox(app.UIFigure,'Text','Save data','Value',true, ...
                'FontSize',app.UIFontSize+1);
            app.CheckFlipX = uicheckbox(app.UIFigure,'Text','Flip X-axis','Value',true, ...
                'FontSize',app.UIFontSize+1);
            app.ButtonOK = uibutton(app.UIFigure,'push','Text','OK', ...
                'FontSize',app.UIFontSize+1,'FontWeight','bold', ...
                'BackgroundColor',[0.08 0.02 0.95],'FontColor',[1 1 1], ...
                'ButtonPushedFcn',@(~,~)app.onRun());

            app.applyLayout();
        end

        function initializeState(app)
            c = app.Context;
            if isfield(c,'MonZoom'), app.MonZoom = c.MonZoom; end
            if isfield(c,'sortdata'), app.sortdata = c.sortdata; end
            if isfield(c,'val1'), app.val1 = c.val1; end
            if isfield(c,'current_data'), app.dat = c.current_data; end
            if isfield(c,'unit'), app.unit = c.unit; end
            if isfield(c,'unit_type'), app.unit_type = c.unit_type; end
            if isfield(c,'slash_v'), app.slash_v = c.slash_v; end
            if isfield(c,'acfigmain'), app.acfigmain = c.acfigmain; end
            if isfield(c,'data_name'), app.data_name = c.data_name; end
            if isfield(c,'path_temp'), app.path_temp = c.path_temp; end
            if isfield(c,'listbox_acmain'), app.listbox_acmain = c.listbox_acmain; end
            if isfield(c,'edit_acfigmain_dir'), app.edit_acfigmain_dir = c.edit_acfigmain_dir; end
            if isfield(c,'lang_choice'), app.lang_choice = c.lang_choice; end
            if isfield(c,'lang_id'), app.lang_id = c.lang_id; end
            if isfield(c,'lang_var'), app.lang_var = c.lang_var; end

            [~, app.filename, ~] = fileparts(app.data_name);
            app.LabelDataName.Text = app.filename;

            if app.lang_choice > 0
                app.UIFigure.Name = app.getLang('c00','Acycle: Circular spectral analysis');
                app.LabelData.Text = [app.getLang('main02','Data'),':'];
                app.PanelTest.Title = app.getLang('c02','Test period');
                app.PanelSliding.Title = app.getLang('main07','Sliding Window');

                app.RadioLinear.Text = app.getLang('main03','Linear');
                app.RadioLog.Text = app.getLang('main04','Log');
                app.LabelMin.Text = app.getLang('main05','Minimum');
                app.LabelMax.Text = app.getLang('main06','maximum');
                app.LabelSteps.Text = app.getLang('c07','Number of steps');

                app.LabelMonte.Text = app.getLang('main08','Monte Carlo #');
                app.RadioRandom.Text = app.getLang('c13','Random distance');
                app.RadioFixed.Text = app.getLang('c14','Fixed distance');
                app.GroupNoise.Title = app.getLang('c15','Noise Model');
                app.RadioWhite.Text = app.getLang('c16','White');
                app.RadioRed.Text = app.getLang('c17','Red');
                app.CheckSave.Text = app.getLang('main01','Save data');
                app.CheckFlipX.Text = app.getLang('main09','Flip X-axis');
            else
                app.UIFigure.Name = 'Acycle: Circular spectral analysis';
            end

            % keep original behavior: if more than one column, use first column
            [~, ncol] = size(app.dat);
            if ncol > 1
                if app.lang_choice == 0
                    msgbox('More than 1 column detected. The first column data was used','Info');
                else
                    msgbox(app.getLang('c08','More than 1 column detected. The first column data was used'), ...
                           app.getLang('c09','Info'));
                end
                app.dat = app.dat(:,1);
            end

            datx = app.dat(:,1);
            datx = sort(datx);
            diffx = diff(datx);
            app.dt = min(diffx)/2;
            app.fh = (max(datx)-min(datx))/2;
            app.sedmin = app.dt;
            app.sedmax = app.fh;
            app.numsed = 100;
            app.linLog = 2;

            app.EditMin.Value = num2str(app.sedmin);
            app.EditMax.Value = num2str(app.sedmax);
            app.EditSteps.Value = num2str(app.numsed);
            app.EditMonte.Value = '10000';
            app.RadioLinear.Value = true;
            app.RadioLog.Value = false;
            app.GroupLinLog.SelectedObject = app.RadioLinear;
            app.RadioRandom.Value = false;
            app.RadioFixed.Value = true;
            app.GroupDistance.SelectedObject = app.RadioFixed;
            app.GroupNoise.Visible = 'off';

            app.CheckSave.Value = true;
            app.CheckFlipX.Value = true;

            app.UIFigure.Position = app.normalizedToPixelPosition([0.2,0.3,0.45,0.28]);
            app.applyLayout();
            app.updateSedInfo();
        end

        function onDistanceModelChanged(app)
            isRandom = app.RadioRandom.Value;
            if isRandom
                app.GroupNoise.Visible = 'on';
            else
                app.GroupNoise.Visible = 'off';
            end
        end

        function onLinLogChanged(app)
            if app.GroupLinLog.SelectedObject == app.RadioLog
                app.linLog = 1;
            else
                app.linLog = 2;
            end
            app.updateSedInfo();
        end

        function onMinChanged(app)
            v = str2double(app.EditMin.Value);
            if ~isfinite(v), return; end
            app.sedmin = v;
            if app.sedmin < app.sedmax
                if app.sedmin < app.dt
                    msgbox(['Minimum is beyond the detection limit ', num2str(app.dt)], 'Warning');
                end
                app.updateSedInfo();
            else
                msgbox('Minimum is larger than maximum','Warning');
            end
        end

        function onMaxChanged(app)
            v = str2double(app.EditMax.Value);
            if ~isfinite(v), return; end
            app.sedmax = v;
            if app.sedmax > app.sedmin
                if app.sedmax > app.fh
                    msgbox(['Maximum is beyond the detection limit ', num2str(app.fh), ' ', app.unit], 'Warning');
                end
                app.updateSedInfo();
            else
                msgbox('Maximum is smaller than minimum','Warning');
            end
        end

        function onStepsChanged(app)
            v = str2double(app.EditSteps.Value);
            if ~isfinite(v), return; end
            app.numsed = v;
            if app.numsed > 0
                if rem(app.numsed,1)
                    app.numsed = round(app.numsed);
                    app.EditSteps.Value = num2str(app.numsed);
                end
                if app.numsed < 2
                    msgbox('Number should be no less than 2','Warning');
                else
                    app.updateSedInfo();
                end
            else
                msgbox('Number should be large than 0','Warning');
            end
            if app.numsed > 2000
                msgbox('Large number, may be very slow','Warning');
            end
        end

        function sr = getPeriodArray(app)
            if app.linLog == 2
                sr = linspace(app.sedmin, app.sedmax, app.numsed);
            else
                sedinc = (log10(app.sedmax)-log10(app.sedmin))/(app.numsed-1);
                sr = zeros(1, app.numsed);
                for ii = 1:app.numsed
                    sr(ii) = 10^(log10(app.sedmin) + (ii-1)*sedinc);
                end
            end
        end

        function updateSedInfo(app)
            sr = app.getPeriodArray();
            tips3 = app.getLang('c10','test periods of');

            if numel(sr) > 3
                sedinfo = [tips3,' ',num2str(sr(1),'% 3.3f'),', ',num2str(sr(2),'% 3.3f'),', ',...
                    num2str(sr(3),'% 3.3f'),', ..., ',num2str(sr(end),'% 3.3f'),' ',app.unit];
            elseif numel(sr) == 3
                sedinfo = [tips3,' ',num2str(sr(1),'% 3.3f'),', ',num2str(sr(2),'% 3.3f'),', ..., ',...
                    num2str(sr(end),'% 3.3f'),' ',app.unit];
            else
                sedinfo = [tips3,' ',num2str(sr(1),'% 3.3f'),', ',num2str(sr(end),'% 3.3f'),' ',app.unit];
            end
            app.LabelInfo.Text = sedinfo;
        end

        function onRun(app)
            p1 = app.sedmin;
            p2 = app.sedmax;
            pn = app.numsed;
            mcn = str2double(app.EditMonte.Value);

            savedata = app.CheckSave.Value;
            flipx = app.CheckFlipX.Value;

            if app.RadioRandom.Value
                if app.RadioWhite.Value
                    clmodel = 2;
                else
                    clmodel = 3;
                    dlg_title = 'Robust AR(1)';
                    if app.lang_choice==0
                        prompt = {'Median smoothing window: default 0.2=20%'};
                    else
                        prompt = {app.getLang('c20','Median smoothing window: default 0.2=20%')};
                    end
                    answer = inputdlg(prompt, dlg_title, 1, {num2str(0.2)}, struct('Resize','on'));
                    if isempty(answer)
                        return
                    end
                    smoothwin = str2double(answer{1});
                    nw = 2;
                    rho = 0.5;
                    linlog = app.linLog;
                end
            else
                clmodel = 1;
            end

            data = app.dat;
            RR = zeros(mcn,pn);
            plotn = 0;

            if clmodel < 3
                if clmodel == 1
                    for i = 1:mcn
                        t2 = diff(data);
                        tn3 = randperm(length(t2));
                        tn4 = [0; cumsum(t2(tn3))];
                        [~,Ri,~] = circularspec(tn4,p1,p2,pn,app.linLog,plotn);
                        RR(i,:) = Ri;
                    end
                elseif clmodel == 2
                    a = rand(length(data),mcn)*(max(data)-min(data)) + min(data);
                    for i = 1:mcn
                        [~,Ri,~] = circularspec(a(:,i),p1,p2,pn,app.linLog,plotn);
                        RR(i,:) = Ri;
                    end
                end

                prt = [50,90,95,99];
                Y = prctile(RR,prt,1);
                [P,R,~] = circularspec(data,p1,p2,pn,app.linLog,0);

                cl = zeros(1,pn);
                for j = 1:length(cl)
                    percj = [RR(:,j);R(j)];
                    cl(j) = length(percj(percj<R(j)))/(1+mcn);
                end

                if clmodel == 2
                    theowhite = ones(1,pn) * mean(Y(1,:));
                    nw = 2;
                    K = 2*nw -1;
                    nw2 = 2*(K);
                    chi90 = theowhite * chi2inv(0.90,nw2)/nw2;
                    chi95 = theowhite * chi2inv(0.95,nw2)/nw2;
                    chi99 = theowhite * chi2inv(0.99,nw2)/nw2;
                    chi999 = theowhite * chi2inv(0.999,nw2)/nw2;
                    chi2norm = R./theowhite';
                    chi2normnw2 = chi2norm' * nw2;
                    pll = chi2cdf(chi2normnw2,nw2);
                    Y1 = [theowhite',chi90',chi95',chi99',chi999'];
                end
            else
                datan = length(data);
                duration = max(data(:,1)) - min(data(:,1));
                fmax = 1/(2 * duration/datan);
                [P,R,~] = circularspec(data(:,1),p1,p2,pn,linlog,0);

                s0 = mean(R);
                ft = 1./P;
                ft = ft';
                pxxsmooth = moveMedian(R,round(smoothwin*length(R)));

                cospara = cos(pi.*ft./fmax);
                funrobust = @(v,f) v(1) * (1-v(2)^2)./(1-(2.*v(2).*cospara)+v(2)^2);
                v1 = [s0,rho];
                x = lsqcurvefit(funrobust,v1,ft,pxxsmooth);
                rhoM = x(2);
                s0M = x(1);
                theored1 = s0M * (1-rhoM^2)./(1-(2.*rhoM.*cos(pi.*ft./fmax))+rhoM^2);

                K = 2*nw -1;
                nw2 = 2*(K);
                chi90 = theored1 * chi2inv(0.90,nw2)/nw2;
                chi95 = theored1 * chi2inv(0.95,nw2)/nw2;
                chi99 = theored1 * chi2inv(0.99,nw2)/nw2;
                chi999 = theored1 * chi2inv(0.999,nw2)/nw2;
            end

            if clmodel < 3
                figure; set(gcf,'Color','white');
                subplot(2,1,1); hold on;
                plot(P,Y(4,:),'g-','LineWidth',1);
                plot(P,Y(3,:),'r-','LineWidth',3);
                plot(P,Y(2,:),'b-','LineWidth',1);
                plot(P,Y(1,:),'k-','LineWidth',1);
                plot(P,R,'LineWidth',1,'color',[0.9290 0.6940 0.1250]);
                hold off;
                if clmodel == 1
                    title('CSA with Confidence Levels (Monte Carlo, fixed distance)');
                else
                    title('CSA with Confidence Levels (Monte Carlo, random distance)');
                end
                xlabel(['Period (',app.unit,')']); ylabel('Power');
                xlim([p1,p2]); legend('99%','95%','90%','50%','power');
                if flipx, set(gca,'XDir','reverse'); end

                subplot(2,1,2); hold on;
                plot(P,ones(1,pn)*95,'r-','LineWidth',3);
                plot(P,ones(1,pn)*99,'g-','LineWidth',1);
                plot(P,cl*100,'LineWidth',1,'color',[0.9290 0.6940 0.1250]);
                hold off;
                ylim([90,100]); xlim([p1,p2]);
                xlabel(['Period (',app.unit,')']); ylabel('Confidence level (%)');
                if flipx, set(gca,'XDir','reverse'); end

                if clmodel == 2
                    figure; set(gcf,'Color','white');
                    subplot(2,1,1); hold on;
                    plot(P,chi99,'g-','LineWidth',1);
                    plot(P,chi95,'r-','LineWidth',3);
                    plot(P,chi90,'b-','LineWidth',1);
                    plot(P,theowhite,'k-','LineWidth',1);
                    plot(P,R,'LineWidth',1,'color',[0.9290 0.6940 0.1250]);
                    hold off;
                    title('CSA with Confidence Levels (white, chi2, random distance)');
                    xlabel(['Period (',app.unit,')']); ylabel('Power');
                    xlim([p1,p2]); legend('99%','95%','90%','50%','power');
                    if flipx, set(gca,'XDir','reverse'); end

                    subplot(2,1,2); hold on;
                    plot(P,ones(1,pn)*95,'r-','LineWidth',3);
                    plot(P,ones(1,pn)*99,'g-','LineWidth',1);
                    plot(P,pll*100,'LineWidth',1,'color',[0.9290 0.6940 0.1250]);
                    hold off;
                    ylim([90,100]); xlim([p1,p2]);
                    xlabel(['Period (',app.unit,')']); ylabel('Confidence level (%)');
                    if flipx, set(gca,'XDir','reverse'); end
                end
            else
                figure; set(gcf,'Color','white');
                subplot(2,1,1); hold on;
                semilogy(P,chi999,'g--','LineWidth',1);
                semilogy(P,chi99,'b-.');
                semilogy(P,chi95,'r--','LineWidth',2);
                semilogy(P,chi90,'r-');
                semilogy(P,theored1,'k-','LineWidth',2);
                semilogy(P,pxxsmooth,'m-.');
                semilogy(P,R,'k');
                hold off; xlim([p1,p2]);
                xlabel(['Period (',app.unit,')']); ylabel('Power');
                title('CSA with Confidence Levels (red, chi2, random distance)');
                smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
                legend('Robust AR(1) 99.9%','Robust AR(1) 99%','Robust AR(1) 95%','Robust AR(1) 90%',...
                       'Robust AR(1) median',smthwin,'Power');
                if flipx, set(gca,'XDir','reverse'); end

                subplot(2,1,2); hold on;
                chi2norm = R./theored1';
                chi2normnw2 = chi2norm' * nw2;
                pl = chi2cdf(chi2normnw2,nw2);
                plot(P,ones(1,pn)*90,'r-.','LineWidth',1);
                plot(P,ones(1,pn)*95,'r--','LineWidth',3);
                plot(P,ones(1,pn)*99,'b-.','LineWidth',1);
                plot(P,ones(1,pn)*99.9,'g--','LineWidth',1);
                plot(P,pl*100,'LineWidth',1,'color',[0.9290 0.6940 0.1250]);
                hold off; ylim([80,100]); xlim([p1,p2]);
                xlabel(['Period (',app.unit,')']); ylabel('confidence level (%)');
                if flipx, set(gca,'XDir','reverse'); end
            end

            if savedata
                if clmodel < 3
                    xx = [P',R',Y',cl'];
                    if clmodel == 1
                        name1 = [app.filename,'-CSA-fixed','.txt'];
                    else
                        name1 = [app.filename,'-CSA-random-theoreticwhite','.txt'];
                        name2 = [app.filename,'-CSA-random-MonteCarlo','.txt'];
                    end
                    CDac_pwd;
                    dlmwrite(name1, xx, 'delimiter', ' ', 'precision', 9);
                    if clmodel == 2
                        dlmwrite(name2, Y1, 'delimiter', ' ', 'precision', 9);
                    end
                    app.refreshMainListbox();
                    cd(pre_dirML);
                    disp(['>> saved data: ',name1]);
                else
                    Y = [pxxsmooth';theored1';chi90';chi95';chi99';chi999'];
                    chi2norm = R./theored1';
                    chi2normnw2 = chi2norm' * nw2;
                    pl = chi2cdf(chi2normnw2,nw2);
                    xx = [P',R',Y',pl(:,1)];
                    name1 = [app.filename,'-CSA-random-robustAR1','.txt'];
                    CDac_pwd;
                    dlmwrite(name1, xx, 'delimiter', ' ', 'precision', 9);
                    app.refreshMainListbox();
                    cd(pre_dirML);
                    disp(['>> saved data: ',name1]);
                end

                if clmodel == 2
                    Y = [theowhite;chi90;chi95;chi99;chi999];
                    xx = [P',R',Y',pll(:,1)];
                    name1 = [app.filename,'-CSA-random-white','.txt'];
                    CDac_pwd;
                    dlmwrite(name1, xx, 'delimiter', ' ', 'precision', 9);
                    app.refreshMainListbox();
                    cd(pre_dirML);
                    disp(['>> saved data: ',name1]);
                end
            end
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
        function app = circularspecGUI(varargin)
            if nargin > 0 && isstruct(varargin{1})
                app.Context = varargin{1};
                if isfield(app.Context,'MonZoom')
                    app.MonZoom = app.Context.MonZoom;
                end
            else
                error('circularspecGUI requires a handles/context struct input.');
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
