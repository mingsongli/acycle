function tests = test_spectrum_sampling
%TEST_SPECTRUM_SAMPLING Regression tests for Spectral Analysis grid checks.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
seriesDirectory = fileparts(fileparts(mfilename('fullpath')));
codeDirectory = fileparts(seriesDirectory);
oldPath = path;
addpath(seriesDirectory);
addpath(fullfile(codeDirectory,'guicode'));
addpath(fullfile(codeDirectory,'misc'));
addpath(fullfile(codeDirectory,'package','swa'));
testCase.addTeardown(@()path(oldPath));
end

function testNineDigitSerializationJitterIsRegular(testCase)
coordinate = quantizedRegularCoordinate();
[isUneven,info] = acycleSamplingIsUneven(coordinate);

verifyFalse(testCase,isUneven);
verifyEqual(testCase,info.MedianSpacing,3.9,'RelTol',1e-13);
verifyEqual(testCase,info.MaximumSpacingError,4.0000000467443897e-6, ...
    'RelTol',1e-8);
verifyLessThan(testCase,info.RelativeSpacingError,info.RelativeTolerance);
end

function testMaterialSpacingJitterIsUneven(testCase)
dt = 3.9;
coordinate = (0:127)'.*dt;
coordinate(64) = coordinate(64)+1e-3*dt;

[isUneven,info] = acycleSamplingIsUneven(coordinate);

verifyTrue(testCase,isUneven);
verifyGreaterThan(testCase,info.MaximumSpacingError,info.AbsoluteTolerance);
end

function testTenPpmBoundarySeparatesNearUniformAndUneven(testCase)
dt = 3.9;
within = (0:127)'.*dt;
within(64) = within(64)+9e-6*dt;
outside = (0:127)'.*dt;
outside(64) = outside(64)+11e-6*dt;

verifyFalse(testCase,acycleSamplingIsUneven(within));
verifyTrue(testCase,acycleSamplingIsUneven(outside));
end

function testTenPpmLimitSurvivesScaleAndOffset(testCase)
largeOffset = 1e12+(0:127)';
largeOffset(64) = largeOffset(64)+1e-3;
verifyTrue(testCase,acycleSamplingIsUneven(largeOffset));

smallDt = 1e-10;
smallSpacing = (0:127)'.*smallDt;
smallSpacing(64) = smallSpacing(64)+11e-6*smallDt;
verifyTrue(testCase,acycleSamplingIsUneven(smallSpacing));
end

function testInvalidAndMissingIntervalsAreUneven(testCase)
verifyTrue(testCase,acycleSamplingIsUneven(NaN));
verifyTrue(testCase,acycleSamplingIsUneven([0;1;1;2]));
verifyTrue(testCase,acycleSamplingIsUneven([0;1;3;4]));
verifyTrue(testCase,acycleSamplingIsUneven([0;1;NaN;3]));
end

function testDataPreprocessingPreservesSerializedRegularGrid(testCase)
coordinate = quantizedRegularCoordinate();
data = [coordinate,sin(2*pi*coordinate/97)];

processed = datapreproc(data,0);

verifyEqual(testCase,processed,data,'AbsTol',0);
end

function testAuditedEntryPointsUseSharedClassifier(testCase)
seriesDirectory = fileparts(fileparts(mfilename('fullpath')));
codeDirectory = fileparts(seriesDirectory);
entryPoints = { ...
    fullfile(codeDirectory,'guicode','ft.m'), ...
    fullfile(codeDirectory,'guicode','DynamicFilter.m'), ...
    fullfile(codeDirectory,'guicode','waveletGUI.m'), ...
    fullfile(codeDirectory,'guicode','RecPlotGUI.m'), ...
    fullfile(codeDirectory,'guicode','evofftGUI.m'), ...
    fullfile(codeDirectory,'guicode','SpectralMomentsGUI.m'), ...
    fullfile(codeDirectory,'guicode','prewhitenGUI.m'), ...
    fullfile(codeDirectory,'guicode','RobotGUI.m'), ...
    fullfile(codeDirectory,'guicode','spectrum.m'), ...
    fullfile(codeDirectory,'guicode','AC.m'), ...
    fullfile(codeDirectory,'misc','datapreproc.m'), ...
    fullfile(codeDirectory,'package','wavelet','wavecoh_readGUI.m')};

for fileIndex = 1:numel(entryPoints)
    source = fileread(entryPoints{fileIndex});
    verifyNotEmpty(testCase,strfind(source,'acycleSamplingIsUneven('), ...
        sprintf('%s must use the shared sampling classifier.', ...
        entryPoints{fileIndex}));
end
end

function testSpectrumGuiKeepsMtmForSerializedRegularGrid(testCase)
coordinate = quantizedRegularCoordinate();
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/97)], ...
    'data_name','serialized-regular-grid.txt', ...
    'unit','m');
figureHandle = spectrum(context);
testCase.addTeardown(@()closeFigure(figureHandle));
drawnow;

method = findall(figureHandle,'Tag','spectrumMethodDropdown');
verifyNumElements(testCase,method,1);
verifyEqual(testCase,string(method.Value),"Multi-taper method");
end

function testSpectrumGuiDefaultsToLombForMaterialJitter(testCase)
dt = 3.9;
coordinate = (0:127)'.*dt;
coordinate(64) = coordinate(64)+1e-3*dt;
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/97)], ...
    'data_name','uneven-grid.txt', ...
    'unit','m');
figureHandle = spectrum(context);
testCase.addTeardown(@()closeFigure(figureHandle));
drawnow;

method = findall(figureHandle,'Tag','spectrumMethodDropdown');
verifyNumElements(testCase,method,1);
verifyEqual(testCase,string(method.Value),"Lomb-Scargle spectrum");

swa = findall(figureHandle,'Tag','spectrumSwaCheckbox');
verifyNumElements(testCase,swa,1);
verifyFalse(testCase,swa.Value, ...
    'Uneven data must retain v2.8 SWA-off state when MTM is reselected.');
lastwarn('');
selectSpectrumMethod(figureHandle,'Multi-taper method');
[warningMessage,warningId] = lastwarn;
verifyEqual(testCase,warningId,'spectrum:unevenData');
verifyNotEmpty(testCase,warningMessage);
verifyFalse(testCase,swa.Value);
end

function testSpectrumRestoresLocalizedGuiTextWithSafeFallback(testCase)
coordinate = (0:31)';
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/9)], ...
    'data_name','localized-spectrum.txt','unit','m', ...
    'lang_choice',1, ...
    'lang_id',{{'menu107','spectral01','spectral11'}}, ...
    'lang_var',{{'Localized Spectrum', ...
    'Localized method','Localized white noise'}}, ...
    'main_unit_selection',1);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
gui.Visible = 'off';

verifyEqual(testCase,string(gui.Name),"Acycle: Localized Spectrum");
methodLabel = findall(gui,'Type','uilabel', ...
    'Text','Localized method');
verifyNumElements(testCase,methodLabel,1);
panel = findall(gui,'Type','uipanel','Title','Method');
verifyNumElements(testCase,panel,1, ...
    'A missing dictionary key must retain its English fallback.');

selectSpectrumMethod(gui,'Lomb-Scargle spectrum');
classic = findall(gui,'Tag','spectrumClassicCheckbox');
verifyNumElements(testCase,classic,1);
verifyEqual(testCase,string(classic.Text),"Localized white noise");
end

function testSpectrumRestoresV28BiasCorrectionRecommendation(testCase)
closeTaggedSpectrumResults();
n = 128;
coordinate = (0:n-1)';

lowFrequency = sin(2*pi*coordinate/31);
[expectedRecommended,expectedFitMaximum] = ...
    expectedBiasRecommendation(coordinate,lowFrequency);
verifyTrue(testCase,expectedRecommended, ...
    'The regression signal must exercise the v2.8 recommendation.');
