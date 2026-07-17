function tests = test_ecoco_crossfit_core
%TEST_ECOCO_CROSSFIT_CORE Cross-fitted eCOCO numerical invariants.
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
