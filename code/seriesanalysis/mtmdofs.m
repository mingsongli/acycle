
function [freq,dof,wt] = mtmdofs(t,y,NW,npad)
%   Adaptive-weights and degrees of freedom for 
%   prolate multitapered spectra
%
%   INPUTS:
%	t (column vector) = timescale of y; must be uniformly sampled. 
%	y (column vector) = real-valued time series  
%	NW = time-bandwidth product to use (e.g. NW=2 for 2pi multitapers)
%   npad = zero pad to npad * length of y; the product is rounded to an
%          integer NFFT, so non-integer multipliers are supported.
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
% Linda Hinnov (George Mason University)

dof=[ ]; wt=[ ]; evals=[ ]; bias=[ ]; spw=[ ]; 
N = length(y);
validateFtestInputs(N,NW);
sig2=var(y);
K = acycleMtmTaperCount(NW); % total number of dpss tapers to use
[h,evals] = dpss(N,NW);	% get the dpss tapers and eigenvalues
bias = 1.-evals; % compute bias of the dpss tapers
k = 1;	% index, dpss taper
f = 1;	% index, frequency
% get K sets of dpss-tapered Fourier coefficients of y;
% zero pad to npad x length of y 
nfft = max(1,round(npad*N));
for k = 1:K
    Yk(:,k) = fft(h(:,k).*y,nfft);
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
dt = median(diff(t));
fnyq = 1/(2*dt);
M = length(dof);
df=fnyq/(M/2);
freq =(0:df:(M-1)*df);
%disp('Real-valued time series spectra valid from f=0 to 1/(2*dt) only')
% Note: dof=dof(1:(M/2+1)) are the positive frequencies
end

function validateFtestInputs(N,NW)
K = 2*NW-1;
if ~(isnumeric(NW) && isreal(NW) && isscalar(NW) && ...
        isfinite(NW) && NW >= 1.5 && NW < N/2 && ...
        abs(K-round(K)) <= eps(max(1,abs(K))))
    error('Acycle:FtestMTM:InvalidTimeBandwidth', ...
        ['NW must be at least 1.5, less than half the data length, ', ...
         'and in 0.5 increments so that at least two whole tapers ', ...
         'are available.']);
end
end
