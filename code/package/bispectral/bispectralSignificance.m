function significance = bispectralSignificance(y,dt,options,observed,state)
%BISPECTRALSIGNIFICANCE Pointwise or global inference for bicoherence.
%   Surrogate-global uses the maximum bicoherence-squared value in the
%   fixed set of finite observed triads in the computed principal domain
%   for each null realization and therefore
%   controls family-wise error independently of the plotted frequency limit.
%   Formal inference uses IAAFT maximum-statistic surrogates. Analytical,
%   pointwise, and FT-phase paths remain for API compatibility and validation.

method = lower(strtrim(char(options.SignificanceMethod)));
nAxis = numel(observed.Frequency);
emptyMatrix = nan(nAxis);
significance = struct( ...
    'Method',method, ...
    'ConfidenceLevel',options.ConfidenceLevel, ...
    'Threshold',NaN, ...
    'ThresholdComparison','not applicable', ...
    'ThresholdMatrix',emptyMatrix, ...
    'PValue',emptyMatrix, ...
    'SignificantMask',false(nAxis), ...
    'SurrogateMaxima',[], ...
    'SurrogateSpectralErrors',[], ...
    'SurrogateAttemptSpectralErrors',[], ...
    'SurrogateSpectralErrorDomain','', ...
    'SurrogateType','none', ...
    'NumSurrogates',0, ...
    'SurrogateAttemptCount',0, ...
    'RejectedSurrogateCount',0, ...
    'RejectedIAAFTQualityCount',0, ...
    'RejectedNonfiniteEstimateCount',0, ...
    'IAAFTSpectralTolerance',options.IAAFTSpectralTolerance, ...
    'MaxSurrogateAttempts',0, ...
    'RandomSeed',options.RandomSeed, ...
    'InferenceFamilyTriadCount',0, ...
    'InferenceFamilyDefinition','none', ...
    'FrequencyViewLimitsAffectInferenceFamily',false, ...
    'Warnings',{cell(0,1)}, ...
    'Interpretation','No significance calculation requested.');

if any(strcmp(method,{'none','off',''}))
    return
end
confidence = double(options.ConfidenceLevel);
if ~(isscalar(confidence) && isreal(confidence) && isfinite(confidence) && ...
        confidence > 0.5 && confidence < 1)
    error('Acycle:Bispectral:InvalidConfidence', ...
        'ConfidenceLevel must lie strictly between 0.5 and 1.');
end

observedPairs = observed.PairBicoherenceSquared;
pairIndex = observed.PairLinearIndex;
observedFamily = isfinite(observedPairs);
significance.InferenceFamilyTriadCount = nnz(observedFamily);
if any(strcmp(method,{'analytical','analytic','beta'}))
    realizationCount = state.Meta.EffectiveRealizationCount;
    if ~(isfinite(realizationCount) && realizationCount > 1)
        error('Acycle:Bispectral:InsufficientRealizations', ...
            'At least two effective realizations are needed for the Beta approximation.');
    end
    alpha = 1-confidence;
    threshold = 1-alpha^(1/(realizationCount-1));
    pPairs = (1-observedPairs).^(realizationCount-1);
    pPairs(~isfinite(observedPairs)) = NaN;
    thresholdMatrix = nan(nAxis);
    thresholdMatrix(pairIndex) = threshold;
    pValue = nan(nAxis);
    pValue(pairIndex) = pPairs;
    significant = false(nAxis);
    significant(pairIndex) = observedPairs >= threshold;
    significance.Threshold = threshold;
    significance.ThresholdComparison = '>=';
    significance.ThresholdMatrix = thresholdMatrix;
    significance.PValue = pValue;
    significance.SignificantMask = significant & observed.ValidMask;
    significance.InferenceFamilyDefinition = ...
        'Individual finite observed triads in the computed principal domain';
    significance.Warnings = {[
        'Analytical Beta inference is retained for API compatibility and ', ...
        'method validation only. Formal map inference uses IAAFT ', ...
        'maximum-statistic FWER control.']};
    significance.Interpretation = [ ...
        'Compatibility-only pointwise Beta(1,R-1) approximation. Overlap, ', ...
        'tapering, and shared frequency-smoothed triads make this a reference ', ...
        'threshold, not formal inference.'];
    return
