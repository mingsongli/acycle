function la = cocoTargetSpectrum( ...
    dat,pad,dataPower,orbit9,lax,sr_i,targetMode)
%COCOTARGETSPECTRUM Dispatch adaptive or fixed COCO target construction.

if nargin < 7 || isempty(targetMode)
    targetMode = 'adaptive';
end
targetMode = lower(strtrim(char(targetMode)));

switch targetMode
    case {'adaptive','adaptive9','adaptive9a'}
        % FREQ2TARGETNEW is the compatibility implementation that already
        % sums fitted orbital sine terms before calculating target power.
        % The per-orbit peak path uses COCOADAPTIVEEVALUATE directly; these
        % internal aliases keep diagnostic/compatibility callers consistent.
        la = freq2targetNew(dat,pad,dataPower,orbit9,lax,sr_i);
    case 'adaptive9b'
        % The four-group area design cannot be represented by the
        % per-orbit peak helper. Route compatibility callers through the
        % same native evaluator used by the observed and Monte Carlo paths.
        la = adaptiveNineBCompatibility( ...
            dat,pad,dataPower,orbit9,lax,sr_i);
    case {'fixed','fixed9'}
        % Fixed-target COCO uses the native-grid evaluator.
        % FREQ2TARGETFIXED already applies the same coherent
        % fixed-weight construction for compatibility callers.
        la = freq2targetFixed(dat,pad,orbit9,lax,sr_i);
    otherwise
        error(['Select either Adaptive COCO or Fixed-target COCO through ', ...
            'a supported Acycle interface.']);
end
end

function targetPower = adaptiveNineBCompatibility( ...
        dat,pad,dataPower,orbit9,targetFrequency,sr)
targetFrequency = targetFrequency(:);
targetPower = zeros(size(targetFrequency));
if isempty(targetFrequency)
    return
end
validateattributes(dat,{'numeric'}, ...
    {'2d','ncols',2,'real','finite','nonempty'},mfilename,'dat',1);
depth = dat(:,1);
dz = median(diff(depth));
if numel(depth) < 2 || any(diff(depth) <= 0) || ...
        ~isfinite(dz) || dz <= 0
    error('cocoTargetSpectrum:InvalidDepth', ...
        'Adaptive COCO requires a strictly increasing depth grid.');
end
nFrequency = floor(pad/2)+1;
if ismatrix(dataPower) && size(dataPower,2) == 2 && ...
        size(dataPower,1) == nFrequency
    spatialFrequency = dataPower(:,1);
    spatialPower = dataPower(:,2);
elseif isvector(dataPower) && numel(dataPower) == nFrequency
    spatialPower = dataPower(:);
    spatialFrequency = (0:nFrequency-1)'./(pad*dz);
else
    error('cocoTargetSpectrum:InvalidAdaptive9BPower', ...
        ['Adaptive COCO requires either a one-sided PAD-point power ', ...
         'vector or a frequency/power matrix with floor(PAD/2)+1 rows.']);
end
rayleigh = enbw(rectwin(numel(depth)),1/dz);
finiteTargetFrequency = targetFrequency(isfinite(targetFrequency));
maximumFrequency = 1.2*max(1./orbit9(:));
if ~isempty(finiteTargetFrequency)
    maximumFrequency = max(maximumFrequency,max(finiteTargetFrequency));
end
[~,~,~,diagnostic] = cocoAdaptiveEvaluate( ...
    spatialPower,dat,pad,spatialFrequency,[],orbit9,rayleigh,sr,0, ...
    'Pearson','BatchSize',1,'RateBounds',[sr sr], ...
    'MaxFrequency',maximumFrequency,'TargetModel','coherent-nine', ...
    'AmplitudeMode','four-group-area');
if ~diagnostic.geometryValid || isempty(diagnostic.frequency)
    return
end
targetPower = interp1(diagnostic.frequency,diagnostic.targetPower, ...
    targetFrequency,'linear',0);
targetPower(~isfinite(targetPower)) = 0;
end
