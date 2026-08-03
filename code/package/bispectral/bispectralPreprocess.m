function [processed,meta] = bispectralPreprocess(data,options)
%BISPECTRALPREPROCESS Prepare a two-column series for FFT bispectra.
%   [PROCESSED,META] = BISPECTRALPREPROCESS(DATA,OPTIONS) removes invalid
%   rows, sorts coordinates, averages duplicate coordinates, regularizes
%   uneven sampling when requested, detrends, and optionally standardizes.

if istable(data)
    data = table2array(data);
end
if ~isnumeric(data) || ~ismatrix(data) || size(data,2) < 2
    error('Acycle:Bispectral:InvalidData', ...
        'Input must be a numeric array with coordinate and value columns.');
end
if ~isreal(data(:,1:2))
    error('Acycle:Bispectral:ComplexData', ...
        'Bispectral analysis requires real coordinates and a real-valued signal.');
end

data = double(data(:,1:2));
meta = struct();
meta.OriginalCount = size(data,1);
meta.Warnings = {};
inputPolicy = lower(strtrim(char(options.InputPolicy)));
meta.InputPolicy = inputPolicy;
switch inputPolicy
    case 'strict'
        if any(~isfinite(data(:)))
            error('Acycle:Bispectral:StrictNonfiniteData', ...
                ['Strict input policy does not remove nonfinite rows. ', ...
                 'Prepare a finite two-column series before analysis.']);
        end
        if size(data,1) < 32
            error('Acycle:Bispectral:TooShort', ...
                'At least 32 finite observations are required.');
        end
        if ~issorted(data(:,1))
            error('Acycle:Bispectral:StrictUnsortedCoordinates', ...
                ['Strict input policy does not sort coordinates. ', ...
                 'Provide coordinates in strictly increasing order.']);
        end
        x = data(:,1);
        y = data(:,2);
        if any(diff(x) == 0)
            error('Acycle:Bispectral:StrictDuplicateCoordinates', ...
                ['Strict input policy does not combine duplicate coordinates. ', ...
                 'Resolve duplicate rows before analysis.']);
        end
        meta.RemovedNonfiniteRows = 0;
        meta.WasSorted = true;
        meta.DuplicateRowsCombined = 0;

    case 'prepare'
        finiteRows = all(isfinite(data),2);
        data = data(finiteRows,:);
        meta.RemovedNonfiniteRows = meta.OriginalCount - size(data,1);
        if size(data,1) < 32
            error('Acycle:Bispectral:TooShort', ...
                'At least 32 finite observations are required.');
        end

        wasSorted = issorted(data(:,1));
        data = sortrows(data,1);
        x = data(:,1);
        y = data(:,2);
        meta.WasSorted = wasSorted;

        [xUnique,~,group] = unique(x,'sorted');
        if numel(xUnique) < numel(x)
            y = accumarray(group,y,[],@mean);
            x = xUnique;
        end
        meta.DuplicateRowsCombined = size(data,1) - numel(x);
        if numel(x) < 32
            error('Acycle:Bispectral:TooShortAfterDuplicates', ...
                'Fewer than 32 distinct coordinates remain after combining duplicates.');
        end

    otherwise
        error('Acycle:Bispectral:InvalidInputPolicy', ...
            'InputPolicy must be prepare or strict.');
end

dx = diff(x);
if any(~isfinite(dx)) || any(dx <= 0)
    error('Acycle:Bispectral:InvalidCoordinates', ...
        'Coordinates must be finite and contain at least 32 distinct values.');
end

originalMedianSpacing = median(dx);
if isempty(options.SampleInterval)
    dt = originalMedianSpacing;
    intervalSource = 'median spacing';
else
    dt = double(options.SampleInterval);
    intervalSource = 'user input';
end
if ~(isscalar(dt) && isfinite(dt) && dt > 0)
    error('Acycle:Bispectral:InvalidSampleInterval', ...
        'SampleInterval must be a positive finite scalar.');
end
coarseningTolerance = max(32*eps(max(1,abs(originalMedianSpacing))), ...
    1e-10*originalMedianSpacing);
if dt > originalMedianSpacing + coarseningTolerance
    error('Acycle:Bispectral:AliasingRisk', ...
        ['SampleInterval is coarser than the original median spacing. Linear, ', ...
         'PCHIP, or MAKIMA interpolation is not an anti-aliasing filter. ', ...
         'Low-pass filter and resample the series before Bispectral Analysis, ', ...
         'then leave SampleInterval at 0 (automatic).']);
end

relativeDeparture = max(abs(dx-dt)) / dt;
gapFactor = max(dx) / dt;
mode = lower(strtrim(char(options.Interpolate)));
if ~any(strcmp(mode,{'auto','always','never'}))
    error('Acycle:Bispectral:InvalidInterpolationMode', ...
        'Interpolate must be auto, always, or never.');
