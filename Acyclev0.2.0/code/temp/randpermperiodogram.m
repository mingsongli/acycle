function [p,f] = randpermperiodogram(data,dt,pad)
% read data; randperm data and do periodogram
% 
% dt sampling rate
% 
if nargin< 3
    pad = 5000;
    if nargin<2
        % sampling rate
        dt = median(diff(data(:,1)));
        if nargin<1
            disp('Too few input argument')
        end
    end
end
%x = data(:,1);
y = data(:,2);

% random permutation of y
yrp = y(randperm(length(y)));  % 

[p, f] = periodogram(yrp,[],pad,1/dt);