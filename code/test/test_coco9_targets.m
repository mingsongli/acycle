function tests = test_coco9_targets
%TEST_COCO9_TARGETS Regression tests for the explicit nine-peak COCO modes.
%
% The important invariant is spectral, not merely bookkeeping: every one
% of the nine nominal orbital frequencies must own a distinct local maximum
% in the target spectrum.  In particular, all four short-eccentricity
% periods between 80 and 200 kyr must be represented by separate peaks.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
addpath(genpath(fullfile(repoRoot,'code')));
testCase.addTeardown(@()path(oldPath));

% These are the present-day GUI defaults.  The two close pairs near
% 100 kyr are the regression geometry that used to merge into two peaks.
orbit9 = [405.6912;130.6979;123.8532;98.8517;94.8856; ...
    40.9897;23.6820;22.3758;18.9519];
sedimentationRate = 4;
% cvCOCO splits at the midpoint.  A 4000-kyr record leaves a 2000-kyr
% target in each held-out half, matching the GUI-scale regression while
% giving the coherent construction enough duration to separate both close
% short-eccentricity pairs.
timeKyr = (0:4000)';
depth = timeKyr*sedimentationRate/100;
amplitude = [1.00;0.96;0.92;0.88;0.84;0.80;0.76;0.72;0.68];
phase = [0.10;0.70;1.40;2.20;2.80;0.40;1.10;1.90;2.50];
signal = zeros(size(timeKyr));
for ii = 1:numel(orbit9)
    signal = signal+amplitude(ii)*sin( ...
        2*pi*timeKyr/orbit9(ii)+phase(ii));
end
signal = signal+0.003*depth;
data = [depth,signal];

pad = 16384;
dt = median(diff(depth));
samplingFrequency = 1/dt;
[dataPower,dataFrequency] = periodogram( ...
    detrend(signal,1),[],pad,samplingFrequency);

testCase.TestData.repoRoot = repoRoot;
testCase.TestData.orbit9 = orbit9;
testCase.TestData.data = data;
testCase.TestData.pad = pad;
testCase.TestData.dt = dt;
testCase.TestData.sedimentationRate = sedimentationRate;
testCase.TestData.maximumFrequency = 0.06;
testCase.TestData.dataPower = dataPower;
testCase.TestData.dataFrequency = dataFrequency;
testCase.TestData.rayleigh = 1/(size(data,1)*dt);
end

function testCvCoco9ABAndCompatibilityAlias(testCase)
data = testCase.TestData.data;
orbit9 = testCase.TestData.orbit9;
rate = testCase.TestData.sedimentationRate;
limit = testCase.TestData.maximumFrequency;

methodA = cvcoco9A(data,orbit9,testCase.TestData.pad, ...
    rate,rate,1,0,0,'Pearson','MaxFrequency',limit,'Seed',91);
methodB = cvcoco9B(data,orbit9,testCase.TestData.pad, ...
    rate,rate,1,0,0,'Pearson','MaxFrequency',limit,'Seed',91);
compatibility = cvcoco9(data,orbit9,testCase.TestData.pad, ...
    rate,rate,1,0,0,'Pearson','MaxFrequency',limit,'Seed',91);

verifyEqual(testCase,methodA.name,'cvCOCO9A');
verifyEqual(testCase,methodA.variant,'A');
verifyEqual(testCase,methodA.targetModel, ...
    'rayleigh-peak-coherent-nine');
verifyEqual(testCase,methodA.config.targetModel, ...
    'rayleigh-peak-coherent-nine');
verifyEqual(testCase,methodA.frozenValidationWeightLevel, ...
    'nine individual orbital amplitudes');
verifyFalse(testCase,methodA.compatibilityAlias);

verifyEqual(testCase,methodB.name,'cvCOCO9B');
verifyEqual(testCase,methodB.variant,'B');
verifyEqual(testCase,methodB.targetModel,'four-group-coherent-nine');
verifyEqual(testCase,methodB.config.targetModel, ...
    'four-group-coherent-nine');
verifyEqual(testCase,methodB.frozenValidationWeightLevel, ...
    'four RMS orbital-group amplitudes');
