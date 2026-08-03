function [estimate,state] = bispectralEstimate(y,dt,options,state)
%BISPECTRALESTIMATE Direct bispectrum and bounded bicoherence estimators.
%   This lower-level function expects an evenly sampled, preprocessed
%   vector. Use BISPECTRALANALYZE for normal use.

if nargin < 4
    state = [];
end
if ~isnumeric(y) || ~isvector(y)
    error('Acycle:Bispectral:InvalidEstimatorData', ...
        'The lower-level estimator requires a numeric vector.');
end
if ~isreal(y)
    error('Acycle:Bispectral:ComplexData', ...
        'Bispectral estimation requires a real-valued input series.');
end
y = double(y(:));
if any(~isfinite(y))
    error('Acycle:Bispectral:InvalidEstimatorData', ...
        'The lower-level estimator requires a finite preprocessed series.');
end
if ~(isscalar(dt) && isnumeric(dt) && isreal(dt) && ...
        isfinite(dt) && dt > 0)
    error('Acycle:Bispectral:InvalidSampleInterval','dt must be positive.');
end
validateEstimatorOptions(options);
if isempty(state)
    state = buildState(numel(y),dt,options);
else
    validateStateCompatibility(state,numel(y),dt,options);
end

switch state.Estimator
    case 'wosa'
        [pairBispectrum,bicoherenceSquared,denominator,power] = ...
            estimateWosa(y,state,options);
    case 'frequency-smoothed'
        [pairBispectrum,bicoherenceSquared,denominator,power] = ...
            estimateFrequencySmoothed(y,state,options);
    otherwise
        error('Acycle:Bispectral:InternalEstimator','Unknown estimator state.');
end

matrixSize = [numel(state.Frequency),numel(state.Frequency)];
bispectrum = complex(nan(matrixSize),nan(matrixSize));
bicoh2 = nan(matrixSize);
denom = nan(matrixSize);
bispectrum(state.PairLinearIndex) = pairBispectrum;
bicoh2(state.PairLinearIndex) = bicoherenceSquared;
denom(state.PairLinearIndex) = denominator;

estimate = struct();
estimate.Frequency = state.Frequency;
estimate.Bispectrum = bispectrum;
estimate.BispectrumMagnitude = abs(bispectrum);
estimate.BispectrumSquaredMagnitude = abs(bispectrum).^2;
estimate.BispectrumReal = real(bispectrum);
estimate.BispectrumImaginary = imag(bispectrum);
biphase = angle(bispectrum);
phaseDefined = state.ValidMask & isfinite(bicoh2) & ...
    isfinite(real(bispectrum)) & isfinite(imag(bispectrum)) & abs(bispectrum) > 0;
biphase(~phaseDefined) = NaN;
estimate.Biphase = biphase;
estimate.BicoherenceSquared = bicoh2;
estimate.Denominator = denom;
estimate.PrincipalDomainMask = state.ValidMask;
estimate.ValidMask = state.ValidMask & isfinite(bicoh2);
estimate.InvalidDenominatorMask = state.ValidMask & ~isfinite(bicoh2);
estimate.Power = power;
estimate.PairBicoherenceSquared = bicoherenceSquared;
estimate.PairLinearIndex = state.PairLinearIndex;
estimate.Meta = state.Meta;
estimate.Meta.InvalidDenominatorTriadCount = nnz(estimate.InvalidDenominatorMask);
end

function state = buildState(n,dt,options)
estimator = canonicalEstimator(options.Estimator);
if n < 32
    error('Acycle:Bispectral:TooShort','At least 32 samples are required.');
end

