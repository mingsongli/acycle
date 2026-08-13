function pow = pdan(data,f3,window,nw,ftmin,fterm,step,pad)
%PDAN Legacy-compatible evolutionary power decomposition.
%   POW = PDAN(DATA,F3,WINDOW,NW,FTMIN,FTERM,STEP,PAD) preserves the
%   historical DYNOT/PDA calculation. F3 contains paired target-frequency
%   limits. Either endpoint may come first, pair order is irrelevant, and
%   overlapping pairs form one union of FFT bins so overlap is counted once.
%   Frequencies above the physical Nyquist are clipped. WINDOW resolves to
%   FIX(WINDOW/DT) samples, STEP is an integer number of samples, and PAD is
%   passed directly to PMTM even when it is shorter than the window.
%
%   The implementation is deterministic and vectorized, but deliberately
%   retains the legacy proportional bin mapping and bin-sum power ratio used
%   by DYNOT. Use ACYCLEPOWERDECOMPOSITION directly for the newer strict,
%   exact-boundary PSD-integration contract.
%
%   Original PDA by Mingsong Li (2014); PDAN update by Mingsong Li (2016).
%   Scientific reference: Li et al. (2016), Geology,
%   https://doi.org/10.1130/G37970.1; data: https://doi.org/10.1594/PANGAEA.859147.

narginchk(3,8);
validateData(data);
coordinate = double(data(:,1));
sampleInterval = coordinate(2)-coordinate(1);
spacing = diff(coordinate);
spacingTolerance = 1e-5;
if any(spacing <= 0) || ...
        max(abs(spacing-sampleInterval))/sampleInterval > spacingTolerance
    error('Acycle:PdanCompatibility:InvalidCoordinates', ...
        ['DATA coordinates must be strictly increasing and regularly ', ...
         'sampled to relative tolerance %.17g.'],spacingTolerance);
end
nyquist = 1/(2*sampleInterval);

if nargin < 4 || isempty(nw), nw = 2; end
if nargin < 5 || isempty(ftmin), ftmin = 0; end
if nargin < 6 || isempty(fterm), fterm = nyquist; end
if nargin < 7 || isempty(step), step = 1; end
if nargin < 8 || isempty(pad), pad = 1000; end

window = positiveFiniteScalar(window,'WINDOW');
nw = positiveFiniteScalar(nw,'NW');
ftmin = finiteScalar(ftmin,'FTMIN');
fterm = finiteScalar(fterm,'FTERM');
step = positiveInteger(step,'STEP');
pad = positiveInteger(pad,'PAD');
validateTargetVector(f3);

windowSamples = fix(window/sampleInterval);
rowCount = size(data,1);
if windowSamples < 2 || windowSamples > rowCount
    error('Acycle:PdanCompatibility:InvalidWindow', ...
        ['WINDOW must resolve with FIX(WINDOW/DT) to between 2 and ', ...
         'the number of input rows.']);
end
if nw < 0.5 || nw >= windowSamples/2
    error('Acycle:PdanCompatibility:InvalidTimeBandwidth', ...
        'NW must be at least 0.5 and less than WINDOW_SAMPLES/2.');
end

fterm = min(fterm,nyquist);
if ftmin < 0 || fterm <= ftmin
    error('Acycle:PdanCompatibility:InvalidTotalBand', ...
        'Frequency limits must satisfy 0 <= FTMIN < FTERM after clipping.');
end

targetBands = reshape(double(f3(:)),2,[]).';
targetBands = [min(targetBands,[],2),max(targetBands,[],2)];
targetBands(targetBands > nyquist) = nyquist;
if any(targetBands(:,1) < 0)
    error('Acycle:PdanCompatibility:InvalidTargetBands', ...
        'Target-frequency limits must be nonnegative.');
end

startIndices = (1:step:(rowCount-windowSamples+1)).';
windowCount = numel(startIndices);
if windowCount < 1
    error('Acycle:PdanCompatibility:NoCompleteWindows', ...
        'The requested window and step produce no complete windows.');
