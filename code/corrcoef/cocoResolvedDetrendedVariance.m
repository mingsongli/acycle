function [resolved,residualStd,relativeResidualRms,tolerance] = ...
        cocoResolvedDetrendedVariance(originalValues,detrendedValues)
%COCORESOLVEDDETRENDedVARIANCE Test variance after linear detrending.
%
% Exact constant or affine input can leave nonzero roundoff after DETREND.
% Testing STD(residual)>0 therefore accepts numerically meaningless spectra.
% This scale-aware test compares residual RMS with the magnitude of the
% original stored values.  A residual must exceed 256 floating-point eps
% relative to that magnitude.  The same rule is used by cvCOCO, Adaptive
% COCO, and their Monte Carlo preprocessing.

validateattributes(originalValues,{'numeric'}, ...
    {'vector','real','finite','nonempty'},mfilename,'originalValues',1);
validateattributes(detrendedValues,{'numeric'}, ...
    {'vector','real','finite','numel',numel(originalValues)}, ...
    mfilename,'detrendedValues',2);

originalValues = originalValues(:);
detrendedValues = detrendedValues(:);
n = numel(detrendedValues);
tolerance = 256*eps(class(detrendedValues));
referenceScale = max(abs(originalValues));
residualScale = max(abs(detrendedValues));
resolved = false;
residualStd = 0;
relativeResidualRms = 0;
if n < 2 || referenceScale <= 0 || residualScale <= 0
    return
end

scaledResidual = detrendedValues./residualScale;
scaledEnergy = sum(scaledResidual.^2);
if ~isfinite(scaledEnergy) || scaledEnergy <= 0
    return
end
relativeResidualRms = (residualScale/referenceScale) * ...
    sqrt(scaledEnergy/n);
residualStd = residualScale*sqrt(scaledEnergy/(n-1));
resolved = isfinite(relativeResidualRms) && ...
    relativeResidualRms > tolerance && ...
    isfinite(residualStd) && residualStd > 0;
end
