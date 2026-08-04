function runSummary = runInterleavedCvCocoComparison(outputRoot,varargin)
%RUNINTERLEAVEDCVCOCOCOMPARISON Reproducible seven-record I-cvCOCO study.
%
% RUNSUMMARY = RUNINTERLEAVEDCVCOCOCOMPARISON(OUTPUTROOT) runs the
% odd/even Interleaved cvCOCO engine on the seven registered syn3 records.
% The registered production design uses 2000 Monte Carlo realizations,
% Pearson correlation, RED=0, seed 1, BatchSize 100, and a temporal
% frequency ceiling 1.2 times the highest nominal orbital frequency.
%
% Every completed data set has a signature-matched checkpoint.  A resumed
% call reuses the complete numerical result and repairs missing derived
% tables or figures without repeating Monte Carlo.  Checkpoints are at the
% data-set level; a partially completed Monte Carlo loop itself is not
% resumed.
%
% Files written for every successful data set include the complete MATLAB
% result, parameters, summary, rate curves, Monte Carlo null statistics, an
% editable tabbed FIG, a multipage vector PDF, and 300-dpi PNG pages.  Root
% outputs include an overall summary, JSON manifest, MAT summary, and log.
%
% Important name-value inputs:
%   InputRoot       folder containing the seven exact input files
%   NSim            Monte Carlo realizations (default 2000; zero allowed
%                   only for diagnostic/smoke runs)
%   Seed            local reproducible seed (default 1)
%   BatchSize       Monte Carlo batch size (default 100)
%   Resume          reuse signature-matched numerical results (default true)
%   ContinueOnError continue with later records after a failure (default true)
%   ExportFigures   write FIG/PDF/PNG outputs (default true)
%   DatasetIDs      optional subset of registered identifiers
%   DatasetPlan     optional custom plan, intended for tests/smoke runs
%   EnforceGuiPad   require plan Pad to match the GUI point-count rule
%                   (default true)

defaultInputRoot = fullfile(filesep,'Users','mingsongli','Dropbox', ...
    'Research','_通用方法火山构造波动','202606COCO','data_18','syn3');
if nargin < 1
    outputRoot = '';
end
validateattributes(outputRoot,{'char','string'},{'scalartext'}, ...
    mfilename,'outputRoot',1);

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'InputRoot',defaultInputRoot,@isScalarText);
addParameter(parser,'NSim',2000,@isNonnegativeInteger);
addParameter(parser,'Seed',1,@isSeed);
addParameter(parser,'Red',0,@isRedOption);
addParameter(parser,'Method','Pearson',@isScalarText);
addParameter(parser,'BatchSize',100,@isPositiveInteger);
addParameter(parser,'MaxFrequencyScale',1.2,@isPositiveScalar);
addParameter(parser,'Resume',true,@isLogicalScalar);
addParameter(parser,'ContinueOnError',true,@isLogicalScalar);
addParameter(parser,'ExportFigures',true,@isLogicalScalar);
addParameter(parser,'CloseFigures',true,@isLogicalScalar);
addParameter(parser,'Visible','off',@isScalarText);
addParameter(parser,'ShowProgress',true,@isLogicalScalar);
addParameter(parser,'DatasetIDs',strings(0,1),@isTextList);
addParameter(parser,'DatasetPlan',struct([]), ...
    @(x) isempty(x) || isstruct(x));
addParameter(parser,'EnforceGuiPad',true,@isLogicalScalar);
parse(parser,varargin{:});
options = parser.Results;
options.InputRoot = char(string(options.InputRoot));
options.Method = validatestring(char(string(options.Method)), ...
    {'Pearson','Spearman'},mfilename,'Method');
options.Visible = validatestring(char(string(options.Visible)), ...
    {'on','off'},mfilename,'Visible');
logicalNames = {'Resume','ContinueOnError','ExportFigures','CloseFigures', ...
    'ShowProgress','EnforceGuiPad'};
for optionIndex = 1:numel(logicalNames)
    name = logicalNames{optionIndex};
    options.(name) = logical(options.(name));
end
if options.MaxFrequencyScale < 1
    error('runInterleavedCvCocoComparison:MaximumFrequencyScaleTooSmall', ...
        'MaxFrequencyScale must be at least one.');
end

if isempty(options.DatasetPlan)
    datasets = defaultDatasetPlan(options.InputRoot);
else
    datasets = normalizeDatasetPlan(options.DatasetPlan,options.InputRoot);
end
datasets = selectDatasets(datasets,options.DatasetIDs);
if isempty(datasets)
    error('runInterleavedCvCocoComparison:EmptyPlan', ...
        'At least one data set must remain selected.');
end

if strlength(string(outputRoot)) == 0
    dayStamp = char(datetime('now','TimeZone','Asia/Shanghai', ...
        'Format','yyyyMMdd'));
    outputRoot = fullfile(options.InputRoot,sprintf( ...
        'Interleaved_cvCOCO_7datasets_MC%d_%s',options.NSim,dayStamp));
end
outputRoot = char(string(outputRoot));
ensureDirectory(outputRoot);
outputRoot = canonicalPath(outputRoot);
logFile = fullfile(outputRoot,'run.log');
logMessage({logFile},sprintf( ...
    'Study started: %d data set(s), MC=%d, method=%s, red=%d, seed=%d.', ...
    numel(datasets),options.NSim,options.Method,options.Red,options.Seed));

oldVisibility = get(groot,'defaultFigureVisible');
visibilityCleanup = onCleanup(@()set(groot,'defaultFigureVisible', ...
    oldVisibility));
set(groot,'defaultFigureVisible',options.Visible);

manifestPath = fullfile(outputRoot,'manifest.json');
summaryPath = fullfile(outputRoot,'overall_summary.csv');
caseManifests = repmat(emptyCaseManifest(),0,1);
summaryRows = repmat(emptySummaryRow(),0,1);
manifest = struct( ...
    'schema_version',1, ...
    'study','Seven-record Interleaved cvCOCO comparison', ...
    'created_at',timestampNow(), ...
    'updated_at',timestampNow(), ...
    'status','running', ...
    'output_root',outputRoot, ...
    'log_file','run.log', ...
    'overall_summary_csv','overall_summary.csv', ...
    'comparison_report_md','comparison_report.md', ...
    'options',publicOptions(options), ...
    'cases',caseManifests);
writeRootManifest(manifestPath,manifest);
writeSummaryCsv(summaryPath,summaryRows);
writeComparisonReport(fullfile(outputRoot,'comparison_report.md'), ...
    summaryRows,options);

fatalException = [];
for datasetIndex = 1:numel(datasets)
    spec = datasets(datasetIndex);
    try
        [caseManifest,row] = runOneDataset( ...
            spec,datasetIndex,outputRoot,logFile,options);
    catch exception
        [caseManifest,row] = failedDataset( ...
            spec,datasetIndex,outputRoot,exception,options);
        logMessage({logFile},sprintf('FAILED %s: %s (%s)', ...
            spec.id,exception.message,exception.identifier));
        if ~options.ContinueOnError
            fatalException = exception;
        end
    end
    caseManifests(end+1,1) = caseManifest; %#ok<AGROW>
    summaryRows(end+1,1) = row; %#ok<AGROW>
    manifest.cases = caseManifests;
    manifest.updated_at = timestampNow();
    manifest.status = 'running';
    writeSummaryCsv(summaryPath,summaryRows);
    writeRootManifest(manifestPath,manifest);
    writeComparisonReport(fullfile(outputRoot,'comparison_report.md'), ...
        summaryRows,options);
    if ~isempty(fatalException)
        break
    end
