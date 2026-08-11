function tests = test_public_timeseries_transforms
%TEST_PUBLIC_TIMESERIES_TRANSFORMS Public deterministic core regressions.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
seriesDirectory = fileparts(fileparts(mfilename('fullpath')));
codeDirectory = fileparts(seriesDirectory);
oldPath = path;
addpath(seriesDirectory,'-begin');
addpath(fullfile(codeDirectory,'misc'));
testCase.addTeardown(@()path(oldPath));
testCase.TestData.CodeDirectory = codeDirectory;
end

function testInterpolationAndAmplitudeUseSharedSamplingPolicy(testCase)
data = [10,0,100;11,2,110;13,6,130];
[interpolated,meta] = acycleInterpolateSeries(data,0.5);
grid = (10:0.5:13)';
verifyEqual(testCase,interpolated, ...
    [grid,2*(grid-10),100+10*(grid-10)],'AbsTol',0);
verifyEqual(testCase,meta.OutputRows,7);
verifyTrue(testCase,meta.PreserveAllColumns);

coordinate = (0:31)'/4;
value = sin(2*pi*0.5*coordinate);
[envelope,envelopeMeta] = acycleAmplitudeModulation( ...
    [coordinate,value]);
verifyEqual(testCase,envelope(:,1),coordinate,'AbsTol',0);
verifyEqual(testCase,envelope(:,2),ones(size(coordinate)), ...
    'AbsTol',128*eps(1));
verifyFalse(testCase,envelopeMeta.interpolated);

within = coordinate;
within(16) = within(16)+9e-6*0.25;
[~,withinMeta] = acycleAmplitudeModulation([within,value]);
outside = coordinate;
outside(16) = outside(16)+11e-6*0.25;
[outsideResult,outsideMeta] = acycleAmplitudeModulation( ...
    [outside,value]);
verifyFalse(testCase,withinMeta.interpolated);
verifyTrue(testCase,outsideMeta.interpolated);
verifyEqual(testCase,outsideMeta.irregularity_tolerance,1e-5, ...
    'AbsTol',0);
verifyEqual(testCase,outsideResult(:,1),coordinate,'AbsTol',0);
end

function testFixedCountAndFixedBandwidthSummaries(testCase)
data = [[0;0.001;2;70;1000],[10;1;7;20;-4]];
twoPoint = acycleFixedCountMovingSummary(data,'mean',2);
threePoint = acycleFixedCountMovingSummary(data,'median',3);
verifyEqual(testCase,twoPoint(:,2),[5.5;4;13.5;8;-4], ...
    'AbsTol',32*eps(20));
verifyEqual(testCase,twoPoint(:,3),[2;2;2;2;1]);
verifyEqual(testCase,threePoint(:,2),[5.5;7;7;7;8], ...
    'AbsTol',0);
verifyEqual(testCase,movemean(data(:,2),2),twoPoint(:,2), ...
    'AbsTol',0);

bandData = [0,1;0.5,2;1.5,5;2,7;3,3;4,8];
options = struct('window_length',2,'step',1, ...
    'endpoint_policy','complete','alpha',0.05);
meanResult = acycleFixedBandwidthSummary( ...
    bandData,'mean',options);
verifyEqual(testCase,meanResult(:,1),[1;2;3],'AbsTol',0);
verifyEqual(testCase,meanResult(:,2),[3.75;5;6], ...
    'AbsTol',2e-15);
verifyEqual(testCase,meanResult(:,3),[91/12;4;7], ...
    'AbsTol',2e-15);
verifyEqual(testCase,meanResult(:,4),[4;3;3],'AbsTol',0);

[centers,means,variances,counts,lower,upper,medians] = ...
    movmeanfbw(bandData,2,1,0,0.05,0);
verifyEqual(testCase,centers,meanResult(:,1),'AbsTol',0);
verifyEqual(testCase,means,meanResult(:,2),'AbsTol',0);
verifyEqual(testCase,variances,meanResult(:,3),'AbsTol',0);
verifyEqual(testCase,counts,meanResult(:,4),'AbsTol',0);
verifyEqual(testCase,lower,meanResult(:,5),'AbsTol',0);
verifyEqual(testCase,upper,meanResult(:,6),'AbsTol',0);
verifyEqual(testCase,medians,[3.5;5;7],'AbsTol',0);
end

function testGaussianMovingAverageUsesSampleIndexWeights(testCase)
coordinate = [0;0.2;1.1;4;9;15;22];
value = [2;-1;4;8;-3;5;7];
[result,meta] = acycleGaussianMovingAverage( ...
    [coordinate,value],5);
verifyEqual(testCase,result(:,1),coordinate,'AbsTol',0);
verifyEqual(testCase,result(:,2),gaussianReference(value,5), ...
    'AbsTol',64*eps(8));
verifyEqual(testCase,result(:,3),[3;4;5;5;5;4;3]);
verifyFalse(testCase,meta.coordinate_used_for_weights);
verifyEqual(testCase,meta.weight_domain,'sample_index');
end

