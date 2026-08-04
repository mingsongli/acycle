function [isUneven,info] = acycleSamplingIsUneven(coordinate,relativeTolerance)
%ACYCLESAMPLINGISUNEVEN Classify a coordinate grid by relative spacing.
%   ISUNEVEN = ACYCLESAMPLINGISUNEVEN(COORDINATE) treats maximum spacing
%   departures of at most 10 parts per million from the median spacing as
%   regular. This accommodates text-serialization jitter without changing
%   or interpolating the coordinate vector.
%
%   [ISUNEVEN,INFO] also returns the measured spacing and tolerance. A
%   nonfinite or non-increasing coordinate vector is classified as uneven.

if nargin < 2 || isempty(relativeTolerance)
    relativeTolerance = 1e-5;
end

if ~(isnumeric(coordinate) && isreal(coordinate) && isvector(coordinate))
    error('Acycle:Sampling:InvalidCoordinate', ...
        'Coordinate must be a real numeric vector.');
end
if ~(isnumeric(relativeTolerance) && isreal(relativeTolerance) && ...
        isscalar(relativeTolerance) && isfinite(relativeTolerance) && ...
        relativeTolerance >= 0)
    error('Acycle:Sampling:InvalidRelativeTolerance', ...
        'Relative tolerance must be a finite nonnegative scalar.');
end

coordinate = double(coordinate(:));
relativeTolerance = double(relativeTolerance);
info = struct( ...
    'MedianSpacing',NaN, ...
    'MaximumSpacingError',NaN, ...
    'RelativeSpacingError',NaN, ...
    'RelativeTolerance',relativeTolerance, ...
    'AbsoluteTolerance',NaN, ...
    'RoundoffTolerance',NaN);

if any(~isfinite(coordinate))
    isUneven = true;
    return
end
if numel(coordinate) < 2
    isUneven = false;
    return
end

spacing = diff(coordinate);
if any(~isfinite(spacing)) || any(spacing <= 0)
    isUneven = true;
    return
end

medianSpacing = median(spacing);
maximumSpacingError = max(abs(spacing-medianSpacing));
relativeSpacingError = maximumSpacingError/medianSpacing;

info.MedianSpacing = medianSpacing;
info.MaximumSpacingError = maximumSpacingError;
info.RelativeSpacingError = relativeSpacingError;
info.AbsoluteTolerance = relativeTolerance*medianSpacing;
info.RoundoffTolerance = 8*eps(abs(medianSpacing));
isUneven = relativeSpacingError > relativeTolerance;
end