end

manifest.status = overallStatus(caseManifests);
manifest.updated_at = timestampNow();
manifest.cases = caseManifests;
writeSummaryCsv(summaryPath,summaryRows);
writeRootManifest(manifestPath,manifest);
writeComparisonReport(fullfile(outputRoot,'comparison_report.md'), ...
    summaryRows,options);
runSummary = manifest;
runSummary.summary_rows = summaryRows;
saveAtomic(fullfile(outputRoot,'run_summary.mat'),struct( ...
    'runSummary',runSummary,'summaryRows',summaryRows, ...
    'datasetPlan',datasets));
logMessage({logFile},sprintf('Study finished with status %s.', ...
    manifest.status));
clear visibilityCleanup
if ~isempty(fatalException)
    rethrow(fatalException)
end
end

function [caseManifest,row] = runOneDataset( ...
        spec,index,outputRoot,rootLog,options)
caseName = sprintf('%02d_%s',index,sanitizeFilename(spec.id));
caseDirectory = fullfile(outputRoot,caseName);
figureDirectory = fullfile(caseDirectory,'figures');
ensureDirectory(caseDirectory);
ensureDirectory(figureDirectory);
caseLog = fullfile(caseDirectory,'run.log');
logPaths = {rootLog,caseLog};
logMessage(logPaths,sprintf('Starting %s (%s).',spec.title,spec.id));

inputFile = resolveInputFile(spec,options.InputRoot);
inputHash = sha256File(inputFile);
raw = readmatrix(inputFile);
if ~isnumeric(raw) || isempty(raw) || size(raw,2) < 2
    error('runInterleavedCvCocoComparison:InvalidInput', ...
        '%s did not yield two numeric columns.',inputFile);
end
raw = raw(:,1:2);
originalRowCount = size(raw,1);
clean = cleanInput(raw);
if size(clean,1) < 8
    error('runInterleavedCvCocoComparison:InsufficientInput', ...
        '%s has fewer than eight finite unique depth rows.',inputFile);
end
[guiPointCount,guiInterpolationApplied,medianSpacing] = ...
    guiRegularizedPointCount(clean);
calculatedGuiPad = defaultGuiPad(guiPointCount);
if options.EnforceGuiPad && spec.pad ~= calculatedGuiPad
    error('runInterleavedCvCocoComparison:GuiPadMismatch', ...
        ['Registered Pad %d does not match GUI-rule Pad %d after the ', ...
         'full-record median-spacing audit (%d points) for %s.'], ...
        spec.pad,calculatedGuiPad,guiPointCount,inputFile);
end

orbitMatrix = calculate_orbit9(spec.age_ma);
orbit9 = orbitMatrix(:,2)/1000;
if numel(orbit9) ~= 9 || any(~isfinite(orbit9) | orbit9 <= 0)
    error('runInterleavedCvCocoComparison:InvalidOrbitPeriods', ...
        'calculate_orbit9 did not return nine finite positive periods.');
end
maxFrequency = options.MaxFrequencyScale*max(1./orbit9);
writeNumericCsvAtomic(fullfile(caseDirectory,'input_clean.csv'), ...
    {'depth_m','value'},clean);

parameterPayload = struct( ...
    'spec',spec,'options',publicOptions(options), ...
    'inputFile',inputFile,'inputSha256',inputHash, ...
    'originalRowCount',originalRowCount, ...
    'cleanPointCount',size(clean,1), ...
    'guiRegularizedPointCount',guiPointCount, ...
    'guiInterpolationApplied',guiInterpolationApplied, ...
    'medianSpacing',medianSpacing, ...
    'calculatedGuiPad',calculatedGuiPad, ...
    'orbitMatrix',orbitMatrix,'orbit9',orbit9, ...
    'maximumFrequency',maxFrequency);
writeParameters(fullfile(caseDirectory,'parameters.csv'),parameterPayload);
saveAtomic(fullfile(caseDirectory,'parameters.mat'),parameterPayload);

signature = buildSignature(spec,inputHash,orbit9,maxFrequency,options);
checkpointFile = fullfile(caseDirectory,'checkpoint.mat');
resultFile = fullfile(caseDirectory,'results.mat');
[reused,saved] = reusableResult(resultFile,signature,options.Resume);
if reused
    result = saved.result;
    row = saved.summary;
    if isfield(saved,'figureEntries')
        figureEntries = saved.figureEntries;
    else
        figureEntries = repmat(emptyFigureEntry(),0,1);
    end
    row.reused = true;
    [figureEntries,row] = writeDerivedOutputs( ...
        result,row,figureEntries,spec,caseDirectory,figureDirectory, ...
        outputRoot,parameterPayload,options);
    saveAtomic(resultFile,struct('result',result,'summary',row, ...
        'figureEntries',figureEntries,'signature',signature));
    writeResultManifest(caseDirectory,signature,row,figureEntries);
    checkpoint = struct('status','complete','signature',signature, ...
        'updated_at',timestampNow(),'error','');
    saveAtomic(checkpointFile,struct('checkpoint',checkpoint));
    caseManifest = completedCaseManifest(spec,caseName,inputFile, ...
        inputHash,row,figureEntries,true);
    writeJsonAtomic(fullfile(caseDirectory,'case_manifest.json'),caseManifest);
    logMessage(logPaths,sprintf('Reused completed numerical result for %s.', ...
        spec.id));
    return
end

checkpoint = struct('status','running','signature',signature, ...
    'updated_at',timestampNow(),'error','');
saveAtomic(checkpointFile,struct('checkpoint',checkpoint));
startedAt = timestampNow();
timerValue = tic;
progressFcn = [];
if options.ShowProgress
    progressFcn = createProgressReporter(logPaths,spec.title);
end
try
    result = interleavedcvcoco(clean,orbit9,spec.pad, ...
        spec.sr1,spec.sr2,spec.srstep,options.Red,options.NSim, ...
        options.Method,'BatchSize',options.BatchSize,'Seed',options.Seed, ...
        'MaxFrequency',maxFrequency,'ProgressFcn',progressFcn, ...
        'AnalysisName','Interleaved cvCOCO');
    completedAt = timestampNow();
    elapsedSeconds = toc(timerValue);
    row = summarizeResult(spec,result,options,startedAt,completedAt, ...
        elapsedSeconds);
    figureEntries = repmat(emptyFigureEntry(),0,1);

    % Save the expensive numerical result before derived exports.  A later
    % resume can repair tables/figures if export is interrupted.
    saveAtomic(resultFile,struct('result',result,'summary',row, ...
        'figureEntries',figureEntries,'signature',signature));
    checkpoint.status = 'computed';
    checkpoint.updated_at = timestampNow();
    saveAtomic(checkpointFile,struct('checkpoint',checkpoint));

    [figureEntries,row] = writeDerivedOutputs( ...
        result,row,figureEntries,spec,caseDirectory,figureDirectory, ...
        outputRoot,parameterPayload,options);
    saveAtomic(resultFile,struct('result',result,'summary',row, ...
        'figureEntries',figureEntries,'signature',signature));
    writeResultManifest(caseDirectory,signature,row,figureEntries);
    checkpoint.status = 'complete';
    checkpoint.updated_at = timestampNow();
    checkpoint.error = '';
    saveAtomic(checkpointFile,struct('checkpoint',checkpoint));