context = struct('current_data',[coordinate,lowFrequency], ...
    'data_name','bias-recommended.txt','unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
gui.Visible = 'off';
verifyTrue(testCase,getappdata(gui, ...
    'SpectrumBiasCorrectionRecommended'));
verifyEqual(testCase,getappdata(gui, ...
    'SpectrumBiasCorrectionFitMaximum'),expectedFitMaximum, ...
    'RelTol',1e-13,'AbsTol',1e-13);
inputMode = findall(gui,'Tag','spectrumFmaxInputRadio');
inputField = findall(gui,'Tag','spectrumFmaxInputField');
verifyTrue(testCase,inputMode.Value, ...
    'v2.8 recommended its reliable cutoff as the initial display fmax.');
verifyEqual(testCase,str2double(inputField.Value),expectedFitMaximum, ...
    'RelTol',1e-13,'AbsTol',1e-13);
delete(gui);

wideBand = deterministicRedSignal(n);
[expectedRecommended,expectedFitMaximum] = ...
    expectedBiasRecommendation(coordinate,wideBand);
verifyFalse(testCase,expectedRecommended, ...
    'The regression signal must exercise the non-recommended branch.');
context.current_data = [coordinate,wideBand];
context.data_name = 'bias-not-recommended.txt';
gui = spectrum(context);
verifyFalse(testCase,getappdata(gui, ...
    'SpectrumBiasCorrectionRecommended'));
verifyEqual(testCase,getappdata(gui, ...
    'SpectrumBiasCorrectionFitMaximum'),expectedFitMaximum, ...
    'RelTol',1e-13,'AbsTol',1e-13);
nyquistMode = findall(gui,'Tag','spectrumFmaxNyquistRadio');
verifyTrue(testCase,nyquistMode.Value);
delete(gui);

context.current_data = [coordinate,zeros(n,1)];
context.data_name = 'bias-constant.txt';
gui = spectrum(context);
verifyFalse(testCase,getappdata(gui, ...
    'SpectrumBiasCorrectionRecommended'), ...
    'A zero-power series must safely fall back to bias correction off.');
verifyEqual(testCase,getappdata(gui, ...
    'SpectrumBiasCorrectionFitMaximum'),0.5,'AbsTol',0);
delete(gui);

unevenCoordinate = coordinate;
unevenCoordinate(64) = unevenCoordinate(64)+1e-3;
context.current_data = [unevenCoordinate,lowFrequency];
context.data_name = 'bias-uneven.txt';
gui = spectrum(context);
verifyFalse(testCase,getappdata(gui, ...
    'SpectrumBiasCorrectionRecommended'), ...
    ['The v2.8 periodogram heuristic must not be applied to data that ', ...
     'the GUI classifies as uneven.']);
delete(gui);
end

function testSpectrumBiasCorrectionUsesFitCutoffButSavesPhysicalGrid(testCase)
closeTaggedSpectrumResults();
outputDirectory = tempname;
mkdir(outputDirectory);
testCase.addTeardown(@()removeDirectory(outputDirectory));
n = 128;
coordinate = (0:n-1)';
signal = sin(2*pi*coordinate/31);
[recommended,fitMaximum] = ...
    expectedBiasRecommendation(coordinate,signal);
verifyTrue(testCase,recommended);
hooks = struct( ...
    'RobustSmoothingPromptFcn',@(){'0.1','1','1'}, ...
    'OutputDirectory',outputDirectory);
context = struct('current_data',[coordinate,signal], ...
    'data_name','bias-on.txt','unit','m','SpectrumTestHooks',hooks);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
disableSpectrumSwa(gui);
setExactSpectrumNfft(gui,5*numel(coordinate));
invokeSpectrumButton(gui,'spectrumRunSaveButton');
drawnow;

result = findall(groot,'Type','figure','Tag','spectrumResultFigure');
verifyNumElements(testCase,result,1);
verifyTrue(testCase,getappdata(result, ...
    'SpectrumRobustBiasCorrection'));
verifyEqual(testCase,getappdata(result,'SpectrumRobustFitMaximum'), ...
    fitMaximum,'RelTol',1e-13,'AbsTol',1e-13);

robustFiles = dir(fullfile(outputDirectory, ...
    'bias-on-spectrum-MTM-RobustAR1-*.txt'));
robustFiles = robustFiles(~contains({robustFiles.name},'-median-'));
verifyNumElements(testCase,robustFiles,1);
savedRobust = readmatrix(fullfile(robustFiles.folder,robustFiles.name));
verifyEqual(testCase,savedRobust(end,1),0.5,'AbsTol',8*eps, ...
    ['Bias correction may limit fit support, but saved AR(1) products ', ...
     'must retain the complete physical frequency grid.']);

parameterFiles = dir(fullfile(outputDirectory, ...
    'bias-on-spectrum-parameters-*.xls'));
verifyNumElements(testCase,parameterFiles,1);
parameters = string(readcell(fullfile(parameterFiles.folder, ...
    parameterFiles.name),'Sheet','COCO'));
[row,column] = find(parameters == ...
    "Bias correction for ultra-high resolution data");
verifyNumElements(testCase,row,1);
verifyTrue(testCase,startsWith(parameters(row,column+1), ...
    "On (fit <= "));
end

function testSpectrumRejectsInvalidBiasCorrectionChoice(testCase)
closeTaggedSpectrumResults();
n = 128;
coordinate = (0:n-1)';
[recordAlert,getAlerts] = spectrumAlertRecorder();
hooks = struct('RobustSmoothingPromptFcn',@(){'0.1','1','2'}, ...
    'AlertFcn',recordAlert);
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','bias-invalid.txt','unit','m', ...
    'SpectrumTestHooks',hooks);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
disableSpectrumSwa(gui);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

verifyEmpty(testCase,findall(groot,'Type','figure', ...
    'Tag','spectrumResultFigure'));
verifyEqual(testCase,getAlerts(), ...
    {'Robust AR(1)','Choose bias correction 1 (on) or 0 (off).'});
end

function testSpectrumRejectsInsufficientBiasFitSupport(testCase)
closeTaggedSpectrumResults();
n = 128;
coordinate = (0:n-1)';
[recordAlert,getAlerts] = spectrumAlertRecorder();
hooks = struct( ...
    'RobustSmoothingPromptFcn',@(){'0.05','1','1'}, ...
    'AlertFcn',recordAlert);
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/120)], ...
    'data_name','bias-support.txt','unit','m', ...
    'SpectrumTestHooks',hooks);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
verifyTrue(testCase,getappdata(gui, ...
    'SpectrumBiasCorrectionRecommended'));
disableSpectrumSwa(gui);
setExactSpectrumNfft(gui,n);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

verifyEmpty(testCase,findall(groot,'Type','figure', ...
    'Tag','spectrumResultFigure'));
verifyEqual(testCase,getAlerts(),{'Robust AR(1)', ...
    ['The selected NFFT and robust-fit frequency range contain too ', ...
     'few ordinates for this median smoothing window. Increase NFFT, ', ...
     'increase the window, or turn bias correction off.']});
end

function testSpectrumPaddingRetainsMultiplierSemantics(testCase)
closeTaggedSpectrumResults();
n = 32;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/11)], ...
    'data_name','padding-semantics.txt', ...
    'unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

multiplier = findall(gui,'Tag','spectrumPaddingMultiplierRadio');
multiplierField = findall(gui,'Tag','spectrumPaddingMultiplierField');
exact = findall(gui,'Tag','spectrumPaddingExactRadio');
exactField = findall(gui,'Tag','spectrumPaddingExactField');
verifyNumElements(testCase,multiplier,1);
verifyNumElements(testCase,multiplierField,1);
verifyNumElements(testCase,exact,1);
verifyNumElements(testCase,exactField,1);
verifyFalse(testCase,multiplier.Value);
verifyTrue(testCase,exact.Value, ...
    'Spectrum must default to the exact-NFFT text input.');
verifyEqual(testCase,numericUiValue(multiplierField),5,'AbsTol',0);
verifyEqual(testCase,numericUiValue(exactField),n,'AbsTol',0);
verifyEqual(testCase,string(multiplierField.Enable),"off");
verifyEqual(testCase,string(exactField.Enable),"on");

paddingChildren = multiplier.Parent.Children;
isRadio = arrayfun(@(component)isa(component, ...
    'matlab.ui.control.RadioButton'),paddingChildren);
paddingRadios = paddingChildren(isRadio);
verifyNumElements(testCase,paddingRadios,2, ...
    'Padding must offer multiplier and exact-NFFT modes only.');
paddingTags = strings(size(paddingRadios));
for radioIndex = 1:numel(paddingRadios)
    paddingTags(radioIndex) = string(paddingRadios(radioIndex).Tag);
end
verifyEqual(testCase,sort(paddingTags(:)),sort([ ...
    "spectrumPaddingMultiplierRadio";"spectrumPaddingExactRadio"]));

selectSpectrumMethod(gui,'Periodogram');
selectSpectrumNyquist(gui);
setNumericUiValue(multiplierField,5);
selectSpectrumRadio(multiplier);
[result,power] = runSpectrumResult(gui,'spectrumRunButton');
[expectedFrequency,expectedPower] = expectedPeriodogram(context,5*n);
verifyEqual(testCase,power.XData(:),expectedFrequency,'RelTol',1e-13, ...
    'AbsTol',1e-13);
verifyEqual(testCase,power.YData(:),expectedPower,'RelTol',1e-12, ...
    'AbsTol',1e-12);
delete(result);

% The v2.8 exact-NFFT field was passed straight to PMTM/PERIODOGRAM and
% could intentionally request fewer FFT points than input samples.
exactNfft = 24;
setNumericUiValue(exactField,exactNfft);
selectSpectrumRadio(exact);
[~,power] = runSpectrumResult(gui,'spectrumRunButton');
[expectedFrequency,expectedPower] = expectedPeriodogram(context,exactNfft);
verifyEqual(testCase,power.XData(:),expectedFrequency,'RelTol',1e-13, ...
    'AbsTol',1e-13);
verifyEqual(testCase,power.YData(:),expectedPower,'RelTol',1e-12, ...
    'AbsTol',1e-12);
end

function testSpectrumRejectsRoundedOrOverflowedNfftInputs(testCase)
closeTaggedSpectrumResults();
n = 32;
coordinate = (0:n-1)';
[recordAlert,getAlerts] = spectrumAlertRecorder();
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/11)], ...
    'data_name','invalid-nfft.txt','unit','m', ...
    'SpectrumTestHooks',struct('AlertFcn',recordAlert));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
selectSpectrumMethod(gui,'Periodogram');

multiplier = findall(gui,'Tag','spectrumPaddingMultiplierRadio');
multiplierField = findall(gui,'Tag','spectrumPaddingMultiplierField');
exact = findall(gui,'Tag','spectrumPaddingExactRadio');
exactField = findall(gui,'Tag','spectrumPaddingExactField');

selectSpectrumRadio(exact);
setNumericUiValue(exactField,n+0.25);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;
verifyEmpty(testCase,findall(groot,'Type','figure', ...
    'Tag','spectrumResultFigure'));
alerts = getAlerts();
verifyEqual(testCase,alerts(end,:),{'Spectrum', ...
    ['Zero padding must be a positive multiplier, or an exact ', ...
     'positive-integer NFFT.']});

