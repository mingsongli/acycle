function result = multivariatePermanova(D,groups,varargin)
%MULTIVARIATEPERMANOVA Permutational multivariate analysis of variance.
%   RESULT = MULTIVARIATEPERMANOVA(D,GROUPS) tests whether groups differ
%   in multivariate location, from the distance matrix alone, following
%   Anderson (2001). Sums of squares are computed over UNORDERED pairs:
%
%       SS_T = (1/n)   * sum_{i<j}       d_ij^2
%       SS_W = sum_g   (1/n_g) * sum_{i<j in g} d_ij^2
%       SS_B = SS_T - SS_W
%       F    = (SS_B / (G-1)) / (SS_W / (n-G))
%
%   The n and n_g denominators are sample/group COUNTS, the form
%   reproduced by R vegan::adonis2. Significance comes from a one-sided
%   permutation test over group-label shuffles with the
%   (1 + count)/(n + 1) p-value form of Phipson & Smyth (2010).
%
%   Optional name-value arguments:
%       'Permutations'  number of label shuffles (default 999)
%       'RandomSeed'    integer seed, [] for a random draw (default [])
%
%   RESULT fields:
%       fStatistic       observed pseudo-F
%       pValue           permutation p-value
%       permutations     number of permutations used
%       randomSeed       effective seed (for reproduction)
%       ssBetween, ssWithin, ssTotal
%       dfBetween, dfWithin
%       msBetween, msWithin
%       rSquared         SS_B / SS_T (variance explained by grouping)
%       groupCounts      per-group sample counts, [groupIndex count] rows
%       nSamples, nGroups, distanceMatrix

D = multivariateValidateDistanceMatrix(D,'distance matrix');
n = size(D,1);

groups = double(groups(:));
if numel(groups) ~= n
    error('Acycle:Multivariate:GroupMismatch', ...
        'The number of group labels (%d) must match the distance matrix size (%d).', ...
        numel(groups),n);
end
if any(isnan(groups)) || any(groups ~= round(groups)) || any(groups < 1)
    error('Acycle:Multivariate:InvalidGroups', ...
        'Group labels must be positive integers (use multivariateGroupLabels).');
end

uniqueGroups = unique(groups);
groupCount = numel(uniqueGroups);

% A design with a single group has nothing to contrast; refuse it the way
% ANOSIM does rather than reporting F = 0, p = 1.
if groupCount < 2
    error('Acycle:Multivariate:NeedTwoGroups', ...
        'PERMANOVA requires at least 2 groups; provide group boundaries in the dialog.');
end

p = inputParser;
p.addParameter('Permutations',999,@(x)isscalar(x) && x >= 1);
p.addParameter('RandomSeed',[]);
p.parse(varargin{:});
nPermutations = round(p.Results.Permutations);
randomSeed = p.Results.RandomSeed;

[pairI,pairJ] = find(triu(true(n),1));
pairD2 = D(sub2ind([n n],pairI,pairJ)) .^ 2;

observedF = computeF(pairD2,pairI,pairJ,groups,n,groupCount,true);

permuteFcn = @() computeF(pairD2,pairI,pairJ,randperm(n)',n,groupCount,false);
[pValue,nullValues,seedUsed] = multivariatePermutationPvalue( ...
    observedF,permuteFcn,nPermutations,randomSeed);

% Recover the observed decomposition for reporting.
[~,ssBetween,ssWithin,dfBetween,dfWithin,ssTotal] = ...
    computeDecomposition(pairD2,pairI,pairJ,groups,n);

msBetween = ssBetween / dfBetween;
if dfWithin > 0
    msWithin = ssWithin / dfWithin;
else
    msWithin = 0;
end

counts = zeros(groupCount,2);
for k = 1:groupCount
    counts(k,:) = [uniqueGroups(k),sum(groups == uniqueGroups(k))];
end

result = struct();
result.fStatistic = observedF;
result.pValue = pValue;
result.permutations = nPermutations;
result.randomSeed = seedUsed;
result.ssBetween = ssBetween;
result.ssWithin = ssWithin;
result.ssTotal = ssTotal;
result.dfBetween = dfBetween;
result.dfWithin = dfWithin;
result.msBetween = msBetween;
result.msWithin = msWithin;
result.nullDistribution = nullValues;
if ssTotal > 0
    result.rSquared = ssBetween / ssTotal;
else
    result.rSquared = 0;
end
result.groupCounts = counts;
result.nSamples = n;
result.nGroups = groupCount;
result.distanceMatrix = D;
end


function [f,ssBetween,ssWithin,dfBetween,dfWithin] = ...
        computeF(pairD2,pairI,pairJ,groups,n,groupCount,strict)
[~,ssBetween,ssWithin,dfBetween,dfWithin] = ...
    computeDecomposition(pairD2,pairI,pairJ,groups,n);

if dfBetween <= 0
    f = 0;
    return
end
msBetween = ssBetween / dfBetween;
if dfWithin <= 0
    if strict
        error('Acycle:Multivariate:NoResidualDf', ...
            ['PERMANOVA F is undefined: no residual degrees of freedom ', ...
             '(n = %d samples, G = %d groups, n - G = %d). Add more ', ...
             'samples or fewer groups.'],n,groupCount,dfWithin);
    end
    f = Inf;
    return
end
msWithin = ssWithin / dfWithin;
if msWithin <= 0
    if strict
        error('Acycle:Multivariate:ZeroWithinDispersion', ...
            ['PERMANOVA F is undefined: zero within-group dispersion ', ...
             '(every group is a set of identical samples). Check for ', ...
             'duplicated rows in the input.']);
    end
    f = Inf;
    return
end
f = msBetween / msWithin;
end


function [ssTotal,ssBetween,ssWithin,dfBetween,dfWithin] = ...
        computeDecomposition(pairD2,pairI,pairJ,groups,n)
% Anderson (2001) decomposition over unordered pairs. The n and n_g
% denominators are the sample and group counts (see the header).
nPair = numel(pairD2);
ssTotal = sum(pairD2) / n;

uniqueGroups = unique(groups);
ssWithin = 0;
for k = 1:numel(uniqueGroups)
    inGroupK = ismember(groups(pairI),uniqueGroups(k)) & ...
               ismember(groups(pairJ),uniqueGroups(k));
    countK = sum(groups == uniqueGroups(k));
    if countK < 2
        continue
    end
    ssWithin = ssWithin + sum(pairD2(inGroupK)) / countK;
end
ssBetween = ssTotal - ssWithin;
dfBetween = numel(uniqueGroups) - 1;
dfWithin = n - numel(uniqueGroups);
if nPair == 0
    ssTotal = 0;
end
end
