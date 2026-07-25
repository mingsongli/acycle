function [data,info,clean] = cocoPrepareRegularData(rawData,label,varargin)
%COCOPREPAREREGULARDATA Shared full-record COCO/eCOCO preprocessing.
%
% [DATA,INFO,CLEAN] = COCOPREPAREREGULARDATA(RAWDATA,LABEL) keeps the first
% two columns, removes nonfinite rows, sorts by depth, averages values at
% duplicate depths, and conditionally linearly interpolates at the median
% positive depth interval. CLEAN is the sorted, de-duplicated observation
% series before interpolation; DATA is the uniform analysis series.
%
% This helper is for full-record COCO/eCOCO inputs. Held-out cvCOCO methods
% deliberately split CLEAN observations before regularizing each fold and
% must not call this helper on the complete record.
%
% Name-value options:
%   MaximumPoints  maximum output grid size (default 1,000,000)
%   MinimumPoints  minimum finite unique input/output size (default 4)
%   Verbose        print preprocessing diagnostics (default true)

if nargin < 2 || strlength(string(label)) == 0
    label = 'COCO/eCOCO input';
end

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'MaximumPoints',1e6,@(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x >= 4 && x == fix(x));
addParameter(parser,'MinimumPoints',4,@(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x >= 2 && x == fix(x));
addParameter(parser,'Verbose',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(double(x) == [0 1]));
parse(parser,varargin{:});
maximumPoints = double(parser.Results.MaximumPoints);
minimumPoints = double(parser.Results.MinimumPoints);
verbose = logical(parser.Results.Verbose);

validateattributes(rawData,{'numeric'}, ...
    {'2d','real','nonempty'},mfilename,'rawData',1);
if size(rawData,2) < 2
    error('cocoPrepareRegularData:InsufficientColumns', ...
        'RAWDATA must contain at least two numeric columns (depth and value).');
end

originalRows = size(rawData,1);
raw = rawData(:,1:2);
finiteMask = all(isfinite(raw),2);
raw = raw(finiteMask,:);
if size(raw,1) < minimumPoints
    error('cocoPrepareRegularData:InsufficientFiniteData', ...
        'At least %d finite depth/value observations are required.',minimumPoints);
end

raw = sortrows(raw,1);
[uniqueDepth,~,duplicateGroup] = unique(raw(:,1),'sorted');
uniqueValue = accumarray(duplicateGroup,raw(:,2),[],@mean);
clean = [uniqueDepth,uniqueValue];
if size(clean,1) < minimumPoints
    error('cocoPrepareRegularData:InsufficientUniqueDepths', ...
        'At least %d unique depths are required after de-duplication.', ...
        minimumPoints);
end

observedSpacing = diff(clean(:,1));
if any(~isfinite(observedSpacing)) || any(observedSpacing <= 0)
    error('cocoPrepareRegularData:InvalidDepthSpacing', ...
        'A finite, strictly increasing depth coordinate is required.');
end
medianSpacing = median(observedSpacing);
if ~isfinite(medianSpacing) || medianSpacing <= 0
    error('cocoPrepareRegularData:InvalidMedianSpacing', ...
        'The median positive depth spacing must be finite and positive.');
end
tolerance = cocoSamplingTolerance(clean(:,1),medianSpacing);
maximumDeviation = max(abs(observedSpacing-medianSpacing));
interpolationApplied = maximumDeviation > tolerance;

if interpolationApplied
    exactIntervalCount = (clean(end,1)-clean(1,1))/medianSpacing;
    roundedIntervalCount = round(exactIntervalCount);
    countTolerance = 1e-10*max(1,abs(exactIntervalCount));
    if abs(exactIntervalCount-roundedIntervalCount) <= countTolerance
        intervalCount = roundedIntervalCount;
    else
        intervalCount = floor(exactIntervalCount);
    end
    outputPointCount = intervalCount+1;
    if ~isfinite(outputPointCount) || outputPointCount < minimumPoints || ...
            outputPointCount > maximumPoints
        error('cocoPrepareRegularData:InterpolationGridTooLarge', ...
            ['Median-spacing interpolation would create approximately ', ...
             '%.6g points (allowed range %d to %.6g).'], ...
            outputPointCount,minimumPoints,maximumPoints);
    end
    grid = clean(1,1)+(0:intervalCount)'*medianSpacing;
    endpointTolerance = 16*eps(max(1,max(abs(clean([1,end],1))))) * ...
        max(1,numel(grid));
    if abs(grid(end)-clean(end,1)) <= endpointTolerance
        grid(end) = clean(end,1);
    end
    values = interp1(clean(:,1),clean(:,2),grid,'linear');
    valid = isfinite(grid) & isfinite(values);
    data = [grid(valid),values(valid)];
else
    data = clean;
end

if size(data,1) < minimumPoints
    error('cocoPrepareRegularData:InsufficientOutputData', ...
        'Fewer than %d finite observations remain after preprocessing.', ...
        minimumPoints);
end
outputSpacing = median(diff(data(:,1)));
outputTolerance = cocoSamplingTolerance(data(:,1),outputSpacing);
if any(abs(diff(data(:,1))-outputSpacing) > outputTolerance)
    error('cocoPrepareRegularData:InternalUnevenOutput', ...
        'The median-spacing output grid is not uniformly sampled.');
end

info = struct( ...
    'label',char(string(label)), ...
    'method','finite rows; sort; mean duplicate values; conditional linear interpolation', ...
    'originalRowCount',originalRows, ...
    'finiteRowCount',size(raw,1), ...
    'nonfiniteRowsRemoved',originalRows-size(raw,1), ...
    'uniqueDepthCount',size(clean,1), ...
    'duplicateRowsCollapsed',size(raw,1)-size(clean,1), ...
    'interpolationApplied',interpolationApplied, ...
    'interpolationMethod','linear', ...
    'originalDepthRange',clean([1,end],1)', ...
    'outputDepthRange',data([1,end],1)', ...
    'spacingMinimum',min(observedSpacing), ...
    'spacingMedian',medianSpacing, ...
    'spacingMaximum',max(observedSpacing), ...
    'outputSpacing',outputSpacing, ...
    'maximumSpacingDeviation',maximumDeviation, ...
    'uniformityTolerance',tolerance, ...
    'maximumGapToMedianRatio',max(observedSpacing)/medianSpacing, ...
    'outputPointCount',size(data,1), ...
    'maximumOutputPointCount',maximumPoints, ...
    'inputAssumption', ...
        'proxy values were scientifically detrended before COCO/eCOCO');

if verbose && (info.nonfiniteRowsRemoved > 0 || ...
        info.duplicateRowsCollapsed > 0 || info.interpolationApplied)
    fprintf('\n>> Full-record COCO/eCOCO preprocessing (%s):\n',info.label);
    fprintf('   Input / finite / unique rows : %d / %d / %d\n', ...
        info.originalRowCount,info.finiteRowCount,info.uniqueDepthCount);
    fprintf('   Nonfinite rows removed       : %d\n',info.nonfiniteRowsRemoved);
    fprintf('   Duplicate rows collapsed     : %d\n',info.duplicateRowsCollapsed);
    fprintf('   Original depth range         : %.12g to %.12g m\n', ...
        info.originalDepthRange);
    fprintf('   Spacing (min/median/max)     : %.12g / %.12g / %.12g m\n', ...
        info.spacingMinimum,info.spacingMedian,info.spacingMaximum);
    fprintf('   Uniformity tolerance         : %.12g m\n',info.uniformityTolerance);
    fprintf('   Maximum spacing deviation    : %.12g m\n', ...
        info.maximumSpacingDeviation);
    fprintf('   Largest gap / median spacing : %.12g\n', ...
        info.maximumGapToMedianRatio);
    if info.maximumGapToMedianRatio > 10
        fprintf(['   WARNING: linear interpolation bridges a gap larger than ', ...
            '10 median intervals; the AR(1) null conditions on the ', ...
            'regularized grid and does not model missingness.\n']);
    end
    fprintf('   Interpolation applied        : %s\n',yesNo(interpolationApplied));
    fprintf('   Interpolation interval       : %.12g m\n',info.outputSpacing);
    fprintf('   Analysis point count         : %d\n',info.outputPointCount);
    fprintf('   Analysis depth range         : %.12g to %.12g m\n\n', ...
        info.outputDepthRange);
end
end

function answer = yesNo(value)
if value
    answer = 'yes';
else
    answer = 'no';
end
end
