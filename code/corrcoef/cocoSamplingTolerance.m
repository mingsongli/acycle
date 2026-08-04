function tolerance = cocoSamplingTolerance(depth,spacing)
%COCOSAMPLINGTOLERANCE Shared near-uniform tolerance for COCO depth grids.
%
% TOLERANCE = COCOSAMPLINGTOLERANCE(DEPTH,SPACING) returns the common
% absolute tolerance used when deciding whether a sorted depth series is
% already uniformly sampled. Coordinate-spacing departures of at most
% 10 parts per million are treated as regular, matching other Acycle
% spectral tools and avoiding interpolation caused only by text precision.

validateattributes(depth,{'numeric'}, ...
    {'vector','real','finite','nonempty'},mfilename,'depth',1);
validateattributes(spacing,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'spacing',2);

% Validate DEPTH for the established public contract even though the
% relative tolerance intentionally does not grow with coordinate offset.
tolerance = 1e-5*abs(double(spacing));
end