verifyFalse(testCase,methodB.compatibilityAlias);

% The historical spelling is intentionally retained only as an exact
% compatibility alias for method B.  Its public name is no longer the
% ambiguous cvCOCO9 label.
verifyEqual(testCase,compatibility.name,'cvCOCO9B');
verifyTrue(testCase,compatibility.compatibilityAlias);
verifyEqual(testCase,compatibility.canonicalEntryPoint,'cvcoco9B');
verifyEqual(testCase,compatibility.targetModel,methodB.targetModel);
verifyEqual(testCase,compatibility.trainA.curve,methodB.trainA.curve, ...
    'AbsTol',0);
verifyEqual(testCase,compatibility.trainB.curve,methodB.trainB.curve, ...
    'AbsTol',0);
verifyEqual(testCase,compatibility.validateAtoB.curve, ...
    methodB.validateAtoB.curve,'AbsTol',0);
verifyEqual(testCase,compatibility.validateBtoA.curve, ...
    methodB.validateBtoA.curve,'AbsTol',0);

methods = {methodA,methodB};
methodNames = {'cvCOCO9A','cvCOCO9B'};
for methodIndex = 1:numel(methods)
    result = methods{methodIndex};
    verifyTrue(testCase,all(isfinite(result.trainA.curve( ...
        result.trainingRateMaskA))));
    verifyTrue(testCase,all(isfinite(result.trainB.curve( ...
        result.trainingRateMaskB))));

    diagnosticNames = {'trainA','trainB','validateAtoB','validateBtoA'};
    for diagnosticIndex = 1:numel(diagnosticNames)
        diagnosticName = diagnosticNames{diagnosticIndex};
        diagnostic = result.spectra.(diagnosticName);
        verifyNineNominalPeaks(testCase,diagnostic.frequency, ...
            diagnostic.targetPower,orbit9,sprintf('%s %s', ...
            methodNames{methodIndex},diagnosticName));
    end
end

% Method A preserves and normalizes nine separately fitted peak
% amplitudes.  It must not silently collapse the four short-eccentricity
% members or the three precession members to one group value.
for trainName = {'trainA','trainB'}
    trained = methodA.(trainName{1});
    verifySize(testCase,trained.amplitudes9,[9 1]);
    verifySize(testCase,trained.amplitudes9Normalized,[9 1]);
    verifyEqual(testCase,trained.amplitudes9Normalized, ...
        trained.amplitudes9./max(trained.amplitudes9), ...
        'RelTol',2e-14,'AbsTol',2e-14);
    verifyGreaterThan(testCase,range(trained.amplitudes9(2:5)), ...
        1e-5*max(trained.amplitudes9(2:5)));
    verifyGreaterThan(testCase,range(trained.amplitudes9(7:9)), ...
        1e-5*max(trained.amplitudes9(7:9)));
end

% Method B has four fitted parameters.  Expansion into the coherent
% nine-term target must assign exactly one common amplitude inside each
% orbital group.
for trainName = {'trainA','trainB'}
    trained = methodB.(trainName{1});
    expectedNine = trained.groupRaw(methodB.groupIndex);
    verifyEqual(testCase,trained.amplitudes9,expectedNine, ...
        'RelTol',2e-14,'AbsTol',2e-14);
end
end

function testAdaptiveCoherentNineEvaluatorContainsNineDistinctPeaks(testCase)
[rho,pValue,nMissing,diagnostic] = adaptiveEvaluate( ...
    testCase,'coherent-nine','adaptive');

verifyTrue(testCase,isfinite(rho));
verifyTrue(testCase,isfinite(pValue));
verifyEqual(testCase,nMissing,0);
verifyEqual(testCase,nnz(diagnostic.activeOrbit),9);
verifyEqual(testCase,diagnostic.targetModel,'coherent-nine');
verifyTrue(testCase,all(isfinite(diagnostic.amplitudes)));
verifyGreaterThan(testCase,min(diagnostic.amplitudes),0);
verifyNineNominalPeaks(testCase,diagnostic.frequency, ...
    diagnostic.targetPower,testCase.TestData.orbit9, ...
    'Adaptive COCO9');
end

