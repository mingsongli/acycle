function [rho,pValue,nMissing,diagnostic] = cocoAdaptiveEvaluate( ...
        dataPower,dat,pad,dataFrequency,~,orbit9, ...
        rayleigh,srGrid,~,method,varargin)
%COCOADAPTIVEEVALUATE Batch evaluator for adaptive COCO spectra.
%
% The first column of DATAPOWER is the observed spectrum. Additional
% columns are Monte Carlo spectra on the same spatial-frequency grid. For
% every tested sedimentation rate, the finite-record orbital FFT basis and
% unit-amplitude calibration are built once and then reused for all
% columns. Adaptive peak extraction is repeated independently for every
% spectrum. Physically unresolved orbital terms are excluded rather than
% being assigned to a nearest spectral bin.
% MaxFrequency defaults to 1.2 times the highest requested orbital
% frequency and limits both the correlation interval and participation.
% The temporalized data-periodogram grid and each finite-record orbital
% template grid are mathematically identical, so the audited evaluator
% correlates them directly without a rate-dependent interpolation branch.
% TargetModel='phase-averaged' (default) adds the nine independently
% phase-averaged orbital powers. TargetModel='coherent-nine' instead sums
% the nine zero-phase sine FFT terms before calculating power, matching the
% coherent construction used by the compatibility cvCOCO target while retaining
% this evaluator's native-grid and batched Monte Carlo workflow.
% AmplitudeMode='adaptive' (default) estimates one amplitude per orbit from
% the maximum PSD in its Rayleigh band. AmplitudeMode='four-group-area'
% integrates the union of the member Rayleigh bands for long eccentricity,
% short eccentricity, obliquity, and precession, corrects their finite-record
% leakage with a four-by-four phase-averaged template matrix and nonnegative
% least squares, then expands the four fitted amplitudes to nine terms.
% AmplitudeMode='fixed' uses the pre-specified COCOFIXEDTARGETWEIGHTS
% amplitudes for the observation and every null realization; it never
% estimates target power from the data.
% TARGETFREQUENCY and SR0 remain positional compatibility inputs for older
% callers but do not define the audited native-grid calculation.
% If background removal leaves a target or data vector constant, its COCO
% similarity score is defined as zero (with parametric p=1) rather than an
% undefined correlation. This keeps the null statistic defined for every
% Monte Carlo realization without discarding simulations.

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'BatchSize',100,@(x) isnumeric(x) && isscalar(x) && ...
    isfinite(x) && x >= 1 && x == fix(x));
addParameter(parser,'ProgressFcn',[],@(x) isempty(x) || ...
    isa(x,'function_handle'));
addParameter(parser,'RateBounds',[],@(x) isempty(x) || ...
    (isnumeric(x) && isvector(x) && numel(x) == 2 && ...
    all(isfinite(x)) && x(2) >= x(1)));
addParameter(parser,'MaxFrequency',[],@(x) isempty(x) || ...
    (isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x > 0));
addParameter(parser,'TargetModel','phase-averaged',@(x) ischar(x) || ...
    (isstring(x) && isscalar(x)));
addParameter(parser,'AmplitudeMode','adaptive',@(x) ischar(x) || ...
    (isstring(x) && isscalar(x)));
parse(parser,varargin{:});
batchSize = parser.Results.BatchSize;
progressFcn = parser.Results.ProgressFcn;
maximumFrequency = parser.Results.MaxFrequency;
rateBounds = parser.Results.RateBounds;
targetModel = validatestring(parser.Results.TargetModel, ...
    {'phase-averaged','coherent-nine'},mfilename,'TargetModel');
amplitudeMode = validatestring(parser.Results.AmplitudeMode, ...
    {'adaptive','four-group-area','fixed'},mfilename,'AmplitudeMode');

validateattributes(dataPower,{'numeric'}, ...
    {'2d','real','nonempty'},mfilename,'dataPower',1);
validateattributes(dat,{'numeric'}, ...
    {'2d','real','nonempty'},mfilename,'dat',2);
