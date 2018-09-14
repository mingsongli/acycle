% gaussfilter.m
function [gaussbandx,filter,f]=gaussfilter(datax,dt,fc,fl,fh)
%
%  Fourier domain BANDPASS filter based on a simple Gaussian curve
%  with zero phase response. Mimics Gauss filter in Analyseries 2.0
%
%  Inputs:
%     datax = 1 column vector with data to filter
%     dt = sample rate of datax 
%     fc = center frequency of filter 
%     fl = lower cutoff frequency of filter 
%     fh = upper cutoff frequency of filter
%
%  Outputs:
%     gaussbandx = 1 column vector with filtered data
%     filter = zero and positive frequencies of filter gain
%     f = frequency-scale for filter
%
%  Procedure:
%  1. Prepare data length to next power of 2 + npad*zero-padding 
%     (default npad=10)
%  2. Set up filter parameters with 1000 point Gaussian reference curve
%  3. Rescale reference curve to Fourier domain scale of zero-padded data
%  4. Set up filter across Fourier domain
%  5. Apply filter to FFT of zero-padded data
%  6. Inverse FFT filtered data and remove zero-padding
%
% Example:
% dt=5.;
% len=2000;
% t=(1:dt:len*dt)';
% x=randn(len,1)+cos(2*pi*t/20);
% fc=1/20;
% fl=fc-1/50;
% fh=fc+1/50;
% [gx,gfilter,gf]=gaussfilter(x,dt,fc,fl,fh);
% figure;plot(gf,gfilter);xlim([0,0.1]);
% figure;plot(t,x,t,gx+4);xlim([0 500]);legend('x','gx');
%
%  Still need to test for use as low-pass filter (fc=0)
%  
%  Brief editing log:
%  L. Hinnov, October 2016 - corrected Fourier domain application with 
%                            with zero-padding to circumvent odd vs.
%                            even FFT bin assignments.
%  K. Ramamurthy, January 2013 - definition of filter parameters to 
%                                mimic Gauss filter of Analyseries 2.0
%
npad=10; % default zero-padding length
nlen=length(datax);
fnyq=1/(2*dt);
% force into even number(power of 2) plus npad x npts zero-padding
pow=log10(nlen)/log10(2);
npow=round(pow);
dpow=pow-npow;
if dpow < 0
    npow=npow+1;
end
npts=2^npow;
newnlen=npad*npts;
df=1/(newnlen*dt); 
f=[ ];
ntot=fix(fnyq/df); %ntot+1 out to Nyquist; total number freqs is 2*ntot
for j=1:ntot;
    f(j)=(j-1)*df; %set up frequency scale in datax units
end
nfs=round((fh-fl)/df); %distance between cutoffs
% Compute reference Gauss curve length 1000 at 1/10 spacing;
g=[ ];
x=[ ];
NN=100; 
sigma=1;
dx=1/10;
NNX=round(NN/dx);
norm=-2*sigma^2*NN;
del=(NNX/2)*dx;
for i=1:NNX;
    x(i)=i*dx;
    g(i)=exp(((x(i)-del)^2)/norm);   
end
% Identify xlo and xhi (halfpower points on x, i.e., g=0.707)
% Currently g=0.5 to match Analyseries power (?) scale.
halfpow=1./2.;
flag=1;
xlo=0;
NNX2=NNX/2; 
for i=1:NNX2;
 if g(i) <= halfpow
        flag=i;
        xlo=x(i);
 end
end
% Round to nearest neighbor
g1=halfpow-g(flag);
g2=g(flag+1)-halfpow;
if g1 > g2
    xlo=x(flag+1);
   flag=flag+1;
end
xhi=x(NNX-flag);
nrange=(xhi-xlo)/dx; % distance between cutoffs
% Rescale Gauss curve to datax frequency scale
x=[ ];
g=[ ];
dx=dx*nrange/nfs;  % nfs from datax cutoff freqs
NNX=round(NN/dx); % rescaled
norm=-2*sigma^2*NN; 
del=(NNX/2)*dx;
for i=1:NNX;
    x(i)=i*dx;
    g(i)=exp(((x(i)-del)^2)/norm);   
end
% Identify new xlo and xhi (halfpower points on x)
flag=1;
xlo=0;
NNX2=round(NNX/2);
for i=1:NNX2;
 if g(i) <= halfpow
        flag=i;
        xlo=x(i);
 end
end
% Round to nearest neighbor
g1=halfpow-g(flag);
g2=g(flag+1)-halfpow;
if g1 > g2
    xlo=x(flag+1);
    flag=flag+1;
end
xhi=x(NNX-flag);
nrange=(xhi-xlo)/dx;
% Identify center of filter; position at fc; truncate if necessary
NCENTER=round(NNX/2); %center of reference filter
dfcenter=fc/df; %center of datax filter; must be integer
nfcenter=round(dfcenter)+1; %center of datax frequency scale (why+1?)
% Set up the filter in positive frequencies using makefilter function
% (included at the end of this script)
filter=makefilter(NCENTER,ntot,NNX,nfcenter,g); 
% Apply filter to datax fft (neg and pos frequencies)
filterall=[ ];
%.....Filter for positive frequencies PLUS f=0
ncut=fix(ntot+1); 
for n=1:ncut;
    n;
    filterall(n)=filter(n);
end
ncut1 = ncut+1;
%.....Filter for negative frequencies
nrev=ncut1;
for n=ncut1:2*ntot;
    nrev=nrev-1;
    nrev;
    filterall(n) = filter(nrev);
end
%.....Forward FFT datax; ZEROPADDING!!!
xftfor = fft(datax,2*ntot);
%.....Apply the filter over all frequencies
for n=1:2*ntot
xftfor(n) = xftfor(n) * filterall(n);
end
%.....Inverse FFT; normalize by sqrt(2);remove zero-padding.
xftinv = ifft(xftfor);
gaussbandx = real(xftinv);
gaussbandx=gaussbandx(1:nlen);
filter=filter(1:ntot);
% end of main gaussfilter function
% ------ start of function makefilter.m 
function filter = makefilter(NCENTER,ntot,NNX,nfcenter,g)
filter=[ ];
for k=1:2*ntot
    filter(k)=0.;
end
% Put center of reference filter into fc position
filter(nfcenter)=g(NCENTER); 
% Fill in the filter for positive freqs >>except at filter(nfcenter)
for k=1:(nfcenter-1);
    kminus=nfcenter-k; % for data filter
    nminus=NCENTER-k; % for reference filter
    if nminus >= 1
        filter(kminus)=g(nminus);
    end
end
% Fill in the filter for negative freqs >>except at filter(nfcenter)
ntot2=2*ntot/2;
for k=1:ntot2
    kplus=nfcenter+k; % for data filter
    nplus=NCENTER+k; % for reference filter
    if nplus <= NNX 
        filter(kplus)=g(nplus);
    end
end
% ------- end of makefilter.m

