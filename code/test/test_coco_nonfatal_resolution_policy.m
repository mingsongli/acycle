function tests = test_coco_nonfatal_resolution_policy
%TEST_COCO_NONFATAL_RESOLUTION_POLICY Nonblocking orchestration policy.
%
% Modern four-group cvCOCO may train a resolved partial orbital target when
% the tested grid contains no complete all-nine rate.  It must warn, zero
% unresolved group weights, and still return the numerical result.  Truly
% undefined geometries retain audited exceptions that GUI/batch boundaries
% may classify, warn about, and skip without blocking later work.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
addpath(genpath(fullfile(repoRoot,'code')));
testCase.addTeardown(@()path(oldPath));

oldWarning = warning;
testCase.addTeardown(@()warning(oldWarning));

testCase.TestData.repoRoot = repoRoot;
testCase.TestData.orbit9 = [405;125;100;95;82;41;23;22;19];
depth = (0:0.5:100)';
proxy = sin(2*pi*depth/13.7) + 0.35*cos(2*pi*depth/5.3);
testCase.TestData.data = [depth,proxy];
end

function testFourGroupCoreWarnsAndReturnsPartialNumerics(testCase)
% This exact fixture has usable long/short-eccentricity geometry but no
% all-nine rate in either held-out segment.  It previously threw
% cvcoco:NoAllNineTrainingRate and caused the GUI to skip the whole method.
warning('on','Acycle:BlockedCVCOCO:PartialOrbitTraining');
lastwarn('');
result = cvcoco(testCase.TestData.data,testCase.TestData.orbit9,256, ...
    1,2,0.5,0,3,'Pearson','TargetModel','four-group', ...
    'AnalysisName','Blocked cvCOCO', ...
    'BatchSize',2,'Seed',13,'Verbose',false);
[warningMessage,warningIdentifier] = lastwarn;

verifyEqual(testCase,warningIdentifier, ...
    'Acycle:BlockedCVCOCO:PartialOrbitTraining');
verifySubstring(testCase,lower(warningMessage),'partial');
verifyEqual(testCase,result.warningIdentifier,warningIdentifier);
verifyTrue(testCase,result.degradedMode);
verifyEqual(testCase,result.trainingCompleteness,'partial-orbit');

% The strict complete-target masks are empty, while the operational masks
% retain rates at which at least one orbital group can be trained.
verifyFalse(testCase,any(result.strictTrainingRateMaskA));
verifyFalse(testCase,any(result.strictTrainingRateMaskB));
verifyTrue(testCase,any(result.trainingRateMaskA));
verifyTrue(testCase,any(result.trainingRateMaskB));
verifyTrue(testCase,result.trainA.partialOrbitTraining);
verifyTrue(testCase,result.trainB.partialOrbitTraining);
verifySize(testCase,result.trainA.resolvedGroupMask,[4,1]);
verifySize(testCase,result.trainB.resolvedGroupMask,[4,1]);
verifyClass(testCase,result.trainA.resolvedGroupMask,'logical');
verifyClass(testCase,result.trainB.resolvedGroupMask,'logical');
verifyTrue(testCase,any(result.trainA.resolvedGroupMask));
verifyTrue(testCase,any(result.trainB.resolvedGroupMask));
verifyTrue(testCase,any(~result.trainA.resolvedGroupMask));
verifyTrue(testCase,any(~result.trainB.resolvedGroupMask));

verifyPartialFrozenWeights(testCase,result.trainA);
verifyPartialFrozenWeights(testCase,result.trainB);

% Both observed directional searches and the complete small Monte Carlo
% pipeline must remain numerical. NaNs outside operational masks are not
% treated as missing results.
verifyFiniteOnMask(testCase,result.trainA.curve, ...
    result.trainingRateMaskA,'train A');
verifyFiniteOnMask(testCase,result.trainB.curve, ...
    result.trainingRateMaskB,'train B');
verifyFiniteOnMask(testCase,result.validateAtoB.curve, ...
    result.validateAtoB.validRateMask,'A-to-B validation');
verifyFiniteOnMask(testCase,result.validateBtoA.curve, ...
    result.validateBtoA.validRateMask,'B-to-A validation');
verifyTrue(testCase,all(isfinite([ ...
    result.trainA.bestCorrelation,result.trainB.bestCorrelation, ...
    result.validateAtoB.score,result.validateBtoA.score, ...
    result.scoreSymmetric,result.scoreConsensus,result.scoreMean, ...
    result.pAtoB,result.pBtoA,result.pSym,result.pConsensus])));

verifyEqual(testCase,result.nsimRequested,3);
verifyEqual(testCase,result.nsimCompleted,3);
verifyEqual(testCase,result.nsimValid,3);
verifyEqual(testCase,result.nsimValidConsensus,3);
verifyEqual(testCase,result.nsimValidAtoB,3);
verifyEqual(testCase,result.nsimValidBtoA,3);
verifySize(testCase,result.nullAtoB,[3,1]);
verifySize(testCase,result.nullBtoA,[3,1]);
verifyTrue(testCase,all(isfinite(result.nullAtoB)));
verifyTrue(testCase,all(isfinite(result.nullBtoA)));

