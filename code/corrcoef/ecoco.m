function [prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,sr_p,ecoDetails] = ...
   ecoco(data,~,orbit9,window,dt,step,delinear,red,pad,sr1,sr2,srstep,nsim,adjust,~,plotn,method,fmaxdata,main_unit_selection,calcMode,maxFrequency,seed,anchorFraction,varargin)
% Evolutionary COCO using sliding-window 1-slice COCO.
%
% Each window is evaluated by corrcoefslices_rankNew, so eCOCO uses the
% same target construction, Monte Carlo p-value, and pCOCO definition as
% the upgraded COCO workflow.
% Modern Adaptive/Blocked modes clean, sort, average duplicate depths,
% and conditionally interpolate at the median spacing at this public entry
% point. Interleaved mode instead retains cleaned raw observations so every
% complete window can split by globally fixed odd/even identity before
% fold-specific interpolation. Every observed and null fold/window is then
% linearly detrended.
% Optional trailing name-value input:
%   ProgressFcn  callback FCN(fraction,message), with a determinate
%                FRACTION on [0,1].
%   SeparateFinalPanel  compatibility option. Plot mode 1 always displays
%                the final eCOCO map in its own figure (default true).
%   Verbose      print detailed tracked-rate and legacy window messages
%                (default true for backward compatibility).
%   InterleavedWindowMode  'physical-depth' (default) or 'legacy-count'.
%                The GUI uses physical-depth so WINDOW and the requested
%                sliding step retain their literal depth units.
%   InterleavedStepDepth  exact depth-coordinate center spacing. Empty
%                uses STEP*DT, preserving STEP's sample-count units.
%   ECOCOWindowMode  common modern eCOCO window contract:
%                'physical-depth' (default) or 'legacy-count'.
%   ECOCOStepDepth  exact physical center spacing for Adaptive,
%                Blocked, and Interleaved eCOCO. Empty preserves the
%                historical STEP*DT interpretation.
%   ECOCOCenterLimits  optional [first last] physical output-center limits.
%                The GUI uses the unpadded record limits when edge padding
%                is enabled, so synthetic padding never creates extra maps.
%   BlockedConsensusPolicy 'supported' (default) preserves Blocked eCOCO's
%                historical one-direction edge fallback. 'strict' publishes
%                only the bidirectionally supported STRICTCONSENSUS surface;
%                one-direction edge windows remain NaN and cannot enter the
%                tracked ridge.

if nargin < 20 || isempty(calcMode)
    calcMode = 'adaptive';
end
if nargin < 21 || isempty(maxFrequency)
    maxFrequency = 1.2*max(1./orbit9(:));
end
if nargin < 22 || isempty(seed)
    seed = 1;
end
if nargin < 23 || isempty(anchorFraction)
    anchorFraction = 0.5;
end
progressParser = inputParser;
progressParser.FunctionName = mfilename;
addParameter(progressParser,'ProgressFcn',[],@(x) isempty(x) || ...
    isa(x,'function_handle'));
addParameter(progressParser,'SeparateFinalPanel',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(x == [0 1]));
addParameter(progressParser,'Verbose',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(x == [0 1]));
addParameter(progressParser,'InterleavedWindowMode','physical-depth', ...
    @(x) ischar(x) || (isstring(x) && isscalar(x)));
addParameter(progressParser,'InterleavedStepDepth',[],@(x) isempty(x) || ...
    (isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x > 0));
addParameter(progressParser,'ECOCOWindowMode','physical-depth', ...
    @(x) ischar(x) || (isstring(x) && isscalar(x)));
addParameter(progressParser,'ECOCOStepDepth',[],@(x) isempty(x) || ...
    (isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x > 0));
addParameter(progressParser,'ECOCOCenterLimits',[],@(x) isempty(x) || ...
    (isnumeric(x) && isvector(x) && numel(x) == 2 && isreal(x) && ...
    all(isfinite(x)) && x(2) >= x(1)));
addParameter(progressParser,'BlockedConsensusPolicy','supported',@(x) ...
    ischar(x) || (isstring(x) && isscalar(x)));
% Retained as an undocumented name-value alias for saved scripts.
addParameter(progressParser,'CrossfitConsensus','',@(x) ...
    ischar(x) || (isstring(x) && isscalar(x)));
