function [values,info] = ecocoPhysicalWindowValues( ...
        data,window,centers,nominalDt,varargin)
%ECOCOPHYSICALWINDOWVALUES Sample exact physical-depth eCOCO windows.
%
% [VALUES,INFO] = ECOCOPHYSICALWINDOWVALUES(DATA,WINDOW,CENTERS,NOMINALDT)
% selects the observations physically contained in every requested
% [CENTER-WINDOW/2, CENTER+WINDOW/2] support.  Each local subset is then
% independently mapped to one common, odd-length analysis grid.  No
% observation outside that physical window is used for interpolation or
% extrapolation.
%
% The common grid contains
%
%   2*round(WINDOW/(2*NOMINALDT)) + 1
%
% points and spans exactly WINDOW, so its actual sampling interval is
% WINDOW/(N-1). VALUES is N-by-numel(CENTERS), with one window per column.
%
% Name-value option:
%   MinimumSourcePoints  minimum local observations required (default 2)

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'MinimumSourcePoints',2,@(x) isnumeric(x) && ...
    isscalar(x) && isreal(x) && isfinite(x) && x >= 2 && x == fix(x));
parse(parser,varargin{:});
minimumSourcePoints = double(parser.Results.MinimumSourcePoints);

validateattributes(data,{'numeric'}, ...
    {'2d','real','nonempty'},mfilename,'data',1);
if size(data,2) < 2
    error('ecocoPhysicalWindowValues:InsufficientColumns', ...
        'DATA must contain at least two columns (depth and value).');
end
validateattributes(window,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'window',2);
validateattributes(centers,{'numeric'}, ...
    {'vector','real','finite','nonempty'},mfilename,'centers',3);
validateattributes(nominalDt,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'nominalDt',4);

data = double(data(:,1:2));
if any(~isfinite(data),'all')
    error('ecocoPhysicalWindowValues:NonfiniteData', ...
        'The first two DATA columns must contain only finite values.');
end
depth = data(:,1);
proxy = data(:,2);
if numel(depth) < minimumSourcePoints
    error('ecocoPhysicalWindowValues:InsufficientData', ...
        'DATA must contain at least %d rows.',minimumSourcePoints);
end
if any(diff(depth) <= 0)
    error('ecocoPhysicalWindowValues:NonIncreasingDepth', ...
        'DATA depth coordinates must be strictly increasing.');
end

centers = double(centers(:));
if numel(centers) > 10000
    error('ecocoPhysicalWindowValues:TooManyWindows', ...
        'At most 10000 physical windows may be sampled in one call.');
end
if any(diff(centers) <= 0)
    error('ecocoPhysicalWindowValues:NonIncreasingCenters', ...
        'CENTERS must be strictly increasing.');
end

halfIntervalCount = round(window/(2*nominalDt));
if halfIntervalCount < 1
    error('ecocoPhysicalWindowValues:WindowTooShort', ...
        ['WINDOW is too short relative to NOMINALDT to construct the ', ...
         'required odd analysis grid.']);
end
intervalCount = 2*halfIntervalCount;
windowPointCount = intervalCount+1;
analysisDt = window/intervalCount;
relativeDepth = (-halfIntervalCount:halfIntervalCount)'*analysisDt;
relativeDepth(1) = -window/2;
relativeDepth(halfIntervalCount+1) = 0;
relativeDepth(end) = window/2;

nWindows = numel(centers);
requestedBounds = [centers-window/2,centers+window/2];
values = nan(windowPointCount,nWindows);
sourceStartIndex = nan(nWindows,1);
sourceEndIndex = nan(nWindows,1);
sourcePointCount = zeros(nWindows,1);
observedCenter = nan(nWindows,1);
observedSpan = nan(nWindows,1);
coverageFraction = nan(nWindows,1);
fastPathUsed = false(nWindows,1);
extrapolationApplied = false(nWindows,1);

