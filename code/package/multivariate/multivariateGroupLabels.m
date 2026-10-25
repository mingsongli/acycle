function [groupIndex,groupNames,groupCounts] = multivariateGroupLabels(axisValues,boundaries)
%MULTIVARIATEGROUPLABELS Turn axis breakpoints into group labels.
%   [GROUPINDEX,NAMES,COUNTS] = MULTIVARIATEGROUPLABELS(AXIS,BOUNDARIES)
%   assigns each element of AXIS (the common depth/time column of the
%   stacked series) to an interval defined by the ascending BOUNDARIES:
%
%       axis < b(1)                 -> group 1
%       b(k) <= axis < b(k+1)       -> group k+1
%       axis >= b(end)              -> group G
%
%   BOUNDARIES may be given as a numeric vector or as a delimited string
%   ("25 40", "25,40", "25;40"). Empty input yields a single group.
%
%   GROUPINDEX is an n-by-1 vector of positive integers (1..G, only
%   non-empty groups are numbered consecutively), NAMES is a G-by-1 cell
%   of display names ('G1', ...), and COUNTS an n-by-1 column of the
%   group index per sample for convenience.

if ischar(boundaries) || isstring(boundaries)
    boundaries = parseBoundaryString(char(boundaries));
end
boundaries = double(boundaries(:));

axisValues = double(axisValues(:));
n = numel(axisValues);
if n == 0
    error('Acycle:Multivariate:EmptyAxis', ...
        'The depth/time axis is empty.');
end
if any(isnan(axisValues)) || any(isinf(axisValues))
    error('Acycle:Multivariate:NonFiniteAxis', ...
        'The depth/time axis contains NaN or Inf values.');
end

if isempty(boundaries)
    groupIndex = ones(n,1);
    groupNames = {'G1'};
    groupCounts = ones(n,1);
    return
end

if any(isnan(boundaries)) || any(isinf(boundaries))
    error('Acycle:Multivariate:InvalidBoundaries', ...
        'Group boundaries must be finite numbers.');
end
if numel(boundaries) > 1 && any(diff(boundaries) <= 0)
    error('Acycle:Multivariate:UnsortedBoundaries', ...
        'Group boundaries must be strictly ascending (e.g. "25 40" for G1 < 25 <= G2 < 40 <= G3).');
end

rawIndex = sum(axisValues >= boundaries',2) + 1;

% Renumber consecutively if an interval received no samples.
presentGroups = unique(rawIndex);
groupIndex = zeros(n,1);
for k = 1:numel(presentGroups)
    groupIndex(rawIndex == presentGroups(k)) = k;
end
groupNames = cellfun(@(k)sprintf('G%d',k),num2cell(1:numel(presentGroups)), ...
    'UniformOutput',false);
groupCounts = groupIndex;
end


function values = parseBoundaryString(text)
text = strtrim(text);
if isempty(text)
    values = [];
    return
end
tokens = regexp(text,'[\s,;]+','split');
tokens = tokens(~cellfun(@isempty,tokens));
values = str2double(tokens);
if any(isnan(values))
    error('Acycle:Multivariate:UnparseableBoundaries', ...
        'Could not parse the group boundaries "%s". Enter numbers separated by spaces, e.g. "25 40".',text);
end
end
