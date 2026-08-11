function tests = test_ecoco_crossfit_core
%TEST_ECOCO_CROSSFIT_CORE Blocked eCOCO numerical invariants.
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
dt = 0.04;
depth = (0:2000)'*dt;
timeKyr = depth*100/trueRate;
groupAmplitude = [1.0;0.82;0.67;0.53];
groupIndex = [1;2;2;2;2;3;4;4;4];
phase = [0.1;0.7;1.3;1.9;2.5;0.4;1.0;1.6;2.2];
value = zeros(size(depth));
for k = 1:numel(orbit9)
    value = value + groupAmplitude(groupIndex(k))*sin( ...
        2*pi*timeKyr/orbit9(k)+phase(k));
end
% A deterministic, non-orbital perturbation keeps every local AR(1)
% estimate and detrended variance numerically resolved.
value = value + 0.07*sin(2*pi*timeKyr/71.3) + ...
    0.02*cos(2*pi*timeKyr/33.7) + 0.0003*depth;

testCase.TestData.repoRoot = repoRoot;
testCase.TestData.data = [depth,value];
testCase.TestData.orbit9 = orbit9;
testCase.TestData.window = 20;
testCase.TestData.dt = dt;
testCase.TestData.step = 125;
testCase.TestData.pad = 1024;
testCase.TestData.srGrid = [3.8;4.0;4.2];
testCase.TestData.maxFrequency = 0.06;
testCase.TestData.seed = 2718;
end

function testCompleteWindowsNearestNonoverlapAndEdgeFallback(testCase)
r = runCore(testCase,0,2);
nWindow = round(testCase.TestData.window/testCase.TestData.dt)+1;
anchorStep = round(0.5*(nWindow-1));

verifyEqual(testCase,r.name,'Blocked eCOCO');
verifyEqual(testCase,r.publicName,'Blocked eCOCO');
verifyEqual(testCase,r.abbreviation,'Blocked eCOCO');
verifyEqual(testCase,r.version,3);
verifyEqual(testCase,r.algorithmVersion, ...
    'Blocked eCOCO — full-grid partial-group v4');
verifyEqual(testCase,r.metadata.windowPointCount,nWindow);
verifyEqual(testCase,r.metadata.windowActualSpan, ...
    testCase.TestData.window,'AbsTol',1e-13);
verifyEqual(testCase,r.metadata.anchorStepSamples,anchorStep);
verifyEqual(testCase,diff(r.anchors.startIndex), ...
    repmat(anchorStep,numel(r.anchors.startIndex)-1,1));
verifyEqual(testCase,r.windows.endIndex-r.windows.startIndex+1, ...
    repmat(nWindow,numel(r.depth),1));

for j = 1:numel(r.depth)
    if r.windows.hasForward(j)
        k = r.windows.forwardAnchorIndex(j);
        verifyLessThan(testCase,r.anchors.endIndex(k), ...
            r.windows.startIndex(j));
        eligible = find(r.anchors.endIndex < r.windows.startIndex(j));
        verifyEqual(testCase,k,eligible(end));
    else
        verifyTrue(testCase,all(isnan(r.forward.rho(:,j))));
    end
    if r.windows.hasBackward(j)
        k = r.windows.backwardAnchorIndex(j);
        verifyGreaterThan(testCase,r.anchors.startIndex(k), ...
            r.windows.endIndex(j));
        eligible = find(r.anchors.startIndex > r.windows.endIndex(j));
        verifyEqual(testCase,k,eligible(1));
    else
        verifyTrue(testCase,all(isnan(r.backward.rho(:,j))));
    end
end

verifyEqual(testCase,r.supportDirection{1},'backward-only');
verifyEqual(testCase,r.supportDirection{end},'forward-only');
both = r.windows.hasForward & r.windows.hasBackward;
verifyTrue(testCase,any(both));
verifyEqual(testCase,r.consensus.rho(:,both), ...
    min(r.forward.rho(:,both),r.backward.rho(:,both)),'AbsTol',0);
verifyTrue(testCase,all(isnan(r.strictConsensus.rho(:,~both)),'all'));

forwardOnly = r.windows.hasForward & ~r.windows.hasBackward;
backwardOnly = ~r.windows.hasForward & r.windows.hasBackward;
verifyEqual(testCase,r.consensus.rho(:,forwardOnly), ...
    r.forward.rho(:,forwardOnly),'AbsTol',0);
