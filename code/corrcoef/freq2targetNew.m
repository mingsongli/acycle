function la = freq2targetNew(dat,pad,data_pow,orbit9,lax,sr_i)
%
% Generate a target periodogram from orbital periods.
%
% INPUT
% dat: depth series, unit = m; 2 columns
% data_pow: data power spectrum, column 1 = spatial frequency (cycles/m),
%           column 2 = power. Its power near each orbital frequency is used
%           to set the target sinusoid amplitudes.
% orbit9: 9 orbital periods, in kyr
% sr1, sr2, srstep: test sedimentation rates
%
% OUTPUT
%   la: target power interpolated on lax, where lax is in cycles/kyr
%
% calls for 
%   cocoGetPowerNew

targetp = cocoGetPowerNew(data_pow, orbit9, sr_i, dat); % get variance for each orbital period (in kyr)

lax = lax(:);
la = zeros(size(lax));
if isempty(lax)
    return
end

orbit9 = orbit9(:);
targetp = targetp(:);
ok = isfinite(orbit9) & orbit9 > 0 & isfinite(targetp) & targetp > 0;
orbit9 = orbit9(ok);
targetp = targetp(ok);
if isempty(orbit9)
    return
end

if nargin < 2 || isempty(pad) || ~isfinite(pad) || pad <= 0
    pad = 5000;
end

[targetTime, targetFs, nfft] = targetSamplingFromData(dat, pad, orbit9, sr_i);

amp = orbitAmplitudeFromPower(orbit9, targetp, targetTime, nfft, targetFs);
y0 = zeros(size(targetTime));
for ii = 1:numel(orbit9)
    if amp(ii) > 0
        y0 = y0 + amp(ii) .* sin(2 * pi / orbit9(ii) .* targetTime);
    end
end

if std(y0) == 0
    return
end

y0 = detrend(y0, 1);
[targetPower, targetFreq] = periodogram(y0, [], nfft, targetFs);

okFreq = isfinite(targetFreq) & isfinite(targetPower);
targetFreq = targetFreq(okFreq);
targetPower = targetPower(okFreq);
if isempty(targetFreq)
    return
end

[targetFreq, uniqueIdx] = unique(targetFreq);
targetPower = targetPower(uniqueIdx);
la = interp1(targetFreq, targetPower, lax, 'linear', 0);
la(~isfinite(la)) = 0;
end

function [targetTime, targetFs, nfft] = targetSamplingFromData(dat, pad, orbit9, sr_i)
targetFs = 1;
nSamples = max(2, ceil(5 * max(orbit9)));

if ~isempty(dat) && size(dat,2) >= 1 && isfinite(sr_i) && sr_i > 0
    depth = dat(:,1);
    depth = depth(isfinite(depth));
    if numel(depth) >= 2
        depth = sort(depth(:));
        dz = diff(depth);
        dz = dz(isfinite(dz) & dz > 0);
        if ~isempty(dz)
            nSamples = numel(depth);
            targetFs = sr_i / (100 * median(dz));
        end
    end
end

if ~isfinite(targetFs) || targetFs <= 0
    targetFs = 1;
end

nSamples = max(2, nSamples);
nfft = max(ceil(pad), nSamples);
targetTime = (0:nSamples-1)' ./ targetFs;
end

function amp = orbitAmplitudeFromPower(orbit9, targetp, targetTime, nfft, targetFs)
amp = zeros(size(targetp));
unitPeakPower = unitPeakPowerForOrbits(orbit9, targetTime, nfft, targetFs);
ok = isfinite(unitPeakPower) & unitPeakPower > 0;
amp(ok) = sqrt(targetp(ok) ./ unitPeakPower(ok));
end

function unitPeakPower = unitPeakPowerForOrbits(orbit9, targetTime, nfft, targetFs)
persistent cachedOrbit cachedTimen cachedNfft cachedFs cachedPower

if ~isempty(cachedPower) && cachedTimen == numel(targetTime) && ...
        cachedNfft == nfft && cachedFs == targetFs && isequal(cachedOrbit, orbit9)
    unitPeakPower = cachedPower;
    return
end

unitPeakPower = zeros(size(orbit9));
targetFreq = 1 ./ orbit9;
targetRBW = enbw(rectwin(numel(targetTime)), targetFs); % cycles/kyr

for ii = 1:numel(orbit9)
    y = detrend(sin(2 * pi / orbit9(ii) .* targetTime), 1);
    if std(y) == 0
        continue
    end

    [unitPower, unitFreq] = periodogram(y, [], nfft, targetFs);
    inBand = abs(unitFreq - targetFreq(ii)) <= targetRBW;
    if any(inBand)
        unitPeakPower(ii) = max(unitPower(inBand));
    else
        [~, nearestIdx] = min(abs(unitFreq - targetFreq(ii)));
        unitPeakPower(ii) = unitPower(nearestIdx);
    end
end

cachedOrbit = orbit9;
cachedTimen = numel(targetTime);
cachedNfft = nfft;
cachedFs = targetFs;
cachedPower = unitPeakPower;
end