selectSpectrumRadio(multiplier);
setNumericUiValue(multiplierField,realmax);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;
verifyEmpty(testCase,findall(groot,'Type','figure', ...
    'Tag','spectrumResultFigure'));
alerts = getAlerts();
verifyEqual(testCase,alerts(end,:),{'Spectrum', ...
    ['Zero padding must be a positive multiplier, or an exact ', ...
     'positive-integer NFFT.']});
end

function testSpectrumRejectsInvalidFrequencyLimits(testCase)
closeTaggedSpectrumResults();
n = 32;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/11)], ...
    'data_name','invalid-frequency-limits.txt', ...
    'unit','m');
[recordAlert,getAlerts] = spectrumAlertRecorder();
context.SpectrumTestHooks = struct('AlertFcn',recordAlert);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
fminField = findall(gui,'Tag','spectrumFminField');
fmaxField = findall(gui,'Tag','spectrumFmaxInputField');
fmaxInput = findall(gui,'Tag','spectrumFmaxInputRadio');
verifyNumElements(testCase,fminField,1);
verifyNumElements(testCase,fmaxField,1);
verifyNumElements(testCase,fmaxInput,1);

invalidMinimum = {'not-a-number',Inf};
for index = 1:numel(invalidMinimum)
    alertCount = size(getAlerts(),1);
    setNumericUiValue(fminField,invalidMinimum{index});
    invokeSpectrumButton(gui,'spectrumRunButton');
    drawnow;
    verifyEmpty(testCase,findall(groot,'Type','figure', ...
        'Tag','spectrumResultFigure'));
    alerts = getAlerts();
    verifySize(testCase,alerts,[alertCount+1 2]);
    verifyEqual(testCase,alerts(end,:), ...
        {'Spectrum','fmin must be a finite number.'});
end


setNumericUiValue(fminField,-0.1);
alertCount = size(getAlerts(),1);
[result,~] = runSpectrumResult(gui,'spectrumRunButton');
verifyEqual(testCase,size(getAlerts(),1),alertCount, ...
    'A finite negative fmin must retain v2.8 clipping-to-zero semantics.');
delete(result);

setNumericUiValue(fminField,0.2);
selectSpectrumRadio(fmaxInput);
invalidMaximum = {0.2,0.1,'not-a-number',Inf};
for index = 1:numel(invalidMaximum)
    alertCount = size(getAlerts(),1);
    setNumericUiValue(fmaxField,invalidMaximum{index});
    invokeSpectrumButton(gui,'spectrumRunButton');
    drawnow;
    verifyEmpty(testCase,findall(groot,'Type','figure', ...
        'Tag','spectrumResultFigure'));
    alerts = getAlerts();
    verifySize(testCase,alerts,[alertCount+1 2]);
    verifyEqual(testCase,alerts(end,:), ...
        {'Spectrum','fmax must be finite and > fmin.'});
end

setNumericUiValue(fmaxField,0.6);
alertCount = size(getAlerts(),1);
[result,~,ax] = runSpectrumResult(gui,'spectrumRunButton');
verifyEqual(testCase,size(getAlerts(),1),alertCount, ...
    'fmax above Nyquist must retain v2.8 display-limit semantics.');
verifyEqual(testCase,ax.XLim,[0.2 0.6],'AbsTol',4*eps);
delete(result);

setNumericUiValue(fminField,0);
setNumericUiValue(fmaxField,0.4);
alertCount = size(getAlerts(),1);
[result,~] = runSpectrumResult(gui,'spectrumRunButton');
verifyEqual(testCase,size(getAlerts(),1),alertCount);
delete(result);
end

function testSpectrumRejectsFrequencyRangesWithoutPlottableBins(testCase)
closeTaggedSpectrumResults();
n = 32;
coordinate = (0:n-1)';
[recordAlert,getAlerts] = spectrumAlertRecorder();
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/11)], ...
    'data_name','empty-frequency-range.txt','unit','m', ...
    'SpectrumTestHooks',struct('AlertFcn',recordAlert));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
setExactSpectrumNfft(gui,n);
fminField = findall(gui,'Tag','spectrumFminField');
periodControl = findall(gui,'Tag','spectrumPeriodCheckbox');
verifyNumElements(testCase,fminField,1);
verifyNumElements(testCase,periodControl,1);

setNumericUiValue(fminField,0.201);
setSpectrumMaximumFrequency(gui,0.205);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;
verifyEmpty(testCase,findall(groot,'Type','figure', ...
    'Tag','spectrumResultFigure'));
verifyEqual(testCase,getAlerts(),{'Spectrum', ...
    ['The selected frequency range contains no plottable spectral ', ...
     'ordinates for the selected NFFT and x-axis.']});

setNumericUiValue(fminField,0);
setSpectrumMaximumFrequency(gui,0.01);
setSpectrumCheckbox(periodControl,true);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;
verifyEmpty(testCase,findall(groot,'Type','figure', ...
    'Tag','spectrumResultFigure'), ...
    ['Period mode must reject a range containing only the zero-frequency ', ...
     'ordinate, because 1/f is undefined there.']);
verifyEqual(testCase,getAlerts(),repmat({'Spectrum', ...
    ['The selected frequency range contains no plottable spectral ', ...
     'ordinates for the selected NFFT and x-axis.']},2,1));
end

function testSpectrumPreservesNoiseSelectionsPerMethod(testCase)
coordinate = (0:31)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(numel(coordinate))], ...
    'data_name','method-state.txt','unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
gui.Visible = 'off';

robust = findall(gui,'Tag','spectrumRobustCheckbox');
classic = findall(gui,'Tag','spectrumClassicCheckbox');
ftest = findall(gui,'Tag','spectrumFtestCheckbox');
swa = findall(gui,'Tag','spectrumSwaCheckbox');
verifyNumElements(testCase,robust,1);
verifyNumElements(testCase,classic,1);
verifyNumElements(testCase,ftest,1);
verifyNumElements(testCase,swa,1);

robust.Value = false;
classic.Value = true;
ftest.Value = true;
swa.Value = true;

selectSpectrumMethod(gui,'Lomb-Scargle spectrum');
verifyFalse(testCase,ftest.Value);
verifyFalse(testCase,swa.Value);
verifyEqual(testCase,string(ftest.Visible),"off");
verifyEqual(testCase,string(swa.Visible),"off");
verifyTrue(testCase,robust.Value);
verifyFalse(testCase,classic.Value);
robust.Value = false;
classic.Value = true;

selectSpectrumMethod(gui,'Periodogram');
verifyFalse(testCase,robust.Value);
verifyFalse(testCase,classic.Value);
verifyFalse(testCase,ftest.Value);
verifyFalse(testCase,swa.Value);
classic.Value = true;

selectSpectrumMethod(gui,'Multi-taper method');
verifyFalse(testCase,robust.Value);
verifyTrue(testCase,classic.Value);
verifyTrue(testCase,ftest.Value);
verifyTrue(testCase,swa.Value);
verifyEqual(testCase,string(ftest.Visible),"on");
verifyEqual(testCase,string(swa.Visible),"on");

selectSpectrumMethod(gui,'Lomb-Scargle spectrum');
verifyFalse(testCase,robust.Value);
verifyTrue(testCase,classic.Value);
selectSpectrumMethod(gui,'Periodogram');
verifyTrue(testCase,classic.Value);
end

function testSpectrumInputModeAcceptsDisplayedNyquist(testCase)
closeTaggedSpectrumResults();
n = 32;
coordinate = (0:n-1)'*3;
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','displayed-nyquist.txt', ...
    'unit','m');
[recordAlert,getAlerts] = spectrumAlertRecorder();
context.SpectrumTestHooks = struct('AlertFcn',recordAlert);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
fmaxField = findall(gui,'Tag','spectrumFmaxInputField');
fmaxInput = findall(gui,'Tag','spectrumFmaxInputRadio');
verifyNumElements(testCase,fmaxField,1);
verifyNumElements(testCase,fmaxInput,1);
verifyEqual(testCase,str2double(fmaxField.Value),1/6, ...
    'RelTol',4*eps,'AbsTol',4*eps);
selectSpectrumRadio(fmaxInput);
[result,~] = runSpectrumResult(gui,'spectrumRunButton');
verifyEmpty(testCase,getAlerts());
delete(result);
end

function testSpectrumNwPresetsAndCustomValue(testCase)
closeTaggedSpectrumResults();
n = 40;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','custom-nw.txt', ...
    'unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

nwDropdown = findall(gui,'Tag','spectrumNwDropdown');
customNw = findall(gui,'Tag','spectrumCustomNwRadio');
customNwField = findall(gui,'Tag','spectrumCustomNwField');
verifyNumElements(testCase,nwDropdown,1);
verifyNumElements(testCase,customNw,1);
verifyNumElements(testCase,customNwField,1);
nwPresets = str2double(string(nwDropdown.Items));
verifyEqual(testCase,nwPresets(:)',2:0.5:8,'AbsTol',0);
verifyEqual(testCase,customNwField.Position([1 3]), ...
    nwDropdown.Position([1 3]),'AbsTol',0, ...
    'The custom NW field must align directly below the preset dropdown.');
verifyLessThan(testCase,customNwField.Position(2), ...
    nwDropdown.Position(2));
verifyEqual(testCase,customNwField.Position(4),30,'AbsTol',0, ...
    'Moving the custom NW field must preserve its height.');

robust = findall(gui,'Tag','spectrumRobustCheckbox');
verifyNumElements(testCase,robust,1);
robust.Value = false;
disableSpectrumSwa(gui);
selectSpectrumNyquist(gui);
setExactSpectrumNfft(gui,5*n);
setNumericUiValue(customNwField,2.75);
selectSpectrumRadio(customNw);
[~,power] = runSpectrumResult(gui,'spectrumRunButton');

y = context.current_data(:,2)-mean(context.current_data(:,2));
nfft = 5*n;
[expectedPower,w] = pmtm(y,2.75,nfft);
expectedFrequency = w/(2*pi*median(diff(coordinate)));
keep = isfinite(expectedFrequency) & isfinite(expectedPower) & ...
    expectedFrequency >= 0 & expectedFrequency <= 0.5;
verifyEqual(testCase,power.XData(:),expectedFrequency(keep), ...
    'RelTol',1e-13,'AbsTol',1e-13);
verifyEqual(testCase,power.YData(:),real(expectedPower(keep)), ...
    'RelTol',1e-12,'AbsTol',1e-12);
end

function testSpectrumRejectsInvalidCustomNwAndSingleTaperFtest(testCase)
closeTaggedSpectrumResults();
n = 32;
coordinate = (0:n-1)';
[recordAlert,getAlerts] = spectrumAlertRecorder();
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','invalid-nw.txt','unit','m', ...
    'SpectrumTestHooks',struct('AlertFcn',recordAlert));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
