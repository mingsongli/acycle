function [dataX] = zeropad2(data,win)
% zero-padding data, to the beginning and the end of the data
% data: 2 column, equal spaced sampling data
% win: window size, must be larger than sampling rate of the data
%
% Mingsong Li, April 2019
% Penn State

% ensure data is sorted in the ascending order
data = sortrows(data);

x = data(:,1);
y = data(:,2);

% remove mean
data(:,2) = y - mean(y);
% get mean sampling rate
dt = mean(diff(x));
% number of zero-padding data
n = round(win/2/dt);
% zero-padding first half window
X1x = linspace( (min(x)-win/2), min(x)-dt, n);
X1y = zeros(n,1);
X1 = [X1x',X1y];

% zero-padding last half window
X2x = linspace( max(x)+dt, (max(x)+win/2), n);
X2 = [X2x',X1y];

% final result
dataX = [X1; data; X2];