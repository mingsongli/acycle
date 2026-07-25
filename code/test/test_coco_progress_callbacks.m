function tests = test_coco_progress_callbacks
%TEST_COCO_PROGRESS_CALLBACKS Determinate progress for standalone COCO.
%
% Progress callbacks are part of the GUI contract: each run starts at 0,
% ends at 1, remains monotone and reports at least one completed fraction
% strictly between those endpoints.  Installing a callback must not alter
% any numerical result or consume random numbers.

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
sedimentationRate = 4;
timeKyr = (0:2:1600)';
depth = timeKyr*sedimentationRate/100;
amplitudes = [1.00;0.96;0.92;0.88;0.84;0.80;0.76;0.72;0.68];
phases = [0.10;0.70;1.40;2.20;2.80;0.40;1.10;1.90;2.50];
signal = zeros(size(timeKyr));
for orbitIndex = 1:numel(orbit9)
    signal = signal+amplitudes(orbitIndex)*sin( ...
        2*pi*timeKyr/orbit9(orbitIndex)+phases(orbitIndex));
end
% A deterministic non-orbital component prevents the fixture from being
% an unrealistically exact target without making the test stochastic.
signal = signal+0.08*sin(2*pi*timeKyr/61.3)+0.002*depth;

testCase.TestData.data = [depth,signal];
testCase.TestData.orbit9 = orbit9;
testCase.TestData.rate = sedimentationRate;
testCase.TestData.dt = median(diff(depth));
testCase.TestData.pad = 2048;
testCase.TestData.maxFrequency = 0.06;
testCase.TestData.nsim = 3;
testCase.TestData.seed = 2701;
end

function testCvCoco9BProgressIsDeterminateAndNumericallyPassive(testCase)
fractions = zeros(0,1);
messages = cell(0,1);
callbackRandomDraws = zeros(0,2);
args = cvArguments(testCase);
entryRandomState = rng;
restoreRandomState = onCleanup(@()rng(entryRandomState));
rng(9101,'twister');
expectedCallerState = rng;

withoutCallback = cvcoco9B(args{:});
verifyEqual(testCase,rng,expectedCallerState, ...
    'cvCOCO9B without a callback changed the caller RNG state.');
withCallback = cvcoco9B(args{:},'ProgressFcn',@captureProgress);
verifyEqual(testCase,rng,expectedCallerState, ...
    ['cvCOCO9B did not isolate random numbers consumed by its ', ...
     'progress callback.']);

verifyProgressTrace(testCase,fractions,messages,'cvCOCO9B');
verifySize(testCase,callbackRandomDraws,[numel(fractions),2]);
verifyEqual(testCase,withCallback.trainA.curve, ...
    withoutCallback.trainA.curve,'AbsTol',0);
verifyEqual(testCase,withCallback.trainB.curve, ...
    withoutCallback.trainB.curve,'AbsTol',0);
verifyEqual(testCase,withCallback.validateAtoB.curve, ...
    withoutCallback.validateAtoB.curve,'AbsTol',0);
verifyEqual(testCase,withCallback.validateBtoA.curve, ...
    withoutCallback.validateBtoA.curve,'AbsTol',0);
verifyEqual(testCase,withCallback.nullAtoB, ...
    withoutCallback.nullAtoB,'AbsTol',0);
verifyEqual(testCase,withCallback.nullBtoA, ...
    withoutCallback.nullBtoA,'AbsTol',0);
verifyEqual(testCase,withCallback.nullSymmetric, ...
    withoutCallback.nullSymmetric,'AbsTol',0);
verifyEqual(testCase,withCallback.pAtoB,withoutCallback.pAtoB, ...
    'AbsTol',0);
verifyEqual(testCase,withCallback.pBtoA,withoutCallback.pBtoA, ...
    'AbsTol',0);
verifyEqual(testCase,withCallback.pSym,withoutCallback.pSym,'AbsTol',0);

    function captureProgress(fraction,message)
        fractions(end+1,1) = fraction;
        messages{end+1,1} = char(string(message));
        % A GUI callback is arbitrary caller code and may itself use the
        % global stream. The numerical engine must isolate these draws.
        callbackRandomDraws(end+1,:) = [rand,randn];
    end
