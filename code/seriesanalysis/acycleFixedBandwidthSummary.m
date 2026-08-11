function [result,meta] = acycleFixedBandwidthSummary(data,method,options)
%ACYCLEFIXEDBANDWIDTHSUMMARY Summarise fixed-coordinate-width windows.
%   [RESULT,META] = ACYCLEFIXEDBANDWIDTHSUMMARY(DATA,METHOD,OPTIONS)
%   calculates an equal-weight moving mean or median directly on a strict
%   unevenly spaced series. DATA must be a finite, real N-by-2 SINGLE or
%   DOUBLE matrix with at least two rows and unique, strictly increasing
%   coordinates. The function never sorts, merges, interpolates, pads, or
%   otherwise preprocesses DATA.
%
%   METHOD is 'mean' or 'median'. OPTIONS must contain:
%     window_length   fixed full coordinate width, in (0,data span]
%     step            positive center-grid step, no larger than data span
%     endpoint_policy 'complete' or 'partial'
%   METHOD='mean' additionally requires ALPHA in (0,1). ALPHA is rejected
%   for METHOD='median' so an inactive confidence setting cannot be
%   silently accepted.
%
%   COMPLETE windows have centers
%       xmin + window_length/2 + k*step
%   and are emitted only while their full nominal interval lies inside the
%   input coordinate domain. PARTIAL windows have centers
%       xmin + k*step <= xmax.
%   Their nominal interval is clipped by the absence of observations beyond
%   the input domain; no final center is appended when STEP does not land on
%   XMAX. Both policies include observations on both closed window
%   boundaries. Distinct geometric centers remain distinct even when they
%   contain the same observations or have identical statistics.
%
%   MEAN requires at least two observations in every emitted window and
%   returns six DOUBLE columns:
%       window_center, mean, sample_variance, n,
%       variance_ci_lower, variance_ci_upper.
%   SAMPLE_VARIANCE uses N-1. The confidence interval is the conventional
%   two-sided (1-ALPHA) chi-square interval for the variance of independent
%   normal observations. Chi-square quantiles are evaluated as
%   2*GAMMAINCINV(probability,(N-1)/2,'lower'), using base MATLAB only.
%
%   MEDIAN requires at least one observation and returns three DOUBLE
%   columns: window_center, median, n. It does not calculate a variance or
%   confidence interval and does not call a chi-square or gamma quantile.
%   Candidate windows below the method's support threshold are omitted and
%   counted in META. No file I/O, graphics, dialog, path or current-folder
%   change, root-state change, RNG use, or base-workspace assignment occurs.

narginchk(3,3);
limits = resourceLimits();
validateInputData(data,limits);
method = normalizeMethod(method);
options = validateOptions(options,method);

working = full(double(data));
coordinates = working(:,1);
values = working(:,2);
inputRows = size(working,1);
coordinateStart = coordinates(1);
coordinateEnd = coordinates(end);
coordinateSpan = coordinateEnd-coordinateStart;
if ~isfinite(coordinateSpan) || coordinateSpan <= 0
    error('Acycle:FixedBandwidth:UnrepresentableCoordinateSpan', ...
        'The finite input coordinates must have a representable positive span.');
end
shiftedCoordinates = coordinates-coordinateStart;
if any(~isfinite(shiftedCoordinates)) || shiftedCoordinates(1) ~= 0 || ...
        shiftedCoordinates(end) ~= coordinateSpan || ...
        any(diff(shiftedCoordinates) <= 0)
    error('Acycle:FixedBandwidth:UnrepresentableShiftedCoordinates', ...
        ['Subtracting the coordinate origin must preserve a finite, ', ...
         'strictly increasing coordinate grid.']);
end

windowLength = positiveFiniteScalar( ...
    options.window_length,'window_length');
step = positiveFiniteScalar(options.step,'step');
if windowLength > coordinateSpan
    error('Acycle:FixedBandwidth:WindowLongerThanSpan', ...
        'WINDOW_LENGTH %.17g exceeds the coordinate span %.17g.', ...
        windowLength,coordinateSpan);
end
if step > coordinateSpan
    error('Acycle:FixedBandwidth:StepLongerThanSpan', ...
        'STEP %.17g exceeds the coordinate span %.17g.', ...
        step,coordinateSpan);
end
halfWindow = windowLength/2;
if ~isfinite(halfWindow) || halfWindow <= 0
    error('Acycle:FixedBandwidth:UnrepresentableHalfWindow', ...
        'WINDOW_LENGTH/2 must be representable as a positive finite DOUBLE.');
end

[candidateCentersShifted,windowStarts,windowEnds, ...
    candidateIsComplete] = candidateWindows( ...
    coordinateSpan,windowLength,halfWindow,step, ...
    options.endpoint_policy,limits);
