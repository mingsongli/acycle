function tests = test_ecoco_interleaved_core
%TEST_ECOCO_INTERLEAVED_CORE Prototype Interleaved eCOCO invariants.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
addpath(genpath(fullfile(repoRoot,'code')));
testCase.addTeardown(@()path(oldPath));

orbit9 = [405.6912;130.6979;123.8532;98.8517;94.8856; ...
    40.9897;23.6820;22.3758;18.9519];
trueRate = 4;
dt = 0.15;
depth = (0:178)'*dt;
timeKyr = depth*100/trueRate;
groupAmplitude = [1.0;0.82;0.67;0.53];
groupIndex = [1;2;2;2;2;3;4;4;4];
phase = [0.1;0.7;1.3;1.9;2.5;0.4;1.0;1.6;2.2];
value = zeros(size(depth));
for k = 1:numel(orbit9)
    value = value + groupAmplitude(groupIndex(k))*sin( ...
        2*pi*timeKyr/orbit9(k)+phase(k));
end
value = value + 0.05*sin(2*pi*timeKyr/71.3) + ...
    0.02*cos(2*pi*timeKyr/33.7) + 0.0004*depth.^2;
clean = [depth,value];

% The core must restore the exact cleaned record before assigning global
% parity: reverse the rows, append an identical duplicate, and add one
% nonfinite row that must not affect the global odd/even sequence.
raw = [clean(end:-1:1,:);clean(21,:);NaN,1];
rng(919,'twister');
stateBefore = rng;
% The modern Interleaved contract expresses both WINDOW and STEP in the
% physical depth unit.  These values preserve the historical two complete,
% balanced windows while making their intended 19.95-m width and 6.75-m
% centre spacing explicit.
windowDepth = 19.95;
stepDepth = 6.75;
legacyStepSamples = round(stepDepth/dt);
result = ecocoInterleavedCore( ...
    raw,orbit9,windowDepth,dt,legacyStepSamples,0,256, ...
    [3.8;4.0;4.2],1,'Pearson',0.06,2718,'BatchSize',1, ...
    'WindowMode','physical-depth','StepDepth',stepDepth);
stateAfter = rng;

legacyResult = ecocoInterleavedCore(raw,orbit9,20,dt,45,0,256, ...
    [3.8;4.0;4.2],0,'Pearson',0.06,2718,'BatchSize',1, ...
    'WindowMode','legacy-count');

[irregularRaw,irregularExpected] = irregularPhysicalWindowFixture(orbit9);
irregularResult = ecocoInterleavedCore( ...
    irregularRaw,orbit9,irregularExpected.window, ...
    irregularExpected.nominalSpacing, ...
    irregularExpected.legacyStepSamples,0,256, ...
    [3.8;4.0;4.2],0,'Pearson',0.06,314159,'BatchSize',1, ...
    'WindowMode','physical-depth','StepDepth',irregularExpected.step);

testCase.TestData.result = result;
testCase.TestData.legacyResult = legacyResult;
testCase.TestData.stateBefore = stateBefore;
testCase.TestData.stateAfter = stateAfter;
testCase.TestData.cleanPointCount = size(clean,1);
testCase.TestData.rawPointCount = size(raw,1);
testCase.TestData.raw = raw;
testCase.TestData.orbit9 = orbit9;
testCase.TestData.dt = dt;
testCase.TestData.windowDepth = windowDepth;
testCase.TestData.stepDepth = stepDepth;
testCase.TestData.irregularRaw = irregularRaw;
testCase.TestData.irregularExpected = irregularExpected;
testCase.TestData.irregularResult = irregularResult;
end

function testExplicitLegacyWindowModeRetainsCountContract(testCase)
r = testCase.TestData.legacyResult;

verifyEqual(testCase,r.windowPointCount,134);
verifyEqual(testCase,r.windows.startIndex,[1;46]);
verifyEqual(testCase,r.windows.endIndex,[134;179]);
verifyEqual(testCase,r.stepSamples,45);
verifyEqual(testCase,r.requestedWindow,20,'AbsTol',0);
end

function testBalancedCompleteWindowsKeepGlobalParity(testCase)
r = testCase.TestData.result;

