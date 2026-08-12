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

function testEmpiricalModeDecompositionContract(testCase)
coordinate = (0:95)'/8;
value = sin(2*pi*coordinate/3)+ ...
    0.25*cos(2*pi*coordinate/8)+0.01*coordinate;
data = [coordinate,value];
options = struct('method','emd','max_num_imf',5, ...
    'max_num_extrema',1,'interpolation','pchip');

[result,meta] = acycleEmpiricalModeDecomposition(data,options);
[expectedImfs,expectedResidual] = emd(value, ...
    'MaxNumIMF',5,'MaxNumExtrema',1, ...
    'Interpolation','pchip','Display',false);

verifyEqual(testCase,result.coordinate,coordinate,'AbsTol',0);
verifyEqual(testCase,result.input,value,'AbsTol',0);
verifyEqual(testCase,result.imfs,expectedImfs,'AbsTol',0);
verifyEqual(testCase,result.residual,expectedResidual,'AbsTol',0);
verifyEqual(testCase,result.reconstruction, ...
    sum(result.imfs,2)+result.residual,'AbsTol',0);
verifyEqual(testCase,result.reconstruction,value, ...
    'AbsTol',1e-12*max(1,max(abs(value))));
verifyEqual(testCase,meta.method,'emd');
verifyEqual(testCase,meta.sample_interval,1/8,'AbsTol',0);
verifyEqual(testCase,meta.actual_decomposition_count,1);
verifyEqual(testCase,meta.raw_variance,var(value,0,1), ...
    'RelTol',4*eps(1));
verifyEqual(testCase,meta.component_variance_sum, ...
    sum(result.component_variance),'AbsTol',0);
verifyEqual(testCase,meta.covariance_gap, ...
    meta.raw_variance-meta.component_variance_sum,'AbsTol',0);
verifyFalse(testCase,meta.file_io);
verifyFalse(testCase,meta.graphics);

constant = [coordinate,ones(size(coordinate))];
[constantResult,constantMeta] = ...
    acycleEmpiricalModeDecomposition(constant,options);
verifySize(testCase,constantResult.imfs,[numel(coordinate),0]);
verifyEqual(testCase,constantResult.residual,constant(:,2),'AbsTol',0);
verifyEqual(testCase,constantResult.component_variance_percent,0, ...
    'AbsTol',0);
verifyFalse(testCase,constantMeta.variance_ratio_defined);

largeConstant = [coordinate,repmat(1e308,size(coordinate))];
[largeResult,largeMeta] = ...
    acycleEmpiricalModeDecomposition(largeConstant,options);
verifyEqual(testCase,largeResult.residual,largeConstant(:,2), ...
    'AbsTol',0);
verifyEqual(testCase,largeMeta.raw_standard_deviation,0,'AbsTol',0);
verifyEqual(testCase,largeMeta.raw_variance,0,'AbsTol',0);
end

function testEemdIsReproducibleAndPreservesSmallAmplitude(testCase)
coordinate = (0:63)'/4;
value = 1e-4*(sin(2*pi*coordinate/4)+ ...
    0.3*cos(2*pi*coordinate/9));
data = [coordinate,value];
options = struct('method','eemd','max_num_imf',3, ...
    'ensemble_count',3,'noise_amplitude',0.2,'random_seed',731);

[first,firstMeta] = ...
    acycleEmpiricalModeDecomposition(data,options);
[second,secondMeta] = ...
    acycleEmpiricalModeDecomposition(data,options);

verifyEqual(testCase,first,second);
verifyEqual(testCase,firstMeta,secondMeta);
verifyEqual(testCase,first.reconstruction,value, ...
    'AbsTol',1e-12*max(abs(value)));
verifyLessThan(testCase,max(abs(first.imfs(:))),0.01);
verifyEqual(testCase,firstMeta.actual_decomposition_count,6);
verifyEqual(testCase,firstMeta.ensemble_pairs_completed,3);

tinyValue = 1e-200*(sin(2*pi*coordinate/4)+ ...
    0.3*cos(2*pi*coordinate/9));
[tiny,tinyMeta] = acycleEmpiricalModeDecomposition( ...
    [coordinate,tinyValue],options);
