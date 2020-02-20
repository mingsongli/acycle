function [corrCI,corr_h0,corry] = corrcoefsig(dat,target,orbit7,dt,pad,sr1,sr2,srstep,adjust,red,nsim,plotn,display)
% Modify from corrcoefMC, but not repmat
% INPUT
%   dat: 2 column time series of depth and value. Unit of depth must be m
%   target: target series, generated from gentarget.m
%   orbit7: 7 orbital target frequencies
%   dt: sample rates of input series (the dat)
%   pad: zero-padding of periodogram of input series: dat. default = 5000
%   sr1: begining sedimentation rates to be estimated
%   sr2: end sedimentation rates to be estimated for correlation and H0
%   srstep: step of sedimentation rates. 
%       Note: (sr2-sr1)/srstep may be < 200 for a faster estimation
%   adjust:
%   red: 1 = remove AR1 noise
%   nsim: number of simulation for H0 significant level of correlation coefficient
%   plotn: 1 = plot results. else = no plot
% 
% OUTPUT
%   corrCI:     6-column series; 
%                   c1 = tested sedimentation rates
%                   c2 = correlation coefficient for each sed. rates
%                   c3 = p-value of c2
%                   c4 = lower limit of 95% confidence interval of c2
%                   c5 = upper limit of 95% confidence interval of c2
%                   c6 = nmi
%   corr_h0:    3-column series
%                   c1 = Monte carlo simulation significant level of the null
%                       hypothesis (H0) that there is no orbital forcing
%                       with dat series
%                   c2 = H0 SL X correlation coefficient
%                   c3 = H0 SL X (correlation coefficient - 0.3)
% 
% CALLS FOR
%   gentarget.m
%   theoredar1
%   target_real
%   cyclecorr4   % single run for evolutionary correlation coefficient
%   cyclecorr4sig
%   cyclecorr5   % Monte Carlo simulation for H0 significant level
%   
% EXAMPLE:
%   dat = load('yourdata.txt');
%   target = gentarget(4,55000,57000,0,0.06,1,.6,.5,10000,1);
%   [corrCI,corr_h0]=corrcoefsig(dat,target,.05,5000,1,8,.25,1,1,600,1,1);
%   
%   Mingsong Li, June 2017 @ Penn State
%
if nargin > 13
    error('Too many input arguments')
    return;
end
if nargin < 13
    display = 1;
    if nargin < 12
    plotn = 1;
    if nargin < 11
        nsim = 0;  % no Monte Carlo simulation for confidence level estimation
        if nargin < 10
            red = 1;
            if nargin < 9
                adjust = 1;
                if nargin < 8
                    srstep = 0.2;  % sedimentation rate is 0.2 cm/kyr
                    if nargin < 7
                        sr2 = 20;   % default sed. rate from 0.1 to 20 cm/kyr
                        if nargin < 6
                            sr1 = 0.1;  % default sed. rate from 0.1 to 20 cm/kyr
                            if nargin < 5
                                pad = 5000; % zero-pading = 5000
                                if nargin < 4
                                    dt = dat(2,1)-dat(1,1);
                                    if nargin < 3
                                        error('Too few input arguments')
                                        return;
                                    end
                                end
                            end
                        end
                    end
                end    
            end
        end
    end
    end
end

%% data
dat_nyq = 1/(2*dt);   % Nyquist
dat_ray = 1/(length(dat(:,1))*dt);  % rayleigh
[p,f] = periodogram(dat(:,2),[],pad,1/dt);  % power of dat

% remove AR1 noise
if red == 1
        [theored]=theoredar1ML(dat(:,2),f,mean(p),dt);
%         p = p - theored;
%         p(p<0)=0;   % power removing AR(1) noise
        p = p ./ theored;
%       p(p<0)=0;   % power removing AR(1) noise
        p = p - 1;
        p(p<0) = 0;   % power removing AR(1) noise
end
% remove red% noise
if and (red >= 50, red < 100)
        [theored]=theoredar1ML(dat(:,2),f,mean(p),dt);
        facchired = 2*gammaincinv(red/100,2)/(2*2);
        tabtchired = theored * facchired;
