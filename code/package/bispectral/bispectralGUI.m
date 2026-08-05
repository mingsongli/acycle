function varargout = bispectralGUI(varargin)
%BISPECTRALGUI Parameter window for Acycle bispectral analysis.
%   BISPECTRALGUI(HANDLES) receives the selected two-column data through the
%   same handles contract used by spectrum.m and evofftGUI.m.

context = struct();
if nargin >= 1 && isstruct(varargin{1})
    context = varargin{1};
end
if ~isfield(context,'current_data') || ~isnumeric(context.current_data) || ...
        size(context.current_data,2) < 2
    error('Acycle:BispectralGUI:MissingData', ...
        'Bispectral Analysis requires one selected two-column data file.');
end

app = struct();
app.Context = context;
app.Data = context.current_data;
app.DataName = getDataName(context);
app.Unit = getCoordinateUnit(context);
app.Defaults = bispectralDefaults(app.Data);
% Strict GUI input must already be finite, strictly increasing, and unique;
% rows are never silently removed, sorted, or merged. If coordinate spacing
% exceeds the shared 10 ppm threshold, replace the series with its linear
% median-spacing interpolation grid after warning the user.
app.Defaults.Interpolate = 'auto';
app.Defaults.SampleInterval = [];
app.Defaults.DetrendMethod = 'none';
app.Defaults.Standardize = false;
app.Defaults.InputPolicy = 'strict';
app.Defaults.InputName = app.DataName;
app.Defaults.CoordinateUnit = app.Unit;
app.AnticipatedSampleCount = anticipatedGuiSampleCount( ...
    app.Data,app.Defaults);
app.Defaults = applyAnticipatedSampleCountDefaults( ...
    app.Defaults,app.AnticipatedSampleCount);
app.Defaults.SignificanceMethod = 'surrogate-global';
app.Defaults.SurrogateType = 'iaaft';
app.Defaults.NumSurrogates = 199;
app.ProgressDialog = [];
app.IsRunning = false;
app.IsRendering = false;
app.IsApplyingDefaults = false;
app.LastResult = [];
app.LastFigure = [];
app.LastPlotHandles = struct();
app.DisplayInferenceMethod = 'none';
app.CalculationDirty = false;
app.InferenceDirty = false;
app.AnalysisCount = 0;
app.LastValidReferencePeriods = [];
app.LastValidFrequencyPairs = zeros(0,2);
app.LastParameterCorrections = cell(0,1);
app.LastOperationParameterCorrections = cell(0,1);
app.PendingParameterCorrections = cell(0,1);
app.ParameterCorrectionCount = 0;
app.ParameterAlertRequestCount = 0;
app.ParameterAlertFailureCount = 0;
app.ScientificAlertRequestCount = 0;
app.ScientificAlertFailureCount = 0;
app.TestHooks = resolveGuiTestHooks(context);

background = [0.94 0.94 0.94];
blue = [0.1137 0.0235 0.9725];
scienceBlue = [0.00 0.24 0.68];
instantGreen = [0.00 0.35 0.16];
standardBlack = [0 0 0];
app.UIFigure = uifigure('Name','Acycle: Bispectral Analysis', ...
    'Color',background,'Position',[90 35 980 850], ...
    'AutoResizeChildren','off','Tag','bispectralGUI');
app.UIFigure.CloseRequestFcn = @onCloseRequest;
app.UIFigure.KeyPressFcn = @onKeyPress;
try
    app.UIFigure.WindowKeyPressFcn = @onKeyPress;
catch
end

outer = uigridlayout(app.UIFigure,[4 1]);
outer.RowHeight = {52,'1x',30,48};
outer.ColumnWidth = {'1x'};
outer.Padding = [16 12 16 12];
outer.RowSpacing = 8;

app.DataSummary = uilabel(outer,'Text',dataSummary(app.Data,app.DataName), ...
    'FontWeight','bold','FontSize',12,'WordWrap','on', ...
    'BackgroundColor',[0.98 0.98 1.00],'Tag','bispectralDataSummary');
app.DataSummary.Layout.Row = 1;

content = uigridlayout(outer,[2 2]);
content.Layout.Row = 2;
content.RowHeight = {'1x',320};
content.ColumnWidth = {'1x','1x'};
content.RowSpacing = 10;
content.ColumnSpacing = 10;
content.Padding = [0 0 0 0];

estPanel = uipanel(content,'Title','Estimator','BackgroundColor',background, ...
    'FontWeight','bold');
estPanel.Layout.Row = 1; estPanel.Layout.Column = 1;
est = uigridlayout(estPanel,[9 2]);
est.RowHeight = repmat({28},1,9); est.ColumnWidth = {190,'1x'};
est.Padding = [10 8 10 8]; est.RowSpacing = 4;
addLabel(est,1,'Method',scienceBlue);
app.Estimator = uidropdown(est, ...
    'Items',{'WOSA segmented FFT (recommended)','Frequency-smoothed direct'}, ...
    'ItemsData',{'wosa','frequency-smoothed'}, ...
    'ValueChangedFcn',@(~,~)onValidatedEstimatorChanged(), ...
    'Tag','bispectralEstimator'); setCell(app.Estimator,1,2);
addLabel(est,2,'Number of segments',scienceBlue);
app.NumSegments = uieditfield(est,'numeric','RoundFractionalValues','off', ...
    'Tag','bispectralNumSegments'); setCell(app.NumSegments,2,2);
addLabel(est,3,'Overlap (%)',standardBlack);
app.Overlap = uieditfield(est,'numeric'); setCell(app.Overlap,3,2);
addLabel(est,4,'Taper',standardBlack);
app.Window = uidropdown(est,'Items',{'Hann','Hamming','Blackman','Rectangular'}, ...
    'ItemsData',{'hann','hamming','blackman','rectangular'}); setCell(app.Window,4,2);
addLabel(est,5,'Within-segment detrend',scienceBlue);
app.SegmentDetrend = uidropdown(est,'Items',{'None','Remove mean','Linear'}, ...
    'ItemsData',{'none','mean','linear'}); setCell(app.SegmentDetrend,5,2);
addLabel(est,6,'Zero-padding factor',standardBlack);
app.Padding = uidropdown(est,'Items',{'1 (none)','2 x segment','4 x segment','8 x segment'}, ...
    'ItemsData',[1 2 4 8]); setCell(app.Padding,6,2);
addLabel(est,7,'Frequency-smoothing span',scienceBlue);
app.SmoothingSpan = uidropdown(est,'Items',{'3 bins (7 triads)','5 bins (19 triads)','7 bins (37 triads)'}, ...
    'ItemsData',[3 5 7]); setCell(app.SmoothingSpan,7,2);
addLabel(est,8,'Frequency kernel',standardBlack);
app.SmoothingKernel = uidropdown(est,'Items',{'Daniell (uniform)','Raised cosine'}, ...
    'ItemsData',{'daniell','cosine'}); setCell(app.SmoothingKernel,8,2);
addLabel(est,9,'Maximum computed freq. bins',scienceBlue);
app.MaxBins = uieditfield(est,'numeric','RoundFractionalValues','off','Tooltip',[ ...
    'Computational control: if needed, selects a stride-sampled subset of ', ...
    'FFT-frequency bins. It changes the numerical map grid and the FWER ', ...
    'family, but does not improve Rayleigh resolution.']);
setCell(app.MaxBins,9,2);

sigPanel = uipanel(content,'Title','Frequency and significance','BackgroundColor',background, ...
    'FontWeight','bold');
sigPanel.Layout.Row = 1; sigPanel.Layout.Column = 2;
sigGrid = uigridlayout(sigPanel,[6 2]);
sigGrid.RowHeight = repmat({28},1,6); sigGrid.ColumnWidth = {190,'1x'};
sigGrid.Padding = [10 8 10 8]; sigGrid.RowSpacing = 4;
addLabel(sigGrid,1,'Minimum frequency',instantGreen);
app.FrequencyMin = uieditfield(sigGrid,'numeric', ...
    'Tooltip','Display limit only; changing it redraws the cached result.');
setCell(app.FrequencyMin,1,2);
addLabel(sigGrid,2,'Maximum plotted frequency',instantGreen);
app.FrequencyMax = uieditfield(sigGrid,'numeric','Tooltip', ...
    'Display limit only; the estimator always computes the full positive-frequency domain.');
setCell(app.FrequencyMax,2,2);
addLabel(sigGrid,3,'Inference',scienceBlue);
app.Significance = uidropdown(sigGrid, ...
    'Items',{'None (hide inference)', ...
    'IAAFT surrogate max-statistic (FWER)'}, ...
    'ItemsData',{'none','surrogate-global'}, ...
    'ValueChangedFcn',@(~,~)onInferenceSelectionChanged(), ...
    'Tag','bispectralSignificance'); setCell(app.Significance,3,2);
addLabel(sigGrid,4,'FWER confidence (%)',standardBlack);
app.Confidence = uieditfield(sigGrid,'numeric'); setCell(app.Confidence,4,2);
addLabel(sigGrid,5,'Number of surrogates',scienceBlue);
app.NumSurrogates = uieditfield(sigGrid,'numeric', ...
    'RoundFractionalValues','off','Tooltip',[ ...
    '199 is the interactive default; use at least 999 for final ', ...
    'publication-quality IAAFT max-statistic inference.']);
