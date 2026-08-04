function tests = test_coco_shared_preprocessing
%TEST_COCO_SHARED_PREPROCESSING Shared full-record input contract.
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
end

function testSharedHelperCleansDeduplicatesAndInterpolates(testCase)
raw = [ ...
    4,4; ...
    2,2; ...
    NaN,8; ...
    0,0; ...
    2,4; ...
    1,1];

[data,info,clean] = cocoPrepareRegularData( ...
    raw,'unit test','Verbose',false);

verifyEqual(testCase,clean(:,1),[0;1;2;4]);
verifyEqual(testCase,clean(:,2),[0;1;3;4]);
verifyEqual(testCase,data(:,1),(0:4)');
verifyEqual(testCase,data(:,2),[0;1;3;3.5;4], ...
    'AbsTol',16*eps);
verifyEqual(testCase,info.originalRowCount,6);
verifyEqual(testCase,info.finiteRowCount,5);
verifyEqual(testCase,info.nonfiniteRowsRemoved,1);
verifyEqual(testCase,info.duplicateRowsCollapsed,1);
verifyTrue(testCase,info.interpolationApplied);
verifyEqual(testCase,info.spacingMedian,1);
verifyEqual(testCase,info.outputSpacing,1);
end

function testDirectFullCocoMatchesExplicitPreprocessing(testCase)
[regular,raw,periods,dt] = syntheticIrregularInput();
[prepared,preparation] = cocoPrepareRegularData( ...
    raw,'explicit COCO test','Verbose',false);
verifyTrue(testCase,preparation.interpolationApplied);
verifyEqual(testCase,prepared(:,1),regular(:,1),'AbsTol',2e-12);

[corrAuto,h0Auto,mcAuto,detailsAuto] = corrcoefslices_rankNew( ...
    raw,periods,0.37,1024,3,7,1,0,0,0,0,1,'Pearson', ...
    1/(2*dt),0,false,'adaptive9b','MaxFrequency',0.06, ...
    'ShowPeriodograms',false);
[corrExplicit,h0Explicit,mcExplicit] = corrcoefslices_rankNew( ...
    prepared,periods,preparation.outputSpacing,1024,3,7,1, ...
    0,0,0,0,1,'Pearson',1/(2*dt),0,false,'adaptive9b', ...
    'MaxFrequency',0.06,'ShowPeriodograms',false);

verifyEqual(testCase,corrAuto,corrExplicit,'AbsTol',2e-12);
verifyTrue(testCase,isequaln(h0Auto,h0Explicit));
verifyTrue(testCase,isequaln(mcAuto,mcExplicit));
verifyTrue(testCase,detailsAuto.inputPreprocessing.interpolationApplied);
verifyEqual(testCase,detailsAuto.requestedSamplingInterval,0.37);
verifyEqual(testCase,detailsAuto.samplingInterval,dt,'AbsTol',2e-12);
end

function testDirectModernEcocoMatchesExplicitPreprocessing(testCase)
[~,raw,periods,dt] = syntheticIrregularInput();
[prepared,preparation] = cocoPrepareRegularData( ...
    raw,'explicit eCOCO test','Verbose',false);

argumentsAuto = {raw,[],periods,40.4,0.37,75,0,0,256, ...
    4,6,1,0,0,[],0,'Pearson',1/(2*dt),0, ...
    'adaptive',0.06,17,0.5,'Verbose',false};
argumentsExplicit = argumentsAuto;
argumentsExplicit{1} = prepared;
argumentsExplicit{5} = preparation.outputSpacing;

auto = cell(1,10);
explicit = cell(1,10);
[auto{:}] = ecoco(argumentsAuto{:});
[explicit{:}] = ecoco(argumentsExplicit{:});
for outputIndex = 1:9
    verifyTrue(testCase,isequaln(auto{outputIndex},explicit{outputIndex}), ...
        sprintf('eCOCO output %d changed after implicit preprocessing.', ...
        outputIndex));
end
detailsAuto = auto{10};
verifyTrue(testCase,detailsAuto.inputPreprocessing.interpolationApplied);
verifyEqual(testCase,detailsAuto.requestedSamplingInterval,0.37);
verifyEqual(testCase,detailsAuto.samplingInterval,dt,'AbsTol',2e-12);
verifyEqual(testCase,detailsAuto.rho,explicit{10}.rho,'AbsTol',0);
end

function testCoreAndHelperUseSameUniformityTolerance(testCase)
periods = defaultPeriods();
dt = 0.2;
depth = (0:dt:100)';
depth(251) = depth(251)+5e-9;
timeKyr = depth*100/5;
value = orbitalSignal(timeKyr,periods);
data = [depth,value];

[prepared,info] = cocoPrepareRegularData( ...
    data,'tolerance test','Verbose',false);
verifyFalse(testCase,info.interpolationApplied);
verifyEqual(testCase,prepared,data,'AbsTol',0);

result = ecocoAdaptiveCore(data,periods,40.4,dt,75,0,256, ...
    (4:6)',0,'Pearson',0.06,19);
verifyNotEmpty(testCase,result.rho);
end

function testNineDigitSerializedGridIsNotInterpolated(testCase)
depth = 289.816514+(0:518)'.*3.9;
depth = arrayfun(@(value)str2double(sprintf('%.9g',value)),depth);
data = [depth,sin(2*pi*depth/97)];

[prepared,info] = cocoPrepareRegularData( ...
    data,'serialized regular grid','Verbose',false);

verifyFalse(testCase,info.interpolationApplied);
verifyEqual(testCase,prepared,data,'AbsTol',0);
verifyEqual(testCase,info.uniformityTolerance,3.9e-5,'RelTol',1e-12);
end

function testElevenPpmGridIsStillInterpolated(testCase)
dt = 3.9;
depth = (0:127)'.*dt;
depth(64) = depth(64)+11e-6*dt;
data = [depth,sin(2*pi*depth/97)];

[~,info] = cocoPrepareRegularData( ...
    data,'materially uneven grid','Verbose',false);

verifyTrue(testCase,info.interpolationApplied);
verifyGreaterThan(testCase,info.maximumSpacingDeviation, ...
    info.uniformityTolerance);
end

function testAdaptiveEvaluatorAcceptsSerializedRegularDepth(testCase)
depth = 289.816514+(0:518)'.*3.9;
depth = arrayfun(@(value)str2double(sprintf('%.9g',value)),depth);
data = [depth,sin(2*pi*depth/97)];
pad = 1024;
dt = median(diff(depth));
frequency = (0:floor(pad/2))'/(pad*dt);
power = ones(size(frequency));
periods = defaultPeriods();
rayleigh = enbw(rectwin(numel(depth)),1/dt);

rho = cocoAdaptiveEvaluate(power,data,pad,frequency,[],periods, ...
    rayleigh,[50;51],[],'Pearson');

verifySize(testCase,rho,[2 1]);
verifyEqual(testCase,rho,zeros(2,1),'AbsTol',0);
end

function [regular,raw,periods,dt] = syntheticIrregularInput()
periods = defaultPeriods();
dt = 0.2;
depth = (0:dt:100)';
timeKyr = depth*100/5;
value = orbitalSignal(timeKyr,periods)+0.08*cos(2*pi*depth/7.3);
regular = [depth,value];

keep = true(size(depth));
keep([101,203,307,409]) = false;
raw = regular(keep,:);
duplicate = raw(180,:);
raw = flipud([raw;duplicate;NaN,NaN]);
end

function periods = defaultPeriods()
periods = [405.6912;130.6979;123.8532;98.8517;94.8856; ...
    40.9897;23.6820;22.3758;18.9519];
end

function value = orbitalSignal(timeKyr,periods)
weights = [1;.7;.65;.6;.55;.8;.5;.45;.4];
value = sum(sin(2*pi*timeKyr./periods').*weights',2);
end
