function tests = test_run_ecoco_two_method_experiment
%TEST_RUN_ECOCO_TWO_METHOD_EXPERIMENT Temporary-output integration test.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
addpath(genpath(fullfile(repoRoot,'code')));
testCase.addTeardown(@()path(oldPath));
testCase.TestData.repoRoot = repoRoot;
end

function testTemporaryRunExportsAndResumes(testCase)
root = tempname;
mkdir(root);
testCase.addTeardown(@()removeTree(root));
inputFile = fullfile(root,'synthetic.csv');
outputRoot = fullfile(root,'output');

orbitMatrix = calculate_orbit9(0);
orbit9 = orbitMatrix(:,2)/1000;
dt = 0.02;
depth = (0:dt:5)';
trueRate = 0.2;
time = depth*100/trueRate;
value = zeros(size(depth));
for ii = 1:numel(orbit9)
    value = value + sin(2*pi*time/orbit9(ii)+0.23*ii);
end
value = value+0.04*sin(2*pi*time/71.7)+0.001*depth;
writematrix([depth,value],inputFile);

plan = struct( ...
    'id','synthetic','title','Synthetic eCOCO integration record', ...
    'category','theory','filename','synthetic.csv', ...
    'input_file',inputFile,'age_ma',0, ...
    'sr1',0.18,'sr2',0.22,'srstep',0.02, ...
    'windowRate',trueRate,'expected_rate','0.2 cm/kyr', ...
    'expectedWindows',[0.18,0.22],'reconstructSpacing',NaN);

first = runEcocoTwoMethodExperiment(outputRoot, ...
    'DatasetPlan',plan,'NSim',2,'MaxWindows',20, ...
    'ExportFigures',true,'Visible','off','ContinueOnError',false);
verifyEqual(testCase,first.status,'complete');
verifyTrue(testCase,isfile(fullfile(outputRoot,'manifest.json')));
verifyTrue(testCase,isfile(fullfile(outputRoot,'overall_summary.csv')));
verifyTrue(testCase,isfile(fullfile(outputRoot,'run_summary.mat')));
rootManifest = jsondecode(fileread(fullfile(outputRoot,'manifest.json')));
verifyEqual(testCase,rootManifest.report_title, ...
    'Adaptive and Blocked eCOCO: 1-data-set comparison');
verifyEqual(testCase,sort(string(rootManifest.options.MethodIDs(:))), ...
    sort(["Adaptive eCOCO";"Blocked eCOCO"]));
verifyNoLegacyPublicNames(testCase,rootManifest,'root manifest');

caseDirectory = fullfile(outputRoot,'01_synthetic');
verifyTrue(testCase,isfile(fullfile(caseDirectory,'parameters.csv')));
verifyTrue(testCase,isfile(fullfile(caseDirectory,'parameters.json')));
verifyTrue(testCase,isfile(fullfile(caseDirectory,'case_manifest.json')));
summary = readtable(fullfile(caseDirectory,'summary.csv'), ...
    'VariableNamingRule','preserve');
verifyEqual(testCase,height(summary),2);
verifyEqual(testCase,sort(string(summary.method_id)), ...
    sort(["Adaptive eCOCO";"Blocked eCOCO"]));
verifyTrue(testCase,all(string(summary.status) == "complete"));
verifyLessThan(testCase,max(summary.window_count),300);

parameters = jsondecode(fileread(fullfile(caseDirectory,'parameters.json')));
verifyEqual(testCase,parameters.window_formula, ...
    '2 * 405 kyr * rate / 100 m');
verifyEqual(testCase,parameters.target_anchor_fraction,0.5);
verifyEqual(testCase,parameters.pad_nfft, ...
    2^nextpow2(parameters.window_point_count));
expectedWindowPoints = 2*round(parameters.window_requested_m/ ...
    (2*parameters.sampling_interval_m))+1;
verifyEqual(testCase,parameters.window_point_count,expectedWindowPoints);
verifyEqual(testCase,mod(parameters.window_point_count,2),1);
verifyTrue(testCase,parameters.edge_padding_second_column_strict_zero);
verifyTrue(testCase,parameters.global_mean_removed_before_padding);
verifyEqual(testCase,parameters.monte_carlo_simulations,2);

analysisInput = readmatrix(fullfile(caseDirectory,'analysis_input.csv'), ...
    'NumHeaderLines',1);
nHalf = parameters.half_window_zero_padding_points_each_edge;
verifyEqual(testCase,analysisInput(1:nHalf,2),zeros(nHalf,1),'AbsTol',0);
verifyEqual(testCase,analysisInput(end-nHalf+1:end,2),zeros(nHalf,1), ...
    'AbsTol',0);
retained = analysisInput(nHalf+(1:numel(value)),2);
verifyEqual(testCase,retained,value-mean(value),'AbsTol',1e-12);