verifyEqual(testCase,r.windowPointCount,134);
verifyEqual(testCase,r.windows.startIndex,[1;46]);
verifyEqual(testCase,r.windows.endIndex,[134;179]);
verifyEqual(testCase,r.windows.interleavedPhase,[0;1]);
verifyTrue(testCase,all(r.windows.success));
verifyEqual(testCase,r.windows.endIndex-r.windows.startIndex+1, ...
    repmat(r.windowPointCount,numel(r.depth),1));
verifyEqual(testCase,r.requestedWindow,testCase.TestData.windowDepth, ...
    'AbsTol',1e-12);
verifyEqual(testCase,r.actualWindowSpanByWindow, ...
    repmat(testCase.TestData.windowDepth,numel(r.depth),1), ...
    'AbsTol',1e-12);
verifyEqual(testCase,diff(r.depth),testCase.TestData.stepDepth, ...
    'AbsTol',1e-12);
verifyEqual(testCase,r.windows.oddFirstGlobalIndex,[1;47]);
verifyEqual(testCase,r.windows.evenFirstGlobalIndex,[2;46]);
verifyEqual(testCase,mod(r.windows.oddFirstGlobalIndex-1,2),[0;0]);
verifyEqual(testCase,mod(r.windows.evenFirstGlobalIndex-1,2),[1;1]);
verifyGreaterThanOrEqual(testCase,r.folds.rawPointCountOdd, ...
    repmat(8,numel(r.depth),1));
verifyGreaterThanOrEqual(testCase,r.folds.rawPointCountEven, ...
    repmat(8,numel(r.depth),1));
verifyEqual(testCase,r.folds.rawPointCountOdd, ...
    r.folds.rawPointCountEven);
end

function testIrregularSamplingUsesStrictPhysicalWindowsAndCentres(testCase)
r = testCase.TestData.irregularResult;
expected = testCase.TestData.irregularExpected;

% The fixture is deliberately nonuniform, but includes every requested
% boundary exactly.  A row-count implementation produces the wrong spans
% and centres; a physical-depth implementation produces these values
% exactly without interpolating the complete record.
verifyGreaterThan(testCase,numel(unique(round(diff(expected.cleanDepth),12))),1);
verifyEqual(testCase,r.windows.startIndex,expected.startIndex);
verifyEqual(testCase,r.windows.endIndex,expected.endIndex);
verifyEqual(testCase,r.depth,expected.centerDepth,'AbsTol',1e-12);
verifyEqual(testCase,diff(r.depth), ...
    repmat(expected.step,numel(r.depth)-1,1),'AbsTol',1e-12);
verifyEqual(testCase,r.actualWindowSpanByWindow, ...
    repmat(expected.window,numel(r.depth),1),'AbsTol',1e-12);
verifyEqual(testCase,r.requestedWindow,expected.window,'AbsTol',1e-12);
verifyEqual(testCase,r.stepDepth,expected.step,'AbsTol',1e-12);
verifyFalse(testCase,r.inputPreprocessing.fullRecordInterpolation);
verifyTrue(testCase,r.inputPreprocessing.splitBeforeInterpolation);
end

function testIrregularWindowsPreserveGlobalParity(testCase)
r = testCase.TestData.irregularResult;
expected = testCase.TestData.irregularExpected;

verifyEqual(testCase,r.windows.interleavedPhase,expected.phase);
verifyEqual(testCase,r.windows.oddFirstGlobalIndex,expected.oddFirstIndex);
verifyEqual(testCase,r.windows.evenFirstGlobalIndex,expected.evenFirstIndex);
verifyEqual(testCase,mod(r.windows.oddFirstGlobalIndex-1,2), ...
    zeros(expected.windowCount,1));
verifyEqual(testCase,mod(r.windows.evenFirstGlobalIndex-1,2), ...
    ones(expected.windowCount,1));
verifyEqual(testCase,r.folds.rawPointCountOdd, ...
    repmat(expected.foldPointCount,expected.windowCount,1));
verifyEqual(testCase,r.folds.rawPointCountEven, ...
    repmat(expected.foldPointCount,expected.windowCount,1));
