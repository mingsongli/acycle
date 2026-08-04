function tests = test_bispectral_io
%TEST_BISPECTRAL_IO Regression tests for transactional output behavior.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
toolboxDirectory = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
addpath(toolboxDirectory);
testCase.addTeardown(@()path(oldPath));
end

function testFailedWriterLeavesNoPartialResultGroup(testCase)
outputDirectory = tempname;
mkdir(outputDirectory);
cleanup = onCleanup(@()removeFolder(outputDirectory));

n = 192;
coordinate = (0:n-1)';
signal = sin(2*pi*coordinate/23)+0.3*cos(2*pi*coordinate/11);
result = bispectralAnalyze([coordinate signal]);
fig = bispectralPlot(result,'Visible','off','Quantity','bicoherence-squared');
figureCleanup = onCleanup(@()closeFigure(fig));

% The PDF, FIG and MAT writers run before writematrix. A deliberately
% invalid matrix therefore exercises rollback after several successful
% temporary writes.
result.ProcessedData = struct('invalidForWriteMatrix',true);
didThrow = false;
try
    bispectralSave(result,fig,outputDirectory,'rollback-check');
catch
    didThrow = true;
end

verifyTrue(testCase,didThrow);
entries = dir(outputDirectory);
entries = entries(~ismember({entries.name},{'.','..'}));
verifyEmpty(testCase,entries, ...
    'A failed save must not leave final files or a temporary directory.');
end

function testEachSaveCreatesOneUniqueResultFolder(testCase)
outputDirectory = tempname;
mkdir(outputDirectory);
cleanup = onCleanup(@()removeFolder(outputDirectory));

n = 192;
coordinate = (0:n-1)';
signal = sin(2*pi*coordinate/23)+0.3*cos(2*pi*coordinate/11);
result = bispectralAnalyze([coordinate signal]);
result.InputName = 'folder-check.txt';
result.ExternalPreprocessing = struct( ...
    'PerformedOutsideBispectralGUI',true, ...
    'Description','unit-test external preparation metadata');
fig = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared', ...
    'BispectrumKeepStrongestFraction',0.45, ...
    'BicoherenceKeepStrongestFraction',0.35, ...
    'ColorGrid',17,'FrequencyMinimum',0.02,'FrequencyMaximum',0.20, ...
    'ReferencePeriods',[8 13], ...
    'FrequencyPairs',[0.05 0.08;0.11 0.14], ...
    'ShowPeriodAxes',false,'PeakCount',0, ...
    'ShowSignificance',false);
figureCleanup = onCleanup(@()closeFigure(fig));
renderSettings = getappdata(fig,'BispectralRenderSettings');
verifyTrue(testCase,isstruct(renderSettings) && isscalar(renderSettings));
verifyEqual(testCase,renderSettings.Quantity,'bicoherence-squared');
verifyEqual(testCase,renderSettings.FrequencyPairs,[0.05 0.08;0.11 0.14]);
verifyNotEqual(testCase,result.Options.PlotQuantity,renderSettings.Quantity, ...
    'The fixture must exercise plot overrides that differ from result.Options.');

first = bispectralSave(result,fig,outputDirectory,'folder-check.txt');
second = bispectralSave(result,fig,outputDirectory,'folder-check.txt');
verifyNotEqual(testCase,first.Directory,second.Directory);
verifyTrue(testCase,isfolder(first.Directory));
verifyTrue(testCase,isfolder(second.Directory));
verifyEqual(testCase,string({dir(outputDirectory).name}), ...
    [".","..","folder-check-bispectral-1","folder-check-bispectral-2"]);

firstStem = "folder-check-bispectral-1";
secondStem = "folder-check-bispectral-2";
verifyEqual(testCase,folderFileNames(first.Directory), ...
    expectedArtifactNames(firstStem));
verifyEqual(testCase,folderFileNames(second.Directory), ...
    expectedArtifactNames(secondStem));
fileFields = {'PDF','FIG','MAT','ProcessedCSV','ConfigJSON'};
for ii = 1:numel(fileFields)
    verifyTrue(testCase,isfile(first.(fileFields{ii})));
    verifyEqual(testCase,fileparts(first.(fileFields{ii})),first.Directory);
end