candidateCenters = coordinateStart+candidateCentersShifted;
if any(~isfinite(candidateCenters)) || ...
        (numel(candidateCenters) > 1 && ...
         any(diff(candidateCenters) <= 0))
    error('Acycle:FixedBandwidth:UnrepresentableWindowCenters', ...
        ['The requested STEP does not produce finite, distinct window ', ...
         'centers at the precision of the input coordinate origin.']);
end

[leftIndices,rightIndices,pointsPerWindow] = windowMembership( ...
    shiftedCoordinates,windowStarts,windowEnds);
totalWindowMembership = sum(pointsPerWindow);
if ~isfinite(totalWindowMembership) || ...
        totalWindowMembership > limits.maximum_window_membership
    error('Acycle:FixedBandwidth:MembershipLimitExceeded', ...
        ['The request contains %.17g observation-window memberships; ', ...
         'the fixed maximum is %.17g. Increase STEP, reduce ', ...
         'WINDOW_LENGTH, or shorten the input.'], ...
        totalWindowMembership,limits.maximum_window_membership);
end

if strcmp(method,'mean')
    minimumSupport = 2;
else
    minimumSupport = 1;
end
emit = pointsPerWindow >= minimumSupport;
if ~any(emit)
    error('Acycle:FixedBandwidth:NoWindowsWithRequiredSupport', ...
        ['No candidate %s window contains the required minimum of %d ', ...
         'observation(s).'],upper(method),minimumSupport);
end

emittedCandidateIndices = find(emit);
outputRows = numel(emittedCandidateIndices);
outputCenters = candidateCenters(emit);
outputCounts = pointsPerWindow(emit);

if strcmp(method,'mean')
    windowMeans = zeros(outputRows,1);
    sampleVariances = zeros(outputRows,1);
    for outputIndex = 1:outputRows
        candidateIndex = emittedCandidateIndices(outputIndex);
        windowValues = values( ...
            leftIndices(candidateIndex):rightIndices(candidateIndex));
        windowMeans(outputIndex) = mean(windowValues);
        sampleVariances(outputIndex) = var(windowValues,0);
    end

    alpha = options.alpha;
    degreesOfFreedom = outputCounts-1;
    lowerTailProbability = alpha/2;
    upperTailProbability = 1-alpha/2;
    lowerTailQuantile = 2*gammaincinv( ...
        lowerTailProbability*ones(outputRows,1), ...
        degreesOfFreedom/2,'lower');
    upperTailQuantile = 2*gammaincinv( ...
        upperTailProbability*ones(outputRows,1), ...
        degreesOfFreedom/2,'lower');
    if any(~isfinite(lowerTailQuantile)) || ...
            any(~isfinite(upperTailQuantile)) || ...
            any(lowerTailQuantile <= 0) || ...
            any(upperTailQuantile <= lowerTailQuantile)
        error('Acycle:FixedBandwidth:InvalidVarianceQuantile', ...
            ['ALPHA and the emitted window sizes must produce finite, ', ...
             'ordered, positive variance-confidence quantiles.']);
    end
    varianceCiLower = degreesOfFreedom.*sampleVariances./ ...
        upperTailQuantile;
    varianceCiUpper = degreesOfFreedom.*sampleVariances./ ...
        lowerTailQuantile;
    result = [outputCenters,windowMeans,sampleVariances,outputCounts, ...
        varianceCiLower,varianceCiUpper];
    resultColumns = { ...
        'window_center','mean','sample_variance','n', ...
        'variance_ci_lower','variance_ci_upper'};
    confidenceLevel = 1-alpha;
    varianceNormalization = 'sample_n_minus_1';
    varianceCiModel = 'normal_population_chi_square_two_sided';
    varianceCiAssumptions = ...
        'independent_equal_variance_normal_observations';
    varianceQuantileImplementation = ...
        '2*gammaincinv(probability,(n-1)/2,''lower'')';
else
    windowMedians = zeros(outputRows,1);
    for outputIndex = 1:outputRows
        candidateIndex = emittedCandidateIndices(outputIndex);
        windowMedians(outputIndex) = median(values( ...
            leftIndices(candidateIndex):rightIndices(candidateIndex)));
    end
    result = [outputCenters,windowMedians,outputCounts];
    resultColumns = {'window_center','median','n'};
    alpha = [];
    confidenceLevel = [];
    varianceNormalization = 'not_applicable';
    varianceCiModel = 'not_applicable';
    varianceCiAssumptions = 'not_applicable';
    varianceQuantileImplementation = 'not_called';
end

expectedColumns = numel(resultColumns);
if ~isequal(size(result),[outputRows,expectedColumns]) || ...
        ~isreal(result) || any(~isfinite(result(:)))
    error('Acycle:FixedBandwidth:InvalidOutput', ...
        ['The fixed-bandwidth summary must be a finite real matrix with ', ...
         'one row per emitted geometric center. Rescale extreme values ', ...
         'if a mean, variance, or confidence bound overflows.']);
