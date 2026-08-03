function validation = bispectralValidateExamples(outputDirectory,varargin)
%BISPECTRALVALIDATEEXAMPLES Reproducible five-dataset validation run.
%   VALIDATION = BISPECTRALVALIDATEEXAMPLES(OUTPUTDIRECTORY) analyzes a
%   known quadratic phase-coupling signal, an AR(1) negative control, and
%   three real paleoclimate/geological records: Newark, Site 1262, and the
%   public LR04 benthic oxygen-isotope stack. Each run saves PDF/FIG/MAT/
%   CSV/JSON plus a combined validation summary.
%
%   Name/value options:
%     DataDirectory  folder containing the requested Newark/Site 1262 files;
%                    required unless both files are in pwd or data/Examples
%     NumSurrogates  maximum-statistic IAAFT surrogates (default 199)
%     IAAFTIterations iteration cap per surrogate (default 200)
%     IAAFTSpectralTolerance accepted relative amplitude error (default 0.02)
%     RandomSeed     base deterministic seed (default 20260801)
%     Visible        figure visibility, on or off (default off)

if nargin < 1 || isempty(outputDirectory)
    outputDirectory = fullfile(pwd,'bispectral-validation');
end
settings = struct( ...
    'DataDirectory','', ...
    'NumSurrogates',199, ...
    'IAAFTIterations',200, ...
    'IAAFTSpectralTolerance',0.02, ...
    'RandomSeed',20260801, ...
    'Visible','off');
settings = parseSettings(settings,varargin{:});
validateSettings(settings);
if ~isfolder(outputDirectory)
    [ok,message] = mkdir(outputDirectory);
    if ~ok, error('Acycle:Bispectral:ValidationDirectory','%s',message); end
end

toolboxDirectory = fileparts(mfilename('fullpath'));
repositoryRoot = fileparts(fileparts(fileparts(toolboxDirectory)));
ar1Path = fullfile(repositoryRoot,'data','Examples','Example-Rednoise0.7-2000.txt');
lr04Path = fullfile(repositoryRoot,'data','Examples','LR04stack5320ka.txt');
newarkFile = 'newark2km-s-rsp0.85.txt';
xrfFile = '1262XRF-Fe-log10-s.u.-111-170-10-rLOESS-dpks-0.5_0.4.txt';
settings.DataDirectory = resolveDataDirectory( ...
    settings.DataDirectory,repositoryRoot,newarkFile,xrfFile);
newarkPath = fullfile(settings.DataDirectory,newarkFile);
xrfPath = fullfile(settings.DataDirectory,xrfFile);
required = {ar1Path,newarkPath,xrfPath,lr04Path};
for ii = 1:numel(required)
    if ~isfile(required{ii})
        error('Acycle:Bispectral:MissingValidationData', ...
            'Validation input not found: %s',required{ii});
    end
end

oldRng = rng;
cleanupRng = onCleanup(@()rng(oldRng));
rng(settings.RandomSeed,'twister');
[synthetic,syntheticTruth] = knownCouplingSignal();
syntheticSource = fullfile(outputDirectory,sprintf( ...
    'synthetic-qpc-source-seed%d.csv',settings.RandomSeed));
if ~isfile(syntheticSource)
    writematrix(synthetic,syntheticSource);
end

datasets = struct( ...
    'Label',{'Synthetic QPC positive control','AR(1) 0.7 negative control', ...
        'Newark 2-km record','Site 1262 XRF-Fe','LR04 benthic d18O stack'}, ...
    'BaseName',{'synthetic-qpc','ar1-rednoise-0.7','newark2km-rsp0.85', ...
        'site1262-xrf-fe','lr04-benthic-d18o'}, ...
    'Path',{syntheticSource,ar1Path,newarkPath,xrfPath,lr04Path}, ...
    'Unit',{'sample','sample','m','m','kyr'}, ...
    'Data',{synthetic,readNumeric(ar1Path),readNumeric(newarkPath),readNumeric(xrfPath), ...
        readNumeric(lr04Path)}, ...
    'Segments',{16,7,7,7,7}, ...
    'Overlap',{0,50,50,50,50}, ...
    'WholeDetrend',{'none','linear','linear','linear','linear'}, ...
    'SegmentDetrend',{'mean','linear','linear','linear','linear'});

