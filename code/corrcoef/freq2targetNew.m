function la = freq2targetNew(dat,pad,theoredML96_pow,orbit9,lax,sr_i)
%
% Generate target power spectrum using given orbital periods and the power 
% ratio of ML96 background noise model
%
% INPUT
% dat: depth series, unit = m; 2 columns
% theoredML96_pow: theoretical background AR1 noise from ML96 model
% orbit9: 9 orbital periods, in kyr
% sr1, sr2, srstep: test sedimentation rates
%
% OUTPUT
%   la: 
%
% calls for 
%   cocoGetPower

% Check whether the depth series is evenly sampled 
depth = dat(:,1);
nData = numel(depth);
dz = diff(depth);
meanDz = mean(dz); 
if meanDz <= 0 
    error('Depth values must increase monotonically.'); 
end 
if max(abs(dz - meanDz)) > 1e-6 * abs(meanDz) 
    error(['The depth series is not evenly sampled. ', ... 
        'Resample the data or use a method for uneven sampling.']); 
end 

% Spatial sampling frequency, with units of samples per metre 
fsDepth = 1 / meanDz;

time_sr = dat(:,1) * 100 / sr_i;  % convert depth (m) to time using given sed. rate

targetp = cocoGetPower(theoredML96_pow, orbit9, sr_i); % get variance for each orbital periods (in kyr)

A = sqrt(2*targetp);  % convert vairance to amplitude

y0 = zeros(nData,1);  % initial signal
for ii = 1 : length(orbit9)
    y = A(ii) * sin(2 * pi / orbit9(ii) .* time_sr);  % Y = A * sin(2pi/T * t)
    y0 = y + y0;
end

y0= detrend(y0, 1);  % remove any linear trend

[p,f] = periodogram(y0,[],pad,fsDepth);  % power of dat

la = interp1(f, p, lax, 'linear', 0);

