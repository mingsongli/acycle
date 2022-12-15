function [powratio,m]=pda(data,fmin,fmax,window,nw)
%% MATLAB FUNCTION PDA
%
% PDA (power decomposition analysis) calculates evolutionary spectral power
% of a selected narrow frequency band
% divided by total spectral power: (selected power) / (total power)
%
% usage: [powratio,m]=pda(data,fmin,fmax,window,nw)
%
% INPUT
%
% data: evenly spaced 2-column time series; column 1 is time value
%      in ascending order; column 2 is signal value 
% fmin:   lower cutoff frequency (> 0) of selected frequency band
% fmax:   upper cutoff frequency (< nyquist) of selected frequency band
% window: moving window length in units of time (<< total data length)
% nw:     time-bandwidth product of discrete prolate spheroidal sequences  
%         used for window.  Typical choices for NW are 2, 5/2, 3, 7/2, 4.
%
% Uses pmtm.m, ones.m, zeros.m, mean.m, diff.m; 
%      nfft.m included in this script
%
% OUTPUT
%
% powratio: 4 columns: time, power ratio, power of selected frequency & total power
%           (power ratio is power of selected frequency divided by total power)
% m:        Time of pmtm calculation
%
% By Mingsong Li & Linda Hinnov (China Univ Geosci & Johns Hopkins Univ)
% Nov 12, 2014
%%
datasxdif=diff(data(:,1));
dt=mean(datasxdif);        % sample rate
nyquist=1/(2*dt);          % Nyquist frequency
[nrow , ~]=size(data);     % size of data
xdata=data(:,2);           % values of time series
npts=round(window/dt);    % number of time series used for one calculation
m=nrow-npts+1;          % number of pmtm calculations, n_row of pmtm matrix results
pow=ones(1,m);          % matrix of sum power from fmin to fmax
powall=ones(1,m);        % matrix of sum power from 0 to fterm
ratio=zeros(1,m);         % ratio of selected pow/powall
x=zeros(1,npts);          % 1*npts matrix for picking data using floating window
[nfpts]=nfft(npts);         % function nfft is at the end of this function
ss=zeros(m,nfpts);         % pmtm results of each mtm calculation
%% Calculate evolutionary pmtm results for data in given window
%  get ss[m X nfpts]
for m1=1:m
    m2=npts+m1-1;
    if m2>nrow           % break in case of reaching moving window boundary
        break
    end
    for mx=m1:m2         % select data using running npts 
        j=mx-m1+1;       % j=1:npts for extracted window
        x(j)=xdata(mx);   
    end
    x=detrend(x);
    [p,w]=pmtm(x,nw);
    ss(m1,:)=p;
end    
%% Sum power of selected frequency band and total frequency range
nfmin=ceil(nfpts*fmin/nyquist);
if nfmin==0
    nfmin=1;
end
nfmax=fix(nfpts*fmax/nyquist);
powallsum=zeros(1,nfpts);
nfn=nfmax-nfmin+1;
spq=zeros(1,nfn);

% calculate power
for p=1:m
    %  power of total frequency (from 0 to Nyquist frequency)
    for ii=1:nfpts
        powallsum(ii)=ss(p,ii);
    end
    powall(p)=sum(powallsum);
    % power of selected frequency band
    ij=1;
    for q=nfmin:nfmax
        spq(ij)=ss(p,q);
        ij=ij+1;
    end 
    pow(p)=sum(spq);
    ratio(p)=pow(p)/powall(p);   
end
data1=data(1,1);
data2=data(nrow,1);
xgrid=linspace(data1+window/2,data2-window/2,m);
powratio=[xgrid;ratio;pow;powall];
powratio=powratio';
 end
% get total number of frequencies from pmtm
function [nfpts]=nfft(npts)
   x=rand(1,npts);
   xx=pmtm(x);
   [nfpts n]=size(xx);
end
