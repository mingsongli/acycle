
function [mm,dd] = mmdd2dayi(doy)
% Function, estimate month-date for a given day of year
% [mm,dd] = mmdd2dayi(32)
%   will get mm = 2, dd = 1; Feb 1.
% Online resource: 
% https://www.mathworks.com/matlabcentral/answers/49021-converting-day-of-year-to-month-and-day
dayspermonth = [0 31 28 31 30 31 30 31 31 30 31 30 31];
mm = ones(size(doy))*NaN;
dd = ones(size(doy))*NaN;
for im = 1:12
   I = find(doy > sum(dayspermonth(1:im)) & doy <= sum(dayspermonth(1:im+1)));
   mm(I) = ones(size(I)).*im;
   dd(I) = doy(I) - ones(size(I))*sum(dayspermonth(1:im));
end