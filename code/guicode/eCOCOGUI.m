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
        app.fmaxdata = app.meta.fmax_data;
        app.main_unit_selection = getfielddef(ctx,'main_unit_selection',0);
        app.mode = 2; % 1=COCO, 2=eCOCO
        % Public default: the coherent nine-term, method-B bidirectional
        % held-out engine formerly exposed as cvCOCO9B.
        app.cocoTargetMode = 'cv9b';
        app.cvBatchSize = 100;
        app.cvSeed = 1;
        app.adaptiveSeed = 1;
        % Retain the numeric field for workspace/backward compatibility,
        % but its public meaning is now the selected eCOCO algorithm.
        app.ecocoCalcMode = 1; % 1=Adaptive eCOCO, 2=Cross-fitted eCOCO
        app.anchorFraction = 0.5;
        app.corrmethod = 1; % 1 Pearson, 2 Spearman
        app.red = 0; % 0 no
        app.time_0pad = 1;
        app.padtype = 1;
        
        app.orbit9 = [405.6912, 130.6979, 123.8532, 98.8517, 94.8856, 40.9897, 23.6820, 22.3758, 18.9519];
        app.age = 0;
        app.f1 = 0;
        app.f2 = 1.2/min(app.orbit9);
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
        
        app.run = emptyRunState();

        app.UIFigure = uifigure('Name','Acycle: (Evolutionary) Correlation Coefficient version 2 / (e)COCO v2', ...
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
            app.LCOCOMethod = uilabel(app.PMethod,'Text','COCO method','FontColor',app.blue,'BackgroundColor',app.bg);
            app.DCOCOMethod = uidropdown(app.PMethod, ...
                'Items',{'cvCOCO','Adaptive COCO','Fixed-target COCO'}, ...
                'Value','cvCOCO','Enable','off', ...
                'Tooltip',['cvCOCO uses bidirectional held-out validation; ', ...
                'Adaptive and Fixed-target COCO use the full record.'], ...
                'ValueChangedFcn',@(s,e)onCocoMethodChanged());
            app.BGEcoCalc = uibuttongroup(app.PMethod,'BackgroundColor',app.bg,'BorderType','none', ...
                'SelectionChangedFcn',@(s,e)onEcoCalcChanged());
            % RFast/RAccurate field names are retained so saved app-state
            % and older callbacks do not fail; the visible choices now
            % select scientifically distinct sliding algorithms.
            app.RFast = uiradiobutton(app.BGEcoCalc, ...
                'Text','Adaptive eCOCO','Value',true, ...
                'Tooltip','Per-window Adaptive COCO method-B target.');
            app.RAccurate = uiradiobutton(app.BGEcoCalc, ...
                'Text','Cross-fitted eCOCO','Value',false, ...
                'Tooltip',['Frozen method-B targets updated at the selected ', ...
                'fraction of the sliding-window width.']);

            app.PData = uipanel(app.UIFigure,'Title','Data','BackgroundColor',app.bg);
            app.LData = uilabel(app.PData,'Text','Data','BackgroundColor',app.bg);
            app.LDataName = uilabel(app.PData,'Text',app.meta.dat_name,'BackgroundColor',app.bg);
            app.C0Pad = uicheckbox(app.PData,'Text','0 padding','Value',true,'ValueChangedFcn',@(s,e)onPadToggle());
            app.EPad = uieditfield(app.PData,'text','Value',num2str(app.pad),'ValueChangedFcn',@(s,e)onNumericSettingEdited(app.EPad,app.pad));
            app.CPadEdge = uicheckbox(app.PData,'Text','0 padding edge','Value',true, ...
                'ValueChangedFcn',@(s,e)onPadEdgeToggle());
            app.DPadEdge = uidropdown(app.PData,'Items',{'zero','mirror','mean','random'},'Value','zero', ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.CFlipY = uicheckbox(app.PData,'Text','Flip Depth (y axis)','Value',true, ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());

            app.PPeriod = uipanel(app.UIFigure,'Title','Periodogram of Data','BackgroundColor',app.bg);
            app.CShowPeriod = uicheckbox(app.PPeriod,'Text','Show period.','Value',true, ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.LMaxF = uilabel(app.PPeriod,'Text','Maximum Frequency (cycle/m)','BackgroundColor',app.bg);
            app.EMaxF = uieditfield(app.PPeriod,'text','Value',num2str(app.meta.fmax_data,'%.4f'), ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.LSlices = uilabel(app.PPeriod,'Text','Number of slices','BackgroundColor',app.bg);
            app.ESlices = uieditfield(app.PPeriod,'text','Value','1', ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.CRed = uicheckbox(app.PPeriod,'Text','Remove red noise model','FontColor',app.blue, ...
                'ValueChangedFcn',@(s,e)onRedToggle());
            app.DRed = uidropdown(app.PPeriod,'Items',{'Classic AR1','Robust AR1','Smoothed Window'}, ...
                'Enable','off','ValueChangedFcn',@(s,e)markSettingsChanged());

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
            app.EF2 = uieditfield(app.PTarget,'text', ...
                'Value',num2str(app.f2,'%.6g'), ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.LUnitFreq = uilabel(app.PTarget,'Text','1/kyr','BackgroundColor',app.bg);
            app.BGOrbit = uibuttongroup(app.PTarget,'BackgroundColor',app.bg,'BorderType','none','SelectionChangedFcn',@(s,e)onOrbitChanged());
            app.RLaskar = uiradiobutton(app.BGOrbit,'Text','Farhat+2022','Value',true);
            app.RUser = uiradiobutton(app.BGOrbit,'Text','User-defined period');
            app.LOrbit2 = uilabel(app.BGOrbit,'Text',orbitString(app.orbit9),'BackgroundColor',app.bg);
            app.EOrbitUser = uieditfield(app.BGOrbit,'text','Value',orbitString(app.orbit9),'Enable','off', ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.BWaltham = uibutton(app.BGOrbit,'push','Text','?Waltham15','ButtonPushedFcn',@(s,e)onWaltham());

            app.PCorr = uipanel(app.UIFigure,'Title','Correlation method','BackgroundColor',app.bg);
            app.BGCorr = uibuttongroup(app.PCorr,'BackgroundColor',app.bg,'BorderType','none','SelectionChangedFcn',@(s,e)onCorrChanged());
            app.RSpearman = uiradiobutton(app.BGCorr,'Text','Spearman','Value',false);
            app.RPearson = uiradiobutton(app.BGCorr,'Text','Pearson','FontWeight','bold','Value',true);

            app.PMC = uipanel(app.UIFigure,'Title','Monte Carlo','BackgroundColor',app.bg);
            app.ENsim = uieditfield(app.PMC,'text','Value',num2str(app.nsim), ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.LTimes = uilabel(app.PMC,'Text','times','BackgroundColor',app.bg);

            app.PSlide = uipanel(app.UIFigure,'Title','Sliding Window','BackgroundColor',app.bg);
            app.LSize = uilabel(app.PSlide,'Text','Size','BackgroundColor',app.bg);
            app.ESize = uieditfield(app.PSlide,'text','Value',num2str(app.window,'%.4f'),'FontColor',app.blue,'FontWeight','bold', ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.LSizeUnit = uilabel(app.PSlide,'Text',app.meta.unit,'BackgroundColor',app.bg);
            app.LStep = uilabel(app.PSlide,'Text','Step','BackgroundColor',app.bg);
            app.EStep = uieditfield(app.PSlide,'text','Value',num2str(app.step,'%.4f'), ...
                'ValueChangedFcn',@(s,e)markSettingsChanged());
            app.LStepUnit = uilabel(app.PSlide,'Text',app.meta.unit,'BackgroundColor',app.bg);
            app.LTargetUpdate = uilabel(app.PSlide,'Text','Target update', ...
                'BackgroundColor',app.bg);
            app.DTargetUpdate = uidropdown(app.PSlide, ...
                'Items',{'0.25 W','0.5 W','1.0 W','2.0 W'}, ...
                'ItemsData',[0.25 0.5 1.0 2.0], ...
                'Value',0.5,'Enable','off', ...
                'Tooltip',['Cross-fitted eCOCO target-anchor spacing as a ', ...
                'fraction of the sliding-window width.'], ...
                'ValueChangedFcn',@(s,e)onEcoTargetUpdateChanged());

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
            if w < 1024 || h < 1010
                app.UIFigure.Position(3:4) = [max(w,1024), max(h,1010)];
                w = app.UIFigure.Position(3);
            end
            m = 18;
            gap = 12;

            hMethod = 78;
            hData = 112;
            hPeriod = 114;
            hSed = 126;
            hTarget = 184;
            hCorr = 84;
            hBottom = 172;

            y = m + 10; % bottom anchor

            app.PMC.Position = [m y 190 hBottom];
            app.ENsim.Position = [20 66 120 34];
            app.LTimes.Position = [90 32 70 26];

            app.PSlide.Position = [230 y 320 hBottom];
            app.LSize.Position = [16 104 70 28];
            app.ESize.Position = [90 106 120 30];
            app.LSizeUnit.Position = [214 104 90 28];
            app.LStep.Position = [16 64 70 28];
            app.EStep.Position = [90 66 120 30];
            app.LStepUnit.Position = [214 64 90 28];
            app.LTargetUpdate.Position = [16 22 105 28];
            app.DTargetUpdate.Position = [130 24 170 30];

            app.BPlotE.Position = [570 y+110 220 52];
            app.BTrack.Position = [570 y+50 220 52];
            app.BRun.Position = [810 y+16 100 146];

            y = y + hBottom + gap;
            app.PCorr.Position = [m y w-2*m hCorr];
            app.BGCorr.Position = [10 4 app.PCorr.Position(3)-20 56];
            app.RSpearman.Position = [20 16 140 28];
            app.RPearson.Position = [260 16 140 28];

            y = y + hCorr + gap;
            app.PTarget.Position = [m y w-2*m hTarget];
            app.LAge.Position =     [20 120 180 28];
            app.EAge.Position =     [300 122 100 30];
            app.LMa.Position =      [410 120 40 28];
            app.LMaxFreq.Position = [560 120 120 28];
            app.EF2.Position =      [700 122 110 30];
            app.LUnitFreq.Position =[820 120 60 28];
            
            app.BGOrbit.Position = [12 10 app.PTarget.Position(3)-24 90];
            app.RLaskar.Position = [10  62 180 28];
            app.LOrbit2.Position = [300 62 460 28];
            app.RUser.Position =      [10 14 200 28];
            app.EOrbitUser.Position = [300 14 460 30];
            app.BWaltham.Position =   [780 14 130 30];

            y = y + hTarget + gap;
            app.PSed.Position = [m y w-2*m hSed];
            app.LSedMin.Position = [40 52 110 28];
            app.ESedMin.Position = [170 54 100 30];
            app.LSedMax.Position = [310 52 110 28];
            app.ESedMax.Position = [440 54 100 30];
            app.LSedStep.Position = [580 52 80 28];
            app.ESedStep.Position = [650 54 80 30];
            app.LSedUnit.Position = [760 52 100 28];
            app.LSedInfo.Position = [110 16 w-300 30];

            y = y + hSed + gap;
            app.PPeriod.Position = [m y w-2*m hPeriod];
            app.CShowPeriod.Position = [20 38 130 28];
            app.LMaxF.Position = [210 28 120 48];
            app.EMaxF.Position = [360 36 90 30];
            app.LSlices.Position = [480 28 120 48];
            app.ESlices.Position = [620 36 70 30];
            
            app.CRed.Position = [700 52 260 28];
            app.DRed.Position = [700 16 280 30];

            y = y + hPeriod + gap;
            app.PData.Position = [m y w-2*m hData];
            app.LData.Position = [20 56 80 28];
            app.LDataName.Position = [120 56 520 28];
            app.C0Pad.Position = [20 12 110 28];
            app.EPad.Position = [200 14 100 30];
            app.CPadEdge.Position = [330 12 160 28];
            app.DPadEdge.Position = [500 14 180 30];
            app.CFlipY.Position = [700 12 170 28];

            y = y + hData + gap;
            app.PMethod.Position = [m y w-2*m hMethod];

            app.BGMethod.Position = [8 15 230 26];
            app.RCOCO.Position =  [10 1 90 24];
            app.RECOCO.Position = [120 1 100 24];
            app.LCOCOMethod.Position = [270 14 105 28];
            app.DCOCOMethod.Position = [380 14 235 30];

            app.BGEcoCalc.Position = [640 2 345 50];
            app.RFast.Position = [8 13 145 24];
            app.RAccurate.Position = [160 13 175 24];

            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function loadDefaultsToUI()
            app.EOrbitUser.Value = orbitString(app.orbit9);
            app.LOrbit2.Text = orbitString(app.orbit9);
            app.DTargetUpdate.Value = app.anchorFraction;
            onPadEdgeToggle();
        end

        function onPadToggle()
            tf = app.C0Pad.Value;
            app.EPad.Enable = onoff(tf);
            markSettingsChanged();
        end

        function onPadEdgeToggle()
            isEco = app.mode == 2;
            isCrossfit = isEco && app.RAccurate.Value;
            if isCrossfit
                % Cross-fitted eCOCO uses the predeclared deterministic
                % half-window zero edge requested by the method.  Do not
                % let mirror/mean/random padding silently change its
                % training and validation records.
                app.CPadEdge.Value = true;
                app.DPadEdge.Value = 'zero';
                app.padtype = 1;
            end
            app.CPadEdge.Enable = onoff(isEco && ~isCrossfit);
            app.DPadEdge.Enable = onoff( ...
                isEco && app.CPadEdge.Value && ~isCrossfit);
            markSettingsChanged();
        end

        function onRedToggle()
            if app.CRed.Value
                app.DRed.Enable = 'on';
            else
                app.DRed.Enable = 'off';
            end
            markSettingsChanged();
        end

        function onModeChanged()
            isEco = app.RECOCO.Value;
            app.mode = 1 + double(isEco);
            updateCocoTargetMode();
            isCv = ~isEco && isCvCocoTargetMode(app.cocoTargetMode);
            app.CPadEdge.Visible = onoff(isEco);
            app.DPadEdge.Visible = onoff(isEco);
            app.CFlipY.Visible = onoff(isEco);
            app.PSlide.Visible = onoff(isEco);
            app.BPlotE.Visible = onoff(isEco);
            app.BTrack.Visible = onoff(isEco);
            app.DCOCOMethod.Enable = onoff(~isEco);
            app.ESlices.Enable = onoff(~isEco && ~isCv);
            app.EMaxF.Enable = onoff(isEco || ~isCv);
            app.RFast.Enable = onoff(isEco);
            app.RAccurate.Enable = onoff(isEco);
            app.DTargetUpdate.Enable = onoff(isEco && app.RAccurate.Value);
            invalidateRunState();
            onPadEdgeToggle();
            setappdata(app.UIFigure,'ECOCO_APP',app);
            onResize();
        end

        function onCocoMethodChanged()
            updateCocoTargetMode();
            isCv = app.mode == 1 && isCvCocoTargetMode(app.cocoTargetMode);
            app.ESlices.Enable = onoff(app.mode == 1 && ~isCv);
            app.EMaxF.Enable = onoff(app.mode == 2 || ~isCv);
            invalidateRunState();
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function updateCocoTargetMode()
            switch app.DCOCOMethod.Value
                case 'cvCOCO'
                    app.cocoTargetMode = 'cv9b';
                case 'Adaptive COCO'
                    app.cocoTargetMode = 'adaptive9b';
                case 'Fixed-target COCO'
                    app.cocoTargetMode = 'fixed9';
                otherwise
                    error('eCOCOGUI:UnknownCOCOMethod', ...
                        'Unknown COCO method: %s.',app.DCOCOMethod.Value);
            end
        end

        function onEcoCalcChanged()
            app.ecocoCalcMode = 1;
            if app.RAccurate.Value
                app.ecocoCalcMode = 2;
                app.DPadEdge.Value = 'zero';
                app.padtype = 1;
            end
            app.DTargetUpdate.Enable = onoff( ...
                app.mode == 2 && app.ecocoCalcMode == 2);
            invalidateRunState();
            onPadEdgeToggle();
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function onEcoTargetUpdateChanged()
            app.anchorFraction = app.DTargetUpdate.Value;
            invalidateRunState();
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function onCorrChanged()
            app.corrmethod = 1;
            if app.RSpearman.Value
                app.corrmethod = 2;
            end
            invalidateRunState();
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function onOrbitChanged()

            app.EOrbitUser.Enable = 'off';

            if app.RUser.Value
                app.EOrbitUser.Enable = 'on';
                candidateOrbit = parseNumericList(app.EOrbitUser.Value);
                if isempty(candidateOrbit) || any(~isfinite(candidateOrbit)) || ...
                        any(candidateOrbit <= 0)
                    markSettingsChanged();
                    uialert(app.UIFigure, ...
                        'User-defined periods must be a positive numeric list.', ...
                        'Invalid astronomical periods');
                    return
                end
                app.orbit9 = candidateOrbit;
            else                
                age = str2double(app.EAge.Value);
                if ~isfinite(age), age = 0; end
                app.age = age;
                orbit9 = calculate_orbit9(age);
                app.orbit9  = orbit9(:,2)/1000;
            end
            
            app.LOrbit2.Text = orbitString(app.orbit9);
            updateF2FromOrbit();

            if app.RUser.Value
                app.EOrbitUser.Value = orbitString(app.orbit9);
            end

            invalidateRunState();
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function onAgeEdited()
            app.age = toNum(app.EAge.Value, app.age);
            onOrbitChanged();
        end

        function updateF2FromOrbit()
            orbit = app.orbit9(isfinite(app.orbit9));
            if isempty(orbit)
                return;
            end
            app.f2 = 1.2 / min(orbit);
            app.EF2.Value = num2str(app.f2,'%.6g');
        end

        function onSedEdited()
            app.sedmin = toNum(app.ESedMin.Value, app.sedmin);
            app.sedmax = toNum(app.ESedMax.Value, app.sedmax);
            candidateStep = toNum(app.ESedStep.Value,app.sedstep);
            if isfinite(candidateStep) && candidateStep > 0
                app.sedstep = candidateStep;
            end
            app.ESedMin.Value = num2str(app.sedmin);
            app.ESedMax.Value = num2str(app.sedmax);
            app.ESedStep.Value = num2str(app.sedstep);
            refreshSedInfo();
            invalidateRunState();
            setappdata(app.UIFigure,'ECOCO_APP',app);
        end

        function refreshSedInfo()
            if ~isfinite(app.sedmin) || ~isfinite(app.sedmax) || ...
                    ~isfinite(app.sedstep) || app.sedstep <= 0 || ...
                    app.sedmax < app.sedmin
                app.LSedInfo.Text = 'No valid test sed. rates.';
                return;
            end
            nRate = floor((app.sedmax-app.sedmin)/app.sedstep)+1;
            if nRate < 2
                app.LSedInfo.Text = 'Fewer than two test sed. rates.';
            elseif nRate == 2
                app.LSedInfo.Text = sprintf( ...
                    '2 test sed. rates: %.3f, %.3f cm/kyr', ...
                    app.sedmin,app.sedmin+app.sedstep);
            elseif nRate > 10000
                app.LSedInfo.Text = sprintf( ...
                    '%d rates is too many; increase the step.',nRate);
            else
                app.LSedInfo.Text = sprintf('%d test sed. rates: %.3f, %.3f, %.3f, ..., %.3f cm/kyr', ...
                    nRate,app.sedmin,app.sedmin+app.sedstep, ...
                    app.sedmin+2*app.sedstep, ...
                    app.sedmin+(nRate-1)*app.sedstep);
            end
        end

        function onRun()
            h = [];
            conclusionReport = [];
            invalidateRunState();
            setappdata(app.UIFigure,'ECOCO_APP',app);
            try
                if ~isfield(app.meta,'depthInMeters') || ~app.meta.depthInMeters
                    error('eCOCOGUI:DepthUnitRequired', ...
                        ['COCO/eCOCO sedimentation rates are defined for depth in metres. ', ...
                         'Select a supported depth unit (m, dm, cm, mm, ft, or km) ', ...
                         'in the Acycle main window before running this analysis.']);
                end
                % Full-record COCO/eCOCO calculations use the uniformly
                % sampled series. Both cvCOCO engines receive the sorted,
                % de-duplicated raw
                % series so its two halves can be interpolated separately.
                dat = app.data;
                if size(app.dataRaw,1) < 20
                    uialert(app.UIFigure, ...
                        ['Fewer than 20 finite, unique observed depth levels ', ...
                         'remain after sorting and de-duplication. Interpolated ', ...
                         'points do not count as independent observations.'], ...
                        'eCOCO');
                    return;
                end
                isCvRun = app.mode == 1 && ...
                    isCvCocoTargetMode(app.cocoTargetMode);
                isLegacyCvRun = isCvRun && ...
                    strcmp(app.cocoTargetMode,'cvlegacy');
                isCv9ARun = isCvRun && strcmp(app.cocoTargetMode,'cv9a');
                % Keep the former internal cv9 token as a compatibility
                % alias for the renamed group-band method, cvCOCO9B.
                isCv9BRun = isCvRun && ...
                    any(strcmp(app.cocoTargetMode,{'cv9b','cv9'}));
                dataToCheck = dat;
                if isCvRun
                    % cvCOCO must split first, then interpolate each half.
                    % Passing the full-series interpolation here would leak
                    % information across the held-out boundary.
                    dataToCheck = app.dataRaw;
                end
                if isempty(dataToCheck) || size(dataToCheck,1) < 20
                    uialert(app.UIFigure, ...
                        'Fewer than 20 valid points remain after preprocessing.', ...
                        'eCOCO');
                    return;
                end

                if app.mode == 1 && ~isCvRun
                    app.slices = requireIntegerScalar( ...
                        app.ESlices.Value,'Number of slices',1,Inf);
                else
                    app.slices = 1;
                end
                if app.C0Pad.Value
                    app.pad = requireIntegerScalar( ...
                        app.EPad.Value,'Periodogram NFFT (Pad)',1,Inf);
                elseif isCvRun
                    % cvcoco interprets zero as one unpadded FFT per half.
                    app.pad = 0;
                elseif app.mode == 1
                    % A common unpadded frequency grid for all slices uses
                    % the longest possible equal-depth slice.
                    app.pad = max(2,ceil(size(dat,1) / max(1,app.slices)));
                else
                    requestedWindow = max(eps,toNum(app.ESize.Value,app.window));
                    windowDt = median(diff(dat(:,1)));
                    app.pad = max(3, ...
                        2*round(requestedWindow/(2*windowDt))+1);
                end
                if isCvRun
                    excelMaximumDataRows = 1048572; % spectrum sheets begin at row 5
                    upperNfft = max(app.pad,size(app.dataRaw,1));
                    upperSpectrumRows = floor(upperNfft/2)+1;
                    if size(app.dataRaw,1) > 1048575 || ...
                            upperSpectrumRows > excelMaximumDataRows
                        error('eCOCOGUI:CVCOCOExcelRowLimit', ...
                            ['The requested cvCOCO input/NFFT can exceed the ', ...
                             'Excel .xlsx row limit used for the mandatory ', ...
                             'audit workbook. Reduce Pad or the input size.']);
                    end
                end
                requestedNsim = requireIntegerScalar( ...
                    app.ENsim.Value,'Monte Carlo iterations',100,1e6);
                app.nsim = requestedNsim;
                app.ENsim.Value = num2str(app.nsim);
                if app.nsim < 1999
                    fprintf(['\n>> COCO Monte Carlo precision note: %d simulations requested.\n', ...
                        '   At least 1999 simulations are recommended for publication-quality inference.\n\n'], ...
                        app.nsim);
                end
                app.f2 = requirePositiveScalar( ...
                    app.EF2.Value,'Maximum target frequency');
                requestedDisplayFrequency = requirePositiveScalar( ...
                    app.EMaxF.Value,'Maximum displayed data frequency');
                app.fmaxdata = min(app.meta.fmax_data,requestedDisplayFrequency);
                if requestedDisplayFrequency > app.meta.fmax_data
                    fprintf(['\n>> Display-frequency adjustment:\n', ...
                        '   Requested maximum frequency : %.12g cycle/m\n', ...
                        '   Data Nyquist frequency      : %.12g cycle/m\n', ...
                        '   Display maximum used        : %.12g cycle/m\n\n'], ...
                        requestedDisplayFrequency,app.meta.fmax_data,app.fmaxdata);
                end
                app.EMaxF.Value = num2str(app.fmaxdata,'%.12g');
                if app.mode == 2
                    app.window = requirePositiveScalar( ...
                        app.ESize.Value,'Sliding-window size');
                    app.step = requirePositiveScalar( ...
                        app.EStep.Value,'Sliding-window step');
                    app.anchorFraction = app.DTargetUpdate.Value;
                end
                app.sedmin = requirePositiveScalar( ...
                    app.ESedMin.Value,'Minimum sedimentation rate');
                app.sedmax = requirePositiveScalar( ...
                    app.ESedMax.Value,'Maximum sedimentation rate');
                app.sedstep = requirePositiveScalar( ...
                    app.ESedStep.Value,'Sedimentation-rate step');
                if app.RUser.Value
                    candidateAge = str2double(app.EAge.Value);
                    if isfinite(candidateAge)
                        app.age = candidateAge;
                    end
                else
                    app.age = requireFiniteScalar(app.EAge.Value,'Middle age');
                end
                app.orbit9 = parseOrbit();

                if ~isfinite(app.sedmin) || app.sedmin <= 0 || ...
                        ~isfinite(app.sedmax) || app.sedmax < app.sedmin || ...
                        ~isfinite(app.sedstep) || app.sedstep <= 0
                    error('eCOCOGUI:InvalidSedimentationRateGrid', ...
                        ['Sedimentation-rate minimum and step must be positive, ', ...
                         'and the maximum must not be smaller than the minimum.']);
                end
                nRate = floor((app.sedmax-app.sedmin)/app.sedstep)+1;
                if nRate < 2 || nRate > 10000
                    error('eCOCOGUI:InvalidSedimentationRateGridSize', ...
                        ['The requested grid contains %d rate(s). Use between ', ...
                         '2 and 10000 pre-specified sedimentation rates.'],nRate);
                end

                if numel(app.orbit9) ~= 9 || any(~isfinite(app.orbit9)) || ...
                        any(app.orbit9 <= 0)
                    error('eCOCOGUI:InvalidOrbitPeriods', ...
                        'Exactly nine finite, positive astronomical periods are required.');
                end
                minimumTargetCutoff = max(1 ./ app.orbit9);
                if ~isfinite(app.f2) || app.f2 < minimumTargetCutoff
                    error('eCOCOGUI:TargetFrequencyTooLow', ...
                        ['Maximum target frequency must be at least %.6g cycle/kyr ', ...
                         'to include the shortest selected astronomical period.'], ...
                        minimumTargetCutoff);
                end
                app.red = redCode();
                app.padtype = selectedPadType();
                assignin('base','main_unit_selection',app.main_unit_selection);

                srm = median(diff(dat(:,1)));
                sr1 = app.sedmin; 
                sr2 = app.sedmax; 
                srstep = app.sedstep;
                adjust = app.adjust; nsim = app.nsim; red = app.red; plotn = 1;
                method = iff(app.corrmethod==1,'Pearson','Spearman');

                if app.mode == 1
                    if isCvRun
                        cvDisplayName = 'cvCOCO';
                        if isLegacyCvRun
                            cvDisplayName = 'cvCOCO Legacy';
                        elseif isCv9ARun
                            cvDisplayName = 'cvCOCO9A';
                        end
                        h = uiprogressdlg(app.UIFigure,'Title',cvDisplayName, ...
                            'Message','Preparing bidirectional validation ...  0.0%', ...
                            'Indeterminate','off','Value',0,'Cancelable','off');
                        if isLegacyCvRun
                            cv = cvcocoLegacy(app.dataRaw,app.orbit9,app.pad, ...
                                sr1,sr2,srstep,red,nsim,method, ...
                                'BatchSize',app.cvBatchSize,'Seed',app.cvSeed, ...
                                'AnalysisName','cvCOCO Legacy', ...
                                'MaxFrequency',app.f2, ...
                                'ProgressFcn',@(fraction,message) ...
                                updateProgressDialog(h,fraction,message));
                            cv.name = 'cvCOCO Legacy';
                            cv.engine = 'legacy coherent nine-term held-out engine';
                            cv.analysisRole = ...
                                'Legacy compatibility analysis; not confirmatory';
                            modeName = 'CVCOCOLEGACY';
                        elseif isCv9ARun
                            cv = cvcoco9A(app.dataRaw,app.orbit9,app.pad, ...
                                sr1,sr2,srstep,red,nsim,method, ...
                                'BatchSize',app.cvBatchSize,'Seed',app.cvSeed, ...
                                'AnalysisName','cvCOCO9A', ...
                                'MaxFrequency',app.f2, ...
                                'ProgressFcn',@(fraction,message) ...
                                updateProgressDialog(h,fraction,message));
                            modeName = 'CVCOCO9A';
                        elseif isCv9BRun
                            cv = cvcoco9B(app.dataRaw,app.orbit9,app.pad, ...
                                sr1,sr2,srstep,red,nsim,method, ...
                                'BatchSize',app.cvBatchSize,'Seed',app.cvSeed, ...
                                'AnalysisName','cvCOCO', ...
                                'MaxFrequency',app.f2, ...
                                'ProgressFcn',@(fraction,message) ...
                                updateProgressDialog(h,fraction,message));
                            % cvCOCO9B remains the callable implementation
                            % name, while cvCOCO is now its public GUI name.
                            cv.name = 'cvCOCO';
                            cv.publicName = 'cvCOCO';
                            cv.analysisRole = [ ...
                                'Default method-B coherent-nine ', ...
                                'bidirectional held-out analysis'];
                            modeName = 'CVCOCO';
                        else
                            % Use the current cvCOCO2 four-group engine under
                            % its final public name, cvCOCO.
                            cv = cvcoco(app.dataRaw,app.orbit9,app.pad, ...
                                sr1,sr2,srstep,red,nsim,method, ...
                                'BatchSize',app.cvBatchSize,'Seed',app.cvSeed, ...
                                'TargetModel','four-group','AnalysisName','cvCOCO', ...
                                'MaxFrequency',app.f2, ...
                                'ProgressFcn',@(fraction,message) ...
                                updateProgressDialog(h,fraction,message));
                            cv.targetLabel = 'Phase-averaged four-group piecewise-constant target';
                            cv.validationLabel = 'Frozen phase-averaged noncoherent four-group target';
                            cv.engine = 'phase-averaged four-group band-integrated engine';
                            conclusionReport = ...
                                cocoConclusionReport('confirmatory',cv);
                            cv.conclusion = conclusionReport;
                            cv.pRobust = conclusionReport.pRobust;
                            cv.confirmatoryPass = conclusionReport.pass;
                            modeName = 'CVCOCO';
                        end
                        closeProgress(h);
                        h = [];

                        app.run.cv = cv;
                        app.run.conclusion = conclusionReport;
                        app.run.ready = true;
                        if isLegacyCvRun
                            assignin('base','cvCOCOLegacy_result',cv);
                        elseif isCv9ARun
                            assignin('base','cvCOCO9A_result',cv);
                        elseif isCv9BRun
                            assignin('base','cvCOCO_result',cv);
                            % Compatibility alias for scripts written while
                            % this implementation was exposed as cvCOCO9B.
                            assignin('base','cvCOCO9B_result',cv);
                        else
                            assignin('base','cvCOCO_result',cv);
                            assignin('base','cvCOCO_conclusion',conclusionReport);
                        end
                        [outputFile,outputIndex] = ...
                            saveCVCOCOOutputs(cv,modeName);
                        plotCVCOCOResult(cv);
                    else
                        cocoDisplayName = char(string(app.DCOCOMethod.Value));
                        h = uiprogressdlg(app.UIFigure, ...
                            'Title',cocoDisplayName, ...
                            'Message','Preparing COCO ...  0.0%', ...
                            'Indeterminate','off','Value',0,'Cancelable','off');
                        [corrCI,corr_h0,corry,adaptiveDetails] = ...
                            corrcoefslices_rankNew(dat,app.orbit9,srm,app.pad, ...
                            sr1,sr2,srstep,adjust,red,nsim,plotn,app.slices, ...
                            method,app.fmaxdata,app.main_unit_selection,false, ...
                            app.cocoTargetMode,'MaxFrequency',app.f2, ...
                            'Seed',app.adaptiveSeed, ...
                            'ShowPeriodograms',app.CShowPeriod.Value, ...
                            'ProgressFcn',@(fraction,message) ...
                            updateProgressDialog(h,fraction,message));
                        closeProgress(h);
                        h = [];
                        app.run.corrCI = corrCI;
                        app.run.corr_h0 = corr_h0;
                        app.run.corry = corry;
                        app.run.adaptiveDetails = adaptiveDetails;
                        if isAdaptiveCocoTargetMode(app.cocoTargetMode)
                            % Use the same strict plus-one/null-maximum audit
                            % as the non-GUI Adaptive publication path.
                            conclusionReport = cocoAdaptivePublicationReport( ...
                                corrCI,corr_h0,adaptiveDetails);
                            if strcmp(app.cocoTargetMode,'adaptive9b')
                                conclusionReport = relabelReportMethod( ...
                                    conclusionReport,'Adaptive COCO9B', ...
                                    'Adaptive COCO');
                            end
                            adaptiveResult = struct( ...
                                'name',adaptiveCocoDisplayName( ...
                                    app.cocoTargetMode), ...
                                'variant',adaptiveCocoVariant( ...
                                    app.cocoTargetMode), ...
                                'targetMode',app.cocoTargetMode, ...
                                'targetAmplitudeMode',detailValue( ...
                                    adaptiveDetails,'targetAmplitudeMode','adaptive'), ...
                                'corrCI',corrCI,'corr_h0',corr_h0, ...
                                'corry',corry,'details',adaptiveDetails, ...
                                'conclusion',conclusionReport);
                            if strcmp(app.cocoTargetMode,'adaptive9b')
                                assignin('base','AdaptiveCOCO_result', ...
                                    adaptiveResult);
                                assignin('base','AdaptiveCOCO_conclusion', ...
                                    conclusionReport);
                                % Compatibility aliases for existing scripts.
                                assignin('base','AdaptiveCOCO9B_result', ...
                                    adaptiveResult);
                                assignin('base','AdaptiveCOCO9B_conclusion', ...
                                    conclusionReport);
                                modeName = 'ADAPTIVECOCO';
                            elseif any(strcmp(app.cocoTargetMode, ...
                                    {'adaptive9a','adaptive9'}))
                                assignin('base','AdaptiveCOCO9A_result', ...
                                    adaptiveResult);
                                assignin('base','AdaptiveCOCO9A_conclusion', ...
                                    conclusionReport);
                                modeName = 'ADAPTIVECOCO9A';
                            else
                                assignin('base','AdaptiveCOCO_result', ...
                                    adaptiveResult);
                                assignin('base','AdaptiveCOCO_conclusion', ...
                                    conclusionReport);
                                modeName = 'COCO';
                            end
                        else
                            % The fixed-target compatibility mode must not be
                            % mislabeled with the Adaptive conclusion report.
                            conclusionReport = [];
                            isFixed9Run = strcmp(app.cocoTargetMode,'fixed9');
                            fixedName = 'Fixed COCO';
                            if isFixed9Run
                                fixedName = 'Fixed-target COCO';
                            end
                            fixedResult = struct('name',fixedName, ...
                                'targetMode',app.cocoTargetMode,'corrCI',corrCI, ...
                                'corr_h0',corr_h0,'corry',corry, ...
                                'details',adaptiveDetails);
                            if isFixed9Run
                                assignin('base','FixedTargetCOCO_result',fixedResult);
                                % Compatibility alias for existing scripts.
                                assignin('base','FixedCOCO9_result',fixedResult);
                                modeName = 'FIXEDTARGETCOCO';
                            else
                                assignin('base','FixedCOCO_result',fixedResult);
                                modeName = 'COCO';
                            end
                        end
                        app.run.conclusion = conclusionReport;
                        app.run.ready = true;
                        [outputFile,outputIndex] = ...
                            saveCOCOOutputs(corrCI,corr_h0,modeName);
                    end
                else
                    stepN = max(1,round(app.step/srm));
                    dat2 = dat;
                    isCrossfitRun = app.ecocoCalcMode == 2;
                    if isCrossfitRun
                        % This is an algorithm requirement, not an optional
                        % display/preprocessing preference.
                        dat2 = zeropad2(dat2,app.window,1);
                    elseif app.CPadEdge.Value
                        dat2 = zeropad2(dat2,app.window,app.padtype);
                    end
                    ecocoMode = iff(app.ecocoCalcMode == 1, ...
                        'adaptive','crossfit');
                    ecoDisplayName = iff(app.ecocoCalcMode == 1, ...
                        'Adaptive eCOCO','Cross-fitted eCOCO');
                    h = uiprogressdlg(app.UIFigure,'Title',ecoDisplayName, ...
                        'Message','Preparing sliding windows ...  0.0%', ...
                        'Indeterminate','off','Value',0,'Cancelable','off');
                    ecoPlotn = iff(app.CFlipY.Value,-1,1);
                    [prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco, ...
                        out_ecocorb,out_norbit,sr_p,ecoDetails] = ...
                        ecoco(dat2,[],app.orbit9,app.window,srm,stepN,0, ...
                        red,app.pad,sr1,sr2,srstep,nsim,adjust,1, ...
                        ecoPlotn,method,app.fmaxdata, ...
                        app.main_unit_selection,ecocoMode,app.f2, ...
                        app.adaptiveSeed,app.anchorFraction, ...
                        'ProgressFcn',@(fraction,message) ...
                        updateProgressDialog(h,fraction,message));
                    closeProgress(h);
                    h = [];
                    
                    app.run.prt_sr = prt_sr;
                    app.run.out_depth = out_depth;
                    app.run.out_ecc = out_ecc;
                    app.run.out_ep = out_ep;
                    app.run.out_eci = out_eci;
                    app.run.out_ecoco = out_ecoco;
                    app.run.out_ecocorb = out_ecocorb;
                    app.run.out_norbit = out_norbit;
                    app.run.sr_p = sr_p;
                    app.run.ecoDetails = ecoDetails;
                    app.run.ecoMethod = ecocoMode;
                    app.run.anchorFraction = app.anchorFraction;
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
                    assignin('base','sr_p_tracked',sr_p);
                    assignin('base','eCOCO_details',ecoDetails);
                    [outputFile,outputIndex] = saveECOCOOutputs( ...
                        prt_sr,out_depth,out_ecc,out_ep,out_eci,out_norbit, ...
                        out_ecoco,out_ecocorb,sr_p,dat,ecoDetails);
                    modeName = 'ECOCO';
                end

                saveRunParameterTable( ...
                    modeName,outputFile,outputIndex,conclusionReport, ...
                    app.run.adaptiveDetails);
                refreshMainListbox(ctx,resolveSaveDir(ctx));
                setappdata(app.UIFigure,'ECOCO_APP',app);
                if ~isempty(conclusionReport)
                    showConclusionReport(conclusionReport);
                end
            catch ME
                closeProgress(h);
                invalidateRunState();
                setappdata(app.UIFigure,'ECOCO_APP',app);
                try
                    evalin('base',['clear cvCOCO_result cvCOCO_conclusion ', ...
                        'cvCOCO9A_result cvCOCO9B_result cvCOCO9_result ', ...
                        'cvCOCOLegacy_result ', ...
                        'AdaptiveCOCO_result AdaptiveCOCO_conclusion ', ...
                        'AdaptiveCOCO9A_result AdaptiveCOCO9A_conclusion ', ...
                        'AdaptiveCOCO9B_result AdaptiveCOCO9B_conclusion ', ...
                        'AdaptiveCOCO9_result AdaptiveCOCO9_conclusion ', ...
                        'FixedCOCO_result FixedCOCO9_result ', ...
                        'FixedTargetCOCO_result']);
                catch
                end
                fprintf(2,'\n>> eCOCO error [%s]\n%s\n\n', ...
                    ME.identifier,getReport(ME,'extended','hyperlinks','off'));
                uialert(app.UIFigure,ME.message,'eCOCO error');
            end
        end

        function invalidateRunState()
            app.run = emptyRunState();
            try
                evalin('base',['clear cvCOCO_result cvCOCO_conclusion ', ...
                    'cvCOCO9A_result cvCOCO9B_result cvCOCO9_result ', ...
                    'cvCOCOLegacy_result ', ...
                    'AdaptiveCOCO_result AdaptiveCOCO_conclusion ', ...
                    'AdaptiveCOCO9A_result AdaptiveCOCO9A_conclusion ', ...
                    'AdaptiveCOCO9B_result AdaptiveCOCO9B_conclusion ', ...
                    'AdaptiveCOCO9_result AdaptiveCOCO9_conclusion ', ...
                    'FixedCOCO_result FixedCOCO9_result ', ...
                    'FixedTargetCOCO_result']);
            catch
            end
            if isfield(app,'BPlotE') && isgraphics(app.BPlotE)
                app.BPlotE.Enable = 'off';
            end
            if isfield(app,'BTrack') && isgraphics(app.BTrack)
                app.BTrack.Enable = 'off';
            end
        end

        function markSettingsChanged()
            invalidateRunState();
            if isfield(app,'UIFigure') && isgraphics(app.UIFigure)
                setappdata(app.UIFigure,'ECOCO_APP',app);
            end
        end

        function onNumericSettingEdited(editor,defaultValue)
            onEditNum(editor,defaultValue);
            markSettingsChanged();
        end

        function closeProgress(h)
            if isempty(h)
                return
            end
            try
                if isvalid(h)
                    close(h);
                end
            catch
            end
        end

        function updateProgressDialog(h,fraction,message)
            if isempty(h)
                return
            end
            try
                if ~isvalid(h)
                    return
                end
                fraction = min(max(double(fraction),0),1);
                if ~isfinite(fraction)
                    return
                end
                message = strtrim(char(string(message)));
                if isempty(message)
                    message = 'Running';
                end
                h.Indeterminate = 'off';
                h.Value = fraction;
                h.Message = sprintf('%s  %.1f%%',message,100*fraction);
                drawnow limitrate nocallbacks
            catch MEprogress
                warning('eCOCOGUI:ProgressUpdateFailed', ...
                    'Progress display update failed: %s',MEprogress.message);
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
            ecoPlotDetails = app.run.ecoDetails;
            if ~isstruct(ecoPlotDetails)
                ecoPlotDetails = struct();
            end
            ecoPlotDetails.trackedRate = app.run.sr_p;
            ecocoplot(app.run.prt_sr,app.run.out_depth,app.run.out_ecc,app.run.out_ep, ...
                app.run.out_eci,app.run.out_ecoco,app.run.out_ecocorb, ...
                app.run.out_norbit,plotn,ecoPlotDetails);
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
                {'3','0.05','0.3','4','2','3','1', ...
                num2str(app.sedmin),num2str(app.sedmax)});
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
            saveDir = resolveSaveDir(ctx);
            [~,dn,~] = fileparts(app.meta.filename);
            out = uniqueName(fullfile(saveDir,[dn,'-SR.txt']));
            writematrix(srn_map,out,'Delimiter','space');
            uialert(app.UIFigure,['Saved: ',out],'Track');
            refreshMainListbox(ctx,saveDir);
        end

        function onWaltham()
            msg = sprintf('Waltham, D. (2015). Milankovitch period uncertainties and their impact on cyclostratigraphy. JSR.');
            uialert(app.UIFigure,msg,'Reference');
        end

        function [nm,runIndex] = saveCOCOOutputs(corrCI,corr_h0,modeName)
            if nargin < 3 || isempty(modeName)
                modeName = 'COCO';
            end
            [~,dn,~] = fileparts(app.meta.filename);
            saveDir = resolveSaveDir(ctx);
            data_COCOCI = [corrCI(:,1:2),corr_h0(:,1),corr_h0(:,3),corr_h0(:,2)];
            outputStem = [dn,'-COCO-data'];
            if strcmp(modeName,'ADAPTIVECOCO')
                outputStem = [dn,'-Adaptive-COCO-data'];
            elseif strcmp(modeName,'ADAPTIVECOCO9A')
                outputStem = [dn,'-Adaptive-COCO9A-data'];
            elseif strcmp(modeName,'ADAPTIVECOCO9B')
                outputStem = [dn,'-Adaptive-COCO9B-data'];
            elseif strcmp(modeName,'FIXEDTARGETCOCO')
                outputStem = [dn,'-Fixed-target-COCO-data'];
            elseif strcmp(modeName,'FIXEDCOCO9')
                outputStem = [dn,'-Fixed-COCO9-data'];
            end
            [nm,runIndex] = indexedRunName( ...
                saveDir,outputStem,'.txt',dn,modeName);
            temporaryFile = [tempname(saveDir),'.txt'];
            cleanup = onCleanup(@()deleteIfPresent(temporaryFile));
            writematrix(data_COCOCI,temporaryFile,'Delimiter',',');
            [ok,message] = movefile(temporaryFile,nm,'f');
            if ~ok
                error('eCOCOGUI:AtomicSaveFailed', ...
                    'Could not finalize the COCO output: %s',message);
            end
            clear cleanup
        end

        function [nm,runIndex] = saveCVCOCOOutputs(cv,modeName)
            if nargin < 2 || isempty(modeName)
                modeName = 'CVCOCO';
            end
            targetModel = '';
            if isfield(cv,'targetModel') && ...
                    (ischar(cv.targetModel) || ...
                    (isstring(cv.targetModel) && isscalar(cv.targetModel)))
                targetModel = char(cv.targetModel);
            end
            % Detect the implementation from result metadata, rather than
            % only the public mode name.  The public CVCOCO mode now uses
            % the former cvCOCO9B coherent-nine method-B implementation.
            isCv9AOutput = strcmp(targetModel, ...
                'rayleigh-peak-coherent-nine') || ...
                strcmp(modeName,'CVCOCO9A');
            isCv9BOutput = strcmp(targetModel, ...
                'four-group-coherent-nine') || ...
                any(strcmp(modeName,{'CVCOCO9B','CVCOCO9'}));
            isCv9Output = isCv9AOutput || isCv9BOutput;
            isFourGroupOutput = isfield(cv,'targetModel') && ...
                any(strcmp(cv.targetModel, ...
                {'four-group','four-group-coherent-nine'}));
            required = {'srGrid','splitDepth','dataA','dataB','trainA','trainB', ...
                'dataClean', ...
                'validateAtoB','validateBtoA','scoreSymmetric','scoreMean', ...
                'nullSymmetric','nullAtoB','nullBtoA', ...
                'nullBestRateAtoB','nullBestRateBtoA', ...
                'pSym','pA','pB','pAtoB','pBtoA', ...
                'pSymConfidenceInterval','pAConfidenceInterval','pBConfidenceInterval', ...
                'pCurveAtoB','pCurveBtoA', ...
                'pLocalCurveAtoB','pLocalCurveBtoA', ...
                'rhoM','rhoMA','rhoMB', ...
                'rhoMethodA','rhoMethodB', ...
                'nsimRequested','nsimCompleted','nsimValid', ...
                'nsimValidAtoB','nsimValidBtoA', ...
                'seed','validRateMaskA','validRateMaskB','groupNames', ...
                'groupIndex','orbitPeriods','samplingIntervalA','samplingIntervalB', ...
                'interpolationA','interpolationB','spectra', ...
                'orbitCountA','orbitCountB', ...
                'resolvableOrbitCountA','resolvableOrbitCountB', ...
                'resolvableGroupCountA','resolvableGroupCountB','targetModel', ...
                'activeOrbitCountAtoB','activeOrbitCountBtoA', ...
                'activeGroupCountAtoB','activeGroupCountBtoA', ...
                'groupLeakageRcondA','groupLeakageRcondB', ...
                'trainingRateMaskA','trainingRateMaskB', ...
                'allNineRateRangeA','allNineRateRangeB','allNineRateRangeShared', ...
                'config'};
            missing = required(~cellfun(@(f)isfield(cv,f),required));
            if ~isempty(missing)
                error('eCOCOGUI:InvalidCVCOCOResult', ...
                    'cvCOCO result is missing required field(s): %s.',strjoin(missing,', '));
            end
            trainRequired = {'curve','bestRate','bestIndex','amplitudes9', ...
                'groupRaw','groupNormalized','groupLeakageMatrix', ...
                'groupLeakageRcond'};
            validationRequired = {'curve','bestRate','bestIndex','score', ...
                'pDirectional','pConfidenceInterval','pGlobalCurve', ...
                'pLocalCurve'};
            validateNestedFields(cv.trainA,'trainA',trainRequired);
            validateNestedFields(cv.trainB,'trainB',trainRequired);
            if isCv9AOutput
                validateNestedFields(cv.trainA,'trainA', ...
                    {'amplitudes9Normalized'});
                validateNestedFields(cv.trainB,'trainB', ...
                    {'amplitudes9Normalized'});
            end
            validateNestedFields(cv.validateAtoB,'validateAtoB',validationRequired);
            validateNestedFields(cv.validateBtoA,'validateBtoA',validationRequired);

            sr = cv.srGrid(:);
            nRate = numel(sr);
            curves = [sr, cvColumn(cv.trainA.curve,nRate,'trainA.curve'), ...
                cvColumn(cv.trainB.curve,nRate,'trainB.curve'), ...
                cvColumn(cv.validateAtoB.curve,nRate,'validateAtoB.curve'), ...
                cvColumn(cv.validateBtoA.curve,nRate,'validateBtoA.curve'), ...
                cvColumn(cv.pCurveAtoB,nRate,'pCurveAtoB'), ...
                cvColumn(cv.pCurveBtoA,nRate,'pCurveBtoA'), ...
                cvColumn(cv.pLocalCurveAtoB,nRate,'pLocalCurveAtoB'), ...
                cvColumn(cv.pLocalCurveBtoA,nRate,'pLocalCurveBtoA'), ...
                cvColumn(cv.orbitCountA,nRate,'orbitCountA'), ...
                cvColumn(cv.orbitCountB,nRate,'orbitCountB'), ...
                cvColumn(cv.activeOrbitCountAtoB,nRate,'activeOrbitCountAtoB'), ...
                cvColumn(cv.activeOrbitCountBtoA,nRate,'activeOrbitCountBtoA')];
            if isFourGroupOutput
                curves = [curves, ...
                    cvColumn(cv.groupLeakageRcondA,nRate,'groupLeakageRcondA'), ...
                    cvColumn(cv.groupLeakageRcondB,nRate,'groupLeakageRcondB')];
            end
            curves = [curves, ...
                double(cvColumn(cv.trainingRateMaskA,nRate,'trainingRateMaskA')), ...
                double(cvColumn(cv.trainingRateMaskB,nRate,'trainingRateMaskB')), ...
                double(cvColumn(cv.validRateMaskA,nRate,'validRateMaskA')), ...
                double(cvColumn(cv.validRateMaskB,nRate,'validRateMaskB'))];

            nNull = cv.nsimCompleted;
            nullScore = cvColumn(cv.nullSymmetric,nNull,'nullSymmetric');
            nullAtoB = cvColumn(cv.nullAtoB,nNull,'nullAtoB');
            nullBtoA = cvColumn(cv.nullBtoA,nNull,'nullBtoA');
            nullRateAtoB = cvColumn(cv.nullBestRateAtoB,nNull,'nullBestRateAtoB');
            nullRateBtoA = cvColumn(cv.nullBestRateBtoA,nNull,'nullBestRateBtoA');
            groupNames = cellstr(string(cv.groupNames(:)));
            nGroup = numel(groupNames);
            groupAraw = cvColumn(cv.trainA.groupRaw,nGroup,'trainA.groupRaw');
            groupAnorm = cvColumn(cv.trainA.groupNormalized,nGroup,'trainA.groupNormalized');
            groupBraw = cvColumn(cv.trainB.groupRaw,nGroup,'trainB.groupRaw');
            groupBnorm = cvColumn(cv.trainB.groupNormalized,nGroup,'trainB.groupNormalized');

            methodLabel = ['cvCOCO Legacy bidirectional held-out ', ...
                'compatibility analysis (non-confirmatory)'];
            analysisRole = 'Legacy compatibility analysis; not confirmatory';
            trainingLabel = 'Adaptive nine-period peaks reduced to four groups';
            validationLabel = ['Train one half; freeze four group weights; ', ...
                'scan sedimentation rate in the other half'];
            trainingTargetUnits = ...
                'Nine periods summarized to four validation groups';
            if isCv9AOutput
                methodLabel = ['Rayleigh-band peak-trained coherent ', ...
                    'nine-term bidirectional held-out COCO (cvCOCO9A)'];
                analysisRole = [ ...
                    'Internal coherent-nine method comparison; ', ...
                    'exploratory and separate from confirmatory cvCOCO'];
                trainingLabel = [ ...
                    'Nine per-orbit amplitudes calibrated from the maximum ', ...
                    'data PSD in each +/-1-Rayleigh band'];
                validationLabel = [ ...
                    'Train one half; freeze the nine normalized per-orbit ', ...
                    'amplitudes; sum the nine sine terms coherently before power'];
                trainingTargetUnits = ...
                    'Nine individual orbital periods; group summaries are descriptive only';
            elseif isCv9BOutput
                if strcmp(modeName,'CVCOCO')
                    methodLabel = ['Four-group-trained coherent nine-term ', ...
                        'bidirectional held-out COCO (cvCOCO)'];
                    analysisRole = [ ...
                        'Default method-B coherent-nine bidirectional ', ...
                        'held-out analysis'];
                else
                    methodLabel = ['Four-group-trained coherent nine-term ', ...
                        'bidirectional held-out COCO (cvCOCO9B)'];
                    analysisRole = [ ...
                        'Internal coherent-nine method comparison; ', ...
                        'retained for compatibility'];
                end
                trainingLabel = [ ...
                    'Four union-band energies de-mixed by a 4-by-4 ', ...
                    'finite-record leakage matrix and exact nonnegative ', ...
                    'least squares'];
                validationLabel = [ ...
                    'Train one half; freeze four group weights; expand ', ...
                    'them to nine sine terms summed coherently before power'];
                trainingTargetUnits = ...
                    'Long eccentricity / short eccentricity / obliquity / precession';
            elseif isFourGroupOutput
                methodLabel = ['Four-group band-integrated bidirectional ', ...
                    'cross-validated COCO (cvCOCO; confirmatory)'];
                analysisRole = 'Confirmatory bidirectional held-out analysis';
                trainingLabel = ['Four union-band energies de-mixed by a ', ...
                    '4-by-4 finite-record leakage matrix and exact ', ...
                    'nonnegative least squares, using phase-averaged ', ...
                    'sine/cosine templates'];
                validationLabel = ['Train one half; freeze four group ', ...
                    'weights; compare the other half with noncoherent ', ...
                    'four-group periodogram targets'];
                trainingTargetUnits = ...
                    'Long eccentricity / short eccentricity / obliquity / precession';
            end
            conclusionRows = cell(0,2);
            if isfield(cv,'conclusion') && isstruct(cv.conclusion) && ...
                    isfield(cv.conclusion,'summaryRows')
                conclusionRows = cv.conclusion.summaryRows;
                if ~iscell(conclusionRows) || size(conclusionRows,2) ~= 2
                    error('eCOCOGUI:InvalidConclusionReport', ...
                        'cvCOCO conclusion summaryRows must be a two-column cell array.');
                end
            end
            summaryDetails = {
                'Method',methodLabel;
                'Analysis role',analysisRole;
                'Split depth (m)',cv.splitDepth;
                'Segment A sampling interval (m)',cv.samplingIntervalA;
                'Segment B sampling interval (m)',cv.samplingIntervalB;
                'Segment A interpolated',yesno(cv.interpolationA.applied);
                'Segment B interpolated',yesno(cv.interpolationB.applied);
                'Segment A original/interpolated point counts',sprintf('%d / %d', ...
                    cv.interpolationA.originalPointCount, ...
                    cv.interpolationA.interpolatedPointCount);
                'Segment B original/interpolated point counts',sprintf('%d / %d', ...
                    cv.interpolationB.originalPointCount, ...
                    cv.interpolationB.interpolatedPointCount);
                'Segment A largest gap / median spacing', ...
                    cv.interpolationA.maximumGapToMedianRatio;
                'Segment B largest gap / median spacing', ...
                    cv.interpolationB.maximumGapToMedianRatio;
                'Segment A theoretical all-nine rate lower bound (exclusive)',cv.allNineRateRangeA(1);
                'Segment A theoretical all-nine rate upper bound (inclusive)',cv.allNineRateRangeA(2);
                'Segment B theoretical all-nine rate lower bound (exclusive)',cv.allNineRateRangeB(1);
                'Segment B theoretical all-nine rate upper bound (inclusive)',cv.allNineRateRangeB(2);
                'Shared all-nine rate lower bound (exclusive)',cv.allNineRateRangeShared(1);
                'Shared all-nine rate upper bound (inclusive)',cv.allNineRateRangeShared(2);
                'Adaptive training rate A (cm/kyr)',cv.trainA.bestRate;
                'Adaptive training rate B (cm/kyr)',cv.trainB.bestRate;
                'A-to-B frozen-target validation rate (cm/kyr)',cv.validateAtoB.bestRate;
                'B-to-A frozen-target validation rate (cm/kyr)',cv.validateBtoA.bestRate;
                'A-to-B validation score',cv.validateAtoB.score;
                'B-to-A validation score',cv.validateBtoA.score;
                'p_B: A-to-B, Segment B held out',cv.pB;
                'p_B null-exceedance probability 95% Wilson CI lower',cv.pBConfidenceInterval(1);
                'p_B null-exceedance probability 95% Wilson CI upper',cv.pBConfidenceInterval(2);
                'Finite A-to-B null maxima',cv.nsimValidAtoB;
                'p_A: B-to-A, Segment A held out',cv.pA;
                'p_A null-exceedance probability 95% Wilson CI lower',cv.pAConfidenceInterval(1);
                'p_A null-exceedance probability 95% Wilson CI upper',cv.pAConfidenceInterval(2);
                'Finite B-to-A null maxima',cv.nsimValidBtoA;
                'Symmetric score (minimum)',cv.scoreSymmetric;
                'Mean directional score',cv.scoreMean;
                'Symmetric Monte Carlo p-value',cv.pSym;
                'p_sym null-exceedance probability 95% Wilson CI lower',cv.pSymConfidenceInterval(1);
                'p_sym null-exceedance probability 95% Wilson CI upper',cv.pSymConfidenceInterval(2);
                'Segment A AR(1) rho used in null',cv.rhoMA;
                'Segment A AR(1) estimator',cv.rhoMethodA;
                'Segment B AR(1) rho used in null',cv.rhoMB;
                'Segment B AR(1) estimator',cv.rhoMethodB;
                'Compatibility mean rhoM (not used to simulate)',cv.rhoM;
                'Monte Carlo iterations requested',cv.nsimRequested;
                'Monte Carlo iterations completed',cv.nsimCompleted;
                'Finite null statistics used for p-value',cv.nsimValid;
                'Random seed',cv.seed;
                'Maximum temporal frequency used (cycle/kyr)',cv.config.maximumTemporalFrequency;
                'Training target units',trainingTargetUnits;
                'Training amplitude rule',trainingLabel;
                'Validation rule',validationLabel;
                'Symmetric statistic','min(max rho A-to-B, max rho B-to-A)'};
            if isFourGroupOutput
                summaryDetails = [summaryDetails; {
                    'Leakage correction', ...
                    '4-by-4 finite-record leakage matrix; exact nonnegative least squares';
                    'Minimum leakage-matrix rcond', ...
                    cv.config.minimumLeakageMatrixRcond}];
            end
            summary = [{'Metric','Value'};conclusionRows;summaryDetails];

            [~,dn,~] = fileparts(app.meta.filename);
            saveDir = resolveSaveDir(ctx);
            if strcmp(modeName,'CVCOCOLEGACY')
                methodStem = 'cvCOCO-Legacy';
            elseif strcmp(modeName,'CVCOCO9A')
                methodStem = 'cvCOCO9A';
            elseif any(strcmp(modeName,{'CVCOCO9B','CVCOCO9'}))
                methodStem = 'cvCOCO9B';
            elseif strcmp(modeName,'CVCOCO2')
                methodStem = 'cvCOCO2';
            else
                methodStem = 'cvCOCO';
            end
            [nm,runIndex] = indexedRunName(saveDir, ...
                [dn,'-',methodStem,'-data'],'.xlsx',dn,modeName);
            workbook = [tempname(saveDir),'.xlsx'];
            cleanup = onCleanup(@()deleteIfPresent(workbook));

            writecell(summary,workbook,'Sheet','Summary','Range','A1');
            trainPrefix = iff(isFourGroupOutput,'GroupBandTrain','AdaptiveTrain');
            if isCv9AOutput
                trainPrefix = 'RayleighPeakTrain';
            end
            validatePrefix = iff(isFourGroupOutput,'FourGroupValidate','FixedValidate');
            if isCv9Output
                validatePrefix = 'Coherent9Validate';
            end
            curveHeader = {'SedRate_cm_per_kyr',[trainPrefix,'A'],[trainPrefix,'B'], ...
                [validatePrefix,'_A_to_B'],[validatePrefix,'_B_to_A'], ...
                'GlobalP_A_to_B','GlobalP_B_to_A', ...
                'LocalP_A_to_B','LocalP_B_to_A', ...
                'ResolvablePeriods_A','ResolvablePeriods_B', ...
                'ActivePeriods_A_to_B','ActivePeriods_B_to_A'};
            if isFourGroupOutput
                curveHeader = [curveHeader, ...
                    {'LeakageMatrixRcond_A','LeakageMatrixRcond_B'}];
            end
            curveHeader = [curveHeader, ...
                { ...
                'AllNineTrainingRate_A','AllNineTrainingRate_B', ...
                'ValidRate_A','ValidRate_B'}];
            writecell(curveHeader,workbook,'Sheet','SedRateCurves','Range','A1');
            writematrix(curves,workbook,'Sheet','SedRateCurves','Range','A2');

            groupRows = [groupNames,num2cell([groupAraw,groupAnorm,groupBraw,groupBnorm])];
            if isCv9AOutput
                groupHeader = {'Group', ...
                    'TrainA_descriptive_group_RMS_raw_not_used_for_validation', ...
                    'TrainA_descriptive_group_RMS_relative_not_used_for_validation', ...
                    'TrainB_descriptive_group_RMS_raw_not_used_for_validation', ...
                    'TrainB_descriptive_group_RMS_relative_not_used_for_validation'};
            else
                groupHeader = {'Group','TrainA_raw_amplitude', ...
                    'TrainA_relative_weight','TrainB_raw_amplitude', ...
                    'TrainB_relative_weight'};
            end
            writecell([groupHeader;groupRows],workbook,'Sheet','GroupWeights','Range','A1');
            if isFourGroupOutput
                writeLeakageMatrixSheet(workbook,'LeakageMatrixA',groupNames, ...
                    cv.trainA.groupLeakageMatrix,cv.trainA.groupLeakageRcond);
                writeLeakageMatrixSheet(workbook,'LeakageMatrixB',groupNames, ...
                    cv.trainB.groupLeakageMatrix,cv.trainB.groupLeakageRcond);
            end
            if ~isequal(size(cv.activeGroupCountAtoB),[nRate,4]) || ...
                    ~isequal(size(cv.activeGroupCountBtoA),[nRate,4])
                error('eCOCOGUI:InvalidCVCOCOResult', ...
                    'cvCOCO active-group count curves must be N-rate by four.');
            end
            activeGroupHeader = [{'SedRate_cm_per_kyr'}, ...
                strcat('AtoB_active_',groupNames(:)'), ...
                strcat('BtoA_active_',groupNames(:)')];
            writecell(activeGroupHeader,workbook, ...
                'Sheet','ActiveGroupCounts','Range','A1');
            writematrix([sr,cv.activeGroupCountAtoB, ...
                cv.activeGroupCountBtoA],workbook, ...
                'Sheet','ActiveGroupCounts','Range','A2');

            orbitPeriods = cv.orbitPeriods(:);
            orbitGroups = cv.groupIndex(:);
            if numel(orbitPeriods) ~= numel(cv.trainA.amplitudes9) || ...
                    numel(orbitPeriods) ~= numel(cv.trainB.amplitudes9) || ...
                    numel(orbitPeriods) ~= numel(orbitGroups)
                error('eCOCOGUI:InvalidCVCOCOResult', ...
                    'cvCOCO orbital amplitude arrays have inconsistent lengths.');
            end
            groupLabels = groupNames(orbitGroups);
            if isCv9AOutput && ...
                    isfield(cv.trainA,'amplitudes9Normalized') && ...
                    isfield(cv.trainB,'amplitudes9Normalized')
                normalizedA = cvColumn(cv.trainA.amplitudes9Normalized, ...
                    numel(orbitPeriods),'trainA.amplitudes9Normalized');
                normalizedB = cvColumn(cv.trainB.amplitudes9Normalized, ...
                    numel(orbitPeriods),'trainB.amplitudes9Normalized');
                amplitudeHeader = {'Period_kyr','Group', ...
                    'TrainA_per_orbit_Rayleigh_peak_raw_amplitude', ...
                    'TrainB_per_orbit_Rayleigh_peak_raw_amplitude', ...
                    'TrainA_per_orbit_normalized_weight', ...
                    'TrainB_per_orbit_normalized_weight'};
                amplitudeRows = [num2cell(orbitPeriods),groupLabels, ...
                    num2cell(cv.trainA.amplitudes9(:)), ...
                    num2cell(cv.trainB.amplitudes9(:)), ...
                    num2cell(normalizedA),num2cell(normalizedB)];
            elseif isFourGroupOutput
                amplitudeHeader = {'Period_kyr','Group', ...
                    'TrainA_group_common_amplitude_repeated_for_member', ...
                    'TrainB_group_common_amplitude_repeated_for_member'};
                amplitudeRows = [num2cell(orbitPeriods),groupLabels, ...
                    num2cell(cv.trainA.amplitudes9(:)), ...
                    num2cell(cv.trainB.amplitudes9(:))];
            else
                amplitudeHeader = {'Period_kyr','Group', ...
                    'TrainA_per_orbit_adaptive_amplitude', ...
                    'TrainB_per_orbit_adaptive_amplitude'};
                amplitudeRows = [num2cell(orbitPeriods),groupLabels, ...
                    num2cell(cv.trainA.amplitudes9(:)), ...
                    num2cell(cv.trainB.amplitudes9(:))];
            end
            writecell([amplitudeHeader;amplitudeRows],workbook, ...
                'Sheet','OrbitAmplitudes','Range','A1');

            nullHeader = {'Simulation','S_A_to_B','S_B_to_A','T_symmetric', ...
                'BestRate_A_to_B_cm_per_kyr','BestRate_B_to_A_cm_per_kyr'};
            writecell(nullHeader,workbook,'Sheet','NullStatistics','Range','A1');
            writematrix([(1:nNull)',nullAtoB,nullBtoA,nullScore, ...
                nullRateAtoB,nullRateBtoA],workbook,'Sheet','NullStatistics','Range','A2');

            writeSegmentSheet(workbook,'CleanInput',cv.dataClean);
            writeSegmentSheet(workbook,'SegmentA',cv.dataA);
            writeSegmentSheet(workbook,'SegmentB',cv.dataB);
            writeSpectrumSheet(workbook,'TrainingSpectrumA',cv.spectra.trainA);
            writeSpectrumSheet(workbook,'TrainingSpectrumB',cv.spectra.trainB);
            writeSpectrumSheet(workbook,'ValidationSpectrum_AtoB',cv.spectra.validateAtoB);
            writeSpectrumSheet(workbook,'ValidationSpectrum_BtoA',cv.spectra.validateBtoA);
            [ok,message] = movefile(workbook,nm,'f');
            if ~ok
                error('eCOCOGUI:AtomicSaveFailed', ...
                    'Could not finalize the cvCOCO workbook: %s',message);
            end
            clear cleanup
        end

        function validateNestedFields(s,label,required)
            if ~isstruct(s)
                error('eCOCOGUI:InvalidCVCOCOResult','cvCOCO result.%s must be a struct.',label);
            end
            missing = required(~cellfun(@(f)isfield(s,f),required));
            if ~isempty(missing)
                error('eCOCOGUI:InvalidCVCOCOResult', ...
                    'cvCOCO result.%s is missing required field(s): %s.', ...
                    label,strjoin(missing,', '));
            end
        end

        function x = cvColumn(x,n,label)
            x = x(:);
            if numel(x) ~= n
                error('eCOCOGUI:InvalidCVCOCOResult', ...
                    'cvCOCO result.%s has %d values; expected %d.',label,numel(x),n);
            end
        end

        function writeSegmentSheet(nm,sheetName,data)
            if ~isnumeric(data) || size(data,2) < 2
                error('eCOCOGUI:InvalidCVCOCOResult', ...
                    'cvCOCO result.data%s must be an N-by-2 numeric array.',sheetName(end));
            end
            writecell({'Depth_m','Value'},nm,'Sheet',sheetName,'Range','A1');
            writematrix(data(:,1:2),nm,'Sheet',sheetName,'Range','A2');
        end

        function writeSpectrumSheet(nm,sheetName,spectrum)
            required = {'frequency','dataPower','targetPower','rate','mode'};
            if ~isstruct(spectrum) || any(~isfield(spectrum,required))
                error('eCOCOGUI:InvalidCVCOCOResult', ...
                    'cvCOCO spectrum diagnostic %s is incomplete.',sheetName);
            end
            writecell({'Rate_cm_per_kyr',spectrum.rate;'Target_mode',spectrum.mode}, ...
                nm,'Sheet',sheetName,'Range','A1');
            writecell({'Frequency_cycle_per_kyr','Data_temporal_PSD','Target_temporal_PSD'}, ...
                nm,'Sheet',sheetName,'Range','A4');
            if ~isempty(spectrum.frequency)
                writematrix([spectrum.frequency(:),spectrum.dataPower(:), ...
                    spectrum.targetPower(:)],nm,'Sheet',sheetName,'Range','A5');
            end
        end

        function writeLeakageMatrixSheet( ...
                nm,sheetName,groupNames,matrixValue,rcondValue)
            if ~isnumeric(matrixValue) || ~isequal(size(matrixValue),[4,4]) || ...
                    any(~isfinite(matrixValue),'all') || ...
                    ~isnumeric(rcondValue) || ~isscalar(rcondValue) || ...
                    ~isfinite(rcondValue)
                error('eCOCOGUI:InvalidCVCOCOResult', ...
                    'cvCOCO %s is not a finite 4-by-4 leakage matrix.',sheetName);
            end
            header = [{'Observed_band_energy_by_row'}, ...
                strcat('Template_',groupNames(:)')];
            rows = [groupNames,num2cell(matrixValue)];
            writecell({'Matrix_rcond',rcondValue}, ...
                nm,'Sheet',sheetName,'Range','A1');
            writecell([header;rows],nm,'Sheet',sheetName,'Range','A3');
        end

        function plotCVCOCOResult(cv)
            if exist('plotcvcoco','file') ~= 2
                return
            end
            try
                app.run.cocoFigure = plotcvcoco(cv, ...
                    'ShowSpectra',app.CShowPeriod.Value);
            catch MEplot
                warning('eCOCOGUI:CVCOCOPlotFailed', ...
                    'cvCOCO calculation and output succeeded, but plotting failed: %s',MEplot.message);
            end
        end

        function writeConclusionSummary(workbook,report)
            if isempty(workbook) || ~isfile(workbook) || ~isstruct(report) || ...
                    ~isfield(report,'summaryRows')
                return
            end
            rows = report.summaryRows;
            if ~iscell(rows) || size(rows,2) ~= 2
                error('eCOCOGUI:InvalidConclusionReport', ...
                    'Conclusion summaryRows must be a two-column cell array.');
            end
            writecell([{'Metric','Value'};rows],workbook, ...
                'Sheet','Summary','Range','A1');
        end

        function writeAdaptiveAudit(workbook,details)
            if isempty(workbook) || ~isfile(workbook) || ~isstruct(details)
                return
            end
            rows = {
                'Metric','Value';
                'AR1_rhoM',detailValue(details,'rhoM',NaN);
                'AR1_estimator',detailValue(details,'rhoMethod','');
                'Random_seed',detailValue(details,'seed',NaN);
                'MC_requested',detailValue(details,'nsimRequested',NaN);
                'MC_completed',detailValue(details,'nsimCompleted',NaN);
                'MC_valid_null_maxima',detailValue(details,'nsimValid',NaN);
                'Minimum_resolvable_plus_one_p',detailValue(details,'pFloor',NaN);
                'Maximum_frequency_cycle_per_kyr',detailValue(details,'maxFrequency',NaN);
                'Data_Nyquist_MaxFrequency_crossover_cm_per_kyr',detailValue(details,'sr0',NaN);
                'Slices',detailValue(details,'slices',NaN);
                'NFFT',detailValue(details,'pad',NaN);
                'MC_spectrum_streaming_batch_size',detailValue(details,'mcSpectrumBatchSize',NaN);
                'Red_noise_option',detailValue(details,'red',NaN);
                'Correlation_method',detailValue(details,'method','');
                'Target_mode',detailValue(details,'targetMode','');
                'Target_amplitude_mode', ...
                    detailValue(details,'targetAmplitudeMode','');
                'Null_conditioning',detailValue(details,'nullConditioning','');
                'Adaptive_target_construction',detailValue(details,'targetConstruction','');
                'Adaptive_band_assignment',detailValue(details,'bandAssignment','')};
            writecell(rows,workbook,'Sheet','AdaptiveAudit','Range','A1');
            nullMax = detailValue(details,'nullMax',[]);
            if isnumeric(nullMax) && ~isempty(nullMax)
                nullMax = nullMax(:);
                writecell({'Simulation','Null_maximum_correlation'},workbook, ...
                    'Sheet','NullMaximum','Range','A1');
                writematrix([(1:numel(nullMax))',nullMax],workbook, ...
                    'Sheet','NullMaximum','Range','A2');
            end
        end

        function writeAdaptiveCurves(workbook,corrCI,corrH0)
            if ~isnumeric(corrCI) || size(corrCI,2) < 4 || ...
                    ~isnumeric(corrH0) || size(corrH0,2) < 3 || ...
                    size(corrCI,1) ~= size(corrH0,1)
                error('eCOCOGUI:InvalidAdaptiveResult', ...
                    'Adaptive COCO curve arrays are incomplete.');
            end
            header = {'SedRate_cm_per_kyr','Correlation', ...
                'Parametric_correlation_p_descriptive_only', ...
                'Missing_or_unresolved_periods','Global_max_statistic_p', ...
                'Participating_periods','Local_Monte_Carlo_p'};
            writecell(header,workbook,'Sheet','SedRateCurves','Range','A1');
            writematrix([corrCI(:,1:4),corrH0(:,1:3)],workbook, ...
                'Sheet','SedRateCurves','Range','A2');
        end

        function showConclusionReport(report)
            if ~isstruct(report) || ~isfield(report,'message')
                return
            end
            fprintf('\n>> COCO conclusion report\n%s\n\n',report.message);
            try
                uialert(app.UIFigure,report.message,'COCO conclusion');
            catch MEreport
                warning('eCOCOGUI:ConclusionDisplayFailed', ...
                    'The conclusion was saved, but its dialog failed: %s', ...
                    MEreport.message);
            end
        end

        function [nm,runIndex] = saveECOCOOutputs( ...
                prt_sr,out_depth,out_ecc,out_ep,out_eci,out_norbit, ...
                out_ecoco,out_ecocorb,sr_p,rawData,ecoDetails)
            [~,dn,~] = fileparts(app.meta.filename);
            saveDir = resolveSaveDir(ctx);
            [nm,runIndex] = indexedRunName(saveDir,[dn,'-ECOCO.data'],'.xlsx',dn,'ECOCO');
            writematrix(prt_sr,nm,'Sheet','Sed.Rate');
            writematrix(out_depth,nm,'Sheet','Depth');
            writematrix(out_ecc,nm,'Sheet','COCO');
            writematrix(out_eci,nm,'Sheet','p_global');
            writematrix(out_norbit,nm,'Sheet','#Orbits');
            writematrix(out_ecoco,nm,'Sheet','pCOCO');
            writematrix(out_ecocorb,nm,'Sheet','RidgeScore');

            methodName = ecoCalcModeName('ECOCO');
            engineMethod = iff(app.ecocoCalcMode == 1, ...
                'adaptive','crossfit');
            detailsAnchorFraction = app.anchorFraction;
            if nargin >= 11 && isstruct(ecoDetails)
                engineMethod = detailValue( ...
                    ecoDetails,'method',engineMethod);
                detailsAnchorFraction = detailValue( ...
                    ecoDetails,'anchorFraction',detailsAnchorFraction);
            end
            writecell({'Parameter','Value';'Method',methodName; ...
                'Engine_method',engineMethod; ...
                'Anchor_fraction_W',detailsAnchorFraction},nm, ...
                'Sheet','eCOCO_Method','Range','A1');

            if any(strcmpi(char(string(engineMethod)), ...
                    {'adaptive','crossfit'})) && ...
                    isnumeric(out_ep) && ~isempty(out_ep)
                writematrix(out_ep,nm,'Sheet','p_local');
            end

            if nargin >= 11 && isstruct(ecoDetails)
                writeEcoDirectionSheets(nm,ecoDetails,'forward','Fwd');
                writeEcoDirectionSheets(nm,ecoDetails,'backward','Bwd');
                writeEcoDirectionSheets(nm,ecoDetails, ...
                    'consensus','Consensus');
                if isfield(ecoDetails,'supportDirection')
                    writeEcoSheet(nm,'SupportDirection', ...
                        ecoDetails.supportDirection);
                end
                if isfield(ecoDetails,'anchors')
                    writeEcoMetadata(nm,'AnchorMetadata', ...
                        ecoDetails.anchors);
                elseif isfield(ecoDetails,'anchor')
                    writeEcoMetadata(nm,'AnchorMetadata',ecoDetails.anchor);
                end
            end

            if nargin >= 10 && ~isempty(sr_p)
                trackedHeader = {'Depth_m','SedRate_cm_per_kyr','Correlation','P_value','N_orbits','pCOCOxOrbits','SedRate_low_cm_per_kyr','SedRate_high_cm_per_kyr'};
                writecell(trackedHeader,nm,'Sheet','TrackedSR','Range','A1');
                writematrix(sr_p,nm,'Sheet','TrackedSR','Range','A2');

                [ageModel,timeDomainData] = buildAgeModelFromTrackedSR(rawData,sr_p);
                ageHeader = {'Depth_m','Age_kyr','Age_min_kyr','Age_max_kyr','SedRate_cm_per_kyr','SedRate_low_cm_per_kyr','SedRate_high_cm_per_kyr'};
                writecell(ageHeader,nm,'Sheet','AgeModel','Range','A1');
                writematrix(ageModel,nm,'Sheet','AgeModel','Range','A2');

                timeHeader = {'Age_kyr','Age_min_kyr','Age_max_kyr','Value','Depth_m'};
                writecell(timeHeader,nm,'Sheet','TimeDomainData','Range','A1');
                writematrix(timeDomainData,nm,'Sheet','TimeDomainData','Range','A2');
            end
        end

        function writeEcoDirectionSheets(workbook,details,fieldName,prefix)
            if ~isfield(details,fieldName) || ...
                    ~isstruct(details.(fieldName))
                return
            end
            direction = details.(fieldName);
            fields = {'rho','pLocal','pGlobal','nOrbit','score'};
            suffix = {'rho','p_local','p_global','Orbits','score'};
            for fieldIndex = 1:numel(fields)
                if isfield(direction,fields{fieldIndex})
                    writeEcoSheet(workbook, ...
                        [prefix,'_',suffix{fieldIndex}], ...
                        direction.(fields{fieldIndex}));
                end
            end
        end

        function writeEcoSheet(workbook,sheetName,value)
            sheetName = sheetName(1:min(31,numel(sheetName)));
            if isnumeric(value) || islogical(value)
                writematrix(value,workbook,'Sheet',sheetName);
            elseif isstring(value)
                writecell(cellstr(value),workbook,'Sheet',sheetName);
            elseif iscell(value)
                writecell(value,workbook,'Sheet',sheetName);
            elseif ischar(value)
                writecell({value},workbook,'Sheet',sheetName);
            end
        end

        function writeEcoMetadata(workbook,sheetName,metadata)
            if ~isstruct(metadata)
                writeEcoSheet(workbook,sheetName,metadata);
                return
            end
            names = fieldnames(metadata);
            if isempty(names)
                return
            end
            if isscalar(metadata)
                rows = cell(numel(names)+1,2);
                rows(1,:) = {'Field','Value'};
                for metadataIndex = 1:numel(names)
                    rows{metadataIndex+1,1} = names{metadataIndex};
                    rows{metadataIndex+1,2} = metadataText( ...
                        metadata.(names{metadataIndex}));
                end
            else
                rows = cell(numel(metadata)+1,numel(names));
                rows(1,:) = names(:).';
                for itemIndex = 1:numel(metadata)
                    for metadataIndex = 1:numel(names)
                        rows{itemIndex+1,metadataIndex} = metadataText( ...
                            metadata(itemIndex).(names{metadataIndex}));
                    end
                end
            end
            writecell(rows,workbook,'Sheet',sheetName,'Range','A1');
        end

        function value = metadataText(value)
            if isnumeric(value) || islogical(value)
                value = mat2str(value);
            elseif ischar(value) || ...
                    (isstring(value) && isscalar(value))
                value = char(string(value));
            else
                value = sprintf('<%s %s>', ...
                    class(value),mat2str(size(value)));
            end
        end

        function nm = saveRunParameterTable( ...
                modeName,outputFile,runIndex,conclusionReport,adaptiveDetails)
            [~,dn,~] = fileparts(app.meta.filename);
            saveDir = resolveSaveDir(ctx);
            nm = indexedParameterName(saveDir,dn,modeName,runIndex);
            params = buildRunParameterTable(modeName,outputFile);
            temporaryWorkbook = [tempname(saveDir),'.xlsx'];
            cleanup = onCleanup(@()deleteIfPresent(temporaryWorkbook));
            if strcmp(modeName,'CVCOCOLEGACY')
                sheetName = 'cvCOCO Legacy';
            elseif strcmp(modeName,'CVCOCO9A')
                sheetName = 'cvCOCO9A';
            elseif any(strcmp(modeName,{'CVCOCO9B','CVCOCO9'}))
                sheetName = 'cvCOCO9B';
            elseif strcmp(modeName,'CVCOCO2')
                sheetName = 'cvCOCO2';
            elseif strcmp(modeName,'CVCOCO')
                sheetName = 'cvCOCO';
            elseif strcmp(modeName,'ADAPTIVECOCO')
                sheetName = 'Adaptive COCO';
            elseif strcmp(modeName,'ADAPTIVECOCO9A')
                sheetName = 'Adaptive COCO9A';
            elseif strcmp(modeName,'ADAPTIVECOCO9B')
                sheetName = 'Adaptive COCO9B';
            elseif strcmp(modeName,'FIXEDCOCO9')
                sheetName = 'Fixed COCO9';
            elseif strcmp(modeName,'FIXEDTARGETCOCO')
                sheetName = 'Fixed-target COCO';
            else
                sheetName = 'COCO';
            end
            writecell(params,temporaryWorkbook,'Sheet',sheetName);
            if isFullRecordCocoModeName(modeName) && ...
                    ~isempty(conclusionReport)
                writeConclusionSummary(temporaryWorkbook,conclusionReport);
                writeAdaptiveAudit(temporaryWorkbook,adaptiveDetails);
                writeAdaptiveCurves(temporaryWorkbook, ...
                    app.run.corrCI,app.run.corr_h0);
            end
            [ok,message] = movefile(temporaryWorkbook,nm,'f');
            if ~ok
                error('eCOCOGUI:AtomicSaveFailed', ...
                    'Could not finalize the parameter workbook: %s',message);
            end
            clear cleanup
        end

        function params = buildRunParameterTable(modeName,outputFile)
            [~,outBase,outExt] = fileparts(outputFile);
            outputName = [outBase,outExt];
            params = repmat({''},45,6);
            params(1,2) = {'Detailed Parameters Used in Data Processing by Acycle'};
            params(2,2:6) = {'Version','Designed by','Institute','E-mail','Date'};
            runTimestamp = char(datetime('now', ...
                'Format','yyyy-MM-dd HH:mm:ss'));
            params(3,2:6) = {'v1.2','Mingsong Li','Peking University', ...
                'msli@pku.edu.cn',runTimestamp};
            params(5,2:5) = {'Tools','Items','Parameters','Explanations'};

            params(7,:) = {'', 'COCO/eCOCO','Input file name',app.meta.filename,'',''};
            params(8,:) = {'', '', 'Zero padding',app.pad,'',''};
            params(9,:) = {'', '', 'Number of slices',sliceParameterValue(modeName),'Disabled for cvCOCO',''};
            params(10,:) = {'', '', 'Remove red noise model',yesno(app.CRed.Value),'Select Yes or No',''};
            params(11,:) = {'', '', 'Red noise removal method',redMethodName(),'',''};
            params(12,:) = {'', '', 'Test sedimentation rate: minimum',app.sedmin,'',''};
            params(13,:) = {'', '', 'Test sedimentation rate: requested maximum',app.sedmax,'The colon grid may end below this value',''};
            params(14,:) = {'', '', 'Test sedimentation rate: step',app.sedstep,'',''};
            params(15,:) = {'', '', 'Median age of data',app.age,'',''};
            params(16,:) = {'', '', 'Maximum temporal frequency used (cycle/kyr)',app.f2,'',''};
            params(17,:) = {'', '', 'Astronomical solution',astronomicalSolutionName(),'Farhat+2022 vs. User-defined period',''};
            params(18,:) = {'', '', 'User-defined period',userPeriodValue(),'',''};
            params(19,:) = {'', '', 'Correlation method',iff(app.corrmethod==1,'Pearson','Spearman'),'',''};
            params(20,:) = {'', 'COCO','Selected COCO method',selectedCocoMethod(modeName), ...
                'cvCOCO / Adaptive COCO / Fixed-target COCO',''};
            params(21,:) = {'', 'COCO','Target mode',cocoTargetModeName(modeName), ...
                ['cvCOCO and Adaptive COCO use method-B four-group ', ...
                 'areas with leakage-matrix NNLS and a coherent ', ...
                 'nine-term target; Fixed-target COCO uses preset weights'],''};
            params(22,:) = {'', 'COCO','Fixed target amplitude weights',fixedTargetWeightValue(modeName),'Eccentricity / obliquity / precession',''};
            params(23,:) = {'', '', 'Monte Carlo iterations',app.nsim,'',''};
            params(24,:) = {'', 'cvCOCO','Split and validation rule',cvParameterValue(modeName, ...
                'Depth midpoint; bidirectional two-fold held-out validation'),'For cvCOCO only',''};
            params(25,:) = {'', 'cvCOCO','Trained target structure', ...
                cvTrainingTargetValue(modeName),'For cvCOCO only',''};
            params(26,:) = {'', 'cvCOCO','Symmetric statistic',cvParameterValue(modeName, ...
                'min(max rho A-to-B, max rho B-to-A)'),'For cvCOCO only',''};
            params(27,:) = {'', 'cvCOCO','Monte Carlo batch size',cvParameterValue(modeName,app.cvBatchSize),'For cvCOCO only',''};
            params(28,:) = {'', 'COCO','Random seed',cocoSeedValue(modeName),'Local RNG; restored after the run',''};
            params(29,:) = {'', 'cvCOCO','Split depth (m)',cvParameterValue(modeName,cvSplitDepthValue()),'For cvCOCO only',''};
            params(30,:) = {'', 'cvCOCO','Secondary p_sym',cvResultValue(modeName,'pSym'), ...
                'Joint statistic; does not override directional global-p failure',''};
            params(31,:) = {'', 'cvCOCO','Directional p_A',cvResultValue(modeName,'pA'), ...
                'B trains; Segment A is held out; rate-search corrected',''};
            params(32,:) = {'', 'cvCOCO','Directional p_B',cvResultValue(modeName,'pB'), ...
                'A trains; Segment B is held out; rate-search corrected',''};
            params(33,:) = {'', 'cvCOCO','Monte Carlo null model',cvParameterValue(modeName, ...
                ['Independent segment-specific stationary AR(1) nulls; ', ...
                 'repeat training, frozen-target validation, and rate search']), ...
                'For cvCOCO only',''};
            params(34,:) = {'', 'eCOCO','Selected eCOCO method', ...
                ecoCalcModeName(modeName), ...
                'Adaptive eCOCO / Cross-fitted eCOCO',''};
            params(35,:) = {'', 'eCOCO','Target update interval', ...
                ecoAnchorFractionValue(modeName), ...
                'Fraction of window width; Cross-fitted eCOCO only',''};
            params(36,:) = {'', 'eCOCO','Zero padding edge',ecoPadEdgeValue(modeName),'For eCOCO only',''};
            params(37,:) = {'', 'eCOCO','Sliding window size',ecoValue(modeName,app.window),'For eCOCO only',''};
            params(38,:) = {'', 'eCOCO','Sliding window step',ecoValue(modeName,app.step),'For eCOCO only',''};
            params(39,:) = {'', '', 'Output file name',outputName,'',''};
            params(40,:) = {'', '', 'Show input/target periodograms',yesno(app.CShowPeriod.Value),'COCO only',''};
            params(41,:) = {'', '', 'Maximum displayed data frequency (cycle/m)', ...
                displayedFrequencyParameter(modeName), ...
                'Adaptive/Fixed COCO and eCOCO display only; not used by cvCOCO',''};
            params(42,:) = {'', '', 'Depth unit used internally','m','Supported input depth units are converted to metres',''};
            params(43,:) = {'', '', 'Test sedimentation rate: actual final grid value',actualSedRateMaximum(),'',''};
            params(44,:) = {'', '', 'Input depth unit',app.meta.input_unit,'Converted before preprocessing',''};
            params(45,:) = {'', '', 'Input-depth multiplier to metres',app.meta.depth_scale_to_m,'',''};
        end

        function nm = indexedParameterName(saveDir,dn,modeName,runIndex)
            if nargin >= 4 && ~isempty(runIndex) && isfinite(runIndex)
                nm = fullfile(saveDir,sprintf('%s-%s-parameters-%d.xlsx',dn,modeName,runIndex));
                if ~exist(nm,'file')
                    return
                end
            end

            for k = 1:9999
                nm = fullfile(saveDir,sprintf('%s-%s-parameters-%d.xlsx',dn,modeName,k));
                if ~exist(nm,'file')
                    return;
                end
            end
            nm = uniqueName(fullfile(saveDir,sprintf('%s-%s-parameters.xlsx',dn,modeName)));
        end

        function s = yesno(tf)
            if tf, s = 'Yes'; else, s = 'No'; end
        end

        function s = redMethodName()
            if app.CRed.Value
                s = app.DRed.Value;
            else
                s = 'NA';
            end
        end

        function s = astronomicalSolutionName()
            if app.RUser.Value
                s = 'User-defined period';
            else
                s = 'Farhat+2022';
            end
        end

        function v = userPeriodValue()
            if app.RUser.Value
                v = orbitString(app.orbit9);
            else
                v = 'NA';
            end
        end

        function v = ecoCalcModeName(modeName)
            if strcmp(modeName,'ECOCO')
                v = iff(app.ecocoCalcMode==1, ...
                    'Adaptive eCOCO','Cross-fitted eCOCO');
            else
                v = 'NA';
            end
        end

        function v = ecoAnchorFractionValue(modeName)
            if strcmp(modeName,'ECOCO') && app.ecocoCalcMode == 2
                v = sprintf('%.2g W',app.anchorFraction);
            else
                v = 'NA';
            end
        end

        function v = cocoTargetModeName(modeName)
            if strcmp(modeName,'ADAPTIVECOCO')
                v = ['method-B four-group band areas with leakage-matrix ', ...
                    'NNLS in a coherent nine-term adaptive target'];
            elseif strcmp(modeName,'FIXEDTARGETCOCO')
                v = 'coherent nine-term fixed target';
            elseif isFullRecordCocoModeName(modeName)
                v = app.cocoTargetMode;
            elseif strcmp(modeName,'CVCOCO')
                v = ['four group-band area amplitudes, leakage-matrix ', ...
                    'NNLS, and coherent nine-term target ', ...
                    '(bidirectional held-out)'];
            elseif strcmp(modeName,'CVCOCO9A')
                v = ['nine per-orbit +/-1-Rayleigh peak amplitudes in a ', ...
                    'coherent nine-term target (bidirectional held-out)'];
            elseif any(strcmp(modeName,{'CVCOCO9B','CVCOCO9'}))
                v = ['four group-band area amplitudes, leakage-matrix ', ...
                    'NNLS, and coherent nine-term target ', ...
                    '(bidirectional held-out)'];
            elseif strcmp(modeName,'CVCOCOLEGACY')
                v = ['legacy coherent nine-term adaptive target ', ...
                    '(bidirectional held-out compatibility analysis)'];
            elseif strcmp(modeName,'CVCOCO2')
                v = 'band-integrated four-group target (bidirectional cross-validation)';
            else
                v = 'NA';
            end
        end

        function v = selectedCocoMethod(modeName)
            if strcmp(modeName,'ECOCO')
                v = 'NA';
            elseif strcmp(modeName,'CVCOCO')
                v = 'cvCOCO';
            elseif strcmp(modeName,'ADAPTIVECOCO')
                v = 'Adaptive COCO';
            elseif strcmp(modeName,'FIXEDTARGETCOCO')
                v = 'Fixed-target COCO';
            elseif strcmp(modeName,'CVCOCO9A')
                v = 'cvCOCO9A';
            elseif any(strcmp(modeName,{'CVCOCO9B','CVCOCO9'}))
                v = 'cvCOCO9B';
            elseif strcmp(modeName,'CVCOCOLEGACY')
                v = 'cvCOCO Legacy';
            elseif strcmp(modeName,'CVCOCO2')
                v = 'cvCOCO2';
            else
                v = app.DCOCOMethod.Value;
            end
        end

        function v = fixedTargetWeightValue(modeName)
            if (strcmp(modeName,'COCO') && strcmp(app.cocoTargetMode,'fixed')) || ...
                    any(strcmp(modeName,{'FIXEDCOCO9','FIXEDTARGETCOCO'}))
                v = '1.0 / 0.8 / 0.6';
            else
                v = 'NA';
            end
        end

        function v = sliceParameterValue(modeName)
            if isCVModeName(modeName) || strcmp(modeName,'ECOCO')
                v = 'NA';
            else
                v = app.slices;
            end
        end

        function v = cvParameterValue(modeName,value)
            if isCVModeName(modeName)
                v = value;
            else
                v = 'NA';
            end
        end

        function v = cvTrainingTargetValue(modeName)
            if strcmp(modeName,'CVCOCOLEGACY')
                v = ['Nine coherent orbital terms trained adaptively; ', ...
                    'four group-RMS weights frozen for validation'];
            elseif strcmp(modeName,'CVCOCO9A')
                v = ['Nine +/-1-Rayleigh-band peak amplitudes calibrated ', ...
                    'per orbit, normalized, and frozen for coherent validation'];
            elseif any(strcmp(modeName,{'CVCOCO9B','CVCOCO9'}))
                v = ['Four leakage-corrected group amplitudes expanded ', ...
                    'to nine coherently summed orbital terms'];
            elseif strcmp(modeName,'CVCOCO')
                v = ['Four leakage-corrected group amplitudes expanded ', ...
                    'to nine coherently summed orbital terms'];
            elseif isCVModeName(modeName)
                v = 'Long eccentricity / short eccentricity / obliquity / precession';
            else
                v = 'NA';
            end
        end

        function v = cvResultValue(modeName,fieldName)
            v = 'NA';
            if isCVModeName(modeName) && isstruct(app.run.cv) && ...
                    isfield(app.run.cv,fieldName)
                candidate = app.run.cv.(fieldName);
                if isscalar(candidate) && (isnumeric(candidate) || islogical(candidate))
                    v = candidate;
                end
            end
        end

        function tf = isCVModeName(modeName)
            tf = any(strcmp(modeName, ...
                {'CVCOCO','CVCOCO9A','CVCOCO9B','CVCOCO9', ...
                 'CVCOCOLEGACY','CVCOCO2'}));
        end

        function tf = isFullRecordCocoModeName(modeName)
            tf = any(strcmp(modeName, ...
                {'COCO','ADAPTIVECOCO','ADAPTIVECOCO9A', ...
                 'ADAPTIVECOCO9B','FIXEDTARGETCOCO','FIXEDCOCO9'}));
        end

        function v = cvSeedValue()
            v = app.cvSeed;
            if isstruct(app.run.cv) && isfield(app.run.cv,'seed') && ~isempty(app.run.cv.seed)
                v = app.run.cv.seed;
            end
        end

        function v = cocoSeedValue(modeName)
            if isCVModeName(modeName)
                v = cvSeedValue();
            elseif isFullRecordCocoModeName(modeName)
                v = app.adaptiveSeed;
                if isstruct(app.run.adaptiveDetails) && ...
                        isfield(app.run.adaptiveDetails,'seed')
                    v = app.run.adaptiveDetails.seed;
                end
            else
                v = 'NA';
            end
        end

        function v = selectedPadType()
            switch app.DPadEdge.Value
                case 'mirror'
                    v = 2;
                case 'mean'
                    v = 3;
                case 'random'
                    v = 4;
                otherwise
                    v = 1;
            end
        end

        function v = displayedFrequencyParameter(modeName)
            if isCVModeName(modeName)
                v = 'NA';
            else
                v = app.fmaxdata;
            end
        end

        function v = actualSedRateMaximum()
            nRate = floor((app.sedmax-app.sedmin)/app.sedstep)+1;
            v = app.sedmin+(max(1,nRate)-1)*app.sedstep;
        end

        function v = cvSplitDepthValue()
            v = 'NA';
            if isstruct(app.run.cv) && isfield(app.run.cv,'splitDepth') && ~isempty(app.run.cv.splitDepth)
                v = app.run.cv.splitDepth;
            end
        end

        function v = ecoPadEdgeValue(modeName)
            if strcmp(modeName,'ECOCO')
                if app.CPadEdge.Value
                    v = app.DPadEdge.Value;
                else
                    v = 'No';
                end
            else
                v = 'NA';
            end
        end

        function v = ecoValue(modeName,value)
            if strcmp(modeName,'ECOCO')
                v = value;
            else
                v = 'NA';
            end
        end

        function [ageModel,timeDomainData] = buildAgeModelFromTrackedSR(rawData,sr_p)
            rawData = rawData(:,1:min(2,size(rawData,2)));
            rawData = rawData(all(isfinite(rawData),2),:);
            rawData = sortrows(rawData,1);

            srTrack = sr_p(:,[1,2,7,8]);
            srTrack = srTrack(isfinite(srTrack(:,1)) & isfinite(srTrack(:,2)) & srTrack(:,2) > 0,:);
            srTrack = sortrows(srTrack,1);
            [trackDepth,ia] = unique(srTrack(:,1),'stable');
            trackSr = srTrack(ia,2);
            trackSrLow = srTrack(ia,3);
            trackSrHigh = srTrack(ia,4);

            depth = rawData(:,1);
            values = rawData(:,2);
            if isempty(depth)
                ageModel = [];
                timeDomainData = [];
                return
            end

            if numel(trackDepth) == 0
                srAtDepth = nan(size(depth));
                srLowAtDepth = nan(size(depth));
                srHighAtDepth = nan(size(depth));
            elseif isscalar(trackDepth)
                srAtDepth = repmat(trackSr, size(depth));
                srLowAtDepth = repmat(trackSrLow, size(depth));
                srHighAtDepth = repmat(trackSrHigh, size(depth));
            else
                srAtDepth = interpolateTrackedRate(trackDepth,trackSr,depth);
                srLowAtDepth = interpolateTrackedRate(trackDepth,trackSrLow,depth);
                srHighAtDepth = interpolateTrackedRate(trackDepth,trackSrHigh,depth);
            end

            srAtDepth(~isfinite(srAtDepth) | srAtDepth <= 0) = NaN;
            srLowAtDepth(~isfinite(srLowAtDepth) | srLowAtDepth <= 0) = NaN;
            srHighAtDepth(~isfinite(srHighAtDepth) | srHighAtDepth <= 0) = NaN;
            srBoundLow = min(srLowAtDepth,srHighAtDepth);
            srBoundHigh = max(srLowAtDepth,srHighAtDepth);

            age = cumulativeAge(depth,srAtDepth);
            ageMax = cumulativeAge(depth,srBoundLow);
            ageMin = cumulativeAge(depth,srBoundHigh);

            ageModel = [depth, age, ageMin, ageMax, srAtDepth, srBoundLow, srBoundHigh];
            timeDomainData = [age, ageMin, ageMax, values, depth];
        end

        function srAtDepth = interpolateTrackedRate(trackDepth,trackSr,depth)
            ok = isfinite(trackDepth) & isfinite(trackSr) & trackSr > 0;
            trackDepth = trackDepth(ok);
            trackSr = trackSr(ok);
            if isempty(trackDepth)
                srAtDepth = nan(size(depth));
            elseif isscalar(trackDepth)
                srAtDepth = repmat(trackSr, size(depth));
            else
                srAtDepth = interp1(trackDepth,trackSr,depth,'linear','extrap');
                before = depth < trackDepth(1);
                after = depth > trackDepth(end);
                srAtDepth(before) = trackSr(1);
                srAtDepth(after) = trackSr(end);
            end
        end

        function age = cumulativeAge(depth,srAtDepth)
            age = nan(size(depth));
            if isempty(depth)
                return
            end
            age(1) = 0;
            for ii = 2:numel(depth)
                srMid = mean(srAtDepth(ii-1:ii),'omitnan');
                if ~isfinite(srMid) || srMid <= 0
                    age(ii) = NaN;
                else
                    age(ii) = age(ii-1) + 100 * (depth(ii) - depth(ii-1)) / srMid;
                end
            end
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

        function [nm,runIndex] = indexedRunName(saveDir,baseName,ext,dn,modeName)
            for runIndex = 1:9999
                nm = fullfile(saveDir,sprintf('%s-%d%s',baseName,runIndex,ext));
                paramName = '';
                if nargin >= 5
                    paramName = fullfile(saveDir,sprintf('%s-%s-parameters-%d.xlsx',dn,modeName,runIndex));
                end
                if ~exist(nm,'file') && (isempty(paramName) || ~exist(paramName,'file'))
                    return
                end
            end

            nm = uniqueName(fullfile(saveDir,[baseName,ext]));
            runIndex = NaN;
        end
        
        function out = parseOrbit()
            if app.RUser.Value
                out = parseNumericList(app.EOrbitUser.Value);
                if isempty(out)
                    error('eCOCOGUI:InvalidUserOrbitPeriods', ...
                        'User-defined periods must be a numeric list.');
                end
            else
                age = app.age;
                orbit9 = calculate_orbit9(age);
                out = orbit9(:,2)/1000;
            end
            out = out(:)';
        end

        function r = redCode()
            if ~app.CRed.Value
                r = 0;
                return
            end
            switch app.DRed.Value
                case 'Classic AR1'
                    r = 1;
                case 'Robust AR1'
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

        function v = requireFiniteScalar(textValue,label)
            v = str2double(textValue);
            if ~isfinite(v)
                error('eCOCOGUI:InvalidNumericInput', ...
                    '%s must be one finite numeric value.',label);
            end
        end

        function v = requirePositiveScalar(textValue,label)
            v = requireFiniteScalar(textValue,label);
            if v <= 0
                error('eCOCOGUI:InvalidNumericInput', ...
                    '%s must be greater than zero.',label);
            end
        end

        function v = requireIntegerScalar(textValue,label,minimum,maximum)
            v = requireFiniteScalar(textValue,label);
            if v ~= fix(v) || v < minimum || v > maximum
                if isfinite(maximum)
                    error('eCOCOGUI:InvalidNumericInput', ...
                        '%s must be an integer from %.0f to %.0f.', ...
                        label,minimum,maximum);
                else
                    error('eCOCOGUI:InvalidNumericInput', ...
                        '%s must be an integer greater than or equal to %.0f.', ...
                        label,minimum);
                end
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
    inputUnit = char(getfielddef(ctx,'unit','m'));
    [depthScaleToM,depthInMeters] = depthUnitScaleToMetres(inputUnit);
    raw = getfielddef(ctx,'current_data',[]);
    if isempty(raw)
        raw = [0 0; 1 1; 2 0.5; 3 1.5];
    end
    if ~isnumeric(raw) || ~ismatrix(raw) || size(raw,2) < 2
        error('eCOCOGUI:InvalidInputData', ...
            'The input must be a numeric array with depth and proxy-value columns.');
    end
    raw = raw(:,1:2);
    raw = raw(all(isfinite(raw),2),:);
    raw = sortrows(raw,1);
    if ~isempty(raw)
        originalCount = size(raw,1);
        [uniqueDepth,~,group] = unique(raw(:,1),'sorted');
        raw = [uniqueDepth,accumarray(group,raw(:,2),[],@mean)];
        if size(raw,1) < originalCount
            fprintf('>> Duplicate depths were merged by averaging proxy values (%d -> %d rows).\n', ...
                originalCount,size(raw,1));
        end
    end

    if depthInMeters
        raw(:,1) = raw(:,1) .* depthScaleToM;
        if depthScaleToM ~= 1
            fprintf('\n>> COCO/eCOCO depth-unit conversion:\n');
            fprintf('   Input depth unit             : %s\n',inputUnit);
            fprintf('   Conversion factor to metres : %.12g\n',depthScaleToM);
            fprintf('   Internal depth unit          : m\n\n');
        end
    end
    
    % Periodogram-based COCO/eCOCO calculations require a uniformly sampled
    % depth series.  After sorting and merging duplicate depths, use the
    % median observed spacing to construct the regular grid.  Keeping the
    % original cleaned series in raw makes the preprocessing explicit while
    % dat is the series used by every downstream calculation.
    if depthInMeters
        dat = interpolateAtMedianSpacing(raw);
    else
        dat = raw;
    end
    meta = struct();
    meta.input_unit = inputUnit;
    meta.depth_scale_to_m = depthScaleToM;
    meta.depthInMeters = depthInMeters;
    if depthInMeters
        meta.unit = 'm';
    else
        meta.unit = inputUnit;
    end
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

function [factor,isSupported] = depthUnitScaleToMetres(unit)
unit = lower(strtrim(char(unit)));
factor = NaN;
isSupported = true;
switch unit
    case {'m','meter','meters','metre','metres','米'}
        factor = 1;
    case {'dm','decimeter','decimeters','decimetre','decimetres','分米'}
        factor = 0.1;
    case {'cm','centimeter','centimeters','centimetre','centimetres','厘米'}
        factor = 0.01;
    case {'mm','millimeter','millimeters','millimetre','millimetres','毫米'}
        factor = 0.001;
    case {'ft','foot','feet','英尺'}
        factor = 0.3048;
    case {'km','kilometer','kilometers','kilometre','kilometres','千米','公里'}
        factor = 1000;
    otherwise
        isSupported = false;
end
end

function dat = interpolateAtMedianSpacing(raw)
    dat = raw;
    if size(raw,1) < 2
        return
    end

    spacing = diff(raw(:,1));
    spacing = spacing(isfinite(spacing) & spacing > 0);
    if isempty(spacing)
        return
    end

    dt = median(spacing);
    if ~isfinite(dt) || dt <= 0
        return
    end

    % Do not interpolate an already uniform series.  The tolerance absorbs
    % only floating-point roundoff in decimal depth coordinates.
    spacingTolerance = max(64 * eps(max(1,max(abs(raw(:,1))))), ...
        1e-8 * max(1,abs(dt)));
    maxSpacingDeviation = max(abs(spacing - dt));
    if maxSpacingDeviation <= spacingTolerance
        return
    end

    intervalCountExact = (raw(end,1)-raw(1,1))/dt;
    intervalCountRounded = round(intervalCountExact);
    countTolerance = 1e-10*max(1,abs(intervalCountExact));
    if abs(intervalCountExact-intervalCountRounded) <= countTolerance
        intervalCount = intervalCountRounded;
    else
        intervalCount = floor(intervalCountExact);
    end
    interpolatedPointCount = intervalCount+1;
    maximumInterpolatedPoints = 5e6;
    if ~isfinite(interpolatedPointCount) || interpolatedPointCount < 2 || ...
            interpolatedPointCount > maximumInterpolatedPoints
        error('eCOCOGUI:InterpolationGridTooLarge', ...
            ['Median-spacing interpolation would create approximately %.6g ', ...
             'points (safety limit %.6g). Inspect large gaps/outliers or ', ...
             'preprocess the record in scientifically defensible segments.'], ...
            interpolatedPointCount,maximumInterpolatedPoints);
    end
    depthEven = raw(1,1) + (0:intervalCount)'*dt;
    if numel(depthEven) < 2
        return
    end

    % Avoid leaving an endpoint microscopically different from the original
    % because of floating-point accumulation, without adding a short final
    % interval that would make the grid uneven.
    endpointTolerance = 16 * eps(max(1,max(abs(raw([1,end],1))))) * ...
        max(1,numel(depthEven));
    if abs(depthEven(end) - raw(end,1)) <= endpointTolerance
        depthEven(end) = raw(end,1);
    end

    valueEven = interp1(raw(:,1),raw(:,2),depthEven,'linear');
    dat = [depthEven,valueEven];

    maximumGapRatio = max(spacing)/dt;
    fprintf(['\n>> Full-record preprocessing for Adaptive COCO/eCOCO: ', ...
        'uneven depth spacing detected.\n']);
    fprintf(['   Note: cvCOCO does not use this full-record grid; it splits ', ...
        'the cleaned observations first and regularizes A/B separately.\n']);
    fprintf('   Original valid points        : %d\n',size(raw,1));
    fprintf('   Original depth range         : %.12g to %.12g m\n',raw(1,1),raw(end,1));
    fprintf('   Original spacing (min/median/max): %.12g / %.12g / %.12g m\n', ...
        min(spacing),dt,max(spacing));
    fprintf('   Uniformity tolerance         : %.12g m\n',spacingTolerance);
    fprintf('   Maximum spacing deviation    : %.12g m\n',maxSpacingDeviation);
    fprintf('   Largest gap / median spacing : %.12g\n',maximumGapRatio);
    if maximumGapRatio > 10
        fprintf(['   WARNING: linear interpolation bridges a gap larger than ', ...
            '10 median intervals; the AR(1) null conditions on this ', ...
            'interpolation and does not model missingness.\n']);
    end
    fprintf('   Interpolation method         : linear\n');
    fprintf('   Interpolation interval       : %.12g m\n',dt);
    fprintf('   Interpolated points          : %d\n',size(dat,1));
    fprintf('   Interpolated depth range     : %.12g to %.12g m\n\n',dat(1,1),dat(end,1));
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
        sedmin = 2*dtr*fh * 100;
    end

    fray = sedmax/(npts*dtr);
    flow = 1/max(app.orbit9);
    if fray > flow
        sedmax = npts*dtr*flow * 100;
    end

    if (sedmax-sedmin)/sedstep > 300
        sedstep = (sedmax-sedmin)/300;
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

function tf = isCvCocoTargetMode(targetMode)
tf = any(strcmp(targetMode,{'cv2','cv9a','cv9b','cv9','cvlegacy'}));
end

function tf = isAdaptiveCocoTargetMode(targetMode)
tf = any(strcmp(targetMode, ...
    {'adaptive','adaptive9a','adaptive9b','adaptive9'}));
end

function name = adaptiveCocoDisplayName(targetMode)
if strcmp(targetMode,'adaptive9b')
    name = 'Adaptive COCO';
elseif any(strcmp(targetMode,{'adaptive9a','adaptive9'}))
    name = 'Adaptive COCO9A';
else
    name = 'Adaptive COCO';
end
end

function variant = adaptiveCocoVariant(targetMode)
if strcmp(targetMode,'adaptive9b')
    variant = 'B';
elseif any(strcmp(targetMode,{'adaptive9a','adaptive9'}))
    variant = 'A';
else
    variant = 'baseline';
end
end

function report = relabelReportMethod(report,oldName,newName)
% Keep the audited numeric result intact while applying the current public
% GUI method name to human-readable report fields.
if ~isstruct(report) || ~isscalar(report)
    return
end
textFields = {'method','classification','conclusion','message'};
for fieldIndex = 1:numel(textFields)
    fieldName = textFields{fieldIndex};
    if isfield(report,fieldName) && ...
            (ischar(report.(fieldName)) || ...
            (isstring(report.(fieldName)) && isscalar(report.(fieldName))))
        report.(fieldName) = strrep(report.(fieldName),oldName,newName);
    end
end
if isfield(report,'summaryRows') && iscell(report.summaryRows)
    for cellIndex = 1:numel(report.summaryRows)
        value = report.summaryRows{cellIndex};
        if ischar(value) || (isstring(value) && isscalar(value))
            report.summaryRows{cellIndex} = strrep(value,oldName,newName);
        end
    end
end
end

function run = emptyRunState()
run = struct('ready',false,'target',[],'prt_sr',[],'out_depth',[], ...
    'out_ecc',[],'out_ep',[],'out_eci',[],'out_ecoco',[], ...
    'out_ecocorb',[],'out_norbit',[],'sr_p',[],'corrCI',[], ...
    'corr_h0',[],'corry',[],'adaptiveDetails',[],'ecoDetails',[], ...
    'ecoMethod','','anchorFraction',NaN,'cv',[], ...
    'conclusion',[],'cocoFigure',[]);
end

function values = parseNumericList(textValue)
textValue = char(string(textValue));
textValue = regexprep(textValue,'[\[\],;]',' ');
if ~isempty(regexp(textValue,'[^0-9eE+\-.\s]','once'))
    values = [];
    return
end
values = sscanf(textValue,'%f')';
end

function value = detailValue(details,name,fallback)
value = fallback;
if isstruct(details) && isfield(details,name) && ~isempty(details.(name))
    value = details.(name);
end
end

function deleteIfPresent(filename)
if ischar(filename) || (isstring(filename) && isscalar(filename))
    filename = char(filename);
    if isfile(filename)
        try
            delete(filename);
        catch
        end
    end
end
end

function p = figurePos(ctx)
monzoom = getfielddef(ctx,'MonZoom',1);
sc = get(groot,'ScreenSize');
p = [0.38*sc(3), 0.08*sc(4), 0.46*sc(3), 0.84*sc(4)] .* monzoom;
p = round(p);
% Reduce overall GUI size by ~20% compared with the previous enlarged layout.
if p(3) < 1024, p(3) = 1024; end
if p(4) < 976, p(4) = 976; end
end

function refreshMainListbox(ctx,dirpath)
    listbox = getfielddef(ctx,'listbox_acmain',[]);
    editdir = getfielddef(ctx,'edit_acfigmain_dir',[]);
    if isempty(listbox) || ~isgraphics(listbox)
        return
    end
    if nargin < 2 || isempty(dirpath) || ~isfolder(dirpath)
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
            val1 = getSortMode(ctx,listbox);
            switch val1
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
        if ~isempty(editdir) && isgraphics(editdir)
            set(editdir,'String',dirpath);
        end
        syncAcPwd(dirpath);
        if exist('ac_update_listbox_acmain','file') == 2
            ac_update_listbox_acmain(listbox,names,isDir);
        elseif isempty(names)
            set(listbox,'String',{},'Value',[]);
        else
            set(listbox,'String',names,'Value',1);
        end
        drawnow limitrate;
    catch
    end
end

function val1 = getSortMode(ctx,listbox)
val1 = getfielddef(ctx,'val1',4);
try
    mainFig = ancestor(listbox,'figure');
    mainHandles = guidata(mainFig);
    if isstruct(mainHandles) && isfield(mainHandles,'val1') && ~isempty(mainHandles.val1)
        val1 = mainHandles.val1;
    end
catch
end
end

function syncAcPwd(dirpath)
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

function saveDir = resolveSaveDir(ctx)
saveDir = pwd;
editdir = getfielddef(ctx,'edit_acfigmain_dir',[]);
if ~isempty(editdir) && isgraphics(editdir)
    try
        p = get(editdir,'String');
        if iscell(p), p = p{1}; end
        if isstring(p), p = char(p); end
        if ischar(p)
            p = strtrim(p);
            if ~isempty(p) && isfolder(p)
                saveDir = p;
                return
            end
        end
    catch
    end
end
try
    acPwdFile = which('ac_pwd.txt');
    if ~isempty(acPwdFile)
        p = strtrim(fileread(acPwdFile));
        if ~isempty(p) && isfolder(p)
            saveDir = p;
        end
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
