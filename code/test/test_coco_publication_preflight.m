function tests = test_coco_publication_preflight
%TEST_COCO_PUBLICATION_PREFLIGHT Publication-preflight tests for COCO.
%
% These tests exercise the public four-group cvCOCO implementation and the
% exploratory Adaptive COCO implementation.  They intentionally emphasize
% invariants that affect scientific interpretation: complete-pipeline null
% replication, max-statistic p-values, physical period resolution, held-out
% report directionality, preprocessing, and reproducibility.

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
baseState = captureBaseVariables({'sr0','sim_spectum'});
testCase.addTeardown(@()restoreBaseVariables(baseState));

orbit9 = [405;125;100;95;82;41;23;22;19];
data = syntheticOrbitalSeries(orbit9);

testCase.TestData.repoRoot = repoRoot;
testCase.TestData.orbit9 = orbit9;
testCase.TestData.data = data;
testCase.TestData.dt = median(diff(data(:,1)));
testCase.TestData.padCv = 256;
testCase.TestData.padAdaptive = 512;
testCase.TestData.rateRange = [1,8,1];
testCase.TestData.maximumFrequency = 0.06;
testCase.TestData.nsim = 9;
testCase.TestData.cvSeed = 173;
testCase.TestData.adaptiveSeed = 271;

testCase.TestData.cv = runCv(testCase,0,testCase.TestData.nsim, ...
    testCase.TestData.cvSeed,3,testCase.TestData.maximumFrequency);
[corrCI,corrH0,corry,details] = runAdaptive( ...
    testCase,0,testCase.TestData.nsim,1, ...
    testCase.TestData.adaptiveSeed,testCase.TestData.maximumFrequency);
testCase.TestData.adaptive = struct('corrCI',corrCI,'corrH0',corrH0, ...
    'corry',corry,'details',details);
end

function testPublicDefaultAndCompatibilityNaming(testCase)
orbit9 = testCase.TestData.orbit9;
expectedAutomaticLimit = 1.2*max(1./orbit9);

cv = runCv(testCase,0,0,11,2,[]);
verifyEqual(testCase,cv.name,'Blocked cvCOCO');
verifyEqual(testCase,cv.publicName,'Blocked cvCOCO');
verifyEqual(testCase,cv.abbreviation,'B-cvCOCO');
verifyEqual(testCase,cv.targetModel,'four-group');
verifyEqual(testCase,cv.config.targetModel,'four-group');
verifyTrue(testCase,cv.config.maximumTemporalFrequencyWasDefault);
verifyEqual(testCase,cv.config.maximumTemporalFrequency, ...
    expectedAutomaticLimit,'RelTol',32*eps);

wrapped = cvcoco2(testCase.TestData.data,orbit9, ...
    testCase.TestData.padCv,1,8,1,0,0,'Pearson', ...
    'MaxFrequency',testCase.TestData.maximumFrequency,'Seed',11);
verifyEqual(testCase,wrapped.name,'Blocked cvCOCO');
verifyEqual(testCase,wrapped.publicName,'Blocked cvCOCO');
verifyEqual(testCase,wrapped.abbreviation,'B-cvCOCO');
verifyEqual(testCase,wrapped.targetModel,'four-group');
verifyEqual(testCase,wrapped.entryPoint,'cvcoco2 compatibility wrapper');

legacy = cvcocoLegacy(testCase.TestData.data,orbit9, ...
    testCase.TestData.padCv,1,8,1,0,0,'Pearson','Seed',11);
verifyEqual(testCase,legacy.name,'legacy cvCOCO');
verifyEqual(testCase,legacy.targetModel,'legacy');
verifyError(testCase,@()cocoConclusionReport('confirmatory',legacy), ...
    'cocoConclusionReport:LegacyTargetNotConfirmatory');

[~,~,~,adaptiveDetails] = runAdaptive(testCase,0,0,1,11,[]);
verifyEqual(testCase,adaptiveDetails.MaxFrequency, ...
    expectedAutomaticLimit,'RelTol',32*eps);
verifyEqual(testCase,adaptiveDetails.maxFrequency, ...
    expectedAutomaticLimit,'RelTol',32*eps);
expectedSr0 = expectedAutomaticLimit*100/(1/(2*testCase.TestData.dt));
verifyEqual(testCase,adaptiveDetails.sr0,expectedSr0,'RelTol',32*eps);
end

function testOrbitResourcesAreIndependentOfCurrentFolder(testCase)
startingFolder = pwd;
cleanup = onCleanup(@()cd(startingFolder));
cd(tempdir);
orbit = calculate_orbit9(210);
verifySize(testCase,orbit,[9 2]);
verifyTrue(testCase,all(isfinite(orbit),'all'));
verifyTrue(testCase,all(orbit(:,2) > 0));
clear cleanup
cd(startingFolder);
end

function testMaximumFrequencyControlsActualCvDiagnostics(testCase)
cv = testCase.TestData.cv;
limit = testCase.TestData.maximumFrequency;
verifyEqual(testCase,cv.config.maximumTemporalFrequency,limit);
verifyFalse(testCase,cv.config.maximumTemporalFrequencyWasDefault);

diagnostics = {cv.spectra.trainA,cv.spectra.trainB, ...
    cv.spectra.validateAtoB,cv.spectra.validateBtoA};
expectedRho = [cv.trainA.bestCorrelation,cv.trainB.bestCorrelation, ...
    cv.validateAtoB.score,cv.validateBtoA.score];
for ii = 1:numel(diagnostics)
    diagnostic = diagnostics{ii};
    verifyNotEmpty(testCase,diagnostic.frequency);
    verifyEqual(testCase,numel(diagnostic.frequency), ...
        numel(diagnostic.dataPower));
    verifyEqual(testCase,numel(diagnostic.frequency), ...
        numel(diagnostic.targetPower));
    verifyLessThanOrEqual(testCase,max(diagnostic.frequency), ...
        limit+128*eps(max(1,limit)));
    rho = corr(diagnostic.dataPower,diagnostic.targetPower, ...
        'Type','Pearson','Rows','complete');
    verifyEqual(testCase,rho,expectedRho(ii),'AbsTol',2e-11);
end
verifyEqual(testCase,cv.config.spectralDiagnosticUnits, ...
    'temporal PSD; spatial PSD multiplied by 100/sedimentation rate');
expectedAdaptiveSr0 = limit*100/(1/(2*testCase.TestData.dt));
verifyEqual(testCase,testCase.TestData.adaptive.details.sr0, ...
    expectedAdaptiveSr0,'RelTol',32*eps);

tooLow = max(1./testCase.TestData.orbit9)-1e-4;
args = cvArguments(testCase,0,0);
verifyError(testCase,@()cvcoco(args{:},'MaxFrequency',tooLow), ...
    'cvcoco:MaximumFrequencyExcludesOrbit');
verifyError(testCase,@()adaptiveCall( ...
    testCase.TestData.data,testCase.TestData.orbit9, ...
    testCase.TestData.padAdaptive,0,0,1,19,tooLow), ...
    'corrcoefslices_rankNew:MaximumFrequencyExcludesOrbit');
end

function testCvRngRestorationReproducibilityAndBatchInvariance(testCase)
rng(918273,'twister');
stateBefore = rng;
expectedNext = rand(1,8);
rng(stateBefore);

repeated = runCv(testCase,0,testCase.TestData.nsim, ...
    testCase.TestData.cvSeed,1,testCase.TestData.maximumFrequency);
actualNext = rand(1,8);
verifyEqual(testCase,actualNext,expectedNext,'AbsTol',0);

reference = testCase.TestData.cv;
verifyEqual(testCase,repeated.nullSymmetric,reference.nullSymmetric, ...
    'AbsTol',2e-13);
verifyEqual(testCase,repeated.nullAtoB,reference.nullAtoB,'AbsTol',2e-13);
verifyEqual(testCase,repeated.nullBtoA,reference.nullBtoA,'AbsTol',2e-13);
verifyEqual(testCase,repeated.nullBestRateAtoB, ...
    reference.nullBestRateAtoB,'AbsTol',0);
verifyEqual(testCase,repeated.nullBestRateBtoA, ...
    reference.nullBestRateBtoA,'AbsTol',0);
verifyEqual(testCase,repeated.pCurveAtoB,reference.pCurveAtoB, ...
    'AbsTol',0);
verifyEqual(testCase,repeated.pCurveBtoA,reference.pCurveBtoA, ...
    'AbsTol',0);
verifyEqual(testCase,repeated.pLocalCurveAtoB, ...
    reference.pLocalCurveAtoB,'AbsTol',0);
verifyEqual(testCase,repeated.pLocalCurveBtoA, ...
    reference.pLocalCurveBtoA,'AbsTol',0);
verifyEqual(testCase,repeated.localExceedanceCountAtoB, ...
    reference.localExceedanceCountAtoB,'AbsTol',0);
verifyEqual(testCase,repeated.localExceedanceCountBtoA, ...
    reference.localExceedanceCountBtoA,'AbsTol',0);
end

function testAdaptiveRngRestorationReproducibilityAndBatchInvariance(testCase)
rng(192837,'twister');
stateBefore = rng;
expectedNext = rand(1,8);
rng(stateBefore);

[corrCI,corrH0,corry,details] = runAdaptive( ...
    testCase,0,testCase.TestData.nsim,1, ...
    testCase.TestData.adaptiveSeed,testCase.TestData.maximumFrequency);