report = cocoConclusionReport('confirmatory',result);
verifyEqual(testCase,report.mode,'partial-orbit-exploratory');
verifyFalse(testCase,report.confirmatoryEligible);
verifyFalse(testCase,report.pass);
verifyEqual(testCase,report.directionalPass, ...
    max(result.pA,result.pB) < report.alphaGlobal);
verifySubstring(testCase,lower(report.conclusion),'partial-orbit');
end

function testInterleavedEcocoRetainsPartialWindows(testCase)
result = ecocoInterleavedCore(testCase.TestData.data, ...
    testCase.TestData.orbit9,100,0.5,2,0,256,[1;1.5;2],3, ...
    'Pearson',0.064,13,'WindowMode','physical-depth', ...
    'StepDepth',2,'BatchSize',2,'WarnOnPartialTraining',false);

verifyTrue(testCase,result.degradedMode);
verifyEqual(testCase,result.status,'complete-with-warning');
verifyGreaterThanOrEqual(testCase,result.partialOrbitTrainingWindowCount,1);
verifyTrue(testCase,any(result.windows.success));
verifyTrue(testCase,all(result.windows.partialOrbitTraining( ...
    result.windows.success)));
verifyTrue(testCase,all(isfinite( ...
    result.rho(:,result.windows.success)),'all'));
verifyTrue(testCase,all(isfinite( ...
    result.pGlobal(:,result.windows.success)),'all'));
verifyEqual(testCase,result.warningIdentifier, ...
    'Acycle:InterleavedECOCO:PartialOrbitTraining');
end

function testPublicCoherentWrapperAlsoCompletes(testCase)
result = cvcoco9B(testCase.TestData.data,testCase.TestData.orbit9,256, ...
    1,2,0.5,0,2,'Pearson','BatchSize',2,'Seed',13, ...
    'Verbose',false,'WarnOnPartialTraining',false);

verifyTrue(testCase,result.degradedMode);
verifyEqual(testCase,result.status,'complete-with-warning');
verifyEqual(testCase,result.nsimCompleted,2);
verifyTrue(testCase,all(isfinite([result.validateAtoB.score, ...
    result.validateBtoA.score,result.pA,result.pB])));
verifySubstring(testCase,result.analysisRole,'partial-orbit');
end

function testPublicEcocoWrapperSanitizesCoreFailures(testCase)
cases = { ...
    'adaptive','Adaptive eCOCO','Acycle:AdaptiveECOCO:PadTooShort',2; ...
    'crossfit','Blocked eCOCO','Acycle:BlockedECOCO:PadTooShort',2; ...
    'interleaved','Interleaved eCOCO', ...
        'Acycle:InterleavedECOCO:DuplicateOrbitPeriods',256};
for index = 1:size(cases,1)
    mode = cases{index,1};
    publicName = cases{index,2};
    expectedIdentifier = cases{index,3};
    pad = cases{index,4};
    periods = testCase.TestData.orbit9;
    if strcmp(mode,'interleaved')
        periods(end) = periods(end-1);
    end
    exception = captureEcocoFailure(testCase.TestData.data,periods,pad,mode);
    verifyEqual(testCase,exception.identifier,expectedIdentifier);
    verifySubstring(testCase,exception.message,publicName);
    report = getReport(exception,'extended','hyperlinks','off');
    forbidden = [ ...
        '(?i)(cvcoco9[a-z]*|adaptive9[a-z]*|interleavedcvcoco|', ...
        'cross[- _]?fit|method[- _]?[ab]|', ...
        'ecoco(?:adaptive|crossfit|interleaved)core)'];
    verifyEmpty(testCase,regexp(report,forbidden,'match','once'));
end
end

function exception = captureEcocoFailure(data,periods,pad,mode)
try
    ecoco(data,[],periods,20,0.5,2,0,0,pad,1,2,0.5,0,0,1,0, ...
        'Pearson',1,0,mode,0.064,1,0.5,'Verbose',false);
    error('test_coco_nonfatal_resolution_policy:ExpectedFailure', ...
        'The deliberate invalid eCOCO request unexpectedly succeeded.');
catch exception
    if strcmp(exception.identifier, ...
            'test_coco_nonfatal_resolution_policy:ExpectedFailure')
        rethrow(exception)
    end
end
end

function testClassifierRecognizesOnlyAuditedResolutionFailures(testCase)
knownIdentifiers = { ...
    'cvcoco:NoAllNineTrainingRate'; ...
    'cvcoco:NoValidSedimentationRate'; ...
    'ecocoCrossfitCore:NoTrainingRate'; ...
    'ecocoCrossfitCore:NoValidationRate'; ...
    'ecocoInterleavedCore:NoResolvableWindows'; ...
    'Acycle:BlockedECOCO:NoTrainingRate'; ...
    'Acycle:BlockedECOCO:NoValidationRate'; ...
    'Acycle:InterleavedECOCO:NoResolvableWindows'; ...
    'corrcoefslices_rankNew:NoValidObservedStatistic'};

