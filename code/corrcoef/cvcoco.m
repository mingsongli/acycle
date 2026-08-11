function result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method,varargin)
%CVCOCO Bidirectional held-out cross-validated COCO.
%
% RESULT = CVCOCO(DATA,ORBIT9,PAD,SR1,SR2,SRSTEP,RED,NSIM,METHOD)
% splits a cleaned depth series at its deterministic depth midpoint by
% default.  SPLITMODE='interleaved' instead assigns the sorted unique odd
% observations to the Odd fold and the even observations to the Even fold.
% Each fold is regularized independently at its median depth spacing. In
% each direction, one fold estimates a best sedimentation rate and the
% requested target amplitudes; those amplitudes are frozen while the other
% fold selects its own validation rate. FOUR-GROUP models fit four
% leakage-aware orbital-group amplitudes from union-band energies.
% If a four-group model has no tested rate at which all nine periods are
% resolvable, but at least one well-conditioned resolved group remains in
% each fold, the same observed and Monte Carlo pipelines continue with an
% audited partial-orbit target. Unresolved group weights are fixed to zero,
% and RESULT is marked complete-with-warning/degraded rather than eligible
% for all-nine confirmatory interpretation.
% RAYLEIGH-PEAK-COHERENT-NINE instead calibrates nine separate band maxima
% and freezes all nine relative amplitudes. LEGACY retains its historical
% nine-peak training/four-group-RMS validation behavior. The symmetric
% joint statistic is the smaller directional validation maximum.
%
% A single outer stationary-AR(1) Monte Carlo reproduces the complete
% bidirectional train/validate operation.  There is no inner Monte Carlo.
% Midpoint mode conditions on two deterministic, separately regularized
% sample grids. Interleaved mode simulates one process on the complete raw
% observation order, then repeats the deterministic odd/even split and
% fold-specific interpolation in every realization.
% Directional p-values use each direction's null maximum and therefore
% include the held-out sedimentation-rate search. The pre-specified
% confirmatory gate requires both directional global p-values to pass via
% max(pA,pB) < alpha; PSYM is a secondary whole-flow diagnostic.
% Directional local-p curves are also returned as descriptive diagnostics.
% They repeat the complete training pipeline in every null realization but
% compare the validation statistic at the same sedimentation rate, before
% correction for the held-out validation-rate search.
%
% DATA(:,1) is depth in metres; DATA(:,2) is the proxy value. ORBIT9 is in
% kyr. Its four physical groups are identified by descending period rank:
% one long-eccentricity period, four short-eccentricity periods, one
% obliquity period, and three precession periods. No fixed period cutoffs
% are imposed, because obliquity and precession shorten in deep time.
%
% RED follows the existing COCO convention: 0 none, 1 classical AR(1),
% 2 robust AR(1), 3 smoothed-window background removal. METHOD is
% 'Pearson' or 'Spearman'.
%
% Name-value options:
%   BatchSize  - Monte Carlo realizations per batch (default 100)
%   Seed       - local reproducible RNG seed (default 1)
%   ProgressFcn- function handle called as f(fraction,message), or []
%   TargetModel- 'four-group' (default), 'four-group-coherent-nine',
%                'rayleigh-peak-coherent-nine', or 'legacy'. The two
%                coherent-nine models differ only in amplitude estimation:
%                four-group-coherent-nine integrates four union bands and
%                leakage-corrects their energies; rayleigh-peak-coherent-
%                nine reads one calibrated maximum within plus/minus one
%                Rayleigh of each of the nine nominal orbital frequencies.
%                The legacy engine is retained only for explicit backward-
%                compatible calls.
%   MaxFrequency- maximum temporal frequency included in every spectral
%                correlation, in cycle/kyr. Empty/default uses 1.2 times
%                the highest nominal ORBIT9 frequency for every modern
%                target model and 0.5 only for explicit 'legacy'
%                compatibility. An
%                explicit value must include every nominal orbit frequency.
%   AnalysisName- retained compatibility option. Progress and result
%                 metadata always use Blocked cvCOCO or Interleaved
%                 cvCOCO, according to the selected split design.
%   SplitMode   - 'midpoint' (default) or 'interleaved'. Interleaved mode
%                 splits before interpolation and uses one full raw-order
%                 AR(1) realization per Monte Carlo draw before applying
%                 the same odd/even split and fold-specific interpolation.
%   InterleavedPhase - internal parity phase for sliding-window callers:
%                 0 (default) makes the first cleaned row Odd; 1 makes it
%                 Even, preserving parity assigned on a parent record.
%   Verbose     - print target/preprocessing diagnostics (default true).
%   WarnOnPartialTraining - emit the partial-orbit fallback warning
%                 (default true). Windowed callers may set this false and
%                 aggregate RESULT warning metadata instead.
%
% The routine deliberately contains no GUI, plotting, workspace assignment
% or file I/O.  See PLOTCVCOCO for COCO-style diagnostic figures.
% NSIM=0 is allowed only for diagnostic curve generation; a confirmatory
% report requires Monte Carlo p-values and finite precision intervals.

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'BatchSize',100,@(x) isnumeric(x) && isscalar(x) && ...
    isfinite(x) && x >= 1 && x == fix(x));
addParameter(parser,'Seed',1,@(x) isnumeric(x) && isscalar(x) && ...
    isfinite(x) && x >= 0 && x == fix(x) && x <= 2^32-1);
addParameter(parser,'ProgressFcn',[],@(x) isempty(x) || isa(x,'function_handle'));
addParameter(parser,'TargetModel','four-group',@(x) ischar(x) || ...
    (isstring(x) && isscalar(x)));
addParameter(parser,'MaxFrequency',[],@(x) isempty(x) || ...
    (isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x > 0));
addParameter(parser,'AnalysisName','',@(x) ischar(x) || ...
    (isstring(x) && isscalar(x)));
addParameter(parser,'SplitMode','midpoint',@(x) ischar(x) || ...
    (isstring(x) && isscalar(x)));
addParameter(parser,'InterleavedPhase',0,@(x) isnumeric(x) && isscalar(x) && ...
    isfinite(x) && any(x == [0 1]));
addParameter(parser,'Verbose',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(x == [0 1]));
addParameter(parser,'WarnOnPartialTraining',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(x == [0 1]));
parse(parser,varargin{:});
options = parser.Results;
options.Verbose = logical(options.Verbose);
options.WarnOnPartialTraining = logical(options.WarnOnPartialTraining);
options.TargetModel = validatestring(options.TargetModel, ...
    {'legacy','four-group','four-group-coherent-nine', ...
     'rayleigh-peak-coherent-nine'}, ...
    mfilename,'TargetModel');
options.SplitMode = validatestring(options.SplitMode, ...
    {'midpoint','interleaved'},mfilename,'SplitMode');
isInterleaved = strcmp(options.SplitMode,'interleaved');
isFourGroupTraining = usesFourGroupTraining(options.TargetModel);
isRayleighPeakTraining = usesRayleighPeakTraining(options.TargetModel);
isCoherentNine = usesCoherentNineTarget(options.TargetModel);
analysisName = 'Blocked cvCOCO';
if isInterleaved
    analysisName = 'Interleaved cvCOCO';
end
if isInterleaved
    foldModelDescription = 'one constant rate within each odd/even fold';
    resultFoldLabelA = 'Odd';
    resultFoldLabelB = 'Even';
    diagnosticFoldLabelA = 'Odd fold';
    diagnosticFoldLabelB = 'Even fold';
    heldOutUnitPlural = 'folds';
else
    foldModelDescription = 'one constant rate within each A/B segment';
    resultFoldLabelA = 'Segment A';
    resultFoldLabelB = 'Segment B';
    diagnosticFoldLabelA = 'Segment A';
    diagnosticFoldLabelB = 'Segment B';
    heldOutUnitPlural = 'halves';
end
validateattributes(data,{'numeric'},{'2d','ncols',2,'nonempty','real'}, ...
    mfilename,'data',1);
validateattributes(orbit9,{'numeric'}, ...
    {'vector','numel',9,'real','finite','positive'},mfilename,'orbit9',2);
validateattributes(pad,{'numeric'}, ...
    {'scalar','integer','nonnegative','finite'},mfilename,'pad',3);
validateattributes(sr1,{'numeric'}, ...
    {'scalar','real','positive','finite'},mfilename,'sr1',4);
validateattributes(sr2,{'numeric'}, ...
    {'scalar','real','positive','finite','>=',sr1},mfilename,'sr2',5);
validateattributes(srstep,{'numeric'}, ...
    {'scalar','real','positive','finite'},mfilename,'srstep',6);
validateattributes(red,{'numeric'}, ...
    {'scalar','integer','>=',0,'<=',3,'finite'},mfilename,'red',7);
validateattributes(nsim,{'numeric'}, ...
    {'scalar','integer','nonnegative','finite'},mfilename,'nsim',8);
if nsim > 1e6
    error('cvcoco:MonteCarloRequestTooLarge', ...
        'NSIM must not exceed 1,000,000 in one in-memory cvCOCO run.');
end

method = validatestring(method,{'Pearson','Spearman'},mfilename,'method',9);
orbit9 = orbit9(:);
if numel(unique(orbit9)) ~= numel(orbit9)
    error('cvcoco:DuplicateOrbitPeriods', ...
        'ORBIT9 must contain nine distinct orbital periods.');
end
highestOrbitFrequency = max(1./orbit9);
maximumFrequencyWasDefault = isempty(options.MaxFrequency);
if maximumFrequencyWasDefault
    if ~strcmp(options.TargetModel,'legacy')
        options.MaxFrequency = 1.2*highestOrbitFrequency;
        maximumFrequencySource = ...
            'automatic: 1.2 times highest nominal orbital frequency';
    else
        options.MaxFrequency = 0.5;
        maximumFrequencySource = ...
            'legacy compatibility default: 0.5 cycle/kyr';
    end
else
    maximumFrequencySource = 'explicit user option';
end
frequencyOptionTolerance = 64*eps(max(1,highestOrbitFrequency));
if options.MaxFrequency < highestOrbitFrequency-frequencyOptionTolerance
    error('cvcoco:MaximumFrequencyExcludesOrbit', ...
        ['MaxFrequency (%.12g cycle/kyr) is below the highest nominal ', ...
         'orbital frequency (%.12g cycle/kyr; period %.12g kyr). ', ...
         'Increase MaxFrequency so every requested orbital period is ', ...
         'inside the correlation interval.'],options.MaxFrequency, ...
        highestOrbitFrequency,min(orbit9));
end
if options.Verbose && isFourGroupTraining
    targetCombination = 'phase-averaged noncoherent';
    if isCoherentNine
        targetCombination = 'coherent nine-term';
    end
    fprintf('\n>> %s four-group-trained %s spectral target:\n', ...
        analysisName,targetCombination);
    fprintf('   Sedimentation-rate model: %s.\n',foldModelDescription);
    fprintf(['   Training amplitudes: four-band energy with a 4-by-4 ', ...
        'finite-record leakage matrix and nonnegative least squares.\n']);
    fprintf(['   Validation statistic: spectral correlation up to %.6g ', ...
        'cycle/kyr with the frozen %s target.\n', ...
        '   Frequency-limit rule: %s.\n\n'], ...
        options.MaxFrequency,targetCombination,maximumFrequencySource);
elseif options.Verbose && isRayleighPeakTraining
    fprintf('\n>> %s Rayleigh-peak-trained coherent nine-term spectral target:\n', ...
        analysisName);
    fprintf('   Sedimentation-rate model: %s.\n',foldModelDescription);
    fprintf(['   Training amplitudes: nine separately calibrated PSD maxima ', ...
        'within plus/minus one Rayleigh of the nominal orbital frequencies.\n']);
    fprintf(['   Validation statistic: spectral correlation up to %.6g ', ...
        'cycle/kyr with the nine frozen relative amplitudes.\n', ...
        '   Frequency-limit rule: %s.\n\n'], ...
        options.MaxFrequency,maximumFrequencySource);
end
groups = defineOrbitGroups(orbit9);
nRateEstimate = floor((sr2-sr1)/srstep)+1;
if ~isfinite(nRateEstimate) || nRateEstimate > 10000
    error('cvcoco:SedimentationRateGridTooLarge', ...
        ['The requested grid contains approximately %g sedimentation ', ...
         'rates. Reduce the range or increase SRSTEP.'],nRateEstimate);
end
srGrid = (sr1:srstep:sr2)';
if isempty(srGrid)
    error('cvcoco:EmptySedimentationRateGrid', ...
        'The sedimentation-rate grid is empty.');
end

[dataClean,dataA,dataB,splitDepth,spacingA,spacingB,interpA,interpB, ...
    rawFoldIndexA,rawFoldIndexB] = prepareHeldOutData( ...
    data,analysisName,options.SplitMode,options.InterleavedPhase, ...
    options.Verbose);