function testAdaptiveCoherentNineMethodBEvaluator(testCase)
[rho,pValue,nMissing,diagnostic] = adaptiveEvaluate( ...
    testCase,'coherent-nine','four-group-area');

verifyTrue(testCase,isfinite(rho));
verifyTrue(testCase,isfinite(pValue));
verifyEqual(testCase,nMissing,0);
verifyEqual(testCase,nnz(diagnostic.activeOrbit),9);
verifyEqual(testCase,diagnostic.targetModel,'coherent-nine');
verifyEqual(testCase,diagnostic.amplitudeMode,'four-group-area');
verifyTrue(testCase,diagnostic.geometryValid);
verifySize(testCase,diagnostic.groupAmplitudes,[4 1]);
verifySize(testCase,diagnostic.groupBandEnergy,[4 1]);
verifySize(testCase,diagnostic.leakageMatrix,[4 4]);
verifyGreaterThan(testCase,diagnostic.leakageRcond,1e-10);
verifyGreaterThan(testCase,min(diagnostic.groupAmplitudes),0);
verifyGreaterThan(testCase,min(diagnostic.groupBandEnergy),0);
verifyEqual(testCase,diagnostic.amplitudes, ...
    diagnostic.groupAmplitudes(diagnostic.groupIndex), ...
    'RelTol',2e-14,'AbsTol',2e-14);
verifyNineNominalPeaks(testCase,diagnostic.frequency, ...
    diagnostic.targetPower,testCase.TestData.orbit9, ...
    'Adaptive COCO9B');
end

function testAdaptiveMethodBRejectsNonfiniteIntegratedEnergy(testCase)
% DATA POWER itself is finite, but summing several REALMAX bins over a
% method-B union band overflows.  This is invalid evidence, not a zero
% fitted amplitude, and must stop the analysis explicitly.
overflowPower = repmat(realmax('double'), ...
    size(testCase.TestData.dataPower));
data = testCase.TestData.data;
rate = testCase.TestData.sedimentationRate;
verifyError(testCase,@()cocoAdaptiveEvaluate( ...
    overflowPower,data,testCase.TestData.pad, ...
    testCase.TestData.dataFrequency,[],testCase.TestData.orbit9, ...
    testCase.TestData.rayleigh,rate,0,'Pearson', ...
    'BatchSize',1,'RateBounds',[rate rate], ...
    'MaxFrequency',testCase.TestData.maximumFrequency, ...
    'TargetModel','coherent-nine','AmplitudeMode','four-group-area'), ...
    'cocoAdaptiveEvaluate:InvalidGroupBandEnergy');
end

function testFixedCoco9EvaluatorContainsNineDistinctPeaks(testCase)
% Fixed COCO9 must use the same coherent nine-term construction for its
% actual numerical target, with prescribed rather than fitted amplitudes.
[rho,pValue,nMissing,diagnostic] = fixed9Evaluate(testCase, ...
    testCase.TestData.dataPower);

verifyTrue(testCase,isfinite(rho));
verifyTrue(testCase,isfinite(pValue));
verifyEqual(testCase,nMissing,0);
verifyEqual(testCase,nnz(diagnostic.activeOrbit),9);
verifyEqual(testCase,diagnostic.targetModel,'coherent-nine');
verifyEqual(testCase,diagnostic.amplitudeMode,'fixed');
verifyEqual(testCase,diagnostic.amplitudes, ...
    fixedWeightReference(testCase.TestData.orbit9),'AbsTol',0);
verifyNineNominalPeaks(testCase,diagnostic.frequency, ...
    diagnostic.targetPower,testCase.TestData.orbit9,'Fixed COCO9');

% Keep the compatibility target dispatcher public and coherent as well.
compatibilityFrequency = (0:floor(testCase.TestData.pad/2))' ./ ...
    testCase.TestData.pad;
compatibilityPower = cocoTargetSpectrum( ...
    testCase.TestData.data,testCase.TestData.pad, ...
    testCase.TestData.dataPower,testCase.TestData.orbit9, ...
    compatibilityFrequency,testCase.TestData.sedimentationRate,'fixed9');
