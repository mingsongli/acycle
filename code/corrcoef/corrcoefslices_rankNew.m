function [corrCI,corr_h0,corry,details] = corrcoefslices_rankNew(dat,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,nsim,plotn,slices,method,fmaxdata,main_unit_selection,showProgress,targetMode,varargin)
%CORRCOEFSLICES_RANKNEW Adaptive or fixed-target COCO analysis.
% INPUT
%   dat: two-column evenly spaced depth/value series; depth must be metres
%   orbit9: positive orbital periods in kyr
%   dt: depth sampling interval in metres
%   pad: periodogram NFFT (must be at least the longest slice)
%   sr1/sr2/srstep: tested sedimentation-rate grid in cm/kyr
%   adjust: audited Adaptive/fixed-target modes require 0
%   red: 0 none; 1 classical AR(1); 2 robust AR(1); 3 SWA removal
%   nsim: number of stationary-AR(1) Monte Carlo realizations
%   plotn: 1 = plot results. else = no plot
%   targetMode: 'adaptive' estimates target amplitudes from each data
%               spectrum and adds phase-averaged powers; 'adaptive9a'
%               estimates one amplitude per orbital Rayleigh-band peak;
%               'adaptive9b' fits four group amplitudes from Rayleigh-band
%               union areas with finite-record leakage correction. Both
%               9A/9B coherently sum nine zero-phase sine terms before
%               calculating power. 'adaptive9' remains a compatibility
%               alias for 'adaptive9a';
%               'fixed' retains the compatibility fixed-target engine;
%               'fixed9' uses the same fixed 1.0/0.8/0.6 amplitudes for
%               eccentricity/obliquity/precession but coherently sums all
%               nine zero-phase sine terms on the native spectral grid
% Optional name-value inputs after TARGETMODE:
%   MaxFrequency     maximum temporal frequency used in correlations,
%                    cycles/kyr (adaptive default is 1.2 times the
%                    highest requested orbital frequency; both fixed-mode
%                    defaults remain 0.5)
%   Seed             local Monte Carlo random seed (default 1)
%   ShowPeriodograms show spectrum diagnostic figures when PLOTN is 1
%                    (default true)
%   ProgressFcn      function handle called as FCN(fraction,message), or
%                    [] (default). FRACTION is determinate on [0,1].
% 
% OUTPUT
%   corrCI:     4-column series;
%                   c1 = tested sedimentation rates
%                   c2 = correlation coefficient for each sed. rates
%                   c3 = naive parametric correlation p-value (descriptive
%                        only; formal inference must use CORR_H0)
%                   c4 = number of missing/unresolved orbital periods
%   corr_h0:    3-column series
%                   c1 = Monte Carlo max-statistic p-value corrected for
%                       the full sedimentation-rate search grid
%                   c2 = number of contributing astronomical parameters
%                   c3 = local Monte Carlo p-value at each sedimentation
%                       rate before grid-search correction
%   corry:      Monte Carlo correlation matrix (rate by simulation)
%   details:    reproducibility and Monte Carlo diagnostics. Important
%               fields include rhoM, rhoEstimator, seed, nSimRequested,
%               nSimCompleted, nSimValid, nullMax, MaxFrequency, and pFloor.
% The Monte Carlo null is conditional on DAT after sorting, duplicate
% handling, and any regular-grid interpolation performed by the caller.
%   Mingsong Li, June 2017 @ Penn State
% Revised and publication-audited, 2026.
if nargin < 16 || isempty(showProgress)
    showProgress = true;
end
if nargin < 17 || isempty(targetMode)
    targetMode = 'adaptive';
