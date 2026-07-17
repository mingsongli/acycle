function result = ecocoAdaptiveCore(data,orbit9,window,dt,step,red,pad, ...
        srGrid,nsim,method,maxFrequency,seed,varargin)
%ECOCOADAPTIVECORE Batched full-grid Adaptive COCO9B sliding analysis.
%
% Every full sliding window is evaluated at every requested sedimentation
% rate.  The observed and null spectra are batched across windows, while
% COCoadaptiveEvaluate repeats method-B four-group area/leakage fitting for
% every window, rate, and Monte Carlo realization.  PGLOBAL is the
% within-window maximum-over-rate (SR-global) Monte Carlo p-value; no
% correction over the sliding-window dimension is applied.  PLOCAL is the
% same-rate Monte Carlo p-value from those identical null realizations.

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'BatchSimulations',[],@(x) isempty(x) || ...
    (isnumeric(x) && isscalar(x) && isfinite(x) && x >= 1 && x == fix(x)));
addParameter(parser,'ProgressFcn',[],@(x) isempty(x) || isa(x,'function_handle'));
parse(parser,varargin{:});
requestedBatch = parser.Results.BatchSimulations;
progressFcn = parser.Results.ProgressFcn;

validateattributes(data,{'numeric'},{'2d','ncols',2,'real','finite','nonempty'}, ...
    mfilename,'data',1);
validateattributes(orbit9,{'numeric'}, ...
    {'vector','numel',9,'real','finite','positive'},mfilename,'orbit9',2);
validateattributes(window,{'numeric'},{'scalar','real','finite','positive'}, ...
    mfilename,'window',3);
validateattributes(dt,{'numeric'},{'scalar','real','finite','positive'}, ...
    mfilename,'dt',4);
validateattributes(step,{'numeric'},{'scalar','integer','finite','positive'}, ...
    mfilename,'step',5);
validateattributes(red,{'numeric'},{'scalar','integer','finite','>=',0,'<=',3}, ...
    mfilename,'red',6);
validateattributes(pad,{'numeric'},{'scalar','integer','finite','positive'}, ...
    mfilename,'pad',7);
validateattributes(srGrid,{'numeric'},{'vector','real','finite','positive','nonempty'}, ...
    mfilename,'srGrid',8);
validateattributes(nsim,{'numeric'},{'scalar','integer','finite','nonnegative'}, ...
    mfilename,'nsim',9);
method = validatestring(method,{'Pearson','Spearman'},mfilename,'method',10);
validateattributes(maxFrequency,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'maxFrequency',11);
validateattributes(seed,{'numeric'}, ...
    {'scalar','integer','finite','nonnegative','<=',2^32-1}, ...
    mfilename,'seed',12);

data = sortrows(data,1);
spacing = diff(data(:,1));
spacingTolerance = max(1e-10*max(1,dt),64*eps(max(abs(data(:,1)))));
if any(spacing <= 0) || any(abs(spacing-dt) > spacingTolerance)
    error('ecocoAdaptiveCore:UnevenSampling', ...
        'DATA must be a strictly increasing, evenly sampled depth series.');
end
srGrid = srGrid(:);
if any(diff(srGrid) <= 0)
    error('ecocoAdaptiveCore:InvalidRateGrid', ...
        'SRGRID must be strictly increasing.');
end

% Use an odd point count whose two equal half-spans match ZEROPAD2's
% integer half-window padding.  This keeps the first/last result centres
% on the first/last observed depths even when WINDOW/(2*DT) is fractional.
nWindow = 2*round(window/(2*dt))+1;
if nWindow < 4 || nWindow > size(data,1)
    error('ecocoAdaptiveCore:InvalidWindow', ...
        'The requested window must contain 4..N data points.');
end
if pad < nWindow
    error('ecocoAdaptiveCore:PadTooShort', ...
        'PAD (%d) must be at least the %d samples in one window.',pad,nWindow);
end
lastStart = size(data,1)-nWindow+1;
starts = endpointInclusiveStarts(lastStart,step);
if isempty(starts)
    error('ecocoAdaptiveCore:NoWindows','No complete sliding windows remain.');
