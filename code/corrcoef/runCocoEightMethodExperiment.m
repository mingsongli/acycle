function runSummary = runCocoEightMethodExperiment(outputRoot,varargin)
%RUNCOCOEIGHTMETHODEXPERIMENT Run the registered 9-data x 8-method suite.
%
% RUNSUMMARY = RUNCOCOEIGHTMETHODEXPERIMENT(OUTPUTROOT) runs, in order,
% cvCOCO9A, cvCOCO9B, cvCOCO, cvCOCO Legacy, Adaptive COCO9A,
% Adaptive COCO9B, Adaptive COCO, and Fixed COCO9 on the nine registered
% records. Every method has an input/settings signature and an atomic MAT
% checkpoint, so an interrupted run can be resumed without repeating
% completed, signature-matched work. Numerical curves are saved as MAT and
% CSV, compact results as JSON, and every standard result figure as PNG.
% Root and per-case manifests contain report-ready titles and captions.
%
% Important name-value options:
%   InputRoot       folder containing the nine source files (registered
%                   syn3 folder by default)
%   NSim            Monte Carlo realizations for every method (default 5000)
%   Seed            reproducible local random seed (default 1)
%   Red             COCO red-noise option, 0--3 (default 0)
%   Method          Pearson or Spearman (default Pearson)
%   BatchSize       cvCOCO Monte Carlo batch size (default 100)
%   DatasetIDs      optional subset of registered data ids
%   MethodIDs       optional subset of method ids; see METHODPLAN below
%   Resume          reuse complete signature-matched results (default true)
%   ExportFigures   save standard PNG figures (default true)
%   DatasetPlan     optional caller-supplied plan structure (testing only)
%
% This function does not run merely by being installed. The full default
% request is intentionally expensive: 72 analyses x 5000 simulations.

defaultInputRoot = ['/Users/mingsongli/Dropbox/Research/', ...
    '_通用方法火山构造波动/202606COCO/data_18/syn3'];
if nargin < 1 || strlength(string(outputRoot)) == 0
    outputRoot = fullfile(defaultInputRoot,'COCO_8method_results');
end
validateattributes(outputRoot,{'char','string'}, ...
    {'scalartext','nonempty'},mfilename,'outputRoot',1);

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'InputRoot',defaultInputRoot,@isScalarText);
addParameter(parser,'NSim',5000,@isPositiveInteger);
addParameter(parser,'Seed',1,@isSeed);
addParameter(parser,'Red',0,@isRedOption);
addParameter(parser,'Method','Pearson',@isScalarText);
addParameter(parser,'BatchSize',100,@isPositiveInteger);
addParameter(parser,'Slices',1,@isPositiveInteger);
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
if options.MaxFrequencyScale < 1
    error('runCocoEightMethodExperiment:MaximumFrequencyScaleTooSmall', ...
        'MaxFrequencyScale must be at least one.');
end

if isempty(options.DatasetPlan)
    datasets = defaultDatasetPlan(options.InputRoot);
else
    datasets = normalizeDatasetPlan(options.DatasetPlan,options.InputRoot);
end
datasets = selectItems(datasets,options.DatasetIDs,'dataset');
methods = selectItems(methodPlan(),options.MethodIDs,'method');
if isempty(datasets) || isempty(methods)
    error('runCocoEightMethodExperiment:EmptyPlan', ...
        'At least one dataset and one method must remain selected.');
end

outputRoot = char(string(outputRoot));
ensureDirectory(outputRoot);
outputRoot = canonicalPath(outputRoot);
previousVisibility = get(groot,'defaultFigureVisible');
visibilityCleanup = onCleanup(@()set(groot,'defaultFigureVisible', ...
    previousVisibility));
set(groot,'defaultFigureVisible',options.Visible);

manifestPath = fullfile(outputRoot,'manifest.json');
summaryPath = fullfile(outputRoot,'overall_summary.csv');
manifest = struct( ...
    'schema_version',1, ...
    'report_title','COCO 八方法 × 九数据大型对比分析报告', ...
    'created_at',timestampNow(), ...
    'updated_at',timestampNow(), ...
    'status','running', ...
    'output_root',outputRoot, ...
    'summary_csv','overall_summary.csv', ...
    'options',publicOptions(options), ...
    'method_order',{string({methods.title})}, ...
    'cases',repmat(emptyCaseManifest(),0,1));