for windowIndex = 1:nWindows
    lower = requestedBounds(windowIndex,1);
    upper = requestedBounds(windowIndex,2);
    supportTolerance = coordinateTolerance(depth,lower,upper,window);
    if lower < depth(1)-supportTolerance || ...
            upper > depth(end)+supportTolerance
        error('ecocoPhysicalWindowValues:InsufficientDataSupport', ...
            ['Physical window %d of %d requests bounds %.12g to %.12g, ', ...
             'but DATA only supports %.12g to %.12g. Supply edge padding ', ...
             'that reaches at least one exact half-window beyond the ', ...
             'requested output-center limits.'],windowIndex,nWindows, ...
            lower,upper,depth(1),depth(end));
    end
    firstIndex = lowerBound(depth,lower-supportTolerance);
    lastIndex = upperBound(depth,upper+supportTolerance);
    count = max(0,lastIndex-firstIndex+1);
    sourcePointCount(windowIndex) = count;
    if count < minimumSourcePoints
        error('ecocoPhysicalWindowValues:InsufficientWindowData', ...
            ['Physical window %d of %d (center %.12g, bounds %.12g to ', ...
             '%.12g) contains %d source observations; at least %d are ', ...
             'required.'],windowIndex,nWindows,centers(windowIndex), ...
            lower,upper,count,minimumSourcePoints);
    end

    sourceStartIndex(windowIndex) = firstIndex;
    sourceEndIndex(windowIndex) = lastIndex;
    localDepth = depth(firstIndex:lastIndex);
    localProxy = proxy(firstIndex:lastIndex);
    observedCenter(windowIndex) = 0.5*(localDepth(1)+localDepth(end));
    observedSpan(windowIndex) = localDepth(end)-localDepth(1);
    coverageFraction(windowIndex) = min(1,max(0, ...
        observedSpan(windowIndex)/window));

    queryDepth = centers(windowIndex)+relativeDepth;
    queryDepth(1) = lower;
    queryDepth(halfIntervalCount+1) = centers(windowIndex);
    queryDepth(end) = upper;
    [isAligned,alignedIndex] = alignedSourceIndex( ...
        localDepth,queryDepth,supportTolerance);
    if isAligned
        values(:,windowIndex) = localProxy(alignedIndex);
        fastPathUsed(windowIndex) = true;
    else
        values(:,windowIndex) = interp1( ...
            localDepth,localProxy,queryDepth,'linear','extrap');
    end
    extrapolationApplied(windowIndex) = ...
        queryDepth(1) < localDepth(1)-supportTolerance || ...
        queryDepth(end) > localDepth(end)+supportTolerance;
end

if any(~isfinite(values),'all')
    error('ecocoPhysicalWindowValues:NonfiniteOutput', ...
        'Physical-window interpolation produced nonfinite output values.');
end

info = struct( ...
    'mode','physical-depth-local-interpolation', ...
    'centers',centers, ...
    'requestedWindow',double(window), ...
    'requestedBounds',requestedBounds, ...
    'sourceStartIndex',sourceStartIndex, ...
    'sourceEndIndex',sourceEndIndex, ...
    'sourcePointCount',sourcePointCount, ...
    'observedCenter',observedCenter, ...
    'observedSpan',observedSpan, ...
    'coverageFraction',coverageFraction, ...
    'minimumSourcePoints',minimumSourcePoints, ...
    'windowPointCount',windowPointCount, ...
    'nominalSamplingInterval',double(nominalDt), ...
    'analysisSamplingInterval',analysisDt, ...
    'relativeDepthGrid',relativeDepth, ...
    'actualSpan',relativeDepth(end)-relativeDepth(1), ...
    'fastPathUsed',fastPathUsed, ...
    'extrapolationApplied',extrapolationApplied);
end

function tolerance = coordinateTolerance(depth,lower,upper,window)
scale = max([1,abs(depth(1)),abs(depth(end)),abs(lower),abs(upper), ...
    abs(window)]);
tolerance = 64*eps(scale)*max(1,numel(depth));
end

function index = lowerBound(vector,target)
left = 1;
right = numel(vector)+1;
while left < right
    middle = floor((left+right)/2);
    if middle <= numel(vector) && vector(middle) < target
        left = middle+1;
    else
        right = middle;
    end
end
index = left;
end

function index = upperBound(vector,target)
left = 0;
right = numel(vector);
while left < right
    middle = ceil((left+right)/2);
    if vector(middle) <= target
        left = middle;
    else
        right = middle-1;
    end
end
index = left;
end

function [tf,index] = alignedSourceIndex(sourceDepth,queryDepth,tolerance)
index = zeros(numel(queryDepth),1);
sourceIndex = 1;
for queryIndex = 1:numel(queryDepth)
    lower = queryDepth(queryIndex)-tolerance;
    while sourceIndex <= numel(sourceDepth) && ...
            sourceDepth(sourceIndex) < lower
        sourceIndex = sourceIndex+1;
    end
    if sourceIndex > numel(sourceDepth) || ...
            abs(sourceDepth(sourceIndex)-queryDepth(queryIndex)) > tolerance
        tf = false;
        index = zeros(0,1);
        return
    end
    index(queryIndex) = sourceIndex;
    sourceIndex = sourceIndex+1;
end
tf = true;
end