verifyNineNominalPeaks(testCase,compatibilityFrequency, ...
    compatibilityPower,testCase.TestData.orbit9, ...
    'Fixed COCO9 compatibility target');
end

function testAdaptive9ABPublicMetadataAndCompatibilityAlias(testCase)
data = testCase.TestData.data;
dt = testCase.TestData.dt;
rate = testCase.TestData.sedimentationRate;
limit = testCase.TestData.maximumFrequency;

[corrA,corrH0A,corryA,detailsA] = corrcoefslices_rankNew( ...
    data,testCase.TestData.orbit9,dt,testCase.TestData.pad, ...
    rate,rate,1,0,0,0,0,1,'Pearson',1/(2*dt),0,false, ...
    'adaptive9a','MaxFrequency',limit,'Seed',37, ...
    'ShowPeriodograms',false);
[corrB,corrH0B,corryB,detailsB] = corrcoefslices_rankNew( ...
    data,testCase.TestData.orbit9,dt,testCase.TestData.pad, ...
    rate,rate,1,0,0,0,0,1,'Pearson',1/(2*dt),0,false, ...
    'adaptive9b','MaxFrequency',limit,'Seed',37, ...
    'ShowPeriodograms',false);
[corrAlias,corrH0Alias,corryAlias,detailsAlias] = ...
    corrcoefslices_rankNew( ...
    data,testCase.TestData.orbit9,dt,testCase.TestData.pad, ...
    rate,rate,1,0,0,0,0,1,'Pearson',1/(2*dt),0,false, ...
    'adaptive9','MaxFrequency',limit,'Seed',37, ...
    'ShowPeriodograms',false);

for corrCI = {corrA,corrB,corrAlias}
    verifySize(testCase,corrCI{1},[1 4]);
    verifyTrue(testCase,isfinite(corrCI{1}(1,2)));
    verifyEqual(testCase,corrCI{1}(1,4),0);
end
for corrH0 = {corrH0A,corrH0B,corrH0Alias}
    verifySize(testCase,corrH0{1},[1 3]);
    verifyEqual(testCase,corrH0{1}(1,2),9);
end
verifyEmpty(testCase,corryA);
verifyEmpty(testCase,corryB);
verifyEmpty(testCase,corryAlias);

verifyEqual(testCase,detailsA.targetMode,'adaptive9a');
verifyEqual(testCase,detailsA.targetModel,'coherent-nine');
verifyEqual(testCase,detailsA.targetAmplitudeMode,'adaptive');
verifyTrue(testCase,contains(lower(detailsA.targetConstruction), ...
    'per-orbit rayleigh-band peak'));
verifyEqual(testCase,detailsB.targetMode,'adaptive9b');
verifyEqual(testCase,detailsB.targetModel,'coherent-nine');
verifyEqual(testCase,detailsB.targetAmplitudeMode,'four-group-area');
verifyTrue(testCase,contains(lower(detailsB.targetConstruction), ...
    'leakage correction'));

% The former Adaptive COCO9 token remains an exact method-A alias.  Keep
% its spelling in metadata so old scripts remain auditable, while the
% target model and amplitude estimator identify the canonical behavior.
verifyEqual(testCase,detailsAlias.targetMode,'adaptive9');
verifyEqual(testCase,detailsAlias.targetModel,'coherent-nine');
verifyEqual(testCase,detailsAlias.targetAmplitudeMode,'adaptive');
verifyEqual(testCase,corrAlias,corrA,'AbsTol',0);
verifyEqual(testCase,corrH0Alias,corrH0A,'AbsTol',0);
end

function testFixed9PublicEntryPointAndMetadata(testCase)
data = testCase.TestData.data;
dt = testCase.TestData.dt;
rate = testCase.TestData.sedimentationRate;
limit = testCase.TestData.maximumFrequency;

[corrCI,corrH0,corry,details] = corrcoefslices_rankNew( ...
    data,testCase.TestData.orbit9,dt,testCase.TestData.pad, ...
    rate,rate,1,0,0,0,0,1,'Pearson',1/(2*dt),0,false, ...
    'fixed9','MaxFrequency',limit,'Seed',43, ...
    'ShowPeriodograms',false);