end

function testAdaptiveAndFixedCocoProgressIsDeterminate(testCase)
targetModes = {'adaptive9b','fixed9'};
entryRandomState = rng;
restoreRandomState = onCleanup(@()rng(entryRandomState));
for modeIndex = 1:numel(targetModes)
    targetMode = targetModes{modeIndex};
    fractions = zeros(0,1);
    messages = cell(0,1);
    callbackRandomDraws = zeros(0,2);
    args = sliceArguments(testCase,targetMode);
    rng(9200+modeIndex,'twister');
    expectedCallerState = rng;

    [corrWithout,pWithout,nullWithout,detailsWithout] = ...
        corrcoefslices_rankNew(args{:});
    verifyEqual(testCase,rng,expectedCallerState,sprintf( ...
        '%s without a callback changed the caller RNG state.',targetMode));
    [corrWith,pWith,nullWith,detailsWith] = ...
        corrcoefslices_rankNew(args{:},'ProgressFcn',@captureProgress);
    verifyEqual(testCase,rng,expectedCallerState,sprintf( ...
        '%s did not isolate callback random-number use.',targetMode));

    verifyProgressTrace(testCase,fractions,messages,targetMode);
    verifySize(testCase,callbackRandomDraws,[numel(fractions),2]);
    verifyEqual(testCase,corrWith,corrWithout,'AbsTol',0);
    verifyEqual(testCase,pWith,pWithout,'AbsTol',0);
    % Reporting progress must not change the streaming batch width or any
    % realized Monte Carlo statistic.
    verifyEqual(testCase,nullWith,nullWithout,'AbsTol',0);
    verifyEqual(testCase,detailsWith.nullMax,detailsWithout.nullMax, ...
        'AbsTol',0);
    verifyEqual(testCase,detailsWith.nSimCompleted, ...
        detailsWithout.nSimCompleted);
    verifyEqual(testCase,detailsWith.nSimValid,detailsWithout.nSimValid);
end

    function captureProgress(fraction,message)
        fractions(end+1,1) = fraction;
        messages{end+1,1} = char(string(message));
        callbackRandomDraws(end+1,:) = [rand,randn];
    end
end

function args = cvArguments(testCase)
d = testCase.TestData;
args = {d.data,d.orbit9,d.pad,d.rate,d.rate,1,0,d.nsim, ...
    'Pearson','BatchSize',1,'Seed',d.seed, ...
    'MaxFrequency',d.maxFrequency};
end

function args = sliceArguments(testCase,targetMode)
d = testCase.TestData;
args = {d.data,d.orbit9,d.dt,d.pad,d.rate,d.rate,1,0,0,d.nsim, ...
    0,1,'Pearson',1/(2*d.dt),0,false,targetMode, ...
    'MaxFrequency',d.maxFrequency,'Seed',d.seed, ...
    'ShowPeriodograms',false};
end

function verifyProgressTrace(testCase,fractions,messages,label)
verifyNotEmpty(testCase,fractions,sprintf('%s did not report progress.',label));
verifyEqual(testCase,fractions(1),0,'AbsTol',0, ...
    sprintf('%s progress must begin at zero.',label));
verifyEqual(testCase,fractions(end),1,'AbsTol',0, ...
    sprintf('%s progress must end at one.',label));
verifyGreaterThanOrEqual(testCase,fractions,0, ...
    sprintf('%s reported progress below zero.',label));
verifyLessThanOrEqual(testCase,fractions,1, ...
    sprintf('%s reported progress above one.',label));
verifyGreaterThanOrEqual(testCase,diff(fractions),0, ...
    sprintf('%s progress moved backwards.',label));
verifyTrue(testCase,any(fractions > 0 & fractions < 1), ...
    sprintf('%s did not report a completed intermediate fraction.',label));
verifyEqual(testCase,numel(messages),numel(fractions));
verifyTrue(testCase,all(~cellfun('isempty',messages)), ...
    sprintf('%s emitted an empty progress message.',label));
end
