function [groupPower,bestResidual] = cocoNonnegativeLeakageSolve( ...
        mixingMatrix,dataEnergy)
%COCONONNEGATIVELEAKAGESOLVE Exact four-variable nonnegative least squares.
%
% GROUPPOWER = COCONONNEGATIVELEAKAGESOLVE(M,E) solves
%       min_{q >= 0} ||M*q-E||_2
% for a finite nonnegative 4-by-4 leakage matrix M and one or more
% four-row energy vectors E.  All 2^4 active sets are enumerated, making the
% small problem deterministic and vectorized over Monte Carlo columns.

validateattributes(mixingMatrix,{'numeric'}, ...
    {'2d','size',[4,4],'real','finite','nonnegative'}, ...
    mfilename,'mixingMatrix',1);
validateattributes(dataEnergy,{'numeric'}, ...
    {'2d','nrows',4,'real','finite','nonnegative','nonempty'}, ...
    mfilename,'dataEnergy',2);

nSeries = size(dataEnergy,2);
columnScale = max(dataEnergy,[],1);
columnScale(~isfinite(columnScale) | columnScale <= 0) = 1;
scaledEnergy = dataEnergy./columnScale;
groupPowerScaled = zeros(4,nSeries,'like',dataEnergy);
bestResidual = sum(scaledEnergy.^2,1);
if any(~isfinite(bestResidual))
    error('cocoNonnegativeLeakageSolve:InvalidEnergyScale', ...
        'Energy scaling produced a nonfinite residual.');
end

for activeCode = 1:15
    active = logical(bitget(activeCode,1:4));
    design = mixingMatrix(:,active);
    if rank(design) < nnz(active)
        continue
    end
    candidateActive = design\scaledEnergy;
    feasibilityTolerance = 256*eps(class(dataEnergy)) .* ...
        max(1,max(abs(candidateActive),[],1));
    feasible = all(candidateActive >= -feasibilityTolerance,1);
    if ~any(feasible)
        continue
    end
    candidateActive = max(candidateActive,0);
    residual = sum((design*candidateActive-scaledEnergy).^2,1);
    better = feasible & isfinite(residual) & residual < bestResidual;
    if any(better)
        groupPowerScaled(:,better) = 0;
        groupPowerScaled(active,better) = candidateActive(:,better);
        bestResidual(better) = residual(better);
    end
end

if any(~isfinite(bestResidual))
    error('cocoNonnegativeLeakageSolve:NonfiniteResidual', ...
        'No finite nonnegative least-squares residual was found.');
end
groupPower = groupPowerScaled.*columnScale;
if any(~isfinite(groupPower),'all') || any(groupPower < 0,'all')
    error('cocoNonnegativeLeakageSolve:InvalidSolution', ...
        'The nonnegative leakage solution is nonfinite or negative.');
end
end
