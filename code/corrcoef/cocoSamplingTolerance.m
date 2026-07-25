function tolerance = cocoSamplingTolerance(depth,spacing)
%COCOSAMPLINGTOLERANCE Shared roundoff tolerance for COCO depth grids.
%
% TOLERANCE = COCOSAMPLINGTOLERANCE(DEPTH,SPACING) returns the common
% absolute tolerance used when deciding whether a sorted depth series is
% already uniformly sampled.  The relative term is intentionally small
% enough to absorb decimal-coordinate roundoff without treating meaningful
% sampling jitter as an exact regular grid.

validateattributes(depth,{'numeric'}, ...
    {'vector','real','finite','nonempty'},mfilename,'depth',1);
validateattributes(spacing,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'spacing',2);

depthScale = max(1,max(abs(depth(:))));
spacingScale = max(1,abs(spacing));
tolerance = max(64*eps(depthScale),1e-8*spacingScale);
end
