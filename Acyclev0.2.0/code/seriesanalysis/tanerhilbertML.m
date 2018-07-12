function [tanhilb,ifaze,ifreq] = tanerhilbertML(data,fc,fl,fh)
%tanerhilbert.m - Produces a bandpassed version of an input real-
%            valued time series by FFT, multiplication by filter
%           designed in frequency domain, and inverse FFT.
%
%    INPUTS
%
%           data=[t,x] time series to filter
%           dt = sample rate of time series
%           f1 = lower cut-off frequency 
%           fc = center frequency of passband
%           fh = upper cut-off frequency
%           c = roll-off/octave (default= 10^12)
%
%           x = data to filter
%           t=output time scale
%           bandx = output filtered series
%
%      Linda Hinnov, December, 2006.  
%      All service Ricker-based filter by Turhan Taner.
%
%      Reference:
%        Taner, M.T. (2000), Attributes revisited, Technical Publication, 
%         Rock Solid Images, Inc., Houston, Texas, URL:
%         http://www.rocksolidimages.com/pdf/attrib_revisited.htm 
%%
t=data(:,1);
x=data(:,2);
dt=t(2)-t(1);
filter = [ ];
xftfor = [ ];
xftinv = [ ];
bandx = [ ];
twopi=2.*pi;
c=10^12;
npts=length(x);
xnpts = npts;
wnyq = twopi/(2.*dt);
dw = twopi/(xnpts*dt);
% dummy operation to set up filter size
filter=x;
%.....Set up filter
wl = twopi*fl;     % calculate number in the fft rol result ML add
wc = twopi*fc;     %
wh = twopi*fh;     %
bw = wh - wl;      % num used
amp = 1./sqrt(2.);
arg1 = 1. - (c*log(10.)) / (20.*log(amp));
arg1 = log(arg1);
arg2 = ((bw+2)/bw)^2;
arg2 = log(arg2);
twod = 2.*arg1/arg2;
ncut = fix(npts/2+1);
%.....Filter for positive frequencies
for n=1:ncut;
w = (n-1)*dw;
arg = (2.*abs(w-wc)/bw)^twod;
darg=-1.0*arg;
filter(n) =  ( amp * exp(darg));
end
ncut1 = ncut+1;
%.....Filter for negative frequencies
for n=ncut1:npts;
w = (n-npts-1)*dw;
aw = abs(w);
arg = (2.*abs(aw-wc)/bw)^twod;
darg=-1.0*arg;
filter(n) = (amp * exp(darg));
end
%% Forward FFT data
xftfor = fft(x,npts);
%.....Apply the filter over all frequencies
for n=1:npts;
xftfor(n) = xftfor(n) * filter(n);
end
%.....Inverse FFT
xftinv = ifft(xftfor,npts);
bandx = real(xftinv);
%figure;plot(time,bandx),title('Taner');
%
% PERFORM QUADRATURE ANALYSIS
% x is evenly spaced signal; t is time vector; 
% dt is the spacing of x.
% from Florian Maurer (found in MATLAB newsgroup)
%
xx=bandx;
% performing the HILBERT TRANSFORM
hx = hilbert(xx);
% calculating the INSTANTANEOUS AMPLITUDE
iamp = abs(hx);
% calculating the UNROLLED PHASE
ufaze = unwrap(angle(hx));
ufazedet=detrend(ufaze);
% calculating the INSTANTANEOUS PHASE
ifaze = atan(angle(hx));
% calculating the INSTANTANEOUS FREQUENCY
ifreq = diff(ufaze)/(2*pi*dt);
% plot the results
%figure;
%subplot(4,1,1), plot(t,xx),title('Modulated signal & Instantaneous amplitude'); hold on;
%subplot(4,1,1), plot(t,iamp); hold off;
%subplot(4,1,2), plot(t,ufaze),title('Unrolled phase')
%subplot(4,1,3), plot(t,ufazedet),title('Detrended phase')
%subplot(4,1,4), plot(t(1:(length(t)-1)),ifreq),title('Instantaneous frequency')
%%

tanhilb=[t,xx,iamp,ufaze,ufazedet];