validateattributes(pad,{'numeric'}, ...
    {'scalar','integer','positive','finite'},mfilename,'pad',3);
validateattributes(dataFrequency,{'numeric'}, ...
    {'vector','real','finite','nonnegative','nonempty'}, ...
    mfilename,'dataFrequency',4);
validateattributes(orbit9,{'numeric'}, ...
    {'vector','real','finite','positive'},mfilename,'orbit9',6);
validateattributes(rayleigh,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'rayleigh',7);
validateattributes(srGrid,{'numeric'}, ...
    {'vector','real','finite','positive','nonempty'},mfilename,'srGrid',8);
method = validatestring(method,{'Pearson','Spearman'},mfilename,'method',10);

dataFrequency = dataFrequency(:);
orbit9 = orbit9(:);
srGrid = srGrid(:);
fixedAmplitudes = zeros(size(orbit9));
if strcmp(amplitudeMode,'fixed')
    fixedAmplitudes = cocoFixedTargetWeights(orbit9);
end
groupIndex = zeros(size(orbit9));
if strcmp(amplitudeMode,'four-group-area')
    if ~strcmp(targetModel,'coherent-nine')
        error('cocoAdaptiveEvaluate:GroupAreaRequiresCoherentNine', ...
            ['AmplitudeMode=''four-group-area'' is defined for the ', ...
             'coherent nine-term target only.']);
    end
    groupIndex = adaptiveOrbitGroups(orbit9);
end
if numel(unique(orbit9)) ~= numel(orbit9)
    error('cocoAdaptiveEvaluate:DuplicateOrbitPeriods', ...
        'ORBIT9 must contain distinct orbital periods.');
end
if isempty(maximumFrequency)
    maximumFrequency = 1.2*max(1./orbit9);
end
highestOrbitFrequency = max(1./orbit9);
if maximumFrequency < highestOrbitFrequency- ...
        64*eps(max(1,highestOrbitFrequency))
    error('cocoAdaptiveEvaluate:MaximumFrequencyExcludesOrbit', ...
        ['MaxFrequency (%.12g cycle/kyr) is below the highest nominal ', ...
         'orbital frequency (%.12g cycle/kyr).'], ...
        maximumFrequency,highestOrbitFrequency);
end
if size(dataPower,1) ~= numel(dataFrequency)
    error('cocoAdaptiveEvaluate:FrequencySizeMismatch', ...
        'DATAPOWER rows must match DATAFREQUENCY.');
end
expectedSpectrumRows = floor(pad/2)+1;
if size(dataPower,1) ~= expectedSpectrumRows
    error('cocoAdaptiveEvaluate:SpectrumPadMismatch', ...
        ['DATAPOWER/DATAFREQUENCY must contain floor(PAD/2)+1 rows ', ...
         'from a one-sided PAD-point periodogram.']);
end
if numel(dataFrequency) < 2 || any(diff(dataFrequency) <= 0)
    error('cocoAdaptiveEvaluate:InvalidDataFrequency', ...
        'DATAFREQUENCY must be strictly increasing with at least two values.');
end
dataFrequencyStep = mean(diff(dataFrequency));
if any(abs(diff(dataFrequency)-dataFrequencyStep) > ...
        max(1e-10*abs(dataFrequencyStep),32*eps(max(dataFrequency))))
    error('cocoAdaptiveEvaluate:UnevenDataFrequency', ...
        'DATAFREQUENCY must be evenly spaced.');
end
if any(~isfinite(dataPower),'all')
    error('cocoAdaptiveEvaluate:NonfinitePower', ...
        'DATAPOWER must contain only finite values.');
end
negativeTolerance = 64*eps(max(1,max(abs(dataPower),[],'all')));
if any(dataPower < -negativeTolerance,'all')
    error('cocoAdaptiveEvaluate:NegativePower', ...
        'DATAPOWER cannot contain negative spectral power.');
end
dataPower(dataPower < 0) = 0;
if any(diff(srGrid) <= 0)
    error('cocoAdaptiveEvaluate:InvalidRateGrid', ...
        'SRGRID must be strictly increasing.');
