function varargout = linegenerator(varargin)
% App Designer-style migration of linegenerator (single-file).

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
        app.lang_choice = getFieldDefault(ctx,'lang_choice',0);
        app.lang_id = getFieldDefault(ctx,'lang_id',{});
        app.lang_var = getFieldDefault(ctx,'lang_var',{});
        app.listbox_acmain = getFieldDefault(ctx,'listbox_acmain',[]);
        app.edit_acfigmain_dir = getFieldDefault(ctx,'edit_acfigmain_dir',[]);
        app.val1 = getFieldDefault(ctx,'val1',1);
        app.acfigmain = getFieldDefault(ctx,'acfigmain',[]);

        app.xfixed = false;
        app.mode = "poly"; % poly | harmonic | white | red
        app.whiteDist = "normal"; % normal | uniform

        figName = 'Acycle: Signal Noise Generator';
        if app.lang_choice > 0
            figName = ['Acycle: ',langText(app,'menu53','Signal Noise Generator')];
        end

        app.UIFigure = uifigure('Name',figName,'Color',bg, ...
            'Position',[120 80 1152 755],'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @onResize;
        app.UIFigure.WindowKeyPressFcn = @onFigureKeyPress;
        app.UIFigure.WindowKeyReleaseFcn = @onFigureKeyPress;

        buildControls();
        seedDefaults();
        onResize();
        updateModeUI();
        regenerate();

        function buildControls()
            app.LXAxis = uilabel(app.UIFigure,'Text',langText(app,'dd14','X axis'), ...
                'BackgroundColor',bg,'FontColor',blue,'FontWeight','bold');
            app.LFrom = uilabel(app.UIFigure,'Text',langText(app,'main16','From'),'BackgroundColor',bg);
            app.LTo = uilabel(app.UIFigure,'Text',langText(app,'main17','To'),'BackgroundColor',bg);
            app.LStep = uilabel(app.UIFigure,'Text',langText(app,'main32','Step'),'BackgroundColor',bg);
            app.LSelData = uilabel(app.UIFigure,'Text',langText(app,'sngen01','selected data'),'BackgroundColor',bg);

            app.EFrom = uieditfield(app.UIFigure,'text','Value','0','ValueChangedFcn',@regenerate);
            app.ETo = uieditfield(app.UIFigure,'text','Value','1000','ValueChangedFcn',@regenerate);
            app.EStep = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);

            app.LYAxis = uilabel(app.UIFigure,'Text',langText(app,'dd15','Y axis'), ...
                'BackgroundColor',bg,'FontColor',blue,'FontWeight','bold');

            app.ModeGroup = uibuttongroup(app.UIFigure,'BorderType','none','BackgroundColor',bg, ...
                'SelectionChangedFcn',@onModeGroupChanged);
            app.RPoly = uiradiobutton(app.ModeGroup,'Text',langText(app,'sngen02','Polynomial'), ...
                'FontColor',blue,'FontWeight','bold','Value',true);
            app.RHarmonic = uiradiobutton(app.ModeGroup,'Text',langText(app,'sngen03','Harmonic'), ...
                'FontColor',blue,'FontWeight','bold');
            app.RWhite = uiradiobutton(app.ModeGroup,'Text',langText(app,'sngen04','White noise'), ...
                'FontColor',blue,'FontWeight','bold');
            app.RRed = uiradiobutton(app.ModeGroup,'Text',langText(app,'sngen05','Red noise'), ...
                'FontColor',blue,'FontWeight','bold');

            app.DropPoly = uidropdown(app.UIFigure,'Items',compose('%d',0:8), ...
                'Value','0','ValueChangedFcn',@regenerate);

            app.TEq = uilabel(app.UIFigure,'Text','y =','BackgroundColor',bg);
            app.PB = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TPlus1 = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.PA1 = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TX1 = uilabel(app.UIFigure,'Text','x','BackgroundColor',bg);
            app.TPlus2 = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.PA2 = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TX2 = uilabel(app.UIFigure,'Text','x^2','BackgroundColor',bg);
            app.TPlus3 = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.PA3 = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TX3 = uilabel(app.UIFigure,'Text','x^3','BackgroundColor',bg);
            app.TPlus4 = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.PA4 = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TX4 = uilabel(app.UIFigure,'Text','x^4','BackgroundColor',bg);

            app.TPlus5 = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.PA5 = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TX5 = uilabel(app.UIFigure,'Text','x^5','BackgroundColor',bg);
            app.TPlus6 = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.PA6 = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TX6 = uilabel(app.UIFigure,'Text','x^6','BackgroundColor',bg);
            app.TPlus7 = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.PA7 = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TX7 = uilabel(app.UIFigure,'Text','x^7','BackgroundColor',bg);
            app.TPlus8 = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.PA8 = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.TX8 = uilabel(app.UIFigure,'Text','x^8','BackgroundColor',bg);

            app.HEq = uilabel(app.UIFigure,'Text','y =','BackgroundColor',bg);
            app.HA = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.HMid = uilabel(app.UIFigure,'Text','* sin ( X * 2 * pi /','BackgroundColor',bg);
            app.HT = uieditfield(app.UIFigure,'text','Value','100','ValueChangedFcn',@regenerate);
            app.HPlus = uilabel(app.UIFigure,'Text','+','BackgroundColor',bg);
            app.HPh = uieditfield(app.UIFigure,'text','Value','0','ValueChangedFcn',@regenerate);
            app.HRight = uilabel(app.UIFigure,'Text',') +','BackgroundColor',bg);
            app.HB = uieditfield(app.UIFigure,'text','Value','0','ValueChangedFcn',@regenerate);

            app.NMean = uilabel(app.UIFigure,'Text',langText(app,'sngen06','Mean'),'BackgroundColor',bg);
            app.EMean = uieditfield(app.UIFigure,'text','Value','0','ValueChangedFcn',@regenerate);
            app.NStd = uilabel(app.UIFigure,'Text',langText(app,'sngen07','Standard deviation'),'BackgroundColor',bg);
            app.EStd = uieditfield(app.UIFigure,'text','Value','1','ValueChangedFcn',@regenerate);
            app.LAlpha = uilabel(app.UIFigure,'Text','a =','BackgroundColor',bg,'Visible','off');

            app.BtnSave = uibutton(app.UIFigure,'push','Text',langText(app,'main01','Save data'), ...
                'BackgroundColor',[0.05 0.05 0.95],'FontColor','white','FontWeight','bold', ...
                'ButtonPushedFcn',@saveData);

            app.UIAxes = uiaxes(app.UIFigure,'BackgroundColor','white');
            app.UIAxes.Box = 'on';
            app.UIAxes.XMinorTick = 'on';
            app.UIAxes.YMinorTick = 'on';
            try
                app.UIAxes.Toolbar.Visible = 'off';
            catch
            end

            app.HiddenAlpha = uieditfield(app.UIFigure,'text','Value','0.5','Visible','off','ValueChangedFcn',@regenerate);
            app.DistGroup = uibuttongroup(app.UIFigure,'BorderType','none','BackgroundColor',bg,'Visible','off', ...
                'SelectionChangedFcn',@onDistGroupChanged);
            app.HiddenDistNorm = uiradiobutton(app.DistGroup,'Text',langText(app,'sngen08','Normal distribution'), ...
                'Value',true,'Visible','off');
            app.HiddenDistRand = uiradiobutton(app.DistGroup,'Text',langText(app,'sngen09','Random distribution'), ...
                'Visible','off');
        end

        function seedDefaults()
            if isfield(ctx,'current_data') && ~isempty(ctx.current_data) && size(ctx.current_data,2) >= 1
                x = ctx.current_data(:,1);
                x = x(:);
                x = x(isfinite(x));
                if ~isempty(x)
                    app.xfixed = true;
                    app.x = x;
                    app.EFrom.Value = num2str(min(x),'%.10g');
                    app.ETo.Value = num2str(max(x),'%.10g');
                    app.EStep.Value = '';
                    app.EFrom.Enable = 'off';
                    app.ETo.Enable = 'off';
                    app.EStep.Enable = 'off';
                    app.LSelData.Visible = 'on';
                end
            end
            if ~app.xfixed
                app.LSelData.Visible = 'off';
            end
        end

        function onResize(~,~)
            p = app.UIFigure.Position; w = p(3); h = p(4);
            place(app.LXAxis,[0.013,0.933,0.069,0.029],w,h);
            place(app.LFrom,[0.013,0.858,0.05,0.029],w,h);
            place(app.LTo,[0.013,0.807,0.05,0.029],w,h);
            place(app.LStep,[0.013,0.747,0.05,0.029],w,h);
            place(app.LSelData,[0.013,0.641,0.12,0.07],w,h);

            place(app.EFrom,[0.06,0.847,0.075,0.049],w,h);
            place(app.ETo,[0.06,0.792,0.075,0.049],w,h);
            place(app.EStep,[0.06,0.736,0.075,0.049],w,h);

            place(app.LYAxis,[0.173,0.933,0.069,0.029],w,h);
            mg = [round(0.165*w) round(0.62*h) round(0.16*w) round(0.30*h)];
            app.ModeGroup.Position = mg;
            app.RPoly.Position = [round(0.008*w) round(0.25*h) round(0.125*w) round(0.05*h)];
            app.RHarmonic.Position = [round(0.008*w) round(0.15*h) round(0.125*w) round(0.05*h)];
            app.RWhite.Position = [round(0.008*w) round(0.085*h) round(0.125*w) round(0.05*h)];
            app.RRed.Position = [round(0.008*w) round(0.035*h) round(0.125*w) round(0.05*h)];
            dg = [round(0.48*w) round(0.64*h) round(0.45*w) round(0.12*h)];
            app.DistGroup.Position = dg;
            app.HiddenDistNorm.Position = [round(0.02*dg(3)) round(0.52*dg(4)) round(0.97*dg(3)) round(0.40*dg(4))];
            app.HiddenDistRand.Position = [round(0.02*dg(3)) round(0.08*dg(4)) round(0.97*dg(3)) round(0.40*dg(4))];

            place(app.DropPoly,[0.3,0.887,0.0667,0.04],w,h);
            place(app.TEq,[0.398,0.918,0.056,0.029],w,h);
            place(app.TPlus1,[0.489,0.918,0.029,0.029],w,h);
            place(app.TX1,[0.569,0.918,0.029,0.029],w,h);
            place(app.TPlus2,[0.598,0.918,0.029,0.029],w,h);
            place(app.TX2,[0.715,0.918,0.029,0.029],w,h);
            place(app.TPlus3,[0.678,0.918,0.029,0.029],w,h);
            place(app.TX3,[0.836,0.918,0.029,0.029],w,h);
            place(app.TPlus4,[0.795,0.918,0.029,0.029],w,h);
            place(app.TX4,[0.916,0.918,0.029,0.029],w,h);

            place(app.TPlus5,[0.489,0.858,0.029,0.029],w,h);
            place(app.TX5,[0.569,0.858,0.029,0.029],w,h);
            place(app.TPlus6,[0.598,0.858,0.029,0.029],w,h);
            place(app.TX6,[0.715,0.858,0.029,0.029],w,h);
            place(app.TPlus7,[0.678,0.858,0.029,0.029],w,h);
            place(app.TX7,[0.836,0.858,0.029,0.029],w,h);
            place(app.TPlus8,[0.795,0.858,0.029,0.029],w,h);
            place(app.TX8,[0.916,0.858,0.029,0.029],w,h);

            place(app.PB,[0.441,0.902,0.044,0.049],w,h);
            place(app.PA1,[0.518,0.902,0.044,0.049],w,h);
            place(app.PA2,[0.627,0.902,0.044,0.049],w,h);
            place(app.PA3,[0.744,0.902,0.044,0.049],w,h);
            place(app.PA4,[0.866,0.902,0.044,0.049],w,h);
            place(app.PA5,[0.518,0.849,0.044,0.049],w,h);
            place(app.PA6,[0.627,0.849,0.044,0.049],w,h);
            place(app.PA7,[0.744,0.849,0.044,0.049],w,h);
            place(app.PA8,[0.866,0.849,0.044,0.049],w,h);

            place(app.HEq,[0.398,0.783,0.056,0.029],w,h);
            place(app.HMid,[0.489,0.783,0.108,0.029],w,h);
            place(app.HPlus,[0.644,0.783,0.02,0.029],w,h);
            place(app.HRight,[0.715,0.783,0.02,0.029],w,h);
            place(app.HA,[0.441,0.774,0.044,0.049],w,h);
            place(app.HT,[0.592,0.774,0.044,0.049],w,h);
            place(app.HPh,[0.666,0.774,0.044,0.049],w,h);
            place(app.HB,[0.739,0.774,0.044,0.049],w,h);

            place(app.NMean,[0.302,0.687,0.056,0.029],w,h);
            place(app.NStd,[0.406,0.687,0.123,0.029],w,h);
            place(app.EMean,[0.358,0.678,0.044,0.049],w,h);
            place(app.EStd,[0.531,0.678,0.044,0.049],w,h);
            place(app.LAlpha,[0.586,0.687,0.045,0.029],w,h);
            place(app.HiddenAlpha,[0.636,0.678,0.044,0.049],w,h);

            place(app.BtnSave,[0.868,0.665,0.1,0.085],w,h);
            place(app.UIAxes,[0.065,0.065,0.897,0.557],w,h);
        end

        function onModeChanged(src)
            app.RPoly.Value = src == app.RPoly;
            app.RHarmonic.Value = src == app.RHarmonic;
            app.RWhite.Value = src == app.RWhite;
            app.RRed.Value = src == app.RRed;
            if src == app.RPoly
                app.mode = "poly";
            elseif src == app.RHarmonic
                app.mode = "harmonic";
            elseif src == app.RWhite
                app.mode = "white";
            else
                app.mode = "red";
            end
            updateModeUI();
            regenerate();
        end

        function onModeGroupChanged(~,event)
            if isstruct(event) && isfield(event,'NewValue')
                src = event.NewValue;
            else
                src = app.ModeGroup.SelectedObject;
            end
            onModeChanged(src);
        end

        function onDistChanged(src)
            app.HiddenDistNorm.Value = src == app.HiddenDistNorm;
            app.HiddenDistRand.Value = src == app.HiddenDistRand;
            if app.HiddenDistNorm.Value
                app.whiteDist = "normal";
            else
                app.whiteDist = "uniform";
            end
            regenerate();
        end

        function onDistGroupChanged(~,event)
            if isstruct(event) && isfield(event,'NewValue')
                src = event.NewValue;
            else
                src = app.DistGroup.SelectedObject;
            end
            onDistChanged(src);
        end

        function updateModeUI()
            isPoly = app.mode == "poly";
            isHar = app.mode == "harmonic";
            isWhite = app.mode == "white";
            isRed = app.mode == "red";

            app.DropPoly.Enable = tf(isPoly);
            app.PB.Enable = tf(isPoly);
            for f = [app.PA1 app.PA2 app.PA3 app.PA4 app.PA5 app.PA6 app.PA7 app.PA8]
                f.Enable = tf(isPoly);
            end

            for f = [app.HA app.HT app.HPh app.HB]
                f.Enable = tf(isHar);
            end

            app.EMean.Enable = tf(isWhite || isRed);
            app.EStd.Enable = tf(isWhite || isRed);

            app.DistGroup.Visible = tf(isWhite);
            app.HiddenDistNorm.Visible = tf(isWhite);
            app.HiddenDistRand.Visible = tf(isWhite);
            app.HiddenDistNorm.Enable = tf(isWhite);
            app.HiddenDistRand.Enable = tf(isWhite);

            app.LAlpha.Visible = tf(isRed);
            app.HiddenAlpha.Visible = tf(isRed);
            app.HiddenAlpha.Enable = tf(isRed);

            setPolyFieldEnableByDegree();
        end

        function setPolyFieldEnableByDegree()
            deg = str2double(app.DropPoly.Value);
            if ~isfinite(deg), deg = 0; end
            polyFields = [app.PA1 app.PA2 app.PA3 app.PA4 app.PA5 app.PA6 app.PA7 app.PA8];
            for i = 1:numel(polyFields)
                if app.mode == "poly" && deg >= i
                    polyFields(i).Enable = 'on';
                else
                    polyFields(i).Enable = 'off';
                end
            end
        end

        function regenerate(~,~)
            try
                if app.xfixed
                    x = app.x;
                else
                    x1 = asNum(app.EFrom.Value,0);
                    x2 = asNum(app.ETo.Value,1000);
                    dx = asNum(app.EStep.Value,1);
                    if dx == 0
                        dx = 1;
                    end
                    if x2 < x1
                        tmp = x1; x1 = x2; x2 = tmp;
                    end
                    x = (x1:dx:x2)';
                    if isempty(x)
                        x = [x1;x2];
                    end
                    app.x = x;
                end

                setPolyFieldEnableByDegree();
                deg = str2double(app.DropPoly.Value);
                if ~isfinite(deg), deg = 0; end

                if app.mode == "poly"
                    b = asNum(app.PB.Value,1);
                    c = [asNum(app.PA1.Value,1), asNum(app.PA2.Value,1), asNum(app.PA3.Value,1), asNum(app.PA4.Value,1), ...
                        asNum(app.PA5.Value,1), asNum(app.PA6.Value,1), asNum(app.PA7.Value,1), asNum(app.PA8.Value,1)];
                    c((deg+1):end) = 0;
                    y = b + c(1)*x + c(2)*x.^2 + c(3)*x.^3 + c(4)*x.^4 + c(5)*x.^5 + c(6)*x.^6 + c(7)*x.^7 + c(8)*x.^8;
                elseif app.mode == "harmonic"
                    A = asNum(app.HA.Value,1);
                    T = asNum(app.HT.Value,100);
                    Ph = asNum(app.HPh.Value,0);
                    B = asNum(app.HB.Value,0);
                    if T == 0
                        T = 100;
                    end
                    y = A * sin(2*pi./T.*x + Ph) + B;
                elseif app.mode == "white"
                    mu = asNum(app.EMean.Value,0);
                    sigma = asNum(app.EStd.Value,1);
                    if app.whiteDist == "normal"
                        y = sigma * randn(length(x),1) + mu;
                    else
                        y = sigma * zscore(rand(length(x),1)) + mu;
                    end
                else
                    mu = asNum(app.EMean.Value,0);
                    sigma = asNum(app.EStd.Value,1);
                    alpha = asNum(app.HiddenAlpha.Value,0.5);
                    y = sigma * zscore(localRedNoise(alpha,length(x))) + mu;
                end

                app.x = x;
                app.y = y;

                cla(app.UIAxes);
                plot(app.UIAxes,x,y,'r-o','MarkerFaceColor','none','LineWidth',1);
                xlim(app.UIAxes,[min(x) max(x)]);
                xlabel(app.UIAxes,'x');
                ylabel(app.UIAxes,'y');
                drawnow limitrate;
            catch ME
                uialert(app.UIFigure,ME.message,'Line Generator Error');
            end
        end

        function saveData(~,~)
            try
                regenerate();
                [filename, fileOut] = makeFileName();

                oldDir = pwd;
                outDir = getAcPwdPath(oldDir);
                cd(outDir);
                dlmwrite(filename, [app.x,app.y], 'delimiter', ' ', 'precision', 9);

                refreshMainListbox();

                if ~isempty(app.acfigmain) && isgraphics(app.acfigmain)
                    figure(app.acfigmain);
                end

                cd(oldDir);
                disp('Generated data:');
                disp(fileOut);
            catch ME
                uialert(app.UIFigure,ME.message,'Save Error');
            end
        end

        function [name, shown] = makeFileName()
            if app.mode == "harmonic"
                A = asNum(app.HA.Value,1);
                T = asNum(app.HT.Value,100);
                Ph = asNum(app.HPh.Value,0);
                B = asNum(app.HB.Value,0);
                name = ['SigGen-sineA',num2str(A),'T',num2str(T),'Ph',num2str(Ph),'B',num2str(B),'.txt'];
            elseif app.mode == "poly"
                deg = str2double(app.DropPoly.Value);
                if ~isfinite(deg), deg = 0; end
                if deg == 0
                    name = ['SigGen-linear-0-',app.PB.Value,'.txt'];
                elseif deg == 1
                    name = ['SigGen-linear-1-',app.PB.Value,'+',app.PA1.Value,'x.txt'];
                elseif deg == 2
                    name = ['SigGen-linear-2-',app.PB.Value,'+',app.PA1.Value,'x+',app.PA2.Value,'x2.txt'];
                else
                    name = ['SigGen-poly-',num2str(deg),'-',app.PB.Value,'+',app.PA1.Value,'x+',app.PA2.Value,'x2+more.txt'];
                end
            elseif app.mode == "white"
                mu = asNum(app.EMean.Value,0);
                sigma = asNum(app.EStd.Value,1);
                if app.whiteDist == "normal"
                    dist = 'normdist';
                else
                    dist = 'randdist';
                end
                name = ['SigGen-whitenoise-',num2str(sigma),'std-',num2str(mu),'mean-',dist,'.txt'];
            else
                mu = asNum(app.EMean.Value,0);
                sigma = asNum(app.EStd.Value,1);
                alpha = asNum(app.HiddenAlpha.Value,0.5);
                name = ['SigGen-rednoise-',num2str(sigma),'std-',num2str(mu),'mean-',num2str(alpha),'alpha.txt'];
            end
            shown = name;
        end

        function refreshMainListbox()
            if isempty(app.listbox_acmain) || ~ishandle(app.listbox_acmain)
                return
            end

            d = dir;
            d = d(~ismember({d.name},{'.','..'}));
            val1 = app.val1;
            if ~isscalar(val1) || ~isfinite(val1)
                val1 = 1;
            end
            switch round(val1)
                case 1
                    [~,idx] = sort({d.name});
                case 2
                    [~,idx] = sort({d.name},'descend');
                case 3
                    [~,idx] = sort([d.datenum],'ascend');
                case 4
                    [~,idx] = sort([d.datenum],'descend');
                case 5
                    [~,idx] = sort([d.bytes],'ascend');
                case 6
                    [~,idx] = sort([d.bytes],'descend');
                otherwise
                    [~,idx] = sort({d.name});
            end
            d = d(idx);

            pre = '<HTML><FONT color="blue">';
            post = '</FONT></HTML>';
            listboxStr = cell(numel(d),1);
            for i = 1:numel(d)
                if d(i).isdir
                    listboxStr{i} = [pre,d(i).name,post];
                else
                    listboxStr{i} = d(i).name;
                end
            end

            set(app.listbox_acmain,'String',listboxStr,'Value',[]);
            if ~isempty(app.edit_acfigmain_dir) && ishandle(app.edit_acfigmain_dir)
                set(app.edit_acfigmain_dir,'String',pwd);
            end
            updateAcPwdTextFile(pwd);
        end

        function onFigureKeyPress(~,event)
            keyVal = getEventProp(event,'Key','');
            charVal = getEventProp(event,'Character','');
            keyIsW = strcmpi(string(keyVal),'w');
            chIsCtrlW = isequal(char(charVal),char(23));
            if ~(keyIsW || chIsCtrlW)
                return
            end

            mods = normalizeModifiers(event);
            hasCloseMod = any(mods == "control") || any(mods == "command") || any(mods == "meta");
            if hasCloseMod || chIsCtrlW
                try
                    if isvalid(app.UIFigure)
                        close(app.UIFigure);
                    end
                catch
                end
            end
        end
    end
