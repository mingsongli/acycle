function [pValue,nullValues,seedUsed] = ...
        multivariatePermutationPvalue(observed,statisticFcn,nPermutations,randomSeed)
%MULTIVARIATEPERMUTATIONPVALUE Monte Carlo permutation p-value.
%   [P,NULL,SEED] = MULTIVARIATEPERMUTATIONPVALUE(OBSERVED,FCN,NPERM,SEED)
%   calls FCN() NPERM times to build the null distribution and returns the
%   one-sided p-value
%
%       p = (1 + #{null >= observed}) / (nValid + 1)
%
%   using the (1 + count) / (n + 1) form of Phipson & Smyth (2010), so the
%   p-value is strictly positive even when no permutation reaches the
%   observed statistic. Permutations returning non-finite statistics are
%   excluded from both counts; an error is raised when no permutation is
%   finite at all.
%
%   SEED: [] or empty draws a fresh integer seed from the global stream
%   and reports it back in SEED so the run can be reproduced; a numeric
%   seed is used directly. Mersenne Twister ('twister') is used in both
%   cases, and the previous global generator state is restored on exit.

if nargin < 3 || isempty(nPermutations)
    nPermutations = 999;
end
if ~isscalar(nPermutations) || nPermutations < 1 || nPermutations ~= round(nPermutations)
    error('Acycle:Multivariate:InvalidPermutations', ...
        'The number of permutations must be a positive integer.');
end

oldGeneratorState = rng;
restoreRng = onCleanup(@() rng(oldGeneratorState)); %#ok<NASGU>
if isempty(randomSeed)
    seedUsed = randi(2^31-1);
    rng(seedUsed,'twister');
elseif ~isscalar(randomSeed) || ~isnumeric(randomSeed) || randomSeed < 0 ...
        || randomSeed ~= round(randomSeed)
    error('Acycle:Multivariate:InvalidSeed', ...
        'The random seed must be a non-negative integer (leave empty for a random seed).');
else
    seedUsed = double(randomSeed);
    rng(seedUsed,'twister');
end

nullValues = nan(nPermutations,1);
for m = 1:nPermutations
    nullValues(m) = statisticFcn();
end

finite = isfinite(nullValues);
nValid = sum(finite);
if nValid == 0
    error('Acycle:Multivariate:NullUndefined', ...
        ['Every permutation produced an undefined statistic, so there ', ...
         'is no null distribution to compare against.']);
end
nGe = sum(nullValues(finite) >= observed);
pValue = (1 + nGe) / (nValid + 1);
end
