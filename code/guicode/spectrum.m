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
        app.langChoice = getContextField(ctx,'lang_choice',0);
        app.langId = getContextField(ctx,'lang_id',{});
        app.langVar = getContextField(ctx,'lang_var',{});
        app.mainUnitSelection = getContextField( ...
            ctx,'main_unit_selection',0);
        app.method = "Multi-taper method";
        app.activeMethod = "";
        app.nyquist = estimateNyquist(app.data);
        app.isUneven = acycleSamplingIsUneven(app.data(:,1));
        app.mtmNoiseState = struct('Robust',true,'Classic',false, ...
            'Ftest',false,'Swa',~app.isUneven);
        app.periodogramNoiseState = struct('Classic',false);
        app.lombNoiseState = struct('Robust',true,'Classic',false);
        [app.biasCorrectionRecommended,app.biasCorrectionFitMaximum] = ...
            recommendUltraHighResolutionBiasCorrection( ...
            app.data,app.nyquist,~app.isUneven);

        app.UIFigure = uifigure('Name',['Acycle: ',localizedText( ...
            'menu107','Spectral Analysis')],'Color',bg, ...
            'Position',[80 80 808 397],'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)doLayout();
        bindCloseShortcut();

        app.LMethod = uilabel(app.UIFigure,'Text',localizedText( ...
            'spectral01','Select method'),'FontSize',39/3,'BackgroundColor',bg);
        defaultMethod = 'Multi-taper method';
        if app.isUneven
            defaultMethod = 'Lomb-Scargle spectrum';
            app.method = "Lomb-Scargle spectrum";
        end
        app.DropMethod = uidropdown(app.UIFigure, ...
            'Items',{'Multi-taper method','Periodogram','Lomb-Scargle spectrum'}, ...
            'Value',defaultMethod,'Tag','spectrumMethodDropdown', ...
            'ValueChangedFcn',@(~,~)onMethodChanged());

        app.PanelMethod = uipanel(app.UIFigure,'Title',localizedText( ...
            'spectral02','Method'),'BackgroundColor',bg);
        app.BGNW = uibuttongroup(app.PanelMethod,'BorderType','none','BackgroundColor',bg);
        app.RBNwPreset = uiradiobutton(app.BGNW,'Text','', 'Value',true);
        app.RBNwCustom = uiradiobutton(app.BGNW,'Text','', ...
            'Tag','spectrumCustomNwRadio');
        app.LabelNW = uilabel(app.PanelMethod,'Text',localizedText( ...
            'spectral03','Time-bandwidth product'),'BackgroundColor',bg);
        nwItems = compose('%.1f',2:0.5:8);
        nwItems(1:2:end) = compose('%.0f',2:8);
        app.DropNW = uidropdown(app.PanelMethod,'Items',cellstr(nwItems), ...
            'Value','2','Tag','spectrumNwDropdown');
        app.EditNW = uieditfield(app.PanelMethod,'text','Value','2.0', ...
            'Enable','off','Tag','spectrumCustomNwField');

        app.BGPad = uibuttongroup(app.PanelMethod,'BorderType','none','BackgroundColor',bg);
        app.RBPadMultiplier = uiradiobutton(app.BGPad,'Text','', ...
            'Tag','spectrumPaddingMultiplierRadio');
        app.RBPadExact = uiradiobutton(app.BGPad,'Text','', ...
            'Value',true,'Tag','spectrumPaddingExactRadio');
        app.LblZero = uilabel(app.PanelMethod,'Text',localizedText( ...
            'spectral04','Zeropadding'),'BackgroundColor',bg);
        app.EditPadMultiplier = uieditfield(app.PanelMethod,'text','Value','5', ...
            'Enable','off','Tag','spectrumPaddingMultiplierField');
        app.LblMul = uilabel(app.PanelMethod,'Text','x','BackgroundColor',bg);
        app.EditPadExact = uieditfield(app.PanelMethod,'text', ...
            'Value',num2str(size(app.data,1)), ...
            'Tag','spectrumPaddingExactField');

        app.BGNW.SelectionChangedFcn = @(~,~)onNwModeChanged();
        app.BGPad.SelectionChangedFcn = @(~,~)onPadModeChanged();

        app.PanelPlot = uipanel(app.UIFigure,'Title',localizedText( ...
            'spectral12','Plot: max frequency & Y'),'BackgroundColor',bg);
        app.BGFmax = uibuttongroup(app.PanelPlot,'BorderType','none','BackgroundColor',bg);
        app.RBFmaxNyq = uiradiobutton(app.BGFmax,'Text',localizedText( ...
            'spectral13','Nyquist'), ...
            'Value',~app.biasCorrectionRecommended, ...
            'Tag','spectrumFmaxNyquistRadio');
        app.RBFmaxInput = uiradiobutton(app.BGFmax,'Text',localizedText( ...
            'spectral14','Input'), ...
            'Value',app.biasCorrectionRecommended, ...
            'Tag','spectrumFmaxInputRadio');
        app.LblFmin = uilabel(app.PanelPlot,'Text',localizedText( ...
            'dd32','Freq. min'),'BackgroundColor',bg);
        app.EditFmin = uieditfield(app.PanelPlot,'text','Value','0', ...
            'Tag','spectrumFminField');
        app.LblNyq = uilabel(app.PanelPlot,'Text',num2str(app.nyquist,'%.4f'),'BackgroundColor',bg);
        initialFmax = app.nyquist;
        if app.biasCorrectionRecommended
            initialFmax = app.biasCorrectionFitMaximum;
        end
        app.EditFmax = uieditfield(app.PanelPlot,'text', ...
            'Value',num2str(initialFmax,'%.17g'), ...
            'Tag','spectrumFmaxInputField');

        app.BGFmax.SelectionChangedFcn = @(~,~)onFmaxModeChanged();

        app.CkLinearY = uicheckbox(app.PanelPlot,'Text',localizedText( ...
            'spectral15','Linear Y'),'Value',false, ...
            'ValueChangedFcn',@(~,~)onYScaleChanged('linear'));
        app.CkLogY = uicheckbox(app.PanelPlot,'Text',localizedText( ...
            'spectral16','Log Y'),'Value',true, ...
            'ValueChangedFcn',@(~,~)onYScaleChanged('log'));
        app.CkLogF = uicheckbox(app.PanelPlot,'Text',localizedText( ...
            'spectral17','log(freq.)'),'Value',false, ...
            'Tag','spectrumLogFrequencyCheckbox', ...
            'ValueChangedFcn',@(~,~)onLogFreqChanged());
        app.CkXPeriod = uicheckbox(app.PanelPlot,'Text',localizedText( ...
            'spectral18','X in period'),'Value',false, ...
            'Tag','spectrumPeriodCheckbox', ...
            'ValueChangedFcn',@(~,~)onXPeriodChanged());

        app.PanelRed = uipanel(app.UIFigure,'Title',localizedText( ...
            'spectral05','Red noise'),'BackgroundColor',bg);
        app.CkRobust = uicheckbox(app.PanelRed,'Text',localizedText( ...
            'spectral06','Robust AR(1)'),'Value',true, ...
            'FontWeight','bold','Tag','spectrumRobustCheckbox');
        app.CkClassic = uicheckbox(app.PanelRed,'Text',localizedText( ...
            'spectral07','Classic AR(1)'), ...
            'Value',false,'Tag','spectrumClassicCheckbox');
        app.CkFtest = uicheckbox(app.PanelRed,'Text',localizedText( ...
            'spectral08','F-test & Ampl.'), ...
            'Value',false,'Tag','spectrumFtestCheckbox');
        app.CkSWA = uicheckbox(app.PanelRed, ...
            'Text',localizedText('spectral21','Smoothed Window Averages'), ...
            'Value',~app.isUneven, ...
            'FontWeight','bold','Tag','spectrumSwaCheckbox');
        app.CkBPL = uicheckbox(app.PanelRed,'Text',localizedText( ...
            'spectral10','Bending Power Law'), ...
            'Value',false,'Tag','spectrumBplCheckbox');
        app.CkPL = uicheckbox(app.PanelRed,'Text',localizedText( ...
            'spectral09','Power Law'), ...
            'Value',false,'Tag','spectrumPlCheckbox');

        app.BtnRun = uibutton(app.UIFigure,'push','Text',localizedText( ...
            'spectral20','Run'), ...
            'BackgroundColor',blue,'FontColor','white','FontWeight','bold', ...
            'Tag','spectrumRunButton', ...
            'ButtonPushedFcn',@(~,~)runSpectrum(false));
        app.BtnRunSave = uibutton(app.UIFigure,'push','Text',localizedText( ...
            'spectral19','Run & Save'), ...
            'BackgroundColor',blue,'FontColor','white','FontWeight','bold', ...
            'Tag','spectrumRunSaveButton', ...
            'ButtonPushedFcn',@(~,~)runSpectrum(true));

        setappdata(app.UIFigure,'SpectrumBiasCorrectionRecommended', ...
            app.biasCorrectionRecommended);
        setappdata(app.UIFigure,'SpectrumBiasCorrectionFitMaximum', ...
            app.biasCorrectionFitMaximum);

        doLayout();
        onMethodChanged();
        onNwModeChanged();
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
            app.BGNW.Position    = [round(0.05*pw) round(0.35*ph) round(0.58*pw) round(0.50*ph)];
            % Keep the padding group below BGNW. On macOS, a borderless
            % uibuttongroup still paints its background and can clip the
            % lower time-bandwidth radio button when the groups overlap.
            app.BGPad.Position   = [round(0.05*pw) round(0.10*ph) round(0.53*pw) round(0.23*ph)];
            app.LabelNW.Position = [round(0.05*pw) round(0.6*ph) round(0.43*pw) 34];
            app.DropNW.Position  = [round(0.66*pw) round(0.6*ph) round(0.33*pw) 30];

            ngpw = app.BGNW.Position(3); ngph = app.BGNW.Position(4);
            app.RBNwPreset.Position = [round(0.86*ngpw) round(0.50*ngph) 26 26];
            app.RBNwCustom.Position = [round(0.86*ngpw) round(0.10*ngph) 26 26];
            app.EditNW.Position = [round(0.66*pw) round(0.4*ph) round(0.33*pw) 30];

            gpw = app.BGPad.Position(3); gph = app.BGPad.Position(4);
            app.LblZero.Position = [round(0.05*pw) round(0.3*ph) round(0.27*pw) 36];
            app.RBPadMultiplier.Position = [round(0.05*gpw) round(0.05*gph) 26 26];
            app.EditPadMultiplier.Position = [round(0.19*pw) round(0.1*ph) round(0.15*pw) 30];
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
                uistack(app.DropNW,'top');
                uistack(app.EditNW,'top');
                uistack(app.EditPadMultiplier,'top');
                uistack(app.EditPadExact,'top');
                uistack(app.EditFmin,'top');
                uistack(app.EditFmax,'top');
            catch
            end
        end

        function onMethodChanged()
            if strlength(app.activeMethod) > 0
                saveActiveMethodNoiseState();
            end
            app.method = string(app.DropMethod.Value);
            isMtm = contains(lower(app.method),'multi');
            isPeriodogram = contains(lower(app.method),'periodogram');
            isLomb = contains(lower(app.method),'lomb');

            if isMtm
                app.CkRobust.Value = app.mtmNoiseState.Robust;
                app.CkClassic.Value = app.mtmNoiseState.Classic;
                app.CkFtest.Value = app.mtmNoiseState.Ftest;
                app.CkSWA.Value = app.mtmNoiseState.Swa;
                if app.isUneven
                    warning('spectrum:unevenData', ...
                        ['Sampling may be uneven: Multi-taper analysis ', ...
                         'may be unreliable.']);
                end
                app.DropNW.Enable = 'on';
                app.RBNwPreset.Enable = 'on';
                app.RBNwCustom.Enable = 'on';
                app.CkRobust.Enable = 'on';
                app.CkClassic.Enable = 'on';
                app.CkClassic.Text = localizedText( ...
                    'spectral07','Classic AR(1)');
                app.CkFtest.Visible = 'on';
                app.CkSWA.Visible = 'on';
            elseif isPeriodogram
                app.CkRobust.Value = false;
                app.CkClassic.Value = app.periodogramNoiseState.Classic;
                app.CkFtest.Value = false;
                app.CkSWA.Value = false;
                if app.isUneven
                    warning('spectrum:unevenData','Sampling may be uneven: Periodogram may be unreliable.');
                end
                app.DropNW.Enable = 'off';
                app.EditNW.Enable = 'off';
                app.RBNwPreset.Enable = 'off';
                app.RBNwCustom.Enable = 'off';
                app.CkRobust.Enable = 'off';
                app.CkClassic.Enable = 'on';
                app.CkClassic.Text = localizedText( ...
                    'spectral07','Classic AR(1)');
                app.CkFtest.Visible = 'off';
                app.CkSWA.Visible = 'off';
            elseif isLomb
                app.CkRobust.Value = app.lombNoiseState.Robust;
                app.CkClassic.Value = app.lombNoiseState.Classic;
                app.CkFtest.Value = false;
                app.CkSWA.Value = false;
                app.DropNW.Enable = 'off';
                app.EditNW.Enable = 'off';
                app.RBNwPreset.Enable = 'off';
                app.RBNwCustom.Enable = 'off';
                app.CkRobust.Enable = 'on';
                app.CkClassic.Enable = 'on';
                app.CkClassic.Text = localizedText( ...
                    'spectral11','White noise');
                app.CkFtest.Visible = 'off';
                app.CkSWA.Visible = 'off';
            end
            app.activeMethod = app.method;
            if isMtm
                onNwModeChanged();
            end
        end

        function saveActiveMethodNoiseState()
            activeMethod = lower(app.activeMethod);
            if contains(activeMethod,'multi')
                app.mtmNoiseState.Robust = app.CkRobust.Value;
                app.mtmNoiseState.Classic = app.CkClassic.Value;
                app.mtmNoiseState.Ftest = app.CkFtest.Value;
                app.mtmNoiseState.Swa = app.CkSWA.Value;
            elseif contains(activeMethod,'periodogram')
                app.periodogramNoiseState.Classic = ...
                    app.CkClassic.Value;
            elseif contains(activeMethod,'lomb')
                app.lombNoiseState.Robust = app.CkRobust.Value;
                app.lombNoiseState.Classic = app.CkClassic.Value;
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
            % Period coordinates may be shown on either a linear or log axis.
        end

        function onNwModeChanged()
            isCustom = app.BGNW.SelectedObject == app.RBNwCustom;
            isMtm = contains(lower(app.method),'multi');
            app.DropNW.Enable = ternary(isMtm && ~isCustom,'on','off');
            app.EditNW.Enable = ternary(isMtm && isCustom,'on','off');
        end

        function onPadModeChanged()
            app.EditPadMultiplier.Enable = ternary( ...
                app.BGPad.SelectedObject == app.RBPadMultiplier,'on','off');
            app.EditPadExact.Enable = ternary(app.BGPad.SelectedObject == app.RBPadExact,'on','off');
        end

        function onFmaxModeChanged()
            app.EditFmax.Enable = ternary(app.BGFmax.SelectedObject == app.RBFmaxInput,'on','off');
        end

        function value = localizedText(key,fallback)
            value = fallback;
            if ~(isnumeric(app.langChoice) && isscalar(app.langChoice) && ...
                    isfinite(app.langChoice) && app.langChoice > 0) || ...
                    isempty(app.langId) || isempty(app.langVar)
                return
            end
            [found,index] = ismember(key,app.langId);
            if found && index > 0 && index <= numel(app.langVar) && ...
                    ~isempty(app.langVar{index})
                value = char(string(app.langVar{index}));
            end
        end

        function runSpectrum(saveResult)
            try
                data = app.data;
                if size(data,2) < 2 || size(data,1) < 8
                    alertUser('Data format invalid.','Spectrum');
                    return;
                end
                x = data(:,1);
                y = data(:,2) - mean(data(:,2),'omitnan');
                dt = median(diff(x));
                if ~(isfinite(dt) && dt > 0)
                    alertUser('Sampling rate invalid.','Spectrum');
                    return;
                end

                fmin = str2double(app.EditFmin.Value);
                if ~isfinite(fmin)
                    alertUser( ...
                        'fmin must be a finite number.','Spectrum');
                    return;
                end
                fmin = max(0,fmin);
                fmax = app.nyquist;
                if app.BGFmax.SelectedObject == app.RBFmaxInput
                    fmax = str2double(app.EditFmax.Value);
                end
                if ~(isfinite(fmax) && fmax > fmin)
                    alertUser( ...
                        'fmax must be finite and > fmin.', ...
                        'Spectrum');
                    return;
                end

                nw = selectedNw();
                if contains(lower(app.method),'multi') && ...
                        ~(isfinite(nw) && nw >= 1 && ...
                        nw < numel(y)/2 && ...
                        (nw == 1 || nw >= 1.25))
                    alertUser( ...
                        ['Time-bandwidth product must be 1, or at least ', ...
                         '1.25 and less than half the data length.'], ...
                        'Spectrum');
                    return;
                end
                if contains(lower(app.method),'multi') && ...
                        app.CkFtest.Value && (nw < 1.5 || ...
                        abs((2*nw-1)-round(2*nw-1)) > ...
                        eps(max(1,abs(2*nw-1))))
                    alertUser( ...
                        ['F-test requires NW >= 1.5 in 0.5 increments ', ...
                         'so that at least two tapers are available.'], ...
                        'Spectrum');
                    return;
                end
                nfft = chooseNfft(numel(y));
                if ~isfinite(nfft)
                    alertUser( ...
                        ['Zero padding must be a positive multiplier, or an ', ...
                         'exact positive-integer NFFT.'], ...
                        'Spectrum');
                    return;
                end
                method = char(app.method);
                robustSmoothingFraction = NaN;
                robustFitModel = NaN;
                robustBiasCorrection = NaN;
                robustFitMaximum = NaN;
                useRobustAr1 = app.CkRobust.Value && ...
                    (contains(lower(method),'multi') || ...
                    contains(lower(method),'lomb'));
                if useRobustAr1
                    [robustSmoothingFraction,robustFitModel, ...
                        robustBiasCorrection,proceed,promptMessage] = ...
                        requestRobustSettings(method);
                    if ~proceed
                        if ~isempty(promptMessage)
                            alertUser(promptMessage, ...
                                'Robust AR(1)','Icon','warning');
                        end
                        return;
                    end
                    if contains(lower(method),'multi')
                        robustFitMaximum = app.nyquist;
                        if robustBiasCorrection
                            robustFitMaximum = ...
                                app.biasCorrectionFitMaximum;
                        end
                        fitFrequency = (0:floor(nfft/2))'/(nfft*dt);
                        fitBinCount = nnz(fitFrequency <= ...
                            robustFitMaximum);
                        if round(robustSmoothingFraction*fitBinCount) < 1
                            alertUser( ...
                                ['The selected NFFT and robust-fit ', ...
                                 'frequency range contain too few ', ...
                                 'ordinates for this median smoothing ', ...
                                 'window. Increase NFFT, increase the ', ...
                                 'window, or turn bias correction off.'], ...
                                'Robust AR(1)');
                            return;
                        end
                    end
                end
                outdir = '';
                if saveResult
                    outdir = getAcWorkDir();
                    if ~isfolder(outdir)
                        outdir = pwd;
                    end
                end
                calculationMaximum = app.nyquist;
                if contains(lower(method),'lomb')
                    % Unevenly sampled Lomb spectra do not have a strict
                    % Nyquist cutoff.  v2.8 honored an explicitly larger
                    % FMAX; retain the physical Nyquist as the minimum
                    % calculation range so lower display limits do not
                    % change full-spectrum fits or saved output.
                    calculationMaximum = max(app.nyquist,fmax);
                end
                [fFull,pFull] = computeSpectrum( ...
                    method,y,x,dt,nw,nfft,calculationMaximum);
                keep = isfinite(fFull) & isfinite(pFull) & ...
                    (fFull >= fmin) & (fFull <= fmax);
                plottable = keep;
                if app.CkXPeriod.Value || app.CkLogF.Value
                    plottable = plottable & fFull > 0;
                end
                if ~any(plottable)
                    alertUser( ...
                        ['The selected frequency range contains no ', ...
                         'plottable spectral ordinates for the ', ...
                         'selected NFFT and x-axis.'], ...
                        'Spectrum');
                    return;
                end
                f = fFull(keep); p = pFull(keep);

                fig = figure('Color','white','Name',['Acycle: ', ...
                    localizedText('menu107','Spectral Analysis')], ...
                    'Tag','spectrumResultFigure');
                setappdata(fig,'SpectrumRobustSmoothingFraction', ...
                    robustSmoothingFraction);
                setappdata(fig,'SpectrumRobustFitModel',robustFitModel);
                setappdata(fig,'SpectrumRobustBiasCorrection', ...
                    robustBiasCorrection);
                setappdata(fig,'SpectrumRobustFitMaximum', ...
                    robustFitMaximum);
                ax = axes(fig); hold(ax,'on');
                plotFrequencySeries(ax,f,p,fmin,fmax, ...
                    'k-','LineWidth',1.2,'DisplayName','Power');
                plotCount = 1;
                figFtest = [];
                figFtestDiagnostics = [];
                figSwa = [];
                ftestOutput = [];
                plOutput = [];
                bplOutput = [];
                robustOutput = [];
                robustSmoothOutput = [];
                classicOutput = [];
                lombWhiteOutput = [];
                swaOutput = [];
                producedRobust = false;
                producedClassic = false;
                producedSwa = false;

                if contains(lower(method),'multi') && app.CkRobust.Value
                    try
                        [rhoM,s0M,redconfAR1,redconfML96] = redconfML( ...
                            y,dt,nw,nfft,robustFitModel, ...
                            robustSmoothingFraction, ...
                            min(fmax,app.nyquist),0, ...
                            robustFitMaximum); %#ok<ASGLU>
                        rr0 = redconfAR1(:,1) >= fmin & redconfAR1(:,1) <= fmax;
                        rr = redconfML96(:,1) >= fmin & redconfML96(:,1) <= fmax;
                        plotFrequencySeries(ax,redconfAR1(rr0,1),redconfAR1(rr0,3),fmin,fmax, ...
                            'm-.','LineWidth',1.0,'DisplayName', ...
                            smoothingLegend(robustSmoothingFraction));
                        plotFrequencySeries(ax,redconfML96(rr,1),redconfML96(rr,3),fmin,fmax,'k-','LineWidth',1.8,'DisplayName','Robust AR(1)');
                        plotFrequencySeries(ax,redconfML96(rr,1),redconfML96(rr,4),fmin,fmax,'r-','LineWidth',0.9,'DisplayName','Robust 90%');
                        plotFrequencySeries(ax,redconfML96(rr,1),redconfML96(rr,5),fmin,fmax,'r--','LineWidth',1.4,'DisplayName','Robust 95%');
                        plotFrequencySeries(ax,redconfML96(rr,1),redconfML96(rr,6),fmin,fmax,'b-.','LineWidth',1.0,'DisplayName','Robust 99%');
                        plotCount = plotCount + 5;
                        robustOutput = redconfML96;
                        robustSmoothOutput = redconfAR1(:,[1 3]);
                        producedRobust = true;
                    catch MEi
                        warning('spectrum:robustMTM','Robust AR(1) (MTM) failed: %s',MEi.message);
                    end
                elseif contains(lower(method),'lomb') && app.CkRobust.Value
                    try
                        [pR,fR,pth] = plomb_robustar1( ...
                            y,x+abs(min(x)),fmax,robustSmoothingFraction,0);
                        rr = fR >= fmin & fR <= fmax;
                        plotFrequencySeries(ax,fR(rr),pth(2,rr),fmin,fmax,'k-','LineWidth',1.8,'DisplayName','Robust AR(1)');
                        plotFrequencySeries(ax,fR(rr),pth(3,rr),fmin,fmax,'r-','LineWidth',0.9,'DisplayName','Robust 90%');
                        plotFrequencySeries(ax,fR(rr),pth(4,rr),fmin,fmax,'r--','LineWidth',1.4,'DisplayName','Robust 95%');
                        plotFrequencySeries(ax,fR(rr),pth(5,rr),fmin,fmax,'b-.','LineWidth',1.0,'DisplayName','Robust 99%');
                        plotFrequencySeries(ax,fR(rr),pth(1,rr),fmin,fmax,'m-.','LineWidth',1.0, ...
                            'DisplayName',smoothingLegend(robustSmoothingFraction));
                        plotCount = plotCount + 5;
                        robustOutput = [fR(:),pR(:),pth'];
                        producedRobust = true;
                    catch MEi
                        warning('spectrum:robustLS','Robust AR(1) (Lomb-Scargle) failed: %s',MEi.message);
                    end
                end

                if app.CkClassic.Value
                    if contains(lower(method),'multi')
                        try
                            [fc,pClassic,theo,c90,c95,c99,c999] = ...
                                redconfchi2(y,nw,dt,nfft,2);
                            cc = fc >= fmin & fc <= fmax;
                            plotFrequencySeries(ax,fc(cc),theo(cc),fmin,fmax,'k-','LineWidth',1.8,'DisplayName','Classic AR(1)');
                            plotFrequencySeries(ax,fc(cc),c90(cc),fmin,fmax,'r-','LineWidth',0.9,'DisplayName','Classic 90%');
                            plotFrequencySeries(ax,fc(cc),c95(cc),fmin,fmax,'r--','LineWidth',1.4,'DisplayName','Classic 95%');
                            plotFrequencySeries(ax,fc(cc),c99(cc),fmin,fmax,'b-.','LineWidth',1.0,'DisplayName','Classic 99%');
                            plotFrequencySeries(ax,fc(cc),c999(cc),fmin,fmax,'g--','LineWidth',1.0,'DisplayName','Classic 99.9%');
                            plotCount = plotCount + 5;
                            classicOutput = [fc(:),pClassic(:),theo(:), ...
                                c90(:),c95(:),c99(:),c999(:)];
                            producedClassic = true;
                        catch MEi
                            warning('spectrum:classicMTM','Classic AR(1) (MTM) failed: %s',MEi.message);
                        end
                    elseif contains(lower(method),'periodogram')
                        try
                            [fc,pClassic,theo,c90,c95,c99,c999] = ...
                                redconfchi2(y,1,dt,nfft,1);
                            cc = fc >= fmin & fc <= fmax;
                            plotFrequencySeries(ax,fc(cc),theo(cc),fmin,fmax,'k-','LineWidth',1.8,'DisplayName','Classic AR(1)');
                            plotFrequencySeries(ax,fc(cc),c90(cc),fmin,fmax,'r-','LineWidth',0.9,'DisplayName','Classic 90%');
                            plotFrequencySeries(ax,fc(cc),c95(cc),fmin,fmax,'r--','LineWidth',1.4,'DisplayName','Classic 95%');
                            plotFrequencySeries(ax,fc(cc),c99(cc),fmin,fmax,'b-.','LineWidth',1.0,'DisplayName','Classic 99%');
                            plotFrequencySeries(ax,fc(cc),c999(cc),fmin,fmax,'g--','LineWidth',1.0,'DisplayName','Classic 99.9%');
                            plotCount = plotCount + 5;
                            classicOutput = [fc(:),pClassic(:),theo(:), ...
                                c90(:),c95(:),c99(:),c999(:)];
                            producedClassic = true;
                        catch MEi
                            warning('spectrum:classicPer','Classic AR(1) (Periodogram) failed: %s',MEi.message);
                        end
                    elseif contains(lower(method),'lomb')
                        try
                            pfa = [0.50 0.10 0.01 0.0001];
                            pd = 1 - pfa;
                            [pLS,fLS,pth] = plomb( ...
                                y,x+abs(min(x)),calculationMaximum, ...
                                'Pd',pd);
                            rr = fLS >= fmin & fLS <= fmax;
                            if any(rr)
                                fr = fLS(rr);
                                plotFrequencySeries(ax,fr,pth(1)+0*fr,fmin,fmax,'r-','LineWidth',0.9,'DisplayName','White noise 50%');
                                plotFrequencySeries(ax,fr,pth(2)+0*fr,fmin,fmax,'r--','LineWidth',1.2,'DisplayName','White noise 90%');
                                plotFrequencySeries(ax,fr,pth(3)+0*fr,fmin,fmax,'b-.','LineWidth',1.0,'DisplayName','White noise 99%');
                                plotFrequencySeries(ax,fr,pth(4)+0*fr,fmin,fmax,'g--','LineWidth',1.0,'DisplayName','White noise 99.99%');
                                plotCount = plotCount + 4;
                                lombWhiteOutput = [fLS(:),pLS(:), ...
                                    repmat(pth(:)',numel(fLS),1)];
                                producedClassic = true;
                            end
                        catch MEi
                            warning('spectrum:classicLS','White-noise significance (Lomb) failed: %s',MEi.message);
                        end
                    end
                end

                if app.CkPL.Value
                    try
                        dof = spectrumConfidenceDegreesOfFreedom(method,nw);
                        [pl,loc90,loc95,loc99,g90,g95,g99] = ...
                            powerLawLevels(fFull,pFull,dof,numel(y)/2);
                        plOutput = [fFull,pFull,pl,loc90,loc95,loc99, ...
                            g90,g95,g99];
                        plotModelLevels(ax,fFull,pl,loc90,loc95,loc99, ...
                            g90,g95,g99,fmin,fmax,'Power law');
                        plotCount = plotCount + 7;
                    catch MEi
                        warning('spectrum:pl','Power-law test failed: %s',MEi.message);
                    end
                end

                if app.CkBPL.Value
                    try
                        dof = spectrumConfidenceDegreesOfFreedom(method,nw);
                        [bpl,loc90,loc95,loc99,g90,g95,g99] = ...
                            bendingPowerLawLevels( ...
                            fFull,pFull,dof,numel(y)/2);
                        bplOutput = [fFull,pFull,bpl,loc90,loc95,loc99, ...
                            g90,g95,g99];
                        plotModelLevels(ax,fFull,bpl,loc90,loc95,loc99, ...
                            g90,g95,g99,fmin,fmax,'Bending power law');
                        plotCount = plotCount + 7;
                    catch MEi
                        warning('spectrum:bpl','Bending-power-law test failed: %s',MEi.message);
                    end
                end

                if contains(lower(method),'multi') && app.CkFtest.Value
                    try
                        padtimes = nfft/numel(y);
                        [freq,ftest,fsig,Amp,Faz,Sig,Noi,dof,~] = ...
                            ftestmtmML([x y],nw,padtimes,0);
                        freq = freq(:); ftest = ftest(:); fsig = fsig(:);
                        Amp = Amp(:); Faz = Faz(:); Sig = Sig(:);
                        Noi = Noi(:); dof = dof(:);
                        oneSided = isfinite(freq) & freq >= 0 & ...
                            freq <= app.nyquist;
                        freq = freq(oneSided); ftest = ftest(oneSided);
                        fsig = fsig(oneSided); Amp = Amp(oneSided);
                        Faz = Faz(oneSided); Sig = Sig(oneSided);
                        Noi = Noi(oneSided); dof = dof(oneSided);
                        ftestOutput = [freq,ftest,fsig,Amp,Faz,Sig,Noi,dof];

                        figFtest = figure('Color','white','Name', ...
                            'Acycle: F-test & Amplitude', ...
                            'Tag','spectrumFtestFigure');
                        axAmp = subplot(3,1,1,'Parent',figFtest);
                        plotFrequencySeries(axAmp,freq,Amp,fmin,fmax, ...
                            'Color',[0 0.4470 0.7410],'LineWidth',1.5);
                        ylabel(axAmp,'Amplitude');
                        title(axAmp,sprintf('Amplitude & F-test: %.6g%s', ...
                            nw,char(960)));
                        axRatio = subplot(3,1,2,'Parent',figFtest);
                        plotFrequencySeries(axRatio,freq,ftest,fmin,fmax, ...
                            'k-','LineWidth',1);
                        ylabel(axRatio,'F-ratio');
                        axSig = subplot(3,1,3,'Parent',figFtest); hold(axSig,'on');
                        fsigPlot = min(fsig,0.15);
                        plotFrequencySeries(axSig,freq,fsigPlot,fmin,fmax, ...
                            'r-','LineWidth',1);
                        plotSignificanceReferenceLines(axSig,fmin,fmax);
                        ylim(axSig,[0 0.15]);
                        set(axSig,'YDir','reverse', ...
                            'YTick',[0 0.01 0.05 0.10 0.15]);
                        ylabel(axSig,'F-test significance level');
                        xlabel(axSig,frequencyAxisLabel());
                        configureFrequencyAxes([axAmp axRatio axSig],fmin,fmax);

                        figFtestDiagnostics = figure('Color','white','Name', ...
                            'Acycle: F-test Diagnostics', ...
                            'Tag','spectrumFtestDiagnosticsFigure');
                        axDof = subplot(2,1,1,'Parent',figFtestDiagnostics);
                        plotFrequencySeries(axDof,freq,dof,fmin,fmax, ...
                            'k-','LineWidth',1);
                        title(axDof,'Adaptive weighted degrees of freedom');
                        axPhase = subplot(2,1,2,'Parent',figFtestDiagnostics);
                        plotFrequencySeries(axPhase,freq,Faz,fmin,fmax, ...
                            'k-','LineWidth',1);
                        title(axPhase,'Harmonic phase');
                        ylabel(axPhase,'Phase (degrees)');
                        xlabel(axPhase,frequencyAxisLabel());
                        configureFrequencyAxes([axDof axPhase],fmin,fmax);
                    catch MEi
                        warning('spectrum:ftest','F-test failed: %s',MEi.message);
                    end
                end

                if contains(lower(method),'multi') && app.CkSWA.Value
                    try
                        padtimes = nfft/numel(y);
                        outSWA = runSpectralSwa([x y],nw,padtimes);
                        fx = outSWA(:,1);
                        rr = fx >= fmin & fx <= fmax;
                        if any(rr)
                            swaOpts = struct('selected',[1 3:10]);
                            swaUsePeriod = app.CkXPeriod.Value;
                            swaUseLog = app.CkLogF.Value;
                            figSwa = figure('Color','white', ...
                                'Name','Acycle: SWA confidence', ...
                                'Tag','spectrumSwaFigure');
                            axSwa = axes(figSwa); hold(axSwa,'on');
                            renderSwaPlot(axSwa,fx(rr),outSWA(rr,:), ...
                                swaOpts,fmin,fmax,swaUsePeriod,swaUseLog);
                            figSwaOptions = createSwaOptionsFigure( ...
                                figSwa,axSwa,fx(rr),outSWA(rr,:), ...
                                fmin,fmax,swaUsePeriod,swaUseLog);
                            figSwa.CloseRequestFcn = @(src,~) ...
                                closeSwaPlotAndOptions( ...
                                src,figSwaOptions);
                            swaOutput = outSWA;
                            producedSwa = true;
                        end
                    catch MEi
                        warning('spectrum:swa','SWA failed: %s',MEi.message);
                    end
                end

                xlabel(ax,frequencyAxisLabel());
                ylabel(ax,powerAxisLabel());
                set(ax,'XMinorTick','on','YMinorTick','on');
                if app.CkLinearY.Value
                    set(ax,'YScale','linear');
                else
                    set(ax,'YScale','log');
                end
                configureFrequencyAxes(ax,fmin,fmax);
                if plotCount > 1
                    legend(ax,'show','Location','best');
                end

                if saveResult
                    out = [fFull pFull];
                    [~,name,~] = fileparts(getDataName(ctx));
                    if isempty(outdir) || ~isfolder(outdir)
                        outdir = pwd;
                    end
                    hasFtestPdf = ~isempty(figFtest) && isgraphics(figFtest);
                    hasFtestDiagnosticsPdf = ~isempty(figFtestDiagnostics) && ...
                        isgraphics(figFtestDiagnostics);
                    hasSwaPdf = ~isempty(figSwa) && isgraphics(figSwa);
                    [dataFile,pdfFile,ftestPdfFile,ftestDiagnosticsPdfFile, ...
                        swaPdfFile,paramFile,runSuffix] = spectrumOutputNames( ...
                        outdir,name);
                    writematrix(out,dataFile,'Delimiter','tab');
                    saveFigurePdf(fig,pdfFile);
                    if hasFtestPdf
                        saveFigurePdf(figFtest,ftestPdfFile);
                    end
                    if hasFtestDiagnosticsPdf
                        saveFigurePdf(figFtestDiagnostics, ...
                            ftestDiagnosticsPdfFile);
                    end
                    if hasSwaPdf
                        saveFigurePdf(figSwa,swaPdfFile);
                    end
                    if ~isempty(ftestOutput)
                        writeFtestOutputs(outdir,name,runSuffix,ftestOutput);
                    end
                    if ~isempty(plOutput)
                        writeModelOutputs(outdir,name,runSuffix,'PL',plOutput);
                    end
                    if ~isempty(bplOutput)
                        writeModelOutputs(outdir,name,runSuffix,'BPL',bplOutput);
                    end
                    writeNoiseOutputs(outdir,name,runSuffix,method, ...
                        robustOutput,robustSmoothOutput,classicOutput, ...
                        lombWhiteOutput,swaOutput);
                    saveSpectrumParameterTable(paramFile,method,nw,nfft, ...
                        fmin,fmax,robustSmoothingFraction,robustFitModel, ...
                        robustBiasCorrection,robustFitMaximum, ...
                        producedRobust,producedClassic,producedSwa, ...
                        ~isempty(plOutput),~isempty(bplOutput), ...
                        ~isempty(ftestOutput));

                    refreshAcMainList(outdir);
                end
            catch ME
                alertUser(ME.message,'Spectrum Error');
            end
        end

        function alertUser(message,title,varargin)
            hooks = [];
            if isfield(app.ctx,'SpectrumTestHooks') && ...
                    isstruct(app.ctx.SpectrumTestHooks)
                hooks = app.ctx.SpectrumTestHooks;
            end
            if ~isempty(hooks) && isfield(hooks,'AlertFcn') && ...
                    isa(hooks.AlertFcn,'function_handle')
                feval(hooks.AlertFcn,app.UIFigure,message,title,varargin{:});
            else
                uialert(app.UIFigure,message,title,varargin{:});
            end
        end

        function renderSwaPlot(axh,xFrequency,outRows,swaOpts, ...
                fmin,fmax,usePeriod,useLog)
            if ~isgraphics(axh)
                return
            end
            legend(axh,'off');
            cla(axh);
            hold(axh,'on');
            plotSwaLines(axh,xFrequency,outRows,swaOpts,fmin,fmax, ...
                usePeriod);
            xlabel(axh,frequencyAxisLabelForMode(usePeriod));
            ylabel(axh,powerAxisLabel());
            set(axh,'YScale','log');
            set(axh,'XMinorTick','on','YMinorTick','on');
            configureFrequencyAxesForMode( ...
                axh,fmin,fmax,usePeriod,useLog);
            legend(axh,'show','Location','best');
        end

        function optionsFigure = createSwaOptionsFigure( ...
                swaFigure,axh,xFrequency,outRows,fmin,fmax, ...
                usePeriod,useLog)
            labels = {'0.01% FDR','0.1% FDR','1% FDR','5% FDR', ...
                '10% FDR','99.99% Chi2 CL','99.9% Chi2 CL', ...
                '99% Chi2 CL','95% Chi2 CL','90% Chi2 CL', ...
                'Background'};
            % Plot cases are ordered for the drawing helper; preserve the
            % v2.8 selector's visible top-to-bottom ordering here.
            plotCases = [6 5 4 3 2 11 10 9 8 7 1];
            available = true(1,11);
            defaultSelected = [1 3:10];
            for fdrCase = 2:6
                available(fdrCase) = ~isnan(outRows(1,fdrCase+7));
            end

            optionsFigure = figure('Name','FDR & Chi2 CL', ...
                'NumberTitle','off','Position',[100 100 300 350], ...
                'MenuBar','none','ToolBar','none', ...
                'Tag','spectrumSwaOptionsFigure');
            positions = linspace(320,20,numel(labels));
            for labelIndex = 1:numel(labels)
                plotCase = plotCases(labelIndex);
                uicontrol(optionsFigure, ...
                    'Style','checkbox','String',labels{labelIndex}, ...
                    'Position',[50 positions(labelIndex) 200 20], ...
                    'Tag','spectrumSwaOptionCheckbox', ...
                    'UserData',plotCase, ...
                    'Enable',ternary(available(plotCase),'on','off'), ...
                    'Value',double(available(plotCase) && ...
                    ismember(plotCase,defaultSelected)), ...
                    'Callback',@(~,~)refreshSwaFromOptions( ...
                    optionsFigure,axh,xFrequency,outRows,fmin,fmax, ...
                    usePeriod,useLog));
            end
            setappdata(optionsFigure,'SpectrumSwaFigure',swaFigure);
        end

        function refreshSwaFromOptions(optionsFigure,axh,xFrequency, ...
                outRows,fmin,fmax,usePeriod,useLog)
            if ~isgraphics(optionsFigure) || ~isgraphics(axh)
                return
            end
            controls = findall(optionsFigure, ...
                'Tag','spectrumSwaOptionCheckbox');
            selected = [];
            for controlIndex = 1:numel(controls)
                if controls(controlIndex).Value && ...
                        strcmp(controls(controlIndex).Enable,'on')
                    selected(end+1) = ...
                        controls(controlIndex).UserData; %#ok<AGROW>
                end
            end
            renderSwaPlot(axh,xFrequency,outRows, ...
                struct('selected',selected),fmin,fmax,usePeriod,useLog);
        end

        function closeSwaPlotAndOptions(swaFigure,optionsFigure)
            if ~isempty(optionsFigure) && isgraphics(optionsFigure)
                delete(optionsFigure);
            end
            if ~isempty(swaFigure) && isgraphics(swaFigure)
                delete(swaFigure);
            end
        end

        function plotSwaLines(axh,xFrequency,outRows,swaOpts, ...
                fmin,fmax,usePeriod)
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
                        plotFrequencySeriesForMode(axh,xFrequency,swa, ...
                            fmin,fmax,usePeriod,'k-','LineWidth',1.5, ...
                            'DisplayName','SWA background');
                    case 2
                        if ~isnan(clfdr(1,1))
                            plotFrequencySeriesForMode(axh,xFrequency, ...
                                clfdr(:,1),fmin,fmax,usePeriod,'m--', ...
                                'LineWidth',0.5,'DisplayName','10% FDR');
                        end
                    case 3
                        if ~isnan(clfdr(1,2))
                            plotFrequencySeriesForMode(axh,xFrequency, ...
                                clfdr(:,2),fmin,fmax,usePeriod,'r-.', ...
                                'LineWidth',2,'DisplayName','5% FDR');
                        end
                    case 4
                        if ~isnan(clfdr(1,3))
                            plotFrequencySeriesForMode(axh,xFrequency, ...
                                clfdr(:,3),fmin,fmax,usePeriod,'b--', ...
                                'LineWidth',0.5,'DisplayName','1% FDR');
                        end
                    case 5
                        if ~isnan(clfdr(1,4))
                            plotFrequencySeriesForMode(axh,xFrequency, ...
                                clfdr(:,4),fmin,fmax,usePeriod,'g-.', ...
                                'LineWidth',0.5,'DisplayName','0.1% FDR');
                        end
                    case 6
                        if ~isnan(clfdr(1,5))
                            plotFrequencySeriesForMode(axh,xFrequency, ...
                                clfdr(:,5),fmin,fmax,usePeriod,'m-.', ...
                                'LineWidth',0.5,'DisplayName','0.01% FDR');
                        end
                    case 7
                        plotFrequencySeriesForMode(axh,xFrequency,chi90, ...
                            fmin,fmax,usePeriod,'r-','LineWidth',0.5, ...
                            'DisplayName','Chi2 90%');
                    case 8
                        plotFrequencySeriesForMode(axh,xFrequency,chi95, ...
                            fmin,fmax,usePeriod,'r--','LineWidth',2, ...
                            'DisplayName','Chi2 95%');
                    case 9
                        plotFrequencySeriesForMode(axh,xFrequency,chi99, ...
                            fmin,fmax,usePeriod,'b-.','LineWidth',0.5, ...
                            'DisplayName','Chi2 99%');
                    case 10
                        plotFrequencySeriesForMode(axh,xFrequency,chi999, ...
                            fmin,fmax,usePeriod,'m-.','LineWidth',0.5, ...
                            'DisplayName','Chi2 99.9%');
                    case 11
                        plotFrequencySeriesForMode(axh,xFrequency, ...
                            chi9999,fmin,fmax,usePeriod,'g-.', ...
                            'LineWidth',0.5,'DisplayName','Chi2 99.99%');
                end
            end

            plotFrequencySeriesForMode(axh,xFrequency,pxx,fmin,fmax, ...
                usePeriod,'k-','LineWidth',0.5,'DisplayName','Power');
        end

        function outputdata = runSpectralSwa(dataForSwa,nw,padtimes)
            oldDir = pwd;
            cleanupDir = tempname;
            mkdir(cleanupDir);
            cleanup = onCleanup(@()restoreAfterSwa(oldDir,cleanupDir));
            cd(cleanupDir);
            outputdata = spectralswafdr(dataForSwa,'mtm',nw,padtimes,0);
        end

        function restoreAfterSwa(oldDir,cleanupDir)
            try
                cd(oldDir);
            catch
            end
            if ~isempty(cleanupDir) && isfolder(cleanupDir)
                try
                    rmdir(cleanupDir,'s');
                catch
                end
            end
        end

        function [dataFile,pdfFile,ftestPdfFile,ftestDiagnosticsPdfFile, ...
                swaPdfFile,paramFile,runSuffix] = spectrumOutputNames( ...
                outdir,name)
            for runIndex = 1:9999
                runSuffix = sprintf('%d',runIndex);
                [dataFile,pdfFile,ftestPdfFile, ...
                    ftestDiagnosticsPdfFile,swaPdfFile,paramFile,files] = ...
                    spectrumFilesForSuffix(outdir,name,runSuffix);
                if all(cellfun(@(f)~isfile(f),files))
                    return
                end
            end

            baseSuffix = char(datetime('now', ...
                'Format','yyyyMMdd''T''HHmmssSSS'));
            fallbackIndex = 1;
            while true
                if fallbackIndex == 1
                    runSuffix = baseSuffix;
                else
                    runSuffix = sprintf('%s-%d',baseSuffix,fallbackIndex);
                end
                [dataFile,pdfFile,ftestPdfFile, ...
                    ftestDiagnosticsPdfFile,swaPdfFile,paramFile,files] = ...
                    spectrumFilesForSuffix(outdir,name,runSuffix);
                if all(cellfun(@(f)~isfile(f),files))
                    return
                end
                fallbackIndex = fallbackIndex + 1;
            end
        end

        function [dataFile,pdfFile,ftestPdfFile, ...
                ftestDiagnosticsPdfFile,swaPdfFile,paramFile,files] = ...
                spectrumFilesForSuffix(outdir,name,suffix)
            dataFile = fullfile(outdir,sprintf( ...
                '%s-spectrum-%s.txt',name,suffix));
            pdfFile = fullfile(outdir,sprintf( ...
                '%s-spectrum-%s.pdf',name,suffix));
            ftestPdfFile = fullfile(outdir,sprintf( ...
                '%s-spectrum-Ftest-%s.pdf',name,suffix));
            ftestDiagnosticsPdfFile = fullfile(outdir,sprintf( ...
                '%s-spectrum-Ftest-diagnostics-%s.pdf',name,suffix));
            swaPdfFile = fullfile(outdir,sprintf( ...
                '%s-spectrum-SWA-%s.pdf',name,suffix));
            paramFile = fullfile(outdir,sprintf( ...
                '%s-spectrum-parameters-%s.xls',name,suffix));

            files = {dataFile,pdfFile,ftestPdfFile, ...
                ftestDiagnosticsPdfFile,swaPdfFile,paramFile, ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-Ftest-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-Fsig-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-amplitude-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-phase-signal-noise-dof-%s.txt', ...
                name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-PL-local-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-PL-global-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-BPL-local-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-BPL-global-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-MTM-RobustAR1-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-Lomb-RobustAR1-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-MTM-RobustAR1-median-%s.txt', ...
                name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-MTM-ClassicAR1-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-Periodogram-ClassicAR1-%s.txt', ...
                name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-Lomb-white-noise-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-MTM-SWA-Chi2-%s.txt',name,suffix)), ...
                fullfile(outdir,sprintf( ...
                '%s-spectrum-MTM-SWA-FDR-%s.txt',name,suffix))};
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

        function writeFtestOutputs(outdir,name,suffix,data)
            writematrix(data(:,[1 2]),fullfile(outdir,sprintf( ...
                '%s-spectrum-Ftest-%s.txt',name,suffix)),'Delimiter','tab');
            writematrix(data(:,[1 3]),fullfile(outdir,sprintf( ...
                '%s-spectrum-Fsig-%s.txt',name,suffix)),'Delimiter','tab');
            writematrix(data(:,[1 4]),fullfile(outdir,sprintf( ...
                '%s-spectrum-amplitude-%s.txt',name,suffix)),'Delimiter','tab');
            writematrix(data(:,[1 5:8]),fullfile(outdir,sprintf( ...
                '%s-spectrum-phase-signal-noise-dof-%s.txt',name,suffix)), ...
                'Delimiter','tab');
        end

        function writeModelOutputs(outdir,name,suffix,modelName,data)
            writematrix(data(:,1:6),fullfile(outdir,sprintf( ...
                '%s-spectrum-%s-local-%s.txt',name,modelName,suffix)), ...
                'Delimiter','tab');
            writematrix(data(:,[1:3 7:9]),fullfile(outdir,sprintf( ...
                '%s-spectrum-%s-global-%s.txt',name,modelName,suffix)), ...
                'Delimiter','tab');
        end

        function writeNoiseOutputs(outdir,name,suffix,method, ...
                robust,robustSmooth,classic,lombWhite,swa)
            if ~isempty(robust)
                if contains(lower(method),'multi')
                    robustLabel = 'MTM-RobustAR1';
                else
                    robustLabel = 'Lomb-RobustAR1';
                end
                writematrix(robust,fullfile(outdir,sprintf( ...
                    '%s-spectrum-%s-%s.txt',name,robustLabel,suffix)), ...
                    'Delimiter','tab');
            end
            if ~isempty(robustSmooth)
                writematrix(robustSmooth,fullfile(outdir,sprintf( ...
                    '%s-spectrum-MTM-RobustAR1-median-%s.txt', ...
                    name,suffix)),'Delimiter','tab');
            end
            if ~isempty(classic)
                if contains(lower(method),'multi')
                    classicLabel = 'MTM-ClassicAR1';
                else
                    classicLabel = 'Periodogram-ClassicAR1';
                end
                writematrix(classic,fullfile(outdir,sprintf( ...
                    '%s-spectrum-%s-%s.txt',name,classicLabel,suffix)), ...
                    'Delimiter','tab');
            end
            if ~isempty(lombWhite)
                writematrix(lombWhite,fullfile(outdir,sprintf( ...
                    '%s-spectrum-Lomb-white-noise-%s.txt',name,suffix)), ...
                    'Delimiter','tab');
            end
            if ~isempty(swa)
                writematrix(swa(:,1:8),fullfile(outdir,sprintf( ...
                    '%s-spectrum-MTM-SWA-Chi2-%s.txt',name,suffix)), ...
                    'Delimiter','tab');
                writematrix(swa(:,[1:3 9:13]),fullfile(outdir,sprintf( ...
                    '%s-spectrum-MTM-SWA-FDR-%s.txt',name,suffix)), ...
                    'Delimiter','tab');
            end
        end

        function saveSpectrumParameterTable(paramFile,method,nw,nfft, ...
                fmin,fmax,robustSmoothingFraction,robustFitModel, ...
                robustBiasCorrection,robustFitMaximum, ...
                producedRobust,producedClassic,producedSwa, ...
                producedPl,producedBpl,producedFtest)
            inputName = getDataName(ctx);
            params = repmat({''},19,6);
            params(1,2) = {'Detailed Parameters Used in Data Processing by Acycle'};
            params(2,2:6) = {'Version','Designed by','Institute','E-mail','Date'};
            params(3,2:6) = {acycleVersionLabel(), ...
                'Mingsong Li','Peking University', ...
                'msli@pku.edu.cn',char(datetime('now', ...
                'Format','yyyy-MM-dd HH:mm:ss'))};
            params(5,2:5) = {'Tools','Items','Parameters','Explanations'};

            params(7,:) = {'','Spectral analysis','Input file name',inputName,'',''};
            params(8,:) = {'','','Method',method,'',''};
            params(9,:) = {'','','Time-bandwidth product',timeBandwidthText(method,nw),'',''};
            params(10,:) = {'','','Zero padding',paddingParameterText(nfft),'',''};
            params(11,:) = {'','','Frequency minimum',fmin,'',''};
            params(12,:) = {'','','Frequency maximum',fmax,'',''};

            params(14,:) = {'','Noise model','Input file name',inputName,'',''};
            params(15,:) = {'','','Method',spectrumNoiseModelName( ...
                producedRobust,producedClassic,producedSwa, ...
                producedPl,producedBpl,producedFtest),'',''};
            params(16,:) = {'','','Median smoothing window', ...
                smoothingParameterText( ...
                robustSmoothingFraction,producedRobust),'',''};
            params(17,:) = {'','','AR(1) best fit model', ...
                robustFitModelText(method,robustFitModel,producedRobust),'',''};
            params(18,:) = {'', '', ...
                'Bias correction for ultra-high resolution data', ...
                robustBiasCorrectionText(method,robustBiasCorrection, ...
                robustFitMaximum,producedRobust),'',''};
            params(19,:) = {'','','Output file name', ...
                spectrumNoiseOutputName(producedRobust, ...
                producedClassic,producedSwa,producedPl, ...
                producedBpl,producedFtest),'',''};

            writecell(params,paramFile,'Sheet','COCO');
        end

        function label = acycleVersionLabel()
            label = 'Acycle';
            versionPath = fullfile(fileparts(mfilename('fullpath')), ...
                '..','bin','ac_version.txt');
            try
                versionText = strtrim(fileread(versionPath));
                if ~isempty(regexp(versionText, ...
                        '^[0-9]+(?:\.[0-9]+)*(?:[-+][0-9A-Za-z.-]+)?$', ...
                        'once'))
                    label = ['v',versionText];
                end
            catch
            end
        end

        function [fraction,fitModel,biasCorrection,proceed,message] = ...
                requestRobustSettings(method)
            fraction = NaN;
            fitModel = NaN;
            biasCorrection = NaN;
            proceed = false;
            message = '';
            if isfield(app.ctx,'SpectrumTestHooks') && ...
                    isstruct(app.ctx.SpectrumTestHooks) && ...
                    isfield(app.ctx.SpectrumTestHooks, ...
                    'RobustSmoothingPromptFcn') && ...
                    isa(app.ctx.SpectrumTestHooks.RobustSmoothingPromptFcn, ...
                    'function_handle')
                answer = feval( ...
                    app.ctx.SpectrumTestHooks.RobustSmoothingPromptFcn);
            else
                dialogOptions.Resize = 'on';
                if contains(lower(method),'multi')
                    biasDefault = num2str(double( ...
                        app.biasCorrectionRecommended));
                    answer = inputdlg( ...
                        {localizedText('spectral26', ...
                        ['Median smoothing window: default 0.2 = 20% ', ...
                        '(recommended range 0.05-0.25)']); ...
                        localizedText('spectral27', ...
                        ['AR(1) best-fit model: 1 = linear power ', ...
                        '(default), 2 = log power']); ...
                        localizedText('spectral28', ...
                        ['Bias correction for ultra-high resolution ', ...
                        'data: 1 = on, 0 = off'])}, ...
                        localizedText('spectral25', ...
                        'Robust AR(1) Estimation'),1, ...
                        {'0.2','1',biasDefault}, ...
                        dialogOptions);
                else
                    answer = inputdlg( ...
                        {localizedText('spectral26', ...
                        ['Median smoothing window: default 0.2 = 20% ', ...
                        '(recommended range 0.05-0.25)'])}, ...
                        localizedText('spectral25', ...
                        'Robust AR(1) Estimation'),1,{'0.2'},dialogOptions);
                end
            end
            if isempty(answer)
                return
            end
            if iscell(answer)
                fractionAnswer = answer{1};
                if numel(answer) >= 2
                    fitModelAnswer = answer{2};
                else
                    fitModelAnswer = 1;
                end
                if numel(answer) >= 3
                    biasAnswer = answer{3};
                else
                    biasAnswer = app.biasCorrectionRecommended;
                end
            else
                fractionAnswer = answer;
                fitModelAnswer = 1;
                biasAnswer = app.biasCorrectionRecommended;
            end
            if isnumeric(fractionAnswer) && isscalar(fractionAnswer)
                value = double(fractionAnswer);
            else
                value = str2double(string(fractionAnswer));
            end
            % Also accept an explicit percentage such as 20 for convenience.
            if isfinite(value) && value > 1 && value <= 100
                value = value/100;
            end
            if ~(isscalar(value) && isfinite(value) && ...
                    value >= 0.05 && value <= 0.25)
                message = ['Enter a median smoothing fraction from 0.05 ', ...
                    'through 0.25 (or 5 through 25 percent).'];
                return
            end
            if isnumeric(fitModelAnswer) && isscalar(fitModelAnswer)
                fitModel = double(fitModelAnswer);
            else
                fitModel = str2double(string(fitModelAnswer));
            end
            if ~contains(lower(method),'multi')
                fitModel = 1;
                biasCorrection = NaN;
            elseif ~(isscalar(fitModel) && isfinite(fitModel) && ...
                    any(fitModel == [1 2]))
                message = ['Choose AR(1) best-fit model 1 (linear power) ', ...
                    'or 2 (log power).'];
                fitModel = NaN;
                return
            end
            if contains(lower(method),'multi')
                if islogical(biasAnswer) && isscalar(biasAnswer)
                    biasCorrection = biasAnswer;
                elseif isnumeric(biasAnswer) && isreal(biasAnswer) && ...
                        isscalar(biasAnswer)
                    biasCorrection = double(biasAnswer);
                else
                    biasCorrection = str2double(string(biasAnswer));
                end
                if ~(isscalar(biasCorrection) && ...
                        isfinite(biasCorrection) && ...
                        any(biasCorrection == [0 1]))
                    message = ['Choose bias correction 1 (on) or ', ...
                        '0 (off).'];
                    biasCorrection = NaN;
                    return
                end
                biasCorrection = logical(biasCorrection);
            end
            fraction = value;
            proceed = true;
        end

        function label = smoothingLegend(fraction)
            label = sprintf('%.6g%% median-smoothed',100*fraction);
        end

        function value = smoothingParameterText(fraction,producedRobust)
            if producedRobust && isfinite(fraction)
                value = sprintf('%.6g (%.6g%%)',fraction,100*fraction);
            else
                value = 'NA';
            end
        end

        function value = robustFitModelText(method,fitModel,producedRobust)
            if ~(producedRobust && contains(lower(method),'multi'))
                value = 'NA';
            elseif fitModel == 1
                value = 'Linear power';
            elseif fitModel == 2
                value = 'Log power';
            else
                value = 'NA';
            end
        end

        function value = robustBiasCorrectionText( ...
                method,biasCorrection,fitMaximum,producedRobust)
            if ~(producedRobust && contains(lower(method),'multi') && ...
                    (islogical(biasCorrection) || ...
                    (isnumeric(biasCorrection) && ...
                    isfinite(biasCorrection))))
                value = 'NA';
            elseif logical(biasCorrection)
                value = sprintf('On (fit <= %.15g)',fitMaximum);
            else
                value = 'Off';
            end
        end

        function value = paddingParameterText(nfft)
            if app.BGPad.SelectedObject == app.RBPadMultiplier
                multiplier = str2double(app.EditPadMultiplier.Value);
                value = sprintf('%.15g x (NFFT = %d)',multiplier,nfft);
            else
                value = sprintf('Exact NFFT = %d',nfft);
            end
        end

        function s = timeBandwidthText(method,nw)
            if contains(lower(method),'multi')
                s = [num2str(nw),char(960)];
            else
                s = 'NA';
            end
        end

        function s = spectrumNoiseModelName( ...
                producedRobust,producedClassic,producedSwa, ...
                producedPl,producedBpl,producedFtest)
            models = {};
            if producedSwa
                models{end+1} = 'Smoothed Window Averages';
            end
            if producedRobust
                models{end+1} = 'Robust AR(1)';
            end
            if producedClassic
                models{end+1} = char(app.CkClassic.Text);
            end
            if producedPl
                models{end+1} = 'Power Law';
            end
            if producedBpl
                models{end+1} = 'Bending Power Law';
            end
            if producedFtest
                models{end+1} = 'F-test & Amplitude';
            end
            if isempty(models)
                s = 'NA';
            else
                s = strjoin(models,', ');
            end
        end

        function s = spectrumNoiseOutputName( ...
                producedRobust,producedClassic,producedSwa, ...
                producedPl,producedBpl,producedFtest)
            products = {};
            if producedRobust
                products{end+1} = 'Robust AR(1) data';
            end
            if producedClassic
                products{end+1} = 'Classic/white-noise data';
            end
            if producedSwa
                products{end+1} = 'SWA FDR and Chi2 data';
            end
            if producedPl
                products{end+1} = 'Power-law local/global data';
            end
            if producedBpl
                products{end+1} = 'Bending-power-law local/global data';
            end
            if producedFtest
                products{end+1} = 'F-test, amplitude, and diagnostics data';
            end
            if isempty(products)
                s = 'NA';
            else
                s = strjoin(products,', ');
            end
        end

        function outdir = getAcWorkDir()
            outdir = '';
            if isfield(app.ctx,'SpectrumTestHooks') && ...
                    isstruct(app.ctx.SpectrumTestHooks) && ...
                    isfield(app.ctx.SpectrumTestHooks,'OutputDirectory')
                candidate = app.ctx.SpectrumTestHooks.OutputDirectory;
                if (ischar(candidate) || ...
                        (isstring(candidate) && isscalar(candidate))) && ...
                        isfolder(candidate)
                    outdir = char(candidate);
                    return
                end
            end
            try
                outdir = ac_working_directory('get',pwd);
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
                val1 = 1;
                try
                    val1 = app.ctx.val1;
                catch
                end
                try
                    mainHandles = guidata(app.ctx.listbox_acmain);
                    if isstruct(mainHandles) && isfield(mainHandles,'val1') && ...
                            ~isempty(mainHandles.val1)
                        val1 = mainHandles.val1;
                    end
                catch
                end
                sortMode = val1;
                switch sortMode
                    case {1,2,3,4,5,6}
                    otherwise
                        sortMode = 1;
                end
                d = ac_sort_dir_entries(d,sortMode);

                try
                    set(app.ctx.edit_acfigmain_dir,'String',workDir);
                catch
                end
                try
                    ac_update_listbox_acmain(app.ctx.listbox_acmain, ...
                        {d.name},[d.isdir]);
                    drawnow limitrate;
                catch
                end

                try
                    ac_working_directory('set',workDir);
                catch
                end
            catch
            end
        end

        function [f,p] = computeSpectrum(method,y,x,dt,nw,nfft,physicalNyquist)
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
                [p,f] = plomb(y,x+abs(min(x)),physicalNyquist);
            end
            f = real(f(:));
            p = real(p(:));
        end

        function [pl,loc90,loc95,loc99,g90,g95,g99] = ...
                powerLawLevels(f,p,dof,Nf)
            ff = f(:); pp = p(:);
            good = ff > 0 & isfinite(ff) & isfinite(pp) & pp > 0;
            ff = ff(good); pp = pp(good);
            if numel(ff) < 2
                error('spectrum:insufficientPowerLawData', ...
                    'At least two positive finite spectral ordinates are required.');
            end
            pf = polyfit(log(ff),log(pp),1);
            a = pf(1); k = exp(pf(2));
            pl = NaN(size(f));
            evalGood = f > 0 & isfinite(f);
            pl(evalGood) = k * f(evalGood).^a;
            loc90 = pl * chi2inv(0.90,dof)/dof;
            loc95 = pl * chi2inv(0.95,dof)/dof;
            loc99 = pl * chi2inv(0.99,dof)/dof;
            g90 = pl * chi2inv(1-0.10/Nf,dof)/dof;
            g95 = pl * chi2inv(1-0.05/Nf,dof)/dof;
            g99 = pl * chi2inv(1-0.01/Nf,dof)/dof;
        end

        function dof = spectrumConfidenceDegreesOfFreedom(method,nw)
            % Do not evaluate an inactive MTM setting for periodogram/Lomb.
            if contains(lower(method),'multi')
                dof = 2*acycleMtmTaperCount(nw);
            else
                dof = 2;
            end
        end

        function [bpl,loc90,loc95,loc99,g90,g95,g99] = ...
                bendingPowerLawLevels(f,p,dof,Nf)
            ff = f(:); pp = p(:);
            good = ff > 0 & isfinite(ff) & isfinite(pp) & pp > 0;
            ff = ff(good); pp = pp(good);
            if numel(ff) < 4
                error('spectrum:insufficientBendingPowerLawData', ...
                    'At least four positive finite spectral ordinates are required.');
            end
            % Fit the BPL in log-power space. The legacy expression fitted a
            % linear-power model directly to LOG(P) and then exponentiated
            % it, which is not a bending power law and permits invalid bend
            % frequencies. Parameter 3 is a log positive slope increment,
            % scaled by the fitted log-frequency range for conditioning.
            logFrequencyRange = log(ff(end))-log(ff(1));
            if ~(isfinite(logFrequencyRange) && logFrequencyRange > 0)
                error('spectrum:insufficientBendingPowerLawRange', ...
                    'Bending-power-law fitting requires distinct frequencies.');
            end
            logModel = @(v,fx) v(1)-v(2).*log(fx)-stableSoftplus( ...
                (exp(v(3))/logFrequencyRange).* ...
                (log(fx)-v(4)));
            initialSlopeIncrement = 2.5;
            v0 = [log(median(pp)),0.5, ...
                log(initialSlopeIncrement*logFrequencyRange), ...
                0.5*(log(ff(1))+log(ff(end)))];
            lowerBounds = [-Inf,0,log(eps),log(ff(1))];
            upperBounds = [Inf,20,log(40*logFrequencyRange),log(ff(end))];
            options = optimoptions('lsqcurvefit','Display','off');
            v = lsqcurvefit(logModel,v0,ff,log(pp), ...
                lowerBounds,upperBounds,options);
            bpl = NaN(size(f));
            evalGood = f > 0 & isfinite(f);
            bpl(evalGood) = exp(logModel(v,f(evalGood)));
            bpl = bpl(:);
            loc90 = bpl * chi2inv(0.90,dof)/dof;
            loc95 = bpl * chi2inv(0.95,dof)/dof;
            loc99 = bpl * chi2inv(0.99,dof)/dof;
            g90 = bpl * chi2inv(1-0.10/Nf,dof)/dof;
            g95 = bpl * chi2inv(1-0.05/Nf,dof)/dof;
            g99 = bpl * chi2inv(1-0.01/Nf,dof)/dof;
        end

        function value = stableSoftplus(value)
            value = max(value,0)+log1p(exp(-abs(value)));
        end

        function lineHandle = plotFrequencySeries( ...
                axh,frequency,values,fmin,fmax,varargin)
            lineHandle = plotFrequencySeriesForMode( ...
                axh,frequency,values,fmin,fmax, ...
                app.CkXPeriod.Value,varargin{:});
        end

        function lineHandle = plotFrequencySeriesForMode( ...
                axh,frequency,values,fmin,fmax,usePeriod,varargin)
            frequency = frequency(:);
            values = values(:);
            keepPlot = isfinite(frequency) & isfinite(values) & ...
                frequency >= fmin & frequency <= fmax;
            if usePeriod
                keepPlot = keepPlot & frequency > 0;
                xPlot = 1./frequency(keepPlot);
            else
                xPlot = frequency(keepPlot);
            end
            lineHandle = plot(axh,xPlot,values(keepPlot),varargin{:});
        end

        function plotModelLevels(axh,frequency,background, ...
                loc90,loc95,loc99,g90,g95,g99,fmin,fmax,modelName)
            plotFrequencySeries(axh,frequency,background,fmin,fmax, ...
                'k-','LineWidth',1.6,'DisplayName',modelName);
            plotFrequencySeries(axh,frequency,loc90,fmin,fmax, ...
                'b-','LineWidth',0.8,'DisplayName','Local 90%');
            plotFrequencySeries(axh,frequency,loc95,fmin,fmax, ...
                'b--','LineWidth',1.0,'DisplayName','Local 95%');
            plotFrequencySeries(axh,frequency,loc99,fmin,fmax, ...
                'b-.','LineWidth',0.8,'DisplayName','Local 99%');
            plotFrequencySeries(axh,frequency,g90,fmin,fmax, ...
                'r-','LineWidth',0.8,'DisplayName','Global 90%');
            plotFrequencySeries(axh,frequency,g95,fmin,fmax, ...
                'r--','LineWidth',1.4,'DisplayName','Global 95%');
            plotFrequencySeries(axh,frequency,g99,fmin,fmax, ...
                'r-.','LineWidth',0.8,'DisplayName','Global 99%');
        end

        function configureFrequencyAxes(axesHandles,fmin,fmax)
            configureFrequencyAxesForMode(axesHandles,fmin,fmax, ...
                app.CkXPeriod.Value,app.CkLogF.Value);
        end

        function configureFrequencyAxesForMode( ...
                axesHandles,fmin,fmax,usePeriod,useLog)
            axesHandles = axesHandles(isgraphics(axesHandles));
            for axisHandle = axesHandles(:)'
                if usePeriod
                    positiveLow = fmin;
                    if ~(isfinite(positiveLow) && positiveLow > 0)
                        plottedLines = findall(axisHandle,'Type','line');
                        positivePeriods = [];
                        for lineIndex = 1:numel(plottedLines)
                            values = plottedLines(lineIndex).XData;
                            positivePeriods = [positivePeriods; ...
                                values(isfinite(values) & values > 0)']; %#ok<AGROW>
                        end
                        if isempty(positivePeriods)
                            continue
                        end
                        periodLimits = [1/fmax,max(positivePeriods)];
                    else
                        periodLimits = sort([1/fmax,1/positiveLow]);
                    end
                    if periodLimits(1) == periodLimits(2)
                        periodLimits(2) = periodLimits(1)*(1+eps);
                    end
                    xlim(axisHandle,periodLimits);
                    set(axisHandle,'XDir','reverse');
                else
                    if useLog && fmin <= 0
                        positiveFrequencies = plottedPositiveXData( ...
                            axisHandle);
                        if isempty(positiveFrequencies)
                            continue
                        end
                        xlim(axisHandle,[min(positiveFrequencies) fmax]);
                    else
                        xlim(axisHandle,[fmin fmax]);
                    end
                    set(axisHandle,'XDir','normal');
                end
                set(axisHandle,'XScale', ...
                    ternary(useLog,'log','linear'));
                set(axisHandle,'XMinorTick','on');
            end
        end

        function values = plottedPositiveXData(axisHandle)
            values = [];
            plottedLines = findall(axisHandle,'Type','line');
            for lineIndex = 1:numel(plottedLines)
                current = plottedLines(lineIndex).XData;
                values = [values,current(isfinite(current) & current > 0)]; %#ok<AGROW>
            end
        end

        function label = frequencyAxisLabel()
            label = frequencyAxisLabelForMode(app.CkXPeriod.Value);
        end

        function label = frequencyAxisLabelForMode(usePeriod)
            if usePeriod
                if localizedUnitLabelsEnabled()
                    label = [localizedText('main15','Period'), ...
                        ' (',app.unit,')'];
                else
                    label = ['Period (',app.unit,')'];
                end
            else
                if localizedUnitLabelsEnabled()
                    label = [localizedText( ...
                        'spectral33','Frequency (cycles/'),app.unit,')'];
                else
                    label = ['Frequency (cycles/',app.unit,')'];
                end
            end
        end

        function label = powerAxisLabel()
            if localizedUnitLabelsEnabled()
                label = localizedText('spectral30','Power');
            else
                label = 'Power';
            end
        end

        function tf = localizedUnitLabelsEnabled()
            tf = isnumeric(app.langChoice) && isscalar(app.langChoice) && ...
                isfinite(app.langChoice) && app.langChoice > 0 && ...
                isnumeric(app.mainUnitSelection) && ...
                isscalar(app.mainUnitSelection) && ...
                isfinite(app.mainUnitSelection) && ...
                app.mainUnitSelection > 0;
        end

        function plotSignificanceReferenceLines(axh,fmin,fmax)
            if app.CkXPeriod.Value
                plottedLines = findall(axh,'Type','line');
                xValues = [];
                for lineIndex = 1:numel(plottedLines)
                    current = plottedLines(lineIndex).XData;
                    xValues = [xValues,current(isfinite(current) & current > 0)]; %#ok<AGROW>
                end
                if isempty(xValues)
                    return
                end
                limits = [min(xValues),max(xValues)];
            else
                limits = [fmin fmax];
            end
            line(axh,limits,[0.10 0.10],'Color','k', ...
                'LineWidth',0.5,'LineStyle',':');
            line(axh,limits,[0.05 0.05],'Color','m', ...
                'LineWidth',0.35,'LineStyle','-.');
            line(axh,limits,[0.01 0.01],'Color','r', ...
                'LineWidth',0.5,'LineStyle','--');
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

        function nw = selectedNw()
            if app.BGNW.SelectedObject == app.RBNwCustom
                nw = str2double(app.EditNW.Value);
            else
                nw = str2double(app.DropNW.Value);
            end
        end

        function nfft = chooseNfft(n)
            if app.BGPad.SelectedObject == app.RBPadMultiplier
                multiplier = str2double(app.EditPadMultiplier.Value);
                if ~(isfinite(multiplier) && multiplier > 0)
                    nfft = NaN;
                    return
                end
                nfft = round(multiplier*n);
                if ~(isfinite(nfft) && nfft >= 1)
                    nfft = NaN;
                end
            else
                requestedNfft = str2double(app.EditPadExact.Value);
                if ~(isfinite(requestedNfft) && requestedNfft >= 1 && ...
                        abs(requestedNfft-round(requestedNfft)) <= ...
                        eps(max(1,abs(requestedNfft))))
                    nfft = NaN;
                else
                    nfft = round(requestedNfft);
                end
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

function value = getContextField(ctx,fieldName,defaultValue)
value = defaultValue;
if isstruct(ctx) && isfield(ctx,fieldName) && ~isempty(ctx.(fieldName))
    value = ctx.(fieldName);
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

function [recommended,fitMaximum] = ...
        recommendUltraHighResolutionBiasCorrection( ...
        data,physicalNyquist,isRegular)
% Restore the v2.8 recommendation without treating its fit cutoff as Nyquist.
recommended = false;
fitMaximum = physicalNyquist;
if ~isRegular || size(data,1) < 3 || size(data,2) < 2 || ...
        ~(isfinite(physicalNyquist) && physicalNyquist > 0)
    return
end
dt = median(diff(data(:,1)));
values = data(:,2)-mean(data(:,2),'omitnan');
if ~(isfinite(dt) && dt > 0) || any(~isfinite(values))
    return
end
try
    [power,angularFrequency] = periodogram(values);
catch
    return
end
frequency = angularFrequency/(2*pi*dt);
valid = isfinite(power) & power >= 0 & ...
    isfinite(frequency) & frequency >= 0;
power = real(power(valid));
frequency = real(frequency(valid));
totalPower = sum(power);
if isempty(power) || ~(isfinite(totalPower) && totalPower > 0) || ...
        ~(isfinite(frequency(end)) && frequency(end) > 0)
    return
end
cutoffIndex = find(cumsum(power) >= 0.99*totalPower,1,'first');
if isempty(cutoffIndex) || ~(isfinite(frequency(cutoffIndex)) && ...
        frequency(cutoffIndex) > 0)
    return
end
fitMaximum = min(frequency(cutoffIndex),physicalNyquist);
recommended = fitMaximum/frequency(end) <= 0.85;
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
