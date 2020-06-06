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
%bootprt = prctile(yboot2, [.5,2.275,15.865,50,84.135,97.725,99.5],2);
bootprt = prctile(yboot2, [0.5,2.5,5,25,50,75,95,97.5,99.5],2);

colorcode = [67/255,180/255,100/255];

figure;
set(gcf,'units','norm') % set location
set(gcf,'position',[0.005,0.45,0.38,0.45]) % set position
set(gcf,'color','w');
hold on
fill([X', fliplr(X')],[(meanboot + 2 * bootstd)', fliplr((meanboot - 2 * bootstd)')],colorcode,'LineStyle','none','facealpha',.2)
fill([X', fliplr(X')],[(meanboot + bootstd)', fliplr((meanboot - bootstd)')],colorcode,'LineStyle','none','facealpha',.6)
plot(X,meanboot,'Color',[0,120/255,0],'LineWidth',1.5,'LineStyle','-')
scatter(X,Y,'b')
title([num2str(span*100),' % ',method,' regression'])
legend('2\sigma confidence intervals','1\sigma confidence intervals',...
    'mean','Data',...
    'Location','NorthEast','Interpreter','tex');
hold off

figure;
set(gcf,'units','norm') % set location
set(gcf,'position',[0.385,0.45,0.38,0.45]) % set position
set(gcf,'color','w');
hold on
fill([X', fliplr(X')],[(bootprt(:,end))', fliplr((bootprt(:,1))')],colorcode,'LineStyle','none','facealpha',.1)
fill([X', fliplr(X')],[(bootprt(:,end-1))', fliplr((bootprt(:,2))')],colorcode,'LineStyle','none','facealpha',.3)
fill([X', fliplr(X')],[(bootprt(:,end-2))', fliplr((bootprt(:,3))')],colorcode,'LineStyle','none','facealpha',.5)
fill([X', fliplr(X')],[(bootprt(:,end-3))', fliplr((bootprt(:,4))')],colorcode,'LineStyle','none','facealpha',.9)
plot(X,bootprt(:,5),'Color',[0,120/255,0],'LineWidth',1.5,'LineStyle','-')
scatter(X,Y,'b')
title([num2str(span*100),' % ',method,' regression'])
legend('99% confidence intervals','95% confidence intervals','90% confidence intervals',...
    '50% confidence intervals','median','Data',...
    'Location','NorthEast');
hold off