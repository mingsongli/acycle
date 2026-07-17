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

validateattributes(s0,{'numeric'},{'scalar','real','finite','positive'}, ...
    mfilename,'s0',1);
validateattributes(fn,{'numeric'},{'scalar','real','finite','positive'}, ...
    mfilename,'fn',2);
validateattributes(ft,{'numeric'},{'vector','real','finite','nonempty'}, ...
    mfilename,'ft',3);
validateattributes(pxxsmooth,{'numeric'}, ...
    {'vector','real','finite','positive','numel',numel(ft)}, ...
    mfilename,'pxxsmooth',4);
if ~ismember(linlog,[1,2])
    error('minirhos0:InvalidScale','LINLOG must be 1 (linear) or 2 (log).');
end
cospara = cos(pi.*ft(:)./fn);
pxxsmooth = pxxsmooth(:);
% Two runs for estimation of rho and s0.  The former nested implementation
% rebuilt an N-frequency theoretical spectrum for every point in the
% rho-by-S0 grid.  The squared distance separates algebraically into
% sufficient sums for each rho, so the identical discrete search can be
% evaluated as a small matrix without changing its candidate grids.
nn = 50;
rhoi = linspace(0.001,0.999,nn);
s0i = linspace(0.2*s0,5*s0,nn);
disti = distanceGrid(rhoi,s0i,cospara,pxxsmooth,linlog);
[x,y] = firstMinimum(disti);
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
    
    disti = distanceGrid(rhoi,s0i,cospara,pxxsmooth,linlog);
    [x,y] = firstMinimum(disti);

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
end

function distance = distanceGrid(rhoGrid,s0Grid,cospara,power,linlog)
rhoGrid = rhoGrid(:)';
s0Grid = s0Grid(:)';
denominator = 1-2*cospara.*rhoGrid+rhoGrid.^2;
shape = (1-rhoGrid.^2)./denominator;
if any(~isfinite(shape) | shape <= 0,'all') || ...
        any(~isfinite(s0Grid) | s0Grid <= 0)
    error('minirhos0:InvalidCandidate', ...
        'The rho/S0 search produced a nonpositive theoretical spectrum.');
end
if linlog == 1
    shapeSquareSum = sum(shape.^2,1)';
    shapePowerSum = (shape'*power);
    powerSquareSum = sum(power.^2);
    distance = shapeSquareSum.*(s0Grid.^2) ...
        -2*shapePowerSum.*s0Grid+powerSquareSum;
else
    baseResidual = log(shape)-log(power);
    residualSum = sum(baseResidual,1)';
    residualSquareSum = sum(baseResidual.^2,1)';
    logScale = log(s0Grid);
    distance = residualSquareSum+2*residualSum.*logScale ...
        +numel(power).*(logScale.^2);
end
% Roundoff in the expanded linear SSE may create a tiny negative value;
% distances are mathematically nonnegative and only their ordering matters.
negativeTolerance = 256*eps(max(1,max(abs(distance),[],'all')));
distance(distance < 0 & distance >= -negativeTolerance) = 0;
if any(~isfinite(distance),'all') || any(distance < 0,'all')
    error('minirhos0:InvalidDistance', ...
        'The rho/S0 search produced an invalid squared distance.');
end
end

function [row,column] = firstMinimum(distance)
[~,linearIndex] = min(distance(:));
[row,column] = ind2sub(size(distance),linearIndex);
end
