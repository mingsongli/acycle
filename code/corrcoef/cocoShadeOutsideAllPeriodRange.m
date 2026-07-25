function patches = cocoShadeOutsideAllPeriodRange(ax,rateGrid,validRange)
%COCOSHADEOUTSIDEALLPERIODRANGE Shade rates outside the all-period range.
%
% The patches intentionally have no label and are hidden from legends.
% Plot callers are responsible for setting the final x/y limits before
% calling this function and for drawing data curves after the patches.

if nargin < 3
    error('cocoShadeOutsideAllPeriodRange:TooFewInputs', ...
        'AX, RATEGRID, and VALIDRANGE are required.');
end
if ~isscalar(ax) || ~isgraphics(ax,'axes')
    error('cocoShadeOutsideAllPeriodRange:InvalidAxes', ...
        'AX must be a scalar Cartesian axes handle.');
end
validateattributes(rateGrid,{'numeric'}, ...
    {'vector','real','finite','nonempty'},mfilename,'rateGrid',2);
validateattributes(validRange,{'numeric'}, ...
    {'vector','numel',2,'real','finite'},mfilename,'validRange',3);

rateGrid = rateGrid(:);
xLimits = xlim(ax);
if ~all(isfinite(xLimits)) || diff(xLimits) <= 0
    if isscalar(rateGrid)
        xLimits = rateGrid(1)+[-0.5 0.5];
    else
        xLimits = [min(rateGrid),max(rateGrid)];
    end
end
yLimits = ylim(ax);
lower = validRange(1);
upper = validRange(2);

regions = zeros(0,2);
if lower >= upper
    regions = xLimits;
else
    if lower > xLimits(1)
        regions(end+1,:) = [xLimits(1),min(lower,xLimits(2))];
    end
    if upper < xLimits(2)
        regions(end+1,:) = [max(upper,xLimits(1)),xLimits(2)];
    end
end

patches = gobjects(0,1);
for regionIndex = 1:size(regions,1)
    region = regions(regionIndex,:);
    if region(2) <= region(1)
        continue
    end
    patches(end+1,1) = patch(ax,region([1 2 2 1]), ...
        yLimits([1 1 2 2]),[0.88 0.88 0.88], ...
        'EdgeColor','none','FaceAlpha',0.55, ...
        'HandleVisibility','off', ...
        'Tag','COCO-unreliable-rate-shading'); %#ok<AGROW>
end
end