end

isPointwise = any(strcmp(method,{'surrogate-pointwise','pointwise-surrogate'}));
isGlobal = any(strcmp(method,{'surrogate-global','global-surrogate','max-surrogate'}));
if ~(isPointwise || isGlobal)
    error('Acycle:Bispectral:InvalidSignificanceMethod', ...
        ['SignificanceMethod must be none, analytical, ', ...
         'surrogate-pointwise, or surrogate-global.']);
end
if isGlobal && ~any(observedFamily)
    error('Acycle:Bispectral:EmptyInferenceFamily', ...
        ['Maximum-statistic inference requires at least one finite observed ', ...
         'b^2 value in the computed principal domain.']);
end
if isGlobal
    significance.InferenceFamilyDefinition = ...
        'Fixed finite observed b^2 triads in the computed principal domain';
else
    significance.InferenceFamilyDefinition = ...
        'Individual finite observed triads in the computed principal domain';
end

nSurrogates = options.NumSurrogates;
if ~(isFiniteIntegerScalar(nSurrogates) && ...
        nSurrogates >= 19 && nSurrogates <= 99999)
    error('Acycle:Bispectral:InvalidSurrogateCount', ...
        ['Use an integer between 19 and 99999 surrogates. Formal IAAFT ', ...
         'maximum-statistic inference defaults to 999.']);
end
nSurrogates = double(nSurrogates);
alpha = 1-confidence;
minimumPossibleP = 1/(nSurrogates+1);
if minimumPossibleP > alpha
    minimumSurrogates = ceil(1/alpha-1);
    error('Acycle:Bispectral:InsufficientSurrogatesForConfidence', ...
        ['%d surrogates give a minimum plus-one p-value of %.6g, which ', ...
         'cannot reach alpha=%.6g. Use at least %d surrogates for %.4g%% confidence.'], ...
        nSurrogates,minimumPossibleP,alpha,minimumSurrogates,100*confidence);
end
surrogateType = canonicalSurrogateType(options.SurrogateType);
nullLabel = surrogateLabel(surrogateType);
if ~(isFiniteIntegerScalar(options.IAAFTIterations) && ...
        options.IAAFTIterations >= 1)
    error('Acycle:Bispectral:InvalidIAAFTIterations', ...
        'IAAFTIterations must be a positive integer.');
end
iaaftTolerance = double(options.IAAFTSpectralTolerance);
if ~(isscalar(iaaftTolerance) && isreal(iaaftTolerance) && ...
        isfinite(iaaftTolerance) && ...
        iaaftTolerance > 0 && iaaftTolerance <= 1)
    error('Acycle:Bispectral:InvalidIAAFTSpectralTolerance', ...
        'IAAFTSpectralTolerance must lie in (0,1].');
end
if isempty(options.MaxSurrogateAttempts)
    maxAttempts = nSurrogates+max(10,ceil(0.1*nSurrogates));
else
    maxAttempts = options.MaxSurrogateAttempts;
end
if ~(isFiniteIntegerScalar(maxAttempts) && ...
        maxAttempts >= nSurrogates)
    error('Acycle:Bispectral:InvalidMaxSurrogateAttempts', ...
        'MaxSurrogateAttempts must be at least NumSurrogates.');
end
maxAttempts = double(maxAttempts);

randomSeed = options.RandomSeed;
if ~(isFiniteIntegerScalar(randomSeed) && randomSeed >= 0 && ...
        randomSeed <= double(intmax('uint32')))
    error('Acycle:Bispectral:InvalidRandomSeed', ...
        'RandomSeed must be an integer from 0 through 2^32-1.');
end
randomSeed = double(randomSeed);