summary = repmat(struct(),numel(datasets),1);
saved = cell(numel(datasets),1);
boundedChecks = false(numel(datasets),1);
phaseMaskChecks = false(numel(datasets),1);
artifactChecks = false(numel(datasets),1);
familyChecks = false(numel(datasets),1);
for ii = 1:numel(datasets)
    item = datasets(ii);
    fprintf('Bispectral validation %d/%d: %s\n',ii,numel(datasets),item.Label);
    options = bispectralDefaults(item.Data);
    options.InputPolicy = 'prepare';
    options.Estimator = 'wosa';
    options.NumSegments = item.Segments;
    options.OverlapPercent = item.Overlap;
    options.Window = 'hann';
    options.DetrendMethod = item.WholeDetrend;
    options.SegmentDetrendMethod = item.SegmentDetrend;
    options.Standardize = true;
    options.Interpolate = 'auto';
    options.InterpolationMethod = 'linear';
    options.ZeroPaddingFactor = 1;
    options.MaxFrequencyBins = 256;
    options.SignificanceMethod = 'surrogate-global';
    options.ConfidenceLevel = 0.95;
    options.NumSurrogates = settings.NumSurrogates;
    options.SurrogateType = 'iaaft';
    options.IAAFTIterations = settings.IAAFTIterations;
    options.IAAFTSpectralTolerance = settings.IAAFTSpectralTolerance;
    options.RandomSeed = settings.RandomSeed+ii;
    options.InputName = item.Path;
    options.CoordinateUnit = item.Unit;
    options.PlotQuantity = 'overview';
    options.PlotPeakCount = 5;
    options.ShowPeriodAxes = true;

    result = bispectralAnalyze(item.Data,options);
    result.Validation = struct('Label',item.Label,'SourcePath',item.Path, ...
        'ExpectedSyntheticTriad',[]);
    if ii == 1
        result.Validation.ExpectedSyntheticTriad = syntheticTruth;
    end
    fig = bispectralPlot(result,'Visible',settings.Visible,'Quantity','overview');
    cleanupFigure = onCleanup(@()closeIfValid(fig));
    files = bispectralSave(result,fig,outputDirectory,item.BaseName);
    saved{ii} = files;

    validValues = result.BicoherenceSquared;
    validValues(~result.ValidMask) = NaN;
    [peakB2,peakLinear] = max(validValues(:),[],'omitnan');
    [peakRow,peakColumn] = ind2sub(size(validValues),peakLinear);
    summary(ii).Dataset = item.Label;
    summary(ii).Source = item.Path;
    summary(ii).OriginalN = size(item.Data,1);
    summary(ii).ProcessedN = size(result.ProcessedData,1);
    summary(ii).Interpolated = result.Preprocessing.WasInterpolated;
    summary(ii).SampleInterval = result.Preprocessing.SampleInterval;
    summary(ii).SegmentCount = result.Meta.SegmentCount;
    summary(ii).SegmentLength = result.Meta.SegmentLength;
    summary(ii).RayleighResolution = result.Meta.RayleighResolution;
    summary(ii).MaximumBicoherenceSquared = peakB2;
    summary(ii).PeakF1 = result.Frequency(peakColumn);
    summary(ii).PeakF2 = result.Frequency(peakRow);
    summary(ii).PeakF3 = summary(ii).PeakF1+summary(ii).PeakF2;
    summary(ii).GlobalThreshold = result.Significance.Threshold;
    summary(ii).SignificantTriadCount = nnz(result.SignificantMask);
    summary(ii).InferenceMethod = "IAAFT maximum-statistic FWER";
    summary(ii).FWERConfidenceLevel = result.Significance.ConfidenceLevel;
    summary(ii).InferenceFamily = string( ...
        result.Significance.InferenceFamilyDefinition);
    summary(ii).InferenceFamilyTriadCount = ...
        result.Significance.InferenceFamilyTriadCount;
    summary(ii).SurrogateType = string(result.Significance.SurrogateType);
    summary(ii).AcceptedSurrogates = result.Significance.NumSurrogates;
    summary(ii).IAAFTIterations = result.Options.IAAFTIterations;
    summary(ii).IAAFTSpectralTolerance = ...
        result.Significance.IAAFTSpectralTolerance;
    summary(ii).SurrogateAttempts = result.Significance.SurrogateAttemptCount;
    summary(ii).RejectedSurrogates = result.Significance.RejectedSurrogateCount;
    summary(ii).MaximumAcceptedIAAFTSpectralError = max( ...
        result.Significance.SurrogateSpectralErrors,[],'omitnan');
    summary(ii).RandomSeed = result.Significance.RandomSeed;
    summary(ii).PDF = files.PDF;
    summary(ii).FIG = files.FIG;
    finiteBicoherence = result.BicoherenceSquared(result.ValidMask);
    boundedChecks(ii) = all(finiteBicoherence >= -1e-14 & ...
        finiteBicoherence <= 1+1e-12);
    phaseMaskChecks(ii) = all(isnan(result.Biphase(result.InvalidDenominatorMask)));
    familyChecks(ii) = result.Significance.InferenceFamilyTriadCount == ...
        nnz(result.ValidMask) && contains( ...
        result.Significance.InferenceFamilyDefinition,'Fixed finite');
    fileFields = {'PDF','FIG','MAT','ProcessedCSV','ConfigJSON'};
    outputPaths = cellfun(@(name)files.(name),fileFields,'UniformOutput',false);
    [~,resultStem] = fileparts(files.Directory);
    expectedNames = sort(string({[resultStem,'.pdf'],[resultStem,'.fig'], ...
        [resultStem,'.mat'],[resultStem,'-preprocessed.csv'], ...
        [resultStem,'-config.json']}));
    artifactChecks(ii) = isfolder(files.Directory) && ...
        all(cellfun(@isNonemptyFile,outputPaths)) && ...
        isequal(folderFileNames(files.Directory),expectedNames);
    summary(ii).AllBicoherenceWithinBounds = boundedChecks(ii);
    summary(ii).InvalidBiphaseCellsAreNaN = phaseMaskChecks(ii);
    summary(ii).OutputFolderExactFiveNonempty = artifactChecks(ii);
    summary(ii).FixedFiniteInferenceFamily = familyChecks(ii);
    if ii == 1
        [~,targetColumn] = min(abs(result.Frequency-syntheticTruth.F1));
        [~,targetRow] = min(abs(result.Frequency-syntheticTruth.F2));
        summary(ii).KnownTriadBicoherenceSquared = ...
            result.BicoherenceSquared(targetRow,targetColumn);
        summary(ii).KnownTriadSignificant = result.SignificantMask(targetRow,targetColumn);
        summary(ii).KnownTriadF1Error = abs(result.Frequency(targetColumn)-syntheticTruth.F1);
        summary(ii).KnownTriadF2Error = abs(result.Frequency(targetRow)-syntheticTruth.F2);
        summary(ii).KnownTriadBiphase = result.Biphase(targetRow,targetColumn);
        summary(ii).KnownTriadBiphaseError = circularDistance( ...
            summary(ii).KnownTriadBiphase,syntheticTruth.ExpectedBiphase);
    else
        summary(ii).KnownTriadBicoherenceSquared = NaN;
        summary(ii).KnownTriadSignificant = false;
        summary(ii).KnownTriadF1Error = NaN;
        summary(ii).KnownTriadF2Error = NaN;
        summary(ii).KnownTriadBiphase = NaN;
        summary(ii).KnownTriadBiphaseError = NaN;
    end
    clear cleanupFigure