end

function place(h, r, w, hgt)
if isempty(h) || ~isvalid(h)
    return
end
h.Position = [round(r(1)*w) round(r(2)*hgt) round(r(3)*w) round(r(4)*hgt)];
end

function outDir = getAcPwdPath(fallbackDir)
outDir = fallbackDir;
try
    if exist('ac_pwd.txt','file') == 2
        p = strtrim(fileread('ac_pwd.txt'));
        if ~isempty(p) && isfolder(p)
            outDir = p;
        end
    end
catch
end
end

function updateAcPwdTextFile(address)
try
    ac_pwd_str = which('ac_pwd.txt');
    if isempty(ac_pwd_str)
        return
    end
    [ac_pwd_dir,~,~] = fileparts(ac_pwd_str);
    fid = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
    if fid < 0
        return
    end
    c = onCleanup(@()fclose(fid)); %#ok<NASGU>
    fprintf(fid,'%s',address);
catch
end
end

function y = localRedNoise(alpha,n)
if exist('redmark','file') == 2
    y = redmark(alpha,n);
else
    rng('shuffle');
    y = filter(1,[1;-alpha],randn(n,1));
end
end

function v = asNum(s, d)
v = str2double(string(s));
if ~isfinite(v)
    v = d;
end
end

function t = tf(flag)
if flag
    t = 'on';
else
    t = 'off';
end
end

function txt = langText(app,key,fallback)
txt = fallback;
if ~isstruct(app) || ~isfield(app,'lang_choice') || app.lang_choice == 0
    return
end
if ~isfield(app,'lang_id') || ~isfield(app,'lang_var') || isempty(app.lang_id) || isempty(app.lang_var)
    return
end
[tfm,idx] = ismember(key, app.lang_id);
if tfm && idx > 0 && idx <= numel(app.lang_var)
    v = app.lang_var{idx};
    if ischar(v) || isstring(v)
        txt = char(v);
    end
end
end

function v = getFieldDefault(s,name,default)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default;
end
end

function mods = normalizeModifiers(event)
mods = strings(0,1);
raw = getEventProp(event,'Modifier',[]);
if isempty(raw)
    return
end
if isstring(raw)
    mods = lower(raw(:));
elseif ischar(raw)
    mods = string(lower(raw));
elseif iscell(raw)
    mods = lower(string(raw(:)));
end
end

function v = getEventProp(event,name,default)
v = default;
try
    if isstruct(event)
        if isfield(event,name)
            v = event.(name);
        end
    else
        if isprop(event,name)
            v = event.(name);
        end
    end
catch
end
end
