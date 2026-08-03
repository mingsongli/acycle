function [surrogate,meta] = bispectralSurrogate(y,type,iterations)
%BISPECTRALSURROGATE Generate FT or IAAFT null series.
%   Phase-randomized surrogates preserve the periodogram exactly. IAAFT
%   surrogates additionally preserve the observed marginal distribution
%   while iteratively approaching the target Fourier amplitudes. IAAFT is
%   the default; FT phase randomization remains an explicit compatibility and
%   validation tool. RelativeSpectralError is evaluated only on independent
%   positive frequencies, excluding DC and the exact even-N Nyquist bin.

if ~isnumeric(y) || ~isvector(y)
    error('Acycle:Bispectral:InvalidSurrogateData', ...
        'Bispectral surrogates require a numeric vector.');
end
if ~isreal(y)
    error('Acycle:Bispectral:ComplexData', ...
        'Bispectral surrogates require a real-valued input series.');
end
y = double(y(:));
if isempty(y) || any(~isfinite(y))
    error('Acycle:Bispectral:InvalidSurrogateData', ...
        'Bispectral surrogates require a nonempty finite input series.');
end
if nargin < 2 || isempty(type)
    type = 'iaaft';
end
if nargin < 3 || isempty(iterations)
    iterations = 200;
end

switch lower(strtrim(char(type)))
    case {'phase','ft','fourier'}
        spectrum = fft(y);
        targetAmplitude = abs(spectrum);
        n = numel(y);
        if mod(n,2) == 0
            positive = (2:(n/2))';
        else
            positive = (2:((n+1)/2))';
        end
        randomPhase = exp(1i*2*pi*rand(numel(positive),1));
        spectrum(positive) = abs(spectrum(positive)).*randomPhase;
        negative = n-positive+2;
        spectrum(negative) = conj(spectrum(positive));
        surrogate = real(ifft(spectrum));
        spectralError = independentPositiveSpectralError( ...
            surrogate,targetAmplitude);
        meta = struct('Type','phase','Iterations',1, ...
            'RelativeSpectralError',spectralError, ...
            'SpectralErrorDomain',spectralErrorDomain());

    case 'iaaft'
        if ~(isscalar(iterations) && isnumeric(iterations) && ...
                isreal(iterations) && isfinite(iterations) && ...
                iterations >= 1 && iterations == fix(iterations))
            error('Acycle:Bispectral:InvalidIAAFTIterations', ...
                'IAAFTIterations must be a positive integer.');
        end
        iterations = double(iterations);
        targetAmplitude = abs(fft(y));
        sortedTarget = sort(y);
        surrogate = y(randperm(numel(y)));
        previousError = Inf;
        completed = 0;
        for ii = 1:iterations
            phase = angle(fft(surrogate));
            spectralProjection = real(ifft(targetAmplitude.*exp(1i*phase)));
            [~,rankIndex] = sort(spectralProjection,'ascend');
            next = zeros(size(y));
            next(rankIndex) = sortedTarget;
            surrogate = next;
            spectralError = independentPositiveSpectralError( ...
                surrogate,targetAmplitude);
            completed = ii;
            if ii > 1 && abs(previousError-spectralError) <= ...
                    1e-10*max(1,previousError)
                break
            end
            previousError = spectralError;
        end
        meta = struct('Type','iaaft','Iterations',completed, ...
            'RelativeSpectralError',spectralError, ...
            'SpectralErrorDomain',spectralErrorDomain());

    otherwise
        error('Acycle:Bispectral:InvalidSurrogateType', ...
            'SurrogateType must be phase or iaaft.');
end
end

function relativeError = independentPositiveSpectralError(y,targetAmplitude)
% DC is intentionally excluded: it can dominate a global norm despite being
% removed within estimator segments. For even N, the exact Nyquist bin is
% also excluded because the computed bispectral principal domain excludes it.
n = numel(y);
positive = 2:floor((n+1)/2);
if isempty(positive)
    relativeError = 0;
    return
end
candidateAmplitude = abs(fft(y));
target = targetAmplitude(positive);
difference = candidateAmplitude(positive)-target;
relativeError = norm(difference)/max(norm(target),realmin);
end

function text = spectralErrorDomain()
text = 'Independent positive frequencies excluding DC and exact even-N Nyquist';
end
