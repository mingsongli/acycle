

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
% Linda Hinnov (George Mason University)

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