end
if ~isempty(rateBounds)
    rateTolerance = 64*eps(max(1,max(abs([srGrid;rateBounds(:)]))));
    if srGrid(1) < rateBounds(1)-rateTolerance || ...
            srGrid(end) > rateBounds(2)+rateTolerance
        error('cocoAdaptiveEvaluate:RateOutsideBounds', ...
            'SRGRID must lie inside the optional RateBounds interval.');
    end
end
[depthForBands,depthForTarget] = usableDepth(dat);
dataStep = abs(diff(depthForBands));
dataStep = dataStep(isfinite(dataStep) & dataStep > 0);
targetStepDepth = diff(depthForTarget);
targetStepDepth = targetStepDepth( ...
    isfinite(targetStepDepth) & targetStepDepth > 0);
dataSpacing = median(dataStep);
targetSpacing = median(targetStepDepth);
if ~isfinite(dataSpacing) || dataSpacing <= 0 || ...
        ~isfinite(targetSpacing) || targetSpacing <= 0
    error('cocoAdaptiveEvaluate:InvalidDepthSpacing', ...
        'A positive finite depth spacing is required.');
end
nTarget = numel(depthForTarget);
if pad < nTarget
    error('cocoAdaptiveEvaluate:PadTooShort', ...
        'PAD must be at least the effective target record length.');
end
nfft = max(ceil(pad),nTarget);
nf = floor(nfft/2)+1;
dataRbw = enbw(rectwin(numel(depthForBands)),1/dataSpacing);
expectedDataFrequencyStep = 1/(pad*dataSpacing);
frequencyGridTolerance = max(1e-10*abs(expectedDataFrequencyStep), ...
    64*eps(max(1,abs(expectedDataFrequencyStep))));
if abs(dataFrequency(1)) > frequencyGridTolerance || ...
        abs(dataFrequencyStep-expectedDataFrequencyStep) > ...
        frequencyGridTolerance
    error('cocoAdaptiveEvaluate:DataFrequencyUnitMismatch', ...
        ['DATAFREQUENCY must be the cycles/depth grid from a PAD-point ', ...
         'periodogram sampled at the DAT spacing.']);
end
rayleighTolerance = max(1e-10*max(1,abs(dataRbw)), ...
    64*eps(max(1,abs(dataRbw))));
if abs(rayleigh-dataRbw) > rayleighTolerance
    error('cocoAdaptiveEvaluate:RayleighMismatch', ...
        ['RAYLEIGH (%.16g) does not match the rectangular-window ', ...
         'resolution implied by DAT (%.16g).'],rayleigh,dataRbw);
end
nRate = numel(srGrid);
nSeries = size(dataPower,2);
computePValue = nargout >= 2;
computeOrbitCount = nargout >= 3;
computeDiagnostic = nargout >= 4;
rho = nan(nRate,nSeries);
pValue = nan(nRate,1);
nMissing = nan(nRate,1);
if computeDiagnostic
    diagnostic = repmat(struct('rate',NaN,'frequency',zeros(0,1), ...
        'dataPower',zeros(0,1),'targetPower',zeros(0,1), ...
        'activeOrbit',false(numel(orbit9),1), ...
        'amplitudes',zeros(numel(orbit9),1), ...
        'targetModel',targetModel, ...
        'amplitudeMode',amplitudeMode, ...
        'groupIndex',groupIndex, ...
        'groupAmplitudes',zeros(4,1), ...
        'groupBandEnergy',zeros(4,1), ...
        'leakageMatrix',zeros(4,4), ...
        'leakageRcond',NaN, ...
        'geometryValid',true),nRate,1);
else
    diagnostic = [];
end
oneSidedWeight = 2*ones(nf,1);
oneSidedWeight(1) = 1;
if rem(nfft,2) == 0
    oneSidedWeight(end) = 1;