robust = findall(gui,'Tag','spectrumRobustCheckbox');
customRadio = findall(gui,'Tag','spectrumCustomNwRadio');
customField = findall(gui,'Tag','spectrumCustomNwField');
ftestControl = findall(gui,'Tag','spectrumFtestCheckbox');
robust.Value = false;
disableSpectrumSwa(gui);
selectSpectrumRadio(customRadio);

invalidMtm = [1.1,n/2];
for index = 1:numel(invalidMtm)
    setNumericUiValue(customField,invalidMtm(index));
    invokeSpectrumButton(gui,'spectrumRunButton');
    drawnow;
    verifyEmpty(testCase,findall(groot,'Type','figure', ...
        'Tag','spectrumResultFigure'));
    alerts = getAlerts();
    verifyEqual(testCase,alerts(end,:),{'Spectrum', ...
        ['Time-bandwidth product must be 1, or at least 1.25 ', ...
         'and less than half the data length.']});
end

setNumericUiValue(customField,1);
ftestControl.Value = true;
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;
verifyEmpty(testCase,findall(groot,'Type','figure', ...
    'Tag','spectrumResultFigure'));
alerts = getAlerts();
verifyEqual(testCase,alerts(end,:),{'Spectrum', ...
    ['F-test requires NW >= 1.5 in 0.5 increments so that at least ', ...
     'two tapers are available.']});

data = [coordinate,deterministicRedSignal(n)];
verifyError(testCase,@()ftestmtmML(data,1,1,0), ...
    'Acycle:FtestMTM:InvalidTimeBandwidth');
verifyError(testCase,@()ftestmtmML(data,1.75,1,0), ...
    'Acycle:FtestMTM:InvalidTimeBandwidth');
verifyError(testCase,@()ftestmtm( ...
    coordinate,deterministicRedSignal(n),1.75,ones(n,1)*4,1), ...
    'Acycle:FtestMTM:InvalidTimeBandwidth');
end

function testMtmConfidenceUsesActualPmtmTaperCount(testCase)
verifyEqual(testCase,acycleMtmTaperCount(1),2,'AbsTol',0);
verifyEqual(testCase,acycleMtmTaperCount(2.75),5,'AbsTol',0);

closeTaggedSpectrumResults();
n = 40;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','actual-taper-dof.txt','unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
robust = findall(gui,'Tag','spectrumRobustCheckbox');
customRadio = findall(gui,'Tag','spectrumCustomNwRadio');
customField = findall(gui,'Tag','spectrumCustomNwField');
powerLaw = findall(gui,'Tag','spectrumPlCheckbox');
robust.Value = false;
disableSpectrumSwa(gui);
powerLaw.Value = true;
selectSpectrumRadio(customRadio);

cases = [1 4;2.75 10];
for caseIndex = 1:size(cases,1)
    setNumericUiValue(customField,cases(caseIndex,1));
    result = runSpectrumResult(gui,'spectrumRunButton');
    model = findall(result,'Type','line','DisplayName','Power law');
    local95 = findall(result,'Type','line','DisplayName','Local 95%');
    verifyNumElements(testCase,model,1);
    verifyNumElements(testCase,local95,1);
    expectedRatio = chi2inv(0.95,cases(caseIndex,2))/ ...
        cases(caseIndex,2);
    verifyEqual(testCase,local95.YData(:)./model.YData(:), ...
        repmat(expectedRatio,numel(model.YData),1), ...
        'RelTol',1e-12,'AbsTol',1e-12, ...
        ['Confidence limits must use the actual PMTM taper count, ', ...
         'including custom and NW=1 settings.']);
    delete(result);
end
end

function testPeriodogramClassicAr1RetainsTwoDegreesOfFreedom(testCase)
n = 40;
coordinate = (0:n-1)';
values = deterministicRedSignal(n);
[~,~,background,~,confidence95] = redconfchi2( ...
    values,1,1,5*n,1);
verifyEqual(testCase,confidence95./background, ...
    repmat(chi2inv(0.95,2)/2,numel(background),1), ...
    'RelTol',1e-12,'AbsTol',1e-12, ...
    'Classic periodogram AR(1) confidence must retain DOF=2.');
end

function testSpectrumPeriodAxisUsesReciprocalData(testCase)
closeTaggedSpectrumResults();
n = 48;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/13)], ...
    'data_name','period-axis.txt', ...
    'unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
selectSpectrumNyquist(gui);
setExactSpectrumNfft(gui,128);
periodControl = findall(gui,'Tag','spectrumPeriodCheckbox');
logControl = findall(gui,'Tag','spectrumLogFrequencyCheckbox');
verifyNumElements(testCase,periodControl,1);
verifyNumElements(testCase,logControl,1);
setSpectrumCheckbox(periodControl,true);
setSpectrumCheckbox(logControl,false);
verifyFalse(testCase,logControl.Value, ...
    'Period display must not force a logarithmic x-axis.');

[result,power,ax] = runSpectrumResult(gui,'spectrumRunButton');
[expectedFrequency,expectedPower] = expectedPeriodogram(context,128);
positive = expectedFrequency > 0;
verifyEqual(testCase,power.XData(:),1./expectedFrequency(positive), ...
    'RelTol',1e-13,'AbsTol',1e-13);
verifyEqual(testCase,power.YData(:),expectedPower(positive), ...
    'RelTol',1e-12,'AbsTol',1e-12);
verifyTrue(testCase,all(isfinite(power.XData)));
verifyTrue(testCase,all(power.XData > 0));
verifyEqual(testCase,string(ax.XDir),"reverse");
verifyEqual(testCase,string(ax.XScale),"linear");
delete(result);

setSpectrumMaximumFrequency(gui,0.37);
[result,~,ax] = runSpectrumResult(gui,'spectrumRunButton');
verifyEqual(testCase,ax.XLim(1),1/0.37, ...
    'RelTol',1e-13,'AbsTol',1e-13, ...
    ['Period limits must represent the requested physical fmax even ', ...
     'when fmax is between spectral-grid ordinates.']);
delete(result);

fminField = findall(gui,'Tag','spectrumFminField');
setNumericUiValue(fminField,0.08);
[result,~,ax] = runSpectrumResult(gui,'spectrumRunButton');
verifyEqual(testCase,ax.XLim,[1/0.37 1/0.08], ...
    'RelTol',1e-13,'AbsTol',1e-13, ...
    'Positive frequency bounds must map exactly to reciprocal limits.');
delete(result);

selectSpectrumNyquist(gui);
setNumericUiValue(fminField,0);
setSpectrumCheckbox(periodControl,false);
setSpectrumCheckbox(logControl,false);
[~,power,ax] = runSpectrumResult(gui,'spectrumRunButton');
verifyEqual(testCase,power.XData(:),expectedFrequency, ...
    'RelTol',1e-13,'AbsTol',1e-13);
verifyEqual(testCase,power.YData(:),expectedPower, ...
    'RelTol',1e-12,'AbsTol',1e-12);
verifyEqual(testCase,string(ax.XDir),"normal");
verifyEqual(testCase,string(ax.XScale),"linear");
end

function testSpectrumLogFrequencyExcludesZeroFromAxisLimits(testCase)
closeTaggedSpectrumResults();
n = 48;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/13)], ...
    'data_name','log-frequency-axis.txt','unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
selectSpectrumNyquist(gui);
setExactSpectrumNfft(gui,128);
logControl = findall(gui,'Tag','spectrumLogFrequencyCheckbox');
verifyNumElements(testCase,logControl,1);
setSpectrumCheckbox(logControl,true);

[~,power,ax] = runSpectrumResult(gui,'spectrumRunButton');
verifyEqual(testCase,string(ax.XScale),"log");
positiveFrequency = power.XData(power.XData > 0);
verifyEqual(testCase,ax.XLim(1),min(positiveFrequency), ...
    'RelTol',1e-13,'AbsTol',1e-13, ...
    'Log-frequency display must not pass a zero lower limit to MATLAB.');
end

function testSpectrumRunAndSaveKeepsFrequencyColumnInPeriodMode(testCase)
closeTaggedSpectrumResults();
outputDirectory = tempname;
mkdir(outputDirectory);
testCase.addTeardown(@()removeDirectory(outputDirectory));
n = 32;
coordinate = (0:n-1)';
hooks = struct('OutputDirectory',outputDirectory);
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/9)], ...
    'data_name','period-save-frequency.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',hooks);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
