function [dataX] = zeropad2(data,win,padding)
% zero-padding data, to the beginning and the end of the data
% data: 2 column, equal spaced sampling data
% win: window size, must be larger than sampling rate of the data
% padding: padding type. (1=zero padding,
%           2=mirror padding, 3=mean padding, 4=random padding)
%
%
% partly based on evofft19.m
% 2019: update by Nicolas Thibault & Giovanni Rizzi on padding options
%
% Mingsong Li, April 2019
% Penn State
if nargin < 3; padding = 1; end
if nargin < 2; win = 0.35 * abs(data(end,1) - data(1,1)); end
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
%X1x = linspace( (min(x)-win/2), min(x)-dt, n);
X1x = (min(x)-dt) : -dt : (min(x)-win/2);
X1x = sort(X1x);

% zero-padding last half window
%X2x = linspace( max(x)+dt, (max(x)+win/2), n);
X2x = (max(x)+dt) : dt : (max(x)+win/2);

if padding == 1
    % zero padding
    X1y = zeros(length(X1x),1);
    X2y = zeros(length(X2x),1);
elseif padding == 2
    % mirror padding
    X1y = y(length(X1x):-1:1);
    X2y = y(end: -1 : (end-length(X2x)+1));
    %disp(size(X2x'))
    %disp(size(X2y))
elseif padding == 3
    % mean padding
    y_start_mean = mean(y(1:n));
    y_end_mean = mean(y(end-n:end));
    X1y = zeros(length(X1x),1) + y_start_mean;
    X2y = zeros(length(X2x),1) + y_end_mean;
elseif padding == 4
    % random padding
    y_start_mean = mean(y(1:n));
    y_end_mean = mean(y(end-n:end));
    X1y = randn(length(X1x),1) * std(y(1:n)) + y_start_mean;
    X2y = randn(length(X2x),1) * std(y(end-n:end)) + y_end_mean;
else
    error('Error: padding must be either 1, 2, 3, or 4')
end

X1 = [X1x',X1y];
X2 = [X2x',X2y];

% final result
dataX = [X1; data; X2];