function weights = cocoFixedTargetWeights(orbitPeriods)
%COCOFIXEDTARGETWEIGHTS Fixed sinusoid-amplitude weights for COCO targets.
%
% The grouping follows the historical period2spectrum convention:
%   405 kyr and ~100 kyr eccentricity periods : 1.0
%   ~41 kyr obliquity periods                 : 0.8
%   ~20 kyr precession periods                : 0.6
%
% Period-based grouping supports both the historical seven-period target
% and the current nine-period astronomical target.

orbitPeriods = orbitPeriods(:);
weights = 0.6 * ones(size(orbitPeriods));
weights(orbitPeriods >= 30 & orbitPeriods < 80) = 0.8;
weights(orbitPeriods >= 80) = 1.0;
weights(~isfinite(orbitPeriods) | orbitPeriods <= 0) = 0;
end
