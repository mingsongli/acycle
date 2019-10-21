function [freq,ftest,fsig,Amp,Faz,Sig,Noi,dof,wt]=ftestmtmML(data,NW,npad,plotn)
% ftestmtmML.m
%
% This script is based on an educational SCILAB script provided by 
% Jeffrey Park (Yale University), who has given permission for its
% adaptation into Matlab for Acycle by:
%
% Linda Hinnov (George Mason University)
% Mingsong Li (Penn State University)
% October 6, 2019
%
% CALLS:
%  mtmdofs.m  - function by L. Hinnov, included below
%  ftestmtm.m - function by L. Hinnov, included below
%  dpss.m - discrete prolate spheroidal sequences, Matlab's Signal Processing Toolbox 
%  fcdf.m - Fisher cumulative distribution, MATLAB Statistics Toolbox
%
% INPUT
%   data: n-by-2 dataset, must be uniformly sampled.
%   NW:   time-bandwidth product to use (e.g. NW=2 for 2pi multitapers)
%   npad: zero pad to npad * length of y (1 for no padding)
%   plotn: 1 for plot, 0 for no plot.
%
% OUTPUT
%	Freq = vector of frequencies
%	ftest = vector with F-ratios
%	fsig = vector of 1-alpha probability for the F-ratios
%   Amp = vector of harmonic amplitude 
%   Faz = vector of harmonic phase (in degrees)
%   Sig = vector of signal (F-ratio nominator)
%   Noi = vector of noise (F-ratio denominator)
%   dof = adaptive weighted dofs (NOTE: input to ftestmtm.m)
%   wt(n,k) = adaptive weights for each of k eigenspectra
%
% EXAMPLE:
% time=0:1:8191;time=time'; % create time scale
% value=randn(8192,1)+sin(2*pi*time/4); %create sine curve+noise
% data=[time,value];plot(data(:,1),data(:,2)); % store in "data" and plot
% [freq,ftest,fsig,Amp,Faz,Sig,Noi,dof,wt]=ftestmtmML(data,2,20,1);
% xlim([0.248, 0.252]); % zoom in on the peak
% This last command might take a few minutes to run.
% A plot of 2pi MTM amplitude and f-test spectra will appear.
% Change NW from 2 to 10 in the last command and run again.    
% Zoom in on the peak and surrounding band and compare.
%
% REFERENCE:
% Thomson, D.J., 1982. Spectrum estimation and harmonic analysis. 
%      Proceedings of the IEEE, 70, 1055-1096.
%
t = data(:,1);
w = data(:,2);
dt = median(diff(t));
% 
% Harmonic analysis of w
%
% Apply mtmdofs.m to analyze adaptive weights wt
% and degrees of freedom dof vs. frequency freq;
% zero pad x 20 (npad=20); remove (mean and) linear trend;
% to use 2pi multitapers, NW=2
%
[~,dof,wt] = mtmdofs(t,detrend(w),NW,npad);
%
% Apply ftestmtm.m to compute Amp, ftest, etc. 
% using output dof from mtmdofs.m with same NW and npad
%
[freq,ftest,fsig,Amp,Faz,Sig,Noi] = ftestmtm(t,detrend(w),NW,dof,npad);
fnyq = 1/(2*dt);
if plotn
    figure; 
    subplot(3,1,1)
    plot(freq, Amp,'color',[0, 0.4470, 0.7410],'LineWidth',1.5)
    xlim([0, fnyq])
    title(['Amplitude, F-test & significance level : ', num2str(NW), '\pi'])
    ylabel('Amplitude')
    
    subplot(3,1,3)
    fsigsh = 0.9;
    fsig1 = fsig;
    fsig1(fsig1<fsigsh) = 0;
    %yyaxis right
    plot(freq, fsig1,'color','red','LineWidth',1);
    ylim([fsigsh,1.0])
    xlim([0, fnyq])
    line([0 fnyq],[.95 .95],'Color','r','LineWidth',0.5,'LineStyle','-.')
    line([0 fnyq],[.99 .99],'Color','m','LineWidth',0.5,'LineStyle','--')
    yticks([0.9 0.95 0.99 1])
    yticklabels({'0.9','0.95','0.99', '1'})
    ylabel('Significance level')
    xlabel('Frequency')
    
    subplot(3,1,2)
    plot(freq, ftest,'color','k','LineWidth',1);
    xlim([0, fnyq])
    ylabel('F-test')
    