previousRng = rng;
cleanupRng = onCleanup(@()rng(previousRng));
rng(randomSeed,'twister');
nPairs = numel(observedPairs);
if isPointwise
    estimatedWorkingBytes = 8*double(nPairs)*double(nSurrogates);
    maximumWorkingBytes = 1024^3;
    if ~isfinite(estimatedWorkingBytes) || estimatedWorkingBytes > maximumWorkingBytes
        error('Acycle:Bispectral:PointwiseSurrogateMemory', ...
            ['Pointwise surrogate thresholds would require about %.2f GiB of ', ...
             'working memory (safety limit %.2f GiB). Reduce Maximum computed ', ...
             'freq. bins or NumSurrogates, or use max-statistic FWER inference.'], ...
            estimatedWorkingBytes/1024^3,maximumWorkingBytes/1024^3);
    end
    % Keep thresholds and plus-one exceedance counts on the same double-
    % precision values. The memory guard above already budgets 8 bytes/value.
    surrogateValues = nan(nPairs,nSurrogates);
else
    surrogateValues = [];
end
surrogateMaxima = nan(nSurrogates,1);
surrogateSpectralErrors = nan(nSurrogates,1);
attemptSpectralErrors = nan(maxAttempts,1);
exceedanceCount = zeros(nPairs,1);
finiteNullCount = zeros(nPairs,1);
notify(options,0,'Generating bispectral null surrogates');
attemptCount = 0;
acceptedCount = 0;
rejectedIaaftCount = 0;
rejectedNonfiniteCount = 0;
spectralErrorDomain = '';
while acceptedCount < nSurrogates && attemptCount < maxAttempts
    attemptCount = attemptCount+1;
    [surrogate,surrogateMeta] = bispectralSurrogate( ...
        y,surrogateType,options.IAAFTIterations);
    spectralError = double(surrogateMeta.RelativeSpectralError);
    if isfield(surrogateMeta,'SpectralErrorDomain')
        spectralErrorDomain = char(surrogateMeta.SpectralErrorDomain);
    end
    attemptSpectralErrors(attemptCount) = spectralError;
    if strcmp(surrogateType,'iaaft') && ...
            ~(isfinite(spectralError) && spectralError <= iaaftTolerance)
        rejectedIaaftCount = rejectedIaaftCount+1;
        notify(options,acceptedCount/nSurrogates,sprintf( ...
            'Rejected IAAFT surrogate %d (spectral error %.4g > %.4g)', ...
            attemptCount,spectralError,iaaftTolerance));
        continue
    end
    surrogateEstimate = bispectralEstimate(surrogate,dt,options,state);
    values = surrogateEstimate.PairBicoherenceSquared;
    if isGlobal
        % Maximum-statistic inference must use one fixed family in every
        % null realization.  The family is the set of finite observed
        % triads in the computed principal domain; accepting a surrogate
        % with a missing member would silently shrink that realization's
        % family and can bias its maximum downward.
        finiteValues = values(observedFamily);
        hasRequiredValues = ~isempty(finiteValues) && ...
            all(isfinite(finiteValues));
    else
        finiteValues = values(isfinite(values));
        hasRequiredValues = ~isempty(finiteValues);
    end
    if ~hasRequiredValues
        rejectedNonfiniteCount = rejectedNonfiniteCount+1;
        notify(options,acceptedCount/nSurrogates,sprintf( ...
            'Rejected incomplete bispectral surrogate attempt %d',attemptCount));
        continue
    end
    acceptedCount = acceptedCount+1;
    surrogateSpectralErrors(acceptedCount) = spectralError;
    exceedanceCount = exceedanceCount + (values >= observedPairs);
    finiteNullCount = finiteNullCount + isfinite(values);
    surrogateMaxima(acceptedCount) = max(finiteValues);
    if isPointwise
        surrogateValues(:,acceptedCount) = values;
    end
    notify(options,acceptedCount/nSurrogates, ...
        sprintf('Bispectral surrogate %d of %d (attempt %d)', ...
        acceptedCount,nSurrogates,attemptCount));
end
if acceptedCount < nSurrogates
    if rejectedIaaftCount > 0
        error('Acycle:Bispectral:IAAFTQualityFailure', ...
            ['Only %d of %d required null surrogates passed after %d attempts; ', ...
             '%d IAAFT surrogate(s) exceeded spectral-error tolerance %.4g. ', ...
             'Increase IAAFTIterations or, with scientific justification, ', ...
             'adjust IAAFTSpectralTolerance/MaxSurrogateAttempts.'], ...
            acceptedCount,nSurrogates,attemptCount,rejectedIaaftCount,iaaftTolerance);
    end
    error('Acycle:Bispectral:SurrogateFailure', ...
        ['Only %d of %d required finite null surrogates were obtained after ', ...
         '%d attempts.'],acceptedCount,nSurrogates,attemptCount);
