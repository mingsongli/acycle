function dayi = monthday2dayi(month,day)
% using month-day input calculate the number of day [1,365]
% INPUT
%   month = 1, 2, ... , 12
%   day = 1, 2, ..., 28 (30 or 31)
% OUTPUT
%   number of day in the year
% Mingsong Li, 2018 Penn State

dayi = 0;
% months = 1:month;
if month == 1
    dayi = day;
else
    for i = 1:month
        if ismember(i,[2,4,6,8,9,11])
            dayi = dayi + 31;
        elseif i == 3
            dayi = dayi + 28;
        elseif ismember(i,[5,7,10,12])
            dayi = dayi + 30;
        end
    end
    dayi = dayi + day;
end