end
ends = starts+nWindow-1;
nRate = numel(srGrid);
nWindows = numel(starts);

values = zeros(nWindow,nWindows);
depth = zeros(nWindows,1);
for windowIndex = 1:nWindows
    index = starts(windowIndex):ends(windowIndex);
    values(:,windowIndex) = data(index,2);
    depth(windowIndex) = mean(data(index([1,end]),1));
end

reportProgress(progressFcn,0,sprintf( ...
    'Preparing %d Adaptive eCOCO sliding windows.',nWindows));
[observedPower,frequency] = ecocoWindowSpectra(values,dt,pad,red);
templateData = [(0:nWindow-1)'*dt,zeros(nWindow,1)];
rayleigh = enbw(rectwin(nWindow),1/dt);
[rho,~,nMissing] = cocoAdaptiveEvaluate( ...
    observedPower,templateData,pad,frequency,[],orbit9,rayleigh, ...
    srGrid,[],method,'BatchSize',max(1,min(100,nWindows)), ...
    'RateBounds',[srGrid(1),srGrid(end)], ...
    'MaxFrequency',maxFrequency,'TargetModel','coherent-nine', ...
    'AmplitudeMode','four-group-area');
if ~isequal(size(rho),[nRate,nWindows])
    error('ecocoAdaptiveCore:ObservedSizeMismatch', ...
        'The adaptive evaluator returned an unexpected observed matrix size.');
end

[rhoM,dataStd,validNullWindow] = ecocoEstimateAr1(values);
pGlobal = nan(nRate,nWindows);
pLocal = nan(nRate,nWindows);
nCompleted = 0;
batchSimulations = 0;
if nsim > 0
    nFrequency = floor(pad/2)+1;
    memoryBudget = 256*1024^2;
    bytesPerSimulation = nWindows*max(1,24*nWindow+72*nFrequency+16*nRate);
    memoryBatch = max(1,floor(memoryBudget/bytesPerSimulation));
    if isempty(requestedBatch)
        batchSimulations = min([50,nsim,memoryBatch]);
    else
        batchSimulations = min([requestedBatch,nsim,memoryBatch]);
    end
    globalExceedance = zeros(nRate,nWindows,'uint32');
    localExceedance = zeros(nRate,nWindows,'uint32');
    previousRng = rng;
    rngCleanup = onCleanup(@()rng(previousRng));
    rng(seed,'twister');

    for firstSimulation = 1:batchSimulations:nsim
        lastSimulation = min(firstSimulation+batchSimulations-1,nsim);
        nBatch = lastSimulation-firstSimulation+1;
        rhoRep = repmat(rhoM,1,nBatch);
        stdRep = repmat(dataStd,1,nBatch);
        validRep = repmat(validNullWindow,1,nBatch);
        nullValues = stationaryAr1Batch(nWindow,rhoRep,stdRep,validRep);
        [nullPower,nullFrequency] = ...
            ecocoWindowSpectra(nullValues,dt,pad,red);
        if ~isequal(frequency,nullFrequency)
            error('ecocoAdaptiveCore:NullFrequencyChanged', ...
                'Observed and null frequency grids differ.');
        end
        nullRho = cocoAdaptiveEvaluate( ...
            nullPower,templateData,pad,nullFrequency,[],orbit9,rayleigh, ...
            srGrid,[],method,'BatchSize',max(1,min(100,size(nullPower,2))), ...
            'RateBounds',[srGrid(1),srGrid(end)], ...
            'MaxFrequency',maxFrequency,'TargetModel','coherent-nine', ...
            'AmplitudeMode','four-group-area');
        nullRho = reshape(nullRho,nRate,nWindows,nBatch);
        for batchIndex = 1:nBatch
            nullCurve = nullRho(:,:,batchIndex);
            nullMaximum = finiteRateMaximum(nullCurve);
            globalExceedance = globalExceedance + ...
                uint32(rho <= nullMaximum);
            localExceedance = localExceedance + ...
                uint32(nullCurve >= rho);
        end
        nCompleted = lastSimulation;
        reportProgress(progressFcn,nCompleted/nsim,sprintf( ...
            'Adaptive eCOCO Monte Carlo: %d of %d',nCompleted,nsim));
    end
    clear rngCleanup
    pGlobal = (double(globalExceedance)+1)./(nsim+1);
    pLocal = (double(localExceedance)+1)./(nsim+1);
    pGlobal(~isfinite(rho)) = NaN;
    pLocal(~isfinite(rho)) = NaN;
    pGlobal(:,~validNullWindow) = NaN;
    pLocal(:,~validNullWindow) = NaN;
end

nOrbitRate = numel(orbit9)-nMissing(:);
nOrbit = repmat(nOrbitRate,1,nWindows);
pCOCO = pcoco(rho,pGlobal);
score = pCOCO.*nOrbit./numel(orbit9);

result = struct;
result.method = 'adaptive';
result.name = 'Adaptive eCOCO';
result.targetMode = 'adaptive9b';
result.srGrid = srGrid;
result.depth = depth;
result.rho = rho;
% PParametric is the historical OUT_EP field name in ECOCO.  Retain it as
% an exact alias so old callers receive the newly audited local Monte
% Carlo p-value without an interface break.
result.pLocal = pLocal;
result.pParametric = pLocal;
result.pGlobal = pGlobal;
result.nOrbit = nOrbit;
result.pCOCO = pCOCO;
result.score = score;
result.windowStartIndex = starts(:);
result.windowEndIndex = ends(:);
result.windowPointCount = nWindow;
result.requestedWindow = window;
result.actualWindowSpan = (nWindow-1)*dt;
result.stepSamples = step;
result.stepDepth = step*dt;
result.rhoM = rhoM(:);
result.validNullWindow = validNullWindow(:);
result.nsimRequested = nsim;
result.nsimCompleted = nCompleted;
result.pFloor = conditionalPFloor(nsim);
result.seed = seed;
result.red = red;
result.pad = pad;
result.maxFrequency = maxFrequency;
result.rateGlobalDefinition = [ ...
    'plus-one Monte Carlo p from the per-realization maximum correlation ', ...
    'over the complete sedimentation-rate grid within each window'];
result.localDefinition = [ ...
    'plus-one same-rate Monte Carlo p from the identical local AR(1) ', ...
    'null realizations used for SR-global p'];
result.mapGlobalApplied = false;
result.batchSimulations = batchSimulations;
result.algorithmVersion = 'Adaptive-eCOCO9B-full-grid-local-p-v2';
reportProgress(progressFcn,1,sprintf( ...
    'Adaptive eCOCO sliding-window analysis complete: %d windows.', ...
    nWindows));
end

function starts = endpointInclusiveStarts(lastStart,step)
starts = 1:step:lastStart;
if isempty(starts)
    starts = lastStart;
elseif starts(end) ~= lastStart
    % The half-window edge padding is intended to place results exactly at
    % both observed endpoints.  Preserve the requested regular step in the
    % interior and add the final complete window when the span is not an
    % integer multiple of STEP.
    starts(end+1) = lastStart;
end
end

function values = stationaryAr1Batch(n,rho,dataStd,valid)
nSeries = numel(rho);
values = zeros(n,nSeries);
if ~any(valid)
    return
end
innovations = randn(n,nSeries);
values(1,valid) = innovations(1,valid);
innovationStd = sqrt(max(0,1-rho(valid).^2));
for row = 2:n
    values(row,valid) = rho(valid).*values(row-1,valid) + ...
        innovationStd.*innovations(row,valid);
end
values(:,valid) = values(:,valid).*dataStd(valid);
end

function maximum = finiteRateMaximum(values)
maximum = nan(1,size(values,2));
for column = 1:size(values,2)
    x = values(:,column);
    x = x(isfinite(x));
    if ~isempty(x)
        maximum(column) = max(x);
    end
end
end

function value = pcoco(rho,p)
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
    warning('ecocoAdaptiveCore:ProgressCallbackFailed', ...
        'Progress callback failed: %s',exception.message);
end
clear restoreRandomState
end