end

function testIrregularWindowsAreCompleteAndNeverEdgePadded(testCase)
r = testCase.TestData.irregularResult;
expected = testCase.TestData.irregularExpected;

verifyEqual(testCase,numel(r.depth),expected.windowCount);
verifyEqual(testCase,r.windows.startIndex(1),1);
verifyEqual(testCase,r.windows.endIndex(end),numel(expected.cleanDepth));
verifyGreaterThanOrEqual(testCase,r.windows.startIndex, ...
    ones(expected.windowCount,1));
verifyLessThanOrEqual(testCase,r.windows.endIndex, ...
    repmat(numel(expected.cleanDepth),expected.windowCount,1));
verifyEqual(testCase,r.windows.pointCount, ...
    repmat(expected.windowPointCount,expected.windowCount,1));
verifyEqual(testCase,r.windows.endIndex-r.windows.startIndex+1, ...
    r.windows.pointCount);
verifyTrue(testCase,contains(r.metadata.completeWindowRule, ...
    'no edge padding','IgnoreCase',true));
end

function testOddBoundaryCountKeepsAllObservationsAndGlobalParity(testCase)
raw = testCase.TestData.irregularRaw;
expected = testCase.TestData.irregularExpected;
oddWindow = 24.30; % 162 intervals, hence 163 boundary-inclusive points
oddWindowIntervals = round(oddWindow/expected.nominalSpacing);
candidateStart = expected.startIndex;
candidateEnd = candidateStart+oddWindowIntervals;
center = oddWindow/2+(0:expected.windowCount-1)'*expected.step;

args = {raw,testCase.TestData.orbit9,oddWindow, ...
    expected.nominalSpacing,expected.legacyStepSamples,0,256,4,0, ...
    'Pearson',0.06};
r = ecocoInterleavedCore(args{:},2718,'BatchSize',1, ...
    'WindowMode','physical-depth','StepDepth',expected.step);

verifyEqual(testCase,r.depth,center,'AbsTol',1e-12);
verifyEqual(testCase,diff(r.depth), ...
    repmat(expected.step,expected.windowCount-1,1),'AbsTol',1e-12);
verifyEqual(testCase,r.windows.startIndex,candidateStart);
verifyEqual(testCase,r.windows.endIndex,candidateEnd);
verifyEqual(testCase,r.windows.pointCount, ...
    repmat(oddWindowIntervals+1,expected.windowCount,1));
verifyEqual(testCase,r.folds.rawPointCountOdd+ ...
    r.folds.rawPointCountEven,r.windows.pointCount);
verifyLessThanOrEqual(testCase,abs(r.folds.rawPointCountOdd- ...
    r.folds.rawPointCountEven),ones(expected.windowCount,1));
verifyEqual(testCase,mod(r.windows.oddFirstGlobalIndex-1,2), ...
    zeros(expected.windowCount,1));
verifyEqual(testCase,mod(r.windows.evenFirstGlobalIndex-1,2), ...
    ones(expected.windowCount,1));
end

function testPhysicalBoundariesBetweenObservationsUseEveryInteriorPoint(testCase)
raw = testCase.TestData.irregularRaw;
expected = testCase.TestData.irregularExpected;
windowDepth = 24.40;
stepDepth = 3.20;
leftBoundary = (0:expected.windowCount-1)'*stepDepth;
rightBoundary = leftBoundary+windowDepth;
center = 0.5*(leftBoundary+rightBoundary);
cleanDepth = expected.cleanDepth;
tolerance = 64*eps(max(1,max(abs(cleanDepth))));
startIndex = arrayfun(@(x)find(cleanDepth >= x-tolerance,1,'first'), ...
    leftBoundary);
endIndex = arrayfun(@(x)find(cleanDepth <= x+tolerance,1,'last'), ...
    rightBoundary);
pointCount = endIndex-startIndex+1;

r = ecocoInterleavedCore(raw,testCase.TestData.orbit9,windowDepth, ...
    expected.nominalSpacing,round(stepDepth/expected.nominalSpacing), ...
    0,256,4,0,'Pearson',0.06,2718,'BatchSize',1, ...
    'WindowMode','physical-depth','StepDepth',stepDepth);

