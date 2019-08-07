function [rho, s0] = minirhos0(s0,fn,ft,pxxsmooth,linlog,genplot)
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
    genplot = 0;
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
s0i = linspace(0.2*s0, 5*s0,nn);
disti = zeros(length(rhoi), length(s0i));

for i = 1: nn
    rho0 = rhoi(i);
    %disp(i)
    for j = 1: nn
        s0j = s0i(j);
        theored = s0j * (1-rho0^2)./(1-(2.*rho0.*cospara)+rho0^2);
        if linlog == 1
            dist = theored - pxxsmooth;
        else
            dist = log(theored) - log(pxxsmooth);
        end
        disti(i,j) = (sum(dist.^2));
    end
end
% get indice for rho, and s0 of the minimum distance
[x,y]=find(disti==min(min(disti)));
rho = rhoi(x);
s0 = s0i(y);
%disp([rho s0])
if genplot == 1
    [X,Y] = meshgrid(rhoi,s0i);
    figure;
    surf(X,Y,disti)
    xlabel('rho')
    ylabel('s0')
    title('Best fit values of rho and S0 to the median-smoothed spectrum')
    shading flat
end

mm = nn/2;
% second run
for k= 1:3
    s0imax = s0i(y) + (s0i(2) - s0i(1));
    s0imin = s0i(y) - (s0i(2) - s0i(1));
    rhomax = rhoi(x) + (rhoi(2)-rhoi(1));
    rhomin = rhoi(x) - (rhoi(2)-rhoi(1));
    if rhomax >= 1
        rhomax = 0.9999;
    end
    if rhomin <= 0
        rhomin = 0.0001;
    end
    rhoi = linspace(rhomin,rhomax,mm);
    s0i = linspace(s0imin, s0imax,mm);
    
    disti = zeros(mm,mm);
    for i = 1: mm
        rho0 = rhoi(i);
        for j = 1: mm
            s0j = s0i(j);
            theored = s0j * (1-rho0^2)./(1-(2.*rho0.*cospara)+rho0^2);
            if linlog == 1
                dist = theored - pxxsmooth;
            else
                dist = log(theored) - log(pxxsmooth);
            end
            disti(i,j) = (sum(dist.^2));
        end
    end
    [x,y]=find(disti==min(min(disti)));

rho = rhoi(x);
s0 = s0i(y);

%disp([rho s0])
if genplot == 1
    [X,Y] = meshgrid(rhoi,s0i);
    figure;
    surf(X,Y,disti)
    xlabel('rho')
    ylabel('s0')
    title('Best fit values of rho and S0 to the median-smoothed spectrum')
    shading flat
    %zlim([min(min(disti)),1.2*min(min(disti))])
end
end