actualNext = rand(1,8);
verifyEqual(testCase,actualNext,expectedNext,'AbsTol',0);

reference = testCase.TestData.adaptive;
verifyEqual(testCase,corrCI,reference.corrCI,'AbsTol',0);
verifyEqual(testCase,corrH0,reference.corrH0,'AbsTol',0);
verifyEqual(testCase,corry,reference.corry,'AbsTol',0);
verifyEqual(testCase,details.nullMax,reference.details.nullMax,'AbsTol',0);
verifyEqual(testCase,details.seed,testCase.TestData.adaptiveSeed);

data = testCase.TestData.data;
rng(4721,'twister');
[f1,p1] = redNoisePeriodogramMC(data,0.45,7,0,256, ...
    'Slices',2,'BatchSize',1,'UseParallel',false);
rng(4721,'twister');
[f2,p2] = redNoisePeriodogramMC(data,0.45,7,0,256, ...
    'Slices',2,'BatchSize',4,'UseParallel',false);
verifyEqual(testCase,f2,f1,'AbsTol',0);
verifyEqual(testCase,p2,p1,'RelTol',5e-13,'AbsTol',1e-14);
end

function testAllBackgroundModesSmoke(testCase)
smokeNsim = 2;
for red = 0:3
    cv = runCv(testCase,red,smokeNsim,31+red,2, ...
        testCase.TestData.maximumFrequency);
    verifyGreaterThan(testCase,nnz(isfinite(cv.trainA.curve)),0, ...
        sprintf('cvCOCO red=%d training curve is entirely nonfinite.',red));
    verifyGreaterThan(testCase,nnz(isfinite(cv.validateAtoB.curve)),0, ...
        sprintf('cvCOCO red=%d validation curve is entirely nonfinite.',red));
    verifyEqual(testCase,cv.config.red,red);
    verifyEqual(testCase,cv.nsimValid,smokeNsim);
    verifyTrue(testCase,all(isfinite(cv.nullSymmetric)));

    [corrCI,corrH0,corry,details] = runAdaptive( ...
        testCase,red,smokeNsim,1,31+red, ...
        testCase.TestData.maximumFrequency);
    verifyGreaterThan(testCase,nnz(isfinite(corrCI(:,2))),0, ...
        sprintf('Adaptive COCO red=%d curve is entirely nonfinite.',red));
    verifyTrue(testCase,all(isfinite(corrH0(:,2))));
    verifySize(testCase,corry,[numel(corrCI(:,1)),smokeNsim]);
    verifyTrue(testCase,all(isfinite(corry(isfinite(corrCI(:,2)),:)),'all'));
    verifyEqual(testCase,details.nSimValid,smokeNsim);
    verifyEqual(testCase,details.red,red);
end
end

function testRobustRedNoiseFrequencyUnitScaling(testCase)
n = 256;
dt1 = 0.08;
sample = (0:n-1)';
x = sin(2*pi*sample/29)+0.55*cos(2*pi*sample/11) ...
    +0.25*sin(2*pi*sample/67+0.4);
x = detrend(x,1);
[p1,f1] = periodogram(x,[],n,1/dt1);
background1 = redconf_any(2*pi*f1*dt1,p1,dt1,0.25,2);

unitScale = 10;
dt2 = unitScale*dt1;
[p2,f2] = periodogram(x,[],n,1/dt2);
background2 = redconf_any(2*pi*f2*dt2,p2,dt2,0.25,2);

verifyTrue(testCase,all(isfinite(background1)));
verifyTrue(testCase,all(isfinite(background2)));
verifyEqual(testCase,f2,f1/unitScale,'RelTol',2e-13,'AbsTol',1e-14);
verifyEqual(testCase,p2,unitScale*p1,'RelTol',2e-12,'AbsTol',1e-12);
verifyEqual(testCase,background2,unitScale*background1, ...
    'RelTol',5e-11,'AbsTol',1e-10);

% The two public paths must also be invariant when the depth unit and the
% tested sedimentation rates are rescaled together.  This fails if the
% robust-background routine receives cycles/depth instead of rad/sample.
data1 = testCase.TestData.data;
data2 = data1;
data2(:,1) = unitScale*data2(:,1);
orbit9 = testCase.TestData.orbit9;
limit = testCase.TestData.maximumFrequency;
cv1 = cvcoco(data1,orbit9,testCase.TestData.padCv,2,6,2,2,0, ...
    'Pearson','MaxFrequency',limit,'Seed',91);
cv2 = cvcoco(data2,orbit9,testCase.TestData.padCv,20,60,20,2,0, ...
    'Pearson','MaxFrequency',limit,'Seed',91);
verifyEqual(testCase,cv2.srGrid,unitScale*cv1.srGrid,'AbsTol',1e-13);
verifyEqual(testCase,cv2.trainA.curve,cv1.trainA.curve,'AbsTol',2e-10);
verifyEqual(testCase,cv2.validateAtoB.curve, ...
    cv1.validateAtoB.curve,'AbsTol',2e-10);

dt = testCase.TestData.dt;
[adaptive1,h01] = corrcoefslices_rankNew( ...
    data1,orbit9,dt,testCase.TestData.padAdaptive,2,6,2,0,2,0, ...
    0,1,'Pearson',1/(2*dt),0,false,'adaptive', ...
    'MaxFrequency',limit,'Seed',91,'ShowPeriodograms',false);
[adaptive2,h02] = corrcoefslices_rankNew( ...
    data2,orbit9,unitScale*dt,testCase.TestData.padAdaptive, ...
    20,60,20,0,2,0,0,1,'Pearson',1/(2*unitScale*dt),0,false, ...
    'adaptive','MaxFrequency',limit,'Seed',91, ...
    'ShowPeriodograms',false);
verifyEqual(testCase,adaptive2(:,1),unitScale*adaptive1(:,1), ...
    'AbsTol',1e-13);
verifyEqual(testCase,adaptive2(:,2),adaptive1(:,2),'AbsTol',2e-10);
verifyEqual(testCase,h02(:,2),h01(:,2));
end

function testRobustRedOptimizationMatchesLegacyDiscreteSearch(testCase)
x = sin((1:73)'*0.31)+0.17*cos((1:73)'*0.07);
for width = [4,5,18,19]
    verifyEqual(testCase,moveMedian(x,width), ...
        legacyMoveMedianReference(x,width), ...
        'AbsTol',4*eps(max(abs(x))));
end

fn = 0.5;
frequency = linspace(0,fn,65)';
power = 0.4+1./(1+18*frequency)+0.03*sin(31*frequency).^2;
smoothed = moveMedian(power,round(0.25*numel(power)));
s0 = mean(smoothed);
[rhoOptimized,scaleOptimized] = minirhos0( ...
    s0,fn,frequency,smoothed,2);
[rhoReference,scaleReference] = legacyMinirhos0Reference( ...
    s0,fn,frequency,smoothed,2);
verifyEqual(testCase,rhoOptimized,rhoReference,'AbsTol',0);
verifyEqual(testCase,scaleOptimized,scaleReference,'AbsTol',0);
end

function testSpecswaQuietOptionUsedByPublicRed3Paths(testCase)
frequency = linspace(0,0.5,129)';
logPower = log10(0.2+1./(1+25*frequency));
commandText = evalc( ...
    'specswa(frequency,logPower,256,false);');
verifyEmpty(testCase,strtrim(commandText));
[background,selectedWindow] = specswa(frequency,logPower,256,false);
verifySize(testCase,background,size(frequency));
verifyTrue(testCase,all(isfinite(background) & background > 0));
verifyTrue(testCase,isfinite(selectedWindow) && selectedWindow >= 11);

% Regression cases for the lexicographic reversal/RMSE selector. The old
% ndata initialization could reject every candidate when zero padding made
% the spectrum much longer than the input record.
longFrequency = linspace(0,1,513)';
increasingLogPower = longFrequency;
[increasingBackground,increasingWindow] = specswa( ...
    longFrequency,increasingLogPower,64,false);
verifySize(testCase,increasingBackground,size(longFrequency));
verifyTrue(testCase,all(isfinite(increasingBackground) & ...
    increasingBackground > 0));
verifyTrue(testCase,isfinite(increasingWindow));

