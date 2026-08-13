function [column,powerMean] = dynotIterationWorker( ...
        data,yGrid,sample,window,nw,targetBands,options)
%DYNOTITERATIONWORKER Evaluate one deterministic DYNOT realization.
%   This standalone worker is shared by serial and PARFEVAL execution so
%   enabling the Process-panel core setting cannot change the calculation.

coordinates = (data(1,1):sample:data(end,1)).';
dat = [coordinates,interp1( ...
    data(:,1),data(:,2),coordinates,'pchip')];
trend = polyfit(dat(:,1),dat(:,2),1);
dat(:,2) = dat(:,2)-polyval(trend,dat(:,1));
if options.padwin > 0
    dat = zeropad2(dat,window,options.padwin);
end
power = pdan(dat,targetBands,window,nw, ...
    options.ftmin,options.ftmax,options.step,options.pad);
column = interp1(power(:,1),power(:,2),yGrid);
values = power(:,2);
powerMean = mean(values(~isnan(values)));
end
