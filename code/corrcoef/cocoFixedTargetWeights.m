function weights = cocoFixedTargetWeights(orbitPeriods)
%COCOFIXEDTARGETWEIGHTS Fixed sinusoid-amplitude weights for COCO targets.
%
% For nine-period ORBIT9 targets, physical groups are identified by
% descending period rank so deep-time shortening does not change a term's
% identity. The amplitudes follow the historical period2spectrum
% convention:
%   405 kyr and ~100 kyr eccentricity periods : 1.0
%   ~41 kyr obliquity periods                 : 0.8
%   ~20 kyr precession periods                : 0.6
%
% Other target sizes retain threshold-based compatibility with the
% historical seven-period target.

orbitPeriods = orbitPeriods(:);
weights = 0.6 * ones(size(orbitPeriods));
valid = isfinite(orbitPeriods) & orbitPeriods > 0;
if numel(orbitPeriods) == 9 && all(valid) && ...
        numel(unique(orbitPeriods)) == 9
    groups = cocoOrbitGroups(orbitPeriods);
    weights(groups.index == 3) = 0.8;
    weights(groups.index <= 2) = 1.0;
else
    weights(orbitPeriods >= 30 & orbitPeriods < 80) = 0.8;
    weights(orbitPeriods >= 80) = 1.0;
end
weights(~isfinite(orbitPeriods) | orbitPeriods <= 0) = 0;
end