setCell(app.NumSurrogates,5,2);
addLabel(sigGrid,6,'Random seed',standardBlack);
app.RandomSeed = uieditfield(sigGrid,'numeric', ...
    'RoundFractionalValues','off'); setCell(app.RandomSeed,6,2);

plotPanel = uipanel(content,'Title','Output and interpretation','BackgroundColor',background, ...
    'FontWeight','bold');
plotPanel.Layout.Row = 2; plotPanel.Layout.Column = [1 2];
plotLabelWidth = 190;
plotColumnGap = 10;
plotGrid = uigridlayout(plotPanel,[8 2]);
plotGrid.RowHeight = {28,30,28,28,28,28,'1x',28};
plotGrid.ColumnWidth = {plotLabelWidth,'1x'};
plotGrid.Padding = [10 8 10 8];
plotGrid.RowSpacing = 4;
plotGrid.ColumnSpacing = plotColumnGap;
addLabel(plotGrid,1,'Figure',instantGreen);
app.PlotQuantity = uidropdown(plotGrid, ...
    'Items',{'Overview: |B| + b^2','Squared bicoherence (b^2)', ...
    'Bispectrum amplitude (|B|)','Biphase'}, ...
    'ItemsData',{'overview','bicoherence-squared', ...
    'bispectrum-magnitude','biphase'}); setCell(app.PlotQuantity,1,2);
displayRow = uigridlayout(plotGrid,[1 6]);
displayRow.Layout.Row = 2;
displayRow.Layout.Column = [1 2];
displayRow.RowHeight = {'1x'};
retainFirstLabelWidth = 155;
retainColumnGap = 5;
displayRow.ColumnWidth = {retainFirstLabelWidth,58,155,58,125,58};
% Align the first Retain edit field with PlotQuantity in column 2:
% 190 + 10 - 155 - 5 = 40 pixels of left inset for the entire row.
retainRowLeftInset = plotLabelWidth + plotColumnGap - ...
    retainFirstLabelWidth - retainColumnGap;
displayRow.Padding = [retainRowLeftInset 0 0 0];
displayRow.ColumnSpacing = retainColumnGap;
retainBispectrumLabel = uilabel(displayRow,'Text','Retain |B| strongest (%)', ...
    'HorizontalAlignment','right','FontColor',instantGreen);
retainBispectrumLabel.Layout.Column = 1;
app.KeepBispectrum = uieditfield(displayRow,'numeric', ...
    'Tooltip','Plot only: percentile mask calculated independently from |B|.');
app.KeepBispectrum.Layout.Column = 2;
retainBicoherenceLabel = uilabel(displayRow,'Text','Retain b^2 strongest (%)', ...
    'HorizontalAlignment','right','FontColor',instantGreen);
retainBicoherenceLabel.Layout.Column = 3;
app.KeepBicoherence = uieditfield(displayRow,'numeric', ...
    'Tooltip',['Plot only: percentile mask calculated independently from b^2; ', ...
    'this mask is also used for biphase.']);
app.KeepBicoherence.Layout.Column = 4;
colorGridLabel = uilabel(displayRow,'Text','Colormap grid #', ...
    'HorizontalAlignment','right','FontColor',instantGreen);
colorGridLabel.Layout.Column = 5;
app.ColorGrid = uieditfield(displayRow,'numeric', ...
    'RoundFractionalValues','off','Tooltip', ...
    'Number of discrete colors shared by every two-dimensional map.');
app.ColorGrid.Layout.Column = 6;
addLabel(plotGrid,3,'Reference periods',instantGreen);
app.ReferencePeriods = uieditfield(plotGrid,'text','Placeholder','e.g. 405 100 41', ...
    'Tooltip',['Periods in the coordinate unit, separated by spaces. ', ...
    'Press Tab or Enter to draw f1+f2=1/period guide lines; ', ...
    '1/period must be below Nyquist.']);
setCell(app.ReferencePeriods,3,2);
addLabel(plotGrid,4,'Frequency pairs',instantGreen);
app.FrequencyPairs = uieditfield(plotGrid,'text', ...
    'Placeholder','e.g. 0.00247 0.010; 0.0244,0.0417', ...
    'Tooltip',['Enter f1 f2 pairs separated by semicolons; commas or spaces ', ...
    'separate the two frequencies within each pair. Press Tab or Enter ', ...
    'to redraw the cached result. Each frequency and f1+f2 must be ', ...
    'below Nyquist.']);
setCell(app.FrequencyPairs,4,2);
addLabel(plotGrid,5,'Peak annotations',instantGreen);
app.AnnotatePeaks = uicheckbox(plotGrid, ...
    'Text','Label strongest coupled triads','FontColor',instantGreen); setCell(app.AnnotatePeaks,5,2);
addLabel(plotGrid,6,'Secondary axis',instantGreen);
app.PeriodAxes = uicheckbox(plotGrid, ...
    'Text','Show period along map top','FontColor',instantGreen); setCell(app.PeriodAxes,6,2);
interpretation = uilabel(plotGrid,'Text',[ ...
    'Report b^2 and bispectrum magnitude |B| separately. A significant high b^2 ', ...
    'means stable quadratic phase coupling at f1 + f2; it does not by itself ', ...
    'prove causality or energy transfer. Minimum/maximum frequency change only the ', ...
    'visible range. Complete maps use red-white-blue; strongest-value views ', ...
    'use a smoothly transparent white-red frequency mesh.'], ...
    'WordWrap','on','FontColor',[0.24 0.24 0.24]);
interpretation.Layout.Row = 7; interpretation.Layout.Column = [1 2];
actionRow = uigridlayout(plotGrid,[1 2]);
actionRow.Layout.Row = 8;
actionRow.Layout.Column = [1 2];
actionRow.RowHeight = {'1x'};
actionRow.ColumnWidth = {'1x','1x'};
actionRow.Padding = [0 0 0 0];
actionRow.ColumnSpacing = plotColumnGap;
app.ResetButton = uibutton(actionRow,'push','Text','Reset recommended defaults', ...
    'ButtonPushedFcn',@(~,~)applyDefaults());
app.ResetButton.Layout.Row = 1; app.ResetButton.Layout.Column = 1;
app.HelpButton = uibutton(actionRow,'push','Text','Method notes and citations', ...
    'ButtonPushedFcn',@(~,~)showHelp());
app.HelpButton.Layout.Row = 1; app.HelpButton.Layout.Column = 2;

app.Status = uilabel(outer,'Text','Ready','FontColor',[0.22 0.22 0.22], ...
    'Tag','bispectralStatus'); app.Status.Layout.Row = 3;
buttons = uigridlayout(outer,[1 3]);
buttons.Layout.Row = 4; buttons.ColumnWidth = {'1x','1x','1x'};
buttons.Padding = [0 0 0 0]; buttons.ColumnSpacing = 10;
app.CloseButton = uibutton(buttons,'push','Text','Close', ...
    'ButtonPushedFcn',@onCloseRequest);
app.PreviewButton = uibutton(buttons,'push','Text','Run', ...
    'BackgroundColor',blue,'FontColor','w','FontWeight','bold', ...
    'ButtonPushedFcn',@(~,~)runAnalysis(false),'Tag','bispectralRun');
app.SaveButton = uibutton(buttons,'push','Text','Run & Save', ...
    'BackgroundColor',blue,'FontColor','w','FontWeight','bold', ...
    'ButtonPushedFcn',@(~,~)runAnalysis(true),'Tag','bispectralRunSave');
app.NumSegments.ValueChangedFcn = @(~,~)onValidatedCalculationChanged('Number of segments');
app.Overlap.ValueChangedFcn = @(~,~)onValidatedCalculationChanged('Overlap');
app.Window.ValueChangedFcn = @(~,~)onValidatedCalculationChanged('Taper');
app.SegmentDetrend.ValueChangedFcn = @(~,~)onValidatedCalculationChanged('Within-segment detrend');
app.Padding.ValueChangedFcn = @(~,~)onValidatedCalculationChanged('Zero padding');
app.SmoothingSpan.ValueChangedFcn = @(~,~)onValidatedCalculationChanged('Smoothing span');
app.SmoothingKernel.ValueChangedFcn = @(~,~)onValidatedCalculationChanged('Smoothing kernel');
app.MaxBins.ValueChangedFcn = @(~,~)onValidatedCalculationChanged('Maximum computed frequency bins');
app.Confidence.ValueChangedFcn = @(~,~)onValidatedInferenceChanged('Confidence');
app.NumSurrogates.ValueChangedFcn = @(~,~)onValidatedInferenceChanged('Number of surrogates');
app.RandomSeed.ValueChangedFcn = @(~,~)onValidatedInferenceChanged('Random seed');
app.FrequencyMin.ValueChangedFcn = @(~,~)onValidatedDisplayChanged('Minimum frequency');
app.FrequencyMax.ValueChangedFcn = @(~,~)onValidatedDisplayChanged('Maximum frequency');
app.PlotQuantity.ValueChangedFcn = @(~,~)onDirectDisplayChanged('Figure');
app.KeepBispectrum.ValueChangedFcn = @(~,~)onValidatedDisplayChanged('|B| strongest values');
app.KeepBicoherence.ValueChangedFcn = @(~,~)onValidatedDisplayChanged('b^2 strongest values');
app.ColorGrid.ValueChangedFcn = @(~,~)onValidatedDisplayChanged('Colormap grid');
app.ReferencePeriods.ValueChangedFcn = @(~,~)onReferencePeriodsChanged();
app.FrequencyPairs.ValueChangedFcn = @(~,~)onFrequencyPairsChanged();
app.AnnotatePeaks.ValueChangedFcn = @(~,~)onDirectDisplayChanged('Peak annotations');
app.PeriodAxes.ValueChangedFcn = @(~,~)onDirectDisplayChanged('Secondary period axis');
app.InteractiveControls = {app.Estimator,app.NumSegments,app.Overlap, ...
    app.Window,app.SegmentDetrend,app.Padding,app.SmoothingSpan, ...
    app.SmoothingKernel,app.MaxBins,app.FrequencyMin,app.FrequencyMax, ...
    app.Significance,app.Confidence,app.NumSurrogates, ...
    app.RandomSeed,app.PlotQuantity,app.KeepBispectrum, ...
    app.KeepBicoherence,app.ColorGrid,app.ReferencePeriods,app.FrequencyPairs, ...
    app.AnnotatePeaks,app.PeriodAxes,app.ResetButton,app.HelpButton};