end
for m = 1:nRate
    sr = srGrid(m);
    needPhaseTemplate = strcmp(amplitudeMode,'four-group-area');
    [unitTemplate,nativeFrequency,unitPeak,targetScale,basisResolved, ...
        sineBasis,phaseTemplate] = orbitalBasis( ...
        nTarget,targetSpacing,nfft,nf,oneSidedWeight,orbit9,sr, ...
        targetModel,needPhaseTemplate);
    orbitCenter = 1./orbit9;
    temporalRayleigh = rayleigh*sr/100;
    temporalNyquist = (1/(2*dataSpacing))*sr/100;
    physicallyResolved = orbitCenter >= temporalRayleigh & ...
        orbitCenter < temporalNyquist & ...
        orbitCenter <= maximumFrequency;
    eligibleOrbit = physicallyResolved & basisResolved;
    groupGeometry = emptyGroupAreaGeometry();
    if strcmp(amplitudeMode,'four-group-area')
        groupGeometry = fourGroupAreaGeometry( ...
            dataFrequency,nativeFrequency,orbit9,sr,dataRbw, ...
            maximumFrequency,eligibleOrbit,groupIndex,phaseTemplate);
        bandResolved = groupGeometry.orbitBandResolved;
    else
        [bandIndex,bandResolved] = adaptiveBandIndex( ...
            dataFrequency,orbit9,sr,dataRbw,maximumFrequency,eligibleOrbit);
    end
    if strcmp(amplitudeMode,'fixed')
        % A fixed target does not need a data-peak search band. Include
        % every physically and numerically resolved requested term.
        activeOrbit = eligibleOrbit;
    else
        activeOrbit = eligibleOrbit & bandResolved;
    end
    scaledDataFrequency = sr.*dataFrequency./100;
    gridTolerance = max(1e-10*max(1,max(abs(nativeFrequency))), ...
        128*eps(max(1,max(abs(nativeFrequency)))));
    if numel(nativeFrequency) ~= numel(scaledDataFrequency) || ...
            any(abs(nativeFrequency-scaledDataFrequency) > gridTolerance)
        error('cocoAdaptiveEvaluate:NativeFrequencyGridMismatch', ...
            ['The temporalized data grid and finite-record target grid ', ...
             'must be identical. Check PAD and depth spacing.']);
    end
    frequencyMask = nativeFrequency <= maximumFrequency + ...
        64*eps(max(1,maximumFrequency));
    if nnz(frequencyMask) < 3
        error('cocoAdaptiveEvaluate:InsufficientCorrelationBins', ...
            ['Fewer than three common native frequency bins remain below ', ...
             'MaxFrequency at %.12g cm/kyr.'],sr);
    end
    rateBatchSize = memoryLimitedBatchSize( ...
        batchSize,nf,nnz(frequencyMask),numel(dataFrequency));

    if strcmp(amplitudeMode,'four-group-area') && ...
            ~groupGeometry.valid
        % This rate has physically ambiguous cross-group bands or an
        % ill-conditioned active leakage system. Leave its correlation as
        % NaN so it cannot participate in the observed or null search.
        if computeDiagnostic
            diagnostic(m).rate = sr;
            diagnostic(m).frequency = nativeFrequency(frequencyMask);
            diagnostic(m).dataPower = dataPower(frequencyMask,1);
            diagnostic(m).targetPower = zeros(nnz(frequencyMask),1);
            diagnostic(m).activeOrbit = activeOrbit(:);
            diagnostic(m).leakageMatrix = groupGeometry.leakageMatrix;
            diagnostic(m).leakageRcond = groupGeometry.rcond;
            diagnostic(m).geometryValid = false;
        end
        if computeOrbitCount
            nMissing(m) = sum(~activeOrbit);
        end
        reportProgress(progressFcn,m/nRate,m,nRate);
        continue
    end

    for first = 1:rateBatchSize:nSeries
        last = min(first+rateBatchSize-1,nSeries);
        columns = first:last;
        if strcmp(amplitudeMode,'fixed')
            amplitudes = repmat(fixedAmplitudes.*double(activeOrbit), ...
                1,numel(columns));
            groupAmplitudes = zeros(4,numel(columns));
            groupBandEnergy = zeros(4,numel(columns));
        elseif strcmp(amplitudeMode,'four-group-area')
            [amplitudes,groupAmplitudes,groupBandEnergy] = ...
                fourGroupAreaAmplitudes( ...
                dataPower(:,columns),groupGeometry,dataFrequencyStep, ...
                groupIndex,activeOrbit);
        else
            amplitudes = adaptiveAmplitudes( ...
                dataPower(:,columns),bandIndex,unitPeak, ...
                activeOrbit);
            groupAmplitudes = zeros(4,numel(columns));
            groupBandEnergy = zeros(4,numel(columns));
        end
        if strcmp(targetModel,'coherent-nine')
            if strcmp(amplitudeMode,'four-group-area')
                % Method B has only four fitted amplitudes.  Collapse the
                % nine resolved sine columns into four coherent group
                % columns once per rate, then multiply 4-by-series rather
                % than expanding and multiplying 9-by-series.  This is
                % algebraically identical and materially accelerates the
                % large sliding-window Monte Carlo workload.
                coherentGroupBasis = zeros(size(sineBasis,1),4, ...
                    'like',sineBasis);
                for group = 1:4
                    members = groupIndex == group & activeOrbit;
                    if any(members)
                        coherentGroupBasis(:,group) = ...
                            sum(sineBasis(:,members),2);
                    end
                end
                targetFFT = coherentGroupBasis*groupAmplitudes;
            else
                targetFFT = sineBasis*amplitudes;
            end
            targetPower = abs(targetFFT).^2 .* oneSidedWeight .* ...
                targetScale;
        else
            targetPower = unitTemplate*(amplitudes.^2);
        end
        targetForCorrelation = targetPower(frequencyMask,:);
        dataForCorrelation = dataPower(frequencyMask,columns);

        rho(m,columns) = columnCorrelation( ...
            targetForCorrelation,dataForCorrelation,method);
        if first == 1 && computePValue
            [rhoObserved,pObserved] = correlationWithP( ...
                targetForCorrelation(:,1),dataForCorrelation(:,1),method);
            rho(m,1) = rhoObserved;
            pValue(m) = pObserved;
        end
        if first == 1 && computeDiagnostic
            diagnosticFrequency = nativeFrequency(frequencyMask);
            diagnostic(m).rate = sr;
            diagnostic(m).frequency = diagnosticFrequency(:);
            diagnostic(m).dataPower = dataForCorrelation(:,1);
            diagnostic(m).targetPower = targetForCorrelation(:,1);
            diagnostic(m).activeOrbit = activeOrbit(:);
            diagnostic(m).amplitudes = amplitudes(:,1);
            diagnostic(m).groupAmplitudes = groupAmplitudes(:,1);
            diagnostic(m).groupBandEnergy = groupBandEnergy(:,1);
            diagnostic(m).leakageMatrix = groupGeometry.leakageMatrix;
            diagnostic(m).leakageRcond = groupGeometry.rcond;
            diagnostic(m).geometryValid = groupGeometry.valid;
        end
    end

    if computeOrbitCount
        % A direct resolution count is independent of the order of ORBIT9
        % and does not infer participation from target power after the fact.
        nMissing(m) = sum(~activeOrbit);
    end

    reportProgress(progressFcn,m/nRate,m,nRate);
