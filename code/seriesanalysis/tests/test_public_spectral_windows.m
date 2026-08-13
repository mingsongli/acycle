function tests = test_public_spectral_windows
%TEST_PUBLIC_SPECTRAL_WINDOWS Public coherence and sliding-spectrum tests.
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

function testCoherencePhaseSignAndFrequencyGrid(testCase)
rowCount = 256;
coordinate = (0:rowCount-1)'/4;
reference = [coordinate,cos(2*pi*0.5*coordinate)+ ...
    0.2*cos(2*pi*coordinate)];
target = [coordinate,cos(2*pi*0.5*coordinate+pi/3)+ ...
    0.2*cos(2*pi*coordinate-pi/4)];
options = struct('window_samples',64,'overlap_samples',32, ...
    'nfft',128,'alpha',0.05);
[result,meta] = acycleCoherencePhase(reference,target,options);

first = find(result.frequency == 0.5,1,'first');
second = find(result.frequency == 1,1,'first');
verifyNotEmpty(testCase,first);
verifyNotEmpty(testCase,second);
verifyGreaterThan(testCase, ...
    result.magnitude_squared_coherence(first),1-1e-12);
verifyGreaterThan(testCase, ...
    result.magnitude_squared_coherence(second),1-1e-12);
verifyEqual(testCase,result.cross_phase_degrees(first),60, ...
    'AbsTol',2e-10);
verifyEqual(testCase,result.cross_phase_degrees(second),-45, ...
    'AbsTol',2e-10);
verifyTrue(testCase,result.pointwise_significant(first));
verifyEqual(testCase,result.frequency(1),4/128,'AbsTol',0);
verifyEqual(testCase,result.frequency(end),2,'AbsTol',0);
verifyEqual(testCase,meta.cross_spectrum_convention, ...
    'conj_fft_reference_times_fft_target');
end

function testDynamicFilterSelectsStationaryBandAndCoversAllSamples(testCase)
coordinate = (0:0.1:63.9)';
target = sin(2*pi*0.8*coordinate);
nuisance = 0.8*sin(2*pi*2.2*coordinate+0.3);
data = [coordinate,target+nuisance];
options = struct('window_length',12.7,'step_length',3.2);
[result,windows,meta] = acycleDynamicFilter( ...
    data,[0,0.6;coordinate(end),0.6], ...
    [0,1;coordinate(end),1],options);

interior = 100:540;
filteredCorrelation = normalizedCorrelation( ...
    result(interior,2),target(interior));
inputCorrelation = normalizedCorrelation( ...
    data(interior,2),target(interior));
verifyGreaterThan(testCase,filteredCorrelation,0.97);
verifyGreaterThan(testCase,filteredCorrelation,inputCorrelation+0.15);
verifyGreaterThanOrEqual(testCase,min(result(:,3)),1);
verifyGreaterThan(testCase,min(result(:,4)),0);
verifyEqual(testCase,windows(:,2),0.6*ones(size(windows,1),1), ...
    'AbsTol',16*eps(0.6));
verifyEqual(testCase,windows(:,3),ones(size(windows,1),1), ...
    'AbsTol',0);
verifyEqual(testCase,meta.overlap_add_normalization, ...
    'sum_of_half_sample_shifted_hann_weights');
end

function testPowerDecompositionUsesExplicitBandUnion(testCase)
coordinate = (0:0.25:127.75)';
value = 1.3*sin(2*pi*0.25*coordinate)+ ...
    0.7*sin(2*pi*0.62*coordinate+0.4)+ ...
    0.35*cos(2*pi*1.1*coordinate);
bands = [0.20,0.30;0.56,0.68];
options = struct('window_length',63.75,'step_length',8, ...
    'time_bandwidth',2.5,'fft_length',512, ...
    'total_band',[0,2]);
[result,bandPowers,meta] = acyclePowerDecomposition( ...
    [coordinate,value],bands,options);

verifyEqual(testCase,result(:,3),sum(bandPowers(:,2:end),2), ...
    'AbsTol',64*eps(max(result(:,3))));
verifyEqual(testCase,result(:,2),result(:,3)./result(:,4), ...
    'AbsTol',32*eps(1));
