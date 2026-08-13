function taperCount = acycleMtmTaperCount(nw)
%ACYCLEMTMTAPERCOUNT Number of Slepian tapers actually used by Acycle MTM.
% PMTM obtains ROUND(2*NW) DPSS vectors and normally drops the last one.
% Acycle retains that last vector only for its supported NW=1 special case.

if ~(isnumeric(nw) && isreal(nw) && isscalar(nw) && ...
        isfinite(nw) && nw > 0)
    error('Acycle:MTM:InvalidTimeBandwidth', ...
        'NW must be a finite positive real numeric scalar.');
end
if nw == 1
    taperCount = round(2*nw);
else
    taperCount = round(2*nw)-1;
end
if taperCount < 1
    error('Acycle:MTM:InsufficientTapers', ...
        'NW does not provide a usable Slepian taper.');
end
end