reportProgress(options.ProgressFcn,0, ...
    sprintf('Preparing %s frequency geometry.',analysisName));

detrendedA = detrend(dataA(:,2),1);
detrendedB = detrend(dataB(:,2),1);
[resolvedA,dataStdA] = cocoResolvedDetrendedVariance( ...
    dataA(:,2),detrendedA);
[resolvedB,dataStdB] = cocoResolvedDetrendedVariance( ...
    dataB(:,2),detrendedB);
if ~resolvedA || ~resolvedB
    error('cvcoco:ZeroVariance', ...
        ['Each held-out fold must retain numerically resolved variance ', ...
         'after linear detrending; constant or affine-only folds are ', ...
         'not valid spectral observations.']);
end
% Fit transparent conditional-least-squares AR(1) coefficients on both
% regularized folds. Midpoint mode uses them directly; interleaved mode
% retains them only as diagnostics because its dependent folds require one
% coefficient estimated on the complete raw observation order.
[rhoMA,rhoMethodA] = estimateRhoM(detrendedA);
[rhoMB,rhoMethodB] = estimateRhoM(detrendedB);
dataStdFull = NaN;
if isInterleaved
    % Odd and even folds contain adjacent observations from the same
    % record.  Their nulls must therefore come from one jointly simulated
    % process rather than two independent fold-specific processes.
    detrendedFull = detrend(dataClean(:,2),1);
    [resolvedFull,dataStdFull] = cocoResolvedDetrendedVariance( ...
        dataClean(:,2),detrendedFull);
    if ~resolvedFull
        error('cvcoco:ZeroVariance', ...
            ['The complete cleaned series must retain numerically resolved ', ...
             'variance after linear detrending for an interleaved null.']);
    end
    [rhoM,~] = estimateRhoM(detrendedFull);
    rhoMethod = [ ...
        'conditional least-squares AR(1) on the linearly detrended ', ...
        'complete sorted raw observation order'];
else
    rhoM = mean([rhoMA,rhoMB]); % compatibility summary; not simulated
    rhoMethod = 'compatibility mean of segment-specific CLS coefficients';
end

% The noncoherent four-group engine retains one four-column target template
% per rate and segment. The coherent-nine four-group engine additionally
% retains the complex nine-column sine basis, while the Rayleigh-peak and
% legacy engines keep only that basis. Reject a request before allocation
% if those caches alone would be unreasonably large.
nFrequencyA = floor(max(pad,size(dataA,1))/2)+1;
nFrequencyB = floor(max(pad,size(dataB,1))/2)+1;
if strcmp(options.TargetModel,'four-group')
    storedDoubleEquivalentsPerBin = 4;
elseif strcmp(options.TargetModel,'four-group-coherent-nine')
    storedDoubleEquivalentsPerBin = 22; % four real + nine complex columns
else
    storedDoubleEquivalentsPerBin = 18; % nine complex sine-basis values
end
estimatedGeometryBytes = 8*storedDoubleEquivalentsPerBin* ...
    numel(srGrid)*(nFrequencyA+nFrequencyB);
geometryMemoryBudget = 512*1024^2;
if estimatedGeometryBytes > geometryMemoryBudget
    error('cvcoco:GeometryRequestTooLarge', ...
        ['The requested Pad/rate grid would require approximately %.3g MiB ', ...
         'for reusable target geometry alone (safety limit %.3g MiB). ', ...
         'Reduce Pad, narrow the rate range, or increase SRSTEP.'], ...
        estimatedGeometryBytes/1024^2,geometryMemoryBudget/1024^2);
end

geomA = prepareGeometry(dataA(:,1),orbit9,srGrid,pad,groups, ...
    options.TargetModel,options.MaxFrequency);
geomB = prepareGeometry(dataB(:,1),orbit9,srGrid,pad,groups, ...
    options.TargetModel,options.MaxFrequency);
if ~any(geomA.validRateMask) || ~any(geomB.validRateMask)
    error('cvcoco:NoValidSedimentationRate', ...
        ['No tested sedimentation rate has usable frequency geometry in ', ...
         'both held-out %s. Use a longer record, widen the rate range, ', ...
         'or revise the sampling interval. Numerically valid rates: ', ...
         '%s %d of %d; %s %d of %d.'],heldOutUnitPlural, ...
        diagnosticFoldLabelA, ...
        nnz(geomA.validRateMask),numel(srGrid), ...
        diagnosticFoldLabelB, ...
        nnz(geomB.validRateMask),numel(srGrid));
end
degradedMode = false;
trainingCompletenessA = 'complete-nine';
trainingCompletenessB = 'complete-nine';
trainingWarningIdentifier = '';
trainingWarningMessage = '';
strictTrainingRateMaskA = geomA.strictTrainingRateMask;
strictTrainingRateMaskB = geomB.strictTrainingRateMask;
if ~any(strictTrainingRateMaskA) || ~any(strictTrainingRateMaskB)
    canUsePartialFourGroup = isFourGroupTraining && ...
        any(geomA.partialTrainingRateMask) && ...
        any(geomB.partialTrainingRateMask);
    if canUsePartialFourGroup
        degradedMode = true;
        if ~any(strictTrainingRateMaskA)
            geomA.trainingRateMask = geomA.partialTrainingRateMask;
            trainingCompletenessA = 'partial-orbit';
        end
        if ~any(strictTrainingRateMaskB)
            geomB.trainingRateMask = geomB.partialTrainingRateMask;
            trainingCompletenessB = 'partial-orbit';
        end
        if isInterleaved
            trainingWarningIdentifier = ...
                'Acycle:InterleavedCVCOCO:PartialOrbitTraining';
        else
            trainingWarningIdentifier = ...
                'Acycle:BlockedCVCOCO:PartialOrbitTraining';
        end
        trainingWarningMessage = sprintf([ ...
            '%s has no tested rate that supports complete all-nine ', ...
            'training in at least one held-out unit. Continuing with an ', ...
            'audited partial-orbit four-group target: only physically ', ...
            'resolved groups are leakage-fitted at each eligible training ', ...
            'rate, and unresolved group weights are fixed exactly to zero. ', ...
            'This result is degraded/exploratory rather than an all-nine ', ...
            'confirmatory result. Effective training rates: %s %d of %d; ', ...
            '%s %d of %d. Theoretical all-nine ranges (cm/kyr): %s ', ...
            '(%.6g, %.6g], %s (%.6g, %.6g].'], ...
            analysisName,diagnosticFoldLabelA, ...
            nnz(geomA.trainingRateMask),numel(srGrid), ...
            diagnosticFoldLabelB,nnz(geomB.trainingRateMask), ...
            numel(srGrid),diagnosticFoldLabelA, ...
            geomA.allNineRateRange(1),geomA.allNineRateRange(2), ...
            diagnosticFoldLabelB,geomB.allNineRateRange(1), ...
            geomB.allNineRateRange(2));
        if options.WarnOnPartialTraining
            warning(trainingWarningIdentifier,'%s',trainingWarningMessage);
        end
    elseif isRayleighPeakTraining
        error('cvcoco:NoAllNineTrainingRate', ...
            ['%s must train all nine separately calibrated Rayleigh-peak ', ...
             'amplitudes at a tested rate where every period is ', ...
             'frequency-resolvable and every unit-sine calibration peak ', ...
             'is positive. No such grid point exists in at least one ', ...
             'held-out unit. Theoretical all-nine ranges (cm/kyr): %s ', ...
             '(%.6g, %.6g], %s (%.6g, %.6g]. Widen/refine the ', ...
             'tested grid, use a longer/finer sampled record, or inspect ', ...
             'the orbital band geometry.'],analysisName, ...
            diagnosticFoldLabelA, ...
            geomA.allNineRateRange(1),geomA.allNineRateRange(2), ...
            diagnosticFoldLabelB, ...
            geomB.allNineRateRange(1),geomB.allNineRateRange(2));
    else
        trainingTargetDescription = 'the complete four-group target';
        if strcmp(options.TargetModel,'legacy')
            trainingTargetDescription = ...
                'the complete legacy nine-period target';
        end
        error('cvcoco:NoAllNineTrainingRate', ...
            ['%s must train %s at a tested ', ...
             'rate where all nine periods are resolvable. No such grid point ', ...
             'exists in at least one held-out unit, and no numerically ', ...
             'valid partial-orbit four-group fallback is available. ', ...
             'Theoretical all-nine ranges (cm/kyr): %s (%.6g, %.6g], ', ...
             '%s (%.6g, %.6g]. Continuous cross-group training-band ', ...
             'overlaps: %s %d rates; %s %d rates. Ill-conditioned leakage ', ...
             'matrices (rcond < %.3g): %s %d rates; %s %d rates. ', ...
             'Widen/refine the tested grid, use a longer/finer sampled ', ...
             'record, or inspect the orbital band geometry.'], ...
            analysisName,trainingTargetDescription,diagnosticFoldLabelA, ...
            geomA.allNineRateRange(1),geomA.allNineRateRange(2), ...
            diagnosticFoldLabelB,geomB.allNineRateRange(1), ...
            geomB.allNineRateRange(2),diagnosticFoldLabelA, ...
            nnz(geomA.crossGroupBandOverlap),diagnosticFoldLabelB, ...
            nnz(geomB.crossGroupBandOverlap), ...
            geomA.minimumLeakageRcond,diagnosticFoldLabelA, ...
            nnz(geomA.orbitCount == 9 & ~geomA.crossGroupBandOverlap & ...
                geomA.groupLeakageRcond < geomA.minimumLeakageRcond), ...
            diagnosticFoldLabelB, ...
            nnz(geomB.orbitCount == 9 & ~geomB.crossGroupBandOverlap & ...
                geomB.groupLeakageRcond < geomB.minimumLeakageRcond));
    end
end

% Observed spectra are calculated once. Sedimentation rate changes only
% their frequency units, not their spatial-domain periodogram powers.
[powerA,fA] = spectrumBatch(dataA(:,2),geomA,red);
[powerB,fB] = spectrumBatch(dataB(:,2),geomB,red);
if max(abs(fA-geomA.frequency)) > frequencyTolerance(geomA.frequency) || ...
        max(abs(fB-geomB.frequency)) > frequencyTolerance(geomB.frequency)
    error('cvcoco:InternalFrequencyMismatch', ...
        'The periodogram and precomputed frequency grids do not match.');
end

[curveA,bestA,ampA] = adaptiveTrain(powerA,geomA,method,true);
[curveB,bestB,ampB] = adaptiveTrain(powerB,geomB,method,true);
[groupRawA,groupNormA] = groupAmplitudes(ampA,groups);
[groupRawB,groupNormB] = groupAmplitudes(ampB,groups);
orbitNormA = normalizeOrbitAmplitudes(ampA);
orbitNormB = normalizeOrbitAmplitudes(ampB);
frozenA = frozenValidationWeights( ...
    options.TargetModel,groupNormA,orbitNormA);
frozenB = frozenValidationWeights( ...
    options.TargetModel,groupNormB,orbitNormB);
if any(~isfinite(frozenA),'all') || any(~isfinite(frozenB),'all')
    error('cvcoco:InvalidTrainedWeights', ...
        ['At least one training fold produced nonfinite frozen target ', ...
         'weights. Check the tested rates, record length, variance, and ', ...
         'red-noise removal settings.']);
end

[curveAtoB,scoreAtoB,bestBfromA] = ...
    fixedValidate(powerB,geomB,frozenA,method,true);
[curveBtoA,scoreBtoA,bestAfromB] = ...
    fixedValidate(powerA,geomA,frozenB,method,true);

% The evolutionary interleaved engine needs a same-rate bidirectional
% surface, not merely the historical minimum of two independently located
% directional maxima. Keep both definitions explicit and backward
% compatible: scoreSymmetric is the historical diagnostic, whereas
% scoreConsensus is max_r min(direction_1(r),direction_2(r)).
curveConsensus = minFinitePair(curveAtoB,curveBtoA);
[scoreConsensus,bestRateConsensus,bestIndexConsensus] = ...
    finiteCurveMaximum(curveConsensus,srGrid);
scoreSymmetric = minFinitePair(scoreAtoB,scoreBtoA);
scoreMean = meanFinitePair(scoreAtoB,scoreBtoA);

