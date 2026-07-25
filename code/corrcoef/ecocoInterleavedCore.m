function result = ecocoInterleavedCore(data,orbit9,window,dt,step,red,pad, ...
        srGrid,nsim,method,maxFrequency,seed,varargin)
%ECOCOINTERLEAVEDCORE Prototype odd/even cross-validated evolutionary COCO.
%
% RESULT = ECOCOINTERLEAVEDCORE(DATA,ORBIT9,WINDOW,DT,STEP,RED,PAD,
% SRGRID,NSIM,METHOD,MAXFREQUENCY,SEED) evaluates complete sliding windows
% of the cleaned input record.  Within every window the
% globally Odd observations train a frozen Method-B coherent-nine target
% that is validated on the globally Even observations, and vice versa.
% Odd/even assignment is made on the complete sorted, de-duplicated record
% and therefore does not change when a window starts on an Even row.
%
% Each window delegates its complete bidirectional analysis and joint
% full-order AR(1) null to INTERLEAVEDCVCOCO.  The same-rate consensus is
% the smaller of the two directional correlation curves.  Its global p is
% a plus-one Monte Carlo p-value against the null maximum over the full
% tested sedimentation-rate grid within that window.  No correction is
% applied over sliding windows.  STRICTCONSENSUS retains the same observed
% curve but uses the larger of the two directional p-values.
% The ridge-ranking score is pCOCO = rho*abs(log10(global p)); resolved
% orbit count is retained as a diagnostic map and does not weight pCOCO.
%
% DATA may be irregularly sampled.  This function removes nonfinite rows,
% sorts depth, and replaces duplicate-depth values by their mean.  It does
% not interpolate the complete record: each odd/even fold is interpolated
% independently inside INTERLEAVEDCVCOCO after the split.  The default
% physical-depth mode treats WINDOW and StepDepth as exact
% depth-coordinate support and center spacing.  Only complete windows are
% used (no edge padding).  Every real observation inside the requested
% support is retained; global Odd/Even folds may therefore differ by one
% observation when a physical window contains an odd number of rows.  The
% historical fixed-point behavior remains available as legacy-count.
%
% Name-value options:
%   'BatchSize'   Monte Carlo realizations per delegated batch (default 20)
%   'ProgressFcn' function handle called as FCN(fraction,message), or []
%   'WindowMode'  'physical-depth' (default) or 'legacy-count'
%   'StepDepth'   exact center spacing in depth units for physical-depth
%                 mode; default STEP*DT preserves the public positional
%                 STEP parameter's historical sample-count units
%   'WarnOnPartialTraining' emit one aggregate warning when one or more
%                 windows use audited partial-orbit training (default true)

% When NSIM is positive, progress reports one total-work percentage across
% all windows.  When NSIM is zero, it reports completed-window counts.


parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'BatchSize',20,@(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x >= 1 && x == fix(x));
addParameter(parser,'ProgressFcn',[],@(x) isempty(x) || ...
    isa(x,'function_handle'));
addParameter(parser,'WindowMode','physical-depth',@(x) ischar(x) || ...
    (isstring(x) && isscalar(x)));
addParameter(parser,'StepDepth',[],@(x) isempty(x) || ...
    (isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x > 0));
addParameter(parser,'WarnOnPartialTraining',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(x == [0 1]));
parse(parser,varargin{:});
options = parser.Results;
options.WarnOnPartialTraining = logical(options.WarnOnPartialTraining);
windowMode = validatestring(char(options.WindowMode), ...
    {'legacy-count','physical-depth'},mfilename,'WindowMode');
stepDepth = options.StepDepth;
if strcmp(windowMode,'physical-depth') && isempty(stepDepth)
    stepDepth = step*dt;
end

[data,orbit9,srGrid,method,nWindow,inputInfo] = validateInputs( ...
    data,orbit9,window,dt,step,red,pad,srGrid,nsim,method, ...
    maxFrequency,seed,windowMode);

if strcmp(windowMode,'physical-depth')
    [starts,ends,depth,windowLower,windowUpper,pointCount, ...
        observedCenter,observedSpan,physicalWindowInfo] = ...
        buildPhysicalDepthWindows(data(:,1),window,stepDepth);
    supportSpan = windowUpper-windowLower;
    requestedStepDepth = stepDepth;
else
    nData = size(data,1);
    lastStart = nData-nWindow+1;
    starts = (1:step:lastStart)';
    if isempty(starts)
        error('ecocoInterleavedCore:NoWindows', ...
            'No complete balanced sliding windows remain.');
    end
    ends = starts+nWindow-1;
    pointCount = ends-starts+1;
    windowLower = data(starts,1);
    windowUpper = data(ends,1);
    observedCenter = 0.5*(windowLower+windowUpper);
    observedSpan = windowUpper-windowLower;
    depth = observedCenter;
    supportSpan = observedSpan;
    requestedStepDepth = step*dt;
    physicalWindowInfo = struct( ...
        'candidateCount',numel(starts), ...
        'oddCandidateCount',0, ...
        'emptyCandidateCount',0);
end
nWindows = numel(starts);
nRate = numel(srGrid);
phase = mod(starts-1,2);
windowSeed = nan(nWindows,1);
for windowIndex = 1:nWindows
    windowSeed(windowIndex) = deriveWindowSeed( ...
        seed,starts(windowIndex),ends(windowIndex),windowIndex);
end

if nRate == 1
    rateStep = max(1,abs(srGrid(1))*sqrt(eps));
else
    rateStep = median(diff(srGrid));
