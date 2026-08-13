function tests = test_bispectral_plot
%TEST_BISPECTRAL_PLOT Regression tests for frequency-mesh rendering.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
toolboxDirectory = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
addpath(toolboxDirectory);
testCase.addTeardown(@()path(oldPath));
end

function testFrequencyLimitsAreViewOnlyAndMapsUseMesh(testCase)
n = 512;
t = (0:n-1)';
y = cos(2*pi*31*t/128+0.2)+0.7*cos(2*pi*19*t/128-0.4) ...
    +0.5*cos(2*pi*50*t/128-0.2);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
options.Interpolate = 'never';
options.DetrendMethod = 'none';
options.Standardize = false;
options.FrequencyMax = 0.18;
result = bispectralAnalyze([t y],options);
viewChangedOptions = options;
viewChangedOptions.FrequencyMin = 0.07;
viewChangedOptions.FrequencyMax = 0.12;
viewChangedResult = bispectralAnalyze([t y],viewChangedOptions);
verifyEqual(testCase,viewChangedResult.Frequency,result.Frequency);
verifyEqual(testCase,viewChangedResult.Bispectrum,result.Bispectrum);
verifyEqual(testCase,viewChangedResult.BicoherenceSquared, ...
    result.BicoherenceSquared);

[fig,handles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','ShowPeriodAxes',false,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
surfaces = findobj(handles.Map,'Type','surface');
verifyNumElements(testCase,surfaces,1);
verifyGreaterThan(testCase,size(surfaces.XData,1),numel(result.Frequency));
displayFrequency = linspace(result.Frequency(1),result.Frequency(end), ...
    size(surfaces.XData,1));
[expectedX,expectedY] = meshgrid(displayFrequency,displayFrequency);
verifyEqual(testCase,surfaces.XData,expectedX,'AbsTol',32*eps);
verifyEqual(testCase,surfaces.YData,expectedY,'AbsTol',32*eps);
verifyEqual(testCase,surfaces.FaceColor,'interp');
verifyEqual(testCase,handles.Map.XLim,[result.Frequency(1),options.FrequencyMax], ...
    'AbsTol',32*eps);
verifyEqual(testCase,handles.Map.YLim,handles.Map.XLim,'AbsTol',32*eps);
verifyEqual(testCase,pbaspect(handles.Map),[1 1 1],'AbsTol',32*eps);
bicoherenceMap = colormap(handles.Map);
verifySize(testCase,bicoherenceMap,[32 3]);
renderSettings = getappdata(fig,'BispectralRenderSettings');
verifyEqual(testCase,renderSettings.Quantity,'bicoherence-squared');
verifyEqual(testCase,renderSettings.FrequencyMinimum,result.Frequency(1), ...
    'AbsTol',32*eps);
verifyEqual(testCase,renderSettings.FrequencyMaximum,options.FrequencyMax, ...
    'AbsTol',32*eps);
verifyEqual(testCase,renderSettings.BispectrumKeepStrongestFraction, ...
    options.PlotKeepStrongestBispectrumFraction);
verifyEqual(testCase,renderSettings.BicoherenceKeepStrongestFraction, ...
    options.PlotKeepStrongestBicoherenceFraction);
verifyEqual(testCase,renderSettings.FrequencyPairs,zeros(0,2));
verifyEqual(testCase,renderSettings.PowerSpectrumMethod,'2pi MTM (Thomson)');
verifyEqual(testCase,renderSettings.PowerSpectrumTimeBandwidth,2);
verifyEqual(testCase,renderSettings.PowerSpectrumTaperCount,3);
verifyEqual(testCase,renderSettings.PowerSpectrumPaddingFactor,5);
verifyFalse(testCase,renderSettings.PowerSpectrumDisplayed);
verifyEqual(testCase,handles.Colorbar.Location,'southoutside');
verifyLessThan(testCase,handles.Colorbar.Label.Position(1),0);
verifyEqual(testCase,handles.Colorbar.Label.Position(2),0.5,'AbsTol',32*eps);
verifyFalse(testCase,isfield(renderSettings,'Visible'));
verifyFalse(testCase,isfield(renderSettings,'KeepStrongestFraction'));

[fig2,handles2] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bispectrum-magnitude','ShowPeriodAxes',false,'PeakCount',0);
cleanup2 = onCleanup(@()closeFigure(fig2));
verifyEqual(testCase,colormap(handles2.Map),bicoherenceMap,'AbsTol',32*eps);

[fig3,handles3] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','FrequencyMinimum',0.04, ...
    'FrequencyMaximum',0.16,'ShowPeriodAxes',false,'PeakCount',0);
cleanup3 = onCleanup(@()closeFigure(fig3));
verifyEqual(testCase,handles3.Map.XLim,[0.04 0.16],'AbsTol',32*eps);
verifyEqual(testCase,handles3.Map.YLim,handles3.Map.XLim,'AbsTol',32*eps);
end

function testGuiHasNoPreprocessingControls(testCase)
n = 128;
t = (0:n-1)';
context = struct('current_data',[t sin(2*pi*t/41)], ...
    'data_name','gui-test.txt','unit','kyr');
fig = bispectralGUI(context);
cleanup = onCleanup(@()closeFigure(fig));
controls = getappdata(fig,'BispectralControls');
verifyFalse(testCase,isfield(controls,'Interpolate'));
verifyFalse(testCase,isfield(controls,'Detrend'));
verifyEqual(testCase,controls.Defaults.Interpolate,'auto');
verifyEqual(testCase,controls.Defaults.DetrendMethod,'none');
verifyFalse(testCase,controls.Defaults.Standardize);
verifyEqual(testCase,controls.Defaults.InputPolicy,'strict');
verifyEqual(testCase,controls.Defaults.PlotKeepStrongestBispectrumFraction,0.5);
verifyEqual(testCase,controls.Defaults.PlotKeepStrongestBicoherenceFraction,0.5);
verifyEqual(testCase,controls.Defaults.PlotColorGrid,32);
verifyEqual(testCase,controls.Defaults.PlotFrequencyPairs,zeros(0,2));
verifyEqual(testCase,controls.Defaults.SignificanceMethod,'surrogate-global');
verifyEqual(testCase,controls.Defaults.SurrogateType,'iaaft');
verifyEqual(testCase,controls.Defaults.NumSurrogates,199);
verifyEqual(testCase,controls.KeepBispectrum.Value,50);
verifyEqual(testCase,controls.KeepBicoherence.Value,50);
verifyEqual(testCase,controls.ColorGrid.Value,32);
verifyEqual(testCase,string(controls.PlotQuantity.ItemsData), ...
    ["overview" "bicoherence-squared" "bispectrum-magnitude" "biphase"]);
scienceBlue = [0.00 0.24 0.68];
instantGreen = [0.00 0.35 0.16];
defaultBlack = [0 0 0];
blueLabels = {'Method','Number of segments','Within-segment detrend', ...
    'Frequency-smoothing span','Maximum computed freq. bins', ...
    'Number of surrogates','Inference'};
blackLabels = {'Overlap (%)','Taper','Zero-padding factor', ...
    'Frequency kernel','FWER confidence (%)','Random seed'};
greenLabels = {'Minimum frequency','Maximum plotted frequency','Figure', ...
    'Retain |B| strongest (%)','Retain b^2 strongest (%)', ...
    'Colormap grid #','Reference periods','Frequency pairs', ...
    'Peak annotations','Secondary axis'};
verifyGuiLabelColors(testCase,fig,blueLabels,scienceBlue);
verifyGuiLabelColors(testCase,fig,blackLabels,defaultBlack);
verifyGuiLabelColors(testCase,fig,greenLabels,instantGreen);
verifyEqual(testCase,controls.AnnotatePeaks.FontColor,instantGreen,'AbsTol',32*eps);
verifyEqual(testCase,controls.PeriodAxes.FontColor,instantGreen,'AbsTol',32*eps);
verifyEqual(testCase,string(controls.Significance.ItemsData), ...
    ["none" "surrogate-global"]);
verifyEqual(testCase,string(controls.Significance.Items), ...
    ["None (hide inference)" "IAAFT surrogate max-statistic (FWER)"]);
verifyEqual(testCase,controls.KeepBispectrum.Parent,controls.KeepBicoherence.Parent);
verifyEqual(testCase,controls.KeepBispectrum.Parent,controls.ColorGrid.Parent);
verifyEqual(testCase,controls.KeepBispectrum.Layout.Row,1);
verifyEqual(testCase,controls.KeepBicoherence.Layout.Row,1);
verifyEqual(testCase,controls.ColorGrid.Layout.Row,1);
originalPosition = fig.Position;
baselineGeometry = settleGuiOutputLayout(fig,controls);
verifyOutputControlGeometry(testCase,controls,baselineGeometry);
expandedPosition = originalPosition;
expandedPosition(3) = originalPosition(3) + 137;
fig.Position = expandedPosition;
expandedGeometry = settleGuiOutputLayout(fig,controls);
verifyOutputControlGeometry(testCase,controls,expandedGeometry);
verifyEqual(testCase,expandedGeometry.Reset(3)-baselineGeometry.Reset(3), ...
    137/2,'AbsTol',1);
verifyEqual(testCase,expandedGeometry.Preview(3)-baselineGeometry.Preview(3), ...
    137/3,'AbsTol',1);
fig.Position = originalPosition;
restoredGeometry = settleGuiOutputLayout(fig,controls);
verifyOutputControlGeometry(testCase,controls,restoredGeometry);
verifyEqual(testCase,restoredGeometry.Reset(3),baselineGeometry.Reset(3), ...
    'AbsTol',1);
verifyEqual(testCase,restoredGeometry.Preview(3),baselineGeometry.Preview(3), ...
    'AbsTol',1);
verifyFalse(testCase,isfield(controls,'SurrogateType'));
end

function verifyOutputControlGeometry(testCase,controls,geometry)
verifyEqual(testCase,geometry.Retain(1),geometry.Quantity(1),'AbsTol',1);
verifyEqual(testCase,geometry.Reset(2),geometry.Help(2),'AbsTol',1);
verifyEqual(testCase,geometry.Reset(3:4),geometry.Help(3:4),'AbsTol',1);
verifyEqual(testCase,geometry.Help(1)-sum(geometry.Reset([1 3])),10, ...
    'AbsTol',1);
verifyGreaterThan(testCase,geometry.Help(1),sum(geometry.Reset([1 3])));
verifyEqual(testCase,geometry.Preview(3),geometry.Save(3),'AbsTol',1);
verifyEqual(testCase,controls.KeepBispectrum.Parent.Padding,[40 0 0 0]);
verifyEqual(testCase,controls.ResetButton.Parent,controls.HelpButton.Parent);
end

function geometry = settleGuiOutputLayout(fig,controls)
% R2025b web components can briefly report the same 100-pixel placeholder
% geometry for unrelated controls. Nudge the width, then require two stable
% resolved samples before testing actual component positions.
targetPosition = fig.Position;
expectedResetWidth = (targetPosition(3)-64)/2;
expectedPreviewWidth = (targetPosition(3)-52)/3;
nudgePosition = targetPosition;
nudgePosition(3) = targetPosition(3)+1;
fig.Position = nudgePosition;
drawnow;
fig.Position = targetPosition;
lastSignature = [];
stableCount = 0;
resolved = false;
attempt = 0;
while attempt < 100
    attempt = attempt+1;
    drawnow;
    pause(0.02);
    geometry = captureGuiOutputGeometry(controls);
    signature = [geometry.Quantity geometry.Retain geometry.Reset ...
        geometry.Help geometry.Preview geometry.Save];
    actionGap = geometry.Help(1)-sum(geometry.Reset([1 3]));
    resolved = abs(geometry.Retain(3)-58) <= 1 && ...
        abs(actionGap-10) <= 1 && ...
        abs(geometry.Reset(3)-expectedResetWidth) <= 1 && ...
        abs(geometry.Preview(3)-expectedPreviewWidth) <= 1;
    if resolved && ~isempty(lastSignature) && ...
            max(abs(signature-lastSignature),[],'all') <= 0.01
        stableCount = stableCount+1;
    else
        stableCount = 0;
    end
    if stableCount >= 2
        return
    end
    lastSignature = signature;