applyDefaults();
setappdata(app.UIFigure,'BispectralControls',app);
publishState();
if nargout > 0
    varargout{1} = app.UIFigure;
end

    function applyDefaults()
        hadResult = ~isempty(app.LastResult);
        app.LastOperationParameterCorrections = cell(0,1);
        app.IsApplyingDefaults = true;
        defaults = app.Defaults;
        app.SegmentDetrend.Value = defaults.SegmentDetrendMethod;
        app.Estimator.Value = defaults.Estimator;
        app.NumSegments.Value = defaults.NumSegments;
        app.Overlap.Value = defaults.OverlapPercent;
        app.Window.Value = defaults.Window;
        app.Padding.Value = defaults.ZeroPaddingFactor;
        app.SmoothingSpan.Value = defaults.FrequencySmoothingSpan;
        app.MaxBins.Value = defaults.MaxFrequencyBins;
        app.FrequencyMin.Value = defaults.FrequencyMin;
        dt = estimateSampleInterval(app.Data);
        app.FrequencyMax.Value = 1/(2*dt);
        app.Significance.Value = defaults.SignificanceMethod;
        app.Confidence.Value = 100*defaults.ConfidenceLevel;
        app.NumSurrogates.Value = defaults.NumSurrogates;
        app.RandomSeed.Value = defaults.RandomSeed;
        app.PlotQuantity.Value = defaults.PlotQuantity;
        app.KeepBispectrum.Value = 100*defaults.PlotKeepStrongestBispectrumFraction;
        app.KeepBicoherence.Value = 100*defaults.PlotKeepStrongestBicoherenceFraction;
        app.ColorGrid.Value = defaults.PlotColorGrid;
        app.ReferencePeriods.Value = formatPeriods(defaults.PlotReferencePeriods);
        app.LastValidReferencePeriods = defaults.PlotReferencePeriods;
        app.FrequencyPairs.Value = formatFrequencyPairs(defaults.PlotFrequencyPairs);
        app.LastValidFrequencyPairs = defaults.PlotFrequencyPairs;
        app.AnnotatePeaks.Value = true;
        app.PeriodAxes.Value = defaults.ShowPeriodAxes;
        app.SmoothingKernel.Value = defaults.FrequencySmoothingKernel;
        app.IsApplyingDefaults = false;
        onEstimatorChanged(false);
        updateSignificanceControlEnablement();
        if hadResult
            app.CalculationDirty = ~estimationMatchesCached();
            updateInferenceSelection(false);
            renderLatest('Recommended defaults restored');
        else
            setStatusSafe('Recommended defaults restored; press Run to calculate');
            publishState();
        end
    end

    function corrections = sanitizeGuiParameters(forRun)
        % Numeric edit fields intentionally have no UI Limits and no
        % automatic rounding.  This single validator can therefore report
        % the value the user entered, restore a documented recommendation,
        % and let the requested operation continue transparently.
        if nargin < 1
            forRun = false;
        end
        previousApplyingState = app.IsApplyingDefaults;
        app.IsApplyingDefaults = true;
        cleanupSanitizer = onCleanup( ...
            @()restoreApplyingState(previousApplyingState));
        corrections = cell(0,1);
        defaults = app.Defaults;
        nyquist = 1/(2*estimateSampleInterval(app.Data));

        corrections = correctNumericControl(app.NumSegments, ...
            'Number of segments',defaults.NumSegments, ...
            @(value)isFiniteIntegerScalar(value) && value >= 3, ...
            'must be an integer of at least 3',corrections);
        corrections = correctNumericControl(app.Overlap,'Overlap (%)', ...
            defaults.OverlapPercent,@(value)isFiniteRealScalar(value) && ...
            value >= 0 && value < 90,'must lie in [0, 90)',corrections);
        corrections = correctNumericControl(app.MaxBins, ...
            'Maximum computed freq. bins',defaults.MaxFrequencyBins, ...
            @(value)isFiniteIntegerScalar(value) && value >= 16 && value <= 2048, ...
            'must be an integer from 16 through 2048',corrections);
        corrections = correctNumericControl(app.FrequencyMin, ...
            'Minimum frequency',defaults.FrequencyMin, ...
            @(value)isFiniteRealScalar(value) && value >= 0 && value < nyquist, ...
            sprintf('must lie in [0, Nyquist), where Nyquist is %.15g',nyquist), ...
            corrections);
        corrections = correctNumericControl(app.FrequencyMax, ...
            'Maximum plotted frequency',nyquist, ...
            @(value)isFiniteRealScalar(value) && value > 0 && value <= nyquist, ...
            sprintf('must lie in (0, Nyquist], where Nyquist is %.15g',nyquist), ...
            corrections);
        corrections = correctNumericControl(app.Confidence, ...
            'FWER confidence (%)',100*defaults.ConfidenceLevel, ...
            @(value)isFiniteRealScalar(value) && value > 50 && value < 100, ...
            'must lie strictly between 50 and 100',corrections);
        corrections = correctNumericControl(app.NumSurrogates, ...
            'Number of surrogates',defaults.NumSurrogates, ...
            @(value)isFiniteIntegerScalar(value) && value >= 19 && value <= 99999, ...
            'must be an integer from 19 through 99999',corrections);
        corrections = correctNumericControl(app.RandomSeed,'Random seed', ...
            defaults.RandomSeed,@(value)isFiniteIntegerScalar(value) && ...
            value >= 0 && value <= double(intmax('uint32')), ...
            'must be an integer from 0 through 2^32-1',corrections);
        corrections = correctNumericControl(app.KeepBispectrum, ...
            'Retain |B| strongest (%)', ...
            100*defaults.PlotKeepStrongestBispectrumFraction, ...
            @(value)isFiniteRealScalar(value) && value > 0 && value <= 100, ...
            'must lie in (0, 100]',corrections);
        corrections = correctNumericControl(app.KeepBicoherence, ...
            'Retain b^2 strongest (%)', ...
            100*defaults.PlotKeepStrongestBicoherenceFraction, ...
            @(value)isFiniteRealScalar(value) && value > 0 && value <= 100, ...
            'must lie in (0, 100]',corrections);
        corrections = correctNumericControl(app.ColorGrid,'Colormap grid #', ...
            defaults.PlotColorGrid,@(value)isFiniteIntegerScalar(value) && ...
            value >= 4 && value <= 256, ...
            'must be an integer from 4 through 256',corrections);

        if strcmp(app.Estimator.Value,'wosa') && ...
                ~wosaConfigurationFeasible(app.AnticipatedSampleCount, ...
                app.NumSegments.Value,app.Overlap.Value)
            oldValue = sprintf('%g segments, %.15g%% overlap', ...
                app.NumSegments.Value,app.Overlap.Value);
            app.NumSegments.Value = defaults.NumSegments;
            app.Overlap.Value = defaults.OverlapPercent;
            if wosaConfigurationFeasible(app.AnticipatedSampleCount, ...
                    app.NumSegments.Value,app.Overlap.Value)
                newValue = sprintf('%g segments, %.15g%% overlap', ...
                    app.NumSegments.Value,app.Overlap.Value);
            else
                app.Estimator.Value = defaults.Estimator;
                newValue = sprintf('%s estimator with recommended settings', ...
                    char(defaults.Estimator));
            end
            corrections{end+1,1} = sprintf([ ...
                'WOSA segment geometry: %s -> %s; every segment must contain ', ...
                'at least 32 samples and segment starts must be distinct.'], ...
                oldValue,newValue);
        end

        alpha = 1-app.Confidence.Value/100;
        if 1/(app.NumSurrogates.Value+1) > alpha
            oldConfidence = app.Confidence.Value;
            app.Confidence.Value = 100*defaults.ConfidenceLevel;
            corrections{end+1,1} = sprintf([ ...
                'FWER confidence/surrogate combination: %.15g%% with %g ', ...
                'surrogates -> %.15g%% with %g surrogates; the original ', ...
                'plus-one p-value grid could not reach the requested alpha.'], ...
                oldConfidence,app.NumSurrogates.Value,app.Confidence.Value, ...
                app.NumSurrogates.Value);
        end

        if app.FrequencyMax.Value <= app.FrequencyMin.Value
            oldValue = sprintf('[%.15g, %.15g]', ...
                app.FrequencyMin.Value,app.FrequencyMax.Value);
            app.FrequencyMin.Value = defaults.FrequencyMin;
            app.FrequencyMax.Value = nyquist;
            corrections{end+1,1} = sprintf([ ...
                'Plotted frequency range: %s -> [%.15g, %.15g]; maximum ', ...
                'frequency must be strictly greater than minimum frequency.'], ...
                oldValue,app.FrequencyMin.Value,app.FrequencyMax.Value);
        end

        if ~forRun && ~isempty(app.LastResult)
            axisFrequency = app.LastResult.Frequency(:);
            visibleAxis = axisFrequency >= app.FrequencyMin.Value & ...
                axisFrequency <= app.FrequencyMax.Value;
            hasVisibleTriad = any(app.LastResult.PrincipalDomainMask( ...
                visibleAxis,visibleAxis),'all');
        else
            [axisFrequency,axisBins,maximumSumBin,sumMargin] = ...
                anticipatedFrequencyAxis();
            candidate = axisBins(axisFrequency >= app.FrequencyMin.Value & ...
                axisFrequency <= app.FrequencyMax.Value);
            hasVisibleTriad = ~isempty(candidate) && ...
                2*candidate(1)+sumMargin <= maximumSumBin;
        end
        if ~isempty(axisFrequency)
            if ~hasVisibleTriad
                oldValue = sprintf('[%.15g, %.15g]', ...
                    app.FrequencyMin.Value,app.FrequencyMax.Value);
                app.FrequencyMin.Value = defaults.FrequencyMin;
                app.FrequencyMax.Value = nyquist;
                corrections{end+1,1} = sprintf([ ...
                    'Plotted frequency range: %s -> [%.15g, %.15g]; the ', ...
                    'original range contained no computed principal-domain triad.'], ...
                    oldValue,app.FrequencyMin.Value,app.FrequencyMax.Value);
            end
        end

        try
            periods = parseReferencePeriods(app.ReferencePeriods.Value);
            validateReferencePeriodsForData(periods,nyquist);
            app.ReferencePeriods.Value = formatPeriods(periods);
            app.LastValidReferencePeriods = periods;
        catch exception
            oldValue = app.ReferencePeriods.Value;
            app.ReferencePeriods.Value = formatPeriods( ...
                app.LastValidReferencePeriods);
            corrections{end+1,1} = sprintf( ...
                'Reference periods: %s -> %s; %s', ...
                formatParameterValue(oldValue), ...
                formatParameterValue(app.ReferencePeriods.Value), ...
                exception.message);
        end
        try
            pairs = parseFrequencyPairs(app.FrequencyPairs.Value);
            validateFrequencyPairsForData(pairs,nyquist);
            app.FrequencyPairs.Value = formatFrequencyPairs(pairs);
            app.LastValidFrequencyPairs = pairs;
        catch exception
            oldValue = app.FrequencyPairs.Value;
            app.FrequencyPairs.Value = formatFrequencyPairs( ...
                app.LastValidFrequencyPairs);
            corrections{end+1,1} = sprintf( ...
                'Frequency pairs: %s -> %s; %s', ...
                formatParameterValue(oldValue), ...
                formatParameterValue(app.FrequencyPairs.Value), ...
                exception.message);
        end
        clear cleanupSanitizer
        onEstimatorChanged(false);
    end

    function restoreApplyingState(previousState)
        app.IsApplyingDefaults = previousState;
    end

    function corrections = correctNumericControl(control,label,fallback, ...
            validator,rule,corrections)
        original = control.Value;
        if validator(original)
            return
        end
        control.Value = fallback;
        corrections{end+1,1} = sprintf('%s: %s -> %s; %s.', ...
            label,formatParameterValue(original), ...
            formatParameterValue(fallback),rule);
    end

    function [frequency,axisBins,maximumSumBin,sumMargin] = ...
            anticipatedFrequencyAxis()
        frequency = [];
        axisBins = [];
        maximumSumBin = NaN;
        sumMargin = 0;
        n = app.AnticipatedSampleCount;
        dt = estimateSampleInterval(app.Data);
        if n < 1 || ~(isfinite(dt) && dt > 0)
            return
        end
        if strcmp(app.Estimator.Value,'wosa')
            denominator = 1+(app.NumSegments.Value-1)* ...
                (1-app.Overlap.Value/100);
            segmentLength = floor(n/denominator);
            nfft = round(segmentLength*app.Padding.Value);
            minimumBin = 1;
        else
            nfft = n;
            sumMargin = (app.SmoothingSpan.Value-1)/2;
            minimumBin = sumMargin+1;
        end
        maximumSumBin = floor((nfft-1)/2);
        allBins = minimumBin:maximumSumBin;
        if nfft < 1 || numel(allBins) < 2
            return
        end
        stride = max(1,ceil(numel(allBins)/app.MaxBins.Value));
        axisBins = allBins(1:stride:end);
        frequency = axisBins(:)/(nfft*dt);
    end

    function recordParameterCorrections(corrections)
        app.LastOperationParameterCorrections = corrections(:);
        if isempty(corrections)
            publishState();
            return
        end
        app.LastParameterCorrections = corrections(:);
        app.PendingParameterCorrections = appendUniqueCorrections( ...
            app.PendingParameterCorrections,corrections);
        app.ParameterCorrectionCount = app.ParameterCorrectionCount+numel(corrections);
        fprintf(2,'\n[Acycle Bispectral] GUI parameters automatically corrected for %s:\n', ...
            app.DataName);
        for correctionIndex = 1:numel(corrections)
            fprintf(2,'  - %s\n',corrections{correctionIndex});
        end
        fprintf(2,['  Corrected values are active. Parameter correction does ', ...
            'not relax finite-value, ordering, duplicate-coordinate, or ', ...
            'minimum-length validation.\n\n']);
        publishState();
    end

    function finalizeParameterCorrections(corrections)
        if isempty(corrections) || ~isValidUiHandle(app.UIFigure)
            return
        end
        if isValidUiHandle(app.Status)
            app.Status.Text = sprintf('%s | %d GUI parameter correction(s)', ...
                app.Status.Text,numel(corrections));
        end
        publishState();
        if strcmp(app.UIFigure.Visible,'on')
            message = [{['Invalid GUI parameters were restored to safe ', ...
                'recommended or last-valid values:']}; ...
                strcat('- ',corrections(:)); ...
                {['The corrected values were applied. Parameter correction ', ...
                'itself does not stop analysis; unrecoverable input-data ', ...
                'errors and user cancellation still do.']}];
            app.ParameterAlertRequestCount = ...
                app.ParameterAlertRequestCount+1;
            try
                feval(app.TestHooks.AlertFcn,app.UIFigure,message, ...
                    'Bispectral parameter correction','Icon','warning');
            catch exception
                app.ParameterAlertFailureCount = ...
                    app.ParameterAlertFailureCount+1;
                fprintf(2,['[Acycle Bispectral] The parameter warning dialog ', ...
                    'could not be displayed (%s). Corrected values remain active.\n'], ...
                    exception.message);
            end
            publishState();
        end
    end

    function onValidatedCalculationChanged(label)
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        corrections = sanitizeGuiParameters(false);
        recordParameterCorrections(corrections);
        onCalculationChanged(label);
        finalizeParameterCorrections(corrections);
    end

    function onValidatedEstimatorChanged()
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        corrections = sanitizeGuiParameters(false);
        recordParameterCorrections(corrections);
        onEstimatorChanged(false);
        onCalculationChanged('Estimator');
        finalizeParameterCorrections(corrections);
    end

    function onValidatedInferenceChanged(label)
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        corrections = sanitizeGuiParameters(false);
        recordParameterCorrections(corrections);
        onInferenceParameterChanged(label);
        finalizeParameterCorrections(corrections);
    end

    function onValidatedDisplayChanged(label)
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        corrections = sanitizeGuiParameters(false);
        recordParameterCorrections(corrections);
        onDisplayChanged(label);
        finalizeParameterCorrections(corrections);
    end

    function options = readOptions()
        options = app.Defaults;
        options.Interpolate = 'auto';
        options.SampleInterval = [];
        options.DetrendMethod = 'none';
        options.Standardize = false;
        options.InputPolicy = 'strict';
        options.SegmentDetrendMethod = app.SegmentDetrend.Value;
        options.Estimator = app.Estimator.Value;
        options.NumSegments = app.NumSegments.Value;
        options.OverlapPercent = app.Overlap.Value;
        options.Window = app.Window.Value;
        options.ZeroPaddingFactor = app.Padding.Value;
        options.FrequencySmoothingSpan = app.SmoothingSpan.Value;
        options.FrequencySmoothingKernel = app.SmoothingKernel.Value;
        options.MaxFrequencyBins = app.MaxBins.Value;
        options.FrequencyMin = app.FrequencyMin.Value;
        options.FrequencyMax = app.FrequencyMax.Value;
        % None skips inference on a new Run. Switching to None after an
        % IAAFT run is display-only and leaves that completed result cached.
        options.SignificanceMethod = app.Significance.Value;
        options.ConfidenceLevel = app.Confidence.Value/100;
        options.SurrogateType = 'iaaft';
        options.NumSurrogates = app.NumSurrogates.Value;
        options.RandomSeed = app.RandomSeed.Value;
        options.PlotQuantity = app.PlotQuantity.Value;
        options.PlotKeepStrongestBispectrumFraction = app.KeepBispectrum.Value/100;
        options.PlotKeepStrongestBicoherenceFraction = app.KeepBicoherence.Value/100;
        options.PlotColorGrid = app.ColorGrid.Value;
        options.PlotReferencePeriods = parseReferencePeriods(app.ReferencePeriods.Value);
        options.PlotFrequencyPairs = parseFrequencyPairs(app.FrequencyPairs.Value);
        options.PlotPeakCount = 5*double(app.AnnotatePeaks.Value);
        options.ShowPeriodAxes = app.PeriodAxes.Value;
        options.InputName = app.DataName;
        options.CoordinateUnit = app.Unit;
    end

    function runAnalysis(saveResult)
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        corrections = sanitizeGuiParameters(true);
        recordParameterCorrections(corrections);
        resultCorrections = app.PendingParameterCorrections;
        app.IsRunning = true;
        cleanupButtons = onCleanup(@()enableRunButtons());
        publishState();
        renderSucceeded = false;
        archiveSucceeded = false;
        completedResult = [];
        scientificWarnings = cell(0,1);
        try
            setEnabled(app.InteractiveControls,false);
            app.PreviewButton.Enable = 'off';
            app.SaveButton.Enable = 'off';
            app.CloseButton.Enable = 'off';
            options = readOptions();
            if strcmp(app.UIFigure.Visible,'on')
                app.ProgressDialog = uiprogressdlg(app.UIFigure, ...
                    'Title','Bispectral Analysis','Message','Preparing data', ...
                    'Cancelable','on','Value',0);
            else
                app.ProgressDialog = [];
            end
            cleanupProgress = onCleanup(@()closeProgress());
            options.ProgressFcn = @updateProgress;
            result = bispectralAnalyze(app.Data,options);
            result.GUIParameterCorrections = resultCorrections(:);
            % Cancel applies to the numerical analysis. End that progress
            % contract before rendering or writing files, where cancellation
            % is not polled and would otherwise be misleading.
            closeProgress();
            setStatusSafe('Rendering bispectral figure');
            if strcmp(app.Significance.Value,'none')
                candidateInferenceMethod = 'none';
            else
                candidateInferenceMethod = result.Significance.Method;
            end
            [fig,~] = replaceLatestFigure( ...
                result,candidateInferenceMethod,false);
            renderSucceeded = true;
            % Commit the cached numerical and display state only after the
            % candidate figure has rendered successfully. A rendering error
            % therefore cannot pair a new result with an older figure.
            app.LastResult = result;
            app.AnalysisCount = app.AnalysisCount+1;
            app.DisplayInferenceMethod = candidateInferenceMethod;
            app.CalculationDirty = false;
            app.InferenceDirty = false;
            publishState();
            completedResult = result;
            scientificWarnings = collectScientificWarnings(result);
            if saveResult
                setStatusSafe('Saving bispectral results');
                outputDirectory = bispectralAcycleDirectory(app.Context);
                files = feval(app.TestHooks.SaveFcn, ...
                    result,fig,outputDirectory,app.DataName);
                archiveSucceeded = true;
                refreshMainList(app.Context,outputDirectory);
                setStatusSafe(sprintf('Saved result folder: %s',files.Directory));
            else
                setStatusSafe('Analysis complete (not saved)');
            end
        catch exception
            closeProgress();
            if strcmp(exception.identifier,'Acycle:Bispectral:Canceled')
                setStatusSafe('Analysis canceled');
            elseif saveResult && renderSucceeded && ~archiveSucceeded
                setStatusSafe(['Save failed: ',exception.message]);
                printGuiFailure('Save failed',exception);
            else
                setStatusSafe(['Analysis failed: ',exception.message]);
                printGuiFailure('Analysis failed',exception);
            end
            publishState();
        end
        % Scientific and automatic-interpolation warnings describe the
        % completed analysis, not the archive operation. Report them even
        % when Run & Save fails after the result and figure are available.
        if renderSucceeded && ~isempty(scientificWarnings)
            if isValidUiHandle(app.Status)
                statusText = app.Status.Text;
            else
                statusText = 'Analysis complete';
            end
            setStatusSafe(sprintf('%s | %d scientific warning(s)', ...
                statusText,numel(scientificWarnings)));
            printScientificWarnings(scientificWarnings,app.DataName);
            showScientificWarningAlert(completedResult);
        end
        % A Preview Run keeps the audit pending so a later Run & Save can
        % archive it. Consume it only after the atomic result folder exists.
        if saveResult && archiveSucceeded
            app.PendingParameterCorrections = cell(0,1);
        end
        clear cleanupButtons
        finalizeParameterCorrections(corrections);
        publishState();
    end

    function onDisplayChanged(label)
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        if isempty(app.LastResult)
            setStatusSafe(sprintf('%s updated; press Run to calculate',label));
            publishState();
            return
        end
        renderLatest([label,' updated']);
    end

    function onReferencePeriodsChanged()
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        corrections = sanitizeGuiParameters(false);
        recordParameterCorrections(corrections);
        onDisplayChanged('Reference periods');
        finalizeParameterCorrections(corrections);
    end

    function onFrequencyPairsChanged()
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        corrections = sanitizeGuiParameters(false);
        recordParameterCorrections(corrections);
        onDisplayChanged('Frequency pairs');
        finalizeParameterCorrections(corrections);
    end

    function renderLatest(reason)
        if isempty(app.LastResult) || app.IsRendering
            return
        end
        try
            replaceLatestFigure();
            status = [reason,'; cached result redrawn without recalculation'];
            if app.CalculationDirty || app.InferenceDirty
                status = [status,' | calculation changes pending Run'];
            end
            setStatusSafe(status);
        catch exception
            setStatusSafe(['Display update failed: ',exception.message]);
            printGuiFailure('Display update failed',exception);
        end
        publishState();
    end

    function [newFigure,newHandles] = replaceLatestFigure( ...
            resultForPlot,displayInferenceMethod,publishAfter)
        if nargin < 1 || isempty(resultForPlot)
            resultForPlot = app.LastResult;
        end
        if nargin < 2 || isempty(displayInferenceMethod)
            displayInferenceMethod = app.DisplayInferenceMethod;
        end
        if nargin < 3
            publishAfter = true;
        end
        app.IsRendering = true;
        cleanupRendering = onCleanup(@()finishRendering(publishAfter));
        periods = parseReferencePeriods(app.ReferencePeriods.Value);
        frequencyPairs = parseFrequencyPairs(app.FrequencyPairs.Value);
        showSignificance = ~strcmp(displayInferenceMethod,'none') && ...
            strcmp(displayInferenceMethod,resultForPlot.Significance.Method);
        [newFigure,newHandles] = bispectralPlot(resultForPlot, ...
            'Visible',app.UIFigure.Visible,'Quantity',app.PlotQuantity.Value, ...
            'BispectrumKeepStrongestFraction',app.KeepBispectrum.Value/100, ...
            'BicoherenceKeepStrongestFraction',app.KeepBicoherence.Value/100, ...
            'ColorGrid',app.ColorGrid.Value, ...
            'FrequencyMinimum',app.FrequencyMin.Value, ...
            'FrequencyMaximum',app.FrequencyMax.Value, ...
            'ReferencePeriods',periods, ...
            'FrequencyPairs',frequencyPairs, ...
            'ShowPeriodAxes',app.PeriodAxes.Value, ...
            'PeakCount',5*double(app.AnnotatePeaks.Value), ...
            'ShowSignificance',showSignificance);
        cleanupCandidate = onCleanup(@()discardUncommittedFigure(newFigure));
        if ~isempty(app.TestHooks.AfterCandidatePlotFcn)
            feval(app.TestHooks.AfterCandidatePlotFcn,newFigure);
        end
        previousFigure = app.LastFigure;
        drawnow nocallbacks;
        if isValidUiHandle(previousFigure) && previousFigure ~= newFigure
            retireManagedFigure(previousFigure);
        end
        app.LastPlotHandles = newHandles;
        app.LastFigure = newFigure;
        clear cleanupCandidate
    end

    function discardUncommittedFigure(candidateFigure)
        if ~isValidUiHandle(candidateFigure)
            return
        end
        if isValidUiHandle(app.LastFigure) && app.LastFigure == candidateFigure
            return
        end
        retireManagedFigure(candidateFigure);
    end

    function finishRendering(publishAfter)
        app.IsRendering = false;
        if publishAfter
            publishState();
        end
    end

    function updateProgress(fraction,message)
        if ~isValidUiHandle(app.ProgressDialog)
            return
        end
        if app.ProgressDialog.CancelRequested
            error('Acycle:Bispectral:Canceled','Bispectral analysis canceled by user.');
        end
        app.ProgressDialog.Value = max(0,min(1,fraction));
        app.ProgressDialog.Message = message;
        setStatusSafe(message);
        drawnow limitrate;
    end

    function closeProgress()
        try
            if isValidUiHandle(app.ProgressDialog)
                close(app.ProgressDialog);
            end
        catch
        end
        app.ProgressDialog = [];
    end

    function enableRunButtons()
        app.IsRunning = false;
        if ~isValidUiHandle(app.UIFigure), return, end
        setEnabled(app.InteractiveControls,true);
        onEstimatorChanged(false);
        updateSignificanceControlEnablement();
        if isValidUiHandle(app.PreviewButton), app.PreviewButton.Enable = 'on'; end
        if isValidUiHandle(app.SaveButton), app.SaveButton.Enable = 'on'; end
        if isValidUiHandle(app.CloseButton), app.CloseButton.Enable = 'on'; end
        publishState();
    end

    function setStatusSafe(message)
        if isValidUiHandle(app.Status)
            app.Status.Text = message;
        end
    end

    function onCloseRequest(~,~)
        if app.IsRunning
            message = ['Analysis is running; use Cancel in the progress ', ...
                'window before closing'];
            setStatusSafe(message);
            fprintf(2,'[Acycle Bispectral] %s.\n',message);
            return
        end
        if isValidUiHandle(app.UIFigure)
            delete(app.UIFigure);
        end
    end

    function onEstimatorChanged(markDirty)
        isWosa = strcmp(app.Estimator.Value,'wosa');
        if ~app.IsRunning
            setEnabled({app.NumSegments,app.Overlap,app.Padding},isWosa);
            setEnabled({app.SmoothingSpan,app.SmoothingKernel},~isWosa);
        end
        if nargin > 0 && markDirty
            onCalculationChanged('Estimator');
        end
    end

    function onCalculationChanged(label)
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        if isempty(app.LastResult)
            setStatusSafe(sprintf('%s updated; press Run to calculate',label));
        else
            app.CalculationDirty = ~estimationMatchesCached();
            if app.CalculationDirty
                setStatusSafe(sprintf( ...
                    '%s changed; current figure still uses the latest completed calculation | press Run', ...
                    label));
            else
                setStatusSafe(sprintf('%s restored to the cached calculation value',label));
            end
        end
        publishState();
    end

    function matches = estimationMatchesCached()
        matches = false;
        if isempty(app.LastResult) || ~isfield(app.LastResult,'Options')
            return
        end
        cached = app.LastResult.Options;
        matches = strcmp(char(app.Estimator.Value),char(cached.Estimator)) && ...
            strcmp(char(app.SegmentDetrend.Value),char(cached.SegmentDetrendMethod)) && ...
            strcmp(char(app.Window.Value),char(cached.Window)) && ...
            app.MaxBins.Value == cached.MaxFrequencyBins;
        if ~matches
            return
        end
        if strcmp(app.Estimator.Value,'wosa')
            matches = app.NumSegments.Value == cached.NumSegments && ...
                app.Overlap.Value == cached.OverlapPercent && ...
                app.Padding.Value == cached.ZeroPaddingFactor;
        else
            matches = app.SmoothingSpan.Value == cached.FrequencySmoothingSpan && ...
                strcmp(char(app.SmoothingKernel.Value), ...
                char(cached.FrequencySmoothingKernel));
        end
    end

    function updateSignificanceControlEnablement()
        if ~app.IsRunning
            % Keep these editable while None is selected so the next IAAFT
            % run can be configured before the inference dropdown is changed.
            setEnabled({app.Confidence,app.NumSurrogates,app.RandomSeed},true);
        end
    end

    function onInferenceSelectionChanged()
        updateSignificanceControlEnablement();
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        recordParameterCorrections(cell(0,1));
        updateInferenceSelection(true);
    end

    function onDirectDisplayChanged(label)
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        recordParameterCorrections(cell(0,1));
        onDisplayChanged(label);
    end

    function updateInferenceSelection(redraw)
        selected = char(app.Significance.Value);
        if strcmp(selected,'none')
            app.DisplayInferenceMethod = 'none';
            app.InferenceDirty = false;
            if redraw && ~isempty(app.LastResult)
                renderLatest('Inference contour hidden');
            elseif isempty(app.LastResult)
                setStatusSafe( ...
                    'No inference selected; Run will estimate spectra without surrogates');
                publishState();
            end
            return
        end
        if inferenceMatchesCached(selected)
            app.DisplayInferenceMethod = selected;
            app.InferenceDirty = false;
            if redraw
                renderLatest('Cached inference contour restored');
            end
        else
            app.InferenceDirty = true;
            if isempty(app.LastResult)
                setStatusSafe('Selected inference has not been calculated; press Run or Run & Save');
            else
                setStatusSafe([ ...
                    'Selected inference settings are not cached; latest figure remains unchanged | ', ...
                    'press Run or Run & Save']);
            end
            publishState();
        end
    end

    function onInferenceParameterChanged(label)
        if app.IsApplyingDefaults || app.IsRunning
            return
        end
        if strcmp(app.Significance.Value,'none')
            app.InferenceDirty = false;
            setStatusSafe(sprintf([ ...
                '%s updated; it will apply when IAAFT inference is selected ', ...
                'and Run is pressed'],label));
            publishState();
            return
        end
        if inferenceMatchesCached('surrogate-global')
            app.InferenceDirty = false;
            restoreDisplay = strcmp(app.Significance.Value,'surrogate-global') && ...
                ~strcmp(app.DisplayInferenceMethod,'surrogate-global');
            if restoreDisplay && ~isempty(app.LastResult)
                app.DisplayInferenceMethod = 'surrogate-global';
                renderLatest('Cached inference contour restored');
            elseif strcmp(app.Significance.Value,'none')
                setStatusSafe(sprintf( ...
                    '%s matches the cached IAAFT result; contour remains hidden',label));
            else
                setStatusSafe(sprintf('%s matches the cached inference result',label));
            end
        else
            app.InferenceDirty = true;
            setStatusSafe(sprintf( ...
                '%s changed; cached contour remains unchanged | press Run or Run & Save',label));
        end
        publishState();
    end

    function matches = inferenceMatchesCached(selected)
        matches = false;
        if isempty(app.LastResult) || ~isfield(app.LastResult,'Significance')
            return
        end
        cached = app.LastResult.Significance;
        selected = char(selected);
        if ~strcmp(selected,char(cached.Method))
            return
        end
        tolerance = 64*eps(max(1,abs(cached.ConfidenceLevel)));
        if abs(app.Confidence.Value/100-cached.ConfidenceLevel) > tolerance
            return
        end
        if contains(selected,'surrogate')
            if ~strcmp('iaaft',char(cached.SurrogateType)) || ...
                    app.NumSurrogates.Value ~= cached.NumSurrogates || ...
                    app.RandomSeed.Value ~= cached.RandomSeed
                return
            end
            if ~iaaftSettingsMatchCached()
                return
            end
        end
        matches = true;
    end

    function matches = iaaftSettingsMatchCached()
        matches = false;
        if isempty(app.LastResult) || ~isfield(app.LastResult,'Options')
            return
        end
        cachedOptions = app.LastResult.Options;
        names = {'IAAFTIterations','IAAFTSpectralTolerance', ...
            'MaxSurrogateAttempts'};
        names = names(cellfun(@(name)isfield(app.Defaults,name),names));
        for ii = 1:numel(names)
            name = names{ii};
            if ~isfield(cachedOptions,name) || ...
                    ~isequaln(app.Defaults.(name),cachedOptions.(name))
                return
            end
        end
        matches = true;
    end

    function publishState()
        if ~isValidUiHandle(app.UIFigure)
            return
        end
        state = struct( ...
            'HasResult',~isempty(app.LastResult), ...
            'LastResult',app.LastResult, ...
            'LastFigure',app.LastFigure, ...
            'LastPlotHandles',app.LastPlotHandles, ...
            'DisplayInferenceMethod',app.DisplayInferenceMethod, ...
            'CalculationDirty',app.CalculationDirty, ...
            'InferenceDirty',app.InferenceDirty, ...
            'ComputationDirty',app.CalculationDirty || app.InferenceDirty, ...
            'AnalysisCount',app.AnalysisCount, ...
            'LastParameterCorrections',{app.LastParameterCorrections}, ...
            'LastOperationParameterCorrections',{ ...
            app.LastOperationParameterCorrections}, ...
            'PendingParameterCorrections',{app.PendingParameterCorrections}, ...
            'ParameterCorrectionCount',app.ParameterCorrectionCount, ...
            'ParameterAlertRequestCount',app.ParameterAlertRequestCount, ...
            'ParameterAlertFailureCount',app.ParameterAlertFailureCount, ...
            'ScientificAlertRequestCount',app.ScientificAlertRequestCount, ...
            'ScientificAlertFailureCount',app.ScientificAlertFailureCount, ...
            'IsRunning',app.IsRunning, ...
            'IsRendering',app.IsRendering);
        setappdata(app.UIFigure,'BispectralState',state);
    end

    function showScientificWarningAlert(result)
        samplingWarnings = {};
        if isfield(result,'Preprocessing') && ...
                isfield(result.Preprocessing,'WasIrregular') && ...
                isfield(result.Preprocessing,'WasInterpolated') && ...
                result.Preprocessing.WasIrregular && ...
                result.Preprocessing.WasInterpolated && ...
                isfield(result.Preprocessing,'Warnings')
            allPreprocessingWarnings = appendScientificWarnings( ...
                {},result.Preprocessing.Warnings);
            samplingWarnings = allPreprocessingWarnings(contains( ...
                string(allPreprocessingWarnings), ...
                'interpolated onto a regular grid','IgnoreCase',true));
        end
        if isempty(samplingWarnings) || ...
                ~isValidUiHandle(app.UIFigure) || ...
                ~strcmp(app.UIFigure.Visible,'on')
            return
        end
        message = [{'The analysis completed. Review these scientific warnings:'}; ...
            strcat('- ',samplingWarnings(:)); ...
            {'Automatic sampling interpolation, when used, is recorded in the result metadata.'}];
        app.ScientificAlertRequestCount = ...
            app.ScientificAlertRequestCount+1;
        try
            feval(app.TestHooks.AlertFcn,app.UIFigure,message, ...
                'Bispectral data warning','Icon','warning');
        catch exception
            app.ScientificAlertFailureCount = ...
                app.ScientificAlertFailureCount+1;
            fprintf(2,['[Acycle Bispectral] The scientific warning dialog ', ...
                'could not be displayed (%s). The completed result remains active.\n'], ...
                exception.message);
        end
        publishState();
    end

    function showHelp()
        message = { ...
            'Displayed quantities: squared bicoherence b^2, bispectrum amplitude |B|, and biphase.'; ...
            'The MAT result retains complex B and derived components for reproducibility; redundant b=sqrt(b^2), Re(B), and Im(B) are not separate GUI figures.'; ...
            'WOSA averages Hann-tapered segment FFT triads and is the recommended general estimator.'; ...
            'Frequency-smoothed direct analysis uses a full hexagonal kernel on native (not zero-padded) FFT bins.'; ...
            'The only formal GUI inference is IAAFT surrogate max-statistic FWER. None hides a cached contour immediately, and a new Run with None skips inference.'; ...
            'The 199-surrogate default balances precision and runtime; use 999 or more for final publication inference.'; ...
            'This window requires finite, strictly increasing, unique observations and never silently deletes, sorts, or merges rows. Coordinate-spacing departures above 10 ppm trigger a warning and replace the series with its linear median-spacing interpolation grid before FFT analysis.'; ...
            'Minimum and maximum frequency clip the figure only; estimation and map-wide inference retain the full positive-frequency domain.'; ...
            '|B| and b^2 retain fractions are display-only, independently ranked within the current visible frequency range; biphase uses the b^2 mask.'; ...
            'Colormap grid # is shared by all maps; five thin value contours use the same refined display mesh.'; ...
            'Space-separated reference periods draw f1+f2=1/period guide lines after Tab or Enter; 1/period must be below Nyquist.'; ...
            'Frequency pairs use f1 f2; f3,f4 syntax; frequencies and their sum must remain below Nyquist. Tab or Enter redraws thin dotted guides with 1/f1 and 1/f2 labels outside the map.'; ...
            'Overview power panels use the mean-removed processed series and 2pi Thomson MTM (NW=2, K=3, NFFT=5N), independent of the bispectral estimator.'; ...
            'After a Run, display controls redraw the cached result; estimator or uncached inference changes wait for the next Run.'; ...
            'Invalid GUI parameters are reported and restored to recommended or last-valid values. Nonfinite, unsorted, duplicate, or too-short inputs still stop; recoverable uneven sampling is warned about and regularized. Correction records remain pending through Preview runs and are archived by the next successful Run & Save.'; ...
            'Interpretation: high b^2 is stable quadratic phase coupling, not automatic proof of causality or energy transfer.'; ...
            'References: Kim & Powers (1979); Da Silva et al. (2019), Geology, doi:10.1130/G45511.1.'};
        uialert(app.UIFigure,message,'Bispectral method notes','Icon','info');
    end

    function onKeyPress(~,event)
        try
            modifiers = lower(string(event.Modifier));
            if strcmpi(event.Key,'w') && ...
                    any(modifiers == "command" | modifiers == "control")
                onCloseRequest([],[]);
            end
        catch
        end
    end
