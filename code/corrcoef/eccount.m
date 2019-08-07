function [eccounts] = eccount(srn,ecc,eci,ecoco,enorb)
%function [eccounts] = eccount(srn,ecc,eci,ecoco,ecocorb)
% for a given srn (sedimentation maps, a nrow x ncol matrix)
% INPUT:
%   srn:    sedimentation maps, a nrow x ncol matrix; nrow can be 1
%   ecc:    correlation coefficient
%   eci:    correlation coefficient confidence interval
%   ecoco:  correlation coefficient x confidence interval
%   ecocorb:    correlation coefficient x confidence interval x #orbits
% OUTPUT
% to estimate eccounts:
%   ecsrn_mean: sed. rate mean of non-NaN value of each row
%   ecsrn_median: sed. rate median non-NaN value of each row
%   ecsrn_n: number of non-NaN value of each row
%   eccsum: correlation coefficient of non-NaN value of each row
%   ecisum: correlation coefficient confidence interval of non-NaN value of each row
%   ecocosum: correlation coefficient x confidence interval of non-NaN value of each row
%   ecocorbsum: correlation coefficient x confidence interval x #orbits of non-NaN value of each row
% Mingsong Li, June 2017.
%
[nrow, ncol] = size (srn);
ecsrn_n = zeros(nrow,1);
ecsrn_mean = zeros(nrow,1);
ecsrn_median = zeros(nrow,1);
eccsum = zeros(nrow,1);
ecisum = zeros(nrow,1);
ecocosum = zeros(nrow,1);
enorbsum = zeros(nrow,1);

for i=1:nrow
    srni = srn(i,:);
    srninan = srni(~isnan(srni));
    ecsrn_n(i) = length(srninan);
    ecsrn_mean(i) = mean(srninan);
    ecsrn_median(i) = median(srninan);
    for j = 1:ncol
        if isnan(srni(j))
        else
            eccsum(i) = ecc(srni(j),j) + eccsum(i);
            ecisum(i) = eci(srni(j),j) + ecisum(i);
            ecocosum(i) = ecoco(srni(j),j) + ecocosum(i);
            enorbsum(i) = enorb(srni(j),j) + enorbsum(i);
        end
    end
end

eccounts = [ecsrn_mean,ecsrn_median,ecsrn_n,eccsum./ecsrn_n,ecisum./ecsrn_n,ecocosum,enorbsum];