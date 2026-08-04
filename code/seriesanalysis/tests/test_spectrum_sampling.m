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

function coordinate = quantizedRegularCoordinate()
coordinate = 289.816514+(0:518)'.*3.9;
coordinate = arrayfun(@(value)str2double(sprintf('%.9g',value)),coordinate);
end

function closeFigure(figureHandle)
if ~isempty(figureHandle) && isgraphics(figureHandle)
    delete(figureHandle);
end
end
