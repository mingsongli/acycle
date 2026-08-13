function plan = dynotPercentilePlan(selection)
%DYNOTPERCENTILEPLAN Build a symmetric DYNOT percentile layout.
%   PLAN = DYNOTPERCENTILEPLAN(SELECTION) accepts the six Plot-panel
%   selections [median, 50%, 68%, 80%, 90%, 95%]. The selected confidence
%   intervals contribute their historical endpoint pairs. The 50th
%   percentile is always included as the structural center: DYNOT plots and
%   exports a median curve even when the Median checkbox is cleared because
%   every confidence envelope and the legacy median output depend on it.

if ~(isnumeric(selection) || islogical(selection)) || ...
        ~isreal(selection) || numel(selection) ~= 6 || ...
        any(~isfinite(double(selection(:)))) || ...
        any(~ismember(double(selection(:)),[0 1]))
    error('Acycle:DYNOT:InvalidPercentileSelection', ...
        'SELECTION must contain six logical or binary values.');
end

selection = logical(selection(:).');
confidenceEndpoints = { ...
    [25 75], ...
    [15.865 84.135], ...
    [10 90], ...
    [5 95], ...
    [2.5 97.5]};

percentiles = 50;
for intervalIndex = 1:numel(confidenceEndpoints)
    if selection(intervalIndex+1)
        percentiles = [percentiles, ...
            confidenceEndpoints{intervalIndex}]; %#ok<AGROW>
    end
end
percentiles = sort(percentiles);

plan = struct();
plan.percentiles = percentiles;
plan.intervalCount = nnz(selection(2:end));
plan.medianIndex = find(percentiles == 50,1);
end
