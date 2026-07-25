function study = runSyn3FourMethodPublicationStudy(varargin)
%RUNSYN3FOURMETHODPUBLICATIONSTUDY Reproducible seven-record COCO/eCOCO run.
%
% This study-specific launcher runs the two requested COCO methods
% (confirmatory Blocked cvCOCO and exploratory Adaptive COCO) and the two requested
% eCOCO methods (Adaptive eCOCO and Blocked eCOCO).  It writes the
% complete numerical outputs, parameters, editable MATLAB figures, and
% vector PDFs through the audited non-GUI batch runners.
%
% Name-value inputs:
%   Phase       'prepare', 'coco', 'ecoco', or 'all' (default 'all')
%   InputRoot   directory containing the seven input records
%   OutputRoot  new study directory; COCO and eCOCO are subdirectories
%   CocoNSim    COCO Monte Carlo realizations (default 5000)
%   EcocoNSim   eCOCO Monte Carlo realizations (default 2000)
%   Seed        common reproducible random seed (default 1)
%   Resume      resume signature-matched method checkpoints (default true)
%
% The Givetian rate increment was not specified in the request.  This
% launcher preregisters 0.05 cm/kyr, matching the existing Acycle Givetian
% configuration.  eCOCO windows are twice the 405-kyr depth equivalent;
% the 4-to-6 cm/kyr synthetic record uses the conservative 6 cm/kyr rate.

parser = inputParser;
parser.FunctionName = mfilename;
defaultInputRoot = fullfile(filesep,'Users','msli','Dropbox','Research', ...
    '_通用方法火山构造波动','202606COCO','data_18','syn3');
defaultOutputRoot = fullfile(defaultInputRoot, ...
    'COCO_eCOCO_4methods_7datasets_MC5000_2000_English_20260718');
addParameter(parser,'Phase','all',@(x) ischar(x) || ...
    (isstring(x) && isscalar(x)));
addParameter(parser,'InputRoot',defaultInputRoot,@isScalarText);
addParameter(parser,'OutputRoot',defaultOutputRoot,@isScalarText);
addParameter(parser,'CocoNSim',5000,@isPositiveInteger);
addParameter(parser,'EcocoNSim',2000,@isPositiveInteger);
addParameter(parser,'Seed',1,@isSeed);
addParameter(parser,'Resume',true,@isLogicalScalar);
parse(parser,varargin{:});
options = parser.Results;
phase = validatestring(char(string(options.Phase)), ...
    {'prepare','coco','ecoco','all'},mfilename,'Phase');
inputRoot = canonicalPath(char(string(options.InputRoot)));
outputRoot = canonicalPath(char(string(options.OutputRoot)));
ensureDirectory(outputRoot);

repositoryRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(repositoryRoot,'code')));
[cocoPlan,ecocoPlan] = studyPlans(inputRoot);
validateInputs(cocoPlan);

study = buildStudyManifest(phase,inputRoot,outputRoot,repositoryRoot, ...
    cocoPlan,ecocoPlan,options);
writeStudyDesign(outputRoot,study,cocoPlan,ecocoPlan);
copyLauncher(outputRoot);
writeRepositoryState(outputRoot,repositoryRoot);

if ismember(phase,{'coco','all'})
    runCocoPublicationValidation(fullfile(outputRoot,'COCO'), ...
        'InputRoot',inputRoot, ...
        'DatasetPlan',cocoPlan, ...
        'NSim',options.CocoNSim, ...
        'NSimSensitivity',[], ...
        'Seed',options.Seed, ...
        'Red',0, ...
        'SensitivityRed',[], ...
        'Method','Pearson', ...
        'Slices',1, ...
        'BatchSize',100, ...
        'MaxFrequencyScale',1.2, ...
        'Resume',logical(options.Resume), ...
        'ContinueOnError',true, ...
        'RunCV',true, ...
        'RunAdaptive',true, ...
        'ExportFigures',true, ...
        'CloseFigures',true, ...
        'Visible','off', ...
        'FigureWidthCm',9);
end