end
end

function batchSize = memoryLimitedBatchSize( ...
        requested,nNative,nTargetGrid,nDataGrid)
% Bound temporary target/data matrices to roughly 128 MiB.
memoryBudget = 128*1024^2;
bytesPerColumn = 24*nNative + 32*nTargetGrid + 16*nDataGrid;
memoryLimit = max(1,floor(memoryBudget/max(1,bytesPerColumn)));
batchSize = min(requested,memoryLimit);
end

function [depthOriginal,depthSorted] = usableDepth(dat)
if size(dat,2) < 1
    error('cocoAdaptiveEvaluate:MissingDepth','DAT must contain a depth column.');
end
depthOriginal = dat(:,1);
if any(~isfinite(depthOriginal)) || numel(depthOriginal) < 2
    error('cocoAdaptiveEvaluate:InsufficientDepth', ...
        'At least two finite depth values are required.');
end
depthOriginal = depthOriginal(:);
if any(diff(depthOriginal) <= 0)
    error('cocoAdaptiveEvaluate:InvalidDepth', ...
        'DAT(:,1) must be strictly increasing.');
end
depthStep = median(diff(depthOriginal));
if any(abs(diff(depthOriginal)-depthStep) > ...
        cocoSamplingTolerance(depthOriginal,depthStep))
    error('cocoAdaptiveEvaluate:UnevenDepth', ...
        'DAT(:,1) must be evenly spaced.');