saved = load(first.MAT,'result');
verifyTrue(testCase,isfield(saved.result,'RenderSettings'));
verifyEqual(testCase,saved.result.RenderSettings,renderSettings);
configuration = jsondecode(fileread(first.ConfigJSON));
verifyTrue(testCase,isfield(configuration,'RenderSettings'));
expectedRenderSettings = jsondecode(jsonencode(renderSettings));
verifyEqual(testCase,configuration.RenderSettings,expectedRenderSettings);
verifyTrue(testCase,isfield(configuration,'ExternalPreprocessing'));
verifyTrue(testCase,configuration.ExternalPreprocessing.PerformedOutsideBispectralGUI);
verifyEqual(testCase,configuration.Significance.NumSurrogates, ...
    result.Significance.NumSurrogates);
verifyEqual(testCase,configuration.Significance.IAAFTSpectralTolerance, ...
    result.Significance.IAAFTSpectralTolerance);
verifyEqual(testCase,configuration.Significance.SurrogateAttemptCount, ...
    result.Significance.SurrogateAttemptCount);
verifyEqual(testCase,configuration.Significance.MultipleComparisonControl,'none');
verifyEqual(testCase,configuration.Significance.InferenceFamily,'none');
verifyEqual(testCase,configuration.Significance.InferenceFamilyTriadCount,0);
verifyEqual(testCase,configuration.Significance.InferenceFamilyDefinition,'none');
verifyFalse(testCase, ...
    configuration.Significance.FrequencyViewLimitsAffectInferenceFamily);
verifyEqual(testCase,string(first.PDF), ...
    fullfile(string(first.Directory),firstStem+".pdf"));
verifyEqual(testCase,string(first.FIG), ...
    fullfile(string(first.Directory),firstStem+".fig"));
verifyEqual(testCase,string(first.MAT), ...
    fullfile(string(first.Directory),firstStem+".mat"));
verifyEqual(testCase,string(first.ProcessedCSV), ...
    fullfile(string(first.Directory),firstStem+"-preprocessed.csv"));
verifyEqual(testCase,string(first.ConfigJSON), ...
    fullfile(string(first.Directory),firstStem+"-config.json"));
verifyVectorPDFWhenToolsAreAvailable(testCase,first.PDF, ...
    ["folder-check" "frequency"]);
end

function testInvalidValidationDirectoryFailsBeforeAnalysis(testCase)
outputDirectory = tempname;
cleanup = onCleanup(@()removeFolder(outputDirectory));
missingDirectory = fullfile(tempdir,'acycle-bispectral-missing-data-directory');

verifyError(testCase,@()bispectralValidateExamples(outputDirectory, ...
    'DataDirectory',missingDirectory), ...
    'Acycle:Bispectral:MissingValidationDataDirectory');
end

function testGlobalSaveJSONRecordsPlusOneFWERFamily(testCase)
outputDirectory = tempname;
mkdir(outputDirectory);
cleanup = onCleanup(@()removeFolder(outputDirectory));

n = 128;
coordinate = (0:n-1)';
signal = sin(2*pi*coordinate/19)+0.35*sin(2*pi*coordinate/7) ...
    +0.08*cos(2*pi*coordinate/29);
data = [coordinate signal];
options = bispectralDefaults(data);
options.InputPolicy = 'strict';
options.Interpolate = 'never';
options.DetrendMethod = 'none';
options.Standardize = false;
options.NumSegments = 3;
options.OverlapPercent = 0;
options.MaxFrequencyBins = 16;
options.SignificanceMethod = 'surrogate-global';
options.SurrogateType = 'phase';
options.NumSurrogates = 19;
options.MaxSurrogateAttempts = 19;
options.RandomSeed = 8417;
options.PlotQuantity = 'bicoherence-squared';
options.PlotPeakCount = 0;
options.ShowPeriodAxes = false;
options.InputName = 'global-json-check.txt';
result = bispectralAnalyze(data,options);

verifyFalse(testCase, ...
    result.Significance.FrequencyViewLimitsAffectInferenceFamily);
verifyEqual(testCase,result.Significance.Threshold, ...
    max(result.Significance.SurrogateMaxima),'AbsTol',0, ...
    ['At 95% with M=19, the plus-one decision can reject only above every ', ...
     'surrogate maximum.']);
verifyTrue(testCase,contains(result.Significance.ThresholdComparison, ...
    'strictly greater','IgnoreCase',true));

fig = bispectralPlot(result,'Visible','off', ...
    'Quantity','bicoherence-squared','ShowPeriodAxes',false, ...
    'PeakCount',0);
figureCleanup = onCleanup(@()closeFigure(fig));
verifyEqual(testCase,fig.Name,'global-json-check: bispectral analysis');
files = bispectralSave(result,fig,outputDirectory,options.InputName);
verifyEqual(testCase,files.Directory, ...
    fullfile(outputDirectory,'global-json-check-bispectral-1'));