end
srCallEnd = srGrid(1)+rateStep*(nRate-1);

rhoForward = nan(nRate,nWindows);
rhoBackward = nan(nRate,nWindows);
rhoConsensus = nan(nRate,nWindows);
pGlobalForward = nan(nRate,nWindows);
pGlobalBackward = nan(nRate,nWindows);
pGlobalConsensus = nan(nRate,nWindows);
pLocalForward = nan(nRate,nWindows);
pLocalBackward = nan(nRate,nWindows);
pLocalConsensus = nan(nRate,nWindows);
pGlobalStrict = nan(nRate,nWindows);
pLocalStrict = nan(nRate,nWindows);
nOrbitForward = nan(nRate,nWindows);
nOrbitBackward = nan(nRate,nWindows);
nOrbitConsensus = nan(nRate,nWindows);

bestRateForward = nan(nWindows,1);
bestRateBackward = nan(nWindows,1);
bestRateConsensus = nan(nWindows,1);
bestIndexForward = nan(nWindows,1);
bestIndexBackward = nan(nWindows,1);
bestIndexConsensus = nan(nWindows,1);
bestCorrelationForward = nan(nWindows,1);
bestCorrelationBackward = nan(nWindows,1);
bestCorrelationConsensus = nan(nWindows,1);
pDirectionalOddToEven = nan(nWindows,1);
pDirectionalEvenToOdd = nan(nWindows,1);
pRobustByWindow = nan(nWindows,1);
pSymByWindow = nan(nWindows,1);
pConsensusByWindow = nan(nWindows,1);

foldSpacingOdd = nan(nWindows,1);
foldSpacingEven = nan(nWindows,1);
rawPointCountOdd = nan(nWindows,1);
rawPointCountEven = nan(nWindows,1);
regularPointCountOdd = nan(nWindows,1);
regularPointCountEven = nan(nWindows,1);
allNineRateRangeOdd = nan(nWindows,2);
allNineRateRangeEven = nan(nWindows,2);
allNineRateRangeShared = nan(nWindows,2);
rhoM = nan(nWindows,1);
nsimCompletedByWindow = zeros(nWindows,1);
batchSizeByWindow = zeros(nWindows,1);
success = false(nWindows,1);
failureIdentifier = repmat({''},nWindows,1);
failureReason = repmat({''},nWindows,1);
supportDirection = repmat({'none'},nWindows,1);
partialOrbitTraining = false(nWindows,1);
trainingCompletenessOdd = repmat({'unresolved'},nWindows,1);
trainingCompletenessEven = repmat({'unresolved'},nWindows,1);
trainingResolvablePeriodsOdd = nan(nWindows,1);
trainingResolvablePeriodsEven = nan(nWindows,1);
trainingResolvedGroupsOdd = false(nWindows,4);
trainingResolvedGroupsEven = false(nWindows,4);

lastReportedPercent = -1;
reportProgress(options.ProgressFcn,0,sprintf( ...
    'Preparing %d complete %s Interleaved eCOCO windows.', ...
    nWindows,strrep(windowMode,'-',' ')));

