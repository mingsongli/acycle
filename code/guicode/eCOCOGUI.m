function varargout = eCOCOGUI(varargin)
% eCOCOGUI - App Designer style single-file GUI (no GUIDE .fig)
ctx = struct();
if nargin > 0 && isstruct(varargin{1})
    ctx = varargin{1};
end

app = createApp(ctx);
if nargout > 0
    varargout{1} = app.UIFigure;
end

    function app = createApp(ctx)
        app = struct();
        app.ctx = ctx;
        app.bg = [0.94 0.94 0.94];
        app.blue = [0.08 0.02 0.95];

        [app.dataRaw, app.data, app.meta] = prepData(ctx);

        app.mode = 2; % 1=COCO, 2=eCOCO
        app.corrmethod = 1; % 1 Pearson, 2 Spearman
        app.red = 0; % 0 no
        app.time_0pad = 1;
        app.padtype = 1;

        app.orbit7 = [405 125 95 41 22.43 23.75 19.18];
        app.age = 0;
        app.f1 = 0;
        app.f2 = 0.06;
        app.slices = 1;
        app.adjust = 0;
        app.nsim = 2000;

        app.window = max(1e-6, 0.25 * abs(app.data(end,1) - app.data(1,1)));
        app.step = app.meta.dt;
        if size(app.data,1) > 300
            app.step = app.meta.dt * ceil(size(app.data,1)/300);
        end

        app.pad = defaultPad(size(app.data,1));
        [app.sedmin, app.sedmax, app.sedstep, app.fh] = defaultSedRange(app);

        app.run = struct('ready',false,'target',[],'prt_sr',[],'out_depth',[], ...
            'out_ecc',[],'out_ep',[],'out_eci',[],'out_ecoco',[],'out_ecocorb',[], ...
            'out_norbit',[],'corrCI',[],'corr_h0',[],'cocoFigure',[]);

        app.UIFigure = uifigure('Name','Acycle: (Evolutionary) Correlation Coefficient / (e)COCO', ...
            'Color',app.bg,'Position',figurePos(ctx),'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)onResize();

        createComponents();
        loadDefaultsToUI();
        onModeChanged();
        refreshSedInfo();

        setappdata(app.UIFigure,'ECOCO_APP',app);
        onResize();

        function createComponents()
            app.PMethod = uipanel(app.UIFigure,'Title','Select Method','BackgroundColor',app.bg);
            app.BGMethod = uibuttongroup(app.PMethod,'BackgroundColor',app.bg,'BorderType','none', ...
                'SelectionChangedFcn',@(s,e)onModeChanged());
            app.RCOCO = uiradiobutton(app.BGMethod,'Text','COCO','FontWeight','bold','FontColor',app.blue,'Value',false);
            app.RECOCO = uiradiobutton(app.BGMethod,'Text','eCOCO','FontWeight','bold','FontColor',app.blue,'Value',true);

            app.PData = uipanel(app.UIFigure,'Title','Data','BackgroundColor',app.bg);
            app.LData = uilabel(app.PData,'Text','Data','BackgroundColor',app.bg);
            app.LDataName = uilabel(app.PData,'Text',app.meta.dat_name,'BackgroundColor',app.bg);
            app.C0Pad = uicheckbox(app.PData,'Text','0 padding','Value',true,'ValueChangedFcn',@(s,e)onPadToggle());
            app.EPad = uieditfield(app.PData,'text','Value',num2str(app.pad),'ValueChangedFcn',@(s,e)onEditNum(app.EPad,app.pad));
            app.CPadEdge = uicheckbox(app.PData,'Text','0 padding edge','Value',true);
            app.DPadEdge = uidropdown(app.PData,'Items',{'zero','mirror','mean','random'},'Value','zero');
            app.CFlipY = uicheckbox(app.PData,'Text','Flip Depth (y axis)','Value',true);

            app.PPeriod = uipanel(app.UIFigure,'Title','Periodogram of Data','BackgroundColor',app.bg);
            app.CShowPeriod = uicheckbox(app.PPeriod,'Text','Show period.','Value',true);
            app.LMaxF = uilabel(app.PPeriod,'Text','Maximum Frequency','BackgroundColor',app.bg);
            app.EMaxF = uieditfield(app.PPeriod,'text','Value',num2str(app.meta.fmax_data,'%.4f'));
            app.LSlices = uilabel(app.PPeriod,'Text','Number of slices','BackgroundColor',app.bg);
            app.ESlices = uieditfield(app.PPeriod,'text','Value','1');
            app.CRed = uicheckbox(app.PPeriod,'Text','Remove red noise model','FontColor',app.blue, ...
                'ValueChangedFcn',@(s,e)onRedToggle());
            app.DRed = uidropdown(app.PPeriod,'Items',{'classic AR1 (f-fred)','classic AR1 (f/fred-1)','robust AR1 (f-fred)'}, ...
                'Enable','off');

            app.PSed = uipanel(app.UIFigure,'Title','Test sedimentation rate','BackgroundColor',app.bg);
            app.LSedMin = uilabel(app.PSed,'Text','Minimum','FontColor',app.blue,'BackgroundColor',app.bg);
            app.ESedMin = uieditfield(app.PSed,'text','Value',num2str(app.sedmin),'ValueChangedFcn',@(s,e)onSedEdited());
            app.LSedMax = uilabel(app.PSed,'Text','maximum','FontColor',app.blue,'BackgroundColor',app.bg);
            app.ESedMax = uieditfield(app.PSed,'text','Value',num2str(app.sedmax),'ValueChangedFcn',@(s,e)onSedEdited());
            app.LSedStep = uilabel(app.PSed,'Text','step','FontColor',app.blue,'BackgroundColor',app.bg);
            app.ESedStep = uieditfield(app.PSed,'text','Value',num2str(app.sedstep),'ValueChangedFcn',@(s,e)onSedEdited());
            app.LSedUnit = uilabel(app.PSed,'Text','cm/kyr','FontColor',app.blue,'BackgroundColor',app.bg);
            app.LSedInfo = uilabel(app.PSed,'Text','','FontAngle','italic','BackgroundColor',app.bg);

            app.PTarget = uipanel(app.UIFigure,'Title','Target: Astronomical cycles','BackgroundColor',app.bg);
            app.LAge = uilabel(app.PTarget,'Text','Middle age of data','FontColor',app.blue,'FontWeight','bold','BackgroundColor',app.bg);
            app.EAge = uieditfield(app.PTarget,'text','Value','0','ValueChangedFcn',@(s,e)onAgeEdited());
            app.LMa = uilabel(app.PTarget,'Text','Ma','FontColor',app.blue,'FontWeight','bold','BackgroundColor',app.bg);
            app.LMaxFreq = uilabel(app.PTarget,'Text','Max frequency','BackgroundColor',app.bg);
            app.EF2 = uieditfield(app.PTarget,'text','Value','0.06');
            app.LUnitFreq = uilabel(app.PTarget,'Text','1/kyr','BackgroundColor',app.bg);
            app.BGOrbit = uibuttongroup(app.PTarget,'BackgroundColor',app.bg,'BorderType','none','SelectionChangedFcn',@(s,e)onOrbitChanged());
            app.RBerger = uiradiobutton(app.BGOrbit,'Text','Berger89 solution');
            app.RLaskar = uiradiobutton(app.BGOrbit,'Text','Laskar04 Solution','Value',true);
            app.RUser = uiradiobutton(app.BGOrbit,'Text','User-defined period');
            app.LOrbit1 = uilabel(app.BGOrbit,'Text',orbitString(app.orbit7),'BackgroundColor',app.bg);
            app.LOrbit2 = uilabel(app.BGOrbit,'Text',orbitString(app.orbit7),'BackgroundColor',app.bg);
            app.EOrbitUser = uieditfield(app.BGOrbit,'text','Value',orbitString(app.orbit7),'Enable','off');
            app.BWaltham = uibutton(app.BGOrbit,'push','Text','?Waltham15','ButtonPushedFcn',@(s,e)onWaltham());

            app.PCorr = uipanel(app.UIFigure,'Title','Correlation method','BackgroundColor',app.bg);
            app.BGCorr = uibuttongroup(app.PCorr,'BackgroundColor',app.bg,'BorderType','none','SelectionChangedFcn',@(s,e)onCorrChanged());
            app.RSpearman = uiradiobutton(app.BGCorr,'Text','Spearman');
            app.RPearson = uiradiobutton(app.BGCorr,'Text','Pearson','FontWeight','bold','Value',true);

            app.PMC = uipanel(app.UIFigure,'Title','Monte Carlo','BackgroundColor',app.bg);
            app.ENsim = uieditfield(app.PMC,'text','Value',num2str(app.nsim));
            app.LTimes = uilabel(app.PMC,'Text','times','BackgroundColor',app.bg);

            app.PSlide = uipanel(app.UIFigure,'Title','Sliding Window','BackgroundColor',app.bg);
            app.LSize = uilabel(app.PSlide,'Text','Size','BackgroundColor',app.bg);
            app.ESize = uieditfield(app.PSlide,'text','Value',num2str(app.window,'%.4f'),'FontColor',app.blue,'FontWeight','bold');
            app.LSizeUnit = uilabel(app.PSlide,'Text',app.meta.unit,'BackgroundColor',app.bg);
            app.LStep = uilabel(app.PSlide,'Text','Step','BackgroundColor',app.bg);
            app.EStep = uieditfield(app.PSlide,'text','Value',num2str(app.step,'%.4f'));
            app.LStepUnit = uilabel(app.PSlide,'Text',app.meta.unit,'BackgroundColor',app.bg);

            app.BPlotE = uibutton(app.UIFigure,'push','Text','eCOCO plot','Enable','off', ...
                'ButtonPushedFcn',@(s,e)onECOCOPlot());
            app.BTrack = uibutton(app.UIFigure,'push','Text','Track sed. rates','Enable','off', ...
                'ButtonPushedFcn',@(s,e)onTrack());
            app.BRun = uibutton(app.UIFigure,'push','Text','OK','BackgroundColor',app.blue,'FontColor','white','FontWeight','bold', ...
                'ButtonPushedFcn',@(s,e)onRun());
        end

        function onResize()
            app = getappdata(app.UIFigure,'ECOCO_APP');
            if isempty(app), return; end
            w = app.UIFigure.Position(3); h = app.UIFigure.Position(4);
            if w < 1280 || h < 1220
                app.UIFigure.Position(3:4) = [max(w,1280), max(h,1220)];
                w = app.UIFigure.Position(3); h = app.UIFigure.Position(4);
            end
            m = 18;
            gap = 12;

            hMethod = 92;
            hData = 112;
            hPeriod = 114;
            hSed = 156;
            hTarget = 214;
            hCorr = 84;
            hBottom = 138;

            y = m + 10; % bottom anchor

            app.PMC.Position = [m y 190 hBottom];
            app.ENsim.Position = [20 66 120 34];
            app.LTimes.Position = [90 32 70 26];

            app.PSlide.Position = [230 y 320 hBottom];
            app.LSize.Position = [16 86 70 28];
            app.ESize.Position = [90 88 120 30];
            app.LSizeUnit.Position = [214 86 90 28];
            app.LStep.Position = [16 42 70 28];
            app.EStep.Position = [90 44 120 30];
            app.LStepUnit.Position = [214 42 90 28];

            app.BPlotE.Position = [570 y+76 220 52];
            app.BTrack.Position = [570 y+16 220 52];
            app.BRun.Position = [810 y+16 100 112];

            y = y + hBottom + gap;
            app.PCorr.Position = [m y w-2*m hCorr];
            app.BGCorr.Position = [10 4 app.PCorr.Position(3)-20 56];
            app.RSpearman.Position = [20 6 140 28];
            app.RPearson.Position = [260 6 140 28];

            y = y + hCorr + gap;
            app.PTarget.Position = [m y w-2*m hTarget];
            app.LAge.Position = [20 160 180 28];
            app.EAge.Position = [300 162 100 30];
            app.LMa.Position = [410 160 40 28];
            app.LMaxFreq.Position = [560 160 120 28];
            app.EF2.Position = [700 162 110 30];
            app.LUnitFreq.Position = [820 160 60 28];
            app.BGOrbit.Position = [12 10 app.PTarget.Position(3)-24 150];
            app.RBerger.Position = [10 96 180 28];
            app.RLaskar.Position = [10 62 180 28];
            app.RUser.Position = [10 24 200 28];
            app.LOrbit1.Position = [300 96 360 28];
            app.LOrbit2.Position = [300 62 360 28];
            app.EOrbitUser.Position = [300 24 460 30];
            app.BWaltham.Position = [780 24 130 30];

            y = y + hTarget + gap;
            app.PSed.Position = [m y w-2*m hSed];
            app.LSedMin.Position = [40 92 110 28];
            app.ESedMin.Position = [170 94 100 30];
            app.LSedMax.Position = [310 92 110 28];
            app.ESedMax.Position = [440 94 100 30];
            app.LSedStep.Position = [580 92 80 28];
            app.ESedStep.Position = [650 94 80 30];
            app.LSedUnit.Position = [760 92 100 28];
            app.LSedInfo.Position = [110 36 w-300 30];

            y = y + hSed + gap;
            app.PPeriod.Position = [m y w-2*m hPeriod];
            app.CShowPeriod.Position = [20 48 130 28];
            app.LMaxF.Position = [210 38 120 48];
            app.EMaxF.Position = [360 46 90 30];
            app.LSlices.Position = [480 38 120 48];
            app.ESlices.Position = [620 46 70 30];
            app.CRed.Position = [700 72 260 28];
            app.DRed.Position = [700 16 280 30];

            y = y + hPeriod + gap;
            app.PData.Position = [m y w-2*m hData];
            app.LData.Position = [20 56 80 28];
            app.LDataName.Position = [120 56 520 28];
            app.C0Pad.Position = [20 22 110 28];
            app.EPad.Position = [200 24 100 30];
            app.CPadEdge.Position = [330 22 160 28];
            app.DPadEdge.Position = [500 24 180 30];
            app.CFlipY.Position = [700 22 170 28];

            y = y + hData + gap;
            app.PMethod.Position = [m y 0.46*w hMethod];
            app.BGMethod.Position = [8 4 app.PMethod.Position(3)-16 app.PMethod.Position(4)-28];
            app.RCOCO.Position = [40 8 180 28];
            app.RECOCO.Position = [220 8 180 28];

            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function loadDefaultsToUI()
            app.EOrbitUser.Value = orbitString(app.orbit7);
            app.LOrbit1.Text = orbitString(app.orbit7);
            app.LOrbit2.Text = orbitString(app.orbit7);
        end

        function onPadToggle()
            tf = app.C0Pad.Value;
            app.EPad.Enable = onoff(tf);
        end

        function onRedToggle()
            if app.CRed.Value
                app.DRed.Enable = 'on';
            else
                app.DRed.Enable = 'off';
            end
        end

        function onModeChanged()
            app.mode = 1 + double(app.RECOCO.Value);
            isEco = app.mode == 2;
            app.CPadEdge.Visible = onoff(isEco);
            app.DPadEdge.Visible = onoff(isEco);
            app.CFlipY.Visible = onoff(isEco);
            app.PSlide.Visible = onoff(isEco);
            app.BPlotE.Visible = onoff(isEco);
            app.BTrack.Visible = onoff(isEco);
            app.ESlices.Enable = onoff(~isEco);
            setappdata(app.UIFigure,'ECOCO_APP',app);
            onResize();
        end

        function onCorrChanged()
            app.corrmethod = 1;
            if app.RSpearman.Value
                app.corrmethod = 2;
            end
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function onOrbitChanged()
            app.EOrbitUser.Enable = 'off';
            if app.RUser.Value
                app.EOrbitUser.Enable = 'on';
                app.orbit7 = str2num(app.EOrbitUser.Value); %#ok<ST2NM>
                if isempty(app.orbit7)
                    app.orbit7 = [405 125 95 41 22.43 23.75 19.18];
                end
            elseif app.RBerger.Value
                age = str2double(app.EAge.Value);
                if ~isfinite(age), age = 0; end
                if age > 0
                    app.orbit7 = getBerger89Period(age);
                else
                    app.orbit7 = [405 125 95 41 22.43 23.75 19.18];
                end
            else
                age = str2double(app.EAge.Value);
                if ~isfinite(age), age = 0; end
                obl = 41 - 0.0332 * age;
                p1 = 22.43 - 0.0108 * age;
                p2 = 23.75 - 0.0121 * age;
                p3 = 19.18 - 0.0079 * age;
                app.orbit7 = [405 125 95 obl p2 p1 p3];
            end
            app.LOrbit1.Text = orbitString(app.orbit7);
            app.LOrbit2.Text = orbitString(app.orbit7);
            if app.RUser.Value
                app.EOrbitUser.Value = orbitString(app.orbit7);
            end
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function onAgeEdited()
            onOrbitChanged();
        end

        function onSedEdited()
            app.sedmin = toNum(app.ESedMin.Value, app.sedmin);
            app.sedmax = toNum(app.ESedMax.Value, app.sedmax);
            app.sedstep = max(eps,toNum(app.ESedStep.Value, app.sedstep));
            app.ESedMin.Value = num2str(app.sedmin);
            app.ESedMax.Value = num2str(app.sedmax);
            app.ESedStep.Value = num2str(app.sedstep);
            refreshSedInfo();
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function refreshSedInfo()
            sr = app.sedmin:app.sedstep:app.sedmax;
            if numel(sr) < 3
                app.LSedInfo.Text = 'No valid test sed. rates.';
                return;
            end
            app.LSedInfo.Text = sprintf('%d test sed. rates: %.3f, %.3f, %.3f, ..., %.3f cm/kyr', ...
                numel(sr), sr(1), sr(2), sr(3), sr(end));
        end

        function onRun()
            try
                dat = app.dataRaw;
                if isempty(dat) || size(dat,1) < 20
                    uialert(app.UIFigure,'Current data is empty.','eCOCO');
                    return;
                end

                app.pad = max(0,round(toNum(app.EPad.Value,app.pad)));
                app.nsim = max(10,round(toNum(app.ENsim.Value,app.nsim)));
                app.slices = max(1,round(toNum(app.ESlices.Value,1)));
                app.f2 = max(0,toNum(app.EF2.Value,app.f2));
                app.window = max(eps,toNum(app.ESize.Value,app.window));
                app.step = max(eps,toNum(app.EStep.Value,app.step));
                app.sedmin = toNum(app.ESedMin.Value, app.sedmin);
                app.sedmax = toNum(app.ESedMax.Value, app.sedmax);
                app.sedstep = max(eps,toNum(app.ESedStep.Value, app.sedstep));
                app.age = toNum(app.EAge.Value, app.age);
                app.orbit7 = parseOrbit();
                app.red = redCode();

                srm = mean(diff(dat(:,1)));
                npts = size(dat,1);
                t1 = 1000 * app.age;
                target = buildTarget(app.orbit7,t1,app.f1,app.f2,app.pad);

                sr1 = app.sedmin; sr2 = app.sedmax; srstep = app.sedstep;
                adjust = app.adjust; nsim = app.nsim; red = app.red; plotn = 1;

                if app.mode == 1
                    method = iff(app.corrmethod==1,'Pearson','Spearman');
                    h = uiprogressdlg(app.UIFigure,'Title','COCO','Message','Running ...','Indeterminate','on');
                    [corrCI,corr_h0,~] = corrcoefslices_rank(dat,target,app.orbit7,srm,app.pad,sr1,sr2,srstep,adjust,red,nsim,plotn,app.slices,method);
                    close(h);
                    app.run.corrCI = corrCI;
                    app.run.corr_h0 = corr_h0;
                    app.run.ready = true;
                    saveCOCOOutputs(corrCI,corr_h0);
                else
                    stepN = max(1,round(app.step/srm));
                    dat2 = dat;
                    if app.CPadEdge.Value
                        dat2 = zeropad2(dat2,app.window,app.padtype);
                    end
                    h = uiprogressdlg(app.UIFigure,'Title','eCOCO','Message','Running ...','Indeterminate','on');
                    [prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,~] = ...
                        ecoco(dat2,target,app.orbit7,app.window,srm,stepN,0,red,app.pad,sr1,sr2,srstep,nsim,adjust,1,plotn);
                    close(h);

                    app.run.prt_sr = prt_sr;
                    app.run.out_depth = out_depth;
                    app.run.out_ecc = out_ecc;
                    app.run.out_ep = out_ep;
                    app.run.out_eci = out_eci;
                    app.run.out_ecoco = out_ecoco;
                    app.run.out_ecocorb = out_ecocorb;
                    app.run.out_norbit = out_norbit;
                    app.run.ready = true;

                    app.BPlotE.Enable = 'on';
                    app.BTrack.Enable = 'on';

                    assignin('base','prt_sr',prt_sr);
                    assignin('base','out_depth',out_depth);
                    assignin('base','out_ecc',out_ecc);
                    assignin('base','out_ep',out_ep);
                    assignin('base','out_eci',out_eci);
                    assignin('base','out_ecoco',out_ecoco);
                    assignin('base','out_ecocorb',out_ecocorb);
                    assignin('base','out_norbit',out_norbit);
                    saveECOCOOutputs(prt_sr,out_depth,out_ecc,out_eci,out_norbit,out_ecoco);
                end

                refreshMainListbox(ctx);
                setappdata(app.UIFigure,'ECOCO_APP',app);
            catch ME
                uialert(app.UIFigure,ME.message,'eCOCO error');
            end
        end

        function onECOCOPlot()
            if ~app.run.ready || isempty(app.run.prt_sr)
                return
            end
            a = inputdlg({'Plot: 1=one fig; 2=multi-figs; 3=3D; reverse Y use negative'},'Plot eCOCO',1,{'1'});
            if isempty(a), return; end
            plotn = str2double(a{1});
            if ~isfinite(plotn), plotn = 1; end
            ecocoplot(app.run.prt_sr,app.run.out_depth,app.run.out_ecc,app.run.out_ep, ...
                app.run.out_eci,app.run.out_ecoco,app.run.out_ecocorb,app.run.out_norbit,plotn);
        end

        function onTrack()
            if ~app.run.ready || isempty(app.run.out_ecc)
                return
            end
            prm = {'How many peaks each window?','Threshold H0 significant level', ...
                'Threshold correlation coefficient','Threshold number of orbital parameters', ...
                'Threshold sed. rate searching radius','How many intervals to cut the series?', ...
                'Plot? 1=Yes, 0=No','Optional: sed.rate from','Optional: sed.rate to'};
            answ = inputdlg(prm,'Track optimal sedimentation rates',1, ...
                {'3','5','0.3','4','2','3','1',num2str(app.sedmin),num2str(app.sedmax)});
            if isempty(answ), return; end

            n = str2double(answ{1});
            ci = str2double(answ{2});
            corrcf = str2double(answ{3});
            sh_norb = str2double(answ{4});
            srsh = str2double(answ{5});
            srslice = str2double(answ{6});
            plotn = str2double(answ{7});
            sr1 = str2double(answ{8});
            sr2 = str2double(answ{9});

            ecc = app.run.out_ecc;
            eci = app.run.out_eci;
            norbit = app.run.out_norbit;
            ec = app.run.out_ecoco;
            [Y] = ebrief(ecc,2,-2);
            [~,locatcc] = eccpeaks(Y,ecc,eci,norbit,corrcf,ci,sh_norb,n,1,NaN);
            [~,~,srn_best,~] = ecocotrack(locatcc,ecc,eci,ec,norbit,app.run.out_depth,sr1,sr2,app.sedstep, ...
                srsh,srslice,corrcf,ci,plotn,sh_norb);

            srn_map(:,2) = (sr1 + app.sedstep*(srn_best(1,:)-1))';
            srn_map(:,1) = app.run.out_depth;
            CDac_pwd;
            [~,dn,~] = fileparts(app.meta.filename);
            out = [dn,'-SR.txt'];
            dlmwrite(out,srn_map,'delimiter',' ','precision',9);
            uialert(app.UIFigure,['Saved: ',out],'Track');
            refreshMainListbox(ctx);
        end

        function onWaltham()
            msg = sprintf('Waltham, D. (2015). Milankovitch period uncertainties and their impact on cyclostratigraphy. JSR.');
            uialert(app.UIFigure,msg,'Reference');
        end

        function saveCOCOOutputs(corrCI,corr_h0)
            [~,dn,~] = fileparts(app.meta.filename);
            CDac_pwd;
            data_COCOCI = [corrCI(:,1:2),corr_h0(:,1:2)];
            nm = uniqueName([dn,'-COCO-data.txt']);
            dlmwrite(nm,data_COCOCI,'delimiter',',','precision',9);
        end

        function saveECOCOOutputs(prt_sr,out_depth,out_ecc,out_eci,out_norbit,out_ecoco)
            [~,dn,~] = fileparts(app.meta.filename);
            CDac_pwd;
            nm = uniqueName([dn,'-ECOCO.data.xlsx']);
            writematrix(prt_sr,nm,'Sheet','Sed.Rate');
            writematrix(out_depth,nm,'Sheet','Depth');
            writematrix(out_ecc,nm,'Sheet','COCO');
            writematrix(out_eci,nm,'Sheet','Conf.Int.');
            writematrix(out_norbit,nm,'Sheet','#Orbits');
            writematrix(out_ecoco,nm,'Sheet','COCOxH0');
        end

        function s = uniqueName(nm)
            s = nm;
            if ~exist(s,'file'), return; end
            [p,n,e] = fileparts(nm);
            for k = 1:999
                s = fullfile(p,sprintf('%s-%d%s',n,k,e));
                if ~exist(s,'file'), return; end
            end
        end

        function out = parseOrbit()
            if app.RUser.Value
                out = str2num(app.EOrbitUser.Value); %#ok<ST2NM>
                if isempty(out)
                    out = [405 125 95 41 22.43 23.75 19.18];
                end
            elseif app.RBerger.Value
                out = getBerger89Period(app.age);
            else
                age = app.age;
                out = [405 125 95, 41 - 0.0332*age, 23.75 - 0.0121*age, 22.43 - 0.0108*age, 19.18 - 0.0079*age];
            end
            out = out(:)';
        end

        function r = redCode()
            if ~app.CRed.Value
                r = 0;
                return
            end
            switch app.DRed.Value
                case 'classic AR1 (f-fred)'
                    r = 1;
                case 'classic AR1 (f/fred-1)'
                    r = 2;
                otherwise
                    r = 3;
            end
        end

        function v = toNum(s,def)
            v = str2double(s);
            if ~isfinite(v)
                v = def;
            end
        end

        function onEditNum(ed,def)
            v = str2double(ed.Value);
            if ~isfinite(v)
                ed.Value = num2str(def);
            end
        end
    end
end

function [raw, dat, meta] = prepData(ctx)
raw = getfielddef(ctx,'current_data',[]);
if isempty(raw)
    raw = [0 0; 1 1; 2 0.5; 3 1.5];
end
raw = raw(:,1:min(2,size(raw,2)));
raw = raw(all(isfinite(raw),2),:);
raw = sortrows(raw,1);
if exist('findduplicate','file') == 2
    raw = findduplicate(raw);
else
    [~,ia] = unique(raw(:,1),'stable');
    raw = raw(ia,:);
end

dat = raw;
meta = struct();
meta.unit = char(getfielddef(ctx,'unit','m'));
meta.unit_type = getfielddef(ctx,'unit_type',0);
meta.filename = char(getfielddef(ctx,'data_name','data.txt'));
meta.dat_name = char(getfielddef(ctx,'dat_name',meta.filename));

if size(dat,1) < 3
    dat = [0 0;1 1;2 0.5;3 1.5];
end

dt = median(diff(dat(:,1)));
if ~isfinite(dt) || dt <= 0
    dt = 1;
end
meta.dt = dt;
meta.fmax_data = 1/(2*dt);
end

function pad = defaultPad(npts)
if npts <= 2500
    pad = 5000;
elseif npts <= 5000
    pad = 10000;
else
    pad = fix(npts/5000) * 5000 + 5000;
end
end

function [sedmin, sedmax, sedstep, fh] = defaultSedRange(app)
sedmin = 0;
sedmax = 100;
sedstep = 0.1;
fh = 0.065;
dtr = app.meta.dt;
npts = size(app.data,1);
fnyq = sedmin/(2*dtr);
if fh > fnyq
    sedmin = 2*dtr*fh;
end
fray = sedmax/(npts*dtr);
flow = 1/max(app.orbit7);
if fray > flow
    sedmax = npts*dtr*flow;
end
if (sedmax-sedmin)/sedstep > 300
    sedstep = (sedmax-sedmin)/300;
end
end

function target = buildTarget(orbit7,t1,f1,f2,pad)
p1 = 1; p2 = .6; p3 = .5;
target = period2spectrum(orbit7,t1-1000,t1+1000,1,f1,f2,1,pad);
if t1 > 249000
    target = period2spectrum(orbit7,t1-1000,t1+1000,1,f1,f2,1,pad);
else
    if t1 <= 248000 && t1 > 1000
        target = gentarget(4,t1-1000,t1+1000,f1,f2,p1,p2,p3,pad,1);
    elseif t1 > 248000
        target = gentarget(4,247000,249000,f1,f2,p1,p2,p3,pad,1);
    else
        target = gentarget(4,1,2000,f1,f2,p1,p2,p3,pad,1);
    end
end
end

function s = orbitString(v)
s = strtrim(sprintf('%g ',v));
end

function s = onoff(tf)
if tf, s = 'on'; else, s = 'off'; end
end

function out = iff(cond,a,b)
if cond, out = a; else, out = b; end
end

function p = figurePos(ctx)
monzoom = getfielddef(ctx,'MonZoom',1);
sc = get(groot,'ScreenSize');
p = [0.38*sc(3), 0.08*sc(4), 0.46*sc(3), 0.84*sc(4)] .* monzoom;
p = round(p);
if p(3) < 1280, p(3) = 1280; end
if p(4) < 1220, p(4) = 1220; end
end

function refreshMainListbox(ctx)
listbox = getfielddef(ctx,'listbox_acmain',[]);
editdir = getfielddef(ctx,'edit_acfigmain_dir',[]);
if isempty(listbox) || ~isgraphics(listbox)
    return
end
try
    d = dir;
    n = {d.name};
    set(listbox,'String',n,'Value',1);
    if ~isempty(editdir) && isgraphics(editdir)
        set(editdir,'String',pwd);
    end
    if exist('refreshcolor','file') == 2
        refreshcolor;
    end
catch
end
end

function v = getfielddef(s,name,def)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = def;
end
end