%         p = p - tabtchired;
%         p(p<0)=0;
        p = p ./ tabtchired;
        p = p - 1;
        p(p<0) = 0;   % power removing AR(1) noise
end

data = [f,p];
%% target
target_real= target;  % save target frequencies-power series
targetnew = targetrebuilt(target);  % get peaks from given target
targetf = targetnew(:,2);
targetp = targetnew(:,1);
%  Number of peaks in the power spectrum of real data series?
[pks,~] = findpeaks(p);
npks = length(pks);

%% sr0 - a key boundary sedimentary rate
f_nyq_target = target_real(length(target_real(:,1)),1);
sr0 = f_nyq_target*100/dat_nyq;

%% correlation coefficient and its 95% significant level
[corrxch,corry_rch,corrpych,corrloch,corrupch,nmi] = ...
    cyclecorr4(data,targetf,targetp,target_real,orbit7,dat_ray,sr1,sr2,srstep,sr0,adjust);
corrCI = [corrxch,corry_rch,corrpych,corrloch,corrupch,nmi];

%% simulation:  corry (sr x nsim) correlation coefficient
sr_range = sr1:srstep:sr2;
mpts = length(sr_range);
%critical = 100/mpts;% critical significance level by Meyers
if nsim > 0
    corry = zeros(mpts,nsim);
    for i = 1: nsim
        if display == 1
            disp(['>> Step 2: Simulation ',num2str(i),' of ',num2str(nsim)])
        end
        randspectrum = randspec_sin(f,npks,dat_ray);
        [corry(:,i)] = cyclecorr4sig([f,randspectrum],targetf,targetp,target_real,orbit7,dat_ray,sr1,sr2,srstep,sr0,adjust);
    end
    %% Monte Carlo simulation
    corry_sim_sort = sort(corry,2);
    corrlength = length(corry_rch);
    corry_per=zeros(corrlength,1);
    
    for i = 1: corrlength
        corry_r1 = corry_rch(i);
        corry_sim_sort1 = corry_sim_sort(i,:);
%        corry_sim_sort2 = [];
        corry_sim_sort2 = corry_sim_sort1(corry_sim_sort1<corry_r1);
        totallength = length(corry_sim_sort1(~isnan(corry_sim_sort1)));
        corry_per(i) = (totallength-length(corry_sim_sort2)+1)/(nsim+1);
        if corry_per(i)==0
            corry_per(i) = 1/(nsim+1);
        end
    end
    %% confidence interval estimation for correlation coefficient

    corr_h0 = corry_per;  % percentile of the value
    corr_h0(:,2) = (7-corrCI(:,6))/7;   % number of orbits involved
    % corr_h0 = [corry_per,corr_mcadj_ci];
    if plotn == 1
        % plot H0 test of Monte carlo simulation
        figure;
        semilogy(corrxch,corry_per,'r'); 
        xlabel('Sedimentation rates (cm/kyr)')
        ylabel('H_0 significance level')
        title('Null hypothesis test')
        ylim([0.5*min(corry_per) 1])
        line([sr1, sr2],[.10, .10],'LineStyle',':','Color','k')
        line([sr1, sr2],[.05, .05],'LineStyle',':','Color','k')
        line([sr1, sr2],[.01, .01],'LineStyle','--','Color','k')
        line([sr1, sr2],[.001, .001],'LineStyle',':','Color','k')
        legend('H_0 Sig.level','10%','5%','1 %','0.1%')
        set(gca,'Ydir','reverse')
        
        figure; 
        plot(corrxch,corry_rch,'r');
        hold on; 
        plot(corrxch,corrloch,'k--');
        plot(corrxch,corrupch,'k--');
        plot(corrxch,corr_h0(:,2),'b');
        hold off;
        xlabel('Sedimentation rates (cm/kyr)')
        ylabel('Correlation coefficient (r)')
        legend('Corrcoef','95% CI ch','95% CI ch','# orbits')
        line([sr1, sr2],[.5, .5],'LineStyle','--','Color','b')
        line([sr1, sr2],[.3, .3],'LineStyle',':','Color','b')
        title('Correlation coefficient')
    end
else
    corr_h0 = zeros(mpts,1);
    corry = [];
end