nullSymmetric = nan(nsim,1);
nullConsensus = nan(nsim,1);
nullAtoB = nan(nsim,1);
nullBtoA = nan(nsim,1);
nullBestRateAtoB = nan(nsim,1);
nullBestRateBtoA = nan(nsim,1);
nRate = numel(srGrid);
localExceedanceCountAtoB = zeros(nRate,1);
localExceedanceCountBtoA = zeros(nRate,1);
localExceedanceCountConsensus = zeros(nRate,1);
localValidCountAtoB = zeros(nRate,1);
localValidCountBtoA = zeros(nRate,1);
localValidCountConsensus = zeros(nRate,1);
nsimCompleted = 0;
actualBatchSize = 0;
if nsim > 0
    previousRng = rng;
    restoreRng = onCleanup(@() rng(previousRng));
    rng(options.Seed,'twister');

    nA = size(dataA,1);
    nB = size(dataB,1);
    if isInterleaved
        nTotal = size(dataClean,1);
        rawDepthA = dataClean(rawFoldIndexA,1);
        rawDepthB = dataClean(rawFoldIndexB,1);
    else
        nTotal = nA+nB;
    end
    % Bound simultaneous innovations, surrogates, spectra, and target
    % workspaces.  BatchSize is a requested upper bound, not permission to
    % allocate an arbitrarily large matrix.
    batchMemoryBudget = 256*1024^2;
    sampleWorkspaceCount = nTotal;
    if isInterleaved
        sampleWorkspaceCount = sampleWorkspaceCount+nA+nB;
    end
    bytesPerSimulation = 64*max(1, ...
        sampleWorkspaceCount+nFrequencyA+nFrequencyB+2*nRate);
    memoryLimitedBatchSize = max(1,floor( ...
        batchMemoryBudget/bytesPerSimulation));
    actualBatchSize = min([options.BatchSize,nsim,memoryLimitedBatchSize]);
    if isInterleaved
        innovationStdFull = sqrt(max(0,1-rhoM^2));
    else
        innovationStdA = sqrt(max(0,1-rhoMA^2));
        innovationStdB = sqrt(max(0,1-rhoMB^2));
    end

    for first = 1:actualBatchSize:nsim
        last = min(first+actualBatchSize-1,nsim);
        nBatch = last-first+1;

        innovations = randn(nTotal,nBatch);
        if isInterleaved
            if nTotal > 1
                innovations(2:end,:) = ...
                    innovationStdFull .* innovations(2:end,:);
            end
            surrogateFull = dataStdFull .* ...
                filter(1,[1,-rhoM],innovations,[],1);
            % Apply the same deterministic split and interpolation grids as
            % the observed data. INTERP1 acts column-wise, so every draw
            % retains the cross-fold dependence of its parent realization.
            surrogateA = interp1(rawDepthA, ...
                surrogateFull(rawFoldIndexA,:), ...
                dataA(:,1),'linear');
            surrogateB = interp1(rawDepthB, ...
                surrogateFull(rawFoldIndexB,:), ...
                dataB(:,1),'linear');
            if any(~isfinite(surrogateA),'all') || ...
                    any(~isfinite(surrogateB),'all')
                error('cvcoco:InvalidInterleavedInterpolation', ...
                    ['The fixed odd/even interpolation map produced ', ...
                     'nonfinite Monte Carlo values.']);
            end
        else
            innovationsA = innovations(1:nA,:);
            innovationsB = innovations(nA+1:end,:);
            if nA > 1
                innovationsA(2:end,:) = innovationStdA .* innovationsA(2:end,:);
            end
            if nB > 1
                innovationsB(2:end,:) = innovationStdB .* innovationsB(2:end,:);
            end
            surrogateA = dataStdA .* ...
                filter(1,[1,-rhoMA],innovationsA,[],1);
            surrogateB = dataStdB .* ...
                filter(1,[1,-rhoMB],innovationsB,[],1);
        end

        [pA,~] = spectrumBatch(surrogateA,geomA,red);
        [pB,~] = spectrumBatch(surrogateB,geomB,red);

        [~,~,simAmpA] = adaptiveTrain(pA,geomA,method,false);
        [~,simGroupA] = groupAmplitudes(simAmpA,groups);
        simOrbitA = normalizeOrbitAmplitudes(simAmpA);
        simFrozenA = frozenValidationWeights( ...
            options.TargetModel,simGroupA,simOrbitA);
        [simCurveAtoB,simScoreAtoB,simBestRateAtoB] = ...
            fixedValidate(pB,geomB,simFrozenA,method,true);
        [localExceedanceCountAtoB,localValidCountAtoB] = ...
            accumulatePointwiseExceedance(simCurveAtoB,curveAtoB, ...
            localExceedanceCountAtoB,localValidCountAtoB);

        [~,~,simAmpB] = adaptiveTrain(pB,geomB,method,false);
        [~,simGroupB] = groupAmplitudes(simAmpB,groups);
        simOrbitB = normalizeOrbitAmplitudes(simAmpB);
        simFrozenB = frozenValidationWeights( ...
            options.TargetModel,simGroupB,simOrbitB);
        [simCurveBtoA,simScoreBtoA,simBestRateBtoA] = ...
            fixedValidate(pA,geomA,simFrozenB,method,true);
        [localExceedanceCountBtoA,localValidCountBtoA] = ...
            accumulatePointwiseExceedance(simCurveBtoA,curveBtoA, ...
            localExceedanceCountBtoA,localValidCountBtoA);

        simCurveConsensus = minFinitePair(simCurveAtoB,simCurveBtoA);
        [localExceedanceCountConsensus,localValidCountConsensus] = ...
            accumulatePointwiseExceedance( ...
            simCurveConsensus,curveConsensus, ...
            localExceedanceCountConsensus,localValidCountConsensus);
        nullConsensus(first:last) = ...
            maxFiniteColumns(simCurveConsensus).';
        clear simCurveAtoB simCurveBtoA simCurveConsensus

        simSym = minFinitePair(simScoreAtoB,simScoreBtoA);
        nullAtoB(first:last) = simScoreAtoB(:);
        nullBtoA(first:last) = simScoreBtoA(:);
        nullBestRateAtoB(first:last) = simBestRateAtoB(:);
        nullBestRateBtoA(first:last) = simBestRateBtoA(:);
        nullSymmetric(first:last) = simSym(:);
        nsimCompleted = last;
        reportProgress(options.ProgressFcn,0.98*last/nsim, ...
            sprintf('%s Monte Carlo: %d of %d',analysisName,last,nsim));
    end
end

nullSymmetric = nullSymmetric(1:nsimCompleted);
nullConsensus = nullConsensus(1:nsimCompleted);
nullAtoB = nullAtoB(1:nsimCompleted);
nullBtoA = nullBtoA(1:nsimCompleted);
nullBestRateAtoB = nullBestRateAtoB(1:nsimCompleted);
nullBestRateBtoA = nullBestRateBtoA(1:nsimCompleted);

[pSym,nsimValid,~,pSymCI] = monteCarloP(nullSymmetric,scoreSymmetric);
[pConsensus,nsimValidConsensus,~,pConsensusCI] = ...
    monteCarloP(nullConsensus,scoreConsensus);
[pAtoB,nsimValidAtoB,~,pAtoBCI] = ...
    monteCarloP(nullAtoB,scoreAtoB);
[pBtoA,nsimValidBtoA,~,pBtoACI] = ...
    monteCarloP(nullBtoA,scoreBtoA);
if nsimCompleted > 0 && (nsimValid ~= nsimCompleted || ...
        nsimValidConsensus ~= nsimCompleted || ...
        nsimValidAtoB ~= nsimCompleted || nsimValidBtoA ~= nsimCompleted)
    error('cvcoco:InvalidMonteCarloStatistics', ...
        ['At least one full-pipeline Monte Carlo realization produced a ', ...
         'nonfinite directional or symmetric statistic. No simulations ', ...
         'were discarded: revise the rate grid or processing settings. ', ...
         'Finite symmetric/consensus/A-to-B/B-to-A counts: ', ...
         '%d/%d/%d/%d of %d.'], ...
        nsimValid,nsimValidConsensus,nsimValidAtoB, ...
        nsimValidBtoA,nsimCompleted);
end
validatePointwiseSimulationCounts(localValidCountAtoB,curveAtoB, ...
    nsimCompleted,'A-to-B');
validatePointwiseSimulationCounts(localValidCountBtoA,curveBtoA, ...
    nsimCompleted,'B-to-A');
validatePointwiseSimulationCounts(localValidCountConsensus, ...
    curveConsensus,nsimCompleted,'same-rate consensus');
pCurveAtoB = maxStatisticPCurve(nullAtoB,curveAtoB);
pCurveBtoA = maxStatisticPCurve(nullBtoA,curveBtoA);
pCurveConsensus = maxStatisticPCurve(nullConsensus,curveConsensus);
pLocalCurveAtoB = pointwisePCurve(localExceedanceCountAtoB, ...
    localValidCountAtoB,curveAtoB);
pLocalCurveBtoA = pointwisePCurve(localExceedanceCountBtoA, ...
    localValidCountBtoA,curveBtoA);
pLocalCurveConsensus = pointwisePCurve( ...
    localExceedanceCountConsensus,localValidCountConsensus,curveConsensus);
validateGlobalLocalOrdering(pCurveAtoB,pLocalCurveAtoB,'A-to-B');
validateGlobalLocalOrdering(pCurveBtoA,pLocalCurveBtoA,'B-to-A');
validateGlobalLocalOrdering(pCurveConsensus,pLocalCurveConsensus, ...
    'same-rate consensus');
pCOCO = pcocoCurve(curveConsensus,pCurveConsensus);
[bestPCOCO,bestPCOCORate,bestPCOCOIndex] = ...
    finiteCurveMaximum(pCOCO,srGrid);

trainA = makeTrainResult(curveA,bestA,ampA,orbitNormA,groupRawA,groupNormA, ...
    srGrid,geomA.trainingRateMask);
trainB = makeTrainResult(curveB,bestB,ampB,orbitNormB,groupRawB,groupNormB, ...
    srGrid,geomB.trainingRateMask);
trainA.frozenValidationWeights = frozenA(:);
trainB.frozenValidationWeights = frozenB(:);
trainA.frozenValidationWeightLevel = ...
    frozenValidationWeightLevel(options.TargetModel);
trainB.frozenValidationWeightLevel = ...
    frozenValidationWeightLevel(options.TargetModel);
trainA = attachTrainingLeakage(trainA,geomA);
trainB = attachTrainingLeakage(trainB,geomB);
validateAtoB = makeValidationResult(curveAtoB,scoreAtoB,bestBfromA, ...
    srGrid,geomB.validRateMask);
validateBtoA = makeValidationResult(curveBtoA,scoreBtoA,bestAfromB, ...
    srGrid,geomA.validRateMask);
validateAtoB = attachParticipation(validateAtoB,geomB,frozenA);
validateBtoA = attachParticipation(validateBtoA,geomA,frozenB);
[activeOrbitCountAtoB,activeGroupCountAtoB] = ...
    activeOrbitCountCurve(geomB,frozenA);
[activeOrbitCountBtoA,activeGroupCountBtoA] = ...
    activeOrbitCountCurve(geomA,frozenB);
activeMaskAtoB = geomB.resolvedOrbitMask & ...
    activeOrbitWeights(geomB,frozenA)';
activeMaskBtoA = geomA.resolvedOrbitMask & ...
    activeOrbitWeights(geomA,frozenB)';
activeOrbitCountConsensus = sum(activeMaskAtoB & activeMaskBtoA,2);
validateAtoB.pDirectional = pAtoB;
validateAtoB.pConfidenceInterval = pAtoBCI;
validateAtoB.pGlobalCurve = pCurveAtoB;
validateAtoB.pLocalCurve = pLocalCurveAtoB;
validateAtoB.pLocalAtBest = valueAtIndex( ...
    pLocalCurveAtoB,validateAtoB.bestIndex);
validateBtoA.pDirectional = pBtoA;
validateBtoA.pConfidenceInterval = pBtoACI;
validateBtoA.pGlobalCurve = pCurveBtoA;
validateBtoA.pLocalCurve = pLocalCurveBtoA;
validateBtoA.pLocalAtBest = valueAtIndex( ...
    pLocalCurveBtoA,validateBtoA.bestIndex);

consensus = makeValidationResult(curveConsensus,scoreConsensus, ...
    bestRateConsensus,srGrid,geomA.validRateMask & geomB.validRateMask);
consensus.bestIndex = bestIndexConsensus;
consensus.bestCorrelation = scoreConsensus;
consensus.pGlobal = pConsensus;
consensus.pConfidenceInterval = pConsensusCI;
consensus.pGlobalCurve = pCurveConsensus;
consensus.pLocalCurve = pLocalCurveConsensus;
consensus.pGlobalAtBest = valueAtIndex( ...
    pCurveConsensus,bestIndexConsensus);
consensus.pLocalAtBest = valueAtIndex( ...
    pLocalCurveConsensus,bestIndexConsensus);
consensus.pDirectionalMax = maxFinitePair(pAtoB,pBtoA);
consensus.pDirectionalMaxCurve = ...
    maxFinitePair(pCurveAtoB,pCurveBtoA);
