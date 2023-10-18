function [t, meantd, vartd, np, CI_lower, CI_upper, mediantd] ...
    = movmeanfbw(data, window, step, halfwindow, alpha, plotn)
%
% This function calculates the time-dependent mean and variance of a 
% time series using a sliding rectangular window. Temporal changes in 
% mean and vari­ance can be used as a first-order check if a time series 
% is weakly stationary.
% It can process unevenly spaced time series directly without interpolation.
% It use fixed bandwidth method.

% INPUT
%   data: time series, the first column must be time or depth
%   window: sliding window
%   step: running step
%   halfwindow: 0 = empty half window; 1 = force window to cover the end of the data 
%   alpha: p value
%
% OUTPUT
%   t: mean of timestamps within each sliding window 
%   meantd: time dependent mean
%   vartd: time dependent variance
%   np: number of data points
%   CI_lower: 95% confidence interval lower bound
%   CI_upper: 95% confidence interval upper bound
%   mediantd: time dependent median value
%
% Mingsong Li
% Peking University
% Oct. 13, 2023
%
%
% sort data
data = sortrows(data);
% first column
timestamps = data(:,1);
% max and min of time
tmin = min(timestamps);
tmax = max(timestamps);
tspan = tmax - tmin;

if nargin < 6; plotn = 0; end
if nargin < 5; alpha = 0.05; end
if nargin < 4; halfwindow = 0; end
if nargin < 3; step = median(diff(data(:,1))); end
if nargin < 2; window = 0.3 * (tspan); end
% data = currentdata; % load acycle data
% window = 10; 
% step = 2;
%plotn = 1; % for plot

% values
values = data(:,2:end);

if window > tspan; error('Error: Window size is larger than the time span.'); end
if step > tspan; error('Error: Step is larger than the time span.'); end

t = [];
meantd = [];
vartd = [];
mediantd = [];
np = [];
CI_lower = [];
CI_upper = [];

if halfwindow == 0  % empty half window
    allwindow = tmin:step:(tmax-window);
elseif  halfwindow == 1  % fill half window
    allwindow = tmin - window/2 : step :(tmax + window/2) ;
end
% for each windows
for t_start = allwindow
    t_end = t_start + window;
    t_center = t_start + window/2;
    % find data within this window
    mask = (timestamps >= t_start) & (timestamps <= t_end);
    
    if sum(mask) > 0  % if this window contain data, save data
        if t_center >= tmin && t_center <= tmax
            % window t
            window_t = mean(timestamps(mask));
            % mean of the window
            window_mean = mean(values(mask,:), 1);
            % variance of the window
            window_var = var(values(mask,:), 0, 1); % second input "0" uses N-1
            % median
            window_median = median(values(mask,:), 1);
            % size
            n = sum(mask);
            
            % critical values
            chi2_lower = chi2inv(1-alpha/2, n-1); 
            chi2_upper = chi2inv(alpha/2, n-1); 
            % Confidence intervals at alpha
            CI_var_lower = (n-1).*window_var./chi2_lower;
            CI_var_upper = (n-1).*window_var./chi2_upper;
            
            % save median 
            mediantd = [mediantd; window_median];
            % save data
            meantd = [meantd; window_mean];
            vartd = [vartd; window_var];
            t = [t; window_t];
            np = [np; n];
            CI_lower = [CI_lower; CI_var_lower];
            CI_upper = [CI_upper; CI_var_upper];
        end
    end
end

data = [t, meantd, vartd, np, CI_lower, CI_upper, mediantd];

data = findduplicate(data);

t = data(:,1);
meantd = data(:,2);
vartd = data(:,3);
np = data(:,4);
CI_lower = data(:,5);
CI_upper = data(:,6);
mediantd = data(:,7);

if plotn == 1
    figure
    subplot(2,1,1)
    plot(timestamps, values,'k-')
    hold on
    plot(t, meantd,'ro-')
    xlim([tmin, tmax])
    title(['Raw and move mean. Window = ', num2str(window)])
    subplot(2,1,2)
    plot(t, vartd,'r-')
    hold on
    plot(t, CI_lower,'k--')
    plot(t, CI_upper,'k--')
    xlim([tmin, tmax])
    title(['Move variance and 95% CI. Window = ', num2str(window)])
end

function data=findduplicate(data)

% This function aims to creat a new data series
% with no duplicate values
% Updated: data >2 columns allowed.
%
% Mingsong Li
% Peking University
% Oct. 14, 2023
%

x=data(:,1);
b=unique(x);
sizex=length(x);
sizeb=length(b);

if sizex-sizeb~=0
    y = data(:,2:end);

      for i = 1:length(b)
        d(i,:) = mean( y(x==b(i),:) , 1);
      end

    data=[b,d];
    disp('>> Duplicate has been detected')
end