end
assert(resolved && stableCount >= 2, ...
    'Acycle:BispectralTest:GuiLayoutDidNotSettle', ...
    'R2025b did not resolve the bispectral GUI component geometry in time.');
end

function geometry = captureGuiOutputGeometry(controls)
geometry = struct( ...
    'Quantity',getpixelposition(controls.PlotQuantity,true), ...
    'Retain',getpixelposition(controls.KeepBispectrum,true), ...
    'Reset',getpixelposition(controls.ResetButton,true), ...
    'Help',getpixelposition(controls.HelpButton,true), ...
    'Preview',getpixelposition(controls.PreviewButton,true), ...
    'Save',getpixelposition(controls.SaveButton,true));
end

function testGuiInvalidParametersAreReportedCorrectedAndUsed(testCase)
n = 128;
t = (0:n-1)';
y = sin(2*pi*t/37)+0.35*cos(2*pi*t/19);
context = struct('current_data',[t y], ...
    'data_name','parameter-sanitizer-test.txt','unit','kyr');
gui = bispectralGUI(context);
gui.Visible = 'off';
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');
verifyEqual(testCase,string(controls.NumSegments.RoundFractionalValues),"off");
verifyEqual(testCase,string(controls.MaxBins.RoundFractionalValues),"off");
verifyEqual(testCase,string(controls.NumSurrogates.RoundFractionalValues),"off");
verifyEqual(testCase,string(controls.RandomSeed.RoundFractionalValues),"off");
verifyEqual(testCase,string(controls.ColorGrid.RoundFractionalValues),"off");
verifyEqual(testCase,controls.ColorGrid.Limits,[-Inf Inf]);

% Bypass ValueChanged to exercise the mandatory Run-time full validation.
controls.Significance.Value = 'none';
controls.NumSegments.Value = 4.5;
controls.MaxBins.Value = -8;
controls.FrequencyMin.Value = 0.40;
controls.FrequencyMax.Value = 0.50;
controls.Confidence.Value = 99.9;
controls.NumSurrogates.Value = 20;
controls.RandomSeed.Value = 1.5;
controls.KeepBispectrum.Value = 0;
controls.ColorGrid.Value = -12;
invokeButton(controls.PreviewButton);

state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,1);
verifyGreaterThanOrEqual(testCase,numel(state.LastParameterCorrections),7);
verifyGreaterThanOrEqual(testCase,state.ParameterCorrectionCount,7);
verifyTrue(testCase,any(contains(string(state.LastParameterCorrections), ...
    'Colormap grid #')));
verifyTrue(testCase,any(contains(string(state.LastParameterCorrections), ...
    'plus-one p-value grid')));
verifyTrue(testCase,any(contains(string(state.LastParameterCorrections), ...
    'no computed principal-domain triad')));
verifyEqual(testCase,controls.NumSegments.Value,controls.Defaults.NumSegments);
verifyEqual(testCase,controls.MaxBins.Value,controls.Defaults.MaxFrequencyBins);
verifyEqual(testCase,controls.FrequencyMin.Value,0);
verifyEqual(testCase,controls.FrequencyMax.Value,0.5,'AbsTol',32*eps);
verifyEqual(testCase,controls.Confidence.Value,95);
verifyEqual(testCase,controls.NumSurrogates.Value,20);
verifyEqual(testCase,controls.RandomSeed.Value,1);
verifyEqual(testCase,controls.KeepBispectrum.Value,50);
verifyEqual(testCase,controls.ColorGrid.Value,32);
verifyEqual(testCase,state.LastResult.Options.NumSegments, ...
    controls.Defaults.NumSegments);
verifyEqual(testCase,state.LastResult.Options.MaxFrequencyBins,512);
verifyEqual(testCase,state.LastResult.Options.ConfidenceLevel,0.95);
verifyEqual(testCase,state.LastResult.Options.RandomSeed,1);
verifyEqual(testCase,state.LastResult.Options.PlotColorGrid,32);
verifyEqual(testCase,state.LastResult.GUIParameterCorrections, ...
    state.LastParameterCorrections);
renderSettings = getappdata(state.LastFigure,'BispectralRenderSettings');
verifyEqual(testCase,renderSettings.ColorGrid,32);
verifyTrue(testCase,contains(controls.Status.Text, ...
    'GUI parameter correction(s)'));

analysisCount = state.AnalysisCount;
correctionCount = state.ParameterCorrectionCount;
controls.ColorGrid.Value = 12.5;
invokeValueChanged(controls.ColorGrid);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,analysisCount);
verifyEqual(testCase,controls.ColorGrid.Value,32);
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount+1);
verifyNumElements(testCase,state.LastParameterCorrections,1);
verifyTrue(testCase,contains(state.LastParameterCorrections{1}, ...
    'integer from 4 through 256'));

controls.ReferencePeriods.Value = '405 invalid';
invokeValueChanged(controls.ReferencePeriods);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,analysisCount);
verifyEmpty(testCase,controls.ReferencePeriods.Value);
verifyNumElements(testCase,state.LastParameterCorrections,1);
verifyTrue(testCase,contains(state.LastParameterCorrections{1}, ...
    'Reference periods'));

controls.ReferencePeriods.Value = '1';
invokeValueChanged(controls.ReferencePeriods);
state = getappdata(gui,'BispectralState');
verifyEmpty(testCase,controls.ReferencePeriods.Value);
verifyTrue(testCase,contains(state.LastParameterCorrections{1}, ...
    'below the Nyquist frequency'));

correctionCount = state.ParameterCorrectionCount;
controls.ReferencePeriods.Value = '2.000000000001';
invokeValueChanged(controls.ReferencePeriods);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,controls.ReferencePeriods.Value,'2.000000000001');
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount);
verifyEmpty(testCase,state.LastOperationParameterCorrections);
controls.ReferencePeriods.Value = '2';
invokeValueChanged(controls.ReferencePeriods);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,controls.ReferencePeriods.Value,'2.000000000001');
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount+1);

controls.FrequencyPairs.Value = '0.30 0.25';
invokeValueChanged(controls.FrequencyPairs);
state = getappdata(gui,'BispectralState');
verifyEmpty(testCase,controls.FrequencyPairs.Value);
verifyTrue(testCase,contains(state.LastParameterCorrections{1}, ...
    'f1+f2 < Nyquist'));

correctionCount = state.ParameterCorrectionCount;
controls.FrequencyPairs.Value = '0.3 0.199999999999';
invokeValueChanged(controls.FrequencyPairs);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,controls.FrequencyPairs.Value,'0.3 0.199999999999');
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount);
controls.FrequencyPairs.Value = '0.3 0.2';
invokeValueChanged(controls.FrequencyPairs);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,controls.FrequencyPairs.Value,'0.3 0.199999999999');
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount+1);

correctionCount = state.ParameterCorrectionCount;
controls.FrequencyMin.Value = 0.1;
controls.FrequencyMax.Value = 0.1;
invokeValueChanged(controls.FrequencyMax);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,controls.FrequencyMin.Value,0);
verifyEqual(testCase,controls.FrequencyMax.Value,0.5,'AbsTol',32*eps);
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount+1);
verifyTrue(testCase,contains(state.LastParameterCorrections{1}, ...
    'strictly greater than minimum frequency'));

correctionCount = state.ParameterCorrectionCount;
controls.NumSegments.Value = 8;
controls.Overlap.Value = 0;
invokeValueChanged(controls.Overlap);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,analysisCount);
verifyEqual(testCase,controls.NumSegments.Value,controls.Defaults.NumSegments);
verifyEqual(testCase,controls.Overlap.Value,controls.Defaults.OverlapPercent);
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount+1);
verifyTrue(testCase,contains(state.LastParameterCorrections{1}, ...
    'WOSA segment geometry'));

controls.AnnotatePeaks.Value = ~controls.AnnotatePeaks.Value;
invokeValueChanged(controls.AnnotatePeaks);
state = getappdata(gui,'BispectralState');
verifyEmpty(testCase,state.LastOperationParameterCorrections);
end

function testGuiEveryFreeNumericControlUsesSafeFallback(testCase)
n = 128;
t = (0:n-1)';
y = sin(2*pi*t/37)+0.35*cos(2*pi*t/19);
context = struct('current_data',[t y], ...
    'data_name','all-numeric-fallbacks-test.txt','unit','kyr');
gui = bispectralGUI(context);
gui.Visible = 'off';
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');
controls.Significance.Value = 'none';

% Assign all eleven free numeric controls invalid values in one operation.
% Run-time validation must consolidate them, restore every safe fallback,
% and use only those corrected values in the completed result.
controls.NumSegments.Value = 2.5;
controls.Overlap.Value = -1;
controls.MaxBins.Value = 3.5;
controls.FrequencyMin.Value = -1;
controls.FrequencyMax.Value = 0;
controls.Confidence.Value = 100;
controls.NumSurrogates.Value = 19.5;
controls.RandomSeed.Value = -1;
controls.KeepBispectrum.Value = 101;
controls.KeepBicoherence.Value = 0;
controls.ColorGrid.Value = 3.5;
invokeButton(controls.PreviewButton);

state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,1);
verifyNumElements(testCase,state.LastResult.GUIParameterCorrections,11);
verifyNumElements(testCase,state.LastOperationParameterCorrections,11);
verifyEqual(testCase,state.ParameterCorrectionCount,11);
verifyEqual(testCase,state.ParameterAlertRequestCount,0, ...
    'A hidden GUI must not request a visible warning alert.');
expectedLabels = {'Number of segments','Overlap (%)', ...
    'Maximum computed freq. bins','Minimum frequency', ...
    'Maximum plotted frequency','FWER confidence (%)', ...
    'Number of surrogates','Random seed', ...
    'Retain |B| strongest (%)','Retain b^2 strongest (%)', ...
    'Colormap grid #'};
correctionText = string(state.LastResult.GUIParameterCorrections);
for labelIndex = 1:numel(expectedLabels)
    verifyTrue(testCase,any(contains(correctionText,expectedLabels{labelIndex})), ...
        sprintf('Missing correction audit for %s.',expectedLabels{labelIndex}));
end
verifyEqual(testCase,controls.NumSegments.Value,controls.Defaults.NumSegments);
verifyEqual(testCase,controls.Overlap.Value,controls.Defaults.OverlapPercent);
verifyEqual(testCase,controls.MaxBins.Value,controls.Defaults.MaxFrequencyBins);
verifyEqual(testCase,controls.FrequencyMin.Value,0);
verifyEqual(testCase,controls.FrequencyMax.Value,0.5,'AbsTol',32*eps);
verifyEqual(testCase,controls.Confidence.Value,95);
verifyEqual(testCase,controls.NumSurrogates.Value,199);
verifyEqual(testCase,controls.RandomSeed.Value,1);
verifyEqual(testCase,controls.KeepBispectrum.Value,50);
verifyEqual(testCase,controls.KeepBicoherence.Value,50);
verifyEqual(testCase,controls.ColorGrid.Value,32);
verifyEqual(testCase,state.LastResult.Options.PlotKeepStrongestBispectrumFraction,0.5);
verifyEqual(testCase,state.LastResult.Options.PlotKeepStrongestBicoherenceFraction,0.5);
end

