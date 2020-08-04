% rmse4leadlag.m
% RMSE of two series
%   to determine the 'lead/lag' of the series related to the target
%
% Step 1. Select the common interval for both target and series
% Step 2. Shift series
% Step 3. Select the common interval for both target and shifted series
% Step 4. Interpolate the series using the first column (time) of the target
% Step 5. Calculate the RMSE of both series
%   
% INPUT
%   target  : a 2-column matrix. 
%   series  : a 2-column matrix. The time span must cover at least part of
%               the time of the target
%   ll      : time, the limit for lead/lag.
%               Positive: series leads target
%               Negative: series lags target
%   step    : time step, from 'lead' to 'lag'

% OUTPUT
%   leadlag : 
%   RMSE    : 

% Author:	Mingsong Li (Penn State)
% Date  :   Aug. 3, 2020
function [llgrid,RMSE] = rmse4leadlag(target,series,ll,step,plotn)

% Example:
%
% target = load('/Users/mingsongli/Dropbox/Research/202004NewarkMengWang/data/PC1.txt');
% series = load('/Users/mingsongli/Dropbox/Research/202004NewarkMengWang/data/composite-sue-rsp0.02-16.041-LOWESS-TD-composite-sue-rsp0.02-16.041-LOWESS-Gau-0.132±0.07-agemodel-405_max-DYNOT-median-new.txt');
% series = load('/Users/mingsongli/Dropbox/Research/202004NewarkMengWang/data/composite-sue-rsp0.02-16.041-LOWESS-TD-composite-sue-rsp0.02-16.041-LOWESS-Gau-0.132±0.07-agemodel-405_max-rho1-median.txt');
% step = 1;
% ll = 300;
% plotn = 1;
% [llgrid,RMSE] = rmse4leadlag(target,series,ll,step,plotn)

% start and end of the 1st column of the target
tar1 = min(target(:,1));
tar2 = max(target(:,1));
% start and end of the 1st column of the series
ser1 = min(series(:,1));
ser2 = max(series(:,1));
% common interval
sel1 = max(ser1, tar1); % lower bound
sel2 = min(ser2, tar2); % upper bound
if sel1 >= sel2
    error('Error: no overlap')
else
    sel = sel2 - sel1;
    if ll> sel
        ll = sel;
        disp('Warning: the test range is too large')
    end
end

% Step 1. Select the common interval for both target and series
[series1] = select_interval(series,sel1,sel2);
[target1] = select_interval(target,sel1,sel2);
% standardized
series1(:,2) = (series1(:,2) - mean(series1(:,2)))/std(series1(:,2));
target1(:,2) = (target1(:,2) - mean(target1(:,2)))/std(target1(:,2));

llgrid = 0:step:ll;
llgrid1 = -1 * llgrid(2:end);
llgrid = [llgrid1, llgrid];
llgrid = sort(llgrid);
lln = length(llgrid);
RMSE = NaN(1,lln);
% iteration
for i = 1: lln
    series2 = series1;
    % Step 2. Shift series
    series2(:,1) = series2(:,1) + llgrid(i);
    % Step 3. Select the common interval for both target and shifted series
    
    % start and end of the 1st column of the series
    ser1 = min(series2(:,1));
    ser2 = max(series2(:,1));
    % common interval
    sel1 = max(ser1, tar1); % lower bound
    sel2 = min(ser2, tar2); % upper bound
    if sel1 >= sel2
        continue
    end
    [series3] = select_interval(series2,sel1,sel2);
    [target4] = select_interval(target1,sel1,sel2);
    
    % Step 4. Interpolate the series using the first column (time) of the target
    series2int = interp1(series3(:,1),series3(:,2),target4(:,1));
    series4  = [target4(:,1),series2int];
    rmsei = sqrt(mean((series4(:,2) - target4(:,2)).^2));
    RMSE(i) = rmsei;
end

RMSEj = RMSE(RMSE==min(RMSE));
llgridj = llgrid(RMSE==min(RMSE));

if llgridj > 0
    leadlagid = 'leads';
elseif llgridj == 0
    leadlagid = 'is in-phase with';
else
    leadlagid = 'lags behind';
end

if plotn == 1
    figure;
    set(gcf,'color','white')
    plot(llgrid,RMSE,'k');
    hold on
    ylimhere = ylim;
    plot([llgridj llgridj],[ylimhere(1) ylimhere(2)],'r-.')
    xlabel('lead (+) / lag (-)')
    ylabel('RMSE')
    title(['Min RMSE @ ', num2str(llgridj),'. Series ',leadlagid,' reference.'])
    
    figure;set(gcf,'color','white')
    subplot(311)
    plot(target(:,1),target(:,2),'b-')
    xlim([min(target(:,1)),max(target(:,1))]);
    title('Reference')
    subplot(312)
    plot(series(:,1),series(:,2),'k-')
    if llgridj ~=0
        hold on
        plot(series(:,1)+llgridj, series(:,2),'r-.')
        legend({'Raw series';'Adjusted series'});
    end
    xlim([min(target(:,1)),max(target(:,1))]);
    title('Series')
    
    subplot(313)
    plot(target1(:,1),target1(:,2),'b-')
    hold on;
    plot(series1(:,1),series1(:,2),'k-')
    
    if llgridj ~=0
        plot(series1(:,1)+llgridj, series1(:,2),'r-.')
        %legend({'Target';'Raw series';'Adjusted series'})
    end
    xlim([min(target1(:,1)),max(target1(:,1))]);
    hold off;
    xlabel('Depth/Time')
    ylabel('Standardized value')
end