switch estimator
    case 'wosa'
        nSegments = double(options.NumSegments);
        if nSegments < 3
            error('Acycle:Bispectral:InvalidSegments', ...
                'NumSegments must be an integer of at least 3.');
        end
        overlap = double(options.OverlapPercent) / 100;
        if ~(isfinite(overlap) && overlap >= 0 && overlap < 0.9)
            error('Acycle:Bispectral:InvalidOverlap', ...
                'OverlapPercent must be in the interval [0,90).');
        end
        segmentLength = floor(n/(1+(nSegments-1)*(1-overlap)));
        if segmentLength < 32
            error('Acycle:Bispectral:SegmentsTooShort', ...
                'This segment count/overlap leaves fewer than 32 samples per segment.');
        end
        if nSegments == 1
            starts = 1;
        else
            starts = round(linspace(1,n-segmentLength+1,nSegments));
        end
        if numel(unique(starts)) ~= nSegments
            error('Acycle:Bispectral:DuplicateSegments', ...
                'The requested settings do not produce distinct segments.');
        end
        if isempty(options.NFFT)
            nfft = round(segmentLength*double(options.ZeroPaddingFactor));
        else
            nfft = double(options.NFFT);
        end
        if ~(isfinite(nfft) && nfft >= segmentLength)
            error('Acycle:Bispectral:InvalidNFFT','NFFT must be at least the segment length.');
        end
        window = localWindow(segmentLength,options.Window);
        smoothingOffsets = zeros(0,2);
        smoothingWeights = [];
        effectiveRealizations = nSegments;
        actualOverlap = 100*(1-median(diff(starts))/segmentLength);
        rayleigh = 1/(segmentLength*dt);
    case 'frequency-smoothed'
        % Adjacent zero-padded bins are not new realizations. Always use
        % the native DFT grid for this estimator.
        nfft = n;
        segmentLength = n;
        starts = 1;
        window = localWindow(n,options.Window);
        span = double(options.FrequencySmoothingSpan);
        if ~(span >= 3 && mod(span,2) == 1)
            error('Acycle:Bispectral:InvalidSmoothingSpan', ...
                'FrequencySmoothingSpan must be an odd integer of at least 3.');
        end
        halfWidth = (span-1)/2;
        [smoothingOffsets,smoothingWeights] = hexKernel( ...
            halfWidth,options.FrequencySmoothingKernel);
        effectiveRealizations = 1/sum(smoothingWeights.^2);
        actualOverlap = NaN;
        rayleigh = 1/(n*dt);
    otherwise
        error('Acycle:Bispectral:InvalidEstimator','Unsupported estimator.');
end

positiveMaxBin = floor((nfft-1)/2); % excludes an exact Nyquist bin
nyquist = 1/(2*dt);
% FrequencyMin and FrequencyMax are deliberately not used by the estimator.
% They are view settings consumed by BISPECTRALPLOT, so changing the visible
% range cannot change the computed triads or a map-wide significance family.
% The numerical domain is the positive, unaliased sum-frequency triangle:
% k1>0, k2>0, k2<=k1, and k1+k2 below Nyquist. It deliberately excludes the
% outer 12-fold discrete-time symmetry sector, where k1+k2 wraps across
% Nyquist to a negative frequency; that sector has a different interpretation
% from the positive f3=f1+f2 coupling shown by this GUI.
minBin = 1;
maxBin = positiveMaxBin;
if strcmp(estimator,'frequency-smoothed')
    halfWidth = max(abs(smoothingOffsets(:)));
    minBin = max(minBin,halfWidth+1);
end
allBins = minBin:maxBin;
if numel(allBins) < 2
    error('Acycle:Bispectral:TooFewFrequencyBins', ...
        'Too few positive FFT bins remain for bispectral estimation.');
end
maxFrequencyBins = double(options.MaxFrequencyBins);
if maxFrequencyBins < 16
    error('Acycle:Bispectral:InvalidMaxFrequencyBins', ...
        'MaxFrequencyBins must be an integer of at least 16.');
end
binStride = max(1,ceil(numel(allBins)/maxFrequencyBins));
axisBins = allBins(1:binStride:end);
frequency = axisBins(:)/(nfft*dt);

