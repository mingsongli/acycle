% Modified from cyclecorr3, but using a target with changing rayleigh resolution with
% sedimentation rate.
%
% INPUT
%   xx: 1 column frequencies (cycles/m)
%   yy: 1 column power
%   targetf:    1 column, significant frequencies with high power
%   targetp:    1 column, power of significant frequencies
%   lax: target-1 column frequency (cycles/kyr)
%   rayleigh: frequency (1/total_time)
%   sr1  
%   sr2
%   srstep: sedimentation rates to be evaluted
%   sr0: shreshold frequency
%   adjust: 1 =  adjust target power to real power
%
% OUTPUT
%   corrx
%   corry
%   yin
% EXAMPLE
%
%     sr1 = 2;
%     sr2 = 40;
%     srstep = .2;
%
% Mingsong Li, May 2017

function [corry] = cyclecorr5(xx,yy,targetf,targetp,lax,orbit7,rayleigh,sr1,sr2,srstep,sr0,adjust)
sri = sr1:srstep:sr2;
sri = sri';
corry = zeros(length(sri),length(yy(1,:)));
% cover trun sed.rate point sr0
if (sr1 < sr0) && (sr2 > sr0)
    srii = sr1:srstep:sr0;
    lax_sr=sri*lax'/100;
    for i=1:length(srii)
        lax_sr1 = (lax_sr(i,:))';
        la = freq2target(targetf,targetp,lax_sr1,i*rayleigh/100);
        if adjust == 1
            [targ,~] = targetadj_real([lax_sr1,la],xx,yy,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax_sr1,la,xx);
        r = corrcoef([yy,lai]);
        corry(i,:)=r(1,2:end);
    end
    xx_sr=sri*xx'/100;
    for i = length(srii)+1:length(sri);
        xx_sr1 = (xx_sr(i,:))';
        yi = interp1(xx_sr1,yy,lax);
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
            [targ,~] = targetadj_real([lax,la],lax,yi,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        r = corrcoef([la,yi]);
        corry(i,:)=r(1,2:end);
    end
% All is larger than sr0
elseif sr1 >= sr0
    xx_sr = sri * xx'/100;
    for i = 1:length(sri);
        xx_sr1 = (xx_sr(i,:))';
        yi = interp1(xx_sr1,yy,lax);
        la = freq2target(targetf,targetp,lax,i*rayleigh/100);
        if adjust == 1
            [targ,~] = targetadj_real([lax,la],lax,yi,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        r = corrcoef([la,yi]);
        corry(i,:) = r(1,2:end);
    end 
% All is smaller than sr0
else
    lax_sr=sri*lax'/100;
    for i = 1:length(sri);
        lax_sr1 = (lax_sr(i,:))';
        la = freq2target(targetf,targetp,lax_sr1,i*rayleigh/100);
        if adjust == 1
            [targ,~] = targetadj_real([lax_sr1,la],xx,yy,orbit7,rayleigh,i);
            la = targ(:,2);
        end
        lai = interp1(lax_sr1,la,xx);
        r = corrcoef([yy,lai]);
        corry(i,:)=r(1,2:end);
    end
end