parse(progressParser,varargin{:});
progressFcn = progressParser.Results.ProgressFcn;
% Retain the accepted name-value option for existing scripts, but enforce
% the common plotting contract at the public wrapper and in ECOCOPLOT.
separateFinalPanel = true;
verbose = logical(progressParser.Results.Verbose);
interleavedWindowMode = validatestring( ...
    char(progressParser.Results.InterleavedWindowMode), ...
    {'legacy-count','physical-depth'},mfilename,'InterleavedWindowMode');
interleavedStepDepth = progressParser.Results.InterleavedStepDepth;
ecocoWindowMode = validatestring( ...
    char(progressParser.Results.ECOCOWindowMode), ...
    {'legacy-count','physical-depth'},mfilename,'ECOCOWindowMode');
ecocoStepDepth = progressParser.Results.ECOCOStepDepth;
ecocoCenterLimits = progressParser.Results.ECOCOCenterLimits;
blockedConsensusPolicy = char( ...
    progressParser.Results.BlockedConsensusPolicy);
legacyConsensusPolicy = char(progressParser.Results.CrossfitConsensus);
if ~isempty(legacyConsensusPolicy)
    if ~any(strcmpi(progressParser.UsingDefaults, ...
            'BlockedConsensusPolicy')) && ...
            ~strcmpi(blockedConsensusPolicy,legacyConsensusPolicy)
        error('Acycle:BlockedECOCO:ConflictingConsensusPolicy', ...
            ['BlockedConsensusPolicy and its compatibility alias specify ', ...
             'different values.']);
    end
    blockedConsensusPolicy = legacyConsensusPolicy;
end
blockedConsensusPolicy = validatestring(blockedConsensusPolicy, ...
    {'supported','strict'},mfilename,'BlockedConsensusPolicy');
interleavedModeExplicit = ~any(strcmpi( ...
    progressParser.UsingDefaults,'InterleavedWindowMode'));
interleavedStepExplicit = ~any(strcmpi( ...
    progressParser.UsingDefaults,'InterleavedStepDepth'));
validateattributes(maxFrequency,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'maxFrequency',21);
validateattributes(seed,{'numeric'}, ...
    {'scalar','integer','finite','nonnegative','<=',2^32-1}, ...
    mfilename,'seed',22);
validateattributes(anchorFraction,{'numeric'}, ...
    {'scalar','real','finite','positive','<=',2}, ...
    mfilename,'anchorFraction',23);
highestOrbitFrequency = max(1./orbit9(:));
if maxFrequency < highestOrbitFrequency-64*eps(max(1,highestOrbitFrequency))
    error('ecoco:MaximumFrequencyExcludesOrbit', ...
        'MAXFREQUENCY must include the highest nominal orbital frequency.');
end
if nargin < 19 || isempty(main_unit_selection)
    main_unit_selection = get_main_unit_selection();
end
if nargin < 18 || isempty(fmaxdata)
    fmaxdata = 1/(2*dt);
end
if nargin < 17 || isempty(method)
    method = 'Spearman';
end
if nargin < 16 || isempty(plotn)
    plotn = 1;
end
calcMode = lower(strtrim(char(calcMode)));
if ~ismember(calcMode,{'adaptive','crossfit','interleaved','fast','accurate'})
    error(['Select Adaptive eCOCO, Blocked eCOCO, or Interleaved eCOCO ', ...
        'through a supported Acycle interface.']);
end
if strcmp(blockedConsensusPolicy,'strict') && ~strcmp(calcMode,'crossfit')
    error('Acycle:BlockedECOCO:ConsensusPolicyMethodMismatch', ...
        'Strict bidirectional consensus is valid only for Blocked eCOCO.');
end

ecoDetails = struct;