selectSpectrumNyquist(gui);
setExactSpectrumNfft(gui,64);
periodControl = findall(gui,'Tag','spectrumPeriodCheckbox');
verifyNumElements(testCase,periodControl,1);
setSpectrumCheckbox(periodControl,true);
runSpectrumResult(gui,'spectrumRunSaveButton');

dataFiles = dir(fullfile(outputDirectory, ...
    'period-save-frequency-spectrum-*.txt'));
verifyNumElements(testCase,dataFiles,1);
saved = readmatrix(fullfile(dataFiles.folder,dataFiles.name));
[expectedFrequency,expectedPower] = expectedPeriodogram(context,64);
verifySize(testCase,saved,[numel(expectedFrequency),2]);
verifyEqual(testCase,saved(:,1),expectedFrequency, ...
    'RelTol',1e-13,'AbsTol',1e-13);
verifyEqual(testCase,saved(:,2),expectedPower, ...
    'RelTol',1e-12,'AbsTol',1e-12);
end

function testSpectrumRunAndSaveDoesNotReuseOrphanedAuxiliarySuffix(testCase)
closeTaggedSpectrumResults();
outputDirectory = tempname;
mkdir(outputDirectory);
testCase.addTeardown(@()removeDirectory(outputDirectory));
orphanFile = fullfile(outputDirectory, ...
    'orphan-numbering-spectrum-MTM-SWA-FDR-1.txt');
writematrix([1 2;3 4],orphanFile,'Delimiter','tab');
orphanContents = fileread(orphanFile);

n = 32;
coordinate = (0:n-1)';
hooks = struct('OutputDirectory',outputDirectory);
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/9)], ...
    'data_name','orphan-numbering.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',hooks);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
setExactSpectrumNfft(gui,64);
runSpectrumResult(gui,'spectrumRunSaveButton');

verifyTrue(testCase,isfile(fullfile(outputDirectory, ...
    'orphan-numbering-spectrum-2.txt')));
verifyFalse(testCase,isfile(fullfile(outputDirectory, ...
    'orphan-numbering-spectrum-1.txt')));
verifyEqual(testCase,fileread(orphanFile),orphanContents, ...
    'An orphaned auxiliary product must reserve its run suffix.');
end

function testPowerLawUsesFullSpectrumAndOriginalSampleCount(testCase)
closeTaggedSpectrumResults();
n = 40;
nfft = 200;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','power-law-full-spectrum.txt', ...
    'unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
setExactSpectrumNfft(gui,nfft);
powerLawControl = findall(gui,'Text','Power Law');
verifyNumElements(testCase,powerLawControl,1);
powerLawControl.Value = true;

lowFmax = 0.25;
setSpectrumMaximumFrequency(gui,lowFmax);
[lowResult,~,~] = runSpectrumResult(gui,'spectrumRunButton');
lowModel = findall(lowResult,'Type','line','DisplayName','Power law');
lowGlobal95 = findall(lowResult,'Type','line','DisplayName','Global 95%');
verifyNumElements(testCase,lowModel,1);
verifyNumElements(testCase,lowGlobal95,1);
lowFrequency = lowModel.XData(:);
lowModelPower = lowModel.YData(:);
lowGlobalPower = lowGlobal95.YData(:);
delete(lowResult);

setSpectrumMaximumFrequency(gui,0.5);
[highResult,~,~] = runSpectrumResult(gui,'spectrumRunButton');
highModel = findall(highResult,'Type','line','DisplayName','Power law');
highGlobal95 = findall(highResult,'Type','line','DisplayName','Global 95%');
verifyNumElements(testCase,highModel,1);
verifyNumElements(testCase,highGlobal95,1);
highFrequency = highModel.XData(:);
highModelPower = highModel.YData(:);
highGlobalPower = highGlobal95.YData(:);
common = highFrequency <= lowFmax;
verifyEqual(testCase,highFrequency(common),lowFrequency, ...
    'RelTol',1e-13,'AbsTol',1e-13);
verifyEqual(testCase,highModelPower(common),lowModelPower, ...
    'RelTol',1e-12,'AbsTol',1e-12, ...
    'The power-law fit must not depend on the displayed fmax.');
verifyEqual(testCase,highGlobalPower(common),lowGlobalPower, ...
    'RelTol',1e-12,'AbsTol',1e-12, ...
    'Global thresholds must not depend on the displayed fmax.');

y = context.current_data(:,2)-mean(context.current_data(:,2));
[fullPower,fullFrequency] = periodogram(y,[],nfft,1);
fitBins = fullFrequency > 0 & isfinite(fullFrequency) & ...
    isfinite(fullPower) & fullPower > 0;
coefficients = polyfit(log(fullFrequency(fitBins)), ...
    log(fullPower(fitBins)),1);
expectedModel = exp(coefficients(2))* ...
    highFrequency.^coefficients(1);
verifyEqual(testCase,highModelPower,expectedModel, ...
    'RelTol',1e-12,'AbsTol',1e-12, ...
    'Power-law fitting must use the full physical frequency range.');

expectedGlobalRatio = chi2inv(1-0.05/(n/2),2)/2;
verifyEqual(testCase,highGlobalPower./highModelPower, ...
    repmat(expectedGlobalRatio,numel(highModelPower),1), ...
    'RelTol',1e-12,'AbsTol',1e-12, ...
    'Global thresholds must use N/2, not the padded bin count.');
end

function testBendingPowerLawFitsLogPowerAndUsesFullSpectrum(testCase)
closeTaggedSpectrumResults();
n = 40;
nfft = 200;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','bending-power-law-full-spectrum.txt', ...
    'unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Periodogram');
setExactSpectrumNfft(gui,nfft);
customNw = findall(gui,'Tag','spectrumCustomNwRadio');
customNwField = findall(gui,'Tag','spectrumCustomNwField');
bendingPowerLaw = findall(gui,'Tag','spectrumBplCheckbox');
verifyNumElements(testCase,customNw,1);
verifyNumElements(testCase,customNwField,1);
verifyNumElements(testCase,bendingPowerLaw,1);
selectSpectrumRadio(customNw);
setNumericUiValue(customNwField,'invalid-inactive-nw');
bendingPowerLaw.Value = true;

lowFmax = 0.25;
setSpectrumMaximumFrequency(gui,lowFmax);
[lowResult,~,~] = runSpectrumResult(gui,'spectrumRunButton');
lowModel = findall(lowResult,'Type','line', ...
    'DisplayName','Bending power law');
lowLocal95 = findall(lowResult,'Type','line','DisplayName','Local 95%');
verifyNumElements(testCase,lowModel,1, ...
    ['A non-MTM model must not evaluate an inactive custom NW ', ...
     'setting.']);
verifyNumElements(testCase,lowLocal95,1);
lowFrequency = lowModel.XData(:);
lowModelPower = lowModel.YData(:);
verifyTrue(testCase,all(isfinite(lowModelPower) & lowModelPower > 0), ...
    'The fitted BPL must be finite and positive at every positive frequency.');
verifyEqual(testCase,lowLocal95.YData(:)./lowModelPower, ...
    repmat(chi2inv(0.95,2)/2,numel(lowModelPower),1), ...
    'RelTol',1e-12,'AbsTol',1e-12);
delete(lowResult);

setSpectrumMaximumFrequency(gui,0.5);
[highResult,~,~] = runSpectrumResult(gui,'spectrumRunButton');
highModel = findall(highResult,'Type','line', ...
    'DisplayName','Bending power law');
verifyNumElements(testCase,highModel,1);
highFrequency = highModel.XData(:);
highModelPower = highModel.YData(:);
common = highFrequency <= lowFmax;
verifyEqual(testCase,highFrequency(common),lowFrequency, ...
    'RelTol',1e-13,'AbsTol',1e-13);
verifyEqual(testCase,highModelPower(common),lowModelPower, ...
    'RelTol',2e-10,'AbsTol',2e-10*max(lowModelPower), ...
    'The BPL fit must use the full spectrum, independent of display fmax.');

slopes = diff(log(highModelPower))./diff(log(highFrequency));
verifyTrue(testCase,all(isfinite(slopes)), ...
    'A log-domain BPL fit must have finite log-log slopes.');
verifyLessThanOrEqual(testCase,max(diff(slopes)),1e-6, ...
    ['The positive slope-increment parameterization must produce a ', ...
     'smoothly steepening bending power law.']);
end

