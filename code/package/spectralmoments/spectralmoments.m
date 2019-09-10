function [depth,uf,Bw,Bwtrend,sr] = spectralmoments(data,window,step,pad,srmean,smoothmodel,padedge)
%
% Spectral moments of a given series in depth domain
%   for the recognition of variable sedimentation rate
%   When the mean sedimentation rate is assigned, sedimentation rate trend
%   can be evaluated using a sliding window approach.
%
% Designed for Acycle software by 
%   Mingsong Li, August 20, 2019
%   based on SpectralMoments_with_SR_estimation.m by Sinnesael M.
%
% INPUT
%
%   data:   2 column， Uniform sampled, increasing stratigraphic series
%           unit: meters
%   window: runing window; Default = 35% of total length
%   step:   runing step >= sampeling rates. Default = raw sampling rate
%   pad:    zero-padding of each sliding window. 
%           Default = 5. Five times of data points for each sliding window.
%   srmean: [optional] mean sedimentation rate
%           unit: cm/kyr
%   smoothmodel: [optional]
%       'poly'    :  polynomial [default]
%       'lowess'  :  lowess
%       'rlowess' :  rlowess
%       'loess'   :  loess
%       'rloess'  :  rloess
%   padedge:    [optional: 0 or 1] default = 1
%
% OUTPUT
%
%   depth:      n-by-1 vector; depth
%   uf:         n-by-1 vector; mean frequency
%   Bw:         n-by-1 vector; bandwidth
%   Bwtrend:    n-by-1 vector; long-term trend of bandwidth [optional]
%   sr:         n-by-1 vector; variable sedimentation rate  [optional]
% 
% ASK FOR:
%
%   DetrendSignalPP.m by Sinnesael M.
%
% Syntax
%
%   [depth,uf,Bw] = spectralmoments(data)
%   [depth,uf,Bw] = spectralmoments(data,window)
%   [depth,uf,Bw] = spectralmoments(data,window,step)
%   [depth,uf,Bw] = spectralmoments(data,window,step,pad)
%   [depth,uf,Bw,Bwtrend,sr] = spectralmoments(data,window,step,pad,srmean)
%   [depth,uf,Bw,Bwtrend,sr] = spectralmoments(data,window,step,pad,srmean,smoothmodel)
%   [depth,uf,Bw,Bwtrend,sr] = spectralmoments(data,window,step,pad,srmean,smoothmodel,padedge)
%
% EXAMPLE
%
%   data = load('P140-GR-stand-2164-4112 m-sue-681.8-LOWESS.txt');
%   [depth,uf,Bw] = spectralmoments(data,120);
%   figure; plot(depth,uf,'r-',depth,Bw,'b-.');
%   xlabel('Depth (m)'); ylabel('Frequency (cycles/m)'); legend('\mu_f','B')
%
%   [depth,uf,Bw,Bwtrend,sr] = spectralmoments(data,120,0.125,5,11,'lowess',1);
%   figure; plot(depth,uf,'r-',depth,Bw,'b-.',depth,Bwtrend,'g');
%   xlabel('Depth (m)'); ylabel('Frequency (cycles/m)'); legend('\mu_f','B','trend')
%   figure; plot(depth, sr); xlabel('Depth (m)'); ylabel('Sed. rate (cm/kyr)');
%
% Please cite:
%
%   Sinnesael, M., Zivanovic, M., De Vleeschouwer, D., Claeys, P. (2018) 
%   Spectral Moments in Cyclostratigraphy: Advantages and Disadvantages 
%   compared to more classic Approaches. Paleoceanography and Paleoclimatology
%   33, 493-510. https://doi.org/10.1029/2017PA003293
%   
%   AND
%
%   Li, M., Hinnov, L., Kump, L. (2019) Acycle: Time-series analysis software 
%   for paleoclimate research and education. Computers & Geosciences 127, 12-22.

if nargin > 7; error('Too many input arguments'); end
if nargin < 7; padedge = 1; end
if nargin < 6; smoothmodel = 'poly'; end
if nargin < 5; srmean = 0;end
if nargin < 4; pad = 5;   end
if nargin < 3; step = data(2,1) - data(1,1); end
if nargin < 2; window = .35 * (data(end,1)-data(1,1));end

if srmean < 0; error('Mean sedimentation rate must be > 0'); end
if pad < 1; error('padding must be > 0'); end
if step <= 0; error('Step must be larger than 0'); end

if padedge == 1
    data = zeropad2(data,window,1);
end

controlbar = 1; % show control bar

x = data(:,1); % depth 
y = data(:,2); % value

dt = median(diff(x)); % sampling rate

if step < dt
    step = dt;
end

npts = length(x); % number of rows of data

if window >= npts * dt
    error('Error in spectralmoments. Window must be smaller than data length')
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
uf = zeros(npts_new,1);
Bw = zeros(npts_new,1);

% read data y for each n and detrend before saving data in z
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

if controlbar
    % Waitbar
    hwaitbar = waitbar(0,'Sliding window processing ...[CTRL + C to quit]',...    
       'WindowStyle','modal');
    hwaitbar_find = findobj(hwaitbar,'Type','Patch');
    set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
    steps = 100;
    % step estimation for waitbar
    nmc_n = round(npts_new/steps);
    waitbarstep = 1;
    waitbar(waitbarstep / steps)
end
    
for i =1:npts_new
    d = z(i,:);
    [pxx,f] = periodogram(d,[],pad*n_win,1/dt);
    uf(i) = sum(f.*pxx./sum(pxx));
    BW2 = sum((f-uf(i)).^2 .* pxx / sum(pxx));
    Bw(i) = sqrt(BW2);
    
    if rem(i,nmc_n) == 0
        waitbarstep = waitbarstep+1; 
        if waitbarstep > steps; waitbarstep = steps; end
        pause(0.0001);%
        waitbar(waitbarstep / steps)
    end
end

if ishandle(hwaitbar)
    close(hwaitbar);
end
        
depth = linspace((x(1)+window/2), (x(end)-window/2), npts_new);
depth = depth';

if nargout > 3
    if strcmp(smoothmodel, 'poly')
        windowsize = round(window/dt);
        [~,Bwtrend] = DetrendSignalPP(Bw,windowsize,dt,2);
    else
        span = window/abs(depth(end)-depth(1));
        Bwtrend = smooth(depth,Bw, span,smoothmodel);
    end
    sr = srmean * Bw(1) ./ Bwtrend;
    sr = sr - mean(sr);
    sr = sr + srmean;
end