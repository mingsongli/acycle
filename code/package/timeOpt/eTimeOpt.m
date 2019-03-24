function [senv,spow,sopt,x_grid,y_grid,sr_p_data] = eTimeOpt(data,window,step,sedmin,sedmax,numsed,nsim,linLog,fit,fl,fh,roll,targetE,targetP,normal,detrend,cormethod,genplot)
%                                                   1     2     3     4      5      6      7     8    9  10 11  12     13      14     15      16       17       18
if nargin < 18; genplot = 1; end % default: plot
if nargin < 17; cormethod = 2; end
if nargin < 16; detrend = 0; end % default: no detrending
if nargin < 15; normal = 0; end % default: no normalize for each window
if nargin < 14; targetP = [23.62069,22.31868,19.06768,18.91979]; end % default: precession
if nargin < 13; targetE = [405.6795,130.719,123.839,98.86307,94.87666]; end % default: eccentricity
if nargin < 12; roll = 10^12; end % default: roll off rate
if nargin < 11; fh = 0.065; end % default: high cutoff freq
if nargin < 10; fl = 0.035; end % default: low cutoff freq
if nargin < 9; fit = 1;  end  % default: fit to precession amplitude modulation
if nargin < 8; linLog = 1; end % linear (1) or log (2) sedimentation rate grid
if nargin < 7; nsim = 0; end
if nargin < 6; numsed = 100; end % tested 100 sed. rates
if nargin < 5; sedmax = 30; end  % max sed. rate is 30 cm/kyr
if nargin < 4; sedmin = 0.1;end % min sed. rate is 0.1 cm/kyr
if nargin < 3; step = 1; end % sliding window step cm/kyr
if nargin < 2; window = 300; end % window size
if nargin < 1; % if no input date ...
    n = 800; dat(:,1) = (1:n)'; dat(:,2) = filter(1,[1;-0.5],randn(n,1));
end 
%%
senv=[];
spow=[];
sopt=[];

x = data(:,1);
y = data(:,2);
dt = median(diff(x)); % sample rates

if step < dt; 
    step = dt;
end

npts = length(x);      % number of rows of data
if window >= abs(x(end)-x(1))
    error('Error in eTimeOpt. Window must be smaller than the x range')
end
n_win = floor(window/dt);  % number of data within 1 window
n_step = floor(step/dt); % number of data for 1 step
npts_new1 = npts - n_win +1; % size of y_grid if step = 1
npts_new = ceil(npts_new1/n_step); % size of y_grid
% 
sr_p_data = zeros(npts_new,6);

if mod(n_win,2)==0
    nstart = (n_win/2);
else
    nstart = (n_win+1)/2; % first data in y_grid
end

z = zeros(npts_new,n_win);
y_grid = zeros(npts_new,1);

% read data y for each window and detrend before saving data in z
j=1;
for i = 1: n_step : npts
    k = i + n_win - 1; %
    z(j,:) = y(i:k);
    y_grid(j,:) = x(nstart+i-1);
    j = j+1;
    if j > npts_new
        break
    end
end

depth_w = (0: dt : (n_win-1) * dt)';

% Waitbar
hwaitbar = waitbar(0,'eTimeOpt: sliding window. processing ...',...    
   'WindowStyle','modal');
hwaitbar_find = findobj(hwaitbar,'Type','Patch');
set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
setappdata(hwaitbar,'canceling',0)
steps = npts_new;
% step estimation for waitbar
waitbarstep = 0;
waitbar(waitbarstep / steps)

for i =1 : npts_new
    % waitbar
    pause(0.0001);%
    waitbar(i / steps)
    if getappdata(hwaitbar,'canceling')
        break
    end
    %
    d = z(i,:);
    dat = [depth_w,d'];
    disp(' ')
    disp(['--> Sliding window ',num2str(i),' of ',num2str(npts_new),'. Window center = ',num2str(y_grid(i)/100)])
    [xx,~,~,sr_p] =timeOptAc(dat,sedmin,sedmax,numsed,nsim,linLog,fit,fl,fh,roll,targetE,targetP,detrend,cormethod,0);
    senv(i,:) = xx(:,2)';
    spow(i,:) = xx(:,3)';
    sopt(i,:) = xx(:,4)';
    sr_p_data(i,:) = sr_p;
end
% hwaitbar
try close(hwaitbar)
catch
end
%
if normal == 1
    maxsenv = max(senv,[],2);
    maxspow = max(spow,[],2);
    maxsopt = max(sopt,[],2);
    for i = 1: npts_new
        senv(i,:) = senv(i,:)/maxsenv(i);
        spow(i,:) = spow(i,:)/maxspow(i);
        sopt(i,:) = sopt(i,:)/maxsopt(i);
    end
end
x_grid = xx(:,1)';

[srow, ~] = size(senv);
y_grid = linspace((x(1)+window/2), (x(end)-window/2), srow); %debug