consensus.activeOrbitCountCurve = activeOrbitCountConsensus;
consensus.activeOrbitCountAtBest = valueAtIndex( ...
    activeOrbitCountConsensus,bestIndexConsensus);
consensus.nullMaximum = nullConsensus;
consensus.localExceedanceCount = localExceedanceCountConsensus;
consensus.localValidCount = localValidCountConsensus;
consensus.pCOCO = pCOCO;
consensus.bestPCOCO = bestPCOCO;
consensus.bestPCOCORate = bestPCOCORate;
consensus.bestPCOCOIndex = bestPCOCOIndex;

spectra = struct;
spectra.trainA = spectrumDiagnostic(powerA,geomA,bestA,ampA,'adaptive');
spectra.trainB = spectrumDiagnostic(powerB,geomB,bestB,ampB,'adaptive');
spectra.validateAtoB = spectrumDiagnostic( ...
    powerB,geomB,bestBfromA,frozenA,'fixed');
spectra.validateBtoA = spectrumDiagnostic( ...
    powerA,geomA,bestAfromB,frozenB,'fixed');

if isInterleaved
    foldLabels = {resultFoldLabelA;resultFoldLabelB};
    splitRule = ...
        ['sorted unique observations use parent-record parity: odd rows ', ...
         'in Odd fold and even rows in Even fold'];
    interpolationRule = ...
        'separate linear interpolation at each odd/even fold''s median spacing';
    nullConditioning = [ ...
        'one stationary Gaussian AR(1) null on the complete sorted raw ', ...
        'observation order; each realization is split into odd/even ', ...
        'observations and passed through the fixed fold-specific linear ', ...
        'interpolation grids before the complete bidirectional pipeline'];
    rhoRule = [ ...
        'one conditional-least-squares sample-lag rho on the complete ', ...
        'linearly detrended sorted raw observation order; odd/even fold ', ...
        'rho values are diagnostics and are not simulated'];
else
    rawFoldIndexA = find(dataClean(:,1) <= splitDepth);
    rawFoldIndexB = find(dataClean(:,1) > splitDepth);
    foldLabels = {resultFoldLabelA;resultFoldLabelB};
    splitRule = 'depth midpoint';
    interpolationRule = ...
        'separate linear interpolation at each half''s median spacing';
    nullConditioning = [ ...
        'independent stationary Gaussian AR(1) nulls on the separately ', ...
        'regularized A/B sample grids; raw irregular sampling and ', ...
        'interpolation are conditioned on, not resimulated'];
    rhoRule = [ ...
        'one conditional-least-squares sample-lag rho per separately ', ...
        'detrended half; the split boundary is excluded'];
end

result = struct;
result.name = analysisName;
result.publicName = analysisName;
result.abbreviation = analysisName;
result.supported = true;
result.degradedMode = degradedMode;
if degradedMode
    result.status = 'complete-with-warning';
    result.trainingCompleteness = 'partial-orbit';
else
    result.status = 'complete';
    result.trainingCompleteness = 'complete-nine';
end
result.trainingCompletenessA = trainingCompletenessA;
result.trainingCompletenessB = trainingCompletenessB;
result.warningIdentifier = trainingWarningIdentifier;
result.warningMessage = trainingWarningMessage;
if degradedMode
    result.analysisRole = [ ...
        'Partial-orbit exploratory bidirectional held-out analysis; ', ...
        'not eligible for complete all-nine confirmation'];
else
    result.analysisRole = 'Bidirectional held-out analysis';
end
result.targetModel = options.TargetModel;
result.amplitudeMethod = targetAmplitudeMethod(options.TargetModel);
result.frozenValidationWeightLevel = ...
    frozenValidationWeightLevel(options.TargetModel);
result.srGrid = srGrid;
result.splitDepth = splitDepth;
result.splitMode = options.SplitMode;
result.interleavedPhase = options.InterleavedPhase;
result.foldLabels = foldLabels;
result.rawFoldIndexA = rawFoldIndexA;
result.rawFoldIndexB = rawFoldIndexB;
result.rawDataA = dataClean(rawFoldIndexA,:);
result.rawDataB = dataClean(rawFoldIndexB,:);
result.inputMedianSpacing = median(diff(dataClean(:,1)));
result.samplingIntervalA = spacingA;
result.samplingIntervalB = spacingB;
result.interpolationA = interpA;
result.interpolationB = interpB;
result.dataClean = dataClean;
result.dataA = dataA;
result.dataB = dataB;
result.trainA = trainA;
result.trainB = trainB;
result.validateAtoB = validateAtoB;
result.validateBtoA = validateBtoA;
result.consensus = consensus;
result.spectra = spectra;
result.AtoB = validateAtoB;
result.BtoA = validateBtoA;
result.scoreSymmetric = scoreSymmetric;
result.scoreConsensus = scoreConsensus;
result.scoreMean = scoreMean;
result.nullSymmetric = nullSymmetric;
result.nullConsensus = nullConsensus;
result.nullAtoB = nullAtoB;
result.nullBtoA = nullBtoA;
result.nullBestRateAtoB = nullBestRateAtoB;
result.nullBestRateBtoA = nullBestRateBtoA;
result.pSym = pSym;
result.pSymConfidenceInterval = pSymCI;
result.pConsensus = pConsensus;
result.pConsensusConfidenceInterval = pConsensusCI;
result.pRobust = maxFinitePair(pAtoB,pBtoA);
result.pAtoB = pAtoB;
result.pBtoA = pBtoA;
% pA evaluates Fold A held out (B -> A); pB evaluates Fold B held out
% (A -> B). Direction-named fields above avoid any ambiguity.
result.pA = pBtoA;
result.pB = pAtoB;
result.pAConfidenceInterval = pBtoACI;
result.pBConfidenceInterval = pAtoBCI;
result.pCurveAtoB = pCurveAtoB;
result.pCurveBtoA = pCurveBtoA;
result.pLocalCurveAtoB = pLocalCurveAtoB;
result.pLocalCurveBtoA = pLocalCurveBtoA;
result.pCurveConsensus = pCurveConsensus;
result.pLocalCurveConsensus = pLocalCurveConsensus;
result.pCOCO = pCOCO;
result.bestPCOCO = bestPCOCO;
result.bestPCOCORate = bestPCOCORate;
result.bestPCOCOIndex = bestPCOCOIndex;
result.pCOCODefinition = [ ...
    'same-rate minimum consensus rho multiplied by abs(log10(', ...
    'joint full-pipeline consensus global p))'];
result.localExceedanceCountAtoB = localExceedanceCountAtoB;
result.localExceedanceCountBtoA = localExceedanceCountBtoA;
result.localValidCountAtoB = localValidCountAtoB;
result.localValidCountBtoA = localValidCountBtoA;
result.localExceedanceCountConsensus = localExceedanceCountConsensus;
result.localValidCountConsensus = localValidCountConsensus;
result.rhoM = rhoM;
result.rhoMethod = rhoMethod;
result.rhoMA = rhoMA;
result.rhoMB = rhoMB;
result.rhoMethodA = rhoMethodA;
result.rhoMethodB = rhoMethodB;
result.rhoMUsedInNull = isInterleaved;
result.rhoMAUsedInNull = ~isInterleaved;
result.rhoMBUsedInNull = ~isInterleaved;
result.nsimRequested = nsim;
result.nsimCompleted = nsimCompleted;
result.nsimValid = nsimValid;
result.nsimValidConsensus = nsimValidConsensus;
result.nsimValidAtoB = nsimValidAtoB;
result.nsimValidBtoA = nsimValidBtoA;
result.seed = options.Seed;
result.orbitPeriods = orbit9;
result.groupNames = groups.names;
result.groupIndex = groups.index;
result.validRateMaskA = geomA.validRateMask;
result.validRateMaskB = geomB.validRateMask;
result.trainingRateMaskA = geomA.trainingRateMask;
result.trainingRateMaskB = geomB.trainingRateMask;
result.strictTrainingRateMaskA = strictTrainingRateMaskA;
result.strictTrainingRateMaskB = strictTrainingRateMaskB;
result.partialTrainingRateMaskA = geomA.partialTrainingRateMask;
result.partialTrainingRateMaskB = geomB.partialTrainingRateMask;
result.partialOnlyTrainingRateMaskA = ...
    geomA.partialTrainingRateMask & ~strictTrainingRateMaskA;
result.partialOnlyTrainingRateMaskB = ...
    geomB.partialTrainingRateMask & ~strictTrainingRateMaskB;
result.trainingActiveGroupMaskA = geomA.trainingActiveGroupMask;
result.trainingActiveGroupMaskB = geomB.trainingActiveGroupMask;
% Correlations remain available outside the strict all-nine resolution
% range, as in Fixed-target COCO.  The count decreases one period at a time
% when individual periods cross the Rayleigh or Nyquist boundary.
result.orbitCountA = geomA.orbitCount;
result.orbitCountB = geomB.orbitCount;
result.resolvableOrbitCountA = geomA.orbitCount;
result.resolvableOrbitCountB = geomB.orbitCount;
result.resolvableGroupCountA = geomA.resolvedGroupCount;
result.resolvableGroupCountB = geomB.resolvedGroupCount;
result.resolvedOrbitMaskA = geomA.resolvedOrbitMask;
result.resolvedOrbitMaskB = geomB.resolvedOrbitMask;
result.activeOrbitCountAtoB = activeOrbitCountAtoB;
result.activeOrbitCountBtoA = activeOrbitCountBtoA;
result.activeGroupCountAtoB = activeGroupCountAtoB;
result.activeGroupCountBtoA = activeGroupCountBtoA;
result.activeOrbitCountConsensus = activeOrbitCountConsensus;
result.crossGroupBandOverlapA = geomA.crossGroupBandOverlap;
result.crossGroupBandOverlapB = geomB.crossGroupBandOverlap;
% The public leakage-rcond curves describe the matrix actually solved at
% each rate (the active-group submatrix). Keep the raw full 4-by-4 value
% separately so a partial fit never appears ineligible merely because an
% intentionally inactive row/column is singular.
result.groupLeakageRcondA = geomA.partialGroupLeakageRcond;
result.groupLeakageRcondB = geomB.partialGroupLeakageRcond;
result.partialGroupLeakageRcondA = geomA.partialGroupLeakageRcond;
result.partialGroupLeakageRcondB = geomB.partialGroupLeakageRcond;
result.fullGroupLeakageRcondA = geomA.groupLeakageRcond;
result.fullGroupLeakageRcondB = geomB.groupLeakageRcond;
result.allNineRateRangeA = geomA.allNineRateRange;
result.allNineRateRangeB = geomB.allNineRateRange;
result.allNineRateRangeShared = [ ...
    max(geomA.allNineRateRange(1),geomB.allNineRateRange(1)), ...
    min(geomA.allNineRateRange(2),geomB.allNineRateRange(2))];
result.effectiveValidRateMasks = struct( ...
    'A',geomA.validRateMask,'B',geomB.validRateMask, ...
    'both',geomA.validRateMask & geomB.validRateMask, ...
    'trainingA',geomA.trainingRateMask, ...
    'trainingB',geomB.trainingRateMask, ...
    'trainingBoth',geomA.trainingRateMask & geomB.trainingRateMask, ...
    'strictTrainingA',strictTrainingRateMaskA, ...
    'strictTrainingB',strictTrainingRateMaskB, ...
    'strictTrainingBoth',strictTrainingRateMaskA & strictTrainingRateMaskB, ...
    'partialTrainingA',geomA.partialTrainingRateMask, ...
    'partialTrainingB',geomB.partialTrainingRateMask, ...
    'partialOnlyTrainingA', ...
        geomA.partialTrainingRateMask & ~strictTrainingRateMaskA, ...
    'partialOnlyTrainingB', ...
        geomB.partialTrainingRateMask & ~strictTrainingRateMaskB);
