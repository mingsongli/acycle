function runSummary = runCocoPublicationValidation(outputRoot,varargin)
%RUNCOCOPUBLICATIONVALIDATION Reproducible non-GUI COCO publication suite.
%
% RUNSUMMARY = RUNCOCOPUBLICATIONVALIDATION(OUTPUTROOT) analyzes the six
% pre-registered validation records with confirmatory cvCOCO and
% exploratory Adaptive COCO.  Every method is checkpointed independently.
% The suite writes MAT and XLSX numerical results, CSV parameter/summary
% tables, plain-text conclusions, editable FIG files, vector PDF figures,
% and 600-dpi PNG figures.  Figure width is fixed at 180 mm (full column).
% Root and per-case JSON manifests are suitable for automated Word report
% construction.  No GUI is created or required.
%
% Important name-value options:
%   InputRoot       base directory containing the six records
%   NSim            Monte Carlo realizations (default 9999)
%   Seed            reproducible random seed (default 20260713)
%   Red             primary background option (default 2, robust AR(1))
%   SensitivityRed  optional sensitivity background option (default 0;
%                   pass [] to disable)
%   DatasetIDs      subset of case ids to run (default all)
%   Resume          reuse signature-matched checkpoints (default true)
%   ContinueOnError continue with remaining methods/cases (default true)
%   RunCV           run confirmatory cvCOCO (default true)
%   RunAdaptive     run exploratory Adaptive COCO (default true)
%   ExportFigures   write FIG/PDF/PNG artifacts (default true)
%   DatasetPlan     caller-supplied plan structure (default registered six)
%
% The default rate grids and expected-rate statements are encoded by
% DEFAULTDATASETPLAN near the end of this file and are also saved before
% calculation.  Existing checkpoints are accepted only if their complete
% input/settings/code signature matches the current request.

validateattributes(outputRoot,{'char','string'},{'scalartext','nonempty'}, ...
    mfilename,'outputRoot',1);
outputRoot = char(string(outputRoot));

parser = inputParser;
parser.FunctionName = mfilename;
defaultInputRoot = ['/Users/msli/Dropbox/Research/', ...
    '_通用方法火山构造波动/202606COCO'];
addParameter(parser,'InputRoot',defaultInputRoot,@isScalarText);
addParameter(parser,'NSim',9999,@isNonnegativeInteger);
addParameter(parser,'NSimSensitivity',[],@(x) isempty(x) || isNonnegativeInteger(x));
addParameter(parser,'Seed',20260713,@isSeed);
addParameter(parser,'Red',2,@isRedOption);
addParameter(parser,'SensitivityRed',0,@(x) isempty(x) || isRedOption(x));
addParameter(parser,'Method','Pearson',@isScalarText);
addParameter(parser,'Slices',1,@isPositiveInteger);
addParameter(parser,'BatchSize',100,@isPositiveInteger);
addParameter(parser,'MaxFrequencyScale',1.2,@isPositiveScalar);
addParameter(parser,'DatasetIDs',strings(0,1),@(x) ischar(x) || isstring(x) || iscellstr(x));
addParameter(parser,'Resume',true,@isLogicalScalar);
addParameter(parser,'ContinueOnError',true,@isLogicalScalar);
addParameter(parser,'RunCV',true,@isLogicalScalar);
addParameter(parser,'RunAdaptive',true,@isLogicalScalar);
addParameter(parser,'ExportFigures',true,@isLogicalScalar);
addParameter(parser,'CloseFigures',true,@isLogicalScalar);
addParameter(parser,'Visible','off',@isScalarText);
addParameter(parser,'DatasetPlan',struct([]),@(x) isempty(x) || isstruct(x));
parse(parser,varargin{:});
options = parser.Results;
options.InputRoot = char(string(options.InputRoot));
options.Method = validatestring(char(string(options.Method)), ...
    {'Pearson','Spearman'},mfilename,'Method');
options.Visible = validatestring(char(string(options.Visible)),{'on','off'});
options.Resume = logical(options.Resume);
options.ContinueOnError = logical(options.ContinueOnError);
options.RunCV = logical(options.RunCV);
options.RunAdaptive = logical(options.RunAdaptive);
options.ExportFigures = logical(options.ExportFigures);
options.CloseFigures = logical(options.CloseFigures);
if isempty(options.NSimSensitivity)
    options.NSimSensitivity = options.NSim;
end
if ~options.RunCV && ~options.RunAdaptive
    error('runCocoPublicationValidation:NoMethodSelected', ...
        'At least one of RunCV or RunAdaptive must be true.');
end
if options.MaxFrequencyScale < 1
    error('runCocoPublicationValidation:MaximumFrequencyScaleTooSmall', ...
        ['MaxFrequencyScale must be at least one so that every nominal ', ...
         'astronomical frequency remains inside the correlation interval.']);
end
if options.NSim < 1
    error('runCocoPublicationValidation:MonteCarloRequired', ...
        'Publication conclusion reports require NSim >= 1.');
end
if ~isempty(options.SensitivityRed) && options.NSimSensitivity < 1
    error('runCocoPublicationValidation:SensitivityMonteCarloRequired', ...
        'NSimSensitivity must be at least one when SensitivityRed is enabled.');
end

if isempty(options.DatasetPlan)
    plan = defaultDatasetPlan(options.InputRoot);
else
    plan = normalizeDatasetPlan(options.DatasetPlan,options.InputRoot);
end
if ischar(options.DatasetIDs)
    requestedIDs = string({options.DatasetIDs});
else
    requestedIDs = string(options.DatasetIDs(:));
end
requestedIDs = requestedIDs(strlength(requestedIDs) > 0);
if ~isempty(requestedIDs)
    keep = ismember(string({plan.id}),requestedIDs);
    missingIDs = setdiff(requestedIDs,string({plan.id}));
    if ~isempty(missingIDs)
        error('runCocoPublicationValidation:UnknownDatasetID', ...
            'Unknown DatasetIDs: %s.',strjoin(missingIDs,', '));
    end
    plan = plan(keep);
end
if isempty(plan)
    error('runCocoPublicationValidation:EmptyDatasetPlan', ...
        'No datasets remain in the requested publication plan.');
end

ensureDirectory(outputRoot);
outputRoot = canonicalFilesystemPath(outputRoot);
logFile = fullfile(outputRoot,'run.log');
repositoryRoot = repositoryDirectory();
codeAudit = codeFingerprint(repositoryRoot);
gitInfo = gitMetadata(repositoryRoot);
runStarted = timestampNow();
appendLog(logFile,'Publication validation started: %s',runStarted);
appendLog(logFile,'Output root: %s',outputRoot);
appendLog(logFile,'MATLAB: %s',version);

previousFigureVisibility = get(groot,'defaultFigureVisible');
visibilityCleanup = onCleanup(@()set(groot,'defaultFigureVisible', ...
    previousFigureVisibility));
set(groot,'defaultFigureVisible',options.Visible);

manifest = struct;
manifest.schema_version = 1;
manifest.title = 'COCO publication validation suite';
manifest.created_at = runStarted;
manifest.updated_at = runStarted;
manifest.status = 'running';
manifest.output_root = outputRoot;
manifest.repository = repositoryRoot;
manifest.git_head = gitInfo.head;
manifest.git_status = gitInfo.status;
manifest.matlab_version = version;
manifest.artifact_sha256_csv = 'artifact_sha256.csv';
manifest.combined_report_docx = 'COCO_publication_validation_report.docx';
manifest.options = publicOptions(options);
manifest.code_fingerprint = codeAudit;
manifest.cases = repmat(emptyCaseManifest(),0,1);
writeRootManifest(fullfile(outputRoot,'manifest.json'),manifest);