end

function hooks = resolveGuiTestHooks(context)
% Internal dependency seams make failure-state regression tests
% deterministic without changing the production code path.
hooks = struct('AlertFcn',@uialert, ...
    'SaveFcn',@bispectralSave,'AfterCandidatePlotFcn',[]);
if ~isfield(context,'BispectralTestHooks')
    return
end
candidate = context.BispectralTestHooks;
if ~(isstruct(candidate) && isscalar(candidate))
    error('Acycle:BispectralGUI:InvalidTestHooks', ...
        'BispectralTestHooks must be a scalar structure.');
end
allowed = fieldnames(hooks);
supplied = fieldnames(candidate);
unknown = setdiff(supplied,allowed);
if ~isempty(unknown)
    error('Acycle:BispectralGUI:InvalidTestHooks', ...
        'Unknown BispectralTestHooks field: %s.',unknown{1});
end
for ii = 1:numel(supplied)
    name = supplied{ii};
    value = candidate.(name);
    mayBeEmpty = strcmp(name,'AfterCandidatePlotFcn');
    if ~(isa(value,'function_handle') || (mayBeEmpty && isempty(value)))
        if mayBeEmpty
            rule = 'a function handle or empty';
        else
            rule = 'a function handle';
        end
        error('Acycle:BispectralGUI:InvalidTestHooks', ...
            '%s must be %s.',name,rule);
    end
    hooks.(name) = value;