result.config = struct( ...
    'pad',pad,'nfftA',geomA.nfft,'nfftB',geomB.nfft, ...
    'sr1',sr1,'sr2',sr2,'srstep',srstep,'red',red, ...
    'nsim',nsim,'method',method, ...
    'requestedBatchSize',options.BatchSize,'batchSize',actualBatchSize, ...
    'estimatedGeometryBytes',estimatedGeometryBytes, ...
    'geometryMemoryBudgetBytes',geometryMemoryBudget, ...
    'seed',options.Seed,'splitMode',options.SplitMode, ...
    'interleavedPhase',options.InterleavedPhase, ...
    'splitRule',splitRule,'jointNull',isInterleaved, ...
    'targetModel',options.TargetModel, ...
    'degradedMode',degradedMode, ...
    'trainingCompleteness',result.trainingCompleteness, ...
    'trainingCompletenessA',trainingCompletenessA, ...
    'trainingCompletenessB',trainingCompletenessB, ...
    'trainingWarningIdentifier',trainingWarningIdentifier, ...
    'trainingWarningMessage',trainingWarningMessage, ...
    'amplitudeMethod',targetAmplitudeMethod(options.TargetModel), ...
    'frozenValidationWeightLevel', ...
    frozenValidationWeightLevel(options.TargetModel), ...
    'maximumTemporalFrequency',options.MaxFrequency, ...
    'maximumTemporalFrequencyWasDefault',maximumFrequencyWasDefault, ...
    'maximumTemporalFrequencyRule',maximumFrequencySource, ...
    'interpolation',interpolationRule, ...
    'nullConditioning',nullConditioning, ...
    'rhoRule',rhoRule, ...
    'trainingRateRule','maximum adaptive correlation', ...
    'groupRule','RMS sinusoid amplitude within 1/4/1/3 orbital groups', ...
    'symmetricRule','minimum of the two directional maxima', ...
    'consensusRule', ...
    'maximum over rates of the same-rate minimum directional curve', ...
    'directionalPValueRule','plus-one p from each full-pipeline null maximum', ...
    'pCurveRule','directional max-statistic p at each observed rate', ...
    'consensusPCurveRule', ...
    ['plus-one p from each full-pipeline null maximum over the ', ...
     'same-rate minimum directional curve'], ...
    'pCOCODefinition', ...
    ['same-rate minimum consensus rho multiplied by abs(log10(', ...
     'joint full-pipeline consensus global p))'], ...
    'localPCurveRule', ...
    ['plus-one same-rate directional p after repeating the complete ', ...
     'training pipeline; validation-rate search uncorrected; descriptive only'], ...
    'degenerateSpectrumRule', ...
    'a constant/zero target or data spectrum has operational similarity zero', ...
    'spectralDiagnosticUnits', ...
    'temporal PSD; spatial PSD multiplied by 100/sedimentation rate', ...
    'participatingPeriodRule', ...
    ['report frequency-resolvable counts separately from nonzero-frozen-', ...
     'weight active counts; neither count gates validation correlation'], ...
    'trainingPeriodRule', ...
    ['estimate four group weights only where all nine periods resolve ', ...
     'continuous cross-group bands do not overlap, and the leakage matrix ', ...
     'meets its pre-specified conditioning threshold']);
if isFourGroupTraining
    result.config.trainingRateRule = ...
        'maximum four-group union-band target correlation';
    result.config.groupRule = [ ...
        'one common amplitude per 1/4/1/3 group from nonnegative ', ...
        'four-by-four leakage de-mixing of union-band energies'];
    result.config.bandRule = ...
        ['nominal orbital spatial frequency plus or minus one Rayleigh, ', ...
         'clipped at the declared MaxFrequency'];
    if isCoherentNine
        result.config.targetConstruction = [ ...
            'four leakage-corrected group amplitudes expanded to nine ', ...
            'zero-phase orbital sinusoids, summed coherently before power'];
        result.config.templatePhaseRule = [ ...
            'legacy-style zero-phase sine terms summed before the ', ...
            'periodogram, preserving nine-term interference peaks'];
    else
        result.config.targetConstruction = [ ...
            'phase-averaged finite-record unit-sine/unit-cosine ', ...
            'periodograms added noncoherently within each of four orbital groups'];
        result.config.templatePhaseRule = ...
            'uniform-phase expectation: 0.5*(unit-sine PSD + unit-cosine PSD)';
    end
    result.config.crossGroupBandRule = [ ...
        'a rate is ineligible for training if continuous one-Rayleigh ', ...
        'bands of two different orbital groups overlap'];
    result.config.leakageCorrection = [ ...
        'exact four-variable nonnegative least squares on the finite-record ', ...
        'group-template leakage matrix'];
    result.config.minimumLeakageMatrixRcond = geomA.minimumLeakageRcond;
    result.config.activeGroupWeightTolerance = activeGroupWeightTolerance();
elseif isRayleighPeakTraining
    result.config.trainingRateRule = ...
        'maximum coherent-nine Rayleigh-peak target correlation';
    result.config.groupRule = [ ...
        'nine independent orbital amplitudes; four RMS group values are ', ...
        'reported only as summaries and are not used for validation'];
    result.config.bandRule = [ ...
        'maximum data PSD within nominal orbital spatial frequency plus ', ...
        'or minus one Rayleigh, calibrated by the corresponding unit-', ...
        'amplitude sine maximum in the same band; each orbit is evaluated ', ...
        'independently, so an overlapping bin may contribute to more than ', ...
        'one orbit, matching the compatibility peak-selection rule'];
    result.config.targetConstruction = [ ...
        'nine separately estimated zero-phase orbital sinusoids summed ', ...
        'coherently before power'];
    result.config.templatePhaseRule = [ ...
        'zero-phase sine terms summed before the periodogram, preserving ', ...
        'nine-term interference peaks'];
    result.config.validationAmplitudeRule = [ ...
        'normalize the nine fitted amplitudes by their maximum and freeze ', ...
        'all nine relative weights without four-group aggregation'];
    result.config.trainingPeriodRule = [ ...
        'estimate all nine Rayleigh-peak amplitudes only where all nine ', ...
        'periods are frequency-resolvable and their unit peaks are positive'];
    result.config.activeGroupWeightTolerance = activeGroupWeightTolerance();
end
if degradedMode
    result.config.trainingPeriodRule = [ ...
        'partial-orbit fallback: at each eligible training rate fit only ', ...
        'the physically resolved orbital groups with the corresponding ', ...
        'active leakage submatrix; fix every unresolved group weight to zero'];
    result.config.inferenceQualification = [ ...
        'complete numerical pipeline with matched Monte Carlo, but ', ...
        'exploratory/degraded because at least one training unit lacks an ', ...
        'eligible all-nine rate'];
end

reportProgress(options.ProgressFcn,1,sprintf('%s complete.',analysisName));
end

function groups = defineOrbitGroups(periods)
groups = cocoOrbitGroups(periods);
end

function [clean,A,B,splitDepth,dzA,dzB,infoA,infoB,indexA,indexB] = ...
        prepareHeldOutData(data,analysisName,splitMode,interleavedPhase,verbose)
clean = data(all(isfinite(data),2),:);
if size(clean,1) < 8
    error('cvcoco:InsufficientData', ...
        'At least eight finite observations are required.');
end
clean = sortrows(clean,1);
[depthUnique,~,group] = unique(clean(:,1),'sorted');
valueMean = accumarray(group,clean(:,2),[],@mean);
clean = [depthUnique,valueMean];
if size(clean,1) < 8
    error('cvcoco:InsufficientUniqueDepths', ...
        'At least eight unique depth levels are required after de-duplication.');
end
spacing = diff(clean(:,1));
spacing = spacing(isfinite(spacing) & spacing > 0);
if isempty(spacing) || ~isfinite(median(spacing)) || median(spacing) <= 0
    error('cvcoco:InvalidDepthSpacing','A positive depth spacing is required.');
end
if strcmp(splitMode,'interleaved')
    splitDepth = NaN;
    if interleavedPhase == 0
        indexA = (1:2:size(clean,1))';
        indexB = (2:2:size(clean,1))';
    else
        % The first local row is globally Even. Keep A=global Odd and
        % B=global Even so direction labels do not alternate by window.
        indexA = (2:2:size(clean,1))';
        indexB = (1:2:size(clean,1))';
    end
    rawA = clean(indexA,:);
    rawB = clean(indexB,:);
    if size(rawA,1) < 4 || size(rawB,1) < 4
        error('cvcoco:InsufficientInterleavedFoldData', ...
            ['Each odd/even fold must contain at least four unique ', ...
             'observations.']);
    end
    labelA = 'Odd fold';
    labelB = 'Even fold';
else
    splitDepth = clean(1,1)/2+clean(end,1)/2;
    indexA = find(clean(:,1) <= splitDepth);
    indexB = find(clean(:,1) > splitDepth);
    rawA = clean(indexA,:);
    rawB = clean(indexB,:);
    if size(rawA,1) < 4 || size(rawB,1) < 4
        error('cvcoco:InsufficientHalfData', ...
            'Each midpoint half must contain at least four unique observations.');
    end
    labelA = 'Segment A';
    labelB = 'Segment B';
end
A = regularizeHalf(rawA,labelA);
B = regularizeHalf(rawB,labelB);
dzA = median(diff(A(:,1)));
dzB = median(diff(B(:,1)));
infoA = interpolationInfo(rawA,A,dzA);
infoB = interpolationInfo(rawB,B,dzB);
if verbose
    reportInterpolation(infoA,labelA,analysisName);
    reportInterpolation(infoB,labelB,analysisName);
end
end

function out = regularizeHalf(raw,label)
spacing = diff(raw(:,1));
spacing = spacing(isfinite(spacing) & spacing > 0);
dz = median(spacing);
if isempty(dz) || ~isfinite(dz) || dz <= 0
    error('cvcoco:InvalidDepthSpacing', ...
        '%s has no positive finite depth spacing.',label);
end

tolerance = spacingTolerance(raw(:,1),dz);
if max(abs(spacing-dz)) <= tolerance
    out = raw;
    return
end

intervalCountExact = (raw(end,1)-raw(1,1))/dz;
intervalCountRounded = round(intervalCountExact);
countTolerance = 1e-10*max(1,abs(intervalCountExact));
if abs(intervalCountExact-intervalCountRounded) <= countTolerance
    intervalCount = intervalCountRounded;
else
    intervalCount = floor(intervalCountExact);
end
interpolatedPointCount = intervalCount+1;
maximumInterpolatedPoints = 1e6;
if ~isfinite(interpolatedPointCount) || interpolatedPointCount < 4 || ...
        interpolatedPointCount > maximumInterpolatedPoints
    error('cvcoco:InterpolationGridTooLarge', ...
        ['%s median-spacing interpolation would create ', ...
         'approximately %.6g points (safety limit %.6g). Inspect large ', ...
         'gaps/outliers or preprocess scientifically defensible segments.'], ...
        label,interpolatedPointCount,maximumInterpolatedPoints);
end
grid = raw(1,1) + (0:intervalCount)'*dz;
if numel(grid) < 4
    error('cvcoco:InsufficientInterpolatedHalf', ...
        '%s contains fewer than four points on the median-spacing grid.',label);
end
endpointTolerance = 16*eps(max(1,max(abs(raw([1,end],1))))) * ...
    max(1,numel(grid));
if abs(grid(end)-raw(end,1)) <= endpointTolerance
    grid(end) = raw(end,1);
end
values = interp1(raw(:,1),raw(:,2),grid,'linear');
ok = isfinite(grid) & isfinite(values);
out = [grid(ok),values(ok)];
if size(out,1) < 4
    error('cvcoco:InsufficientInterpolatedHalf', ...
        '%s contains fewer than four finite interpolated points.',label);
end
end

function info = interpolationInfo(raw,out,dz)
spacing = diff(raw(:,1));
tolerance = spacingTolerance(raw(:,1),dz);
deviation = max(abs(spacing-dz));
info = struct( ...
    'applied',deviation > tolerance, ...
    'method','linear', ...
    'originalPointCount',size(raw,1), ...
    'interpolatedPointCount',size(out,1), ...
    'originalDepthRange',raw([1,end],1)', ...
    'interpolatedDepthRange',out([1,end],1)', ...
    'spacingMinimum',min(spacing), ...
    'spacingMedian',dz, ...
    'spacingMaximum',max(spacing), ...
    'maximumGapToMedianRatio',max(spacing)/dz, ...
    'uniformityTolerance',tolerance, ...
    'maximumSpacingDeviation',deviation);
end

function tolerance = spacingTolerance(depth,dz)
tolerance = cocoSamplingTolerance(depth,dz);
end

function reportInterpolation(info,label,analysisName)
if ~info.applied
    return
end
fprintf('\n>> %s preprocessing: uneven depth spacing detected in %s.\n', ...
    analysisName,label);
fprintf('   Original valid points        : %d\n',info.originalPointCount);
fprintf('   Original depth range         : %.12g to %.12g m\n',info.originalDepthRange);
fprintf('   Original spacing (min/median/max): %.12g / %.12g / %.12g m\n', ...
    info.spacingMinimum,info.spacingMedian,info.spacingMaximum);
fprintf('   Uniformity tolerance         : %.12g m\n',info.uniformityTolerance);
fprintf('   Maximum spacing deviation    : %.12g m\n',info.maximumSpacingDeviation);
fprintf('   Largest gap / median spacing : %.12g\n', ...
    info.maximumGapToMedianRatio);
if info.maximumGapToMedianRatio > 10
    fprintf(['   WARNING: linear interpolation bridges a gap larger than ', ...
        '10 median intervals; the AR(1) null conditions on this ', ...
        'interpolation and does not model missingness.\n']);
