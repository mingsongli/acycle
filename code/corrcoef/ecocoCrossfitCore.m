function result = ecocoCrossfitCore(data,orbit9,window,dt,step,red,pad, ...
        srGrid,nsim,method,maxFrequency,seed,anchorFraction,varargin)
%ECOCOCROSSFITCORE Cross-fitted evolutionary COCO numerical engine.
%
% RESULT = ECOCOCROSSFITCORE(DATA,ORBIT9,WINDOW,DT,STEP,RED,PAD,
% SRGRID,NSIM,METHOD,MAXFREQUENCY,SEED,ANCHORFRACTION) evaluates complete
% WINDOW-length validation records.  Method-B four-group amplitudes are
% trained at regularly spaced anchor windows, using the complete
% sedimentation-rate grid.  Every validation window is evaluated twice:
% with the nearest strictly non-overlapping lower-depth anchor (forward)
% and the nearest strictly non-overlapping higher-depth anchor (backward).
% The bidirectional consensus at a common rate is the smaller of the two
% correlations.  At record edges, where only one direction is available,
% the consensus falls back to that direction and SUPPORTDIRECTION records
% the one-sided support explicitly.
%
% STEP is an integer number of samples.  ANCHORFRACTION defaults to 0.5 and
% determines the anchor-start spacing relative to the complete window
% physical window span.  Training and validation windows never share a sample.
%
% Monte Carlo simulations repeat the complete anchor rate search and
% amplitude fitting.  Forward and backward validation use the same null
% realization of the validation window.  SR-global p-values use, for each
% window and simulation, the maximum statistic over the complete tested
% sedimentation-rate grid.  They do not correct a search across multiple
% sliding windows. When ComputeLocalP is enabled, the identical null
% realizations also provide same-rate local p-values for each direction
% and for the supported bidirectional consensus.
%
% Name-value options:
%   'BatchSize'       maximum Monte Carlo simulations per streamed batch
%                     (default 20; an internal memory bound may reduce it)
%   'ComputeLocalP'   also accumulate same-rate local p-values (default false)
%   'ProgressFcn'     function handle called as FCN(fraction,message)
%   'MemoryBudgetMiB' null-spectrum batch memory budget (default 256)

if nargin < 13 || isempty(anchorFraction)
    anchorFraction = 0.5;
end

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'BatchSize',20,@(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x >= 1 && x == fix(x));
addParameter(parser,'ComputeLocalP',false,@(x) islogical(x) && isscalar(x));
addParameter(parser,'ProgressFcn',[],@(x) isempty(x) || ...
    isa(x,'function_handle'));
addParameter(parser,'MemoryBudgetMiB',256,@(x) isnumeric(x) && ...
    isscalar(x) && isreal(x) && isfinite(x) && x >= 16);
parse(parser,varargin{:});
options = parser.Results;

[data,orbit9,srGrid,method,nWindow] = validateInputs( ...
    data,orbit9,window,dt,step,red,pad,srGrid,nsim,method, ...
    maxFrequency,seed,anchorFraction);

nData = size(data,1);
lastStart = nData-nWindow+1;
validationStarts = endpointInclusiveStarts(lastStart,step)';
anchorStep = max(1,round(anchorFraction*(nWindow-1)));
anchorStarts = endpointInclusiveStarts(lastStart,anchorStep)';
validationEnds = validationStarts+nWindow-1;
anchorEnds = anchorStarts+nWindow-1;
nWindowPosition = numel(validationStarts);
nAnchor = numel(anchorStarts);
nRate = numel(srGrid);

forwardAnchorIndex = nan(nWindowPosition,1);
backwardAnchorIndex = nan(nWindowPosition,1);
for j = 1:nWindowPosition
    candidate = find(anchorEnds < validationStarts(j),1,'last');
    if ~isempty(candidate)
        forwardAnchorIndex(j) = candidate;
    end
    candidate = find(anchorStarts > validationEnds(j),1,'first');
    if ~isempty(candidate)
        backwardAnchorIndex(j) = candidate;
    end
end

% Build every unique complete interval once.  Anchor windows commonly
% coincide with validation windows; this cache prevents duplicate spectra
% and gives exact identity when an interval serves both roles elsewhere.
blockStarts = unique([validationStarts;anchorStarts],'sorted');
blockEnds = blockStarts+nWindow-1;
nBlock = numel(blockStarts);
[~,validationBlockIndex] = ismember(validationStarts,blockStarts);
[~,anchorBlockIndex] = ismember(anchorStarts,blockStarts);
blockValues = zeros(nWindow,nBlock);
for k = 1:nBlock
    blockValues(:,k) = data(blockStarts(k):blockEnds(k),2);
end

groups = defineOrbitGroups(orbit9);
estimatedGeometryBytes = 8*22*nRate*(floor(pad/2)+1);
geometryMemoryBudget = 512*1024^2;
if estimatedGeometryBytes > geometryMemoryBudget
    error('ecocoCrossfitCore:GeometryRequestTooLarge', ...
        ['PAD and SRGRID require approximately %.3g MiB of reusable ', ...
         'coherent-nine geometry (safety limit %.3g MiB).'], ...
        estimatedGeometryBytes/1024^2,geometryMemoryBudget/1024^2);
end
geom = prepareGeometry(nWindow,dt,orbit9,srGrid,pad,groups,maxFrequency);
if ~any(geom.trainingRateMask)
    error('ecocoCrossfitCore:NoTrainingRate', ...
        ['No tested sedimentation rate resolves all nine periods with ', ...
         'non-overlapping four-group bands and a well-conditioned leakage ', ...
         'matrix. Revise WINDOW, DT, PAD, or SRGRID.']);
end
if ~any(geom.validRateMask)
    error('ecocoCrossfitCore:NoValidationRate', ...
        'No tested sedimentation rate has usable validation geometry.');
end

reportProgress(options.ProgressFcn,0,sprintf( ...
    'Preparing %d Cross-fitted eCOCO sliding windows.',nWindowPosition));
[blockPower,frequency] = ecocoWindowSpectra(blockValues,dt,pad,red);
if size(blockPower,1) ~= numel(geom.frequency) || ...
        numel(frequency) ~= numel(geom.frequency) || ...
        max(abs(frequency(:)-geom.frequency)) > frequencyTolerance(geom.frequency)
    error('ecocoCrossfitCore:SpectrumGeometryMismatch', ...
        'Window spectra and the shared target geometry use different grids.');