end

summaryTable = struct2table(summary);
summaryFile = fullfile(outputDirectory,'bispectral-validation-summary.csv');
writetable(summaryTable,summaryFile);
checks = struct( ...
    'KnownTriadBicoherenceAbove090',summary(1).KnownTriadBicoherenceSquared > 0.90, ...
    'KnownTriadGloballySignificant',logical(summary(1).KnownTriadSignificant), ...
    'KnownTriadFrequenciesRecovered',max(summary(1).KnownTriadF1Error, ...
        summary(1).KnownTriadF2Error) <= summary(1).RayleighResolution/2+eps, ...
    'KnownTriadBiphaseRecovered',summary(1).KnownTriadBiphaseError < 0.12, ...
    'KnownTriadIsStrongestPeak',abs(summary(1).PeakF1-syntheticTruth.F1) <= ...
        summary(1).RayleighResolution/2+eps && abs(summary(1).PeakF2-syntheticTruth.F2) <= ...
        summary(1).RayleighResolution/2+eps, ...
    'AR1HasNoGlobalSignificance',summary(2).SignificantTriadCount == 0, ...
    'AllBicoherenceWithinBounds',all(boundedChecks), ...
    'AllUndefinedBiphasesAreNaN',all(phaseMaskChecks), ...
    'AllInferenceFamiliesFixedAndFinite',all(familyChecks), ...
    'AllOutputFoldersExactFiveNonempty',all(artifactChecks));
