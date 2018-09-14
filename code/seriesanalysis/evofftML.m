function [s,x_grid,y_grid] = evofftML(data,window,step,fmin,fmax,normal)
% INPUT
%   data: 2 column evenly spaced, increasing time series
%   window: runing window
%   step: runing step; >= sampeling rates
%   normal: normalize output or not
% OUTPUT
%   s:      
%   x_grid: 
%   y_grid: 
% 
% Then
%   figure; pcolor(x_grid,y_grid,s);shading interp;colormap(jet);
%   OR
%   figure; surf(x_grid,y_grid,s);shading interp;colormap(jet);
% Mingsong Li, May 2017

pad = 10; % x zero-padding
x = data(:,1);
y = data(:,2);
dt = abs(x(2)-x(1)); % sample rates

if step < dt
    step = dt;
end
npts = length(x);      % number of rows of data
if window >= npts
    error('Error in evoperiodogram. Window must be smaller than the row of data')
end
n_win = floor(window/dt);  % number of data within 1 window
n_step = floor(step/dt); % number of data for 1 step
npts_new1 = npts - n_win +1; % size of y_grid if step = 1
npts_new = ceil(npts_new1/n_step); % size of y_grid
% 
if mod(n_win,2)==0
    nstart = (n_win/2);
else
    nstart = (n_win+1)/2; % first data in y_grid
end
z = zeros(npts_new,n_win);
y_grid = zeros(npts_new,1);
nspec=round(npts-n_win)/n_step + 1; % number of spectra to be calculated
% read data y for each window and detrend before saving data in z
j=1;
for i = 1: n_step : npts
    k = i+n_win-1; %
    zz = y(i:k);
    c = detrend(zz);
    z(j,:) = c';
    y_grid(j,:)=x(nstart+i-1);
    j = j+1;
    if j > npts_new
        break
    end
end
s = [];
for i =1:npts_new
    d = z(i,:);
    pxx = fft(d,n_win*pad);
    Y = pxx';
    s(i,:) = Y.*conj(Y)/n_win*pad;
end
ss = s;
nyquist = 1/(2*dt);
nfft = length(s(1,:));
nfmin = ceil(nfft*fmin/nyquist);
if nfmin == 0; nfmin = 1; end
nfmax = floor(nfft*fmax/(2*nyquist));
s = s(:,nfmin:nfmax);
if normal == 1
    s = zeros(i,nfmax-nfmin+1);
    maxs = max(ss(:,nfmin:nfmax),[],2);
    for i = 1: npts_new
        s(i,:) = ss(i,nfmin:nfmax)/maxs(i);
    end
end
x_grid = linspace(fmin,fmax,nfmax-nfmin+1);

% Ensure x_grid and y_grid has the same dimention as s  |  Mingsong Li 2018
[srow, scol] = size(s);  % size of s
if length(x_grid) ~= scol
    x_grid = linspace(fmin,fmax,scol);
end
if length(y_grid) ~= srow
    y_grid = linspace((time(1)+window/2), (time(1)+window/2+(nspec-1)*step), srow);
end