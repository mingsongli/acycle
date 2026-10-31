function D = multivariateValidateDistanceMatrix(D,name)
%MULTIVARIATEVALIDATEDISTANCEMATRIX Check a square finite symmetric matrix.
%   D = MULTIVARIATEVALIDATEDISTANCEMATRIX(D,NAME) enforces the input
%   contract shared by PCoA, ANOSIM, and PERMANOVA: a square, finite,
%   symmetric matrix with a zero diagonal. The diagonal is forced to zero
%   (self-dissimilarity) and mild asymmetry is averaged out; grossly
%   asymmetric or non-finite input raises an error.

if nargin < 2
    name = 'distance matrix';
end
D = double(D);
if isempty(D) || ndims(D) ~= 2 || size(D,1) ~= size(D,2)
    error('Acycle:Multivariate:MatrixNotSquare', ...
        'The %s must be square (n-by-n).',name);
end
if size(D,1) < 2
    error('Acycle:Multivariate:TooFewSamples', ...
        'The %s needs at least 2 samples.',name);
end
if any(isnan(D(:))) || any(isinf(D(:)))
    error('Acycle:Multivariate:NonFiniteMatrix', ...
        'The %s contains NaN or Inf entries.',name);
end
maxAsymmetry = max(abs(D - D'));
tolerance = 1e-8 + 1e-5 * max(abs(D(:)));
if maxAsymmetry > tolerance
    error('Acycle:Multivariate:AsymmetricMatrix', ...
        ['The %s must be symmetric (max asymmetry %.6g). ', ...
         'Pass the output of multivariateDistanceMatrix.'], ...
        name,maxAsymmetry);
end
D = (D + D') / 2;
D(1:size(D,1)+1:end) = 0;
end