end

candidateCount = numel(candidateCenters);
completeCandidateCount = sum(candidateIsComplete);
partialCandidateCount = candidateCount-completeCandidateCount;
completeOutputCount = sum(candidateIsComplete(emit));
partialOutputCount = outputRows-completeOutputCount;
meta = struct( ...
    'method',method, ...
    'input_policy','strict_finite_real_two_column_unique_increasing', ...
    'input_rows',inputRows, ...
    'input_columns',2, ...
    'coordinate_start',coordinateStart, ...
    'coordinate_end',coordinateEnd, ...
    'coordinate_span',coordinateSpan, ...
    'window_length',windowLength, ...
    'half_window',halfWindow, ...
    'step',step, ...
    'endpoint_policy',options.endpoint_policy, ...
    'window_center_semantics','nominal_geometric_center', ...
    'complete_grid_policy', ...
        'xmin_plus_half_window_plus_k_step_full_nominal_window_in_domain', ...
    'partial_grid_policy', ...
        'xmin_plus_k_step_through_xmax_no_forced_final_center', ...
    'window_membership','closed_left_and_right', ...
    'interpolated',false, ...
    'weighted',false, ...
    'minimum_points_per_window',minimumSupport, ...
    'low_support_policy','omit_and_count', ...
    'candidate_window_count',candidateCount, ...
    'complete_candidate_window_count',completeCandidateCount, ...
    'partial_candidate_window_count',partialCandidateCount, ...
    'output_window_count',outputRows, ...
    'complete_output_window_count',completeOutputCount, ...
    'partial_output_window_count',partialOutputCount, ...
    'skipped_insufficient_support_count',sum(~emit), ...
    'window_membership_count',totalWindowMembership, ...
    'result_columns',{resultColumns}, ...
    'alpha',alpha, ...
    'confidence_level',confidenceLevel, ...
    'variance_normalization',varianceNormalization, ...
    'variance_ci_model',varianceCiModel, ...
    'variance_ci_assumptions',varianceCiAssumptions, ...
    'variance_quantile_implementation', ...
        varianceQuantileImplementation, ...
    'toolbox_dependency','MATLAB_only', ...
    'file_io',false, ...
    'graphics',false, ...
    'maximum_input_rows',limits.maximum_input_rows, ...
    'maximum_candidate_windows',limits.maximum_candidate_windows, ...
    'maximum_window_membership',limits.maximum_window_membership);
end

function limits = resourceLimits()
limits = struct( ...
    'maximum_input_rows',1e6, ...
    'maximum_candidate_windows',1e6, ...
    'maximum_window_membership',1e7);
end

function validateInputData(data,limits)
if ~(isa(data,'double') || isa(data,'single')) || ~isreal(data) || ...
        ~ismatrix(data) || size(data,2) ~= 2
    error('Acycle:FixedBandwidth:InvalidData', ...
        ['DATA must be a real SINGLE or DOUBLE N-by-2 matrix with ', ...
         'coordinate in column 1 and value in column 2.']);
end
inputRows = size(data,1);
if inputRows < 2
    error('Acycle:FixedBandwidth:TooFewRows', ...
        'DATA must contain at least two rows.');
end
if inputRows > limits.maximum_input_rows
    error('Acycle:FixedBandwidth:InputRowLimitExceeded', ...
        'DATA exceeds the fixed maximum of %.17g rows.', ...
        limits.maximum_input_rows);
end
if any(~isfinite(data(:)))
    error('Acycle:FixedBandwidth:NonfiniteData', ...
        'Every DATA coordinate and value must be finite.');
end
coordinates = double(data(:,1));
if any(coordinates(2:end) <= coordinates(1:end-1))
    error('Acycle:FixedBandwidth:CoordinatesNotStrictlyIncreasing', ...
        ['DATA(:,1) must already be sorted, contain no duplicates, and ', ...
         'be strictly increasing.']);
end
end

function method = normalizeMethod(method)
if isstring(method) && isscalar(method)
    method = char(method);
end
if ~(ischar(method) && isrow(method) && ~isempty(method))
    error('Acycle:FixedBandwidth:InvalidMethod', ...
        'METHOD must be ''mean'' or ''median''.');
end
method = lower(strtrim(method));
if ~ismember(method,{'mean','median'})
    error('Acycle:FixedBandwidth:InvalidMethod', ...
        'METHOD must be ''mean'' or ''median''.');
end
end

function options = validateOptions(options,method)
if ~isstruct(options) || ~isscalar(options)
    error('Acycle:FixedBandwidth:InvalidOptions', ...
        'OPTIONS must be one scalar struct.');