end
fprintf('   Interpolation method         : %s\n',info.method);
fprintf('   Interpolation interval       : %.12g m\n',info.spacingMedian);
fprintf('   Interpolated points          : %d\n',info.interpolatedPointCount);
fprintf('   Interpolated depth range     : %.12g to %.12g m\n\n', ...
    info.interpolatedDepthRange);
end

function geom = prepareGeometry(depth,periods,srGrid,pad,groups,targetModel, ...
        maximumTemporalFrequency)
n = numel(depth);
dz = median(diff(depth));
fs = 1/dz;
nfft = max(pad,n);
nf = floor(nfft/2)+1;
frequency = (0:nf-1)' .* (fs/nfft);
rayleigh = fs/n;
nyquist = fs/2;
nRate = numel(srGrid);
nOrbit = numel(periods);
isFourGroupTraining = usesFourGroupTraining(targetModel);
isCoherentNine = usesCoherentNineTarget(targetModel);

geom = struct;
geom.n = n;
geom.dz = dz;
geom.fs = fs;
geom.nfft = nfft;
geom.frequency = frequency;
geom.rayleigh = rayleigh;
geom.nyquist = nyquist;
geom.bandLo = zeros(nRate,nOrbit);
geom.bandHi = zeros(nRate,nOrbit);
geom.unitPeak = nan(nRate,nOrbit);
geom.basis = cell(nRate,1);
geom.groupTemplate = cell(nRate,1);
geom.groupBandIndex = cell(nRate,4);
geom.groupUnitEnergy = nan(nRate,4);
geom.groupLeakageMatrix = cell(nRate,1);
geom.groupLeakageRcond = nan(nRate,1);
geom.groupLeakageSolveMatrix = cell(nRate,1);
geom.partialGroupLeakageRcond = nan(nRate,1);
geom.minimumLeakageRcond = 1e-10;
geom.corrIndex = cell(nRate,1);
geom.validRateMask = false(nRate,1);
geom.trainingRateMask = false(nRate,1);
geom.strictTrainingRateMask = false(nRate,1);
geom.partialTrainingRateMask = false(nRate,1);
geom.trainingActiveGroupMask = false(nRate,4);
geom.orbitCount = zeros(nRate,1);
geom.resolvedOrbitMask = false(nRate,nOrbit);
geom.resolvedGroupCount = zeros(nRate,4);
geom.crossGroupBandOverlap = false(nRate,1);
geom.groupIndex = groups.index;
geom.targetModel = targetModel;
geom.allNineRateRange = cocoAllPeriodRateRange(periods,dz,n);

oneSidedWeight = 2*ones(nf,1);
oneSidedWeight(1) = 1;
if rem(nfft,2) == 0
    oneSidedWeight(end) = 1;
end

for m = 1:nRate
    sr = srGrid(m);
    spatialOrbit = 100 ./ (periods*sr);
    % Match legacy Fixed COCO resolution logic: equality at Rayleigh is
    % usable, while the Nyquist boundary itself is excluded.
    isResolved = spatialOrbit >= rayleigh & spatialOrbit < nyquist;
    geom.orbitCount(m) = sum(isResolved);
    geom.resolvedOrbitMask(m,:) = isResolved(:)';
    for g = 1:4
        geom.resolvedGroupCount(m,g) = ...
            nnz(isResolved & groups.index == g);
    end
    temporalFrequency = frequency .* sr/100;
    corrIndex = find(temporalFrequency <= maximumTemporalFrequency + ...
        16*eps(max(1,maximumTemporalFrequency)));
    geom.corrIndex{m} = corrIndex;
    if numel(corrIndex) < 3 || ~any(isResolved)
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
    H = fft(unitSine,nfft,1);
    H = H(1:nf,:);
    % Match MATLAB periodogram's rectangular-window PSD normalization.
    % This makes the recovered sinusoid amplitudes retain the proxy-data
    % amplitude unit, instead of being scaled by FFT length and sample rate.
    spectrumScale = 1/(fs*n);
    if any(~isfinite(H(:)))
        continue
    end
    geom.bandLo(m,:) = lo;
    geom.bandHi(m,:) = hi;
    if isFourGroupTraining
        unitCosine = detrend(cos(phase),1);
        Hcosine = fft(unitCosine,nfft,1);
        Hcosine = Hcosine(1:nf,:);
        if any(~isfinite(Hcosine(:)))
            continue
        end
        % A sinusoid with uniformly unknown phase has expected PSD
        % 0.5*(PSD_sine+PSD_cosine).  This eliminates arbitrary leakage
        % caused by fixing every astronomical term at phase zero.
        unitPower = 0.5 .* (abs(H).^2 + abs(Hcosine).^2) .* ...
            oneSidedWeight .* spectrumScale;
        groupTemplate = zeros(nf,4);
        analysisUpperSpatialFrequency = min( ...
            nyquist,maximumTemporalFrequency*100/sr);
        for j = 1:nOrbit
            if ~isResolved(j)
                continue
            end
            groupTemplate(:,groups.index(j)) = ...
                groupTemplate(:,groups.index(j)) + unitPower(:,j);
        end
        for g = 1:4
            members = find(groups.index == g & isResolved);
            bandMask = false(nf,1);
            for member = members(:)'
                bandMask(lo(member):hi(member)) = true;
            end
            bandMask = bandMask & ...
                frequency <= analysisUpperSpatialFrequency + ...
                64*eps(max(1,analysisUpperSpatialFrequency));
            idxGroup = find(bandMask);
            geom.groupBandIndex{m,g} = idxGroup;
            if ~isempty(idxGroup)
                geom.groupUnitEnergy(m,g) = ...
                    sum(groupTemplate(idxGroup,g))*(fs/nfft);
            end
        end
        % Decide physical band overlap from continuous one-Rayleigh
        % intervals, not from whichever DFT bins happen to exist at this
        % Pad.  Training eligibility must be invariant to zero-padding.
        geom.crossGroupBandOverlap(m) = continuousGroupBandOverlap( ...
            spatialOrbit,rayleigh,analysisUpperSpatialFrequency, ...
            isResolved,groups.index);
        leakageMatrix = zeros(4,4);
        for observedGroup = 1:4
            observedBand = geom.groupBandIndex{m,observedGroup};
            if ~isempty(observedBand)
                leakageMatrix(observedGroup,:) = ...
                    sum(groupTemplate(observedBand,:),1)*(fs/nfft);
            end
        end
        geom.groupLeakageMatrix{m} = leakageMatrix;
        if all(isfinite(leakageMatrix),'all')
            geom.groupLeakageRcond(m) = rcond(leakageMatrix);
        end
        geom.groupTemplate{m} = groupTemplate;
        if isCoherentNine
            geom.basis{m} = H;
        end
        geom.validRateMask(m) = any(groupTemplate(:) > 0);
        activeGroup = geom.resolvedGroupCount(m,:) > 0 & ...
            isfinite(geom.groupUnitEnergy(m,:)) & ...
            geom.groupUnitEnergy(m,:) > 0;
        geom.trainingActiveGroupMask(m,:) = activeGroup;
        solveMatrix = leakageMatrix;
        inactiveGroup = find(~activeGroup);
        for inactiveIndex = inactiveGroup(:)'
            solveMatrix(inactiveIndex,:) = 0;
            solveMatrix(:,inactiveIndex) = 0;
            solveMatrix(inactiveIndex,inactiveIndex) = 1;
        end
        geom.groupLeakageSolveMatrix{m} = solveMatrix;
        if any(activeGroup)
            activeMatrix = leakageMatrix(activeGroup,activeGroup);
            if all(isfinite(activeMatrix),'all') && ...
                    all(diag(activeMatrix) > 0)
                geom.partialGroupLeakageRcond(m) = rcond(activeMatrix);
            end
        end
        geom.partialTrainingRateMask(m) = geom.validRateMask(m) && ...
            any(activeGroup) && ...
            isfinite(geom.partialGroupLeakageRcond(m)) && ...
            geom.partialGroupLeakageRcond(m) >= ...
                geom.minimumLeakageRcond && ...
            ~geom.crossGroupBandOverlap(m);
        geom.strictTrainingRateMask(m) = all(isResolved) && ...
            all(isfinite(geom.groupUnitEnergy(m,:)) & ...
            geom.groupUnitEnergy(m,:) > 0) && ...
            isfinite(geom.groupLeakageRcond(m)) && ...
            geom.groupLeakageRcond(m) >= geom.minimumLeakageRcond && ...
            ~geom.crossGroupBandOverlap(m);
        geom.trainingRateMask(m) = geom.strictTrainingRateMask(m);
    else
        unitPower = abs(H).^2 .* oneSidedWeight .* spectrumScale;
        unitPeak = zeros(1,nOrbit);
        for j = 1:nOrbit
            unitPeak(j) = max(unitPower(lo(j):hi(j),j));
        end
        geom.unitPeak(m,:) = unitPeak;
        geom.basis{m} = H;
        geom.validRateMask(m) = true;
        geom.trainingRateMask(m) = all(isResolved) && ...
            all(isfinite(unitPeak) & unitPeak > 0);
        geom.strictTrainingRateMask(m) = geom.trainingRateMask(m);
        geom.partialTrainingRateMask(m) = geom.trainingRateMask(m);
    end
end
geom.oneSidedWeight = oneSidedWeight;
geom.spectrumScale = 1/(fs*n);
geom.srGrid = srGrid;
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
        overlapWidth = min(hi(first),hi(second)) - ...
            max(lo(first),lo(second));
        if overlapWidth > tolerance
            tf = true;
            return
        end
    end
end
end

function [power,f] = spectrumBatch(values,geom,red)
values = detrend(values,1);
if any(~isfinite(values),'all')
    error('cvcoco:NonfiniteDetrendedData', ...
        'Linear detrending overflowed; rescale the proxy values before COCO.');
end
[power,f] = periodogram(values,[],geom.nfft,geom.fs);
if isvector(power)
    power = power(:);
end
if any(~isfinite(power),'all')
    error('cvcoco:NonfinitePeriodogram', ...
        ['The periodogram overflowed or returned nonfinite power. Rescale ', ...
         'the proxy values before COCO; the spectrum cannot be repaired ', ...
         'by replacing nonfinite ordinates with zero.']);
end
negativeTolerance = 64*eps(max(1,max(abs(power),[],'all')));
if any(power < -negativeTolerance,'all')
    error('cvcoco:NegativePeriodogram', ...
        'The periodogram returned materially negative power.');
end
power(power < 0) = 0;
if red == 3 && size(power,1) < 33
    error('cvcoco:SwaSpectrumTooShort', ...
        ['Smoothed-window background removal requires at least 33 ', ...
         'one-sided spectral bins (three initial 11-bin windows); only ', ...
         '%d are available. Increase Pad/NFFT or use another red-noise ', ...
         'option.'],size(power,1));
end
if red == 0
    return
end
for k = 1:size(power,2)
    p = power(:,k);
    x = values(:,k);
    switch red
        case 1
            background = theoredar1ML(x,f,mean(p),geom.dz);
        case 2
            % REDCONF_ANY expects normalized angular frequency (rad/sample),
            % not PERIODGRAM's cycle/depth frequency.  Convert explicitly;
            % its internal transform then recovers f in cycle/m exactly.
            background = redconf_any(2*pi*f*geom.dz,p,geom.dz,0.25,2);
        case 3
            positivePower = p(isfinite(p) & p > 0);
            if isempty(positivePower)
                error('cvcoco:SwaNonpositiveSpectrum', ...
                    ['Smoothed-window background removal requires at ', ...
                     'least one positive finite periodogram ordinate.']);
            end
            powerScale = max(positivePower);
            logFloor = max(realmin,powerScale*eps(1));
            pForLog = p;
            pForLog(pForLog < logFloor) = logFloor;
            try
                [background,~] = specswa( ...
                    f,log10(pForLog),numel(x),false);
            catch exception
                error('cvcoco:SwaBackgroundFailure', ...
                    ['Smoothed-window background removal failed for a ', ...
                     '%d-point series with %d spectral bins: %s'], ...
                    numel(x),numel(p),exception.message);
            end
    end
    background = background(:);
    if numel(background) ~= numel(p) || ...
            any(~isfinite(background) | background <= 0)
        error('cvcoco:InvalidRedNoiseBackground', ...
            ['The selected red-noise method returned a nonpositive, ', ...
             'nonfinite, or size-mismatched spectral background.']);
    end
    p = p-background;
    if any(~isfinite(p))
        error('cvcoco:NonfiniteAdjustedSpectrum', ...
            'Red-noise subtraction produced nonfinite spectral power.');
    end
    p(p < 0) = 0;
    power(:,k) = p;
end
end

function [curve,bestRate,amplitudeAtBest] = adaptiveTrain(power,geom,method,keepCurve)
if usesFourGroupTraining(geom.targetModel)
    [curve,bestRate,amplitudeAtBest] = ...
        fourGroupAdaptiveTrain(power,geom,method,keepCurve);
    return