for windowIndex = 1:nWindows
    if ~isfinite(starts(windowIndex)) || ~isfinite(ends(windowIndex)) || ...
            pointCount(windowIndex) < 16
        failureIdentifier{windowIndex} = ...
            'ecocoInterleavedCore:InsufficientWindowObservations';
        failureReason{windowIndex} = sprintf([ ...
            'The complete window centered at %.12g m contains %d usable ', ...
            'raw observations; at least 16 (eight per Odd/Even fold) ', ...
            'are required.'],depth(windowIndex),pointCount(windowIndex));
        if nsim > 0
            reportTotalMonteCarloWork(windowIndex,1);
        else
            reportProgress(options.ProgressFcn,windowIndex/nWindows, ...
                sprintf('Interleaved eCOCO windows completed: %d of %d', ...
                windowIndex,nWindows));
        end
        continue
    end
    index = starts(windowIndex):ends(windowIndex);
    localProgressFcn = [];
    if nsim > 0 && ~isempty(options.ProgressFcn)
        localProgressFcn = @(fraction,~) ...
            reportTotalMonteCarloWork(windowIndex,fraction);
    end
    try
        windowResult = interleavedcvcoco( ...
            data(index,:),orbit9,pad,srGrid(1),srCallEnd,rateStep, ...
            red,nsim,method,'Seed',windowSeed(windowIndex), ...
            'BatchSize',options.BatchSize,'MaxFrequency',maxFrequency, ...
            'InterleavedPhase',phase(windowIndex),'Verbose',false, ...
            'WarnOnPartialTraining',false, ...
            'ProgressFcn',localProgressFcn);
    catch exception
        if isUnresolvableWindow(exception)
            failureIdentifier{windowIndex} = exception.identifier;
            failureReason{windowIndex} = exception.message;
            if nsim > 0
                reportTotalMonteCarloWork(windowIndex,1);
            else
                reportProgress(options.ProgressFcn,windowIndex/nWindows, ...
                    sprintf('Interleaved eCOCO windows completed: %d of %d', ...
                    windowIndex,nWindows));
            end
            continue
        end
        rethrow(exception)
    end

    validateWindowResult(windowResult,srGrid,nRate);
    forwardResult = windowResult.validateAtoB;
    backwardResult = windowResult.validateBtoA;
    consensusResult = windowResult.consensus;

    rhoForward(:,windowIndex) = columnVector( ...
        forwardResult.curve,nRate,'Odd-to-Even correlation');
    rhoBackward(:,windowIndex) = columnVector( ...
        backwardResult.curve,nRate,'Even-to-Odd correlation');
    rhoConsensus(:,windowIndex) = columnVector( ...
        consensusResult.curve,nRate,'consensus correlation');
    pGlobalForward(:,windowIndex) = columnVector( ...
        forwardResult.pGlobalCurve,nRate,'Odd-to-Even global p');
    pGlobalBackward(:,windowIndex) = columnVector( ...
        backwardResult.pGlobalCurve,nRate,'Even-to-Odd global p');
    pGlobalConsensus(:,windowIndex) = columnVector( ...
        consensusResult.pGlobalCurve,nRate,'consensus global p');
    pLocalForward(:,windowIndex) = columnVector( ...
        forwardResult.pLocalCurve,nRate,'Odd-to-Even local p');
    pLocalBackward(:,windowIndex) = columnVector( ...
        backwardResult.pLocalCurve,nRate,'Even-to-Odd local p');
    pLocalConsensus(:,windowIndex) = columnVector( ...
        consensusResult.pLocalCurve,nRate,'consensus local p');
    pGlobalStrict(:,windowIndex) = columnVector( ...
        consensusResult.pDirectionalMaxCurve,nRate, ...
        'directional-maximum global p');
    pLocalStrict(:,windowIndex) = maxPairStrict( ...
        pLocalForward(:,windowIndex),pLocalBackward(:,windowIndex));

    nOrbitForward(:,windowIndex) = columnVector( ...
        windowResult.activeOrbitCountAtoB,nRate, ...
        'Odd-to-Even active-orbit count');
    nOrbitBackward(:,windowIndex) = columnVector( ...
        windowResult.activeOrbitCountBtoA,nRate, ...
        'Even-to-Odd active-orbit count');
    nOrbitConsensus(:,windowIndex) = columnVector( ...
        consensusResult.activeOrbitCountCurve,nRate, ...
        'consensus active-orbit count');

    [bestRateForward(windowIndex),bestIndexForward(windowIndex), ...
        bestCorrelationForward(windowIndex)] = ...
        directionMaximum(forwardResult,srGrid);
    [bestRateBackward(windowIndex),bestIndexBackward(windowIndex), ...
        bestCorrelationBackward(windowIndex)] = ...
        directionMaximum(backwardResult,srGrid);
    bestRateConsensus(windowIndex) = consensusResult.bestRate;
    bestIndexConsensus(windowIndex) = consensusResult.bestIndex;
    bestCorrelationConsensus(windowIndex) = ...
        consensusResult.bestCorrelation;
    pDirectionalOddToEven(windowIndex) = windowResult.pAtoB;
    pDirectionalEvenToOdd(windowIndex) = windowResult.pBtoA;
    pRobustByWindow(windowIndex) = windowResult.pRobust;
    pSymByWindow(windowIndex) = windowResult.pSym;
    pConsensusByWindow(windowIndex) = windowResult.pConsensus;

    foldSpacingOdd(windowIndex) = windowResult.samplingIntervalA;
    foldSpacingEven(windowIndex) = windowResult.samplingIntervalB;
    rawPointCountOdd(windowIndex) = size(windowResult.rawDataA,1);
    rawPointCountEven(windowIndex) = size(windowResult.rawDataB,1);
    regularPointCountOdd(windowIndex) = size(windowResult.dataA,1);
    regularPointCountEven(windowIndex) = size(windowResult.dataB,1);
    allNineRateRangeOdd(windowIndex,:) = ...
        reshape(windowResult.allNineRateRangeA,1,2);
    allNineRateRangeEven(windowIndex,:) = ...
        reshape(windowResult.allNineRateRangeB,1,2);
    allNineRateRangeShared(windowIndex,:) = ...
        reshape(windowResult.allNineRateRangeShared,1,2);
    rhoM(windowIndex) = windowResult.rhoM;
    nsimCompletedByWindow(windowIndex) = windowResult.nsimCompleted;
    batchSizeByWindow(windowIndex) = windowResult.config.batchSize;
    partialOrbitTraining(windowIndex) = windowResult.degradedMode;
    trainingCompletenessOdd{windowIndex} = ...
        windowResult.trainingCompletenessA;
    trainingCompletenessEven{windowIndex} = ...
        windowResult.trainingCompletenessB;
    trainingResolvablePeriodsOdd(windowIndex) = ...
        windowResult.trainA.resolvablePeriodCount;
    trainingResolvablePeriodsEven(windowIndex) = ...
        windowResult.trainB.resolvablePeriodCount;
    trainingResolvedGroupsOdd(windowIndex,:) = ...
        reshape(windowResult.trainA.resolvedGroupMask,1,4);
    trainingResolvedGroupsEven(windowIndex,:) = ...
        reshape(windowResult.trainB.resolvedGroupMask,1,4);
    success(windowIndex) = true;
    supportDirection{windowIndex} = 'both';

    if nsim == 0
        reportProgress(options.ProgressFcn,windowIndex/nWindows,sprintf( ...
            'Interleaved eCOCO windows completed: %d of %d', ...
            windowIndex,nWindows));
    end
end

if ~any(success)
    identifiers = unique(failureIdentifier(~cellfun(@isempty,failureIdentifier)));
    summaryText = strjoin(identifiers,', ');
    error('ecocoInterleavedCore:NoResolvableWindows', ...
        ['Every complete sliding window was frequency-unresolvable for ', ...
         'the requested sedimentation-rate grid. Underlying errors: %s.'], ...
        summaryText);
