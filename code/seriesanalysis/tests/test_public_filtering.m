function tests = test_public_filtering
%TEST_PUBLIC_FILTERING Public Gaussian/Taner scientific regressions.
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

function testGaussianResponseAndCompatibilityWrapper(testCase)
for n = [63,64,65]
    dt = 0.125;
    coordinate = (0:n-1)'*dt;
    value = 7+sin(2*pi*coordinate)+ ...
        0.2*cos(2*pi*2.25*coordinate+0.1);
    options = struct( ...
        'method','gaussian', ...
        'lower_frequency',0.75, ...
        'upper_frequency',1.25);
    [result,meta] = acycleBandpassFilter( ...
        [coordinate,value],options);

    expectedNfft = 10*2^nextpow2(n);
    expectedFrequency = (0:expectedNfft/2)'/(expectedNfft*dt);
    expectedGain = exp(-log(sqrt(2))* ...
        ((expectedFrequency-1)/0.25).^2);
    verifyEqual(testCase,result.response_frequency,expectedFrequency, ...
        'AbsTol',8*eps(expectedFrequency(end)));
    verifyEqual(testCase,result.response_gain,expectedGain, ...
        'RelTol',8e-15,'AbsTol',8*eps(1));
    verifyEqual(testCase,meta.nfft,expectedNfft);
    verifyEqual(testCase,meta.maximum_hermitian_error,0,'AbsTol',0);
    verifyTrue(testCase,all(isfinite(result.filtered)));
end

n = 128;
dt = 0.125;
coordinate = (0:n-1)'*dt;
value = 5+sin(2*pi*coordinate)+0.1*cos(2*pi*2*coordinate);
[wrapped,gain,frequency] = gaussfilter(value,dt,1,0.75,1.25);
core = acycleBandpassFilter([coordinate,value],struct( ...
    'method','gaussian','lower_frequency',0.75, ...
    'upper_frequency',1.25));
verifyEqual(testCase,wrapped,core.filtered,'AbsTol',0);
verifyEqual(testCase,gain,core.response_gain,'AbsTol',0);
verifyEqual(testCase,frequency,core.response_frequency,'AbsTol',0);
verifyError(testCase,@()gaussfilter( ...
    value,dt,1.01,0.75,1.25), ...
    'Acycle:GaussFilter:CenterFrequencyMismatch');
end

function testTanerReferencePointsPhaseAndNoWorkspaceBridge(testCase)
n = 256;
dt = 0.125;
coordinate = (0:n-1)'*dt;
value = 4+sin(2*pi*coordinate)+0.2*cos(2*pi*2.2*coordinate);
q = 12;
[result,meta] = acycleBandpassFilter([coordinate,value],struct( ...
    'method','taner_hilbert','lower_frequency',0.75, ...
    'upper_frequency',1.25,'rolloff_exponent',q));

df = 1/(n*dt);
centerIndex = round(1/df)+1;
lowerIndex = round(0.75/df)+1;
upperIndex = round(1.25/df)+1;
verifyEqual(testCase,result.response_gain(centerIndex),1,'AbsTol',0);
verifyEqual(testCase,result.response_gain(lowerIndex),1/sqrt(2), ...
    'RelTol',4e-15);
verifyEqual(testCase,result.response_gain(upperIndex),1/sqrt(2), ...
    'RelTol',4e-15);
verifyEqual(testCase,meta.maximum_hermitian_error,0,'AbsTol',0);
verifyEqual(testCase,result.instantaneous_frequency_coordinate, ...
    coordinate(1:end-1)+diff(coordinate)/2,'AbsTol',0);

evalin('base','clear tanerfilterenv');
cleanup = onCleanup(@()evalin('base','clear tanerfilterenv'));
assignin('base','tanerfilterenv',246813579);
[matrix,wrapped,instantaneous,gain,frequency,midpoint] = ...
    tanerhilbertML([coordinate,value],1,0.75,1.25,1e12);
verifyEqual(testCase,matrix,[result.coordinate,result.filtered, ...
    result.envelope,result.unwrapped_phase_rad, ...
    result.phase_residual_rad],'AbsTol',0);
verifyEqual(testCase,wrapped,result.wrapped_phase_rad,'AbsTol',0);
verifyEqual(testCase,instantaneous, ...
    result.instantaneous_frequency,'AbsTol',0);
verifyEqual(testCase,gain,result.response_gain,'AbsTol',0);
verifyEqual(testCase,frequency,result.response_frequency,'AbsTol',0);
verifyEqual(testCase,midpoint, ...
    result.instantaneous_frequency_coordinate,'AbsTol',0);
verifyEqual(testCase,evalin('base','tanerfilterenv'),246813579);
clear cleanup
evalin('base','clear tanerfilterenv');
end

function testDesktopFilterPathsUseSharedCore(testCase)
codeDirectory = testCase.TestData.CodeDirectory;
ftSource = fileread(fullfile(codeDirectory,'guicode','ft.m'));
axesSource = fileread(fullfile(codeDirectory,'misc', ...
    'update_filter_axes.m'));
tanerSource = fileread(fullfile(codeDirectory,'seriesanalysis', ...
    'tanerhilbertML.m'));

verifyTrue(testCase,contains(ftSource,'acycleBandpassFilter('));
verifyTrue(testCase,contains(ftSource,'acycleSamplingIsUneven('));
verifyTrue(testCase,contains(ftSource,'app.prepareInputSeries'));
verifyTrue(testCase,contains(ftSource, ...
    'filtered.instantaneous_frequency_coordinate'));
verifyTrue(testCase,contains(axesSource,'tanerResponseFrequency'));
verifyTrue(testCase,contains(axesSource,'handles.ifreq_coordinate'));
verifyFalse(testCase,contains(ftSource, ...
    'evalin(''base'',''tanerfilterenv'')'));
verifyFalse(testCase,contains(axesSource, ...
    'evalin(''base'',''tanerfilterenv'')'));
verifyFalse(testCase,contains(tanerSource,'assignin'));
verifyEqual(testCase,nargin('gaussfilter'),5);
verifyEqual(testCase,nargout('gaussfilter'),3);
verifyEqual(testCase,nargin('tanerhilbertML'),5);
verifyEqual(testCase,nargout('tanerhilbertML'),6);
end
