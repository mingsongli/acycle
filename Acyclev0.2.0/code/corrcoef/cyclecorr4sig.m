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

function [corry] = cyclecorr4sig(data,targetf,targetp,target,orbit7,rayleigh,sr1,sr2,srstep,sr0,adjust)

lax= target(:,1);  % frequency of target
xx = data(:,1);  % frequency of data
yy = data(:,2);  % power of data
leng_x = sr1:srstep:sr2;  % tested sed. rate series
mpts = length(leng_x);  % tested sed. rates number

corry = zeros(mpts,1);
j=1;
% if test sedimentation rates cover the key sed. rate of sr0
if (sr1 < sr0) && (sr2 > sr0)
    for i = leng_x(leng_x<sr0)
        y=i.*xx/100;
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax,la,y); % greatly increase number of freq.
        [r] = corrcoef(lai,yy);
        if isnan(r(2,1))
            disp(['>> Warning: correlation coefficient is NaN at sed. rate of ',num2str(i)])
        end
        corry(j)=r(2,1);
        j=j+1;
    end
    for k = leng_x(leng_x>=sr0)
        y=k.*xx/100;
        yi = interp1(y,data(:,2),lax);  % decrease number of freq. of data
        la = freq2target(targetf,targetp,lax,k*rayleigh/100);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,k);
            la = targ(:,2);
        end
        [r] = corrcoef(la,yi);
        if isnan(r(2,1))
            disp(['>> Warning: correlation coefficient is NaN at sed. rate of ',num2str(k)])
        end
        corry(j)=r(2,1);
        j=j+1; 
    end
% If all tested sed. rate is larger than the sr0
elseif sr1 >= sr0
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax);
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        [r] = corrcoef(la,yi);
        if isnan(r(2,1))
            disp(['>> Warning: correlation coefficient is NaN at sed. rate of ',num2str(i)])
        end
        corry(j)=r(2,1);
        j=j+1;
    end
% If all tested sed. rate is smaller than the sr0
else
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax,la,y);
        [r] = corrcoef(lai,yy);
        if isnan(r(2,1))
            disp(['>> Warning: correlation coefficient is NaN at sed. rate of ',num2str(i)])
        end
        corry(j)=r(2,1);
        j=j+1;
    end
end