[bin1,bin2] = meshgrid(axisBins,axisBins);
validMask = bin2 <= bin1 & (bin1+bin2 <= maxBin);
if strcmp(estimator,'frequency-smoothed')
    h = max(abs(smoothingOffsets(:)));
    validMask = validMask & (bin1-h >= 1) & (bin2-h >= 1) & ...
        (bin1+bin2+h <= maxBin);
end
if ~any(validMask(:))
    error('Acycle:Bispectral:EmptyPrincipalDomain', ...
        'No triads remain in the selected nonredundant principal domain.');
end

pairLinearIndex = find(validMask);
pairBin1 = bin1(pairLinearIndex);
pairBin2 = bin2(pairLinearIndex);

window = window ./ sqrt(mean(window.^2));
windowEnbw = segmentLength*sum(window.^2)/(sum(window)^2);
coverage = zeros(n,1);
for ii = 1:numel(starts)
    coverage(starts(ii):starts(ii)+segmentLength-1) = ...
        coverage(starts(ii):starts(ii)+segmentLength-1)+1;
end

warnings = {};
if strcmp(estimator,'wosa') && nSegments < 8
    warnings{end+1} = 'Fewer than 8 segments gives a high-variance bicoherence estimate.';
end
usesAnalyticalInference = any(strcmpi(strtrim(char(options.SignificanceMethod)), ...
    {'analytical','analytic','beta'}));
if strcmp(estimator,'wosa') && options.OverlapPercent > 0 && ...
        usesAnalyticalInference
    warnings{end+1} = ['Overlapped segments are correlated; analytical Beta ', ...
        'significance is approximate and retained only for API compatibility. ', ...
        'Formal inference uses IAAFT maximum-statistic FWER control.'];
elseif strcmp(estimator,'frequency-smoothed')
    warnings{end+1} = ['Frequency-smoothed triads share FFT coefficients; the ', ...
        'kernel effective count is diagnostic, not strict degrees of freedom.'];
end
if isempty(smoothingOffsets)
    smoothingBandwidth = 0;
else
    smoothingBandwidth = max(abs(smoothingOffsets(:)))*rayleigh;
end

state = struct();
state.Estimator = estimator;
state.RecordLength = n;
state.SampleInterval = dt;
state.NFFT = nfft;
state.SegmentLength = segmentLength;
state.SegmentStarts = starts(:);
state.Window = window(:);
state.AxisBins = axisBins(:);
state.Frequency = frequency;
state.ValidMask = validMask;
state.PairLinearIndex = pairLinearIndex;
state.PairBin1 = pairBin1(:);
state.PairBin2 = pairBin2(:);
state.SmoothingOffsets = smoothingOffsets;
state.SmoothingWeights = smoothingWeights(:);
state.Signature = estimatorSignature(n,dt,options);
computedAxisMinimum = frequency(1);
computedAxisMaximum = frequency(end);
nativePositiveMaximum = positiveMaxBin/(nfft*dt);
principalSumMaximum = max(pairBin1+pairBin2)/(nfft*dt);
state.Meta = struct( ...
    'Estimator',estimator, ...
    'RecordLength',n, ...
    'SampleInterval',dt, ...
    'Nyquist',nyquist, ...
    'NFFT',nfft, ...
    'ZeroPaddingFactorActual',nfft/segmentLength, ...
    'SegmentLength',segmentLength, ...
    'SegmentCount',numel(starts), ...
    'SegmentStarts',starts(:), ...
    'RequestedOverlapPercent',options.OverlapPercent, ...
    'ActualMedianOverlapPercent',actualOverlap, ...
    'Window',char(options.Window), ...
    'WindowENBWBins',windowEnbw, ...
    'RayleighResolution',rayleigh, ...
    'FrequencyBinStride',binStride, ...
    'ComputedAxisBinCount',numel(axisBins), ...
    'ComputedAxisFrequencyMinimum',computedAxisMinimum, ...
    'ComputedAxisFrequencyMaximum',computedAxisMaximum, ...
    'NativePositiveFrequencyMaximum',nativePositiveMaximum, ...
    'PrincipalSumFrequencyMaximum',principalSumMaximum, ...
    'ComputedFrequencyMaximum',computedAxisMaximum, ... % legacy, now accurately axis-based
    'PrincipalDomainMaximum',principalSumMaximum, ...   % legacy alias
    'TriadCount',numel(pairLinearIndex), ...
    'EffectiveRealizationCount',effectiveRealizations, ...
    'SmoothingOffsets',smoothingOffsets, ...
    'SmoothingWeights',smoothingWeights(:), ...
    'SmoothingBandwidth',smoothingBandwidth, ...
    'UnusedSampleCount',sum(coverage == 0), ...
    'MinimumCoverage',min(coverage), ...
    'MaximumCoverage',max(coverage), ...
    'DFTScaling','FFT(window .* segment) / segmentLength; window RMS normalized to one', ...
    'BispectrumConvention','B(f1,f2) = mean[X(f1) X(f2) conj(X(f1+f2))]', ...
    'Warnings',{warnings});
