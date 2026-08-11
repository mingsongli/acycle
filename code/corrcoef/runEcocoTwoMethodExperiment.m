function runSummary = runEcocoTwoMethodExperiment(outputRoot,varargin)
%RUNECOCOTWOMETHODEXPERIMENT Run the registered 6-data x 2-method eCOCO suite.
%
% RUNSUMMARY = RUNECOCOTWOMETHODEXPERIMENT(OUTPUTROOT) compares Adaptive
% eCOCO and Blocked eCOCO on six pre-registered records.  Each method
% calls the public ECOCO interface, retains the complete sedimentation-rate
% grid, and receives the tenth ECODETAILS output.  Method checkpoints are
% atomic and signature matched, so interrupted runs can be resumed.
%
% Default design:
%   * four-group coherent-nine targets through the published eCOCO methods
%   * N_MC = 2000, RED = 0, Pearson, seed = 1
%   * Blocked eCOCO target-anchor fraction = 0.5 window
%   * physical window = 2 * 405 kyr * registered rate / 100 metres
%   * sliding step = 0.5 window, rounded to the sampling grid
%   * fewer than 300 complete windows per case
%   * remove the full-record mean, then append one strict zero-valued
%     half-window to each data edge
%   * PAD = 2^nextpow2(number of samples in one complete window)
%
% Name-value options useful for tests and resumable production runs:
%   InputRoot, NSim, Seed, Red, Method, AnchorFraction, StepFraction,
%   MaxWindows, DatasetIDs, MethodIDs, Resume, ContinueOnError,
%   ExportFigures, CloseFigures, Visible, DatasetPlan, ShowProgress,
%   Verbose.  Verbose controls detailed ECOCO console output and defaults
%   to true for backward compatibility.
%
% DatasetPlan is intended primarily for tests.  A custom item must provide
% id, title, category, age_ma, sr1, sr2, srstep, windowRate, and either
% input_file or filename.  expectedWindows and reconstructSpacing are
% optional.

defaultInputRoot = ['/Users/mingsongli/Dropbox/Research/', ...
    '_通用方法火山构造波动/202606COCO/data_18/syn3'];
if nargin < 1 || strlength(string(outputRoot)) == 0
    outputRoot = fullfile(defaultInputRoot,'ECOCO_2method_results');
end
validateattributes(outputRoot,{'char','string'}, ...
    {'scalartext','nonempty'},mfilename,'outputRoot',1);

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'InputRoot',defaultInputRoot,@isScalarText);
addParameter(parser,'NSim',2000,@isNonnegativeInteger);
addParameter(parser,'Seed',1,@isSeed);
addParameter(parser,'Red',0,@isRedOption);
addParameter(parser,'Method','Pearson',@isScalarText);
addParameter(parser,'AnchorFraction',0.5,@isPositiveScalar);
addParameter(parser,'StepFraction',0.5,@isPositiveScalar);
addParameter(parser,'MaxWindows',299,@isPositiveInteger);
addParameter(parser,'MaxFrequencyScale',1.2,@isPositiveScalar);
addParameter(parser,'DatasetIDs',strings(0,1),@isTextList);
addParameter(parser,'MethodIDs',strings(0,1),@isTextList);
addParameter(parser,'Resume',true,@isLogicalScalar);
addParameter(parser,'ContinueOnError',true,@isLogicalScalar);
addParameter(parser,'ExportFigures',true,@isLogicalScalar);
addParameter(parser,'CloseFigures',true,@isLogicalScalar);
addParameter(parser,'Visible','off',@isScalarText);
addParameter(parser,'DatasetPlan',struct([]),@(x) isempty(x) || isstruct(x));
addParameter(parser,'ShowProgress',false,@isLogicalScalar);
addParameter(parser,'Verbose',true,@isLogicalScalar);
parse(parser,varargin{:});
options = parser.Results;
options.InputRoot = char(string(options.InputRoot));
options.Method = validatestring(char(string(options.Method)), ...
    {'Pearson','Spearman'},mfilename,'Method');
options.Visible = validatestring(char(string(options.Visible)),{'on','off'});
options.Resume = logical(options.Resume);
options.ContinueOnError = logical(options.ContinueOnError);
options.ExportFigures = logical(options.ExportFigures);
options.CloseFigures = logical(options.CloseFigures);
options.ShowProgress = logical(options.ShowProgress);
options.Verbose = logical(options.Verbose);
if options.AnchorFraction > 2
    error('runEcocoTwoMethodExperiment:AnchorFractionTooLarge', ...
        'AnchorFraction must not exceed two windows.');
end
if options.MaxFrequencyScale < 1
    error('runEcocoTwoMethodExperiment:MaximumFrequencyScaleTooSmall', ...
        'MaxFrequencyScale must be at least one.');
end
if options.MaxWindows >= 300
    error('runEcocoTwoMethodExperiment:TooManyWindows', ...
        'MaxWindows must be smaller than 300.');
end

if isempty(options.DatasetPlan)
    datasets = defaultDatasetPlan(options.InputRoot);
else
    datasets = normalizeDatasetPlan(options.DatasetPlan,options.InputRoot);
end
datasets = selectItems(datasets,options.DatasetIDs,'dataset');
methods = selectEcocoMethods(methodPlan(),options.MethodIDs);
options.MethodIDs = string({methods.id});
if isempty(datasets) || isempty(methods)
    error('runEcocoTwoMethodExperiment:EmptyPlan', ...
        'At least one dataset and one method must remain selected.');
end

outputRoot = canonicalPath(char(string(outputRoot)));
ensureDirectory(outputRoot);
previousVisibility = get(groot,'defaultFigureVisible');
visibilityCleanup = onCleanup(@()set(groot,'defaultFigureVisible', ...
    previousVisibility));
set(groot,'defaultFigureVisible',options.Visible);

manifestPath = fullfile(outputRoot,'manifest.json');
summaryPath = fullfile(outputRoot,'overall_summary.csv');
eventLogPath = fullfile(outputRoot,'run.log');
manifest = struct( ...
    'schema_version',2, ...
    'report_title',sprintf( ...
    'Adaptive and Blocked eCOCO: %d-data-set comparison', ...
    numel(datasets)), ...
    'created_at',timestampNow(), ...
    'updated_at',timestampNow(), ...
    'status','running', ...
    'output_root',outputRoot, ...
    'summary_csv','overall_summary.csv', ...
    'event_log','run.log', ...
    'options',publicOptions(options), ...
    'method_order',{string({methods.title})}, ...
    'cases',repmat(emptyCaseManifest(),0,1));
writeRootManifest(manifestPath,manifest);

caseManifests = repmat(emptyCaseManifest(),numel(datasets),1);
allRows = repmat(emptySummaryRow(),0,1);
fatalException = [];
for caseIndex = 1:numel(datasets)
    spec = datasets(caseIndex);
    try
        [caseManifests(caseIndex),caseRows] = runOneCase( ...
            spec,caseIndex,methods,outputRoot,options,eventLogPath);
        allRows = [allRows;caseRows(:)]; %#ok<AGROW>
    catch exception
        caseManifests(caseIndex) = failedCaseManifest( ...
            spec,caseIndex,outputRoot,exception);
        if ~options.ContinueOnError
            fatalException = exception;
        end
    end
    manifest.cases = caseManifests(1:caseIndex);
    manifest.updated_at = timestampNow();
    manifest.status = 'running';
    writeRootManifest(manifestPath,manifest);
    writeSummaryCsv(summaryPath,allRows);
    if ~isempty(fatalException)
        break
    end
end

manifest.cases = caseManifests;
manifest.updated_at = timestampNow();
manifest.status = overallStatus(caseManifests);
writeSummaryCsv(summaryPath,allRows);
writeRootManifest(manifestPath,manifest);
runSummary = manifest;
saveAtomic(fullfile(outputRoot,'run_summary.mat'), ...
    struct('runSummary',runSummary,'summaryRows',allRows));
clear visibilityCleanup
if ~isempty(fatalException)
    rethrow(fatalException)