verifyGreaterThan(testCase,tinyMeta.raw_standard_deviation,0);
verifyEqual(testCase,tinyMeta.raw_variance,0,'AbsTol',0);
verifyTrue(testCase,tinyMeta.raw_variance_underflow);
verifyFalse(testCase,tinyMeta.raw_variance_representable);
verifyEqual(testCase,sum(tiny.component_variance_percent),100, ...
    'AbsTol',1e-12);
verifyEqual(testCase, ...
    tinyMeta.component_variance_percent_denominator, ...
    'scaled_component_standard_deviation_squares');
verifyFalse(testCase,tinyMeta.covariance_gap_defined);
verifyTrue(testCase,isnan(tinyMeta.covariance_gap));
verifyGreaterThan(testCase,max(abs(tiny.imfs(:))),0);
verifyEqual(testCase,tiny.reconstruction,tinyValue, ...
    'AbsTol',1e-212);

constantOptions = options;
constantOptions.noise_amplitude = 0;
[constantEemd,constantEemdMeta] = ...
    acycleEmpiricalModeDecomposition( ...
        [coordinate,ones(size(coordinate))],constantOptions);
verifySize(testCase,constantEemd.imfs,[numel(coordinate),0]);
verifyEqual(testCase,constantEemd.residual,ones(size(coordinate)), ...
    'AbsTol',0);
verifyEqual(testCase,constantEemdMeta.actual_num_imf,0);
constantLegacy = eemd(ones(1,numel(coordinate)),3,1,0);
verifySize(testCase,constantLegacy,[4,numel(coordinate)]);
verifyEqual(testCase,constantLegacy(1:3,:), ...
    zeros(3,numel(coordinate)),'AbsTol',0);
verifyEqual(testCase,constantLegacy(4,:), ...
    ones(1,numel(coordinate)),'AbsTol',0);

