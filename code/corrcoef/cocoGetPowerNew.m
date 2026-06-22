function targetp = cocoGetPowerNew(data_pow, orbit9, sr, dat)
%COCOGETPOWERNEW Pick data power peaks near orbital frequencies.
%
% INPUTS:
%   data_pow - Data power spectrum:
%              column 1: spatial frequency (cycles/m)
%              column 2: spectral power
%   orbit9   - Orbital periods (kyr)
%   sr       - Sedimentation rate (cm/kyr)
%   dat      - Depth series, column 1 in metres
%
% OUTPUT:
%   targetp  - Maximum data power within each orbital-frequency band

validateattributes(data_pow, {'numeric'}, ...
    {'2d', 'real', 'nonempty'}, mfilename, 'data_pow');
validateattributes(orbit9, {'numeric'}, ...
    {'vector', 'real', 'finite', 'positive'}, mfilename, 'orbit9');
validateattributes(sr, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'positive'}, mfilename, 'sr');
validateattributes(dat, {'numeric'}, ...
    {'2d', 'real', 'finite', 'nonempty'}, mfilename, 'dat');

if size(data_pow, 2) < 2
    error('data_pow must contain at least two columns.');
end
if size(dat, 2) < 1
    error('dat must contain at least one depth column.');
end

depth = dat(:,1);
dz_all = abs(diff(depth));
dz_all = dz_all(isfinite(dz_all) & dz_all > 0);
if isempty(dz_all)
    error('Depth values must contain at least two distinct samples.');
end

dz = median(dz_all);
Fs = 1 / dz;
window = rectwin(numel(depth));
RBW = enbw(window, Fs);           % cycles/m
RBW_time = RBW * sr / 100;        % cycles/kyr

spatialFreq = data_pow(:,1);
powerValue = data_pow(:,2);
ok = isfinite(spatialFreq) & isfinite(powerValue);
spatialFreq = spatialFreq(ok);
powerValue = powerValue(ok);

timeFreq = spatialFreq * sr / 100; % cycles/kyr
targetFreq = 1 ./ orbit9(:);       % cycles/kyr
targetp = nan(size(targetFreq));

for ii = 1:numel(targetFreq)
    fi = targetFreq(ii);
    fi_range = [fi - RBW_time, fi + RBW_time];
    inBand = timeFreq >= fi_range(1) & timeFreq <= fi_range(2);
    if any(inBand)
        targetp(ii) = max(powerValue(inBand));
    else
        [~, nearestIdx] = min(abs(timeFreq - fi));
        if ~isempty(nearestIdx)
            targetp(ii) = powerValue(nearestIdx);
        end
    end
end

targetp(~isfinite(targetp) | targetp < 0) = 0;
end
