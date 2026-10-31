function result = multivariatePcoa(D,varargin)
%MULTIVARIATEPCOA Principal coordinate analysis of a distance matrix.
%   RESULT = MULTIVARIATEPCOA(D) runs Gower (1966) principal coordinate
%   analysis (classical metric multidimensional scaling) on the symmetric
%   n-by-n distance matrix D.
%
%   RESULT = MULTIVARIATEPCOA(D,'Correction','lingoes') applies the
%   Lingoes (1971) correction before embedding: a constant
%   c = 2*|lambda_min| is added to the OFF-DIAGONAL squared distances,
%   which shifts every non-trivial eigenvalue by exactly +c/2 and lands
%   the most negative eigenvalue on zero. 'cmdscale' (default) keeps the
%   R cmdscale convention: negative eigenvalues are excluded from the
%   coordinates and only reported.
%
%   Mathematical outline:
%       B = -1/2 * J * D^2 * J,  J = I - (1/n) * ones(n)
%       B = U * diag(lambda) * U'
%       coordinates = U * sqrt(max(lambda, 0))
%   Proportions follow cmdscale(eig=TRUE): each positive eigenvalue
%   divided by the sum of ALL positive eigenvalues, computed before any
%   truncation.
%
%   RESULT fields:
%       coordinates           n-by-k embedding (k = min(n-1, 20))
%       eigenvalues           k sorted eigenvalues (descending)
%       proportionExplained   percent per axis of the k reported
%       cumulativeProportion  cumulative percent
%       allEigenvalues        full n-vector of sorted eigenvalues
%       negativeEigenvalueSum sum of negative eigenvalues (0 if none)
%       correction            'cmdscale' or 'lingoes'
%       distanceMatrix        the (possibly zero-diagonal) input matrix

p = inputParser;
p.addParameter('Correction','cmdscale',@(c)any(strcmpi(c,{'cmdscale','none','lingoes'})));
p.parse(varargin{:});
correction = lower(p.Results.Correction);
if strcmp(correction,'none')
    correction = 'cmdscale';
end

D = multivariateValidateDistanceMatrix(D,'distance matrix');
n = size(D,1);

Dsq = D .^ 2;
J = eye(n) - ones(n)/n;
B = -0.5 * J * Dsq * J;
B = (B + B') / 2;

if strcmp(correction,'lingoes')
    lambda = eigEigenvalues(B);
    negative = lambda(lambda < 0);
    if ~isempty(negative)
        shift = 2 * abs(min(negative));
        Dsq = Dsq + shift * (ones(n) - eye(n));
        B = -0.5 * J * Dsq * J;
        B = (B + B') / 2;
    end
end

[eigenvalues,eigenvectors] = eigFull(B);

% Sort descending; axes are ranked by signed eigenvalue so a large
% negative eigenvalue cannot displace genuine positive axes.
[eigenvalues,order] = sort(eigenvalues,'descend');
eigenvectors = eigenvectors(:,order);

negativeSum = sum(eigenvalues(eigenvalues < 0));
if strcmp(correction,'lingoes') && negativeSum < 0
    % After the shift the residual negative part is floating-point slack
    % only; clip so sqrt() below stays well defined.
    eigenvalues(eigenvalues < 0) = 0;
    negativeSum = 0;
end

positivePart = max(eigenvalues,0);
coordinates = eigenvectors .* reshape(sqrt(positivePart),1,n);

totalPositive = sum(positivePart);
if totalPositive > 0
    proportionAll = positivePart / totalPositive * 100;
else
    proportionAll = zeros(size(eigenvalues));
end

componentCount = min(n-1,20);
result = struct();
result.coordinates = coordinates(:,1:componentCount);
result.eigenvalues = eigenvalues(1:componentCount);
result.proportionExplained = proportionAll(1:componentCount);
result.cumulativeProportion = cumsum(result.proportionExplained);
result.allEigenvalues = eigenvalues;
result.negativeEigenvalueSum = negativeSum;
result.correction = correction;
result.distanceMatrix = D;
end


function lambda = eigEigenvalues(B)
lambda = eig((B + B') / 2);
lambda = real(lambda);
end


function [eigenvalues,eigenvectors] = eigFull(B)
[vectors,diagonal] = eig((B + B') / 2);
eigenvalues = real(diag(diagonal));
eigenvectors = real(vectors);
end
