function perct = findperct(va,m)
% find percentile of a single value in a vector m
% INPUT
%   va: a single value
%   m: a vector series
% OUTPUT
%   p: percentile value
% by Mingsong Li, Dec. 25, 2017

m = sort(m);
mv = m(m<va);
lengthm = length(m(~isnan(m)));
perct = (lengthm-length(mv))/lengthm;