end

degradedWindowCount = nnz(success & partialOrbitTraining);
partialTrainingWarningIdentifier = '';
partialTrainingWarningMessage = '';
if degradedWindowCount > 0
    partialTrainingWarningIdentifier = ...
        'ecocoInterleavedCore:PartialOrbitTraining';
    partialTrainingWarningMessage = sprintf([ ...
        'Interleaved eCOCO completed with audited partial-orbit training ', ...
        'in %d of %d successful windows. Those windows use only resolved ', ...
        'orbital groups, fix unresolved group weights to zero, and remain ', ...
        'exploratory rather than complete all-nine results. Numerical maps ', ...
        'and matched Monte Carlo outputs were retained.'], ...
        degradedWindowCount,nnz(success));
    if options.WarnOnPartialTraining
        warning(partialTrainingWarningIdentifier,'%s', ...
            partialTrainingWarningMessage);
    end
end

bestRateAllNineResolved = success & isfinite(bestRateConsensus) & ...
    bestRateConsensus > allNineRateRangeShared(:,1) & ...
    bestRateConsensus <= allNineRateRangeShared(:,2);

directionForward = makeDirectionResult(rhoForward,pGlobalForward, ...
    pLocalForward,bestRateForward,bestIndexForward, ...
    bestCorrelationForward,nOrbitForward,success);
directionBackward = makeDirectionResult(rhoBackward,pGlobalBackward, ...
    pLocalBackward,bestRateBackward,bestIndexBackward, ...
    bestCorrelationBackward,nOrbitBackward,success);
directionConsensus = makeDirectionResult(rhoConsensus,pGlobalConsensus, ...
    pLocalConsensus,bestRateConsensus,bestIndexConsensus, ...
    bestCorrelationConsensus,nOrbitConsensus,success);
directionConsensus.pDirectionalMax = pGlobalStrict;
directionConsensus.pBoth = pGlobalStrict;
directionConsensus.bestDirectionalMaxP = valuesAtIndices( ...
    pGlobalStrict,bestIndexConsensus);
directionConsensus.supportDirection = supportDirection;
directionConsensus.windowGlobalP = pConsensusByWindow;
directionConsensus.windowRobustDirectionalP = pRobustByWindow;
directionConsensus.windowSymmetricP = pSymByWindow;

directionStrict = makeDirectionResult(rhoConsensus,pGlobalStrict, ...
    pLocalStrict,bestRateConsensus,bestIndexConsensus, ...
    bestCorrelationConsensus,nOrbitConsensus,success);
directionStrict.pDirectionalMax = pGlobalStrict;
directionStrict.pBoth = pGlobalStrict;
directionStrict.bestDirectionalMaxP = valuesAtIndices( ...
    pGlobalStrict,bestIndexConsensus);

finiteObservedSpan = observedSpan(isfinite(observedSpan));
finitePointCount = pointCount(isfinite(pointCount));
centerStepByWindow = diff(depth);
if isempty(centerStepByWindow)
    centerStepRange = [NaN,NaN];
    centerStepMedian = NaN;
else
    centerStepRange = [min(centerStepByWindow),max(centerStepByWindow)];
    centerStepMedian = median(centerStepByWindow);
end
if strcmp(windowMode,'physical-depth')
    completeWindowRule = [ ...
        'complete fixed physical-depth support only; no edge padding; ', ...
        'all real observations inside each support are retained'];
else
    completeWindowRule = ...
        'complete balanced fixed-count windows only; no edge padding';
end

result = struct;
result.name = 'Interleaved eCOCO';
result.publicName = 'Interleaved eCOCO';
result.abbreviation = 'I-eCOCO';
result.version = 3;
result.method = 'interleaved';
result.targetMode = 'four-group-coherent-nine';
result.windowMode = windowMode;
result.degradedMode = degradedWindowCount > 0;
if result.degradedMode
    result.status = 'complete-with-warning';
else
    result.status = 'complete';
end
result.warningIdentifier = partialTrainingWarningIdentifier;
result.warningMessage = partialTrainingWarningMessage;
result.partialOrbitTrainingWindowCount = degradedWindowCount;
result.srGrid = srGrid;
result.depth = depth;
result.directionLabels = struct( ...
    'forward','Odd -> Even','backward','Even -> Odd', ...
    'consensus','same-rate Odd/Even minimum', ...
    'strictConsensus','same-rate minimum with directional-maximum p');
result.supportDirection = supportDirection;
result.forward = directionForward;
result.backward = directionBackward;
result.oddToEven = directionForward;
result.evenToOdd = directionBackward;
result.consensus = directionConsensus;
result.strictConsensus = directionStrict;

% Root maps are the exact same-rate joint-null consensus.  The separate
% STRICTCONSENSUS structure is available for the more conservative rule.
result.rho = rhoConsensus;
result.pLocal = pLocalConsensus;
result.pParametric = nan(size(rhoConsensus));
result.pGlobal = pGlobalConsensus;
result.nOrbit = nOrbitConsensus;
result.pCOCO = pcocoValue(result.rho,result.pGlobal);
result.score = result.pCOCO;
result.pDirectionalOddToEven = pDirectionalOddToEven;
result.pDirectionalEvenToOdd = pDirectionalEvenToOdd;
result.pRobust = pRobustByWindow;
result.pSym = pSymByWindow;
result.pConsensus = pConsensusByWindow;

