function rateRange = cocoAllPeriodRateRange(periods,sampleSpacing,sampleCount)
%COCOALLPERIODRATERANGE Nyquist/Rayleigh rate range for all target periods.
%
% RATERANGE = COCOALLPERIODRATERANGE(PERIODS,DZ,N) returns the continuous
% sedimentation-rate interval in cm/kyr over which every requested period
% is physically represented between the rectangular-window Rayleigh and
% Nyquist frequencies of an N-point series sampled every DZ metres.
%
% The lower boundary is exclusive because a target exactly at Nyquist is
% excluded.  The upper boundary is inclusive because a target exactly at
% the Rayleigh frequency is retained:
%
%   rateRange = ( max(200*DZ./PERIODS), ...
%                 min(100*N*DZ./PERIODS) ]

validateattributes(periods,{'numeric'}, ...
    {'vector','real','finite','positive','nonempty'},mfilename,'periods',1);
validateattributes(sampleSpacing,{'numeric'}, ...
    {'scalar','real','finite','positive'},mfilename,'sampleSpacing',2);
validateattributes(sampleCount,{'numeric'}, ...
    {'scalar','integer','finite','>=',2},mfilename,'sampleCount',3);

periods = periods(:);
rateRange = [max(200*sampleSpacing./periods), ...
    min(100*sampleCount*sampleSpacing./periods)];
end
