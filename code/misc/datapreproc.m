function dat = datapreproc(target,qwarn)
if nargin<2; qwarn=1; end
% prep data
dat = target(~any(isnan(target),2),:);
% check NaN
datx = dat(:,1); 

if length(target(:,1)) > length(datx)
    if qwarn==1
        warndlg('Data: NaN numbers removed.')
        disp('>>  ==========        removing NaNs')
    end
end
% check empty
dat(any(isinf(dat),2),:) = [];
if length(dat(:,1)) < length(datx)
    if qwarn==1
        warndlg('Data: Empty numbers removed.')
        disp('>>  ==========        removing empty numbers')
    end
end
% check order
diffx = diff(dat(:,1));
if any(diffx(:) < 0)
    if qwarn==1
         warndlg('Data: Not sorted. Sorted.')
         disp('>>  ==========        sorted')
    end
     dat = sortrows(dat);
end
% duplicate
diffx = diff(dat(:,1));
if any(diffx(:) == 0)
    if qwarn==1
         warndlg('Data: duplicated numbers are replaced with the mean')
         disp('>>  ==========        duplicate numbers were replaced by the mean value')
    end
     dat=findduplicate(dat);
end
% interpolation
diffx = diff(dat(:,1));
sr_target = median(diff(dat(:,1)));
if nanmax(diffx) - nanmin(diffx) > eps('single')
    if qwarn==1
        warndlg('Data may not be evenly spaced. Interpolation using median sampling rate. Done !')
        disp('>>  ==========        interpolation using median sampling rate')
    end
    dat = interpolate(dat,sr_target);
end