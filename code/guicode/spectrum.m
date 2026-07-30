function varargout = spectrum(varargin)
% App Designer-style migration of spectrum.fig (single-file).

ctx = struct();
if nargin > 0 && isstruct(varargin{1})
    ctx = varargin{1};
end

app = buildUI(ctx);
if nargout > 0
    varargout{1} = app.UIFigure;
end

    function app = buildUI(ctx)
        bg = [0.94 0.94 0.94];
        blue = [0 0 1];

        app = struct();
        app.ctx = ctx;
        app.data = getCurrentData(ctx);
        app.unit = getUnit(ctx);
        app.method = "Multi-taper method";
        app.nyquist = estimateNyquist(app.data);
        dtx = diff(app.data(:,1));
        app.isUneven = ~isempty(dtx) && (max(dtx)-min(dtx) > 10*eps('single'));

        app.UIFigure = uifigure('Name','Acycle: Spectral Analysis','Color',bg, ...
            'Position',[80 80 808 397],'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)doLayout();
        bindCloseShortcut();

        app.LMethod = uilabel(app.UIFigure,'Text','Select method','FontSize',39/3,'BackgroundColor',bg);
        defaultMethod = 'Multi-taper method';
        if app.isUneven
            defaultMethod = 'Lomb-Scargle spectrum';
            app.method = "Lomb-Scargle spectrum";
        end
        app.DropMethod = uidropdown(app.UIFigure, ...
            'Items',{'Multi-taper method','Periodogram','Lomb-Scargle spectrum'}, ...
            'Value',defaultMethod, ...
            'ValueChangedFcn',@(~,~)onMethodChanged());

        app.PanelMethod = uipanel(app.UIFigure,'Title','Method','BackgroundColor',bg);
        app.BGPad = uibuttongroup(app.PanelMethod,'BorderType','none','BackgroundColor',bg);
        app.RBPadPow = uiradiobutton(app.BGPad,'Text','');
        app.RBPadN = uiradiobutton(app.BGPad,'Text','');
        app.RBPadExact = uiradiobutton(app.BGPad,'Text','', 'Value',true);
        app.LabelNW = uilabel(app.PanelMethod,'Text','Time-bandwidth product','BackgroundColor',bg);
        app.DropNW = uidropdown(app.PanelMethod,'Items',{'1','2','3','4','5'},'Value','2');
        app.LblZero = uilabel(app.PanelMethod,'Text','Zeropadding','BackgroundColor',bg);
        app.EditPadPow = uieditfield(app.PanelMethod,'text','Value','2.0','Enable','off');
        app.EditPadNLeft = uieditfield(app.PanelMethod,'text','Value','5');
        app.LblMul = uilabel(app.PanelMethod,'Text','x','BackgroundColor',bg);
        app.EditPadExact = uieditfield(app.PanelMethod,'text','Value',num2str(size(app.data,1)));

        app.BGPad.SelectionChangedFcn = @(~,~)onPadModeChanged();

        app.PanelPlot = uipanel(app.UIFigure,'Title','Plot: max frequency & Y','BackgroundColor',bg);
        app.BGFmax = uibuttongroup(app.PanelPlot,'BorderType','none','BackgroundColor',bg);
        app.RBFmaxNyq = uiradiobutton(app.BGFmax,'Text','Nyquist','Value',true);
        app.RBFmaxInput = uiradiobutton(app.BGFmax,'Text','Input');
        app.LblFmin = uilabel(app.PanelPlot,'Text','Freq. min','BackgroundColor',bg);
        app.EditFmin = uieditfield(app.PanelPlot,'text','Value','0');
        app.LblNyq = uilabel(app.PanelPlot,'Text',num2str(app.nyquist,'%.4f'),'BackgroundColor',bg);
        app.EditFmax = uieditfield(app.PanelPlot,'text','Value',num2str(app.nyquist,'%.4f'));

        app.BGFmax.SelectionChangedFcn = @(~,~)onFmaxModeChanged();

        app.CkLinearY = uicheckbox(app.PanelPlot,'Text','Linear Y','Value',false, ...
            'ValueChangedFcn',@(~,~)onYScaleChanged('linear'));
        app.CkLogY = uicheckbox(app.PanelPlot,'Text','Log Y','Value',true, ...
            'ValueChangedFcn',@(~,~)onYScaleChanged('log'));
        app.CkLogF = uicheckbox(app.PanelPlot,'Text','log(freq.)','Value',false, ...
            'ValueChangedFcn',@(~,~)onLogFreqChanged());
        app.CkXPeriod = uicheckbox(app.PanelPlot,'Text','X in period','Value',false, ...
            'ValueChangedFcn',@(~,~)onXPeriodChanged());

        app.PanelRed = uipanel(app.UIFigure,'Title','Red noise','BackgroundColor',bg);
        app.CkRobust = uicheckbox(app.PanelRed,'Text','Robust AR(1)','Value',true,'FontWeight','bold');
        app.CkClassic = uicheckbox(app.PanelRed,'Text','Classic AR(1)','Value',false);
        app.CkFtest = uicheckbox(app.PanelRed,'Text','F-test & Ampl.','Value',false);
        app.CkSWA = uicheckbox(app.PanelRed,'Text','Smoothed Window Averages','Value',true,'FontWeight','bold');
        app.CkBPL = uicheckbox(app.PanelRed,'Text','Bending Power Law','Value',false);
        app.CkPL = uicheckbox(app.PanelRed,'Text','Power Law','Value',false);

        app.BtnRun = uibutton(app.UIFigure,'push','Text','Run', ...
            'BackgroundColor',blue,'FontColor','white','FontWeight','bold', ...
            'ButtonPushedFcn',@(~,~)runSpectrum(false));
        app.BtnRunSave = uibutton(app.UIFigure,'push','Text','Run & Save', ...
            'BackgroundColor',blue,'FontColor','white','FontWeight','bold', ...
            'ButtonPushedFcn',@(~,~)runSpectrum(true));

        doLayout();
        onMethodChanged();
        onPadModeChanged();
        onFmaxModeChanged();
        restackUI();

        function doLayout()
            p = app.UIFigure.Position;
            w = p(3); h = p(4);
            app.LMethod.Position = [round(0.05*w) round(0.84*h) round(0.18*w) 38];
            app.DropMethod.Position = [round(0.25*w) round(0.835*h) round(0.70*w) 40];

            app.PanelMethod.Position = [round(0.05*w) round(0.39*h) round(0.44*w) round(0.42*h)];
            app.PanelPlot.Position   = [round(0.50*w) round(0.24*h) round(0.45*w) round(0.57*h)];
            app.PanelRed.Position    = [round(0.05*w) round(0.12*h) round(0.44*w) round(0.26*h)];

            app.BtnRun.Position = [round(0.50*w) round(0.12*h) round(0.16*w) round(0.11*h)];
            app.BtnRunSave.Position = [round(0.67*w) round(0.12*h) round(0.28*w) round(0.11*h)];

            % Method panel
            pw = app.PanelMethod.Position(3); ph = app.PanelMethod.Position(4);
            app.BGPad.Position   = [round(0.05*pw) round(0.10*ph) round(0.53*pw) round(0.56*ph)];
            app.LabelNW.Position = [round(0.05*pw) round(0.6*ph) round(0.43*pw) 34];
            app.DropNW.Position  = [round(0.66*pw) round(0.6*ph) round(0.33*pw) 30];

            gpw = app.BGPad.Position(3); gph = app.BGPad.Position(4);
            app.LblZero.Position = [round(0.05*pw) round(0.3*ph) round(0.27*pw) 36];
            app.RBPadPow.Position = [round(0.86*gpw) round(0.53*gph) 26 26];
            app.EditPadPow.Position = [round(0.66*pw) round(0.4*ph) round(0.30*pw) 30];
            
            app.RBPadN.Position = [round(0.05*gpw) round(0.05*gph) 26 26];
            app.EditPadNLeft.Position = [round(0.19*pw) round(0.1*ph) round(0.15*pw) 30];
            app.LblMul.Position = [round(0.38*pw) round(0.08*ph) 22 35];
            app.RBPadExact.Position = [round(0.86*gpw) round(0.05*gph) 26 26];
            app.EditPadExact.Position = [round(0.66*pw) round(0.08*ph) round(0.30*pw) 30];
            
            % Plot panel
            pw = app.PanelPlot.Position(3); ph = app.PanelPlot.Position(4);
            app.BGFmax.Position = [round(0.10*pw) round(0.43*ph) round(0.40*pw) round(0.29*ph)];
            app.LblFmin.Position = [round(0.1*pw) round(0.74*ph) round(0.22*pw) 34];
            app.EditFmin.Position = [round(0.54*pw) round(0.74*ph) round(0.30*pw) 29];

            fpw = app.BGFmax.Position(3); fph = app.BGFmax.Position(4);
            app.RBFmaxNyq.Position = [round(0.02*fpw) round(0.5*fph) round(0.95*fpw) 36];
            app.LblNyq.Position = [round(0.56*pw) round(0.6*ph) round(0.30*pw) 28];
            app.RBFmaxInput.Position = [round(0.02*fpw) round(0.05*fph) round(0.95*fpw) 36];
            app.EditFmax.Position = [round(0.54*pw) round(0.46*ph) round(0.30*pw) 29];
            
            app.CkLinearY.Position = [round(0.10*pw) round(0.25*ph) round(0.30*pw) 30];
            app.CkLogY.Position = [round(0.50*pw) round(0.25*ph) round(0.30*pw) 30];
            app.CkLogF.Position = [round(0.10*pw) round(0.10*ph) round(0.30*pw) 30];
            app.CkXPeriod.Position = [round(0.50*pw) round(0.10*ph) round(0.30*pw) 30];

            % Red panel
            pw = app.PanelRed.Position(3); ph = app.PanelRed.Position(4);
            app.CkRobust.Position = [round(0.06*pw) round(0.52*ph) round(0.33*pw) 34];
            app.CkClassic.Position = [round(0.06*pw) round(0.27*ph) round(0.33*pw) 34];
            app.CkFtest.Position = [round(0.06*pw) round(0.02*ph) round(0.33*pw) 34];
            app.CkSWA.Position = [round(0.41*pw) round(0.52*ph) round(0.54*pw) 34];
            app.CkBPL.Position = [round(0.41*pw) round(0.27*ph) round(0.54*pw) 34];
            app.CkPL.Position = [round(0.41*pw) round(0.02*ph) round(0.54*pw) 34];

            restackUI();
        end

        function restackUI()
            % Keep labels above transparent radio groups for old uifigure rendering.
            try
                uistack(app.LabelNW,'top');
                uistack(app.LblZero,'top');
                uistack(app.LblFmin,'top');
                uistack(app.LblNyq,'top');
                uistack(app.EditPadPow,'top');
                uistack(app.EditPadNLeft,'top');
                uistack(app.EditPadExact,'top');
                uistack(app.EditFmin,'top');
                uistack(app.EditFmax,'top');
            catch
            end
        end

        function onMethodChanged()
            app.method = string(app.DropMethod.Value);
            isMtm = contains(lower(app.method),'multi');
            isPeriodogram = contains(lower(app.method),'periodogram');
            isLomb = contains(lower(app.method),'lomb');

            if isMtm
                app.DropNW.Enable = 'on';
                app.CkRobust.Enable = 'on';
                app.CkClassic.Enable = 'on';
                app.CkClassic.Text = 'Classic AR(1)';
                app.CkFtest.Visible = 'on';
                app.CkSWA.Visible = 'on';
            elseif isPeriodogram
                if app.isUneven
                    warning('spectrum:unevenData','Sampling may be uneven: Periodogram may be unreliable.');
                end
                app.DropNW.Enable = 'off';
                app.CkRobust.Enable = 'off';
                app.CkClassic.Enable = 'on';
                app.CkClassic.Text = 'Classic AR(1)';
                app.CkFtest.Visible = 'off';
                app.CkSWA.Visible = 'off';
            elseif isLomb
                app.DropNW.Enable = 'off';
                app.CkRobust.Enable = 'on';
                app.CkRobust.Value = true;
                app.CkClassic.Enable = 'on';
                app.CkClassic.Value = false;
                app.CkClassic.Text = 'White noise';
                app.CkFtest.Visible = 'off';
                app.CkSWA.Visible = 'off';
            end
        end

        function onYScaleChanged(mode)
            if strcmp(mode,'linear')
                app.CkLogY.Value = ~app.CkLinearY.Value;
            else
                app.CkLinearY.Value = ~app.CkLogY.Value;
            end
        end

        function onXPeriodChanged()
            if app.CkXPeriod.Value
                app.CkLogF.Value = true;
            end
        end

        function onLogFreqChanged()
            if ~app.CkLogF.Value && app.CkXPeriod.Value
                app.CkLogF.Value = true;
            end
        end

        function onPadModeChanged()
            app.EditPadPow.Enable = ternary(app.BGPad.SelectedObject == app.RBPadPow,'on','off');
            app.EditPadNLeft.Enable = ternary(app.BGPad.SelectedObject == app.RBPadN,'on','off');
            app.EditPadExact.Enable = ternary(app.BGPad.SelectedObject == app.RBPadExact,'on','off');
        end

        function onFmaxModeChanged()
            app.EditFmax.Enable = ternary(app.BGFmax.SelectedObject == app.RBFmaxInput,'on','off');
        end

        function runSpectrum(saveResult)
            try
                data = app.data;
                if size(data,2) < 2 || size(data,1) < 8
                    uialert(app.UIFigure,'Data format invalid.','Spectrum');
                    return;
                end
                x = data(:,1);
                y = data(:,2) - mean(data(:,2),'omitnan');
                dt = median(diff(x));
                if ~(isfinite(dt) && dt > 0)
                    uialert(app.UIFigure,'Sampling rate invalid.','Spectrum');
                    return;
                end

                fmin = max(0, str2double(app.EditFmin.Value));
                fmax = app.nyquist;
                if app.BGFmax.SelectedObject == app.RBFmaxInput
                    fmax = str2double(app.EditFmax.Value);
                end
                if ~(isfinite(fmax) && fmax > fmin)
                    uialert(app.UIFigure,'fmax must be > fmin.','Spectrum');
                    return;
                end

                nw = str2double(app.DropNW.Value);
                if ~isfinite(nw), nw = 2; end
                nfft = chooseNfft(numel(y));
                method = char(app.method);
                outdir = '';
                if saveResult
                    outdir = getAcWorkDir();
                    if ~isfolder(outdir)
                        outdir = pwd;
                    end
                end
                [f,p] = computeSpectrum(method,y,x,dt,nw,nfft,fmax);
                keep = isfinite(f) & isfinite(p) & (f >= fmin) & (f <= fmax);
                f = f(keep); p = p(keep);

                fig = figure('Color','white','Name','Acycle: Spectral Analysis');
                ax = axes(fig); hold(ax,'on');
                plot(ax,f,p,'k-','LineWidth',1.2,'DisplayName','Power');
                plotCount = 1;
                figFtest = [];
                figSwa = [];

                if contains(lower(method),'multi') && app.CkRobust.Value
                    try
                        [rhoM,s0M,redconfAR1,redconfML96] = redconfML(y,dt,nw,nfft,2,0.2,fmax,0); %#ok<ASGLU>
                        rr0 = redconfAR1(:,1) >= fmin & redconfAR1(:,1) <= fmax;
                        rr = redconfML96(:,1) >= fmin & redconfML96(:,1) <= fmax;
                        plot(ax,redconfAR1(rr0,1),redconfAR1(rr0,3),'m-.','LineWidth',1.0,'DisplayName','Median smooth');
                        plot(ax,redconfML96(rr,1),redconfML96(rr,3),'k-','LineWidth',1.8,'DisplayName','Robust AR(1)');
                        plot(ax,redconfML96(rr,1),redconfML96(rr,4),'r-','LineWidth',0.9,'DisplayName','Robust 90%');
                        plot(ax,redconfML96(rr,1),redconfML96(rr,5),'r--','LineWidth',1.4,'DisplayName','Robust 95%');
                        plot(ax,redconfML96(rr,1),redconfML96(rr,6),'b-.','LineWidth',1.0,'DisplayName','Robust 99%');
                        plotCount = plotCount + 5;
                    catch MEi
                        warning('spectrum:robustMTM','Robust AR(1) (MTM) failed: %s',MEi.message);
                    end
                elseif contains(lower(method),'lomb') && app.CkRobust.Value
                    try
                        [~,fR,pth] = plomb_robustar1(y,x+abs(min(x)),fmax,0.2,0);
                        rr = fR >= fmin & fR <= fmax;
                        plot(ax,fR(rr),pth(2,rr),'k-','LineWidth',1.8,'DisplayName','Robust AR(1)');
                        plot(ax,fR(rr),pth(3,rr),'r-','LineWidth',0.9,'DisplayName','Robust 90%');
                        plot(ax,fR(rr),pth(4,rr),'r--','LineWidth',1.4,'DisplayName','Robust 95%');
                        plot(ax,fR(rr),pth(5,rr),'b-.','LineWidth',1.0,'DisplayName','Robust 99%');
                        plot(ax,fR(rr),pth(1,rr),'m-.','LineWidth',1.0,'DisplayName','Median smooth');
                        plotCount = plotCount + 5;
                    catch MEi
                        warning('spectrum:robustLS','Robust AR(1) (Lomb-Scargle) failed: %s',MEi.message);
                    end
                end

                if app.CkClassic.Value
                    if contains(lower(method),'multi')
                        try
                            [fc,~,theo,c90,c95,c99,c999] = redconfchi2(y,nw,dt,nfft,2);
                            cc = fc >= fmin & fc <= fmax;
                            plot(ax,fc(cc),theo(cc),'k-','LineWidth',1.8,'DisplayName','Classic AR(1)');
                            plot(ax,fc(cc),c90(cc),'r-','LineWidth',0.9,'DisplayName','Classic 90%');
                            plot(ax,fc(cc),c95(cc),'r--','LineWidth',1.4,'DisplayName','Classic 95%');
                            plot(ax,fc(cc),c99(cc),'b-.','LineWidth',1.0,'DisplayName','Classic 99%');
                            plot(ax,fc(cc),c999(cc),'g--','LineWidth',1.0,'DisplayName','Classic 99.9%');
                            plotCount = plotCount + 5;
                        catch MEi
                            warning('spectrum:classicMTM','Classic AR(1) (MTM) failed: %s',MEi.message);
                        end
                    elseif contains(lower(method),'periodogram')
                        try
                            [fc,~,theo,c90,c95,c99,c999] = redconfchi2(y,1,dt,nfft,1);
                            cc = fc >= fmin & fc <= fmax;
                            plot(ax,fc(cc),theo(cc),'k-','LineWidth',1.8,'DisplayName','Classic AR(1)');
                            plot(ax,fc(cc),c90(cc),'r-','LineWidth',0.9,'DisplayName','Classic 90%');
                            plot(ax,fc(cc),c95(cc),'r--','LineWidth',1.4,'DisplayName','Classic 95%');
                            plot(ax,fc(cc),c99(cc),'b-.','LineWidth',1.0,'DisplayName','Classic 99%');
                            plot(ax,fc(cc),c999(cc),'g--','LineWidth',1.0,'DisplayName','Classic 99.9%');
                            plotCount = plotCount + 5;
                        catch MEi
                            warning('spectrum:classicPer','Classic AR(1) (Periodogram) failed: %s',MEi.message);
                        end
                    elseif contains(lower(method),'lomb')
                        try
                            pfa = [0.50 0.10 0.01 0.0001];
                            pd = 1 - pfa;
                            [~,fLS,pth] = plomb(y,x+abs(min(x)),fmax,'Pd',pd);
                            rr = fLS >= fmin & fLS <= fmax;
                            if any(rr)
                                fr = fLS(rr);
                                plot(ax,fr,pth(1)+0*fr,'r-','LineWidth',0.9,'DisplayName','White noise 50%');
                                plot(ax,fr,pth(2)+0*fr,'r--','LineWidth',1.2,'DisplayName','White noise 90%');
                                plot(ax,fr,pth(3)+0*fr,'b-.','LineWidth',1.0,'DisplayName','White noise 99%');
                                plot(ax,fr,pth(4)+0*fr,'g--','LineWidth',1.0,'DisplayName','White noise 99.99%');
                                plotCount = plotCount + 4;
                            end
                        catch MEi
                            warning('spectrum:classicLS','White-noise significance (Lomb) failed: %s',MEi.message);
                        end
                    end
                end

                if app.CkPL.Value
                    try
                        dof = ternary(contains(lower(method),'multi'),2*(2*nw-1),2);
                        [pl,~,loc95,~,~,g95,~] = powerLawLevels(f,p,dof);
                        plot(ax,f,pl,'k-','LineWidth',1.6,'DisplayName','Power law');
                        plot(ax,f,loc95,'b--','LineWidth',1.0,'DisplayName','Local 95%');
                        plot(ax,f,g95,'r--','LineWidth',1.4,'DisplayName','Global 95%');
                        plotCount = plotCount + 3;
                    catch MEi
                        warning('spectrum:pl','Power-law test failed: %s',MEi.message);
                    end
                end

                if app.CkBPL.Value
                    try
                        dof = ternary(contains(lower(method),'multi'),2*(2*nw-1),2);
                        [bpl,~,loc95,~,~,g95,~] = bendingPowerLawLevels(f,p,dof);
                        plot(ax,f,bpl,'k-','LineWidth',1.6,'DisplayName','Bending power law');
                        plot(ax,f,loc95,'b--','LineWidth',1.0,'DisplayName','Local 95%');
                        plot(ax,f,g95,'r--','LineWidth',1.4,'DisplayName','Global 95%');
                        plotCount = plotCount + 3;
                    catch MEi
                        warning('spectrum:bpl','Bending-power-law test failed: %s',MEi.message);
                    end
                end

                if contains(lower(method),'multi') && app.CkFtest.Value
                    try
                        padtimes = max(1,round(nfft/numel(y)));
                        [freq,ftest,fsig,~,~,~,~,dof,~] = ftestmtmML([x y],nw,padtimes,1); %#ok<ASGLU>
                        figFtest = figure('Color','white','Name','Acycle: F-test');
                        subplot(2,1,1,'Parent',figFtest); plot(freq,dof,'k-','LineWidth',1); xlim([fmin fmax]); title('Adaptive weighted degrees of freedom');
                        subplot(2,1,2,'Parent',figFtest); plot(freq,ftest,'k-'); hold on; plot(freq,fsig,'r--'); xlim([fmin fmax]); title('F-test and significance');
                    catch MEi
                        warning('spectrum:ftest','F-test failed: %s',MEi.message);
                    end
                end

                if contains(lower(method),'multi') && app.CkSWA.Value
                    try
                        padtimes = max(1,round(nfft/numel(y)));
                        outSWA = runSpectralSwa([x y],nw,padtimes,saveResult,outdir);
                        fx = outSWA(:,1);
                        rr = fx >= fmin & fx <= fmax;
                        if any(rr)
                            swaOpts = getSwaOptions();
                            if ~isempty(swaOpts)
                                if swaOpts.mode == "overlay" || swaOpts.mode == "both"
                                    plotSwaLines(ax, fx(rr), outSWA(rr,:), swaOpts);
                                end
                                if swaOpts.mode == "separate" || swaOpts.mode == "both"
                                    figSwa = figure('Color','white','Name','Acycle: SWA confidence');
                                    axSwa = axes(figSwa); hold(axSwa,'on');
                                    plotSwaLines(axSwa, fx(rr), outSWA(rr,:), swaOpts);
                                    xlabel(axSwa,['Frequency (cycles/',app.unit,')']);
                                    ylabel(axSwa,'Power');
                                    set(axSwa,'YScale','log');
                                    set(axSwa,'XMinorTick','on','YMinorTick','on');
                                    xlim(axSwa,[fmin fmax]);
                                    if app.CkXPeriod.Value
                                        set(axSwa,'XDir','reverse');
                                        xlabel(axSwa,['Period (',app.unit,')']);
                                        xt = get(axSwa,'XTick');
                                        xt = xt(xt>0);
                                        if ~isempty(xt)
                                            set(axSwa,'XTick',xt,'XTickLabel',compose('%.3g',1./xt));
                                        end
                                    end
                                    set(axSwa,'XScale',ternary(app.CkLogF.Value,'log','linear'));
                                    legend(axSwa,'show','Location','best');
                                end
                                if swaOpts.mode ~= "separate"
                                    plotCount = plotCount + 1;
                                end
                            end
                        end
                    catch MEi
                        warning('spectrum:swa','SWA failed: %s',MEi.message);
                    end
                end

                if app.CkXPeriod.Value
                    set(ax,'XDir','reverse');
                    xlabel(ax,['Period (',app.unit,')']);
                    xt = get(ax,'XTick');
                    xt = xt(xt>0);
                    if ~isempty(xt)
                        set(ax,'XTick',xt,'XTickLabel',compose('%.3g',1./xt));
                    end
                else
                    xlabel(ax,['Frequency (cycles/',app.unit,')']);
                end
                ylabel(ax,'Power');
                xlim(ax,[fmin fmax]);
                set(ax,'XMinorTick','on','YMinorTick','on');
                if app.CkLinearY.Value
                    set(ax,'YScale','linear');
                else
                    set(ax,'YScale','log');
                end
                set(ax,'XScale',ternary(app.CkLogF.Value,'log','linear'));
                if plotCount > 1
                    legend(ax,'show','Location','best');
                end

                if saveResult
                    out = [f p];
                    [~,name,~] = fileparts(getDataName(ctx));
                    if isempty(outdir) || ~isfolder(outdir)
                        outdir = pwd;
                    end
                    hasFtestPdf = ~isempty(figFtest) && isgraphics(figFtest);
                    hasSwaPdf = ~isempty(figSwa) && isgraphics(figSwa);
                    [dataFile,pdfFile,ftestPdfFile,swaPdfFile,paramFile,runIndex] = spectrumOutputNames(outdir,name,hasFtestPdf,hasSwaPdf);
                    writematrix(out,dataFile,'Delimiter','tab');
                    saveFigurePdf(fig,pdfFile);
                    if hasFtestPdf
                        saveFigurePdf(figFtest,ftestPdfFile);
                    end
                    if hasSwaPdf
                        saveFigurePdf(figSwa,swaPdfFile);
                    end
                    saveSpectrumParameterTable(paramFile,method,nw,nfft,fmin,fmax);

                    swaFdr = 'SWA-Spectrum-background-FDR.dat';
                    swaChi = 'SWA-Spectrum-Chi2CL.dat';
                    if isfile(swaFdr)
                        try
                            movefile(swaFdr, fullfile(outdir,swaFdr));
                        catch
                        end
                    end
                    if isfile(swaChi)
                        try
                            movefile(swaChi, fullfile(outdir,swaChi));
                        catch
                        end
                    end

                    refreshAcMainList(outdir);
                end
            catch ME
                uialert(app.UIFigure,ME.message,'Spectrum Error');
            end
        end

        function swaOpts = getSwaOptions()
            swaOpts = [];
            labels = swaLabels();
            [idx, ok] = listdlg('PromptString','SWA confidence lines:', ...
                'SelectionMode','multiple', ...
                'ListString',labels, ...
                'InitialValue',[1 3 8], ...
                'Name','SWA options');
            if ~ok || isempty(idx)
                return;
            end

            mode = questdlg('SWA plot mode:', 'SWA options', ...
                'Overlay on main plot', 'Separate SWA figure', 'Both', 'Overlay on main plot');
            if isempty(mode)
                return;
            end

            swaOpts.selected = idx;
            if strcmp(mode,'Overlay on main plot')
                swaOpts.mode = "overlay";
            elseif strcmp(mode,'Separate SWA figure')
                swaOpts.mode = "separate";
            else
                swaOpts.mode = "both";
            end
        end

        function plotSwaLines(axh, xPlot, outRows, swaOpts)
            hold(axh,'on');
            pxx = outRows(:,2);
            swa = outRows(:,3);
            chi90 = outRows(:,4);
            chi95 = outRows(:,5);
            chi99 = outRows(:,6);
            chi999 = outRows(:,7);
            chi9999 = outRows(:,8);
            clfdr = outRows(:,9:13);

            for k = swaOpts.selected(:)'
                switch k
                    case 1
                        plot(axh,xPlot,swa,'k-','LineWidth',1.6,'DisplayName','SWA background');
                    case 2
                        if ~isnan(clfdr(1,1))
                            plot(axh,xPlot,clfdr(:,1),'m--','LineWidth',0.6,'DisplayName','10% FDR');
                        end
                    case 3
                        if ~isnan(clfdr(1,2))
                            plot(axh,xPlot,clfdr(:,2),'r--','LineWidth',1.3,'DisplayName','5% FDR');
                        end
                    case 4
                        if ~isnan(clfdr(1,3))
                            plot(axh,xPlot,clfdr(:,3),'b--','LineWidth',0.8,'DisplayName','1% FDR');
                        end
                    case 5
                        if ~isnan(clfdr(1,4))
                            plot(axh,xPlot,clfdr(:,4),'g-.','LineWidth',0.8,'DisplayName','0.1% FDR');
                        end
                    case 6
                        if ~isnan(clfdr(1,5))
                            plot(axh,xPlot,clfdr(:,5),'k-.','LineWidth',0.8,'DisplayName','0.01% FDR');
                        end
                    case 7
                        plot(axh,xPlot,chi90,'k--','LineWidth',0.8,'DisplayName','Chi2 90%');
                    case 8
                        plot(axh,xPlot,chi95,'r-','LineWidth',1.2,'DisplayName','Chi2 95%');
                    case 9
                        plot(axh,xPlot,chi99,'b-','LineWidth',0.8,'DisplayName','Chi2 99%');
                    case 10
                        plot(axh,xPlot,chi999,'m-','LineWidth',0.8,'DisplayName','Chi2 99.9%');
                    case 11
                        plot(axh,xPlot,chi9999,'g:','LineWidth',0.8,'DisplayName','Chi2 99.99%');
                end
            end

            plot(axh,xPlot,pxx,'k-','LineWidth',0.7,'DisplayName','Power');
        end

        function outputdata = runSpectralSwa(dataForSwa,nw,padtimes,saveResult,outdir)
            oldDir = pwd;
            cleanupDir = '';
            try
                if saveResult && ~isempty(outdir) && isfolder(outdir)
                    cd(outdir);
                elseif ~saveResult
                    cleanupDir = tempname;
                    mkdir(cleanupDir);
                    cd(cleanupDir);
                end
                outputdata = spectralswafdr(dataForSwa,'mtm',nw,padtimes,0);
            catch ME
                cd(oldDir);
                if ~isempty(cleanupDir) && isfolder(cleanupDir)
                    try
                        rmdir(cleanupDir,'s');
                    catch
                    end
                end
                rethrow(ME);
            end
            cd(oldDir);
            if ~isempty(cleanupDir) && isfolder(cleanupDir)
                try
                    rmdir(cleanupDir,'s');
                catch
                end
            end
        end

        function labels = swaLabels()
            labels = {'SWA background','10% FDR','5% FDR','1% FDR','0.1% FDR','0.01% FDR','Chi2 90%','Chi2 95%','Chi2 99%','Chi2 99.9%','Chi2 99.99%'};
        end

        function [dataFile,pdfFile,ftestPdfFile,swaPdfFile,paramFile,runIndex] = spectrumOutputNames(outdir,name,hasFtestPdf,hasSwaPdf)
            for runIndex = 1:9999
                dataFile = fullfile(outdir,sprintf('%s-spectrum-%d.txt',name,runIndex));
                pdfFile = fullfile(outdir,sprintf('%s-spectrum-%d.pdf',name,runIndex));
                ftestPdfFile = fullfile(outdir,sprintf('%s-spectrum-Ftest-%d.pdf',name,runIndex));
                swaPdfFile = fullfile(outdir,sprintf('%s-spectrum-SWA-%d.pdf',name,runIndex));
                paramFile = fullfile(outdir,sprintf('%s-spectrum-parameters-%d.xls',name,runIndex));

                files = {dataFile,pdfFile,paramFile};
                if hasFtestPdf
                    files{end+1} = ftestPdfFile; %#ok<AGROW>
                end
                if hasSwaPdf
                    files{end+1} = swaPdfFile; %#ok<AGROW>
                end
                if all(cellfun(@(f)~isfile(f),files))
                    return
                end
            end

            stamp = datestr(now,'yyyymmddTHHMMSS');
            runIndex = NaN;
            dataFile = fullfile(outdir,sprintf('%s-spectrum-%s.txt',name,stamp));
            pdfFile = fullfile(outdir,sprintf('%s-spectrum-%s.pdf',name,stamp));
            ftestPdfFile = fullfile(outdir,sprintf('%s-spectrum-Ftest-%s.pdf',name,stamp));
            swaPdfFile = fullfile(outdir,sprintf('%s-spectrum-SWA-%s.pdf',name,stamp));
            paramFile = fullfile(outdir,sprintf('%s-spectrum-parameters-%s.xls',name,stamp));
        end

        function saveFigurePdf(figHandle,outFile)
            if isempty(figHandle) || ~isgraphics(figHandle)
                return
            end
            try
                exportgraphics(figHandle,outFile,'ContentType','vector');
            catch
                try
                    print(figHandle,outFile,'-dpdf','-bestfit');
                catch
                    saveas(figHandle,outFile);
                end
            end
        end

        function saveSpectrumParameterTable(paramFile,method,nw,nfft,fmin,fmax)
            inputName = getDataName(ctx);
            params = repmat({''},19,6);
            params(1,2) = {'Detailed Parameters Used in Data Processing by Acycle'};
            params(2,2:6) = {'Version','Designed by','Institute','E-mail','Date'};
            params(3,2:6) = {'v1.1','Mingsong Li','Peking University','msli@pku.edu.cn',datestr(now,'yyyy-mm-dd HH:MM:SS')};
            params(5,2:5) = {'Tools','Items','Parameters','Explanations'};

            params(7,:) = {'','Spectral analysis','Input file name',inputName,'',''};
            params(8,:) = {'','','Method',method,'',''};
            params(9,:) = {'','','Time-bandwidth product',timeBandwidthText(method,nw),'',''};
            params(10,:) = {'','','Zero padding',nfft,'',''};
            params(11,:) = {'','','Frequency minimum',fmin,'',''};
            params(12,:) = {'','','Frequency maximum',fmax,'',''};

            params(14,:) = {'','Noise model','Input file name',inputName,'',''};
            params(15,:) = {'','','Method',spectrumNoiseModelName(method),'',''};
            params(16,:) = {'','','Median smoothing window','NA','',''};
            params(17,:) = {'','','AR(1) best fit model',spectrumAr1ModelName(),'',''};
            params(18,:) = {'','','Bias correction for ultra-high resolution data','NA','',''};
            params(19,:) = {'','','Output file name',spectrumNoiseOutputName(method),'',''};

            writecell(params,paramFile,'Sheet','COCO');
        end

        function s = timeBandwidthText(method,nw)
            if contains(lower(method),'multi')
                s = [num2str(nw),char(960)];
            else
                s = 'NA';
            end
        end

        function s = spectrumNoiseModelName(method)
            models = {};
            if contains(lower(method),'multi') && app.CkSWA.Value
                models{end+1} = 'Smoothed Window Averages'; %#ok<AGROW>
            end
            if app.CkRobust.Value
                models{end+1} = 'Robust AR(1)'; %#ok<AGROW>
            end
            if app.CkClassic.Value
                models{end+1} = char(app.CkClassic.Text); %#ok<AGROW>
            end
            if app.CkBPL.Value
                models{end+1} = 'Bending Power Law'; %#ok<AGROW>
            end
            if app.CkPL.Value
                models{end+1} = 'Power Law'; %#ok<AGROW>
            end
            if isempty(models)
                s = 'NA';
            else
                s = strjoin(models,', ');
            end
        end

        function s = spectrumAr1ModelName()
            models = {};
            if app.CkRobust.Value
                models{end+1} = 'Robust AR(1)'; %#ok<AGROW>
            end
            if app.CkClassic.Value
                models{end+1} = char(app.CkClassic.Text); %#ok<AGROW>
            end
            if isempty(models)
                s = 'NA';
            else
                s = strjoin(models,', ');
            end
        end

        function s = spectrumNoiseOutputName(method)
            if contains(lower(method),'multi') && app.CkSWA.Value
                s = 'SWA-Spectrum-background-FDR.dat';
            else
                s = 'NA';
            end
        end

        function outdir = getAcWorkDir()
            outdir = '';
            try
                acPwdPath = which('ac_pwd.txt');
                if ~isempty(acPwdPath) && isfile(acPwdPath)
                    outdir = strtrim(fileread(acPwdPath));
                end
            catch
            end
            if isempty(outdir)
                try
                    outdir = strtrim(get(app.ctx.edit_acfigmain_dir,'String'));
                catch
                    outdir = pwd;
                end
            end
        end

        function refreshAcMainList(workDir)
            try
                if ac_refresh_main_list(app.ctx.listbox_acmain,workDir)
                    return
                end
            catch
            end
            try
                if ~isfolder(workDir)
                    return;
                end
                d = dir(workDir);
                d = d(~ismember({d.name},{'.','..'}));
                if isempty(d)
                    return;
                end

                val1 = 1;
                try
                    val1 = app.ctx.val1;
                catch
                end
                sortMode = val1;
                switch sortMode
                    case {1,2,3,4,5,6}
                    otherwise
                        sortMode = 1;
                end
                d = ac_sort_dir_entries(d,sortMode);

                pre = '<HTML><FONT color="blue">';
                post = '</FONT></HTML>';
                listboxStr = cell(numel(d),1);
                for i = 1:numel(d)
                    if d(i).isdir
                        listboxStr{i} = [pre d(i).name post];
                    else
                        listboxStr{i} = d(i).name;
                    end
                end

                try
                    set(app.ctx.edit_acfigmain_dir,'String',workDir);
                catch
                end
                try
                    set(app.ctx.listbox_acmain,'String',listboxStr,'Value',[]);
                catch
                end

                try
                    acPwdPath = which('ac_pwd.txt');
                    if ~isempty(acPwdPath)
                        fid = fopen(acPwdPath,'w');
                        fprintf(fid,'%s',workDir);
                        fclose(fid);
                    end
                catch
                end
            catch
            end
        end

        function [f,p] = computeSpectrum(method,y,x,dt,nw,nfft,fmax)
            if contains(lower(method),'multi')
                if nw == 1
                    [p,w] = pmtm(y,nw,nfft,'DropLastTaper',false);
                else
                    [p,w] = pmtm(y,nw,nfft);
                end
                f = w/(2*pi*dt);
            elseif contains(lower(method),'periodogram')
                [p,f] = periodogram(y,[],nfft,1/dt);
            else
                [p,f] = plomb(y,x+abs(min(x)),fmax);
            end
            f = real(f(:));
            p = real(p(:));
        end

        function [pl,loc90,loc95,loc99,g90,g95,g99] = powerLawLevels(f,p,dof)
            ff = f(:); pp = p(:);
            good = ff > 0 & isfinite(ff) & isfinite(pp) & pp > 0;
            ff = ff(good); pp = pp(good);
            Nf = max(2,numel(ff));
            pf = polyfit(log(ff),log(pp),1);
            a = pf(1); k = exp(pf(2));
            fEval = max(f,min(ff));
            pl = k * fEval.^a;
            loc90 = pl * chi2inv(0.90,dof)/dof;
            loc95 = pl * chi2inv(0.95,dof)/dof;
            loc99 = pl * chi2inv(0.99,dof)/dof;
            g90 = pl * chi2inv(1-0.10/Nf,dof)/dof;
            g95 = pl * chi2inv(1-0.05/Nf,dof)/dof;
            g99 = pl * chi2inv(1-0.01/Nf,dof)/dof;
        end

        function [bpl,loc90,loc95,loc99,g90,g95,g99] = bendingPowerLawLevels(f,p,dof)
            ff = f(:); pp = p(:);
            good = ff > 0 & isfinite(ff) & isfinite(pp) & pp > 0;
            ff = ff(good); pp = pp(good);
            Nf = max(2,numel(ff));
            pol = log(pp);
            fun = @(v,fx)(v(1) * fx.^(-1*v(2)))./(1 + (fx/v(4)).^(v(3)-v(2)));
            v0 = [100,0.5,3,0.5*ff(end)];
            v = lsqcurvefit(fun,v0,ff,pol);
            fEval = max(f,min(ff));
            bpl = real(exp(fun(v,fEval)));
            bpl = bpl(:);
            loc90 = bpl * chi2inv(0.90,dof)/dof;
            loc95 = bpl * chi2inv(0.95,dof)/dof;
            loc99 = bpl * chi2inv(0.99,dof)/dof;
            g90 = bpl * chi2inv(1-0.10/Nf,dof)/dof;
            g95 = bpl * chi2inv(1-0.05/Nf,dof)/dof;
            g99 = bpl * chi2inv(1-0.01/Nf,dof)/dof;
        end

        function bindCloseShortcut()
            % Follow Insolation.m behavior.
            try
                app.UIFigure.KeyPressFcn = @onKeyPress;
            catch
            end
            try
                app.UIFigure.WindowKeyPressFcn = @onKeyPress;
            catch
            end
        end

        function onKeyPress(src,evt)
            try
                key = lower(string(evt.Key));
                mods = lower(string(evt.Modifier));
                isMacClose = key == "w" && any(mods == "command");
                isOtherClose = key == "w" && any(mods == "control");
                if isMacClose || isOtherClose
                    delete(src);
                end
            catch
            end
        end

        function nfft = chooseNfft(n)
            if app.BGPad.SelectedObject == app.RBPadPow
                v = str2double(app.EditPadPow.Value); if ~isfinite(v), v = 2; end
                nfft = max(16,2^round(v));
            elseif app.BGPad.SelectedObject == app.RBPadN
                v = str2double(app.EditPadNLeft.Value); if ~isfinite(v), v = 5; end
                nfft = max(16,2^round(v)*n);
            else
                v = str2double(app.EditPadExact.Value); if ~isfinite(v), v = n; end
                nfft = max(16,round(v));
            end
        end
    end
end

function data = getCurrentData(ctx)
if isfield(ctx,'current_data') && ~isempty(ctx.current_data)
    data = sortrows(ctx.current_data);
else
    data = [(1:100)' sin((1:100)'/7)];
end
end

function u = getUnit(ctx)
if isfield(ctx,'unit') && ~isempty(ctx.unit)
    u = char(ctx.unit);
else
    u = 'unit';
end
end

function n = estimateNyquist(data)
if size(data,1) < 3
    n = 0.5;
    return;
end
dt = median(diff(data(:,1)));
if ~(isfinite(dt) && dt > 0)
    n = 0.5;
else
    n = 1/(2*dt);
end
end

function v = ternary(tf,a,b)
if tf
    v = a;
else
    v = b;
end
end

function n = getDataName(ctx)
if isfield(ctx,'data_name') && ~isempty(ctx.data_name)
    n = char(ctx.data_name);
else
    n = 'data';
end
end
