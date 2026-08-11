function tests = test_run_interleaved_cvcoco_comparison
%TEST_RUN_INTERLEAVED_CVCOCO_COMPARISON Batch-output and resume smoke tests.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
addpath(genpath(fullfile(repoRoot,'code')));
testCase.addTeardown(@()path(oldPath));

oldVisibility = get(groot,'defaultFigureVisible');
set(groot,'defaultFigureVisible','off');
testCase.addTeardown(@()set(groot,'defaultFigureVisible',oldVisibility));

rngState = rng;
testCase.addTeardown(@()rng(rngState));
testCase.TestData.orbit9 = [405.6912;130.6979;123.8532;98.8517; ...
    94.8856;40.9897;23.6820;22.3758;18.9519];
end

function testDiagnosticRunWritesCompleteOutputsAndResumes(testCase)
[root,inputFile,cleanup] = makeWorkspace(testCase); %#ok<ASGLU>
plan = syntheticPlan(inputFile);
outputRoot = fullfile(root,'diagnostic-output');

first = runInterleavedCvCocoComparison(outputRoot, ...
    'InputRoot',root,'DatasetPlan',plan,'NSim',0, ...
    'ExportFigures',false,'ShowProgress',false, ...
    'EnforceGuiPad',false);

verifyEqual(testCase,first.status,'complete');
verifyFalse(testCase,first.cases(1).reused);
caseDirectory = fullfile(outputRoot,'01_synthetic');
required = {'parameters.csv','parameters.mat','input_clean.csv', ...
    'results.mat','results.xlsx','curves.csv','null_statistics.csv','summary.csv', ...
    'summary.txt','result.json','case_manifest.json','checkpoint.mat', ...
    'run.log'};
for fileIndex = 1:numel(required)
    verifyTrue(testCase,isfile(fullfile(caseDirectory,required{fileIndex})), ...
        required{fileIndex});
end
verifyTrue(testCase,isfile(fullfile(outputRoot,'overall_summary.csv')));
verifyTrue(testCase,isfile(fullfile(outputRoot,'manifest.json')));
verifyTrue(testCase,isfile(fullfile(outputRoot,'run_summary.mat')));
verifyTrue(testCase,isfile(fullfile(outputRoot,'run.log')));
verifyTrue(testCase,isfile(fullfile(outputRoot,'comparison_report.md')));

saved = load(fullfile(caseDirectory,'results.mat'),'result','signature');
verifyEqual(testCase,saved.result.nsimCompleted,0);
verifyEqual(testCase,saved.result.splitMode,'interleaved');
verifyTrue(testCase,saved.result.config.jointNull);
verifyEqual(testCase,first.summary_rows(1).all_nine_rate_min_cm_per_kyr, ...
    saved.result.allNineRateRangeShared(1),'AbsTol',0);
verifyEqual(testCase,first.summary_rows(1).all_nine_rate_max_cm_per_kyr, ...
    saved.result.allNineRateRangeShared(2),'AbsTol',0);
signatureValue = jsondecode(saved.signature);
verifyEqual(testCase,signatureValue.dataset_title,plan.title);
verifyEqual(testCase,signatureValue.category,plan.category);
verifyEqual(testCase,signatureValue.expected_rate,plan.expected_rate);
verifyEqual(testCase,signatureValue.expected_windows(:), ...
    plan.expected_windows(:),'AbsTol',0);
verifyEqual(testCase,numel(split(string(signatureValue.engine_sha256),':')),6);
verifyFalse(testCase,contains(string(signatureValue.engine_sha256),'missing'));
nullTable = readtable(fullfile(caseDirectory,'null_statistics.csv'));
verifyEqual(testCase,height(nullTable),0);
workbookSheets = string(sheetnames(fullfile(caseDirectory,'results.xlsx')));
requiredSheets = ["Parameters","Summary","Curves","NullStatistics", ...
    "CleanInput","RawOdd","RawEven","OddFold","EvenFold"];
verifyTrue(testCase,all(ismember(requiredSheets,workbookSheets)));

% Simulate interruption after the atomic results.mat save but before the
% checkpoint advances.  The complete matching result must be authoritative
% even when checkpoint status/signature are stale.
checkpointPath = fullfile(caseDirectory,'checkpoint.mat');
checkpointSaved = load(checkpointPath,'checkpoint');
checkpoint = checkpointSaved.checkpoint;
checkpoint.status = 'running';
checkpoint.signature = 'stale-checkpoint-signature';
save(checkpointPath,'checkpoint');