end

function validateStateCompatibility(state,n,dt,options)
if ~isstruct(state) || ~isscalar(state) || ~isfield(state,'RecordLength')
    error('Acycle:Bispectral:InvalidState', ...
        'A reused estimator state must be the scalar structure returned by bispectralEstimate.');
end
if ~isequal(state.RecordLength,n)
    error('Acycle:Bispectral:StateSizeMismatch', ...
        'A reused estimator state must have the same record length.');
end
if ~isfield(state,'Signature') || ~isstruct(state.Signature)
    error('Acycle:Bispectral:StateSignatureMissing', ...
        'The estimator state lacks the scientific configuration signature required for safe reuse.');
end
expected = estimatorSignature(n,dt,options);
names = fieldnames(expected);
different = cell(0,1);
for ii = 1:numel(names)
    name = names{ii};
    if ~isfield(state.Signature,name) || ...
            ~isequaln(state.Signature.(name),expected.(name))
        different{end+1,1} = name; %#ok<AGROW>
    end
end
if ~isempty(different)
    error('Acycle:Bispectral:StateSignatureMismatch', ...
        ['A reused estimator state does not match the current scientific ', ...
         'configuration. Changed field(s): %s.'],strjoin(different,', '));
end
end

function signature = estimatorSignature(n,dt,options)
requestedNfft = options.NFFT;
if ~isempty(requestedNfft)
    requestedNfft = double(requestedNfft);
end
signature = struct( ...
    'Version',1, ...
    'RecordLength',double(n), ...
    'SampleInterval',double(dt), ...
    'Estimator',canonicalEstimator(options.Estimator), ...
    'NumSegments',double(options.NumSegments), ...
    'OverlapPercent',double(options.OverlapPercent), ...
    'Window',canonicalWindow(options.Window), ...
    'SegmentDetrendMethod',canonicalSegmentDetrend(options.SegmentDetrendMethod), ...
    'FrequencySmoothingSpan',double(options.FrequencySmoothingSpan), ...
    'FrequencySmoothingKernel',canonicalSmoothingKernel( ...
        options.FrequencySmoothingKernel), ...
    'RequestedNFFT',requestedNfft, ...
    'ZeroPaddingFactor',double(options.ZeroPaddingFactor), ...
    'MaxFrequencyBins',double(options.MaxFrequencyBins));
end

function validateEstimatorOptions(options)
if ~(isscalar(options.OverlapPercent) && isnumeric(options.OverlapPercent) && ...
        isreal(options.OverlapPercent) && isfinite(options.OverlapPercent) && ...
        options.OverlapPercent >= 0 && options.OverlapPercent < 90)
    error('Acycle:Bispectral:InvalidOverlap', ...
        'OverlapPercent must be in the interval [0,90).');
end
if ~(isscalar(options.ZeroPaddingFactor) && ...
        isnumeric(options.ZeroPaddingFactor) && ...
        isreal(options.ZeroPaddingFactor) && ...
        isfinite(options.ZeroPaddingFactor) && options.ZeroPaddingFactor > 0)
    error('Acycle:Bispectral:InvalidZeroPaddingFactor', ...
        'ZeroPaddingFactor must be a positive finite scalar.');
