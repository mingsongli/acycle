function [norbit]=numorbit(orbit7,nyquist,rayleigh,sr_range,mpts,plotn)
% INPUT
%   targetf  a target series containing orbital frequencies and its power
%   rayleigh   rayleigh frequency of data series.
%   sr_range:  sedimentation rates to be evaluated
%   mpts: number of sedimentation rates to be evaluated
%
% OUTPUT
%   norbit:     a series indicating how many orbital frequencies are used
%
% EXAMPLE
%
%       orbit7 = [400 133 110 39 23 21.8 18.5];  % seven orbit periods to be evaluated
%       rayleigh = 0.02;
%       nyquist  = 10;
%       sr_range = .1:.02:20
%       mpts = length(sr_range);
%       [norbit]=numorbit(orbit7,rayleigh,nyquist,sr_range,mpts);
%       figure; plot(sr_range,norbit)
%
% Mingsong Li, June 2017 @ Penn State

if nargin > 6
    error('Too many input arguments')
    return;
end
if nargin < 6
    plotn = 0;
    if nargin < 5
        mpts = length(sr_range);
        if nargin < 4
            sr_range = .1:.1:20;
            if nargin < 3
                error('Too few input arguments')
                return;
            end
        end
    end
end

nlength = 100/rayleigh;  % length of input dataseries
sr_period = nlength./sr_range;  % length of data in time for each sed. rates
sr_period = sr_period';
% orbit7 = [400 133 110 39 23 21.8 18.5];  % seven orbit periods to be evaluated
freq7 = 1./orbit7;   % 7 freq. 
sr0orbit7 = freq7*100/nyquist;  % turn points sr0 (if sr < sr0, high freq orbital cycles will be ignored)
norbit7 = length(orbit7);
srorbit = ones(norbit7,1);   %
% evaluate shreshold sedimentation rates that exceed rayleigh freq. for
% each period
for i = 1: norbit7
    sr_period1 = length(sr_period(sr_period >= orbit7(i)));
    if sr_period1 == 0
        sr_period1=1;
    end
    srorbit(i) = sr_range(sr_period1);
end
% evalute large sedimentation rates corresponding orbital cycles numbers
norbit = norbit7 * ones(mpts,1);
for i = 1 : norbit7
    j = norbit7+1-i;
    norbit(sr_range <= srorbit(j))=i;
end
% evalute small sedimentation rates corresponding orbital cycles numbers
for i = 1 : norbit7
    j = norbit7+1-i;
    norbit(sr_range < sr0orbit7(j)) = j-1;
end

if plotn == 1
     % plot number of orbital
    figure; plot(sr_range,norbit)
    xlabel('Sedimentation rates (cm/kyr)')
    ylabel('Number of orbital cycles (#)')
    ylim([min(norbit)-1 max(norbit)+1])
    legend('Orbital solutions to be evaluated')
end