catch exception
    if isfile(resultFile)
        checkpoint.status = 'computed';
    else
        checkpoint.status = 'failed';
    end
    checkpoint.updated_at = timestampNow();
    checkpoint.error = exceptionReport(exception);
    saveAtomic(checkpointFile,struct('checkpoint',checkpoint));
    rethrow(exception)
end

caseManifest = completedCaseManifest(spec,caseName,inputFile,inputHash, ...
    row,figureEntries,false);
writeJsonAtomic(fullfile(caseDirectory,'case_manifest.json'),caseManifest);
logMessage(logPaths,sprintf([ ...
    'Completed %s in %.3f s: Odd->Even %.6g, Even->Odd %.6g, ', ...
    'pSym %.6g, pRobust %.6g.'],spec.id,row.elapsed_seconds, ...
    row.best_rate_odd_to_even,row.best_rate_even_to_odd, ...
    row.p_symmetric,row.p_robust));
end

function [figureEntries,row] = writeDerivedOutputs( ...
        result,row,figureEntries,spec,caseDirectory,figureDirectory, ...
        outputRoot,parameterPayload,options)
writeCurves(fullfile(caseDirectory,'curves.csv'),result);
writeNullStatistics(fullfile(caseDirectory,'null_statistics.csv'),result);
writeSummaryCsv(fullfile(caseDirectory,'summary.csv'),row);
writeSummaryText(fullfile(caseDirectory,'summary.txt'),row);
if options.ExportFigures && ~figuresExist(figureEntries,outputRoot)
    figureEntries = exportResultFigures( ...
        result,spec,figureDirectory,outputRoot,options);
end
row.figure_count = numel(figureEntries);
writeSummaryCsv(fullfile(caseDirectory,'summary.csv'),row);
writeSummaryText(fullfile(caseDirectory,'summary.txt'),row);
writeResultsWorkbookAtomic(fullfile(caseDirectory,'results.xlsx'), ...
    parameterPayload,row,result);
end

function row = summarizeResult( ...
        spec,result,options,startedAt,completedAt,elapsedSeconds)
row = emptySummaryRow();
row.dataset_id = spec.id;
row.dataset_title = spec.title;
row.category = spec.category;
row.status = 'complete';
row.reused = false;
row.age_ma = spec.age_ma;
row.expected_rate = spec.expected_rate;
row.rate_min_cm_per_kyr = spec.sr1;
row.rate_max_cm_per_kyr = spec.sr2;
row.rate_step_cm_per_kyr = spec.srstep;
row.pad = spec.pad;
row.monte_carlo_requested = options.NSim;
row.monte_carlo_completed = result.nsimCompleted;
row.best_rate_odd_to_even = result.validateAtoB.bestRate;
row.best_rate_even_to_odd = result.validateBtoA.bestRate;
row.p_global_odd_to_even = result.pAtoB;
row.p_global_even_to_odd = result.pBtoA;
row.p_robust = finiteMaximum([result.pAtoB,result.pBtoA]);
row.p_symmetric = result.pSym;
row.p_local_odd_to_even_at_best = result.validateAtoB.pLocalAtBest;
row.p_local_even_to_odd_at_best = result.validateBtoA.pLocalAtBest;
row.rho_full_record = result.rhoM;
allNineRange = result.allNineRateRangeShared(:)';
if numel(allNineRange) ~= 2
    allNineRange = [NaN,NaN];
end
row.all_nine_rate_min_cm_per_kyr = allNineRange(1);
row.all_nine_rate_max_cm_per_kyr = allNineRange(2);
row.best_odd_to_even_in_all_nine_range = rateInRange( ...
    row.best_rate_odd_to_even,allNineRange);
row.best_even_to_odd_in_all_nine_range = rateInRange( ...
    row.best_rate_even_to_odd,allNineRange);
[row.expected_target_intersects_all_nine_range, ...
    row.expected_target_fully_within_all_nine_range] = ...
    expectedRangeResolution(spec.expected_windows,allNineRange);
row.significant_odd_to_even = isSignificant(result.pAtoB);
row.significant_even_to_odd = isSignificant(result.pBtoA);
row.significant_symmetric = isSignificant(result.pSym);
row.significant_robust = isSignificant(row.p_robust);
row.expected_rate_hit = expectedRateHit(spec,result);
row.started_at = startedAt;
row.completed_at = completedAt;
row.elapsed_seconds = elapsedSeconds;
row.figure_count = 0;
row.error_identifier = '';
row.error_message = '';
row.conclusion = sprintf([ ...
    'Odd->Even best %.6g cm/kyr (global p %.6g); ', ...
    'Even->Odd best %.6g cm/kyr (global p %.6g); ', ...
    'symmetric p %.6g; conservative max directional p %.6g; ', ...
    'shared all-nine range %.6g-%.6g cm/kyr.'], ...
    row.best_rate_odd_to_even,row.p_global_odd_to_even, ...
    row.best_rate_even_to_odd,row.p_global_even_to_odd, ...
    row.p_symmetric,row.p_robust,row.all_nine_rate_min_cm_per_kyr, ...
    row.all_nine_rate_max_cm_per_kyr);
end

function entries = exportResultFigures( ...
        result,spec,figureDirectory,outputRoot,options)
stem = sprintf('%s-Interleaved_cvCOCO-MC%d', ...
    sanitizeFilename(spec.id),options.NSim);
