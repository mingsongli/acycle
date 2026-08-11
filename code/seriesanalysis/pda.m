function [powratio,m] = pda(data,fmin,fmax,window,nw)
%PDA Deterministic compatibility wrapper for power decomposition.
%   [POWRATIO,M] = PDA(DATA,FMIN,FMAX,WINDOW,NW) preserves the historical
%   four-column output while delegating to ACYCLEPOWERDECOMPOSITION. WINDOW
%   is now an explicit first-to-last coordinate span, the step is one sample
%   interval, NFFT is the smallest power of two no shorter than the resolved
%   window, and total power spans DC through the physical Nyquist frequency.
%   Invalid frequency limits are rejected rather than silently remapped.
%
%   Original PDA implementation by Mingsong Li and Linda Hinnov (China
%   University of Geosciences and Johns Hopkins University), Nov. 12, 2014.

narginchk(5,5);
if ~((isa(data,'double') || isa(data,'single')) && ...
        isreal(data) && ismatrix(data) && size(data,2) == 2 && ...
        size(data,1) >= 2 && all(isfinite(data(:))))
    error('Acycle:PdaCompatibility:InvalidData', ...
        'DATA must be a finite real floating-point N-by-2 matrix.');
end
coordinate = double(data(:,1));
spacing = diff(coordinate);
if any(~isfinite(spacing)) || any(spacing <= 0)
    error('Acycle:PdaCompatibility:InvalidCoordinates', ...
        'DATA coordinates must be finite and strictly increasing.');
end
sampleInterval = median(spacing);
window = positiveFiniteScalar(window,'WINDOW');
windowIntervals = floor(window/sampleInterval+0.5);
windowSamples = windowIntervals+1;
fftLength = 2^nextpow2(windowSamples);
nyquist = 1/(2*sampleInterval);
options = struct( ...
    'window_length',window, ...
    'step_length',sampleInterval, ...
    'time_bandwidth',positiveFiniteScalar(nw,'NW'), ...
    'fft_length',fftLength, ...
    'total_band',[0,nyquist]);
[powratio,~,~] = acyclePowerDecomposition( ...
    data,double([fmin,fmax]),options);
m = size(powratio,1);
end

function value = positiveFiniteScalar(value,name)
if ~(isnumeric(value) && ~islogical(value) && isreal(value) && ...
        isscalar(value) && isfinite(value) && value > 0)
    error('Acycle:PdaCompatibility:InvalidParameter', ...
        '%s must be a finite positive numeric scalar.',name);
end
value = double(value);
end
