function [D,metricUsed] = multivariateDistanceMatrix(X,metric,standardize)
%MULTIVARIATEDISTANCEMATRIX Pairwise distance matrix for multivariate data.
%   D = MULTIVARIATEDISTANCEMATRIX(X,METRIC,STANDARDIZE) returns the full
%   symmetric n-by-n distance matrix of the n-by-p data matrix X, where
%   rows are samples (observations) and columns are variables (series).
%
%   METRIC selects the dissimilarity, case-insensitive:
%       'euclidean'   d = sqrt(sum_k (x_ik - x_jk)^2)
%       'manhattan'   d = sum_k |x_ik - x_jk|
%       'braycurtis'  d = sum_k |x_ik - x_jk| / sum_k (x_ik + x_jk)
%       'jaccard'     d = 1 - |A and B| / |A or B| on the non-zero sets
%
%   STANDARDIZE (logical) z-scores each column before the distance is
%   computed, so variables measured in different units contribute
%   comparable spread. Bray-Curtis and Jaccard ignore it by design at the
%   call site; if requested anyway, Bray-Curtis is refused after
%   standardization because z-scores are signed and Bray-Curtis requires
%   non-negative abundances.
%
%   The implementation uses base MATLAB only (no Statistics or other
%   toolboxes). Definitions follow scipy.spatial.distance / R vegan::vegdist.

if nargin < 2 || isempty(metric)
    metric = 'euclidean';
end
if nargin < 3
    standardize = false;
end
if ~islogical(standardize)
    standardize = logical(standardize);
end

X = double(X);
if isempty(X) || size(X,1) < 2
    error('Acycle:Multivariate:TooFewSamples', ...
        'The data matrix must contain at least 2 samples (rows).');
end
if any(isnan(X(:))) || any(isinf(X(:)))
    error('Acycle:Multivariate:NonFiniteData', ...
        'The data matrix contains NaN or Inf values. Remove or interpolate them first.');
end

metricUsed = validateAndNormalizeMetric(metric);

if standardize && strcmp(metricUsed,'braycurtis')
    error('Acycle:Multivariate:StandardizeBrayCurtis', ...
        'Bray-Curtis requires raw non-negative abundances; do not standardize for this metric.');
end

if standardize
    X = zscoreColumns(X);
end

n = size(X,1);
D = zeros(n,n);

switch metricUsed
    case 'euclidean'
        for i = 1:n-1
            differences = X(i+1:end,:) - X(i,:); %#ok<AGROW>
            d = sqrt(sum(differences.^2,2));
            D(i,i+1:end) = d;
            D(i+1:end,i) = d;
        end
    case 'manhattan'
        for i = 1:n-1
            differences = abs(X(i+1:end,:) - X(i,:)); %#ok<AGROW>
            d = sum(differences,2);
            D(i,i+1:end) = d;
            D(i+1:end,i) = d;
        end
    case 'braycurtis'
        if any(X(:) < 0)
            error('Acycle:Multivariate:NegativeData', ...
                ['Bray-Curtis requires non-negative values (abundances, ', ...
                 'percentages, counts). Negative values were found; use ', ...
                 'Euclidean or Manhattan for signed data.']);
        end
        for i = 1:n-1
            numerator = sum(abs(X(i+1:end,:) - X(i,:)),2);
            denominator = sum(X(i+1:end,:) + X(i,:),2);
            d = nan(size(numerator));
            ok = denominator > 0;
            d(ok) = numerator(ok) ./ denominator(ok);
            D(i,i+1:end) = d;
            D(i+1:end,i) = d;
        end
    case 'jaccard'
        presence = X ~= 0;
        for i = 1:n-1
            shared = sum(presence(i+1:end,:) & presence(i,:),2);
            either = sum(presence(i+1:end,:) | presence(i,:),2);
            d = zeros(size(shared));
            ok = either > 0;
            d(ok) = 1 - shared(ok) ./ either(ok);
            D(i,i+1:end) = d;
            D(i+1:end,i) = d;
        end
    otherwise
        % validateAndNormalizeMetric already rejected unknown metrics.
end

% All-zero sample pairs make Bray-Curtis undefined (0/0). Distance-based
% methods below need a fully finite matrix, so surface the problem here
% with an actionable message instead of failing later inside the
% permutation loop.
if any(isnan(D(:)))
    error('Acycle:Multivariate:UndefinedDistance', ...
        ['Bray-Curtis is undefined for pairs of all-zero samples ', ...
         '(both abundances add up to zero). Remove empty samples or ', ...
         'switch to a metric that handles zeros, e.g. Jaccard.']);
end
end


function metricUsed = validateAndNormalizeMetric(metric)
if isstring(metric)
    metric = char(metric);
end
if ~ischar(metric)
    error('Acycle:Multivariate:InvalidMetric', ...
        'METRIC must be a character vector, e.g. ''euclidean''.');
end
metricUsed = lower(strtrim(metric));
validMetrics = {'euclidean','manhattan','braycurtis','jaccard'};
if ~any(strcmp(metricUsed,validMetrics))
    error('Acycle:Multivariate:UnknownMetric', ...
        'Unknown distance metric ''%s''. Valid metrics: %s.', ...
        metric,strjoin(validMetrics,', '));
end
end


function Z = zscoreColumns(X)
mu = mean(X,1);
sigma = std(X,0,1);
sigma(~isfinite(sigma) | sigma == 0) = 1;
Z = (X - mu) ./ sigma;
end
