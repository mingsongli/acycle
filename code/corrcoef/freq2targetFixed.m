function la = freq2targetFixed(dat,pad,orbit9,lax,sr_i)
%FREQ2TARGETFIXED Generate a fixed-relative-weight astronomical target.
%
% Unlike freq2targetNew, this target never estimates amplitudes from the
% observed or simulated data spectrum.  Its sinusoid amplitudes are fixed
% by cocoFixedTargetWeights and only its sampling grid changes with the
% tested sedimentation rate.

persistent cacheDepth cachePad cacheOrbit cacheGrids ...
    cacheSr cacheGridIndex cacheValues

lax = lax(:);
la = zeros(size(lax));
if isempty(lax)
    return
end

orbit9 = orbit9(:);
weights = cocoFixedTargetWeights(orbit9);
ok = isfinite(orbit9) & orbit9 > 0 & isfinite(weights) & weights > 0;
orbit9 = orbit9(ok);
weights = weights(ok);
if isempty(orbit9)
    return
end

if nargin < 2 || isempty(pad) || ~isfinite(pad) || pad <= 0
    pad = 5000;
end

depthKey = zeros(0,1);
if ~isempty(dat) && size(dat,2) >= 1
    depthKey = dat(:,1);
    depthKey = sort(depthKey(isfinite(depthKey)));
end

baseMatches = ~isempty(cachePad) && isequal(cacheDepth,depthKey) && ...
    isequal(cachePad,pad) && isequal(cacheOrbit,orbit9);
if ~baseMatches
    cacheDepth = depthKey;
    cachePad = pad;
    cacheOrbit = orbit9;
    cacheGrids = {};
    cacheSr = zeros(0,1);
    cacheGridIndex = zeros(0,1);
    cacheValues = {};
end

gridIndex = [];
for ii = 1:numel(cacheGrids)
    if isequal(cacheGrids{ii},lax)
        gridIndex = ii;
        break
    end
end
if isempty(gridIndex)
    cacheGrids{end+1} = lax;
    gridIndex = numel(cacheGrids);
end

cacheIndex = find(cacheSr == sr_i & cacheGridIndex == gridIndex,1);
if ~isempty(cacheIndex)
    la = cacheValues{cacheIndex};
    return
end

[targetTime,targetFs,nfft] = fixedTargetSamplingFromData( ...
    dat,pad,orbit9,sr_i);

y0 = zeros(size(targetTime));
for ii = 1:numel(orbit9)
    y0 = y0 + weights(ii) .* ...
        sin(2*pi/orbit9(ii) .* targetTime);
end

if std(y0) == 0
    return
end

y0 = detrend(y0,1);
[targetPower,targetFreq] = periodogram(y0,[],nfft,targetFs);

okFreq = isfinite(targetFreq) & isfinite(targetPower);
targetFreq = targetFreq(okFreq);
targetPower = targetPower(okFreq);
if isempty(targetFreq)
    return
end

[targetFreq,uniqueIdx] = unique(targetFreq);
targetPower = targetPower(uniqueIdx);
la = interp1(targetFreq,targetPower,lax,'linear',0);
la(~isfinite(la)) = 0;

cacheSr(end+1,1) = sr_i;
cacheGridIndex(end+1,1) = gridIndex;
cacheValues{end+1,1} = la;
end

function [targetTime,targetFs,nfft] = fixedTargetSamplingFromData( ...
    dat,pad,orbit9,sr_i)
% Match the sampling and FFT conventions used by freq2targetNew.
targetFs = 1;
nSamples = max(2,ceil(5*max(orbit9)));

if ~isempty(dat) && size(dat,2) >= 1 && isfinite(sr_i) && sr_i > 0
    depth = dat(:,1);
    depth = depth(isfinite(depth));
    if numel(depth) >= 2
        depth = sort(depth(:));
        dz = diff(depth);
        dz = dz(isfinite(dz) & dz > 0);
        if ~isempty(dz)
            nSamples = numel(depth);
            targetFs = sr_i/(100*median(dz));
        end
    end
end

if ~isfinite(targetFs) || targetFs <= 0
    targetFs = 1;
end

nSamples = max(2,nSamples);
nfft = max(ceil(pad),nSamples);
targetTime = (0:nSamples-1)' ./ targetFs;
end
