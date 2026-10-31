function result = multivariateAnosim(D,groups,varargin)
%MULTIVARIATEANOSIM Analysis of similarities (Clarke 1993).
%   RESULT = MULTIVARIATEANOSIM(D,GROUPS) tests whether the between-group
%   ranks of a distance matrix are larger than the within-group ranks.
%
%   Statistic (ranks are ascending distances; rank 1 = most similar pair):
%       R = (mean(rank_B) - mean(rank_W)) / (N/2),  N = n(n-1)/2
%   The denominator N/2 = n(n-1)/4 keeps R inside [-1, 1] (Legendre &
%   Fortin 1989; the same scaling as R vegan::anosim).
%
%   The raw R is biased upward when group sizes are unequal, so the PAI
%   correction of vegan::anosim is reported alongside it:
%       R_PAI = (R - E[R|H0]) / (1 - E[R|H0]),  E[R|H0] = -1/(n-1)
%
%   Significance comes from a one-sided permutation test over group-label
%   shuffles with the (1 + count)/(n + 1) p-value form of Phipson & Smyth
%   (2010). Label shuffling keeps the group sizes, hence the numbers of
%   within- and between-group pairs, fixed.
%
%   Optional name-value arguments:
%       'Permutations'  number of label shuffles (default 999)
%       'RandomSeed'    integer seed, [] for a random draw (default [])
%
%   RESULT fields:
%       statistic        raw R
%       rPai             PAI-corrected R
%       pValue           permutation p-value
%       permutations     number of permutations used
%       randomSeed       effective seed (for reproduction)
%       meanRankWithin   mean within-group rank
%       meanRankBetween  mean between-group rank
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

% ANOSIM contrasts between- with within-group rank sums, so both kinds of
% pair must exist (mirrors vegan::anosim, which requires replication).
if groupCount < 2
    error('Acycle:Multivariate:NeedTwoGroups', ...
        'ANOSIM requires at least 2 groups; provide group boundaries in the dialog.');
end
if n == groupCount
    error('Acycle:Multivariate:NeedReplication', ...
        ['ANOSIM requires at least one within-group pair, so at least ', ...
         'one group must contain 2 or more samples.']);
end

p = inputParser;
p.addParameter('Permutations',999,@(x)isscalar(x) && x >= 1);
p.addParameter('RandomSeed',[]);
p.parse(varargin{:});
nPermutations = round(p.Results.Permutations);
randomSeed = p.Results.RandomSeed;

% Rank the unordered pairs once (ascending distance; ties averaged).
triUpper = triu(true(n),1);
ranks = zeros(n,n);
ranks(triUpper) = multivariateTiedRank(D(triUpper));
ranks = ranks + ranks';

isBetween = triUpper & (groups(:) ~= groups(:)');

meanRankBetween = mean(ranks(isBetween));
meanRankWithin = mean(ranks(~isBetween & triUpper));
totalPairs = n * (n - 1) / 2;
observedR = (meanRankBetween - meanRankWithin) / (totalPairs / 2);

[pairI,pairJ] = find(triUpper);
pairRanks = ranks(triUpper);

permuteFcn = @() permutedR(pairRanks,pairI,pairJ,n);
[pValue,nullValues,seedUsed] = multivariatePermutationPvalue( ...
    observedR,permuteFcn,nPermutations,randomSeed);

% PAI correction (Clarke 1993 null expectation; matches vegan::anosim).
expectedR = -1 / (n - 1);
rPai = (observedR - expectedR) / (1 - expectedR);

counts = zeros(groupCount,2);
for k = 1:groupCount
    counts(k,:) = [uniqueGroups(k),sum(groups == uniqueGroups(k))];
end

result = struct();
result.statistic = observedR;
result.rPai = rPai;
result.pValue = pValue;
result.permutations = nPermutations;
result.randomSeed = seedUsed;
result.meanRankWithin = meanRankWithin;
result.meanRankBetween = meanRankBetween;
result.nullDistribution = nullValues;
result.groupCounts = counts;
result.nSamples = n;
result.nGroups = groupCount;
result.distanceMatrix = D;
end


function r = permutedR(pairRanks,pairI,pairJ,n)
% Recompute R for a random label shuffle. The pair set and the group
% sizes are fixed; only the group membership of each sample changes.
permutedGroups = randperm(n)';
sameGroup = permutedGroups(pairI) == permutedGroups(pairJ);
meanW = mean(pairRanks(sameGroup));
meanB = mean(pairRanks(~sameGroup));
totalPairs = n * (n - 1) / 2;
r = (meanB - meanW) / (totalPairs / 2);
end
