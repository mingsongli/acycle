function [prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,sr_p] = ...
   ecoco(data,target,orbit7,window,dt,step,delinear,red,pad,sr1,sr2,srstep,nsim,adjust,slices,plotn)
% Evolutionary correlation coefficient
% INPUT
%   data: 2 column time series: depth-variances; depth must be a evenly
%           spaced, increasing-downward series.
%   target: 2 column target ETP solution (e.g., a 2-myr long laskar solution)
%           time-ETP;  ETP is a normalized eccentricity-tilt-precession series.
%   orbit7: seven main orbit cycles, 405, 125, 95, Obl. P1, P2, and P3
%   window: sliding window
%   dt: sample rates of data
%   step: runing step
%   delinear: 1 = yes. Remove linear trend of data
%   method 1 = periodogram; 2 = 2pi-MTM
%   red: red = 0; no adjust power; 1 = AR(1); else red% Confidence interval
%   pad: zero-padding number
%   sr1: tested sed. rate: start
%   sr2: tested sed. rate: end
%   srstep: tested sed. rate: step
%   nsim: number of simulation
%   adjust 1: adjust the power of the target to the power of the real data
%   slices: divide series within each sliding window into several slices
%   plotn: plot result
%
% OUTPUT
%   prt_sr:  sedimentation rate evaluated
%   out_depth: 
%   out_ecc  % evolutionary correlation coefficient
%   out_ep  % evolutionary correlation coefficient p-value (Matlab version)
%   out_eci  % evolutionary correlation coefficient H0 significance level
%   out_ecoco  % evolutionary corrcoef and H0 sig.level
%   out_ecocorb: evolutionary corrcoef, orbit cycles involved and H0 sig.level
%   out_norbit: number of orbit cycles involved
%
% Calls for 
%   theoredar1
%   noiseDH
%   ecocoplot
%   numorbit
%
% By Mingsong Li, June 2017
%   updated by Mingsong Li, Dec 25, 2017
%
%%
%f_nyq_target = target(length(target(:,1)),1);  % to estimate sr0 (turnpoint sed.rate)
% nyquist = 1/(2*dt);             % Nyquist frequency of real data
nrow = length(data(:,1));       % number of the row of data
time = data(:,1);               % depth or data
datay = data(:,2);              % value of data
npts = fix(window/dt);            % number of time series within 1 window
            
if step >= nrow/2
   errordlg('Error: sliding step is too large!');
end

m=fix((nrow-npts)/step)+1;     % number of FFT calculations, n_row of FFT matrix results
x=[];
timex=[];

%% prepare data based on running window and steps
disp('>> Step 1: prepare data');
for m1=1:step:(step*m-1)
    m2=npts+m1-1;
    m3 = (m1-1)/step+1;               % number of FFT calculations related with step
    if m2 > nrow                      % break in case of reach moving window boundary
        break
    end
    x(:,m3) = datay(m1:m2,1);
    timex(:,m3) = time(m1:m2,1);
end
    if delinear == 1
        x = detrend(x,0);                   % remove mean trend of x
    end
%% Prepare varables
sr_range = sr1:srstep:sr2;
nofsr = length(sr_range); % number of sedimentation rates to be tested
out_ecc = zeros(nofsr,m3);
out_ep = zeros(nofsr,m3);
out_eci = zeros(nofsr,m3);
out_ecoco = zeros(nofsr,m3);
out_ecocorb = zeros(nofsr,m3);
out_norbit = zeros(nofsr,m3);

%% Simulation for the first sliding window
i = 1;
%[corrCI,~,corry] = corrcoefsig([timex(:,i),x(:,i)],target,orbit7,dt,pad,sr1,sr2,srstep,adjust,red,nsim,0,1);
[~,~,corry] = corrcoefslices([timex(:,i),x(:,i)],target,orbit7,dt,pad,sr1,sr2,srstep,adjust,red,nsim,0,slices);
%%
corrCI =[];
sr_p = zeros(m3,6);

% Waitbar
hwaitbar = waitbar(0,'eCOCO processing ... [CTRL + C to quit]',...    
   'WindowStyle','modal');