end
end

function addLabel(grid,row,textValue,fontColor)
label = uilabel(grid,'Text',textValue,'HorizontalAlignment','right');
if nargin >= 4
    label.FontColor = fontColor;
end
setCell(label,row,1);
end

function setCell(control,row,column)
control.Layout.Row = row;
control.Layout.Column = column;
end

function setEnabled(controls,enabled)
if enabled, value = 'on'; else, value = 'off'; end
if ~iscell(controls), controls = {controls}; end
for ii = 1:numel(controls)
    controls{ii}.Enable = value;
end
end

function valid = isValidUiHandle(value)
try
    valid = ~isempty(value) && isvalid(value);
catch
    try
        valid = ~isempty(value) && isgraphics(value);
    catch
        valid = false;
    end
end
end

function name = getDataName(context)
if isfield(context,'data_name') && ~isempty(context.data_name)
    name = char(context.data_name);
else
    name = 'data';
end
end

function unit = getCoordinateUnit(context)
unit = 'unit';
if isfield(context,'unit') && ~isempty(context.unit)
    unit = char(context.unit);
end
try
    if isfield(context,'popupmenu1') && isgraphics(context.popupmenu1)
        items = get(context.popupmenu1,'String');
        index = get(context.popupmenu1,'Value');
        if ischar(items), items = cellstr(items); end
        if index >= 1 && index <= numel(items), unit = char(items{index}); end
    end