end
% if plotn
%     figure; 
%     yyaxis left
%     plot(freq, Amp,'color',[0, 0.4470, 0.7410],'LineWidth',1.5)
%     xlim([0, fnyq])
%     title(['Amplitude & F-test : ', num2str(NW), '\pi'])
%     ylabel('Amplitude')
%     fsigsh = 0.9;
%     fsig1 = fsig;
%     fsig1(fsig1<fsigsh) = 0;
%     yyaxis right
%     plot(freq, fsig1,'color','red','LineWidth',1);
%     ylim([fsigsh,1.5])
%     xlim([0, fnyq])
%     line([0 fnyq],[.95 .95],'Color','r','LineWidth',0.5,'LineStyle','-.')
%     line([0 fnyq],[.99 .99],'Color','m','LineWidth',0.5,'LineStyle','--')
%     yticks([0.9 0.95 0.99 1])
%     yticklabels({'0.9','0.95','0.99', '1'})
%     ylabel('F-test')
%     xlabel('Frequency')
% end


function [freq,dof,wt] = mtmdofs(t,y,NW,npad)
%   Adaptive-weights and degrees of freedom for 
%   prolate multitapered spectra
%
%   INPUTS:
%	t (column vector) = timescale of y; must be uniformly sampled. 
%	y (column vector) = real-valued time series  
%	NW = time-bandwidth product to use (e.g. NW=2 for 2pi multitapers)
%   npad = zero pad to npad * length of y 
%
%   CALLS TO:
%   dpss.m (discrete prolate spheroidal sequences, MATLAB Signal Toolbox)
%
%   OUTPUTS:
%	freq = vector of frequencies
%	dof = adaptive weighted dofs (NOTE: input to ftestmtm.m)
%	wt(n,k) = adaptive weights for each of k eigenspectra
%
% 
%   REFERENCE:
%   Thomson, D.J., 1982. Spectrum estimation and harmonic analysis. 
%      Proceedings of the IEEE, 70, 1055-1096.
%
dof=[ ]; wt=[ ]; evals=[ ]; bias=[ ]; spw=[ ]; 
N = length(y);
sig2=var(y);
K = 2*NW - 1; % total number of dpss tapers to use
[h,evals] = dpss(N,NW);	% get the dpss tapers and eigenvalues
bias = 1.-evals; % compute bias of the dpss tapers
k = 1;	% index, dpss taper
f = 1;	% index, frequency
% get K sets of dpss-tapered Fourier coefficients of y;
% zero pad to npad x length of y 
for k = 1:K
    Yk(:,k) = fft(h(:,k).*y,npad*N);
end
% 
nfft=length(Yk);
jj=100.;
tol=0.0003;
% Equations 5.3 and 5.4 in Thomson (1982)
for n=1:nfft % end at line 62
% Analyze current frequency using all K tapers
for k=1:K 
spw(k)=real(Yk(n,k)*conj(Yk(n,k)))/sig2;
end
as = (spw(1)+spw(2))/2.0;
iflag=0;
% Convergence to tol usually in a few steps
for j=1:jj 
fn=0.;
fx=0.;
for k=1:K 
a1=sqrt(evals(k))*as/(evals(k)*as + bias(k));
a1=a1^2;
fn=fn+a1*spw(k);
fx=fx+a1;
end
ax=fn/fx;
das=abs(ax-as);
as=ax;
end
iflag=0;
if das >= tol
    iflag=1