passed = all(cell2mat(struct2cell(checks)));
reportFile = fullfile(outputDirectory,'bispectral-validation-report.txt');
writeReport(reportFile,summary,settings,syntheticTruth,checks,passed);
validation = struct('Passed',passed,'Checks',checks,'OutputDirectory',outputDirectory, ...
    'Summary',summaryTable,'SummaryFile',summaryFile,'ReportFile',reportFile, ...
    'SavedFiles',{saved},'SyntheticSource',syntheticSource, ...
    'Settings',settings);
fprintf('Bispectral validation complete: %s\n',outputDirectory);
if ~passed
    warning('Acycle:Bispectral:ValidationFailed', ...
        'One or more bispectral validation checks failed. Inspect %s.',reportFile);
end
end

function directory = resolveDataDirectory(requested,repositoryRoot,newarkFile,xrfFile)
directory = char(requested);
if ~isempty(directory)
    if ~isfolder(directory)
        error('Acycle:Bispectral:MissingValidationDataDirectory', ...
            'Validation DataDirectory does not exist: %s',directory);
    end
    return
end

candidates = {pwd,fullfile(repositoryRoot,'data','Examples')};
for ii = 1:numel(candidates)
    if isfile(fullfile(candidates{ii},newarkFile)) && ...
            isfile(fullfile(candidates{ii},xrfFile))
        directory = candidates{ii};
        return
    end
end
error('Acycle:Bispectral:ValidationDataDirectoryRequired', ...
    ['Pass DataDirectory containing both %s and %s. The AR(1) and LR04 ', ...
    'controls are bundled, but these two local research records are not.'], ...
    newarkFile,xrfFile);
end

function [data,truth] = knownCouplingSignal()
segmentLength = 256;
segmentCount = 16;
n = segmentLength*segmentCount;
t = (0:n-1)';
f1 = 30/segmentLength;
f2 = 17/segmentLength;
phaseOffset = 0.45;
y = zeros(n,1);
for segment = 1:segmentCount
    index = (segment-1)*segmentLength+(1:segmentLength);
    phase1 = 2*pi*rand;
    phase2 = 2*pi*rand;
    y(index) = cos(2*pi*f1*t(index)+phase1) ...
        +0.85*cos(2*pi*f2*t(index)+phase2) ...
        +0.65*cos(2*pi*(f1+f2)*t(index)+phase1+phase2+phaseOffset) ...
        +0.18*randn(segmentLength,1);
end
data = [t y];
truth = struct('F1',f1,'F2',f2,'F3',f1+f2, ...
    'ExpectedBiphase',-phaseOffset, ...
    'Construction','Segment-wise random phases with phi3=phi1+phi2+0.45');
end

function data = readNumeric(path)
try
    data = load(path);
catch
    data = readmatrix(path);
end
if ~isnumeric(data) || size(data,2) < 2
    error('Acycle:Bispectral:InvalidValidationData', ...
        'Expected at least two numeric columns: %s',path);
end
data = data(:,1:2);
end

function settings = parseSettings(settings,varargin)
if mod(numel(varargin),2) ~= 0
    error('Acycle:Bispectral:ValidationOptions','Use name/value validation options.');
end
names = fieldnames(settings);
for ii = 1:2:numel(varargin)
    index = find(strcmpi(char(varargin{ii}),names),1);
    if isempty(index)
        error('Acycle:Bispectral:ValidationOptions', ...
            'Unknown validation option: %s',char(varargin{ii}));
    end
    settings.(names{index}) = varargin{ii+1};
end
end

function validateSettings(settings)
positive = {'NumSurrogates','IAAFTIterations','IAAFTSpectralTolerance'};
for ii = 1:numel(positive)
    value = settings.(positive{ii});
    if ~(isnumeric(value) && isscalar(value) && isfinite(value) && value > 0)
        error('Acycle:Bispectral:ValidationOptions', ...
            '%s must be a positive finite scalar.',positive{ii});
    end
end
integers = {'NumSurrogates','IAAFTIterations','RandomSeed'};
for ii = 1:numel(integers)
    value = settings.(integers{ii});
    if ~(isnumeric(value) && isscalar(value) && isfinite(value) && ...
            value == round(value))
        error('Acycle:Bispectral:ValidationOptions', ...
            '%s must be a finite integer.',integers{ii});
    end