verifyEqual(testCase,r.depth,center,'AbsTol',1e-12);
verifyEqual(testCase,diff(r.depth), ...
    repmat(stepDepth,expected.windowCount-1,1),'AbsTol',1e-12);
verifyEqual(testCase,r.windows.startIndex,startIndex);
verifyEqual(testCase,r.windows.endIndex,endIndex);
verifyEqual(testCase,r.windows.pointCount,pointCount);
verifyGreaterThanOrEqual(testCase,cleanDepth(startIndex), ...
    leftBoundary-tolerance);
verifyLessThanOrEqual(testCase,cleanDepth(endIndex), ...
    rightBoundary+tolerance);
verifyLessThanOrEqual(testCase,r.windowObservedSpanByWindow, ...
    repmat(windowDepth,expected.windowCount,1)+tolerance);
verifyTrue(testCase,any(r.windowObservedSpanByWindow < ...
    windowDepth-1e-6));
verifyEqual(testCase,r.folds.rawPointCountOdd+ ...
    r.folds.rawPointCountEven,r.windows.pointCount);
verifyLessThanOrEqual(testCase,abs(r.folds.rawPointCountOdd- ...
    r.folds.rawPointCountEven),ones(expected.windowCount,1));
end

function testSameRateConsensusAndPValueOrdering(testCase)
r = testCase.TestData.result;
bothFinite = isfinite(r.forward.rho) & isfinite(r.backward.rho);
verifyTrue(testCase,any(bothFinite,'all'));
expectedConsensus = min(r.forward.rho,r.backward.rho);
verifyEqual(testCase,r.consensus.rho(bothFinite), ...
    expectedConsensus(bothFinite),'AbsTol',0);
verifyEqual(testCase,r.rho,r.consensus.rho,'AbsTol',0);

finiteP = isfinite(r.pGlobal) & isfinite(r.pLocal);
verifyTrue(testCase,any(finiteP,'all'));
verifyGreaterThanOrEqual(testCase,r.pGlobal(finiteP),r.pLocal(finiteP));
verifyEqual(testCase,r.consensus.pDirectionalMax, ...
    max(r.forward.pGlobal,r.backward.pGlobal),'AbsTol',0);
verifyEqual(testCase,r.strictConsensus.pGlobal, ...
    r.consensus.pDirectionalMax,'AbsTol',0);
verifyEqual(testCase,r.pRobust, ...
    max(r.pDirectionalOddToEven,r.pDirectionalEvenToOdd),'AbsTol',0);
verifyEqual(testCase,r.pConsensus, ...
    r.consensus.windowGlobalP,'AbsTol',0);
verifySize(testCase,r.pSym,[numel(r.depth),1]);
verifyEqual(testCase,r.windows.directionalBestRateDifference, ...
    abs(r.forward.bestRate-r.backward.bestRate),'AbsTol',0);
verifyTrue(testCase,all(isnan(r.pParametric),'all'));
end

function testSchemaRngAndJointNullMetadata(testCase)
r = testCase.TestData.result;
nRate = numel(r.srGrid);
nWindows = numel(r.depth);
rootMaps = {'rho','pLocal','pGlobal','nOrbit','pCOCO','score'};
for k = 1:numel(rootMaps)
    verifySize(testCase,r.(rootMaps{k}),[nRate,nWindows]);
end
verifyEqual(testCase,r.oddToEven.rho,r.forward.rho,'AbsTol',0);
verifyEqual(testCase,r.evenToOdd.rho,r.backward.rho,'AbsTol',0);
verifyEqual(testCase,r.method,'Interleaved eCOCO');
verifyEqual(testCase,r.name,'Interleaved eCOCO');
verifyEqual(testCase,r.publicName,'Interleaved eCOCO');
verifyEqual(testCase,r.abbreviation,'Interleaved eCOCO');
verifyEqual(testCase,r.version,3);
verifyEqual(testCase,r.algorithmVersion, ...
    'Interleaved eCOCO — windowed v3');