configuration = jsondecode(fileread(files.ConfigJSON));

verifyEqual(testCase,configuration.Significance.MultipleComparisonControl, ...
    'maximum-statistic family-wise error rate (FWER)');
verifyEqual(testCase,configuration.Significance.InferenceFamily, ...
    result.Significance.InferenceFamilyDefinition);
verifyEqual(testCase,configuration.Significance.InferenceFamilyDefinition, ...
    result.Significance.InferenceFamilyDefinition);
verifyEqual(testCase,configuration.Significance.InferenceFamilyTriadCount, ...
    result.Significance.InferenceFamilyTriadCount);
verifyEqual(testCase,configuration.Significance.InferenceFamilyTriadCount, ...
    nnz(result.ValidMask));
verifyEqual(testCase,configuration.Significance.Threshold, ...
    result.Significance.Threshold,'AbsTol',0);
verifyTrue(testCase,contains(configuration.Significance.ThresholdComparison, ...
    'strictly greater','IgnoreCase',true));
verifyFalse(testCase, ...
    configuration.Significance.FrequencyViewLimitsAffectInferenceFamily);
end

function testValidationRegularizationChainRebuildsSubToleranceJitter(testCase)
n = 96;
coordinate = (0:n-1)';
coordinate(2:2:end) = coordinate(2:2:end)+1e-3;
signal = sin(2*pi*coordinate/19)+0.25*cos(2*pi*coordinate/7);
data = [coordinate signal];

autoOptions = bispectralDefaults(data);
autoOptions.InputPolicy = 'prepare';
autoOptions.Interpolate = 'auto';
autoOptions.DetrendMethod = 'none';
autoOptions.Standardize = false;
[~,autoMeta] = bispectralPreprocess(data,autoOptions);
verifyLessThan(testCase,autoMeta.RelativeSpacingDeparture, ...
    autoOptions.IrregularTolerance);
verifyFalse(testCase,autoMeta.WasInterpolated, ...
    'This fixture must exercise jitter that auto would leave untouched.');

prepareOptions = autoOptions;
prepareOptions.Interpolate = 'always';
[regular,prepareMeta] = bispectralPreprocess(data,prepareOptions);
verifyTrue(testCase,prepareMeta.WasInterpolated);
verifyLessThanOrEqual(testCase,max(abs(diff(regular(:,1))- ...
    prepareMeta.SampleInterval)),128*eps(max(abs(regular(:,1)))));

strictOptions = bispectralDefaults(regular);
strictOptions.InputPolicy = 'strict';
strictOptions.Interpolate = 'never';
strictOptions.DetrendMethod = 'none';
strictOptions.Standardize = false;
[strict,strictMeta] = bispectralPreprocess(regular,strictOptions);
verifyEqual(testCase,strict,regular,'AbsTol',0);
verifyFalse(testCase,strictMeta.WasInterpolated);
end

function testStrictPolicyAcceptsSerializationJitterWithinTenPpm(testCase)
coordinate = 289.816514+(0:518)'.*3.9;
coordinate = arrayfun(@(value)str2double(sprintf('%.9g',value)),coordinate);
signal = sin(2*pi*coordinate/97)+0.2*cos(2*pi*coordinate/41);
data = [coordinate signal];

options = bispectralDefaults(data);
options.InputPolicy = 'strict';
options.Interpolate = 'never';
options.DetrendMethod = 'none';
options.Standardize = false;
[processed,meta] = bispectralPreprocess(data,options);

verifyEqual(testCase,processed,data,'AbsTol',0);
verifyFalse(testCase,meta.WasInterpolated);
verifyTrue(testCase,meta.AcceptedNearUniformSpacing);
verifyEqual(testCase,meta.StrictSpacingRelativeTolerance,1e-5,'AbsTol',0);
verifyLessThan(testCase,meta.RelativeSpacingDeparture, ...
    meta.StrictSpacingRelativeTolerance);
verifyGreaterThan(testCase,meta.MaximumSpacingError, ...
    meta.StrictSpacingRoundoffTolerance);
verifyEqual(testCase,meta.MaximumSpacingError,4.0000000467443897e-6, ...
    'RelTol',1e-8);
end

function testStrictPolicyRejectsSpacingBeyondTenPpm(testCase)
dt = 3.9;
coordinate = (0:127)'.*dt;
coordinate(64) = coordinate(64)+11e-6*dt;
signal = sin(2*pi*coordinate/97);
data = [coordinate signal];