catch
end
end

function text = dataSummary(data,name)
finite = all(isfinite(data(:,1:2)),2);
x = unique(sort(double(data(finite,1))));
if numel(x) < 2
    text = sprintf('%s | insufficient finite coordinates',name);
    return
end
dx = diff(x);
dt = estimateSampleInterval(data);
departure = max(abs(dx-dt))/dt;
text = sprintf('%s | N=%d | range %.6g to %.6g | median dx=%.6g | Nyquist=%.6g | max spacing departure %.2f%%', ...
    name,sum(finite),x(1),x(end),dt,1/(2*dt),100*departure);
end

function dt = estimateSampleInterval(data)
finite = all(isfinite(data(:,1:2)),2);
x = unique(sort(double(data(finite,1))));
dx = diff(x);
dx = dx(isfinite(dx) & dx > 0);
if isempty(dx)
    dt = 1;
else
    dt = median(dx);
end
end

function n = anticipatedGuiSampleCount(data,options)
% Use the production preprocessing path so GUI geometry validation is based
% on the same regular grid that the estimator will actually receive. Keep
% structural input errors deferred until Run, as in the existing GUI flow.
n = size(data,1);
try
    [processed,~] = bispectralPreprocess(data,options);
    n = size(processed,1);
catch
end
end

function options = applyAnticipatedSampleCountDefaults(options,n)
% Re-evaluate the estimator recommendation after strict/auto sampling has
% established its anticipated grid length. Raw-row defaults can otherwise
% request WOSA segments that no longer fit after interpolation.
base = bispectralDefaults();
options.NumSegments = base.NumSegments;
candidateSegments = base.NumSegments;
while candidateSegments >= 3 && ...
        ~wosaConfigurationFeasible(n,candidateSegments, ...
        options.OverlapPercent)
    candidateSegments = candidateSegments-1;