counterexample = -log1p(5*longFrequency) + ...
    0.01*sin((0:512)'*0.15);
[counterexampleBackground,counterexampleWindow,counterexampleDiagnostics] = specswa( ...
    longFrequency,counterexample,64,false);
verifyTrue(testCase,all(isfinite(counterexampleBackground) & ...
    counterexampleBackground > 0));
verifyEqual(testCase,counterexampleDiagnostics.selectedWindow, ...
    counterexampleWindow);
verifyEqual(testCase,counterexampleDiagnostics.initialVariant,1);
verifyEqual(testCase,counterexampleDiagnostics.initialNondecreasingCount,0);
verifyTrue(testCase,isfinite(counterexampleDiagnostics.initialRMSE));
end

function testFourGroupLeakageNnlsExactRecovery(testCase)
mixing = [1.00 0.12 0.04 0.01; ...
          0.08 0.95 0.07 0.02; ...
          0.02 0.09 1.10 0.08; ...
          0.01 0.03 0.11 0.90];
truth = [1.2 0 2.1e250; ...
         0.7 0 0; ...
         0.0 0 1.4e250; ...
         0.4 0 0.8e250];
energy = mixing*truth;
[estimated,residual] = cocoNonnegativeLeakageSolve(mixing,energy);
verifyEqual(testCase,estimated,truth,'RelTol',2e-12,'AbsTol',1e-13);
verifyLessThanOrEqual(testCase,residual,1e-24*ones(size(residual)));
verifyGreaterThanOrEqual(testCase,estimated,zeros(size(estimated)));
end

function testCvSegmentSpecificNullAndLeakageAudit(testCase)
cv = testCase.TestData.cv;
verifyTrue(testCase,isfinite(cv.rhoMA) && abs(cv.rhoMA) < 1);
verifyTrue(testCase,isfinite(cv.rhoMB) && abs(cv.rhoMB) < 1);
verifyTrue(testCase,contains(cv.rhoMethodA,'conditional least-squares'));
verifyTrue(testCase,contains(cv.rhoMethodB,'conditional least-squares'));
verifyEqual(testCase,cv.rhoM,mean([cv.rhoMA,cv.rhoMB]),'AbsTol',0);
verifyTrue(testCase,contains(cv.config.nullConditioning,'independent'));
verifyTrue(testCase,contains(cv.config.rhoRule,'split boundary is excluded'));
verifyEqual(testCase,size(cv.trainA.groupLeakageMatrix),[4 4]);
verifyEqual(testCase,size(cv.trainB.groupLeakageMatrix),[4 4]);
verifyGreaterThanOrEqual(testCase,cv.trainA.groupLeakageRcond, ...
    cv.config.minimumLeakageMatrixRcond);
verifyGreaterThanOrEqual(testCase,cv.trainB.groupLeakageRcond, ...
    cv.config.minimumLeakageMatrixRcond);
verifyTrue(testCase,all(cv.groupLeakageRcondA(cv.trainingRateMaskA) >= ...
    cv.config.minimumLeakageMatrixRcond));
verifyTrue(testCase,all(cv.groupLeakageRcondB(cv.trainingRateMaskB) >= ...
    cv.config.minimumLeakageMatrixRcond));

report = cocoConclusionReport('confirmatory',cv);
verifyTrue(testCase,contains(report.nullHypothesis,'its own fitted'));
verifyEqual(testCase,report.rhoA,cv.rhoMA);
verifyEqual(testCase,report.rhoB,cv.rhoMB);
verifyTrue(testCase,contains(report.directionalPInterpretation,'joint null'));
verifyEqual(testCase,report.pSymExceedanceProbabilityInterval, ...
    cv.pSymConfidenceInterval);
end

function testCvTrainingMaskPaddingInvariant(testCase)
data = testCase.TestData.data;
orbit9 = testCase.TestData.orbit9;
limit = testCase.TestData.maximumFrequency;
smallPad = cvcoco(data,orbit9,256,1,8,1,0,0,'Pearson', ...
    'MaxFrequency',limit,'Seed',41);
largePad = cvcoco(data,orbit9,512,1,8,1,0,0,'Pearson', ...
    'MaxFrequency',limit,'Seed',41);
verifyEqual(testCase,largePad.crossGroupBandOverlapA, ...
    smallPad.crossGroupBandOverlapA);
verifyEqual(testCase,largePad.crossGroupBandOverlapB, ...
    smallPad.crossGroupBandOverlapB);
verifyEqual(testCase,largePad.trainingRateMaskA,smallPad.trainingRateMaskA);
verifyEqual(testCase,largePad.trainingRateMaskB,smallPad.trainingRateMaskB);
verifyTrue(testCase,any(smallPad.trainingRateMaskA));
verifyTrue(testCase,any(smallPad.trainingRateMaskB));
end

function testAdaptiveDiagnosticUsesAuditedTarget(testCase)
data = testCase.TestData.data;
pad = testCase.TestData.padAdaptive;
dt = testCase.TestData.dt;
fs = 1/dt;
[power,frequency] = periodogram(detrend(data(:,2),1),[],pad,fs);
targetFrequency = (0:floor(pad/2))'./pad;
rayleigh = 1/(size(data,1)*dt);
limit = testCase.TestData.maximumFrequency;
sr0 = limit*100/(1/(2*dt));
for rate = [1,sr0,4]
    [rho,~,missing,diagnostic] = cocoAdaptiveEvaluate( ...
        power,data,pad,frequency,targetFrequency,testCase.TestData.orbit9, ...
        rayleigh,rate,sr0,'Pearson','RateBounds',[rate rate], ...
        'MaxFrequency',limit);
    expectedFrequency = frequency*rate/100;
    expectedMask = expectedFrequency <= ...
        limit+64*eps(max(1,limit));
    verifyEqual(testCase,diagnostic.rate,rate);
    verifyEqual(testCase,diagnostic.frequency, ...
        expectedFrequency(expectedMask),'AbsTol',2e-14);
    verifyEqual(testCase,diagnostic.dataPower,power(expectedMask), ...
        'AbsTol',0);
    verifyLessThanOrEqual(testCase,max(diagnostic.frequency), ...
        limit+64*eps(max(1,limit)));
    verifyEqual(testCase,nnz(diagnostic.activeOrbit),9-missing);
    verifyEqual(testCase,corr(diagnostic.targetPower,diagnostic.dataPower, ...
        'Rows','complete'),rho,'AbsTol',2e-12);
    verifyTrue(testCase,all( ...
        diagnostic.amplitudes(~diagnostic.activeOrbit) == 0));
end

% TARGETFREQUENCY and SR0 are retained only as positional compatibility
% arguments.  They must not change the audited native-grid inference.
rate = 4;
[rhoReference,pReference,missingReference,diagnosticReference] = ...
    cocoAdaptiveEvaluate(power,data,pad,frequency,[], ...
    testCase.TestData.orbit9,rayleigh,rate,0,'Pearson', ...
    'RateBounds',[rate rate],'MaxFrequency',limit);
[rhoPlaceholder,pPlaceholder,missingPlaceholder,diagnosticPlaceholder] = ...
    cocoAdaptiveEvaluate(power,data,pad,frequency,[NaN;Inf], ...
    testCase.TestData.orbit9,rayleigh,rate,-123,'Pearson', ...
    'RateBounds',[rate rate],'MaxFrequency',limit);
verifyEqual(testCase,rhoPlaceholder,rhoReference,'AbsTol',0);
verifyEqual(testCase,pPlaceholder,pReference,'AbsTol',0);
verifyEqual(testCase,missingPlaceholder,missingReference,'AbsTol',0);
verifyEqual(testCase,diagnosticPlaceholder.frequency, ...
    diagnosticReference.frequency,'AbsTol',0);
verifyEqual(testCase,diagnosticPlaceholder.targetPower, ...
    diagnosticReference.targetPower,'AbsTol',0);
end

function testInvalidScientificInputsFailExplicitly(testCase)
duplicateOrbit = testCase.TestData.orbit9;
duplicateOrbit(2) = duplicateOrbit(3);
data = testCase.TestData.data;
verifyError(testCase,@()cvcoco(data,duplicateOrbit,256,1,8,1,0,0, ...
    'Pearson'),'cvcoco:DuplicateOrbitPeriods');

dt = testCase.TestData.dt;
verifyError(testCase,@()corrcoefslices_rankNew( ...
    data,duplicateOrbit,dt,512,1,8,1,0,0,0,0,1,'Pearson', ...
    1/(2*dt),0,false,'adaptive','ShowPeriodograms',false), ...
    'corrcoefslices_rankNew:DuplicateOrbitPeriods');

constantData = data;
constantData(:,2) = 7;
verifyError(testCase,@()cvcoco(constantData,testCase.TestData.orbit9, ...
    256,1,8,1,0,0,'Pearson'), 'cvcoco:ZeroVariance');

affineData = data;
affineData(:,2) = 7+3*affineData(:,1);
verifyError(testCase,@()cvcoco(affineData,testCase.TestData.orbit9, ...
    256,1,8,1,0,0,'Pearson'),'cvcoco:ZeroVariance');
verifyError(testCase,@()corrcoefslices_rankNew( ...
    affineData,testCase.TestData.orbit9,dt,512,1,8,1,0,0,0,0,1, ...
    'Pearson',1/(2*dt),0,false,'adaptive','ShowPeriodograms',false), ...
    'corrcoefslices_rankNew:ConstantData');

largeOffsetAffine = affineData;
largeOffsetAffine(:,2) = 1e12+3*largeOffsetAffine(:,1);
verifyError(testCase,@()cvcoco(largeOffsetAffine, ...
    testCase.TestData.orbit9,256,1,8,1,0,0,'Pearson'), ...
    'cvcoco:ZeroVariance');
verifyError(testCase,@()corrcoefslices_rankNew( ...
    largeOffsetAffine,testCase.TestData.orbit9,dt,512,1,8,1,0,0,0, ...
    0,2,'Pearson',1/(2*dt),0,false,'adaptive', ...
    'ShowPeriodograms',false), ...
    'corrcoefslices_rankNew:ConstantData');

verifyError(testCase,@()corrcoefslices_rankNew( ...
    data,testCase.TestData.orbit9,dt,512,1,8,1,0,0,0,0, ...
    floor(size(data,1)/4)+1,'Pearson',1/(2*dt),0,false,'adaptive', ...
    'ShowPeriodograms',false),'corrcoefslices_rankNew:TooManySlices');
end

function testScaleAwareDetrendedVarianceResolution(testCase)
sample = (0:200)';
affine = 1000+3*sample;
verifyFalse(testCase,cocoResolvedDetrendedVariance( ...
    affine,detrend(affine,1)));

largeAffine = 1e12+3*sample;
verifyFalse(testCase,cocoResolvedDetrendedVariance( ...
    largeAffine,detrend(largeAffine,1)));

resolvedSignal = affine+1e-8*sin(2*pi*sample/17);
[resolved,~,relativeRms,tolerance] = ...
    cocoResolvedDetrendedVariance( ...
    resolvedSignal,detrend(resolvedSignal,1));
verifyTrue(testCase,resolved);
verifyGreaterThan(testCase,relativeRms,tolerance);

scale = 1e100;
[resolvedScaled,~,relativeScaled,toleranceScaled] = ...
    cocoResolvedDetrendedVariance( ...
    scale*resolvedSignal,detrend(scale*resolvedSignal,1));
verifyTrue(testCase,resolvedScaled);
verifyGreaterThan(testCase,relativeScaled,toleranceScaled);
verifyEqual(testCase,relativeScaled,relativeRms,'RelTol',2e-4);

largeScale = 1e12;
nearTrend = largeScale+3*sample;
belowResolution = nearTrend+8*eps(largeScale)* ...
    sin(2*pi*sample/17);
aboveResolution = nearTrend+4096*eps(largeScale)* ...
    sin(2*pi*sample/17);
verifyFalse(testCase,cocoResolvedDetrendedVariance( ...
    belowResolution,detrend(belowResolution,1)));
verifyTrue(testCase,cocoResolvedDetrendedVariance( ...
    aboveResolution,detrend(aboveResolution,1)));
end

function testSpearmanPublicPathsSmoke(testCase)
data = testCase.TestData.data;
orbit9 = testCase.TestData.orbit9;
limit = testCase.TestData.maximumFrequency;
cv = cvcoco(data,orbit9,testCase.TestData.padCv,2,6,2,0,2, ...
    'Spearman','MaxFrequency',limit,'Seed',102,'BatchSize',2);
verifyGreaterThan(testCase,nnz(isfinite(cv.trainA.curve)),0);
verifyTrue(testCase,all(isfinite(cv.nullSymmetric)));
verifyEqual(testCase,cv.config.method,'Spearman');

dt = testCase.TestData.dt;
[corrCI,corrH0,corry,details] = corrcoefslices_rankNew( ...
    data,orbit9,dt,testCase.TestData.padAdaptive,2,6,2,0,0,2, ...
    0,1,'Spearman',1/(2*dt),0,false,'adaptive', ...
    'MaxFrequency',limit,'Seed',102,'ShowPeriodograms',false);
verifyGreaterThan(testCase,nnz(isfinite(corrCI(:,2))),0);
verifyTrue(testCase,all(isfinite(corrH0(:,[1,3])),'all'));
verifyTrue(testCase,all(isfinite(corry),'all'));
verifyEqual(testCase,details.method,'Spearman');
end

function testCvSortDeduplicateAndMedianInterpolation(testCase)
data = testCase.TestData.data;
data(77,1) = data(77,1)+0.027;
data(422,1) = data(422,1)-0.019;
duplicateIndex = 201;
duplicate = data(duplicateIndex,:);
duplicate(2) = duplicate(2)+2;
inputData = flipud([data;duplicate;NaN,NaN]);

commandText = evalc([ ...
    'cv = cvcoco(inputData,testCase.TestData.orbit9,', ...
    'testCase.TestData.padCv,1,8,1,0,0,''Pearson'',', ...
    '''MaxFrequency'',testCase.TestData.maximumFrequency,''Seed'',53);']);

finiteInput = inputData(all(isfinite(inputData),2),:);
verifyEqual(testCase,size(cv.dataClean,1), ...
    numel(unique(finiteInput(:,1))));
verifyTrue(testCase,all(diff(cv.dataClean(:,1)) > 0));
duplicateDepth = data(duplicateIndex,1);
cleanIndex = find(cv.dataClean(:,1) == duplicateDepth,1);
verifyNotEmpty(testCase,cleanIndex);
verifyEqual(testCase,cv.dataClean(cleanIndex,2), ...
    data(duplicateIndex,2)+1,'AbsTol',2e-14);
verifyTrue(testCase,cv.interpolationA.applied);
verifyTrue(testCase,cv.interpolationB.applied);
verifyTrue(testCase,contains(commandText, ...
    'uneven depth spacing detected in Segment A'));
verifyTrue(testCase,contains(commandText, ...
    'uneven depth spacing detected in Segment B'));
verifyTrue(testCase,contains(commandText,'Interpolation method'));
verifyTrue(testCase,contains(commandText,'Interpolation interval'));
verifyUniformHalf(testCase,cv.dataA,cv.samplingIntervalA);
verifyUniformHalf(testCase,cv.dataB,cv.samplingIntervalB);
end

function testAdaptiveSlicesOneAndTwoUseFiniteFullPipelineNull(testCase)
for slices = [1,2]
    [corrCI,corrH0,corry,details] = runAdaptive( ...
        testCase,0,7,slices,881+slices, ...
        testCase.TestData.maximumFrequency);
    validRate = isfinite(corrCI(:,2));
    verifyTrue(testCase,any(validRate));
    verifyTrue(testCase,all(isfinite(corry(validRate,:)),'all'));
    verifyTrue(testCase,all(isfinite(corrH0(validRate,[1,3])),'all'));
    verifyEqual(testCase,size(corry,2),7);
    verifyEqual(testCase,details.slices,slices);
    verifyEqual(testCase,details.nSimRequested,7);
    verifyEqual(testCase,details.nsimRequested,7);
    verifyEqual(testCase,details.nSimCompleted,7);
    verifyEqual(testCase,details.nsimCompleted,7);
    verifyEqual(testCase,details.nSimValid,7);
    verifyEqual(testCase,details.nsimValid,7);
    verifyEqual(testCase,details.mcSpectrumBatchSize,7);
    verifyEqual(testCase,details.pFloor,1/8);
    verifyEqual(testCase,details.nullMax,max(corry(validRate,:),[],1)', ...
        'AbsTol',2e-14);
end
end

function testOrbitOrderDoesNotChangeParticipation(testCase)
permutation = [9,3,1,7,5,2,6,4,8];
permutedOrbit = testCase.TestData.orbit9(permutation);
cvReference = testCase.TestData.cv;
cvPermuted = cvcoco(testCase.TestData.data,permutedOrbit, ...
    testCase.TestData.padCv,1,8,1,0,0,'Pearson', ...
    'MaxFrequency',testCase.TestData.maximumFrequency,'Seed',67);
verifyEqual(testCase,cvPermuted.orbitCountA,cvReference.orbitCountA);
verifyEqual(testCase,cvPermuted.orbitCountB,cvReference.orbitCountB);
verifyEqual(testCase,cvPermuted.resolvableGroupCountA, ...
    cvReference.resolvableGroupCountA);
verifyEqual(testCase,cvPermuted.resolvableGroupCountB, ...
    cvReference.resolvableGroupCountB);
verifyEqual(testCase,cvPermuted.trainA.curve,cvReference.trainA.curve, ...
    'AbsTol',5e-12);
verifyEqual(testCase,cvPermuted.validateAtoB.curve, ...
    cvReference.validateAtoB.curve,'AbsTol',5e-12);

[corrReference,h0Reference] = runAdaptive( ...
    testCase,0,0,1,67,testCase.TestData.maximumFrequency);
[corrPermuted,h0Permuted] = adaptiveCall( ...
    testCase.TestData.data,permutedOrbit,testCase.TestData.padAdaptive, ...
    0,0,1,67,testCase.TestData.maximumFrequency);
verifyEqual(testCase,corrPermuted(:,4),corrReference(:,4));
verifyEqual(testCase,h0Permuted(:,2),h0Reference(:,2));
verifyEqual(testCase,corrPermuted(:,2),corrReference(:,2), ...
    'AbsTol',5e-12);
end

function testUnresolvedPeriodsAreCountedAndExcluded(testCase)
orbit9 = testCase.TestData.orbit9;
cv = testCase.TestData.cv;
expectedA = physicalOrbitCount(orbit9,cv.srGrid, ...
    cv.samplingIntervalA,size(cv.dataA,1), ...
    testCase.TestData.maximumFrequency);
expectedB = physicalOrbitCount(orbit9,cv.srGrid, ...
    cv.samplingIntervalB,size(cv.dataB,1), ...
    testCase.TestData.maximumFrequency);
verifyEqual(testCase,cv.orbitCountA,expectedA);
verifyEqual(testCase,cv.orbitCountB,expectedB);
verifyTrue(testCase,any(cv.orbitCountA > 0 & cv.orbitCountA < 9));
verifyTrue(testCase,any(cv.orbitCountB > 0 & cv.orbitCountB < 9));

[corrCI,corrH0] = runAdaptive( ...
    testCase,0,0,1,73,testCase.TestData.maximumFrequency);
expectedAdaptive = physicalOrbitCount(orbit9,corrCI(:,1), ...
    testCase.TestData.dt,size(testCase.TestData.data,1), ...
    testCase.TestData.maximumFrequency);
verifyLessThanOrEqual(testCase,corrH0(:,2),expectedAdaptive);
verifyEqual(testCase,9-corrCI(:,4),corrH0(:,2));

% At 1 cm/kyr the 19-kyr component lies above the data Nyquist.  The full
% target must therefore give the same statistic as a target in which that
% component was never supplied.
data = testCase.TestData.data;
pad = testCase.TestData.padAdaptive;
fs = 1/testCase.TestData.dt;
[power,frequency] = periodogram(detrend(data(:,2),1),[],pad,fs);
targetFrequency = (0:floor(pad/2))'./pad;
rayleigh = 1/(size(data,1)*testCase.TestData.dt);
sr0 = testCase.TestData.maximumFrequency*100/frequency(end);
[rhoFull,pFull,missingFull] = cocoAdaptiveEvaluate( ...
    power,data,pad,frequency,targetFrequency,orbit9,rayleigh,1,sr0, ...
    'Pearson','RateBounds',[1,1], ...
    'MaxFrequency',testCase.TestData.maximumFrequency);
reducedOrbit = orbit9(orbit9 ~= 19);
[rhoReduced,pReduced,missingReduced] = cocoAdaptiveEvaluate( ...
    power,data,pad,frequency,targetFrequency,reducedOrbit,rayleigh,1,sr0, ...
    'Pearson','RateBounds',[1,1], ...
    'MaxFrequency',testCase.TestData.maximumFrequency);
verifyEqual(testCase,missingFull,1);
verifyEqual(testCase,missingReduced,0);
verifyEqual(testCase,rhoFull,rhoReduced,'AbsTol',2e-13);
verifyEqual(testCase,pFull,pReduced,'AbsTol',2e-13);
end

function testMonteCarloPlusOneAndGlobalLocalOrdering(testCase)
adaptive = testCase.TestData.adaptive;
n = testCase.TestData.nsim;
valid = isfinite(adaptive.corrCI(:,2));
globalP = adaptive.corrH0(valid,1);
localP = adaptive.corrH0(valid,3);
verifyGreaterThanOrEqual(testCase,globalP,localP-32*eps);
verifyGreaterThanOrEqual(testCase,globalP,ones(size(globalP))/(n+1));
verifyGreaterThanOrEqual(testCase,localP,ones(size(localP))/(n+1));
verifyMonteCarloGrid(testCase,globalP,n);
verifyMonteCarloGrid(testCase,localP,n);
verifyEqual(testCase,adaptive.details.nullMax, ...
    max(adaptive.corry(valid,:),[],1)','AbsTol',2e-14);

cv = testCase.TestData.cv;
verifyEqual(testCase,cv.pSym,plusOneP(cv.nullSymmetric, ...
    cv.scoreSymmetric),'AbsTol',0);
verifyEqual(testCase,cv.pAtoB,plusOneP(cv.nullAtoB, ...
    cv.validateAtoB.score),'AbsTol',0);
verifyEqual(testCase,cv.pBtoA,plusOneP(cv.nullBtoA, ...
    cv.validateBtoA.score),'AbsTol',0);
verifyEqual(testCase,cv.pConsensus,plusOneP(cv.nullConsensus, ...
    cv.scoreConsensus),'AbsTol',0);
verifyMonteCarloGrid(testCase, ...
    [cv.pSym;cv.pA;cv.pB;cv.pConsensus],n);

expectedConsensus = nan(size(cv.srGrid));
bothFinite = isfinite(cv.validateAtoB.curve) & ...
    isfinite(cv.validateBtoA.curve);
expectedConsensus(bothFinite) = min( ...
    cv.validateAtoB.curve(bothFinite), ...
    cv.validateBtoA.curve(bothFinite));
verifyEqual(testCase,cv.consensus.curve,expectedConsensus,'AbsTol',0);
for ii = 1:numel(cv.srGrid)
    if isfinite(cv.validateAtoB.curve(ii))
        verifyEqual(testCase,cv.pCurveAtoB(ii), ...
            plusOneP(cv.nullAtoB,cv.validateAtoB.curve(ii)), ...
            'AbsTol',0);
    end
    if isfinite(cv.validateBtoA.curve(ii))
        verifyEqual(testCase,cv.pCurveBtoA(ii), ...
            plusOneP(cv.nullBtoA,cv.validateBtoA.curve(ii)), ...
            'AbsTol',0);
    end
    if isfinite(expectedConsensus(ii))
        verifyEqual(testCase,cv.pCurveConsensus(ii), ...
            plusOneP(cv.nullConsensus,expectedConsensus(ii)), ...
            'AbsTol',0);
        verifyEqual(testCase,cv.pLocalCurveConsensus(ii), ...
            (cv.localExceedanceCountConsensus(ii)+1)/( ...
            cv.localValidCountConsensus(ii)+1),'AbsTol',0);
    end
end

validAtoB = isfinite(cv.validateAtoB.curve);
validBtoA = isfinite(cv.validateBtoA.curve);
verifyEqual(testCase,isfinite(cv.pLocalCurveAtoB),validAtoB);
verifyEqual(testCase,isfinite(cv.pLocalCurveBtoA),validBtoA);
verifyMonteCarloGrid(testCase,cv.pLocalCurveAtoB(validAtoB),n);
verifyMonteCarloGrid(testCase,cv.pLocalCurveBtoA(validBtoA),n);
verifyGreaterThanOrEqual(testCase,cv.pCurveAtoB(validAtoB), ...
    cv.pLocalCurveAtoB(validAtoB)-32*eps);
verifyGreaterThanOrEqual(testCase,cv.pCurveBtoA(validBtoA), ...
    cv.pLocalCurveBtoA(validBtoA)-32*eps);
verifyEqual(testCase,cv.localValidCountAtoB(validAtoB), ...
    n*ones(nnz(validAtoB),1));
verifyEqual(testCase,cv.localValidCountBtoA(validBtoA), ...
    n*ones(nnz(validBtoA),1));
verifyEqual(testCase,cv.pLocalCurveAtoB(validAtoB), ...
    (cv.localExceedanceCountAtoB(validAtoB)+1)./( ...
    cv.localValidCountAtoB(validAtoB)+1),'AbsTol',0);
verifyEqual(testCase,cv.pLocalCurveBtoA(validBtoA), ...
    (cv.localExceedanceCountBtoA(validBtoA)+1)./( ...
    cv.localValidCountBtoA(validBtoA)+1),'AbsTol',0);
verifyEqual(testCase,isfinite(cv.pLocalCurveConsensus),bothFinite);
verifyEqual(testCase,cv.localValidCountConsensus(bothFinite), ...
    n*ones(nnz(bothFinite),1));
verifyMonteCarloGrid(testCase, ...
    cv.pLocalCurveConsensus(bothFinite),n);
verifyGreaterThanOrEqual(testCase,cv.pCurveConsensus(bothFinite), ...
    cv.pLocalCurveConsensus(bothFinite)-32*eps);
verifyEqual(testCase,cv.validateAtoB.pLocalCurve, ...
    cv.pLocalCurveAtoB,'AbsTol',0);
verifyEqual(testCase,cv.validateBtoA.pLocalCurve, ...
    cv.pLocalCurveBtoA,'AbsTol',0);
verifyTrue(testCase,contains(cv.config.localPCurveRule,'same-rate'));
verifyTrue(testCase,contains(cv.config.localPCurveRule,'descriptive only'));
end

function testCvPlotIncludesDirectionalLocalPPanel(testCase)
cv = testCase.TestData.cv;
figures = plotcvcoco(cv,'ShowSpectra',false);
cleanup = onCleanup(@()closeTestFigures(figures));
verifyNumElements(testCase,figures,3);

correlationAxis = findobj(figures(1),'Type','axes', ...
    'Tag','cvCOCO-correlation');
globalAxis = findobj(figures(1),'Type','axes','Tag','cvCOCO-global-p');
localAxis = findobj(figures(1),'Type','axes','Tag','cvCOCO-local-p');
orbitAxis = findobj(figures(1),'Type','axes','Tag','COCO-orbit-count');
verifyNumElements(testCase,correlationAxis,1);
verifyNumElements(testCase,globalAxis,1);
verifyNumElements(testCase,localAxis,1);
verifyNumElements(testCase,orbitAxis,1);
consensusAuditAxis = findall(figures(3),'Type','axes', ...
    'Tag','cvCOCO-consensus-global-audit');
verifyNumElements(testCase,consensusAuditAxis,1);
verifyTrue(testCase,any(contains( ...
    string(consensusAuditAxis.Title.String),'Consensus global p')));
verifyEqual(testCase,consensusAuditAxis.XLabel.String, ...
    'Null consensus maximum');
consensusHistogram = findall(consensusAuditAxis, ...
    'Type','histogram');
verifyNumElements(testCase,consensusHistogram,1);
verifyEqual(testCase,consensusHistogram.Data(:), ...
    cv.nullConsensus(isfinite(cv.nullConsensus)),'AbsTol',0);
consensusObserved = findall(consensusAuditAxis,'Type','line', ...
    'Color',[1 0 0]);
verifyNumElements(testCase,consensusObserved,1);
verifyEqual(testCase,consensusObserved.XData, ...
    [cv.scoreConsensus cv.scoreConsensus],'AbsTol',0);
verifyEqual(testCase,globalAxis.Layout.Tile,2);
verifyEqual(testCase,localAxis.Layout.Tile,3);
verifyEqual(testCase,correlationAxis.Layout.Tile,1);
verifyEqual(testCase,orbitAxis.Layout.Tile,4);
verifyEqual(testCase,correlationAxis.Title.String, ...
    'Correlation coefficient');
verifyEqual(testCase,correlationAxis.YLabel.String,'\rho');
verifyEqual(testCase,globalAxis.Title.String,'Global p');
verifyEqual(testCase,globalAxis.YLabel.String,'Global p');
verifyEqual(testCase,localAxis.Title.String,'Local p');
verifyEqual(testCase,localAxis.YLabel.String,'Local p');
verifyEqual(testCase,orbitAxis.Title.String, ...
    'Number of contributing astronomical parameters');
verifyEqual(testCase,orbitAxis.YLabel.String,'#');
verifyEqual(testCase,globalAxis.YLim,[0 -log10(0.002)],'AbsTol',8*eps);

pCOCOAxis = findobj(figures(2),'Type','axes', ...
    'Tag','cvCOCO-pCOCO-axis');
pCOCOLine = findobj(pCOCOAxis,'Type','line','Tag','cvCOCO-pCOCO');
pCOCOPeak = findall(pCOCOAxis,'Type','line', ...
    'Tag','cvCOCO-pCOCO-peak');
verifyNumElements(testCase,pCOCOAxis,1);
verifyNumElements(testCase,pCOCOLine,1);
verifyNumElements(testCase,pCOCOPeak,1);
expectedPCOCO = cv.consensus.curve(:).* ...
    abs(log10(cv.pCurveConsensus(:)));
verifyEqual(testCase,cv.pCOCO,expectedPCOCO,'AbsTol',0);
verifyEqual(testCase,cv.consensus.pCOCO,expectedPCOCO,'AbsTol',0);
verifyEqual(testCase,pCOCOLine.XData(:),cv.srGrid(:),'AbsTol',0);
verifyEqual(testCase,pCOCOLine.YData(:),expectedPCOCO,'AbsTol',0);
verifyEqual(testCase,pCOCOLine.Color,[1 0 0],'AbsTol',0);
verifyEqual(testCase,pCOCOLine.LineWidth,2,'AbsTol',0);
[expectedBestPCOCO,expectedBestIndex] = max(expectedPCOCO,[],'omitnan');
verifyEqual(testCase,cv.bestPCOCO,expectedBestPCOCO,'AbsTol',0);
verifyEqual(testCase,cv.bestPCOCORate, ...
    cv.srGrid(expectedBestIndex),'AbsTol',0);
verifyEqual(testCase,pCOCOPeak.XData,cv.bestPCOCORate,'AbsTol',0);
verifyEqual(testCase,pCOCOPeak.YData,cv.bestPCOCO,'AbsTol',0);
verifyEqual(testCase,pCOCOPeak.MarkerSize,4,'AbsTol',0);

globalLineAtoB = findobj(globalAxis,'Type','line', ...
    'Tag','cvCOCO-global-p-AtoB');
globalLineBtoA = findobj(globalAxis,'Type','line', ...
    'Tag','cvCOCO-global-p-BtoA');
verifyNumElements(testCase,globalLineAtoB,1);
verifyNumElements(testCase,globalLineBtoA,1);
verifyEqual(testCase,globalLineAtoB.DisplayName, ...
    sprintf('p_B=%s',formatProbability4Expected(cv.pB)));
verifyEqual(testCase,globalLineBtoA.DisplayName, ...
    sprintf('p_A=%s',formatProbability4Expected(cv.pA)));

correlationConsensus = findobj(correlationAxis,'Type','line', ...
    'Tag','cvCOCO-correlation-consensus');
globalConsensus = findobj(globalAxis,'Type','line', ...
    'Tag','cvCOCO-global-p-consensus');
localConsensus = findobj(localAxis,'Type','line', ...
    'Tag','cvCOCO-local-p-consensus');
verifyNumElements(testCase,correlationConsensus,1);
verifyNumElements(testCase,globalConsensus,1);
verifyNumElements(testCase,localConsensus,1);
verifyEqual(testCase,correlationConsensus.YData(:), ...
    cv.consensus.curve(:),'AbsTol',0);

lineAtoB = findobj(localAxis,'Type','line','Tag','cvCOCO-local-p-AtoB');
lineBtoA = findobj(localAxis,'Type','line','Tag','cvCOCO-local-p-BtoA');
verifyNumElements(testCase,lineAtoB,1);
verifyNumElements(testCase,lineBtoA,1);
verifyEqual(testCase,lineAtoB.XData(:),cv.srGrid(:),'AbsTol',0);
verifyEqual(testCase,lineBtoA.XData(:),cv.srGrid(:),'AbsTol',0);
pFloor = 1/(max(cv.nsimValidAtoB,cv.nsimValidBtoA)+1);
expectedAtoB = -log10(max(cv.pLocalCurveAtoB(:),pFloor));
expectedBtoA = -log10(max(cv.pLocalCurveBtoA(:),pFloor));
expectedGlobalConsensus = -log10(max(cv.pCurveConsensus(:),pFloor));
expectedLocalConsensus = -log10(max( ...
    cv.pLocalCurveConsensus(:),pFloor));
verifyEqual(testCase,lineAtoB.YData(:),expectedAtoB,'AbsTol',0);
verifyEqual(testCase,lineBtoA.YData(:),expectedBtoA,'AbsTol',0);
verifyEqual(testCase,globalConsensus.YData(:), ...
    expectedGlobalConsensus,'AbsTol',0);
verifyEqual(testCase,localConsensus.YData(:), ...
    expectedLocalConsensus,'AbsTol',0);
verifyEqual(testCase,lineAtoB.Color,[1 0 0],'AbsTol',0);
verifyEqual(testCase,lineBtoA.Color,[0 0 1],'AbsTol',0);
verifyEqual(testCase,[globalLineAtoB.LineWidth; ...
    globalLineBtoA.LineWidth;lineAtoB.LineWidth;lineBtoA.LineWidth], ...
    0.6*ones(4,1),'AbsTol',0);
consensusLines = [correlationConsensus;globalConsensus;localConsensus];
verifyEqual(testCase,vertcat(consensusLines.Color),zeros(3,3), ...
    'AbsTol',0);
verifyEqual(testCase,vertcat(consensusLines.LineWidth),1.2*ones(3,1), ...
    'AbsTol',0);
verifyEqual(testCase,correlationConsensus.DisplayName,'Consensus');
verifyEqual(testCase,globalConsensus.DisplayName, ...
    sprintf('p_{cons}=%s',formatProbability4Expected(cv.pConsensus)));
verifyEqual(testCase,localConsensus.DisplayName, ...
    sprintf('p_{cons}=%s', ...
    formatProbability4Expected(cv.consensus.pLocalAtBest)));
verifyEqual(testCase,lineAtoB.DisplayName, ...
    sprintf('p_B=%s',formatProbability4Expected( ...
    cv.pLocalCurveAtoB(cv.validateAtoB.bestIndex))));
verifyEqual(testCase,lineBtoA.DisplayName, ...
    sprintf('p_A=%s',formatProbability4Expected( ...
    cv.pLocalCurveBtoA(cv.validateBtoA.bestIndex))));

correlationDirections = findobj(correlationAxis,'Type','line','Tag','');
correlationDirections = correlationDirections(arrayfun(@(line) ...
    ismember(line.Color,[1 0 0;0 0 1],'rows') && ...
    strcmp(line.LineStyle,'-'),correlationDirections));
verifyEqual(testCase,sort(string({correlationDirections.DisplayName})), ...
    ["A","B"]);
verifyEqual(testCase,vertcat(correlationDirections.LineWidth), ...
    0.55*ones(2,1),'AbsTol',0);

blueOrbit = findobj(orbitAxis,'Type','line','Color',[0 0 1]);
redOrbit = findobj(orbitAxis,'Type','line','Color',[1 0 0]);
verifyNumElements(testCase,blueOrbit,1);
verifyNumElements(testCase,redOrbit,1);
verifyEqual(testCase,blueOrbit.LineWidth,1,'AbsTol',0);
verifyEqual(testCase,redOrbit.LineWidth,0.5,'AbsTol',0);

coloredPeakTags = { ...
    'cvCOCO-correlation-AtoB-peak'; ...
    'cvCOCO-correlation-BtoA-peak'; ...
    'cvCOCO-global-p-AtoB-peak'; ...
    'cvCOCO-global-p-BtoA-peak'; ...
    'cvCOCO-local-p-AtoB-peak'; ...
    'cvCOCO-local-p-BtoA-peak'};
for peakIndex = 1:numel(coloredPeakTags)
    peak = findall(figures(1),'Type','line', ...
        'Tag',coloredPeakTags{peakIndex});
    verifyNumElements(testCase,peak,1);
    verifyEqual(testCase,peak.MarkerSize,2.5,'AbsTol',0);
end

blackPeakTags = { ...
    'cvCOCO-correlation-consensus-peak'; ...
    'cvCOCO-global-p-consensus-peak'; ...
    'cvCOCO-local-p-consensus-peak'};
blackPeakY = [cv.consensus.bestCorrelation; ...
    -log10(max(cv.pCurveConsensus(cv.consensus.bestIndex),pFloor)); ...
    -log10(max(cv.pLocalCurveConsensus(cv.consensus.bestIndex),pFloor))];
for peakIndex = 1:numel(blackPeakTags)
    peak = findall(figures(1),'Type','line', ...
        'Tag',blackPeakTags{peakIndex});
    verifyNumElements(testCase,peak,1);
    verifyEqual(testCase,peak.XData,cv.consensus.bestRate,'AbsTol',0);
    verifyEqual(testCase,peak.YData,blackPeakY(peakIndex),'AbsTol',0);
    verifyEqual(testCase,peak.Color,[0 0 0],'AbsTol',0);
    verifyEqual(testCase,peak.MarkerFaceColor,[0 0 0],'AbsTol',0);
    verifyEqual(testCase,peak.MarkerSize,2.5,'AbsTol',0);
end
clear cleanup
closeTestFigures(figures);
end

function testCvPlotExpandsGlobalPRangeForVerySmallValues(testCase)
cv = testCase.TestData.cv;
cv.nsimValidAtoB = 5000;
cv.nsimValidBtoA = 5000;
cv.pCurveAtoB(1) = 0.001;
cv.pB = 0.001;
figures = plotcvcoco(cv,'ShowSpectra',false);
cleanup = onCleanup(@()closeTestFigures(figures));

globalAxis = findobj(figures(1),'Type','axes','Tag','cvCOCO-global-p');
verifyNumElements(testCase,globalAxis,1);
verifyGreaterThan(testCase,globalAxis.YLim(2),-log10(0.002));

clear cleanup
closeTestFigures(figures);
end

function testCvSpectralFigureUsesCompactTitlesAndOneLegend(testCase)
figures = plotcvcoco(testCase.TestData.cv,'ShowSpectra',true);
cleanup = onCleanup(@()closeTestFigures(figures));

depthAxisA = findobj(figures(1),'Type','axes','Tag','cvCOCO-depth-A');
depthAxisB = findobj(figures(1),'Type','axes','Tag','cvCOCO-depth-B');
spectrumBtoA = findobj(figures(1),'Type','axes', ...
    'Tag','cvCOCO-spectrum-BtoA');
spectrumAtoB = findobj(figures(1),'Type','axes', ...
    'Tag','cvCOCO-spectrum-AtoB');
verifyNumElements(testCase,depthAxisA,1);
verifyNumElements(testCase,depthAxisB,1);
verifyNumElements(testCase,spectrumBtoA,1);
verifyNumElements(testCase,spectrumAtoB,1);
verifyEqual(testCase,depthAxisA.Title.String,'Segment A depth series');
verifyEqual(testCase,depthAxisB.Title.String,'Segment B depth series');
verifyNumElements(testCase,spectrumBtoA.Title.String,2);
verifyNumElements(testCase,spectrumAtoB.Title.String,2);
verifyNumElements(testCase,findobj(figures(1),'Type','Legend'),1);
legends = findall(figures,'Type','legend');
verifyNotEmpty(testCase,legends);
verifyEqual(testCase,vertcat(legends.NumColumns), ...
    ones(numel(legends),1));
verifyTrue(testCase,all(strcmp({legends.Orientation},'vertical')));

clear cleanup
closeTestFigures(figures);
end

function testCvGuiPlotUsesOneTabbedFigure(testCase)
fig = plotcvcoco(testCase.TestData.cv, ...
    'ShowSpectra',true,'Tabbed',true);
cleanup = onCleanup(@()closeTestFigures(fig));

verifyNumElements(testCase,fig,1);
verifyEqual(testCase,fig.Units,'normalized');
verifyEqual(testCase,fig.Position,[0.29 0.04 0.42 0.90], ...
    'AbsTol',64*eps);
tabGroups = findobj(fig,'Type','uitabgroup');
verifyNumElements(testCase,tabGroups,1);
tabs = findobj(tabGroups,'Type','uitab');
verifyNumElements(testCase,tabs,4);
titles = sort(string({tabs.Title}));
verifyEqual(testCase,titles,sort(["Data and spectra", ...
    "Correlation and significance","pCOCO","Monte Carlo audit"]));

clear cleanup
closeTestFigures(fig);
end

function testConclusionReportDirectionAndPartialPeriodInvariants(testCase)
cv = testCase.TestData.cv;
report = cocoConclusionReport('confirmatory',cv);
verifyEqual(testCase,report.pA,cv.pA);
verifyEqual(testCase,report.pB,cv.pB);
verifyEqual(testCase,report.pRobust,max(cv.pA,cv.pB));
verifyEqual(testCase,report.pass,report.pRobust < report.alphaGlobal);
verifyEqual(testCase,report.participatingPeriodsAtoB, ...
    cv.activeOrbitCountAtoB(cv.validateAtoB.bestIndex));
verifyEqual(testCase,report.participatingPeriodsBtoA, ...
    cv.activeOrbitCountBtoA(cv.validateBtoA.bestIndex));

partial = cv;
indexAtoB = find(partial.orbitCountB > 0 & partial.orbitCountB < 9,1);
indexBtoA = find(partial.orbitCountA > 0 & partial.orbitCountA < 9,1,'last');
verifyNotEmpty(testCase,indexAtoB);
verifyNotEmpty(testCase,indexBtoA);
partial.validateAtoB.bestIndex = indexAtoB;
partial.validateAtoB.bestRate = partial.srGrid(indexAtoB);
partial.validateBtoA.bestIndex = indexBtoA;
partial.validateBtoA.bestRate = partial.srGrid(indexBtoA);
partial.validateAtoB.participatingPeriodCount = ...
    partial.activeOrbitCountAtoB(indexAtoB);
partial.validateAtoB.participatingGroupCounts = ...
    partial.activeGroupCountAtoB(indexAtoB,:);
partial.validateBtoA.participatingPeriodCount = ...
    partial.activeOrbitCountBtoA(indexBtoA);
partial.validateBtoA.participatingGroupCounts = ...
    partial.activeGroupCountBtoA(indexBtoA,:);
partial.pCurveAtoB = 0.6*ones(size(partial.srGrid));
partial.pCurveBtoA = 0.6*ones(size(partial.srGrid));
partial.pCurveAtoB(indexAtoB) = 0.01;
partial.pCurveBtoA(indexBtoA) = 0.01;
partial.validateAtoB.score = 1;
partial.validateBtoA.score = 1;
partial.scoreSymmetric = 1;
partial.scoreMean = 1;
partial.nullAtoB = zeros(99,1);
partial.nullBtoA = zeros(99,1);
partial.nullSymmetric = zeros(99,1);
partial.pAtoB = 0.01;
partial.pB = 0.01;
partial.pBtoA = 0.01;
partial.pA = 0.01;
partial.pSym = 0.01;
partial.pAConfidenceInterval = wilsonIntervalForFixture(0,99);
partial.pBConfidenceInterval = wilsonIntervalForFixture(0,99);
partial.pSymConfidenceInterval = wilsonIntervalForFixture(0,99);
partial.nsimCompleted = 99;
partial.nsimValid = 99;
partial.nsimValidAtoB = 99;
partial.nsimValidBtoA = 99;

partialReport = cocoConclusionReport('confirmatory',partial);
verifyFalse(testCase,partialReport.allNineAtBothBestRates);
verifyEqual(testCase,partialReport.participatingPeriodsAtoB, ...
    partial.activeOrbitCountAtoB(indexAtoB));
verifyEqual(testCase,partialReport.participatingPeriodsBtoA, ...
    partial.activeOrbitCountBtoA(indexBtoA));
verifyEqual(testCase,sum(partialReport.participatingGroupCountsAtoB), ...
    partialReport.participatingPeriodsAtoB);
verifyEqual(testCase,sum(partialReport.participatingGroupCountsBtoA), ...
    partialReport.participatingPeriodsBtoA);
verifyTrue(testCase,contains(lower(partialReport.conclusion),'partial'));
verifyTrue(testCase,partialReport.pass);

legacy = cv;
legacy.targetModel = 'legacy';
verifyError(testCase,@()cocoConclusionReport('confirmatory',legacy), ...
    'cocoConclusionReport:LegacyTargetNotConfirmatory');
brokenDirection = cv;
brokenDirection.pB = 0.123456789;
verifyError(testCase,@()cocoConclusionReport( ...
    'confirmatory',brokenDirection), ...
    'cocoConclusionReport:DirectionalPInvariant');
brokenSymmetric = cv;
if cv.pSym < 0.5
    brokenSymmetric.pSym = cv.pSym+0.25;
else
    brokenSymmetric.pSym = cv.pSym-0.25;
end
verifyError(testCase,@()cocoConclusionReport( ...
    'confirmatory',brokenSymmetric), ...
    'cocoConclusionReport:DirectionalPInvariant');

adaptive = testCase.TestData.adaptive;
adaptiveReport = cocoConclusionReport( ...
    'adaptive',adaptive.corrCI,adaptive.corrH0);
[~,bestIndex] = max(adaptive.corrCI(:,2));
verifyEqual(testCase,adaptiveReport.bestRate, ...
    adaptive.corrCI(bestIndex,1));
verifyEqual(testCase,adaptiveReport.minimumGlobalP, ...
    min(adaptive.corrH0(:,1)));
verifyEqual(testCase,adaptiveReport.periodCountAtBest, ...
    adaptive.corrH0(bestIndex,2));
verifyEqual(testCase,adaptiveReport.pass, ...
    adaptiveReport.minimumGlobalP < adaptiveReport.alphaGlobal);

publicationReport = cocoAdaptivePublicationReport( ...
    adaptive.corrCI,adaptive.corrH0,adaptive.details);
verifyEqual(testCase,adaptive.details.targetAmplitudeMode,'adaptive');
verifyEqual(testCase,publicationReport.targetAmplitudeMode,'adaptive');
verifyEqual(testCase,publicationReport.minimumGlobalP, ...
    adaptiveReport.minimumGlobalP);
verifyEqual(testCase,publicationReport.globalPExceedanceCount, ...
    sum(adaptive.details.nullMax >= publicationReport.bestCorrelation));
verifyEqual(testCase,publicationReport.nsimValid, ...
    numel(adaptive.details.nullMax));
brokenAdaptiveH0 = adaptive.corrH0;
auditedP = publicationReport.minimumGlobalP;
if auditedP < 1
    replacementP = 1;
else
    replacementP = 1/(numel(adaptive.details.nullMax)+1);
end
brokenAdaptiveH0(:,1) = replacementP;
verifyError(testCase,@()cocoAdaptivePublicationReport( ...
    adaptive.corrCI,brokenAdaptiveH0,adaptive.details), ...
    'cocoAdaptivePublicationReport:GlobalPInvariant');
end

function cv = runCv(testCase,red,nsim,seed,batchSize,maximumFrequency)
args = cvArguments(testCase,red,nsim);
options = {'Seed',seed,'BatchSize',batchSize};
if ~isempty(maximumFrequency)
    options = [options,{'MaxFrequency',maximumFrequency}];
end
cv = cvcoco(args{:},options{:});
end

function args = cvArguments(testCase,red,nsim)
range = testCase.TestData.rateRange;
args = {testCase.TestData.data,testCase.TestData.orbit9, ...
    testCase.TestData.padCv,range(1),range(2),range(3),red,nsim,'Pearson'};
end

function [corrCI,corrH0,corry,details] = runAdaptive( ...
        testCase,red,nsim,slices,seed,maximumFrequency)
[corrCI,corrH0,corry,details] = adaptiveCall( ...
    testCase.TestData.data,testCase.TestData.orbit9, ...
    testCase.TestData.padAdaptive,red,nsim,slices,seed,maximumFrequency);
end

function [corrCI,corrH0,corry,details] = adaptiveCall( ...
        data,orbit9,pad,red,nsim,slices,seed,maximumFrequency)
dt = median(diff(data(:,1)));
options = {'Seed',seed,'ShowPeriodograms',false};
if ~isempty(maximumFrequency)
    options = [options,{'MaxFrequency',maximumFrequency}];
end
[corrCI,corrH0,corry,details] = corrcoefslices_rankNew( ...
    data,orbit9,dt,pad,1,8,1,0,red,nsim,0,slices,'Pearson', ...
    1/(2*dt),0,false,'adaptive',options{:});
end

function data = syntheticOrbitalSeries(orbit9)
depth = (0:0.1:50)';
sedimentationRate = 4;
timeKyr = depth*100/sedimentationRate;
amplitude = [1.0,0.82,0.72,0.66,0.61,0.78,0.58,0.52,0.47];
phase = [0.1,0.7,1.4,2.2,2.8,0.4,1.1,1.9,2.5];
signal = zeros(size(depth));
for ii = 1:numel(orbit9)
    signal = signal+amplitude(ii)*sin( ...
        2*pi*timeKyr/orbit9(ii)+phase(ii));
end
signal = signal+0.12*cos(2*pi*depth/1.73) ...
    +0.08*sin(2*pi*depth/0.91+0.3)+0.003*depth;
data = [depth,signal];
end

function count = physicalOrbitCount(periods,srGrid,dz,n,maximumFrequency)
periods = periods(:)';
srGrid = srGrid(:);
rayleigh = 1/(n*dz);
nyquist = 1/(2*dz);
count = zeros(numel(srGrid),1);
for ii = 1:numel(srGrid)
    spatialFrequency = 100./(periods*srGrid(ii));
    resolved = spatialFrequency >= rayleigh & spatialFrequency < nyquist ...
        & 1./periods <= maximumFrequency;
    count(ii) = nnz(resolved);
end
end

function verifyUniformHalf(testCase,data,spacing)
difference = diff(data(:,1));
tolerance = max(1e-11,128*eps(max(abs(data(:,1)))));
verifyLessThanOrEqual(testCase,max(abs(difference-spacing)),tolerance);
verifyEqual(testCase,spacing,median(difference),'AbsTol',tolerance);
end

function p = plusOneP(nullValues,observed)
nullValues = nullValues(isfinite(nullValues));
p = (1+sum(nullValues >= observed))/(numel(nullValues)+1);
end

function verifyMonteCarloGrid(testCase,p,n)
p = p(isfinite(p));
verifyNotEmpty(testCase,p);
verifyGreaterThanOrEqual(testCase,p,ones(size(p))/(n+1));
verifyLessThanOrEqual(testCase,p,ones(size(p)));
verifyEqual(testCase,p*(n+1),round(p*(n+1)),'AbsTol',1e-12);
end

function interval = wilsonIntervalForFixture(k,n)
z = 1.95996398454005;
phat = k/n;
denominator = 1+z^2/n;
center = (phat+z^2/(2*n))/denominator;
halfWidth = z/denominator*sqrt(phat*(1-phat)/n+z^2/(4*n^2));
interval = [max(0,center-halfWidth),min(1,center+halfWidth)];
end

function y = legacyMoveMedianReference(x,w)
x = x(:);
m = numel(x);
y = zeros(m,1);
halfw = floor(w/2);
idx1 = halfw+1;
if mod(w,2)
    for ii = 1:idx1-1
        y(ii) = median(x(1:idx1-1+ii));
    end
    for ii = idx1:m-idx1+1
        y(ii) = median(x(ii-halfw:ii+halfw));
    end
    for ii = m-idx1+2:m
        y(ii) = median(x(ii-halfw:m));
    end
else
    for ii = 1:halfw-1
        y(ii) = median(x(1:halfw+ii));
    end
    for ii = halfw:m-idx1+1
        y(ii) = median(x(ii-(halfw-1):ii+halfw));
    end
    for ii = m-idx1+2:m
        y(ii) = median(x(ii-(halfw-1):m));
    end
end
end

function [rho,s0] = legacyMinirhos0Reference( ...
        s0,fn,frequency,power,linlog)
cosine = cos(pi*frequency(:)/fn);
nGrid = 50;
rhoGrid = linspace(0.001,0.999,nGrid);
s0Grid = linspace(0.2*s0,5*s0,nGrid);
distance = legacyRhoDistance(rhoGrid,s0Grid,cosine,power,linlog,true);
[rhoIndex,s0Index] = firstReferenceMinimum(distance);
rho = rhoGrid(rhoIndex);
s0 = s0Grid(s0Index);
refinedGrid = nGrid/2;
for iteration = 1:3
    s0Maximum = s0Grid(s0Index)+(s0Grid(2)-s0Grid(1));
    s0Minimum = s0Grid(s0Index)-(s0Grid(2)-s0Grid(1));
    rhoMaximum = min(0.9999, ...
        rhoGrid(rhoIndex)+(rhoGrid(2)-rhoGrid(1)));
    rhoMinimum = max(0.0001, ...
        rhoGrid(rhoIndex)-(rhoGrid(2)-rhoGrid(1)));
    rhoGrid = linspace(rhoMinimum,rhoMaximum,refinedGrid);
    s0Grid = linspace(s0Minimum,s0Maximum,refinedGrid);
    distance = legacyRhoDistance( ...
        rhoGrid,s0Grid,cosine,power,linlog,false);
    [rhoIndex,s0Index] = firstReferenceMinimum(distance);
    rho = rhoGrid(rhoIndex);
    s0 = s0Grid(s0Index);
end
end

function distance = legacyRhoDistance( ...
        rhoGrid,s0Grid,cosine,power,linlog,useLog10)
distance = zeros(numel(rhoGrid),numel(s0Grid));
for ii = 1:numel(rhoGrid)
    shape = (1-rhoGrid(ii)^2)./( ...
        1-2*rhoGrid(ii)*cosine+rhoGrid(ii)^2);
    for jj = 1:numel(s0Grid)
        theoretical = s0Grid(jj)*shape;
        if linlog == 1
            residual = theoretical-power;
        elseif useLog10
            residual = log10(theoretical)-log10(power);
        else
            residual = log(theoretical)-log(power);
        end
        distance(ii,jj) = sum(residual.^2);
    end
end
end

function [row,column] = firstReferenceMinimum(distance)
[~,index] = min(distance(:));
[row,column] = ind2sub(size(distance),index);
end

function textValue = formatProbability4Expected(value)
if value == 0
    textValue = '0.000';
    return
end
exponent = floor(log10(abs(value)));
decimalPlaces = max(0,4-exponent-1);
textValue = sprintf(['%0.',num2str(decimalPlaces),'f'],value);
end

function state = captureBaseVariables(names)
state = struct;
state.name = names(:);
state.existed = false(numel(names),1);
state.value = cell(numel(names),1);
for ii = 1:numel(names)
    state.existed(ii) = evalin('base',sprintf( ...
        'exist(''%s'',''var'') == 1',names{ii}));
    if state.existed(ii)
        state.value{ii} = evalin('base',names{ii});
    end
end
end

function restoreBaseVariables(state)
for ii = 1:numel(state.name)
    if state.existed(ii)
        assignin('base',state.name{ii},state.value{ii});
    else
        evalin('base',sprintf('clear(''%s'')',state.name{ii}));
    end
end
end

function closeTestFigures(figures)
figures = figures(isgraphics(figures,'figure'));
if ~isempty(figures)
    close(figures);
end
end