end
[rhoBlock,stdBlock,validAr1Block] = ecocoEstimateAr1(blockValues);
rhoBlock = rhoBlock(:)';
stdBlock = stdBlock(:)';
validAr1Block = logical(validAr1Block(:)');
if numel(rhoBlock) ~= nBlock || numel(stdBlock) ~= nBlock || ...
        numel(validAr1Block) ~= nBlock || ...
        any(~isfinite(rhoBlock(validAr1Block))) || ...
        any(abs(rhoBlock(validAr1Block)) >= 1) || ...
        any(~isfinite(stdBlock(validAr1Block)) | stdBlock(validAr1Block) <= 0)
    error('ecocoCrossfitCore:InvalidAr1Summary', ...
        'The per-window AR(1) helper returned invalid rho or scale values.');
end

anchorPower = blockPower(:,anchorBlockIndex);
[anchorTrainCurve,anchorBestRate,anchorRawAmplitude] = ...
    trainFourGroup(anchorPower,geom,method,true);
anchorWeights = normalizeGroupAmplitudes(anchorRawAmplitude);
anchorValid = isfinite(anchorBestRate(:)) & ...
    all(isfinite(anchorWeights),1)' & validAr1Block(anchorBlockIndex)';

hasForward = isfinite(forwardAnchorIndex);
hasBackward = isfinite(backwardAnchorIndex);
for j = 1:nWindowPosition
    validValidation = validAr1Block(validationBlockIndex(j));
    if hasForward(j)
        hasForward(j) = validValidation && ...
            anchorValid(forwardAnchorIndex(j));
    end
    if hasBackward(j)
        hasBackward(j) = validValidation && ...
            anchorValid(backwardAnchorIndex(j));
    end
end

validationPower = blockPower(:,validationBlockIndex);
rhoForward = nan(nRate,nWindowPosition);
rhoBackward = nan(nRate,nWindowPosition);
if any(hasForward)
    idxWindow = find(hasForward);
    idxAnchor = forwardAnchorIndex(idxWindow);
    rhoForward(:,idxWindow) = validateFrozen( ...
        validationPower(:,idxWindow),geom,anchorWeights(:,idxAnchor),method);
end
if any(hasBackward)
    idxWindow = find(hasBackward);
    idxAnchor = backwardAnchorIndex(idxWindow);
    rhoBackward(:,idxWindow) = validateFrozen( ...
        validationPower(:,idxWindow),geom,anchorWeights(:,idxAnchor),method);
end
[rhoConsensus,supportDirection] = combineDirectionalCurves( ...
    rhoForward,rhoBackward,hasForward,hasBackward);
hasBoth = hasForward & hasBackward;
rhoStrictConsensus = rhoConsensus;
rhoStrictConsensus(:,~hasBoth) = NaN;

[bestRateForward,bestIndexForward,bestScoreForward] = ...
    curveMaximum(rhoForward,srGrid);
[bestRateBackward,bestIndexBackward,bestScoreBackward] = ...
    curveMaximum(rhoBackward,srGrid);
[bestRateConsensus,bestIndexConsensus,bestScoreConsensus] = ...
    curveMaximum(rhoConsensus,srGrid);
[bestRateStrict,bestIndexStrict,bestScoreStrict] = ...
    curveMaximum(rhoStrictConsensus,srGrid);

activeOrbitForward = participationCount( ...
    geom,anchorWeights,forwardAnchorIndex,hasForward);
activeOrbitBackward = participationCount( ...
    geom,anchorWeights,backwardAnchorIndex,hasBackward);
activeOrbitConsensus = consensusParticipation(geom,anchorWeights, ...
    forwardAnchorIndex,backwardAnchorIndex,hasForward,hasBackward,false);
activeOrbitStrict = consensusParticipation(geom,anchorWeights, ...
    forwardAnchorIndex,backwardAnchorIndex,hasForward,hasBackward,true);

countGlobalForward = zeros(nRate,nWindowPosition,'uint32');
countGlobalBackward = zeros(nRate,nWindowPosition,'uint32');
countGlobalConsensus = zeros(nRate,nWindowPosition,'uint32');
countLocalForward = zeros(nRate,nWindowPosition,'uint32');
countLocalBackward = zeros(nRate,nWindowPosition,'uint32');
countLocalConsensus = zeros(nRate,nWindowPosition,'uint32');
nsimCompleted = 0;
actualBatchSize = 0;
lastReportedPercent = 0;

if nsim > 0
    previousRng = rng;
    restoreRng = onCleanup(@()rng(previousRng));
    rng(seed,'twister');

    nf = size(blockPower,1);
    memoryBudget = options.MemoryBudgetMiB*1024^2;
    % One time-domain matrix and one spectrum matrix dominate.  The factor
    % of two leaves room for detrending, target power, and MATLAB copies.
    bytesPerSimulation = 16*nBlock*(nWindow+nf);
    memoryBatch = max(1,floor(memoryBudget/max(1,bytesPerSimulation)));
    actualBatchSize = min([options.BatchSize,nsim,memoryBatch]);

    for firstSimulation = 1:actualBatchSize:nsim
        lastSimulation = min(firstSimulation+actualBatchSize-1,nsim);
        nBatch = lastSimulation-firstSimulation+1;

        % Simulation-major ordering makes the random assignment invariant
        % to streamed batch size: [all blocks for sim 1, all blocks for sim 2].
        safeRho = rhoBlock;
        safeStd = stdBlock;
        safeRho(~validAr1Block) = 0;
        safeStd(~validAr1Block) = 1;
        rhoColumns = repmat(safeRho,1,nBatch);
        stdColumns = repmat(safeStd,1,nBatch);
        nullValues = randn(nWindow,nBlock*nBatch);
        nullValues(1,:) = stdColumns.*nullValues(1,:);
        innovationScale = stdColumns.*sqrt(max(0,1-rhoColumns.^2));
        for row = 2:nWindow
            nullValues(row,:) = rhoColumns.*nullValues(row-1,:) + ...
                innovationScale.*nullValues(row,:);
        end
        [nullPower,nullFrequency] = ecocoWindowSpectra( ...
            nullValues,dt,pad,red);
        if numel(nullFrequency) ~= numel(frequency) || ...
                max(abs(nullFrequency(:)-frequency(:))) > ...
                frequencyTolerance(frequency)
            error('ecocoCrossfitCore:MonteCarloFrequencyChanged', ...
                'Monte Carlo and observed spectrum grids differ.');
        end

        anchorColumns = anchorBlockIndex(:) + ...
            (0:nBatch-1).*nBlock;
        [~,nullAnchorBestRate,nullAnchorRaw] = trainFourGroup( ...
            nullPower(:,anchorColumns(:)),geom,method,false);
        nullAnchorWeights = normalizeGroupAmplitudes(nullAnchorRaw);
        if any(~isfinite(nullAnchorBestRate)) || ...
                any(~isfinite(nullAnchorWeights),'all')
            error('ecocoCrossfitCore:InvalidMonteCarloTraining', ...
                ['A null anchor failed the complete Method-B training ', ...
                 'pipeline. No Monte Carlo realizations were discarded.']);
        end
        nullAnchorWeights = reshape(nullAnchorWeights,4,nAnchor,nBatch);

        for j = 1:nWindowPosition
            if ~(hasForward(j) || hasBackward(j))
                lastReportedPercent = reportWindowMonteCarloWork( ...
                    options.ProgressFcn,firstSimulation,lastSimulation, ...
                    nsim,nBatch,j,nWindowPosition,lastReportedPercent);
                continue
            end
            validationColumns = validationBlockIndex(j) + ...
                (0:nBatch-1).*nBlock;
            nullValidationPower = nullPower(:,validationColumns);
            nullForward = nan(nRate,nBatch);
            nullBackward = nan(nRate,nBatch);
            if hasForward(j)
                weights = reshape(nullAnchorWeights(:, ...
                    forwardAnchorIndex(j),:),4,nBatch);
                nullForward = validateFrozen( ...
                    nullValidationPower,geom,weights,method);
                countGlobalForward(:,j) = countGlobalForward(:,j) + ...
                    uint32(globalExceedance(nullForward,rhoForward(:,j), ...
                    geom.validRateMask));
                if options.ComputeLocalP
                    countLocalForward(:,j) = countLocalForward(:,j) + ...
                        uint32(localExceedance(nullForward,rhoForward(:,j)));
                end
            end
            if hasBackward(j)
                weights = reshape(nullAnchorWeights(:, ...
                    backwardAnchorIndex(j),:),4,nBatch);
                nullBackward = validateFrozen( ...
                    nullValidationPower,geom,weights,method);
                countGlobalBackward(:,j) = countGlobalBackward(:,j) + ...
                    uint32(globalExceedance(nullBackward,rhoBackward(:,j), ...
                    geom.validRateMask));
                if options.ComputeLocalP
                    countLocalBackward(:,j) = countLocalBackward(:,j) + ...
                        uint32(localExceedance(nullBackward,rhoBackward(:,j)));
                end
            end
            nullConsensus = combineOneNull( ...
                nullForward,nullBackward,hasForward(j),hasBackward(j));
            countGlobalConsensus(:,j) = countGlobalConsensus(:,j) + ...
                uint32(globalExceedance(nullConsensus,rhoConsensus(:,j), ...
                geom.validRateMask));
            if options.ComputeLocalP
                countLocalConsensus(:,j) = countLocalConsensus(:,j) + ...
                    uint32(localExceedance(nullConsensus,rhoConsensus(:,j)));
            end
            lastReportedPercent = reportWindowMonteCarloWork( ...
                options.ProgressFcn,firstSimulation,lastSimulation, ...
                nsim,nBatch,j,nWindowPosition,lastReportedPercent);
        end

        nsimCompleted = lastSimulation;
    end
end

pGlobalForward = pFromCounts( ...
    countGlobalForward,rhoForward,nsimCompleted);
pGlobalBackward = pFromCounts( ...
    countGlobalBackward,rhoBackward,nsimCompleted);
pGlobalConsensus = pFromCounts( ...
    countGlobalConsensus,rhoConsensus,nsimCompleted);
pGlobalStrict = pGlobalConsensus;
pGlobalStrict(:,~hasBoth) = NaN;
if options.ComputeLocalP
    pLocalForward = pFromCounts( ...
        countLocalForward,rhoForward,nsimCompleted);
    pLocalBackward = pFromCounts( ...
        countLocalBackward,rhoBackward,nsimCompleted);
    pLocalConsensus = pFromCounts( ...
        countLocalConsensus,rhoConsensus,nsimCompleted);
    pLocalStrict = pLocalConsensus;
    pLocalStrict(:,~hasBoth) = NaN;
else
    pLocalForward = nan(size(rhoForward));
    pLocalBackward = nan(size(rhoBackward));
    pLocalConsensus = nan(size(rhoConsensus));
    pLocalStrict = nan(size(rhoStrictConsensus));
end

pDirectionalMax = combineDirectionalP(pGlobalForward,pGlobalBackward, ...
    hasForward,hasBackward,true);
pBoth = combineDirectionalP(pGlobalForward,pGlobalBackward, ...
    hasForward,hasBackward,false);

windowCenterDepth = 0.5*(data(validationStarts,1) + ...
    data(validationEnds,1));
anchorCenterDepth = 0.5*(data(anchorStarts,1) + data(anchorEnds,1));
blockCenterDepth = 0.5*(data(blockStarts,1) + data(blockEnds,1));

result = struct;
result.name = 'Cross-fitted eCOCO';
result.version = 1;
result.method = 'crossfit';
result.targetMode = 'four-group-coherent-nine';
result.srGrid = srGrid;
result.depth = windowCenterDepth;
result.supportDirection = supportDirection;
result.forward = makeDirectionResult(rhoForward,pGlobalForward, ...
    pLocalForward,bestRateForward,bestIndexForward,bestScoreForward, ...
    forwardAnchorIndex,hasForward,activeOrbitForward);
result.backward = makeDirectionResult(rhoBackward,pGlobalBackward, ...
    pLocalBackward,bestRateBackward,bestIndexBackward,bestScoreBackward, ...
    backwardAnchorIndex,hasBackward,activeOrbitBackward);
result.consensus = struct( ...
    'rho',rhoConsensus, ...
    'pGlobal',pGlobalConsensus, ...
    'pLocal',pLocalConsensus, ...
    'pDirectionalMax',pDirectionalMax, ...
    'pBoth',pBoth, ...
    'bestRate',bestRateConsensus, ...
    'bestIndex',bestIndexConsensus, ...
    'bestCorrelation',bestScoreConsensus, ...
    'bestGlobalP',valuesAtIndices(pGlobalConsensus,bestIndexConsensus), ...
    'bestDirectionalMaxP',valuesAtIndices( ...
        pDirectionalMax,bestIndexConsensus), ...
    'activeOrbitCount',activeOrbitConsensus, ...
    'supportDirection',{supportDirection});
result.strictConsensus = struct( ...
    'rho',rhoStrictConsensus, ...
    'pGlobal',pGlobalStrict, ...
    'pLocal',pLocalStrict, ...
    'pDirectionalMax',pBoth, ...
    'bestRate',bestRateStrict, ...
    'bestIndex',bestIndexStrict, ...
    'bestCorrelation',bestScoreStrict, ...
    'bestGlobalP',valuesAtIndices(pGlobalStrict,bestIndexStrict), ...
    'bestDirectionalMaxP',valuesAtIndices(pBoth,bestIndexStrict), ...
    'activeOrbitCount',activeOrbitStrict, ...
    'supported',hasBoth);

% Root fields intentionally use the supported consensus: a same-rate
% bidirectional minimum in the interior and an explicitly labelled
% one-direction fallback at the edges.  STRICTCONSENSUS remains available
% for inference that requires both independent flanking anchors.
result.rho = rhoConsensus;
% PLOCAL is the same-rate consensus Monte Carlo result. PParametric remains
% NaN because an analytic correlation p-value is not valid for the trained
% cross-fitted target.
result.pLocal = pLocalConsensus;
result.pParametric = nan(size(rhoConsensus));
result.pGlobal = pGlobalConsensus;
result.nOrbit = activeOrbitConsensus;
result.pCOCO = pcocoValue(result.rho,result.pGlobal);
result.score = result.pCOCO.*result.nOrbit./numel(orbit9);
result.forward = attachScoreFields(result.forward,numel(orbit9));
result.backward = attachScoreFields(result.backward,numel(orbit9));
result.consensus = attachScoreFields(result.consensus,numel(orbit9));
result.strictConsensus = attachScoreFields( ...
    result.strictConsensus,numel(orbit9));
result.windows = struct( ...
    'startIndex',validationStarts, ...
    'endIndex',validationEnds, ...
    'centerDepth',windowCenterDepth, ...
    'blockIndex',validationBlockIndex, ...
    'forwardAnchorIndex',forwardAnchorIndex, ...
    'backwardAnchorIndex',backwardAnchorIndex, ...
    'hasForward',hasForward, ...
    'hasBackward',hasBackward, ...
    'supportDirection',{supportDirection});
result.anchors = struct( ...
    'startIndex',anchorStarts, ...
    'endIndex',anchorEnds, ...
    'centerDepth',anchorCenterDepth, ...
    'blockIndex',anchorBlockIndex, ...
    'trainCurve',anchorTrainCurve, ...
    'bestRate',anchorBestRate(:), ...
    'bestCorrelation',valuesAtRates( ...
        anchorTrainCurve,anchorBestRate,srGrid), ...
    'groupAmplitudes',anchorRawAmplitude, ...
    'groupWeights',anchorWeights, ...
    'valid',anchorValid, ...
    'rhoM',rhoBlock(anchorBlockIndex)', ...
    'dataStd',stdBlock(anchorBlockIndex)');
result.weights = anchorWeights;
result.rhoM = rhoBlock(validationBlockIndex)';
result.validNullWindow = validAr1Block(validationBlockIndex)';
result.ar1 = struct( ...
    'blocks',rhoBlock(:), ...
    'validation',rhoBlock(validationBlockIndex)', ...
    'anchors',rhoBlock(anchorBlockIndex)', ...
    'dataStdBlocks',stdBlock(:));
result.blocks = struct( ...
    'startIndex',blockStarts, ...
    'endIndex',blockEnds, ...
    'centerDepth',blockCenterDepth, ...
    'rhoM',rhoBlock(:), ...
    'dataStd',stdBlock(:));
result.anchor = struct( ...
    'fractionRequested',anchorFraction, ...
    'fractionActual',anchorStep/(nWindow-1), ...
    'stepSamples',anchorStep, ...
    'count',nAnchor, ...
    'nonOverlapRule','strictly no shared sample', ...
    'edgeRule','supported one-direction fallback; strict consensus separate');
result.anchorFraction = anchorFraction;
result.windowStartIndex = validationStarts;
result.windowEndIndex = validationEnds;
result.windowPointCount = nWindow;
result.requestedWindow = window;
result.actualWindowSpan = (nWindow-1)*dt;
result.stepSamples = step;
result.stepDepth = step*dt;
result.geometry = struct( ...
    'validRateMask',geom.validRateMask, ...
    'trainingRateMask',geom.trainingRateMask, ...
    'resolvedOrbitMask',geom.resolvedOrbitMask, ...
    'orbitCount',geom.orbitCount, ...
    'groupLeakageRcond',geom.groupLeakageRcond, ...
    'crossGroupBandOverlap',geom.crossGroupBandOverlap, ...
    'groupIndex',geom.groupIndex, ...
    'frequency',geom.frequency, ...
    'rayleigh',geom.rayleigh, ...
    'nyquist',geom.nyquist);
result.monteCarlo = struct( ...
    'nsimRequested',nsim, ...
    'nsimCompleted',nsimCompleted, ...
    'batchSize',actualBatchSize, ...
    'plusOne',true, ...
    'exceedanceGlobalForward',countGlobalForward, ...
    'exceedanceGlobalBackward',countGlobalBackward, ...
    'exceedanceGlobalConsensus',countGlobalConsensus, ...
    'exceedanceLocalForward',countLocalForward, ...
    'exceedanceLocalBackward',countLocalBackward, ...
    'exceedanceLocalConsensus',countLocalConsensus);
result.nsimRequested = nsim;
result.nsimCompleted = nsimCompleted;
result.pFloor = conditionalPFloor(nsim);
result.seed = seed;
result.red = red;
result.pad = pad;
result.maxFrequency = maxFrequency;
result.rateGlobalDefinition = ...
    'plus-one null maximum over the complete SR grid within each window';
result.localDefinition = [ ...
    'plus-one same-rate Monte Carlo p from the identical cross-fitted ', ...
    'null realizations used for SR-global p'];
result.mapGlobalApplied = false;
result.batchSimulations = actualBatchSize;
result.algorithmVersion = 'Crossfit-eCOCO9B-full-grid-local-p-v2';
result.metadata = struct( ...
    'algorithm','cross-fitted Method-B coherent-nine eCOCO', ...
    'targetModel','four-group-coherent-nine', ...
    'amplitudeMethod', ...
        'four-group union-band area with 4-by-4 leakage NNLS', ...
    'windowRequested',window, ...
    'windowPointCount',nWindow, ...
    'windowActualSpan',(nWindow-1)*dt, ...
    'windowStepSamples',step, ...
    'anchorFractionRequested',anchorFraction, ...
    'anchorStepSamples',anchorStep, ...
    'anchorFractionActual',anchorStep/(nWindow-1), ...
    'nonOverlapRule','anchorEnd < validationStart or anchorStart > validationEnd', ...
    'trainingRateRule','maximum adaptive correlation over complete SR grid', ...
    'validationRateRule','frozen four-group weights over complete SR grid', ...
    'consensusRule','same-rate minimum when bidirectional; available direction at edges', ...
    'srGlobalRule','plus-one null maximum over complete SR grid within each window', ...
    'windowGlobalCorrection',false, ...
    'nullDependencyRule', ...
        'unique intervals shared exactly; distinct overlapping intervals use independent local AR(1) nulls', ...
    'method',method, ...
    'red',red, ...
    'pad',pad, ...
    'dt',dt, ...
    'maximumFrequency',maxFrequency, ...
    'seed',seed, ...
    'computeLocalP',options.ComputeLocalP);

reportProgress(options.ProgressFcn,1,sprintf( ...
    'Cross-fitted eCOCO sliding-window analysis complete: %d windows.', ...
    nWindowPosition));
end

function starts = endpointInclusiveStarts(lastStart,step)
starts = 1:step:lastStart;
if isempty(starts)
    starts = lastStart;
elseif starts(end) ~= lastStart
    starts(end+1) = lastStart;
end
end

function [data,orbit9,srGrid,method,nWindow] = validateInputs( ...
        data,orbit9,window,dt,step,red,pad,srGrid,nsim,method, ...
        maxFrequency,seed,anchorFraction)
validateattributes(data,{'numeric'}, ...
    {'2d','real','finite','ncols',2,'nonempty'},mfilename,'data',1);
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
    {'scalar','real','finite','positive','integer'},mfilename,'pad',7);
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
validateattributes(anchorFraction,{'numeric'}, ...
    {'scalar','real','finite','positive','<=',2}, ...
    mfilename,'anchorFraction',13);

orbit9 = orbit9(:);
srGrid = srGrid(:);
if numel(unique(orbit9)) ~= 9
    error('ecocoCrossfitCore:DuplicateOrbitPeriods', ...
        'ORBIT9 must contain nine distinct periods.');
end
if any(diff(srGrid) <= 0)
    error('ecocoCrossfitCore:InvalidRateGrid', ...
        'SRGRID must be strictly increasing.');
end
if numel(srGrid) > 10000
    error('ecocoCrossfitCore:RateGridTooLarge', ...
        'SRGRID may contain at most 10000 tested rates.');
end
if maxFrequency < max(1./orbit9)-64*eps(max(1,max(1./orbit9)))
    error('ecocoCrossfitCore:MaximumFrequencyExcludesOrbit', ...
        'MAXFREQUENCY must include the highest nominal orbital frequency.');
end

data = sortrows(data,1);
if any(diff(data(:,1)) <= 0)
    error('ecocoCrossfitCore:InvalidDepth', ...
        'DATA depths must be distinct and strictly increasing after sorting.');
end
spacing = diff(data(:,1));
spacingTolerance = max(1e-10*max(1,abs(dt)), ...
    64*eps(max(1,max(abs(data(:,1))))));
if any(abs(spacing-dt) > spacingTolerance)
    error('ecocoCrossfitCore:UnevenDepth', ...
        ['DATA must already be evenly sampled at DT before cross-fitted ', ...
         'window geometry is shared.']);
end

% Match deterministic half-window edge padding with an odd number of
% points, so both halves contain the same integer sample count and output
% centres remain aligned with the observed depth grid.
nWindow = 2*round(window/(2*dt))+1;
if nWindow < 8
    error('ecocoCrossfitCore:WindowTooShort', ...
        'WINDOW must contain at least eight samples.');
end
if nWindow > size(data,1)
    error('ecocoCrossfitCore:WindowLongerThanData', ...
        'WINDOW is longer than DATA.');
end
if pad < nWindow
    error('ecocoCrossfitCore:PadTooShort', ...
        'PAD must be at least the complete window point count.');
end
end

function groups = defineOrbitGroups(periods)
index = zeros(numel(periods),1);
index(periods >= 200) = 1;
index(periods >= 80 & periods < 200) = 2;
index(periods >= 30 & periods < 80) = 3;
index(periods < 30) = 4;
counts = accumarray(index,1,[4,1]);
if ~isequal(counts,[1;4;1;3])
    error('ecocoCrossfitCore:InvalidOrbitGroups', ...
        ['ORBIT9 must contain 1/4/1/3 long-eccentricity, ', ...
         'short-eccentricity, obliquity, and precession periods.']);
end
groups.index = index;
groups.counts = counts;
end

function geom = prepareGeometry(n,dz,periods,srGrid,pad,groups,maxFrequency)
fs = 1/dz;
nfft = pad;
nf = floor(nfft/2)+1;
frequency = (0:nf-1)' .* (fs/nfft);
rayleigh = fs/n;
nyquist = fs/2;
nRate = numel(srGrid);
nOrbit = numel(periods);

geom = struct;
geom.n = n;
geom.dz = dz;
geom.fs = fs;
geom.nfft = nfft;
geom.frequency = frequency;
geom.rayleigh = rayleigh;
geom.nyquist = nyquist;
geom.basis = cell(nRate,1);
geom.coherentGroupBasis = cell(nRate,1);
geom.groupTemplate = cell(nRate,1);
geom.groupBandIndex = cell(nRate,4);
geom.groupUnitEnergy = nan(nRate,4);
geom.groupLeakageMatrix = cell(nRate,1);
geom.groupLeakageRcond = nan(nRate,1);
geom.minimumLeakageRcond = 1e-10;
geom.corrIndex = cell(nRate,1);
geom.validRateMask = false(nRate,1);
geom.trainingRateMask = false(nRate,1);
geom.orbitCount = zeros(nRate,1);
geom.resolvedOrbitMask = false(nRate,nOrbit);
geom.crossGroupBandOverlap = false(nRate,1);
geom.groupIndex = groups.index;
geom.srGrid = srGrid;

oneSidedWeight = 2*ones(nf,1);
oneSidedWeight(1) = 1;
if rem(nfft,2) == 0
    oneSidedWeight(end) = 1;
end

for m = 1:nRate
    sr = srGrid(m);
    spatialOrbit = 100 ./ (periods*sr);
    isResolved = spatialOrbit >= rayleigh & spatialOrbit < nyquist;
    geom.orbitCount(m) = sum(isResolved);
    geom.resolvedOrbitMask(m,:) = isResolved(:)';
    temporalFrequency = frequency .* sr/100;
    geom.corrIndex{m} = find(temporalFrequency <= maxFrequency + ...
        16*eps(max(1,maxFrequency)));
    if numel(geom.corrIndex{m}) < 3 || ~any(isResolved)
        continue
    end

    lo = zeros(1,nOrbit);
    hi = zeros(1,nOrbit);
    for j = 1:nOrbit
        inBand = find(abs(frequency-spatialOrbit(j)) <= rayleigh);
        if isempty(inBand)
            [~,nearest] = min(abs(frequency-spatialOrbit(j)));
            inBand = nearest;
        end
        lo(j) = inBand(1);
        hi(j) = inBand(end);
    end

    time = (0:n-1)' .* (100*dz/sr);
    phase = 2*pi .* time ./ periods';
    unitSine = detrend(sin(phase),1);
    unitCosine = detrend(cos(phase),1);
    H = fft(unitSine,nfft,1);
    Hcosine = fft(unitCosine,nfft,1);
    H = H(1:nf,:);
    Hcosine = Hcosine(1:nf,:);
    if any(~isfinite(H),'all') || any(~isfinite(Hcosine),'all')
        continue
    end
    spectrumScale = 1/(fs*n);
    unitPower = 0.5 .* (abs(H).^2 + abs(Hcosine).^2) .* ...
        oneSidedWeight .* spectrumScale;
    groupTemplate = zeros(nf,4);
    analysisUpperSpatialFrequency = min(nyquist,maxFrequency*100/sr);
    for j = 1:nOrbit
        if isResolved(j)
            groupTemplate(:,groups.index(j)) = ...
                groupTemplate(:,groups.index(j)) + unitPower(:,j);
        end
    end
    for g = 1:4
        members = find(groups.index == g & isResolved);
        bandMask = false(nf,1);
        for member = members(:)'
            bandMask(lo(member):hi(member)) = true;
        end
        bandMask = bandMask & frequency <= analysisUpperSpatialFrequency + ...
            64*eps(max(1,analysisUpperSpatialFrequency));
        idx = find(bandMask);
        geom.groupBandIndex{m,g} = idx;
        if ~isempty(idx)
            geom.groupUnitEnergy(m,g) = ...
                sum(groupTemplate(idx,g))*(fs/nfft);
        end
    end
    geom.crossGroupBandOverlap(m) = continuousGroupBandOverlap( ...
        spatialOrbit,rayleigh,analysisUpperSpatialFrequency, ...
        isResolved,groups.index);
    leakage = zeros(4,4);
    for observedGroup = 1:4
        idx = geom.groupBandIndex{m,observedGroup};
        if ~isempty(idx)
            leakage(observedGroup,:) = ...
                sum(groupTemplate(idx,:),1)*(fs/nfft);
        end
    end
    geom.groupLeakageMatrix{m} = leakage;
    if all(isfinite(leakage),'all')
        geom.groupLeakageRcond(m) = rcond(leakage);
    end
    geom.groupTemplate{m} = groupTemplate;
    geom.basis{m} = H;
    coherentGroupBasis = zeros(nf,4,'like',H);
    for g = 1:4
        members = groups.index == g & isResolved;
        if any(members)
            coherentGroupBasis(:,g) = sum(H(:,members),2);
        end
    end
    geom.coherentGroupBasis{m} = coherentGroupBasis;
    geom.validRateMask(m) = any(groupTemplate(:) > 0);
    geom.trainingRateMask(m) = all(isResolved) && ...
        all(isfinite(geom.groupUnitEnergy(m,:)) & ...
        geom.groupUnitEnergy(m,:) > 0) && ...
        isfinite(geom.groupLeakageRcond(m)) && ...
        geom.groupLeakageRcond(m) >= geom.minimumLeakageRcond && ...
        ~geom.crossGroupBandOverlap(m);
end
geom.oneSidedWeight = oneSidedWeight;
geom.spectrumScale = 1/(fs*n);
end

function tf = continuousGroupBandOverlap( ...
        center,rayleigh,upperFrequency,isResolved,groupIndex)
tf = false;
active = find(isResolved);
if numel(active) < 2
    return
end
lo = max(0,center-rayleigh);
hi = min(upperFrequency,center+rayleigh);
scale = max([1;abs(lo(:));abs(hi(:));abs(upperFrequency)]);
tolerance = 128*eps(scale);
for aa = 1:numel(active)-1
    first = active(aa);
    for bb = aa+1:numel(active)
        second = active(bb);
        if groupIndex(first) == groupIndex(second)
            continue
        end
        overlap = min(hi(first),hi(second))-max(lo(first),lo(second));
        if overlap > tolerance
            tf = true;
            return
        end
    end
end
end

function [curve,bestRate,amplitudeAtBest] = ...
        trainFourGroup(power,geom,method,keepCurve)
nRate = numel(geom.srGrid);
nSeries = size(power,2);
if keepCurve
    curve = nan(nRate,nSeries);
else
    curve = [];
end
bestScore = -inf(1,nSeries);
bestRate = nan(1,nSeries);
amplitudeAtBest = nan(4,nSeries);
df = geom.fs/geom.nfft;
for m = 1:nRate
    if ~geom.trainingRateMask(m)
        continue
    end
    dataEnergy = zeros(4,nSeries);
    for g = 1:4
        idx = geom.groupBandIndex{m,g};
        if isempty(idx)
            dataEnergy(g,:) = NaN;
        else
            dataEnergy(g,:) = sum(power(idx,:),1)*df;
        end
    end
    if any(~isfinite(dataEnergy),'all') || any(dataEnergy < 0,'all')
        error('ecocoCrossfitCore:InvalidGroupBandEnergy', ...
            'A four-group integration band has invalid energy.');
    end
    groupPower = cocoNonnegativeLeakageSolve( ...
        geom.groupLeakageMatrix{m},dataEnergy);
    maximumGroupPower = max(groupPower,[],1);
    negligible = groupPower <= ...
        maximumGroupPower.*activeGroupWeightTolerance()^2;
    groupPower(negligible) = 0;
    groupAmplitude = sqrt(groupPower);
    targetPower = fourGroupTargetPower(geom,m,groupAmplitude);
    idx = geom.corrIndex{m};
    rho = columnCorrelation(power(idx,:),targetPower(idx,:),method);
    if keepCurve
        curve(m,:) = rho;
    end
    better = isfinite(rho) & rho > bestScore;
    if any(better)
        bestScore(better) = rho(better);
        bestRate(better) = geom.srGrid(m);
        amplitudeAtBest(:,better) = groupAmplitude(:,better);
    end
end
bestScore(~isfinite(bestRate)) = NaN;
if ~keepCurve
    curve = bestScore;
end
end

function weights = normalizeGroupAmplitudes(amplitudes)
scale = max(amplitudes,[],1);
weights = amplitudes./scale;
zeroTarget = isfinite(scale) & scale == 0 & all(isfinite(amplitudes),1);
weights(:,zeroTarget) = 0;
bad = ~isfinite(scale) | scale < 0;
weights(:,bad) = NaN;
weights(weights >= 0 & weights <= activeGroupWeightTolerance()) = 0;
end

function curve = validateFrozen(power,geom,weights,method)
nRate = numel(geom.srGrid);
nSeries = size(power,2);
if size(weights,1) ~= 4 || size(weights,2) ~= nSeries
    error('ecocoCrossfitCore:WeightSize', ...
        'Frozen weights must be a 4-by-series matrix.');
end
curve = nan(nRate,nSeries);
for m = 1:nRate
    if ~geom.validRateMask(m)
        continue
    end
    targetPower = fourGroupTargetPower(geom,m,weights);
    idx = geom.corrIndex{m};
    curve(m,:) = columnCorrelation( ...
        power(idx,:),targetPower(idx,:),method);
end
end

function targetPower = fourGroupTargetPower(geom,rateIndex,groupAmplitude)
% Four fitted group amplitudes are repeated across their 1/4/1/3 member
% orbits.  Summing the resolved sine columns into four coherent bases once
% per rate is algebraically identical to expanding to nine rows, while
% substantially reducing the sliding Monte Carlo matrix multiplication.
targetFFT = geom.coherentGroupBasis{rateIndex}*groupAmplitude;
targetPower = abs(targetFFT).^2 .* geom.oneSidedWeight .* ...
    geom.spectrumScale;
end

function rho = columnCorrelation(x,y,method)
nSeries = size(x,2);
if strcmpi(method,'Spearman')
    rho = nan(1,nSeries);
    for k = 1:nSeries
        ok = isfinite(x(:,k)) & isfinite(y(:,k));
        if nnz(ok) >= 2
            if effectivelyConstant(x(ok,k)) || effectivelyConstant(y(ok,k))
                rho(k) = 0;
            else
                rho(k) = corr(x(ok,k),y(ok,k),'Type','Spearman');
            end
        end
    end
    return
end
ok = isfinite(x) & isfinite(y);
n = sum(ok,1);
x0 = x;
y0 = y;
x0(~ok) = 0;
y0(~ok) = 0;
mx = sum(x0,1)./max(n,1);
my = sum(y0,1)./max(n,1);
xc = (x0-mx).*ok;
yc = (y0-my).*ok;
numerator = sum(xc.*yc,1);
sumSquareX = sum(xc.^2,1);
sumSquareY = sum(yc.^2,1);
scaleX = max(abs(x0),[],1);
scaleY = max(abs(y0),[],1);
relativeRoundoff = 256*eps(class(x));
toleranceX = n.*(relativeRoundoff.*max(scaleX,realmin(class(x)))).^2;
toleranceY = n.*(relativeRoundoff.*max(scaleY,realmin(class(y)))).^2;
denominator = sqrt(sumSquareX.*sumSquareY);
rho = numerator./denominator;
degenerate = n >= 2 & (sumSquareX <= toleranceX | ...
    sumSquareY <= toleranceY);
rho(degenerate) = 0;
rho(n < 2 | ~isfinite(rho)) = NaN;
end

function tf = effectivelyConstant(x)
x = x(isfinite(x));
if numel(x) < 2
    tf = true;
    return
end
centered = x-mean(x);
scale = max(abs(x));
tolerance = numel(x)*(256*eps(class(x))* ...
    max(scale,realmin(class(x))))^2;
tf = ~all(isfinite(centered)) || sum(centered.^2) <= tolerance;
end

function [combined,support] = combineDirectionalCurves( ...
        forward,backward,hasForward,hasBackward)
combined = nan(size(forward));
nWindow = size(forward,2);
support = repmat({'none'},nWindow,1);
both = hasForward & hasBackward;
forwardOnly = hasForward & ~hasBackward;
backwardOnly = ~hasForward & hasBackward;
combined(:,both) = min(forward(:,both),backward(:,both));
combined(:,forwardOnly) = forward(:,forwardOnly);
combined(:,backwardOnly) = backward(:,backwardOnly);
support(both) = {'bidirectional'};
support(forwardOnly) = {'forward-only'};
support(backwardOnly) = {'backward-only'};
end

function combined = combineOneNull(forward,backward,hasForward,hasBackward)
if hasForward && hasBackward
    combined = min(forward,backward);
elseif hasForward
    combined = forward;
elseif hasBackward
    combined = backward;
else
    combined = nan(size(forward));
end
end

function count = globalExceedance(nullCurve,observedCurve,validRateMask)
validRows = validRateMask & any(isfinite(nullCurve),2);
if ~any(validRows)
    error('ecocoCrossfitCore:InvalidMonteCarloValidation', ...
        'A null validation curve has no finite sedimentation-rate statistic.');
end
nullMaximum = max(nullCurve(validRows,:),[],1);
if any(~isfinite(nullMaximum))
    error('ecocoCrossfitCore:InvalidMonteCarloMaximum', ...
        'A Monte Carlo realization has no finite SR-global maximum.');
end
count = sum(nullMaximum >= observedCurve,2);
count(~isfinite(observedCurve)) = 0;
end

function count = localExceedance(nullCurve,observedCurve)
count = sum(nullCurve >= observedCurve,2);
count(~isfinite(observedCurve)) = 0;
end

function p = pFromCounts(count,observed,nsim)
p = nan(size(observed));
if nsim <= 0
    return
end
valid = isfinite(observed);
p(valid) = (double(count(valid))+1)/(nsim+1);
end

function p = combineDirectionalP(forward,backward, ...
        hasForward,hasBackward,allowFallback)
p = nan(size(forward));
both = hasForward & hasBackward;
p(:,both) = max(forward(:,both),backward(:,both));
if allowFallback
    forwardOnly = hasForward & ~hasBackward;
    backwardOnly = ~hasForward & hasBackward;
    p(:,forwardOnly) = forward(:,forwardOnly);
    p(:,backwardOnly) = backward(:,backwardOnly);
end
end

function [bestRate,bestIndex,bestScore] = curveMaximum(curve,srGrid)
nWindow = size(curve,2);
bestRate = nan(nWindow,1);
bestIndex = nan(nWindow,1);
bestScore = nan(nWindow,1);
for j = 1:nWindow
    valid = find(isfinite(curve(:,j)));
    if isempty(valid)
        continue
    end
    [score,location] = max(curve(valid,j));
    index = valid(location);
    bestRate(j) = srGrid(index);
    bestIndex(j) = index;
    bestScore(j) = score;
end
end

function values = valuesAtIndices(matrix,index)
values = nan(numel(index),1);
for j = 1:numel(index)
    if isfinite(index(j)) && index(j) >= 1 && index(j) <= size(matrix,1)
        values(j) = matrix(index(j),j);
    end
end
end

function values = valuesAtRates(curve,rates,srGrid)
values = nan(numel(rates),1);
for j = 1:numel(rates)
    index = find(srGrid == rates(j),1);
    if ~isempty(index)
        values(j) = curve(index,j);
    end
end
end

function count = participationCount(geom,weights,anchorIndex,supported)
nRate = numel(geom.srGrid);
nWindow = numel(anchorIndex);
count = nan(nRate,nWindow);
for j = find(supported(:))'
    activeGroup = weights(:,anchorIndex(j)) > activeGroupWeightTolerance();
    activeOrbit = activeGroup(geom.groupIndex);
    count(:,j) = sum(geom.resolvedOrbitMask & activeOrbit',2);
end
end

function count = consensusParticipation(geom,weights,forwardAnchor, ...
        backwardAnchor,hasForward,hasBackward,strictOnly)
nRate = numel(geom.srGrid);
nWindow = numel(forwardAnchor);
count = nan(nRate,nWindow);
for j = 1:nWindow
    if hasForward(j) && hasBackward(j)
        activeForward = weights(:,forwardAnchor(j)) > ...
            activeGroupWeightTolerance();
        activeBackward = weights(:,backwardAnchor(j)) > ...
            activeGroupWeightTolerance();
        activeOrbit = (activeForward & activeBackward);
        activeOrbit = activeOrbit(geom.groupIndex);
    elseif ~strictOnly && hasForward(j)
        activeGroup = weights(:,forwardAnchor(j)) > ...
            activeGroupWeightTolerance();
        activeOrbit = activeGroup(geom.groupIndex);
    elseif ~strictOnly && hasBackward(j)
        activeGroup = weights(:,backwardAnchor(j)) > ...
            activeGroupWeightTolerance();
        activeOrbit = activeGroup(geom.groupIndex);
    else
        continue
    end
    count(:,j) = sum(geom.resolvedOrbitMask & activeOrbit',2);
end
end

function out = makeDirectionResult(rho,pGlobal,pLocal,bestRate,bestIndex, ...
        bestScore,anchorIndex,supported,activeOrbitCount)
out = struct( ...
    'rho',rho, ...
    'pGlobal',pGlobal, ...
    'pLocal',pLocal, ...
    'bestRate',bestRate, ...
    'bestIndex',bestIndex, ...
    'bestCorrelation',bestScore, ...
    'bestGlobalP',valuesAtIndices(pGlobal,bestIndex), ...
    'anchorIndex',anchorIndex, ...
    'supported',supported, ...
    'activeOrbitCount',activeOrbitCount);
end

function out = attachScoreFields(out,totalOrbitCount)
out.nOrbit = out.activeOrbitCount;
out.pCOCO = pcocoValue(out.rho,out.pGlobal);
out.score = out.pCOCO.*out.nOrbit./totalOrbitCount;
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

function tolerance = activeGroupWeightTolerance()
tolerance = 1e-8;
end

function tolerance = frequencyTolerance(frequency)
if isempty(frequency)
    tolerance = 0;
else
    tolerance = max(1,max(abs(frequency)))*1e-10;
end
end

function reportProgress(progressFcn,fraction,message)
if isempty(progressFcn)
    return
end
randomState = rng;
restoreRandomState = onCleanup(@()rng(randomState));
progressFcn(min(max(fraction,0),1),message);
clear restoreRandomState
end

function lastPercent = reportWindowMonteCarloWork(progressFcn, ...
        firstSimulation,lastSimulation,nsim,nBatch,windowIndex, ...
        windowCount,lastPercent)
doneWork = (firstSimulation-1)*windowCount+nBatch*windowIndex;
totalWork = nsim*windowCount;
fraction = min(max(doneWork/max(1,totalWork),0),1);
percent = floor(100*fraction+32*eps(max(1,100*fraction)));
if percent <= lastPercent && fraction < 1
    return
end
windowEquivalent = min(windowCount,floor( ...
    doneWork/max(1,nsim)+32*eps(max(1,doneWork/max(1,nsim)))));
reportProgress(progressFcn,fraction,sprintf( ...
    'Cross-fitted eCOCO window work: %d of %d', ...
    windowEquivalent,windowCount));
lastPercent = percent;
end
