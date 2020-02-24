function [rhoM, s0M,redconfAR1,redconfML96]=redconfML(x,dt,nw,nfft,linlog,smoothwin,fmax,plot)
%
% Robust Estimation of Background Noise and Signal Detection
%INPUT
% x:        1 column evenly spaced dataset. Value only.
% dt:       Sampling rate
% nw:       time-halfbandwidth product; then using K = 2*nw - 1 Slepian
%           tapers in the power spectral density (PSD) estimate.
% nfft:     uses nfft points in the DFT.  
%           If nfft is greater than the signal length, x is zero-padded to length nfft. 
%           If nfft is less than the signal length, the signal is wrapped modulo nfft.
% linlog:   fit to median-smoothing spectrum. Default fits to log S(f)
%           1 = a linear fit to S(f); 2 = a fit to log S(f).
% smoothwin:median smoothing window. Should be smaller than 0.25 and
%           larger than 0.05 or the spectral resolution. Default value is 0.2
% fmax: maximum estimate frequency
% plot: plot results or not
%
%OUTPUT
% rhoM:     Robust AR1 coefficient 
% soM:      Robust S0 estimation
% redconfAR1:   a 4-column matrix including frequencies, power, median-smoothed power, and theored
%               format: [ft,pxx,pxxsmooth,theored]
% redconfML96:  a 7-column matirx including frequencies, power, robust AR(1) median,
%               robust AR(1) 90%, 95%, 99%, and 99.9% confidence levels.
%               format: [ft,pxx,theored1,chi90,chi95,chi99,chi999]
%
%CALL FOR
%   moveMedian.m
%   rhoAR1.m
%   minirhos0.m
%
%By Mingsong Li, Dec. 24, 2018 @ Penn State
%
% Reference:
%   Mann, M.E., Lees, J.M., 1996. Robust estimation of background noise 
%       and signal detection in climatic time series. Climatic Change 33, 409-445.
%
% EXAMPLE:
% x = dat(:,2); dt = 1; nw = 2; nfft = 2000; linlog = 2; smoothwin = 0.2; plot =1;
% [rhoM, s0M,redconfAR1,redconfML96]=redconfML(x,dt,nw,nfft,linlog,smoothwin,plot);
%
%
if nargin < 8
    plot = 1;
    if nargin < 7
        fmax = 1/(2*dt);
    if nargin < 6
        smoothwin = 0.2;
        if nargin < 5
            linlog = 2;
            if nargin < 4
                nfft = length(x);
                if nargin < 3
                    nw = 2;
                    if nargin < 2
                        error('Error! Sampling rate is needed')
                    end
                end
            end
        end
    end
    end
end
%
% Nyquist frequency
fn = 1/(2*dt);
% Multi-taper method power spectrum
if nw == 1
    [pxx,f] = pmtm(x,nw,nfft,'DropLastTaper',false);
else
    [pxx,f] = pmtm(x,nw,nfft);
end

% true frequencies
ft = f/pi*fn;
pxx0 = pxx;
ft0 = ft;
%
pxx = pxx(ft<=fmax);
fn = fmax;
ft = ft(ft<=fmax);
% median-smoothing data numbers
smoothn = round(smoothwin * length(pxx));
% median-smoothing
pxxsmooth = moveMedian(pxx,smoothn);  % valid data; for rho evaluation
pxxsmooth0 = moveMedian(pxx0,smoothn);  % all data;for plot only
%
%pxxsmooth = pxxsmooth(ft<= fmax);
%
% convential rho1 (lag-1 autocorrelation coefficient)
[rho]=rhoAR1(x);
% mean power of spectrum
s0 = mean(pxxsmooth);
% conventional median significance level
%theored = s0 * (1-rho^2)./(1-(2.*rho.*cos(pi.*ft./fn))+rho^2);
theored0 = mean(pxxsmooth) * (1-rho^2)./(1-(2.*rho.*cos(pi.*ft0./fmax)+rho^2));

% Red-noise background fit
% Get the best fit values of rho and s0 (see eq. (2) in Mann and Lees,
% 1996).
% Here we use a naive grid search method.
[rhoM, s0M] = minirhos0(s0,fn,ft,pxxsmooth,linlog);
%
% minimize rho only!
%[rhoM, s0M] = minirho(s0,fn,ft,pxxsmooth,linlog);
% median-smoothing reshape significance level
theored1 = s0M * (1-rhoM^2)./(1-(2.*rhoM.*cos(pi.*ft./fmax))+rhoM^2);

K = 2*nw -1;
nw2 = 2*(K);
% Chi-square inversed distribution
chi90 = theored1 * chi2inv(0.90,nw2)/nw2;
chi95 = theored1 * chi2inv(0.95,nw2)/nw2;
chi99 = theored1 * chi2inv(0.99,nw2)/nw2;
chi999 = theored1 * chi2inv(0.999,nw2)/nw2;

if plot == 1
    figure; semilogy(ft0,pxx0,'k')
    hold on; 
    semilogy(ft0,pxxsmooth0,'m-.');
    semilogy(ft,theored1,'k-','LineWidth',2);
    semilogy(ft,chi90,'r-');
    semilogy(ft,chi95,'r--','LineWidth',2);
    semilogy(ft,chi99,'b-.');
    semilogy(ft,chi999,'g--','LineWidth',1);
    xlabel('Frequency')
    ylabel('Power')
    smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
    legend('Power',smthwin,'Robust AR(1) median',...
        'Robust AR(1) 90%','Robust AR(1) 95%','Robust AR(1) 99%','Robust AR(1) 99.9%')
end

% data for output
redconfAR1 = [ft0,pxx0,pxxsmooth0,theored0];
redconfML96 = [ft,pxx,theored1,chi90,chi95,chi99,chi999];