writeRootManifest(manifestPath,manifest);

caseManifests = repmat(emptyCaseManifest(),numel(datasets),1);
allRows = repmat(emptySummaryRow(),0,1);
fatalException = [];
for caseIndex = 1:numel(datasets)
    spec = datasets(caseIndex);
    fprintf('\n============================================================\n');
    fprintf('COCO eight-method case %d/%d: %s\n', ...
        caseIndex,numel(datasets),spec.title);
    fprintf('============================================================\n');
    try
        [caseManifests(caseIndex),caseRows] = runOneCase( ...
            spec,caseIndex,methods,outputRoot,options);
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
        spec,index,methods,outputRoot,options)
inputFile = resolveInputFile(spec,options.InputRoot);
inputHash = sha256File(inputFile);
raw = readmatrix(inputFile);
if ~isnumeric(raw) || isempty(raw) || size(raw,2) < 2
    error('runCocoEightMethodExperiment:InvalidInput', ...
        '%s did not yield two numeric columns.',inputFile);
end
raw = raw(:,1:2);
originalRowCount = size(raw,1);
raw = raw(all(isfinite(raw),2),:);
finiteRowCount = size(raw,1);
if size(raw,1) < 8
    error('runCocoEightMethodExperiment:InsufficientInput', ...
        '%s has fewer than eight finite depth/value rows.',inputFile);
end
originalMedianSpacing = median(diff(sort(raw(:,1))));

newarkGridRebuilt = isfinite(spec.reconstructSpacing);
if newarkGridRebuilt
    raw(:,1) = (0:size(raw,1)-1)'*spec.reconstructSpacing;
end
[adaptiveData,preprocessing] = cocoPublicationPrepareData(raw,spec.title);
cvData = raw;
orbitMatrix = calculate_orbit9(spec.age_ma);
orbit9 = orbitMatrix(:,2)/1000;
if numel(orbit9) ~= 9 || any(~isfinite(orbit9) | orbit9 <= 0)
    error('runCocoEightMethodExperiment:InvalidOrbitPeriods', ...
        'calculate_orbit9 did not return nine positive periods.');
end
pad = defaultGuiPad(size(adaptiveData,1));
dt = median(diff(adaptiveData(:,1)));
fmaxData = 1/(2*dt);
maxFrequency = options.MaxFrequencyScale*max(1./orbit9);

caseName = sprintf('%02d_%s',index,sanitizeFilename(spec.id));
caseDirectory = fullfile(outputRoot,caseName);
figureDirectory = fullfile(caseDirectory,'figures');
ensureDirectory(caseDirectory);
ensureDirectory(figureDirectory);
writeNumericCsvAtomic(fullfile(caseDirectory,'cv_analysis_input.csv'), ...
    {'Depth_m','Value'},cvData);
writeNumericCsvAtomic(fullfile(caseDirectory,'adaptive_analysis_input.csv'), ...
    {'Depth_m','Value'},adaptiveData);