caseManifests = repmat(emptyCaseManifest(),numel(plan),1);
fatalException = [];
for caseIndex = 1:numel(plan)
    spec = plan(caseIndex);
    fprintf('\n============================================================\n');
    fprintf('COCO publication case %d/%d: %s\n',caseIndex,numel(plan),spec.title);
    fprintf('============================================================\n');
    appendLog(logFile,'Case %d/%d started: %s',caseIndex,numel(plan),spec.id);
    try
        caseManifests(caseIndex) = runOneCase( ...
            spec,caseIndex,outputRoot,options,codeAudit,gitInfo,logFile);
    catch exception
        caseManifests(caseIndex) = failedCaseManifest( ...
            spec,caseIndex,outputRoot,exception);
        appendLog(logFile,'Case %s failed: %s (%s)', ...
            spec.id,exception.message,exception.identifier);
        if ~options.ContinueOnError
            fatalException = exception;
        end
    end
    manifest.cases = caseManifests(1:caseIndex);
    manifest.updated_at = timestampNow();
    manifest.status = suiteStatus(manifest.cases,caseIndex,numel(plan));
    writeRootManifest(fullfile(outputRoot,'manifest.json'),manifest);
    writeRootSummary(outputRoot,manifest.cases);
    if ~isempty(fatalException)
        break
    end
end

manifest.cases = caseManifests;
manifest.updated_at = timestampNow();
manifest.status = finalSuiteStatus(caseManifests);
writeRootManifest(fullfile(outputRoot,'manifest.json'),manifest);
writeRootSummary(outputRoot,caseManifests);
runSummary = manifest;
saveStructAtomic(fullfile(outputRoot,'run_summary.mat'), ...
    struct('runSummary',runSummary));
appendLog(logFile,'Publication validation finished with status %s: %s', ...
    manifest.status,manifest.updated_at);
writeArtifactInventory(outputRoot,manifest.artifact_sha256_csv);
clear visibilityCleanup
if ~isempty(fatalException)
    rethrow(fatalException)
end
end

function caseManifest = runOneCase( ...
        spec,index,outputRoot,options,codeAudit,gitInfo,rootLog)
inputFile = resolveInputFile(spec);
inputHash = sha256File(inputFile);
raw = readmatrix(inputFile);
if ~isnumeric(raw) || isempty(raw) || size(raw,2) < 2
    error('runCocoPublicationValidation:InvalidInputFile', ...
        'Input file %s did not yield at least two numeric columns.',inputFile);
end
raw = raw(:,1:2);
[adaptiveData,preprocessing] = cocoPublicationPrepareData(raw,spec.title);
orbitMatrix = calculate_orbit9(spec.age_ma);
orbit9 = orbitMatrix(:,2)/1000;
if numel(orbit9) ~= 9 || any(~isfinite(orbit9) | orbit9 <= 0)
    error('runCocoPublicationValidation:InvalidOrbitCalculation', ...
        'calculate_orbit9 did not return nine positive periods for %s.',spec.id);
end
pad = spec.pad;
if isempty(pad) || ~isfinite(pad)
    pad = 2^nextpow2(size(adaptiveData,1));
end
pad = max(pad,size(adaptiveData,1));
dt = median(diff(adaptiveData(:,1)));
maximumFrequency = options.MaxFrequencyScale*max(1./orbit9);
spatialNyquist = 1/(2*dt);

caseName = sprintf('%02d_%s',index,sanitizeFilename(spec.id));
caseDirectory = fullfile(outputRoot,caseName);
methodFigureDirectory = fullfile(caseDirectory,'figures');
ensureDirectory(caseDirectory);
ensureDirectory(methodFigureDirectory);
caseLog = fullfile(caseDirectory,'run.log');
appendLog(caseLog,'Case started: %s',timestampNow());
appendLog(caseLog,'Input: %s',inputFile);
appendLog(caseLog,'Input SHA-256: %s',inputHash);

parameters = struct;
parameters.case_id = spec.id;
parameters.title = spec.title;
parameters.input_file = inputFile;
parameters.input_sha256 = inputHash;
parameters.age_ma = spec.age_ma;
parameters.expected_rate = spec.expected_rate;
parameters.rate_min_cm_per_kyr = spec.sr1;
parameters.rate_max_cm_per_kyr = spec.sr2;
parameters.rate_step_cm_per_kyr = spec.srstep;
parameters.pad = pad;
parameters.median_depth_spacing_m = dt;
parameters.maximum_temporal_frequency_cycle_per_kyr = maximumFrequency;
parameters.orbit_periods_kyr = orbit9(:)';
parameters.primary_red_option = options.Red;
parameters.sensitivity_red_option = options.SensitivityRed;
parameters.nsim_primary = options.NSim;
parameters.nsim_sensitivity = options.NSimSensitivity;
parameters.seed = options.Seed;
parameters.correlation_method = options.Method;
parameters.slices = options.Slices;
parameters.cv_target_model = 'four-group';
parameters.adaptive_target_model = 'adaptive phase-averaged noncoherent';
parameters.preprocessing = preprocessing;
parameters.git_head = gitInfo.head;
parameters.git_status = gitInfo.status;
parameters.matlab_version = version;
parameters.code_fingerprint = codeAudit;
parameterRows = flattenStruct(parameters,'');
writeCellAtomic(fullfile(caseDirectory,'parameters.csv'), ...
    [{'Parameter','Value'};parameterRows]);
saveStructAtomic(fullfile(caseDirectory,'parameters.mat'), ...
    struct('parameters',parameters,'orbitMatrix',orbitMatrix));
writeNumericCsvAtomic(fullfile(caseDirectory,'preprocessed_input.csv'), ...
    {'Depth_m','Value'},adaptiveData);

caseSignatureBase = struct( ...
    'schema',1,'inputSHA256',inputHash,'caseID',spec.id, ...
    'ageMa',spec.age_ma,'rateGrid',[spec.sr1,spec.sr2,spec.srstep], ...
    'pad',pad,'orbit9',orbit9(:)','seed',options.Seed, ...
    'method',options.Method,'slices',options.Slices, ...
    'maximumFrequency',maximumFrequency,'codeFingerprint',codeAudit);

tasks = methodTasks(options);
methodRecords = repmat(emptyMethodRecord(),numel(tasks),1);
summaryRows = cell(0,18);
conclusionBlocks = strings(0,1);
figureEntries = repmat(emptyFigureEntry(),0,1);
for taskIndex = 1:numel(tasks)
    task = tasks(taskIndex);
    methodDirectory = fullfile(caseDirectory,task.folder);
    ensureDirectory(methodDirectory);
    methodSignature = caseSignatureBase;
    methodSignature.engine = task.engine;
    methodSignature.role = task.role;
    methodSignature.red = task.red;
    methodSignature.nsim = task.nsim;
    signature = jsonencode(methodSignature);
    appendLog(caseLog,'Method started: %s, red=%d, N=%d', ...
        task.engine,task.red,task.nsim);
    try
        if strcmp(task.engine,'cvCOCO')
            [record,row,block,figures] = runCvTask( ...
                raw,orbit9,pad,spec,task,signature,methodDirectory, ...
                methodFigureDirectory,outputRoot,options,maximumFrequency);
        else
            [record,row,block,figures] = runAdaptiveTask( ...
                adaptiveData,preprocessing,orbit9,pad,dt,spatialNyquist, ...
                spec,task,signature,methodDirectory,methodFigureDirectory, ...
                outputRoot,options,maximumFrequency);
        end
        methodRecords(taskIndex) = record;
        summaryRows(end+1,:) = row; %#ok<AGROW>
        conclusionBlocks(end+1,1) = block; %#ok<AGROW>
        figureEntries = [figureEntries;figures(:)]; %#ok<AGROW>
        appendLog(caseLog,'Method completed: %s (%s)',task.folder,record.status);
    catch exception
        methodRecords(taskIndex) = failedMethodRecord(task,exception);
        summaryRows(end+1,:) = failureSummaryRow(task,exception); %#ok<AGROW>
        conclusionBlocks(end+1,1) = sprintf( ...
            '%s [%s]\nFAILED: %s (%s)',task.engine,task.role, ...
            exception.message,exception.identifier); %#ok<AGROW>
        appendLog(caseLog,'Method failed: %s: %s (%s)', ...
            task.folder,exception.message,exception.identifier);
        appendLog(rootLog,'Case %s method %s failed: %s', ...
            spec.id,task.folder,exception.message);
        if ~options.ContinueOnError
            rethrow(exception)
        end
    end