legacyModes = eemd(value.',3,1,0.2);
verifySize(testCase,legacyModes,[4,numel(value)]);
verifyEqual(testCase,sum(legacyModes,1).',value, ...
    'AbsTol',1e-12*max(abs(value)));
end

function testEemdProgressRngAndCancelContracts(testCase)
coordinate = (0:47)';
value = sin(2*pi*coordinate/11)+0.2*cos(2*pi*coordinate/5);
data = [coordinate,value];
baseOptions = struct('method','eemd','max_num_imf',2, ...
    'ensemble_count',3,'noise_amplitude',0.15,'random_seed',41);
fractions = zeros(0,1);
messages = cell(0,1);

entryState = rng;
rngCleanup = onCleanup(@()rng(entryState));
rng(841,'twister');
expectedCallerState = rng;
withoutCallback = ...
    acycleEmpiricalModeDecomposition(data,baseOptions);
verifyEqual(testCase,rng,expectedCallerState);

withOptions = baseOptions;
withOptions.progress_fcn = @captureProgress;
withCallback = ...
    acycleEmpiricalModeDecomposition(data,withOptions);
verifyEqual(testCase,rng,expectedCallerState);
verifyEqual(testCase,withCallback,withoutCallback);
verifyEqual(testCase,fractions(1),0,'AbsTol',0);
verifyEqual(testCase,fractions(end),1,'AbsTol',0);
verifyGreaterThanOrEqual(testCase,diff(fractions),0);
verifyTrue(testCase,all(~cellfun('isempty',messages)));

cancelOptions = baseOptions;
cancelOptions.cancel_fcn = @()true;
verifyError(testCase,@()acycleEmpiricalModeDecomposition( ...
    data,cancelOptions),'Acycle:EMD:Canceled');
verifyEqual(testCase,rng,expectedCallerState);

cancelPollCount = 0;
lateCancelOptions = baseOptions;
lateCancelOptions.cancel_fcn = @cancelDuringFirstMember;
verifyError(testCase,@()acycleEmpiricalModeDecomposition( ...
    data,lateCancelOptions),'Acycle:EMD:Canceled');
verifyGreaterThan(testCase,cancelPollCount,1);

    function captureProgress(fraction,message)
        callbackDraws = [rand,randn]; %#ok<NASGU>
        fractions(end+1,1) = fraction;
        messages{end+1,1} = char(string(message));
    end

    function canceled = cancelDuringFirstMember
        cancelPollCount = cancelPollCount+1;
        canceled = cancelPollCount >= 3;
    end
end

function testEmpiricalModeValidationAndNoSideEffects(testCase)
coordinate = (0:31)';
value = sin(2*pi*coordinate/9);
data = [coordinate,value];

verifyError(testCase,@()acycleEmpiricalModeDecomposition( ...
    data,struct('method','emd','ensemble_count',2)), ...
    'Acycle:EMD:InactiveOption');
verifyError(testCase,@()acycleEmpiricalModeDecomposition( ...
    data,struct('method','eemd','ensemble_count',0)), ...
    'Acycle:EMD:InvalidIntegerOption');
verifyError(testCase,@()acycleEmpiricalModeDecomposition( ...
    data,struct('method','eemd','noise_amplitude',-0.1)), ...
    'Acycle:EMD:InvalidNonnegativeOption');
verifyError(testCase,@()acycleEmpiricalModeDecomposition( ...
    data,struct('unknown_field',1)), ...
    'Acycle:EMD:UnknownOption');

nonfinite = data;
nonfinite(5,2) = NaN;
verifyError(testCase,@()acycleEmpiricalModeDecomposition(nonfinite), ...
    'Acycle:EMD:NonfiniteData');
unsorted = data;
unsorted([4,5],:) = unsorted([5,4],:);
verifyError(testCase,@()acycleEmpiricalModeDecomposition(unsorted), ...
    'Acycle:EMD:CoordinatesNotStrictlyIncreasing');
uneven = data;
uneven(17,1) = uneven(17,1)+2e-5;
verifyError(testCase,@()acycleEmpiricalModeDecomposition(uneven), ...
    'Acycle:EMD:UnevenSampling');

directoryBefore = pwd;
pathBefore = path;
figuresBefore = findall(groot,'Type','figure');
randomBefore = rng;
folder = tempname;
mkdir(folder);
testCase.addTeardown(@()removeTestFolder(folder));
cd(folder);
directoryCleanup = onCleanup(@()cd(directoryBefore));
listingBefore = directoryListing(folder);
options = struct('method','eemd','max_num_imf',2, ...
    'ensemble_count',1,'noise_amplitude',0.1,'random_seed',8);
acycleEmpiricalModeDecomposition(data,options);
verifyEqual(testCase,pwd,folder);
verifyEqual(testCase,path,pathBefore);
verifyEqual(testCase,findall(groot,'Type','figure'),figuresBefore);
verifyEqual(testCase,rng,randomBefore);
verifyEqual(testCase,directoryListing(folder),listingBefore);
clear directoryCleanup
verifyEqual(testCase,pwd,directoryBefore);
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
verifyTrue(testCase,contains(acSource, ...
    'acycleEmpiricalModeDecomposition(data,options)'));

emdSource = callbackSource(acSource,'menu_emd_Callback', ...
    'menu_eemd_Callback');
eemdSource = callbackSource(acSource,'menu_eemd_Callback', ...
    'AC_runEmpiricalModeMenu');
verifyTrue(testCase,contains(emdSource, ...
    'AC_runEmpiricalModeMenu(handles,''emd'')'));
verifyTrue(testCase,contains(eemdSource, ...
    'AC_runEmpiricalModeMenu(handles,''eemd'')'));
adapterSource = callbackSource(acSource,'AC_runEmpiricalModeMenu', ...
    'titleText = AC_empiricalModeTitle');
verifyFalse(testCase,contains(adapterSource,'loaddata4acycle'));
verifyFalse(testCase,contains(adapterSource,'CDac_pwd'));
verifyFalse(testCase,contains(adapterSource,'eemd('));
end

function source = callbackSource(acSource,startName,endName)
startToken = ['function ',startName];
endToken = ['function ',endName];
startIndex = strfind(acSource,startToken);
endIndex = strfind(acSource,endToken);
assert(~isempty(startIndex) && ~isempty(endIndex));
startIndex = startIndex(1);
endIndex = endIndex(find(endIndex > startIndex,1,'first'));
assert(~isempty(endIndex));
source = acSource(startIndex:endIndex-1);
end

function listing = directoryListing(folder)
entries = dir(folder);
listing = {entries.name};
end

function removeTestFolder(folder)
if exist(folder,'dir') == 7
    try
        rmdir(folder,'s');
    catch
    end
end
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