if ismember(phase,{'ecoco','all'})
    runEcocoTwoMethodExperiment(fullfile(outputRoot,'eCOCO'), ...
        'InputRoot',inputRoot, ...
        'DatasetPlan',ecocoPlan, ...
        'NSim',options.EcocoNSim, ...
        'Seed',options.Seed, ...
        'Red',0, ...
        'Method','Pearson', ...
        'AnchorFraction',0.5, ...
        'StepFraction',0.01, ...
        'MaxWindows',200, ...
        'Resume',logical(options.Resume), ...
        'ContinueOnError',true, ...
        'ExportFigures',true, ...
        'CloseFigures',true, ...
        'Visible','off', ...
        'ShowProgress',false, ...
        'Verbose',false);
end

study.updated_at = timestampNow();
study.status = studyStatus(outputRoot,phase);
writeJsonAtomic(fullfile(outputRoot,'study_manifest.json'),study);
end

function [cocoPlan,ecocoPlan] = studyPlans(inputRoot)
baseCoco = struct('id','','title','','filename','','input_file','', ...
    'age_ma',NaN,'expected_rate','','sr1',NaN,'sr2',NaN,'srstep',NaN, ...
    'pad',[]);
baseEcoco = struct('id','','title','','category','','filename','', ...
    'input_file','','age_ma',NaN,'sr1',NaN,'sr2',NaN,'srstep',NaN, ...
    'windowRate',NaN,'expected_rate','','expectedWindows',zeros(0,2), ...
    'reconstructSpacing',NaN,'expectedKind','constant', ...
    'referenceRate',NaN,'expectedSplitDepthFraction',NaN);

items = {
    'noise80m','80-m red-noise negative control','noise', ...
        'rednoise0.5-80m.csv',0,1,10,0.05,4, ...
        'No physical true rate; nominal 4 cm/kyr design reference', ...
        [3.5,4.5],NaN,'constant',NaN;
    'la04_4cm_red07','La2004 synthetic 1E1T1P plus red noise, 4 cm/kyr','theory', ...
        'La2004-1E1T-1P-54-59Ma-4cmkyr+Red0.7.txt',56,1,10,0.05,4, ...
        '4 cm/kyr',[3.5,4.5],NaN,'constant',4;
    'la04_4to6cm_red07','La2004 synthetic ETP plus red noise, 4-to-6 cm/kyr', ...
        'variable','la04etp54-59ma4-6cmka-rsp0.04+Red0.7.txt', ...
        56,1,10,0.05,6,'4 cm/kyr first half; 6 cm/kyr second half', ...
        [3.5,4.5;5.5,6.5],NaN,'piecewise46',NaN;
    'site1262','ODP Site 1262 XRF Fe residual','real', ...
        '1262XRF-Fe-log10-s.u.-111-170-rsp0.02-10-rLOESS-dpks-rsp0.04.txt', ...
        56,0.1,3,0.01,1.3,'approximately 1-1.3 cm/kyr',[1,1.3], ...
        NaN,'constant',1.15;
    'newark','Newark 2-km record','real','newark2km-s-rsp0.85.txt', ...
        210,1,30,0.2,15,'approximately 15 cm/kyr',[12,18], ...
        0.85,'constant',15;
    'wayao','Wayao Carnian gamma-ray residual','real', ...
        'Example-WayaoCarnianGR0-rsp0.333-80-LOWESS.txt', ...
        235,1,20,0.1,9,'approximately 9 cm/kyr',[7.2,10.8], ...
        NaN,'constant',9;
    'givetian','Givetian DD14 residual','real', ...
        'GivetianDD14-s.u.-rsp0.3-log10-80-rLOESS.txt', ...
        385,1,20,0.05,8,'approximately 8 cm/kyr',[6.4,9.6], ...
        NaN,'constant',8};