end

% PMTM returns exactly this many one-sided bins for a requested NFFT. The
% formula removes the old random probe while preserving its result.
frequencyBinCount = floor(double(pad)/2)+1;
totalIndices = legacyBandIndices( ...
    [ftmin,fterm],frequencyBinCount,nyquist);
targetIndices = legacyBandIndices( ...
    targetBands,frequencyBinCount,nyquist);
if isempty(totalIndices)
    error('Acycle:PdanCompatibility:EmptyTotalBand', ...
        'The total frequency range contains no FFT bins.');
end

targetPower = zeros(windowCount,1);
totalPower = zeros(windowCount,1);
values = double(data(:,2));
for windowIndex = 1:windowCount
    first = startIndices(windowIndex);
    segment = detrend(values(first:first+windowSamples-1).');
    spectrum = pmtm(segment,nw,pad);
    spectrum = spectrum(:);
    if numel(spectrum) ~= frequencyBinCount || ...
            any(~isfinite(spectrum)) || any(spectrum < 0)
        error('Acycle:PdanCompatibility:InvalidSpectrum', ...
            'PMTM returned an invalid spectrum for window %d.',windowIndex);
    end
    totalPower(windowIndex) = sum(spectrum(totalIndices));
    if ~isempty(targetIndices)
        targetPower(windowIndex) = sum(spectrum(targetIndices));
    end
end

if any(~isfinite(totalPower)) || any(totalPower <= 0)
    error('Acycle:PdanCompatibility:InvalidTotalPower', ...
        'A window has zero or nonfinite total-band power.');
end
ratio = targetPower./totalPower;
centers = linspace(coordinate(1)+window/2, ...
    coordinate(end)-window/2,windowCount)';
pow = [centers,ratio,targetPower,totalPower];
end

function indices = legacyBandIndices(bands,frequencyBinCount,nyquist)
indices = cell(size(bands,1),1);
for bandIndex = 1:size(bands,1)
    lower = ceil(frequencyBinCount*bands(bandIndex,1)/nyquist);
    upper = fix(frequencyBinCount*bands(bandIndex,2)/nyquist);
    if lower == 0, lower = 1; end
    lower = max(1,lower);
    upper = min(frequencyBinCount,upper);
    if upper >= lower
        indices{bandIndex} = lower:upper;
    else
        indices{bandIndex} = zeros(1,0);
    end
end
indices = unique([indices{:}]);
end

function validateData(data)
if ~((isa(data,'double') || isa(data,'single')) && ...
        isreal(data) && ismatrix(data) && size(data,2) == 2 && ...
        size(data,1) >= 2 && all(isfinite(data(:))))
    error('Acycle:PdanCompatibility:InvalidData', ...
        'DATA must be a finite real floating-point N-by-2 matrix.');
end
end

function validateTargetVector(f3)
if ~(isnumeric(f3) && ~islogical(f3) && isreal(f3) && ...
        isvector(f3) && ~isempty(f3) && all(isfinite(f3(:))) && ...
        mod(numel(f3),2) == 0)
    error('Acycle:PdanCompatibility:InvalidTargetBands', ...
        'F3 must be a finite real vector containing paired band limits.');
end
end

function value = finiteScalar(value,name)
if ~(isnumeric(value) && ~islogical(value) && isreal(value) && ...
        isscalar(value) && isfinite(value))
    error('Acycle:PdanCompatibility:InvalidParameter', ...
        '%s must be a finite real numeric scalar.',name);
end
value = double(value);
end

function value = positiveFiniteScalar(value,name)
value = finiteScalar(value,name);
if value <= 0
    error('Acycle:PdanCompatibility:InvalidParameter', ...
        '%s must be positive.',name);
end
end

function value = positiveInteger(value,name)
value = positiveFiniteScalar(value,name);
if value ~= fix(value)
    error('Acycle:PdanCompatibility:InvalidParameter', ...
        '%s must be an integer.',name);
end
end