function testGuiTextBudgetsRestoreLastValidValuesAndBoundAuditText(testCase)
n = 128;
t = (0:n-1)';
context = struct('current_data',[t sin(2*pi*t/31)], ...
    'data_name','text-budget-test.txt','unit','kyr');
gui = bispectralGUI(context);
gui.Visible = 'off';
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');

controls.ReferencePeriods.Value = repmat('1234567890',1,410);
invokeValueChanged(controls.ReferencePeriods);
state = getappdata(gui,'BispectralState');
verifyEmpty(testCase,controls.ReferencePeriods.Value);
verifyNumElements(testCase,state.LastParameterCorrections,1);
verifyTrue(testCase,contains(state.LastParameterCorrections{1}, ...
    'at most 4096 characters'));
verifyLessThan(testCase,strlength(state.LastParameterCorrections{1}),500, ...
    'An invalid paste must be abbreviated in logs and warning alerts.');

pairs = strjoin(repmat({'0.01 0.02'},1,65),';');
controls.FrequencyPairs.Value = pairs;
invokeValueChanged(controls.FrequencyPairs);
state = getappdata(gui,'BispectralState');
verifyEmpty(testCase,controls.FrequencyPairs.Value);
verifyNumElements(testCase,state.LastParameterCorrections,1);
verifyTrue(testCase,contains(state.LastParameterCorrections{1}, ...
    'at most 64 frequency pairs'));

% A legal 64-pair entry can grow when canonical formatting adds leading
% zeroes and spaces.  It must remain valid on its next callback/Run rather
% than being rejected by the GUI's own normalized representation.
groups = cell(1,64);
for pairIndex = 1:64
    groups{pairIndex} = sprintf('%.14f,%.14f', ...
        0.123456789+pairIndex*1e-14, ...
        0.234567890+pairIndex*1e-14);
end
controls.FrequencyPairs.Value = strjoin(groups,';');
correctionCount = state.ParameterCorrectionCount;
invokeValueChanged(controls.FrequencyPairs);
canonicalPairs = controls.FrequencyPairs.Value;
verifyGreaterThan(testCase,strlength(canonicalPairs),2048);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount);
invokeValueChanged(controls.FrequencyPairs);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,controls.FrequencyPairs.Value,canonicalPairs);
verifyEqual(testCase,state.ParameterCorrectionCount,correctionCount);
end

function testGuiAlertFailureCannotUndoCompletedAnalysis(testCase)
n = 128;
t = (0:n-1)';
hooks = struct('AlertFcn',@injectedAlertFailure);
context = struct('current_data',[t sin(2*pi*t/31)], ...
    'data_name','alert-failure-test.txt','unit','kyr', ...
    'BispectralTestHooks',hooks);
gui = bispectralGUI(context);
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');
controls.Significance.Value = 'none';
controls.ColorGrid.Value = -1;
invokeButton(controls.PreviewButton);

state = getappdata(gui,'BispectralState');
verifyTrue(testCase,state.HasResult);
verifyEqual(testCase,state.AnalysisCount,1);
verifyEqual(testCase,state.ParameterAlertRequestCount,1);
verifyEqual(testCase,state.ParameterAlertFailureCount,1);
verifyFalse(testCase,state.IsRunning);
verifyFalse(testCase,state.IsRendering);
verifyRunButtonsEnabled(testCase,controls);
end

function testGuiCandidatePlotFailureRollsBackWithoutOrphanFigure(testCase)
baseline = findall(groot,'Type','figure');
n = 128;
t = (0:n-1)';
hooks = struct('AfterCandidatePlotFcn',@injectedCandidatePlotFailure);
context = struct('current_data',[t sin(2*pi*t/31)], ...
    'data_name','candidate-failure-test.txt','unit','kyr', ...
    'BispectralTestHooks',hooks);
gui = bispectralGUI(context);
gui.Visible = 'off';
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');
controls.Significance.Value = 'none';
invokeButton(controls.PreviewButton);

state = getappdata(gui,'BispectralState');
verifyFalse(testCase,state.HasResult);
verifyEqual(testCase,state.AnalysisCount,0);
verifyEmpty(testCase,state.LastFigure);
verifyFalse(testCase,state.IsRunning);
verifyFalse(testCase,state.IsRendering);
verifyTrue(testCase,contains(controls.Status.Text,'Analysis failed'));
verifyRunButtonsEnabled(testCase,controls);
current = findall(groot,'Type','figure');
verifyEqual(testCase,numel(current),numel(baseline)+1, ...
    'The failed candidate plot left an untracked figure behind.');
end

function testGuiSaveFailureKeepsResultFigureAndPendingCorrection(testCase)
n = 128;
t = (0:n-1)';
t(65:end) = t(65:end)+0.25;
hooks = struct('SaveFcn',@injectedSaveFailure,'AlertFcn',@noopAlert);
context = struct('current_data',[t sin(2*pi*t/31)], ...
    'data_name','save-failure-test.txt','unit','kyr', ...
    'BispectralTestHooks',hooks);
gui = bispectralGUI(context);
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');
controls.Significance.Value = 'none';
controls.ColorGrid.Value = -1;
invokeButton(controls.SaveButton);

state = getappdata(gui,'BispectralState');
verifyTrue(testCase,state.HasResult);
verifyEqual(testCase,state.AnalysisCount,1);
verifyTrue(testCase,isgraphics(state.LastFigure,'figure'));
verifyNumElements(testCase,state.PendingParameterCorrections,1);
verifyEqual(testCase,state.PendingParameterCorrections, ...
    state.LastResult.GUIParameterCorrections);
verifyTrue(testCase,contains(controls.Status.Text,'Save failed'));
verifyTrue(testCase,contains(controls.Status.Text,'scientific warning'));
verifyTrue(testCase,state.LastResult.Preprocessing.WasInterpolated);
verifyEqual(testCase,state.ScientificAlertRequestCount,1, ...
    ['A save failure after a completed analysis must not suppress the ', ...
     'automatic-interpolation warning.']);
verifyEqual(testCase,state.ScientificAlertFailureCount,0);
verifyFalse(testCase,state.IsRunning);
verifyFalse(testCase,state.IsRendering);
verifyRunButtonsEnabled(testCase,controls);
end

function testGuiGuideValidationUsesDataNyquist(testCase)
t = (0:2:254)';
y = sin(2*pi*t/37)+0.2*cos(2*pi*t/19);
context = struct('current_data',[t y], ...
    'data_name','guide-nyquist-test.txt','unit','kyr');
gui = bispectralGUI(context);
gui.Visible = 'off';
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');

controls.ReferencePeriods.Value = '4';
invokeValueChanged(controls.ReferencePeriods);
verifyEmpty(testCase,controls.ReferencePeriods.Value);
controls.ReferencePeriods.Value = '4.1';
invokeValueChanged(controls.ReferencePeriods);
verifyEqual(testCase,controls.ReferencePeriods.Value,'4.1');

controls.FrequencyPairs.Value = '0.1 0.15';
invokeValueChanged(controls.FrequencyPairs);
verifyEmpty(testCase,controls.FrequencyPairs.Value);
controls.FrequencyPairs.Value = '0.1 0.149999999999';
invokeValueChanged(controls.FrequencyPairs);
verifyEqual(testCase,controls.FrequencyPairs.Value,'0.1 0.149999999999');
end

function testGuiValueChangedCorrectionIsRecordedByNextRun(testCase)
n = 128;
t = (0:n-1)';
y = sin(2*pi*t/31)+0.25*cos(2*pi*t/13);
context = struct('current_data',[t y], ...
    'data_name','pending-correction-test.txt','unit','kyr');
gui = bispectralGUI(context);
gui.Visible = 'off';
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');
controls.Significance.Value = 'none';
invokeValueChanged(controls.Significance);

controls.ColorGrid.Value = -1;
invokeValueChanged(controls.ColorGrid);
stateBeforeRun = getappdata(gui,'BispectralState');
verifyNumElements(testCase,stateBeforeRun.PendingParameterCorrections,1);
verifyTrue(testCase,contains( ...
    stateBeforeRun.PendingParameterCorrections{1},'Colormap grid #'));

invokeButton(controls.PreviewButton);
stateAfterRun = getappdata(gui,'BispectralState');
verifyEqual(testCase,stateAfterRun.AnalysisCount,1);
verifyNumElements(testCase,stateAfterRun.PendingParameterCorrections,1);
verifyEqual(testCase,stateAfterRun.PendingParameterCorrections, ...
    stateAfterRun.LastResult.GUIParameterCorrections);
verifyNumElements(testCase, ...
    stateAfterRun.LastResult.GUIParameterCorrections,1);
verifyTrue(testCase,contains( ...
    stateAfterRun.LastResult.GUIParameterCorrections{1},'Colormap grid #'));
verifyEqual(testCase,stateAfterRun.LastResult.Options.PlotColorGrid,32);
end

function testGuiAutoInterpolatesUnevenSamplingAndContinues(testCase)
n = 96;
t = (0:n-1)';
t(50:end) = t(50:end)+0.25;
hooks = struct('AlertFcn',@noopAlert);
context = struct('current_data',[t sin(2*pi*t/31)], ...
    'data_name','uneven-sampling-recovery-test.txt','unit','kyr', ...
    'BispectralTestHooks',hooks);
gui = bispectralGUI(context);
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');
controls.Significance.Value = 'none';
controls.ColorGrid.Value = -1;
invokeButton(controls.PreviewButton);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,controls.ColorGrid.Value,32);
verifyEqual(testCase,state.ParameterCorrectionCount,1);
verifyEqual(testCase,state.AnalysisCount,1);
verifyTrue(testCase,state.HasResult);
verifyEqual(testCase,state.LastResult.Options.InputPolicy,'strict');
verifyEqual(testCase,state.LastResult.Options.Interpolate,'auto');
preprocessing = state.LastResult.Preprocessing;
verifyTrue(testCase,preprocessing.WasIrregular);
verifyTrue(testCase,preprocessing.WasInterpolated);
verifyFalse(testCase,preprocessing.AcceptedNearUniformSpacing);
verifyLessThanOrEqual(testCase,max(abs(diff( ...
    state.LastResult.ProcessedData(:,1))-preprocessing.SampleInterval)), ...
    256*eps(max(abs(state.LastResult.ProcessedData(:,1)))));
warningText = string(preprocessing.Warnings);
verifyTrue(testCase,any(contains(warningText,'interpolated', ...
    'IgnoreCase',true)));
verifyTrue(testCase,any(contains(warningText,'10 ppm')));
verifyTrue(testCase,contains(controls.Status.Text,'scientific warning'));
verifyFalse(testCase,contains(controls.Status.Text,'Analysis failed'));
verifyEqual(testCase,state.ScientificAlertRequestCount,1);
verifyEqual(testCase,state.ScientificAlertFailureCount,0);
end

function testGuiWosaDefaultsUseAnticipatedRegularGridCount(testCase)
spacing = [0.1*ones(63,1);ones(64,1)];
t = [0;cumsum(spacing)];
y = sin(2*pi*t/13)+0.2*cos(2*pi*t/7);
context = struct('current_data',[t y], ...
    'data_name','mixed-spacing-wosa-default-test.txt','unit','kyr');
gui = bispectralGUI(context);
gui.Visible = 'off';
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');

verifyEqual(testCase,size(context.current_data,1),128);
verifyEqual(testCase,controls.AnticipatedSampleCount,71, ...
    ['The GUI sample-count preview must match the strict/auto ', ...
     'median-spacing interpolation grid.']);