second = runInterleavedCvCocoComparison(outputRoot, ...
    'InputRoot',root,'DatasetPlan',plan,'NSim',0, ...
    'DatasetIDs','synthetic', ...
    'ExportFigures',false,'ShowProgress',false, ...
    'EnforceGuiPad',false);
verifyEqual(testCase,second.status,'complete');
verifyTrue(testCase,second.cases(1).reused);
verifyTrue(testCase,second.summary_rows(1).reused);

% Report metadata participates in the signature, preventing a numerically
% valid result from silently reusing a stale title/category/target report.
changedPlan = plan;
changedPlan.title = 'Changed report title';
changedPlan.category = 'changed-category';
changedPlan.expected_rate = 'changed target metadata';
changedPlan.expected_windows = [3.8,4.2];
third = runInterleavedCvCocoComparison(outputRoot, ...
    'InputRoot',root,'DatasetPlan',changedPlan,'NSim',0, ...
    'DatasetIDs','synthetic','ExportFigures',false, ...
    'ShowProgress',false,'EnforceGuiPad',false);
verifyFalse(testCase,third.cases(1).reused);
verifyEqual(testCase,third.summary_rows(1).dataset_title, ...
    changedPlan.title);
verifyEqual(testCase,third.summary_rows(1).category, ...
    changedPlan.category);
end

function testSmallMonteCarloExportsFigPdfPngAndNullRows(testCase)
[root,inputFile,cleanup] = makeWorkspace(testCase); %#ok<ASGLU>
plan = syntheticPlan(inputFile);
outputRoot = fullfile(root,'small-mc-output');

summary = runInterleavedCvCocoComparison(outputRoot, ...
    'InputRoot',root,'DatasetPlan',plan,'NSim',2,'BatchSize',1, ...
    'ExportFigures',true,'CloseFigures',true,'Visible','off', ...
    'ShowProgress',false,'EnforceGuiPad',false);

verifyEqual(testCase,summary.status,'complete');
caseDirectory = fullfile(outputRoot,'01_synthetic');
saved = load(fullfile(caseDirectory,'results.mat'), ...
    'result','figureEntries');
verifyEqual(testCase,saved.result.nsimCompleted,2);
verifyEqual(testCase,numel(saved.result.nullSymmetric),2);
verifyEqual(testCase,numel(saved.figureEntries),6);
verifyTrue(testCase,all(arrayfun(@(entry)isfile( ...
    fullfile(outputRoot,entry.path)),saved.figureEntries)));

figureDirectory = fullfile(caseDirectory,'figures');
verifyEqual(testCase,numel(dir(fullfile(figureDirectory,'*.fig'))),1);
verifyEqual(testCase,numel(dir(fullfile(figureDirectory,'*.pdf'))),1);
verifyEqual(testCase,numel(dir(fullfile(figureDirectory,'*.png'))),4);
nullTable = readtable(fullfile(caseDirectory,'null_statistics.csv'));
verifyEqual(testCase,height(nullTable),2);
end

function testContinueOnErrorPreservesLaterDataset(testCase)
[root,inputFile,cleanup] = makeWorkspace(testCase); %#ok<ASGLU>
good = syntheticPlan(inputFile);
missing = good;
missing.id = 'missing';
missing.title = 'Missing input';
missing.filename = 'does-not-exist.txt';
missing.input_file = fullfile(root,missing.filename);
plan = [missing;good];
outputRoot = fullfile(root,'continue-output');

summary = runInterleavedCvCocoComparison(outputRoot, ...
    'InputRoot',root,'DatasetPlan',plan,'NSim',0, ...
    'ExportFigures',false,'ShowProgress',false, ...
    'EnforceGuiPad',false,'ContinueOnError',true);

verifyEqual(testCase,summary.status,'partial');
verifyEqual(testCase,string({summary.cases.status}), ...
    ["failed","complete"]);
verifyEqual(testCase,string({summary.summary_rows.status}), ...
    ["failed","complete"]);
verifyTrue(testCase,isfile(fullfile(outputRoot,'01_missing','error.txt')));
verifyTrue(testCase,isfile(fullfile(outputRoot,'02_synthetic','results.mat')));
end

function testFailureArtifactsUsePublicNamesWithoutStacks(testCase)
[root,inputFile,cleanup] = makeWorkspace(testCase); %#ok<ASGLU>
plan = syntheticPlan(inputFile);
plan.id = 'invalid_grid';
plan.title = 'Invalid rate-grid fixture';
plan.sr1 = 1;
plan.sr2 = 10002;
plan.srstep = 1;
outputRoot = fullfile(root,'public-failure-output');