end
nRate = numel(geom.srGrid);
nSeries = size(power,2);
if keepCurve
    curve = nan(nRate,nSeries);
else
    curve = [];
end

bestScore = -inf(1,nSeries);
bestRate = nan(1,nSeries);
amplitudeAtBest = nan(9,nSeries);

for m = 1:nRate
    if ~geom.trainingRateMask(m)
        continue
    end
    targetPeak = bandMaximum(power,geom.bandLo(m,:),geom.bandHi(m,:));
    amplitudes = sqrt(targetPeak ./ geom.unitPeak(m,:)');
    targetFFT = geom.basis{m}*amplitudes;
    targetPower = abs(targetFFT).^2 .* geom.oneSidedWeight .* ...
        geom.spectrumScale;
    idx = geom.corrIndex{m};
    rho = columnCorrelation(power(idx,:),targetPower(idx,:),method);
    if keepCurve
        curve(m,:) = rho;
    end
    better = isfinite(rho) & rho > bestScore;
    if any(better)
        bestScore(better) = rho(better);
        bestRate(better) = geom.srGrid(m);
        amplitudeAtBest(:,better) = amplitudes(:,better);
    end
end
bestScore(~isfinite(bestRate)) = NaN;
if ~keepCurve
    curve = bestScore;
end
end

function [curve,bestRate,amplitudeAtBest] = ...
        fourGroupAdaptiveTrain(power,geom,method,keepCurve)
nRate = numel(geom.srGrid);
nSeries = size(power,2);
if keepCurve
    curve = nan(nRate,nSeries);
else
    curve = [];
end
bestScore = -inf(1,nSeries);
bestRate = nan(1,nSeries);
amplitudeAtBest = nan(9,nSeries);
df = geom.fs/geom.nfft;

for m = 1:nRate
    if ~geom.trainingRateMask(m)
        continue
    end
    activeGroup = geom.trainingActiveGroupMask(m,:)';
    dataEnergy = zeros(4,nSeries);
    for g = 1:4
        if ~activeGroup(g)
            continue
        end
        idxBand = geom.groupBandIndex{m,g};
        if isempty(idxBand)
            error('cvcoco:MissingActiveGroupBand', ...
                ['An eligible partial-orbit training group has no ', ...
                 'frequency-integration band.']);
        else
            dataEnergy(g,:) = sum(power(idxBand,:),1)*df;
        end
    end
    if any(~isfinite(dataEnergy),'all') || any(dataEnergy < 0,'all')
        error('cvcoco:InvalidGroupBandEnergy', ...
            ['A four-group integration band produced nonfinite or negative ', ...
             'energy. Check the input scale and spectral preprocessing.']);
    end
    solveEnergy = dataEnergy;
    solveEnergy(~activeGroup,:) = 0;
    groupPower = cocoNonnegativeLeakageSolve( ...
        geom.groupLeakageSolveMatrix{m},solveEnergy);
    groupPower(~activeGroup,:) = 0;
    maximumGroupPower = max(groupPower,[],1);
    negligiblePower = groupPower <= ...
        maximumGroupPower.*activeGroupWeightTolerance()^2;
    groupPower(negligiblePower) = 0;
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
        expandedAmplitude = groupAmplitude(geom.groupIndex,:);
        amplitudeAtBest(:,better) = expandedAmplitude(:,better);
    end
end
bestScore(~isfinite(bestRate)) = NaN;
if ~keepCurve
    curve = bestScore;
end
end

function targetPower = fourGroupTargetPower(geom,rateIndex,groupAmplitude)
% Four-group amplitudes remain the fitted parameters in both modern
% cvCOCO variants. Only the final combination of the nine member terms
% differs: power addition for cvCOCO and waveform addition for cvCOCO9B.
if usesCoherentNineTarget(geom.targetModel)
    expandedAmplitude = groupAmplitude(geom.groupIndex,:);
    expandedAmplitude = expandedAmplitude .* ...
        double(geom.resolvedOrbitMask(rateIndex,:))';
    targetFFT = geom.basis{rateIndex}*expandedAmplitude;
    targetPower = abs(targetFFT).^2 .* geom.oneSidedWeight .* ...
        geom.spectrumScale;
else
    targetPower = geom.groupTemplate{rateIndex}*(groupAmplitude.^2);
end
end

function peak = bandMaximum(power,lo,hi)
nOrbit = numel(lo);
nSeries = size(power,2);
peak = zeros(nOrbit,nSeries);
for j = 1:nOrbit
    peak(j,:) = max(power(lo(j):hi(j),:),[],1);
end
peak(~isfinite(peak) | peak < 0) = 0;
end

function [raw,normalized] = groupAmplitudes(amplitudes,groups)
nSeries = size(amplitudes,2);
raw = nan(4,nSeries);
for g = 1:4
    a = amplitudes(groups.index == g,:);
    raw(g,:) = sqrt(mean(a.^2,1));
end
scale = max(raw,[],1);
normalized = raw ./ scale;
zeroTarget = isfinite(scale) & scale == 0 & all(isfinite(raw),1);
normalized(:,zeroTarget) = 0;
bad = ~isfinite(scale) | scale < 0;
normalized(:,bad) = NaN;
% Make the reported active-group definition identical to the numerical
% frozen target. Relative weights below this pre-specified tolerance have
% squared contributions at or below roundoff scale and are set exactly to
% zero in both observed and Monte Carlo workflows.
normalized(normalized >= 0 & ...
    normalized <= activeGroupWeightTolerance()) = 0;
end

function normalized = normalizeOrbitAmplitudes(amplitudes)
% Preserve all nine relative amplitudes for method A. Absolute scale is
% irrelevant to correlation, but a common column scale makes the frozen
% held-out target explicit and numerically stable.
scale = max(amplitudes,[],1);
normalized = amplitudes ./ scale;
zeroTarget = isfinite(scale) & scale == 0 & ...
    all(isfinite(amplitudes),1);
normalized(:,zeroTarget) = 0;
bad = ~isfinite(scale) | scale < 0;
normalized(:,bad) = NaN;
normalized(normalized >= 0 & ...
    normalized <= activeGroupWeightTolerance()) = 0;
end

function weights = frozenValidationWeights( ...
        targetModel,groupNormalized,orbitNormalized)
if usesRayleighPeakTraining(targetModel)
    weights = orbitNormalized;
else
    % Preserve the legacy compatibility workflow: legacy peak amplitudes
    % are summarized as four RMS group weights before held-out validation.
    weights = groupNormalized;
end
end

function [curve,bestScore,bestRate] = fixedValidate(power,geom,weights,method,keepCurve)
nRate = numel(geom.srGrid);
nSeries = size(power,2);
if size(weights,2) == 1 && nSeries > 1
    weights = repmat(weights,1,nSeries);
end
expectedWeightCount = 4;
if usesRayleighPeakTraining(geom.targetModel)
    expectedWeightCount = 9;
end
if size(weights,1) ~= expectedWeightCount || size(weights,2) ~= nSeries
    error('cvcoco:InternalWeightSize','Fixed validation weights have an invalid size.');
end
if keepCurve
    curve = nan(nRate,nSeries);
else
    curve = [];
end
bestScore = -inf(1,nSeries);
bestRate = nan(1,nSeries);
for m = 1:nRate
    if ~geom.validRateMask(m)
        continue
    end
    targetPower = frozenTargetPower(geom,m,weights);
    idx = geom.corrIndex{m};
    rho = columnCorrelation(power(idx,:),targetPower(idx,:),method);
    if keepCurve
        curve(m,:) = rho;
    end
    better = isfinite(rho) & rho > bestScore;
    if any(better)
        bestScore(better) = rho(better);
        bestRate(better) = geom.srGrid(m);
    end
end
bestScore(~isfinite(bestRate)) = NaN;
end

function targetPower = frozenTargetPower(geom,rateIndex,weights)
if usesFourGroupTraining(geom.targetModel)
    targetPower = fourGroupTargetPower(geom,rateIndex,weights);
    return
end
if usesRayleighPeakTraining(geom.targetModel)
    expandedWeights = weights;
else
    % Explicit legacy compatibility: expand four frozen RMS group weights
    % to the nine orbital terms.
    expandedWeights = weights(geom.groupIndex,:);
end
expandedWeights = expandedWeights .* ...
    double(geom.resolvedOrbitMask(rateIndex,:))';
targetFFT = geom.basis{rateIndex}*expandedWeights;
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

function [rhoM,source] = estimateRhoM(values)
% Conditional least-squares/MLE slope for x(t)=rho*x(t-1)+epsilon(t).
% One estimator over (-1,1) avoids the old sign-dependent switch between a
% lag correlation and a nonnegative spectral grid search.
x = values(:);
x = x-mean(x);
scale = max(abs(x));
if numel(x) < 4 || any(~isfinite(x)) || ~isfinite(scale) || scale <= 0
    error('cvcoco:InvalidRhoSeries', ...
        'Each segment needs at least four finite, variable detrended values.');
end
scaled = x./scale;
previous = scaled(1:end-1);
next = scaled(2:end);
denominator = previous'*previous;
if ~isfinite(denominator) || denominator <= 0
    error('cvcoco:InvalidRhoSeries', ...
        'The conditional AR(1) denominator is zero or nonfinite.');
end
rhoM = (previous'*next)/denominator;
if ~isfinite(rhoM) || ~isreal(rhoM)
    error('cvcoco:InvalidRhoEstimate', ...
        'The conditional AR(1) estimate is nonfinite or complex.');
end
rhoM = min(max(real(rhoM),-0.999),0.999);
source = 'conditional least-squares AR(1) on detrended within-segment pairs';
end

function out = makeTrainResult( ...
        curve,bestRate,amp,orbitNormed,raw,normed,srGrid,mask)
out = struct;
out.curve = curve(:);
out.bestRate = scalarValue(bestRate);
out.bestIndex = find(srGrid == out.bestRate,1);
out.bestCorrelation = valueAtIndex(out.curve,out.bestIndex);
out.amplitudes9 = amp(:);
out.amplitudes9Normalized = orbitNormed(:);
out.groupRaw = raw(:);
out.groupNormalized = normed(:);
out.validRateMask = mask(:);
end

function out = attachTrainingLeakage(out,geom)
out.groupLeakageMatrix = nan(4,4);
out.groupLeakagePhysicalMatrix = nan(4,4);
out.groupLeakageSolveMatrix = nan(4,4);
out.groupLeakageRcond = NaN;
out.fullGroupLeakageRcond = NaN;
out.groupLeakageRcondDefinition = ...
    'rcond of the physically active leakage submatrix';
out.resolvedGroupMask = false(4,1);
out.resolvedOrbitMask = false(9,1);
out.resolvablePeriodCount = NaN;
out.partialOrbitTraining = false;
out.trainingCompleteness = 'unresolved';
if ~usesFourGroupTraining(geom.targetModel) || isempty(out.bestIndex) || ...
        out.bestIndex < 1 || out.bestIndex > numel(geom.srGrid)
    return
end
solveMatrix = geom.groupLeakageSolveMatrix{out.bestIndex};
if isequal(size(solveMatrix),[4,4])
    out.groupLeakageSolveMatrix = solveMatrix;
end
physicalMatrix = geom.groupLeakageMatrix{out.bestIndex};
if isequal(size(physicalMatrix),[4,4])
    out.groupLeakageMatrix = physicalMatrix;
    out.groupLeakagePhysicalMatrix = physicalMatrix;
end
out.groupLeakageRcond = geom.partialGroupLeakageRcond(out.bestIndex);
out.fullGroupLeakageRcond = geom.groupLeakageRcond(out.bestIndex);
out.resolvedGroupMask = ...
    geom.trainingActiveGroupMask(out.bestIndex,:)';
out.resolvedOrbitMask = geom.resolvedOrbitMask(out.bestIndex,:)';
out.resolvablePeriodCount = geom.orbitCount(out.bestIndex);
out.partialOrbitTraining = out.resolvablePeriodCount < 9;
if out.partialOrbitTraining
    out.trainingCompleteness = 'partial-orbit';
else
    out.trainingCompleteness = 'complete-nine';
end
end

function out = makeValidationResult(curve,score,bestRate,srGrid,mask)
out = struct;
out.curve = curve(:);
out.bestRate = scalarValue(bestRate);
out.bestIndex = find(srGrid == out.bestRate,1);
out.score = scalarValue(score);
out.validRateMask = mask(:);
end

function out = attachParticipation(out,geom,weights)
out.resolvablePeriodCount = NaN;
out.resolvableGroupCounts = nan(1,4);
out.participatingPeriodCount = NaN;
out.participatingGroupCounts = nan(1,4);
out.allNinePeriodsParticipate = false;
if isempty(out.bestIndex) || ~isfinite(out.bestIndex) || ...
        out.bestIndex < 1 || out.bestIndex > numel(geom.srGrid)
    return
end
idx = out.bestIndex;
out.resolvablePeriodCount = geom.orbitCount(idx);
out.resolvableGroupCounts = geom.resolvedGroupCount(idx,:);
activeOrbit = geom.resolvedOrbitMask(idx,:)' & ...
    activeOrbitWeights(geom,weights);
out.participatingPeriodCount = nnz(activeOrbit);
for group = 1:4
    out.participatingGroupCounts(group) = ...
        nnz(activeOrbit & geom.groupIndex == group);
end
out.allNinePeriodsParticipate = out.participatingPeriodCount == 9;
end

function [count,groupCounts] = activeOrbitCountCurve(geom,weights)
activeByOrbit = activeOrbitWeights(geom,weights);
activeMask = geom.resolvedOrbitMask & activeByOrbit';
count = sum(activeMask,2);
groupCounts = zeros(numel(geom.srGrid),4);
for group = 1:4
    groupCounts(:,group) = sum( ...
        activeMask(:,geom.groupIndex == group),2);
end
end

function active = activeOrbitWeights(geom,weights)
if usesRayleighPeakTraining(geom.targetModel)
    if numel(weights) ~= 9
        error('cvcoco:InternalWeightSize', ...
            ['The per-orbit target design requires nine frozen orbital ', ...
             'weights.']);
    end
    active = weights(:) > activeGroupWeightTolerance();
else
    if numel(weights) ~= 4
        error('cvcoco:InternalWeightSize', ...
            'Group-based participation requires four frozen group weights.');
    end
    activeGroup = weights(:) > activeGroupWeightTolerance();
    active = activeGroup(geom.groupIndex(:));
end
end

function out = spectrumDiagnostic(power,geom,rate,weights,mode)
displayMode = mode;
if strcmp(geom.targetModel,'four-group')
    displayMode = ['four-group ',mode];
elseif strcmp(geom.targetModel,'four-group-coherent-nine')
    displayMode = ['four-group coherent-nine ',mode];
elseif usesRayleighPeakTraining(geom.targetModel)
    displayMode = ['Rayleigh-peak coherent-nine ',mode];
end
out = struct('rate',scalarValue(rate),'frequency',zeros(0,1), ...
    'dataPower',zeros(0,1),'targetPower',zeros(0,1),'mode',displayMode, ...
    'powerUnits','proxy^2/(cycle/kyr)');
if ~isfinite(out.rate)
    return
end
m = find(abs(geom.srGrid-out.rate) <= ...
    16*eps(max(1,abs(out.rate))),1);
if isempty(m) || ~geom.validRateMask(m)
    return
end
switch mode
    case 'adaptive'
        if numel(weights) ~= 9 || any(~isfinite(weights))
            return
        end
        if usesFourGroupTraining(geom.targetModel)
            groupWeights = zeros(4,1);
            for g = 1:4
                groupWeights(g) = sqrt(mean( ...
                    weights(geom.groupIndex == g).^2));
            end
            targetPower = fourGroupTargetPower(geom,m,groupWeights);
        else
            targetFFT = geom.basis{m}*weights(:);
            targetPower = abs(targetFFT).^2 .* geom.oneSidedWeight .* ...
                geom.spectrumScale;
        end
    case 'fixed'
        expectedWeightCount = 4;
        if usesRayleighPeakTraining(geom.targetModel)
            expectedWeightCount = 9;
        end
        if numel(weights) ~= expectedWeightCount || any(~isfinite(weights))
            return
        end
        targetPower = frozenTargetPower(geom,m,weights(:));
    otherwise
        error('cvcoco:InternalDiagnosticMode', ...
            'Unknown spectrum diagnostic mode: %s.',mode);
end
idx = geom.corrIndex{m};
out.frequency = geom.frequency(idx).*out.rate/100;
% Convert the spatial PSD to a temporal PSD. Since
% f_time=f_depth*rate/100, P_time=P_depth*(100/rate) preserves variance
% under integration over frequency.
psdJacobian = 100/out.rate;
out.dataPower = power(idx,1).*psdJacobian;
out.targetPower = targetPower(idx,1).*psdJacobian;
end

function y = scalarValue(x)
if isempty(x)
    y = NaN;
else
    y = x(1);
end
end

function y = valueAtIndex(x,index)
if isempty(index)
    y = NaN;
else
    y = x(index);
end
end

function z = minFinitePair(x,y)
if ~isequal(size(x),size(y))
    error('cvcoco:InternalPairSize', ...
        'Paired arrays must have identical dimensions.');
end
z = nan(size(x));
ok = isfinite(x) & isfinite(y);
z(ok) = min(x(ok),y(ok));
end

function z = meanFinitePair(x,y)
if ~isequal(size(x),size(y))
    error('cvcoco:InternalPairSize', ...
        'Paired arrays must have identical dimensions.');
end
z = nan(size(x));
ok = isfinite(x) & isfinite(y);
z(ok) = (x(ok)+y(ok))/2;
end

function z = maxFinitePair(x,y)
if ~isequal(size(x),size(y))
    error('cvcoco:InternalPairSize', ...
        'Paired arrays must have identical dimensions.');
end
z = nan(size(x));
ok = isfinite(x) & isfinite(y);
z(ok) = max(x(ok),y(ok));
end

function maximum = maxFiniteColumns(x)
maximum = nan(1,size(x,2));
for column = 1:size(x,2)
    values = x(:,column);
    values = values(isfinite(values));
    if ~isempty(values)
        maximum(column) = max(values);
    end
end
end

function [score,bestRate,bestIndex] = finiteCurveMaximum(curve,srGrid)
curve = curve(:);
finiteIndex = find(isfinite(curve));
score = NaN;
bestRate = NaN;
bestIndex = [];
if isempty(finiteIndex)
    return
end
[score,relativeIndex] = max(curve(finiteIndex));
bestIndex = finiteIndex(relativeIndex);
bestRate = srGrid(bestIndex);
end

function value = pcocoCurve(rho,p)
% Match the Adaptive COCO definition without orbital-count weighting.
pSafe = p;
pSafe(~isfinite(pSafe) | pSafe <= 0) = NaN;
pSafe(pSafe > 1) = 1;
value = rho.*abs(log10(pSafe));
end

function [exceedanceCount,validCount] = accumulatePointwiseExceedance( ...
        simulatedCurve,observedCurve,exceedanceCount,validCount)
observedCurve = observedCurve(:);
if size(simulatedCurve,1) ~= numel(observedCurve) || ...
        numel(exceedanceCount) ~= numel(observedCurve) || ...
        numel(validCount) ~= numel(observedCurve)
    error('cvcoco:InternalLocalCurveSize', ...
        'Directional local-p curves have inconsistent rate dimensions.');
end
finiteComparison = isfinite(simulatedCurve) & isfinite(observedCurve);
validCount = validCount(:)+sum(finiteComparison,2);
exceedanceCount = exceedanceCount(:)+sum( ...
    finiteComparison & simulatedCurve >= observedCurve,2);
end

function validatePointwiseSimulationCounts(validCount,observedCurve, ...
        nsimCompleted,directionLabel)
validCount = validCount(:);
observedCurve = observedCurve(:);
if numel(validCount) ~= numel(observedCurve) || ...
        any(~isfinite(validCount)) || any(validCount < 0) || ...
        any(validCount ~= fix(validCount)) || any(validCount > nsimCompleted)
    error('cvcoco:InvalidLocalMonteCarloCounts', ...
        '%s local Monte Carlo counts are invalid.',directionLabel);
end
if nsimCompleted > 0 && ...
        any(validCount(isfinite(observedCurve)) ~= nsimCompleted)
    error('cvcoco:InvalidLocalMonteCarloStatistics', ...
        ['At least one %s null realization produced a nonfinite ', ...
         'same-rate statistic where the observed curve is finite. ', ...
         'No local simulations were discarded.'],directionLabel);
end
end

function pCurve = pointwisePCurve(exceedanceCount,validCount,observedCurve)
exceedanceCount = exceedanceCount(:);
validCount = validCount(:);
observedCurve = observedCurve(:);
if numel(exceedanceCount) ~= numel(observedCurve) || ...
        numel(validCount) ~= numel(observedCurve)
    error('cvcoco:InternalLocalCurveSize', ...
        'Directional local-p counts have inconsistent rate dimensions.');
end
pCurve = nan(size(observedCurve));
ok = isfinite(observedCurve) & validCount > 0;
pCurve(ok) = (exceedanceCount(ok)+1)./(validCount(ok)+1);
end

function validateGlobalLocalOrdering(globalP,localP,directionLabel)
globalP = globalP(:);
localP = localP(:);
if numel(globalP) ~= numel(localP)
    error('cvcoco:InternalLocalCurveSize', ...
        '%s global/local p curves have inconsistent lengths.',directionLabel);
end
ok = isfinite(globalP) & isfinite(localP);
if ~any(ok)
    return
end
scale = max(abs([globalP(ok);localP(ok)]));
tolerance = max(64*eps(max(1,scale)),1e-15);
if any(globalP(ok)+tolerance < localP(ok))
    error('cvcoco:GlobalLocalPInvariant', ...
        ['A %s max-statistic global p-value cannot be smaller than its ', ...
         'same-rate local p-value.'],directionLabel);
end
end

function [p,nValid,nExceed,confidenceInterval] = monteCarloP(nullValues,observed)
nullValues = nullValues(:);
nullValues = nullValues(isfinite(nullValues));
nValid = numel(nullValues);
nExceed = 0;
confidenceInterval = [NaN NaN];
if nValid == 0 || ~isfinite(observed)
    p = NaN;
    return
end
nExceed = sum(nullValues >= observed);
p = (nExceed+1)/(nValid+1);
confidenceInterval = wilsonInterval(nExceed,nValid);
end

function pCurve = maxStatisticPCurve(nullMaximum,observedCurve)
observedCurve = observedCurve(:);
pCurve = nan(size(observedCurve));
nullMaximum = nullMaximum(:);
nullMaximum = nullMaximum(isfinite(nullMaximum));
if isempty(nullMaximum)
    return
end
nullMaximum = sort(nullMaximum,'ascend');
nNull = numel(nullMaximum);
for ii = find(isfinite(observedCurve))'
    firstExceedance = firstGreaterOrEqual(nullMaximum,observedCurve(ii));
    nExceed = nNull-firstExceedance+1;
    pCurve(ii) = (1+nExceed)/(nNull+1);
end
end

function index = firstGreaterOrEqual(sortedValues,threshold)
% Binary lower-bound search preserving the Monte Carlo >= tie rule.
low = 1;
high = numel(sortedValues)+1;
while low < high
    middle = floor((low+high)/2);
    if middle <= numel(sortedValues) && sortedValues(middle) < threshold
        low = middle+1;
    else
        high = middle;
    end
end
index = low;
end

function interval = wilsonInterval(k,n)
if n <= 0
    interval = [NaN NaN];
    return
end
z = 1.95996398454005;
phat = k/n;
denominator = 1+z^2/n;
center = (phat+z^2/(2*n))/denominator;
halfWidth = z/denominator * ...
    sqrt(phat*(1-phat)/n+z^2/(4*n^2));
interval = [max(0,center-halfWidth),min(1,center+halfWidth)];
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

function tol = frequencyTolerance(f)
if isempty(f)
    tol = 0;
else
    tol = max(1,max(abs(f)))*1e-10;
end
end

function tolerance = activeGroupWeightTolerance()
tolerance = 1e-8;
end

function tf = usesFourGroupTraining(targetModel)
tf = any(strcmp(targetModel, ...
    {'four-group','four-group-coherent-nine'}));
end

function tf = usesCoherentNineTarget(targetModel)
tf = any(strcmp(targetModel, ...
    {'legacy','four-group-coherent-nine','rayleigh-peak-coherent-nine'}));
end

function tf = usesRayleighPeakTraining(targetModel)
tf = strcmp(targetModel,'rayleigh-peak-coherent-nine');
end

function method = targetAmplitudeMethod(targetModel)
if usesRayleighPeakTraining(targetModel)
    method = 'separately calibrated per-orbit Rayleigh-band maxima';
elseif strcmp(targetModel,'four-group-coherent-nine')
    method = 'leakage-corrected four-group union-band energies';
elseif strcmp(targetModel,'four-group')
    method = 'four-group leakage-corrected union-band energies';
else
    method = 'legacy per-orbit peak training with four-group RMS validation';
end
end

function level = frozenValidationWeightLevel(targetModel)
if usesRayleighPeakTraining(targetModel)
    level = 'nine individual orbital amplitudes';
else
    level = 'four RMS orbital-group amplitudes';
end
end
