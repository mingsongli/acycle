function pow = pdan(data,f3,window,nw,ftmin,fterm,step,pad)
%PDAN Deterministic compatibility wrapper for evolutionary PDA.
%   POW = PDAN(DATA,F3,WINDOW,NW,FTMIN,FTERM,STEP,PAD) delegates to
%   ACYCLEPOWERDECOMPOSITION and preserves the historical four result
%   columns. F3 is a vector of paired [lower,upper] target limits. WINDOW is
%   an explicit first-to-last coordinate span. For compatibility, STEP is
%   an integer number of input samples, while PAD is the explicit even NFFT.
%   Limits above physical Nyquist, overlapping/unsorted bands, fractional
%   steps, and FFT lengths shorter than the resolved window now fail rather
%   than being silently clipped or truncated. No random NFFT probe is used.
%
%   Original PDA by Mingsong Li (2014); PDAN update by Mingsong Li (2016).
%   Scientific reference: Li et al. (2016), Geology,
%   https://doi.org/10.1130/G37970.1; data: https://doi.org/10.1594/PANGAEA.859147.

narginchk(3,8);
if ~((isa(data,'double') || isa(data,'single')) && ...
        isreal(data) && ismatrix(data) && size(data,2) == 2 && ...
        size(data,1) >= 2 && all(isfinite(data(:))))
    error('Acycle:PdanCompatibility:InvalidData', ...
        'DATA must be a finite real floating-point N-by-2 matrix.');
end
coordinate = double(data(:,1));
spacing = diff(coordinate);
if any(~isfinite(spacing)) || any(spacing <= 0)
    error('Acycle:PdanCompatibility:InvalidCoordinates', ...
        'DATA coordinates must be finite and strictly increasing.');
end
sampleInterval = median(spacing);
nyquist = 1/(2*sampleInterval);

if nargin < 4 || isempty(nw)
    nw = 2;
end
if nargin < 5 || isempty(ftmin)
    ftmin = 0;
end
if nargin < 6 || isempty(fterm)
    fterm = nyquist;
end
if nargin < 7 || isempty(step)
    step = 1;
end
if nargin < 8 || isempty(pad)
    pad = 1000;
end

if ~(isnumeric(f3) && ~islogical(f3) && isreal(f3) && ...
        isvector(f3) && ~isempty(f3) && all(isfinite(f3(:))) && ...
        mod(numel(f3),2) == 0)
    error('Acycle:PdanCompatibility:InvalidTargetBands', ...
        'F3 must be a finite real vector containing paired band limits.');
end
targetBands = reshape(double(f3(:)),2,[]).';
if ~(isnumeric(step) && ~islogical(step) && isreal(step) && ...
        isscalar(step) && isfinite(step) && step >= 1 && step == fix(step))
    error('Acycle:PdanCompatibility:InvalidStep', ...
        'STEP must be a finite positive integer number of input samples.');
end
options = struct( ...
    'window_length',positiveFiniteScalar(window,'WINDOW'), ...
    'step_length',double(step)*sampleInterval, ...
    'time_bandwidth',positiveFiniteScalar(nw,'NW'), ...
    'fft_length',pad, ...
    'total_band',[ftmin,fterm]);
[pow,~,~] = acyclePowerDecomposition(data,targetBands,options);
end

function value = positiveFiniteScalar(value,name)
if ~(isnumeric(value) && ~islogical(value) && isreal(value) && ...
        isscalar(value) && isfinite(value) && value > 0)
    error('Acycle:PdanCompatibility:InvalidParameter', ...
        '%s must be a finite positive numeric scalar.',name);
end
value = double(value);
end