end
strictSpacingTolerance = NaN;
if strcmp(inputPolicy,'strict')
    if ~strcmp(mode,'never')
        error('Acycle:Bispectral:StrictInterpolationDisabled', ...
            ['Strict input policy requires Interpolate=''never'' and never ', ...
             'constructs replacement samples.']);
    end
    strictSpacingTolerance = floatingSpacingTolerance(x,dt);
    maximumSpacingError = max(abs(dx-dt));
    if maximumSpacingError > strictSpacingTolerance
        error('Acycle:Bispectral:StrictUnevenSampling', ...
            ['Strict input policy accepts only floating-point roundoff in ', ...
             'coordinate spacing. Maximum error %.9g exceeds tolerance %.9g.'], ...
            maximumSpacingError,strictSpacingTolerance);
    end
    isIrregular = false;
    doInterpolate = false;
else
    isIrregular = relativeDeparture > options.IrregularTolerance;
    switch mode
        case 'auto'
            doInterpolate = isIrregular;
        case 'always'
            doInterpolate = true;
        case 'never'
            doInterpolate = false;
    end
    if isIrregular && ~doInterpolate
        error('Acycle:Bispectral:UnevenSampling', ...
            ['Bispectral FFT estimators require regular sampling. Select Auto ', ...
             'or Always interpolation, or provide a suitable SampleInterval.']);
    end
end

if doInterpolate
    nIntervals = floor((x(end)-x(1))/dt + 100*eps(max(1,abs(x(end)/dt))));
    if nIntervals + 1 < 32
        error('Acycle:Bispectral:InterpolationTooShort', ...
            'The requested interpolation interval leaves fewer than 32 samples.');
    elseif nIntervals + 1 > 1e7
        error('Acycle:Bispectral:InterpolationTooLarge', ...
            'The requested interpolation grid exceeds 10 million samples.');
    end
    xRegular = x(1) + (0:nIntervals)' .* dt;
    interpolationMethod = lower(strtrim(char(options.InterpolationMethod)));
    validMethods = {'linear','pchip','makima'};
    if ~any(strcmp(interpolationMethod,validMethods))
        error('Acycle:Bispectral:InvalidInterpolationMethod', ...
            'InterpolationMethod must be linear, pchip, or makima.');
    end
    y = interp1(x,y,xRegular,interpolationMethod);
    keep = isfinite(y);
    x = xRegular(keep);
    y = y(keep);
end

if gapFactor > options.GapWarningFactor
    meta.Warnings{end+1} = sprintf( ...
        ['Largest original gap is %.2f sampling intervals; interpolated values ', ...
         'across large gaps should be interpreted cautiously.'],gapFactor);
end

trendMethod = lower(strtrim(char(options.DetrendMethod)));
trend = zeros(size(y));
switch trendMethod
    case 'none'
        % Preserve the supplied level. Segment-mean removal remains separate.
    case 'mean'
        trend(:) = mean(y);
        y = y - trend;
    case 'linear'
        trend = y - detrend(y,'linear');
        y = y - trend;
    case 'polynomial'
        order = options.PolynomialOrder;
        if ~(isscalar(order) && isnumeric(order) && isreal(order) && ...
                isfinite(order) && order == fix(order) && ...
                order >= 1 && order <= 10 && order < numel(y)-1)
            error('Acycle:Bispectral:InvalidPolynomialOrder', ...
                'PolynomialOrder must be an integer from 1 to 10 and below N-1.');
        end
        order = double(order);
        xScaled = (x-mean(x)) ./ std(x,0);
        coefficients = polyfit(xScaled,y,order);
        trend = polyval(coefficients,xScaled);
        y = y - trend;
    otherwise
        error('Acycle:Bispectral:InvalidDetrendMethod', ...
            'DetrendMethod must be none, mean, linear, or polynomial.');
end

scale = 1;
centerAfterDetrend = mean(y);
if options.Standardize
    scale = std(y,0);
    if ~(isfinite(scale) && scale > 10*eps(max(1,max(abs(y)))))
        error('Acycle:Bispectral:ConstantSeries', ...
            'The series is constant, or nearly constant, after detrending.');
    end
    y = (y-centerAfterDetrend) ./ scale;
end

processed = [x(:),y(:)];
meta.FinalCount = size(processed,1);
meta.OriginalStart = data(1,1);
meta.OriginalEnd = data(end,1);
meta.ProcessedStart = processed(1,1);
meta.ProcessedEnd = processed(end,1);
meta.SampleInterval = dt;
meta.SampleIntervalSource = intervalSource;
meta.Nyquist = 1/(2*dt);
meta.OriginalMedianSpacing = originalMedianSpacing;
meta.OriginalMinimumSpacing = min(dx);
meta.OriginalMaximumSpacing = max(dx);
meta.RelativeSpacingDeparture = relativeDeparture;
meta.LargestGapFactor = gapFactor;
meta.WasIrregular = isIrregular;
meta.WasInterpolated = doInterpolate;
meta.StrictSpacingAbsoluteTolerance = strictSpacingTolerance;
meta.InterpolationMethod = char(options.InterpolationMethod);
meta.DetrendMethod = trendMethod;
meta.Trend = trend;
meta.WasStandardized = logical(options.Standardize);
meta.StandardizationCenter = centerAfterDetrend;
meta.StandardizationScale = scale;
end

function tolerance = floatingSpacingTolerance(x,dt)
coordinateScale = max(1,max(abs(x)));
tolerance = max(128*eps(coordinateScale),128*eps(max(1,abs(dt))));
end
