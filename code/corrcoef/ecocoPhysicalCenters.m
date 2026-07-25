function [centers,info] = ecocoPhysicalCenters( ...
        depth,window,stepDepth,centerLimits)
%ECOCOPHYSICALCENTERS Exact physical-depth centers for eCOCO windows.
%
% [CENTERS,INFO] = ECOCOPHYSICALCENTERS(DEPTH,WINDOW,STEPDEPTH,[])
% returns every complete window center from
%
%   min(DEPTH) + WINDOW/2 : STEPDEPTH : max(DEPTH) - WINDOW/2.
%
% The final shorter step is never appended.  Supplying CENTERLIMITS as
% [FIRST LAST] replaces the default complete-window center limits, which
% is useful when an upstream caller has explicitly padded the record.
% CENTERLIMITS identifies the first permitted center and the upper limit;
% centers still follow FIRST + k*STEPDEPTH exactly.

if nargin < 4
    centerLimits = [];
end

validateattributes(depth,{'numeric'}, ...
    {'vector','real','finite','nonempty'},mfilename,'depth',1);
validateattributes(window,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'window',2);
validateattributes(stepDepth,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'stepDepth',3);

depth = double(depth(:));
if numel(depth) < 2
    error('ecocoPhysicalCenters:InsufficientDepths', ...
        'DEPTH must contain at least two finite coordinates.');
end
if any(diff(depth) <= 0)
    error('ecocoPhysicalCenters:NonIncreasingDepth', ...
        'DEPTH must be strictly increasing.');
end

if isempty(centerLimits)
    limits = [depth(1)+window/2,depth(end)-window/2];
    limitsSource = 'complete-data-support';
else
    validateattributes(centerLimits,{'numeric'}, ...
        {'vector','numel',2,'real','finite'},mfilename,'centerLimits',4);
    limits = double(centerLimits(:))';
    limitsSource = 'caller-specified';
end
if limits(2) < limits(1)
    if isempty(centerLimits)
        error('ecocoPhysicalCenters:NoCompleteWindows', ...
            ['The data span (%.12g) is shorter than the requested ', ...
             'physical window (%.12g).'],depth(end)-depth(1),window);
    end
    error('ecocoPhysicalCenters:InvalidCenterLimits', ...
        'CENTERLIMITS(2) must be greater than or equal to CENTERLIMITS(1).');
end

ratio = (limits(2)-limits(1))/stepDepth;
ratioTolerance = 64*eps(max(1,abs(ratio)));
intervalCount = floor(ratio+ratioTolerance);
intervalCount = max(0,intervalCount);
centerCount = intervalCount+1;
maximumCenterCount = 10000;
if ~isfinite(centerCount) || centerCount > maximumCenterCount
    error('ecocoPhysicalCenters:TooManyWindows', ...
        ['The requested physical center grid would contain %.12g windows; ', ...
         'the maximum is %d. Increase STEPDEPTH.'], ...
        centerCount,maximumCenterCount);
end

centers = limits(1)+(0:intervalCount)'*stepDepth;
limitTolerance = 64*eps(max([1,abs(limits),abs(centers(end))]));
if centers(end) > limits(2)+limitTolerance
    centers(end) = [];
end
if isempty(centers)
    error('ecocoPhysicalCenters:NoCenters', ...
        'No physical window centers satisfy the requested limits.');
end

requestedBounds = [centers-window/2,centers+window/2];
if numel(centers) > 1
    actualStep = diff(centers);
    maximumStepError = max(abs(actualStep-stepDepth));
else
    actualStep = zeros(0,1);
    maximumStepError = 0;
end
unusedTail = limits(2)-centers(end);
if abs(unusedTail) <= limitTolerance
    unusedTail = 0;
end

info = struct( ...
    'mode','physical-depth', ...
    'centerLimitsSource',limitsSource, ...
    'centerLimits',limits, ...
    'requestedWindow',double(window), ...
    'requestedStepDepth',double(stepDepth), ...
    'centerCount',numel(centers), ...
    'maximumCenterCount',maximumCenterCount, ...
    'centers',centers, ...
    'requestedBounds',requestedBounds, ...
    'actualStepDepth',actualStep, ...
    'maximumStepError',maximumStepError, ...
    'unusedTailDepth',unusedTail, ...
    'dataDepthRange',depth([1,end])');
end