verifyEqual(testCase,r.consensus.rho(:,backwardOnly), ...
    r.backward.rho(:,backwardOnly),'AbsTol',0);
verifySize(testCase,r.anchors.groupWeights,[4,numel(r.anchors.startIndex)]);
verifySize(testCase,r.anchors.trainCurve, ...
    [numel(r.srGrid),numel(r.anchors.startIndex)]);
verifyTrue(testCase,all(isnan(r.consensus.pGlobal),'all'));

rootFields = {'rho','pLocal','pParametric','pGlobal','nOrbit','pCOCO','score'};
for fieldIndex = 1:numel(rootFields)
    verifySize(testCase,r.(rootFields{fieldIndex}), ...
        [numel(r.srGrid),numel(r.depth)]);
end
for direction = {'forward','backward','consensus','strictConsensus'}
    verifyTrue(testCase,isfield(r.(direction{1}),'nOrbit'));
    verifyTrue(testCase,isfield(r.(direction{1}),'score'));
end
verifyTrue(testCase,isfield(r,'anchor'));
end

function testWrapperStrictConsensusMasksOneDirectionEdgesAndPreservesRng(testCase)
t = testCase.TestData;
arguments = {t.data,[],t.orbit9,t.window,t.dt,t.step,0,0,t.pad, ...
    t.srGrid(1),t.srGrid(end),diff(t.srGrid(1:2)),0,0,1,0, ...
    'Pearson',1/(2*t.dt),0,'crossfit',t.maxFrequency,t.seed,0.5, ...
    'Verbose',false};
rng(97531,'twister');
beforeRng = rng;
[~,~,supportedRho,~,~,~,~,~,~,supported] = ecoco(arguments{:});
verifyEqual(testCase,rng,beforeRng);
[~,~,strictRho,~,~,~,strictScore,~,strictRidge,strict] = ...
    ecoco(arguments{:},'BlockedConsensusPolicy','strict');
verifyEqual(testCase,rng,beforeRng);

oneDirection = xor(strict.windows.hasForward,strict.windows.hasBackward);
bothDirections = strict.windows.hasForward & strict.windows.hasBackward;
verifyTrue(testCase,any(oneDirection));
verifyTrue(testCase,any(bothDirections));
verifyEqual(testCase,supported.blockedConsensusPolicy,'supported');
verifyEqual(testCase,supportedRho,supported.consensus.rho,'AbsTol',0);
verifyEqual(testCase,strict.blockedConsensusPolicy,'strict');
verifyEqual(testCase,strict.rootConsensus, ...
    'strict bidirectional consensus; no one-sided fallback');
verifyTrue(testCase,all(isnan(strictRho(:,oneDirection)),'all'));
verifyTrue(testCase,all(isnan(strictScore(:,oneDirection)),'all'));
verifyEqual(testCase,strictRho(:,bothDirections), ...
    strict.strictConsensus.rho(:,bothDirections),'AbsTol',0);
verifyEqual(testCase,strictRidge(:,1),strict.depth(:),'AbsTol',0);
verifyTrue(testCase,all(isnan(strictRidge(oneDirection,2:8)),'all'));
end

function testAge566PeriodsDoNotStopBlockedEcoco(testCase)
t = testCase.TestData;
orbitMatrix = calculate_orbit9(566);
periods = orbitMatrix(:,2)/1000;
timeKyr = t.data(:,1)*100/4;
phase = (0:8)'*0.31;
value = sum(sin(2*pi*timeKyr./periods'+phase'),2)+ ...
    0.03*cos(2*pi*timeKyr/37.1)+0.0003*t.data(:,1);

r = ecocoCrossfitCore([t.data(:,1),value],periods,t.window,t.dt, ...
    t.step,0,t.pad,t.srGrid,0,'Pearson',1.2/min(periods), ...
    t.seed,0.5,'BatchSize',2,'ComputeLocalP',true, ...
    'MemoryBudgetMiB',64);

verifyEqual(testCase,r.geometry.groupIndex,[1;2;2;2;2;3;4;4;4]);
verifyTrue(testCase,any(isfinite(r.rho),'all'));
end

function testMatchesCvCoco9BOneDirectionOracle(testCase)
r = runCore(testCase,0,2);
j = find(r.windows.hasForward & r.windows.hasBackward,1,'first');
verifyNotEmpty(testCase,j);
nWindow = r.metadata.windowPointCount;
dt = testCase.TestData.dt;
syntheticDepth = (0:2*nWindow-1)'*dt;

validationValues = windowValues(testCase.TestData.data, ...
    r.windows.startIndex(j),nWindow);