for index = 1:numel(knownIdentifiers)
    identifier = knownIdentifiers{index};
    exception = MException(identifier,'deliberate test failure');
    [isNonfatal,matchedIdentifier] = ...
        cocoIsNonfatalResolutionError(exception);
    verifyTrue(testCase,isNonfatal,identifier);
    verifyEqual(testCase,matchedIdentifier,identifier);
end

% The recoverable partial-target condition is a warning identifier, not an
% exception for the GUI's skip branch to classify.
[isNonfatal,matchedIdentifier] = cocoIsNonfatalResolutionError( ...
    MException('Acycle:BlockedCVCOCO:PartialOrbitTraining', ...
    'partial target warning'));
verifyFalse(testCase,isNonfatal);
verifyEmpty(testCase,matchedIdentifier);

% Wrappers may preserve a numerical failure as a cause while giving the
% outer exception their own identifier.  Classification must walk causes.
cause = MException('cvcoco:NoAllNineTrainingRate', ...
    'no complete training target');
wrapped = addCause(MException('publicationStudy:MethodFailed', ...
    'Blocked cvCOCO failed'),cause);
[isNonfatal,matchedIdentifier] = cocoIsNonfatalResolutionError(wrapped);
verifyTrue(testCase,isNonfatal);
verifyEqual(testCase,matchedIdentifier,cause.identifier);

% Similar wording and unrelated runtime/programming errors remain fatal.
unknownIdentifiers = { ...
    'cvcoco:NoAllNineTrainingRates'; ...
    'cvcoco:ZeroVariance'; ...
    'MATLAB:badsubscript'};
for index = 1:numel(unknownIdentifiers)
    exception = MException(unknownIdentifiers{index},'fatal test failure');
    [isNonfatal,matchedIdentifier] = ...
        cocoIsNonfatalResolutionError(exception);
    verifyFalse(testCase,isNonfatal,unknownIdentifiers{index});
    verifyEmpty(testCase,matchedIdentifier);
end
end

function verifyPartialFrozenWeights(testCase,train)
weights = train.frozenValidationWeights(:);
resolved = train.resolvedGroupMask(:);
verifySize(testCase,weights,[4,1]);
verifyTrue(testCase,all(isfinite(weights)));
verifyGreaterThanOrEqual(testCase,weights,zeros(4,1));
verifyEqual(testCase,weights(~resolved),zeros(nnz(~resolved),1), ...
    'AbsTol',0);
verifyGreaterThan(testCase,max(weights(resolved)),0);
end

function verifyFiniteOnMask(testCase,curve,mask,label)
curve = curve(:);
mask = logical(mask(:));
verifyEqual(testCase,numel(curve),numel(mask),label);
verifyTrue(testCase,any(mask),label);
verifyTrue(testCase,all(isfinite(curve(mask))),label);
end

function testWarningPolicyContinuesWithLaterTask(testCase)
tasks = { ...
    @()throwTask(MException('cvcoco:NoAllNineTrainingRate', ...
        'all-nine target is unresolved')), ...
    @()17};

lastwarn('');
trace = runOrchestrationHarness(tasks);
[warningMessage,warningIdentifier] = lastwarn;

verifyEqual(testCase,warningIdentifier,'cvcoco:NoAllNineTrainingRate');
verifySubstring(testCase,warningMessage,'Current method skipped');
verifyEqual(testCase,trace.status,{'skipped';'complete'});
verifyTrue(testCase,isnan(trace.value(1)));
verifyEqual(testCase,trace.value(2),17);
verifyEqual(testCase,trace.completedTaskCount,1);
verifyEqual(testCase,trace.skippedTaskCount,1);
end

function testUnknownFailureStillAbortsOrchestration(testCase)
tasks = {@()throwTask(MException('cvcoco:ZeroVariance', ...
    'invalid observation')),@()17};
verifyError(testCase,@()runOrchestrationHarness(tasks), ...
    'cvcoco:ZeroVariance');
end

function trace = runOrchestrationHarness(tasks)
% Minimal UI-free equivalent of the GUI/batch boundary catch policy.
nTask = numel(tasks);
status = repmat({''},nTask,1);
value = nan(nTask,1);
for index = 1:nTask
    try
        value(index) = tasks{index}();
        status{index} = 'complete';
    catch exception
        if ~cocoIsNonfatalResolutionError(exception)
            rethrow(exception)
        end
        warning(exception.identifier, ...
            '%s\nCurrent method skipped; later tasks remain available.', ...
            exception.message);
        status{index} = 'skipped';
    end
end
trace = struct('status',{status},'value',value, ...
    'completedTaskCount',nnz(strcmp(status,'complete')), ...
    'skippedTaskCount',nnz(strcmp(status,'skipped')));
end

function value = throwTask(exception)
% Declare an output so the harness can treat failing and successful tasks
% uniformly; execution always throws before a value can be consumed.
value = NaN; %#ok<NASGU>
throwAsCaller(exception)
end
