function [result,meta] = acycleFixedCountMovingSummary( ...
    data,statistic,windowPoints)
%ACYCLEFIXEDCOUNTMOVINGSUMMARY Fixed-count row-index moving summary.
%   [RESULT,META] = ACYCLEFIXEDCOUNTMOVINGSUMMARY(DATA,STATISTIC,K)
%   calculates a moving mean or median over contiguous rows of a finite,
%   real N-by-2 series. DATA must be SINGLE or DOUBLE, and DATA(:,1) must
%   already be unique and strictly increasing. The function does not sort,
%   merge, interpolate, or otherwise preprocess rows.
%
%   STATISTIC is 'mean' or 'median'. K is an integer from 1 through N. For
%   an odd K=2H+1, row offsets are -H:H. For an even K=2H, offsets are
%   -(H-1):H, so the window contains one more future/right row than
%   past/left row. Endpoint windows shrink without borrowing rows from the
%   opposite side. Coordinates do not select or weight neighbors: this is
%   a fixed-count sample-index operation, not a coordinate-distance KNN.
%
%   RESULT is a finite DOUBLE N-by-3 matrix with columns coordinate,
%   summary, and contributing-point count. No file I/O, graphics, dialogs,
%   current-directory or path changes, root-state changes, base-workspace
%   assignment, or random-number generation is performed.

narginchk(3,3);

maximumInputRows = 1e6;
if ~(isa(data,'double') || isa(data,'single')) || ~isreal(data) || ...
        ~ismatrix(data) || size(data,2) ~= 2
    error('Acycle:FixedCountMovingSummary:InvalidData', ...
        ['DATA must be a real SINGLE or DOUBLE N-by-2 matrix with ', ...
         'coordinate in column 1 and value in column 2.']);
end

inputRows = size(data,1);
if inputRows < 1
    error('Acycle:FixedCountMovingSummary:TooFewRows', ...
        'DATA must contain at least one row.');
end
if inputRows > maximumInputRows
    error('Acycle:FixedCountMovingSummary:InputRowLimitExceeded', ...
        'DATA exceeds the fixed maximum of %.17g input rows.', ...
        maximumInputRows);
end
if any(~isfinite(data(:)))
    error('Acycle:FixedCountMovingSummary:NonfiniteData', ...
        'Every DATA coordinate and value must be finite.');
end

working = full(double(data));
coordinates = working(:,1);
if any(coordinates(2:end) <= coordinates(1:end-1))
    error( ...
        'Acycle:FixedCountMovingSummary:CoordinatesNotStrictlyIncreasing', ...
        ['DATA(:,1) must already be sorted, contain no duplicates, and ', ...
         'be strictly increasing.']);
end

statistic = normalizeStatistic(statistic);
if ~(isnumeric(windowPoints) && isscalar(windowPoints) && ...
        isreal(windowPoints))
    error('Acycle:FixedCountMovingSummary:InvalidWindowPoints', ...
        'K must be a finite positive integer scalar.');
end
windowPoints = double(windowPoints);
if ~(isfinite(windowPoints) && windowPoints == fix(windowPoints) && ...
        windowPoints >= 1)
    error('Acycle:FixedCountMovingSummary:InvalidWindowPoints', ...
        'K must be a finite positive integer scalar.');
end
if windowPoints > inputRows
    error('Acycle:FixedCountMovingSummary:WindowExceedsInput', ...
        'K must not exceed the number of input rows.');
end

halfWindow = floor(windowPoints/2);
if mod(windowPoints,2) == 1
    backwardPoints = halfWindow;
    forwardPoints = halfWindow;
    alignment = 'current-symmetric';
else
    backwardPoints = max(0,halfWindow-1);
    forwardPoints = halfWindow;
    alignment = 'current-and-next-elements';
end

rowIndex = (1:inputRows)';
leftIndex = max(1,rowIndex-backwardPoints);
rightIndex = min(inputRows,rowIndex+forwardPoints);
contributingPoints = rightIndex-leftIndex+1;
values = working(:,2);
window = [backwardPoints,forwardPoints];
if strcmp(statistic,'mean')
    summary = movmean(values,window,1,'Endpoints','shrink');
else
    summary = movmedian(values,window,1,'Endpoints','shrink');
end

% Current MATLAB releases return finite results for finite moving windows.
% Retain a local scaled fallback so a reduction cannot overflow merely
% because several finite REALMAX-scale values share one window.
invalidSummary = ~isfinite(summary);
if any(invalidSummary)
    invalidRows = find(invalidSummary);
    for invalidIndex = 1:numel(invalidRows)
        outputRow = invalidRows(invalidIndex);
        windowValues = values( ...
            leftIndex(outputRow):rightIndex(outputRow));
        valueScale = max(abs(windowValues));
        if valueScale == 0
            summary(outputRow) = 0;
        else
            scaledValues = windowValues/valueScale;
            if strcmp(statistic,'mean')
                scaledSummary = mean(scaledValues);
            else
                scaledSummary = median(scaledValues);
            end
            scaledSummary = min( ...
                max(scaledValues),max(min(scaledValues),scaledSummary));
            summary(outputRow) = valueScale*scaledSummary;
        end
    end
end

result = [coordinates,summary,contributingPoints];
if ~isequal(size(result),[inputRows,3]) || ~isa(result,'double') || ...
        ~isreal(result) || any(~isfinite(result(:)))
    error('Acycle:FixedCountMovingSummary:InvalidOutput', ...
        ['The fixed-count moving summary must produce one finite real ', ...
         'DOUBLE three-column row for every input row.']);
end

meta = struct( ...
    'version','fixed-count-moving-summary-v1', ...
    'statistic',statistic, ...
    'input_policy','strict-finite-real-two-column-unique-increasing', ...
    'input_rows',inputRows, ...
    'input_columns',2, ...
    'output_rows',inputRows, ...
    'output_columns',3, ...
    'result_columns',{{'coordinate','summary','n'}}, ...
    'window_points',windowPoints, ...
    'backward_points',backwardPoints, ...
    'forward_points',forwardPoints, ...
    'alignment',alignment, ...
    'window_domain','sample_index', ...
    'coordinate_used_for_windows',false, ...
    'nearest_neighbor_search',false, ...
    'weighted',false, ...
    'endpoint_policy','shrink', ...
    'missing_value_policy','reject', ...
    'sorted',false, ...
    'removed_rows',0, ...
    'interpolated',false, ...
    'toolbox_dependency','MATLAB_only', ...
    'maximum_input_rows',maximumInputRows, ...
    'file_io',false, ...
    'graphics',false, ...
    'random_number_generation',false, ...
    'side_effect_policy','none');
end

function statistic = normalizeStatistic(statistic)
if isstring(statistic) && isscalar(statistic)
    statistic = char(statistic);
end
if ~(ischar(statistic) && isrow(statistic) && ~isempty(statistic))
    error('Acycle:FixedCountMovingSummary:InvalidStatistic', ...
        'STATISTIC must be ''mean'' or ''median''.');
end
statistic = lower(strtrim(statistic));
if ~ismember(statistic,{'mean','median'})
    error('Acycle:FixedCountMovingSummary:InvalidStatistic', ...
        'STATISTIC must be ''mean'' or ''median''.');
end
end