cocoPlan = repmat(baseCoco,size(items,1),1);
ecocoPlan = repmat(baseEcoco,size(items,1),1);
for ii = 1:size(items,1)
    inputFile = fullfile(inputRoot,items{ii,4});
    cocoPlan(ii).id = items{ii,1};
    cocoPlan(ii).title = items{ii,2};
    cocoPlan(ii).filename = items{ii,4};
    cocoPlan(ii).input_file = inputFile;
    cocoPlan(ii).age_ma = items{ii,5};
    cocoPlan(ii).expected_rate = items{ii,10};
    cocoPlan(ii).sr1 = items{ii,6};
    cocoPlan(ii).sr2 = items{ii,7};
    cocoPlan(ii).srstep = items{ii,8};

    ecocoPlan(ii).id = items{ii,1};
    ecocoPlan(ii).title = items{ii,2};
    ecocoPlan(ii).category = items{ii,3};
    ecocoPlan(ii).filename = items{ii,4};
    ecocoPlan(ii).input_file = inputFile;
    ecocoPlan(ii).age_ma = items{ii,5};
    ecocoPlan(ii).sr1 = items{ii,6};
    ecocoPlan(ii).sr2 = items{ii,7};
    ecocoPlan(ii).srstep = items{ii,8};
    ecocoPlan(ii).windowRate = items{ii,9};
    ecocoPlan(ii).expected_rate = items{ii,10};
    ecocoPlan(ii).expectedWindows = items{ii,11};
    ecocoPlan(ii).reconstructSpacing = items{ii,12};
    ecocoPlan(ii).expectedKind = items{ii,13};
    ecocoPlan(ii).referenceRate = items{ii,14};
end
ecocoPlan(3).expectedSplitDepthFraction = 4/(4+6);
end

function validateInputs(plan)
for ii = 1:numel(plan)
    if ~isfile(plan(ii).input_file)
        error('runSyn3FourMethodPublicationStudy:MissingInput', ...
            'Required input is missing: %s',plan(ii).input_file);
    end
    raw = readmatrix(plan(ii).input_file);
    if ~isnumeric(raw) || size(raw,1) < 4 || size(raw,2) < 2 || ...
            any(~isfinite(raw(:,1:2)),'all')
        error('runSyn3FourMethodPublicationStudy:InvalidInput', ...
            'Input must contain at least four finite two-column rows: %s', ...
            plan(ii).input_file);
    end
    if any(diff(raw(:,1)) <= 0)
        error('runSyn3FourMethodPublicationStudy:NonmonotonicDepth', ...
            'Depth must be strictly increasing: %s',plan(ii).input_file);
    end
end
end

function study = buildStudyManifest(phase,inputRoot,outputRoot,repositoryRoot, ...
        cocoPlan,ecocoPlan,options)
study = struct;
study.schema_version = 1;
study.title = ['Seven-record comparison of Blocked cvCOCO, Adaptive COCO, ', ...
    'Adaptive eCOCO, and Blocked eCOCO'];
study.language = 'English';
study.purpose = 'Scientific-paper analysis and reporting';
study.created_at = timestampNow();
study.updated_at = study.created_at;
study.status = 'prepared';
study.requested_phase = phase;
study.input_root = inputRoot;
study.output_root = outputRoot;
study.repository_root = repositoryRoot;
study.matlab_version = version;
study.common = struct('correlation','Pearson','red_option',0, ...
    'seed',options.Seed,'max_frequency_scale',1.2);
study.coco = struct('methods',{{'Blocked cvCOCO','Adaptive COCO'}}, ...
    'monte_carlo',options.CocoNSim,'figure_width_mm',90, ...
    'sensitivity_run_enabled',false,'output_directory','COCO');
study.ecoco = struct('methods', ...
    {{'Adaptive eCOCO','Blocked eCOCO'}}, ...
    'monte_carlo',options.EcocoNSim, ...
    'window_rule','2 x 405 kyr x design rate / 100 m', ...
    'step_fraction_requested',0.01,'maximum_windows',200, ...
    'crossfit_anchor_fraction',0.5,'output_directory','eCOCO');
study.assumptions = { ...
    'The pure red-noise record is a negative control; 4 cm/kyr is only a nominal design reference.', ...
    'The 4-to-6 cm/kyr record uses 6 cm/kyr to size the eCOCO window.', ...
    'The Site 1262 window uses the upper target rate, 1.3 cm/kyr.', ...
    'The Givetian grid increment is 0.05 cm/kyr, matching the existing Acycle configuration.', ...
    'The Newark depth coordinate is reconstructed on a strict 0.85-m grid for eCOCO.'};
study.dataset_count = numel(cocoPlan);
study.rate_grids = repmat(struct('id','','minimum',NaN,'maximum',NaN, ...
    'increment',NaN,'age_ma',NaN,'ecoco_window_rate',NaN), ...
    numel(cocoPlan),1);