result.windows = struct;
result.windows.startIndex = starts;
result.windows.endIndex = ends;
result.windows.centerDepth = depth;
result.windows.requestedCenter = depth;
result.windows.requestedBounds = [windowLower,windowUpper];
result.windows.actualSpan = supportSpan;
result.windows.observedCenter = observedCenter;
result.windows.observedSpan = observedSpan;
result.windows.coverageFraction = observedSpan./window;
result.windows.pointCount = pointCount;
result.windows.interleavedPhase = phase;
result.windows.seed = windowSeed;
result.windows.success = success;
result.windows.failureIdentifier = failureIdentifier;
result.windows.failureReason = failureReason;
result.windows.supportDirection = supportDirection;
result.windows.partialOrbitTraining = partialOrbitTraining;
result.windows.trainingCompletenessOdd = trainingCompletenessOdd;
result.windows.trainingCompletenessEven = trainingCompletenessEven;
result.windows.trainingResolvablePeriodsOdd = ...
    trainingResolvablePeriodsOdd;
result.windows.trainingResolvablePeriodsEven = ...
    trainingResolvablePeriodsEven;
result.windows.trainingResolvedGroupsOdd = trainingResolvedGroupsOdd;
result.windows.trainingResolvedGroupsEven = trainingResolvedGroupsEven;
result.windows.pDirectionalOddToEven = pDirectionalOddToEven;
result.windows.pDirectionalEvenToOdd = pDirectionalEvenToOdd;
result.windows.pRobust = pRobustByWindow;
result.windows.pSym = pSymByWindow;
result.windows.pConsensus = pConsensusByWindow;
result.windows.directionalBestRateDifference = abs( ...
    bestRateForward-bestRateBackward);
result.windows.bestRateAllNineResolved = bestRateAllNineResolved;
result.windows.oddFirstGlobalIndex = starts + phase;
result.windows.evenFirstGlobalIndex = starts + (1-phase);

result.folds = struct( ...
    'spacingOdd',foldSpacingOdd, ...
    'spacingEven',foldSpacingEven, ...
    'rawPointCountOdd',rawPointCountOdd, ...
    'rawPointCountEven',rawPointCountEven, ...
    'regularPointCountOdd',regularPointCountOdd, ...
    'regularPointCountEven',regularPointCountEven, ...
    'allNineRateRangeOdd',allNineRateRangeOdd, ...
    'allNineRateRangeEven',allNineRateRangeEven, ...
    'allNineRateRangeShared',allNineRateRangeShared);
% Flat aliases keep commonly inspected diagnostics convenient in saved
% result files and mirror existing eCOCO scalar metadata conventions.
result.foldSpacingOdd = foldSpacingOdd;
result.foldSpacingEven = foldSpacingEven;
result.allNineRateRangeOdd = allNineRateRangeOdd;
result.allNineRateRangeEven = allNineRateRangeEven;
result.allNineRateRangeShared = allNineRateRangeShared;
result.rhoM = rhoM;
result.validNullWindow = success;
result.bestRateAllNineResolved = bestRateAllNineResolved;
result.resolutionWarningWindowCount = nnz( ...
    success & ~bestRateAllNineResolved);

result.windowStartIndex = starts;
result.windowEndIndex = ends;
result.windowPointCount = constantOrNaN(pointCount);
result.windowPointCountByWindow = pointCount;
result.requestedWindow = window;
result.actualWindowSpan = median(supportSpan);
result.actualWindowSpanByWindow = supportSpan;
result.windowObservedSpanByWindow = observedSpan;
result.stepSamples = step;
result.stepDepth = requestedStepDepth;
result.samplingInterval = inputInfo.medianSpacing;
result.inputPreprocessing = struct( ...
    'inputPointCount',inputInfo.inputPointCount, ...
    'finitePointCount',inputInfo.finitePointCount, ...
    'cleanPointCount',size(data,1), ...
    'duplicatePointCount',inputInfo.duplicatePointCount, ...
    'medianSpacing',inputInfo.medianSpacing, ...
    'fullRecordInterpolation',false, ...
    'splitBeforeInterpolation',true, ...
    'cleaningRule','finite rows; sorted depth; duplicate values averaged');
result.monteCarlo = struct( ...
    'nsimRequested',nsim, ...
    'nsimCompletedByWindow',nsimCompletedByWindow, ...
    'batchSizeRequested',options.BatchSize, ...
    'batchSizeByWindow',batchSizeByWindow, ...
    'seedByWindow',windowSeed, ...
    'plusOne',true, ...
    'jointNull',true, ...
    'nullUnit','one full sorted raw-order AR(1) process per window and realization');
result.nsimRequested = nsim;
result.nsimCompleted = nsim;
result.nsimCompletedByWindow = nsimCompletedByWindow;
result.pFloor = conditionalPFloor(nsim);
result.seed = seed;
result.red = red;
result.pad = pad;
result.maxFrequency = maxFrequency;
result.rateGlobalDefinition = [ ...
    'plus-one joint-null maximum over the complete sedimentation-rate ', ...
    'grid within each window; no correction across sliding windows'];
result.scoreDefinition = [ ...
    'pCOCO = consensus rho x abs(log10(consensus global p)); ', ...
    'no orbit-count weighting'];
result.localDefinition = [ ...
    'plus-one same-rate joint-null p from the identical full-pipeline ', ...
    'odd/even simulations; descriptive and uncorrected over rate'];
