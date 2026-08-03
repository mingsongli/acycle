function result = bispectralAnalyze(data,varargin)
%BISPECTRALANALYZE Bispectrum, biphase, and bicoherence of a time series.
%   RESULT = BISPECTRALANALYZE(DATA) analyzes the first two columns of DATA.
%   The first column is coordinate (time/depth); the second is the signal.
%
%   RESULT = BISPECTRALANALYZE(DATA,OPTIONS) overrides fields returned by
%   BISPECTRALDEFAULTS. Name/value pairs are also accepted.
%
%   The returned complex bispectrum uses
%       B(f1,f2) = mean[X(f1) X(f2) conj(X(f1+f2))].
%   BicoherenceSquared is the Kim-Powers normalization and is bounded in
%   [0,1]. High values mean stable quadratic phase coupling; they do not by
%   themselves establish causality or physical energy transfer.
%   The API default performs no inference. Formal map inference uses IAAFT
%   maximum-statistic surrogates; analytical, pointwise, and FT-phase modes
%   remain available only for compatibility and method validation.

options = bispectralDefaults(data);
options = mergeOptions(options,varargin{:});
validateOptions(options);
notify(options,0,'Validating bispectral input');
[processed,preprocessing] = bispectralPreprocess(data,options);
notify(options,0.02,'Estimating bispectrum and bicoherence');
[estimate,state] = bispectralEstimate( ...
    processed(:,2),preprocessing.SampleInterval,options);
significance = bispectralSignificance( ...
    processed(:,2),preprocessing.SampleInterval,options,estimate,state);

result = estimate;
if isfield(significance,'Warnings') && ~isempty(significance.Warnings)
    combinedWarnings = [result.Meta.Warnings(:);significance.Warnings(:)];
    result.Meta.Warnings = unique(combinedWarnings,'stable')';
end
result.ProcessedData = processed;
if isnumeric(data) && size(data,2) >= 2
    result.InputData = double(data(:,1:2));
else
    result.InputData = [];
end
result.Preprocessing = preprocessing;
result.Significance = significance;
result.SignificantMask = significance.SignificantMask;
storedOptions = options;
storedOptions.ProgressFcn = [];
result.Options = storedOptions;
result.InputName = char(options.InputName);
result.CoordinateUnit = char(options.CoordinateUnit);
result.Created = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
result.Version = 'Acycle bispectral 1.0';
result.Interpretation = [ ...
    'Bicoherence quantifies repeatable quadratic phase coupling at ', ...
    '(f1,f2,f1+f2). It is not, alone, evidence of causality or energy transfer.'];
notify(options,1,'Bispectral analysis complete');
end

function options = mergeOptions(options,varargin)
if isempty(varargin)
    return
end
if isscalar(varargin) && isstruct(varargin{1})
    supplied = varargin{1};
    names = fieldnames(supplied);
    for ii = 1:numel(names)
        name = names{ii};
        if ~isfield(options,name)
            error('Acycle:Bispectral:UnknownOption','Unknown option: %s.',name);
        end
        options.(name) = supplied.(name);
    end
    return
end
if mod(numel(varargin),2) ~= 0
    error('Acycle:Bispectral:InvalidOptions', ...
        'Options must be a structure or name/value pairs.');
end
known = fieldnames(options);
for ii = 1:2:numel(varargin)
    requested = char(varargin{ii});
    index = find(strcmpi(requested,known),1);
    if isempty(index)
        error('Acycle:Bispectral:UnknownOption','Unknown option: %s.',requested);
    end
    options.(known{index}) = varargin{ii+1};
end
end

function validateOptions(options)
inputPolicy = strtrim(char(options.InputPolicy));
if ~any(strcmpi(inputPolicy,{'prepare','strict'}))
    error('Acycle:Bispectral:InvalidInputPolicy', ...
        'InputPolicy must be prepare or strict.');
end
scalarNonnegative = {'FrequencyMin'};
for ii = 1:numel(scalarNonnegative)
    value = options.(scalarNonnegative{ii});
    if ~(isscalar(value) && isnumeric(value) && isreal(value) && ...
            isfinite(value) && value >= 0)
        error('Acycle:Bispectral:InvalidOption', ...
            '%s must be a finite nonnegative scalar.',scalarNonnegative{ii});
    end
end
integerNonnegative = {'PolynomialOrder','RandomSeed'};
for ii = 1:numel(integerNonnegative)
    value = options.(integerNonnegative{ii});
    if ~(isscalar(value) && isnumeric(value) && isreal(value) && ...
            isfinite(value) && value >= 0 && value == fix(value))
        error('Acycle:Bispectral:InvalidOption', ...
            '%s must be a finite nonnegative integer.',integerNonnegative{ii});
    end
end
if options.RandomSeed > double(intmax('uint32'))
    error('Acycle:Bispectral:InvalidOption', ...
        'RandomSeed must not exceed 2^32-1.');
end
integerPositive = {'NumSegments','MaxFrequencyBins', ...
    'FrequencySmoothingSpan','NumSurrogates','IAAFTIterations'};
for ii = 1:numel(integerPositive)
    value = options.(integerPositive{ii});
    if ~(isscalar(value) && isnumeric(value) && isreal(value) && ...
            isfinite(value) && value > 0 && value == fix(value))
        error('Acycle:Bispectral:InvalidOption', ...
            '%s must be a finite positive integer.',integerPositive{ii});
    end
end
scalarPositive = {'ZeroPaddingFactor'};
for ii = 1:numel(scalarPositive)
    value = options.(scalarPositive{ii});
    if ~(isscalar(value) && isnumeric(value) && isreal(value) && ...
            isfinite(value) && value > 0)
        error('Acycle:Bispectral:InvalidOption', ...
            '%s must be a finite positive scalar.',scalarPositive{ii});
    end