for ii = 1:numel(cocoPlan)
    study.rate_grids(ii) = struct('id',cocoPlan(ii).id, ...
        'minimum',cocoPlan(ii).sr1,'maximum',cocoPlan(ii).sr2, ...
        'increment',cocoPlan(ii).srstep,'age_ma',cocoPlan(ii).age_ma, ...
        'ecoco_window_rate',ecocoPlan(ii).windowRate);
end
end

function writeStudyDesign(outputRoot,study,cocoPlan,ecocoPlan)
writeJsonAtomic(fullfile(outputRoot,'study_manifest.json'),study);
header = {'dataset_id','input_file','age_ma','rate_min_cm_per_kyr', ...
    'rate_max_cm_per_kyr','rate_step_cm_per_kyr','expected_rate', ...
    'ecoco_window_design_rate_cm_per_kyr','ecoco_window_requested_m', ...
    'ecoco_estimated_window_actual_m','ecoco_estimated_step_m', ...
    'ecoco_estimated_window_count', ...
    'coco_monte_carlo','ecoco_monte_carlo','seed','red_option'};
rows = cell(numel(cocoPlan)+1,numel(header));
rows(1,:) = header;
for ii = 1:numel(cocoPlan)
    estimate = estimateEcocoDesign(ecocoPlan(ii));
    rows(ii+1,:) = {cocoPlan(ii).id,cocoPlan(ii).input_file, ...
        cocoPlan(ii).age_ma,cocoPlan(ii).sr1,cocoPlan(ii).sr2, ...
        cocoPlan(ii).srstep,cocoPlan(ii).expected_rate, ...
        ecocoPlan(ii).windowRate,2*405*ecocoPlan(ii).windowRate/100, ...
        estimate.windowActual,estimate.stepDepth,estimate.windowCount, ...
        study.coco.monte_carlo,study.ecoco.monte_carlo, ...
        study.common.seed,study.common.red_option};
end
writeCellAtomic(fullfile(outputRoot,'study_design.csv'),rows);
saveAtomic(fullfile(outputRoot,'study_design.mat'),struct( ...
    'study',study,'cocoPlan',cocoPlan,'ecocoPlan',ecocoPlan));
end

function estimate = estimateEcocoDesign(spec)
raw = readmatrix(spec.input_file);
raw = raw(:,1:2);
raw = raw(all(isfinite(raw),2),:);
[depth,~,groups] = unique(raw(:,1),'sorted');
values = accumarray(groups,raw(:,2),[],@mean);
raw = [depth,values];
if isfinite(spec.reconstructSpacing) && spec.reconstructSpacing > 0
    dt = spec.reconstructSpacing;
    depth = (raw(1,1):dt:raw(end,1))';
else
    dt = median(diff(raw(:,1)));
    depth = (raw(1,1):dt:raw(end,1))';
end
nData = numel(depth);
windowRequested = 2*405*spec.windowRate/100;
nWindow = 2*round(windowRequested/(2*dt))+1;
windowActual = (nWindow-1)*dt;
requested = max(1,round(0.01*windowActual/dt));
stepSamples = max(requested,ceil((nData-1)/(200-1)));
starts = 1:stepSamples:nData;
if isempty(starts) || starts(end) ~= nData
    starts(end+1) = nData;
end
estimate = struct('samplingInterval',dt,'pointCount',nData, ...
    'windowPoints',nWindow,'windowActual',round(windowActual,9), ...
    'stepSamples',stepSamples,'stepDepth',round(stepSamples*dt,9), ...
    'windowCount',numel(starts));
if estimate.windowCount < 150 || estimate.windowCount > 250
    error('runSyn3FourMethodPublicationStudy:WindowCountOutOfRange', ...
        '%s would use %d windows; the requested range is 150-250.', ...
        spec.id,estimate.windowCount);
end
end

function copyLauncher(outputRoot)
source = [mfilename('fullpath'),'.m'];
if isfile(source)
    copyfile(source,fullfile(outputRoot,'runSyn3FourMethodPublicationStudy.m'),'f');
end
end

function writeRepositoryState(outputRoot,repositoryRoot)
[headStatus,head] = system(sprintf( ...
    'git -C "%s" rev-parse HEAD',repositoryRoot));
