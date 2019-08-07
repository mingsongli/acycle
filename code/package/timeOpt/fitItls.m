function [rsq, rval] = fitItls(timeSeries, sedrate1, targetIn, cormethod,lsmethod,genplot)
% fitIt least squares
% input
%   timeSeries: tested time series, unit: cm
%   targetIn: target input cycles: unit kyr
%   cormethod: correlation method: 1= pearson; 2= spearman
%   lsmethod: least square method. 
%           1 = least square of a, and b
%           2 = timeOpt linear fit
% Output
%   rsq: r^2
%   rval: r
% calls for
%   harm1ML.m % least squares estimate a and b:  fy = a*cos(w*t) + b*sin(w*t)
%
% By Mingsong Li, Penn State, Jan. 5, 2019
%   mul450@psu.edu; www.mingsongli.com
%
if nargin < 6; genplot = 0; end
if nargin < 5; lsmethod = 1; end
if nargin < 4; cormethod = 2; end

x = timeSeries(:,1);
dt = median(diff(x)); % raw sampling rate: unit: cm
y  = timeSeries(:,2);
y = (y-mean(y))/std(y);
npts = length(y);
%
tInn = length(targetIn);
if lsmethod == 1
    ypn = zeros(npts,tInn);
    % reconstruct a model series using least square method
    for i = 1: tInn
        [a,b,~,~] = harm1ML(x,y,targetIn(i));
        ypn(:,i) = a * cos(2*pi*x/targetIn(i)) + b * sin(2*pi*x/targetIn(i));
    end
    fy = sum(ypn,2);
elseif lsmethod == 2
    % original used in timeOpt
    xm = genCycles(dt, sedrate1, targetIn, npts);
    [~,fy] = coeff(xm,y);
end

fy = (fy - mean(fy))/std(fy);

if cormethod == 1
    % pearson
    rval = corrcoef(fy,y);
    rval=rval(2,1);
    rsq = rval^2;
elseif cormethod == 2
    % spearman
    rval = corr(fy,y);
    rsq = rval^2;
end

if genplot == 1
    timeSeries(:,1) = timeSeries(:,1) - min(timeSeries(:,1));
    figure;
    set(gcf,'Units','normalized','Position',[0.0, 0.5, 0.33, 0.4])
    subplot(2,1,1)
    plot(timeSeries(:,1), y,'r','LineWidth',3);
    hold on;
    plot(timeSeries(:,1), fy,'k','LineWidth',2);
    %legend('Envolope','Reconstructed')
    title(['Envolope (red) vs. reconstructed model (black) @', num2str(sedrate1),' cm/kyr'])
    xlabel('Time (kyr)')
    ylabel('Std. Value')
    xlim([min(timeSeries(:,1)), max(timeSeries(:,1))])
    
    sdat = polyfit(y,fy,1);
    datl = y * sdat(1) + sdat(2);
    
    %figure;
    subplot(2,1,2)
    plot(y,fy,'ko','MarkerSize',10)
    hold on;
    plot(y,datl,'r--','LineWidth',3)
    xlabel('Envelope')
    ylabel('Reconstructed Model')
end