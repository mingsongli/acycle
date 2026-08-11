function tests = test_run_coco_eight_method_experiment
%TEST_RUN_COCO_EIGHT_METHOD_EXPERIMENT Public-name export regression tests.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
addpath(genpath(fullfile(repoRoot,'code')));
testCase.addTeardown(@()path(oldPath));
end

function testLegacySelectorIsPrivateInExportedArtifacts(testCase)
root = tempname;
mkdir(root);
testCase.addTeardown(@()removeTree(root));
inputFile = fullfile(root,'synthetic.csv');
outputRoot = fullfile(root,'output');

depth = (0:0.1:1.5)';
value = sin(2*pi*depth/0.7)+0.2*cos(2*pi*depth/0.31);
writematrix([depth,value],inputFile);
plan = struct( ...
    'id','synthetic','title','Synthetic COCO naming record', ...
    'category','theory','filename','synthetic.csv', ...
    'input_file',inputFile,'age_ma',0, ...
    'sr1',0.18,'sr2',0.22,'srstep',0.02, ...
    'expected_rate','0.2 cm/kyr','expectedWindows',[0.18,0.22], ...
    'reconstructSpacing',NaN);

runSummary = runCocoEightMethodExperiment(outputRoot, ...
    'DatasetPlan',plan,'MethodIDs','adaptive9b','NSim',1, ...
    'ExportFigures',false,'Visible','off','ContinueOnError',true);

verifyEqual(testCase,string(runSummary.options.MethodIDs), ...
    "Adaptive COCO");
verifyEqual(testCase,string(runSummary.options.TargetDesigns), ...
    "four-group area coherent target");
verifyNoLegacyPublicNames(testCase,runSummary,'returned run manifest');

rootManifest = jsondecode(fileread(fullfile(outputRoot,'manifest.json')));
verifyEqual(testCase,string(rootManifest.options.MethodIDs), ...
    "Adaptive COCO");
verifyEqual(testCase,string(rootManifest.options.TargetDesigns), ...
    "four-group area coherent target");
verifyNoLegacyPublicNames(testCase,rootManifest,'root manifest');
verifyNoLegacyArtifacts(testCase,outputRoot);
end

function testPublicJsonWritersAreR2020Compatible(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
runnerNames = { ...
    'runCocoEightMethodExperiment.m', ...
    'runCocoPublicationValidation.m', ...
    'runEcocoTwoMethodExperiment.m', ...
    'runInterleavedCvCocoComparison.m', ...
    'runSyn3FourMethodPublicationStudy.m'};
for runnerIndex = 1:numel(runnerNames)
    runnerPath = fullfile(repoRoot,'code','corrcoef', ...
        runnerNames{runnerIndex});
    source = fileread(runnerPath);
    verifyFalse(testCase,contains(source,"'PrettyPrint'"), ...
        sprintf('%s must use the R2020-compatible jsonencode form.', ...
        runnerNames{runnerIndex}));
end
end

function verifyNoLegacyArtifacts(testCase,root)
files = dir(fullfile(root,'**','*'));
for ii = 1:numel(files)
    if files(ii).isdir
        continue
    end
    pathValue = fullfile(files(ii).folder,files(ii).name);
    [~,~,extension] = fileparts(files(ii).name);
    switch lower(extension)
        case {'.csv','.json','.txt','.log'}
            value = fileread(pathValue);
        case '.mat'
            value = load(pathValue);
        otherwise
            continue
    end
    verifyNoLegacyPublicNames(testCase,value,pathValue);
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
