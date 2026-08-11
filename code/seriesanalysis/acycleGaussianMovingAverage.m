function [result,meta] = acycleGaussianMovingAverage(data,windowPoints)
%ACYCLEGAUSSIANMOVINGAVERAGE Gaussian-weighted sample-index smoothing.
%   [RESULT,META] = ACYCLEGAUSSIANMOVINGAVERAGE(DATA,WINDOWPOINTS) smooths
%   the value column of a finite, real N-by-2 series. DATA(:,1) must already
%   be unique and strictly increasing; the function does not sort, remove,
%   merge, interpolate, or otherwise preprocess rows. WINDOWPOINTS must be
%   an integer from 1 through N.
%
%   The Gaussian standard deviation is WINDOWPOINTS/5 sample-index units.
%   For an odd window 2H+1, offsets are -H:H. For an even window 2H, offsets
%   are -H:(H-1), matching the current-and-previous alignment of MATLAB's
%   documented scalar moving-window convention. Endpoints use only the
%   available in-domain samples and renormalize their remaining positive
%   weights. Coordinates never enter the weight calculation.
%
%   RESULT is a finite DOUBLE N-by-3 matrix with columns coordinate,
%   gaussian_mean, and contributing_point_count. No file I/O, graphics,
%   dialogs, current-directory changes, path changes, root-state changes,
%   base-workspace assignment, or random-number generation is performed.

narginchk(2,2);

maximumInputRows = 1e6;
if ~(isa(data,'double') || isa(data,'single')) || ~isreal(data) || ...
        ~ismatrix(data) || size(data,2) ~= 2
    error('Acycle:GaussianMovingAverage:InvalidData', ...
        ['DATA must be a real SINGLE or DOUBLE N-by-2 matrix with ', ...
         'coordinate in column 1 and value in column 2.']);
end

inputRows = size(data,1);
if inputRows < 1
    error('Acycle:GaussianMovingAverage:TooFewRows', ...
        'DATA must contain at least one row.');
end
if inputRows > maximumInputRows
    error('Acycle:GaussianMovingAverage:InputRowLimitExceeded', ...
        'DATA exceeds the fixed maximum of %.17g input rows.', ...
        maximumInputRows);
end
if any(~isfinite(data(:)))
    error('Acycle:GaussianMovingAverage:NonfiniteData', ...
        'Every DATA coordinate and value must be finite.');
end

working = full(double(data));
coordinates = working(:,1);
if any(coordinates(2:end) <= coordinates(1:end-1))
    error('Acycle:GaussianMovingAverage:CoordinatesNotStrictlyIncreasing', ...
        ['DATA(:,1) must already be sorted, contain no duplicates, and ', ...
         'be strictly increasing.']);
end

if ~(isnumeric(windowPoints) && isscalar(windowPoints) && ...
        isreal(windowPoints) && isfinite(windowPoints) && ...
        windowPoints == fix(windowPoints) && windowPoints >= 1)
    error('Acycle:GaussianMovingAverage:InvalidWindowPoints', ...
        'WINDOWPOINTS must be a finite positive integer scalar.');
end
windowPoints = double(windowPoints);
if windowPoints > inputRows
    error('Acycle:GaussianMovingAverage:WindowExceedsInput', ...
        'WINDOWPOINTS must not exceed the number of input rows.');
end

halfWindow = floor(windowPoints/2);
if mod(windowPoints,2) == 1
    backwardPoints = halfWindow;
    forwardPoints = halfWindow;
    alignment = 'current-symmetric';
else
    backwardPoints = halfWindow;
    forwardPoints = halfWindow-1;
    alignment = 'current-and-previous-elements';
end

sigmaPoints = windowPoints/5;
kernelIndex = (1:windowPoints)';
kernelCenter = ceil(windowPoints/2);
kernel = exp(-((kernelIndex-kernelCenter).^2)/(2*sigmaPoints^2));
kernelSum = sum(kernel);
if ~(isfinite(kernelSum) && kernelSum > 0) || ...
        any(~isfinite(kernel)) || any(kernel <= 0)
    error('Acycle:GaussianMovingAverage:InvalidKernel', ...
        'The fixed Gaussian kernel could not be represented safely.');
end
kernel = kernel/kernelSum;

values = working(:,2);
valueScale = max(abs(values));
if valueScale == 0
    scaledValues = values;
else
    scaledValues = values/valueScale;
end

% Copy the documented scalar-window alignment explicitly. CONV uses the
% opposite central sample for even kernels, so reversing both operands and
% the result restores the current-and-previous convention.
available = ones(inputRows,1);
if mod(windowPoints,2) == 0
    numerator = flipud(conv( ...
        flipud(scaledValues),flipud(kernel),'same'));
    denominator = flipud(conv( ...
        flipud(available),flipud(kernel),'same'));
else
    numerator = conv(scaledValues,kernel,'same');
    denominator = conv(available,kernel,'same');
end
if any(~isfinite(numerator)) || any(~isfinite(denominator)) || ...
        any(denominator <= 0)
    error('Acycle:GaussianMovingAverage:InvalidConvolution', ...
        'Gaussian convolution produced an invalid intermediate result.');
end

scaledSmoothed = numerator./denominator;
% Positive normalized weights define a convex combination. Clamp only
% roundoff outside the global input hull before restoring a potentially
% REALMAX-scale finite signal.
scaledMinimum = min(scaledValues);
scaledMaximum = max(scaledValues);
scaledSmoothed = min( ...
    scaledMaximum,max(scaledMinimum,scaledSmoothed));
smoothed = valueScale*scaledSmoothed;

rowIndex = (1:inputRows)';
leftIndex = max(1,rowIndex-backwardPoints);
rightIndex = min(inputRows,rowIndex+forwardPoints);
contributingPoints = rightIndex-leftIndex+1;

result = [coordinates,smoothed,contributingPoints];
if ~isequal(size(result),[inputRows,3]) || ~isreal(result) || ...
        any(~isfinite(result(:)))
    error('Acycle:GaussianMovingAverage:InvalidOutput', ...
        ['Gaussian smoothing must produce one finite real three-column ', ...
         'result row for every input row.']);
end

meta = struct( ...
    'version','gaussian-moving-average-v1', ...
    'implementation','explicit-sample-index-gaussian', ...
    'input_policy','strict-finite-real-two-column-unique-increasing', ...
    'input_rows',inputRows, ...
    'input_columns',2, ...
    'output_rows',inputRows, ...
    'output_columns',3, ...
    'result_columns',{{ ...
        'coordinate','gaussian_mean','contributing_point_count'}}, ...
    'window_points',windowPoints, ...
    'sigma_points',sigmaPoints, ...
    'backward_points',backwardPoints, ...
    'forward_points',forwardPoints, ...
    'alignment',alignment, ...
    'weight_domain','sample_index', ...
    'coordinate_used_for_weights',false, ...
    'kernel','exp(-offset^2/(2*(window_points/5)^2))', ...
    'endpoint_policy','shrink-and-renormalize', ...
    'missing_value_policy','reject', ...
    'sorted',false, ...
    'removed_rows',0, ...
    'interpolated',false, ...
    'maximum_input_rows',maximumInputRows, ...
    'file_io',false, ...
    'graphics',false, ...
    'random_number_generation',false, ...
    'side_effect_policy','none');
end