end
targetMode = lower(strtrim(char(targetMode)));
if ~any(strcmp(targetMode, ...
        {'adaptive','adaptive9','adaptive9a','adaptive9b','fixed','fixed9'}))
    error(['COCO target mode must be ''adaptive'', ''adaptive9a'', ', ...
        '''adaptive9b'', ''adaptive9'' (9A alias), ''fixed'', or ', ...
        '''fixed9''.']);
end
optionParser = inputParser;
optionParser.FunctionName = mfilename;
defaultMaximumFrequency = 0.5;
if isAdaptiveTargetMode(targetMode) && isnumeric(orbit9) && ...
        ~isempty(orbit9) && all(isfinite(orbit9(:))) && all(orbit9(:) > 0)
    defaultMaximumFrequency = 1.2*max(1./orbit9(:));
end
addParameter(optionParser,'MaxFrequency',defaultMaximumFrequency,@(x) isnumeric(x) && ...
    isscalar(x) && isreal(x) && isfinite(x) && x > 0);
addParameter(optionParser,'Seed',1,@(x) isnumeric(x) && isscalar(x) && ...
    isreal(x) && isfinite(x) && x >= 0 && x == fix(x) && x <= 2^32-1);
addParameter(optionParser,'ShowPeriodograms',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    ismember(double(x),[0,1]));
addParameter(optionParser,'ProgressFcn',[],@(x) isempty(x) || ...
    isa(x,'function_handle'));
parse(optionParser,varargin{:});
maximumFrequency = optionParser.Results.MaxFrequency;
randomSeed = optionParser.Results.Seed;
showPeriodograms = logical(optionParser.Results.ShowPeriodograms);
progressFcn = optionParser.Results.ProgressFcn;

[dat,orbit9,dt,method,showProgress] = validateCocoInputs( ...
    dat,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,nsim,plotn,slices, ...
    method,fmaxdata,main_unit_selection,showProgress);
highestOrbitFrequency = max(1./orbit9);
if maximumFrequency < highestOrbitFrequency- ...
        64*eps(max(1,highestOrbitFrequency))
    error('corrcoefslices_rankNew:MaximumFrequencyExcludesOrbit', ...
        ['MaxFrequency (%.12g cycle/kyr) is below the highest nominal ', ...
         'orbital frequency (%.12g cycle/kyr). Increase it so every ', ...
         'requested astronomical period is inside the correlation band.'], ...
        maximumFrequency,highestOrbitFrequency);
end
details = defaultAdaptiveDetails();
details.seed = randomSeed;
details.nSimRequested = nsim;
details.nsimRequested = nsim;
details.MaxFrequency = maximumFrequency;
details.maxFrequency = maximumFrequency;
details.slices = slices;
details.pad = pad;
details.red = red;
details.method = method;
details.targetMode = targetMode;
details.nullConditioning = [ ...
    'stationary Gaussian AR(1) conditional on the regularized grid, ', ...
    'pre-specified periods/rate grid/Pad/MaxFrequency/red/slices/method; ', ...
    'raw irregular sampling and interpolation are not resimulated'];
reportCocoProgress(progressFcn,0,sprintf( ...
    'Preparing %s.',cocoTargetDisplayName(targetMode)));
if isAdaptiveTargetMode(targetMode)
    details.targetModel = adaptiveEvaluatorTargetModel(targetMode);
    details.targetAmplitudeMode = evaluatorTargetAmplitudeMode(targetMode);
    if strcmp(targetMode,'adaptive9b')
        details.targetConstruction = [ ...
            'nine zero-phase sine FFT terms summed coherently before ', ...
            'power, with four group amplitudes fitted independently for ', ...
            'each observed or Monte Carlo spectrum by finite-record ', ...
            'phase-averaged leakage correction and nonnegative least squares'];
        details.bandAssignment = [ ...
            'union of one rectangular-window ENBW band per resolved ', ...
            'member within long eccentricity, short eccentricity, ', ...
            'obliquity, and precession; PSD area integrated once per ', ...
            'group; rates are excluded when continuous bands from ', ...
            'different groups overlap or the active leakage matrix has ', ...
            'nonpositive/nonfinite diagonal energy or rcond below 1e-10'];
    elseif any(strcmp(targetMode,{'adaptive9','adaptive9a'}))
        details.targetConstruction = [ ...
            'nine zero-phase sine FFT terms summed coherently before ', ...
            'power, with per-orbit Rayleigh-band peak amplitudes fitted ', ...
            'independently for each observed or Monte Carlo spectrum'];
        details.bandAssignment = [ ...
            'one rectangular-window ENBW search band per orbit, clipped at ', ...
            'MaxFrequency; overlapping bins assigned to the nearest orbit'];
    else
        details.targetConstruction = [ ...
            'independent uniform-phase sine/cosine mean PSD templates added ', ...
            'noncoherently with per-spectrum adaptive amplitudes'];
        details.bandAssignment = [ ...
            'one rectangular-window ENBW search band per orbit, clipped at ', ...
            'MaxFrequency; overlapping bins assigned to the nearest orbit'];
    end
elseif strcmp(targetMode,'fixed9')
    details.targetModel = 'coherent-nine';
    details.targetAmplitudeMode = 'fixed';
    details.targetConstruction = [ ...
        'pre-specified 1.0/0.8/0.6 eccentricity/obliquity/precession ', ...
        'amplitudes expanded to nine zero-phase sine FFT terms and ', ...
        'summed coherently before power'];
    details.bandAssignment = [ ...
        'fixed target; frequency-resolved periods are included without ', ...
        'estimating amplitudes from the observed or simulated spectrum'];
end
if nsim > 0
    details.pFloor = 1/(nsim+1);
end

if isFixedTargetMode(targetMode) && adjust == 1
    error(['Fixed-target COCO is incompatible with adjust=1 because ', ...
        'target adjustment estimates power from the data. Use adjust=0.']);
end
if isAdaptiveTargetMode(targetMode) && adjust == 1
    error('corrcoefslices_rankNew:LegacyAdjustmentUnsupported', ...
        ['Adaptive COCO already estimates target amplitudes from each ', ...
         'spectrum. ADJUST=1 invokes a second legacy data-dependent ', ...
         'target adjustment that is not part of the audited method; use ', ...
         'ADJUST=0.']);
end
display = double(showProgress);  % show simulation steps
if showProgress
    if strcmp(targetMode,'fixed')
        disp('>> COCO target mode: fixed target (amplitudes 1.0 / 0.8 / 0.6 for eccentricity / obliquity / precession)')
    elseif strcmp(targetMode,'fixed9')
        disp(['>> COCO target mode: Fixed COCO9 coherent nine-term ', ...
            'target (fixed 1.0 / 0.8 / 0.6 amplitudes)'])
    else
        if strcmp(targetMode,'adaptive9b')
            disp(['>> COCO target mode: Adaptive COCO9B coherent ', ...
                'nine-term target (four-group area/leakage amplitudes)'])
        elseif any(strcmp(targetMode,{'adaptive9','adaptive9a'}))
            disp(['>> COCO target mode: Adaptive COCO9A coherent ', ...
                'nine-term target (per-orbit peak amplitudes)'])
        else
            disp(['>> COCO target mode: adaptive phase-averaged noncoherent ', ...
                'target (amplitudes estimated from each data spectrum)'])
        end
    end
end

%% Slice selection
if slices > 1
    [dat_slice, datanewMean] = data_slices(dat, slices);
else
    time = dat(:,1);
    value = dat(:,2);
    detrendedValue = detrend(value,1);
    if ~cocoResolvedDetrendedVariance(value,detrendedValue)
        error('corrcoefslices_rankNew:DegenerateSlice', ...
            ['The full record must retain numerically resolved variance ', ...
             'after linear detrending.']);
    end
    dat_slice = [time,detrendedValue];
    datanewMean = dat_slice;
end
datForTarget = targetBandwidthData(dat_slice, datanewMean, dat, slices);
sliceLengths = sum(isfinite(dat_slice(:,2:2:end)),1);
if any(sliceLengths < 4)
    error('corrcoefslices_rankNew:SliceTooShort', ...
        'Every slice must contain at least four finite observations.');
end
if pad < max(sliceLengths)
    error('corrcoefslices_rankNew:PadTooShort', ...
        'PAD must be at least the number of observations in the longest slice.');
end
for sliceIndex = 1:slices
    sliceValues = dat_slice(:,2*sliceIndex);
    sliceValues = sliceValues(isfinite(sliceValues));
    if numel(sliceValues) < 4 || ~isfinite(std(sliceValues)) || ...
            std(sliceValues) <= 0
        error('corrcoefslices_rankNew:DegenerateSlice', ...
            'Every slice must retain finite, nonzero variance after preprocessing.');
    end
end

%% For acycle language version (2.6 and after)
lang_choice = 0;
lang_id = {};
lang_var = {};
ec79 = [];
ec80 = [];
ec81 = [];
ec82 = [];
ec83 = [];
ec84 = [];
if plotn == 1 || showProgress
    [lang_choice,lang_id,lang_var] = cocoLanguageSettings();
    [~, ec79] = ismember('ec79',lang_id);
    [~, ec80] = ismember('ec80',lang_id);
    [~, ec81] = ismember('ec81',lang_id);
    [~, ec82] = ismember('ec82',lang_id);
    [~, ec83] = ismember('ec83',lang_id);
    [~, ec84] = ismember('ec84',lang_id);
end

%% Peridogram of the data series
% For each slices: power spectrum -> remove red noise -> save adjusted spectra
% calculate the mean of the adjusted spectra
cocoPlotFigure = gobjects(0);
cocoPlotTabs = gobjects(0);
%
periodogramRows = floor(pad/2)+1;
dataf = nan(periodogramRows,slices);
datap = nan(periodogramRows,slices);
ndata = max(2, size(datForTarget, 1));
dat_nyq = 1/(2*dt);   % Nyquist
dat_ray = 1/(ndata * dt);  % rayleigh, matched to the effective slice length
for j = 1: slices
    sliceValue = dat_slice(:,2*j);
    sliceValue = sliceValue(isfinite(sliceValue));
    [p,f] = periodogram(sliceValue,[],pad,1/dt);  % power of dat
    if any(~isfinite(p))
        error('corrcoefslices_rankNew:NonfinitePeriodogram', ...
            ['The observed periodogram overflowed or returned nonfinite ', ...
             'power. Rescale the proxy values before COCO.']);
    end
    negativeTolerance = 64*eps(max(1,max(abs(p))));
    if any(p < -negativeTolerance)
        error('corrcoefslices_rankNew:NegativePeriodogram', ...
            'The observed periodogram returned materially negative power.');
    end
    p(p < 0) = 0;

    % remove AR1 noise
    % 1 = classical red removed
    % 2 = robust red (ML96) removed
    % 3 = smoothed window average removed

    if red == 1
        [theored]=theoredar1ML(sliceValue,f,mean(p),dt);
        theored = theored(:);
        validateAdaptiveBackground(theored,p,'classical AR(1)');
        p = p - theored;
        p(p<0) = 0;   % power removing classic AR(1) noise

    elseif red == 2
        % robust
        % REDCONF_ANY expects normalized angular frequency. Convert the
        % periodogram frequency (cycles/m) to radians/sample.
        theored = redconf_any(2*pi*f*dt,p,dt,0.25,2);
        theored = theored(:);
        validateAdaptiveBackground(theored,p,'robust AR(1)');
        p = p - theored;
        p(p<0) = 0;   % power removing robust AR(1) noise

    elseif red == 3   % smoothed window average
        % A scale-aware floor prevents an exact detrended DC zero from
        % becoming an artificial log10(realmin) ~= -308 outlier.
        xlogp = log10(max(p,adaptivePositivePowerFloor(p)));
        try
            [swa, ~] = specswa(f,xlogp,numel(sliceValue),false);
        catch exception
            error('corrcoefslices_rankNew:SwaBackgroundFailure', ...
                ['Smoothed-window background removal failed for a ', ...
                 '%d-point slice with %d spectral bins: %s'], ...
                numel(sliceValue),numel(p),exception.message);
        end
        swa = swa(:);
        validateAdaptiveBackground(swa,p,'smoothed-window');
        p = p - swa;
        p(p<0) = 0;   % power removing swa (noise)
    
    end
    if any(~isfinite(p))
        error('corrcoefslices_rankNew:NonfiniteAdjustedSpectrum', ...
            'Red-noise subtraction produced nonfinite spectral power.');
    end
    
    if numel(f) ~= size(dataf,1) || numel(p) ~= size(datap,1)
        error('corrcoefslices_rankNew:SliceFrequencySizeMismatch', ...
            'All slice periodograms must have the same frequency length.');
    end
    dataf(:,j) = f;
    datap(:,j) = p;

end

% power spectra series mean
data = [f,mean(datap,2)];

%% plot power spectra
    if plotn == 1 && showPeriodograms
        [cocoPlotFigure,cocoPlotTabs] = ensureCocoPlotTabs( ...
            cocoPlotFigure,cocoPlotTabs);
        spectrumTab = uitab(cocoPlotTabs,'Title','Input and target spectra');
        spectrumLayout = tiledlayout(spectrumTab,2,1, ...
            'TileSpacing','compact','Padding','compact');
        ax2 = nexttile(spectrumLayout,2);
        plot(ax2,f,data(:,2),'r','LineWidth',1);
        hold on
        if slices > 1
            plot(ax2,f,datap,'LineWidth',.3);
        end
        %if red == 0
        %    plot(ax2,f,theoredML96,'k--','LineWidth',2); 
        %end
        xlim(ax2,[0, fmaxdata])
        
        set(ax2,'XMinorTick','on','YMinorTick','on')
        if or(lang_choice == 0, main_unit_selection == 0)
            xlabel(ax2,'Frequency (cycle/m)');
            ylabel(ax2,'Power');
            if red>0
                title(ax2,'Adjusted Periodogram: data');
            else
                title(ax2,'Periodogram: data');
            end

        else
            %
            [~, main14] = ismember('main14',lang_id); % freq
            [~, main46] = ismember('main46',lang_id); % power
            [~, main02] = ismember('main02',lang_id); % data
            [~, menu107] = ismember('menu107',lang_id);

            xlabel(ax2,[lang_var{main14},' (1/m)']);
            ylabel(ax2,lang_var{main46});
            title(ax2,[lang_var{main02},' ',lang_var{menu107}]);
        end
        % save data to workspace
        assignin('base','dataf',dataf)
        assignin('base','datap',datap)
        assignin('base','data',data)
    end

%% target spectrum series
% The numerical engine uses only this uniform target-frequency grid. Build
% the illustrative target time series only when its periodogram is shown.
orbitn = length(orbit9);
f = (0:floor(pad/2))'./pad;
p = zeros(size(f));
if plotn == 1 && showPeriodograms
    timen = min(2000,pad);  % at most about 2 Myr at 1 kyr spacing
    x = (1:timen)';
    targetPlotWeights = ones(orbitn,1);
    if isFixedTargetMode(targetMode)
        targetPlotWeights = cocoFixedTargetWeights(orbit9);
    end
    if usesCoherentNineTarget(targetMode)
        coherentTarget = zeros(timen,1);
        for ii = 1:orbitn
            coherentTarget = coherentTarget+targetPlotWeights(ii).* ...
                sin(2*pi/orbit9(ii)*x);
        end
        [p,fPeriodogram] = periodogram( ...
            detrend(coherentTarget,1),[],pad,1);
    else
        for ii = 1:orbitn
            sineTerm = detrend(sin(2*pi/orbit9(ii)*x),1);
            cosineTerm = detrend(cos(2*pi/orbit9(ii)*x),1);
            [pSine,fPeriodogram] = periodogram(sineTerm,[],pad,1);
            [pCosine,fCosine] = periodogram(cosineTerm,[],pad,1);
            if ~isequal(fPeriodogram,fCosine)
                error('corrcoefslices_rankNew:TargetFrequencyGridMismatch', ...
                    'Sine/cosine target frequency grids differ.');
            end
            p = p+targetPlotWeights(ii)^2 .* 0.5 .* (pSine+pCosine);
        end
    end
    if numel(f) ~= numel(fPeriodogram) || ...
            any(abs(f-fPeriodogram) > 16*eps(max(1,max(fPeriodogram))))
        error('corrcoefslices_rankNew:TargetFrequencyGridMismatch', ...
            'The analytical and periodogram target-frequency grids differ.');
    end
    f = fPeriodogram;
end
target = [f,p];

target_real= target;  % save target frequencies-power series

%% plot target periodogram
if plotn == 1 && showPeriodograms
    ax2 = nexttile(spectrumLayout,1);
    plot(ax2,f,p,'r','LineWidth',1);
    xlim([0,maximumFrequency])
    set(ax2,'XMinorTick','on','YMinorTick','on')
    if or(lang_choice == 0, main_unit_selection == 0)
        xlabel(ax2,'Frequency (cycle/kyr)');
        ylabel(ax2,'Power');
        if usesCoherentNineTarget(targetMode)
            title(ax2,'Illustrative coherent nine-term orbital template');
        else
            title(ax2,'Illustrative phase-averaged orbital template');
        end
    else
        %
        [~, main14] = ismember('main14',lang_id); % freq
        [~, main46] = ismember('main46',lang_id); % power
        [~, main02] = ismember('main02',lang_id); % data
        [~, menu107] = ismember('menu107',lang_id);
        
        xlabel(ax2,[lang_var{main14},' (1/kyr)']);
        ylabel(ax2,lang_var{main46});
        title(ax2,[lang_var{main02},' ',lang_var{menu107}]);
    end
end

%% SR0 compatibility diagnostic
% SR0 is where the mapped data Nyquist reaches the declared correlation
% cutoff. It is retained in outputs and in the compatibility function
% signature, but the audited evaluator now compares data and finite-record
% targets directly on their identical native frequency grid; no
% interpolation direction changes at SR0.
sr0 = maximumFrequency * 100/dat_nyq;
details.sr0 = sr0;
if strcmp(targetMode,'fixed')
    % Preserve only the legacy fixed-target workspace side effect.  The
    % audited Adaptive result records SR0 in DETAILS and does not pollute
    % the caller's base workspace with a diagnostic-only quantity.
    assignin('base','sr0',sr0)
end

%% correlation coefficient and its 95% significant level
sr_range = sr1:srstep:sr2;
mpts = length(sr_range);
useNativeEvaluator = usesNativeTargetEvaluator(targetMode) && adjust == 0;
evaluatorTargetModel = adaptiveEvaluatorTargetModel(targetMode);
evaluatorAmplitudeMode = evaluatorTargetAmplitudeMode(targetMode);
if useNativeEvaluator
    corrxch = sr_range(:);
else
    [corrxch,corry_rch,corrpych,nmi] = ...
        cyclecorrNew(data,datForTarget,pad,[],target,orbit9,dat_ray, ...
        sr1,sr2,srstep,sr0,adjust,method,targetMode);
    corrCI = [corrxch,corry_rch,corrpych,nmi];
end

%% simulation:  corry (sr x nsim) correlation coefficient
%critical = 100/mpts;% critical significance level by Steve Meyers

if nsim > 0
    rngState = rng;
    rngCleanup = onCleanup(@()rng(rngState));
    rng(randomSeed,'twister');

    % Use either the legacy standalone waitbar or the caller-supplied
    % determinate callback, never both.
    useInternalWaitbar = showProgress && isempty(progressFcn);
    hwaitbar = [];
    if useInternalWaitbar
        waitbarRandomState = rng;
        restoreWaitbarRandomState = onCleanup(@()rng(waitbarRandomState));
        if lang_choice == 0
            hwaitbar = waitbar(0,'Monte Carlo processing ... [CTRL + C to quit]',...    
               'WindowStyle','modal');
        else
            hwaitbar = waitbar(0,lang_var{ec79},...    
               'WindowStyle','modal');
        end
    
        hwaitbar_find = findobj(hwaitbar,'Type','Patch');
        set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
        setappdata(hwaitbar,'canceling',0)
        clear restoreWaitbarRandomState
    end
    waitbarCleanup = onCleanup(@()closeAdaptiveWaitbar(hwaitbar));
    if useInternalWaitbar
        updateCocoWaitbar(hwaitbar,0,'Monte Carlo processing ...');
    end

    %% Monte Carlo simulation
    % Estimate the null coefficient from the same linearly detrended signal
    % family used by the observed periodogram.
    [rhoM,rhoEstimator] = estimateAdaptiveRhoM(dat_slice);
    details.rhoM = rhoM;
    details.rhoEstimator = rhoEstimator;
    details.rhoMethod = rhoEstimator;

    if useNativeEvaluator
        % Evaluate the observation once, then stream null spectra through
        % the vectorized correlation engine. Retaining the rate-by-MC
        % statistics is necessary, but retaining every pad-by-MC spectrum
        % is not; streaming prevents a large and completely avoidable pMC
        % allocation for highly padded publication runs.
        [corry_rch,corrpych,nmi] = cocoAdaptiveEvaluate( ...
            data(:,2),datForTarget,pad,data(:,1),[], ...
            orbit9,dat_ray,sr_range,sr0,method,'BatchSize',1, ...
            'RateBounds',[sr1,sr2], ...
            'MaxFrequency',maximumFrequency, ...
            'TargetModel',evaluatorTargetModel, ...
            'AmplitudeMode',evaluatorAmplitudeMode);
        corrCI = [corrxch,corry_rch,corrpych,nmi];
        corry = nan(mpts,nsim);
        spectrumBatchSize = adaptiveSpectrumBatchSize(pad,nsim);
        details.mcSpectrumBatchSize = spectrumBatchSize;
        f = [];
        sim_spectum = [];
        for firstSimulation = 1:spectrumBatchSize:nsim
            lastSimulation = min(firstSimulation+spectrumBatchSize-1,nsim);
            numberInBatch = lastSimulation-firstSimulation+1;
            [fBatch,pBatch] = redNoisePeriodogramMC( ...
                dat,rhoM,numberInBatch,red,pad, ...
                'BatchSize',numberInBatch,'UseParallel',false, ...
                'Slices',slices);
            if isempty(f)
                f = fBatch;
            elseif ~isequal(f,fBatch)
                error('corrcoefslices_rankNew:MonteCarloFrequencyChanged', ...
                    'Monte Carlo frequency grids changed between streamed batches.');
            end
            evaluatorProgressFcn = [];
            if ~isempty(progressFcn)
                evaluatorProgressFcn = @(fraction,index,count) ...
                    reportCocoRateProgress(progressFcn,fraction,index,count, ...
                    firstSimulation,lastSimulation,numberInBatch,nsim, ...
                    targetMode);
            end
            corry(:,firstSimulation:lastSimulation) = ...
                cocoAdaptiveEvaluate(pBatch,datForTarget,pad,fBatch, ...
                [],orbit9,dat_ray,sr_range,sr0,method, ...
                'BatchSize',min(100,numberInBatch), ...
                'RateBounds',[sr1,sr2], ...
                'MaxFrequency',maximumFrequency, ...
                'TargetModel',evaluatorTargetModel, ...
                'AmplitudeMode',evaluatorAmplitudeMode, ...
                'ProgressFcn',evaluatorProgressFcn);
            sim_spectum = [fBatch,pBatch(:,end)];
            details.nSimCompleted = lastSimulation;
            details.nsimCompleted = lastSimulation;
            progressMessage = sprintf('%s Monte Carlo: %d of %d', ...
                cocoTargetDisplayName(targetMode),lastSimulation,nsim);
            if useInternalWaitbar && ishandle(hwaitbar)
                updateCocoWaitbar(hwaitbar,lastSimulation/nsim, ...
                    progressMessage);
            end
            reportCocoProgress(progressFcn,0.98*lastSimulation/nsim, ...
                progressMessage);
        end
    else
        % Retain the compatibility implementation for legacy fixed/adjust
        % modes, which evaluate one complete spectrum at a time.
        [f,pMC] = redNoisePeriodogramMC( ...
            dat,rhoM,nsim,red,pad,'BatchSize',1000, ...
            'UseParallel',false,'Slices',slices);
        details.nSimCompleted = size(pMC,2);
        details.nsimCompleted = size(pMC,2);
        nmc_n = max(1,round(nsim/100));
        corry = nan(mpts,nsim);
        for i = 1:nsim
            sim_spectum = [f,pMC(:,i)];
            corryi = cyclecorrsigNew(sim_spectum,datForTarget,pad,[], ...
                target_real,orbit9,dat_ray,sr1,sr2,srstep,sr0, ...
                adjust,method,targetMode);

            if display == 1 && rem(i,20) == 0
                disp(['>> Step 2: Simulation ',num2str(i),' of ',num2str(nsim)])
            end
            corry(:,i) = corryi;

            progressDue = rem(i,nmc_n) == 0 || i == nsim;
            if useInternalWaitbar && progressDue
                updateCocoWaitbar(hwaitbar,i/nsim,sprintf( ...
                    '%s Monte Carlo: %d of %d', ...
                    cocoTargetDisplayName(targetMode),i,nsim));
            end
            if progressDue
                reportCocoProgress(progressFcn,0.98*i/nsim,sprintf( ...
                    '%s Monte Carlo: %d of %d', ...
                    cocoTargetDisplayName(targetMode),i,nsim));
            end
            if useInternalWaitbar && getappdata(hwaitbar,'canceling')
                error('corrcoefslices_rankNew:MonteCarloCancelled', ...
                    'Monte Carlo processing was cancelled by the user.');
            end
        end
    end
    closeAdaptiveWaitbar(hwaitbar);
    if ~useNativeEvaluator
        assignin('base','sim_spectum',sim_spectum)
    end
    %% MC results
    corrlength = numel(corry_rch);  % number of tested sed. rate
    p_local = nan(corrlength, 1);
    p_global = nan(corrlength, 1);
    if size(corry,1) ~= corrlength || size(corry,2) ~= nsim
        error('corrcoefslices_rankNew:IncompleteMonteCarlo', ...
            ['The Monte Carlo correlation matrix is incomplete: expected ', ...
             '%d-by-%d, received %d-by-%d.'], ...
            corrlength,nsim,size(corry,1),size(corry,2));
    end
    validObservedRate = isfinite(corry_rch);
    if ~any(validObservedRate)
        error('corrcoefslices_rankNew:NoValidObservedStatistic', ...
            ['No sedimentation rate produced a finite observed COCO ', ...
             'correlation. Check the frequency limit and rate range.']);
    end
    validSimulation = all(isfinite(corry(validObservedRate,:)),1);
    details.nSimValid = sum(validSimulation);
    details.nsimValid = details.nSimValid;
    if ~all(validSimulation)
        bad = find(~validSimulation,1);
        error('corrcoefslices_rankNew:NonfiniteMonteCarloStatistic', ...
            ['Simulation %d produced a nonfinite statistic at a rate with ', ...
             'a finite observed statistic. No simulations were discarded; ', ...
             'revise the spectrum/null settings.'],bad);
    end
    nullMax = max(corry(validObservedRate,:),[],1);
    if any(~isfinite(nullMax)) || numel(nullMax) ~= nsim
        error('corrcoefslices_rankNew:InvalidNullMaximum', ...
            'Every Monte Carlo realization must have one finite maximum statistic.');
    end
    details.nullMax = nullMax(:);
    sortedNullMax = sort(nullMax(:),'ascend');
    
    for i = 1:corrlength
    
        corry_obs = corry_rch(i);
        
        if ~isfinite(corry_obs)
            continue
        end

        corry_sim1 = corry(i,:);
        % Number of Monte Carlo results equal to or larger than observation
        nExceed = sum(corry_sim1 >= corry_obs);
    
        % Plus-one correction: Monte Carlo p-value cannot equal zero.
        p_local(i) = (nExceed + 1) / (nsim + 1);

        % Max-statistic p-value. This asks whether any tested
        % sedimentation rate in a red-noise surrogate reaches the observed
        % correlation at this sedimentation rate.
        firstGlobalExceedance = firstGreaterOrEqual( ...
            sortedNullMax,corry_obs);
        nGlobalExceed = nsim-firstGlobalExceedance+1;
        p_global(i) = (nGlobalExceed + 1) / (nsim + 1);
    end
    

    %% confidence interval estimation for correlation coefficient
    
    corr_h0 = p_global;  % grid-search-corrected Monte Carlo p-value
    
    orbitn = length(orbit9);

    corr_h0(:,2) = (orbitn-corrCI(:,end));   % number of orbits involved
    corr_h0(:,3) = p_local;                  % local, uncorrected p-value

    if plotn == 1        
        [cocoPlotFigure,cocoPlotTabs] = ensureCocoPlotTabs( ...
            cocoPlotFigure,cocoPlotTabs);
        resultTab = uitab(cocoPlotTabs,'Title','Correlation and significance');
        resultLayout = tiledlayout(resultTab,4,1, ...
            'TileSpacing','compact','Padding','compact');
        ax1 = nexttile(resultLayout,1);
        plot(ax1,corrxch,corry_rch,'r','LineWidth',1);
        if or(lang_choice == 0, main_unit_selection == 0)
            xlabel(ax1,'Sedimentation rate (cm/kyr)')
            title(ax1,'Correlation coefficient')
        else
            xlabel(ax1,lang_var{ec80})
            title(ax1,lang_var{ec81})
        end
        ylabel(ax1,'\rho')
        set(ax1,'XMinorTick','on','YMinorTick','on')
        xlim(ax1,[sr1, sr2])
        
        nMC = size(corry, 2);

        % Local p-value: original per-sedimentation-rate null comparison.
        ax2 = nexttile(resultLayout,2);
        plotPValuePanel(ax2,corrxch,p_local,nMC,sr1,sr2, ...
            'Local p-value','Local null hypothesis', ...
            lang_choice,main_unit_selection,lang_var,ec80,ec82,ec83,false);

        % Global p-value: max-statistic correction across the whole grid.
        ax3 = nexttile(resultLayout,3);
        plotPValuePanel(ax3,corrxch,p_global,nMC,sr1,sr2, ...
            'Global p-value','Global null hypothesis', ...
            lang_choice,main_unit_selection,lang_var,ec80,ec82,ec83,true);
        
        % Plot number of orbital cycles
        ax4 = nexttile(resultLayout,4);
        plot(ax4,corrxch,corr_h0(:,2),'b','LineWidth',1);
        
        if or(lang_choice == 0, main_unit_selection == 0)
            xlabel(ax4,'Sedimentation rate (cm/kyr)')
            title(ax4,'Number of contributing astronomical parameters')
        else
            xlabel(ax4,lang_var{ec80})
            title(ax4,lang_var{ec84})
        end
        ylabel(ax4,'#')
        ylim(ax4,[0 orbitn+0.5])
        xlim(ax4,[sr1, sr2])
        set(ax4,'XMinorTick','on','YMinorTick','on')

        pcocoTab = uitab(cocoPlotTabs,'Title','pCOCO');
        axPcoco = axes(pcocoTab);
        productValues = corry_rch .* abs(log10(p_global));
        plot(axPcoco,corrxch,productValues,'r','LineWidth',2);
        xlim(axPcoco,[sr1, sr2])
        xlabel(axPcoco,'Sedimentation rate (cm/kyr)')
        ylabel(axPcoco,'pCOCO')

        [bestSr, bestPcoco] = getBestPcoco(corrxch, productValues);
        if isfinite(bestSr)
            annotateBestPcoco(axPcoco, bestSr, bestPcoco);
            if showPeriodograms
                [bestCorrelationSr,~] = getBestCorrelationRate( ...
                    corrxch,corry_rch);
                bestSpectrumTab = uitab(cocoPlotTabs, ...
                    'Title','Best-rate spectra');
                plotBestCorrelationSpectra(bestSpectrumTab,data, datForTarget, pad, orbit9, target_real, ...
                    bestCorrelationSr, fmaxdata, main_unit_selection,lang_choice, ...
                    lang_var,lang_id,targetMode,maximumFrequency,method, ...
                    dat_ray,sr0);
            end
        end
    end
else
    if useNativeEvaluator
        [corry_rch,corrpych,nmi] = cocoAdaptiveEvaluate( ...
            data(:,2),datForTarget,pad,data(:,1),[], ...
            orbit9,dat_ray,sr_range,sr0,method,'BatchSize',1, ...
            'RateBounds',[sr1,sr2], ...
            'MaxFrequency',maximumFrequency, ...
            'TargetModel',evaluatorTargetModel, ...
            'AmplitudeMode',evaluatorAmplitudeMode);
        corrCI = [corrxch,corry_rch,corrpych,nmi];
    end
    corr_h0 = [nan(mpts,1),length(orbit9)-corrCI(:,end),nan(mpts,1)];
    corry = [];
end
reportCocoProgress(progressFcn,1,sprintf('%s complete.', ...
    cocoTargetDisplayName(targetMode)));
end

%%
function details = defaultAdaptiveDetails()
details = struct( ...
    'rhoM',NaN, ...
    'rhoEstimator','not estimated', ...
    'rhoMethod','not estimated', ...
    'seed',NaN, ...
    'nSimRequested',0, ...
    'nsimRequested',0, ...
    'nSimCompleted',0, ...
    'nsimCompleted',0, ...
    'nSimValid',0, ...
    'nsimValid',0, ...
    'nullMax',zeros(0,1), ...
    'MaxFrequency',NaN, ...
    'maxFrequency',NaN, ...
    'slices',NaN, ...
    'pad',NaN, ...
    'red',NaN, ...
    'method','', ...
    'targetMode','', ...
    'targetModel','', ...
    'targetAmplitudeMode','', ...
    'nullConditioning','', ...
    'targetConstruction','', ...
    'bandAssignment','', ...
    'sr0',NaN, ...
    'mcSpectrumBatchSize',NaN, ...
    'pFloor',NaN);
end

function batchSize = adaptiveSpectrumBatchSize(pad,nsim)
% Bound the raw+processed spectral matrices to about 128 MiB. Several
% temporary copies coexist during background removal and target creation,
% so budget approximately 48 bytes per one-sided bin and realization.
nFrequency = floor(pad/2)+1;
memoryBudget = 128*1024^2;
batchSize = max(1,floor(memoryBudget/max(1,48*nFrequency)));
batchSize = min([1000,nsim,batchSize]);
end

function index = firstGreaterOrEqual(sortedValues,threshold)
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

function [dat,orbit9,dt,method,showProgress] = validateCocoInputs( ...
        dat,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,nsim,plotn, ...
        slices,method,fmaxdata,mainUnitSelection,showProgress)
validateattributes(dat,{'numeric'}, ...
    {'2d','ncols',2,'real','finite','nonempty'},mfilename,'dat',1);
if size(dat,1) < 4
    error('corrcoefslices_rankNew:InsufficientData', ...
        'DAT must contain at least four observations.');
end
validateattributes(orbit9,{'numeric'}, ...
    {'vector','real','finite','positive','nonempty'},mfilename,'orbit9',2);
if numel(unique(orbit9(:))) ~= numel(orbit9)
    error('corrcoefslices_rankNew:DuplicateOrbitPeriods', ...
        'ORBIT9 must contain distinct orbital periods.');
end
validateattributes(dt,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'dt',3);
validateattributes(pad,{'numeric'}, ...
    {'scalar','integer','finite','positive'},mfilename,'pad',4);
validateattributes(sr1,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'sr1',5);
validateattributes(sr2,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'sr2',6);
validateattributes(srstep,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'srstep',7);
if sr2 < sr1
    error('corrcoefslices_rankNew:InvalidRateRange', ...
        'SR2 must be greater than or equal to SR1.');
end
nRate = floor((sr2-sr1)/srstep)+1;
if ~isfinite(nRate) || nRate > 10000
    error('corrcoefslices_rankNew:RateGridTooLarge', ...
        ['The requested sedimentation-rate grid contains approximately ', ...
         '%g points; reduce the range or increase SRSTEP.'],nRate);
end
validateattributes(adjust,{'numeric','logical'}, ...
    {'scalar','real','finite'},mfilename,'adjust',8);
if ~ismember(double(adjust),[0,1])
    error('corrcoefslices_rankNew:InvalidAdjust', ...
        'ADJUST must be 0 or 1.');
end
validateattributes(red,{'numeric'}, ...
    {'scalar','integer','finite'},mfilename,'red',9);
if ~ismember(red,0:3)
    error('corrcoefslices_rankNew:InvalidRedOption', ...
        'RED must be 0, 1, 2, or 3.');
end
if red == 3 && floor(pad/2)+1 < 33
    error('corrcoefslices_rankNew:InsufficientSwaResolution', ...
        'RED=3 requires PAD >= 64 so the SWA fit has at least three windows.');
end
nFrequency = floor(pad/2)+1;
% DATAF/DATAP, the finite-record orbital basis, target/data interpolation
% workspaces, and slice spectra coexist.  Bound their deterministic core
% allocation before PERIODogram or FFT attempts a potentially fatal request.
estimatedCoreBytes = nFrequency * ...
    (16*double(slices) + 32*numel(orbit9) + 64);
coreMemoryBudget = 512*1024^2;
if estimatedCoreBytes > coreMemoryBudget
    error('corrcoefslices_rankNew:PadRequestTooLarge', ...
        ['PAD and the requested slice/orbit configuration require ', ...
         'approximately %.3g MiB of core spectral workspace (safety ', ...
         'limit %.3g MiB). Reduce PAD or the number of slices.'], ...
        estimatedCoreBytes/1024^2,coreMemoryBudget/1024^2);
end
validateattributes(nsim,{'numeric'}, ...
    {'scalar','integer','finite','nonnegative'},mfilename,'nsim',10);
if nsim > 1e6 || nRate*max(nsim,1) > 5e7
    error('corrcoefslices_rankNew:MonteCarloRequestTooLarge', ...
        ['The requested rate-by-simulation matrix is too large for a ', ...
         'safe in-memory Adaptive COCO run. Reduce NSIM or the rate grid.']);
end
validateattributes(plotn,{'numeric','logical'}, ...
    {'scalar','real','finite'},mfilename,'plotn',11);
if ~ismember(double(plotn),[0,1])
    error('corrcoefslices_rankNew:InvalidPlotOption', ...
        'PLOTN must be 0 or 1.');
end
validateattributes(slices,{'numeric'}, ...
    {'scalar','integer','finite','positive'},mfilename,'slices',12);
if slices > floor(size(dat,1)/4)
    error('corrcoefslices_rankNew:TooManySlices', ...
        ['SLICES cannot exceed floor(number of observations/4), because ', ...
         'every slice requires at least four observations.']);
end
method = validatestring(method,{'Pearson','Spearman'},mfilename,'method',13);
validateattributes(fmaxdata,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'fmaxdata',14);
validateattributes(mainUnitSelection,{'numeric','logical'}, ...
    {'scalar','real','finite'},mfilename,'main_unit_selection',15);
if ~ismember(double(mainUnitSelection),[0,1])
    error('corrcoefslices_rankNew:InvalidUnitSelection', ...
        'MAIN_UNIT_SELECTION must be 0 or 1.');
end
validateattributes(showProgress,{'numeric','logical'}, ...
    {'scalar','real','finite'},mfilename,'showProgress',16);
if ~ismember(double(showProgress),[0,1])
    error('corrcoefslices_rankNew:InvalidProgressOption', ...
        'SHOWPROGRESS must be true or false.');
end
showProgress = logical(showProgress);

depth = dat(:,1);
depthDifference = diff(depth);
if any(depthDifference <= 0)
    error('corrcoefslices_rankNew:InvalidDepthOrder', ...
        ['DAT(:,1) must be strictly increasing. Sort and de-duplicate ', ...
         'the depth series before COCO analysis.']);
end
dataDt = median(depthDifference);
spacingTolerance = max(1e-10*max(1,abs(dataDt)), ...
    32*eps(max(abs(depth))));
if any(abs(depthDifference-dataDt) > spacingTolerance)
    error('corrcoefslices_rankNew:UnevenSampling', ...
        ['DAT(:,1) must be evenly spaced. Sort, de-duplicate, and ', ...
         'interpolate using the median sampling interval before COCO.']);
end
if abs(dt-dataDt) > spacingTolerance
    error('corrcoefslices_rankNew:SamplingIntervalMismatch', ...
        'DT (%.16g) does not match the depth spacing (%.16g).',dt,dataDt);
end
dt = dataDt;
orbit9 = orbit9(:);

detrendedValue = detrend(dat(:,2),1);
if ~cocoResolvedDetrendedVariance(dat(:,2),detrendedValue)
    error('corrcoefslices_rankNew:ConstantData', ...
        ['The linearly detrended data must have numerically resolved ', ...
         'nonzero variance; constant or affine-only input is invalid.']);
end
end

function [rhoM,source] = estimateAdaptiveRhoM(datSlice)
% Pooled conditional-least-squares AR(1) coefficient over exactly the
% within-slice, standardized/detrended adjacent pairs used by the observed
% statistic. Slice boundaries are never treated as lag-one observations,
% and one estimator covers the full (-1,1) parameter range.
if ~isnumeric(datSlice) || isempty(datSlice) || rem(size(datSlice,2),2) ~= 0
    error('corrcoefslices_rankNew:InvalidRhoSeries', ...
        'The preprocessed slice matrix is invalid for AR(1) estimation.');
end
numerator = 0;
denominator = 0;
nPair = 0;
for sliceIndex = 1:(size(datSlice,2)/2)
    x = datSlice(:,2*sliceIndex);
    x = x(isfinite(x));
    if numel(x) < 4
        continue
    end
    x = x-mean(x);
    previous = x(1:end-1);
    next = x(2:end);
    numerator = numerator+previous'*next;
    denominator = denominator+previous'*previous;
    nPair = nPair+numel(previous);
end
if nPair < 3 || ~isfinite(denominator) || denominator <= 0
    error('corrcoefslices_rankNew:InvalidRhoSeries', ...
        'Too few finite, variable within-slice pairs remain for AR(1) estimation.');
end
rhoM = numerator/denominator;
if ~isfinite(rhoM) || ~isreal(rhoM)
    error('corrcoefslices_rankNew:InvalidRhoEstimate', ...
        'The pooled conditional AR(1) estimate is nonfinite or complex.');
end
rhoM = min(max(real(rhoM),-0.999),0.999);
source = ['pooled conditional least-squares AR(1) on preprocessed ', ...
    'within-slice adjacent pairs'];
end

function closeAdaptiveWaitbar(h)
if ~isempty(h) && ishandle(h)
    randomState = rng;
    restoreRandomState = onCleanup(@()rng(randomState));
    try
        close(h);
    catch
        % Closing a diagnostic window must not affect numerical results.
    end
    clear restoreRandomState
end
end

function updateCocoWaitbar(h,fraction,message)
if isempty(h) || ~ishandle(h)
    return
end
randomState = rng;
restoreRandomState = onCleanup(@()rng(randomState));
waitbar(min(max(double(fraction),0),1),h,message);
clear restoreRandomState
end

function reportCocoProgress(progressFcn,fraction,message)
if isempty(progressFcn)
    return
end
randomState = rng;
restoreRandomState = onCleanup(@()rng(randomState));
progressFcn(min(max(double(fraction),0),1),message);
clear restoreRandomState
end

function reportCocoRateProgress(progressFcn,fraction,index,count, ...
        firstSimulation,lastSimulation,numberInBatch,nsim,targetMode)
if isempty(progressFcn)
    return
end
stride = max(1,ceil(count/20));
if index ~= count && mod(index,stride) ~= 0
    return
end
completedSimulationEquivalent = firstSimulation-1 + ...
    fraction*numberInBatch;
reportCocoProgress(progressFcn, ...
    0.98*completedSimulationEquivalent/nsim,sprintf( ...
    ['%s Monte Carlo batch %d-%d of %d; ', ...
     'sedimentation rates %d of %d'], ...
    cocoTargetDisplayName(targetMode),firstSimulation,lastSimulation, ...
    nsim,index,count));
end

function floorValue = adaptivePositivePowerFloor(p)
positivePower = p(isfinite(p) & p > 0);
if isempty(positivePower)
    scale = 1;
else
    scale = max(positivePower);
end
floorValue = max(realmin(class(p)),scale*eps(class(p)));
end

function validateAdaptiveBackground(background,p,label)
background = background(:);
if numel(background) ~= numel(p) || ...
        any(~isfinite(background) | background <= 0)
    error('corrcoefslices_rankNew:InvalidRedNoiseBackground', ...
        ['The %s method returned a nonpositive, nonfinite, or ', ...
         'size-mismatched spectral background.'],label);
end
end

%%
function datForTarget = targetBandwidthData(dat_slice, datanewMean, dat, slices)
% Use the same effective record length as the spectrum being correlated.
% With slices > 1, the data spectrum is an average of slice spectra, so the
% target-bandwidth estimate must use a representative slice-length series.
if slices > 1
    datForTarget = cleanTwoColumnData(datanewMean);
    if ~hasUsableDepth(datForTarget)
        bestLength = 0;
        for ii = 1:slices
            candidate = cleanTwoColumnData(dat_slice(:,2*ii-1:2*ii));
            if hasUsableDepth(candidate) && size(candidate,1) > bestLength
                datForTarget = candidate;
                bestLength = size(candidate,1);
            end
        end
    end
else
    datForTarget = cleanTwoColumnData(dat_slice(:,1:2));
end

if ~hasUsableDepth(datForTarget)
    datForTarget = cleanTwoColumnData(dat);
end
end

function tf = hasUsableDepth(x)
tf = size(x,1) >= 2 && numel(unique(x(:,1))) >= 2;
end

function x = cleanTwoColumnData(x)
if isempty(x) || size(x,2) < 2
    x = zeros(0,2);
    return
end
x = x(:,1:2);
x = x(all(isfinite(x),2),:);
if ~isempty(x)
    x = sortrows(x,1);
end
end

%%
function [bestSr, bestPcoco] = getBestPcoco(corrx, productValues)
bestSr = NaN;
bestPcoco = NaN;
corrx = corrx(:);
productValues = productValues(:);
ok = isfinite(corrx) & isfinite(productValues);
if ~any(ok)
    return
end
validSr = corrx(ok);
validPcoco = productValues(ok);
[bestPcoco, idx] = max(validPcoco);
bestSr = validSr(idx);
end

function [bestSr,bestCorrelation] = getBestCorrelationRate(corrx,rho)
bestSr = NaN;
bestCorrelation = NaN;
corrx = corrx(:);
rho = rho(:);
ok = isfinite(corrx) & isfinite(rho);
if ~any(ok)
    return
end
validRate = corrx(ok);
[bestCorrelation,index] = max(rho(ok));
bestSr = validRate(index);
end

function annotateBestPcoco(ax, bestSr, bestPcoco)
axes(ax);
hold(ax, 'on');
yl = ylim(ax);
plot(ax, [bestSr bestSr], yl, 'r--', 'LineWidth', 0.75);

xLimits = xlim(ax);
yLabel = yl(1) + 0.9 * diff(yl);
if bestSr > mean(xLimits)
    hAlign = 'right';
    labelText = sprintf('%.4g cm/kyr ', bestSr);
else
    hAlign = 'left';
    labelText = sprintf(' %.4g cm/kyr', bestSr);
end

text(ax, bestSr, yLabel, labelText, ...
    'Color', 'r', ...
    'FontSize', 10, ...
    'HorizontalAlignment', hAlign, ...
    'VerticalAlignment', 'top');

plot(ax, bestSr, bestPcoco, 'ro', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', 'r');
end

function [fig,tabs] = ensureCocoPlotTabs(fig,tabs)
if isempty(fig) || ~isgraphics(fig)
    fig = figure('Color','w','Name','COCO diagnostics', ...
        'Units','normalized','Position',[0.10 0.05 0.80 0.88]);
    tabs = uitabgroup(fig);
elseif isempty(tabs) || ~isgraphics(tabs)
    tabs = uitabgroup(fig);
end
end

function plotBestCorrelationSpectra(parent, data, dat, pad, orbit9, target_real, ...
    bestSr, fmaxdata, main_unit_selection, lang_choice, lang_var, ...
    lang_id, targetMode, maximumFrequency, method, rayleigh, sr0)

if usesNativeTargetEvaluator(targetMode)
    [~,~,~,diagnostic] = cocoAdaptiveEvaluate( ...
        data(:,2),dat,pad,data(:,1),[],orbit9, ...
        rayleigh,bestSr,sr0,method,'BatchSize',1, ...
        'RateBounds',[bestSr,bestSr], ...
        'MaxFrequency',maximumFrequency, ...
        'TargetModel',adaptiveEvaluatorTargetModel(targetMode), ...
        'AmplitudeMode',evaluatorTargetAmplitudeMode(targetMode));
    dataFreqTime = diagnostic.frequency;
    dataPower = diagnostic.dataPower;
    targetFreqTime = diagnostic.frequency;
    targetPower = diagnostic.targetPower;
else
    dataFreqTime = data(:,1) * bestSr / 100;  % cycles/kyr
    dataPower = data(:,2);
    targetFreqTime = target_real(:,1);        % cycles/kyr
    targetPower = cocoTargetSpectrum( ...
        dat,pad,data,orbit9,targetFreqTime,bestSr,targetMode);
end

ax = axes(parent);

if isfinite(fmaxdata) && fmaxdata > 0
    xLimits = [0,min(fmaxdata*bestSr/100,maximumFrequency)];
else
    xLimits = [0,min(max(dataFreqTime),maximumFrequency)];
end

dataPlotPower = normalizeVisiblePower(dataFreqTime, dataPower, xLimits);
targetPlotPower = normalizeVisiblePower(targetFreqTime, targetPower, xLimits);

plot(ax, dataFreqTime, dataPlotPower, 'k-', 'LineWidth', 1);
hold(ax, 'on');
plot(ax, targetFreqTime, targetPlotPower, 'r-', 'LineWidth', 1);
xlim(ax, xLimits);
ylim(ax, [0, 1.05]);

if or(lang_choice == 0, main_unit_selection == 0)
    xlabel(ax, 'Frequency (cycle/kyr)');
    ylabel(ax, 'Normalized power');
else
    [~, main14] = ismember('main14', lang_id);
    xlabel(ax, [lang_var{main14}, ' (1/kyr)']);
    ylabel(ax, 'Normalized power');
end
title(ax, sprintf([ ...
    'Maximum-correlation / minimum-global-p spectrum at %.4g cm/kyr ', ...
    '(%s target)'], ...
    bestSr,targetMode));
legend(ax, {'Data spectrum', 'Target spectrum'}, 'Location', 'best');
set(ax, 'XMinorTick', 'on', 'YMinorTick', 'on');
box(ax, 'on');
end

function yNorm = normalizeVisiblePower(x, y, xLimits)
ok = isfinite(x) & isfinite(y) & x >= xLimits(1) & x <= xLimits(2);
scale = max(y(ok));
if isempty(scale) || ~isfinite(scale) || scale <= 0
    scale = max(y(isfinite(y)));
end
if isempty(scale) || ~isfinite(scale) || scale <= 0
    scale = 1;
end
yNorm = y ./ scale;
end

function plotPValuePanel(ax,corrx,pValues,nMC,sr1,sr2,yLabelText,titleText, ...
    lang_choice,main_unit_selection,lang_var,ec80,ec82,ec83,isGlobalPanel)
pPlot = pValues(:);
% Minimum p-value resolvable by the Monte Carlo simulations.
% For example, 100 simulations give p_min = 1/101.
pFloor = 1 / (nMC + 1);
pPlot(~isfinite(pPlot)) = NaN;
pPlot(pPlot <= 0) = pFloor;
pPlot(pPlot > 1) = 1;

% Transform p-values: smaller p-values are plotted higher.
pScore = -log10(pPlot);
plot(ax, corrx, pScore, 'r', 'LineWidth', 1);
if lang_choice == 0 || main_unit_selection == 0
    xlabel(ax, 'Sedimentation rate (cm/kyr)')
    ylabel(ax, yLabelText)
    title(ax, titleText)
else
    xlabel(ax, lang_var{ec80})
    ylabel(ax, lang_var{ec82})
    title(ax, lang_var{ec83})
end

% Actual p-values to display on the y-axis.  The global panel spans the
% complete p-value range and therefore also labels p = 1.
if isGlobalPanel
    pTicksAll  = [1, 0.1, 0.05, 0.02, 0.01, 0.002, 0.001];
    pLabelsAll = {'1','0.1','0.05','0.02','0.01','0.002','0.001'};
else
    pTicksAll  = [0.1, 0.05, 0.02, 0.01, 0.002, 0.001];
    pLabelsAll = {'0.1','0.05','0.02','0.01','0.002','0.001'};
end
keep = pTicksAll >= pFloor;
pTicks  = pTicksAll(keep);
pLabels = pLabelsAll(keep);
set(ax, ...
    'YTick', -log10(pTicks), ...
    'YTickLabel', pLabels, ...
    'YMinorTick', 'off');

if isGlobalPanel
    % Leave a small amount of space below p = 1 while retaining a valid
    % p-value label at the first tick when using the dynamic range.
    yBottom = -log10(1.01);
else
    yBottom = -log10(0.15);
end
validScore = pScore(isfinite(pScore));
if isempty(validScore)
    yTop = -log10(pFloor);
else
    yTop = max([validScore; -log10(pFloor)]);
end
defaultGlobalMinimumP = 0.002;
hasVerySmallGlobalP = isGlobalPanel && ...
    any(pPlot(isfinite(pPlot)) < defaultGlobalMinimumP);
if isGlobalPanel && ~hasVerySmallGlobalP
    % With the -log10(p) display this is exactly p=1 at the lower edge and
    % p=0.002 at the upper edge. Preserve the former dynamic small-p range
    % whenever the computed global curve extends below p=0.002.
    yLower = 0;
    yUpper = -log10(defaultGlobalMinimumP);
else
    yTop = max(yTop, yBottom + 0.5);
    yRange = max(yTop - yBottom, 0.5);
    topMargin = 0.12 * yRange;
    if isGlobalPanel
        yLower = yBottom;
    else
        yLower = yBottom - 0.03 * yRange;
    end
    yUpper = yTop + topMargin;
end
ylim(ax, [yLower, yUpper]);

yline(ax, -log10(0.10), ':k');
yline(ax, -log10(0.02), ':k');
if isGlobalPanel
    yline(ax, -log10(0.05), '--k');
    yline(ax, -log10(0.01), ':k');
else
    yline(ax, -log10(0.05), ':k');
    yline(ax, -log10(0.01), '--k');
end
if pFloor <= 0.001
    yline(ax, -log10(0.001), ':k');
end
xlim(ax,[sr1, sr2])
set(ax, 'XMinorTick', 'on', 'YMinorTick', 'off');
if isGlobalPanel
    set(ax,'Tag','AdaptiveCOCO-global-p');
else
    set(ax,'Tag','AdaptiveCOCO-local-p');
end
box(ax, 'on');
end

function [langChoice,langId,langVar] = cocoLanguageSettings()
% Cache the comparatively expensive spreadsheet import while still
% re-reading it if the language dictionary file changes on disk.
persistent langDictionary dictionaryStamp cachedDictionaryPath
choicePath = cocoLanguageResource('ac_lang.txt',false);
if isempty(choicePath)
    langChoice = 0;
else
    langChoice = load(choicePath);
end
if ~isnumeric(langChoice) || ~isscalar(langChoice) || ...
        ~isfinite(langChoice) || ~ismember(langChoice,[0,1])
    langChoice = 0;
end
dictionaryPath = cocoLanguageResource('langdict.xlsx',false);
if isempty(dictionaryPath)
    % Language resources are presentation-only and must never prevent a
    % numerical COCO analysis. Fall back to built-in English labels.
    langChoice = 0;
    langId = {};
    langVar = {};
    return
end
try
    fileInfo = dir(dictionaryPath);
    currentStamp = [fileInfo(1).datenum,fileInfo(1).bytes];
    if isempty(langDictionary) || isempty(dictionaryStamp) || ...
            isempty(cachedDictionaryPath) || ...
            ~strcmp(cachedDictionaryPath,dictionaryPath) || ...
            ~isequal(dictionaryStamp,currentStamp)
        langDictionary = readtable(dictionaryPath, ...
            'VariableNamingRule','preserve');
        dictionaryStamp = currentStamp;
        cachedDictionaryPath = dictionaryPath;
    end
catch exception
    warning('corrcoefslices_rankNew:LanguageDictionaryIgnored', ...
        'Language dictionary could not be read; using English (%s).', ...
        exception.message);
    langChoice = 0;
    langId = {};
    langVar = {};
    return
end
if width(langDictionary) < 2+langChoice || ...
        ~ismember('ID',langDictionary.Properties.VariableNames)
    langChoice = 0;
end
if width(langDictionary) < 2 || ...
        ~ismember('ID',langDictionary.Properties.VariableNames)
    langId = {};
    langVar = {};
    return
end
langId = langDictionary.ID;
langVar = table2cell(langDictionary(:,2+langChoice));
end

function resourcePath = cocoLanguageResource(filename,isRequired)
% Resolve resources relative to this installed Acycle source tree instead
% of assuming that MATLAB's current directory is code/bin.
resourcePath = '';
sourceDirectory = fileparts(mfilename('fullpath'));
candidates = { ...
    fullfile(sourceDirectory,'..','bin',filename), ...
    which(filename), ...
    fullfile(pwd,filename)};
for ii = 1:numel(candidates)
    candidate = candidates{ii};
    if ~isempty(candidate) && exist(candidate,'file') == 2
        resourcePath = candidate;
        return
    end
end
if isRequired
    error('corrcoefslices_rankNew:MissingLanguageDictionary', ...
        ['Cannot locate %s. Expected it in the installed Acycle code/bin ', ...
         'directory or on the MATLAB path.'],filename);
end
end

%%
function [datanew, datanewMean] = data_slices(dat, slices)
% data_slices Divide a time series into equal-duration slices.
%
%   [datanew, datanewMean] = data_slices(dat, slices)
%
% INPUT:
%   dat    - Two-column time series:
%            dat(:,1): time
%            dat(:,2): data values
%
%   slices - Number of equal-duration slices.
%
% OUTPUT:
%   datanew - Matrix containing all processed slices.
%             Each slice occupies two columns:
%
%             datanew(:,2*i-1): original time of slice i
%             datanew(:,2*i)  : standardized and demeaned values
%
%             Shorter slices are padded with NaN.
%
%   datanewMean - Two-column mean series:
%
%             datanewMean(:,1): mean relative time within the slices
%             datanewMean(:,2): row-wise mean of all processed slices
%
%   The averaging is performed according to sample position within each
%   slice. It therefore assumes that all slices have approximately the
%   same sampling interval.

    %% Validate inputs

    validateattributes(dat, {'numeric'}, ...
        {'2d', 'ncols', 2, 'nonempty', 'real'}, ...
        mfilename, 'dat', 1);

    validateattributes(slices, {'numeric'}, ...
        {'scalar', 'integer', 'positive', 'finite'}, ...
        mfilename, 'slices', 2);

    %% Remove invalid rows and sort data by time

    validRows = all(isfinite(dat), 2);
    dat = dat(validRows, :);

    if isempty(dat)
        error('data_slices:NoValidData', ...
            'The input data do not contain valid finite values.');
    end

    dat = sortrows(dat, 1);

    timeAll = dat(:,1);

    if timeAll(end) <= timeAll(1)
        error('data_slices:InvalidTime', ...
            'The time range must be greater than zero.');
    end

    %% Define slice boundaries

    sliceBoundary = linspace( ...
        timeAll(1), timeAll(end), slices + 1);

    sliceData = cell(slices, 1);
    relativeTime = cell(slices, 1);
    sliceLength = zeros(slices, 1);

    %% Extract and process each slice

    for i = 1:slices

        % Use half-open intervals for all slices except the last one.
        % This prevents a boundary point from appearing in two slices.
        if i < slices
            index = timeAll >= sliceBoundary(i) & ...
                    timeAll <  sliceBoundary(i + 1);
        else
            index = timeAll >= sliceBoundary(i) & ...
                    timeAll <= sliceBoundary(i + 1);
        end

        dataInterval = dat(index, :);

        if isempty(dataInterval)
            sliceData{i} = zeros(0, 2);
            relativeTime{i} = zeros(0, 1);
            continue
        end

        time = dataInterval(:,1);
        value = dataInterval(:,2);

        % Test the stored values before standardization.  Otherwise a
        % very large offset can magnify pure floating-point detrend residue
        % into apparent unit-scale variance after division by STD.
        rawDetrendedValue = detrend(value,1);
        if ~cocoResolvedDetrendedVariance(value,rawDetrendedValue)
            error('corrcoefslices_rankNew:DegenerateSlice', ...
                ['Every raw slice must retain numerically resolved ', ...
                 'variance after linear detrending.']);
        end

        %% Standardize the values within the current slice

        valueStd = std(value);

        if numel(value) > 1 && isfinite(valueStd) && valueStd > 0
            value = (value - mean(value)) ./ valueStd;
        else
            error('corrcoefslices_rankNew:DegenerateSlice', ...
                'Every slice must have a finite, positive standard deviation.');
        end

        % Remove any linear trend. Reject roundoff left by a constant or
        % affine-only slice instead of treating it as spectral variance.
        valueBeforeDetrend = value;
        value = detrend(value, 1);
        if ~cocoResolvedDetrendedVariance(valueBeforeDetrend,value)
            error('corrcoefslices_rankNew:DegenerateSlice', ...
                ['Every slice must retain numerically resolved variance ', ...
                 'after preprocessing and linear detrending.']);
        end

        %% Store the processed slice

        sliceData{i} = [time, value];

        % Relative time is required for aligning different slices
        relativeTime{i} = time - time(1);

        sliceLength(i) = length(time);

    end

    %% Combine all slices into one matrix

    maximumLength = max(sliceLength);

    if maximumLength == 0
        datanew = [];
        datanewMean = [];
        return
    end

    % NaN padding prevents missing values from influencing the mean
    datanew = nan(maximumLength, 2 * slices);
    relativeTimeMatrix = nan(maximumLength, slices);

    for i = 1:slices

        currentLength = sliceLength(i);

        if currentLength == 0
            continue
        end

        datanew(1:currentLength, 2*i-1:2*i) = ...
            sliceData{i};

        relativeTimeMatrix(1:currentLength, i) = ...
            relativeTime{i};

    end

    %% Calculate the mean series

    % Extract the processed value column from every slice
    valueMatrix = datanew(:, 2:2:end);

    % Calculate the mean value at each relative sample position
    meanValue = mean(valueMatrix, 2, 'omitnan');

    % Calculate a representative relative time coordinate
    meanRelativeTime = mean(relativeTimeMatrix, 2, 'omitnan');

    % Remove rows for which no slice contains data
    validMeanRows = any(isfinite(valueMatrix), 2);

    datanewMean = [ ...
        meanRelativeTime(validMeanRows), ...
        meanValue(validMeanRows)];

end

function tf = isAdaptiveTargetMode(targetMode)
tf = any(strcmp(targetMode, ...
    {'adaptive','adaptive9','adaptive9a','adaptive9b'}));
end

function tf = isFixedTargetMode(targetMode)
tf = any(strcmp(targetMode,{'fixed','fixed9'}));
end

function tf = usesNativeTargetEvaluator(targetMode)
tf = any(strcmp(targetMode, ...
    {'adaptive','adaptive9','adaptive9a','adaptive9b','fixed9'}));
end

function tf = usesCoherentNineTarget(targetMode)
tf = any(strcmp(targetMode, ...
    {'adaptive9','adaptive9a','adaptive9b','fixed9'}));
end

function model = adaptiveEvaluatorTargetModel(targetMode)
if usesCoherentNineTarget(targetMode)
    model = 'coherent-nine';
else
    model = 'phase-averaged';
end
end

function mode = evaluatorTargetAmplitudeMode(targetMode)
if strcmp(targetMode,'fixed9')
    mode = 'fixed';
elseif strcmp(targetMode,'adaptive9b')
    mode = 'four-group-area';
else
    mode = 'adaptive';
end
end

function name = cocoTargetDisplayName(targetMode)
if strcmp(targetMode,'adaptive9b')
    name = 'Adaptive COCO9B';
elseif any(strcmp(targetMode,{'adaptive9','adaptive9a'}))
    name = 'Adaptive COCO9A';
elseif strcmp(targetMode,'fixed9')
    name = 'Fixed COCO9';
else
    name = 'Adaptive COCO';
end
end