options = bispectralDefaults(data);
options.InputPolicy = 'strict';
options.Interpolate = 'never';
options.DetrendMethod = 'none';
options.Standardize = false;

verifyError(testCase,@()bispectralPreprocess(data,options), ...
    'Acycle:Bispectral:StrictUnevenSampling');
end

function testStrictTenPpmLimitSurvivesScaleAndOffset(testCase)
largeOffset = 1e12+(0:127)';
largeOffset(64) = largeOffset(64)+1e-3;
verifyStrictUnevenError(testCase,largeOffset);

smallDt = 1e-10;
smallSpacing = (0:127)'.*smallDt;
smallSpacing(64) = smallSpacing(64)+11e-6*smallDt;
verifyStrictUnevenError(testCase,smallSpacing);
end

function verifyStrictUnevenError(testCase,coordinate)
signal = sin((0:numel(coordinate)-1)'/17);
data = [coordinate signal];
options = bispectralDefaults(data);
options.InputPolicy = 'strict';
options.Interpolate = 'never';
options.DetrendMethod = 'none';
options.Standardize = false;
verifyError(testCase,@()bispectralPreprocess(data,options), ...
    'Acycle:Bispectral:StrictUnevenSampling');
end

function closeFigure(fig)
if ~isempty(fig) && isgraphics(fig)
    close(fig);
end
end

function removeFolder(folder)
if isfolder(folder)
    rmdir(folder,'s');
end
end

function names = folderFileNames(folder)
entries = dir(folder);
entries = entries(~[entries.isdir]);
names = sort(string({entries.name}));
end

function names = expectedArtifactNames(stem)
stem = string(stem);
names = sort([stem+".pdf",stem+".fig",stem+".mat", ...
    stem+"-preprocessed.csv",stem+"-config.json"]);
end

function verifyVectorPDFWhenToolsAreAvailable(testCase,path,expectedText)
% Poppler provides structural checks that cannot be inferred reliably from
% compressed PDF bytes. Keep the unit test portable: run each assertion
% whenever its command is on PATH, and leave MATLAB-only installations to
% the exporter's own vector-content regression coverage.
fileId = fopen(path,'r');
verifyGreaterThanOrEqual(testCase,fileId,0,sprintf('Cannot read %s.',path));
fileCleanup = onCleanup(@()fclose(fileId));
bytes = fread(fileId,Inf,'*uint8')';
pdfText = char(bytes);
verifyTrue(testCase,startsWith(pdfText,'%PDF-'));
verifyEmpty(testCase,regexp(pdfText,'/Subtype\s*/Image','once'), ...
    ['The archival PDF contains an Image XObject; the saved color fields ', ...
     'must remain true vector polygons.']);
if commandIsAvailable('pdffonts')
    [status,output] = system(sprintf('pdffonts %s',shellQuote(path)));
    verifyEqual(testCase,status,0,sprintf('pdffonts failed:\n%s',output));
    rows = toolTableRows(output);
    verifyGreaterThanOrEqual(testCase,numel(rows),1, ...
        'A vector PDF must retain at least one embedded or referenced font.');
end
if commandIsAvailable('pdftotext')
    [status,output] = system(sprintf('pdftotext %s -',shellQuote(path)));
    verifyEqual(testCase,status,0,sprintf('pdftotext failed:\n%s',output));
    for ii = 1:numel(expectedText)
        verifyTrue(testCase,contains(output,expectedText(ii), ...
            'IgnoreCase',true),sprintf( ...
            'Extracted PDF text did not contain "%s".',expectedText(ii)));
    end
end
if commandIsAvailable('pdfimages')
    [status,output] = system(sprintf('pdfimages -list %s',shellQuote(path)));
    verifyEqual(testCase,status,0,sprintf('pdfimages failed:\n%s',output));
    verifyEmpty(testCase,toolTableRows(output), ...
        ['The archival PDF must be fully vector: pdfimages reported one ', ...
         'or more Image XObjects.']);
end
end

function yes = commandIsAvailable(command)
[status,~] = system(sprintf('command -v %s >/dev/null 2>&1',command));
yes = status == 0;
end

function quoted = shellQuote(path)
% POSIX single-quote escaping keeps generated temp paths literal.
quoted = ['''',strrep(char(path),'''','''"''"'''),''''];
end

function rows = toolTableRows(output)
lines = splitlines(string(output));
separator = find(startsWith(strtrim(lines),"---"),1,'first');
if isempty(separator)
    rows = strings(0,1);
    return
end
rows = strtrim(lines(separator+1:end));
rows = rows(strlength(rows) > 0);
end