% New public eCOCO algorithms.  All retain the complete sedimentation-
% rate grid.  The old Fast/Accurate implementation remains below as an
% unadvertised compatibility branch for scripts that still call it.
if any(strcmp(calcMode,{'adaptive','crossfit','interleaved'}))
    try
    if adjust ~= 0
        error('ecoco:LegacyAdjustmentUnsupported', ...
            'Modern eCOCO algorithms require ADJUST=0.');
    end
    validateattributes(dt,{'numeric'}, ...
        {'scalar','real','finite','positive'},mfilename,'dt',5);
    requestedSamplingInterval = dt;
    if strcmp(calcMode,'interleaved')
        % Do not call cocoPrepareRegularData here: whole-record
        % interpolation would mix the future training and validation folds.
        inputPreprocessing = struct( ...
            'method','clean raw then split each window before interpolation', ...
            'fullRecordInterpolation',false, ...
            'splitBeforeInterpolation',true);
    else
        [data,inputPreprocessing] = cocoPrepareRegularData( ...
            data,sprintf('%s input',ecocoPublicMethodName(calcMode)), ...
            'MaximumPoints',1e6,'MinimumPoints',4,'Verbose',verbose);
        dt = inputPreprocessing.outputSpacing;
        if verbose && abs(requestedSamplingInterval-dt) > ...
                cocoSamplingTolerance(data(:,1),dt)
            fprintf(['>> eCOCO sampling interval updated from the caller value ', ...
                '%.12g m to the preprocessed median interval %.12g m.\n'], ...
                requestedSamplingInterval,dt);
        end
    end
    srGrid = (sr1:srstep:sr2)';
    coreProgressFcn = [];
    if ~isempty(progressFcn)
        % Reserve the final two percent for ridge tracking and plotting in
        % this wrapper so the dialog does not claim completion too early.
        % Suppress the core's terminal 100% message: scaling that message to
        % 98% would mislabel a completion notice as intermediate work.  This
        % wrapper emits the single terminal completion message after ridge
        % tracking and plotting are actually finished.
        coreProgressFcn = @(fraction,message) reportEcocoCoreProgress( ...
            progressFcn,fraction,message);
    end
    switch calcMode
        case 'adaptive'
            if isempty(ecocoStepDepth)
                ecocoStepDepth = step*dt;
            end
            result = ecocoAdaptiveCore(data,orbit9,window,dt,step,red,pad, ...
                srGrid,nsim,method,maxFrequency,seed, ...
                'ProgressFcn',coreProgressFcn, ...
                'WindowMode',ecocoWindowMode, ...
                'StepDepth',ecocoStepDepth, ...
                'CenterLimits',ecocoCenterLimits);
        case 'crossfit'
            if isempty(ecocoStepDepth)
                ecocoStepDepth = step*dt;
            end
            result = ecocoCrossfitCore(data,orbit9,window,dt,step,red,pad, ...
                srGrid,nsim,method,maxFrequency,seed,anchorFraction, ...
                'ComputeLocalP',true, ...
                'ProgressFcn',coreProgressFcn, ...
                'WindowMode',ecocoWindowMode, ...
                'StepDepth',ecocoStepDepth, ...
                'CenterLimits',ecocoCenterLimits);
        case 'interleaved'
            if ~interleavedModeExplicit
                interleavedWindowMode = ecocoWindowMode;
            end
            if ~interleavedStepExplicit
                interleavedStepDepth = ecocoStepDepth;
            end
            if strcmp(interleavedWindowMode,'physical-depth') && ...
                    isempty(interleavedStepDepth)
                interleavedStepDepth = step*dt;
            end
            result = ecocoInterleavedCore( ...
                data,orbit9,window,dt,step,red,pad,srGrid,nsim,method, ...
                maxFrequency,seed,'ProgressFcn',coreProgressFcn, ...
                'WindowMode',interleavedWindowMode, ...
                'StepDepth',interleavedStepDepth);
    end
    if strcmp(calcMode,'crossfit')
        result.blockedConsensusPolicy = blockedConsensusPolicy;
        if strcmp(blockedConsensusPolicy,'strict')
            result.rho = result.strictConsensus.rho;
            result.pLocal = result.strictConsensus.pLocal;
            result.pParametric = nan(size(result.rho));
            result.pGlobal = result.strictConsensus.pGlobal;
            result.nOrbit = result.strictConsensus.nOrbit;
            result.pCOCO = result.strictConsensus.pCOCO;
            result.score = result.strictConsensus.score;
            result.rootConsensus = ...
                'strict bidirectional consensus; no one-sided fallback';
        else
            result.rootConsensus = ...
                'supported consensus with one-sided edge fallback';
        end
    end
    prt_sr = result.srGrid(:);
    out_depth = result.depth(:);
    out_ecc = result.rho;
    % In upgraded Adaptive and Blocked eCOCO, OUT_EP carries the
    % same-rate Monte Carlo Local p map. The legacy output position is
    % retained for GUI and script compatibility; analytic correlation
    % p-values are not valid for a target estimated from the spectra.
    if isfield(result,'pLocal') && ~isempty(result.pLocal)
        out_ep = result.pLocal;
    else
        out_ep = result.pParametric;
    end
    out_eci = result.pGlobal;
    out_ecoco = result.pCOCO;
    out_ecocorb = result.score;
    out_norbit = result.nOrbit;
    ecoDetails = result;
    if isfield(result,'inputPreprocessing')
        inputPreprocessing = result.inputPreprocessing;
    end
    ecoDetails.separateFinalPanel = separateFinalPanel;
    ecoDetails.inputPreprocessing = inputPreprocessing;
    ecoDetails.requestedSamplingInterval = requestedSamplingInterval;
    ecoDetails.samplingInterval = dt;
    if isfield(result,'samplingInterval') && ...
            isfinite(result.samplingInterval)
        ecoDetails.samplingInterval = result.samplingInterval;
    end
    orbitn = numel(orbit9);
    sr_p_fallback = bestPerWindowSummary( ...
        prt_sr,out_depth,out_ecc,out_eci,out_norbit,out_ecocorb);
    sr_p = trackEcocoRidge(out_ecocorb,prt_sr,out_depth,out_ecc, ...
        out_eci,out_norbit,sr_p_fallback);
    ecoDetails.trackedSedimentationRate = sr_p;
    if verbose
        if strcmp(calcMode,'interleaved') && ...
                isfield(result,'resolutionWarningWindowCount') && ...
                result.resolutionWarningWindowCount > 0
            fprintf(['>> Interleaved eCOCO resolution note: %d resolved ', ...
                'window(s) have their consensus best rate outside the ', ...
                'shared odd/even all-nine resolvability interval. ', ...
                'Interpret those ridge points as partial-orbit results; ', ...
                'see folds/allNineRateRangeShared in the saved details.\n'], ...
                result.resolutionWarningWindowCount);
        end
        printTrackedEcocoResults(sr_p,orbitn);
    end
    if abs(plotn) > 0
        ecocoplot(prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco, ...
            out_ecocorb,out_norbit,plotn,ecoDetails);
    end
    reportEcocoProgress(progressFcn,1,sprintf('%s complete.',result.name));
    catch exception
        throwPublicEcocoException(exception,calcMode)
    end
    return