hwaitbar_find = findobj(hwaitbar,'Type','Patch');
set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
setappdata(hwaitbar,'canceling',0)
steps = 50;
% step estimation for waitbar
nmc_n = ceil(m3/steps);
waitbarstep = 0;
waitbar(waitbarstep / steps)

 for i = 1:m3
     [corrCI,~,~] = corrcoefslices_rank([timex(:,i),x(:,i)],target,orbit7,dt,pad,sr1,sr2,srstep,adjust,red,0,0,slices);
     out_ecc(:,i) = corrCI(:,2);  % evolutionary ecorrcoef value
     out_ep(:,i) = corrCI(:,3);  % evolutionary ecorrcoef p-value
     norbit1 = 7 - corrCI(:,end);
     out_norbit(:,i) = norbit1;
     for j = 1:nofsr
         percent_value = findperct(corrCI(j,2),corry(j,:));
         if percent_value == 0
             percent_value = 1/(nsim+1);
         end
         out_eci(j,i) = percent_value;
         out_ecoco(j,i) = (- log10(out_eci(j,i))) * out_ecc(j,i);
         out_ecocorb(j,i) = out_norbit(j,i) / 7 * out_ecoco(j,i);
     end
     
     if rem(i,nmc_n) == 0
        waitbarstep = waitbarstep+1; 
        if waitbarstep > steps; waitbarstep = steps; end
        pause(0.001);%
        waitbar(waitbarstep / steps)
    end
    if getappdata(hwaitbar,'canceling')
        break
    end
     
     if nsim > 1
         prt_sr = corrCI(:,1);
         prt_ecc = corrCI(:,2);
         prt_eci = out_eci(:,i);
         prints_ecocorb = max(out_ecocorb(:,i)); % max ecc value
         prints_sr = prt_sr(out_ecocorb(:,i) == prints_ecocorb);
         prints_eci = prt_eci(out_ecocorb(:,i) == prints_ecocorb);
         prints_ecc = prt_ecc(out_ecocorb(:,i) == prints_ecocorb);
         prints_ecoco = prt_ecc(out_ecocorb(:,i) == prints_ecocorb);
         prints_norbit = out_norbit(out_ecocorb(:,i) == prints_ecocorb);
         
         if length(prints_sr) > 1
             disp('Warning: multiple sedimentary rate options are :')
             disp(prints_sr)
         end
         
         loci = ((i-1) * dt * step + data(1,1) + window/2);

         disp(['-----> Location : ',num2str(loci),' m. Iteration : ',num2str(m3),' -> ',num2str(i)])
         try
             disp(['>>  Sedimentation rate = [ ',num2str(prints_sr(1)),...
                 ' ] cm/kyr. # of orbital cycles invloved : ',...
                 num2str(prints_norbit(1)),' of ',num2str(length(orbit7))]);
         catch
             disp('>>  Error: no solution. May not adjust the periodogram of astronomical solutions to the data periodogram')
             break
         end
             disp(['    Correlation coeffcient ',num2str(prints_ecc(1)),...
                 '. H0 significance level ',num2str(prints_eci(1))]);
             disp(['    COCOxH0-SL value ',num2str(prints_ecoco(1)), 'COCOxH0-SLxOrbits',num2str(prints_ecocorb(1)) ])
             sr_p(i,1) = loci;
             sr_p(i,2) = prints_sr(1);
             sr_p(i,3) = prints_ecc(1);
             sr_p(i,4) = prints_eci(1);
             sr_p(i,5) = prints_norbit(1);
             sr_p(i,6) = prints_ecocorb(1);
     else
         out_ecocorb(:,i) = out_norbit.*out_ecc(:,i);
     end
 end
 if ishandle(hwaitbar); 
    close(hwaitbar);
end
%    assignin('base','sr_disp',sr_p)
    out_depth = (linspace(data(1,1)+window/2,data(nrow,1)-window/2,m3))';
    
if abs(plotn) > 0
    hwarn = warndlg('Wait, eCOCO plot ...');
    if nsim > 1
        [prt_sr] =  ecocoplot(corrCI(:,1),out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,plotn);
    else
        [prt_sr] = ecocoplots(corrCI(:,1),out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,plotn);
    end
    try
        close(hwarn)
    catch
    end
end