result.mapGlobalApplied = false;
result.batchSimulations = options.BatchSize;
result.algorithmVersion = 'Interleaved-eCOCO9B-windowed-prototype-v3';
result.metadata = struct( ...
    'algorithm','interleaved Method-B coherent-nine eCOCO prototype', ...
    'experimental',true, ...
    'targetModel','four-group-coherent-nine', ...
    'amplitudeMethod','four-group union-band area with 4-by-4 leakage NNLS', ...
    'inputPointCount',inputInfo.inputPointCount, ...
    'finitePointCount',inputInfo.finitePointCount, ...
    'cleanPointCount',size(data,1), ...
    'duplicatePointCount',inputInfo.duplicatePointCount, ...
    'inputMedianSpacing',inputInfo.medianSpacing, ...
    'windowMode',windowMode, ...
    'dtLegacySamplingInterval',dt, ...
    'windowRequested',window, ...
    'windowSupportSpanMedian',median(supportSpan), ...
    'windowSupportSpanRange',[min(supportSpan),max(supportSpan)], ...
    'windowObservedSpanMedian',median(finiteObservedSpan), ...
    'windowObservedSpanRange',[min(finiteObservedSpan),max(finiteObservedSpan)], ...
    'windowPointCountMedian',median(finitePointCount), ...
    'windowPointCountRange',[min(finitePointCount),max(finitePointCount)], ...
    'windowStepLegacySamples',step, ...
    'windowStepRequestedDepth',requestedStepDepth, ...
    'windowCenterStepMedian',centerStepMedian, ...
    'windowCenterStepRange',centerStepRange, ...
    'physicalWindowCandidateCount',physicalWindowInfo.candidateCount, ...
    'physicalWindowOddCandidateCount',physicalWindowInfo.oddCandidateCount, ...
    'physicalWindowEmptyCandidateCount',physicalWindowInfo.emptyCandidateCount, ...
    'completeWindowRule',completeWindowRule, ...
    'minimumRawPointsPerFold',8, ...
    'parityRule','global parity after finite-row cleaning, sorting, and duplicate averaging', ...
    'interpolationRule','split first; linearly regularize each fold at its own median spacing', ...
    'detrendRule','separate linear detrend inside each odd/even fold', ...
    'trainingRateRule','maximum Method-B adaptive correlation over complete SR grid', ...
    'partialOrbitFallback',[ ...
        'fit only resolved orbital groups with the active leakage ', ...
        'submatrix and fix unresolved group weights to zero'], ...
    'partialOrbitTrainingWindowCount',degradedWindowCount, ...
    'validationRateRule','reciprocal frozen four-group weights over complete SR grid', ...
    'consensusRule','same-rate minimum of Odd-to-Even and Even-to-Odd correlation', ...
    'strictRule','larger directional p at the same consensus curve', ...
    'srGlobalRule','plus-one joint-null maximum over complete SR grid within each window', ...
    'ridgeScoreRule',[ ...
        'pCOCO = consensus rho x abs(log10(consensus global p)); ', ...
        'orbit count is diagnostic only'], ...
    'windowGlobalCorrection',false, ...
    'jointNull',true, ...
    'nullDependencyRule',[ ...
        'one stationary Gaussian AR(1) realization on the complete sorted ', ...
        'window order, followed by the identical global-parity split, ', ...
        'fold interpolation, training, and reciprocal validation'], ...
    'seedRule',[ ...
        'deterministic seed derived from parent seed and global window ', ...
        'start/end indices; identical observation sets reuse a seed'], ...
    'method',method, ...
    'red',red, ...
    'pad',pad, ...
    'maximumFrequency',maxFrequency, ...
    'seed',seed);

reportProgress(options.ProgressFcn,1,sprintf( ...
    'Interleaved eCOCO complete: %d of %d windows resolved.', ...
    nnz(success),nWindows));

    function reportTotalMonteCarloWork(currentWindow,innerFraction)
        innerFraction = min(max(double(innerFraction),0),1);
        totalFraction = ((currentWindow-1)+innerFraction)/nWindows;
        percent = min(100,floor(100*totalFraction+1e-10));
        if percent <= lastReportedPercent
            return
        end
        lastReportedPercent = percent;
        reportProgress(options.ProgressFcn,totalFraction,sprintf( ...
            'Interleaved eCOCO Monte Carlo work: %d%%',percent));
    end
end

function [data,orbit9,srGrid,method,nWindow,info] = validateInputs( ...
        data,orbit9,window,dt,step,red,pad,srGrid,nsim,method, ...
        maxFrequency,seed,windowMode)
validateattributes(data,{'numeric'}, ...
    {'2d','real','ncols',2,'nonempty'},mfilename,'data',1);
validateattributes(orbit9,{'numeric'}, ...
    {'vector','real','finite','positive','numel',9},mfilename,'orbit9',2);
validateattributes(window,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'window',3);
validateattributes(dt,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'dt',4);
validateattributes(step,{'numeric'}, ...
    {'scalar','real','finite','positive','integer'},mfilename,'step',5);
validateattributes(red,{'numeric'}, ...
    {'scalar','real','finite','integer','>=',0,'<=',3},mfilename,'red',6);
validateattributes(pad,{'numeric'}, ...
    {'scalar','real','finite','integer','nonnegative'},mfilename,'pad',7);
validateattributes(srGrid,{'numeric'}, ...
    {'vector','real','finite','positive','nonempty'},mfilename,'srGrid',8);
validateattributes(nsim,{'numeric'}, ...
    {'scalar','real','finite','integer','nonnegative','<=',1e6}, ...
    mfilename,'nsim',9);
