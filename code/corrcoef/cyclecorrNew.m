function [corrx,corry,corrpy,nmi] = ...
    cyclecorrNew(data,dat,pad,theoredML96_pow,target,orbit9,rayleigh,sr1,sr2,srstep,sr0,adjust,method)
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
% Mingsong Li, June 2026
%
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

%orbit9 = orbit9(:,2)/1000;  % year to kyr
%targetf = 1./orbit9;  % 9 orbital frequencies

lax= target(:,1); % frequency of target
% pad
lax_dt = mean(diff(lax));
lax_pad5 = min(lax) : lax_dt : 5 * max(lax);
lax_pad5 = lax_pad5';

xx = data(:,1);  % frequency of data
yy = data(:,2);  % power of data
yy = zscore(yy);
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
        y = i.*xx/100;

        la = freq2targetNew(dat,pad,theoredML96_pow,orbit9,lax_pad5,i); % new
        la = zscore(la);

        nm = norbits([lax_pad5,la],xx,yy,orbit9,rayleigh,i);
        if adjust == 1
            [targ] = targetadj_real([lax_pad5,la],xx,yy,orbit9,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax_pad5,la,y);  % greatly increase number of freq.
        %figure; plot(lax_pad5,la,'k'); hold on; plot(xx,yy,'r'); title(['black: target; red: data @ ',num2str(i),' cm/kyr']); 
        [corry(j),corrpy(j)] = corrFinitePairs(lai,yy,method);
        nmi(j) = nm;
        j=j+1;
    end

    for i = leng_x(leng_x>=sr0)

        y=i.*xx/100;
        yi = interp1(y,data(:,2),lax); % decrease number of freq. of data
        yi = zscore(yi);
        la = freq2targetNew(dat,pad,theoredML96_pow,orbit9,lax,i); % new
        la = zscore(la);
        nm = norbits([lax,la],xx,yy,orbit9,rayleigh,i);
        %figure; plot(lax_pad5,la,'k'); hold on; plot(xx,yi,'r-'); title(['black: target; red: data @ ',num2str(i),' cm/kyr']); 
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit9,rayleigh,i);
            la = targ(:,2);
        end
        
        [corry(j),corrpy(j)] = corrFinitePairs(la,yi,method);
        nmi(j) = nm;
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

        %figure; plot(lax_pad5,la,'k'); hold on; plot(xx,yi,'r-'); title(['black: target; red: data @ ',num2str(i),' cm/kyr']); 
        nm = norbits([lax,la],xx,yy,orbit9,rayleigh,i);
        if adjust == 1
            [targ] = targetadj_real([lax,la],xx,yy,orbit9,rayleigh,i);
            la = targ(:,2);
        end
        [corry(j),corrpy(j)] = corrFinitePairs(la,yi,method);
        nmi(j) = nm;
        j=j+1;
    end

% If all tested sed. rate is smaller than the sr0
else
    for i = sr1:srstep:sr2
        y=i.*xx/100;
        la = freq2targetNew(dat,pad,theoredML96_pow,orbit9,lax_pad5,i); % new
        la = zscore(la);
        
        nm = norbits([lax_pad5,la],xx,yy,orbit9,rayleigh,i);
        if adjust == 1
            [targ] = targetadj_real([lax_pad5,la],xx,yy,orbit9,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax_pad5,la,y);
        %figure; plot(lax_pad5,la,'k'); hold on; plot(xx,yy,'r-'); title(['black: target; red: data @ ',num2str(i),' cm/kyr']); 

        [corry(j),corrpy(j)] = corrFinitePairs(lai,yy,method);
        nmi(j) = nm;
        j=j+1;
    end
end

corrx = linspace(sr1,sr2,j-1);
corrx = corrx';

function [rho,pval] = corrFinitePairs(x,y,method)
rho = NaN;
pval = NaN;
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
    [r,p] = corrcoef(x,y);
    if numel(r) >= 4
        rho = r(2,1);
        pval = p(2,1);
    end
else
    [rho,pval] = corr(x,y,'type','Spearman');
end
