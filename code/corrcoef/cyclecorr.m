function [corrx,corry,corrpy,nmi] = ...
    cyclecorr(data,targetf,targetp,target,orbit7,rayleigh,sr1,sr2,srstep,sr0,adjust,method)
% Calculate corr using different target with different rayleigh frequencies.
% modified from cyclecorr4.m
% INPUT
%   data: a real power spectrum series, 2 column of frequency-power
%   targetf, targetp: 1 column series of power and frequency of peaks in target  
%   target: target power spectrum series, 2 column of frequency-power
%   rayleigh:  rayleigh frequency of real data in cycles/m.
%   sr1: tested sedimentation rate - start, unit: cm/kyr
%   sr2: tested sedimentation rate - end, unit, cm/kyr
%   srstep: tested sedimentatio rate - step, unit, cm/kyr
%   sr0: key sedimentation rate
%   adjust: adjust power
%
% OUTPUT
%   corrx: 
%   corry:
%   corrpy:
%   corrlo:
%   corrup:
%   nmi: if adjust target to real data for their power; then number of
%        Milankovitch forcing not involved will be recored in nmi
% EXAMPLE
%
% Mingsong Li, May 2017
if nargin > 12
    error('Too many input arguments in cyclecorr.m')
elseif nargin < 12
    method = 'Pearson';
    if nargin < 11
        adjust = 0;
        if nargin < 10
            error('Too few input arguments')
        end
    end
end

lax= target(:,1); % frequency of target
xx = data(:,1);  % frequency of data
yy = data(:,2);  % power of data
leng_x = sr1:srstep:sr2;  % tested sed. rate series
mpts = length(leng_x);  % tested sed. rates number

% Set empty vector for corry, corrpy, corrlo, corrup, and nmi
corry = zeros(mpts,1);
corrpy = zeros(mpts,1);
nmi = zeros(mpts,1);

j=1;
% if test sedimentation rates cover the key sed. rate of sr0
if (sr1 < sr0) && (sr2 > sr0)
    for i = leng_x(leng_x<sr0)
        y=i.*xx/100;
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        nm = norbits([lax,la],xx,yy,orbit7,rayleigh,i);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax,la,y);  % greatly increase number of freq.
        if strcmp(method,'Pearson')
            [r,p] = corrcoef(lai,yy);
            corry(j)=r(2,1);
            corrpy(j)=p(2,1);
        else
            [corry(j),corrpy(j)] = corr(lai,yy,'type', 'Spearman');
        end
        nmi(j) = nm;
        j=j+1;
    end
    for k = leng_x(leng_x>=sr0)
        y=k.*xx/100;
        yi = interp1(y,data(:,2),lax); % decrease number of freq. of data
        la = freq2target(targetf,targetp,lax,k*rayleigh/100);
        nm = norbits([lax,la],xx,yy,orbit7,rayleigh,k);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,k);
            la = targ(:,2);
        end
        if strcmp(method,'Pearson')
            [r,p] = corrcoef(la,yi);
            corry(j)=r(2,1);
            corrpy(j)=p(2,1);
        else
            [corry(j),corrpy(j)] = corr(la,yi,'type', 'Spearman');
        end
        nmi(j) = nm;
        j=j+1;
    end
% If all tested sed. rate is larger than the sr0
elseif sr1 >= sr0
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax);
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        nm = norbits([lax,la],xx,yy,orbit7,rayleigh,i);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
            la = targ(:,2);
        end
%         if adjust == 1; figure; plot(targ(:,1),la); hold on; plot(targ(:,1),yi);hold off; else
%         figure; plot(lax,la); hold on; plot(lax,yi);hold off; end
        if strcmp(method, 'Pearson')
            [r,p] = corrcoef(la,yi);
            corry(j)=r(2,1);
            corrpy(j)=p(2,1);
        else
            [corry(j),corrpy(j)] = corr(la,yi,'type', 'Spearman');
        end
        nmi(j) = nm;
        j=j+1;
    end
% If all tested sed. rate is smaller than the sr0
else
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        nm = norbits([lax,la],xx,yy,orbit7,rayleigh,i);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax,la,y);
        if strcmp(method, 'Pearson')
            [r,p] = corrcoef(lai,yy);
            corry(j)=r(2,1);
            corrpy(j)=p(2,1);
        else
            [corry(j),corrpy(j)] = corr(lai,yy,'type', 'Spearman');
        end
        nmi(j) = nm;
        j=j+1;
    end
end
corrx = linspace(sr1,sr2,j-1);
corrx = corrx';