end

[lang_choice,lang_id,lang_var] = ecocoLanguageSettings();
[~, ec79] = ismember('ec79',lang_id);
[~, ec85] = ismember('ec85',lang_id);

data = data(all(isfinite(data(:,1:2)),2),1:2);
data = sortrows(data,1);
nrow = size(data,1);
if nrow < 3
    error('eCOCO requires at least three valid data points.');
end

time = data(:,1);
datay = data(:,2);
npts = fix(window/dt);
if npts < 3
    error('eCOCO window is too small for the data sampling interval.');
end
if npts > nrow
    error('eCOCO window is longer than the data series.');
end
if step < 1 || step >= nrow/2
   error('Error: sliding step is too large!');
end

starts = 1:step:(nrow-npts+1);
m3 = numel(starts);
if m3 < 1
    error('No valid eCOCO sliding windows.');
end

sr_range = sr1:srstep:sr2;
nofsr = numel(sr_range);
orbitn = numel(orbit9);

prt_sr = sr_range(:);
out_depth = nan(m3,1);
out_ecc = nan(nofsr,m3);
out_ep = nan(nofsr,m3);
out_eci = nan(nofsr,m3);
out_ecoco = nan(nofsr,m3);
out_ecocorb = nan(nofsr,m3);
out_norbit = nan(nofsr,m3);
sr_p = nan(m3,8);

if isempty(progressFcn)
    waitbarRandomState = rng;
    restoreWaitbarRandomState = onCleanup(@()rng(waitbarRandomState));
    if lang_choice == 0
        hwaitbar = waitbar(0,'eCOCO processing ... [CTRL + C to quit]', ...
           'WindowStyle','modal');
    else
        hwaitbar = waitbar(0,['eCOCO ',lang_var{ec79}], ...
           'WindowStyle','modal');
    end
    clear restoreWaitbarRandomState
else
    hwaitbar = [];
    reportEcocoProgress(progressFcn,0,sprintf( ...
        'Preparing %d sliding windows.',m3));
end
cleanupObj = onCleanup(@()safeClose(hwaitbar));
if ~isempty(hwaitbar)
    hwaitbar_find = findobj(hwaitbar,'Type','Patch');
    set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0])
    setappdata(hwaitbar,'canceling',0)
end

nmc_n = max(1,ceil(m3/100));
if ~isempty(hwaitbar)
    updateEcocoWaitbar(hwaitbar,0,'Preparing sliding windows.');