methodFolders = ["Adaptive_eCOCO","Blocked_eCOCO"];
methodNames = ["Adaptive eCOCO","Blocked eCOCO"];
for methodIndex = 1:numel(methodFolders)
    methodFolder = methodFolders(methodIndex);
    methodName = methodNames(methodIndex);
    methodDirectory = fullfile(caseDirectory,char(methodFolder));
    required = {'checkpoint.mat','results.mat','result.json', ...
        'parameters.csv','parameters.json','summary.csv','rho.csv', ...
        'p_global.csv','n_orbit.csv','pcoco.csv','ridge_score.csv', ...
        'tracked_sr.csv'};
    for ii = 1:numel(required)
        verifyTrue(testCase,isfile(fullfile(methodDirectory,required{ii})), ...
            sprintf('Missing %s/%s',methodName,required{ii}));
    end
    saved = load(fullfile(methodDirectory,'results.mat'),'analysis');
    resultMetadata = jsondecode(fileread( ...
        fullfile(methodDirectory,'result.json')));
    resultSignature = jsondecode(resultMetadata.signature);
    verifyFalse(testCase,startsWith(string( ...
        resultSignature.engine_sha256),"missing:"));
    verifyTrue(testCase,isfield(saved.analysis,'details'));
    verifyEqual(testCase,size(saved.analysis.out_ecc,1),3);
    verifyEqual(testCase,size(saved.analysis.out_ecc,2), ...
        numel(saved.analysis.out_depth));
    pGlobal = saved.analysis.out_eci;
    validMap = any(isfinite(pGlobal),1);
    mapMinimum = nan(1,size(pGlobal,2));
    mapMinimum(validMap) = min(pGlobal(:,validMap),[],1,'omitnan');
    interior = saved.analysis.out_depth >= depth(1) & ...
        saved.analysis.out_depth <= depth(end);
    savedSummary = load(fullfile(methodDirectory,'results.mat'),'summary');
    verifyEqual(testCase,savedSummary.summary.significant_window_count, ...
        nnz(interior(:)' & validMap & mapMinimum < 0.05));
    methodParameters = jsondecode(fileread( ...
        fullfile(methodDirectory,'parameters.json')));
    tracked = saved.analysis.sr_p;
    for windowIndex = 1:size(tracked,1)
        if ~isfinite(tracked(windowIndex,2))
            continue
        end
        [~,rateIndex] = min(abs( ...
            saved.analysis.prt_sr-tracked(windowIndex,2)));
        verifyEqual(testCase,tracked(windowIndex,6), ...
            saved.analysis.out_ecocorb(rateIndex,windowIndex), ...
            'AbsTol',0);
    end
    verifyEqual(testCase,resultMetadata.algorithm_version, ...
        methodParameters.algorithm_version);
    verifyEqual(testCase,resultMetadata.score_definition, ...
        methodParameters.score_definition);
    verifyEqual(testCase,resultMetadata.orbit_count_role, ...
        methodParameters.orbit_count_role);
    verifyEqual(testCase,string(saved.analysis.method),methodName);
    verifyEqual(testCase,string(saved.analysis.method_id),methodName);
    verifyEqual(testCase,string(saved.analysis.mode),methodName);
    verifyEqual(testCase,string(methodParameters.method),methodName);
    verifyEqual(testCase,string(methodParameters.method_id),methodName);
    verifyEqual(testCase,string(methodParameters.analysis_method),methodName);
    verifyNoLegacyPublicNames(testCase,saved.analysis, ...
        sprintf('%s MAT analysis',methodName));
    verifyNoLegacyPublicNames(testCase,resultMetadata, ...
        sprintf('%s result manifest',methodName));
    verifyNoLegacyPublicNames(testCase,methodParameters, ...
        sprintf('%s parameters',methodName));
    if methodName == "Adaptive eCOCO"
        localPath = fullfile(methodDirectory,'p_local.csv');
        verifyTrue(testCase,isfile(localPath));
        verifyFalse(testCase,isfile(fullfile( ...
            methodDirectory,'p_parametric.csv')));
        verifyEqual(testCase,readmatrix(localPath), ...
            saved.analysis.details.pLocal,'AbsTol',1e-14);
        verifyEqual(testCase,saved.analysis.out_ep, ...
            saved.analysis.details.pLocal,'AbsTol',0);
        verifyEqual(testCase,saved.analysis.out_ecocorb, ...
            saved.analysis.out_ecoco.*saved.analysis.out_norbit./9, ...
            'AbsTol',0);
        verifyEqual(testCase,methodParameters.orbit_count_role, ...
            'ridge-score weight');
    else
        localPath = fullfile(methodDirectory,'p_local.csv');
        verifyTrue(testCase,isfile(localPath));
        verifyFalse(testCase,isfile(fullfile( ...
            methodDirectory,'p_parametric.csv')));
        verifyEqual(testCase,readmatrix(localPath), ...
            saved.analysis.details.consensus.pLocal,'AbsTol',1e-14);
        verifyEqual(testCase,saved.analysis.out_ep, ...
            saved.analysis.details.consensus.pLocal,'AbsTol',0);
        verifyEqual(testCase,methodParameters.target_mode, ...
            'four-group-coherent-nine');
        verifyEqual(testCase,saved.analysis.out_ecocorb, ...
            saved.analysis.out_ecoco,'AbsTol',0);
        verifyEqual(testCase,readmatrix(fullfile( ...
            methodDirectory,'ridge_score.csv')), ...
            readmatrix(fullfile(methodDirectory,'pcoco.csv')), ...
            'AbsTol',0);
        verifyEqual(testCase,methodParameters.orbit_count_role, ...
            'diagnostic only');
        verifyTrue(testCase,contains( ...
            methodParameters.score_definition, ...
            'no orbit-count weighting'));
    end
    savedFigures = load(fullfile(methodDirectory,'results.mat'), ...
        'figureEntries');
    verifyNumElements(testCase,savedFigures.figureEntries,2);
    for suffix = ["","_ridge"]
        stem = sprintf('synthetic_%s%s',methodFolder,suffix);
        png = fullfile(caseDirectory,'figures',[stem,'.png']);
        pdf = fullfile(caseDirectory,'figures',[stem,'.pdf']);
        fig = fullfile(caseDirectory,'figures',[stem,'.fig']);
        verifyTrue(testCase,isfile(png));
        verifyTrue(testCase,isfile(pdf));
        verifyTrue(testCase,isfile(fig));
    end
end

firstCaseManifest = jsondecode(fileread( ...
    fullfile(caseDirectory,'case_manifest.json')));
verifyNoLegacyPublicNames(testCase,firstCaseManifest,'case manifest');
verifyNumElements(testCase,firstCaseManifest.figures,4);
verifyTrue(testCase,all(arrayfun(@(item) ...
    numel(item.figures) == 2,firstCaseManifest.methods)));
ridgeToRegenerate = fullfile(caseDirectory,'figures', ...
    'synthetic_Adaptive_eCOCO_ridge.png');
delete(ridgeToRegenerate);
verifyFalse(testCase,isfile(ridgeToRegenerate));

second = runEcocoTwoMethodExperiment(outputRoot, ...
    'DatasetPlan',plan,'NSim',2,'MaxWindows',20, ...
    'MethodIDs',{'adaptive','crossfit'}, ...
    'ExportFigures',true,'Visible','off','ContinueOnError',false);
verifyEqual(testCase,second.status,'complete');
verifyEqual(testCase,sort(string(second.options.MethodIDs(:))), ...
    sort(["Adaptive eCOCO";"Blocked eCOCO"]));
verifyNoLegacyPublicNames(testCase,second,'resumed run manifest');
verifyTrue(testCase,isfile(ridgeToRegenerate));
caseManifest = jsondecode(fileread( ...
    fullfile(caseDirectory,'case_manifest.json')));
verifyTrue(testCase,all([caseManifest.methods.reused]));
verifyNoLegacyTextFiles(testCase,outputRoot);
end

function verifyNoLegacyTextFiles(testCase,root)
files = dir(fullfile(root,'**','*'));
for ii = 1:numel(files)
    if files(ii).isdir
        continue
    end
    [~,~,extension] = fileparts(files(ii).name);
    if ~ismember(lower(extension),{'.csv','.json','.log','.txt'})
        continue
    end
    pathValue = fullfile(files(ii).folder,files(ii).name);
    verifyNoLegacyPublicNames(testCase,fileread(pathValue),pathValue);
end
end

function verifyNoLegacyPublicNames(testCase,value,context)
pattern = [ ...
    '(?i)(cvcoco9[a-z]*|adaptive9[a-z]*|interleavedcvcoco|', ...
    'cross[- ]?fit(?:ted)?|method[- ]b|', ...
    'ecoco(?:adaptive|crossfit|interleaved)core)'];
texts = collectText(value);
for ii = 1:numel(texts)
    match = regexp(texts{ii},pattern,'match','once');
    verifyEmpty(testCase,match,sprintf( ...
        'Legacy public name "%s" found in %s.',match,context));
end
end

function texts = collectText(value)
texts = {};
if ischar(value)
    texts = {value};
elseif isstring(value)
    texts = cellstr(value(:))';
elseif iscell(value)
    for ii = 1:numel(value)
        childTexts = collectText(value{ii});
        texts = [texts,childTexts(:)']; %#ok<AGROW>
    end
elseif isstruct(value)
    names = fieldnames(value);
    texts = [texts,names(:)'];
    for elementIndex = 1:numel(value)
        for fieldIndex = 1:numel(names)
            childTexts = collectText( ...
                value(elementIndex).(names{fieldIndex}));
            texts = [texts,childTexts(:)']; %#ok<AGROW>
        end
    end
end
end

function removeTree(pathValue)
if isfolder(pathValue)
    try
        rmdir(pathValue,'s');
    catch
    end
end
end