function testFtestPeriodFiguresUseReciprocalCoordinates(testCase)
closeTaggedSpectrumResults();
n = 32;
nfft = 49;
coordinate = (0:n-1)';
signal = deterministicRedSignal(n)+0.4*sin(2*pi*coordinate/9);
context = struct( ...
    'current_data',[coordinate,signal], ...
    'data_name','ftest-period.txt', ...
    'unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

setExactSpectrumNfft(gui,nfft);
robust = findall(gui,'Tag','spectrumRobustCheckbox');
ftestControl = findall(gui,'Text','F-test & Ampl.');
periodControl = findall(gui,'Tag','spectrumPeriodCheckbox');
verifyNumElements(testCase,robust,1);
verifyNumElements(testCase,ftestControl,1);
verifyNumElements(testCase,periodControl,1);
robust.Value = false;
disableSpectrumSwa(gui);
ftestControl.Value = true;
selectSpectrumNyquist(gui);
setSpectrumCheckbox(periodControl,true);

figuresBefore = findall(groot,'Type','figure');
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;
figuresAfter = findall(groot,'Type','figure');
newFigures = figuresAfter(~ismember(figuresAfter,figuresBefore));
newTags = strings(numel(newFigures),1);
for figureIndex = 1:numel(newFigures)
    newTags(figureIndex) = string(newFigures(figureIndex).Tag);
end
verifyNumElements(testCase,newFigures,3, ...
    'Spectrum plus two managed F-test figures should be created.');
verifyEqual(testCase,sort(newTags),sort([ ...
    "spectrumResultFigure"; ...
    "spectrumFtestFigure"; ...
    "spectrumFtestDiagnosticsFigure"]), ...
    'ftestmtmML must not create an implicit untagged figure.');

[frequency,~,~,~,~,~,~,~,~] = ftestmtmML( ...
    context.current_data,2,nfft/n,0);
expectedPeriods = 1./frequency( ...
    isfinite(frequency) & frequency > 0 & frequency <= 0.5);
ftestFigures = [ ...
    findall(groot,'Type','figure','Tag','spectrumFtestFigure'); ...
    findall(groot,'Type','figure', ...
    'Tag','spectrumFtestDiagnosticsFigure')];
verifyNumElements(testCase,ftestFigures,2);
for figureIndex = 1:numel(ftestFigures)
    axesHandles = findall(ftestFigures(figureIndex),'Type','axes');
    for axisIndex = 1:numel(axesHandles)
        lines = findall(axesHandles(axisIndex),'Type','line');
        isMainData = arrayfun(@(lineHandle) ...
            numel(lineHandle.XData) > 2,lines);
        mainLines = lines(isMainData);
        verifyNumElements(testCase,mainLines,1);
        xData = mainLines.XData(:);
        verifyTrue(testCase,all(isfinite(xData) & xData > 0));
        verifyTrue(testCase,all(ismembertol(xData,expectedPeriods(:), ...
            1e-12,'DataScale',1)), ...
            'F-test data XData must be reciprocal positive frequency.');
        verifyEqual(testCase,string(axesHandles(axisIndex).XDir), ...
            "reverse");
    end
end
end

function testFtestHelperHonorsNonIntegralExactNfft(testCase)
n = 24;
nfft = 19;
coordinate = (0:n-1)';
data = [coordinate,deterministicRedSignal(n)];
verifyNotEqual(testCase,nfft/n,round(nfft/n), ...
    'The regression case must use a non-integral padding multiplier.');
verifyLessThan(testCase,nfft,n, ...
    'The regression case must cover a legacy exact NFFT shorter than N.');

[frequency,ftest,significance,amplitude,phase,signal,noise,dof,weights] = ...
    ftestmtmML(data,2,nfft/n,0);
expectedFrequency = (0:nfft-1)'/nfft;
verifyEqual(testCase,frequency(:),expectedFrequency, ...
    'RelTol',1e-13,'AbsTol',1e-13);
outputs = {ftest,significance,amplitude,phase,signal,noise,dof};
for outputIndex = 1:numel(outputs)
    verifyNumElements(testCase,outputs{outputIndex},nfft);
end
verifySize(testCase,weights,[nfft,3]);
end

function testFtestHelpersUseMedianSamplingInterval(testCase)
n = 64;
nfft = 96;
dt = 2;
coordinate = (0:n-1)'*dt;
coordinate(2:end) = coordinate(2:end)+9e-6*dt;
signal = deterministicRedSignal(n);
verifyFalse(testCase,acycleSamplingIsUneven(coordinate), ...
    'The regression grid must remain eligible for regular-spectrum tools.');
verifyNotEqual(testCase,coordinate(2)-coordinate(1), ...
    median(diff(coordinate)));
verifyNotEqual(testCase,mean(diff(coordinate)), ...
    median(diff(coordinate)));

[ftestFrequency,~,~,~,~,~,~,~,~] = ftestmtmML( ...
    [coordinate,signal],2,nfft/n,0);
[dofFrequency,~,~] = mtmdofs( ...
    coordinate,detrend(signal),2,nfft/n);
expectedFrequency = (0:nfft-1)'./ ...
    (nfft*median(diff(coordinate)));
verifyEqual(testCase,ftestFrequency(:),expectedFrequency, ...
    'RelTol',1e-13,'AbsTol',1e-13, ...
    ['F-test frequency must use the same robust sampling interval as ', ...
     'the main spectrum.']);
verifyEqual(testCase,dofFrequency(:),expectedFrequency, ...
    'RelTol',1e-13,'AbsTol',1e-13, ...
    ['Adaptive-DOF frequency must use the same robust sampling interval ', ...
     'as the main spectrum.']);
end

function testSpectrumSwaUsesMainSpectrumSamplingInterval(testCase)
closeTaggedSpectrumResults();
n = 64;
nfft = 128;
dt = 2;
coordinate = (0:n-1)'*dt;
coordinate(2:end) = coordinate(2:end)+9e-6*dt;
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','swa-sampling-grid.txt','unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
verifyFalse(testCase,acycleSamplingIsUneven(coordinate));

robust = findall(gui,'Tag','spectrumRobustCheckbox');
swa = findall(gui,'Tag','spectrumSwaCheckbox');
verifyNumElements(testCase,robust,1);
verifyNumElements(testCase,swa,1);
robust.Value = false;
swa.Value = true;
setExactSpectrumNfft(gui,nfft);
selectSpectrumNyquist(gui);

[~,mainPower] = runSpectrumResult(gui,'spectrumRunButton');
swaFigure = findall(groot,'Type','figure','Tag','spectrumSwaFigure');
verifyNumElements(testCase,swaFigure,1);
swaPower = findall(swaFigure,'Type','line','DisplayName','Power');
verifyNumElements(testCase,swaPower,1);
expectedFrequency = (0:floor(nfft/2))'./ ...
    (nfft*median(diff(coordinate)));
verifyEqual(testCase,swaPower.XData(:),expectedFrequency, ...
    'RelTol',1e-13,'AbsTol',1e-13);
verifyEqual(testCase,swaPower.XData(:),mainPower.XData(:), ...
    'RelTol',1e-13,'AbsTol',1e-13, ...
    'SWA and the main spectrum must share one physical frequency grid.');
end

function testLombHonorsInputFmaxAboveEffectiveNyquist(testCase)
closeTaggedSpectrumResults();
n = 48;
coordinate = (0:n-1)';
coordinate(24) = coordinate(24)+0.01;
signal = sin(2*pi*coordinate/7)+0.2*cos(2*pi*coordinate/2.4);
outputDirectory = tempname;
mkdir(outputDirectory);
testCase.addTeardown(@()removeDirectory(outputDirectory));
context = struct( ...
    'current_data',[coordinate,signal], ...
    'data_name','lomb-high-fmax.txt','unit','m', ...
    'SpectrumTestHooks',struct('OutputDirectory',outputDirectory, ...
    'RobustSmoothingPromptFcn',@()20));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

selectSpectrumMethod(gui,'Lomb-Scargle spectrum');
robust = findall(gui,'Tag','spectrumRobustCheckbox');
classic = findall(gui,'Tag','spectrumClassicCheckbox');
verifyNumElements(testCase,robust,1);
verifyNumElements(testCase,classic,1);
robust.Value = false;
classic.Value = true;
physicalNyquist = 1/(2*median(diff(coordinate)));
requestedMaximum = 1.6*physicalNyquist;
setSpectrumMaximumFrequency(gui,requestedMaximum);

[~,power] = runSpectrumResult(gui,'spectrumRunSaveButton');
verifyGreaterThan(testCase,max(power.XData),physicalNyquist, ...
    ['An explicit Lomb fmax above the effective Nyquist must extend ', ...
     'the calculated spectrum, not only the axes.']);
verifyLessThanOrEqual(testCase,max(power.XData),requestedMaximum);
whiteNoise = findall(groot,'Type','line','DisplayName','White noise 90%');
verifyNumElements(testCase,whiteNoise,1);
verifyGreaterThan(testCase,max(whiteNoise.XData),physicalNyquist, ...
    'Lomb white-noise significance must use the same extended grid.');

dataFiles = dir(fullfile(outputDirectory,'*.txt'));
isMainSpectrum = ~cellfun('isempty',regexp({dataFiles.name}, ...
    '^lomb-high-fmax-spectrum-[0-9]+\.txt$','once'));
dataFiles = dataFiles(isMainSpectrum);
verifyNumElements(testCase,dataFiles,1);
saved = readmatrix(fullfile(dataFiles.folder,dataFiles.name));
verifyGreaterThan(testCase,max(saved(:,1)),physicalNyquist, ...
    'Saved Lomb output must contain the requested high-frequency grid.');
end

function testSpectrumRestoresSwaConfidenceSelector(testCase)
closeTaggedSpectrumResults();
n = 64;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','swa-selector.txt','unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

robust = findall(gui,'Tag','spectrumRobustCheckbox');
swa = findall(gui,'Tag','spectrumSwaCheckbox');
robust.Value = false;
swa.Value = true;
setExactSpectrumNfft(gui,128);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

swaFigure = findall(groot,'Type','figure','Tag','spectrumSwaFigure');
optionsFigure = findall(groot,'Type','figure', ...
    'Tag','spectrumSwaOptionsFigure');
verifyNumElements(testCase,swaFigure,1);
verifyNumElements(testCase,optionsFigure,1, ...
    'v2.8 exposed a live SWA confidence-line selector.');
controls = findall(optionsFigure,'Tag','spectrumSwaOptionCheckbox');
verifyNumElements(testCase,controls,11);
verifyNumElements(testCase,findall(swaFigure,'Type','line', ...
    'DisplayName','10% FDR'),0, ...
    'The restored initial plot must retain the v2.8 default line set.');
verifyNumElements(testCase,findall(swaFigure,'Type','line', ...
    'DisplayName','Chi2 99.99%'),0);

verifySwaLineStyle(testCase,swaFigure,'Chi2 90%',[1 0 0],'-',0.5);
verifySwaLineStyle(testCase,swaFigure,'Chi2 95%',[1 0 0],'--',2);
verifySwaLineStyle(testCase,swaFigure,'Chi2 99%',[0 0 1],'-.',0.5);
verifySwaLineStyle(testCase,swaFigure,'Chi2 99.9%',[1 0 1],'-.',0.5);

tenPercent = controls(arrayfun(@(control)control.UserData == 2,controls));
chi9999 = controls(arrayfun(@(control)control.UserData == 11,controls));
verifyNumElements(testCase,tenPercent,1);
verifyNumElements(testCase,chi9999,1);
verifyFalse(testCase,logical(tenPercent.Value), ...
    'The selector state must match the v2.8 initial plot.');
verifyFalse(testCase,logical(chi9999.Value));

background = controls(arrayfun(@(control)control.UserData == 1,controls));
verifyNumElements(testCase,background,1);
background.Value = false;
invokeUiCallback(background,'Callback');
verifyNumElements(testCase,findall(swaFigure,'Type','line', ...
    'DisplayName','10% FDR'),0, ...
    'Changing an unrelated option must not enable 10% FDR.');
verifyNumElements(testCase,findall(swaFigure,'Type','line', ...
    'DisplayName','Chi2 99.99%'),0, ...
    'Changing an unrelated option must not enable 99.99% Chi2.');
if strcmp(tenPercent.Enable,'on')
    tenPercent.Value = true;
    invokeUiCallback(tenPercent,'Callback');
    verifyNumElements(testCase,findall(swaFigure,'Type','line', ...
        'DisplayName','10% FDR'),1);
end
chi9999.Value = true;
invokeUiCallback(chi9999,'Callback');
verifyNumElements(testCase,findall(swaFigure,'Type','line', ...
    'DisplayName','Chi2 99.99%'),1);

close(swaFigure);
drawnow;
verifyEmpty(testCase,findall(groot,'Type','figure', ...
    'Tag','spectrumSwaOptionsFigure'), ...
    'Closing the SWA plot must also close its selector.');
end

function verifySwaLineStyle(testCase,swaFigure,displayName, ...
        expectedColor,expectedStyle,expectedWidth)
lineHandle = findall(swaFigure,'Type','line', ...
    'DisplayName',displayName);
verifyNumElements(testCase,lineHandle,1);
verifyEqual(testCase,lineHandle.Color,expectedColor,'AbsTol',0);
verifyEqual(testCase,string(lineHandle.LineStyle),string(expectedStyle));
verifyEqual(testCase,lineHandle.LineWidth,expectedWidth,'AbsTol',0);
end

function testSwaSelectorRefreshKeepsReciprocalPeriodCoordinates(testCase)
closeTaggedSpectrumResults();
n = 64;
coordinate = (0:n-1)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(n)], ...
    'data_name','swa-period-selector.txt','unit','m');
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';