end

if verbose
    if strcmp(calcMode,'fast')
        disp('>> Step 1: run the internal eCOCO compatibility calculation');
    else
        disp('>> Step 1: run the internal eCOCO compatibility calculation');
    end
end

fastNull = [];
fastFirstCorrCI = [];
if strcmp(calcMode,'fast') && nsim > 0
    datWin0 = [time(starts(1):starts(1)+npts-1), datay(starts(1):starts(1)+npts-1)];
    if delinear == 1
        datWin0(:,2) = detrend(datWin0(:,2),0);
    end
    [fastFirstCorrCI,~,fastNull] = corrcoefslices_rankNew( ...
        datWin0,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,nsim,0,1, ...
        method,fmaxdata,main_unit_selection,true,'adaptive', ...
        'MaxFrequency',maxFrequency,'Seed',seed);
end

for i = 1:m3
    m1 = starts(i);
    m2 = m1+npts-1;
    datWin = [time(m1:m2), datay(m1:m2)];
    if delinear == 1
        datWin(:,2) = detrend(datWin(:,2),0);
    end
    out_depth(i) = (datWin(1,1) + datWin(end,1))/2;

    if strcmp(calcMode,'fast')
        if i == 1 && ~isempty(fastFirstCorrCI)
            corrCI = fastFirstCorrCI;
        else
            [corrCI,~] = corrcoefslices_rankNew( ...
                datWin,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,0,0,1, ...
                method,fmaxdata,main_unit_selection,false,'adaptive', ...
                'MaxFrequency',maxFrequency,'Seed',mod(seed+i-2,2^32));
        end
        corr_h0 = [];
    else
        [corrCI,corr_h0] = corrcoefslices_rankNew( ...
            datWin,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,nsim,0,1, ...
            method,fmaxdata,main_unit_selection,false,'adaptive', ...
            'MaxFrequency',maxFrequency,'Seed',mod(seed+i-2,2^32));
    end

    if i == 1
        prt_sr = corrCI(:,1);
    end

    out_ecc(:,i) = corrCI(:,2);
    out_ep(:,i) = corrCI(:,3);
    if strcmp(calcMode,'fast') && ~isempty(fastNull)
        out_eci(:,i) = globalPValuesFromNull(corrCI(:,2),fastNull,nofsr);
    else
        out_eci(:,i) = getPValues(corr_h0,nofsr);
    end
    out_norbit(:,i) = getOrbitCounts(corr_h0,corrCI,orbitn,nofsr);
    out_ecoco(:,i) = pcocoValue(out_ecc(:,i),out_eci(:,i));
    out_ecocorb(:,i) = out_norbit(:,i) ./ orbitn .* out_ecoco(:,i);

    bestIdx = bestFiniteIndex(out_ecocorb(:,i));
    if ~isempty(bestIdx)
        sr_p(i,1) = out_depth(i);
        sr_p(i,2) = prt_sr(bestIdx);
        sr_p(i,3) = out_ecc(bestIdx,i);
        sr_p(i,4) = out_eci(bestIdx,i);
        sr_p(i,5) = out_norbit(bestIdx,i);
        sr_p(i,6) = out_ecocorb(bestIdx,i);

        if verbose
            disp(['-----> Location : ',num2str(out_depth(i)), ...
                ' m. Iteration : ',num2str(m3),' -> ',num2str(i)])
            disp(['>>  Sedimentation rate = [ ',num2str(sr_p(i,2)), ...
                ' ] cm/kyr. # of orbital cycles involved : ', ...
                num2str(sr_p(i,5)),' of ',num2str(orbitn)]);
            disp(['    Correlation coefficient ',num2str(sr_p(i,3)), ...
                '. p-value ',num2str(sr_p(i,4)), ...
                '. pCOCO ',num2str(out_ecoco(bestIdx,i)), ...
                '. pCOCOxOrbits ',num2str(sr_p(i,6))])
        end
    else
        if verbose
            disp(['-----> Location : ',num2str(out_depth(i)), ...
                ' m. Iteration : ',num2str(m3),' -> ',num2str(i), ...
                '. No finite pCOCO solution.'])
        end
    end

    if (rem(i,nmc_n) == 0 || i == m3) && ~isempty(hwaitbar)
        updateEcocoWaitbar(hwaitbar,i/m3,sprintf( ...
            'eCOCO sliding windows: %d of %d (%.1f%%)', ...
            i,m3,100*i/m3));
    end
    reportEcocoProgress(progressFcn,0.98*i/m3,sprintf( ...
        'Sliding windows completed: %d of %d',i,m3));
    if ~isempty(hwaitbar) && getappdata(hwaitbar,'canceling')
        break
    end
