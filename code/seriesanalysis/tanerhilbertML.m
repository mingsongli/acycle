function [tanhilb,ifaze,ifreq,filter,responseFrequency, ...
        ifreqCoordinate] = tanerhilbertML(data,fc,fl,fh,c)
%TANERHILBERTML Corrected, side-effect-free Taner-Hilbert wrapper.
%   [TANHILB,IFAZE,IFREQ,FILTER,F,IFREQCOORDINATE] =
%   TANERHILBERTML(DATA,FC,FL,FH,C) preserves the first three historical
%   outputs and explicitly returns the positive-frequency response and the
%   instantaneous-frequency midpoint coordinates. No base-workspace value is
%   assigned. C=10^q and q must lie in (0,20].
%
%   Historical attribution: Linda Hinnov (December 2006), using the filter
%   described by Turhan Taner in "Attributes revisited" (2000), Rock Solid
%   Images, Inc.

narginchk(4,5);
if nargin < 5 || isempty(c)
    c = 1e12;
end
if ~((isa(data,'double') || isa(data,'single')) && ...
        isreal(data) && ismatrix(data) && size(data,2) == 2 && ...
        ~issparse(data) && size(data,1) >= 8 && all(isfinite(data),'all'))
    error('Acycle:TanerHilbert:InvalidData', ...
        'DATA must be a finite real floating-point N-by-2 matrix with N >= 8.');
end
fl = positiveFiniteScalar(fl,'FL');
fh = positiveFiniteScalar(fh,'FH');
fc = positiveFiniteScalar(fc,'FC');
c = positiveFiniteScalar(c,'C');
if fh <= fl
    error('Acycle:TanerHilbert:InvalidFrequencyOrder', ...
        'Frequencies must satisfy 0 < FL < FH.');
end
midpoint = (fl+fh)/2;
tolerance = 64*eps(max([1,abs(fl),abs(fh),abs(midpoint)]));
if abs(fc-midpoint) > tolerance
    error('Acycle:TanerHilbert:CenterFrequencyMismatch', ...
        'FC must equal the midpoint (FL+FH)/2.');
end
q = log10(c);
if ~(isfinite(q) && q > 0 && q <= 20)
    error('Acycle:TanerHilbert:InvalidRolloff', ...
        'C must equal 10^q for an exponent q in (0,20].');
end

[result,~] = acycleBandpassFilter(double(data),struct( ...
    'method','taner_hilbert', ...
    'lower_frequency',fl, ...
    'upper_frequency',fh, ...
    'rolloff_exponent',q));
tanhilb = [result.coordinate,result.filtered,result.envelope, ...
    result.unwrapped_phase_rad,result.phase_residual_rad];
ifaze = result.wrapped_phase_rad;
ifreq = result.instantaneous_frequency;
filter = result.response_gain;
responseFrequency = result.response_frequency;
ifreqCoordinate = result.instantaneous_frequency_coordinate;
end

function value = positiveFiniteScalar(value,name)
if ~(isnumeric(value) && ~islogical(value) && isreal(value) && ...
        isscalar(value) && isfinite(value) && value > 0)
    error('Acycle:TanerHilbert:InvalidParameter', ...
        '%s must be a finite positive real numeric scalar.',name);
end
value = double(value);
end