verifyGreaterThan(testCase,min(result(:,2)),0.85);
verifyGreaterThan(testCase,min(bandPowers(:,2)), ...
    max(bandPowers(:,3)));
verifyEqual(testCase,meta.target_band_policy, ...
    'ordered_nonoverlapping_union');

wrapperData = [coordinate(1:256),value(1:256)];
oldRandomState = rng;
[legacy,m] = pda(wrapperData,0.2,0.3,31.75,2.5);
legacyN = pdan(wrapperData,[0.2,0.3],31.75, ...
    2.5,0,2,2,256);
verifyEqual(testCase,m,size(legacy,1));
verifyEqual(testCase,size(legacy,2),4);
verifyEqual(testCase,size(legacyN,2),4);
verifyTrue(testCase,isequal(rng,oldRandomState));
end

function testSpectralMomentsLockedReferenceAndEdgePadding(testCase)
values = [3;1;4;1;5;9;2;6;5;3;5;8;9;7;9;3;2;3;8;4];
data = [(10:0.5:19.5)',values];
options = struct('window_length',2,'step_length',1.5, ...
    'zero_padding_factor',3,'edge_padding','none');
[result,meta] = acycleSpectralMoments(data,options);
expected = [ ...
    11.0,0.841364593600398,0.173466154437458; ...
    12.5,0.626720026478032,0.175380551431875; ...
    14.0,0.617448635563071,0.158475924951730; ...
    15.5,0.524643250903467,0.184419107119983; ...
    17.0,0.673831163226033,0.193915755575298; ...
    18.5,0.693858507159147,0.164345645354112];
verifyEqual(testCase,result,expected,'AbsTol',8e-15);
verifyEqual(testCase,meta.window_samples,5);
verifyEqual(testCase,meta.step_samples,3);
verifyEqual(testCase,meta.nfft,16);
verifyEqual(testCase,meta.physical_nyquist,1,'AbsTol',0);

edgeData = [(0:7)',[2;7;1;8;2;8;1;8]];
edgeOptions = struct('window_length',3,'step_length',2, ...
    'zero_padding_factor',2,'edge_padding','zero');
[edgeResult,edgeMeta] = acycleSpectralMoments( ...
    edgeData,edgeOptions);
verifyEqual(testCase,edgeResult(:,1),[0.5;2.5;4.5;6.5], ...
    'AbsTol',0);
verifyEqual(testCase,edgeMeta.edge_padding_application_count,1);
verifyEqual(testCase,edgeMeta.left_padding_samples,1);
verifyEqual(testCase,edgeMeta.right_padding_samples,2);
end

function testDesktopSpectralCallersUseIntendedAnalysisContracts(testCase)
codeDirectory = testCase.TestData.CodeDirectory;
coherenceSource = fileread(fullfile( ...
    codeDirectory,'guicode','coherenceGUI.m'));
momentsSource = fileread(fullfile( ...
    codeDirectory,'guicode','SpectralMomentsGUI.m'));
dynamicSource = fileread(fullfile( ...
    codeDirectory,'misc','dynamic_filter_lang.m'));
pdaSource = fileread(fullfile( ...
    codeDirectory,'seriesanalysis','pda.m'));
pdanSource = fileread(fullfile( ...
    codeDirectory,'seriesanalysis','pdan.m'));

verifyTrue(testCase,contains(coherenceSource,'acycleCoherencePhase('));
verifyTrue(testCase,contains(momentsSource,'acycleSpectralMoments('));
verifyTrue(testCase,contains(momentsSource, ...
    'acycleSamplingIsUneven('));
verifyTrue(testCase,contains(dynamicSource,'acycleDynamicFilter('));
verifyTrue(testCase,contains(pdaSource, ...
    'acyclePowerDecomposition('));
verifyFalse(testCase,contains(pdaSource,'rand('));
verifyFalse(testCase,contains(pdanSource,'rand('));
end

function value = normalizedCorrelation(first,second)
first = double(first(:))-mean(first);
second = double(second(:))-mean(second);
value = (first'*second)/sqrt((first'*first)*(second'*second));
end