verifyEqual(testCase,r.pGlobal,r.consensus.pGlobal,'AbsTol',0);
verifyEqual(testCase,r.pCOCO,r.consensus.pCOCO,'AbsTol',0);
verifyEqual(testCase,r.score,r.consensus.score,'AbsTol',0);
verifyEqual(testCase,r.score,r.pCOCO,'AbsTol',0);
verifyEqual(testCase,r.consensus.score,r.consensus.pCOCO,'AbsTol',0);
verifyEqual(testCase,r.scoreDefinition, ...
    ['pCOCO = consensus rho x abs(log10(consensus global p)); ', ...
     'no orbit-count weighting']);
verifyEqual(testCase,r.directionLabels.forward,'Odd -> Even');
verifyTrue(testCase,r.monteCarlo.jointNull);
verifyTrue(testCase,r.metadata.jointNull);
verifyTrue(testCase,r.metadata.experimental);
verifyEqual(testCase,r.nsimCompletedByWindow,[1;1]);
verifyNotEqual(testCase,r.windows.seed(1),r.windows.seed(2));
verifySize(testCase,r.allNineRateRangeOdd,[nWindows,2]);
verifySize(testCase,r.allNineRateRangeEven,[nWindows,2]);
verifySize(testCase,r.allNineRateRangeShared,[nWindows,2]);
verifySize(testCase,r.bestRateAllNineResolved,[nWindows,1]);
verifyEqual(testCase,r.resolutionWarningWindowCount, ...
    nnz(r.windows.success & ~r.bestRateAllNineResolved));

verifyFalse(testCase,r.inputPreprocessing.fullRecordInterpolation);
verifyTrue(testCase,r.inputPreprocessing.splitBeforeInterpolation);
verifyEqual(testCase,r.inputPreprocessing.inputPointCount, ...
    testCase.TestData.rawPointCount);
verifyEqual(testCase,r.inputPreprocessing.cleanPointCount, ...
    testCase.TestData.cleanPointCount);
verifyEqual(testCase,r.inputPreprocessing.duplicatePointCount,1);
verifyEqual(testCase,r.samplingInterval,0.15,'AbsTol',1e-14);
verifyEqual(testCase,testCase.TestData.stateAfter, ...
    testCase.TestData.stateBefore);
end

function testPartialOrbitScoreDoesNotUseOrbitCountWeight(testCase)
raw = testCase.TestData.raw;
orbit9 = testCase.TestData.orbit9;
dt = testCase.TestData.dt;
r = ecocoInterleavedCore(raw,orbit9,testCase.TestData.windowDepth, ...
    dt,round(testCase.TestData.stepDepth/dt),0,256,10,1, ...
    'Pearson',0.06,2718,'BatchSize',1, ...
    'WindowMode','physical-depth', ...
    'StepDepth',testCase.TestData.stepDepth, ...
    'WarnOnPartialTraining',false);

verifyEqual(testCase,r.score,r.pCOCO,'AbsTol',0);
for directionName = {'forward','backward','consensus','strictConsensus', ...
        'oddToEven','evenToOdd'}
    direction = r.(directionName{1});
    verifyEqual(testCase,direction.score,direction.pCOCO,'AbsTol',0);
end
partialScore = isfinite(r.score) & isfinite(r.pCOCO) & ...
    r.nOrbit > 0 & r.nOrbit < numel(orbit9) & abs(r.pCOCO) > 1e-12;
verifyTrue(testCase,any(partialScore,'all'));
oldWeightedScore = r.pCOCO(partialScore).* ...
    r.nOrbit(partialScore)./numel(orbit9);
verifyGreaterThan(testCase,max(abs( ...
    r.score(partialScore)-oldWeightedScore)),1e-12);
end

function testPublicEcocoWrapperDispatchesInterleavedMode(testCase)
raw = testCase.TestData.raw;
orbit9 = testCase.TestData.orbit9;
dt = testCase.TestData.dt;
[rates,depth,rho,pLocal,pGlobal,~,score,nOrbit,tracked,details] = ecoco( ...
    raw,[],orbit9,testCase.TestData.windowDepth,dt, ...
    round(testCase.TestData.stepDepth/dt),0,0,256, ...
    3.8,4.2,0.2,1,0,1,0, ...
    'Pearson',1/(2*dt),0,'interleaved',0.06,2718,0.5, ...
    'Verbose',false,'InterleavedWindowMode','physical-depth', ...
    'InterleavedStepDepth',testCase.TestData.stepDepth);