end

reportEcocoProgress(progressFcn,0.98,sprintf( ...
    'Sliding windows completed: %d of %d',m3,m3));

sr_p = trackEcocoRidge(out_ecocorb,prt_sr,out_depth,out_ecc, ...
    out_eci,out_norbit,sr_p);
if verbose
    printTrackedEcocoResults(sr_p,orbitn);
end

if abs(plotn) > 0
    if lang_choice == 0
        hwarn = warndlg('Wait, eCOCO plot ...');
    else
        hwarn = warndlg(lang_var{ec85});
    end
    ecocoplot(prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,plotn);
    try
        close(hwarn)
    catch
    end

    hold on
    plot(sr_p(:,2), sr_p(:,1), 'r-o')
end
reportEcocoProgress(progressFcn,1,'eCOCO complete.');

function name = ecocoPublicMethodName(calcMode)
switch calcMode
    case 'adaptive'
        name = 'Adaptive eCOCO';
    case 'crossfit'
        name = 'Blocked eCOCO';
    case 'interleaved'
        name = 'Interleaved eCOCO';
    otherwise
        name = 'eCOCO compatibility analysis';
end

function throwPublicEcocoException(exception,calcMode)
name = ecocoPublicMethodName(calcMode);
switch calcMode
    case 'adaptive'
        methodToken = 'AdaptiveECOCO';
    case 'crossfit'
        methodToken = 'BlockedECOCO';
    case 'interleaved'
        methodToken = 'InterleavedECOCO';
    otherwise
        methodToken = 'ECOCO';
end
tokens = regexp(char(string(exception.identifier)), ...
    '([^:]+)$','tokens','once');
if isempty(tokens)
    category = 'AnalysisFailed';
else
    category = regexprep(tokens{1},'[^A-Za-z0-9]','');
end
if isempty(category) || ~isletter(category(1)) || ...
        ~isempty(regexpi(category,[ ...
        'cvcoco9|adaptive9|interleavedcvcoco|cross[-_ ]?fit|', ...
        'method[-_ ]?[ab]|ecoco(?:adaptive|crossfit|interleaved)core'], ...
        'once'))
    category = 'AnalysisFailed';
end
message = publicEcocoFailureText(exception.message);
publicException = MException( ...
    sprintf('Acycle:%s:%s',methodToken,category), ...
    '%s failed: %s',name,message);
throwAsCaller(publicException)

function text = publicEcocoFailureText(text)
text = char(string(text));
replacements = {
    'ecocoAdaptiveCore','Adaptive eCOCO';
    'ecocoCrossfitCore','Blocked eCOCO';
    'ecocoInterleavedCore','Interleaved eCOCO';
    'interleavedcvcoco','Interleaved cvCOCO';
    'cvcoco9[A-Za-z]*','Blocked cvCOCO';
    'adaptive9[A-Za-z]*','Adaptive COCO';
    'cross[- ]?fit(?:ted)?','blocked';
    'Method[- ]?A','per-orbit';
    'Method[- ]?B','four-group';
    '\<route\>','analysis path'};
for index = 1:size(replacements,1)
    text = regexprep(text,replacements{index,1}, ...
        replacements{index,2},'ignorecase');
end

function pValues = getPValues(corr_h0,nofsr)
pValues = nan(nofsr,1);
if ~isempty(corr_h0)
    pValues(1:min(nofsr,size(corr_h0,1))) = corr_h0(1:min(nofsr,size(corr_h0,1)),1);
end

function pValues = globalPValuesFromNull(observed,nullCorr,nofsr)
pValues = nan(nofsr,1);
nullMax = maxFiniteByColumn(nullCorr);
nullMax = nullMax(isfinite(nullMax));
if isempty(nullMax)
    return
end
n = min([nofsr,numel(observed)]);
for ii = 1:n
    obs = observed(ii);
    if ~isfinite(obs)
        continue
    end
    pValues(ii) = (sum(nullMax >= obs) + 1) / (numel(nullMax) + 1);
end