entries = repmat(emptyFigureEntry(),0,1);
tabbedFigure = gobjects(0);
pageFigures = gobjects(0);
try
    tabbedFigure = plotcvcoco(result,'ShowSpectra',true,'Tabbed',true);
    set(tabbedFigure,'Name',sprintf('%s — Interleaved cvCOCO',spec.title), ...
        'Visible',options.Visible);
    drawnow;
    figPath = fullfile(figureDirectory,[stem,'.fig']);
    temporaryFig = [tempname(figureDirectory),'.fig'];
    cleanupFig = onCleanup(@()deleteIfPresent(temporaryFig));
    savefig(tabbedFigure,temporaryFig);
    finalizeAtomicFile(temporaryFig,figPath);
    clear cleanupFig
    entries(end+1,1) = figureEntry(figPath,outputRoot, ...
        'tabbed editable diagnostics','FIG');

    pageFigures = plotcvcoco(result,'ShowSpectra',true,'Tabbed',false);
    expectedKinds = {'data-and-spectra','correlation-and-significance', ...
        'pcoco','monte-carlo-audit'};
    if numel(pageFigures) ~= numel(expectedKinds)
        error('runInterleavedCvCocoComparison:UnexpectedFigureCount', ...
            'plotcvcoco returned %d pages; expected %d.', ...
            numel(pageFigures),numel(expectedKinds));
    end
    pdfPath = fullfile(figureDirectory,[stem,'.pdf']);
    temporaryPdf = [tempname(figureDirectory),'.pdf'];
    cleanupPdf = onCleanup(@()deleteIfPresent(temporaryPdf));
    for pageIndex = 1:numel(pageFigures)
        set(pageFigures(pageIndex),'Color','w','Visible',options.Visible);
        drawnow;
        exportgraphics(pageFigures(pageIndex),temporaryPdf, ...
            'ContentType','vector','Append',pageIndex > 1, ...
            'BackgroundColor','white');
        pngPath = fullfile(figureDirectory,sprintf('%s-%02d-%s.png', ...
            stem,pageIndex,expectedKinds{pageIndex}));
        temporaryPng = [tempname(figureDirectory),'.png'];
        cleanupPng = onCleanup(@()deleteIfPresent(temporaryPng));
        exportgraphics(pageFigures(pageIndex),temporaryPng, ...
            'Resolution',300,'BackgroundColor','white');
        finalizeAtomicFile(temporaryPng,pngPath);
        clear cleanupPng
        entries(end+1,1) = figureEntry(pngPath,outputRoot, ...
            expectedKinds{pageIndex},'PNG'); %#ok<AGROW>
    end
    finalizeAtomicFile(temporaryPdf,pdfPath);
    clear cleanupPdf
    entries(end+1,1) = figureEntry(pdfPath,outputRoot, ...
        'multipage vector diagnostics','PDF');
catch exception
    closeFigureHandles(tabbedFigure);
    closeFigureHandles(pageFigures);
    rethrow(exception)
end
if options.CloseFigures
    closeFigureHandles(tabbedFigure);
    closeFigureHandles(pageFigures);
end
end

function writeCurves(path,result)
[header,values] = curveData(result);
writeNumericCsvAtomic(path,header,values);
end

function [header,values] = curveData(result)
header = {'sedimentation_rate_cm_per_kyr','train_odd','train_even', ...
    'validate_odd_to_even','validate_even_to_odd', ...
    'consensus_rho', ...
    'directional_global_p_curve_odd_to_even', ...
    'directional_global_p_curve_even_to_odd', ...
    'consensus_global_p_curve', ...
    'local_p_curve_odd_to_even','local_p_curve_even_to_odd', ...
    'consensus_local_p_curve','pCOCO', ...
    'resolvable_orbit_count_odd','resolvable_orbit_count_even', ...
    'consensus_active_orbit_count', ...
    'valid_rate_odd','valid_rate_even'};
values = [result.srGrid(:),result.trainA.curve(:), ...
    result.trainB.curve(:),result.validateAtoB.curve(:), ...
    result.validateBtoA.curve(:),result.consensus.curve(:), ...
    result.pCurveAtoB(:),result.pCurveBtoA(:), ...
    result.pCurveConsensus(:),result.pLocalCurveAtoB(:), ...
    result.pLocalCurveBtoA(:),result.pLocalCurveConsensus(:), ...
    result.pCOCO(:),result.orbitCountA(:), ...
    result.orbitCountB(:),result.activeOrbitCountConsensus(:), ...
    double(result.validRateMaskA(:)), ...
    double(result.validRateMaskB(:))];
end

function writeNullStatistics(path,result)
[header,values] = nullStatisticData(result);
writeNumericCsvAtomic(path,header,values);
end

function [header,values] = nullStatisticData(result)
nSimulation = numel(result.nullSymmetric);
values = [(1:nSimulation)',result.nullSymmetric(:), ...
    result.nullConsensus(:),result.nullAtoB(:),result.nullBtoA(:), ...
    result.nullBestRateAtoB(:),result.nullBestRateBtoA(:)];
header = {'simulation','null_symmetric_min_directional_score', ...
    'null_same_rate_consensus_maximum', ...
    'null_max_odd_to_even','null_max_even_to_odd', ...
    'null_best_rate_odd_to_even_cm_per_kyr', ...
    'null_best_rate_even_to_odd_cm_per_kyr'};
end

function writeParameters(path,payload)
writeCellAtomic(path,parameterCells(payload));
end

