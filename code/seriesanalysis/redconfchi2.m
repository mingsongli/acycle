function [f,p,theored,chi90,chi95,chi99,chi999]=redconfchi2(datax,nw,dt,pad,method)
% Calls for 
%   rhoAR1
%   
% Doroth?e Husson, december 2012
% Mingsong Li, 2017
% Calculate rho for AR(1). Estimate 90%, 95%, 99%, and 99.9% CI.
% Updated Nov 5, 2021
% Mingsong Li
% Peking Univeristy

rho = rhoAR1(datax);
fnyq = 1/(2*dt);
if method == 1  
    % periodogram method
    [p,f] = periodogram(datax,[],pad,1/dt);
    meanp = mean(p);
elseif method == 2
    % pmtm method
    if nw == 1
        [p,w]=pmtm(datax,nw,pad,'DropLastTaper',false);
    else
        [p,w] = pmtm(datax,nw,pad);
    end
    f = w/(2*pi*dt);
    meanp = mean(p);
else
    
end

theored=(1-rho^2)./(1-(2.*rho.*cos(pi.*f./fnyq))+rho^2);
theoredun=theored(1);
theored(1)=0;
Art=mean(theored);
theored(1)=theoredun;
theored=theored*(meanp/Art);

K = 2*nw -1;
nw2 = 2*(K);
% Chi-square inversed distribution
chi90 = theored * chi2inv(0.90,nw2)/nw2;
chi95 = theored * chi2inv(0.95,nw2)/nw2;
chi99 = theored * chi2inv(0.99,nw2)/nw2;
chi999 = theored * chi2inv(0.999,nw2)/nw2;