end
end

function [caseManifest,summaryRows] = runOneCase( ...
        spec,index,methods,outputRoot,options,eventLogPath)
inputFile = resolveInputFile(spec,options.InputRoot);
inputHash = sha256File(inputFile);
[data,preprocessing] = prepareInput(inputFile,spec);
dt = median(diff(data(:,1)));
if ~isfinite(dt) || dt <= 0
    error('runEcocoTwoMethodExperiment:InvalidSpacing', ...
        '%s has no positive finite sampling interval.',inputFile);
end

orbitMatrix = calculate_orbit9(spec.age_ma);
orbit9 = orbitMatrix(:,2)/1000;
if numel(orbit9) ~= 9 || any(~isfinite(orbit9) | orbit9 <= 0)
    error('runEcocoTwoMethodExperiment:InvalidOrbitPeriods', ...
        'calculate_orbit9 did not return nine positive periods.');
end
maxFrequency = options.MaxFrequencyScale*max(1./orbit9);
windowRequested = 2*405*spec.windowRate/100;
nWindow = 2*round(windowRequested/(2*dt))+1;
if nWindow < 4
    error('runEcocoTwoMethodExperiment:WindowTooShort', ...
        '%s yields fewer than four points per complete window.',spec.title);
end
windowActual = (nWindow-1)*dt;
pad = 2^nextpow2(nWindow);
[analysisData,padding] = strictZeroHalfWindowPad(data,nWindow,dt);
stepSamplesRequested = max(1,round(options.StepFraction*windowActual/dt));
stepSamples = capWindowCount(size(analysisData,1),nWindow, ...
    stepSamplesRequested,options.MaxWindows);
stepDepth = stepSamples*dt;
lastStart = size(analysisData,1)-nWindow+1;
nSlidingWindows = numel(endpointInclusiveStarts(lastStart,stepSamples));
if nSlidingWindows >= 300
    error('runEcocoTwoMethodExperiment:WindowCapFailed', ...
        'Internal window cap failed: %d windows remain.',nSlidingWindows);
end

caseName = sprintf('%02d_%s',index,sanitizeFilename(spec.id));
caseDirectory = fullfile(outputRoot,caseName);
figureDirectory = fullfile(caseDirectory,'figures');
ensureDirectory(caseDirectory);
ensureDirectory(figureDirectory);
writeNumericCsvAtomic(fullfile(caseDirectory,'analysis_input.csv'), ...
    {'Depth_m','Value'},analysisData);

parameters = caseParameters(spec,inputFile,inputHash,data,analysisData, ...
    preprocessing,padding,dt,orbit9,windowRequested,windowActual,nWindow, ...
    stepSamplesRequested,stepSamples,stepDepth,nSlidingWindows,pad, ...
    maxFrequency,options);
writeParameterCsv(fullfile(caseDirectory,'parameters.csv'),parameters);
writeJsonAtomic(fullfile(caseDirectory,'parameters.json'),parameters);
saveAtomic(fullfile(caseDirectory,'parameters.mat'),struct( ...
    'spec',spec,'options',publicOptions(options),'orbitMatrix',orbitMatrix, ...
    'orbit9',orbit9,'preprocessing',preprocessing,'padding',padding, ...
    'parameters',parameters));

baseSignature = struct( ...
    'schema',2,'input_sha256',inputHash,'dataset_id',spec.id, ...
    'age_ma',spec.age_ma,'rate_grid',[spec.sr1,spec.sr2,spec.srstep], ...
    'window_rate',spec.windowRate,'window_requested',windowRequested, ...
    'window_actual',windowActual,'n_window',nWindow,'step_samples',stepSamples, ...
    'pad',pad,'nsim',options.NSim,'seed',options.Seed,'red',options.Red, ...
    'correlation_method',options.Method, ...
    'anchor_fraction',options.AnchorFraction, ...
    'maximum_frequency',maxFrequency, ...
    'newark_spacing',spec.reconstructSpacing);

summaryRows = repmat(emptySummaryRow(),numel(methods),1);
figures = repmat(emptyFigureEntry(),0,1);
methodManifests = repmat(emptyMethodManifest(),numel(methods),1);
for methodIndex = 1:numel(methods)
    task = methods(methodIndex);
    methodDirectory = fullfile(caseDirectory,task.folder);
    ensureDirectory(methodDirectory);
    signatureValue = baseSignature;
    signatureValue.method_id = task.id;
    signatureValue.engine_sha256 = engineFingerprint(task);
    signature = jsonencode(signatureValue);
    emitMethodEvent(eventLogPath,'START',spec.id,task.id,sprintf( ...
        'engine=%s nsim=%d',task.title,options.NSim));
    try
        [~,row,methodFigures,reused] = runOneMethod( ...
            task,analysisData,orbit9,windowActual,dt,stepSamples,pad, ...
            spec,maxFrequency,methodDirectory,figureDirectory,outputRoot, ...
            options,signature,data(:,1));
        summaryRows(methodIndex) = row;
        figures = [figures;methodFigures(:)]; %#ok<AGROW>
        methodManifests(methodIndex) = completeMethodManifest( ...
            task,methodDirectory,caseDirectory,row,methodFigures,reused);
        emitMethodEvent(eventLogPath,'END',spec.id,task.id,sprintf( ...
            'status=complete reused=%d',reused));
    catch exception
        summaryRows(methodIndex) = failedSummaryRow(spec,task,exception,options);
        methodManifests(methodIndex) = failedMethodManifest( ...
            task,methodDirectory,caseDirectory,exception);
        writeTextAtomic(fullfile(methodDirectory,'error.txt'), ...
            exceptionReport(exception));
        emitMethodEvent(eventLogPath,'ERROR',spec.id,task.id,sprintf( ...
            'identifier=%s message=%s', ...
            publicFailureText(exception.identifier), ...
            publicFailureText(exception.message)));
        if ~options.ContinueOnError
            rethrow(exception)
        end
    end
    writeSummaryCsv(fullfile(caseDirectory,'summary.csv'), ...
        summaryRows(1:methodIndex));
end

caseManifest = emptyCaseManifest();
caseManifest.id = spec.id;
caseManifest.title = spec.title;
caseManifest.category = spec.category;
caseManifest.expected_rate = spec.expected_rate;
caseManifest.age_ma = spec.age_ma;
caseManifest.input_file = inputFile;
caseManifest.input_sha256 = inputHash;
caseManifest.case_dir = caseName;
caseManifest.parameters_csv = fullfile(caseName,'parameters.csv');
caseManifest.parameters_json = fullfile(caseName,'parameters.json');
caseManifest.summary_csv = fullfile(caseName,'summary.csv');
caseManifest.figures = figures;
caseManifest.methods = methodManifests;
caseManifest.status = methodStatus(summaryRows);
caseManifest.updated_at = timestampNow();
writeJsonAtomic(fullfile(caseDirectory,'case_manifest.json'),caseManifest);
end

function [analysis,row,figureEntries,reused] = runOneMethod( ...
        task,data,orbit9,window,dt,stepSamples,pad,spec,maxFrequency, ...
        methodDirectory,figureDirectory,outputRoot,options,signature, ...
        originalDepth)
checkpointFile = fullfile(methodDirectory,'checkpoint.mat');
resultFile = fullfile(methodDirectory,'results.mat');
manifestFile = fullfile(methodDirectory,'result.json');
checkpoint = loadCheckpoint(checkpointFile);
reused = options.Resume && isfield(checkpoint,'status') && ...
    strcmp(checkpoint.status,'complete') && ...
    isfield(checkpoint,'signature') && strcmp(checkpoint.signature,signature) && ...
    isfile(resultFile) && isfile(manifestFile);
if reused
    saved = load(resultFile,'analysis','summary','figureEntries','signature');
    reused = isfield(saved,'signature') && strcmp(saved.signature,signature) && ...
        isfield(saved,'analysis') && isfield(saved,'summary');
