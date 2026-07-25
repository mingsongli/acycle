function [data,info] = cocoPublicationPrepareData(rawData,label)
%COCOPUBLICATIONPREPAREDATA Audited full-record preprocessing for Adaptive COCO.
%
% [DATA,INFO] = COCOPUBLICATIONPREPAREDATA(RAWDATA,LABEL) removes rows
% whose first two columns are nonfinite, sorts by depth, averages duplicate
% proxy values at identical depths, and, only when necessary, linearly
% interpolates onto a grid defined by the median positive depth increment.
% DATA is therefore suitable for CORRCOEFSLICES_RANKNEW.  The complete
% operation is described in INFO.  If interpolation is performed, its
% parameters are printed in English to the Command Window.

if nargin < 2 || strlength(string(label)) == 0
    label = 'Adaptive COCO input';
end

% Publication workflows and interactive full-record COCO/eCOCO now share
% one implementation, including the same uniformity tolerance.  Preserve
% the historical METHOD text because it is stored in existing manifests.
[data,info] = cocoPrepareRegularData(rawData,label, ...
    'MaximumPoints',1e6,'MinimumPoints',4,'Verbose',true);
info.method = 'sort; mean duplicate values; conditional linear interpolation';
end
