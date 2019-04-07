function [rho, s0] = minirho(s0,fn,ft,pxxsmooth,linlog,genplot)
% 
% best fit of rho and s0
%
% s0: mean value of power spectrum
% fn: nyquist frequency
% ft: true frequency (a vector from 0 to nyquist frequency)
% pxxsmooth: median-smoothed poser spectrum
% linlog: fit to S(f) or logS(f). 1 = linear; 2 = log (default)
% plot: show 3d best fit plot? 1 = yes; else = no (default)
%
if nargin < 6
    genplot =0;
    if nargin < 5
        linlog = 2;
        if nargin < 4
            error('Error. Too few input arguments.')
        end
    end
end

cospara = cos(pi.*ft./fn);
% Two runs for estimation of rho and s0.
nn = 50;
% first run
rhoi = linspace(0.001,0.999,nn);
disti = zeros(length(rhoi), 1);
for i = 1: nn
    rho0 = rhoi(i);
    %disp(i)
    theored = s0 * (1-rho0^2)./(1-(2.*rho0.*cospara)+rho0^2);
    if linlog == 1
        dist = theored - pxxsmooth;
    else
        dist = log(theored) - log(pxxsmooth);
    end
    disti(i) = (sum(dist.^2));
end
% get indice for rho, and s0 of the minimum distance
x=find(disti == min(disti));
%length(rhoi)

mm = nn/2;

for k = 1:3
    
    % second run
    rhomax = rhoi(x) + (rhoi(2)-rhoi(1));
    rhomin = rhoi(x) - (rhoi(2)-rhoi(1));
    if rhomax >= 1
        rhomax = 0.9999;
    end
    if rhomin <= 0
        rhomin = 0.0001;
    end
    rhoi = linspace(rhomin,rhomax,mm);
    disti = zeros(mm,1);
    
    for i = 1: mm
        rho0 = rhoi(i);
        theored = s0 * (1-rho0^2)./(1-(2.*rho0.*cospara)+rho0^2);
        if linlog == 1
            dist = theored - pxxsmooth;
        else
            dist = log(theored) - log(pxxsmooth);
        end
        disti(i) = sum(dist.^2);
    end
end

x = find(disti==min(disti));
rho = rhoi(x);

if genplot ==1
    figure;
    plot(rhoi,disti);
    xlabel('RHO')
    ylabel('Distance')
    title('Best fit values of rho to the spectrum')
end