end
% compute adaptive weights for all tapered spectra at nth frequency 
degs=0.;
for k=1:K % end at line 60
wt(n,k)=sqrt(evals(k))*ax/(evals(k)*ax + bias(k));
degs = degs+(evals(k)*wt(n,k)^2)/(evals(1)*wt(n,1)^2);
end
% Equation 5.5 in Thomson (1982)
dof(n)=2.*degs;
end
% create frequency scale; first nnft/2+1 frequencies are 0 and positive
dt= t(2)-t(1);
fnyq = 1/(2*dt);
M = length(dof);
df=fnyq/(M/2);
freq =(0:df:(M-1)*df);
%disp('Real-valued time series spectra valid from f=0 to 1/(2*dt) only')
% Note: dof=dof(1:(M/2+1)) are the positive frequencies




function [freq,ftest,fsig,Amp,Faz,Sig,Noi] = ftestmtm(t,y,NW,dof,npad)
%   Adaptive-weighted harmonic F-test, Thomson multitaper method.
%
%   INPUTS:
%	t (column vector) = timescale of y; **must be uniformly sampled. 
%	y (column vector) = real-valued time series to be tested. 
%	NW = time-bandwidth product
%   dof (column vector) = adaptive-weighted dofs (from mtmdofs.m)
%   >> NOTE: if dof is missing, high-resolution option is used.
%   npad = zero pad to npad * length of y 
%
%   CALLS TO:
%   dpss.m (discrete prolate spheroidal sequences, MATLAB Signal Toolbox)
%   fcdf.m (Fisher cumulative distribution function, MATLAB Statistics Toolbox)
%
%  The F-ratio statistic ("F-test") is distributed as an F pdf
%  with 2 and kdof (high-resolution) or dof(f)-2 (adaptive-weighted) DOFs
%
%   OUTPUTS:
%	Freq = vector of frequencies
%	ftest = vector with F-ratios
%	fsig = vector of 1-alpha probability for the F-ratios
%   Amp = vector of harmonic amplitude 
%   Faz = vector of harmonic phase (in degrees)
%   Sig = vector of signal (F-ratio nominator)
%   Noi = vector of noise (F-ratio denominator)
%  
%   REFERENCE:
%   Thomson, D.J., 1982. Spectrum estimation and harmonic analysis. 
%      Proceedings of the IEEE, 70, 1055-1096.
% 
Amp=[ ];Noi=[ ];Sig=[ ];ftest=[ ];fsig=[ ];freq=[ ];Faz=[ ];
N = length(y);
if nargin<4, disp('NOTE: using high-resolution option'); end
K = 2*NW - 1; % total number of dpss tapers 
h = dpss(N,NW);	% get the dpss tapers 
k = 1;	% dpss taper index
f = 1;	% frequency index
% get K sets of dpss-tapered Fourier coefficients of y;
% pad to  npad x length of y 
for k = 1:K
    Yk(:,k) = fft(h(:,k).*y,npad*N);
end
nfft=length(Yk);
% U0 and Usum are elements from Eq. 13.5 (Thomson, 1982)
U0 = sum(h(:,1:K),1);
Usum = sum(U0.^2);
% kdof is denominator dofs for high resolution estimator
kdof = 2*K-2;
% mu is Eq. 13.5 (Thomson, 1982)
% ftest is Eq. 13.10 (Thomson, 1982)
for f=1:nfft
mu = sum(Yk(f,:).*U0)./Usum;
vimag=imag(mu);
vreal=real(mu);
Amp(f)=2*sqrt(vimag^2+vreal^2);
% sine with no phase shift registers -90 deg. phase
Faz(f)=360.*atan2(vimag,vreal)/(2*pi);
ftest(f)=(((K-1)*(abs(mu)).^2*Usum))./(sum((abs(Yk(f,:)-mu*U0)).^2));
% significance for high resolution option using kdof
if nargin<4, fsig(f)=fcdf1(ftest(f),2,kdof-2.0); end
% significance using adaptive-weighted dof vector from mtmdofs.m
if nargin>3, fsig(f) = fcdf(ftest(f),2,dof(f)-2.0); end
Sig(f)=(((K-1)*(abs(mu)).^2*Usum));
Noi(f)=(sum((abs(Yk(f,:)-mu*U0)).^2));
end
% create frequency scale; first nfft/2+1  0 + positive frequencies
dt= t(2)-t(1);
fnyq = 1/(2*dt);
M = length(Amp);
df=fnyq/(M/2);
freq =0:df:(M-1)*df;