end

summaryHeader = {'method','analysis_role','red_option','status', ...
    'classification','pass','best_rate_A_to_B_cm_per_kyr', ...
    'best_rate_B_to_A_cm_per_kyr','best_rate_cm_per_kyr', ...
    'p_A','p_B','p_robust','p_sym','minimum_global_p', ...
    'local_p_at_best','participating_periods_at_best', ...
    'expected_rate','conclusion'};
writeCellAtomic(fullfile(caseDirectory,'summary.csv'), ...
    [summaryHeader;summaryRows]);
writeTextAtomic(fullfile(caseDirectory,'conclusion.txt'), ...
    strjoin(conclusionBlocks,string(newline)+string(newline)));

caseManifest = emptyCaseManifest();
caseManifest.id = spec.id;
caseManifest.title = spec.title;
caseManifest.input_file = inputFile;
caseManifest.input_sha256 = inputHash;
caseManifest.age_ma = spec.age_ma;
caseManifest.expected_rate = spec.expected_rate;
caseManifest.case_dir = caseName;
caseManifest.parameters_csv = fullfile(caseName,'parameters.csv');
caseManifest.summary_csv = fullfile(caseName,'summary.csv');
caseManifest.conclusion_txt = fullfile(caseName,'conclusion.txt');
caseManifest.case_report_docx = fullfile(caseName,'case_report.docx');
caseManifest.preprocessed_input_csv = ...
    fullfile(caseName,'preprocessed_input.csv');
caseManifest.figures = figureEntries;
caseManifest.methods = methodRecords;
caseManifest.status = caseStatus(methodRecords);
caseManifest.updated_at = timestampNow();
writeCaseManifest(fullfile(caseDirectory,'case_manifest.json'),caseManifest);
saveStructAtomic(fullfile(caseDirectory,'case_results_index.mat'), ...
    struct('caseManifest',caseManifest,'parameters',parameters));
appendLog(caseLog,'Case finished with status %s: %s', ...
    caseManifest.status,caseManifest.updated_at);
end

function [record,row,block,figureEntries] = runCvTask( ...
        raw,orbit9,pad,spec,task,signature,methodDirectory, ...
        figureDirectory,outputRoot,options,maximumFrequency)
checkpointFile = fullfile(methodDirectory,'checkpoint.mat');
resultFile = fullfile(methodDirectory,'results.mat');
workbook = fullfile(methodDirectory,'results.xlsx');
conclusionFile = fullfile(methodDirectory,'conclusion.txt');
checkpoint = loadCheckpoint(checkpointFile);
reuse = options.Resume && checkpointMatches(checkpoint,signature) && ...
    isfile(resultFile);
try
    if reuse
        saved = load(resultFile,'cv','report','signature');
        if ~isfield(saved,'signature') || ~strcmp(saved.signature,signature)
            reuse = false;
        end
    end
    if ~reuse
        checkpoint = runningCheckpoint(signature,task);
        saveStructAtomic(checkpointFile,struct('checkpoint',checkpoint));
        cv = cvcoco(raw,orbit9,pad,spec.sr1,spec.sr2,spec.srstep, ...
            task.red,task.nsim,options.Method,'BatchSize',options.BatchSize, ...
            'Seed',options.Seed,'TargetModel','four-group', ...
            'AnalysisName','cvCOCO','MaxFrequency',maximumFrequency, ...
            'ProgressFcn',[]);
        report = cocoConclusionReport('confirmatory',cv);
        cv.conclusion = report;
        cv.pRobust = report.pRobust;
        cv.confirmatoryPass = report.pass;
        saveStructAtomic(resultFile, ...
            struct('cv',cv,'report',report,'signature',signature));
        checkpoint.status = 'calculated';
        checkpoint.updated_at = timestampNow();
        saveStructAtomic(checkpointFile,struct('checkpoint',checkpoint));
    else
        cv = saved.cv;
        report = saved.report;
    end

    writeCvWorkbook(workbook,cv,report,spec,task);
    writeTextAtomic(conclusionFile,report.message);
    figureEntries = repmat(emptyFigureEntry(),0,1);
    if options.ExportFigures
        [figures,stems,captions,heights] = createCvFigures(cv,spec,task);
        figureEntries = exportFigureSet(figures,stems,captions,heights, ...
            task,figureDirectory,outputRoot,options.CloseFigures);
    end
    checkpoint.status = 'complete';
    checkpoint.updated_at = timestampNow();
    checkpoint.result_file = resultFile;
    checkpoint.workbook = workbook;
    checkpoint.conclusion_file = conclusionFile;
    checkpoint.figures = figureEntries;
    checkpoint.error = '';
    saveStructAtomic(checkpointFile,struct('checkpoint',checkpoint));
catch exception
    checkpoint.signature = signature;
    checkpoint.status = 'failed';
    checkpoint.updated_at = timestampNow();
    checkpoint.error = exceptionReport(exception);
    saveStructAtomic(checkpointFile,struct('checkpoint',checkpoint));
    rethrow(exception)
end

record = emptyMethodRecord();
record.method = task.engine;
record.role = task.role;
record.red = task.red;
record.nsim = task.nsim;
record.status = 'complete';
record.classification = report.classification;
record.pass = report.pass;
record.result_file = relativePath(resultFile,outputRoot);
record.workbook = relativePath(workbook,outputRoot);
record.conclusion_file = relativePath(conclusionFile,outputRoot);
record.error = '';
row = cvSummaryRow(task,report,spec.expected_rate);
block = sprintf('%s [%s; red=%d]\n%s', ...
    task.engine,task.role,task.red,report.message);
end

function [record,row,block,figureEntries] = runAdaptiveTask( ...
        data,preprocessing,orbit9,pad,dt,spatialNyquist,spec,task, ...
        signature,methodDirectory,figureDirectory,outputRoot,options, ...
        maximumFrequency)
checkpointFile = fullfile(methodDirectory,'checkpoint.mat');
resultFile = fullfile(methodDirectory,'results.mat');
workbook = fullfile(methodDirectory,'results.xlsx');
conclusionFile = fullfile(methodDirectory,'conclusion.txt');
checkpoint = loadCheckpoint(checkpointFile);
reuse = options.Resume && checkpointMatches(checkpoint,signature) && ...
    isfile(resultFile);