verifySize(testCase,corrCI,[1 4]);
verifySize(testCase,corrH0,[1 3]);
verifyEmpty(testCase,corry);
verifyTrue(testCase,isfinite(corrCI(1,2)));
verifyEqual(testCase,corrCI(1,4),0);
verifyEqual(testCase,corrH0(1,2),9);
verifyEqual(testCase,details.targetMode,'fixed9');
verifyEqual(testCase,details.targetModel,'coherent-nine');
verifyEqual(testCase,details.targetAmplitudeMode,'fixed');
verifyTrue(testCase,contains(lower(details.targetConstruction), ...
    'coherent'));
end

function testAdaptive9BMonteCarloUsesFourGroupAreaEvaluator(testCase)
% Reproduce the small Monte Carlo batch independently. This prevents a
% wiring regression in which only the observed curve uses method B while
% its null simulations silently fall back to per-orbit peak amplitudes.
data = testCase.TestData.data;
dt = testCase.TestData.dt;
rate = testCase.TestData.sedimentationRate;
limit = testCase.TestData.maximumFrequency;
seed = 137;
nsim = 3;

[corrCI,corrH0,corry,details] = corrcoefslices_rankNew( ...
    data,testCase.TestData.orbit9,dt,testCase.TestData.pad, ...
    rate,rate,1,0,0,nsim,0,1,'Pearson',1/(2*dt),0,false, ...
    'adaptive9b','MaxFrequency',limit,'Seed',seed, ...
    'ShowPeriodograms',false);

verifySize(testCase,corry,[1 nsim]);
verifyTrue(testCase,all(isfinite(corry),'all'));
verifyTrue(testCase,all(isfinite(corrH0(:,[1 3])),'all'));
verifyEqual(testCase,details.nSimValid,nsim);
verifyEqual(testCase,details.targetMode,'adaptive9b');
verifyEqual(testCase,details.targetAmplitudeMode,'four-group-area');
verifyEqual(testCase,details.nullMax,max(corry,[],1)', ...
    'AbsTol',2e-14);

rngState = rng;
cleanup = onCleanup(@()rng(rngState));
rng(seed,'twister');
[frequency,power] = redNoisePeriodogramMC( ...
    data,details.rhoM,nsim,0,testCase.TestData.pad, ...
    'BatchSize',nsim,'UseParallel',false,'Slices',1);
expected = cocoAdaptiveEvaluate( ...
    power,data,testCase.TestData.pad,frequency,[], ...
    testCase.TestData.orbit9,testCase.TestData.rayleigh,rate,0, ...
    'Pearson','BatchSize',nsim,'RateBounds',[rate rate], ...
    'MaxFrequency',limit,'TargetModel','coherent-nine', ...
    'AmplitudeMode','four-group-area');
verifyEqual(testCase,corry,expected,'AbsTol',2e-13);
verifyEqual(testCase,corrCI(1,1),rate);
clear cleanup
rng(rngState);
end

function testFixed9MonteCarloUsesFixedCoherentNineEvaluator(testCase)
% Reproduce Fixed COCO9's null batch independently.  The simulated spectra
% must use the same coherent target and fixed weights as the observation.
data = testCase.TestData.data;
dt = testCase.TestData.dt;
rate = testCase.TestData.sedimentationRate;
limit = testCase.TestData.maximumFrequency;
seed = 149;
nsim = 3;

[corrCI,corrH0,corry,details] = corrcoefslices_rankNew( ...
    data,testCase.TestData.orbit9,dt,testCase.TestData.pad, ...
    rate,rate,1,0,0,nsim,0,1,'Pearson',1/(2*dt),0,false, ...
    'fixed9','MaxFrequency',limit,'Seed',seed, ...
    'ShowPeriodograms',false);

verifySize(testCase,corry,[1 nsim]);
verifyTrue(testCase,all(isfinite(corry),'all'));
verifyTrue(testCase,all(isfinite(corrH0(:,[1 3])),'all'));
verifyEqual(testCase,details.nSimValid,nsim);
verifyEqual(testCase,details.nullMax,max(corry,[],1)', ...
    'AbsTol',2e-14);

