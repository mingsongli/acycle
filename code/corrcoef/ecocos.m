function [prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,norbit] = ...
   ecocos(data,target,window,dt,step,delinear,red,pad,sr1,sr2,srstep,adjust,plotn)
% Modified from ecoco, no monte carlo simulation, no H0 estimtion.
% INPUT
%   data: 2 column time series
%   target: 2 column target (e.g., a 2-myr long laskar solution)
%   window: runing window
%   dt: sample rates of data
%   step: runing step
%   delinear: 1 = yes. Remove linear trend of data
%   method 1 = periodogram; 2 = MTM
%   red: 1 = AR(1).   95: (95% confidence level) 
%   nw: MTM spectrum
%   red: red = 0; no adjust power; 1 = AR(1); else red% Confidence interval
%   sr1:
%   sr2:
%   srstep:
%   adjust 1: adjust power of target to power of real data
%   plotn: plot result
%
% OUTPUT
%
%
% Calls for 
%   theoredar1
%   noiseDH
%   ecocoplot
%   
%%
%f_nyq_target = target(length(target(:,1)),1);  % to estimate sr0 (turnpoint sed.rate)
% nyquist = 1/(2*dt);             % Nyquist frequency of real data
nrow = length(data(:,1));       % number of the row of data
time = data(:,1);               % depth or data
datay = data(:,2);              % value of data
npts=fix(window/dt);            % number of time series within 1 window
if step >= nrow/2
   error('Error: step is too large');
end
m=fix((nrow-npts)/step)+1;     % number of pmtm calculations, n_row of pmtm matrix results

x=[];
timex=[];
%% Calculate evolutionary pmtm results for data in givin window
for m1=1:step:(step*m-1)
    m2=npts+m1-1;
    m3 = (m1-1)/step+1;               % number of pmtm calculations considering step
    if m2 > nrow                      % break in case of reach moving window boundary
        break
    end
    x(:,m3) = datay(m1:m2,1);
    timex(:,m3) = time(m1:m2,1);
end
    if delinear == 1
        x=detrend(x);                   % remove linear trend of x
    end
%%
lengthcorr = length(sr1:srstep:sr2);
out_ecc = zeros(lengthcorr,m3);
out_ep = zeros(lengthcorr,m3);
out_eci = zeros(lengthcorr,m3);
out_ecoco = zeros(lengthcorr,m3);
out_ecocorb = zeros(lengthcorr,m3);
prints_ecoco= zeros(m3,1);
prints_sr = zeros(m3,1);
prints_eci = zeros(m3,1);
prints_ecc = zeros(m3,1);
prints_norbit = zeros(m3,1);
prints_ecocorb=zeros(m3,1);

orbit7 = [400 1/0.0083 1/0.01074 1/0.02588 1/0.04346 1/0.0459 1/0.0542]; % 55-57 Ma
sr_range = sr1:srstep:sr2;
[norbit]=numorbit(data,orbit7,sr_range);

 for i = 1:m3
     [corrCI,corr_h0] = corrcoefsig([timex(:,i),x(:,i)],target,dt,pad,sr1,sr2,srstep,adjust,red,0,0,0);
     out_ecc(:,i) = corrCI(:,2);  % evolutionary ecorrcoef value
     out_ep(:,i) = corrCI(:,3);  % evolutionary ecorrcoef value
     out_eci(:,i) = corr_h0(:,1);   % evolutionary H0 sigificant interval
     out_ecoco(:,i) = corr_h0(:,3);   % evolutionary ecc value
     %out_ecocorb(:,i) = norbit.*out_ecoco(:,i);
     out_ecocorb(:,i) = log10(norbit).*out_ecc(:,i);
     prt_sr = corrCI(:,1);
     prt_ecc = corrCI(:,2);
     prt_ep = corrCI(:,3);
     prt_eci = corr_h0(:,1);
     prt_ecoco = corr_h0(:,3);
     
     prints_ecocorb(i) = max(out_ecocorb(:,i)); % max ecc value
     
     prints_sr(i) = prt_sr(out_ecocorb(:,i) == prints_ecocorb(i));
     prints_eci(i) = prt_eci(out_ecocorb(:,i) == prints_ecocorb(i));
     prints_ep(i) = prt_ep(out_ecocorb(:,i) == prints_ecocorb(i));
     prints_ecc(i) = prt_ecc(out_ecocorb(:,i) == prints_ecocorb(i));
     prints_ecoco(i) = prt_ecc(out_ecocorb(:,i) == prints_ecocorb(i));
     prints_norbit(i) = norbit(out_ecocorb(:,i) == prints_ecocorb(i));
     
     loci = (i-1)*step+1+round(window/2);
     
     disp(['--> Location : ',num2str(time(loci)),' m. Iteration : ',num2str(i),' of ', ...
         num2str(m3)])
     disp(['>>  Sedimentation rate is [ ',num2str(prints_sr(i)),...
         ' ] cm/kyr. # of orbital cycles evaluated : '...
         ,num2str(prints_norbit(i)),' of ',num2str(length(orbit7))]);
     disp(['    Correlation coeffcient ',num2str(prints_ecc(i)),...
         '. Corrcoef p-value ',num2str(prints_ep(i)),'.']);
     % '. H0 (no orbital forcing) significance level ',num2str(prints_ep(i)),'%']);
     %disp(['    ECOCO value is ',num2str(prints_ecoco(i)),'. ECOCO x # of orbits : ',num2str(prints_ecocorb(i))])
     disp(['. ECOCO x # of orbits : ',num2str(prints_ecocorb(i))])
 end
 
    out_depth = (linspace(data(1,1)+window/2,data(nrow,1)-window/2,m3))';
    
if plotn == 1
   [prt_sr] = ecocoplots(prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb);
    % plot number of orbital
    figure; plot(prt_sr,norbit)
    xlabel('Sedimentation rates (cm/kyr)')
    ylabel('Number of orbital cycles (#)')
    ylim([min(norbit)-1 max(norbit)+1])
    legend('Orbital solutions to be evaluated')
end
