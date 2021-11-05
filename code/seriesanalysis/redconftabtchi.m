function [f,p,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconftabtchi(datax,nw,dt,pad,method)
% Calls for 
%   rhoAR1
%   
% Doroth?e Husson, december 2012
% Mingsong Li, 2017
% Calculate rho for AR(1). Estimate 90% CI.
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

% gammaincinv
% The degrees of freedom for MTM is equal to 2*number of tapers;
% since DropLastTaper=true, then number of tapers=2*nw-1
% By Linda Hinnov , June, 2017
nw2=2*(2*nw-1);
facchi90 = 2 * gammaincinv(0.90,nw)/(nw2);
facchi95 = 2 * gammaincinv(0.95,nw)/(nw2);
facchi99 = 2 * gammaincinv(0.99,nw)/(nw2);
facchi999 = 2 * gammaincinv(0.999,nw)/(nw2);
tabtchi90 = theored*facchi90;
tabtchi95 = theored*facchi95;
tabtchi99 = theored*facchi99;
tabtchi999 = theored*facchi999;