function colMax = maxFiniteByColumn(x)
colMax = nan(1,size(x,2));
for ii = 1:size(x,2)
    xi = x(:,ii);
    xi = xi(isfinite(xi));
    if ~isempty(xi)
        colMax(ii) = max(xi);
    end
end

function norbit = getOrbitCounts(corr_h0,corrCI,orbitn,nofsr)
norbit = nan(nofsr,1);
if size(corr_h0,2) >= 2
    norbit(1:min(nofsr,size(corr_h0,1))) = corr_h0(1:min(nofsr,size(corr_h0,1)),2);
else
    norbit(1:min(nofsr,size(corrCI,1))) = orbitn - corrCI(1:min(nofsr,size(corrCI,1)),end);
end

function value = pcocoValue(rho,pValue)
pSafe = pValue;
pSafe(~isfinite(pSafe) | pSafe <= 0) = NaN;
pSafe(pSafe > 1) = 1;
value = rho .* abs(log10(pSafe));

function idx = bestFiniteIndex(values)
idx = [];
valid = find(isfinite(values));
if isempty(valid)
    return
end
[~,loc] = max(values(valid));
idx = valid(loc);

function summary = bestPerWindowSummary( ...
        srGrid,depth,rho,pGlobal,nOrbit,score)
nWindows = numel(depth);
summary = nan(nWindows,8);
% Preserve every requested window coordinate even when no finite score is
% available.  Columns 2:8 remain NaN for an unresolved window, so saved
% diagnostics retain their row identity without implying a ridge result.
summary(:,1) = depth(:);
for windowIndex = 1:nWindows
    bestIndex = bestFiniteIndex(score(:,windowIndex));
    if isempty(bestIndex)
        continue
    end
    summary(windowIndex,2) = srGrid(bestIndex);
    summary(windowIndex,3) = rho(bestIndex,windowIndex);
    summary(windowIndex,4) = pGlobal(bestIndex,windowIndex);
    summary(windowIndex,5) = nOrbit(bestIndex,windowIndex);
    summary(windowIndex,6) = score(bestIndex,windowIndex);
end

function printTrackedEcocoResults(sr_p,orbitn)
disp('>> Tracked eCOCO sedimentation-rate path:')
for ii = 1:size(sr_p,1)
    if ~isfinite(sr_p(ii,2))
        continue
    end
    disp(['-----> Location : ',num2str(sr_p(ii,1)), ...
        ' m. Tracked sed. rate = [ ',num2str(sr_p(ii,2)), ...
        ' ] cm/kyr. Local range = [ ',num2str(sr_p(ii,7)), ...
        ', ',num2str(sr_p(ii,8)), ...
        ' ] cm/kyr. # of orbital cycles involved : ', ...
        num2str(sr_p(ii,5)),' of ',num2str(orbitn)]);
    disp(['    Correlation coefficient ',num2str(sr_p(ii,3)), ...
        '. p-value ',num2str(sr_p(ii,4)), ...
        '. Ridge score ',num2str(sr_p(ii,6))])
end

function sr_p = trackEcocoRidge( ...
        score,prt_sr,out_depth,out_ecc,out_eci,out_norbit,sr_p_fallback)
sr_p = sr_p_fallback;
[nSr,nWin] = size(score);
if nSr == 0 || nWin == 0 || numel(prt_sr) ~= nSr
    return
end

scoreNorm = nan(size(score));
for col = 1:nWin
    colScore = score(:,col);
    ok = isfinite(colScore);
    if ~any(ok)
        continue
    end
    minScore = min(colScore(ok));
    maxScore = max(colScore(ok));
    if maxScore > minScore
        scoreNorm(ok,col) = (colScore(ok) - minScore) ./ (maxScore - minScore);
    else
        scoreNorm(ok,col) = 1;
    end
end

if ~any(isfinite(scoreNorm(:)))
    return
end

srStep = median(abs(diff(prt_sr)));
if ~isfinite(srStep) || srStep <= 0
    srStep = 1;
end
jumpScale = max(2,4*srStep);
jumpPenalty = 0.35;

dp = -inf(nSr,nWin);
back = nan(nSr,nWin);
validFirst = isfinite(scoreNorm(:,1));
dp(validFirst,1) = scoreNorm(validFirst,1);