rngState = rng;
cleanup = onCleanup(@()rng(rngState));
rng(seed,'twister');
[frequency,power] = redNoisePeriodogramMC( ...
    data,details.rhoM,nsim,0,testCase.TestData.pad, ...
    'BatchSize',nsim,'UseParallel',false,'Slices',1);
expected = cocoAdaptiveEvaluate( ...
    power,data,testCase.TestData.pad,frequency,[], ...
    testCase.TestData.orbit9,testCase.TestData.rayleigh,rate,0, ...
    'Pearson','BatchSize',nsim,'RateBounds',[rate rate], ...
    'MaxFrequency',limit,'TargetModel','coherent-nine', ...
    'AmplitudeMode','fixed');
verifyEqual(testCase,corry,expected,'AbsTol',2e-13);
verifyEqual(testCase,corrCI(1,1),rate);
clear cleanup
rng(rngState);
end

function testLegacyFixedTargetNumericsRemainUnchanged(testCase)
% Freeze the original Fixed COCO target independently of its production
% implementation.  Adding Fixed COCO9 must not silently alter this mode.
frequency = (0:floor(testCase.TestData.pad/2))' ./ ...
    testCase.TestData.pad;
actual = cocoTargetSpectrum(testCase.TestData.data, ...
    testCase.TestData.pad,testCase.TestData.dataPower, ...
    testCase.TestData.orbit9,frequency, ...
    testCase.TestData.sedimentationRate,'fixed');
expected = legacyFixedTargetReference(testCase.TestData,frequency);

verifyEqual(testCase,actual,expected,'RelTol',2e-12,'AbsTol',1e-13);
end

function testLegacyAdaptiveDefaultRemainsPhaseAveraged(testCase)
% Omitting TargetModel must remain numerically identical to requesting the
% historical phase-averaged evaluator explicitly.
[rhoDefault,pDefault,missingDefault,diagnosticDefault] = ...
    adaptiveEvaluate(testCase,'','');
[rhoExplicit,pExplicit,missingExplicit,diagnosticExplicit] = ...
    adaptiveEvaluate(testCase,'phase-averaged','');

verifyEqual(testCase,rhoDefault,rhoExplicit,'AbsTol',0);
verifyEqual(testCase,pDefault,pExplicit,'AbsTol',0);
verifyEqual(testCase,missingDefault,missingExplicit,'AbsTol',0);
verifyEqual(testCase,diagnosticDefault.frequency, ...
    diagnosticExplicit.frequency,'AbsTol',0);
verifyEqual(testCase,diagnosticDefault.dataPower, ...
    diagnosticExplicit.dataPower,'AbsTol',0);
verifyEqual(testCase,diagnosticDefault.targetPower, ...
    diagnosticExplicit.targetPower,'AbsTol',0);
verifyEqual(testCase,diagnosticDefault.activeOrbit, ...
    diagnosticExplicit.activeOrbit);
verifyEqual(testCase,diagnosticDefault.amplitudes, ...
    diagnosticExplicit.amplitudes,'AbsTol',0);
verifyEqual(testCase,diagnosticDefault.targetModel,'phase-averaged');
verifyEqual(testCase,diagnosticExplicit.targetModel,'phase-averaged');

% Freeze the actual old target construction, rather than only comparing
% two dispatch spellings that could accidentally change together.
[referenceFrequency,referencePower] = phaseAveragedReference( ...
    testCase.TestData,diagnosticDefault.amplitudes);
verifyEqual(testCase,diagnosticDefault.frequency,referenceFrequency, ...
    'AbsTol',2e-14);
verifyEqual(testCase,diagnosticDefault.targetPower,referencePower, ...
    'RelTol',2e-12,'AbsTol',1e-13);
rhoReference = corr(referencePower,diagnosticDefault.dataPower, ...
    'Type','Pearson','Rows','complete');
verifyEqual(testCase,rhoDefault,rhoReference,'AbsTol',2e-12);

data = testCase.TestData.data;
dt = testCase.TestData.dt;
rate = testCase.TestData.sedimentationRate;
[~,~,~,details] = corrcoefslices_rankNew( ...
    data,testCase.TestData.orbit9,dt,testCase.TestData.pad, ...
    rate,rate,1,0,0,0,0,1,'Pearson',1/(2*dt),0,false, ...
    'adaptive','MaxFrequency',testCase.TestData.maximumFrequency, ...
    'Seed',37,'ShowPeriodograms',false);