robust = findall(gui,'Tag','spectrumRobustCheckbox');
swa = findall(gui,'Tag','spectrumSwaCheckbox');
period = findall(gui,'Tag','spectrumPeriodCheckbox');
robust.Value = false;
swa.Value = true;
setSpectrumCheckbox(period,true);
setExactSpectrumNfft(gui,128);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

swaFigure = findall(groot,'Type','figure','Tag','spectrumSwaFigure');
optionsFigure = findall(groot,'Type','figure', ...
    'Tag','spectrumSwaOptionsFigure');
powerBefore = findall(swaFigure,'Type','line','DisplayName','Power');
frequency = (0:64)'/128;
expectedPeriods = 1./frequency(frequency > 0);
verifyEqual(testCase,powerBefore.XData(:),expectedPeriods, ...
    'RelTol',1e-13,'AbsTol',1e-13);

controls = findall(optionsFigure,'Tag','spectrumSwaOptionCheckbox');
chi9999 = controls(arrayfun(@(control)control.UserData == 11,controls));
chi9999.Value = true;
invokeUiCallback(chi9999,'Callback');
powerAfter = findall(swaFigure,'Type','line','DisplayName','Power');
verifyEqual(testCase,powerAfter.XData(:),expectedPeriods, ...
    'RelTol',1e-13,'AbsTol',1e-13, ...
    'Refreshing SWA options must continue plotting true reciprocal data.');
verifyEqual(testCase,string(ancestor(powerAfter,'axes').XDir),"reverse");
end

function testRobustAr1UsesSelectedMtmSmoothingFraction(testCase)
closeTaggedSpectrumResults();
coordinate = (0:127)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(numel(coordinate))], ...
    'data_name','robust-mtm.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',struct( ...
    'RobustSmoothingPromptFcn',@(){'0.1','1','0'}));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
disableSpectrumSwa(gui);
setExactSpectrumNfft(gui,5*numel(coordinate));
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

result = findall(groot,'Type','figure','Tag','spectrumResultFigure');
verifyNumElements(testCase,result,1);
verifyEqual(testCase, ...
    getappdata(result,'SpectrumRobustSmoothingFraction'),0.1,'AbsTol',0);
verifyEqual(testCase,getappdata(result,'SpectrumRobustFitModel'),1, ...
    'AbsTol',0);
smoothed = findall(result,'Type','line','DisplayName','10% median-smoothed');
verifyNumElements(testCase,smoothed,1);

signal = context.current_data(:,2)-mean(context.current_data(:,2));
[~,~,expected] = redconfML( ...
    signal,1,2,5*numel(signal),1,0.1,0.5,0);
keep = expected(:,1) >= 0 & expected(:,1) <= 0.5;
verifyEqual(testCase,smoothed.YData(:),real(expected(keep,3)), ...
    'RelTol',1e-12,'AbsTol',1e-12);
verifyTrue(testCase,all(isfinite(smoothed.YData)));
end

function testRobustAr1AcceptsExplicitLombPercentage(testCase)
closeTaggedSpectrumResults();
coordinate = (0:127)';
coordinate(64) = coordinate(64)+1e-3;
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/31)], ...
    'data_name','robust-lomb.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',struct( ...
    'RobustSmoothingPromptFcn',@()20));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

result = findall(groot,'Type','figure','Tag','spectrumResultFigure');
verifyNumElements(testCase,result,1);
verifyEqual(testCase, ...
    getappdata(result,'SpectrumRobustSmoothingFraction'),0.2,'AbsTol',0);
smoothed = findall(result,'Type','line','DisplayName','20% median-smoothed');
verifyNumElements(testCase,smoothed,1);

signal = context.current_data(:,2)-mean(context.current_data(:,2));
[~,expectedFrequency,expectedThresholds] = plomb_robustar1( ...
    signal,coordinate+abs(min(coordinate)),0.5,0.2,0);
keep = expectedFrequency >= 0 & expectedFrequency <= 0.5;
verifyEqual(testCase,smoothed.YData(:), ...
    real(expectedThresholds(1,keep))','RelTol',1e-12,'AbsTol',1e-12);
verifyTrue(testCase,all(isfinite(smoothed.YData)));
end

function testCancelingRobustSmoothingStopsBeforeCalculation(testCase)
closeTaggedSpectrumResults();
coordinate = (0:127)';
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/31)], ...
    'data_name','robust-cancel.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',struct( ...
    'RobustSmoothingPromptFcn',@()[]));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
gui.Visible = 'off';
disableSpectrumSwa(gui);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

verifyEmpty(testCase, ...
    findall(groot,'Type','figure','Tag','spectrumResultFigure'));
end

function testRobustUncheckedDoesNotRequestSmoothing(testCase)
closeTaggedSpectrumResults();
coordinate = (0:127)';
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/31)], ...
    'data_name','robust-disabled.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',struct( ...
    'RobustSmoothingPromptFcn',@unexpectedSmoothingPrompt));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
robust = findall(gui,'Tag','spectrumRobustCheckbox');
verifyNumElements(testCase,robust,1);
robust.Value = false;
disableSpectrumSwa(gui);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

result = findall(groot,'Type','figure','Tag','spectrumResultFigure');
verifyNumElements(testCase,result,1);
verifyTrue(testCase,isnan( ...
    getappdata(result,'SpectrumRobustSmoothingFraction')));
end

function testRunAndSaveRecordsSelectedRobustSmoothing(testCase)
closeTaggedSpectrumResults();
outputDirectory = tempname;
mkdir(outputDirectory);
testCase.addTeardown(@()removeDirectory(outputDirectory));
coordinate = (0:127)';
hooks = struct( ...
    'RobustSmoothingPromptFcn',@(){'0.1','1','0'}, ...
    'OutputDirectory',outputDirectory);
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(numel(coordinate))], ...
    'data_name','robust-save.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',hooks);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
disableSpectrumSwa(gui);
setExactSpectrumNfft(gui,5*numel(coordinate));
invokeSpectrumButton(gui,'spectrumRunSaveButton');
drawnow;

parameterFiles = dir(fullfile(outputDirectory, ...
    'robust-save-spectrum-parameters-*.xls'));
verifyNumElements(testCase,parameterFiles,1);
parameters = readcell(fullfile(parameterFiles.folder,parameterFiles.name), ...
    'Sheet','COCO');
parameterText = string(parameters);
[row,column] = find(parameterText == "Median smoothing window");
verifyNumElements(testCase,row,1);
verifyEqual(testCase,parameterText(row,column+1),"0.1 (10%)");
end

function testRobustMtmLogFitIsUsedAndRecorded(testCase)
closeTaggedSpectrumResults();
outputDirectory = tempname;
mkdir(outputDirectory);
testCase.addTeardown(@()removeDirectory(outputDirectory));
coordinate = (0:127)';
hooks = struct( ...
    'RobustSmoothingPromptFcn',@(){'0.1','2','0'}, ...
    'OutputDirectory',outputDirectory);
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(numel(coordinate))], ...
    'data_name','robust-log-fit.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',hooks);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
