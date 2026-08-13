function tests = test_pdan_legacy_band_union
%TEST_PDAN_LEGACY_BAND_UNION Legacy target-band compatibility tests.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
seriesFolder = fileparts(testFolder);
oldPath = path;
addpath(seriesFolder,'-begin');
testCase.addTeardown(@()path(oldPath));
end

function testPdanNormalizesPairsAndUsesOverlappingBandUnion(testCase)
coordinate = (0:0.25:127.75)';
value = sin(2*pi*0.25*coordinate) + ...
    0.7*cos(2*pi*0.52*coordinate+0.2) + ...
    0.4*sin(2*pi*0.81*coordinate-0.1) + ...
    0.3*cos(2*pi*1.14*coordinate+0.4);
data = [coordinate,value];

% These legacy pairs are globally unordered, include reversed endpoints,
% contain one band inside another, and form two overlap chains.
legacyPairs = [ ...
    1.18,1.06; ...
    0.46,0.31; ...
    0.18,0.34; ...
    0.29,0.22; ...
    1.10,1.30; ...
    0.78,0.84; ...
    0.44,0.60];
mergedUnion = [0.18,0.60;0.78,0.84;1.06,1.30];

legacyVector = reshape(legacyPairs.',1,[]);
mergedVector = reshape(mergedUnion.',1,[]);
actual = pdan(data,legacyVector,31.75,2.5,0,2,8,512);
expected = pdan(data,mergedVector,31.75,2.5,0,2,8,512);

verifyEqual(testCase,actual,expected,'AbsTol',1e-12, ...
    ['The pdan compatibility wrapper must preserve the historical ', ...
     'union-of-frequency-bins behavior for overlapping target bands.']);
end

function testStrictCoreStillRejectsOverlappingBands(testCase)
coordinate = (0:0.25:127.75)';
value = sin(2*pi*0.25*coordinate) + ...
    0.3*cos(2*pi*0.52*coordinate);
data = [coordinate,value];
overlappingBands = [0.18,0.34;0.31,0.46];
options = struct( ...
    'window_length',31.75, ...
    'step_length',2, ...
    'time_bandwidth',2.5, ...
    'fft_length',512, ...
    'total_band',[0,2]);

verifyError(testCase,@()acyclePowerDecomposition( ...
    data,overlappingBands,options), ...
    'Acycle:PowerDecomposition:OverlappingTargetBands');
end

function testPdanClipsLegacyFrequencyLimitsToNyquist(testCase)
coordinate = (0:255)';
value = sin(2*pi*0.08*coordinate) + ...
    0.4*cos(2*pi*0.22*coordinate+0.3);
data = [coordinate,value];

% The historical wrapper clipped both FTERM and every target endpoint to
% the physical Nyquist frequency. This is required by the DYNOT defaults,
% whose upper cutoff is 1 even when the resampled Nyquist is lower.
clipped = pdan(data,[0.06,0.10,0.42,0.75],63,2,0.001,1,4,256);
explicit = pdan(data,[0.06,0.10,0.42,0.50],63,2,0.001,0.50,4,256);

verifyEqual(testCase,clipped,explicit,'AbsTol',1e-12);
end

function testPdanUsesLegacyWindowSampleCountAndAllowsShortNfft(testCase)
coordinate = (0:0.25:159.75)';
value = sin(2*pi*0.3*coordinate) + ...
    0.3*cos(2*pi*0.8*coordinate-0.2);
data = [coordinate,value];

% Legacy PDAN uses FIX(WINDOW/DT) samples. PMTM also accepts an NFFT that
% is shorter than that segment and returns exactly the requested FFT grid.
window = 63.9;
legacyWindowSamples = fix(window/0.25);
verifyGreaterThan(testCase,legacyWindowSamples,128);
actual = pdan(data,[0.24,0.36],window,2,0,2,5,128);

expectedRows = fix((size(data,1)-legacyWindowSamples)/5)+1;
verifySize(testCase,actual,[expectedRows,4]);
verifyEqual(testCase,actual(:,1),linspace( ...
    data(1,1)+window/2,data(end,1)-window/2,expectedRows)', ...
    'AbsTol',32*eps(max(data(end,1),window)));
end

function testPdanMatchesLocalV28BinSumReferenceColumnByColumn(testCase)
coordinate = (0:159)';
value = 1.2*sin(2*pi*0.08*coordinate) + ...
    0.65*cos(2*pi*0.21*coordinate+0.3) + ...
    0.25*sin(2*pi*0.39*coordinate-0.2);
data = [coordinate,value];

% This one request exercises the v2.8 details relevant to DYNOT: FIX for
% the window sample count, a short NFFT, reversed endpoints, overlapping
% target bands, and clipping both target and total maxima to Nyquist.
targetLimits = [0.70,0.48,0.23,0.11,0.18,0.30,0.08,0.15];
window = 63.9;
nw = 2;
ftmin = 0.001;
fterm = 1;
step = 5;
nfft = 32;

actual = pdan(data,targetLimits,window,nw,ftmin,fterm,step,nfft);
expected = localV28PdanReference( ...
    data,targetLimits,window,nw,ftmin,fterm,step,nfft);

verifyEqual(testCase,actual(:,1),expected(:,1),'AbsTol',1e-12, ...
    'Legacy center coordinates must match the v2.8 LINSPACE labels.');
verifyEqual(testCase,actual(:,2),expected(:,2),'AbsTol',1e-12, ...
    'Legacy target/total ratios must match the v2.8 bin sums.');
verifyEqual(testCase,actual(:,3),expected(:,3),'AbsTol',1e-12, ...
    'Legacy target-band union power must match the v2.8 bin sum.');
verifyEqual(testCase,actual(:,4),expected(:,4),'AbsTol',1e-12, ...
    'Legacy total-band power must match the v2.8 bin sum.');
end

function testPdanMatchesV28BinMappingForOddNfft(testCase)
coordinate = (0:0.5:179.5)';
value = sin(2*pi*0.07*coordinate) + ...
    0.55*cos(2*pi*0.19*coordinate+0.25) + ...
    0.2*sin(2*pi*0.43*coordinate-0.4);
data = [coordinate,value];

% For an odd NFFT, PMTM returns FLOOR(NFFT/2)+1 one-sided bins. Preserve
% the v2.8 proportional CEIL/FIX mapping on that exact grid, including
% reversed and overlapping bands and clipping at the physical Nyquist.
targetLimits = [0.11,0.04,0.08,0.23,0.21,0.31,1.4,0.38];
window = 59.9;
nw = 2.5;
ftmin = 0.001;
fterm = 1.5;
step = 7;
nfft = 999;

actual = pdan(data,targetLimits,window,nw,ftmin,fterm,step,nfft);
expected = localV28PdanReference( ...
    data,targetLimits,window,nw,ftmin,fterm,step,nfft);

verifyEqual(testCase,actual,expected,'AbsTol',1e-11, ...
    'Odd-NFFT target and total bin mapping must retain v2.8 semantics.');
end

function testDynotDefaultBandsRunWithoutGuiOrFileIo(testCase)
coordinate = (0:400)';
value = sin(2*pi*coordinate/40.9897) + ...
    0.35*cos(2*pi*coordinate/23.6820+0.2);
data = [coordinate,value];

% Reconstruct one in-range realization of the default DYNOT band request.
% These nine bands overlap substantially, and FTMAX=1 exceeds this input's
% Nyquist; both conditions were accepted by the v2.8 PDAN path.
cycles = [405.6912,130.6979,123.8532,98.8517,94.8856, ...
    40.9897,23.6820,22.3758,18.9519];
window = 300;
nw = 2;
ftmin = 0.001;
ftmax = 1;
bandwidth = nw/window;
targetBands = [1./cycles(:)-0.9*bandwidth, ...
    1./cycles(:)+1.2*bandwidth];
targetBands(targetBands < ftmin) = ftmin;
targetBands(targetBands > ftmax) = ftmax;
sortedBands = sortrows(targetBands,1);
verifyTrue(testCase,any( ...
    sortedBands(2:end,1) < sortedBands(1:end-1,2)), ...
    'The smoke request must retain the overlapping DYNOT default bands.');

result = pdan(data,reshape(targetBands.',1,[]), ...
    window,nw,ftmin,ftmax,5,1000);

verifySize(testCase,result,[21,4]);
verifyTrue(testCase,all(isfinite(result),'all'));
verifyGreaterThanOrEqual(testCase,min(result(:,2)),0);
verifyLessThanOrEqual(testCase,max(result(:,2)),1+64*eps(1));
end

function pow = localV28PdanReference( ...
        data,f3,window,nw,ftmin,fterm,step,pad)
% Direct, deterministic transcription of the numerical v2.8 PDAN path.
dt = data(2,1)-data(1,1);
nyquist = 1/(2*dt);
rowCount = size(data,1);
windowSamples = fix(window/dt);
fterm = min(fterm,nyquist);
f3(f3 > nyquist) = nyquist;
windowCount = fix((rowCount-windowSamples)/step)+1;
frequencyBinCount = floor(pad/2)+1;

powerAll = zeros(windowCount,frequencyBinCount);
outputIndex = 0;
for first = 1:step:(step*windowCount-1)
    last = windowSamples+first-1;
    if last > rowCount
        break
    end
    outputIndex = outputIndex+1;
    segment = detrend(data(first:last,2)');
    powerAll(outputIndex,:) = pmtm(segment,nw,pad)';
end
powerAll = powerAll(1:outputIndex,:);

totalMinimum = ceil(frequencyBinCount*ftmin/nyquist);
if totalMinimum == 0
    totalMinimum = 1;
end
totalMaximum = fix(frequencyBinCount*fterm/nyquist);
totalPower = sum(powerAll(:,totalMinimum:totalMaximum),2);

targetIndices = zeros(1,0);
for pairIndex = 1:(numel(f3)/2)
    lower = min(f3(2*pairIndex-1),f3(2*pairIndex));
    upper = max(f3(2*pairIndex-1),f3(2*pairIndex));
    targetMinimum = ceil(frequencyBinCount*lower/nyquist);
    if targetMinimum == 0
        targetMinimum = 1;
    end
    targetMaximum = fix(frequencyBinCount*upper/nyquist);
    targetIndices = [targetIndices, ...
        targetMinimum:targetMaximum]; %#ok<AGROW>
end
targetIndices = unique(targetIndices);
targetPower = sum(powerAll(:,targetIndices),2);

centers = linspace(data(1,1)+window/2, ...
    data(end,1)-window/2,outputIndex)';
pow = [centers,targetPower./totalPower,targetPower,totalPower];
end