verifyEqual(testCase,details.targetMode,'adaptive');
verifyEqual(testCase,details.targetConstruction, ...
    ['independent uniform-phase sine/cosine mean PSD templates added ', ...
     'noncoherently with per-spectrum adaptive amplitudes']);
verifyEqual(testCase,details.bandAssignment, ...
    ['one rectangular-window ENBW search band per orbit, clipped at ', ...
     'MaxFrequency; overlapping bins assigned to the nearest orbit']);
end

function [rho,pValue,nMissing,diagnostic] = adaptiveEvaluate( ...
        testCase,targetModel,amplitudeMode)
data = testCase.TestData.data;
rate = testCase.TestData.sedimentationRate;
arguments = {testCase.TestData.dataPower,data,testCase.TestData.pad, ...
    testCase.TestData.dataFrequency,[],testCase.TestData.orbit9, ...
    testCase.TestData.rayleigh,rate,0,'Pearson', ...
    'BatchSize',1,'RateBounds',[rate rate], ...
    'MaxFrequency',testCase.TestData.maximumFrequency};
if ~isempty(targetModel)
    arguments = [arguments,{'TargetModel',targetModel}];
end
if ~isempty(amplitudeMode)
    arguments = [arguments,{'AmplitudeMode',amplitudeMode}];
end
[rho,pValue,nMissing,diagnostic] = cocoAdaptiveEvaluate(arguments{:});
end

function [rho,pValue,nMissing,diagnostic] = fixed9Evaluate( ...
        testCase,dataPower)
data = testCase.TestData.data;
rate = testCase.TestData.sedimentationRate;
[rho,pValue,nMissing,diagnostic] = cocoAdaptiveEvaluate( ...
    dataPower,data,testCase.TestData.pad, ...
    testCase.TestData.dataFrequency,[],testCase.TestData.orbit9, ...
    testCase.TestData.rayleigh,rate,0,'Pearson', ...
    'BatchSize',size(dataPower,2),'RateBounds',[rate rate], ...
    'MaxFrequency',testCase.TestData.maximumFrequency, ...
    'TargetModel','coherent-nine','AmplitudeMode','fixed');
end

function power = legacyFixedTargetReference(data,frequency)
% Historical FREQ2TARGETFIXED formula, kept local so dispatch/helper edits
% cannot make the regression test pass by changing expected and actual.
depth = sort(data.data(:,1));
depth = depth(isfinite(depth));
dz = diff(depth);
dz = dz(isfinite(dz) & dz > 0);
targetSamplingFrequency = data.sedimentationRate/(100*median(dz));
timeKyr = (0:numel(depth)-1)' ./ targetSamplingFrequency;
weights = fixedWeightReference(data.orbit9);
target = zeros(size(timeKyr));
for ii = 1:numel(data.orbit9)
    target = target+weights(ii).*sin(2*pi*timeKyr/data.orbit9(ii));
end
[fullPower,fullFrequency] = periodogram( ...
    detrend(target,1),[],max(ceil(data.pad),numel(depth)), ...
    targetSamplingFrequency);
[fullFrequency,uniqueIndex] = unique(fullFrequency);
fullPower = fullPower(uniqueIndex);
power = interp1(fullFrequency,fullPower,frequency(:),'linear',0);
power(~isfinite(power)) = 0;
end

function weights = fixedWeightReference(periods)
periods = periods(:);
weights = 0.6*ones(size(periods));
weights(periods >= 30 & periods < 80) = 0.8;
weights(periods >= 80) = 1.0;
weights(~isfinite(periods) | periods <= 0) = 0;
end