verifyEqual(testCase,details.method,'Interleaved eCOCO');
verifyEqual(testCase,details.name,'Interleaved eCOCO');
verifyFalse(testCase,details.inputPreprocessing.fullRecordInterpolation);
verifyTrue(testCase,details.inputPreprocessing.splitBeforeInterpolation);
verifyEqual(testCase,rates,[3.8;4.0;4.2],'AbsTol',1e-14);
verifySize(testCase,rho,[numel(rates),numel(depth)]);
verifySize(testCase,pLocal,size(rho));
verifySize(testCase,pGlobal,size(rho));
verifySize(testCase,score,size(rho));
verifySize(testCase,nOrbit,size(rho));
verifyEqual(testCase,details.trackedSedimentationRate,tracked,'AbsTol',0);
for windowIndex = 1:size(tracked,1)
    if ~isfinite(tracked(windowIndex,2))
        continue
    end
    [~,rateIndex] = min(abs(rates-tracked(windowIndex,2)));
    verifyEqual(testCase,tracked(windowIndex,6), ...
        score(rateIndex,windowIndex),'AbsTol',0);
end
end

function [raw,expected] = irregularPhysicalWindowFixture(orbit9)
% Three unequal increments sum to 0.45 m. WINDOW and STEP are exact
% multiples of this pattern, so every requested physical boundary exists
% in the cleaned observations while the sampling remains unmistakably
% irregular inside every window.
incrementPattern = [0.11;0.15;0.19];
windowDepth = 24.75; % 55 patterns, 165 intervals, 166 points
stepDepth = 3.15;    % 7 patterns, 21 intervals; parity alternates by window
windowCount = 8;
totalDepth = windowDepth+(windowCount-1)*stepDepth;
patternCount = round(totalDepth/sum(incrementPattern));
increment = repmat(incrementPattern,patternCount,1);
cleanDepth = [0;cumsum(increment)];
cleanDepth(end) = totalDepth;

trueRate = 4;
timeKyr = cleanDepth*100/trueRate;
groupAmplitude = [1.0;0.82;0.67;0.53];
groupIndex = [1;2;2;2;2;3;4;4;4];
phase = [0.1;0.7;1.3;1.9;2.5;0.4;1.0;1.6;2.2];
value = zeros(size(cleanDepth));
for k = 1:numel(orbit9)
    value = value + groupAmplitude(groupIndex(k))*sin( ...
        2*pi*timeKyr/orbit9(k)+phase(k));
end
value = value + 0.03*cos(2*pi*timeKyr/67.1) + ...
    0.0002*cleanDepth.^2;
clean = [cleanDepth,value];

% Cleaning must happen before global odd/even identity is assigned.
raw = [clean(end:-1:1,:);clean(23,:);NaN,1];

intervalsPerStep = round(stepDepth/mean(incrementPattern));
intervalsPerWindow = round(windowDepth/mean(incrementPattern));
startIndex = 1+(0:windowCount-1)'*intervalsPerStep;
endIndex = startIndex+intervalsPerWindow;
phaseByWindow = mod(startIndex-1,2);
expected = struct( ...
    'window',windowDepth, ...
    'step',stepDepth, ...
    'nominalSpacing',median(diff(cleanDepth)), ...
    'legacyStepSamples',round(stepDepth/median(diff(cleanDepth))), ...
    'cleanDepth',cleanDepth, ...
    'windowCount',windowCount, ...
    'windowPointCount',intervalsPerWindow+1, ...
    'foldPointCount',(intervalsPerWindow+1)/2, ...
    'startIndex',startIndex, ...
    'endIndex',endIndex, ...
    'centerDepth',(cleanDepth(startIndex)+cleanDepth(endIndex))/2, ...
    'phase',phaseByWindow, ...
    'oddFirstIndex',startIndex+phaseByWindow, ...
    'evenFirstIndex',startIndex+(1-phaseByWindow));
end