verifyEqual(testCase,controls.Defaults.Estimator,'wosa');
verifyEqual(testCase,controls.Defaults.NumSegments,3);
verifyEqual(testCase,controls.NumSegments.Value,3);
controls.Significance.Value = 'none';
invokeButton(controls.PreviewButton);

state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,1);
verifyTrue(testCase,state.HasResult);
verifyTrue(testCase,state.LastResult.Preprocessing.WasInterpolated);
verifyEqual(testCase,state.LastResult.Preprocessing.FinalCount,71);
verifyEqual(testCase,size(state.LastResult.ProcessedData,1),71);
verifyEqual(testCase,state.LastResult.Options.NumSegments,3);
verifyEqual(testCase,state.LastResult.Meta.SegmentCount,3);
verifyGreaterThanOrEqual(testCase,state.LastResult.Meta.SegmentLength,32);
verifyFalse(testCase,contains(controls.Status.Text,'Analysis failed'));
end

function testOverviewLayoutAndCommonMapRendering(testCase)
n = 512;
t = (0:n-1)';
y = cos(2*pi*31*t/128+0.2)+0.7*cos(2*pi*19*t/128-0.4) ...
    +0.5*cos(2*pi*50*t/128-0.2);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
options.FrequencyMax = 0.18;
result = bispectralAnalyze([t y],options);

