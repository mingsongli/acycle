% function [pow,power_all,powall,powf,nc]=pdan(data,f3,window,nw,ftmin,fterm,step,pad)
function [pow]=pdan(data,f3,window,nw,ftmin,fterm,step,pad)
%% pdan calculates evolutionary spectral power of input narrow frequency bands
%% and total spectral power (last colume)
%   highlights variances of Milankovitchian 'signal' within 3 bands
%   i.e., precession, eccentricity and obliquity bands.
%  pda: Power decompostion analysis
% INPUT
% data:   evenly spaced 2-column time series; column 1 is time value
%             in ascending order; column 2 is signal value 
% f3:     2x pairs of frequency bands (> 0 and < nyquist)
% window: moving window length in units of time (<< total data length)
% nw:     time-bandwidth product of discrete prolate spheroidal sequences  
%         used for window.  Typical choices for NW are 2, 5/2, 3, 7/2, 4.
% ftmin:  lower cutoff frequency (> 0) for estimation of total variances
% fterm:  upper cutoff frequency (< nyquist) for estimation of total variances
% step:   step of calculations; default is 1
% pad:    zero-padding number, e.g., 1000
%
% Uses pmtm.m, ones.m, zeros.m, mean.m; 
%      nfft.m included in this script
%
% OUTPUT
% pow:      total power of each selected frequency bands and total power of
%           frequencies from ftmin to fterm
%
%% Mingsong Li (China Univ Geosci & Johns Hopkins Univ), Nov 12, 2014
% Updated from pda.m by Mingsong Li (George Mason Univ), Dec 2016
%       pda.m is from
%       Li et al., 2016 Geology, doi: 10.1130/G37970.1
%       https://doi.pangaea.de/10.1594/PANGAEA.859147

%% Error msgs
if(nargin >= 9)
    disp('>> Error: too many arguments!')
end
if(nargin < 8)
    pad = 1000;
    if nargin < 7
        step = 1;
        if nargin < 6
            fterm = 1/(2*(data(2,1)-data(1,1)));
            if nargin <5
                ftmin = 0;
                if nargin < 4
                    nw = 2;
                end
            end
        end
    end
end
%% 
dt=data(2,1)-data(1,1);             % sample rate
nyquist=1/(2*dt);                   % Nyquist frequency
[nrow, ~]=size(data);               % size of data
xdata=data(:,2);                    % value of time series
npts=fix(window/dt);               % number of time series used for one calculation
    if step >= nrow/2
       disp('€˜Error: step is too big');
    end
    if fterm > nyquist
        fterm = nyquist;
    end
f3(f3>nyquist)=nyquist;
% disp('>>  Warning: Frequency is larger than nyquist frequency!')
m=fix((nrow-npts)/step)+1;     % number of pmtm calculations, n_row of pmtm matrix results
[nfpts]=nfft(npts,pad);        % function nfft is at the end of this function

%% Calculate evolutionary pmtm results for data in givin window
for m1=1:step:(step*m-1)
    m2=npts+m1-1;
    m3=(m1-1)/step+1;               % number of pmtm calculations considering step
   
    if m2>nrow                      % break in case of reach moving window boundary
        break
    end
    x = xdata(m1:m2,1);x = x';
    x=detrend(x);                   % remove linear trend of x
    [p,~]=pmtm(x,nw,pad);           % pmtm of x
    power_all(m3,:)=p;              % matrix of power
end    
%% avoid a overlap of cutoff frequencies
[~, ncol]=size(f3); % ncol is cutoff frequencies; must be odd number
nc = ncol/2;        % number of astronomical parameters

%%
    nftmin = ceil(nfpts*ftmin/nyquist);  % updated June 2016
    if nftmin == 0
        nftmin = 1;
    end
    nfterm = fix(nfpts*fterm/nyquist);   % updated June 2016
    powall = power_all(:,nftmin:nfterm);
    powallsum = sum(powall,2);
    nf=[];
for i = 1 : nc
    % select cutoff frequencies fmin and fmax
    fmin = min(f3(2*i-1), f3(2*i));
    fmax = max(f3(2*i-1), f3(2*i));
    nfmin = ceil(nfpts*fmin/nyquist);
    if nfmin==0
       nfmin=1;
    end
    nfmax = fix(nfpts*fmax/nyquist);
    nf1 = nfmin:nfmax;
    nf = [nf,nf1];
end
    nfrange = unique(nf);
    powf = power_all(:,nfrange);
    powfsum = sum(powf,2);

pow(:,2) = powfsum./powallsum;
pow(:,1) = (linspace(data(1,1)+window/2,data(nrow,1)-window/2,m3))';
 end

 %% get total number of frequencies from pmtm
function [nfpts]=nfft(npts,pad)
   xx=rand(1,npts);
   xxx=pmtm(xx,2,pad);
   [nfpts, ~]=size(xxx);
end