end
common = {'window_length','step','endpoint_policy'};
if strcmp(method,'mean')
    allowed = [common,{'alpha'}];
    required = allowed;
else
    allowed = common;
    required = common;
    if isfield(options,'alpha')
        error('Acycle:FixedBandwidth:InactiveAlpha', ...
            'ALPHA is not applicable to METHOD=''median'' and must be omitted.');
    end
end
provided = fieldnames(options);
unknown = setdiff(provided,allowed);
if ~isempty(unknown)
    error('Acycle:FixedBandwidth:UnknownOption', ...
        'Unknown fixed-bandwidth option: %s.',unknown{1});
end
for index = 1:numel(required)
    if ~isfield(options,required{index}) || isempty(options.(required{index}))
        error('Acycle:FixedBandwidth:MissingOption', ...
            'OPTIONS.%s is required for METHOD=''%s''.', ...
            required{index},method);
    end
end
options.endpoint_policy = textChoice( ...
    options.endpoint_policy,{'complete','partial'},'endpoint_policy');
if strcmp(method,'mean')
    options.alpha = openUnitScalar(options.alpha,'alpha');
end
end

function value = positiveFiniteScalar(value,name)
if ~(isnumeric(value) && ~islogical(value) && isreal(value) && ...
        isscalar(value) && isfinite(value) && value > 0)
    error('Acycle:FixedBandwidth:InvalidPositiveScalar', ...
        '%s must be one positive finite real numeric scalar.',upper(name));
end
value = double(value);
end

function value = openUnitScalar(value,name)
if ~((isa(value,'double') || isa(value,'single')) && ...
        isreal(value) && isscalar(value) && isfinite(value) && ...
        value > 0 && value < 1)
    error('Acycle:FixedBandwidth:InvalidOpenUnitScalar', ...
        '%s must be one finite real scalar in (0,1).',upper(name));
end
value = double(value);
end

function value = textChoice(value,choices,name)
if isstring(value) && isscalar(value)
    value = char(value);
end
if ~(ischar(value) && isrow(value) && ~isempty(value))
    error('Acycle:FixedBandwidth:InvalidTextOption', ...
        '%s must be one supported text value.',upper(name));
end
value = lower(strtrim(value));
if ~any(strcmp(value,choices))
    error('Acycle:FixedBandwidth:InvalidTextOption', ...
        '%s must be one of: %s.',upper(name),strjoin(choices,', '));
end
end

function [centers,starts,ends,isComplete] = candidateWindows( ...
        coordinateSpan,windowLength,halfWindow,step,endpointPolicy,limits)
if strcmp(endpointPolicy,'complete')
    gridMaximum = coordinateSpan-windowLength;
else
    gridMaximum = coordinateSpan;
end
ratio = gridMaximum/step;
if ~isfinite(ratio)
    error('Acycle:FixedBandwidth:CandidateWindowLimitExceeded', ...
        'WINDOW_LENGTH and STEP do not define a finite candidate count.');
end
estimatedCount = floor(ratio)+1;
if estimatedCount > limits.maximum_candidate_windows
    error('Acycle:FixedBandwidth:CandidateWindowLimitExceeded', ...
        ['The request would create at least %.17g candidate windows; ', ...
         'the fixed maximum is %.17g. Increase STEP.'], ...
        estimatedCount,limits.maximum_candidate_windows);
end

grid = (0:step:gridMaximum).';
if numel(grid) > limits.maximum_candidate_windows
    error('Acycle:FixedBandwidth:CandidateWindowLimitExceeded', ...
        ['The request creates %d candidate windows; the fixed maximum ', ...
         'is %.17g.'],numel(grid),limits.maximum_candidate_windows);
end
if strcmp(endpointPolicy,'complete')
    starts = grid;
    ends = starts+windowLength;
    centers = starts+halfWindow;
    isComplete = true(size(centers));
else
    centers = grid;
    starts = centers-halfWindow;
    ends = centers+halfWindow;
    isComplete = starts >= 0 & ends <= coordinateSpan;
end
end

function [leftIndices,rightIndices,counts] = windowMembership( ...
        coordinates,windowStarts,windowEnds)
windowCount = numel(windowStarts);
inputRows = numel(coordinates);
leftIndices = zeros(windowCount,1);
rightIndices = zeros(windowCount,1);
counts = zeros(windowCount,1);
left = 1;
right = 0;
for windowIndex = 1:windowCount
    while left <= inputRows && ...
            coordinates(left) < windowStarts(windowIndex)
        left = left+1;
    end
    if right < left-1
        right = left-1;
    end
    while right < inputRows && ...
            coordinates(right+1) <= windowEnds(windowIndex)
        right = right+1;
    end
    leftIndices(windowIndex) = left;
    rightIndices(windowIndex) = right;
    if right >= left
        counts(windowIndex) = right-left+1;
    end
end
end