disableSpectrumSwa(gui);
setExactSpectrumNfft(gui,5*numel(coordinate));
invokeSpectrumButton(gui,'spectrumRunSaveButton');
drawnow;

result = findall(groot,'Type','figure','Tag','spectrumResultFigure');
verifyNumElements(testCase,result,1);
verifyEqual(testCase, ...
    getappdata(result,'SpectrumRobustSmoothingFraction'),0.1,'AbsTol',0);
verifyEqual(testCase,getappdata(result,'SpectrumRobustFitModel'),2, ...
    'AbsTol',0);
smoothed = findall(result,'Type','line', ...
    'DisplayName','10% median-smoothed');
verifyNumElements(testCase,smoothed,1);

signal = context.current_data(:,2)-mean(context.current_data(:,2));
[~,~,expected] = redconfML( ...
    signal,1,2,5*numel(signal),2,0.1,0.5,0);
keep = expected(:,1) >= 0 & expected(:,1) <= 0.5;
verifyEqual(testCase,smoothed.YData(:),real(expected(keep,3)), ...
    'RelTol',1e-12,'AbsTol',1e-12);

parameterFiles = dir(fullfile(outputDirectory, ...
    'robust-log-fit-spectrum-parameters-*.xls'));
verifyNumElements(testCase,parameterFiles,1);
parameters = readcell(fullfile(parameterFiles.folder,parameterFiles.name), ...
    'Sheet','COCO');
parameterText = string(parameters);
[row,column] = find(parameterText == "AR(1) best fit model");
verifyNumElements(testCase,row,1);
verifyEqual(testCase,parameterText(row,column+1),"Log power");
end

function testCancelingRunAndSaveCreatesNoOutput(testCase)
closeTaggedSpectrumResults();
outputDirectory = tempname;
mkdir(outputDirectory);
testCase.addTeardown(@()removeDirectory(outputDirectory));
coordinate = (0:127)';
hooks = struct( ...
    'RobustSmoothingPromptFcn',@()[], ...
    'OutputDirectory',outputDirectory);
context = struct( ...
    'current_data',[coordinate,sin(2*pi*coordinate/31)], ...
    'data_name','robust-save-cancel.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',hooks);
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
gui.Visible = 'off';
disableSpectrumSwa(gui);
invokeSpectrumButton(gui,'spectrumRunSaveButton');
drawnow;

verifyEmpty(testCase,dir(fullfile(outputDirectory, ...
    'robust-save-cancel-spectrum-*')));
verifyEmpty(testCase, ...
    findall(groot,'Type','figure','Tag','spectrumResultFigure'));
end

function testRobustPromptRetainsV28Settings(testCase)
source = fileread(which('spectrum'));
verifyNotEmpty(testCase,strfind(source, ...
    'Median smoothing window: default 0.2 = 20%'));
verifyNotEmpty(testCase,strfind(source, ...
    'AR(1) best-fit model: 1 = linear power'));
verifyNotEmpty(testCase,strfind(source, ...
    '(default), 2 = log power'));
verifyNotEmpty(testCase,strfind(source, ...
    'Bias correction for ultra-high resolution'));
verifyNotEmpty(testCase,strfind(source, ...
    '{''0.2'',''1'',biasDefault}'));
end

function coordinate = quantizedRegularCoordinate()
coordinate = 289.816514+(0:518)'.*3.9;
coordinate = arrayfun(@(value)str2double(sprintf('%.9g',value)),coordinate);
end

function signal = deterministicRedSignal(n)
index = (1:n)';
innovation = sin(index*12.9898)*43758.5453;
innovation = innovation-floor(innovation)-0.5;
signal = filter(1,[1 -0.65],innovation);
end

function closeFigure(figureHandle)
if ~isempty(figureHandle) && isgraphics(figureHandle)
    delete(figureHandle);
end
end

function disableSpectrumSwa(gui)
swa = findall(gui,'Text','Smoothed Window Averages');
if ~isempty(swa)
    swa.Value = false;
end
end

function selectSpectrumMethod(gui,methodName)
method = findall(gui,'Tag','spectrumMethodDropdown');
assert(isscalar(method));
method.Value = methodName;
invokeUiCallback(method,'ValueChangedFcn');
end

function selectSpectrumRadio(radio)
assert(isscalar(radio));
group = radio.Parent;
if isprop(group,'SelectedObject')
    group.SelectedObject = radio;
    invokeUiCallback(group,'SelectionChangedFcn');
else
    radio.Value = true;
    invokeUiCallback(radio,'ValueChangedFcn');
end
end

function setSpectrumCheckbox(checkbox,value)
assert(isscalar(checkbox));
checkbox.Value = value;
invokeUiCallback(checkbox,'ValueChangedFcn');
end

function setSpectrumMaximumFrequency(gui,value)
nyquist = findall(gui,'Tag','spectrumFmaxNyquistRadio');
inputMode = findall(gui,'Tag','spectrumFmaxInputRadio');
fmaxField = findall(gui,'Tag','spectrumFmaxInputField');
assert(isscalar(nyquist));
assert(isscalar(inputMode));
assert(isscalar(fmaxField));
selectSpectrumRadio(inputMode);
setNumericUiValue(fmaxField,value);
assert(~nyquist.Value && inputMode.Value);
end

function selectSpectrumNyquist(gui)
nyquist = findall(gui,'Tag','spectrumFmaxNyquistRadio');
assert(isscalar(nyquist));
selectSpectrumRadio(nyquist);
end

function setExactSpectrumNfft(gui,nfft)
exact = findall(gui,'Tag','spectrumPaddingExactRadio');
field = findall(gui,'Tag','spectrumPaddingExactField');
assert(isscalar(exact));
assert(isscalar(field));
setNumericUiValue(field,nfft);
selectSpectrumRadio(exact);
end

function value = numericUiValue(control)
value = control.Value;
if ischar(value) || isstring(value)
    value = str2double(value);
end
end

function setNumericUiValue(control,value)
if ischar(control.Value) || isstring(control.Value)
    if ischar(value) || (isstring(value) && isscalar(value))
        control.Value = char(value);
    else
        control.Value = num2str(value,'%.15g');
    end
else
    control.Value = value;
end
invokeUiCallback(control,'ValueChangedFcn');
end

function invokeUiCallback(control,propertyName)
callback = control.(propertyName);
if isempty(callback)
    return
end
if isa(callback,'function_handle')
    callback(control,[]);
elseif iscell(callback)
    feval(callback{1},control,[],callback{2:end});
else
    eval(callback);
end
end

function [recordAlert,getAlerts] = spectrumAlertRecorder()
alerts = cell(0,2);
recordAlert = @record;
getAlerts = @getRecorded;

    function record(~,message,title,varargin) %#ok<INUSD>
        alerts(end+1,:) = {char(title),char(message)};
    end

    function value = getRecorded()
        value = alerts;
    end
end

function [result,power,ax] = runSpectrumResult(gui,buttonTag)
invokeSpectrumButton(gui,buttonTag);
drawnow;
results = findall(groot,'Type','figure','Tag','spectrumResultFigure');
assert(isscalar(results));
result = results;
power = findall(result,'Type','line','DisplayName','Power');
assert(isscalar(power));
ax = ancestor(power,'axes');
assert(isscalar(ax));
end

function [frequency,power] = expectedPeriodogram(context,nfft)
x = context.current_data(:,1);
y = context.current_data(:,2)-mean(context.current_data(:,2));
[power,frequency] = periodogram(y,[],nfft,1/median(diff(x)));
keep = isfinite(frequency) & isfinite(power) & ...
    frequency >= 0 & frequency <= 1/(2*median(diff(x)));
frequency = real(frequency(keep));
power = real(power(keep));
end

function [recommended,fitMaximum] = ...
        expectedBiasRecommendation(coordinate,values)
dt = median(diff(coordinate));
physicalNyquist = 1/(2*dt);
values = values-mean(values,'omitnan');
[power,angularFrequency] = periodogram(values);
frequency = angularFrequency/(2*pi*dt);
totalPower = sum(power);
if ~(isfinite(totalPower) && totalPower > 0)
    recommended = false;
    fitMaximum = physicalNyquist;
    return
end
index = find(cumsum(power) >= 0.99*totalPower,1,'first');
fitMaximum = min(frequency(index),physicalNyquist);
recommended = fitMaximum/frequency(end) <= 0.85;
end

function invokeSpectrumButton(gui,tag)
button = findall(gui,'Tag',tag);
assert(isscalar(button));
callback = button.ButtonPushedFcn;
callback(button,[]);
end

function closeTaggedSpectrumResults()
tags = {'spectrumResultFigure','spectrumFtestFigure', ...
    'spectrumFtestDiagnosticsFigure','spectrumSwaFigure', ...
    'spectrumSwaOptionsFigure'};
figures = gobjects(0);
for tagIndex = 1:numel(tags)
    figures = [figures;findall(groot,'Type','figure', ...
        'Tag',tags{tagIndex})]; %#ok<AGROW>
end
for index = 1:numel(figures)
    if isgraphics(figures(index))
        delete(figures(index));
    end
end
end

function removeDirectory(directory)
if isfolder(directory)
    rmdir(directory,'s');
end
end

function answer = unexpectedSmoothingPrompt()
answer = []; %#ok<NASGU>
error('Acycle:SpectrumTest:UnexpectedPrompt', ...
    'Robust smoothing was requested while Robust AR(1) was disabled.');
end