left = r.windows.forwardAnchorIndex(j);
leftValues = windowValues(testCase.TestData.data, ...
    r.anchors.startIndex(left),nWindow);
forwardReference = cvcoco9B( ...
    [syntheticDepth,[leftValues;validationValues]], ...
    testCase.TestData.orbit9,testCase.TestData.pad, ...
    r.srGrid(1),r.srGrid(end),r.srGrid(2)-r.srGrid(1),0,0, ...
    'Pearson','MaxFrequency',testCase.TestData.maxFrequency, ...
    'Seed',testCase.TestData.seed);
verifyEqual(testCase,r.forward.rho(:,j), ...
    forwardReference.validateAtoB.curve,'AbsTol',5e-12);
verifyEqual(testCase,r.anchors.bestRate(left), ...
    forwardReference.trainA.bestRate,'AbsTol',0);
verifyEqual(testCase,r.anchors.groupWeights(:,left), ...
    forwardReference.trainA.groupNormalized,'AbsTol',5e-12);

right = r.windows.backwardAnchorIndex(j);
rightValues = windowValues(testCase.TestData.data, ...
    r.anchors.startIndex(right),nWindow);
backwardReference = cvcoco9B( ...
    [syntheticDepth,[validationValues;rightValues]], ...
    testCase.TestData.orbit9,testCase.TestData.pad, ...
    r.srGrid(1),r.srGrid(end),r.srGrid(2)-r.srGrid(1),0,0, ...
    'Pearson','MaxFrequency',testCase.TestData.maxFrequency, ...
    'Seed',testCase.TestData.seed);
verifyEqual(testCase,r.backward.rho(:,j), ...
    backwardReference.validateBtoA.curve,'AbsTol',5e-12);
verifyEqual(testCase,r.anchors.bestRate(right), ...
    backwardReference.trainB.bestRate,'AbsTol',0);
verifyEqual(testCase,r.anchors.groupWeights(:,right), ...
    backwardReference.trainB.groupNormalized,'AbsTol',5e-12);
end

function testMonteCarloPlusOneSeedAndBatchReproducibility(testCase)
nsim = 4;
r1 = runCore(testCase,nsim,1);
r3 = runCore(testCase,nsim,3);

verifyEqual(testCase,r1.forward.rho,r3.forward.rho,'AbsTol',0);
verifyEqual(testCase,r1.backward.rho,r3.backward.rho,'AbsTol',0);
verifyEqual(testCase,r1.consensus.rho,r3.consensus.rho,'AbsTol',0);
verifyEqual(testCase,r1.forward.pGlobal,r3.forward.pGlobal,'AbsTol',0);
verifyEqual(testCase,r1.backward.pGlobal,r3.backward.pGlobal,'AbsTol',0);
verifyEqual(testCase,r1.consensus.pGlobal,r3.consensus.pGlobal,'AbsTol',0);
verifyEqual(testCase,r1.forward.pLocal,r3.forward.pLocal,'AbsTol',0);
verifyEqual(testCase,r1.backward.pLocal,r3.backward.pLocal,'AbsTol',0);
verifyEqual(testCase,r1.consensus.pLocal,r3.consensus.pLocal,'AbsTol',0);
verifyEqual(testCase,r1.rho,r1.consensus.rho,'AbsTol',0);
verifyEqual(testCase,r1.pGlobal,r1.consensus.pGlobal,'AbsTol',0);
verifyEqual(testCase,r1.pCOCO,r1.consensus.pCOCO,'AbsTol',0);
verifyEqual(testCase,r1.score,r1.consensus.score,'AbsTol',0);
verifyEqual(testCase,r1.score,r1.pCOCO,'AbsTol',0);
verifyEqual(testCase,r1.consensus.score,r1.consensus.pCOCO,'AbsTol',0);
verifyEqual(testCase,r1.scoreDefinition, ...
    ['pCOCO = consensus rho x abs(log10(consensus global p)); ', ...
     'no orbit-count weighting']);
verifyEqual(testCase,r1.monteCarlo.exceedanceGlobalForward, ...
    r3.monteCarlo.exceedanceGlobalForward);
verifyEqual(testCase,r1.monteCarlo.exceedanceGlobalBackward, ...
    r3.monteCarlo.exceedanceGlobalBackward);
verifyEqual(testCase,r1.monteCarlo.exceedanceGlobalConsensus, ...
    r3.monteCarlo.exceedanceGlobalConsensus);