for col = 2:nWin
    validNow = find(isfinite(scoreNorm(:,col)));
    if isempty(validNow)
        continue
    end
    validPrev = find(isfinite(dp(:,col-1)));
    if isempty(validPrev)
        dp(validNow,col) = scoreNorm(validNow,col);
        continue
    end

    for row = validNow(:)'
        jumps = abs(prt_sr(row) - prt_sr(validPrev)) ./ jumpScale;
        transitionScore = dp(validPrev,col-1) - jumpPenalty .* (jumps .^ 2);
        [bestPrevScore,bestLoc] = max(transitionScore);
        dp(row,col) = scoreNorm(row,col) + bestPrevScore;
        back(row,col) = validPrev(bestLoc);
    end
end

lastCol = find(any(isfinite(dp),1),1,'last');
if isempty(lastCol)
    return
end
[~,row] = max(dp(:,lastCol));
path = nan(1,nWin);
path(lastCol) = row;
for col = lastCol:-1:2
    prev = back(path(col),col);
    if isnan(prev)
        break
    end
    path(col-1) = prev;
end

for col = 1:nWin
    row = path(col);
    if ~isfinite(row)
        continue
    end
    row = round(row);
    sr_p(col,1) = out_depth(col);
    sr_p(col,2) = prt_sr(row);
    sr_p(col,3) = out_ecc(row,col);
    sr_p(col,4) = out_eci(row,col);
    sr_p(col,5) = out_norbit(row,col);
    sr_p(col,6) = score(row,col);
    [sr_p(col,7),sr_p(col,8)] = localSrRange(score(:,col),prt_sr,row,0.9);
end

function [srLow,srHigh] = localSrRange(scoreCol,prt_sr,row,relativeThreshold)
srLow = NaN;
srHigh = NaN;
if row < 1 || row > numel(scoreCol) || ~isfinite(scoreCol(row))
    return
end

threshold = relativeThreshold .* scoreCol(row);
ok = isfinite(scoreCol) & scoreCol >= threshold;
if ~ok(row)
    ok(row) = true;
end

lo = row;
while lo > 1 && ok(lo-1)
    lo = lo - 1;
end

hi = row;
while hi < numel(ok) && ok(hi+1)
    hi = hi + 1;
end

srLow = min(prt_sr([lo,hi]));
srHigh = max(prt_sr([lo,hi]));

function main_unit_selection = get_main_unit_selection()
main_unit_selection = 0;
try
    main_unit_selection = evalin('base','main_unit_selection');
catch
end

function safeClose(h)
randomState = rng;
restoreRandomState = onCleanup(@()rng(randomState));
try
    if ishandle(h)
        close(h);
    end
catch
end
clear restoreRandomState

function updateEcocoWaitbar(h,fraction,message)
if isempty(h) || ~ishandle(h)
    return
end
randomState = rng;
restoreRandomState = onCleanup(@()rng(randomState));
waitbar(min(max(double(fraction),0),1),h,message);
clear restoreRandomState

function reportEcocoProgress(progressFcn,fraction,message)
if isempty(progressFcn)
    return
end
randomState = rng;
restoreRandomState = onCleanup(@()rng(randomState));
progressFcn(min(max(double(fraction),0),1),message);
clear restoreRandomState

function reportEcocoCoreProgress(progressFcn,fraction,message)
isTerminalMessage = fraction >= 1 && ...
    contains(lower(string(message)),'complete');
if isempty(progressFcn) || isTerminalMessage
    return
end
reportEcocoProgress(progressFcn,0.98*fraction,message);

function [langChoice,langId,langVar] = ecocoLanguageSettings()
langChoice = 0;
langId = {};
langVar = {};
candidate = ac_user_settings('getLanguage');
if isnumeric(candidate) && isscalar(candidate) && ...
        isfinite(candidate) && ismember(candidate,[0,1])
    langChoice = candidate;
end
dictionaryPath = ecocoLanguageResource('langdict.xlsx');
if isempty(dictionaryPath)
    langChoice = 0;
    return
end
dictionary = readtable(dictionaryPath,'VariableNamingRule','preserve');
if width(dictionary) < 2+langChoice
    langChoice = 0;
end
langId = dictionary.ID;
langVar = table2cell(dictionary(:,2+langChoice));

function resourcePath = ecocoLanguageResource(filename)
resourcePath = '';
sourceDirectory = fileparts(mfilename('fullpath'));
candidates = {fullfile(sourceDirectory,'..','bin',filename), ...
    which(filename),fullfile(pwd,filename)};
for index = 1:numel(candidates)
    if ~isempty(candidates{index}) && exist(candidates{index},'file') == 2
        resourcePath = candidates{index};
        return
    end
end