try
    if reuse
        saved = load(resultFile,'adaptive','report','signature');
        if ~isfield(saved,'signature') || ~strcmp(saved.signature,signature)
            reuse = false;
        end
    end
    if ~reuse
        checkpoint = runningCheckpoint(signature,task);
        saveStructAtomic(checkpointFile,struct('checkpoint',checkpoint));
        [corrCI,corrH0,corry,details] = corrcoefslices_rankNew( ...
            data,orbit9,dt,pad,spec.sr1,spec.sr2,spec.srstep, ...
            0,task.red,task.nsim,0,options.Slices,options.Method, ...
            spatialNyquist,0,false,'adaptive', ...
            'MaxFrequency',maximumFrequency,'Seed',options.Seed, ...
            'ShowPeriodograms',false);
        report = cocoAdaptivePublicationReport(corrCI,corrH0,details);
        adaptive = struct('corrCI',corrCI,'corrH0',corrH0, ...
            'corry',corry,'details',details,'preprocessing',preprocessing, ...
            'data',data,'orbitPeriods',orbit9,'report',report);
        saveStructAtomic(resultFile, ...
            struct('adaptive',adaptive,'report',report,'signature',signature));
        checkpoint.status = 'calculated';
        checkpoint.updated_at = timestampNow();
        saveStructAtomic(checkpointFile,struct('checkpoint',checkpoint));
    else
        adaptive = saved.adaptive;
        report = saved.report;
    end

    writeAdaptiveWorkbook(workbook,adaptive,report,spec,task);
    writeTextAtomic(conclusionFile,report.message);
    figureEntries = repmat(emptyFigureEntry(),0,1);
    if options.ExportFigures
        titlePrefix = sprintf('%s: Adaptive COCO (%s, red=%d)', ...
            spec.title,task.role,task.red);
        figures = plotAdaptiveCocoPublication( ...
            adaptive.corrCI,adaptive.corrH0,adaptive.details,report, ...
            'TitlePrefix',titlePrefix,'Visible',options.Visible);
        stems = {sprintf('%s_Adaptive_COCO_curves',task.folder), ...
            sprintf('%s_Adaptive_COCO_MC_audit',task.folder)};
        captions = {sprintf([ ...
            '%s. Exploratory Adaptive COCO sedimentation-rate curves ', ...
            '(red-noise option %d).'],spec.title,task.red), ...
            sprintf([ ...
            '%s. Full-search stationary AR(1) null distribution for ', ...
            'exploratory Adaptive COCO (red-noise option %d).'], ...
            spec.title,task.red)};
        heights = [24,12];
        figureEntries = exportFigureSet(figures,stems,captions,heights, ...
            task,figureDirectory,outputRoot,options.CloseFigures);
    end
    checkpoint.status = 'complete';
    checkpoint.updated_at = timestampNow();
    checkpoint.result_file = resultFile;
    checkpoint.workbook = workbook;
    checkpoint.conclusion_file = conclusionFile;
    checkpoint.figures = figureEntries;
    checkpoint.error = '';
    saveStructAtomic(checkpointFile,struct('checkpoint',checkpoint));
catch exception
    checkpoint.signature = signature;
    checkpoint.status = 'failed';
    checkpoint.updated_at = timestampNow();
    checkpoint.error = exceptionReport(exception);
    saveStructAtomic(checkpointFile,struct('checkpoint',checkpoint));
    rethrow(exception)
end

record = emptyMethodRecord();
record.method = task.engine;
record.role = task.role;
record.red = task.red;
record.nsim = task.nsim;
record.status = 'complete';
record.classification = report.classification;
record.pass = report.pass;
record.result_file = relativePath(resultFile,outputRoot);
record.workbook = relativePath(workbook,outputRoot);
record.conclusion_file = relativePath(conclusionFile,outputRoot);
record.error = '';
row = adaptiveSummaryRow(task,report,spec.expected_rate);
block = sprintf('%s [%s; red=%d]\n%s', ...
    task.engine,task.role,task.red,report.message);
end

function [figures,stems,captions,heights] = createCvFigures(cv,spec,task)
figures = plotcvcoco(cv,'ShowSpectra',true);
stems = {sprintf('%s_cvCOCO_depth_validation',task.folder), ...
    sprintf('%s_cvCOCO_curves',task.folder), ...
    sprintf('%s_cvCOCO_MC_audit',task.folder)};
captions = {sprintf([ ...
    '%s. Midpoint-held-out segments and reciprocal frozen-target ', ...
    'validation spectra (cvCOCO; red-noise option %d).'], ...
    spec.title,task.red), ...
    sprintf([ ...
    '%s. Confirmatory cvCOCO directional correlations and global ', ...
    'significance, descriptive directional local p-values, and ', ...
    'participating-period geometry (red-noise option %d).'], ...
    spec.title,task.red), ...
    sprintf([ ...
    '%s. Full-pipeline bidirectional stationary AR(1) Monte Carlo audit ', ...
    'for cvCOCO (red-noise option %d).'],spec.title,task.red)};
heights = [15,24,24];
if numel(figures) ~= numel(stems)
    error('runCocoPublicationValidation:UnexpectedCVFigureCount', ...
        'plotcvcoco returned %d figures; expected %d.',numel(figures),numel(stems));
end
end

function entries = exportFigureSet(figures,stems,captions,heights, ...
        task,figureDirectory,outputRoot,closeFigures)
entries = repmat(emptyFigureEntry(),numel(figures),1);
for ii = 1:numel(figures)
    entries(ii) = exportPublicationFigure(figures(ii),stems{ii}, ...
        captions{ii},heights(ii),task,figureDirectory,outputRoot);
end
if closeFigures
    for ii = 1:numel(figures)
        if isgraphics(figures(ii))
            close(figures(ii));
        end
    end
end
end

function entry = exportPublicationFigure(fig,stem,caption,heightCm, ...
        task,figureDirectory,outputRoot)
if ~isgraphics(fig,'figure')
    error('runCocoPublicationValidation:InvalidFigure', ...
        'A publication figure handle is invalid.');
end
widthCm = 18; % 180 mm journal full-column limit
set(fig,'Color','w','Units','centimeters', ...
    'Position',[1,1,widthCm,heightCm], ...
    'PaperUnits','centimeters','PaperPosition',[0,0,widthCm,heightCm], ...
    'PaperSize',[widthCm,heightCm],'InvertHardcopy','off');
fontObjects = findall(fig,'-property','FontName');
for jj = 1:numel(fontObjects)
    try
        set(fontObjects(jj),'FontName','Arial');
    catch
    end
end
axesObjects = findall(fig,'Type','axes');
for jj = 1:numel(axesObjects)
    try
        set(axesObjects(jj),'FontSize',8,'LineWidth',0.75);
    catch
    end
end
drawnow;
stem = sanitizeFilename(stem);
figFile = fullfile(figureDirectory,[stem,'.fig']);
pdfFile = fullfile(figureDirectory,[stem,'.pdf']);
pngFile = fullfile(figureDirectory,[stem,'.png']);
savefig(fig,figFile);
try
    % PRINT honours PaperSize/PaperPosition and therefore preserves the
    % declared 180-mm physical width. EXPORTGRAPHICS can instead derive a
    % PDF page from on-screen pixel geometry on macOS/Retina displays,
    % yielding a vector page substantially wider than the journal limit.
    % PDF MediaBox dimensions are integer PostScript points in MATLAB's
    % PRINT path.  Use a 0.5-mm safety inset so rounding can never make the
    % physical page exceed the journal's strict 180-mm maximum.
    pdfWidthCm = min(widthCm,17.95);
    pdfHeightCm = heightCm*pdfWidthCm/widthCm;
    set(fig,'PaperPosition',[0,0,pdfWidthCm,pdfHeightCm], ...
        'PaperSize',[pdfWidthCm,pdfHeightCm]);
    print(fig,pdfFile,'-dpdf','-vector','-r600');
catch
    exportgraphics(fig,pdfFile,'ContentType','vector', ...
        'BackgroundColor','white');