verifyEqual(testCase,r1.monteCarlo.exceedanceLocalForward, ...
    r3.monteCarlo.exceedanceLocalForward);
verifyEqual(testCase,r1.monteCarlo.exceedanceLocalBackward, ...
    r3.monteCarlo.exceedanceLocalBackward);
verifyEqual(testCase,r1.monteCarlo.exceedanceLocalConsensus, ...
    r3.monteCarlo.exceedanceLocalConsensus);

verifyPlusOne(testCase,r1.forward.pGlobal, ...
    r1.monteCarlo.exceedanceGlobalForward,r1.forward.rho,nsim);
verifyPlusOne(testCase,r1.backward.pGlobal, ...
    r1.monteCarlo.exceedanceGlobalBackward,r1.backward.rho,nsim);
verifyPlusOne(testCase,r1.consensus.pGlobal, ...
    r1.monteCarlo.exceedanceGlobalConsensus,r1.consensus.rho,nsim);
verifyPlusOne(testCase,r1.forward.pLocal, ...
    r1.monteCarlo.exceedanceLocalForward,r1.forward.rho,nsim);
verifyPlusOne(testCase,r1.backward.pLocal, ...
    r1.monteCarlo.exceedanceLocalBackward,r1.backward.rho,nsim);
verifyPlusOne(testCase,r1.consensus.pLocal, ...
    r1.monteCarlo.exceedanceLocalConsensus,r1.consensus.rho,nsim);
verifyEqual(testCase,r1.pLocal,r1.consensus.pLocal,'AbsTol',0);
verifyTrue(testCase,all(isnan(r1.pParametric),'all'));

both = r1.windows.hasForward & r1.windows.hasBackward;
verifyEqual(testCase,r1.consensus.pDirectionalMax(:,both), ...
    max(r1.forward.pGlobal(:,both),r1.backward.pGlobal(:,both)), ...
    'AbsTol',0);
verifyEqual(testCase,r1.strictConsensus.pGlobal(:,both), ...
    r1.consensus.pGlobal(:,both),'AbsTol',0);
verifyTrue(testCase,all(isnan(r1.strictConsensus.pGlobal(:,~both)),'all'));
verifyEqual(testCase,r1.strictConsensus.pLocal(:,both), ...
    r1.consensus.pLocal(:,both),'AbsTol',0);
verifyTrue(testCase,all(isnan( ...
    r1.strictConsensus.pLocal(:,~both)),'all'));

% The function restores the caller's RNG state.
rng(919,'twister');
before = rng;
runCore(testCase,1,1);
after = rng;
verifyEqual(testCase,after,before);
end

function testTrainingRequiresNineButFrozenValidationAllowsPartial(testCase)
t = testCase.TestData;
r = ecocoCrossfitCore(t.data,t.orbit9,t.window,t.dt,t.step,0, ...
    t.pad,[4;10],0,'Pearson',t.maxFrequency,t.seed,0.5);

verifyTrue(testCase,r.geometry.trainingRateMask(1));
verifyFalse(testCase,r.geometry.trainingRateMask(2));
verifyTrue(testCase,r.geometry.validRateMask(2));
both = find(r.windows.hasForward & r.windows.hasBackward,1,'first');
verifyNotEmpty(testCase,both);
verifyTrue(testCase,isfinite(r.forward.rho(2,both)));
verifyGreaterThan(testCase,r.forward.nOrbit(2,both),0);
verifyLessThan(testCase,r.forward.nOrbit(2,both),9);
end

function testPartialTrainingFallbackReturnsAuditedNumerics(testCase)
t = testCase.TestData;
r = ecocoCrossfitCore(t.data,t.orbit9,t.window,t.dt,t.step,0, ...
    t.pad,10,2,'Pearson',t.maxFrequency,t.seed,0.5, ...
    'BatchSize',1,'ComputeLocalP',true, ...
    'WarnOnPartialTraining',false,'MemoryBudgetMiB',64);

verifyTrue(testCase,r.degradedMode);
verifyEqual(testCase,r.status,'complete-with-warning');
verifyEqual(testCase,r.warningIdentifier, ...
    'Acycle:BlockedECOCO:PartialOrbitTraining');