end
depthSorted = depthOriginal;
end

function [template,frequency,unitPeak,scale,resolved,sineBasis,phaseTemplate] = ...
        orbitalBasis(n,dz,nfft,nf,oneSidedWeight,periods,sr, ...
        targetModel,needPhaseTemplate)
targetFs = sr/(100*dz);
targetTime = (0:n-1)'./targetFs;
phase = 2*pi.*targetTime./periods';
unitSine = detrend(sin(phase),1);
fullSine = fft(unitSine,nfft,1);
sineBasis = fullSine(1:nf,:);
frequency = (0:nf-1)'.*(targetFs/nfft);
scale = 1/(targetFs*n);
phaseTemplate = [];
if strcmp(targetModel,'coherent-nine') && ~needPhaseTemplate
    template = abs(sineBasis).^2 .* oneSidedWeight .* scale;
else
    unitCosine = detrend(cos(phase),1);
    fullCosine = fft(unitCosine,nfft,1);
    cosineBasis = fullCosine(1:nf,:);
    template = 0.5.*(abs(sineBasis).^2+abs(cosineBasis).^2) .* ...
        oneSidedWeight .* scale;
    phaseTemplate = template;
    if strcmp(targetModel,'coherent-nine')
        % Method A deliberately calibrates its peak amplitudes against the
        % zero-phase sine term. Method B uses PHASETEMPLATE only for its
        % finite-record leakage matrix; final target synthesis remains
        % coherent through SINEBASIS.
        sineTemplate = abs(sineBasis).^2 .* oneSidedWeight .* scale;
        template = sineTemplate;
    end
end
unitPeak = zeros(numel(periods),1);
resolved = false(numel(periods),1);
targetRbw = enbw(rectwin(n),targetFs);
targetCenter = 1./periods;
for j = 1:numel(periods)
    inBand = abs(frequency-targetCenter(j)) <= targetRbw;
    if targetCenter(j) < targetFs/2 && any(inBand)
        unitPeak(j) = max(template(inBand,j));
        resolved(j) = isfinite(unitPeak(j)) && unitPeak(j) > 0;
    end
end
end

function groupIndex = adaptiveOrbitGroups(periods)
groups = cocoOrbitGroups(periods);
groupIndex = groups.index;
end

function geometry = emptyGroupAreaGeometry()
geometry = struct( ...
    'bandIndex',{cell(4,1)}, ...
    'orbitBandResolved',false(0,1), ...
    'activeGroup',false(4,1), ...
    'leakageMatrix',zeros(4,4), ...
    'solveMatrix',eye(4), ...
    'rcond',NaN, ...
    'valid',true);
end

function geometry = fourGroupAreaGeometry( ...
        dataFrequency,nativeFrequency,periods,sr,spatialRbw, ...
        maximumFrequency,eligibleOrbit,groupIndex,phaseTemplate)
% Build four union bands and their finite-record phase-averaged leakage
% matrix. Data energy is later integrated on the spatial PSD grid, while
% template energy is integrated on the corresponding temporal PSD grid;
% both integrals therefore have variance units.
geometry = emptyGroupAreaGeometry();
timeFrequency = dataFrequency.*sr./100;
temporalRbw = spatialRbw.*sr./100;
center = 1./periods;
nOrbit = numel(periods);
candidate = false(numel(dataFrequency),nOrbit);
for j = 1:nOrbit
    if ~eligibleOrbit(j)
        continue
    end
    candidate(:,j) = abs(timeFrequency-center(j)) <= temporalRbw & ...
        timeFrequency <= maximumFrequency + ...
        64*eps(max(1,maximumFrequency));