end
if reused
    analysis = saved.analysis;
    row = saved.summary;
    if isfield(saved,'figureEntries')
        figureEntries = saved.figureEntries;
    else
        figureEntries = repmat(emptyFigureEntry(),0,1);
    end
    if options.ExportFigures && ~figuresExist(figureEntries,outputRoot)
        figureEntries = exportMethodFigure( ...
            task,analysis,spec,figureDirectory,outputRoot,options);
        saveAtomic(resultFile,struct('analysis',analysis,'summary',row, ...
            'figureEntries',figureEntries,'signature',signature));
    end
    return
end

checkpoint = struct('status','running','signature',signature, ...
    'updated_at',timestampNow(),'error','');
saveAtomic(checkpointFile,struct('checkpoint',checkpoint));
try
    fmaxData = 1/(2*dt);
    progressFcn = [];
    if options.ShowProgress
        progressFcn = @(fraction,message)reportExperimentProgress( ...
            task.title,fraction,message);
    end
    [prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb, ...
        out_norbit,sr_p,details] = ecoco( ...
        data,[],orbit9,window,dt,stepSamples,0,options.Red,pad, ...
        spec.sr1,spec.sr2,spec.srstep,options.NSim,0,1,0, ...
        options.Method,fmaxData,0,task.mode,maxFrequency,options.Seed, ...
        options.AnchorFraction,'ProgressFcn',progressFcn, ...
        'Verbose',options.Verbose, ...
        'ECOCOWindowMode','physical-depth', ...
        'ECOCOStepDepth',stepSamples*dt, ...
        'ECOCOCenterLimits',originalDepth([1,end])');
    analysis = struct( ...
        'method',task.title,'method_id',task.id,'mode',task.title, ...
        'prt_sr',prt_sr,'out_depth',out_depth,'out_ecc',out_ecc, ...
        'out_ep',out_ep,'out_eci',out_eci,'out_ecoco',out_ecoco, ...
        'out_ecocorb',out_ecocorb,'out_norbit',out_norbit, ...
        'sr_p',sr_p,'details',details,'orbit9',orbit9, ...
        'window',window,'dt',dt,'stepSamples',stepSamples,'pad',pad);
    row = summarizeMethod(spec,task,analysis,originalDepth,options);
    figureEntries = repmat(emptyFigureEntry(),0,1);
    if options.ExportFigures
        figureEntries = exportMethodFigure( ...
            task,analysis,spec,figureDirectory,outputRoot,options);
    end
    saveAtomic(resultFile,struct('analysis',analysis,'summary',row, ...
        'figureEntries',figureEntries,'signature',signature));
    writeMethodMatrices(methodDirectory,analysis);
    methodParameters = methodParameterStruct(spec,task,analysis,options);
    writeParameterCsv(fullfile(methodDirectory,'parameters.csv'), ...
        methodParameters);
    writeJsonAtomic(fullfile(methodDirectory,'parameters.json'), ...
        methodParameters);
    writeSummaryCsv(fullfile(methodDirectory,'summary.csv'),row);
    writeTextAtomic(fullfile(methodDirectory,'conclusion.txt'),row.conclusion);
    writeJsonAtomic(manifestFile,struct( ...
        'signature',signature,'summary',row,'figures',figureEntries, ...
        'algorithm_version',methodParameters.algorithm_version, ...
        'score_definition',methodParameters.score_definition, ...
        'orbit_count_role',methodParameters.orbit_count_role, ...
        'parameters_csv','parameters.csv','parameters_json','parameters.json', ...
        'results_mat','results.mat','matrices_dir','.'));
    checkpoint.status = 'complete';
    checkpoint.updated_at = timestampNow();
    checkpoint.error = '';
    saveAtomic(checkpointFile,struct('checkpoint',checkpoint));
catch exception
    checkpoint.status = 'failed';
    checkpoint.updated_at = timestampNow();
    checkpoint.error = exceptionReport(exception);
    saveAtomic(checkpointFile,struct('checkpoint',checkpoint));
    rethrow(exception)
end
end

function reportExperimentProgress(methodName,fraction,message)
persistent previousMethod previousPercent
percent = floor(100*min(max(double(fraction),0),1));
methodChanged = isempty(previousMethod) || ~strcmp(previousMethod,methodName);
if methodChanged || isempty(previousPercent) || percent >= previousPercent+5 || ...
        fraction <= 0 || fraction >= 1
    fprintf('[%s] PROGRESS method=%s percent=%5.1f message=%s\n', ...
        timestampNow(),methodName,100*fraction,char(string(message)));
    previousMethod = methodName;
    previousPercent = percent;
end
end

function row = summarizeMethod(spec,task,analysis,originalDepth,options)
row = baseSummaryRow(spec,task,options);
track = analysis.sr_p;
depth = track(:,1);
rate = track(:,2);
trackedP = track(:,4);
interior = depth >= min(originalDepth) & depth <= max(originalDepth);
valid = interior & isfinite(rate);
trackedValidP = valid & isfinite(trackedP);
trackedSignificant = trackedValidP & trackedP < 0.05;
targetHit = valid & rateInExpectedWindows(rate,spec.expectedWindows);
significantHit = trackedSignificant & targetHit;

% SR-global p-values correct the rate search within each window.  A noise
% false positive therefore means that any rate in a complete window passes
% this full-grid test; it must not be inferred only from the selected ridge.
[mapMinP,mapMinRate] = minimumPByWindow( ...
    analysis.out_eci,analysis.prt_sr,true(size(analysis.prt_sr)));
validMapP = interior & isfinite(mapMinP);
significant = validMapP & mapMinP < 0.05;

targetRateMask = rateInExpectedWindows( ...
    analysis.prt_sr,spec.expectedWindows);
[targetMinP,~] = minimumPByWindow( ...
    analysis.out_eci,analysis.prt_sr,targetRateMask);
validTargetP = interior & isfinite(targetMinP);
significantTargetBand = validTargetP & targetMinP < 0.05;

row.window_count = numel(depth);
row.interior_window_count = nnz(interior);
row.valid_window_count = nnz(validMapP);
row.tracked_valid_window_count = nnz(valid);
row.significant_window_count = nnz(significant);
row.significant_window_fraction = safeRatio(nnz(significant),nnz(validMapP));
row.tracked_significant_window_count = nnz(trackedSignificant);
row.tracked_significant_window_fraction = ...
    safeRatio(nnz(trackedSignificant),nnz(trackedValidP));
row.significant_target_hit_count = nnz(significantHit);
row.target_hit_fraction = safeRatio(nnz(targetHit),nnz(valid));
row.target_band_valid_window_count = nnz(validTargetP);
row.target_band_significant_window_count = nnz(significantTargetBand);
row.target_band_significant_window_fraction = ...
    safeRatio(nnz(significantTargetBand),nnz(validTargetP));
if any(validTargetP)
    row.min_target_band_global_p = min(targetMinP(validTargetP));
    row.median_target_band_global_p = ...
        median(targetMinP(validTargetP),'omitnan');
end
row.false_positive_count = 0;
row.false_positive_fraction = NaN;
if strcmp(spec.category,'noise')
    row.false_positive_count = nnz(significant);
    row.false_positive_fraction = ...
        safeRatio(row.false_positive_count,nnz(validMapP));
end
if any(valid)
    row.median_tracked_rate = median(rate(valid),'omitnan');
    row.mean_tracked_rate = mean(rate(valid),'omitnan');
end
if any(validMapP)
    candidates = find(validMapP);
    [row.min_sr_global_p,location] = min(mapMinP(validMapP));
    row.rate_at_min_p = mapMinRate(candidates(location));
    row.median_sr_global_p = median(mapMinP(validMapP),'omitnan');
end
if any(trackedValidP)
    row.tracked_min_sr_global_p = min(trackedP(trackedValidP));
    row.tracked_median_sr_global_p = ...
        median(trackedP(trackedValidP),'omitnan');
end
referenceRate = referenceRateByDepth(spec,depth,originalDepth);
validReference = valid & isfinite(referenceRate);
if any(validReference)
    row.median_absolute_rate_error = median( ...
        abs(rate(validReference)-referenceRate(validReference)),'omitnan');
end

midpoint = expectedSegmentBoundary(spec,originalDepth);
firstRate = valid & depth <= midpoint;
secondRate = valid & depth > midpoint;
if any(firstRate)
    row.first_half_median_rate = median(rate(firstRate),'omitnan');
end
if any(secondRate)
    row.second_half_median_rate = median(rate(secondRate),'omitnan');
end
firstP = interior & depth <= midpoint & isfinite(mapMinP);
secondP = interior & depth > midpoint & isfinite(mapMinP);
row.first_half_significant_fraction = ...
    safeRatio(nnz(firstP & mapMinP < 0.05),nnz(firstP));
row.second_half_significant_fraction = ...
    safeRatio(nnz(secondP & mapMinP < 0.05),nnz(secondP));

row.detected = nnz(significantHit) > 0;
row.target_band_detected = nnz(significantTargetBand) > 0;
if strcmp(spec.category,'noise')
    row.detected = row.false_positive_count > 0;
end
row.status = 'complete';
row.conclusion = sprintf([ ...
    '%s: interior windows=%d, median tracked rate=%.6g cm/kyr, ', ...
    'minimum full-grid SR-global p=%.6g, full-grid significant windows=%d, ', ...
    'tracked significant target-rate windows=%d, target-band significant ', ...
    'windows=%d, false positives=%d.'], ...
    task.title,row.valid_window_count,row.median_tracked_rate, ...
    row.min_sr_global_p,row.significant_window_count, ...
    row.significant_target_hit_count, ...
    row.target_band_significant_window_count,row.false_positive_count);
end

function reference = referenceRateByDepth(spec,depth,originalDepth)
reference = nan(size(depth));
if isfield(spec,'expectedKind') && strcmp(spec.expectedKind,'piecewise46')
    boundary = expectedSegmentBoundary(spec,originalDepth);
    reference(depth <= boundary) = 4;
    reference(depth > boundary) = 6;
elseif isfield(spec,'referenceRate') && isfinite(spec.referenceRate)
    reference(:) = spec.referenceRate;
elseif isfinite(spec.windowRate)
    reference(:) = spec.windowRate;
end
end

function boundary = expectedSegmentBoundary(spec,originalDepth)
fraction = 0.5;
if isfield(spec,'expectedSplitDepthFraction') && ...
        isfinite(spec.expectedSplitDepthFraction)
    fraction = spec.expectedSplitDepthFraction;
end
depthMinimum = min(originalDepth);
boundary = depthMinimum + fraction*(max(originalDepth)-depthMinimum);
end

function [minimumP,rateAtMinimum] = minimumPByWindow(pGlobal,srGrid,rowMask)
rowMask = logical(rowMask(:));
if size(pGlobal,1) ~= numel(srGrid) || numel(rowMask) ~= numel(srGrid)
    error('runEcocoTwoMethodExperiment:SummarySizeMismatch', ...
        'The p-global map, sedimentation-rate grid, and rate mask disagree.');
end
nWindow = size(pGlobal,2);
minimumP = nan(nWindow,1);
rateAtMinimum = nan(nWindow,1);
if ~any(rowMask)
    return
end
selected = pGlobal(rowMask,:);
selectedRates = srGrid(rowMask);
validWindow = any(isfinite(selected),1);
if ~any(validWindow)
    return
end
[values,indices] = min(selected(:,validWindow),[],1,'omitnan');
minimumP(validWindow) = values(:);
rateAtMinimum(validWindow) = selectedRates(indices(:));
end

function entries = exportMethodFigure( ...
        task,analysis,spec,figureDirectory,outputRoot,options)
[~,figures] = ecocoplot(analysis.prt_sr,analysis.out_depth,analysis.out_ecc, ...
    analysis.out_ep,analysis.out_eci,analysis.out_ecoco, ...
    analysis.out_ecocorb,analysis.out_norbit,-1,analysis.details);
figures = figures(isgraphics(figures,'figure'));
if numel(figures) ~= 2
    closeFigures(figures);
    error('runEcocoTwoMethodExperiment:UnexpectedFigureCount', ...
        ['%s created %d figures; the standard eCOCO layout requires ', ...
         'one main-map figure and one standalone final-map figure.'], ...
        task.title,numel(figures));
end
entries = repmat(emptyFigureEntry(),2,1);
baseStem = sprintf('%s_%s',sanitizeFilename(spec.id), ...
    sanitizeFilename(task.id));
suffixes = {'','_ridge'};
panelLabels = {'Main maps','Ridge score'};
widths = [28,17.95];
try
    for figureIndex = 1:2
        fig = figures(figureIndex);
        set(fig,'Color','w','Visible',options.Visible, ...
            'Units','centimeters','Position',[1,1,widths(figureIndex),14.5], ...
            'Name',sprintf('%s - %s - %s',spec.title,task.title, ...
            panelLabels{figureIndex}));
        drawnow;
        stem = [baseStem,suffixes{figureIndex}];
        pngPath = fullfile(figureDirectory,[stem,'.png']);
        pdfPath = fullfile(figureDirectory,[stem,'.pdf']);
        figPath = fullfile(figureDirectory,[stem,'.fig']);
        exportgraphics(fig,pngPath,'Resolution',300, ...
            'BackgroundColor','white');
        exportVectorPdf(fig,pdfPath);
        savefig(fig,figPath);
        entry = emptyFigureEntry();
        entry.png = relativePath(pngPath,outputRoot);
        entry.pdf = relativePath(pdfPath,outputRoot);
        entry.fig = relativePath(figPath,outputRoot);
        entry.title = sprintf('%s — %s — %s', ...
            spec.title,task.title,panelLabels{figureIndex});
        if figureIndex == 1
            displayNote = ['Black contours mark the saved Local-p and ', ...
                'Global-p significance thresholds.'];
        else
            displayNote = ['The tracked rate is overlaid on the standalone ', ...
                'window-normalized ridge-score map.'];
        end
        entry.caption = sprintf([ ...
            '%s. Complete sedimentation-rate grid %.6g–%.6g cm/kyr ', ...
            '(step %.6g); W=%.6g m; sliding step=%.6g m; Pad=%d; ', ...
            '%s correlation; red=%d; N_{MC}=%d; seed=%d. %s'], ...
            entry.title,spec.sr1,spec.sr2,spec.srstep,analysis.window, ...
            analysis.stepSamples*analysis.dt,analysis.pad,options.Method, ...
            options.Red,options.NSim,options.Seed,displayNote);
        entry.method = task.title;
        entry.method_id = task.id;
        entries(figureIndex) = entry;
    end
catch exception
    closeFigures(figures);
    rethrow(exception)
end
if options.CloseFigures
    closeFigures(figures);
end

function closeFigures(figures)
figures = figures(isgraphics(figures,'figure'));
if ~isempty(figures)
    close(figures);
end
end

function exportVectorPdf(fig,path)
% Force the Painters backend so dense contour data panels remain editable
% vector objects instead of being silently replaced by JPEG images. MATLAB
% may retain the narrow colorbar gradients as small raster strips.
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.pdf'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
oldUnits = get(fig,'Units');
set(fig,'Units','centimeters');
position = get(fig,'Position');
set(fig, ...
    'Renderer','painters', ...
    'PaperUnits','centimeters', ...
    'PaperSize',position(3:4), ...
    'PaperPosition',[0,0,position(3:4)]);
print(fig,temporary,'-dpdf','-painters','-r300');
set(fig,'Units',oldUnits);
finalizeAtomicFile(temporary,path);
clear cleanup
end
end

function writeMethodMatrices(directory,analysis)
writeVectorCsv(fullfile(directory,'sedimentation_rate.csv'), ...
    'Sedimentation_rate_cm_per_kyr',analysis.prt_sr);
writeVectorCsv(fullfile(directory,'depth.csv'),'Window_center_depth_m', ...
    analysis.out_depth);
writeMatrixCsvAtomic(fullfile(directory,'rho.csv'),analysis.out_ecc);
if isfield(analysis.details,'pLocal') && ...
        isnumeric(analysis.details.pLocal)
    writeMatrixCsvAtomic(fullfile(directory,'p_local.csv'), ...
        analysis.details.pLocal);
else
    writeMatrixCsvAtomic(fullfile(directory,'p_parametric.csv'), ...
        analysis.out_ep);
end
writeMatrixCsvAtomic(fullfile(directory,'p_global.csv'),analysis.out_eci);
writeMatrixCsvAtomic(fullfile(directory,'n_orbit.csv'),analysis.out_norbit);
writeMatrixCsvAtomic(fullfile(directory,'pcoco.csv'),analysis.out_ecoco);
writeMatrixCsvAtomic(fullfile(directory,'ridge_score.csv'),analysis.out_ecocorb);
writeNumericCsvAtomic(fullfile(directory,'tracked_sr.csv'), ...
    {'Depth_m','SedRate_cm_per_kyr','Correlation','SR_global_p', ...
     'N_orbits','Ridge_score','SedRate_low_cm_per_kyr', ...
     'SedRate_high_cm_per_kyr'},analysis.sr_p);
details = analysis.details;
if isfield(details,'forward')
    writeDirectionMatrices(directory,'forward',details.forward);
end
if isfield(details,'backward')
    writeDirectionMatrices(directory,'backward',details.backward);
end
if isfield(details,'consensus')
    writeDirectionMatrices(directory,'consensus',details.consensus);
end
if isfield(details,'strictConsensus')
    writeDirectionMatrices(directory,'strict_consensus', ...
        details.strictConsensus);
end
end

function writeDirectionMatrices(directory,prefix,value)
fields = {'rho','pLocal','pGlobal','nOrbit','pCOCO','score'};
suffixes = {'rho','p_local','p_global','n_orbit','pcoco','score'};
for ii = 1:numel(fields)
    if isfield(value,fields{ii}) && isnumeric(value.(fields{ii}))
        writeMatrixCsvAtomic(fullfile(directory, ...
            [prefix,'_',suffixes{ii},'.csv']),value.(fields{ii}));
    end
end
end

function parameters = caseParameters(spec,inputFile,inputHash,data, ...
        analysisData,preprocessing,padding,dt,orbit9,windowRequested, ...
        windowActual,nWindow,stepSamplesRequested,stepSamples,stepDepth, ...
        nSlidingWindows,pad,maxFrequency,options)
parameters = struct( ...
    'dataset_id',spec.id, ...
    'dataset_title',spec.title, ...
    'category',spec.category, ...
    'input_file',inputFile, ...
    'input_sha256',inputHash, ...
    'age_ma',spec.age_ma, ...
    'expected_rate',spec.expected_rate, ...
    'expected_rate_windows_cm_per_kyr',spec.expectedWindows, ...
    'rate_min_cm_per_kyr',spec.sr1, ...
    'rate_max_cm_per_kyr',spec.sr2, ...
    'rate_step_cm_per_kyr',spec.srstep, ...
    'window_design_rate_cm_per_kyr',spec.windowRate, ...
    'window_formula','2 * 405 kyr * rate / 100 m', ...
    'window_requested_m',windowRequested, ...
    'window_actual_m',windowActual, ...
    'window_point_count',nWindow, ...
    'step_fraction_requested',options.StepFraction, ...
    'step_samples_before_window_cap',stepSamplesRequested, ...
    'step_samples_used',stepSamples, ...
    'step_depth_m',stepDepth, ...
    'sliding_window_count',nSlidingWindows, ...
    'maximum_window_count',options.MaxWindows, ...
    'sampling_interval_m',dt, ...
    'input_point_count',size(data,1), ...
    'padded_point_count',size(analysisData,1), ...
    'half_window_zero_padding_points_each_edge',padding.pointsEachEdge, ...
    'edge_padding_value',0, ...
    'edge_padding_second_column_strict_zero',padding.strictZero, ...
    'global_mean_removed_before_padding',padding.globalMeanRemoved, ...
    'removed_global_mean',padding.removedMean, ...
    'pad_nfft',pad, ...
    'pad_rule','2^nextpow2(window point count)', ...
    'monte_carlo_simulations',options.NSim, ...
    'seed',options.Seed, ...
    'red',options.Red, ...
    'correlation_method',options.Method, ...
    'target_anchor_fraction',options.AnchorFraction, ...
    'maximum_frequency_cycle_per_kyr',maxFrequency, ...
    'maximum_frequency_rule','1.2 x highest nominal orbital frequency', ...
    'orbit_periods_kyr',orbit9(:)', ...
    'newark_reconstructed_spacing_m',spec.reconstructSpacing, ...
    'preprocessing',preprocessing);
end

function parameters = methodParameterStruct(spec,task,analysis,options)
if strcmp(task.mode,'crossfit')
    targetMode = 'four-group-coherent-nine';
    defaultScoreDefinition = [ ...
        'pCOCO = consensus rho x abs(log10(consensus global p)); ', ...
        'no orbit-count weighting'];
    orbitCountRole = 'diagnostic only';
else
    targetMode = 'window-specific-four-group-coherent-nine';
    defaultScoreDefinition = 'pCOCO x N_orbits / 9';
    orbitCountRole = 'ridge-score weight';
end
algorithmVersion = '';
scoreDefinition = defaultScoreDefinition;
if isstruct(analysis.details)
    if isfield(analysis.details,'algorithmVersion') && ...
            (ischar(analysis.details.algorithmVersion) || ...
             (isstring(analysis.details.algorithmVersion) && ...
              isscalar(analysis.details.algorithmVersion)))
        algorithmVersion = char(string(analysis.details.algorithmVersion));
    end
    if isfield(analysis.details,'scoreDefinition') && ...
            (ischar(analysis.details.scoreDefinition) || ...
             (isstring(analysis.details.scoreDefinition) && ...
              isscalar(analysis.details.scoreDefinition)))
        scoreDefinition = char(string(analysis.details.scoreDefinition));
    end
end
parameters = struct( ...
    'dataset_id',spec.id,'method_id',task.id,'method',task.title, ...
    'analysis_method',task.title,'target_mode',targetMode, ...
    'full_rate_grid',true,'sr1',spec.sr1,'sr2',spec.sr2, ...
    'srstep',spec.srstep,'window_m',analysis.window, ...
    'sampling_interval_m',analysis.dt,'step_samples',analysis.stepSamples, ...
    'step_depth_m',analysis.stepSamples*analysis.dt,'pad',analysis.pad, ...
    'nsim',options.NSim,'red',options.Red, ...
    'correlation_method',options.Method, ...
    'seed',options.Seed,'anchor_fraction',options.AnchorFraction, ...
    'algorithm_version',algorithmVersion, ...
    'score_definition',scoreDefinition, ...
    'orbit_count_role',orbitCountRole, ...
    'sr_global_p',true,'map_global_p',false);
end

function [data,info] = prepareInput(path,spec)
raw = readmatrix(path);
if ~isnumeric(raw) || isempty(raw) || size(raw,2) < 2
    error('runEcocoTwoMethodExperiment:InvalidInput', ...
        '%s did not yield two numeric columns.',path);
end
raw = raw(:,1:2);
rowsRead = size(raw,1);
raw = raw(all(isfinite(raw),2),:);
if size(raw,1) < 4
    error('runEcocoTwoMethodExperiment:InsufficientInput', ...
        '%s has fewer than four finite depth/value rows.',path);
end
raw = sortrows(raw,1);
[uniqueDepth,~,group] = unique(raw(:,1),'sorted');
raw = [uniqueDepth,accumarray(group,raw(:,2),[],@mean)];
reconstructed = isfinite(spec.reconstructSpacing);
if reconstructed
    raw(:,1) = (0:size(raw,1)-1)'*spec.reconstructSpacing;
end
spacing = diff(raw(:,1));
dt = median(spacing);
tolerance = cocoSamplingTolerance(raw(:,1),dt);
interpolated = any(abs(spacing-dt) > tolerance);
data = raw;
if interpolated
    nInterval = floor((raw(end,1)-raw(1,1))/dt + 1e-10);
    grid = raw(1,1)+(0:nInterval)'*dt;
    value = interp1(raw(:,1),raw(:,2),grid,'linear');
    data = [grid,value];
    data = data(all(isfinite(data),2),:);
end
if size(data,1) < 4 || ~isfinite(std(detrend(data(:,2),1))) || ...
        std(detrend(data(:,2),1)) <= 0
    error('runEcocoTwoMethodExperiment:DegenerateInput', ...
        '%s has no resolved detrended variance.',path);
end
info = struct('rowsRead',rowsRead,'finiteUniqueRows',size(raw,1), ...
    'newarkGridRebuilt',reconstructed, ...
    'reconstructedSpacing',spec.reconstructSpacing, ...
    'interpolationApplied',interpolated, ...
    'interpolationMethod','linear at median spacing', ...
    'analysisPointCount',size(data,1), ...
    'analysisDepthRange',data([1,end],1)');
end

function [padded,info] = strictZeroHalfWindowPad(data,nWindow,dt)
nHalf = (nWindow-1)/2;
if nHalf < 1 || nHalf ~= fix(nHalf)
    error('runEcocoTwoMethodExperiment:InvalidWindowParity', ...
        'Strict half-window padding requires an odd window point count.');
end
removedMean = mean(data(:,2));
centered = data;
centered(:,2) = centered(:,2)-removedMean;
leftDepth = data(1,1)+(-nHalf:-1)'*dt;
rightDepth = data(end,1)+(1:nHalf)'*dt;
left = [leftDepth,zeros(nHalf,1)];
right = [rightDepth,zeros(nHalf,1)];
padded = [left;centered;right];
strictZero = all(padded(1:nHalf,2) == 0) && ...
    all(padded(end-nHalf+1:end,2) == 0);
if ~strictZero
    error('runEcocoTwoMethodExperiment:NonzeroEdgePadding', ...
        'Half-window edge padding must be strictly zero in column two.');
end
info = struct('pointsEachEdge',nHalf,'depthEachEdge',nHalf*dt, ...
    'strictZero',strictZero,'value',0,'globalMeanRemoved',true, ...
    'removedMean',removedMean);
end

function step = capWindowCount(nData,nWindow,requested,maxWindows)
step = max(1,round(requested));
availableShift = nData-nWindow;
if availableShift < 0
    error('runEcocoTwoMethodExperiment:WindowLongerThanPaddedData', ...
        'The complete window is longer than the padded input.');
end
if maxWindows == 1
    step = max(step,availableShift+1);
else
    step = max(step,ceil(availableShift/(maxWindows-1)));
end
end

function starts = endpointInclusiveStarts(lastStart,step)
starts = 1:step:lastStart;
if isempty(starts)
    starts = lastStart;
elseif starts(end) ~= lastStart
    starts(end+1) = lastStart;
end
end

function plan = defaultDatasetPlan(inputRoot)
items = {
    'noise80m','80 m red noise','noise','rednoise0.5-80m.csv', ...
        0,0.1,20,0.1,5,'none (negative control)',zeros(0,2),NaN;
    'la04_5myr_red','La2004 1E1T1P + red noise, 54-59 Ma, 4 cm/kyr', ...
        'theory','La2004-1E1T-1P-54-59Ma-4cmkyr+Red0.7.txt', ...
        56,0.1,20,0.1,4,'4 cm/kyr',[3.5,4.5],NaN;
    'la04_variable_4_6', ...
        'La2004 ETP + red noise, variable 4 to 6 cm/kyr', ...
        'stress','la04etp54-59ma4-6cmka-rsp0.04+Red0.7.txt', ...
        56,0.1,20,0.1,6,'4 cm/kyr first half; 6 cm/kyr second half', ...
        [3.5,4.5;5.5,6.5],NaN;
    '1262','ODP Site 1262 XRF Fe','real', ...
        '1262XRF-Fe-log10-s.u.-111-170-rsp0.02-10-rLOESS-dpks-rsp0.04.txt', ...
        56,0.1,10,0.02,1.3,'1-1.3 cm/kyr',[1,1.3],NaN;
    'newark','Newark 2-km record','real','newark2km-s-rsp0.85.txt', ...
        210,1,40,0.1,15,'approximately 15 cm/kyr (12-18)',[12,18],0.85;
    'givetian','Givetian DD14 record','real', ...
        'GivetianDD14-s.u.-rsp0.3-log10-80-rLOESS.txt', ...
        385,1,20,0.05,8,'approximately 8 cm/kyr (6.4-9.6)', ...
        [6.4,9.6],NaN};
plan = repmat(emptyDataset(),size(items,1),1);
for ii = 1:size(items,1)
    plan(ii).id = items{ii,1};
    plan(ii).title = items{ii,2};
    plan(ii).category = items{ii,3};
    plan(ii).filename = items{ii,4};
    plan(ii).input_file = fullfile(inputRoot,items{ii,4});
    plan(ii).age_ma = items{ii,5};
    plan(ii).sr1 = items{ii,6};
    plan(ii).sr2 = items{ii,7};
    plan(ii).srstep = items{ii,8};
    plan(ii).windowRate = items{ii,9};
    plan(ii).expected_rate = items{ii,10};
    plan(ii).expectedWindows = items{ii,11};
    plan(ii).reconstructSpacing = items{ii,12};
end
end

function methods = methodPlan()
items = {
    'Adaptive eCOCO','Adaptive_eCOCO','adaptive';
    'Blocked eCOCO','Blocked_eCOCO','crossfit'};
methods = repmat( ...
    struct('id','','title','','folder','','mode',''),size(items,1),1);
for ii = 1:size(items,1)
    methods(ii).id = items{ii,1};
    methods(ii).title = items{ii,1};
    methods(ii).folder = items{ii,2};
    methods(ii).mode = items{ii,3};
end
end

function plan = normalizeDatasetPlan(plan,inputRoot)
required = {'id','title','category','age_ma','sr1','sr2','srstep', ...
    'windowRate'};
for ii = 1:numel(plan)
    missing = required(~isfield(plan(ii),required));
    if ~isempty(missing)
        error('runEcocoTwoMethodExperiment:IncompleteDatasetPlan', ...
            'DatasetPlan item %d is missing: %s.',ii,strjoin(missing,', '));
    end
    if ~isfield(plan(ii),'filename'), plan(ii).filename = ''; end
    if ~isfield(plan(ii),'input_file') || isempty(plan(ii).input_file)
        plan(ii).input_file = fullfile(inputRoot,plan(ii).filename);
    end
    if ~isfield(plan(ii),'expected_rate')
        plan(ii).expected_rate = sprintf('%.6g cm/kyr',plan(ii).windowRate);
    end
    if ~isfield(plan(ii),'expectedWindows')
        plan(ii).expectedWindows = [0.8,1.2]*plan(ii).windowRate;
    end
    if ~isfield(plan(ii),'reconstructSpacing')
        plan(ii).reconstructSpacing = NaN;
    end
end
end

function selected = selectItems(items,requested,kind)
if ischar(requested)
    requested = string({requested});
elseif iscell(requested)
    requested = string(requested(:));
else
    requested = string(requested(:));
end
requested = requested(strlength(requested) > 0);
if isempty(requested)
    selected = items;
    return
end
ids = string({items.id});
missing = setdiff(requested,ids);
if ~isempty(missing)
    error('runEcocoTwoMethodExperiment:UnknownSelection', ...
        'Unknown %s id(s): %s.',kind,strjoin(missing,', '));
end
selected = items(ismember(ids,requested));
end

function selected = selectEcocoMethods(items,requested)
if ischar(requested)
    requested = string({requested});
else
    requested = string(requested(:));
end
requested = requested(strlength(requested) > 0);
if isempty(requested)
    selected = items;
    return
end
% Preserve saved commands while ensuring only published names are carried
% forward into public options and manifests.
requested(strcmpi(requested,'adaptive')) = "Adaptive eCOCO";
requested(strcmpi(requested,'crossfit')) = "Blocked eCOCO";
requested(strcmpi(requested,'Adaptive_eCOCO')) = "Adaptive eCOCO";
requested(strcmpi(requested,'Blocked_eCOCO')) = "Blocked eCOCO";
ids = string({items.id});
missing = setdiff(requested,ids);
if ~isempty(missing)
    error('runEcocoTwoMethodExperiment:UnknownSelection', ...
        'Unknown eCOCO method name(s): %s.',strjoin(missing,', '));
end
selected = items(ismember(ids,requested));
end

function row = baseSummaryRow(spec,task,options)
row = emptySummaryRow();
row.dataset_id = spec.id;
row.dataset_title = spec.title;
row.category = spec.category;
row.expected_rate = spec.expected_rate;
row.method = task.title;
row.method_id = task.id;
row.nsim = options.NSim;
row.seed = options.Seed;
row.red = options.Red;
end

function row = failedSummaryRow(spec,task,exception,options)
row = baseSummaryRow(spec,task,options);
row.status = 'failed';
row.conclusion = sprintf('FAILED: %s (%s)', ...
    publicFailureText(exception.message), ...
    publicFailureText(exception.identifier));
end

function row = emptySummaryRow()
row = struct( ...
    'dataset_id','','dataset_title','','category','','expected_rate','', ...
    'method','','method_id','','status','pending', ...
    'window_count',0,'interior_window_count',0,'valid_window_count',0, ...
    'tracked_valid_window_count',0, ...
    'significant_window_count',0,'significant_window_fraction',NaN, ...
    'tracked_significant_window_count',0, ...
    'tracked_significant_window_fraction',NaN, ...
    'significant_target_hit_count',0,'target_hit_fraction',NaN, ...
    'target_band_valid_window_count',0, ...
    'target_band_significant_window_count',0, ...
    'target_band_significant_window_fraction',NaN, ...
    'min_target_band_global_p',NaN, ...
    'median_target_band_global_p',NaN, ...
    'false_positive_count',0,'false_positive_fraction',NaN, ...
    'detected',false,'target_band_detected',false, ...
    'median_tracked_rate',NaN,'mean_tracked_rate',NaN, ...
    'rate_at_min_p',NaN,'min_sr_global_p',NaN, ...
    'median_sr_global_p',NaN,'tracked_min_sr_global_p',NaN, ...
    'tracked_median_sr_global_p',NaN, ...
    'median_absolute_rate_error',NaN, ...
    'first_half_median_rate',NaN,'second_half_median_rate',NaN, ...
    'first_half_significant_fraction',NaN, ...
    'second_half_significant_fraction',NaN, ...
    'nsim',NaN,'seed',NaN,'red',NaN,'conclusion','');
end

function item = emptyDataset()
item = struct('id','','title','','category','','filename','', ...
    'input_file','','age_ma',NaN,'sr1',NaN,'sr2',NaN,'srstep',NaN, ...
    'windowRate',NaN,'expected_rate','','expectedWindows',zeros(0,2), ...
    'reconstructSpacing',NaN);
end

function item = emptyCaseManifest()
item = struct('id','','title','','category','','expected_rate','', ...
    'age_ma',NaN,'input_file','','input_sha256','','case_dir','', ...
    'parameters_csv','','parameters_json','','summary_csv','', ...
    'figures',repmat(emptyFigureEntry(),0,1), ...
    'methods',repmat(emptyMethodManifest(),0,1), ...
    'status','pending','updated_at','');
end

function entry = emptyFigureEntry()
entry = struct('png','','pdf','','fig','','title','','caption','', ...
    'method','','method_id','');
end

function item = emptyMethodManifest()
item = struct('id','','title','','status','pending','method_dir','', ...
    'summary_csv','','parameters_csv','','parameters_json','', ...
    'results_mat','','result_json','','reused',false, ...
    'figures',repmat(emptyFigureEntry(),0,1),'error','');
end

function item = completeMethodManifest( ...
        task,directory,caseDirectory,row,figures,reused)
item = emptyMethodManifest();
item.id = task.id;
item.title = task.title;
item.status = row.status;
item.method_dir = relativePath(directory,caseDirectory);
item.summary_csv = fullfile(item.method_dir,'summary.csv');
item.parameters_csv = fullfile(item.method_dir,'parameters.csv');
item.parameters_json = fullfile(item.method_dir,'parameters.json');
item.results_mat = fullfile(item.method_dir,'results.mat');
item.result_json = fullfile(item.method_dir,'result.json');
item.reused = reused;
item.figures = figures;
end

function item = failedMethodManifest( ...
        task,directory,caseDirectory,exception)
item = emptyMethodManifest();
item.id = task.id;
item.title = task.title;
item.status = 'failed';
item.method_dir = relativePath(directory,caseDirectory);
item.error = sprintf('%s (%s)',publicFailureText(exception.message), ...
    publicFailureText(exception.identifier));
end

function item = failedCaseManifest(spec,index,outputRoot,exception)
caseName = sprintf('%02d_%s',index,sanitizeFilename(spec.id));
caseDirectory = fullfile(outputRoot,caseName);
ensureDirectory(caseDirectory);
writeTextAtomic(fullfile(caseDirectory,'error.txt'),exceptionReport(exception));
item = emptyCaseManifest();
item.id = spec.id;
item.title = spec.title;
item.category = spec.category;
item.expected_rate = spec.expected_rate;
item.age_ma = spec.age_ma;
item.input_file = spec.input_file;
item.case_dir = caseName;
item.status = 'failed';
item.updated_at = timestampNow();
end

function tf = rateInExpectedWindows(rate,windows)
if isempty(windows)
    tf = false(size(rate));
    return
end
validateattributes(windows,{'numeric'},{'2d','ncols',2,'finite'});
rate = rate(:);
tf = false(size(rate));
for ii = 1:size(windows,1)
    tf = tf | (rate >= windows(ii,1) & rate <= windows(ii,2));
end
end

function ratio = safeRatio(numerator,denominator)
if denominator > 0
    ratio = numerator/denominator;
else
    ratio = NaN;
end
end

function path = resolveInputFile(spec,inputRoot)
path = char(string(spec.input_file));
if isempty(path)
    path = fullfile(inputRoot,char(string(spec.filename)));
end
if ~isfile(path)
    error('runEcocoTwoMethodExperiment:InputFileMissing', ...
        'Input file does not exist: %s',path);
end
end

function digest = engineFingerprint(task)
% MFILE('fullpath') can be empty inside a local function in some MATLAB
% releases. Resolve the public runner explicitly so the signature never
% begins with an unexplained "missing" component.
paths = {which('runEcocoTwoMethodExperiment'),which('ecoco'), ...
    which('cocoAdaptiveEvaluate')};
if strcmp(task.mode,'adaptive')
    paths{end+1} = which('ecocoAdaptiveCore');
else
    paths{end+1} = which('ecocoCrossfitCore');
    paths{end+1} = which('cvcoco');
end
parts = strings(numel(paths),1);
for ii = 1:numel(paths)
    if isempty(paths{ii}) || ~isfile(paths{ii})
        parts(ii) = "missing";
    else
        parts(ii) = string(sha256File(paths{ii}));
    end
end
digest = char(join(parts,':'));
end

function checkpoint = loadCheckpoint(path)
checkpoint = struct;
if ~isfile(path), return; end
try
    saved = load(path,'checkpoint');
    if isfield(saved,'checkpoint'), checkpoint = saved.checkpoint; end
catch
    checkpoint = struct;
end
end

function tf = figuresExist(entries,root)
tf = ~isempty(entries);
for ii = 1:numel(entries)
    tf = tf && isfile(fullfile(root,entries(ii).png)) && ...
        isfile(fullfile(root,entries(ii).pdf)) && ...
        isfield(entries,'fig') && isfile(fullfile(root,entries(ii).fig));
end
end

function status = methodStatus(rows)
states = string({rows.status});
if all(states == "complete")
    status = 'complete';
elseif any(states == "complete")
    status = 'partial';
else
    status = 'failed';
end
end

function status = overallStatus(cases)
states = string({cases.status});
if all(states == "complete")
    status = 'complete';
elseif any(states == "complete" | states == "partial")
    status = 'partial';
else
    status = 'failed';
end
end

function options = publicOptions(options)
options = rmfield(options,{'DatasetPlan'});
end

function writeSummaryCsv(path,rows)
if isempty(rows)
    rows = repmat(emptySummaryRow(),0,1);
end
writeTableAtomic(path,struct2table(rows));
end

function writeParameterCsv(path,value)
names = fieldnames(value);
rows = cell(numel(names)+1,2);
rows(1,:) = {'Parameter','Value'};
for ii = 1:numel(names)
    rows{ii+1,1} = names{ii};
    candidate = value.(names{ii});
    if isstruct(candidate) || iscell(candidate)
        rows{ii+1,2} = jsonencode(candidate);
    elseif isnumeric(candidate) || islogical(candidate)
        if isscalar(candidate)
            rows{ii+1,2} = candidate;
        else
            rows{ii+1,2} = mat2str(candidate,12);
        end
    else
        rows{ii+1,2} = char(string(candidate));
    end
end
writeCellAtomic(path,rows);
end

function writeTableAtomic(path,value)
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.csv'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writetable(value,temporary,'Encoding','UTF-8');
finalizeAtomicFile(temporary,path);
clear cleanup
end

function writeVectorCsv(path,header,value)
writeNumericCsvAtomic(path,{header},value(:));
end

function writeNumericCsvAtomic(path,header,data)
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.csv'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writecell(header,temporary);
writematrix(data,temporary,'WriteMode','append');
finalizeAtomicFile(temporary,path);
clear cleanup
end

function writeMatrixCsvAtomic(path,data)
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.csv'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writematrix(data,temporary);
finalizeAtomicFile(temporary,path);
clear cleanup
end

function writeCellAtomic(path,value)
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.csv'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writecell(value,temporary);
finalizeAtomicFile(temporary,path);
clear cleanup
end

function writeJsonAtomic(path,value)
writeTextAtomic(path,jsonencode(value));
end

function writeRootManifest(path,manifest)
jsonManifest = manifest;
jsonManifest.cases = num2cell(manifest.cases(:));
writeJsonAtomic(path,jsonManifest);
end

function writeTextAtomic(path,value)
ensureDirectory(fileparts(path));
temporary = tempname(fileparts(path));
cleanup = onCleanup(@()deleteIfPresent(temporary));
file = fopen(temporary,'w','n','UTF-8');
if file < 0
    error('runEcocoTwoMethodExperiment:FileOpenFailed', ...
        'Could not open temporary output for %s.',path);
end
fileCleanup = onCleanup(@()fclose(file));
fprintf(file,'%s',char(string(value)));
clear fileCleanup
finalizeAtomicFile(temporary,path);
clear cleanup
end

function emitMethodEvent(path,eventName,datasetID,methodID,detail)
timestamp = timestampNow();
detail = regexprep(char(string(detail)),'\s+',' ');
line = sprintf('[%s] %s dataset=%s method=%s',timestamp, ...
    upper(char(string(eventName))),char(string(datasetID)), ...
    char(string(methodID)));
if ~isempty(detail)
    line = sprintf('%s %s',line,detail);
end
fprintf('%s\n',line);
ensureDirectory(fileparts(path));
file = fopen(path,'a','n','UTF-8');
if file < 0
    warning('runEcocoTwoMethodExperiment:LogOpenFailed', ...
        'Could not append to %s.',path);
    return
end
cleanup = onCleanup(@()fclose(file));
fprintf(file,'%s\n',line);
end

function saveAtomic(path,payload)
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.mat'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
save(temporary,'-struct','payload','-v7.3');
finalizeAtomicFile(temporary,path);
clear cleanup
end

function finalizeAtomicFile(source,destination)
[ok,message] = movefile(source,destination,'f');
if ~ok
    error('runEcocoTwoMethodExperiment:AtomicSaveFailed', ...
        'Could not finalize %s: %s',destination,message);
end
end

function ensureDirectory(path)
if ~isempty(path) && ~isfolder(path)
    [ok,message] = mkdir(path);
    if ~ok
        error('runEcocoTwoMethodExperiment:DirectoryCreateFailed', ...
            'Could not create %s: %s',path,message);
    end
end
end

function deleteIfPresent(path)
if isfile(path), delete(path); end
end

function path = relativePath(path,root)
prefix = [root,filesep];
if startsWith(path,prefix), path = path(numel(prefix)+1:end); end
end

function path = canonicalPath(path)
try
    path = char(java.io.File(path).getCanonicalPath());
catch
    path = char(string(path));
end
end

function digest = sha256File(path)
md = java.security.MessageDigest.getInstance('SHA-256');
stream = java.io.FileInputStream(java.io.File(path));
digestStream = java.security.DigestInputStream(stream,md);
cleanup = onCleanup(@()digestStream.close());
buffer = zeros(8192,1,'int8');
while digestStream.read(buffer,0,numel(buffer)) ~= -1
end
bytes = md.digest();
digest = lower(reshape(dec2hex(mod(double(bytes),256),2).',1,[]));
clear cleanup
end

function text = sanitizeFilename(text)
text = regexprep(char(string(text)),'[^A-Za-z0-9._-]+','_');
text = regexprep(text,'^_+|_+$','');
if isempty(text), text = 'item'; end
end

function text = timestampNow()
text = char(datetime('now','TimeZone','local', ...
    'Format','yyyy-MM-dd''T''HH:mm:ssXXX'));
end

function text = exceptionReport(exception)
text = publicFailureText( ...
    getReport(exception,'extended','hyperlinks','off'));
end

function text = publicFailureText(text)
text = char(string(text));
replacements = {
    'ecocoAdaptiveCore','Adaptive eCOCO';
    'ecocoCrossfitCore','Blocked eCOCO';
    'ecocoInterleavedCore','Interleaved eCOCO';
    'interleavedcvcoco','Interleaved cvCOCO';
    'cvcoco9[A-Za-z]*','Blocked cvCOCO';
    'adaptive9[A-Za-z]*','Adaptive COCO';
    'cross[- ]?fit(?:ted)?','blocked';
    'Method[- ]B','four-group'};
for ii = 1:size(replacements,1)
    text = regexprep(text,replacements{ii,1},replacements{ii,2}, ...
        'ignorecase');
end
end

function tf = isScalarText(x)
tf = (ischar(x) && isrow(x)) || (isstring(x) && isscalar(x));
end

function tf = isTextList(x)
tf = ischar(x) || isstring(x) || iscellstr(x);
end

function tf = isPositiveInteger(x)
tf = isnumeric(x) && isscalar(x) && isfinite(x) && x >= 1 && x == fix(x);
end

function tf = isNonnegativeInteger(x)
tf = isnumeric(x) && isscalar(x) && isfinite(x) && x >= 0 && x == fix(x);
end

function tf = isSeed(x)
tf = isnumeric(x) && isscalar(x) && isfinite(x) && x >= 0 && ...
    x == fix(x) && x <= 2^32-1;
end

function tf = isRedOption(x)
tf = isnumeric(x) && isscalar(x) && isfinite(x) && ...
    x == fix(x) && ismember(x,0:3);
end

function tf = isPositiveScalar(x)
tf = isnumeric(x) && isscalar(x) && isfinite(x) && isreal(x) && x > 0;
end

function tf = isLogicalScalar(x)
tf = (islogical(x) || isnumeric(x)) && isscalar(x) && ...
    isfinite(double(x)) && ismember(double(x),[0,1]);
end