method = validatestring(method,{'Pearson','Spearman'},mfilename,'method',10);
validateattributes(maxFrequency,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'maxFrequency',11);
validateattributes(seed,{'numeric'}, ...
    {'scalar','real','finite','integer','nonnegative','<=',2^32-1}, ...
    mfilename,'seed',12);

orbit9 = orbit9(:);
srGrid = srGrid(:);
if numel(unique(orbit9)) ~= 9
    error('ecocoInterleavedCore:DuplicateOrbitPeriods', ...
        'ORBIT9 must contain nine distinct periods.');
end
if maxFrequency < max(1./orbit9)-64*eps(max(1,max(1./orbit9)))
    error('ecocoInterleavedCore:MaximumFrequencyExcludesOrbit', ...
        'MAXFREQUENCY must include the highest nominal orbital frequency.');
end
if any(diff(srGrid) <= 0)
    error('ecocoInterleavedCore:InvalidRateGrid', ...
        'SRGRID must be strictly increasing.');
end
if numel(srGrid) > 10000
    error('ecocoInterleavedCore:RateGridTooLarge', ...
        'SRGRID may contain at most 10000 rates.');
end
if numel(srGrid) > 2
    spacing = diff(srGrid);
    tolerance = 256*eps(max(1,max(abs(srGrid))));
    if any(abs(spacing-median(spacing)) > tolerance)
        error('ecocoInterleavedCore:IrregularRateGrid', ...
            'SRGRID must have a constant step for INTERLEAVEDCVCOCO.');
    end
end

info.inputPointCount = size(data,1);
finiteRow = all(isfinite(data),2);
info.finitePointCount = nnz(finiteRow);
data = data(finiteRow,:);
if isempty(data)
    error('ecocoInterleavedCore:NoFiniteData', ...
        'DATA has no rows with finite depth and value.');
end
data = sortrows(data,1);
[uniqueDepth,~,group] = unique(data(:,1),'sorted');
meanValue = accumarray(group,data(:,2),[],@mean);
info.duplicatePointCount = size(data,1)-numel(uniqueDepth);
data = [uniqueDepth,meanValue];
if size(data,1) < 16
    error('ecocoInterleavedCore:InsufficientUniqueDepths', ...
        ['At least 16 unique depths are required so each interleaved ', ...
         'fold contains at least eight observations.']);
end
spacing = diff(data(:,1));
if any(spacing <= 0) || any(~isfinite(spacing))
    error('ecocoInterleavedCore:InvalidDepth', ...
        'Cleaned depths must be finite, distinct, and strictly increasing.');
end
info.medianSpacing = median(spacing);

if strcmp(windowMode,'physical-depth')
    nWindow = NaN;
    depthSpan = data(end,1)-data(1,1);
    tolerance = cocoSamplingTolerance(data(:,1),window);
    if window > depthSpan+tolerance
        error('ecocoInterleavedCore:WindowLongerThanData', ...
            ['The requested physical-depth WINDOW exceeds the cleaned ', ...
             'record span.']);
    end
else
    % The legacy desired point count is WINDOW/DT+1.  Choose its nearest
    % even value so Odd and Even folds are exactly balanced; ties round up.
    nWindow = 2*round((window/dt+1)/2);
    if nWindow < 16
        error('ecocoInterleavedCore:WindowTooShort', ...
            'WINDOW must contain at least 16 points (eight per fold).');
    end
    if nWindow > size(data,1)
        error('ecocoInterleavedCore:WindowLongerThanData', ...
            'WINDOW is longer than the cleaned DATA record.');
    end
end
end

function [starts,ends,centers,lower,upper,pointCount,observedCenter, ...
        observedSpan,info] = buildPhysicalDepthWindows(depth,window,stepDepth)
recordStart = depth(1);
recordEnd = depth(end);
tolerance = cocoSamplingTolerance(depth,min(window,stepDepth));
firstCenter = recordStart+window/2;
lastCenter = recordEnd-window/2;
availableCenterSpan = max(0,lastCenter-firstCenter);
nWindows = floor((availableCenterSpan+tolerance)/stepDepth)+1;
if nWindows > 10000
    error('ecocoInterleavedCore:TooManyPhysicalWindows', ...
        ['The requested physical-depth step would create %d windows; ', ...
         'the maximum is 10000.'],nWindows);
end
centers = firstCenter+(0:nWindows-1)'*stepDepth;
lower = centers-window/2;
upper = centers+window/2;

% Snap only roundoff-scale endpoint excursions.  The center lattice itself
% remains the exact requested STEPDEPTH sequence.
lower(abs(lower-recordStart) <= tolerance) = recordStart;
upper(abs(upper-recordEnd) <= tolerance) = recordEnd;

starts = nan(nWindows,1);
ends = nan(nWindows,1);
pointCount = zeros(nWindows,1);
observedCenter = nan(nWindows,1);
observedSpan = nan(nWindows,1);
leftIndex = 1;
rightIndex = 0;
for windowIndex = 1:nWindows
    while leftIndex <= numel(depth) && ...
            depth(leftIndex) < lower(windowIndex)-tolerance
        leftIndex = leftIndex+1;
    end
    rightIndex = max(rightIndex,leftIndex-1);
    while rightIndex < numel(depth) && ...
            depth(rightIndex+1) <= upper(windowIndex)+tolerance
        rightIndex = rightIndex+1;
    end
    if leftIndex <= numel(depth) && leftIndex <= rightIndex && ...
            depth(leftIndex) <= upper(windowIndex)+tolerance
        starts(windowIndex) = leftIndex;
        ends(windowIndex) = rightIndex;
        pointCount(windowIndex) = rightIndex-leftIndex+1;
        observedCenter(windowIndex) = ...
            0.5*(depth(leftIndex)+depth(rightIndex));
        observedSpan(windowIndex) = depth(rightIndex)-depth(leftIndex);
    end