verifyFalse(testCase,any(r.geometry.strictTrainingRateMask));
verifyTrue(testCase,all(r.geometry.trainingRateMask));
verifyTrue(testCase,all(r.geometry.partialOnlyTrainingRateMask));
verifyGreaterThan(testCase,r.partialTrainingAnchorCount,0);
verifyGreaterThan(testCase,r.partialTrainingWindowCount,0);
verifyEqual(testCase,r.nsimCompleted,2);
verifyEqual(testCase,r.score,r.pCOCO,'AbsTol',0);
for directionName = {'forward','backward','consensus','strictConsensus'}
    direction = r.(directionName{1});
    verifyEqual(testCase,direction.score,direction.pCOCO,'AbsTol',0);
end
partialScore = isfinite(r.score) & isfinite(r.pCOCO) & ...
    r.nOrbit > 0 & r.nOrbit < numel(t.orbit9) & abs(r.pCOCO) > 1e-12;
verifyTrue(testCase,any(partialScore,'all'));
oldWeightedScore = r.pCOCO(partialScore).* ...
    r.nOrbit(partialScore)./numel(t.orbit9);
verifyGreaterThan(testCase,max(abs( ...
    r.score(partialScore)-oldWeightedScore)),1e-12);

for anchorIndex = find(r.anchors.valid(:))'
    inactive = ~r.anchors.trainingActiveGroupMask(anchorIndex,:)';
    verifyEqual(testCase,r.anchors.groupWeights(inactive,anchorIndex), ...
        zeros(nnz(inactive),1),'AbsTol',0);
end
supported = r.windows.hasForward | r.windows.hasBackward;
verifyTrue(testCase,all(isfinite(r.consensus.rho(:,supported)),'all'));
verifyTrue(testCase,all(isfinite(r.consensus.pGlobal(:,supported)),'all'));
end

function testPartialSolveSupportsSeveralInactiveGroups(testCase)
t = testCase.TestData;
r = ecocoCrossfitCore(t.data,t.orbit9,t.window,t.dt,t.step,0, ...
    t.pad,50,0,'Pearson',t.maxFrequency,t.seed,0.5, ...
    'WarnOnPartialTraining',false);

verifyTrue(testCase,r.degradedMode);
verifyTrue(testCase,all(r.geometry.trainingRateMask));
verifyGreaterThanOrEqual(testCase, ...
    max(sum(~r.anchors.trainingActiveGroupMask(r.anchors.valid,:),2)),2);
for anchorIndex = find(r.anchors.valid(:))'
    inactive = ~r.anchors.trainingActiveGroupMask(anchorIndex,:)';
    verifyEqual(testCase,r.anchors.groupWeights(inactive,anchorIndex), ...
        zeros(nnz(inactive),1),'AbsTol',0);
end
end

function testPaddedSeriesIncludesBothEndpointCentres(testCase)
t = testCase.TestData;
dt = 0.85;
depth = (0:dt:200)';
timeKyr = depth*100/10;
value = sin(2*pi*timeKyr/t.orbit9(1)) + ...
    0.3*cos(2*pi*timeKyr/71.3);
window = 121.5;
padded = zeropad2([depth,value],window,1);
r = ecocoCrossfitCore(padded,t.orbit9,window,dt,10,0,256, ...
    [5;10;15],0,'Pearson',t.maxFrequency,t.seed,0.5);

verifyEqual(testCase,r.depth(1),depth(1),'AbsTol',1e-10);
verifyEqual(testCase,r.depth(end),depth(end),'AbsTol',1e-9);
verifyEqual(testCase,r.anchors.centerDepth(1),depth(1),'AbsTol',1e-10);
verifyEqual(testCase,r.anchors.centerDepth(end),depth(end),'AbsTol',1e-9);
end

function r = runCore(testCase,nsim,batchSize)
t = testCase.TestData;
r = ecocoCrossfitCore(t.data,t.orbit9,t.window,t.dt,t.step,0, ...
    t.pad,t.srGrid,nsim,'Pearson',t.maxFrequency,t.seed,0.5, ...
    'BatchSize',batchSize,'ComputeLocalP',true, ...
    'MemoryBudgetMiB',64);
end

function values = windowValues(data,startIndex,nWindow)
values = data(startIndex:startIndex+nWindow-1,2);
end

function verifyPlusOne(testCase,p,count,rho,nsim)
valid = isfinite(rho);
verifyEqual(testCase,p(valid), ...
    (double(count(valid))+1)/(nsim+1),'AbsTol',0);
verifyGreaterThanOrEqual(testCase,min(p(valid)),1/(nsim+1));
gridPosition = p(valid)*(nsim+1);
verifyEqual(testCase,gridPosition,round(gridPosition),'AbsTol',4*eps);
end