[fig,handles] = bispectralPlot(result,'Visible','on','Quantity','overview', ...
    'ShowPeriodAxes',true,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
verifyFalse(testCase,isfield(handles,'Series'));
verifyLessThan(testCase,handles.Bispectrum.Position(1), ...
    handles.Bicoherence.Position(1));
verifyEqual(testCase,handles.Bicoherence.Position(1),0.535,'AbsTol',32*eps);
verifyNumElements(testCase,handles.PowerAxes,2);
verifyEqual(testCase,handles.Power,handles.PowerLeft);
verifyEqual(testCase,handles.PowerLeft.Position(2),0.755,'AbsTol',32*eps);
verifyEqual(testCase,handles.PowerRight.Position(2),0.755,'AbsTol',32*eps);
verifyEqual(testCase,handles.PowerLeft.Position(2)-sum( ...
    handles.Bispectrum.Position([2 4])),0.08,'AbsTol',32*eps);
verifyEqual(testCase,handles.PowerRight.Position(2)-sum( ...
    handles.Bicoherence.Position([2 4])),0.08,'AbsTol',32*eps);
verifyEqual(testCase,handles.PowerLeft.XLim,handles.Bispectrum.XLim,'AbsTol',32*eps);
verifyEqual(testCase,handles.PowerRight.XLim,handles.Bicoherence.XLim,'AbsTol',32*eps);
verifyEqual(testCase,handles.PowerLeft.YScale,'log');
verifyEqual(testCase,handles.PowerRight.YScale,'log');
verifyEqual(testCase,handles.PowerLeft.YLim,handles.PowerRight.YLim,'AbsTol',32*eps);
verifyPowerAxisHasReadableTicks(testCase,handles.PowerLeft);
verifyPowerAxisHasReadableTicks(testCase,handles.PowerRight);
verifyEmpty(testCase,handles.PowerLeft.XLabel.String);
verifyEmpty(testCase,handles.PowerRight.XLabel.String);
verifyEqual(testCase,handles.PowerLeft.Title.String, ...
    'Complex bispectrum amplitude, |B|');
verifyEqual(testCase,handles.PowerRight.Title.String, ...
    'Magnitude-squared bicoherence, b^2');
for powerAxis = handles.PowerAxes
    verifyEqual(testCase,powerAxis.Title.Units,'normalized');
    verifyEqual(testCase,powerAxis.Title.Position(1:2),[0.5 1.06], ...
        'AbsTol',32*eps);
    verifyEqual(testCase,powerAxis.Title.VerticalAlignment,'bottom');
    verifyGreaterThanOrEqual(testCase,powerAxis.FontSize,11);
    verifyGreaterThanOrEqual(testCase,powerAxis.Title.FontSize,11);
end
verifyEmpty(testCase,handles.Bispectrum.Title.String);
verifyEmpty(testCase,handles.Bicoherence.Title.String);
verifyEqual(testCase,handles.PowerSpectrumMetadata.TimeBandwidth,2);
verifyEqual(testCase,handles.PowerSpectrumMetadata.TaperCount,3);
verifyEqual(testCase,handles.PowerSpectrumMetadata.NFFT,5*n);
verifyTrue(testCase,handles.PowerSpectrumMetadata.MeanRemoved);
meanRemoved = result.ProcessedData(:,2)-mean(result.ProcessedData(:,2));
[expectedPower,expectedAngularFrequency] = pmtm(meanRemoved,2,5*n);
expectedFrequency = expectedAngularFrequency/(2*pi*result.Meta.SampleInterval);
leftPowerLine = findobj(handles.PowerLeft,'Type','line');
verifyNumElements(testCase,leftPowerLine,1);
verifyEqual(testCase,leftPowerLine.XData(:),expectedFrequency(:),'AbsTol',32*eps);
verifyEqual(testCase,leftPowerLine.YData(:),expectedPower(:),'AbsTol', ...
    64*eps(max(expectedPower)));
visiblePower = expectedPower(expectedFrequency >= handles.PowerLeft.XLim(1) & ...
    expectedFrequency <= handles.PowerLeft.XLim(2) & ...
    isfinite(expectedPower) & expectedPower > 0);
verifyGreaterThan(testCase,numel(visiblePower),1);
visibleMinimum = min(visiblePower);
visibleMaximum = max(visiblePower);
expectedPowerYLim = [visibleMinimum,exp(log(visibleMinimum)+ ...
    (log(visibleMaximum)-log(visibleMinimum))/0.8)];
verifyEqual(testCase,handles.PowerLeft.YLim,expectedPowerYLim, ...
    'RelTol',2e-12);
verifyEqual(testCase,handles.PowerRight.YLim,expectedPowerYLim, ...
    'RelTol',2e-12);
normalizedPeakHeight = (log(visibleMaximum)-log(expectedPowerYLim(1))) / ...
    diff(log(expectedPowerYLim));
verifyEqual(testCase,normalizedPeakHeight,0.8,'AbsTol',64*eps);
verifyEqual(testCase,handles.BispectrumMap.Colorbar.Location,'southoutside');
verifyEqual(testCase,handles.BicoherenceMap.Colorbar.Location,'southoutside');
verifyLessThan(testCase,handles.BispectrumMap.Colorbar.Label.Position(1),0);
verifyLessThan(testCase,handles.BicoherenceMap.Colorbar.Label.Position(1),0);
verifyGreaterThanOrEqual(testCase,handles.BispectrumMap.Colorbar.FontSize,10);
verifyGreaterThanOrEqual(testCase,handles.BicoherenceMap.Colorbar.FontSize,10);
verifyGreaterThanOrEqual(testCase, ...
    handles.BispectrumMap.Colorbar.Label.FontSize,10);
verifyGreaterThanOrEqual(testCase, ...
    handles.BicoherenceMap.Colorbar.Label.FontSize,10);
verifyFalse(testCase,contains(fig.Name,'.txt','IgnoreCase',true));
renderSettings = getappdata(fig,'BispectralRenderSettings');
verifyTrue(testCase,renderSettings.PowerSpectrumDisplayed);
verifyEqual(testCase,renderSettings.PowerSpectrumNFFT,5*n);
verifyEqual(testCase,renderSettings.PowerSpectrumHeadroomFraction,0.20, ...
    'AbsTol',32*eps);
verifyEqual(testCase,renderSettings.PowerSpectrumYLimits,expectedPowerYLim, ...
    'RelTol',2e-12);
verifyHorizontalPlotBoxAlignment(testCase,handles.Bispectrum,handles.PowerLeft);
verifyHorizontalPlotBoxAlignment(testCase,handles.Bicoherence,handles.PowerRight);
leftMapBox = expectedActualPlotBox(handles.Bispectrum);
rightMapBox = expectedActualPlotBox(handles.Bicoherence);
verifyGreaterThan(testCase,rightMapBox(1)-sum(leftMapBox([1 3])),0);
periodTitles = findobj(handles.PeriodAxes,'Tag','bispectralPeriodAxisTitle');
verifyNumElements(testCase,periodTitles,2);
for titleIndex = 1:numel(periodTitles)
    verifyEqual(testCase,periodTitles(titleIndex).Position(1:2), ...
        [1.01 0.985],'AbsTol',32*eps);
    verifyEqual(testCase,periodTitles(titleIndex).HorizontalAlignment,'left');
    verifyEqual(testCase,periodTitles(titleIndex).VerticalAlignment,'top');
    verifyGreaterThanOrEqual(testCase,periodTitles(titleIndex).FontSize,9.5);
    titleExtent = normalizedTextExtentInFigure(periodTitles(titleIndex));
    if ancestor(periodTitles(titleIndex),'axes') == handles.PeriodAxes(1)
        powerBox = getpixelposition(handles.PowerLeft,true);
        mapBox = expectedActualPlotBox(handles.Bispectrum);
    else
        powerBox = getpixelposition(handles.PowerRight,true);
        mapBox = expectedActualPlotBox(handles.Bicoherence);
    end
    verifyGreaterThanOrEqual(testCase,titleExtent(1),sum(mapBox([1 3])));
    verifyLessThanOrEqual(testCase,titleExtent(2)+titleExtent(4), ...
        sum(mapBox([2 4]))+1.25);
    verifyLessThanOrEqual(testCase,titleExtent(2)+titleExtent(4),powerBox(2));
    verifyNormalizedTextWithinFigure(testCase,fig,periodTitles(titleIndex));
end
resizedPosition = fig.Position;
resizedPosition(3) = 0.78*resizedPosition(3);
fig.Position = resizedPosition;
settleFigureResize(fig,resizedPosition);
verifyHorizontalPlotBoxAlignment(testCase,handles.Bispectrum,handles.PowerLeft);
verifyHorizontalPlotBoxAlignment(testCase,handles.Bicoherence,handles.PowerRight);
leftMapBox = expectedActualPlotBox(handles.Bispectrum);
rightMapBox = expectedActualPlotBox(handles.Bicoherence);
verifyGreaterThan(testCase,rightMapBox(1)-sum(leftMapBox([1 3])),0);
for titleIndex = 1:numel(periodTitles)
    titleExtent = normalizedTextExtentInFigure(periodTitles(titleIndex));
    if ancestor(periodTitles(titleIndex),'axes') == handles.PeriodAxes(1)
        powerBox = getpixelposition(handles.PowerLeft,true);
        mapBox = expectedActualPlotBox(handles.Bispectrum);
    else
        powerBox = getpixelposition(handles.PowerRight,true);
        mapBox = expectedActualPlotBox(handles.Bicoherence);
    end
    verifyGreaterThanOrEqual(testCase,titleExtent(1),sum(mapBox([1 3])));
    verifyLessThanOrEqual(testCase,titleExtent(2)+titleExtent(4), ...
        sum(mapBox([2 4]))+1.25);
    verifyLessThanOrEqual(testCase,titleExtent(2)+titleExtent(4),powerBox(2));
    verifyNormalizedTextWithinFigure(testCase,fig,periodTitles(titleIndex));
end
verifyGreaterThanOrEqual(testCase,min([handles.PeriodAxes.FontSize]),9.5);
caption = findTextObjectContaining(fig,'High b^2 indicates phase coupling');
verifyNumElements(testCase,caption,1);
verifyGreaterThanOrEqual(testCase,caption.FontSize,10);
verifyFigureMinimumFontSize(testCase,fig,6);

bispectrumSurface = findobj(handles.Bispectrum,'Type','surface');
bicoherenceSurface = findobj(handles.Bicoherence,'Type','surface');
verifyNumElements(testCase,bispectrumSurface,1);
verifyNumElements(testCase,bicoherenceSurface,1);
verifyEqual(testCase,bispectrumSurface.FaceColor,'interp');
verifyEqual(testCase,bicoherenceSurface.FaceColor,'interp');
verifyEqual(testCase,bispectrumSurface.FaceAlpha,'interp');
verifyEqual(testCase,bicoherenceSurface.FaceAlpha,'interp');
verifyEqual(testCase,bispectrumSurface.XData,bicoherenceSurface.XData);
verifyEmpty(testCase,findall(handles.Bispectrum,'Type','line'));
verifyEmpty(testCase,findall(handles.Bicoherence,'Type','line'));
verifyNumElements(testCase,findall(handles.Bispectrum,'Type','contour'),1);
verifyNumElements(testCase,findall(handles.Bicoherence,'Type','contour'),1);
verifyTrue(testCase,isgraphics(handles.BispectrumMap.ValueContour));
verifyTrue(testCase,isgraphics(handles.BicoherenceMap.ValueContour));
verifyEmpty(testCase,handles.BispectrumMap.SignificanceContour);
verifyEmpty(testCase,handles.BicoherenceMap.SignificanceContour);
verifyGreaterThan(testCase,nnz(bispectrumSurface.AlphaData > 0),0);
verifyGreaterThan(testCase,nnz(bicoherenceSurface.AlphaData > 0),0);

visibleOriginal = visibleFrequencyMask(result, ...
    handles.Bispectrum.XLim(1),handles.Bispectrum.XLim(2));
expectedMagnitudeCutoff = strongestMagnitudeCutoff( ...
    result,options.PlotKeepStrongestBispectrumFraction,visibleOriginal);
expectedBicoherenceCutoff = strongestCutoff( ...
    result.BicoherenceSquared,options.PlotKeepStrongestBicoherenceFraction, ...
    visibleOriginal);
verifyEqual(testCase,handles.BispectrumMap.KeepCutoff, ...
    expectedMagnitudeCutoff,'AbsTol',32*eps(max(1,abs(expectedMagnitudeCutoff))));
verifyEqual(testCase,handles.BicoherenceMap.KeepCutoff, ...
    expectedBicoherenceCutoff,'AbsTol',32*eps(max(1,expectedBicoherenceCutoff)));

[singleFig,singleHandles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bispectrum-magnitude','ShowPeriodAxes',false,'PeakCount',0);
singleCleanup = onCleanup(@()closeFigure(singleFig));
verifyEqual(testCase,singleHandles.Surface.CData,bispectrumSurface.CData);
verifyEqual(testCase,singleHandles.Surface.AlphaData,bispectrumSurface.AlphaData);
verifyEqual(testCase,colormap(singleHandles.Map),colormap(handles.Bispectrum));
verifyEqual(testCase,singleHandles.ValueContour.XData, ...
    handles.BispectrumMap.ValueContour.XData);
end

function testSignificanceContourUsesDisplayProjection(testCase)
n = 512;
t = (0:n-1)';
y = cos(2*pi*31*t/128+0.2)+0.7*cos(2*pi*19*t/128-0.4) ...
    +0.5*cos(2*pi*50*t/128-0.2);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
result = bispectralAnalyze([t y],options);
significant = false(size(result.ValidMask));
significant(3:6,10:14) = result.ValidMask(3:6,10:14);
verifyGreaterThan(testCase,nnz(significant),0);
result.SignificantMask = significant;
result.Significance.Method = 'analytical';
result.Significance.ConfidenceLevel = 0.95;
result.Options.SignificanceMethod = 'analytical';

[fig,handles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','KeepStrongestFraction',1, ...
    'ShowPeriodAxes',false,'PeakCount',3,'ShowSignificance',true);
cleanup = onCleanup(@()closeFigure(fig));
verifyTrue(testCase,isgraphics(handles.ValueContour));
verifyTrue(testCase,isgraphics(handles.SignificanceContour));
verifyEqual(testCase,handles.SignificanceContour.LineWidth,2);
verifyEqual(testCase,handles.SignificanceContour.XData,handles.Surface.XData);
verifyEqual(testCase,handles.SignificanceContour.YData,handles.Surface.YData);
verifyGreaterThan(testCase,size(handles.SignificanceContour.XData,1), ...
    numel(result.Frequency));

[hiddenFig,hiddenHandles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','KeepStrongestFraction',1, ...
    'ShowPeriodAxes',false,'PeakCount',3,'ShowSignificance',false);
hiddenCleanup = onCleanup(@()closeFigure(hiddenFig));
verifyEmpty(testCase,hiddenHandles.SignificanceContour);
verifyEqual(testCase,hiddenHandles.Surface.CData,handles.Surface.CData);
visiblePeakMarkers = findall(handles.Map,'Type','line');
hiddenPeakMarkers = findall(hiddenHandles.Map,'Type','line');
verifyGreaterThan(testCase,numel(visiblePeakMarkers),0);
verifyNumElements(testCase,hiddenPeakMarkers,numel(visiblePeakMarkers));
verifyTrue(testCase,figureContainsText(hiddenFig, ...
    'Cached inference retained; significance contour is hidden.'));
end

function testPeriodAxesTrackMapGeometryAndLinkedFrequencyLimits(testCase)
n = 256;
t = (0:n-1)';
y = cos(2*pi*19*t/128)+0.7*cos(2*pi*31*t/128) ...
    +0.5*cos(2*pi*50*t/128);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
result = bispectralAnalyze([t y],options);

[fig,handles] = bispectralPlot(result,'Visible','on','Quantity','overview', ...
    'ShowPeriodAxes',true,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
verifyNumElements(testCase,handles.PeriodAxes,2);
verifyOverlayPlotBoxAlignment(testCase,handles.Bispectrum,handles.PeriodAxes(1));
verifyOverlayPlotBoxAlignment(testCase,handles.Bicoherence,handles.PeriodAxes(2));

resizedPosition = fig.Position;
resizedPosition(3) = 0.76*resizedPosition(3);
fig.Position = resizedPosition;
settleFigureResize(fig,resizedPosition);
verifyOverlayPlotBoxAlignment(testCase,handles.Bispectrum,handles.PeriodAxes(1));
verifyOverlayPlotBoxAlignment(testCase,handles.Bicoherence,handles.PeriodAxes(2));

visibleRange = [0.04 0.16];
xlim(handles.Bispectrum,visibleRange);
drawnow;
verifyEqual(testCase,handles.Bicoherence.XLim,visibleRange,'AbsTol',32*eps);
verifyEqual(testCase,handles.PowerLeft.XLim,visibleRange,'AbsTol',32*eps);
verifyEqual(testCase,handles.PowerRight.XLim,visibleRange,'AbsTol',32*eps);
verifyEqual(testCase,handles.PeriodAxes(1).XLim,visibleRange,'AbsTol',32*eps);
verifyEqual(testCase,handles.PeriodAxes(2).XLim,visibleRange,'AbsTol',32*eps);
end

function testReferencePeriodGuidesUseVisiblePrincipalDomain(testCase)
n = 512;
t = (0:n-1)';
y = cos(2*pi*31*t/128)+0.6*cos(2*pi*19*t/128) ...
    +0.4*cos(2*pi*50*t/128);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
result = bispectralAnalyze([t y],options);
periods = [10 20 1];

[fig,handles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','FrequencyMinimum',0.02, ...
    'FrequencyMaximum',0.16,'ReferencePeriods',periods, ...
    'ShowPeriodAxes',false,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
verifyNumElements(testCase,handles.ReferenceLines,2);
verifyNumElements(testCase,handles.ReferenceLabels,2);
for ii = 1:2
    lineHandle = handles.ReferenceLines(ii);
    verifyEqual(testCase,lineHandle.XData+lineHandle.YData, ...
        repmat(1/periods(ii),size(lineHandle.XData)),'AbsTol',64*eps);
    verifyGreaterThanOrEqual(testCase,lineHandle.XData,handles.Map.XLim(1));
    verifyLessThanOrEqual(testCase,lineHandle.XData,handles.Map.XLim(2));
    verifyGreaterThanOrEqual(testCase,lineHandle.YData,handles.Map.YLim(1));
    verifyLessThanOrEqual(testCase,lineHandle.YData,handles.Map.YLim(2));
    verifyLessThanOrEqual(testCase,lineHandle.YData,lineHandle.XData+64*eps);
    verifyEqual(testCase,lineHandle.LineStyle,'--');
    verifyEqual(testCase,lineHandle.LineWidth,0.7,'AbsTol',32*eps);
    verifyEqual(testCase,handles.ReferenceLabels(ii).Rotation,0);
    verifyEqual(testCase,handles.ReferenceLabels(ii).String, ...
        sprintf('%.4g',periods(ii)));
    verifyLessThan(testCase,handles.ReferenceLabels(ii).Position(1), ...
        lineHandle.XData(1));
    verifyGreaterThan(testCase,handles.ReferenceLabels(ii).Position(2), ...
        lineHandle.YData(1));
end

[overviewFig,overviewHandles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','overview','FrequencyMinimum',0.02, ...
    'FrequencyMaximum',0.16,'ReferencePeriods',10, ...
    'ShowPeriodAxes',false,'PeakCount',0);
overviewCleanup = onCleanup(@()closeFigure(overviewFig));
verifyNumElements(testCase,overviewHandles.ReferenceLines,2);
verifyEmpty(testCase,findall(overviewHandles.Power, ...
    'Tag','bispectralReferencePeriodLine'));
end

function testFrequencyPairGuidesAndReproducibleDefaults(testCase)
n = 512;
t = (0:n-1)';
y = sin(2*pi*t/37)+0.4*cos(2*pi*t/19);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
options.InputName = 'LR04_0-5.32Ma';
options.PlotFrequencyPairs = [0.05 0.08;0.18 0.06];
result = bispectralAnalyze([t y],options);

[fig,handles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','FrequencyMinimum',0.02, ...
    'FrequencyMaximum',0.16,'ShowPeriodAxes',true,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
drawnow nocallbacks
verifyNumElements(testCase,handles.FrequencyPairLines,2);
verifyNumElements(testCase,handles.FrequencyPairLabels,2);
vertical = findobj(handles.FrequencyPairLines, ...
    'Tag','bispectralFrequencyPairVertical');
horizontal = findobj(handles.FrequencyPairLines, ...
    'Tag','bispectralFrequencyPairHorizontal');
verifyNumElements(testCase,vertical,1);
verifyNumElements(testCase,horizontal,1);
verifyEqual(testCase,vertical.XData,[0.05 0.05],'AbsTol',32*eps);
verifyEqual(testCase,vertical.YData,handles.Map.YLim,'AbsTol',32*eps);
verifyEqual(testCase,horizontal.XData,handles.Map.XLim,'AbsTol',32*eps);
verifyEqual(testCase,horizontal.YData,[0.08 0.08],'AbsTol',32*eps);
verifyEqual(testCase,vertical.LineStyle,':');
verifyEqual(testCase,horizontal.LineStyle,':');
verifyEqual(testCase,vertical.LineWidth,0.2,'AbsTol',32*eps);
verifyEqual(testCase,horizontal.LineWidth,0.2,'AbsTol',32*eps);
verticalLabel = findobj(handles.FrequencyPairLabels, ...
    'Tag','bispectralFrequencyPairVerticalLabel');
horizontalLabel = findobj(handles.FrequencyPairLabels, ...
    'Tag','bispectralFrequencyPairHorizontalLabel');
verifyEqual(testCase,verticalLabel.String,'20');
verifyEqual(testCase,horizontalLabel.String,'12.5');
expectedVerticalPosition = (0.05-handles.Map.XLim(1))/diff(handles.Map.XLim);
expectedHorizontalPosition = (0.08-handles.Map.YLim(1))/diff(handles.Map.YLim);
verifyEqual(testCase,verticalLabel.Position(1),expectedVerticalPosition, ...
    'AbsTol',32*eps);
verifyEqual(testCase,verticalLabel.Position(2),1.0585,'AbsTol',32*eps);
verifyEqual(testCase,verticalLabel.HorizontalAlignment,'center');
verifyEqual(testCase,horizontalLabel.Position(1),1.025,'AbsTol',32*eps);
verifyEqual(testCase,horizontalLabel.Position(2),expectedHorizontalPosition, ...
    'AbsTol',32*eps);
verifyEqual(testCase,horizontalLabel.VerticalAlignment,'middle');
verifyGreaterThanOrEqual(testCase,verticalLabel.FontSize,9);
verifyGreaterThanOrEqual(testCase,horizontalLabel.FontSize,9);
periodTitle = findobj(handles.PeriodAxes,'Tag','bispectralPeriodAxisTitle');
verifyNumElements(testCase,periodTitle,1);
verifyEqual(testCase,periodTitle.Position(1:2),[1.01 0.985],'AbsTol',32*eps);
verifyEqual(testCase,periodTitle.HorizontalAlignment,'left');
verifyEqual(testCase,periodTitle.VerticalAlignment,'top');
verifyNormalizedTextWithinFigure(testCase,fig,verticalLabel);
verifyNormalizedTextWithinFigure(testCase,fig,horizontalLabel);
verifyNormalizedTextWithinFigure(testCase,fig,periodTitle);
verifyRectanglesDoNotOverlap(testCase, ...
    normalizedTextExtentInFigure(verticalLabel), ...
    normalizedTextExtentInFigure(periodTitle));
renderSettings = getappdata(fig,'BispectralRenderSettings');
verifyEqual(testCase,renderSettings.FrequencyPairs,options.PlotFrequencyPairs);
verifyTrue(testCase,contains(fig.Name,'LR04_0-5.32Ma'));

invalidOptions = options;
invalidOptions.PlotFrequencyPairs = [0.05 -0.08];
verifyError(testCase,@()bispectralAnalyze([t y],invalidOptions), ...
    'Acycle:Bispectral:InvalidPlotFrequencyPairs');
verifyError(testCase,@()bispectralPlot(result,'Visible','off', ...
    'FrequencyPairs',[0.05 0.08 0.1]), ...
    'Acycle:Bispectral:InvalidPlotFrequencyPairs');

edgeFrequency = 0.16;
[edgeFig,edgeHandles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','FrequencyMinimum',0.02, ...
    'FrequencyMaximum',edgeFrequency,'FrequencyPairs',[edgeFrequency 0.08], ...
    'ShowPeriodAxes',true,'PeakCount',0);
edgeCleanup = onCleanup(@()closeFigure(edgeFig));
drawnow nocallbacks
edgeLabel = findobj(edgeHandles.FrequencyPairLabels, ...
    'Tag','bispectralFrequencyPairVerticalLabel');
verifyNumElements(testCase,edgeLabel,1);
verifyEqual(testCase,edgeLabel.Position(1),1,'AbsTol',32*eps);
verifyEqual(testCase,edgeLabel.Position(2),1.0585,'AbsTol',32*eps);
verifyEqual(testCase,edgeLabel.HorizontalAlignment,'center');
edgePeriodTitle = findobj(edgeHandles.PeriodAxes, ...
    'Tag','bispectralPeriodAxisTitle');
verifyNumElements(testCase,edgePeriodTitle,1);
verifyRectanglesDoNotOverlap(testCase, ...
    normalizedTextExtentInFigure(edgeLabel), ...
    normalizedTextExtentInFigure(edgePeriodTitle));
verifyNormalizedTextWithinFigure(testCase,edgeFig,edgeLabel);
verifyNormalizedTextWithinFigure(testCase,edgeFig,edgePeriodTitle);
end

function testGuiRedrawsCachedResultWithoutReanalysis(testCase)
segmentLength = 64;
segmentCount = 8;
n = segmentLength*segmentCount;
t = (0:n-1)';
y = zeros(n,1);
rngBeforeFixture = rng;
rng(771,'twister');
for segment = 1:segmentCount
    index = (segment-1)*segmentLength+(1:segmentLength);
    phase1 = 2*pi*rand;
    phase2 = 2*pi*rand;
    y(index) = cos(2*pi*(9/segmentLength)*t(index)+phase1) ...
        +0.8*cos(2*pi*(5/segmentLength)*t(index)+phase2) ...
        +0.7*cos(2*pi*(14/segmentLength)*t(index)+phase1+phase2+0.3) ...
        +0.08*randn(segmentLength,1);
end
rng(rngBeforeFixture);
context = struct('current_data',[t y], ...
    'data_name','reactive-gui-test.txt','unit','kyr');
gui = bispectralGUI(context);
gui.Visible = 'off';
cleanup = onCleanup(@()closeGuiAndManagedResult(gui));
controls = getappdata(gui,'BispectralControls');
controls.Significance.Value = 'none';
invokeValueChanged(controls.Significance);
controls.NumSurrogates.Value = 19;
invokeValueChanged(controls.NumSurrogates);
controls.MaxBins.Value = 32;
invokeValueChanged(controls.MaxBins);
invokeButton(controls.PreviewButton);

state = getappdata(gui,'BispectralState');
verifyTrue(testCase,state.HasResult);
verifyEqual(testCase,state.AnalysisCount,1);
verifyEqual(testCase,state.DisplayInferenceMethod,'none');
verifyEqual(testCase,state.LastResult.Significance.Method,'none');
verifyEmpty(testCase,state.LastPlotHandles.BicoherenceMap.SignificanceContour);
verifyFalse(testCase,state.IsRendering);
noInferenceFigure = state.LastFigure;
controls.Significance.Value = 'surrogate-global';
invokeValueChanged(controls.Significance);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,1);
verifyEqual(testCase,state.DisplayInferenceMethod,'none');
verifyTrue(testCase,state.InferenceDirty);
verifyEqual(testCase,state.LastFigure,noInferenceFigure);
invokeButton(controls.PreviewButton);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,2);
verifyEqual(testCase,state.DisplayInferenceMethod,'surrogate-global');
verifyEqual(testCase,state.LastResult.Significance.Method,'surrogate-global');
verifyEqual(testCase,state.LastResult.Significance.SurrogateType,'iaaft');
verifyFalse(testCase,state.InferenceDirty);

firstCutoff = state.LastPlotHandles.BicoherenceMap.KeepCutoff;
controls.KeepBicoherence.Value = 35;
invokeValueChanged(controls.KeepBicoherence);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,2);
verifyNotEqual(testCase,state.LastPlotHandles.BicoherenceMap.KeepCutoff,firstCutoff);

controls.FrequencyMin.Value = 0.02;
invokeValueChanged(controls.FrequencyMin);
controls.FrequencyMax.Value = 0.18;
invokeValueChanged(controls.FrequencyMax);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.LastPlotHandles.Power.XLim,[0.02 0.18], ...
    'AbsTol',32*eps);
verifyEqual(testCase,state.LastPlotHandles.PowerRight.XLim,[0.02 0.18], ...
    'AbsTol',32*eps);
verifyEqual(testCase,state.LastPlotHandles.Bispectrum.XLim,[0.02 0.18], ...
    'AbsTol',32*eps);
verifyEqual(testCase,state.AnalysisCount,2);

controls.PlotQuantity.Value = 'bicoherence-squared';
invokeValueChanged(controls.PlotQuantity);
controls.ColorGrid.Value = 16;
invokeValueChanged(controls.ColorGrid);
controls.ReferencePeriods.Value = '10 20';
invokeValueChanged(controls.ReferencePeriods);
controls.FrequencyPairs.Value = '0.05 0.08; 0.07,0.09';
invokeValueChanged(controls.FrequencyPairs);
controls.AnnotatePeaks.Value = false;
invokeValueChanged(controls.AnnotatePeaks);
controls.PeriodAxes.Value = false;
invokeValueChanged(controls.PeriodAxes);
state = getappdata(gui,'BispectralState');
verifyEqual(testCase,state.AnalysisCount,2);
verifySize(testCase,colormap(state.LastPlotHandles.Map),[16 3]);
verifyNumElements(testCase,state.LastPlotHandles.ReferenceLines,2);
verifyNumElements(testCase,state.LastPlotHandles.FrequencyPairLines,4);
verifyEqual(testCase,controls.FrequencyPairs.Value,'0.05 0.08; 0.07 0.09');
renderSettings = getappdata(state.LastFigure,'BispectralRenderSettings');
verifyEqual(testCase,renderSettings.FrequencyPairs,[0.05 0.08;0.07 0.09]);
verifyEmpty(testCase,state.LastPlotHandles.PeriodAxes);

for redraw = 1:3
    previousFigure = state.LastFigure;
    controls.KeepBicoherence.Value = 20+5*redraw;
    invokeValueChanged(controls.KeepBicoherence);
    verifyFalse(testCase,isvalid(previousFigure));
    state = getappdata(gui,'BispectralState');
    previousFigure = state.LastFigure;
    controls.ReferencePeriods.Value = sprintf('%d %d',10+redraw,20+redraw);
    invokeValueChanged(controls.ReferencePeriods);
    verifyFalse(testCase,isvalid(previousFigure));
    state = getappdata(gui,'BispectralState');
    previousFigure = state.LastFigure;
    controls.FrequencyPairs.Value = sprintf('%.4g %.4g', ...
        0.04+0.005*redraw,0.07+0.005*redraw);
    invokeValueChanged(controls.FrequencyPairs);
    verifyFalse(testCase,isvalid(previousFigure));
    state = getappdata(gui,'BispectralState');
    verifyFalse(testCase,state.IsRendering);
    verifyEqual(testCase,state.AnalysisCount,2);
    verifyTrue(testCase,getappdata(state.LastFigure,'BispectralPlotComplete'));
    verifyFalse(testCase,contains(controls.Status.Text,'failed','IgnoreCase',true));
end
renderSettings = getappdata(state.LastFigure,'BispectralRenderSettings');
verifyEqual(testCase,renderSettings.BicoherenceKeepStrongestFraction,0.35);
verifyEqual(testCase,renderSettings.ReferencePeriods,[13 23]);
verifyEqual(testCase,renderSettings.FrequencyPairs,[0.055 0.085], ...
    'AbsTol',32*eps);

controls.Significance.Value = 'none';
invokeValueChanged(controls.Significance);
stateNone = getappdata(gui,'BispectralState');
verifyEqual(testCase,stateNone.AnalysisCount,2);
verifyEqual(testCase,stateNone.DisplayInferenceMethod,'none');
verifyEmpty(testCase,stateNone.LastPlotHandles.SignificanceContour);
controls.Significance.Value = 'surrogate-global';
invokeValueChanged(controls.Significance);
stateRestored = getappdata(gui,'BispectralState');
verifyEqual(testCase,stateRestored.AnalysisCount,2);
verifyEqual(testCase,stateRestored.DisplayInferenceMethod,'surrogate-global');
verifyFalse(testCase,stateRestored.InferenceDirty);

controls.Confidence.Value = 90;
invokeValueChanged(controls.Confidence);
controls.Significance.Value = 'none';
invokeValueChanged(controls.Significance);
controls.Significance.Value = 'surrogate-global';
invokeValueChanged(controls.Significance);
parameterPending = getappdata(gui,'BispectralState');
verifyEqual(testCase,parameterPending.DisplayInferenceMethod,'none');
verifyTrue(testCase,parameterPending.InferenceDirty);
pendingHiddenFigure = parameterPending.LastFigure;
controls.Confidence.Value = 95;
invokeValueChanged(controls.Confidence);
stateRestored = getappdata(gui,'BispectralState');
verifyEqual(testCase,stateRestored.AnalysisCount,2);
verifyEqual(testCase,stateRestored.DisplayInferenceMethod,'surrogate-global');
verifyFalse(testCase,stateRestored.InferenceDirty);
verifyFalse(testCase,isvalid(pendingHiddenFigure));
verifyTrue(testCase,isvalid(stateRestored.LastFigure));

restoredFigure = stateRestored.LastFigure;
controls.NumSurrogates.Value = 20;
invokeValueChanged(controls.NumSurrogates);
statePending = getappdata(gui,'BispectralState');
verifyEqual(testCase,statePending.AnalysisCount,2);
verifyEqual(testCase,statePending.DisplayInferenceMethod,'surrogate-global');
verifyTrue(testCase,statePending.InferenceDirty);
verifyEqual(testCase,statePending.LastFigure,restoredFigure);

controls.NumSegments.Value = controls.NumSegments.Value+1;
invokeValueChanged(controls.NumSegments);
stateDirty = getappdata(gui,'BispectralState');
verifyEqual(testCase,stateDirty.AnalysisCount,2);
verifyTrue(testCase,stateDirty.CalculationDirty);
verifyEqual(testCase,stateDirty.LastFigure,restoredFigure);
end

function testMagnitudeLeavesOutsideDomainUnpainted(testCase)
n = 512;
t = (0:n-1)';
y = sin(2*pi*t/37)+0.4*cos(2*pi*t/19);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
options.FrequencyMax = 0.10;
result = bispectralAnalyze([t y],options);

[fig,handles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bispectrum-magnitude','KeepStrongestFraction',1, ...
    'ShowPeriodAxes',false,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
surfaceHandle = findobj(handles.Map,'Type','surface');
verifyNumElements(testCase,surfaceHandle,1);
outsideDomain = surfaceHandle.YData > surfaceHandle.XData | ...
    surfaceHandle.XData+surfaceHandle.YData > ...
    result.Meta.PrincipalDomainMaximum+32*eps;
verifyTrue(testCase,all(isnan(surfaceHandle.CData(outsideDomain))));
verifyGreaterThan(testCase,nnz(isfinite(surfaceHandle.CData)),0);
end

function testAdaptiveMaskRetainsStrongestValues(testCase)
n = 512;
t = (0:n-1)';
y = cos(2*pi*31*t/128+0.2)+0.7*cos(2*pi*19*t/128-0.4) ...
    +0.5*cos(2*pi*50*t/128-0.2);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
result = bispectralAnalyze([t y],options);

[fig,handles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','KeepStrongestFraction',0.2, ...
    'ShowPeriodAxes',false,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
surfaceHandle = findobj(handles.Map,'Type','surface');
finiteValues = sort(result.BicoherenceSquared(isfinite(result.BicoherenceSquared)));
firstKept = floor(0.8*numel(finiteValues))+1;
cutoff = finiteValues(firstKept);
cdata = surfaceHandle.CData;
verifyGreaterThan(testCase,nnz(isfinite(cdata)),0);
alpha = surfaceHandle.AlphaData;
verifyEqual(testCase,surfaceHandle.FaceAlpha,'interp');
verifyEqual(testCase,surfaceHandle.AlphaDataMapping,'none');
weakFinite = isfinite(cdata) & cdata < cutoff;
verifyGreaterThan(testCase,nnz(weakFinite),0);
verifyTrue(testCase,all(alpha(weakFinite) == 0));
verifyGreaterThan(testCase,nnz(alpha > 0),0);
verifyGreaterThan(testCase,countVisibleFaces(cdata,alpha),0);
verifyEqual(testCase,handles.Map.CLim,[cutoff finiteValues(end)], ...
    'AbsTol',32*eps(max(1,finiteValues(end))));
maskedMap = colormap(handles.Map);
verifyEqual(testCase,maskedMap(1,:),[1 1 1],'AbsTol',32*eps);
verifyLessThan(testCase,maskedMap(end,1),0.8);
verifyLessThan(testCase,maskedMap(end,2),0.2);
verifyLessThan(testCase,maskedMap(end,3),0.2);

[fullFig,fullHandles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','KeepStrongestFraction',1, ...
    'ShowPeriodAxes',false,'PeakCount',0);
fullCleanup = onCleanup(@()closeFigure(fullFig));
fullSurface = findobj(fullHandles.Map,'Type','surface');
verifyGreaterThan(testCase,countDrawableFaces(fullSurface.CData),0);
verifyEqual(testCase,fullSurface.FaceAlpha,1);
verifyEqual(testCase,surfaceHandle.CData,fullSurface.CData);

visibleRange = [0.04 0.16];
[zoomFig,zoomHandles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','KeepStrongestFraction',0.2, ...
    'FrequencyMinimum',visibleRange(1),'FrequencyMaximum',visibleRange(2), ...
    'ShowPeriodAxes',false,'PeakCount',0);
zoomCleanup = onCleanup(@()closeFigure(zoomFig));
zoomSurface = zoomHandles.Surface;
visibleDisplay = zoomSurface.XData >= visibleRange(1) & ...
    zoomSurface.XData <= visibleRange(2) & ...
    zoomSurface.YData >= visibleRange(1) & ...
    zoomSurface.YData <= visibleRange(2) & isfinite(zoomSurface.CData);
visibleFraction = nnz(zoomSurface.AlphaData > 0 & visibleDisplay) / ...
    nnz(visibleDisplay);
verifyGreaterThan(testCase,visibleFraction,0.10);
verifyLessThan(testCase,visibleFraction,0.35);
verifyGreaterThan(testCase,nnz(zoomSurface.AlphaData > 0 & visibleDisplay),0);
visibleOriginal = visibleFrequencyMask(result,visibleRange(1),visibleRange(2));
expectedVisibleCutoff = strongestCutoff( ...
    result.BicoherenceSquared,0.2,visibleOriginal);
verifyEqual(testCase,zoomHandles.Map.CLim(1),expectedVisibleCutoff, ...
    'AbsTol',32*eps(max(1,expectedVisibleCutoff)));
end

function testBiphaseValueContoursRespectStrongestMask(testCase)
n = 512;
t = (0:n-1)';
y = cos(2*pi*31*t/128+0.2)+0.7*cos(2*pi*19*t/128-0.4) ...
    +0.5*cos(2*pi*50*t/128-0.2);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
result = bispectralAnalyze([t y],options);

[fig,handles] = bispectralPlot(result,'Visible','off','Quantity','biphase', ...
    'KeepStrongestFraction',0.2,'ShowPeriodAxes',false,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
verifyTrue(testCase,isgraphics(handles.ValueContour));
alphaAtContours = contourAlphaValues(handles.ValueContour,handles.Surface);
alphaAtContours = alphaAtContours(isfinite(alphaAtContours));
verifyNotEmpty(testCase,alphaAtContours);
verifyGreaterThan(testCase,min(alphaAtContours),0);
end

function testDisplayMeshNeverCoarsensComputedFrequencyGrid(testCase)
result = syntheticBicoherenceResult(805);
[fig,handles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','KeepStrongestFraction',1, ...
    'ShowPeriodAxes',false,'PeakCount',0);
cleanup = onCleanup(@()closeFigure(fig));
verifyGreaterThanOrEqual(testCase,size(handles.Surface.XData,1), ...
    numel(result.Frequency));
verifyGreaterThanOrEqual(testCase,size(handles.Surface.YData,2), ...
    numel(result.Frequency));
end

function testPlotErrorsNeverLeakFiguresAndBIsNotAnActiveQuantity(testCase)
n = 256;
t = (0:n-1)';
y = sin(2*pi*t/37)+0.4*cos(2*pi*t/19);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
result = bispectralAnalyze([t y],options);
baseline = findall(groot,'Type','figure');
cleanup = onCleanup(@()closeFiguresCreatedAfter(baseline));

verifyError(testCase,@()bispectralPlot(result,'Visible','off', ...
    'FrequencyMinimum',0.3,'FrequencyMaximum',0.1), ...
    'Acycle:Bispectral:InvalidPlotFrequencyRange');
verifyNumElements(testCase,findall(groot,'Type','figure'),numel(baseline));

brokenResult = rmfield(result,'ProcessedData');
didThrow = false;
try
    bispectralPlot(brokenResult,'Visible','off','Quantity','overview');
catch
    didThrow = true;
end
verifyTrue(testCase,didThrow);
verifyNumElements(testCase,findall(groot,'Type','figure'),numel(baseline));

verifyError(testCase,@()bispectralPlot(result,'Visible','off','Quantity','b'), ...
    'Acycle:Bispectral:InvalidPlotQuantity');
verifyNumElements(testCase,findall(groot,'Type','figure'),numel(baseline));
end

function testPeakAnnotationsChooseStrongestVisibleTriad(testCase)
n = 512;
t = (0:n-1)';
y = sin(2*pi*t/37)+0.4*cos(2*pi*t/19);
options = bispectralDefaults([t y]);
options.SignificanceMethod = 'none';
result = bispectralAnalyze([t y],options);
[f1Grid,f2Grid] = meshgrid(result.Frequency,result.Frequency);
visibleMaximum = 0.12;
inside = result.ValidMask & f1Grid <= visibleMaximum & f2Grid <= visibleMaximum;
outside = result.ValidMask & (f1Grid > visibleMaximum | f2Grid > visibleMaximum);
insideIndex = find(inside,1,'last');
outsideIndex = find(outside,1,'last');
verifyNotEmpty(testCase,insideIndex);
verifyNotEmpty(testCase,outsideIndex);
values = nan(size(result.BicoherenceSquared));
values(result.ValidMask) = 0.1;
values(insideIndex) = 0.9;
values(outsideIndex) = 1;
result.BicoherenceSquared = values;

[fig,handles] = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','KeepStrongestFraction',1, ...
    'FrequencyMaximum',visibleMaximum,'ShowPeriodAxes',false,'PeakCount',1);
cleanup = onCleanup(@()closeFigure(fig));
markers = findall(handles.Map,'Type','line','Marker','o');
verifyNumElements(testCase,markers,1);
verifyGreaterThanOrEqual(testCase,markers.XData,handles.Map.XLim(1));
verifyLessThanOrEqual(testCase,markers.XData,handles.Map.XLim(2));
verifyGreaterThanOrEqual(testCase,markers.YData,handles.Map.YLim(1));
verifyLessThanOrEqual(testCase,markers.YData,handles.Map.YLim(2));
verifyEqual(testCase,[markers.XData markers.YData], ...
    [f1Grid(insideIndex) f2Grid(insideIndex)],'AbsTol',32*eps);
end

function count = countDrawableFaces(cdata)
finite = isfinite(cdata);
drawable = finite(1:end-1,1:end-1) & finite(2:end,1:end-1) & ...
    finite(1:end-1,2:end) & finite(2:end,2:end);
count = nnz(drawable);
end

function count = countVisibleFaces(cdata,alpha)
finite = isfinite(cdata);
drawable = finite(1:end-1,1:end-1) & finite(2:end,1:end-1) & ...
    finite(1:end-1,2:end) & finite(2:end,2:end);
visible = alpha(1:end-1,1:end-1) > 0 | alpha(2:end,1:end-1) > 0 | ...
    alpha(1:end-1,2:end) > 0 | alpha(2:end,2:end) > 0;
count = nnz(drawable & visible);
end

function cutoff = strongestMagnitudeCutoff(result,fraction,mask)
raw = result.BispectrumMagnitude;
if nargin < 3
    mask = true(size(raw));
end
finitePositive = raw(isfinite(raw) & raw > 0);
if isempty(finitePositive)
    floorValue = realmin;
else
    floorValue = max(realmin,min(finitePositive)*0.1);
end
values = nan(size(raw));
valid = isfinite(raw);
values(valid) = log10(max(raw(valid),floorValue));
cutoff = strongestCutoff(values,fraction,mask);
end

function cutoff = strongestCutoff(values,fraction,mask)
if nargin < 3
    mask = true(size(values));
end
finiteValues = sort(values(isfinite(values) & mask));
if isempty(finiteValues)
    cutoff = -Inf;
    return
end
index = max(1,min(numel(finiteValues), ...
    floor((1-fraction)*numel(finiteValues))+1));
cutoff = finiteValues(index);
end

function visible = visibleFrequencyMask(result,minimum,maximum)
[f1Grid,f2Grid] = meshgrid(result.Frequency,result.Frequency);
visible = f1Grid >= minimum & f1Grid <= maximum & ...
    f2Grid >= minimum & f2Grid <= maximum;
end

function yes = figureContainsText(fig,expected)
yes = false;
objects = findall(fig,'-property','String');
for ii = 1:numel(objects)
    value = objects(ii).String;
    if iscell(value)
        value = strjoin(string(value),' ');
    end
    if any(contains(string(value),string(expected)),'all')
        yes = true;
        return
    end
end
end

function verifyPowerAxisHasReadableTicks(testCase,ax)
ticks = ax.YTick(:);
labels = ax.YTickLabel;
if ischar(labels)
    labels = string(cellstr(labels));
else
    labels = string(labels(:));
end
labels = strtrim(labels(:));
verifyGreaterThanOrEqual(testCase,numel(ticks),3, ...
    'Each overview power spectrum needs at least three labeled y ticks.');
verifyEqual(testCase,numel(labels),numel(ticks), ...
    'Every power-spectrum y tick must have a visible numeric label.');
verifyTrue(testCase,all(strlength(labels) > 0), ...
    'Power-spectrum y tick labels must not be suppressed.');
end

function matches = findTextObjectContaining(fig,expected)
matches = gobjects(0,1);
objects = findall(fig,'-property','String');
for ii = 1:numel(objects)
    value = objects(ii).String;
    if iscell(value)
        value = strjoin(string(value),' ');
    end
    if any(contains(string(value),string(expected)),'all')
        matches(end+1,1) = objects(ii); %#ok<AGROW>
    end
end
end

function verifyFigureMinimumFontSize(testCase,fig,minimumPoints)
objects = findall(fig,'-property','FontSize');
verifyNotEmpty(testCase,objects);
for ii = 1:numel(objects)
    pointSize = fontSizeInPoints(objects(ii));
    verifyTrue(testCase,isfinite(pointSize) && pointSize >= minimumPoints, ...
        sprintf('%s uses %.4g pt; every figure label must be at least %.4g pt.', ...
        class(objects(ii)),pointSize,minimumPoints));
end
end

function pointSize = fontSizeInPoints(object)
pointSize = double(object.FontSize);
if ~isprop(object,'FontUnits') || strcmpi(object.FontUnits,'points')
    return
end
originalUnits = object.FontUnits;
object.FontUnits = 'points';
restoreUnits = onCleanup(@()set(object,'FontUnits',originalUnits));
pointSize = double(object.FontSize);
end

function verifyGuiLabelColors(testCase,fig,names,expectedColor)
for ii = 1:numel(names)
    label = findall(fig,'Type','uilabel','Text',names{ii});
    verifyNumElements(testCase,label,1,sprintf('GUI label: %s',names{ii}));
    verifyEqual(testCase,label.FontColor,expectedColor,'AbsTol',32*eps);
end
end

function verifyHorizontalPlotBoxAlignment(testCase,mapAxis,powerAxis)
mapBox = expectedActualPlotBox(mapAxis);
powerBox = getpixelposition(powerAxis,true);
% Independent axes can round opposite plot-box edges to adjacent device
% pixels after a macOS resize. Match the period-overlay regression's bound:
% 1.25 pixels is visually coincident while still catching real layout drift.
verifyEqual(testCase,powerBox([1 3]),mapBox([1 3]),'AbsTol',1.25);
end

function verifyOverlayPlotBoxAlignment(testCase,mapAxis,overlayAxis)
mapBox = expectedActualPlotBox(mapAxis);
overlayBox = expectedActualPlotBox(overlayAxis);
% Independent axes can round their manual 1:1 plot boxes to adjacent device
% pixels after a macOS window resize; a 1.25-pixel bound is visually exact.
verifyEqual(testCase,overlayBox,mapBox,'AbsTol',1.25);
end

function position = expectedActualPlotBox(ax)
position = getpixelposition(ax,true);
ratio = ax.PlotBoxAspectRatio(1)/ax.PlotBoxAspectRatio(2);
outerRatio = position(3)/position(4);
if outerRatio > ratio
    newWidth = position(4)*ratio;
    position(1) = position(1)+(position(3)-newWidth)/2;
    position(3) = newWidth;
else
    newHeight = position(3)/ratio;
    position(2) = position(2)+(position(4)-newHeight)/2;
    position(4) = newHeight;
end
end

function verifyNormalizedTextWithinFigure(testCase,fig,textHandle)
extent = normalizedTextExtentInFigure(textHandle);
figurePixels = getpixelposition(fig);
verifyGreaterThanOrEqual(testCase,extent(1),1);
verifyGreaterThanOrEqual(testCase,extent(2),1);
verifyLessThanOrEqual(testCase,extent(1)+extent(3),figurePixels(3)+1);
verifyLessThanOrEqual(testCase,extent(2)+extent(4),figurePixels(4)+1);
end

function extent = normalizedTextExtentInFigure(textHandle)
assert(strcmp(textHandle.Units,'normalized'));
axisHandle = ancestor(textHandle,'axes');
plotBox = expectedActualPlotBox(axisHandle);
normalizedExtent = textHandle.Extent;
extent = [plotBox(1)+normalizedExtent(1)*plotBox(3), ...
    plotBox(2)+normalizedExtent(2)*plotBox(4), ...
    normalizedExtent(3)*plotBox(3),normalizedExtent(4)*plotBox(4)];
end

function verifyRectanglesDoNotOverlap(testCase,first,second)
overlapWidth = min(first(1)+first(3),second(1)+second(3)) ...
    -max(first(1),second(1));
overlapHeight = min(first(2)+first(4),second(2)+second(4)) ...
    -max(first(2),second(2));
verifyFalse(testCase,overlapWidth > 0 && overlapHeight > 0);
end

function values = contourAlphaValues(contourHandle,surfaceHandle)
matrix = contourHandle.ContourMatrix;
values = nan(1,size(matrix,2));
writeIndex = 0;
column = 1;
while column <= size(matrix,2)
    pointCount = matrix(2,column);
    pointColumns = column+(1:pointCount);
    x = matrix(1,pointColumns);
    y = matrix(2,pointColumns);
    segmentValues = interp2(surfaceHandle.XData,surfaceHandle.YData, ...
        surfaceHandle.AlphaData,x,y,'linear');
    values(writeIndex+(1:pointCount)) = segmentValues;
    writeIndex = writeIndex+pointCount;
    column = column+pointCount+1;
end
values = values(1:writeIndex);
end

function result = syntheticBicoherenceResult(frequencyCount)
frequency = linspace(0.001,0.499,frequencyCount)';
[f1Grid,f2Grid] = meshgrid(frequency,frequency);
valid = f2Grid <= f1Grid & f1Grid+f2Grid <= 0.5;
bicoherenceSquared = nan(frequencyCount);
bicoherenceSquared(valid) = 0.25+0.2*sin(11*f1Grid(valid)).^2;
options = bispectralDefaults([]);
options.PlotQuantity = 'bicoherence-squared';
options.PlotKeepStrongestBispectrumFraction = 1;
options.PlotKeepStrongestBicoherenceFraction = 1;
options.ShowPeriodAxes = false;
options.PlotPeakCount = 0;
result = struct( ...
    'Frequency',frequency, ...
    'Power',1+frequency, ...
    'BicoherenceSquared',bicoherenceSquared, ...
    'ValidMask',valid, ...
    'SignificantMask',false(frequencyCount), ...
    'Options',options, ...
    'InputName','synthetic-dense-grid.txt', ...
    'CoordinateUnit','kyr', ...
    'Meta',struct('Estimator','wosa','SegmentCount',8, ...
        'SegmentLength',256,'ActualMedianOverlapPercent',50, ...
        'Window','hann','SampleInterval',1,'RayleighResolution',1/256), ...
    'Significance',struct('Method','none','ConfidenceLevel',0.95));
end

function closeFiguresCreatedAfter(baseline)
current = findall(groot,'Type','figure');
for ii = 1:numel(current)
    if isempty(baseline) || ~any(current(ii) == baseline)
        delete(current(ii));
    end
end
end

function invokeValueChanged(control)
callback = control.ValueChangedFcn;
callback(control,[]);
end

function settleFigureResize(fig,requestedPosition)
% R2025b applies a visible macOS figure resize asynchronously.  In
% particular, a southoutside colorbar can update its map axes one render
% frame after the first SizeChanged callback.  Wait for the requested
% drawable size and two subsequent render passes so the production
% SizeChangedFcn, map, power axes, and period overlay have all converged.
maximumPasses = 12;
for pass = 1:maximumPasses
    drawnow;
    actualPosition = fig.Position;
    sizeSettled = all(abs(actualPosition(3:4)-requestedPosition(3:4)) <= 1);
    if sizeSettled
        drawnow;
        drawnow;
        return
    end
    pause(0.01);
end
error('Acycle:BispectralTest:FigureResizeTimeout', ...
    'The visible figure did not reach its requested size after %d render passes.', ...
    maximumPasses);
end

function invokeButton(control)
callback = control.ButtonPushedFcn;
callback(control,[]);
end

function verifyRunButtonsEnabled(testCase,controls)
verifyEqual(testCase,string(controls.PreviewButton.Enable),"on");
verifyEqual(testCase,string(controls.SaveButton.Enable),"on");
verifyEqual(testCase,string(controls.CloseButton.Enable),"on");
end

function noopAlert(varargin)
end

function injectedAlertFailure(varargin)
error('Acycle:BispectralTest:InjectedAlertFailure', ...
    'Injected parameter-alert failure.');
end

function injectedCandidatePlotFailure(candidateFigure)
if ~isgraphics(candidateFigure,'figure')
    error('Acycle:BispectralTest:InvalidCandidateFixture', ...
        'The injected candidate failure did not receive a completed figure.');
end
error('Acycle:BispectralTest:InjectedCandidateFailure', ...
    'Injected post-render candidate failure.');
end

function files = injectedSaveFailure(varargin)
files = struct(); %#ok<NASGU> % Match the save hook signature; this stub always throws.
error('Acycle:BispectralTest:InjectedSaveFailure', ...
    'Injected GUI save failure.');
end

function closeGuiAndManagedResult(gui)
if isempty(gui) || ~isvalid(gui)
    return
end
state = getappdata(gui,'BispectralState');
if isstruct(state) && isfield(state,'LastFigure') && ...
        ~isempty(state.LastFigure) && isvalid(state.LastFigure)
    delete(state.LastFigure);
end
delete(gui);
end

function closeFigure(fig)
if ~isempty(fig) && isvalid(fig)
    delete(fig);
end
end