function testEvolutionaryRhoAndSedimentationIntegration(testCase)
coordinate = (0:4)';
[rho,meta] = acycleEvolutionaryRho1( ...
    [coordinate,coordinate.^2],1,3);
verifyEqual(testCase,rho,[1,-0.8;2,-0.8;3,-0.8], ...
    'AbsTol',4e-15);
verifyEqual(testCase,meta.window_points,3);
verifyEqual(testCase,meta.effective_window_span,2,'AbsTol',0);

rates = [10,5;10.5,10;11.5,20;12,999];
[ages,ageMeta] = acycleSedimentationRateAgeModel( ...
    rates,'m',100);
verifyEqual(testCase,ages(:,2),[100;110;120;122.5],'AbsTol',0);
verifyEqual(testCase,ageMeta.integration_rule, ...
    'piecewise-constant-left-endpoint-rate');
verifyFalse(testCase,ageMeta.last_rate_used);
end

function testCircularSpectrumAndCompatibilityWrapper(testCase)
events = [0;1;3;6];
[result,meta] = acycleCircularSpectrum( ...
    events,0.5,4,5,'linear');
expected = circularReference(events,linspace(0.5,4,5)');
verifyEqual(testCase,result,expected,'AbsTol',2e-15);
verifyEqual(testCase,meta.analysis_scope, ...
    'deterministic-vector-strength-only');

[period,strength,phase] = circularspec( ...
    flipud(events),0.5,4,5,2,0);
verifyEqual(testCase,[period(:),strength(:),phase(:)],result, ...
    'AbsTol',2e-15);
end

function testLeadLagAndHistoricalPrewhitenDirection(testCase)
coordinate = (0:39)';
referenceValue = sin(2*pi*coordinate/10)+ ...
    0.37*cos(2*pi*coordinate/5);
reference = [coordinate,referenceValue];
target = [coordinate,sin(2*pi*(coordinate-2)/10)+ ...
    0.37*cos(2*pi*(coordinate-2)/5)];
[result,lagMeta] = acycleLeadLagRmse( ...
    reference,target,4,1,'small_is_young');
verifyEqual(testCase,result(:,1),(-4:4)','AbsTol',0);
verifyEqual(testCase,lagMeta.best_lag,-2,'AbsTol',0);
verifyLessThan(testCase,lagMeta.best_standardized_rmse,1e-14);

data = [10,1;20,2;30,4;40,8];
[whitened,whiteMeta] = acyclePrewhitenSeries( ...
    data,struct('rho_source','user','rho',0.5));
verifyEqual(testCase,whitened,[10,0;20,0;30,0],'AbsTol',0);
verifyEqual(testCase,whiteMeta.formula,'y(i)-rho*y(i+1)');
verifyEqual(testCase,whiteMeta.physical_nyquist,0.05,'AbsTol',0);
end

function testDesktopCallersDelegateToPublicCores(testCase)
codeDirectory = testCase.TestData.CodeDirectory;
acSource = fileread(fullfile(codeDirectory,'guicode','AC.m'));
prewhitenSource = fileread(fullfile( ...
    codeDirectory,'guicode','prewhitenGUI.m'));
leadLagSource = fileread(fullfile( ...
    codeDirectory,'guicode','leadlagGUI.m'));

tokens = {'acycleAmplitudeModulation(','acycleEvolutionaryRho1(', ...
    'acycleFixedBandwidthSummary(', ...
    'acycleFixedCountMovingSummary(', ...
    'acycleGaussianMovingAverage(', ...
    'acycleSedimentationRateAgeModel('};
for index = 1:numel(tokens)
    verifyTrue(testCase,contains(acSource,tokens{index}));
end
verifyTrue(testCase,contains(prewhitenSource, ...
    'acyclePrewhitenSeries('));
verifyTrue(testCase,contains(prewhitenSource, ...
    'acycleSamplingIsUneven('));
verifyTrue(testCase,contains(leadLagSource,'acycleLeadLagRmse('));
end

function expected = gaussianReference(value,window)
value = double(value(:));
count = numel(value);
halfWindow = floor(window/2);
if mod(window,2) == 1
    offsets = -halfWindow:halfWindow;
else
    offsets = -halfWindow:(halfWindow-1);
end
sigma = window/5;
expected = zeros(count,1);
for row = 1:count
    indices = row+offsets;
    valid = indices >= 1 & indices <= count;
    selectedOffsets = offsets(valid);
    weights = exp(-(selectedOffsets.^2)/(2*sigma^2));
    weights = weights/sum(weights);
    expected(row) = weights*value(indices(valid));
end
end

function expected = circularReference(events,period)
expected = zeros(numel(period),3);
for index = 1:numel(period)
    angleValue = 2*pi*mod(events,period(index))/period(index);
    sineMean = mean(sin(angleValue));
    cosineMean = mean(cos(angleValue));
    strength = hypot(sineMean,cosineMean);
    if strength <= 64*eps(1)
        phase = 0;
    else
        phase = mod(period(index)*atan2( ...
            sineMean,cosineMean)/(2*pi),period(index));
    end
    expected(index,:) = [period(index),strength,phase];
end
end