function parameters = parameterCells(payload)
spec = payload.spec;
options = payload.options;
parameters = {
    'Parameter','Value';
    'Method','Interleaved cvCOCO';
    'Target model','four-group-coherent-nine';
    'Dataset ID',spec.id;
    'Dataset title',spec.title;
    'Category',spec.category;
    'Input file',payload.inputFile;
    'Input SHA-256',payload.inputSha256;
    'Original rows read',payload.originalRowCount;
    'Finite sorted unique rows',payload.cleanPointCount;
    'Full-record GUI median-spacing point count', ...
        payload.guiRegularizedPointCount;
    'Full-record GUI interpolation applied', ...
        yesNo(payload.guiInterpolationApplied);
    'Input median spacing (m)',payload.medianSpacing;
    'Age (Ma)',spec.age_ma;
    'Astronomical solution', ...
        'AstroGeo22/Farhat 2022 k plus La2004 secular g/s';
    'Orbit periods (kyr)',mat2str(payload.orbit9(:)',12);
    'Sedimentation-rate minimum (cm/kyr)',spec.sr1;
    'Sedimentation-rate maximum (cm/kyr)',spec.sr2;
    'Sedimentation-rate step (cm/kyr)',spec.srstep;
    'Expected/reference rate',spec.expected_rate;
    'Expected windows (cm/kyr)',mat2str(spec.expected_windows);
    'Pad used',spec.pad;
    'Pad calculated by GUI rule',payload.calculatedGuiPad;
    'Enforce GUI Pad',yesNo(options.EnforceGuiPad);
    'MaxFrequency (cycle/kyr)',payload.maximumFrequency;
    'MaxFrequency rule','1.2 x highest nominal orbital frequency';
    'Monte Carlo simulations',options.NSim;
    'Correlation method',options.Method;
    'Red-noise removal code',options.Red;
    'Random seed',options.Seed;
    'Batch size',options.BatchSize;
    'Split rule','sorted unique odd/even observations, then fold-local interpolation';
    'Null model','joint full-record sample-index stationary Gaussian AR(1)';
    'Observed and null linear detrending','yes, independently for every spectrum'};
end

function writeResultsWorkbookAtomic(path,payload,row,result)
ensureDirectory(fileparts(path));
temporary = [tempname(fileparts(path)),'.xlsx'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writecell(parameterCells(payload),temporary,'Sheet','Parameters');
writetable(struct2table(row,'AsArray',true),temporary,'Sheet','Summary');
[curveHeader,curveValues] = curveData(result);
writetable(array2table(curveValues,'VariableNames',curveHeader), ...
    temporary,'Sheet','Curves');
[nullHeader,nullValues] = nullStatisticData(result);
writetable(array2table(nullValues,'VariableNames',nullHeader), ...
    temporary,'Sheet','NullStatistics');
writetable(twoColumnTable(result.dataClean),temporary,'Sheet','CleanInput');
writetable(twoColumnTable(result.rawDataA),temporary,'Sheet','RawOdd');
writetable(twoColumnTable(result.rawDataB),temporary,'Sheet','RawEven');
writetable(twoColumnTable(result.dataA),temporary,'Sheet','OddFold');
writetable(twoColumnTable(result.dataB),temporary,'Sheet','EvenFold');
finalizeAtomicFile(temporary,path);
clear cleanup
end

function value = twoColumnTable(data)
value = array2table(data(:,1:2),'VariableNames',{'depth_m','value'});
end

function writeSummaryText(path,row)
text = sprintf([ ...
    'Dataset: %s\nMethod: Interleaved cvCOCO\nStatus: %s\n', ...
    'Age (Ma): %.12g\nRate grid (cm/kyr): %.12g : %.12g : %.12g\n', ...
    'MC requested/completed: %d / %d\n', ...
    'Odd trained -> Even validated best rate: %.12g\n', ...
    'Even trained -> Odd validated best rate: %.12g\n', ...
    'Odd -> Even directional global p: %.12g\n', ...
    'Even -> Odd directional global p: %.12g\n', ...
    'Symmetric p: %.12g\nConservative max directional p: %.12g\n', ...
    'Odd -> Even local p at best: %.12g\n', ...
    'Even -> Odd local p at best: %.12g\n', ...
    'Full-record AR(1) rho: %.12g\n', ...
    'Shared all-nine rate range (cm/kyr): %.12g to %.12g\n', ...
    'Odd -> Even best within all-nine range: %s\n', ...
    'Even -> Odd best within all-nine range: %s\n', ...
    'Expected target intersects all-nine range: %s\n', ...
    'Expected target fully within all-nine range: %s\n', ...
    'Started: %s\nCompleted: %s\n', ...
    'Elapsed seconds: %.6f\nConclusion: %s\n'], ...
    row.dataset_title,row.status,row.age_ma, ...
    row.rate_min_cm_per_kyr,row.rate_step_cm_per_kyr, ...
    row.rate_max_cm_per_kyr,row.monte_carlo_requested, ...
    row.monte_carlo_completed,row.best_rate_odd_to_even, ...
    row.best_rate_even_to_odd,row.p_global_odd_to_even, ...
    row.p_global_even_to_odd,row.p_symmetric,row.p_robust, ...
    row.p_local_odd_to_even_at_best, ...
    row.p_local_even_to_odd_at_best,row.rho_full_record, ...
    row.all_nine_rate_min_cm_per_kyr, ...
    row.all_nine_rate_max_cm_per_kyr, ...
    yesNo(row.best_odd_to_even_in_all_nine_range), ...
    yesNo(row.best_even_to_odd_in_all_nine_range), ...
    yesNo(row.expected_target_intersects_all_nine_range), ...
    yesNo(row.expected_target_fully_within_all_nine_range), ...
    row.started_at,row.completed_at,row.elapsed_seconds,row.conclusion);
writeTextAtomic(path,text);
end

function writeComparisonReport(path,rows,options)
lines = {
    '# Interleaved cvCOCO seven-record comparison';
    '';
    sprintf('Updated: %s',timestampNow());
    '';
    '## Registered analysis';
    '';
    sprintf(['Interleaved cvCOCO; %s correlation; red code %d; ', ...
        'MC=%d; seed=%d; BatchSize=%d.'],options.Method,options.Red, ...
        options.NSim,options.Seed,options.BatchSize);
    ['Each cleaned, sorted, unique record is split into odd/even ', ...
        'observations before fold-local median-spacing interpolation.'];
    ['The frequency ceiling is 1.2 times the highest nominal orbital ', ...
        'frequency. Observed data and every joint AR(1) null realization ', ...
        'receive the same fold-level linear detrending.'];
    '';
    '## Resolution caveat';
    '';
    ['The shared all-nine range is the sedimentation-rate interval in ', ...
        'which all nine orbital periods are resolvable in both folds for ', ...
        'training. Curves can remain finite outside this interval using ', ...
        'fewer participating periods; those points must not be described ', ...
        'as a full nine-period test. The Newark and Givetian target/rate ', ...
        'results should therefore be read together with the range columns.'];
    '';
    '## Results';
    '';
    ['| Data set | Status | Odd→Even rate | Even→Odd rate | ', ...
        'p Odd→Even | p Even→Odd | symmetric p | robust p | ', ...
        'shared all-nine range | both best rates in range | ', ...
        'target intersects / fully within |'];
    ['|---|---:|---:|---:|---:|---:|---:|---:|---:|', ...
        '---:|---:|']};
if isempty(rows)
    lines{end+1} = '| No completed cases yet | — | — | — | — | — | — | — | — | — | — |';
else
    for rowIndex = 1:numel(rows)
        row = rows(rowIndex);
        allBestInRange = row.best_odd_to_even_in_all_nine_range && ...
            row.best_even_to_odd_in_all_nine_range;
        rangeText = sprintf('%s–%s', ...
            formatNumber(row.all_nine_rate_min_cm_per_kyr), ...
            formatNumber(row.all_nine_rate_max_cm_per_kyr));
        targetText = sprintf('%s / %s', ...
            yesNo(row.expected_target_intersects_all_nine_range), ...
            yesNo(row.expected_target_fully_within_all_nine_range));
        lines{end+1} = sprintf( ...
            '| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |', ...
            escapeMarkdown(row.dataset_title),row.status, ...
            formatNumber(row.best_rate_odd_to_even), ...
            formatNumber(row.best_rate_even_to_odd), ...
            formatNumber(row.p_global_odd_to_even), ...
            formatNumber(row.p_global_even_to_odd), ...
            formatNumber(row.p_symmetric),formatNumber(row.p_robust), ...
            rangeText,yesNo(allBestInRange),targetText); %#ok<AGROW>
    end
end
lines = [lines;{
    '';
    '## Interpretation notes';
    '';
    ['Directional global p-values include the held-out rate search. ', ...
        'The symmetric p-value tests the weaker of the two directional ', ...
        'scores against the same full bidirectional null pipeline. The ', ...
        'robust p-value is the maximum of the two directional p-values ', ...
        'and requires both directions to pass separately.'];
    ['The 4-to-6 cm/kyr synthetic record is deliberately outside the ', ...
        'single-rate whole-record model: both odd/even folds mix both ', ...
        'halves. A selected 4, 6, or intermediate rate describes the ', ...
        'dominant whole-record match and cannot locate or validate the ', ...
        '4-to-6 transition. Sliding-window eCOCO or explicit segmented ', ...
        'analysis is required for that claim.'];
    ''}];
writeTextAtomic(path,strjoin(lines,newline));
end

function text = formatNumber(value)
if isfinite(value)
    text = sprintf('%.6g',value);
else
    text = '—';
end
end

function text = escapeMarkdown(value)
text = strrep(char(string(value)),'|','\|');
end

function writeResultManifest(caseDirectory,signature,row,figureEntries)
manifest = struct('schema_version',1,'signature',signature, ...
    'summary',row,'figures',figureEntries,'updated_at',timestampNow(), ...
    'results_mat','results.mat','parameters_csv','parameters.csv', ...
    'curves_csv','curves.csv','null_statistics_csv','null_statistics.csv', ...
    'summary_csv','summary.csv','summary_txt','summary.txt', ...
    'results_xlsx','results.xlsx');
manifest.figures = num2cell(figureEntries(:));
writeJsonAtomic(fullfile(caseDirectory,'result.json'),manifest);
end

function manifest = completedCaseManifest( ...
        spec,caseName,inputFile,inputHash,row,figureEntries,reused)
manifest = emptyCaseManifest();
manifest.id = spec.id;
manifest.title = spec.title;
manifest.status = 'complete';
manifest.reused = reused;
manifest.input_file = inputFile;
manifest.input_sha256 = inputHash;
manifest.case_dir = caseName;
manifest.results_mat = fullfile(caseName,'results.mat');
manifest.results_xlsx = fullfile(caseName,'results.xlsx');
manifest.parameters_csv = fullfile(caseName,'parameters.csv');
manifest.summary_csv = fullfile(caseName,'summary.csv');
manifest.curves_csv = fullfile(caseName,'curves.csv');
manifest.null_statistics_csv = fullfile(caseName,'null_statistics.csv');
manifest.figures = figureEntries;
manifest.best_rate_odd_to_even = row.best_rate_odd_to_even;
manifest.best_rate_even_to_odd = row.best_rate_even_to_odd;
manifest.p_symmetric = row.p_symmetric;
manifest.p_robust = row.p_robust;
manifest.updated_at = timestampNow();
end

function [manifest,row] = failedDataset( ...
        spec,index,outputRoot,exception,options)
caseName = sprintf('%02d_%s',index,sanitizeFilename(spec.id));
caseDirectory = fullfile(outputRoot,caseName);
ensureDirectory(caseDirectory);
writeTextAtomic(fullfile(caseDirectory,'error.txt'), ...
    exceptionReport(exception));
row = emptySummaryRow();
row.dataset_id = spec.id;
row.dataset_title = spec.title;
row.category = spec.category;
row.status = 'failed';
row.age_ma = spec.age_ma;
row.expected_rate = spec.expected_rate;
row.rate_min_cm_per_kyr = spec.sr1;
row.rate_max_cm_per_kyr = spec.sr2;
row.rate_step_cm_per_kyr = spec.srstep;
row.pad = spec.pad;
row.monte_carlo_requested = options.NSim;
row.error_identifier = exception.identifier;
row.error_message = exception.message;
row.completed_at = timestampNow();
row.conclusion = sprintf('FAILED: %s (%s)', ...
    exception.message,exception.identifier);
manifest = emptyCaseManifest();
manifest.id = spec.id;
manifest.title = spec.title;
manifest.status = 'failed';
manifest.case_dir = caseName;
manifest.summary_csv = fullfile(caseName,'summary.csv');
manifest.updated_at = timestampNow();
writeSummaryCsv(fullfile(caseDirectory,'summary.csv'),row);
writeSummaryText(fullfile(caseDirectory,'summary.txt'),row);
writeJsonAtomic(fullfile(caseDirectory,'case_manifest.json'),manifest);
end

function plan = defaultDatasetPlan(inputRoot)
items = {
    'noise80m','80 m red-noise negative control','noise', ...
        'rednoise0.5-80m.csv',0,0.1,20,0.1,5000, ...
        'no physical true rate; 4 cm/kyr comparison reference',[3.5,4.5];
    'la04_4cm_red07','La2004 1E1T1P plus red noise, 4 cm/kyr', ...
        'theory','La2004-1E1T-1P-54-59Ma-4cmkyr+Red0.7.txt', ...
        56,0.1,10,0.1,10000,'4 cm/kyr',[3.5,4.5];
    'la04_4to6cm_red07','La2004 ETP plus red noise, 4-to-6 cm/kyr', ...
        'variable','la04etp54-59ma4-6cmka-rsp0.04+Red0.7.txt', ...
        56,0.1,10,0.1,10000, ...
        '4 cm/kyr first half; 6 cm/kyr second half', ...
        [3.5,4.5;5.5,6.5];
    'site1262','ODP Site 1262 XRF Fe residual','real', ...
        '1262XRF-Fe-log10-s.u.-111-170-10-rLOESS-dpks-0.5_0.4.txt', ...
        56,0.1,3,0.02,10000,'approximately 1-1.3 cm/kyr',[1,1.3];
    'wayao','Wayao Carnian gamma-ray residual','real', ...
        'Example-WayaoCarnianGR0-80-LOWESS.txt', ...
        235,1,20,0.1,5000,'approximately 9 cm/kyr',[7.2,10.8];
    'newark','Newark 2-km record','real','newark2km-s-rsp0.85.txt', ...
        210,1,30,0.1,5000,'approximately 15 cm/kyr',[12,18];
    'givetian','Givetian DD14 residual','real', ...
        'GivetianDD14-s.u.-new-log10-80-rLOESS.txt', ...
        385,1,20,0.1,5000,'approximately 8 cm/kyr',[6.4,9.6]};
plan = repmat(emptyDataset(),size(items,1),1);
for itemIndex = 1:size(items,1)
    plan(itemIndex).id = items{itemIndex,1};
    plan(itemIndex).title = items{itemIndex,2};
    plan(itemIndex).category = items{itemIndex,3};
    plan(itemIndex).filename = items{itemIndex,4};
    plan(itemIndex).input_file = fullfile(inputRoot,items{itemIndex,4});
    plan(itemIndex).age_ma = items{itemIndex,5};
    plan(itemIndex).sr1 = items{itemIndex,6};
    plan(itemIndex).sr2 = items{itemIndex,7};
    plan(itemIndex).srstep = items{itemIndex,8};
    plan(itemIndex).pad = items{itemIndex,9};
    plan(itemIndex).expected_rate = items{itemIndex,10};
    plan(itemIndex).expected_windows = items{itemIndex,11};
end
end

function plan = normalizeDatasetPlan(plan,inputRoot)
template = emptyDataset();
fieldNames = fieldnames(template);
normalized = repmat(template,numel(plan),1);
for itemIndex = 1:numel(plan)
    for fieldIndex = 1:numel(fieldNames)
        name = fieldNames{fieldIndex};
        if isfield(plan,name)
            normalized(itemIndex).(name) = plan(itemIndex).(name);
        end
    end
    if strlength(string(normalized(itemIndex).id)) == 0
        normalized(itemIndex).id = sprintf('dataset_%d',itemIndex);
    end
    if strlength(string(normalized(itemIndex).title)) == 0
        normalized(itemIndex).title = normalized(itemIndex).id;
    end
    if strlength(string(normalized(itemIndex).category)) == 0
        normalized(itemIndex).category = 'unspecified';
    end
    if strlength(string(normalized(itemIndex).input_file)) == 0
        normalized(itemIndex).input_file = fullfile( ...
            inputRoot,char(string(normalized(itemIndex).filename)));
    end
    normalized(itemIndex).id = char(string(normalized(itemIndex).id));
    normalized(itemIndex).title = char(string(normalized(itemIndex).title));
    normalized(itemIndex).category = char(string(normalized(itemIndex).category));
    normalized(itemIndex).filename = char(string(normalized(itemIndex).filename));
    normalized(itemIndex).input_file = ...
        char(string(normalized(itemIndex).input_file));
    normalized(itemIndex).expected_rate = ...
        char(string(normalized(itemIndex).expected_rate));
    validateDataset(normalized(itemIndex));
end
plan = normalized;
end

function validateDataset(spec)
validateattributes(spec.age_ma,{'numeric'}, ...
    {'scalar','real','finite','nonnegative'});
validateattributes(spec.sr1,{'numeric'}, ...
    {'scalar','real','finite','positive'});
validateattributes(spec.sr2,{'numeric'}, ...
    {'scalar','real','finite','>=',spec.sr1});
validateattributes(spec.srstep,{'numeric'}, ...
    {'scalar','real','finite','positive'});
validateattributes(spec.pad,{'numeric'}, ...
    {'scalar','integer','finite','positive'});
validateattributes(spec.expected_windows,{'numeric'}, ...
    {'2d','ncols',2,'real','finite'});
end

function selected = selectDatasets(plan,requested)
if isempty(requested)
    selected = plan;
    return
end
if ischar(requested)
    requested = string({requested});
else
    requested = string(requested(:));
end
ids = string({plan.id});
unknown = setdiff(requested,ids,'stable');
if ~isempty(unknown)
    error('runInterleavedCvCocoComparison:UnknownDataset', ...
        'Unknown DatasetIDs: %s.',strjoin(unknown,', '));
end
selected = plan(ismember(ids,requested));
end

function clean = cleanInput(raw)
clean = raw(all(isfinite(raw),2),:);
clean = sortrows(clean,1);
if isempty(clean)
    return
end
[depth,~,group] = unique(clean(:,1),'sorted');
clean = [depth,accumarray(group,clean(:,2),[],@mean)];
end

function [pointCount,interpolationApplied,dt] = ...
        guiRegularizedPointCount(clean)
spacing = diff(clean(:,1));
spacing = spacing(isfinite(spacing) & spacing > 0);
if isempty(spacing)
    error('runInterleavedCvCocoComparison:InvalidDepthSpacing', ...
        'A positive depth spacing is required.');
end
dt = median(spacing);
tolerance = cocoSamplingTolerance(clean(:,1),dt);
interpolationApplied = max(abs(spacing-dt)) > tolerance;
if ~interpolationApplied
    pointCount = size(clean,1);
    return
end
intervalCountExact = (clean(end,1)-clean(1,1))/dt;
intervalCountRounded = round(intervalCountExact);
countTolerance = 1e-10*max(1,abs(intervalCountExact));
if abs(intervalCountExact-intervalCountRounded) <= countTolerance
    intervalCount = intervalCountRounded;
else
    intervalCount = floor(intervalCountExact);
end
pointCount = intervalCount+1;
if ~isfinite(pointCount) || pointCount < 2 || pointCount > 5e6
    error('runInterleavedCvCocoComparison:InterpolationGridTooLarge', ...
        'GUI median-spacing interpolation would create %g points.',pointCount);
end
end

function pad = defaultGuiPad(pointCount)
if pointCount <= 2500
    pad = 5000;
elseif pointCount <= 5000
    pad = 10000;
else
    pad = fix(pointCount/5000)*5000+5000;
end
end

function signature = buildSignature( ...
        spec,inputHash,orbit9,maxFrequency,options)
value = struct( ...
    'schema',2,'dataset_id',spec.id,'dataset_title',spec.title, ...
    'category',spec.category,'expected_rate',spec.expected_rate, ...
    'expected_windows',spec.expected_windows, ...
    'input_sha256',inputHash, ...
    'age_ma',spec.age_ma,'orbit9',orbit9(:)', ...
    'rate_grid',[spec.sr1,spec.sr2,spec.srstep], ...
    'pad',spec.pad,'nsim',options.NSim,'seed',options.Seed, ...
    'red',options.Red,'method',options.Method, ...
    'batch_size',options.BatchSize,'maximum_frequency',maxFrequency, ...
    'target_model','four-group-coherent-nine', ...
    'split_mode','interleaved','matlab_release',version('-release'), ...
    'engine_sha256',engineFingerprint(options.Red));
signature = jsonencode(value);
end

function digest = engineFingerprint(red)
paths = {which('interleavedcvcoco'),which('cvcoco'), ...
    which('cocoNonnegativeLeakageSolve'), ...
    which('cocoSamplingTolerance'), ...
    which('cocoResolvedDetrendedVariance'), ...
    which('calculate_orbit9')};
switch red
    case 1
        paths{end+1} = which('theoredar1ML');
    case 2
        paths{end+1} = which('redconf_any');
    case 3
        paths{end+1} = which('specswa');
end
parts = strings(numel(paths),1);
for pathIndex = 1:numel(paths)
    if isempty(paths{pathIndex}) || ~isfile(paths{pathIndex})
        parts(pathIndex) = "missing";
    else
        parts(pathIndex) = string(sha256File(paths{pathIndex}));
    end
end
digest = char(join(parts,':'));
end

function [tf,saved] = reusableResult(resultFile,signature,resume)
tf = false;
saved = struct;
% RESULTS.MAT is authoritative.  The process can be interrupted after its
% atomic save but before CHECKPOINT.MAT advances from running to computed;
% requiring checkpoint status/signature here would repeat finished Monte
% Carlo work.  A complete, matching result is safe to reuse regardless of
% a missing, stale, or still-running checkpoint.
if ~resume || ~isfile(resultFile)
    return
end
try
    saved = load(resultFile,'result','summary','figureEntries','signature');
    tf = isfield(saved,'signature') && strcmp(saved.signature,signature) && ...
        isfield(saved,'result') && isfield(saved,'summary');
catch
    tf = false;
    saved = struct;
end
end

function callback = createProgressReporter(logPaths,label)
lastBucket = -1;
callback = @report;
    function report(fraction,message)
        fraction = min(max(double(fraction),0),1);
        bucket = min(100,10*floor(10*fraction));
        if fraction >= 1
            bucket = 100;
        end
        if bucket <= lastBucket
            return
        end
        lastBucket = bucket;
        logMessage(logPaths,sprintf('%s: %3d%% — %s', ...
            label,bucket,char(string(message))));
    end
end

function tf = expectedRateHit(spec,result)
if isempty(spec.expected_windows) || strcmp(spec.category,'noise')
    tf = false;
    return
end
tf = rateInWindows(result.validateAtoB.bestRate,spec.expected_windows) && ...
    rateInWindows(result.validateBtoA.bestRate,spec.expected_windows);
end

function tf = rateInWindows(rate,windows)
tf = isfinite(rate) && any(rate >= windows(:,1) & rate <= windows(:,2));
end

function tf = rateInRange(rate,range)
tf = numel(range) == 2 && all(isfinite(range)) && range(1) <= range(2) && ...
    isfinite(rate) && rate >= range(1) && rate <= range(2);
end

function [intersects,fullyWithin] = ...
        expectedRangeResolution(windows,range)
intersects = false;
fullyWithin = false;
if isempty(windows) || numel(range) ~= 2 || ...
        ~all(isfinite(range)) || range(1) > range(2)
    return
end
intersects = any(windows(:,2) >= range(1) & windows(:,1) <= range(2));
fullyWithin = all(windows(:,1) >= range(1) & windows(:,2) <= range(2));
end

function value = finiteMaximum(values)
values = values(isfinite(values));
if isempty(values)
    value = NaN;
else
    value = max(values);
end
end

function tf = isSignificant(value)
tf = isfinite(value) && value < 0.05;
end

function tf = figuresExist(entries,root)
expectedKinds = { ...
    'tabbed editable diagnostics'; ...
    'data-and-spectra'; ...
    'correlation-and-significance'; ...
    'pcoco'; ...
    'monte-carlo-audit'; ...
    'multipage vector diagnostics'};
expectedFormats = {'FIG';'PNG';'PNG';'PNG';'PNG';'PDF'};
tf = numel(entries) == numel(expectedKinds);
if ~tf || ~isstruct(entries) || ...
        ~all(isfield(entries,{'path','kind','format'}))
    tf = false;
    return
end
tf = isequal({entries.kind}',expectedKinds) && ...
    isequal({entries.format}',expectedFormats);
for entryIndex = 1:numel(entries)
    tf = tf && isfile(fullfile(root,entries(entryIndex).path));
end
end

function entry = figureEntry(path,root,kind,format)
entry = emptyFigureEntry();
entry.path = relativePath(path,root);
entry.kind = kind;
entry.format = format;
end

function closeFigureHandles(figures)
for figureIndex = 1:numel(figures)
    if isgraphics(figures(figureIndex))
        close(figures(figureIndex));
    end
end
end

function options = publicOptions(options)
options = rmfield(options,{'DatasetPlan'});
end

function status = overallStatus(cases)
if isempty(cases)
    status = 'failed';
    return
end
states = string({cases.status});
if all(states == "complete")
    status = 'complete';
elseif any(states == "complete")
    status = 'partial';
else
    status = 'failed';
end
end

function item = emptyDataset()
item = struct('id','','title','','category','','filename','', ...
    'input_file','','age_ma',NaN,'sr1',NaN,'sr2',NaN,'srstep',NaN, ...
    'pad',NaN,'expected_rate','','expected_windows',zeros(0,2));
end

function row = emptySummaryRow()
row = struct( ...
    'dataset_id','','dataset_title','','category','','status','', ...
    'reused',false,'age_ma',NaN,'expected_rate','', ...
    'rate_min_cm_per_kyr',NaN,'rate_max_cm_per_kyr',NaN, ...
    'rate_step_cm_per_kyr',NaN,'pad',NaN, ...
    'monte_carlo_requested',NaN,'monte_carlo_completed',NaN, ...
    'best_rate_odd_to_even',NaN,'best_rate_even_to_odd',NaN, ...
    'p_global_odd_to_even',NaN,'p_global_even_to_odd',NaN, ...
    'p_robust',NaN,'p_symmetric',NaN, ...
    'p_local_odd_to_even_at_best',NaN, ...
    'p_local_even_to_odd_at_best',NaN,'rho_full_record',NaN, ...
    'all_nine_rate_min_cm_per_kyr',NaN, ...
    'all_nine_rate_max_cm_per_kyr',NaN, ...
    'best_odd_to_even_in_all_nine_range',false, ...
    'best_even_to_odd_in_all_nine_range',false, ...
    'expected_target_intersects_all_nine_range',false, ...
    'expected_target_fully_within_all_nine_range',false, ...
    'significant_odd_to_even',false, ...
    'significant_even_to_odd',false,'significant_symmetric',false, ...
    'significant_robust',false,'expected_rate_hit',false, ...
    'started_at','','completed_at','','elapsed_seconds',NaN, ...
    'figure_count',0,'error_identifier','','error_message','', ...
    'conclusion','');
end

function item = emptyCaseManifest()
item = struct('id','','title','','status','','reused',false, ...
    'input_file','','input_sha256','','case_dir','','results_mat','', ...
    'results_xlsx','','parameters_csv','','summary_csv','','curves_csv','', ...
    'null_statistics_csv','', ...
    'figures',repmat(emptyFigureEntry(),0,1), ...
    'best_rate_odd_to_even',NaN,'best_rate_even_to_odd',NaN, ...
    'p_symmetric',NaN,'p_robust',NaN,'updated_at','');
end

function item = emptyFigureEntry()
item = struct('path','','kind','','format','');
end

function path = resolveInputFile(spec,inputRoot)
path = char(string(spec.input_file));
if isempty(path)
    path = fullfile(inputRoot,char(string(spec.filename)));
end
if ~isfile(path)
    error('runInterleavedCvCocoComparison:InputFileMissing', ...
        'Input file does not exist: %s',path);
end
path = canonicalPath(path);
end

function writeSummaryCsv(path,rows)
if isempty(rows)
    rows = repmat(emptySummaryRow(),0,1);
end
writeTableAtomic(path,struct2table(rows,'AsArray',true));
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
if ~isempty(data)
    writematrix(data,temporary,'WriteMode','append');
end
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
    error('runInterleavedCvCocoComparison:FileOpenFailed', ...
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
    error('runInterleavedCvCocoComparison:AtomicSaveFailed', ...
        'Could not finalize %s: %s',destination,message);
end
end

function ensureDirectory(path)
if ~isempty(path) && ~isfolder(path)
    [ok,message] = mkdir(path);
    if ~ok
        error('runInterleavedCvCocoComparison:DirectoryCreateFailed', ...
            'Could not create %s: %s',path,message);
    end
end
end

function deleteIfPresent(path)
if isfile(path)
    delete(path);
end
end

function logMessage(paths,message)
line = sprintf('%s | %s\n',timestampNow(),char(string(message)));
fprintf('%s',line);
for pathIndex = 1:numel(paths)
    path = paths{pathIndex};
    ensureDirectory(fileparts(path));
    file = fopen(path,'a','n','UTF-8');
    if file < 0
        warning('runInterleavedCvCocoComparison:LogOpenFailed', ...
            'Could not append to log %s.',path);
        continue
    end
    cleanup = onCleanup(@()fclose(file));
    fprintf(file,'%s',line);
    clear cleanup
end
end

function path = relativePath(path,root)
prefix = [root,filesep];
if startsWith(path,prefix)
    path = path(numel(prefix)+1:end);
end
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
if isempty(text)
    text = 'item';
end
end

function text = timestampNow()
text = char(datetime('now','TimeZone','Asia/Shanghai', ...
    'Format','yyyy-MM-dd''T''HH:mm:ssXXX'));
end

function value = yesNo(tf)
if tf
    value = 'YES';
else
    value = 'NO';
end
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
