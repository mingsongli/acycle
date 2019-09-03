function [meanboot,bootstd,bootprt] = smoothciML(X,Y,method,span,bootn)
%
% INPUT
%   X:      n x 1 vector, time
%   Y:      n x 1 vector, value
%   method: 'loess', 'lowess', 'rloess', or 'rlowess'
%   span:   percentage of smooth method
%   bootn:  number of bootstrap
%
% OUTPUT
%   meanboot:   mean of boot
%   stdboot:    standard deviation of boot
%
% EXAMPLE:
%   X = (linspace(1,10,100))';
%   Y = 1.6 -0.6*cos(X*.6) -1.3*sin(X*.6) -1.2 *cos(2*X*.6) -0.9*sin(2*X*.6);
%   Y = Y +  .2*(max(Y)-min(Y)) * randn(100,1);
%   [meanboot,bootstd,bootprt] = smoothciML(X,Y,'loess',.3,500);
%
% Calls for
%   smoothci.m  An online Matlab code doing smooth and some data adjustments
%
% By Mingsong Li @ Penn State April 2018

if nargin < 5 || isempty(bootn)
    bootn = 500;    % 500 or 1000
    if nargin < 4 || isempty(span)
        span = 0.3; % 0 <= span <= 1
        if nargin < 3
            method = 'loess';  % 'loess', 'lowess', 'rloess', or 'rlowess'
        end
    end
end

f = @(xy) smoothci(xy,X,span,method);
yboot2 = bootstrp(bootn,f,[X,Y])';

meanboot = mean(yboot2,2);
bootstd = std(yboot2,0,2);
%percentile
bootprt = prctile(yboot2, [.5,2.275,15.865,50,84.135,97.725,99.5],2);

figure;
scatter(X,Y)
h1 = line(X, meanboot,'color','k','linestyle','-','linewidth',2);
h3 = line(X, meanboot + 1 * bootstd,'color','r','linestyle','-','linewidth',1);
h2 = line(X, meanboot + 2 * bootstd,'color','r','linestyle','--','linewidth',.5);
h4 = line(X, meanboot - 1 * bootstd,'color','r','linestyle','-','linewidth',1);
h5 = line(X, meanboot - 2 * bootstd,'color','r','linestyle','--','linewidth',.5);
legend('Data',[num2str(span*100),'% ',method,' regression'],...
    '1\sigma confidence intervals','2\sigma confidence intervals','Location','NorthEast');
%L5 = legend('Data',[num2str(span*100),'% ',method,' regression'],...
%    '1\sigma confidence intervals','2\sigma confidence intervals',4);