end
if ~(isFiniteIntegerScalar(options.NumSegments) && options.NumSegments >= 1)
    error('Acycle:Bispectral:InvalidSegments', ...
        'NumSegments must be a positive integer (and at least 3 for WOSA).');
end
if ~(isFiniteIntegerScalar(options.FrequencySmoothingSpan) && ...
        options.FrequencySmoothingSpan >= 1)
    error('Acycle:Bispectral:InvalidSmoothingSpan', ...
        'FrequencySmoothingSpan must be a positive integer.');
end
if ~(isFiniteIntegerScalar(options.MaxFrequencyBins) && ...
        options.MaxFrequencyBins >= 1)
    error('Acycle:Bispectral:InvalidMaxFrequencyBins', ...
        'MaxFrequencyBins must be a positive integer (and at least 16).');
end
if ~isempty(options.NFFT) && ...
        ~(isFiniteIntegerScalar(options.NFFT) && options.NFFT >= 1)
    error('Acycle:Bispectral:InvalidNFFT', ...
        'NFFT must be empty or a positive integer.');
end
end

function tf = isFiniteIntegerScalar(value)
tf = isscalar(value) && isnumeric(value) && isreal(value) && ...
    isfinite(value) && value == fix(value);
end

function [bispectrum,bicoh2,denominator,power] = estimateWosa(y,state,options)
nSegments = numel(state.SegmentStarts);
spectra = complex(zeros(state.NFFT,nSegments));
for ii = 1:nSegments
    first = state.SegmentStarts(ii);
    segment = y(first:first+state.SegmentLength-1);
    segment = segmentDetrend(segment,options.SegmentDetrendMethod);
    spectra(:,ii) = fft(segment.*state.Window,state.NFFT)/state.SegmentLength;
end

i1 = state.PairBin1+1;
i2 = state.PairBin2+1;
i3 = state.PairBin1+state.PairBin2+1;
a = spectra(i1,:).*spectra(i2,:);
c = spectra(i3,:);
triple = a.*conj(c);
sumTriple = sum(triple,2);
sumA2 = sum(abs(a).^2,2);
sumC2 = sum(abs(c).^2,2);
denominator = sumA2.*sumC2;
bispectrum = sumTriple/nSegments;
bicoh2 = nan(size(denominator));
ok = isfinite(denominator) & denominator > 0;
bicoh2(ok) = abs(sumTriple(ok)).^2 ./ denominator(ok);
bicoh2(ok) = min(1,max(0,real(bicoh2(ok))));
power = mean(abs(spectra(state.AxisBins+1,:)).^2,2);
end

function [bispectrum,bicoh2,denominator,power] = ...
        estimateFrequencySmoothed(y,state,options)
series = segmentDetrend(y,options.SegmentDetrendMethod);
spectrum = fft(series.*state.Window,state.NFFT)/state.SegmentLength;
nPairs = numel(state.PairBin1);
weightedTriple = complex(zeros(nPairs,1));
weightedA2 = zeros(nPairs,1);
weightedC2 = zeros(nPairs,1);
for ii = 1:size(state.SmoothingOffsets,1)
    aOffset = state.SmoothingOffsets(ii,1);
    bOffset = state.SmoothingOffsets(ii,2);
    weight = state.SmoothingWeights(ii);
    k1 = state.PairBin1+aOffset;
    k2 = state.PairBin2+bOffset;
    k3 = k1+k2;
    a = spectrum(k1+1).*spectrum(k2+1);
    c = spectrum(k3+1);
    weightedTriple = weightedTriple + weight.*a.*conj(c);
    weightedA2 = weightedA2 + weight.*abs(a).^2;
    weightedC2 = weightedC2 + weight.*abs(c).^2;