end
geometry.orbitBandResolved = any(candidate,1)';
activeOrbit = eligibleOrbit & geometry.orbitBandResolved;
groupTemplate = zeros(size(phaseTemplate,1),4);
for j = 1:nOrbit
    if activeOrbit(j)
        groupTemplate(:,groupIndex(j)) = ...
            groupTemplate(:,groupIndex(j))+phaseTemplate(:,j);
    end
end
for group = 1:4
    members = groupIndex == group & activeOrbit;
    geometry.bandIndex{group} = find(any(candidate(:,members),2));
    geometry.activeGroup(group) = any(members) && ...
        ~isempty(geometry.bandIndex{group});
end

upperFrequency = min(maximumFrequency,nativeFrequency(end));
if continuousCrossGroupOverlap(center,temporalRbw,upperFrequency, ...
        activeOrbit,groupIndex)
    geometry.valid = false;
end
nativeDf = mean(diff(nativeFrequency));
for observedGroup = 1:4
    index = geometry.bandIndex{observedGroup};
    if ~isempty(index)
        geometry.leakageMatrix(observedGroup,:) = ...
            sum(groupTemplate(index,:),1).*nativeDf;
    end
end

active = geometry.activeGroup;
if ~any(active)
    geometry.valid = false;
    geometry.rcond = 0;
    return
end
activeMatrix = geometry.leakageMatrix(active,active);
if any(~isfinite(activeMatrix),'all') || ...
        any(diag(activeMatrix) <= 0)
    geometry.valid = false;
    geometry.rcond = 0;
else
    geometry.rcond = rcond(activeMatrix);
    if ~isfinite(geometry.rcond) || geometry.rcond < 1e-10
        geometry.valid = false;
    end
end

% COCONONNEGATIVELEAKAGESOLVE has an audited deterministic four-variable
% implementation. Identity constraints for completely missing groups are
% algebraically equivalent to fixing their group power to zero while the
% active block remains the physical leakage system above.
geometry.solveMatrix = geometry.leakageMatrix;
inactive = find(~active);
for group = inactive(:)'
    geometry.solveMatrix(group,:) = 0;
    geometry.solveMatrix(:,group) = 0;
    geometry.solveMatrix(group,group) = 1;
end
end

function tf = continuousCrossGroupOverlap( ...
        center,rbw,upperFrequency,activeOrbit,groupIndex)
tf = false;
active = find(activeOrbit);
lo = max(0,center-rbw);
hi = min(upperFrequency,center+rbw);
scale = max([1;abs(lo(:));abs(hi(:));abs(upperFrequency)]);
tolerance = 128*eps(scale);
for firstIndex = 1:numel(active)-1
    first = active(firstIndex);
    for secondIndex = firstIndex+1:numel(active)
        second = active(secondIndex);
        if groupIndex(first) == groupIndex(second)
            continue
        end
        overlapWidth = min(hi(first),hi(second))-max(lo(first),lo(second));
        if overlapWidth > tolerance
            tf = true;
            return
        end
    end
end
end

function [amplitude,groupAmplitude,dataEnergy] = ...
        fourGroupAreaAmplitudes( ...
        power,geometry,dataFrequencyStep,groupIndex,activeOrbit)
nSeries = size(power,2);
dataEnergy = zeros(4,nSeries);
for group = 1:4
    index = geometry.bandIndex{group};
    if ~isempty(index)
        dataEnergy(group,:) = sum(power(index,:),1).*dataFrequencyStep;
    end
end
if any(~isfinite(dataEnergy),'all') || any(dataEnergy < 0,'all')
    error('cocoAdaptiveEvaluate:InvalidGroupBandEnergy', ...
        ['A four-group integration band produced nonfinite or negative ', ...
         'energy. Rescale the proxy values or inspect the input spectrum; ', ...
         'invalid band energy cannot be interpreted as zero amplitude.']);
end
solveEnergy = dataEnergy;
solveEnergy(~geometry.activeGroup,:) = 0;
groupPower = cocoNonnegativeLeakageSolve( ...
    geometry.solveMatrix,solveEnergy);