end

pPairs = (1+exceedanceCount)./(1+finiteNullCount);
pPairs(~isfinite(observedPairs)) = NaN;
pValue = nan(nAxis);
pValue(pairIndex) = pPairs;
significant = false(nAxis);
thresholdMatrix = nan(nAxis);
if isPointwise
    surrogateValues(~isfinite(surrogateValues)) = Inf;
    sortedValues = sort(surrogateValues,2,'ascend');
    thresholdPairs = nan(nPairs,1);
    positiveCounts = unique(finiteNullCount(finiteNullCount > 0));
    for countIndex = 1:numel(positiveCounts)
        finiteCount = positiveCounts(countIndex);
        criticalRank = plusOneCriticalRank(finiteCount,alpha);
        if isnan(criticalRank)
            continue
        end
        rows = find(finiteNullCount == finiteCount);
        linearIndex = sub2ind(size(sortedValues),rows, ...
            repmat(criticalRank,numel(rows),1));
        thresholdPairs(rows) = double(sortedValues(linearIndex));
    end
    thresholdPairs(~isfinite(observedPairs)) = NaN;
    thresholdPairs(~isfinite(thresholdPairs)) = NaN;
    thresholdMatrix(pairIndex) = thresholdPairs;
    significant(pairIndex) = observedPairs > thresholdPairs & pPairs <= alpha;
    significance.ThresholdComparison = [ ...
        'strictly greater than the plus-one Monte Carlo critical order ', ...
        'statistic, with p <= alpha'];
    interpretation = sprintf([ ...
        'Compatibility-only pointwise %s surrogate threshold; it does not ', ...
        'control the family-wise error rate across the full map.'], ...
        nullLabel);
else
    finiteMaxima = sort(surrogateMaxima(isfinite(surrogateMaxima)));
    if numel(finiteMaxima) < ceil(0.9*nSurrogates)
        error('Acycle:Bispectral:SurrogateFailure', ...
            'Too many surrogate estimates lacked finite bicoherence values.');
    end
    criticalRank = plusOneCriticalRank(numel(finiteMaxima),alpha);
    if isnan(criticalRank)
        error('Acycle:Bispectral:InsufficientSurrogatesForConfidence', ...
            ['The accepted surrogate count cannot attain the requested ', ...
             'plus-one Monte Carlo significance level.']);
    end
    threshold = finiteMaxima(criticalRank);
    thresholdMatrix(pairIndex(observedFamily)) = threshold;
    globalP = (1+countGreaterEqual(finiteMaxima,observedPairs))/(numel(finiteMaxima)+1);
    globalP(~isfinite(observedPairs)) = NaN;
    pValue(pairIndex) = globalP;
    significant(pairIndex) = observedPairs > threshold & globalP <= alpha;
    significance.Threshold = threshold;
    significance.ThresholdComparison = [ ...
        'strictly greater than the plus-one Monte Carlo critical order ', ...
        'statistic, with global p <= alpha'];
    interpretation = [nullLabel, ...
        ' maximum-statistic surrogate threshold controlling ', ...
        'family-wise error over the fixed computed principal domain, ', ...
        'conditional on the selected surrogate null and exchangeability.'];
end

qualityWarnings = cell(0,1);
if isPointwise
    qualityWarnings{end+1,1} = [ ...
        'Pointwise surrogate inference is retained for API compatibility and ', ...
        'validation only; formal maps use IAAFT maximum-statistic FWER control.'];
elseif isGlobal && strcmp(surrogateType,'phase')
    qualityWarnings{end+1,1} = [ ...
        'FT phase maximum-statistic inference is retained for API compatibility ', ...
        'and validation only; formal maps use IAAFT surrogates.'];