parameters = {
    'Parameter','Value';
    'Dataset ID',spec.id;
    'Title',spec.title;
    'Category',spec.category;
    'Input file',inputFile;
    'Input SHA-256',inputHash;
    'Original rows read',originalRowCount;
    'Finite two-column rows',finiteRowCount;
    'CV analysis point count',size(cvData,1);
    'Adaptive analysis point count',size(adaptiveData,1);
    'CV analysis depth range (m)',mat2str([min(cvData(:,1)),max(cvData(:,1))]);
    'Adaptive analysis depth range (m)', ...
        mat2str([min(adaptiveData(:,1)),max(adaptiveData(:,1))]);
    'Original finite median spacing (m)',originalMedianSpacing;
    'Age (Ma)',spec.age_ma;
    'Expected sedimentation rate',spec.expected_rate;
    'Pre-registered target windows (cm/kyr)',mat2str(spec.expectedWindows);
    'Rate minimum (cm/kyr)',spec.sr1;
    'Rate maximum (cm/kyr)',spec.sr2;
    'Rate step (cm/kyr)',spec.srstep;
    'Monte Carlo simulations per method',options.NSim;
    'Random seed',options.Seed;
    'Red option',options.Red;
    'Correlation method',options.Method;
    'Slices',options.Slices;
    'Pad (GUI rule)',pad;
    'MaxFrequency (cycle/kyr)',maxFrequency;
    'MaxFrequency rule','1.2 x highest nominal orbital frequency';
    'Orbit periods (kyr)',mat2str(orbit9(:)',10);
    'Adaptive spacing (m)',dt;
    'Newark exact grid rebuilt',newarkGridRebuilt;
    'Newark reconstructed spacing (m)',spec.reconstructSpacing;
    'Adaptive interpolation applied',preprocessing.interpolationApplied;
    'Adaptive preprocessing',preprocessing.method};
writeCellAtomic(fullfile(caseDirectory,'parameters.csv'),parameters);
saveAtomic(fullfile(caseDirectory,'parameters.mat'),struct( ...
    'spec',spec,'options',publicOptions(options),'orbitMatrix',orbitMatrix, ...
    'orbit9',orbit9,'preprocessing',preprocessing));

baseSignature = struct( ...
    'schema',1,'input_sha256',inputHash,'dataset_id',spec.id, ...
    'age_ma',spec.age_ma,'rate_grid',[spec.sr1,spec.sr2,spec.srstep], ...
    'pad',pad,'nsim',options.NSim,'seed',options.Seed,'red',options.Red, ...
    'correlation_method',options.Method,'slices',options.Slices, ...
    'maximum_frequency',maxFrequency,'newark_spacing',spec.reconstructSpacing);

summaryRows = repmat(emptySummaryRow(),numel(methods),1);
figures = repmat(emptyFigureEntry(),0,1);
conclusions = strings(numel(methods),1);
for methodIndex = 1:numel(methods)
    task = methods(methodIndex);
    fprintf('\n[%d/%d] %s\n',methodIndex,numel(methods),task.title);
    methodDirectory = fullfile(caseDirectory,task.id);
    ensureDirectory(methodDirectory);
    signatureValue = baseSignature;
    signatureValue.method_id = task.id;
    signatureValue.engine_sha256 = engineFingerprint(task);
    signature = jsonencode(signatureValue);
    try
        [~,row,methodFigures,reused] = runOneMethod( ...
            task,cvData,adaptiveData,orbit9,pad,dt,fmaxData,spec, ...
            maxFrequency,methodDirectory,figureDirectory,outputRoot, ...
            options,signature);
        summaryRows(methodIndex) = row;
        figures = [figures;methodFigures(:)]; %#ok<AGROW>
        conclusions(methodIndex) = string(row.conclusion);
        if reused
            fprintf('Reused signature-matched checkpoint: %s\n',task.title);
        end
    catch exception
        summaryRows(methodIndex) = failedSummaryRow(spec,task,exception);
        conclusions(methodIndex) = sprintf('%s: FAILED: %s (%s)', ...
            task.title,exception.message,exception.identifier);
        writeTextAtomic(fullfile(methodDirectory,'error.txt'), ...
            exceptionReport(exception));
        if ~options.ContinueOnError
            rethrow(exception)
        end
    end
    writeSummaryCsv(fullfile(caseDirectory,'summary.csv'),summaryRows(1:methodIndex));
end

writeTextAtomic(fullfile(caseDirectory,'conclusion.txt'), ...
    strjoin(conclusions,string(newline)+string(newline)));
writeJsonAtomic(fullfile(caseDirectory,'caption_manifest.json'), ...
    struct('figures',figures));
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
caseManifest.summary_csv = fullfile(caseName,'summary.csv');
caseManifest.conclusion_txt = fullfile(caseName,'conclusion.txt');
caseManifest.figures = figures;
caseManifest.status = methodStatus(summaryRows);
caseManifest.updated_at = timestampNow();
writeJsonAtomic(fullfile(caseDirectory,'case_manifest.json'),caseManifest);
end

function [analysis,row,figureEntries,reused] = runOneMethod( ...
        task,cvData,adaptiveData,orbit9,pad,dt,fmaxData,spec, ...
        maxFrequency,methodDirectory,figureDirectory,outputRoot, ...
        options,signature)
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
        figureEntries = exportMethodFigures( ...
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
    if strcmp(task.family,'cv')
        cv = runCvEngine(task,cvData,orbit9,pad,spec,maxFrequency,options);
        [row,report] = summarizeCv(spec,task,cv,options);
        analysis = struct('family','cv','result',cv,'report',report);
    else
        [corrCI,corrH0,corry,details] = corrcoefslices_rankNew( ...
            adaptiveData,orbit9,dt,pad,spec.sr1,spec.sr2,spec.srstep, ...
            0,options.Red,options.NSim,0,options.Slices,options.Method, ...
            fmaxData,0,options.ShowProgress,task.targetMode, ...
            'MaxFrequency',maxFrequency,'Seed',options.Seed, ...
            'ShowPeriodograms',false);
        [row,report] = summarizeFullRecord( ...
            spec,task,corrCI,corrH0,details,options);
        analysis = struct('family','full-record','corrCI',corrCI, ...
            'corrH0',corrH0,'corry',corry,'details',details, ...
            'report',report,'data',adaptiveData,'orbit9',orbit9);
    end
    figureEntries = repmat(emptyFigureEntry(),0,1);
    if options.ExportFigures
        figureEntries = exportMethodFigures( ...
            task,analysis,spec,figureDirectory,outputRoot,options);
    end
    saveAtomic(resultFile,struct('analysis',analysis,'summary',row, ...
        'figureEntries',figureEntries,'signature',signature));
    writeMethodCurves(fullfile(methodDirectory,'curves.csv'),analysis);
    writeSummaryCsv(fullfile(methodDirectory,'summary.csv'),row);
    writeTextAtomic(fullfile(methodDirectory,'conclusion.txt'),row.conclusion);
    writeJsonAtomic(manifestFile,struct( ...
        'signature',signature,'summary',row,'figures',figureEntries));
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

function cv = runCvEngine(task,data,orbit9,pad,spec,maxFrequency,options)
common = {'BatchSize',options.BatchSize,'Seed',options.Seed, ...
    'MaxFrequency',maxFrequency,'ProgressFcn',[],'AnalysisName',task.title};
switch task.id
    case 'cv9a'
        cv = cvcoco9A(data,orbit9,pad,spec.sr1,spec.sr2,spec.srstep, ...
            options.Red,options.NSim,options.Method,common{:});
    case 'cv9b'
        cv = cvcoco9B(data,orbit9,pad,spec.sr1,spec.sr2,spec.srstep, ...
            options.Red,options.NSim,options.Method,common{:});
    case 'cv'
        cv = cvcoco(data,orbit9,pad,spec.sr1,spec.sr2,spec.srstep, ...
            options.Red,options.NSim,options.Method,common{:}, ...
            'TargetModel','four-group');
    case 'cvlegacy'
        cv = cvcocoLegacy(data,orbit9,pad,spec.sr1,spec.sr2,spec.srstep, ...
            options.Red,options.NSim,options.Method,common{:});
    otherwise
        error('runCocoEightMethodExperiment:UnknownCVMethod', ...
            'Unknown cv method id %s.',task.id);
end
end

function [row,report] = summarizeCv(spec,task,cv,options)
rateAtoB = cv.validateAtoB.bestRate;
rateBtoA = cv.validateBtoA.bestRate;
bestRate = mean([rateAtoB,rateBtoA],'omitnan');
pGlobal = max([cv.pA,cv.pB]);
significant = isfinite(pGlobal) && pGlobal < 0.05;
targetHit = cvRatesHitExpectedWindows( ...
    rateAtoB,rateBtoA,spec.category,spec.expectedWindows);
if strcmp(spec.category,'noise')
    targetHit = ~significant;
end
conclusion = sprintf([ ...
    '%s: A->B best rate %.6g cm/kyr; B->A best rate %.6g cm/kyr; ', ...
    'p_robust=max(p_A,p_B)=%.6g; significant(p<0.05)=%s; ', ...
    'pre-registered target criterion=%s.'],task.title,rateAtoB, ...
    rateBtoA,pGlobal,yesNo(significant),yesNo(targetHit));
row = baseSummaryRow(spec,task,options);
row.best_rate = bestRate;
row.best_rate_a_to_b = rateAtoB;
row.best_rate_b_to_a = rateBtoA;
row.p_global = pGlobal;
row.p_a = cv.pA;
row.p_b = cv.pB;
row.p_symmetric = cv.pSym;
row.significant = significant;
row.target_hit = targetHit;
row.conclusion = conclusion;
report = struct('bestRate',bestRate,'bestRateAtoB',rateAtoB, ...
    'bestRateBtoA',rateBtoA,'minimumGlobalP',pGlobal, ...
    'significant',significant,'message',conclusion);
end

function [row,report] = summarizeFullRecord( ...
        spec,task,corrCI,corrH0,details,options)
valid = isfinite(corrCI(:,2));
if ~any(valid)
    error('runCocoEightMethodExperiment:NoFiniteCorrelation', ...
        '%s produced no finite correlation.',task.title);
end
indices = find(valid);
[bestCorrelation,localIndex] = max(corrCI(valid,2));
bestIndex = indices(localIndex);
bestRate = corrCI(bestIndex,1);
pGlobal = corrH0(bestIndex,1);
significant = isfinite(pGlobal) && pGlobal < 0.05;
targetHit = rateInExpectedWindows(bestRate,spec.expectedWindows);
if strcmp(spec.category,'noise')
    targetHit = ~significant;
end
conclusion = sprintf([ ...
    '%s: best rate %.6g cm/kyr; maximum correlation %.6g; ', ...
    'full-search global p=%.6g; significant(p<0.05)=%s; ', ...
    'pre-registered target criterion=%s.'],task.title,bestRate, ...
    bestCorrelation,pGlobal,yesNo(significant),yesNo(targetHit));
row = baseSummaryRow(spec,task,options);
row.best_rate = bestRate;
row.p_global = pGlobal;
row.significant = significant;
row.target_hit = targetHit;
row.conclusion = conclusion;
report = struct('bestRate',bestRate,'bestCorrelation',bestCorrelation, ...
    'minimumGlobalP',pGlobal,'significant',significant, ...
    'message',conclusion,'targetMode',details.targetMode);
end

function entries = exportMethodFigures( ...
        task,analysis,spec,figureDirectory,outputRoot,options)
if strcmp(task.family,'cv')
    figures = plotcvcoco(analysis.result,'ShowSpectra',true);
    figureKinds = {'held-out spectra','rate curves','Monte Carlo audit'};
    captionDetails = { ...
        'midpoint-held-out data segments and reciprocal validation spectra', ...
        'training and held-out sedimentation-rate correlation/significance curves', ...
        'full-pipeline stationary AR(1) Monte Carlo null audit'};
    heights = [13,20,18];
else
    figures = plotAdaptiveCocoPublication( ...
        analysis.corrCI,analysis.corrH0,analysis.details,analysis.report, ...
        'TitlePrefix',sprintf('%s: %s',spec.title,task.title), ...
        'Visible',options.Visible);
    figureKinds = {'rate curves','Monte Carlo audit'};
    captionDetails = { ...
        'full-record correlation, global/local p-value, and participation curves', ...
        'full-search stationary AR(1) Monte Carlo maximum-statistic audit'};
    heights = [20,13];
end
if numel(figures) ~= numel(figureKinds)
    error('runCocoEightMethodExperiment:UnexpectedFigureCount', ...
        '%s returned %d standard figures; expected %d.', ...
        task.title,numel(figures),numel(figureKinds));
end
entries = repmat(emptyFigureEntry(),numel(figures),1);
for ii = 1:numel(figures)
    figureNumber = sprintf('%s_%02d',task.id,ii);
    stem = sprintf('%s_%s',figureNumber,sanitizeFilename(figureKinds{ii}));
    path = fullfile(figureDirectory,[stem,'.png']);
    titleText = sprintf('%s — %s — %s', ...
        spec.title,task.title,figureKinds{ii});
    caption = sprintf('%s. %s (%s; red=%d; N_{MC}=%d; seed=%d).', ...
        titleText,captionDetails{ii},options.Method,options.Red, ...
        options.NSim,options.Seed);
    fig = figures(ii);
    set(fig,'Color','w','Visible',options.Visible,'Units','centimeters', ...
        'Position',[1,1,18,heights(ii)]);
    drawnow;
    exportgraphics(fig,path,'Resolution',300,'BackgroundColor','white');
    entries(ii) = emptyFigureEntry();
    entries(ii).path = relativePath(path,outputRoot);
    entries(ii).caption = caption;
    entries(ii).title = titleText;
    entries(ii).method = task.title;
    if options.CloseFigures && isgraphics(fig)
        close(fig);
    end
end
end

function writeMethodCurves(path,analysis)
if strcmp(analysis.family,'cv')
    cv = analysis.result;
    header = {'sedimentation_rate_cm_per_kyr','train_A','train_B', ...
        'validate_A_to_B','validate_B_to_A','global_p_A_to_B', ...
        'global_p_B_to_A','local_p_A_to_B','local_p_B_to_A'};
    values = [cv.srGrid(:),cv.trainA.curve(:),cv.trainB.curve(:), ...
        cv.validateAtoB.curve(:),cv.validateBtoA.curve(:), ...
        cv.pCurveAtoB(:),cv.pCurveBtoA(:), ...
        cv.pLocalCurveAtoB(:),cv.pLocalCurveBtoA(:)];
else
    header = {'sedimentation_rate_cm_per_kyr','correlation', ...
        'parametric_p_descriptive','missing_periods','global_p', ...
        'participating_periods','local_mc_p'};
    values = [analysis.corrCI(:,1:4),analysis.corrH0(:,1:3)];
end
writeNumericCsvAtomic(path,header,values);
end

function plan = defaultDatasetPlan(inputRoot)
items = {
    'noise200','200-point red noise','noise', ...
    'SigGen-rednoise-1std-0mean-0.5alpha200.txt',0,13,100,0.2, ...
    'none (negative control)',zeros(0,2),NaN;
    'noise80m','80-m red noise','noise','rednoise0.5-80m.csv', ...
    0,0.1,20,0.1,'none (negative control)',zeros(0,2),NaN;
    'la04_2myr','La2004 ETP, 55-57 Ma, 4 cm/kyr','theory', ...
    'la04etp55-57masr4cmkyr.txt',56,0.1,20,0.1, ...
    '4 cm/kyr (hit window 3.5-4.5)',[3.5,4.5],NaN;
    'la04_2myr_red','La2004 ETP + red noise, 55-57 Ma, 4 cm/kyr','theory', ...
    'la04etp55-57masr4cmkyr+Red0.7.txt',56,0.1,20,0.1, ...
    '4 cm/kyr (hit window 3.5-4.5)',[3.5,4.5],NaN;
    'la04_5myr_red','La2004 1E1T1P + red noise, 54-59 Ma, 4 cm/kyr','theory', ...
    'La2004-1E1T-1P-54-59Ma-4cmkyr+Red0.7.txt',56,0.1,20,0.1, ...
    '4 cm/kyr (hit window 3.5-4.5)',[3.5,4.5],NaN;
    'la04_variable_4_6','La2004 ETP + red noise, variable 4 to 6 cm/kyr','stress', ...
    'la04etp54-59ma4-6cmka-rsp0.04+Red0.7.txt',56,0.1,20,0.1, ...
    ['4 cm/kyr first half; 6 cm/kyr second half ', ...
     '(stress-test windows 3.5-4.5 and 5.5-6.5)'], ...
    [3.5,4.5;5.5,6.5],NaN;
    '1262','ODP Site 1262 XRF Fe','real', ...
    '1262XRF-Fe-log10-s.u.-111-170-rsp0.02-10-rLOESS-dpks-rsp0.04.txt', ...
    56,0.1,10,0.02,'1-1.3 cm/kyr',[1,1.3],NaN;
    'newark','Newark 2-km record','real','newark2km-s-rsp0.85.txt', ...
    210,1,40,0.1,'approximately 15 cm/kyr (plus/minus 20%)',[12,18],0.85;
    'givetian','Givetian DD14 record','real', ...
    'GivetianDD14-s.u.-rsp0.3-log10-80-rLOESS.txt',385,1,20,0.05, ...
    'approximately 8 cm/kyr (plus/minus 20%)',[6.4,9.6],NaN};
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
    plan(ii).expected_rate = items{ii,9};
    plan(ii).expectedWindows = items{ii,10};
    plan(ii).reconstructSpacing = items{ii,11};
end
end

function methods = methodPlan()
items = {
    'cv9a','cvCOCO9A','cv','';
    'cv9b','cvCOCO9B','cv','';
    'cv','cvCOCO','cv','';
    'cvlegacy','cvCOCO Legacy','cv','';
    'adaptive9a','Adaptive COCO9A','full-record','adaptive9a';
    'adaptive9b','Adaptive COCO9B','full-record','adaptive9b';
    'adaptive','Adaptive COCO','full-record','adaptive';
    'fixed9','Fixed COCO9','full-record','fixed9'};
methods = repmat(struct('id','','title','','family','','targetMode',''), ...
    size(items,1),1);
for ii = 1:size(items,1)
    methods(ii).id = items{ii,1};
    methods(ii).title = items{ii,2};
    methods(ii).family = items{ii,3};
    methods(ii).targetMode = items{ii,4};
end
end

function plan = normalizeDatasetPlan(plan,inputRoot)
required = {'id','title','category','age_ma','sr1','sr2','srstep', ...
    'expected_rate'};
for ii = 1:numel(plan)
    missing = required(~isfield(plan(ii),required));
    if ~isempty(missing)
        error('runCocoEightMethodExperiment:IncompleteDatasetPlan', ...
            'DatasetPlan item %d is missing: %s.',ii,strjoin(missing,', '));
    end
    if ~isfield(plan(ii),'filename'), plan(ii).filename = ''; end
    if ~isfield(plan(ii),'input_file') || isempty(plan(ii).input_file)
        plan(ii).input_file = fullfile(inputRoot,plan(ii).filename);
    end
    if ~isfield(plan(ii),'expectedWindows')
        plan(ii).expectedWindows = zeros(0,2);
    end
    if ~isfield(plan(ii),'reconstructSpacing')
        plan(ii).reconstructSpacing = NaN;
    end
end
end

function selected = selectItems(items,requested,kind)
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
ids = string({items.id});
missing = setdiff(requested,ids);
if ~isempty(missing)
    error('runCocoEightMethodExperiment:UnknownSelection', ...
        'Unknown %s id(s): %s.',kind,strjoin(missing,', '));
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
row.status = 'complete';
row.nsim = options.NSim;
row.seed = options.Seed;
row.red = options.Red;
end

function row = failedSummaryRow(spec,task,exception)
row = emptySummaryRow();
row.dataset_id = spec.id;
row.dataset_title = spec.title;
row.category = spec.category;
row.expected_rate = spec.expected_rate;
row.method = task.title;
row.method_id = task.id;
row.status = 'failed';
row.conclusion = sprintf('FAILED: %s (%s)', ...
    exception.message,exception.identifier);
end

function row = emptySummaryRow()
row = struct('dataset_id','','dataset_title','','category','', ...
    'expected_rate','','method','','method_id','','status','', ...
    'best_rate',NaN,'best_rate_a_to_b',NaN,'best_rate_b_to_a',NaN, ...
    'p_global',NaN,'p_a',NaN,'p_b',NaN,'p_symmetric',NaN, ...
    'significant',false,'target_hit',false,'nsim',NaN,'seed',NaN, ...
    'red',NaN,'conclusion','');
end

function item = emptyDataset()
item = struct('id','','title','','category','','filename','', ...
    'input_file','','age_ma',NaN,'sr1',NaN,'sr2',NaN,'srstep',NaN, ...
    'expected_rate','','expectedWindows',zeros(0,2), ...
    'reconstructSpacing',NaN);
end

function item = emptyCaseManifest()
item = struct('id','','title','','category','','expected_rate','', ...
    'age_ma',NaN,'input_file','','input_sha256','','case_dir','', ...
    'parameters_csv','','summary_csv','','conclusion_txt','', ...
    'figures',repmat(emptyFigureEntry(),0,1),'status','pending', ...
    'updated_at','');
end

function entry = emptyFigureEntry()
entry = struct('path','','caption','','title','','method','');
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
if isempty(windows) || ~isfinite(rate)
    tf = false;
    return
end
validateattributes(windows,{'numeric'},{'2d','ncols',2,'finite'});
tf = any(rate >= windows(:,1) & rate <= windows(:,2));
end

function tf = cvRatesHitExpectedWindows(rateA,rateB,category,windows)
if strcmp(category,'stress') && size(windows,1) == 2
    aFirst = rateA >= windows(1,1) && rateA <= windows(1,2);
    aSecond = rateA >= windows(2,1) && rateA <= windows(2,2);
    bFirst = rateB >= windows(1,1) && rateB <= windows(1,2);
    bSecond = rateB >= windows(2,1) && rateB <= windows(2,2);
    tf = (aFirst && bSecond) || (aSecond && bFirst);
else
    tf = rateInExpectedWindows(rateA,windows) && ...
        rateInExpectedWindows(rateB,windows);
end
end

function path = resolveInputFile(spec,inputRoot)
path = char(string(spec.input_file));
if isempty(path)
    path = fullfile(inputRoot,char(string(spec.filename)));
end
if ~isfile(path)
    error('runCocoEightMethodExperiment:InputFileMissing', ...
        'Input file does not exist: %s',path);
end
end

function pad = defaultGuiPad(npts)
if npts <= 2500
    pad = 5000;
elseif npts <= 5000
    pad = 10000;
else
    pad = fix(npts/5000)*5000+5000;
end
end

function digest = engineFingerprint(task)
paths = {mfilename('fullpath')};
if strcmp(task.family,'cv')
    paths{end+1} = which('cvcoco');
    if strcmp(task.id,'cv9a'), paths{end+1} = which('cvcoco9A'); end
    if strcmp(task.id,'cv9b'), paths{end+1} = which('cvcoco9B'); end
    if strcmp(task.id,'cvlegacy'), paths{end+1} = which('cvcocoLegacy'); end
else
    paths{end+1} = which('corrcoefslices_rankNew');
    paths{end+1} = which('cocoAdaptiveEvaluate');
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
    tf = tf && isfile(fullfile(root,entries(ii).path));
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
tableValue = struct2table(rows);
writeTableAtomic(path,tableValue);
end

function writeTableAtomic(path,value)
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.csv'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writetable(value,temporary,'Encoding','UTF-8');
finalizeAtomicFile(temporary,path);
clear cleanup
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

function writeCellAtomic(path,value)
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.csv'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writecell(value,temporary);
finalizeAtomicFile(temporary,path);
clear cleanup
end

function writeJsonAtomic(path,value)
writeTextAtomic(path,jsonencode(value,'PrettyPrint',true));
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
    error('runCocoEightMethodExperiment:FileOpenFailed', ...
        'Could not open temporary output for %s.',path);
end
fileCleanup = onCleanup(@()fclose(file));
fprintf(file,'%s',char(string(value)));
clear fileCleanup
finalizeAtomicFile(temporary,path);
clear cleanup
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
    error('runCocoEightMethodExperiment:AtomicSaveFailed', ...
        'Could not finalize %s: %s',destination,message);
end
end

function ensureDirectory(path)
if ~isempty(path) && ~isfolder(path)
    [ok,message] = mkdir(path);
    if ~ok
        error('runCocoEightMethodExperiment:DirectoryCreateFailed', ...
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

function value = yesNo(tf)
if tf, value = 'YES'; else, value = 'NO'; end
end

function text = exceptionReport(exception)
text = getReport(exception,'extended','hyperlinks','off');
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
