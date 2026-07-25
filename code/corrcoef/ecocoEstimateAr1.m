function [rho,dataStd,valid] = ecocoEstimateAr1(values)
%ECOCOESTIMATEAR1 Column-wise conditional AR(1) estimates for eCOCO.
%
% [RHO,DATASTD,VALID] = ECOCOESTIMATEAR1(VALUES) linearly detrends every
% column, estimates x(t)=rho*x(t-1)+epsilon(t) by conditional least
% squares, and returns the resolved detrended standard deviation used to
% scale stationary Gaussian nulls.  Invalid/affine-only columns are marked
% false rather than silently repaired.

validateattributes(values,{'numeric'},{'2d','real','nonempty'}, ...
    mfilename,'values',1);

nSeries = size(values,2);
rho = nan(1,nSeries);
dataStd = nan(1,nSeries);
valid = false(1,nSeries);
for column = 1:nSeries
    original = values(:,column);
    if numel(original) < 4 || any(~isfinite(original))
        continue
    end
    x = detrend(original,1);
    [resolved,sigma] = cocoResolvedDetrendedVariance(original,x);
    if ~resolved || ~isfinite(sigma) || sigma <= 0
        continue
    end
    scale = max(abs(x));
    if ~isfinite(scale) || scale <= 0
        continue
    end
    scaled = x./scale;
    previous = scaled(1:end-1);
    following = scaled(2:end);
    denominator = previous'*previous;
    if ~isfinite(denominator) || denominator <= 0
        continue
    end
    estimate = (previous'*following)/denominator;
    if ~isfinite(estimate) || ~isreal(estimate)
        continue
    end
    rho(column) = min(max(real(estimate),-0.999),0.999);
    dataStd(column) = sigma;
    valid(column) = true;
end
end