end
if rejectedIaaftCount > 0
    qualityWarnings{end+1,1} = sprintf( ...
        ['Rejected and replaced %d IAAFT null surrogate(s) whose relative ', ...
         'Fourier-amplitude error exceeded %.4g.'], ...
        rejectedIaaftCount,iaaftTolerance);
end
if rejectedNonfiniteCount > 0
    qualityWarnings{end+1,1} = sprintf( ...
        ['Rejected and replaced %d null surrogate estimate(s) that lacked ', ...
         'one or more b^2 values required by the fixed inference family.'], ...
        rejectedNonfiniteCount);
end
significance.ThresholdMatrix = thresholdMatrix;
significance.PValue = pValue;
significance.SignificantMask = significant & observed.ValidMask;
significance.SurrogateMaxima = surrogateMaxima;
significance.SurrogateSpectralErrors = surrogateSpectralErrors;
significance.SurrogateAttemptSpectralErrors = attemptSpectralErrors(1:attemptCount);
significance.SurrogateSpectralErrorDomain = spectralErrorDomain;
significance.SurrogateType = surrogateType;
significance.NumSurrogates = nSurrogates;
significance.SurrogateAttemptCount = attemptCount;
significance.RejectedSurrogateCount = rejectedIaaftCount+rejectedNonfiniteCount;
significance.RejectedIAAFTQualityCount = rejectedIaaftCount;
significance.RejectedNonfiniteEstimateCount = rejectedNonfiniteCount;
significance.IAAFTSpectralTolerance = iaaftTolerance;
significance.MaxSurrogateAttempts = maxAttempts;
significance.Warnings = qualityWarnings;
significance.Interpretation = interpretation;
end

function type = canonicalSurrogateType(value)
value = lower(strtrim(char(value)));
if any(strcmp(value,{'phase','ft','fourier'}))
    type = 'phase';
elseif strcmp(value,'iaaft')
    type = 'iaaft';
else
    error('Acycle:Bispectral:InvalidSurrogateType', ...
        'SurrogateType must be phase or iaaft.');
end
end

function label = surrogateLabel(type)
if strcmp(type,'iaaft')
    label = 'IAAFT';
else
    label = 'FT phase';
end
end

function counts = countGreaterEqual(sortedValues,queryValues)
% Avoid constructing an nTriads-by-nSurrogates temporary logical matrix.
sortedValues = sortedValues(:);
n = numel(sortedValues);
counts = nan(size(queryValues));
for ii = 1:numel(queryValues)
    query = queryValues(ii);
    if ~isfinite(query)
        continue
    end
    low = 1;
    high = n+1;
    while low < high
        middle = floor((low+high)/2);
        if middle <= n && sortedValues(middle) < query
            low = middle+1;
        else
            high = middle;
        end
    end
    counts(ii) = n-low+1;
end
end

function rank = plusOneCriticalRank(sampleCount,alpha)
% Return the strict-exceedance critical rank for a plus-one Monte Carlo test.
% If c null statistics are at least as large as the observation, the exact
% finite-sample p-value is (1+c)/(M+1).  The largest admissible c therefore
% defines a critical order statistic that the observation must strictly
% exceed.  The short correction loops make the rank use exactly the same
% floating-point comparison as the reported p-value at alpha-grid edges.
if ~(isFiniteIntegerScalar(sampleCount) && sampleCount >= 1)
    rank = NaN;
    return
end
sampleCount = double(sampleCount);
allowed = floor(alpha*(sampleCount+1))-1;
allowed = max(-1,min(sampleCount,allowed));
while allowed < sampleCount && ...
        (allowed+2)/(sampleCount+1) <= alpha
    allowed = allowed+1;
end
while allowed >= 0 && ...
        (allowed+1)/(sampleCount+1) > alpha
    allowed = allowed-1;
end
if allowed < 0
    rank = NaN;
else
    rank = sampleCount-allowed;
end
end

function notify(options,fraction,message)
if isempty(options.ProgressFcn)
    return
end
feval(options.ProgressFcn,max(0,min(1,fraction)),message);
end

function tf = isFiniteIntegerScalar(value)
tf = isscalar(value) && isnumeric(value) && isreal(value) && ...
    isfinite(value) && value == fix(value);
end