end
if ~(isscalar(options.OverlapPercent) && isnumeric(options.OverlapPercent) && ...
        isreal(options.OverlapPercent) && isfinite(options.OverlapPercent))
    error('Acycle:Bispectral:InvalidOption','OverlapPercent must be finite.');
end
if ~isempty(options.FrequencyMax) && ...
        ~(isscalar(options.FrequencyMax) && isnumeric(options.FrequencyMax) && ...
        isreal(options.FrequencyMax) && isfinite(options.FrequencyMax) && ...
        options.FrequencyMax > 0)
    error('Acycle:Bispectral:InvalidOption','FrequencyMax must be empty or positive.');
end
if ~isempty(options.SampleInterval) && ...
        ~(isscalar(options.SampleInterval) && isnumeric(options.SampleInterval) && ...
        isreal(options.SampleInterval) && isfinite(options.SampleInterval) && ...
        options.SampleInterval > 0)
    error('Acycle:Bispectral:InvalidOption','SampleInterval must be empty or positive.');
end
if ~isempty(options.NFFT) && ...
        ~(isscalar(options.NFFT) && isnumeric(options.NFFT) && ...
        isreal(options.NFFT) && isfinite(options.NFFT) && ...
        options.NFFT > 0 && options.NFFT == fix(options.NFFT))
    error('Acycle:Bispectral:InvalidOption', ...
        'NFFT must be empty or a positive integer.');
end
if ~isempty(options.ProgressFcn) && ~isa(options.ProgressFcn,'function_handle')
    error('Acycle:Bispectral:InvalidProgressFcn','ProgressFcn must be a function handle.');
end
if ~(isscalar(options.IAAFTSpectralTolerance) && ...
        isnumeric(options.IAAFTSpectralTolerance) && ...
        isreal(options.IAAFTSpectralTolerance) && ...
        isfinite(options.IAAFTSpectralTolerance) && ...
        options.IAAFTSpectralTolerance > 0 && ...
        options.IAAFTSpectralTolerance <= 1)
    error('Acycle:Bispectral:InvalidIAAFTSpectralTolerance', ...
        'IAAFTSpectralTolerance must lie in (0,1].');
end
if ~isempty(options.MaxSurrogateAttempts) && ...
        ~(isscalar(options.MaxSurrogateAttempts) && ...
        isnumeric(options.MaxSurrogateAttempts) && ...
        isreal(options.MaxSurrogateAttempts) && ...
        isfinite(options.MaxSurrogateAttempts) && ...
        options.MaxSurrogateAttempts >= options.NumSurrogates && ...
        options.MaxSurrogateAttempts == fix(options.MaxSurrogateAttempts))
    error('Acycle:Bispectral:InvalidMaxSurrogateAttempts', ...
        ['MaxSurrogateAttempts must be empty or an integer no smaller than ', ...
         'NumSurrogates.']);
end
if ~(isscalar(options.IrregularTolerance) && isnumeric(options.IrregularTolerance) && ...
        isreal(options.IrregularTolerance) && ...
        isfinite(options.IrregularTolerance) && options.IrregularTolerance >= 0)
    error('Acycle:Bispectral:InvalidIrregularTolerance', ...
        'IrregularTolerance must be a finite nonnegative scalar.');
end
if ~(isscalar(options.GapWarningFactor) && isnumeric(options.GapWarningFactor) && ...
        isreal(options.GapWarningFactor) && ...
        isfinite(options.GapWarningFactor) && options.GapWarningFactor > 0)
    error('Acycle:Bispectral:InvalidGapWarningFactor', ...
        'GapWarningFactor must be a finite positive scalar.');
end
keepFields = {'PlotKeepStrongestBispectrumFraction', ...
    'PlotKeepStrongestBicoherenceFraction'};
for ii = 1:numel(keepFields)
    value = options.(keepFields{ii});
    if ~(isscalar(value) && isnumeric(value) && isfinite(value) && ...
            value > 0 && value <= 1)
        error('Acycle:Bispectral:InvalidPlotKeepStrongest', ...
            '%s must lie in (0,1].',keepFields{ii});
    end
end
if ~(isscalar(options.PlotColorGrid) && isnumeric(options.PlotColorGrid) && ...
        isfinite(options.PlotColorGrid) && options.PlotColorGrid >= 4 && ...
        options.PlotColorGrid <= 256 && options.PlotColorGrid == round(options.PlotColorGrid))
    error('Acycle:Bispectral:InvalidPlotColorGrid', ...
        'PlotColorGrid must be an integer from 4 through 256.');
end
periods = options.PlotReferencePeriods;
validPeriods = isempty(periods) || ...
    (isnumeric(periods) && isvector(periods) && ...
    all(isfinite(periods(:))) && all(periods(:) > 0));
if ~validPeriods
    error('Acycle:Bispectral:InvalidPlotReferencePeriods', ...
        'PlotReferencePeriods must be empty or a vector of positive finite periods.');
end
pairs = options.PlotFrequencyPairs;
validPairs = isnumeric(pairs) && isreal(pairs) && ...
    (isempty(pairs) || (ismatrix(pairs) && size(pairs,2) == 2 && ...
    all(isfinite(pairs(:))) && all(pairs(:) > 0)));
if ~validPairs
    error('Acycle:Bispectral:InvalidPlotFrequencyPairs', ...
        ['PlotFrequencyPairs must be empty or an N-by-2 matrix of ', ...
         'positive finite frequencies.']);
end
end

function notify(options,fraction,message)
if ~isempty(options.ProgressFcn)
    feval(options.ProgressFcn,max(0,min(1,fraction)),message);
end
end
