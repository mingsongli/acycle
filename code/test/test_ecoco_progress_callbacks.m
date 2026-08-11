function tests = test_ecoco_progress_callbacks
%TEST_ECOCO_PROGRESS_CALLBACKS Determinate progress must be observational.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
addpath(genpath(fullfile(repoRoot,'code')));
testCase.addTeardown(@()path(oldPath));
end

function testAdaptiveCoreProgressIsDeterminateAndObservational(testCase)
args = adaptiveArguments();
rng(9301,'twister');
externalState = rng;
withoutCallback = ecocoAdaptiveCore(args{:});
verifyEqual(testCase,rng,externalState, ...
    'Adaptive eCOCO changed the caller RNG without a callback.');
rng(externalState);
[withCallback,fractions,messages] = runAdaptiveWithProgress(args);
verifyEqual(testCase,rng,externalState, ...
    'Adaptive eCOCO exposed callback RNG consumption to its caller.');

verifyTrue(testCase,isequaln(withCallback,withoutCallback), ...
    'Installing a progress callback changed an Adaptive eCOCO result.');
verifyStreamlinedProgress(testCase,fractions,messages,'monte carlo');
end

function testCrossfitCoreProgressIsDeterminateAndObservational(testCase)
args = crossfitArguments();
rng(9302,'twister');
externalState = rng;
withoutCallback = ecocoCrossfitCore(args{:});
verifyEqual(testCase,rng,externalState, ...
    'Blocked eCOCO changed the caller RNG without a callback.');
rng(externalState);
[withCallback,fractions,messages] = runCrossfitWithProgress(args);
verifyEqual(testCase,rng,externalState, ...
    'Blocked eCOCO exposed callback RNG consumption to its caller.');

verifyTrue(testCase,isequaln(withCallback,withoutCallback), ...
    'Installing a progress callback changed a Blocked eCOCO result.');
verifyStreamlinedProgress(testCase,fractions,messages,'window work');
end

function testInterleavedCoreProgressIsDeterminateAndObservational(testCase)
args = interleavedArguments();
rng(9304,'twister');
externalState = rng;
withoutCallback = ecocoInterleavedCore(args{:});
verifyEqual(testCase,rng,externalState, ...
    'Interleaved eCOCO changed the caller RNG without a callback.');
rng(externalState);
[withCallback,fractions,messages] = runInterleavedWithProgress(args);
verifyEqual(testCase,rng,externalState, ...
    'Interleaved eCOCO exposed callback RNG consumption to its caller.');

verifyTrue(testCase,isequaln(withCallback,withoutCallback), ...
    'Installing a progress callback changed an Interleaved eCOCO result.');
verifyStreamlinedProgress(testCase,fractions,messages,'monte carlo work');
end

function testEcocoWrapperProgressIsDeterminateAndObservational(testCase)
args = wrapperArguments();
withoutCallback = cell(1,10);
rng(9303,'twister');
externalState = rng;
[withoutCallback{:}] = ecoco(args{:});
verifyEqual(testCase,rng,externalState, ...
    'The eCOCO wrapper changed the caller RNG without a callback.');
rng(externalState);
[withCallback,fractions,messages] = runWrapperWithProgress(args);
verifyEqual(testCase,rng,externalState, ...
    'The eCOCO wrapper exposed callback RNG consumption to its caller.');

for outputIndex = 1:numel(withoutCallback)
    verifyTrue(testCase,isequaln( ...
        withCallback{outputIndex},withoutCallback{outputIndex}), ...
        sprintf(['Installing a progress callback changed eCOCO output ', ...
        '%d.'],outputIndex));
end
verifyStreamlinedProgress(testCase,fractions,messages,'monte carlo');
end

function testEcocoWrapperVerboseControlsPreprocessing(testCase)
for calcMode = {'adaptive','crossfit'}
    args = wrapperArguments(calcMode{1});
    data = args{1};
    % Force the shared modern preprocessing path to report cleaning while
    % preserving the regularized series used by the numerical comparison.
    args{1} = [data(end:-1:1,:); data(17,:); NaN,data(18,2)]; %#ok<NASGU>

    loudOutputs = cell(1,10);
    rng(9305,'twister');
    externalState = rng;
    loudText = evalc( ...
        '[loudOutputs{:}] = ecoco(args{:},''Verbose'',true);');
    verifyEqual(testCase,rng,externalState,sprintf( ...
        '%s eCOCO changed the caller RNG in verbose mode.',calcMode{1}));
    verifyTrue(testCase,contains(loudText, ...
        'Full-record COCO/eCOCO preprocessing'),sprintf( ...
        '%s eCOCO did not exercise preprocessing diagnostics.',calcMode{1}));

    quietOutputs = cell(1,10);
    rng(externalState);
    quietText = evalc( ...
        '[quietOutputs{:}] = ecoco(args{:},''Verbose'',false);');
    verifyEqual(testCase,rng,externalState,sprintf( ...
        '%s eCOCO changed the caller RNG in quiet mode.',calcMode{1}));
    verifyFalse(testCase,contains(quietText, ...
        'Full-record COCO/eCOCO preprocessing'),sprintf( ...
        '%s eCOCO ignored Verbose=false during preprocessing.',calcMode{1}));
    verifyEmpty(testCase,strtrim(quietText),sprintf( ...
        '%s eCOCO emitted diagnostics despite Verbose=false.',calcMode{1}));

    for outputIndex = 1:numel(loudOutputs)
        verifyTrue(testCase,isequaln( ...
            quietOutputs{outputIndex},loudOutputs{outputIndex}),sprintf( ...
            ['Verbose changed %s eCOCO output %d instead of changing ', ...
             'diagnostics only.'],calcMode{1},outputIndex));
    end