function [frequency,power] = phaseAveragedReference(data,amplitudes)
n = size(data.data,1);
rate = data.sedimentationRate;
targetSamplingFrequency = rate/(100*data.dt);
timeKyr = (0:n-1)'/targetSamplingFrequency;
powerFull = zeros(floor(data.pad/2)+1,1);
frequencyFull = [];
for ii = 1:numel(data.orbit9)
    sineTerm = detrend(sin(2*pi*timeKyr/data.orbit9(ii)),1);
    cosineTerm = detrend(cos(2*pi*timeKyr/data.orbit9(ii)),1);
    [sinePower,sineFrequency] = periodogram( ...
        sineTerm,[],data.pad,targetSamplingFrequency);
    [cosinePower,cosineFrequency] = periodogram( ...
        cosineTerm,[],data.pad,targetSamplingFrequency);
    if isempty(frequencyFull)
        frequencyFull = sineFrequency;
    end
    if ~isequal(sineFrequency,cosineFrequency)
        error('test_coco9_targets:ReferenceFrequencyMismatch', ...
            'Reference sine/cosine periodogram grids differ.');
    end
    powerFull = powerFull+amplitudes(ii)^2 .* ...
        0.5.*(sinePower+cosinePower);
end
mask = frequencyFull <= data.maximumFrequency + ...
    64*eps(max(1,data.maximumFrequency));
frequency = frequencyFull(mask);
power = powerFull(mask);
end

function verifyNineNominalPeaks(testCase,frequency,power,periods,label)
frequency = frequency(:);
power = power(:);
verifyEqual(testCase,numel(frequency),numel(power), ...
    sprintf('%s target frequency/power sizes differ.',label));
valid = isfinite(frequency) & isfinite(power) & frequency > 0;
frequency = frequency(valid);
power = power(valid);
verifyGreaterThan(testCase,numel(power),3, ...
    sprintf('%s target spectrum is empty.',label));
maximumPower = max(power);
verifyTrue(testCase,isfinite(maximumPower) && maximumPower > 0, ...
    sprintf('%s target spectrum has no positive finite power.',label));
power = power./maximumPower;

% A one-percent height floor rejects zero-padding sidelobes while retaining
% every deliberately represented orbital peak in this equal-power fixture.
isPeak = false(size(power));
isPeak(2:end-1) = power(2:end-1) > power(1:end-2) & ...
    power(2:end-1) >= power(3:end) & power(2:end-1) >= 0.01;
peakIndex = find(isPeak);

[centerFrequency,order] = sort(1./periods(:));
orderedPeriods = periods(order);
edge = [-Inf;(centerFrequency(1:end-1)+centerFrequency(2:end))/2;Inf];
matchedIndex = nan(numel(centerFrequency),1);
for ii = 1:numel(centerFrequency)
    candidate = peakIndex(frequency(peakIndex) >= edge(ii) & ...
        frequency(peakIndex) < edge(ii+1));
    verifyNotEmpty(testCase,candidate,sprintf( ...
        '%s has no distinct peak for the %.6g-kyr orbit.', ...
        label,orderedPeriods(ii)));
    [~,best] = max(power(candidate));
    matchedIndex(ii) = candidate(best);
end

verifyEqual(testCase,numel(unique(matchedIndex)),9, ...
    sprintf('%s does not map the nine orbits to distinct peaks.',label));
shortEccentricity = orderedPeriods >= 80 & orderedPeriods < 200;
verifyEqual(testCase,nnz(shortEccentricity),4);
verifyEqual(testCase,nnz(isfinite(matchedIndex(shortEccentricity))),4, ...
    sprintf('%s does not contain four distinct 80-200 kyr peaks.',label));

% The two close ~100-kyr pairs must be visibly separated, not merely two
% adjacent zero-padded samples on one broad/flat maximum.  A real valley
% below half the lower peak is a stable discriminator for this fixture.
closePair = find(diff(centerFrequency) < 0.001);
verifyEqual(testCase,numel(closePair),2);
for pair = closePair(:)'
    first = matchedIndex(pair);
    second = matchedIndex(pair+1);
    between = min(first,second):max(first,second);
    valley = min(power(between));
    lowerPeak = min(power([first,second]));
    verifyLessThan(testCase,valley,0.5*lowerPeak,sprintf( ...
        ['%s does not visibly separate the %.6g- and %.6g-kyr ', ...
         'target peaks.'],label,orderedPeriods(pair), ...
        orderedPeriods(pair+1)));
end
end
