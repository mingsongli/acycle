function [gaussbandx,filter,f] = gaussfilter(datax,dt,fc,fl,fh)
%GAUSSFILTER Corrected Gaussian band-pass compatibility wrapper.
%   [Y,H,F] = GAUSSFILTER(X,DT,FC,FL,FH) preserves the historical five-input,
%   three-output interface while delegating all numerical work to
%   ACYCLEBANDPASSFILTER corrected-bandpass-v2. FC must equal (FL+FH)/2.
%
%   Historical attribution: L. Hinnov (2016) corrected the Fourier-domain
%   zero-padding application; K. Ramamurthy (2013) defined the parameters
%   used to mimic the Gaussian filter in Analyseries 2.0.

narginchk(5,5);
if ~((isa(datax,'double') || isa(datax,'single')) && ...
        isreal(datax) && isvector(datax) && ~issparse(datax) && ...
        numel(datax) >= 8 && all(isfinite(datax(:))))
    error('Acycle:GaussFilter:InvalidData', ...
        'DATAX must be a finite real floating-point vector with at least 8 rows.');
end
dt = positiveFiniteScalar(dt,'DT');
fl = positiveFiniteScalar(fl,'FL');
fh = positiveFiniteScalar(fh,'FH');
fc = positiveFiniteScalar(fc,'FC');
if fh <= fl
    error('Acycle:GaussFilter:InvalidFrequencyOrder', ...
        'Frequencies must satisfy 0 < FL < FH.');
end
midpoint = (fl+fh)/2;
tolerance = 64*eps(max([1,abs(fl),abs(fh),abs(midpoint)]));
if abs(fc-midpoint) > tolerance
    error('Acycle:GaussFilter:CenterFrequencyMismatch', ...
        'FC must equal the midpoint (FL+FH)/2.');
end

values = double(datax(:));
coordinate = (0:numel(values)-1)'*dt;
if any(~isfinite(coordinate))
    error('Acycle:GaussFilter:UnrepresentableCoordinate', ...
        'DT and DATAX length do not produce finite coordinates.');
end
[result,~] = acycleBandpassFilter([coordinate,values],struct( ...
    'method','gaussian', ...
    'lower_frequency',fl, ...
    'upper_frequency',fh));
gaussbandx = result.filtered;
filter = result.response_gain;
f = result.response_frequency;
end

function value = positiveFiniteScalar(value,name)
if ~(isnumeric(value) && ~islogical(value) && isreal(value) && ...
        isscalar(value) && isfinite(value) && value > 0)
    error('Acycle:GaussFilter:InvalidParameter', ...
        '%s must be a finite positive real numeric scalar.',name);
end
value = double(value);
end