summary = runInterleavedCvCocoComparison(outputRoot, ...
    'InputRoot',root,'DatasetPlan',plan,'NSim',0, ...
    'ExportFigures',false,'ShowProgress',false, ...
    'EnforceGuiPad',false,'ContinueOnError',true);

publicIdentifier = ...
    'Acycle:InterleavedCVCOCOStudy:SedimentationRateGridTooLarge';
verifyEqual(testCase,summary.status,'failed');
verifyEqual(testCase,summary.summary_rows(1).error_identifier, ...
    publicIdentifier);
verifyEqual(testCase,summary.cases(1).error_identifier,publicIdentifier);

caseDirectory = fullfile(outputRoot,'01_invalid_grid');
errorText = fileread(fullfile(caseDirectory,'error.txt'));
verifyTrue(testCase,contains(errorText,'Method: Interleaved cvCOCO'));
verifyTrue(testCase,contains(errorText, ...
    'Category: SedimentationRateGridTooLarge'));
verifyTrue(testCase,contains(errorText,['Identifier: ',publicIdentifier]));
verifyPublicFailureText(testCase,errorText);

savedCheckpoint = load(fullfile(caseDirectory,'checkpoint.mat'),'checkpoint');
verifyEqual(testCase,savedCheckpoint.checkpoint.error,errorText);
caseManifest = jsondecode(fileread(fullfile( ...
    caseDirectory,'case_manifest.json')));
verifyEqual(testCase,caseManifest.error_identifier,publicIdentifier);
verifyPublicFailureText(testCase,caseManifest.error_message);

caseSummary = readtable(fullfile(caseDirectory,'summary.csv'), ...
    'VariableNamingRule','preserve');
verifyEqual(testCase,string(caseSummary.error_identifier), ...
    string(publicIdentifier));
verifyPublicFailureText(testCase,char(string(caseSummary.error_message)));
verifyPublicFailureText(testCase,fileread(fullfile(outputRoot,'run.log')));
end

function verifyPublicFailureText(testCase,textValue)
forbidden = [ ...
    '(?i)(cvcoco9[a-z]*|adaptive9[a-z]*|interleavedcvcoco(?!study)|', ...
    'cross[- _]?fit|method[- _]?[ab]|', ...
    'ecoco(?:adaptive|crossfit|interleaved)core|error in )'];
verifyEmpty(testCase,regexp(textValue,forbidden,'match','once'));
end

function [root,inputFile,cleanup] = makeWorkspace(testCase)
root = tempname;
mkdir(root);
cleanup = onCleanup(@()removeWorkspace(root));
testCase.addTeardown(@()removeWorkspace(root));
inputFile = fullfile(root,'synthetic.txt');
writematrix(irregularOrbitalSeries(testCase.TestData.orbit9),inputFile);
end

function plan = syntheticPlan(inputFile)
plan = struct( ...
    'id','synthetic', ...
    'title','Synthetic interleaved smoke record', ...
    'category','theory', ...
    'filename','synthetic.txt', ...
    'input_file',inputFile, ...
    'age_ma',0, ...
    'sr1',3, ...
    'sr2',5, ...
    'srstep',1, ...
    'pad',512, ...
    'expected_rate','4 cm/kyr', ...
    'expected_windows',[3.5,4.5]);
end

function data = irregularOrbitalSeries(orbit9)
n = 501;
incrementPattern = [0.07;0.11;0.09;0.14;0.08;0.10;0.13];
increments = repmat(incrementPattern,ceil((n-1)/numel(incrementPattern)),1);
depth = [0;cumsum(increments(1:n-1))];
timeKyr = depth*100/4;
amplitude = [1.00;0.82;0.74;0.68;0.61;0.77;0.57;0.51;0.46];
phase = [0.1;0.7;1.4;2.2;2.8;0.4;1.1;1.9;2.5];
value = zeros(size(depth));
for orbitIndex = 1:numel(orbit9)
    value = value+amplitude(orbitIndex)*sin( ...
        2*pi*timeKyr/orbit9(orbitIndex)+phase(orbitIndex));
end
value = value+0.09*cos(2*pi*depth/1.73) + ...
    0.06*sin(2*pi*depth/0.91+0.3) + 0.002*depth;
data = [depth,value];
end

function removeWorkspace(root)
if isfolder(root)
    rmdir(root,'s');
end
end
