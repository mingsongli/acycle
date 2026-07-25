% This calculates corrcoef using different target with different rayleigh frequencies.
% INPUT
%   data
%   targetnew
%   rayleigh  rayleigh frequency of real data in cycles/m.
%   sr1
%   m
%   step
%
% OUTPUT
%   corrx
%   corry
%   yin
%
% EXAMPLE
%
%     sr1 = 2;
%     sr2 = 40;
%     srstep = .2;
%
% Mingsong Li, May 2017

function [corry] = cyclecorrsigNew(data,dat,pad,theoredML96_pow,target,orbit9,rayleigh,sr1,sr2,srstep,sr0,adjust,method)

% if nargin > 12
%     error('Too many input arguments in cyclecorr.m')
% elseif nargin < 12
%     method = 'Pearson';
%     if nargin < 11
%         adjust = 0;
%         if nargin < 10
%             error('Too few input arguments')
%         end
%     end
% end

lax= target(:,1);  % frequency of target
% pad
lax_dt = mean(diff(lax));
lax_pad5 = min(lax) : lax_dt : 5 * max(lax);
lax_pad5 = lax_pad5';


xx = data(:,1);  % frequency of data
yy = data(:,2);  % power of data
yy = zscore(yy);

leng_x = sr1:srstep:sr2;  % tested sed. rate series
mpts = length(leng_x);  % tested sed. rates number

corry = zeros(mpts,1);

j=1;

% if test sedimentation rates cover the key sed. rate of sr0
if (sr1 < sr0) && (sr2 > sr0)
    for i = leng_x(leng_x<sr0)
        y=i.*xx/100;

        la = freq2targetNew(dat,pad,theoredML96_pow,orbit9,lax_pad5,i); % new
        la = zscore(la); % new

        if adjust == 1
            [targ] = targetadj_real([lax_pad5,la],xx,yy,orbit9,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax_pad5,la,y); % greatly increase number of freq.
        
        corry(j) = corrFinitePairs(lai,yy,method);
        if isnan(corry(j))
          disp(['>> Warning: correlation coefficient is NaN at sed. rate of ',num2str(i)])
        end
        j=j+1;
    end

    for i = leng_x(leng_x>=sr0)
        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax);  % decrease number of freq. of data
        yi = zscore(yi);
        la = freq2targetNew(dat,pad,theoredML96_pow,orbit9,lax,i); % new
        la = zscore(la);% new
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit9,rayleigh,i);
            la = targ(:,2);
        end
        corry(j) = corrFinitePairs(la,yi,method);
        if isnan(corry(j))
            disp(['>> Warning: correlation coefficient is NaN at sed. rate of ',num2str(i)])
        end
        j=j+1; 
    end

% If all tested sed. rate is larger than the sr0
elseif sr1 >= sr0
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax);
        yi = zscore(yi);

        la = freq2targetNew(dat,pad,theoredML96_pow,orbit9,lax,i); % new
        la = zscore(la);

        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit9,rayleigh,i);
            la = targ(:,2);
        end
        corry(j) = corrFinitePairs(la,yi,method);
        if isnan(corry(j))
            disp(['>> Warning: correlation coefficient is NaN at sed. rate of ',num2str(i)])
        end
        j=j+1;
    end

% If all tested sed. rate is smaller than the sr0
else
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        la = freq2targetNew(dat,pad,theoredML96_pow,orbit9,lax_pad5,i); % new
        la = zscore(la);

        if adjust == 1
            [targ] = targetadj_real([lax_pad5,la],xx,yy,orbit9,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax_pad5,la,y);

        corry(j) = corrFinitePairs(lai,yy,method);
        if isnan(corry(j))
            disp(['>> Warning: correlation coefficient is NaN at sed. rate of ',num2str(i)])
        end
        j=j+1;
    end
end

function rho = corrFinitePairs(x,y,method)
rho = NaN;
x = x(:);
y = y(:);
if numel(x) ~= numel(y)
    return
end
ok = isfinite(x) & isfinite(y);
x = x(ok);
y = y(ok);
if numel(x) < 2 || std(x) == 0 || std(y) == 0
    return
end
if strcmp(method,'Pearson')
    r = corrcoef(x,y);
    if numel(r) >= 4
        rho = r(2,1);
    end
else
    rho = corr(x,y,'type','Spearman');
end
