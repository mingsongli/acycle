function options = bispectralDefaults(data)
%BISPECTRALDEFAULTS Recommended defaults for Acycle bispectral analysis.
%   OPTIONS = BISPECTRALDEFAULTS(DATA) returns a documented options
%   structure. DATA is optional and is used only to choose a feasible
%   number of segments for short records.
%
%   The default estimator is a direct FFT bispectrum averaged over Hann-
%   tapered, 50%-overlapped segments (WOSA). The alternative estimator is
%   a two-dimensional frequency-smoothed direct estimate. Both estimators
%   use the same bounded magnitude-squared bicoherence normalization.

options = struct( ...
    'InputPolicy','prepare', ...               % prepare | strict
    'Estimator','wosa', ...                  % wosa | frequency-smoothed
    'NumSegments',8, ...
    'OverlapPercent',50, ...
    'Window','hann', ...                    % hann | hamming | blackman | rectangular
    'SegmentDetrendMethod','mean', ...       % none | mean | linear
    'FrequencySmoothingSpan',3, ...         % odd span; 3 gives a 7-triad hexagon
    'FrequencySmoothingKernel','daniell', ... % daniell | cosine
    'DetrendMethod','linear', ...           % none | mean | linear | polynomial
    'PolynomialOrder',2, ...
    'Standardize',true, ...
    'Interpolate','auto', ...               % auto | always | never
    'InterpolationMethod','linear', ...     % linear | pchip | makima
    'SampleInterval',[], ...                % [] uses median original spacing
    'IrregularTolerance',0.01, ...          % max relative spacing departure
    'GapWarningFactor',5, ...
    'NFFT',[], ...                          % [] chooses estimator-safe value
    'ZeroPaddingFactor',1, ...
    'MaxFrequencyBins',512, ...             % maximum computed axis bins
    'FrequencyMin',0, ...                   % plot limit only; estimator keeps full domain
    'FrequencyMax',[], ...                  % plot limit only; [] shows full domain
    'SignificanceMethod','none', ...        % API default: no inference
    'ConfidenceLevel',0.95, ...
    'NumSurrogates',999, ...                % formal IAAFT max-statistic inference
    'SurrogateType','iaaft', ...            % formal default; phase retained for API validation
    'IAAFTIterations',200, ...
    'IAAFTSpectralTolerance',0.02, ...       % non-DC independent-positive FFT-amplitude error
    'MaxSurrogateAttempts',[], ...           % [] allows 10% (at least 10) replacements
    'RandomSeed',1, ...
    'ProgressFcn',[], ...
    'InputName','', ...
    'CoordinateUnit','unit', ...
    'PlotQuantity','overview', ...
    'PlotKeepStrongestBispectrumFraction',0.5, ... % plot-only: top |B| tail
    'PlotKeepStrongestBicoherenceFraction',0.5, ... % plot-only: top b^2 tail
    'PlotColorGrid',32, ...                % plot-only: discrete colormap entries
    'PlotReferencePeriods',[], ...         % plot-only: f1+f2=1/period guide lines
    'PlotFrequencyPairs',zeros(0,2), ...   % plot-only: [f1 f2] coordinate guides
    'PlotPeakCount',5, ...
    'ShowPeriodAxes',true);

if nargin < 1 || isempty(data)
    return
end

if istable(data)
    try
        data = table2array(data);
    catch
        return
    end
end
if ~isnumeric(data)
    return
end
if ~isreal(data)
    error('Acycle:Bispectral:ComplexData', ...
        'Bispectral analysis requires real coordinates and a real-valued signal.');
end

n = size(data,1);
if size(data,2) >= 1
    finiteRows = all(isfinite(data(:,1:min(2,size(data,2)))),2);
    x = data(finiteRows,1);
    n = numel(unique(x));
end
minimumSegmentLength = 32;
maxSegments = floor(1+(n/minimumSegmentLength-1)/(1-options.OverlapPercent/100));
if maxSegments >= 3
    options.NumSegments = min(options.NumSegments,maxSegments);
else
    % Three 32-point WOSA segments do not fit; the full-record frequency
    % smoother remains well-defined for a record of 32--63 samples.
    options.Estimator = 'frequency-smoothed';
end
end