end
end

function args = adaptiveArguments()
periods = defaultPeriods();
dt = 0.2;
depth = (0:dt:100)';
timeKyr = depth*100/5;
value = orbitalSignal(timeKyr,periods);
args = {[depth,value],periods,40.5,dt,50,0,256,(4:6)', ...
    2,'Pearson',0.06,1847,'BatchSimulations',1};
end

function args = crossfitArguments()
periods = defaultPeriods();
dt = 0.04;
depth = (0:2000)'*dt;
timeKyr = depth*100/4;
value = orbitalSignal(timeKyr,periods);
args = {[depth,value],periods,20,dt,125,0,1024, ...
    [3.8;4.0;4.2],2,'Pearson',0.06,2718,0.5, ...
    'BatchSize',1,'ComputeLocalP',true,'MemoryBudgetMiB',64};
end

function args = interleavedArguments()
periods = defaultPeriods();
dt = 0.15;
depth = (0:178)'*dt;
timeKyr = depth*100/4;
value = orbitalSignal(timeKyr,periods);
args = {[depth,value],periods,20,dt,45,0,256, ...
    [3.8;4.0;4.2],2,'Pearson',0.06,2718,'BatchSize',1};
end

function args = wrapperArguments(calcMode)
if nargin < 1
    calcMode = 'adaptive';
end
coreArguments = adaptiveArguments();
data = coreArguments{1};
periods = coreArguments{2};
dt = coreArguments{4};
args = {data,[],periods,40.5,dt,50,0,0,256,4,6,1,2,0,[], ...
    0,'Pearson',1/(2*dt),0,calcMode,0.06,1847,0.5};
end

function value = orbitalSignal(timeKyr,periods)
value = zeros(size(timeKyr));
for periodIndex = 1:numel(periods)
    value = value + sin(2*pi*timeKyr/periods(periodIndex) + ...
        0.17*periodIndex);
end
value = value + 0.07*sin(2*pi*timeKyr/71.3) + ...
    0.02*cos(2*pi*timeKyr/33.7);
end

function periods = defaultPeriods()
periods = [405.6912;130.6979;123.8532;98.8517;94.8856; ...
    40.9897;23.6820;22.3758;18.9519];
end

function [result,fractions,messages] = runAdaptiveWithProgress(args)
fractions = zeros(0,1);
messages = strings(0,1);
result = ecocoAdaptiveCore(args{:},'ProgressFcn',@captureProgress);

    function captureProgress(fraction,message)
        callbackDraw = [rand(1,3),randn(1,2)]; %#ok<NASGU>
        fractions(end+1,1) = fraction;
        messages(end+1,1) = string(message);
    end
end

function [result,fractions,messages] = runCrossfitWithProgress(args)
fractions = zeros(0,1);
messages = strings(0,1);
result = ecocoCrossfitCore(args{:},'ProgressFcn',@captureProgress);

    function captureProgress(fraction,message)
        callbackDraw = [rand(1,3),randn(1,2)]; %#ok<NASGU>
        fractions(end+1,1) = fraction;
        messages(end+1,1) = string(message);
    end
end

function [result,fractions,messages] = runInterleavedWithProgress(args)
fractions = zeros(0,1);
messages = strings(0,1);
result = ecocoInterleavedCore(args{:},'ProgressFcn',@captureProgress);

    function captureProgress(fraction,message)
        callbackDraw = [rand(1,3),randn(1,2)]; %#ok<NASGU>
        fractions(end+1,1) = fraction;
        messages(end+1,1) = string(message);
    end
end

function [outputs,fractions,messages] = runWrapperWithProgress(args)
fractions = zeros(0,1);
messages = strings(0,1);
outputs = cell(1,10);
[outputs{:}] = ecoco(args{:},'ProgressFcn',@captureProgress);

    function captureProgress(fraction,message)
        callbackDraw = [rand(1,3),randn(1,2)]; %#ok<NASGU>
        fractions(end+1,1) = fraction;
        messages(end+1,1) = string(message);
    end
end

function verifyStreamlinedProgress(testCase,fractions,messages,expectedLabel)
verifyNotEmpty(testCase,fractions);
verifyEqual(testCase,numel(messages),numel(fractions));
verifyTrue(testCase,all(isfinite(fractions)));
verifyGreaterThanOrEqual(testCase,fractions,0);
verifyLessThanOrEqual(testCase,fractions,1);
verifyGreaterThanOrEqual(testCase,diff(fractions),0);
verifyEqual(testCase,fractions(1),0,'AbsTol',0);
verifyEqual(testCase,fractions(end),1,'AbsTol',0);
verifyGreaterThan(testCase,numel(fractions),2);
intermediate = lower(messages(2:end-1));
verifyTrue(testCase,all(contains(intermediate,expectedLabel)), ...
    'Intermediate progress updates must identify one primary work unit.');
verifyFalse(testCase,any(contains(intermediate,'equivalent')), ...
    'Progress text must not expose equivalent-window bookkeeping.');
end