groupPower(~geometry.activeGroup,:) = 0;
maximumPower = max(groupPower,[],1);
negligible = groupPower <= maximumPower.*1e-16;
groupPower(negligible) = 0;
groupAmplitude = sqrt(groupPower);
amplitude = groupAmplitude(groupIndex,:);
amplitude = amplitude.*double(activeOrbit(:));
end

function [index,resolved] = adaptiveBandIndex( ...
        frequency,periods,sr,rbw,maximumFrequency,eligible)
timeFrequency = frequency.*sr./100;
rbwTime = rbw.*sr./100;
center = 1./periods;
candidate = false(numel(frequency),numel(periods));
for j = 1:numel(periods)
    if ~eligible(j)
        continue
    end
    candidate(:,j) = timeFrequency >= center(j)-rbwTime & ...
        timeFrequency <= center(j)+rbwTime & ...
        timeFrequency <= maximumFrequency;
end
for bin = find(sum(candidate,2) > 1)'
    members = find(candidate(bin,:));
    distance = abs(timeFrequency(bin)-center(members));
    minimumDistance = min(distance);
    tied = members(distance == minimumDistance);
    if numel(tied) > 1
        [~,tieChoice] = min(center(tied));
        chosen = tied(tieChoice);
    else
        chosen = tied;
    end
    candidate(bin,members) = false;
    candidate(bin,chosen) = true;
end
index = cell(numel(periods),1);
resolved = false(numel(periods),1);
for j = 1:numel(periods)
    index{j} = find(candidate(:,j));
    resolved(j) = ~isempty(index{j});
end
end

function amplitude = adaptiveAmplitudes( ...
        power,index,unitPeak,active)
nOrbit = numel(index);
nSeries = size(power,2);
peak = zeros(nOrbit,nSeries);
for j = 1:nOrbit
    if active(j)
        peak(j,:) = max(power(index{j},:),[],1);
    end
end
peak(~isfinite(peak) | peak < 0) = 0;
amplitude = zeros(nOrbit,nSeries);
ok = active & isfinite(unitPeak) & unitPeak > 0;
amplitude(ok,:) = sqrt(peak(ok,:)./unitPeak(ok));
end

function rho = columnCorrelation(x,y,method)
nSeries = size(x,2);
if strcmp(method,'Spearman')
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
sumSquareX = sum(xc.^2,1);
sumSquareY = sum(yc.^2,1);
scaleX = max(abs(x0),[],1);
scaleY = max(abs(y0),[],1);
relativeRoundoff = 256*eps(class(x));
toleranceX = n.*(relativeRoundoff.*max(scaleX,realmin(class(x)))).^2;
toleranceY = n.*(relativeRoundoff.*max(scaleY,realmin(class(y)))).^2;
denominator = sqrt(sumSquareX.*sumSquareY);
rho = sum(xc.*yc,1)./denominator;
degenerate = n >= 2 & (sumSquareX <= toleranceX | ...
    sumSquareY <= toleranceY);
rho(degenerate) = 0;
rho(n < 2 | ~isfinite(rho)) = NaN;
end

function [rho,pValue] = correlationWithP(x,y,method)
rho = NaN;
pValue = NaN;
x = x(:);
y = y(:);
ok = isfinite(x) & isfinite(y);
x = x(ok);
y = y(ok);
if numel(x) < 2
    return
end
if effectivelyConstant(x) || effectivelyConstant(y)
    rho = 0;
    pValue = 1;
    return
end
if strcmp(method,'Pearson')
    [r,p] = corrcoef(x,y);
    if numel(r) >= 4
        rho = r(2,1);
        pValue = p(2,1);
    end
else
    [rho,pValue] = corr(x,y,'Type','Spearman');
end
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

function reportProgress(progressFcn,fraction,index,count)
if isempty(progressFcn)
    return
end
try
    progressFcn(fraction,index,count);
catch exception
    warning('cocoAdaptiveEvaluate:ProgressCallbackFailed', ...
        'Progress callback failed: %s',exception.message);
end
end