end
bispectrum = weightedTriple;
denominator = weightedA2.*weightedC2;
bicoh2 = nan(size(denominator));
ok = isfinite(denominator) & denominator > 0;
bicoh2(ok) = abs(weightedTriple(ok)).^2 ./ denominator(ok);
bicoh2(ok) = min(1,max(0,real(bicoh2(ok))));
power = abs(spectrum(state.AxisBins+1)).^2;
end

function y = segmentDetrend(y,method)
switch canonicalSegmentDetrend(method)
    case 'none'
    case 'mean'
        y = y-mean(y);
    case 'linear'
        y = detrend(y,'linear');
    otherwise
        error('Acycle:Bispectral:InvalidSegmentDetrend', ...
            'SegmentDetrendMethod must be none, mean, or linear.');
end
end

function estimator = canonicalEstimator(value)
value = lower(strtrim(char(value)));
if any(strcmp(value,{'wosa','welch','welch/wosa','segmented'}))
    estimator = 'wosa';
elseif any(strcmp(value,{'frequency-smoothed','frequency smoothed','smooth','direct-smoothed'}))
    estimator = 'frequency-smoothed';
else
    error('Acycle:Bispectral:InvalidEstimator', ...
        'Estimator must be wosa or frequency-smoothed.');
end
end

function window = localWindow(n,name)
k = (0:n-1)';
denominator = max(1,n-1);
switch canonicalWindow(name)
    case 'hann'
        window = 0.5-0.5*cos(2*pi*k/denominator);
    case 'hamming'
        window = 0.54-0.46*cos(2*pi*k/denominator);
    case 'blackman'
        window = 0.42-0.5*cos(2*pi*k/denominator)+0.08*cos(4*pi*k/denominator);
    case 'rectangular'
        window = ones(n,1);
    otherwise
        error('Acycle:Bispectral:InvalidWindow', ...
            'Window must be hann, hamming, blackman, or rectangular.');
end
end

function [offsets,weights] = hexKernel(h,kernelName)
[a,b] = meshgrid(-h:h,-h:h);
keep = abs(a+b) <= h;
offsets = [a(keep),b(keep)];
switch canonicalSmoothingKernel(kernelName)
    case 'daniell'
        weights = ones(size(offsets,1),1);
    case 'cosine'
        g1 = 0.5*(1+cos(pi*offsets(:,1)/(h+1)));
        g2 = 0.5*(1+cos(pi*offsets(:,2)/(h+1)));
        g3 = 0.5*(1+cos(pi*sum(offsets,2)/(h+1)));
        weights = g1.*g2.*g3;
    otherwise
        error('Acycle:Bispectral:InvalidSmoothingKernel', ...
            'FrequencySmoothingKernel must be daniell or cosine.');
end
weights = weights/sum(weights);
end

function method = canonicalSegmentDetrend(value)
method = lower(strtrim(char(value)));
if ~any(strcmp(method,{'none','mean','linear'}))
    error('Acycle:Bispectral:InvalidSegmentDetrend', ...
        'SegmentDetrendMethod must be none, mean, or linear.');
end
end

function name = canonicalWindow(value)
value = lower(strtrim(char(value)));
if any(strcmp(value,{'hann','hanning'}))
    name = 'hann';
elseif any(strcmp(value,{'hamming','blackman'}))
    name = value;
elseif any(strcmp(value,{'rectangular','rectwin','none'}))
    name = 'rectangular';
else
    error('Acycle:Bispectral:InvalidWindow', ...
        'Window must be hann, hamming, blackman, or rectangular.');
end
end

function name = canonicalSmoothingKernel(value)
value = lower(strtrim(char(value)));
if any(strcmp(value,{'daniell','uniform','boxcar'}))
    name = 'daniell';
elseif any(strcmp(value,{'cosine','raised-cosine'}))
    name = 'cosine';
else
    error('Acycle:Bispectral:InvalidSmoothingKernel', ...
        'FrequencySmoothingKernel must be daniell or cosine.');
end
end