end
if settings.NumSurrogates < 19 || settings.NumSurrogates > 99999
    error('Acycle:Bispectral:ValidationOptions', ...
        'NumSurrogates must lie between 19 and 99999.');
end
if settings.IAAFTSpectralTolerance > 1
    error('Acycle:Bispectral:ValidationOptions', ...
        'IAAFTSpectralTolerance must lie in (0,1].');
end
if ~(ischar(settings.Visible) || (isstring(settings.Visible) && isscalar(settings.Visible))) || ...
        ~any(strcmpi(char(settings.Visible),{'on','off'}))
    error('Acycle:Bispectral:ValidationOptions', ...
        'Visible must be on or off.');
end
end

function writeReport(path,summary,settings,truth,checks,passed)
fileId = fopen(path,'w');
if fileId < 0
    error('Acycle:Bispectral:ValidationReport','Could not write %s.',path);
end
cleanup = onCleanup(@()fclose(fileId));
fprintf(fileId,'Acycle Bispectral Analysis - validation report\n');
fprintf(fileId,'Generated: %s\n',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')));
fprintf(fileId,'Inference: %d IAAFT max-statistic surrogates, 95%% FWER\n', ...
    settings.NumSurrogates);
fprintf(fileId,'IAAFT quality: %d iterations; accepted spectral error <= %.9g\n', ...
    settings.IAAFTIterations,settings.IAAFTSpectralTolerance);
fprintf(fileId,'Known QPC truth: f1=%.9g, f2=%.9g, f3=%.9g, biphase=%.9g rad\n\n', ...
    truth.F1,truth.F2,truth.F3,truth.ExpectedBiphase);
fprintf(fileId,'Overall validation passed: %d\n',passed);
checkNames = fieldnames(checks);
for checkIndex = 1:numel(checkNames)
    fprintf(fileId,'  %-40s %d\n',checkNames{checkIndex},checks.(checkNames{checkIndex}));
end
fprintf(fileId,'\n');
for ii = 1:numel(summary)
    row = summary(ii);
    fprintf(fileId,'%d. %s\n',ii,row.Dataset);
    fprintf(fileId,'   source: %s\n',row.Source);
    fprintf(fileId,'   N: %d -> %d; interpolated: %d; dt: %.9g\n', ...
        row.OriginalN,row.ProcessedN,row.Interpolated,row.SampleInterval);
    fprintf(fileId,'   peak: b^2=%.6f at (f1,f2,f3)=(%.9g,%.9g,%.9g)\n', ...
        row.MaximumBicoherenceSquared,row.PeakF1,row.PeakF2,row.PeakF3);
    fprintf(fileId,'   95%% global threshold: %.6f; significant triads: %d\n', ...
        row.GlobalThreshold,row.SignificantTriadCount);
    fprintf(fileId,['   inference: %s; accepted/attempted/rejected=%d/%d/%d; ', ...
        'max accepted spectral error=%.9g; seed=%d; family triads=%d\n'], ...
        char(row.SurrogateType),row.AcceptedSurrogates,row.SurrogateAttempts, ...
        row.RejectedSurrogates,row.MaximumAcceptedIAAFTSpectralError, ...
        row.RandomSeed,row.InferenceFamilyTriadCount);
    if ii == 1
        fprintf(fileId,'   known triad: b^2=%.6f; globally significant: %d\n', ...
            row.KnownTriadBicoherenceSquared,row.KnownTriadSignificant);
        fprintf(fileId,'   known biphase: %.6f rad; circular error: %.6g rad\n', ...
            row.KnownTriadBiphase,row.KnownTriadBiphaseError);
    end
    fprintf(fileId,'   PDF: %s\n   FIG: %s\n\n',row.PDF,row.FIG);
end
fprintf(fileId,['Interpretation guardrail: significant bicoherence means stable quadratic ', ...
    'phase coupling, not proof of causality or physical energy transfer.\n']);
clear cleanup
end

function distance = circularDistance(a,b)
distance = abs(angle(exp(1i*(a-b))));
end

function tf = isNonemptyFile(path)
information = dir(path);
tf = isfile(path) && ~isempty(information) && information(1).bytes > 0;
end

function names = folderFileNames(folder)
entries = dir(folder);
entries = entries(~[entries.isdir]);
names = sort(string({entries.name}));
end

function closeIfValid(fig)
if ~isempty(fig) && isgraphics(fig,'figure')
    close(fig);
end
end