if headStatus ~= 0, head = 'unavailable'; end
writeTextAtomic(fullfile(outputRoot,'git_head.txt'),strtrim(head));
[statusCode,statusText] = system(sprintf( ...
    'git -C "%s" status --short',repositoryRoot));
if statusCode ~= 0
    statusText = sprintf('Unable to read git status (exit %d).',statusCode);
end
writeTextAtomic(fullfile(outputRoot,'git_status.txt'),statusText);
[diffCode,diffText] = system(sprintf( ...
    'git -C "%s" diff --no-ext-diff --binary',repositoryRoot));
if diffCode ~= 0
    diffText = sprintf('Unable to read git diff (exit %d).',diffCode);
end
writeTextAtomic(fullfile(outputRoot,'git_worktree.patch'),diffText);
end

function status = studyStatus(outputRoot,phase)
if strcmp(phase,'prepare')
    status = 'prepared';
    return
end
states = strings(0,1);
if ismember(phase,{'coco','all'})
    states(end+1,1) = manifestStatus(fullfile(outputRoot,'COCO','manifest.json'));
end
if ismember(phase,{'ecoco','all'})
    states(end+1,1) = manifestStatus(fullfile(outputRoot,'eCOCO','manifest.json'));
end
if ~isempty(states) && all(states == "complete")
    status = 'complete';
elseif any(states == "complete" | states == "partial")
    status = 'partial';
else
    status = 'failed';
end
end

function status = manifestStatus(path)
status = "missing";
if ~isfile(path), return, end
try
    value = jsondecode(fileread(path));
    status = string(value.status);
catch
    status = "invalid";
end
end

function writeJsonAtomic(path,value)
temporary = [tempname(fileparts(path)),'.json'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
fid = fopen(temporary,'w','n','UTF-8');
if fid < 0
    error('runSyn3FourMethodPublicationStudy:FileOpenFailed', ...
        'Cannot open temporary JSON file for %s.',path);
end
fileCleanup = onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
clear fileCleanup
movefile(temporary,path,'f');
clear cleanup
end

function writeCellAtomic(path,value)
temporary = [tempname(fileparts(path)),'.csv'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
writecell(value,temporary);
movefile(temporary,path,'f');
clear cleanup
end

function writeTextAtomic(path,value)
temporary = [tempname(fileparts(path)),'.txt'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
fid = fopen(temporary,'w','n','UTF-8');
if fid < 0
    error('runSyn3FourMethodPublicationStudy:FileOpenFailed', ...
        'Cannot open temporary text file for %s.',path);
end
fileCleanup = onCleanup(@()fclose(fid));
fprintf(fid,'%s',char(string(value)));
clear fileCleanup
movefile(temporary,path,'f');
clear cleanup
end

function saveAtomic(path,value)
temporary = [tempname(fileparts(path)),'.mat'];
cleanup = onCleanup(@()deleteIfPresent(temporary));
save(temporary,'-struct','value','-v7.3');
movefile(temporary,path,'f');
clear cleanup
end

function ensureDirectory(path)
if ~isfolder(path)
    [ok,message] = mkdir(path);
    if ~ok
        error('runSyn3FourMethodPublicationStudy:DirectoryCreateFailed', ...
            'Cannot create %s: %s',path,message);
    end
end
end

function path = canonicalPath(path)
path = char(java.io.File(path).getCanonicalPath());
end

function value = timestampNow()
value = char(datetime('now','TimeZone','local', ...
    'Format',"yyyy-MM-dd'T'HH:mm:ssXXX"));
end

function deleteIfPresent(path)
if isfile(path), delete(path); end
end

function tf = isScalarText(value)
tf = ischar(value) || (isstring(value) && isscalar(value));
end

function tf = isPositiveInteger(value)
tf = isnumeric(value) && isscalar(value) && isfinite(value) && ...
    value >= 1 && value == fix(value);
end

function tf = isSeed(value)
tf = isnumeric(value) && isscalar(value) && isfinite(value) && ...
    value >= 0 && value <= 2^32-1 && value == fix(value);
end

function tf = isLogicalScalar(value)
tf = (islogical(value) || isnumeric(value)) && isscalar(value) && ...
    isfinite(value) && any(value == [0,1]);
end
