% This calculate corr using different target with different rayleigh frequencies.
% INPUT
%   data:  2 column 
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
%   nmi: if adjust target to real data for their power; then number of
%        Milankovitch forcing not involved will be recored in nmi
% EXAMPLE
%
% Mingsong Li, May 2017

function [corrx,corry,corrpy,nmi] = cyclecorr_rank(data,targetf,targetp,target,orbit7,rayleigh,sr1,sr2,srstep,sr0,adjust)

lax= target(:,1);
xx = data(:,1);
yy = data(:,2);

leng_x = sr1:srstep:sr2;
mpts = length(leng_x);

corry = zeros(mpts,1);
corrpy = zeros(mpts,1);
nmi = zeros(mpts,1);

j=1;
% if test sedimentation rates cover the key sed. rate of sr0
if (sr1 < sr0) && (sr2 > sr0)
    for i = sr1:srstep:sr0
        y=i.*xx/100;
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        [targ,nm] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
        if adjust == 1
            la = targ(:,2);
        end
        lai = interp1(lax,la,y);
        [r,p] = corr(lai,yy,'type', 'Spearman');
        corry(j)=r;
        corrpy(j)=p;
        nmi(j) = nm;
        j=j+1;
    end
    for i = sr0:srstep:sr2
        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax);
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        [targ,nm] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
        if adjust == 1
            la = targ(:,2);
        end
        [r,p] = corr(la,yi,'type', 'Spearman');
        corry(j)=r;
        corrpy(j)=p;
        nmi(j) = nm;
        j=j+1;
    end
% If all tested sed. rate is larger than the sr0
elseif sr1 >= sr0
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax);
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        [targ,nm] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
        if adjust == 1
            la = targ(:,2);
        end
%         if adjust == 1; figure; plot(targ(:,1),la); hold on; plot(targ(:,1),yi);hold off; else
%         figure; plot(lax,la); hold on; plot(lax,yi);hold off; end
        [r,p] = corr(la,yi,'type', 'Spearman');
        corry(j)=r;
        corrpy(j)=p;
        nmi(j) = nm;
        j=j+1;
    end
% If all tested sed. rate is smaller than the sr0
else
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        [targ,nm] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
        if adjust == 1
            la = targ(:,2);
        end
        lai = interp1(lax,la,y);
        [r,p] = corr(lai,yy,'type', 'Spearman');
        corry(j)=r;
        corrpy(j)=p;
        nmi(j) = nm;
        j=j+1;
    end
end
corrx = linspace(sr1,sr2,j-1);
corrx = corrx';