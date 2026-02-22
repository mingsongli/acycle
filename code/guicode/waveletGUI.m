function varargout = waveletGUI(varargin)
% App Designer-style migration of waveletGUI.fig (single-file).

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
        app.name1 = getDataName(ctx);

        app.UIFigure = uifigure('Name','Acycle: Wavelet','Color',bg, ...
            'Position',[110 80 1792 860],'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)doLayout();

        app.LSeries1 = uilabel(app.UIFigure,'Text','Series 1','BackgroundColor',bg);
        app.EName1 = uieditfield(app.UIFigure,'text','Value',app.name1,'Editable','off');
        app.LSeries2 = uilabel(app.UIFigure,'Text','Series 2','FontColor',[0.65 0.65 0.65],'BackgroundColor',bg);
        app.EName2 = uieditfield(app.UIFigure,'text','Value','','Editable','off','Enable','off');
        app.CkStd = uicheckbox(app.UIFigure,'Text','standardize','Value',false);

        app.PanelPeriod = uipanel(app.UIFigure,'Title','Set Period','BackgroundColor',bg);
        app.LPMin = uilabel(app.PanelPeriod,'Text','Period Min','BackgroundColor',bg);
        app.EPMin = uieditfield(app.PanelPeriod,'text','Value','0.68181','FontColor',blue);
        app.LPMax = uilabel(app.PanelPeriod,'Text','Period Max','BackgroundColor',bg);
        app.EPMax = uieditfield(app.PanelPeriod,'text','Value','64.1208','FontColor',blue);
        app.LDj = uilabel(app.PanelPeriod,'Text','Discrete scale spacing','BackgroundColor',bg);
        app.EDj = uieditfield(app.PanelPeriod,'text','Value','0.1','FontColor',blue);
        app.RLinear = uiradiobutton(app.PanelPeriod,'Text','linear');
        app.RLog2 = uiradiobutton(app.PanelPeriod,'Text','log2','Value',true);
        app.BGScale = uibuttongroup(app.PanelPeriod,'BorderType','none','BackgroundColor',bg);
        app.RLinear.Parent = app.BGScale; app.RLog2.Parent = app.BGScale;
        app.CkPad = uicheckbox(app.PanelPeriod,'Text','padding','Value',true,'FontWeight','bold');

        app.PanelMethod = uipanel(app.UIFigure,'Title','Method','BackgroundColor',bg);
        app.LMethod = uilabel(app.PanelMethod,'Text','Method','BackgroundColor',bg);
        app.DropMethod = uidropdown(app.PanelMethod,'Items',{'Continuous Wavelet Transform','Wavelet (Torrence & Compo, 1998)'},'Value','Continuous Wavelet Transform');
        app.LMother = uilabel(app.PanelMethod,'Text','Mother','BackgroundColor',bg);
        app.DropMother = uidropdown(app.PanelMethod,'Items',{'MORLET','PAUL','DOG'},'Value','MORLET','ValueChangedFcn',@(~,~)onMotherChanged());
        app.LParam = uilabel(app.PanelMethod,'Text','Parameter','BackgroundColor',bg);
        app.EParam = uieditfield(app.PanelMethod,'text','Value','6');

        app.PanelPlot = uipanel(app.UIFigure,'Title','Plot','BackgroundColor',bg);
        app.CkPlotSeries = uicheckbox(app.PanelPlot,'Text','plot series','Value',true,'FontWeight','bold');
        app.CkPlotSpectrum = uicheckbox(app.PanelPlot,'Text','plot spectrum','Value',false);
        app.CkCOI = uicheckbox(app.PanelPlot,'Text','cone of influence','Value',true,'FontWeight','bold');
        app.CkPowerLog2 = uicheckbox(app.PanelPlot,'Text','power log 2','Value',true,'FontWeight','bold');
        app.CkZ = uicheckbox(app.PanelPlot,'Text','Z le...','Value',false);
        app.CkFlipDT = uicheckbox(app.PanelPlot,'Text','flip depth/time','Value',false);
        app.CkFlipPeriod = uicheckbox(app.PanelPlot,'Text','flip period','Value',false);
        app.CkSwap = uicheckbox(app.PanelPlot,'Text','swap x-y','Value',false);
        app.CkSig = uicheckbox(app.PanelPlot,'Text','p=0.05 sig.lev.','Value',true,'FontWeight','bold');
        app.LCmap = uilabel(app.PanelPlot,'Text','colormap','BackgroundColor',bg);
        app.DropCmap = uidropdown(app.PanelPlot,'Items',{'default','parula','jet','turbo','hsv','hot','cool','gray'},'Value','default');
        app.LGrid = uilabel(app.PanelPlot,'Text','grid #','BackgroundColor',bg);
        app.EGrid = uieditfield(app.PanelPlot,'text','Value','');
        app.LTick = uilabel(app.PanelPlot,'Text','tick label','BackgroundColor',bg);
        app.ETwitter = uieditfield(app.PanelPlot,'text','Value','1 2 4 8 16 32 64 128');
        app.BtnHelp = uibutton(app.PanelPlot,'push','Text','?','ButtonPushedFcn',@(~,~)showTickHelp());
        app.R2D = uiradiobutton(app.PanelPlot,'Text','2D','Value',true);
        app.R3D = uiradiobutton(app.PanelPlot,'Text','3D','Value',false);
        app.BGDim = uibuttongroup(app.PanelPlot,'BorderType','none','BackgroundColor',bg);
        app.R2D.Parent = app.BGDim; app.R3D.Parent = app.BGDim;

        app.PanelSave = uipanel(app.UIFigure,'Title','Save','BackgroundColor',bg);
        app.CkSave = uicheckbox(app.PanelSave,'Text','save result','Value',false);
        app.BtnOK = uibutton(app.PanelSave,'push','Text','OK', ...
            'BackgroundColor',blue,'FontColor','white','FontWeight','bold', ...
            'ButtonPushedFcn',@(~,~)runWavelet());

        doLayout();

        function doLayout()
            p = app.UIFigure.Position; w = p(3); h = p(4);
            app.LSeries1.Position = [round(0.045*w) round(0.86*h) round(0.09*w) 36];
            app.EName1.Position = [round(0.13*w) round(0.85*h) round(0.65*w) 46];
            app.CkStd.Position = [round(0.79*w) round(0.86*h) round(0.17*w) 34];
            app.LSeries2.Position = [round(0.045*w) round(0.78*h) round(0.09*w) 36];
            app.EName2.Position = [round(0.13*w) round(0.77*h) round(0.65*w) 46];

            app.PanelPeriod.Position = [round(0.02*w) round(0.38*h) round(0.46*w) round(0.31*h)];
            app.PanelMethod.Position = [round(0.50*w) round(0.38*h) round(0.46*w) round(0.31*h)];
            app.PanelPlot.Position   = [round(0.02*w) round(0.03*h) round(0.78*w) round(0.32*h)];
            app.PanelSave.Position   = [round(0.82*w) round(0.03*h) round(0.14*w) round(0.32*h)];

            pw = app.PanelPeriod.Position(3); ph = app.PanelPeriod.Position(4);
            app.BGScale.Position = [1 1 pw-2 ph-2];
            app.LPMin.Position = [round(0.07*pw) round(0.76*ph) round(0.24*pw) 38];
            app.EPMin.Position = [round(0.30*pw) round(0.73*ph) round(0.30*pw) 50];
            app.LPMax.Position = [round(0.07*pw) round(0.48*ph) round(0.24*pw) 38];
            app.EPMax.Position = [round(0.30*pw) round(0.45*ph) round(0.30*pw) 50];
            app.LDj.Position = [round(0.045*pw) round(0.16*ph) round(0.42*pw) 38];
            app.EDj.Position = [round(0.45*pw) round(0.13*ph) round(0.15*pw) 50];
            app.RLinear.Position = [round(0.70*pw) round(0.74*ph) round(0.25*pw) 38];
            app.RLog2.Position = [round(0.70*pw) round(0.44*ph) round(0.25*pw) 38];
            app.CkPad.Position = [round(0.70*pw) round(0.16*ph) round(0.25*pw) 38];

            pw = app.PanelMethod.Position(3); ph = app.PanelMethod.Position(4);
            app.LMethod.Position = [round(0.07*pw) round(0.72*ph) round(0.22*pw) 38];
            app.DropMethod.Position = [round(0.28*pw) round(0.70*ph) round(0.66*pw) 42];
            app.LMother.Position = [round(0.07*pw) round(0.45*ph) round(0.22*pw) 38];
            app.DropMother.Position = [round(0.28*pw) round(0.43*ph) round(0.66*pw) 42];
            app.LParam.Position = [round(0.07*pw) round(0.17*ph) round(0.22*pw) 38];
            app.EParam.Position = [round(0.27*pw) round(0.13*ph) round(0.10*pw) 50];

            pw = app.PanelPlot.Position(3); ph = app.PanelPlot.Position(4);
            app.BGDim.Position = [1 1 pw-2 ph-2];
            app.CkPlotSeries.Position = [round(0.02*pw) round(0.74*ph) round(0.25*pw) 34];
            app.CkPlotSpectrum.Position = [round(0.02*pw) round(0.50*ph) round(0.25*pw) 34];
            app.CkCOI.Position = [round(0.02*pw) round(0.26*ph) round(0.25*pw) 34];
            app.CkPowerLog2.Position = [round(0.02*pw) round(0.05*ph) round(0.18*pw) 34];
            app.CkZ.Position = [round(0.18*pw) round(0.05*ph) round(0.14*pw) 34];

            app.CkFlipDT.Position = [round(0.30*pw) round(0.74*ph) round(0.22*pw) 34];
            app.CkFlipPeriod.Position = [round(0.30*pw) round(0.50*ph) round(0.22*pw) 34];
            app.CkSwap.Position = [round(0.30*pw) round(0.26*ph) round(0.22*pw) 34];
            app.CkSig.Position = [round(0.30*pw) round(0.05*ph) round(0.24*pw) 34];

            app.LCmap.Position = [round(0.50*pw) round(0.73*ph) round(0.16*pw) 34];
            app.DropCmap.Position = [round(0.63*pw) round(0.70*ph) round(0.18*pw) 42];
            app.LGrid.Position = [round(0.50*pw) round(0.50*ph) round(0.16*pw) 34];
            app.EGrid.Position = [round(0.62*pw) round(0.47*ph) round(0.07*pw) 42];
            app.LTick.Position = [round(0.50*pw) round(0.26*ph) round(0.16*pw) 34];
            app.ETwitter.Position = [round(0.62*pw) round(0.23*ph) round(0.32*pw) 42];
            app.BtnHelp.Position = [round(0.95*pw) round(0.23*ph) round(0.035*pw) 42];
            app.R2D.Position = [round(0.65*pw) round(0.05*ph) round(0.10*pw) 34];
            app.R3D.Position = [round(0.75*pw) round(0.05*ph) round(0.10*pw) 34];

            pw = app.PanelSave.Position(3); ph = app.PanelSave.Position(4);
            app.CkSave.Position = [round(0.08*pw) round(0.58*ph) round(0.84*pw) 34];
            app.BtnOK.Position = [round(0.20*pw) round(0.12*ph) round(0.60*pw) round(0.36*ph)];
        end

        function onMotherChanged()
            m = upper(string(app.DropMother.Value));
            if m == "MORLET"
                app.EParam.Value = '6';
            elseif m == "PAUL"
                app.EParam.Value = '4';
            else
                app.EParam.Value = '2';
            end
        end

        function showTickHelp()
            uialert(app.UIFigure,'Use space-separated values, e.g. 1 2 4 8 16 32','tick label');
        end

        function runWavelet()
            try
                data = app.data;
                t = data(:,1);
                y = data(:,2);
                if app.CkStd.Value
                    y = (y - mean(y,'omitnan')) ./ std(y,'omitnan');
                end

                dt = median(diff(t));
                pmin = str2double(app.EPMin.Value);
                pmax = str2double(app.EPMax.Value);
                dj = str2double(app.EDj.Value);
                param = str2double(app.EParam.Value);
                if ~isfinite(param), param = 6; end
                pad = app.CkPad.Value;

                if app.BGScale.SelectedObject == app.RLinear
                    period = linspace(pmin,pmax,120);
                    scale = period;
                else
                    period = 2.^(log2(pmin):dj:log2(pmax));
                    scale = period;
                end
                s0 = max(period(1), eps);
                j1 = max(1,round(log2(pmax/s0)/dj));

                mother = upper(string(app.DropMother.Value));
                [wave,periodOut,~,coi] = wavelet(y,dt,pad,dj,s0,j1,char(mother),param);
                power = abs(wave).^2;

                fig = figure('Color','white','Name','Acycle: Wavelet Result');
                cm = char(app.DropCmap.Value);
                if strcmp(cm,'default'); cm = 'parula'; end

                nrow = 1 + app.CkPlotSeries.Value;
                if nrow == 2
                    ax1 = subplot(2,1,1);
                    plot(ax1,t,y,'k-','LineWidth',1);
                    ylabel(ax1,'Series');
                    set(ax1,'XMinorTick','on','YMinorTick','on');
                end

                ax2 = subplot(nrow,1,nrow);
                pp = power;
                if app.CkPowerLog2.Value
                    pp = log2(power + eps);
                end
                imagesc(ax2,t,periodOut,pp);
                axis(ax2,'xy');
                colormap(ax2,cm);
                colorbar(ax2);
                ylabel(ax2,['Period (',app.unit,')']);
                xlabel(ax2,['Depth/Time (',app.unit,')']);
                title(ax2,'Wavelet power spectrum');

                if app.CkCOI.Value
                    hold(ax2,'on');
                    plot(ax2,t,coi,'w--','LineWidth',1.2);
                    hold(ax2,'off');
                end

                if app.CkFlipDT.Value
                    set(ax2,'XDir','reverse');
                end
                if app.CkFlipPeriod.Value
                    set(ax2,'YDir','reverse');
                end
                if app.CkSwap.Value
                    cla(ax2);
                    imagesc(ax2,periodOut,t,pp');
                    axis(ax2,'xy');
                    colormap(ax2,cm);
                    colorbar(ax2);
                    xlabel(ax2,['Period (',app.unit,')']);
                    ylabel(ax2,['Depth/Time (',app.unit,')']);
                end
                if app.BGDim.SelectedObject == app.R3D
                    figure('Color','white','Name','Acycle: Wavelet 3D');
                    surf(t,periodOut,pp,'EdgeColor','none'); view(3); colormap(cm); colorbar;
                    xlabel(['Depth/Time (',app.unit,')']); ylabel(['Period (',app.unit,')']); zlabel('Power');
                end

                if app.CkSave.Value
                    [~,name,~] = fileparts(app.name1);
                    out = [periodOut(:), mean(pp,2,'omitnan')];
                    writematrix(out,[name,'-wavelet.txt'],'Delimiter','tab');
                end
            catch ME
                uialert(app.UIFigure,ME.message,'Wavelet Error');
            end
        end
    end
end

function data = getCurrentData(ctx)
if isfield(ctx,'current_data') && ~isempty(ctx.current_data)
    data = sortrows(ctx.current_data);
else
    t = linspace(0,100,400)';
    data = [t, sin(2*pi*t/20)+0.4*sin(2*pi*t/7)];
end
end

function u = getUnit(ctx)
if isfield(ctx,'unit') && ~isempty(ctx.unit)
    u = char(ctx.unit);
else
    u = 'unit';
end
end

function n = getDataName(ctx)
if isfield(ctx,'data_name') && ~isempty(ctx.data_name)
    [~,nm,ex] = fileparts(char(ctx.data_name));
    n = [nm,ex];
else
    n = 'Series-1.txt';
end
end