end
if candidateSegments >= 3
    options.Estimator = 'wosa';
    options.NumSegments = candidateSegments;
else
    options.Estimator = 'frequency-smoothed';
end
end

function refreshMainList(context,outputDirectory)
try
    ac_refresh_main_list(context.listbox_acmain,outputDirectory);
catch
end
end

function warnings = collectScientificWarnings(result)
warnings = {};
if isfield(result,'Preprocessing') && isfield(result.Preprocessing,'Warnings')
    warnings = appendScientificWarnings(warnings,result.Preprocessing.Warnings);
end
if isfield(result,'Meta') && isfield(result.Meta,'Warnings')
    warnings = appendScientificWarnings(warnings,result.Meta.Warnings);
end
if isfield(result,'Significance') && isfield(result.Significance,'Warnings')
    warnings = appendScientificWarnings(warnings,result.Significance.Warnings);
end
if ~isempty(warnings)
    warnings = unique(warnings,'stable');
end
end

function warnings = appendScientificWarnings(warnings,values)
if isempty(values)
    return
end
if ischar(values)
    values = cellstr(values);
elseif isstring(values)
    values = cellstr(values(:));
elseif ~iscell(values)
    values = cellstr(string(values(:)));
end
for ii = 1:numel(values)
    value = values{ii};
    if isstring(value) && isscalar(value)
        value = char(value);
    end
    if ischar(value)
        value = strtrim(value);
        if ~isempty(value)
            warnings{end+1} = value; %#ok<AGROW>
        end
    end
