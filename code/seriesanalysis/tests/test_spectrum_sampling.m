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
end

function testRobustAr1UsesSelectedMtmSmoothingFraction(testCase)
closeTaggedSpectrumResults();
coordinate = (0:127)';
context = struct( ...
    'current_data',[coordinate,deterministicRedSignal(numel(coordinate))], ...
    'data_name','robust-mtm.txt', ...
    'unit','m', ...
    'SpectrumTestHooks',struct( ...
    'RobustSmoothingPromptFcn',@()0.1));
gui = spectrum(context);
testCase.addTeardown(@()closeFigure(gui));
testCase.addTeardown(@()closeTaggedSpectrumResults());
gui.Visible = 'off';
disableSpectrumSwa(gui);
invokeSpectrumButton(gui,'spectrumRunButton');
drawnow;

result = findall(groot,'Type','figure','Tag','spectrumResultFigure');
verifyNumElements(testCase,result,1);
verifyEqual(testCase, ...
    getappdata(result,'SpectrumRobustSmoothingFraction'),0.1,'AbsTol',0);
smoothed = findall(result,'Type','line','DisplayName','10% median-smoothed');
verifyNumElements(testCase,smoothed,1);

signal = context.current_data(:,2)-mean(context.current_data(:,2));
[~,~,expected] = redconfML(signal,1,2,numel(signal),2,0.1,0.5,0);
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
    'RobustSmoothingPromptFcn',@()0.1, ...
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

function testRobustPromptRetainsOriginalTwentyPercentDefault(testCase)
source = fileread(which('spectrum'));
verifyNotEmpty(testCase,strfind(source, ...
    'Median smoothing window: default 0.2 = 20%'));
verifyNotEmpty(testCase,strfind(source, ...
    '''Robust AR(1) Estimation'',1,{''0.2''}'));
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

function invokeSpectrumButton(gui,tag)
button = findall(gui,'Tag',tag);
assert(isscalar(button));
callback = button.ButtonPushedFcn;
callback(button,[]);
end

function closeTaggedSpectrumResults()
figures = findall(groot,'Type','figure','Tag','spectrumResultFigure');
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
