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

        app.UIFigure = uifigure('Name','Acycle: Spectral Analysis','Color',bg, ...
            'Position',[80 80 1616 794],'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)doLayout();

        app.LMethod = uilabel(app.UIFigure,'Text','Select method','FontSize',39/3,'BackgroundColor',bg);
        app.DropMethod = uidropdown(app.UIFigure, ...
            'Items',{'Multi-taper method','Lomb-Scargle spectrum'}, ...
            'Value','Multi-taper method', ...
            'ValueChangedFcn',@(~,~)onMethodChanged());

        app.PanelMethod = uipanel(app.UIFigure,'Title','Method','BackgroundColor',bg);
        app.LabelNW = uilabel(app.PanelMethod,'Text','Time-bandwidth product','BackgroundColor',bg);
        app.DropNW = uidropdown(app.PanelMethod,'Items',{'1','2','3','4','5'},'Value','2');
        app.LblZero = uilabel(app.PanelMethod,'Text','Zeropadding','BackgroundColor',bg);

        app.RBPadPow = uiradiobutton(app.PanelMethod,'Text','');
        app.EditPadPow = uieditfield(app.PanelMethod,'text','Value','2.0','Enable','off');
        app.RBPadN = uiradiobutton(app.PanelMethod,'Text','');
        app.EditPadNLeft = uieditfield(app.PanelMethod,'text','Value','5');
        app.LblMul = uilabel(app.PanelMethod,'Text','x','BackgroundColor',bg);
        app.RBPadExact = uiradiobutton(app.PanelMethod,'Text','', 'Value',true);
        app.EditPadExact = uieditfield(app.PanelMethod,'text','Value',num2str(size(app.data,1)));

        app.BGPad = uibuttongroup(app.PanelMethod,'BorderType','none','BackgroundColor',bg);
        app.RBPadPow.Parent = app.BGPad; app.RBPadN.Parent = app.BGPad; app.RBPadExact.Parent = app.BGPad;
        app.BGPad.SelectionChangedFcn = @(~,~)onPadModeChanged();

        app.PanelPlot = uipanel(app.UIFigure,'Title','Plot: max frequency & Y','BackgroundColor',bg);
        app.LblFmin = uilabel(app.PanelPlot,'Text','Freq. min','BackgroundColor',bg);
        app.EditFmin = uieditfield(app.PanelPlot,'text','Value','0');
        app.RBFmaxNyq = uiradiobutton(app.PanelPlot,'Text','Nyquist','Value',true);
        app.LblNyq = uilabel(app.PanelPlot,'Text',num2str(app.nyquist,'%.4f'),'BackgroundColor',bg);
        app.RBFmaxInput = uiradiobutton(app.PanelPlot,'Text','Input');
        app.EditFmax = uieditfield(app.PanelPlot,'text','Value',num2str(app.nyquist,'%.4f'));

        app.BGFmax = uibuttongroup(app.PanelPlot,'BorderType','none','BackgroundColor',bg);
        app.RBFmaxNyq.Parent = app.BGFmax; app.RBFmaxInput.Parent = app.BGFmax;
        app.BGFmax.SelectionChangedFcn = @(~,~)onFmaxModeChanged();

        app.CkLinearY = uicheckbox(app.PanelPlot,'Text','Linear Y','Value',false);
        app.CkLogY = uicheckbox(app.PanelPlot,'Text','Log Y','Value',true);
        app.CkLogF = uicheckbox(app.PanelPlot,'Text','log(freq.)','Value',false);
        app.CkXPeriod = uicheckbox(app.PanelPlot,'Text','X in period','Value',false);

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

        function doLayout()
            p = app.UIFigure.Position;
            w = p(3); h = p(4);
            app.LMethod.Position = [round(0.12*w) round(0.84*h) round(0.18*w) 38];
            app.DropMethod.Position = [round(0.31*w) round(0.835*h) round(0.60*w) 40];

            app.PanelMethod.Position = [round(0.05*w) round(0.39*h) round(0.44*w) round(0.32*h)];
            app.PanelPlot.Position   = [round(0.50*w) round(0.28*h) round(0.45*w) round(0.43*h)];
            app.PanelRed.Position    = [round(0.05*w) round(0.12*h) round(0.44*w) round(0.28*h)];

            app.BtnRun.Position = [round(0.50*w) round(0.12*h) round(0.16*w) round(0.11*h)];
            app.BtnRunSave.Position = [round(0.67*w) round(0.12*h) round(0.28*w) round(0.11*h)];

            % Method panel
            pw = app.PanelMethod.Position(3); ph = app.PanelMethod.Position(4);
            app.BGPad.Position = [1 1 pw-2 ph-2];
            app.LabelNW.Position = [round(0.15*pw) round(0.79*ph) round(0.43*pw) 34];
            app.DropNW.Position  = [round(0.62*pw) round(0.79*ph) round(0.33*pw) 40];
            app.LblZero.Position = [round(0.17*pw) round(0.52*ph) round(0.27*pw) 36];

            app.RBPadPow.Position = [round(0.52*pw) round(0.57*ph) 26 26];
            app.EditPadPow.Position = [round(0.66*pw) round(0.53*ph) round(0.30*pw) 44];
            app.RBPadN.Position = [round(0.06*pw) round(0.18*ph) 26 26];
            app.EditPadNLeft.Position = [round(0.19*pw) round(0.15*ph) round(0.15*pw) 44];
            app.LblMul.Position = [round(0.38*pw) round(0.18*ph) 22 35];
            app.RBPadExact.Position = [round(0.52*pw) round(0.21*ph) 26 26];
            app.EditPadExact.Position = [round(0.66*pw) round(0.15*ph) round(0.30*pw) 44];

            % Plot panel
            pw = app.PanelPlot.Position(3); ph = app.PanelPlot.Position(4);
            app.BGFmax.Position = [1 1 pw-2 ph-2];
            app.LblFmin.Position = [round(0.18*pw) round(0.83*ph) round(0.22*pw) 34];
            app.EditFmin.Position = [round(0.54*pw) round(0.79*ph) round(0.30*pw) 48];
            app.RBFmaxNyq.Position = [round(0.10*pw) round(0.66*ph) round(0.25*pw) 36];
            app.LblNyq.Position = [round(0.56*pw) round(0.67*ph) round(0.30*pw) 28];
            app.RBFmaxInput.Position = [round(0.10*pw) round(0.47*ph) round(0.25*pw) 36];
            app.EditFmax.Position = [round(0.54*pw) round(0.43*ph) round(0.30*pw) 48];

            app.CkLinearY.Position = [round(0.10*pw) round(0.25*ph) round(0.30*pw) 30];
            app.CkLogY.Position = [round(0.50*pw) round(0.25*ph) round(0.30*pw) 30];
            app.CkLogF.Position = [round(0.10*pw) round(0.10*ph) round(0.30*pw) 30];
            app.CkXPeriod.Position = [round(0.50*pw) round(0.10*ph) round(0.30*pw) 30];

            % Red panel
            pw = app.PanelRed.Position(3); ph = app.PanelRed.Position(4);
            app.CkRobust.Position = [round(0.06*pw) round(0.70*ph) round(0.33*pw) 34];
            app.CkClassic.Position = [round(0.06*pw) round(0.45*ph) round(0.33*pw) 34];
            app.CkFtest.Position = [round(0.06*pw) round(0.20*ph) round(0.33*pw) 34];
            app.CkSWA.Position = [round(0.41*pw) round(0.70*ph) round(0.54*pw) 34];
            app.CkBPL.Position = [round(0.41*pw) round(0.45*ph) round(0.54*pw) 34];
            app.CkPL.Position = [round(0.41*pw) round(0.20*ph) round(0.54*pw) 34];
        end

        function onMethodChanged()
            app.method = string(app.DropMethod.Value);
            isMtm = contains(lower(app.method),'multi');
            app.DropNW.Enable = ternary(isMtm,'on','off');
            app.CkFtest.Enable = ternary(isMtm,'on','off');
            app.CkSWA.Enable = ternary(isMtm,'on','off');
            app.CkRobust.Value = true;
            app.CkClassic.Value = false;
            if ~isMtm
                app.CkFtest.Value = false;
                app.CkSWA.Value = false;
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

                if contains(lower(app.method),'multi')
                    [p,f] = pmtm(y,nw,nfft,1/dt);
                else
                    [p,f] = plomb(y,x,fmax);
                end
                p = real(p(:));
                f = f(:);
                keep = f >= fmin & f <= fmax;
                f = f(keep); p = p(keep);

                fig = figure('Color','white','Name','Acycle: Spectral Analysis');
                ax = axes(fig); hold(ax,'on');
                plot(ax,f,p,'k-','LineWidth',1.3);

                if contains(lower(app.method),'multi')
                    if app.CkRobust.Value
                        [rhoM,s0M,redAR1,red96] = redconfML(y,dt,nw,nfft,2,0.25,fmax,0);
                        rr = red96(:,1) >= fmin & red96(:,1) <= fmax;
                        plot(ax,red96(rr,1),red96(rr,3),'m-.','LineWidth',1.2);
                        plot(ax,red96(rr,1),red96(rr,5),'r--','LineWidth',1.6);
                        plot(ax,red96(rr,1),red96(rr,6),'b-.','LineWidth',1.2);
                        title(ax,sprintf('MTM robust AR(1): rho=%.3f, S0=%.3f',rhoM,s0M)); %#ok<NASGU>
                    end
                    if app.CkClassic.Value
                        [fc,pc,theo,c90,c95,c99,~] = redconfchi2(y,nw,dt,nfft,2);
                        cc = fc >= fmin & fc <= fmax;
                        plot(ax,fc(cc),theo(cc),'k-','LineWidth',1.8);
                        plot(ax,fc(cc),c90(cc),'r-','LineWidth',1.1);
                        plot(ax,fc(cc),c95(cc),'r--','LineWidth',1.6);
                        plot(ax,fc(cc),c99(cc),'b-.','LineWidth',1.1);
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
                set(ax,'YScale',ternary(app.CkLogY.Value,'log','linear'));
                if app.CkLogF.Value
                    set(ax,'XScale','log');
                end
                if app.CkLinearY.Value
                    set(ax,'YScale','linear');
                end

                if saveResult
                    out = [f p];
                    [~,name,~] = fileparts(getDataName(ctx));
                    outname = [name,'-spectrum.txt'];
                    writematrix(out,outname,'Delimiter','tab');
                end
            catch ME
                uialert(app.UIFigure,ME.message,'Spectrum Error');
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