end
end

function printScientificWarnings(warnings,dataName)
fprintf(2,'\n[Acycle Bispectral] Scientific warnings for %s:\n',char(dataName));
for ii = 1:numel(warnings)
    fprintf(2,'  - %s\n',warnings{ii});
end
fprintf(2,'\n');
end

function periods = parseReferencePeriods(rawValue)
if isstring(rawValue)
    if ~isscalar(rawValue)
        error('Acycle:BispectralGUI:InvalidReferencePeriods', ...
            'Enter periods as one space-separated line.');
    end
    rawValue = char(rawValue);
elseif iscell(rawValue) && isscalar(rawValue)
    rawValue = rawValue{1};
end
if isempty(rawValue) || (ischar(rawValue) && isempty(strtrim(rawValue)))
    periods = [];
    return
end
if ~ischar(rawValue)
    error('Acycle:BispectralGUI:InvalidReferencePeriods', ...
        'Enter periods as numbers separated by spaces.');
end
if numel(rawValue) > 4096
    error('Acycle:BispectralGUI:ReferencePeriodsTooLong', ...
        'Reference periods must contain at most 4096 characters.');
end
tokens = regexp(strtrim(rawValue),'[\s,;]+','split');
if numel(tokens) > 64
    error('Acycle:BispectralGUI:TooManyReferencePeriods', ...
        'Enter at most 64 reference periods.');
end
periods = str2double(tokens);
if isempty(periods) || any(~isfinite(periods)) || any(periods <= 0)
    error('Acycle:BispectralGUI:InvalidReferencePeriods', ...
        'Every reference period must be a positive finite number.');
end
periods = unique(periods,'stable');
end

function validateReferencePeriodsForData(periods,nyquist)
if isempty(periods)
    return
end
sumFrequencies = 1./periods;
if any(sumFrequencies >= nyquist)
    error('Acycle:BispectralGUI:ReferencePeriodOutsideDomain', ...
        ['Each reference period must imply 1/period below the Nyquist ', ...
         'frequency (%.15g), the theoretical upper limit for an ', ...
         'f1+f2 guide.'],nyquist);
end
end

function textValue = formatPeriods(periods)
if isempty(periods)
    textValue = '';
    return
end
labels = arrayfun(@(value)sprintf('%.15g',value),periods(:)', ...
    'UniformOutput',false);
textValue = strjoin(labels,' ');
end

function pairs = parseFrequencyPairs(rawValue)
if isstring(rawValue)
    if ~isscalar(rawValue)
        error('Acycle:BispectralGUI:InvalidFrequencyPairs', ...
            'Enter frequency pairs on one semicolon-separated line.');
    end
    rawValue = char(rawValue);
elseif iscell(rawValue) && isscalar(rawValue)
    rawValue = rawValue{1};
end
if isempty(rawValue) || (ischar(rawValue) && isempty(strtrim(rawValue)))
    pairs = zeros(0,2);
    return
end
if ~ischar(rawValue)
    error('Acycle:BispectralGUI:InvalidFrequencyPairs', ...
        'Enter frequency pairs as f1 f2; f3,f4.');
end
if numel(rawValue) > 4096
    error('Acycle:BispectralGUI:FrequencyPairsTooLong', ...
        'Frequency pairs must contain at most 4096 characters.');
end
groups = regexp(strtrim(rawValue),'\s*;\s*','split');
if numel(groups) > 64
    error('Acycle:BispectralGUI:TooManyFrequencyPairs', ...
        'Enter at most 64 frequency pairs.');
end
pairs = zeros(numel(groups),2);
for ii = 1:numel(groups)
    tokens = regexp(strtrim(groups{ii}),'[\s,]+','split');
    values = str2double(tokens);
    if numel(values) ~= 2 || any(~isfinite(values)) || any(values <= 0)
        error('Acycle:BispectralGUI:InvalidFrequencyPairs', ...
            'Each pair must contain exactly two positive finite frequencies.');
    end
    pairs(ii,:) = values;
end
pairs = unique(pairs,'rows','stable');
end

function validateFrequencyPairsForData(pairs,nyquist)
if isempty(pairs)
    return
end
outsideDomain = any(pairs >= nyquist,2) | sum(pairs,2) >= nyquist;
if any(outsideDomain)
    error('Acycle:BispectralGUI:FrequencyPairOutsideDomain', ...
        ['Every frequency must be below Nyquist (%.15g), and each pair ', ...
         'must satisfy f1+f2 < Nyquist, the theoretical positive-frequency ', ...
         'triad-sum limit.'],nyquist);
end
end

function textValue = formatFrequencyPairs(pairs)
if isempty(pairs)
    textValue = '';
    return
end
groups = arrayfun(@(row)sprintf('%.15g %.15g', ...
    pairs(row,1),pairs(row,2)),1:size(pairs,1),'UniformOutput',false);
textValue = strjoin(groups,'; ');
end

function retireManagedFigure(fig)
if isempty(fig) || ~isgraphics(fig,'figure')
    return
end
try
    setappdata(fig,'BispectralLayoutReady',false);
    fig.SizeChangedFcn = [];
    fig.Visible = 'off';
    drawnow nocallbacks
    if isgraphics(fig,'figure')
        delete(fig);
    end
    drawnow nocallbacks
catch exception
    fprintf(2,['[Acycle Bispectral] Previous result figure cleanup failed ', ...
        '(%s); the newly rendered result remains active.\n'],exception.message);
    try
        if isgraphics(fig,'figure')
            delete(fig);
        end
    catch
    end
end
end

function yes = isFiniteRealScalar(value)
yes = isnumeric(value) && isreal(value) && isscalar(value) && isfinite(value);
end

function yes = isFiniteIntegerScalar(value)
yes = isFiniteRealScalar(value) && value == fix(value);
end

function combined = appendUniqueCorrections(existing,incoming)
if isempty(existing)
    existing = cell(0,1);
end
if isempty(incoming)
    combined = existing(:);
    return
end
combined = unique([existing(:);incoming(:)],'stable');
end

function yes = wosaConfigurationFeasible(n,numSegments,overlapPercent)
yes = false;
if ~(isFiniteIntegerScalar(n) && n >= 1 && ...
        isFiniteIntegerScalar(numSegments) && numSegments >= 3 && ...
        isFiniteRealScalar(overlapPercent) && ...
        overlapPercent >= 0 && overlapPercent < 90)
    return
end
segmentLength = floor(n/(1+(numSegments-1)*(1-overlapPercent/100)));
if segmentLength < 32
    return
end
starts = round(linspace(1,n-segmentLength+1,numSegments));
yes = numel(unique(starts)) == numSegments;
end

function textValue = formatParameterValue(value)
if ischar(value)
    textValue = quoteBoundedText(value);
elseif isstring(value) && isscalar(value)
    textValue = quoteBoundedText(char(value));
elseif isnumeric(value) && isscalar(value)
    textValue = sprintf('%.15g',value);
elseif islogical(value) && isscalar(value)
    textValue = char(string(value));
else
    try
        textValue = char(string(value));
    catch
        textValue = '<unprintable value>';
    end
end
if isempty(textValue)
    textValue = '''''';
end
end

function textValue = quoteBoundedText(value)
maximumDisplayedCharacters = 160;
originalLength = numel(value);
if originalLength > maximumDisplayedCharacters
    value = [value(1:maximumDisplayedCharacters),'...'];
    textValue = sprintf('''%s'' [%d characters]',value,originalLength);
else
    textValue = ['''',value,''''];
end
end

function printGuiFailure(context,exception)
fprintf(2,'\n[Acycle Bispectral] %s:\n  %s\n\n',context,exception.message);
end
