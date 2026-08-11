function [t,meantd,vartd,np,CI_lower,CI_upper,mediantd] = ...
        movmeanfbw(data,window,step,halfwindow,alpha,plotn)
%MOVMEANFBW Compatibility wrapper for fixed-bandwidth mean statistics.
%   [T,MEAN_TD,VAR_TD,NP,CI_LOWER,CI_UPPER,MEDIAN_TD] =
%   MOVMEANFBW(DATA,WINDOW,STEP,HALFWINDOW,ALPHA,PLOTN) preserves the
%   historical Acycle calling signature while delegating all window
%   construction and statistics to ACYCLEFIXEDBANDWIDTHSUMMARY.
%
%   DATA is sorted by coordinate for GUI compatibility, then must satisfy
%   the shared core's strict finite, unique N-by-2 contract. HALFWINDOW=0
%   selects complete windows; HALFWINDOW=1 selects partial endpoint windows.
%   T now contains each nominal window's geometric center. Distinct windows
%   are never merged merely because they contain the same observations.
%   Mean rows require at least two observations, so every returned sample
%   variance and variance confidence interval is finite and defined.
%
%   The seventh output is calculated through the same shared core's MEDIAN
%   path and aligned to the emitted mean centers. PLOTN=1 retains the legacy
%   optional diagnostic figure. The shared core itself never plots.
%
%   Original Acycle implementation by Mingsong Li (Peking University),
%   Oct. 13, 2023.

narginchk(1,6);
if ~(isa(data,'double') || isa(data,'single')) || ~isreal(data) || ...
        ~ismatrix(data) || size(data,2) ~= 2 || size(data,1) < 2
    error('Acycle:FixedBandwidth:InvalidData', ...
        'DATA must be a real SINGLE or DOUBLE N-by-2 matrix with N >= 2.');
end
data = sortrows(data,1);
timestamps = double(data(:,1));
coordinateSpan = timestamps(end)-timestamps(1);

if nargin < 2 || isempty(window)
    window = 0.3*coordinateSpan;
end
if nargin < 3 || isempty(step)
    step = median(diff(timestamps));
end
if nargin < 4 || isempty(halfwindow)
    halfwindow = 0;
end
if nargin < 5 || isempty(alpha)
    alpha = 0.05;
end
if nargin < 6 || isempty(plotn)
    plotn = 0;
end

endpointPolicy = endpointPolicyFromLegacyFlag(halfwindow);
plotRequested = logicalScalar(plotn,'plotn');
meanOptions = struct( ...
    'window_length',window, ...
    'step',step, ...
    'endpoint_policy',endpointPolicy, ...
    'alpha',alpha);
[meanResult,~] = acycleFixedBandwidthSummary(data,'mean',meanOptions);

medianOptions = rmfield(meanOptions,'alpha');
[medianResult,~] = acycleFixedBandwidthSummary( ...
    data,'median',medianOptions);
[centerFound,medianRow] = ismember(meanResult(:,1),medianResult(:,1));
if ~all(centerFound)
    error('Acycle:FixedBandwidth:InternalCenterAlignmentFailure', ...
        ['Every emitted mean center must also be present in the median ', ...
         'summary generated from the same candidate grid.']);
end

t = meanResult(:,1);
meantd = meanResult(:,2);
vartd = meanResult(:,3);
np = meanResult(:,4);
CI_lower = meanResult(:,5);
CI_upper = meanResult(:,6);
mediantd = medianResult(medianRow,2);

if plotRequested
    values = double(data(:,2));
    confidencePercent = 100*(1-double(alpha));
    figure
    subplot(2,1,1)
    plot(timestamps,values,'k-')
    hold on
    plot(t,meantd,'ro-')
    xlim([timestamps(1),timestamps(end)])
    title(['Raw and move mean. Window = ',num2str(window)])
    subplot(2,1,2)
    plot(t,vartd,'r-')
    hold on
    plot(t,CI_lower,'k--')
    plot(t,CI_upper,'k--')
    xlim([timestamps(1),timestamps(end)])
    title(['Move variance and ',num2str(confidencePercent), ...
        '% CI. Window = ',num2str(window)])
end
end

function policy = endpointPolicyFromLegacyFlag(flag)
if islogical(flag) && isscalar(flag)
    flag = double(flag);
end
if ~(isnumeric(flag) && isreal(flag) && isscalar(flag) && ...
        isfinite(flag) && (flag == 0 || flag == 1))
    error('Acycle:FixedBandwidth:InvalidLegacyEndpointFlag', ...
        'HALFWINDOW must be 0 for complete or 1 for partial windows.');
end
if flag == 0
    policy = 'complete';
else
    policy = 'partial';
end
end

function value = logicalScalar(value,name)
if islogical(value) && isscalar(value)
    return
end
if isnumeric(value) && isreal(value) && isscalar(value) && ...
        isfinite(value) && (value == 0 || value == 1)
    value = logical(value);
    return
end
error('Acycle:FixedBandwidth:InvalidLogicalScalar', ...
    '%s must be one logical scalar.',upper(name));
end
