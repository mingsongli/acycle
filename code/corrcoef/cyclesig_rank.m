% This calculates corr using different target with different rayleigh frequencies.
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

function [corry] = cyclesig_rank(data,targetf,targetp,target,orbit7,rayleigh,sr1,sr2,srstep,sr0,adjust)

lax= target(:,1);
xx = data(:,1);
yy = data(:,2);

leng_x = sr1:srstep:sr2;
mpts = length(leng_x);

corry = zeros(mpts,1);
j=1;
% cover trun sed.rate point sr0
if (sr1 < sr0) && (sr2 > sr0)
    for i = sr1:srstep:sr0
        y=i.*xx/100;
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
        [targ,~] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
        la = targ(:,2);
        end
        lai = interp1(lax,la,y);
        [r] = corr(lai,yy,'type', 'Spearman');
        corry(j)=r;
        j=j+1;
    end
    for i = sr0:srstep:sr2
        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax);
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
        [targ,~] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
        la = targ(:,2);
        end
        [r] = corr(la,yi,'type', 'Spearman');
        corry(j)=r;
        j=j+1;
    end
% All is larger than sr0
elseif sr1 >= sr0
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax);
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
        [targ,~] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
        la = targ(:,2);
        end
        [r] = corr(la,yi,'type', 'Spearman');
        corry(j)=r;
        j=j+1;
    end
% All is smaller than sr0
else
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
        [targ,~] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
        la = targ(:,2);
        end
        lai = interp1(lax,la,y);
        [r] = corr(lai,yy,'type', 'Spearman');
        corry(j)=r;
        j=j+1;
    end
end