end
exportgraphics(fig,pngFile,'Resolution',600,'BackgroundColor','white');

entry = emptyFigureEntry();
entry.path = relativePath(pngFile,outputRoot);
entry.pdf_path = relativePath(pdfFile,outputRoot);
entry.fig_path = relativePath(figFile,outputRoot);
entry.caption = caption;
entry.width = 'full';
entry.width_mm = 180;
entry.method = task.engine;
entry.role = task.role;
entry.red = task.red;
end

function writeCvWorkbook(path,cv,report,spec,task)
temporary = [tempname(fileparts(path)),'.xlsx'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
summaryRows = normalizeKeyValueRows(report.summaryRows);
extra = {
    'Dataset',spec.title;
    'Expected sedimentation rate',spec.expected_rate;
    'Red-noise option',task.red;
    'Monte Carlo simulations',task.nsim;
    'Random seed',cv.seed;
    'Split depth (m)',cv.splitDepth;
    'Segment A interpolation applied',logicalText(cv.interpolationA.applied);
    'Segment B interpolation applied',logicalText(cv.interpolationB.applied);
    'Shared all-nine range (cm/kyr)',mat2str(cv.allNineRateRangeShared)};
writecell([{'Metric','Value'};summaryRows;extra],temporary, ...
    'Sheet','Summary','Range','A1');

curves = [cv.srGrid(:),cv.trainA.curve(:),cv.trainB.curve(:), ...
    cv.validateAtoB.curve(:),cv.validateBtoA.curve(:), ...
    cv.pCurveAtoB(:),cv.pCurveBtoA(:), ...
    cv.pLocalCurveAtoB(:),cv.pLocalCurveBtoA(:),cv.orbitCountA(:), ...
    cv.orbitCountB(:),cv.activeOrbitCountAtoB(:), ...
    cv.activeOrbitCountBtoA(:),cv.groupLeakageRcondA(:), ...
    cv.groupLeakageRcondB(:),double(cv.trainingRateMaskA(:)), ...
    double(cv.trainingRateMaskB(:)),double(cv.validRateMaskA(:)), ...
    double(cv.validRateMaskB(:))];
curveHeader = {'SedRate_cm_per_kyr','Train_A','Train_B', ...
    'Validate_A_to_B','Validate_B_to_A','GlobalP_A_to_B', ...
    'GlobalP_B_to_A','LocalP_A_to_B','LocalP_B_to_A', ...
    'ResolvablePeriods_A','ResolvablePeriods_B', ...
    'ActivePeriods_A_to_B','ActivePeriods_B_to_A', ...
    'LeakageRcond_A','LeakageRcond_B','TrainingRate_A', ...
    'TrainingRate_B','ValidRate_A','ValidRate_B'};
writecell(curveHeader,temporary,'Sheet','SedRateCurves','Range','A1');
writematrix(curves,temporary,'Sheet','SedRateCurves','Range','A2');

nNull = numel(cv.nullSymmetric);
nullData = [(1:nNull)',cv.nullAtoB(:),cv.nullBtoA(:), ...
    cv.nullSymmetric(:),cv.nullBestRateAtoB(:),cv.nullBestRateBtoA(:)];
writecell({'Simulation','S_A_to_B','S_B_to_A','T_symmetric', ...
    'BestRate_A_to_B','BestRate_B_to_A'},temporary, ...
    'Sheet','NullStatistics','Range','A1');
writematrix(nullData,temporary,'Sheet','NullStatistics','Range','A2');

groupNames = cellstr(string(cv.groupNames(:)));
groupData = [cv.trainA.groupRaw(:),cv.trainA.groupNormalized(:), ...
    cv.trainB.groupRaw(:),cv.trainB.groupNormalized(:)];
writecell([{'Group','TrainA_raw','TrainA_relative', ...
    'TrainB_raw','TrainB_relative'}; ...
    [groupNames,num2cell(groupData)]],temporary, ...
    'Sheet','GroupWeights','Range','A1');

writeNumericSheet(temporary,'SegmentA',{'Depth_m','Value'},cv.dataA);
writeNumericSheet(temporary,'SegmentB',{'Depth_m','Value'},cv.dataB);
writeSpectrumSheet(temporary,'Validation_AtoB',cv.spectra.validateAtoB);
writeSpectrumSheet(temporary,'Validation_BtoA',cv.spectra.validateBtoA);
writeSpectrumSheet(temporary,'Training_A',cv.spectra.trainA);
writeSpectrumSheet(temporary,'Training_B',cv.spectra.trainB);
configRows = flattenStruct(cv.config,'config');
writecell([{'Parameter','Value'};configRows],temporary, ...
    'Sheet','Configuration','Range','A1');
finalizeAtomicFile(temporary,path);
clear cleanup
end

function writeAdaptiveWorkbook(path,adaptive,report,spec,task)
temporary = [tempname(fileparts(path)),'.xlsx'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
summaryRows = normalizeKeyValueRows(report.summaryRows);
extra = {
    'Dataset',spec.title;
    'Expected sedimentation rate',spec.expected_rate;
    'Red-noise option',task.red;
    'Monte Carlo simulations',task.nsim;
    'Full rate-by-simulation matrix storage','results.mat only'};
writecell([{'Metric','Value'};summaryRows;extra],temporary, ...
    'Sheet','Summary','Range','A1');
writecell({'SedRate_cm_per_kyr','Correlation', ...
    'Parametric_p_descriptive_only','Missing_periods', ...
    'Global_max_statistic_p','Participating_periods','Local_MC_p'}, ...
    temporary,'Sheet','SedRateCurves','Range','A1');
writematrix([adaptive.corrCI(:,1:4),adaptive.corrH0(:,1:3)], ...
    temporary,'Sheet','SedRateCurves','Range','A2');
nullMax = adaptive.details.nullMax(:);
writecell({'Simulation','Null_maximum_correlation'},temporary, ...
    'Sheet','NullMaximum','Range','A1');
writematrix([(1:numel(nullMax))',nullMax],temporary, ...
    'Sheet','NullMaximum','Range','A2');
detailRows = flattenStruct(rmfield(adaptive.details,'nullMax'),'details');
writecell([{'Parameter','Value'};detailRows],temporary, ...
    'Sheet','Configuration','Range','A1');
writeNumericSheet(temporary,'PreprocessedInput', ...
    {'Depth_m','Value'},adaptive.data);
finalizeAtomicFile(temporary,path);
clear cleanup
end

function writeSpectrumSheet(workbook,sheetName,spectrum)
writecell({'Rate_cm_per_kyr',spectrum.rate;'Target_mode',spectrum.mode}, ...
    workbook,'Sheet',sheetName,'Range','A1');
writecell({'Frequency_cycle_per_kyr','Data_temporal_PSD', ...
    'Target_temporal_PSD'},workbook,'Sheet',sheetName,'Range','A4');
if ~isempty(spectrum.frequency)
    writematrix([spectrum.frequency(:),spectrum.dataPower(:), ...
        spectrum.targetPower(:)],workbook,'Sheet',sheetName,'Range','A5');
end
end

function writeNumericSheet(workbook,sheetName,header,data)
writecell(header,workbook,'Sheet',sheetName,'Range','A1');
if ~isempty(data)
    writematrix(data,workbook,'Sheet',sheetName,'Range','A2');
end
end

function tasks = methodTasks(options)
tasks = repmat(struct('engine','','role','','red',NaN,'nsim',NaN, ...
    'folder',''),0,1);
if options.RunCV
    tasks(end+1) = makeTask('cvCOCO','primary confirmatory', ...
        options.Red,options.NSim,'primary');
end
if options.RunAdaptive
    tasks(end+1) = makeTask('Adaptive COCO','primary exploratory', ...
        options.Red,options.NSim,'primary');
end
if ~isempty(options.SensitivityRed) && options.SensitivityRed ~= options.Red
    if options.RunCV
        tasks(end+1) = makeTask('cvCOCO','background sensitivity', ...
            options.SensitivityRed,options.NSimSensitivity,'sensitivity');
    end
    if options.RunAdaptive
        tasks(end+1) = makeTask('Adaptive COCO','background sensitivity', ...
            options.SensitivityRed,options.NSimSensitivity,'sensitivity');
    end
end
end

function task = makeTask(engine,role,red,nsim,suffix)
task = struct('engine',engine,'role',role,'red',red,'nsim',nsim, ...
    'folder',sprintf('%s_red%d_%s',sanitizeFilename(engine),red,suffix));
end

function row = cvSummaryRow(task,report,expectedRate)
row = {task.engine,task.role,task.red,'complete',report.classification, ...
    double(report.pass),report.bestRateAtoB,report.bestRateBtoA,NaN, ...
    report.pA,report.pB,report.pRobust,report.pSym,NaN,NaN, ...
    min(report.participatingPeriodsAtoB,report.participatingPeriodsBtoA), ...
    expectedRate,report.conclusion};
end

function row = adaptiveSummaryRow(task,report,expectedRate)
row = {task.engine,task.role,task.red,'complete',report.classification, ...
    double(report.pass),NaN,NaN,report.bestRate,NaN,NaN,NaN,NaN, ...
    report.minimumGlobalP,report.localPAtBest,report.periodCountAtBest, ...
    expectedRate,report.conclusion};
end

function row = failureSummaryRow(task,exception)
row = {task.engine,task.role,task.red,'failed','FAILED',0, ...
    NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,'', ...
    sprintf('%s (%s)',exception.message,exception.identifier)};
end

function plan = defaultDatasetPlan(inputRoot)
definitions = {
    'rednoise_long','Long pure red-noise negative control', ...
        'rednoise0.5-80m.csv',0,'No physical rate (negative control)',0.5,20,0.05;
    'rednoise_short','Short pure red-noise negative control', ...
        'SigGen-rednoise-1std-0mean-0.5alpha200.txt',0, ...
        'No physical rate (short negative control)',5,40,0.1;
    'signal_4_to_6','Pure astronomical signal with a 4-to-6 cm/kyr rate change', ...
        'la04etp54-59ma4-6cmka-rsp0.04.txt',56, ...
        '4 cm/kyr and 6 cm/kyr',2,8,0.02;
    'newark_late_triassic','Late Triassic Newark depth-rank record', ...
        'Example-LateTriassicNewarkDepthRank_0_800-300-LOWESS.txt',210, ...
        '10-15 cm/kyr',5,25,0.05;
    'site1262_eocene','Site 1262 XRF Fe record', ...
        '1262XRF-Fe-log10-s.u.-111-170-rsp0.02-10-rLOESS-dpks-rsp0.04.txt',50, ...
        'Approximately 1.2 cm/kyr',0.5,3,0.01;
    'givetian_dd14','Givetian DD14 record', ...
        'GivetianDD14-s.u.-rsp0.3-log10-80-rLOESS.txt',384, ...
        'Approximately 8 cm/kyr',3,20,0.05};
relativeHints = {
    fullfile('data_18','syn3',definitions{1,3});
    fullfile('data_18','syn3',definitions{2,3});
    fullfile('data_18','syn3',definitions{3,3});
    fullfile('data',definitions{4,3});
    fullfile('data18_raw',definitions{5,3});
    fullfile('data18_raw',definitions{6,3})};
plan = repmat(struct('id','','title','','filename','','input_file','', ...
    'age_ma',NaN,'expected_rate','','sr1',NaN,'sr2',NaN,'srstep',NaN, ...
    'pad',[]),size(definitions,1),1);
for ii = 1:size(definitions,1)
    plan(ii).id = definitions{ii,1};
    plan(ii).title = definitions{ii,2};
    plan(ii).filename = definitions{ii,3};
    plan(ii).input_file = fullfile(inputRoot,relativeHints{ii});
    plan(ii).age_ma = definitions{ii,4};
    plan(ii).expected_rate = definitions{ii,5};
    plan(ii).sr1 = definitions{ii,6};
    plan(ii).sr2 = definitions{ii,7};
    plan(ii).srstep = definitions{ii,8};
end
plan = normalizeDatasetPlan(plan,inputRoot);
end

function plan = normalizeDatasetPlan(plan,inputRoot)
required = {'id','title','age_ma','expected_rate','sr1','sr2','srstep'};
for ii = 1:numel(plan)
    missing = required(~isfield(plan(ii),required));
    if ~isempty(missing)
        error('runCocoPublicationValidation:InvalidDatasetPlan', ...
            'Dataset plan item %d lacks: %s.',ii,strjoin(missing,', '));
    end
    if ~isfield(plan(ii),'filename') || strlength(string(plan(ii).filename)) == 0
        if isfield(plan(ii),'input_file')
            [~,name,extension] = fileparts(char(string(plan(ii).input_file)));
            plan(ii).filename = [name,extension];
        else
            error('runCocoPublicationValidation:InvalidDatasetPlan', ...
                'Dataset plan item %d needs filename or input_file.',ii);
        end
    end
    if ~isfield(plan(ii),'input_file') || ...
            strlength(string(plan(ii).input_file)) == 0
        plan(ii).input_file = fullfile(inputRoot,char(string(plan(ii).filename)));
    end
    if ~isfield(plan(ii),'pad')
        plan(ii).pad = [];
    end
    validateattributes(plan(ii).age_ma,{'numeric'}, ...
        {'scalar','real','finite'},mfilename,'plan.age_ma');
    validateattributes([plan(ii).sr1,plan(ii).sr2,plan(ii).srstep], ...
        {'numeric'},{'vector','numel',3,'real','finite','positive'}, ...
        mfilename,'plan rate grid');
    if plan(ii).sr2 < plan(ii).sr1
        error('runCocoPublicationValidation:InvalidDatasetPlan', ...
            'Dataset %s has sr2 < sr1.',char(string(plan(ii).id)));
    end
    nRate = floor((plan(ii).sr2-plan(ii).sr1)/plan(ii).srstep)+1;
    if nRate < 2 || nRate > 10000
        error('runCocoPublicationValidation:InvalidDatasetPlan', ...
            'Dataset %s rate grid must contain 2 to 10,000 points.', ...
            char(string(plan(ii).id)));
    end
    if ~isempty(plan(ii).pad) && (~isnumeric(plan(ii).pad) || ...
            ~isscalar(plan(ii).pad) || ~isfinite(plan(ii).pad) || ...
            plan(ii).pad < 4 || plan(ii).pad ~= fix(plan(ii).pad))
        error('runCocoPublicationValidation:InvalidDatasetPlan', ...
            'Dataset %s pad must be empty or a finite integer >= 4.', ...
            char(string(plan(ii).id)));
    end
    plan(ii).id = char(string(plan(ii).id));
    plan(ii).title = char(string(plan(ii).title));
    plan(ii).filename = char(string(plan(ii).filename));
    plan(ii).input_file = char(string(plan(ii).input_file));
    plan(ii).expected_rate = char(string(plan(ii).expected_rate));
end
end

function path = resolveInputFile(spec)
path = spec.input_file;
if isfile(path)
    return
end
base = fileparts(fileparts(path));
if ~isfolder(base)
    base = fileparts(path);
end
while ~isfolder(base) && ~isempty(base)
    parent = fileparts(base);
    if strcmp(parent,base)
        break
    end
    base = parent;
end
matches = dir(fullfile(base,'**',spec.filename));
matches = matches(~[matches.isdir]);
if numel(matches) ~= 1
    error('runCocoPublicationValidation:InputNotFound', ...
        ['Could not uniquely resolve %s. Expected %s; recursive matches ', ...
         'under %s: %d.'],spec.filename,spec.input_file,base,numel(matches));
end
path = fullfile(matches(1).folder,matches(1).name);
end

function checkpoint = loadCheckpoint(path)
checkpoint = struct;
if ~isfile(path)
    return
end
try
    saved = load(path,'checkpoint');
    if isfield(saved,'checkpoint') && isstruct(saved.checkpoint)
        checkpoint = saved.checkpoint;
    end
catch
    checkpoint = struct;
end
end

function tf = checkpointMatches(checkpoint,signature)
tf = isstruct(checkpoint) && isfield(checkpoint,'signature') && ...
    (ischar(checkpoint.signature) || isstring(checkpoint.signature)) && ...
    strcmp(char(string(checkpoint.signature)),signature) && ...
    isfield(checkpoint,'status') && ...
    ismember(char(string(checkpoint.status)),{'calculated','complete'});
end

function checkpoint = runningCheckpoint(signature,task)
checkpoint = struct('signature',signature,'status','running', ...
    'method',task.engine,'role',task.role,'red',task.red,'nsim',task.nsim, ...
    'started_at',timestampNow(),'updated_at',timestampNow(), ...
    'result_file','','workbook','','conclusion_file','', ...
    'figures',repmat(emptyFigureEntry(),0,1),'error','');
end

function rows = flattenStruct(value,prefix)
rows = cell(0,2);
fields = fieldnames(value);
for ii = 1:numel(fields)
    name = fields{ii};
    if isempty(prefix)
        key = name;
    else
        key = [prefix,'.',name];
    end
    item = value.(name);
    if isstruct(item) && isscalar(item)
        rows = [rows;flattenStruct(item,key)]; %#ok<AGROW>
    else
        rows(end+1,:) = {key,scalarCellValue(item)}; %#ok<AGROW>
    end
end
end

function value = scalarCellValue(value)
if ischar(value)
    return
elseif isstring(value) && isscalar(value)
    value = char(value);
elseif isnumeric(value) || islogical(value)
    if isscalar(value)
        return
    end
    value = mat2str(value);
elseif iscell(value)
    try
        value = char(strjoin(string(value(:)),' | '));
    catch
        value = jsonencode(value);
    end
else
    try
        value = jsonencode(value);
    catch
        value = char(string(value));
    end
end
end

function rows = normalizeKeyValueRows(rows)
if ~iscell(rows) || size(rows,2) ~= 2
    error('runCocoPublicationValidation:InvalidSummaryRows', ...
        'Conclusion summaryRows must be a two-column cell array.');
end
for ii = 1:size(rows,1)
    rows{ii,1} = scalarCellValue(rows{ii,1});
    rows{ii,2} = scalarCellValue(rows{ii,2});
end
end

function writeRootSummary(outputRoot,cases)
header = {'case_id','title','status','age_ma','expected_rate', ...
    'input_file','case_dir'};
body = cell(numel(cases),numel(header));
for ii = 1:numel(cases)
    body(ii,:) = {cases(ii).id,cases(ii).title,cases(ii).status, ...
        cases(ii).age_ma,cases(ii).expected_rate,cases(ii).input_file, ...
        cases(ii).case_dir};
end
writeCellAtomic(fullfile(outputRoot,'run_summary.csv'),[header;body]);
end

function writeArtifactInventory(outputRoot,relativeInventoryPath)
% Hash stable publication artifacts after every atomic output is finalized.
% Logs and method checkpoints are deliberately excluded: logs change while
% the inventory is assembled, and checkpoints are resumability state rather
% than scientific deliverables.
inventoryPath = fullfile(outputRoot,relativeInventoryPath);
listing = dir(fullfile(outputRoot,'**','*'));
listing = listing(~[listing.isdir]);
relative = strings(numel(listing),1);
keep = true(numel(listing),1);
for ii = 1:numel(listing)
    absolutePath = fullfile(listing(ii).folder,listing(ii).name);
    relative(ii) = string(relativePath(absolutePath,outputRoot));
    components = split(replace(relative(ii),'\','/'),'/');
    filename = components(end);
    keep(ii) = relative(ii) ~= string(relativeInventoryPath) && ...
        filename ~= "run.log" && filename ~= "checkpoint.mat" && ...
        ~startsWith(filename,".~") && ~startsWith(filename,"~$") && ...
        filename ~= ".DS_Store";
end
listing = listing(keep);
relative = relative(keep);
[relative,order] = sort(relative);
listing = listing(order);
rows = cell(numel(listing),3);
for ii = 1:numel(listing)
    absolutePath = fullfile(listing(ii).folder,listing(ii).name);
    rows(ii,:) = {char(relative(ii)),listing(ii).bytes,sha256File(absolutePath)};
end
writeCellAtomic(inventoryPath, ...
    [{'Relative_path','Bytes','SHA256'};rows]);
end

function status = caseStatus(records)
states = string({records.status});
if all(states == "complete")
    status = 'complete';
elseif all(states == "failed")
    status = 'failed';
else
    status = 'partial_failure';
end
end

function status = suiteStatus(cases,nDone,nTotal)
if nDone < nTotal
    status = 'running';
else
    status = finalSuiteStatus(cases);
end
end

function status = finalSuiteStatus(cases)
states = string({cases.status});
if all(states == "complete")
    status = 'complete';
elseif all(states == "failed")
    status = 'failed';
else
    status = 'partial_failure';
end
end

function item = emptyCaseManifest()
item = struct('id','','title','','input_file','','input_sha256','', ...
    'age_ma',NaN,'expected_rate','','case_dir','', ...
    'parameters_csv','','summary_csv','','conclusion_txt','', ...
    'case_report_docx','', ...
    'preprocessed_input_csv','', ...
    'figures',repmat(emptyFigureEntry(),0,1), ...
    'methods',repmat(emptyMethodRecord(),0,1), ...
    'status','pending','updated_at','');
end

function item = failedCaseManifest(spec,index,outputRoot,exception)
item = emptyCaseManifest();
item.id = spec.id;
item.title = spec.title;
item.input_file = spec.input_file;
item.age_ma = spec.age_ma;
item.expected_rate = spec.expected_rate;
item.case_dir = sprintf('%02d_%s',index,sanitizeFilename(spec.id));
item.status = 'failed';
item.updated_at = timestampNow();
caseDirectory = fullfile(outputRoot,item.case_dir);
ensureDirectory(caseDirectory);
writeTextAtomic(fullfile(caseDirectory,'conclusion.txt'), ...
    sprintf('CASE FAILED\n%s\n\n%s',exception.message,exceptionReport(exception)));
item.conclusion_txt = fullfile(item.case_dir,'conclusion.txt');
item.case_report_docx = fullfile(item.case_dir,'case_report.docx');
writeCaseManifest(fullfile(caseDirectory,'case_manifest.json'),item);
end

function item = emptyMethodRecord()
item = struct('method','','role','','red',NaN,'nsim',NaN, ...
    'status','pending','classification','','pass',false, ...
    'result_file','','workbook','','conclusion_file','','error','');
end

function item = failedMethodRecord(task,exception)
item = emptyMethodRecord();
item.method = task.engine;
item.role = task.role;
item.red = task.red;
item.nsim = task.nsim;
item.status = 'failed';
item.classification = 'FAILED';
item.pass = false;
item.error = sprintf('%s (%s)',exception.message,exception.identifier);
end

function item = emptyFigureEntry()
item = struct('path','','pdf_path','','fig_path','','caption','', ...
    'width','full','width_mm',180,'method','','role','','red',NaN);
end

function optionsPublic = publicOptions(options)
optionsPublic = rmfield(options,'DatasetPlan');
if ischar(optionsPublic.DatasetIDs)
    optionsPublic.DatasetIDs = {optionsPublic.DatasetIDs};
else
    optionsPublic.DatasetIDs = cellstr(string(optionsPublic.DatasetIDs(:)));
end
end

function audit = codeFingerprint(repositoryRoot)
relative = {
    fullfile('code','corrcoef','cvcoco.m');
    fullfile('code','corrcoef','cocoAdaptiveEvaluate.m');
    fullfile('code','corrcoef','corrcoefslices_rankNew.m');
    fullfile('code','corrcoef','redNoisePeriodogramMC.m');
    fullfile('code','corrcoef','cocoConclusionReport.m');
    fullfile('code','corrcoef','cocoAdaptivePublicationReport.m');
    fullfile('code','corrcoef','cocoPublicationPrepareData.m');
    fullfile('code','corrcoef','plotcvcoco.m');
    fullfile('code','corrcoef','plotAdaptiveCocoPublication.m');
    fullfile('code','package','secular_periods','calculate_orbit9.m');
    fullfile('code','package','swa','specswa.m');
    fullfile('code','seriesanalysis','redconf_any.m');
    fullfile('code','seriesanalysis','moveMedian.m');
    fullfile('code','seriesanalysis','minirhos0.m');
    fullfile('code','seriesanalysis','calculateRhoM.m');
    fullfile('code','corrcoef','runCocoPublicationValidation.m')};
audit = struct;
for ii = 1:numel(relative)
    path = fullfile(repositoryRoot,relative{ii});
    field = matlab.lang.makeValidName(strrep(relative{ii},filesep,'_'));
    if isfile(path)
        audit.(field) = sha256File(path);
    else
        audit.(field) = 'missing';
    end
end
end

function info = gitMetadata(repositoryRoot)
info = struct('head','unavailable','status','unavailable');
[status,head] = system(sprintf('git -C %s rev-parse HEAD', ...
    shellQuote(repositoryRoot)));
if status == 0
    info.head = strtrim(head);
end
[status,worktree] = system(sprintf('git -C %s status --short', ...
    shellQuote(repositoryRoot)));
if status == 0
    info.status = strtrim(worktree);
end
end

function value = shellQuote(value)
value = char(string(value));
value = ['''',strrep(value,'''','''"''"'''),''''];
end

function root = repositoryDirectory()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

function path = canonicalFilesystemPath(path)
% Resolve platform aliases such as macOS /tmp -> /private/tmp so every
% artifact inventory entry can be expressed relative to one stable root.
try
    path = char(java.io.File(path).getCanonicalPath());
catch
    path = char(string(path));
end
end

function digest = sha256File(path)
messageDigest = java.security.MessageDigest.getInstance('SHA-256');
stream = java.io.FileInputStream(java.io.File(path));
digestStream = java.security.DigestInputStream(stream,messageDigest);
cleanup = onCleanup(@()digestStream.close());
buffer = zeros(8192,1,'int8');
while digestStream.read(buffer,0,numel(buffer)) ~= -1
end
bytes = messageDigest.digest();
values = mod(double(bytes),256);
digest = lower(reshape(dec2hex(values,2).',1,[]));
clear cleanup
end

function path = relativePath(path,root)
path = char(string(path));
root = char(string(root));
prefix = [root,filesep];
if startsWith(path,prefix)
    path = path(numel(prefix)+1:end);
end
end

function writeJsonAtomic(path,value)
text = jsonencode(value,'PrettyPrint',true);
writeTextAtomic(path,text);
end

function writeRootManifest(path,manifest)
jsonManifest = manifest;
jsonManifest.cases = num2cell(manifest.cases(:));
writeJsonAtomic(path,jsonManifest);
end

function writeCaseManifest(path,manifest)
jsonManifest = manifest;
jsonManifest.figures = num2cell(manifest.figures(:));
jsonManifest.methods = num2cell(manifest.methods(:));
writeJsonAtomic(path,jsonManifest);
end

function writeTextAtomic(path,value)
ensureDirectory(fileparts(path));
temporary = tempname(fileparts(path));
cleanup = onCleanup(@()deleteIfPresent(temporary));
file = fopen(temporary,'w','n','UTF-8');
if file < 0
    error('runCocoPublicationValidation:FileOpenFailed', ...
        'Could not open temporary output for %s.',path);
end
fileCleanup = onCleanup(@()fclose(file));
fprintf(file,'%s',char(string(value)));
clear fileCleanup
finalizeAtomicFile(temporary,path);
clear cleanup
end

function writeCellAtomic(path,cells)
ensureDirectory(fileparts(path));
[~,~,extension] = fileparts(path);
temporary = [tempname(fileparts(path)),extension];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writecell(cells,temporary);
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

function saveStructAtomic(path,payload)
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
    error('runCocoPublicationValidation:AtomicSaveFailed', ...
        'Could not finalize %s: %s',destination,message);
end
end

function appendLog(path,format,varargin)
ensureDirectory(fileparts(path));
file = fopen(path,'a','n','UTF-8');
if file < 0
    warning('runCocoPublicationValidation:LogOpenFailed', ...
        'Could not append to %s.',path);
    return
end
cleanup = onCleanup(@()fclose(file));
fprintf(file,'[%s] ',timestampNow());
fprintf(file,format,varargin{:});
fprintf(file,'\n');
end

function ensureDirectory(path)
if isempty(path)
    return
end
if ~isfolder(path)
    [ok,message] = mkdir(path);
    if ~ok
        error('runCocoPublicationValidation:DirectoryCreateFailed', ...
            'Could not create %s: %s',path,message);
    end
end
end

function deleteIfPresent(path)
if isfile(path)
    delete(path);
end
end

function text = logicalText(tf)
if tf
    text = 'YES';
else
    text = 'NO';
end
end

function text = exceptionReport(exception)
try
    text = getReport(exception,'extended','hyperlinks','off');
catch
    text = sprintf('%s (%s)',exception.message,exception.identifier);
end
end

function text = sanitizeFilename(text)
text = char(string(text));
text = regexprep(text,'[^A-Za-z0-9._-]+','_');
text = regexprep(text,'_+','_');
text = regexprep(text,'^_|_$','');
if isempty(text)
    text = 'unnamed';
end
end

function value = timestampNow()
value = char(datetime('now','TimeZone','local', ...
    'Format','yyyy-MM-dd''T''HH:mm:ssXXX'));
end

function tf = isScalarText(x)
tf = (ischar(x) && (isrow(x) || isempty(x))) || ...
    (isstring(x) && isscalar(x));
end

function tf = isNonnegativeInteger(x)
tf = isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && ...
    x >= 0 && x == fix(x) && x <= 1e6;
end

function tf = isPositiveInteger(x)
tf = isNonnegativeInteger(x) && x >= 1;
end

function tf = isSeed(x)
tf = isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && ...
    x >= 0 && x == fix(x) && x <= 2^32-1;
end

function tf = isRedOption(x)
tf = isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && ...
    ismember(x,0:3) && x == fix(x);
end

function tf = isPositiveScalar(x)
tf = isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x > 0;
end

function tf = isLogicalScalar(x)
tf = (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    ismember(double(x),[0,1]);
end
