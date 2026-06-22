function targetp = cocoGetPower(theoredML96_pow, orbit9, sr)
%COCOGETPOWER Interpolate theoretical spectral power at orbital frequencies.
%
% INPUTS:
%   theoredML96_pow - Theoretical power spectrum:
%                     column 1: spatial frequency (cycles/m)
%                     column 2: spectral power
%   orbit9          - Nine orbital periods (yr)
%   sr              - Sedimentation rate (cm/kyr)
%
% OUTPUT:
%   targetp         - Interpolated power at the nine orbital frequencies
%
% The orbital periods are converted to spatial frequencies according to:
%
%   spatial frequency = 1 / cycle thickness
%
% where:
%
%   cycle thickness (m) = period (kyr) * sr (cm/kyr) / 100

% Validate inputs
validateattributes(theoredML96_pow, {'numeric'}, ...
    {'2d', 'real', 'finite', 'nonempty'}, mfilename, 'theoredML96_pow');

validateattributes(orbit9, {'numeric'}, ...
    {'vector', 'real', 'finite', 'positive'}, mfilename, 'orbit9');

validateattributes(sr, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'positive'}, mfilename, 'sr');

if size(theoredML96_pow, 2) < 2
    error('theoredML96_pow must contain at least two columns.');
end

% Convert orbital periods to spatial frequencies (cycles/m)
cycleThicknessM = orbit9 .* sr ./ 100;
targetFreq = 1 ./ cycleThicknessM;

% Interpolate the theoretical power spectrum
% Frequencies outside the available range return NaN
targetp = interp1( ...
    theoredML96_pow(:,1), ...
    theoredML96_pow(:,2), ...
    targetFreq, ...
    'linear','extrap');
end