end
info = struct( ...
    'candidateCount',nWindows, ...
    'oddCandidateCount',nnz(rem(pointCount,2) == 1), ...
    'emptyCandidateCount',nnz(pointCount == 0));
end

function seedOut = deriveWindowSeed(parentSeed,startIndex,endIndex,ordinal)
% Physical windows can share a start row while ending on different rows.
% Hash both bounds; use the ordinal only for an empty/unsupported window.
if isfinite(startIndex) && isfinite(endIndex)
    identity = 104729*double(startIndex-1)+130363*double(endIndex-1);
else
    identity = 32452843*double(ordinal-1);
end
seedOut = mod(double(parentSeed)+identity,2^32);
end

function value = constantOrNaN(values)
values = values(isfinite(values));
if isempty(values) || any(values ~= values(1))
    value = NaN;
else
    value = values(1);
end
end

function tf = isUnresolvableWindow(exception)
tf = any(strcmp(exception.identifier,{ ...
    'cvcoco:NoValidSedimentationRate', ...
    'cvcoco:NoAllNineTrainingRate'}));
end

function validateWindowResult(windowResult,srGrid,nRate)
required = {'validateAtoB','validateBtoA','consensus', ...
    'activeOrbitCountAtoB','activeOrbitCountBtoA', ...
    'samplingIntervalA','samplingIntervalB','allNineRateRangeA', ...
    'allNineRateRangeB','allNineRateRangeShared','rhoM','config'};
for k = 1:numel(required)
    if ~isfield(windowResult,required{k})
        error('ecocoInterleavedCore:WindowSchemaMismatch', ...
            'INTERLEAVEDCVCOCO result is missing field %s.',required{k});
    end
end
consensusFields = {'curve','pGlobalCurve','pLocalCurve', ...
    'bestRate','bestIndex','bestCorrelation', ...
    'activeOrbitCountCurve','pDirectionalMaxCurve'};
for k = 1:numel(consensusFields)
    if ~isfield(windowResult.consensus,consensusFields{k})
        error('ecocoInterleavedCore:WindowSchemaMismatch', ...
            'INTERLEAVEDCVCOCO consensus is missing field %s.', ...
            consensusFields{k});
    end
end
if numel(windowResult.srGrid) ~= nRate || ...
        any(abs(windowResult.srGrid(:)-srGrid) > ...
        256*eps(max(1,max(abs(srGrid)))))
    error('ecocoInterleavedCore:RateGridChanged', ...
        'A delegated window returned a different sedimentation-rate grid.');
end
end

function value = columnVector(value,nExpected,label)
value = value(:);
if numel(value) ~= nExpected
    error('ecocoInterleavedCore:WindowSchemaMismatch', ...
        '%s has %d values; expected %d.',label,numel(value),nExpected);
end
end

function [bestRate,bestIndex,bestCorrelation] = ...
        directionMaximum(direction,srGrid)
bestRate = direction.bestRate;
bestIndex = direction.bestIndex;
if isfield(direction,'bestCorrelation')
    bestCorrelation = direction.bestCorrelation;
elseif isfield(direction,'score')
    bestCorrelation = direction.score;
elseif isfinite(bestIndex) && bestIndex >= 1 && bestIndex <= numel(srGrid)
    bestCorrelation = direction.curve(bestIndex);
else
    bestCorrelation = NaN;
end
end

function value = maxPairStrict(a,b)
value = max(a,b);
value(~isfinite(a) | ~isfinite(b)) = NaN;
end

function out = makeDirectionResult(rho,pGlobal,pLocal,bestRate,bestIndex, ...
        bestCorrelation,nOrbit,supported)
out = struct;
out.rho = rho;
out.pGlobal = pGlobal;
out.pLocal = pLocal;
out.bestRate = bestRate;
out.bestIndex = bestIndex;
out.bestCorrelation = bestCorrelation;
out.bestGlobalP = valuesAtIndices(pGlobal,bestIndex);
out.activeOrbitCount = nOrbit;
out.nOrbit = nOrbit;
out.supported = supported;
out.pCOCO = pcocoValue(rho,pGlobal);
out.score = out.pCOCO;
end

function values = valuesAtIndices(map,index)
values = nan(numel(index),1);
for k = 1:numel(index)
    if isfinite(index(k)) && index(k) == fix(index(k)) && ...
            index(k) >= 1 && index(k) <= size(map,1)
        values(k) = map(index(k),k);
    end
end
end

function value = pcocoValue(rho,p)
pSafe = p;
pSafe(~isfinite(pSafe) | pSafe <= 0) = NaN;
pSafe(pSafe > 1) = 1;
value = rho.*abs(log10(pSafe));
end

function value = conditionalPFloor(nsim)
if nsim > 0
    value = 1/(nsim+1);
else
    value = NaN;
end
end

function reportProgress(callback,fraction,message)
if isempty(callback)
    return
end
randomState = rng;
restoreRandomState = onCleanup(@()rng(randomState));
try
    callback(fraction,message);
catch exception
    warning('ecocoInterleavedCore:ProgressCallbackFailed', ...
        'Progress callback failed: %s',exception.message);
end
clear restoreRandomState
end
