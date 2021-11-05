
function [po, f, pth] = plomb_robustar1(datax,timex,fmax,smoothwin,plotn)
% Lomb-Scargle periodogram
% robust AR(1) confidence levels test again red noise model using robust
% AR(1) model
%
% INPUT
% datax: Nx1, signal
% timex: Nx1, time, must increase monotonically but need not be uniformly spaced. All elements of timex must be nonnegative.
% fmax: number, maximum frequency
% smoothwin:  number, median smoothing window, relative to fmax
% plotn: plot results or not
%
% OUTPUT
% po:  Lomb power
% f:  frequency
% pth: confidence levels [smoothed, median, 90%, 95%, 99%, 99.9%]
% pl: Confidence levels at each frequency
%
% EXAMPLES
%  % currentdata is a two column data, need not be uniformly spaced
% timex = currentdata(:,1);
% datax = currentdata(:,2);
% fmax = 1/(2 * mean(diff(timex)));
% smoothwin = 0.2;
% plotn = 1;
% [po, f, pth] = plomb_robustar1(datax,timex,fmax,smoothwin,plotn);
%
% By Mingsong Li, Peking University
%   Email: msli@pku.edu.cn
% Nov. 5, 2021
%

if nargin < 5; plotn = 0; end
if nargin < 4; smoothwin = 0.2; end
if nargin < 3; fmax = 1/(2 * mean(diff(timex))); end

rho = 0.5; % prior

timex = timex + abs(min(timex));
[po,f] = plomb(datax,timex,fmax);
s0 = mean(po);
pxxsmooth = moveMedian(po,round(smoothwin*length(po)));

cospara = cos(pi.*f./fmax);
funrobust = @(v,f)v(1) * (1-v(2)^2)./(1-(2.*v(2).*cospara)+v(2)^2);
v1 = [s0,rho];
x = lsqcurvefit(funrobust,v1,f,pxxsmooth);
rhoM = x(2);
s0M = x(1);

% median-smoothing reshape significance level
theored1 = s0M * (1-rhoM^2)./(1-(2.*rhoM.*cos(pi.*f./fmax))+rhoM^2);


nw2 = 2; % degree of freedom

% Chi-square inversed distribution
chi90 = theored1 * chi2inv(0.90,nw2);
chi95 = theored1 * chi2inv(0.95,nw2);
chi99 = theored1 * chi2inv(0.99,nw2);
chi999 = theored1 * chi2inv(0.999,nw2);

pth = [pxxsmooth';theored1';chi90';chi95';chi99';chi999'];

if plotn
    figure; 
    set(gcf,'Color', 'white')
    hold on; 
    %semilogy(f,chi999,'g--','LineWidth',1);
    semilogy(f,chi99,'b-.');
    semilogy(f,chi95,'r--','LineWidth',2);
    semilogy(f,chi90,'r-');
    semilogy(f,theored1,'k-','LineWidth',2);
    semilogy(f,pxxsmooth,'m-.');
    semilogy(f,po,'k')
    xlim([0,fmax])
    xlabel('Frequency')
    ylabel('Power')
    smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
    legend( 'Robust AR(1) 99%', 'Robust AR(1) 95%','Robust AR(1) 90%',...
        'Robust AR(1) median',smthwin,'Power')
    set(gca,'XMinorTick','on','YMinorTick','on')
end