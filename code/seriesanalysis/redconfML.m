function [rhoM, s0M,redconfAR1,redconfML96]=redconfML(x,dt,nw,nfft,linlog,smoothwin,fmax,plotn,fitFmax)
%
% Robust Estimation of Background Noise and Signal Detection
%INPUT
% x:        1 column evenly spaced dataset. Value only.
% dt:       Sampling rate
% nw:       time-halfbandwidth product. The confidence-level degrees of
%           freedom use the actual number of Slepian tapers retained by
%           PMTM.
% nfft:     uses nfft points in the DFT.  
%           If nfft is greater than the signal length, x is zero-padded to length nfft. 
%           If nfft is less than the signal length, the signal is wrapped modulo nfft.
% linlog:   fit to median-smoothing spectrum. Default fits to log S(f)
%           1 = a linear fit to S(f); 2 = a fit to log S(f).
% smoothwin:median smoothing window. Should be smaller than 0.25 and
%           larger than 0.05 or the spectral resolution. Default value is 0.2
% fmax: maximum displayed frequency. It does not select data for fitting.
% plot: plot results or not
% fitFmax: optional maximum frequency included in the robust fit. The
%          default is the physical Nyquist frequency 1/(2*dt). This limit
%          selects fit ordinates only: the AR(1) transfer function and all
%          returned spectra retain the physical Nyquist frequency and the
%          complete one-sided frequency grid.
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
% [rhoM, s0M,redconfAR1,redconfML96]=redconfML(x,dt,nw,nfft,linlog,smoothwin,fmax,plotn,fitFmax);
%
%
if nargin < 8
    plotn = 1;
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
% Physical Nyquist frequency. Keep this independent from FMAX: FMAX is a
% plotting limit, not a fitting limit or the Nyquist frequency in the
% discrete-time AR(1) transfer function.
if ~(isnumeric(dt) && isreal(dt) && isscalar(dt) && ...
        isfinite(dt) && dt > 0)
    error('Acycle:RedconfML:InvalidSampleInterval', ...
        'DT must be a finite positive real numeric scalar.');
end
physicalNyquist = 1/(2*double(dt));
if ~isfinite(physicalNyquist) || physicalNyquist <= 0
    error('Acycle:RedconfML:InvalidPhysicalNyquist', ...
        'DT must produce a finite positive physical Nyquist frequency.');
end
if ~(isnumeric(fmax) && isreal(fmax) && isscalar(fmax) && ...
        isfinite(fmax) && fmax > 0)
    error('Acycle:RedconfML:InvalidFmax', ...
        'FMAX must be a finite positive real numeric scalar.');
end
fmax = double(fmax);
if fmax > physicalNyquist
    error('Acycle:RedconfML:FmaxAbovePhysicalNyquist', ...
        ['FMAX %.17g exceeds the physical Nyquist frequency %.17g. ', ...
         'FMAX controls only the plot display limit and cannot redefine ', ...
         'the physical Nyquist frequency.'],fmax,physicalNyquist);
end
if nargin < 9
    fitFmax = physicalNyquist;
elseif ~(isnumeric(fitFmax) && isreal(fitFmax) && ...
        isscalar(fitFmax) && isfinite(fitFmax) && fitFmax > 0)
    error('Acycle:RedconfML:InvalidFitFmax', ...
        'FITFMAX must be a finite positive real numeric scalar.');
else
    fitFmax = double(fitFmax);
    if fitFmax > physicalNyquist
        error('Acycle:RedconfML:FitFmaxAbovePhysicalNyquist', ...
            ['FITFMAX %.17g exceeds the physical Nyquist frequency ', ...
             '%.17g. FITFMAX may select reliable fit ordinates but ', ...
             'cannot redefine the physical Nyquist frequency.'], ...
            fitFmax,physicalNyquist);
    end
end
% Multi-taper method power spectrum
if nw == 1
    [pxx,f] = pmtm(x,nw,nfft,'DropLastTaper',false);
else
    [pxx,f] = pmtm(x,nw,nfft);
end

% true frequencies
ft = f/pi*physicalNyquist;
pxx0 = pxx;
ft0 = ft;
%
% FITFMAX selects only the reliable ordinates used to estimate rho and S0.
% Keep the complete grid for the displayed/saved median and backgrounds.
fitMask = ft0 <= fitFmax;
ftFit = ft0(fitMask);
pxxFit = pxx0(fitMask);
% median-smoothing data numbers
smoothn = round(smoothwin * nnz(fitMask));
if smoothn < 1
    error('Acycle:RedconfML:InsufficientFrequencySupport', ...
        ['The selected robust-fit frequency range contains too few ', ...
         'ordinates for the requested median-smoothing fraction. ', ...
         'Increase FITFMAX, NFFT, or SMOOTHWIN.']);
end
% median-smoothing
pxxsmooth = moveMedian(pxxFit,smoothn);  % selected data; for rho evaluation
pxxsmooth0 = moveMedian(pxx0,smoothn);  % all data;for plot only
%
%pxxsmooth = pxxsmooth(ft<= fmax);
%
% convential rho1 (lag-1 autocorrelation coefficient)
[rho]=rhoAR1(x);
% mean power of spectrum
s0 = mean(pxxsmooth);
% conventional median significance level
%theored = s0 * (1-rho^2)./(1-(2.*rho.*cos(pi.*ft./physicalNyquist))+rho^2);
theored0 = mean(pxxsmooth) * (1-rho^2)./(1-(2.*rho.* ...
    cos(pi.*ft0./physicalNyquist))+rho^2);

% Red-noise background fit
% Get the best fit values of rho and s0 (see eq. (2) in Mann and Lees,
% 1996).
    % % % % % % % % % % % % % % % % % %
    % Solve nonlinear curve-fitting (data-fitting) problems in least-squares sense
    % Mingsong Li, Penn State
    % June 5, 2020
try
    cospara = cos(pi.*ftFit./physicalNyquist);
    if linlog == 1
        funrobust = @(v,f)v(1) * (1-v(2)^2)./(1-(2.*v(2).*cospara)+v(2)^2);
        v1 = [s0,rho];
        x = lsqcurvefit(funrobust,v1,ftFit,pxxsmooth);
    else
        funrobust = @(v,f)log10(v(1) * (1-v(2)^2)./(1-(2.*v(2).*cospara)+v(2)^2));
        v1 = [s0,rho];
        x = lsqcurvefit(funrobust,v1,ftFit,log10(pxxsmooth));
    end
    rhoM = x(2);
    s0M = x(1);
    disp('>>  MTM rho and S0 estimation: curve fitting method')
    % % % % % % % % % % % % % % % % % %
catch
    % Alternatively, acycle will use a naive grid search method.
    [rhoM, s0M] = minirhos0( ...
        s0,physicalNyquist,ftFit,pxxsmooth,linlog);
    disp('>>  MTM rho and S0 estimation: grid search method')
end
%
% minimize rho only!
%[rhoM, s0M] = minirho(s0,fn,ft,pxxsmooth,linlog);
% median-smoothing reshape significance level
theored1 = s0M * (1-rhoM^2)./(1-(2.*rhoM.* ...
    cos(pi.*ft0./physicalNyquist))+rhoM^2);

K = acycleMtmTaperCount(nw);
nw2 = 2*(K);
% Chi-square inversed distribution
chi90 = theored1 * chi2inv(0.90,nw2)/nw2;
chi95 = theored1 * chi2inv(0.95,nw2)/nw2;
chi99 = theored1 * chi2inv(0.99,nw2)/nw2;
chi999 = theored1 * chi2inv(0.999,nw2)/nw2;

if plotn == 1
    figure; 
    semilogy(ft0,pxx0,'k')
    hold on; 
    semilogy(ft0,pxxsmooth0,'m-.');
    semilogy(ft0,theored1,'k-','LineWidth',2);
    semilogy(ft0,chi90,'r-');
    semilogy(ft0,chi95,'r--','LineWidth',2);
    semilogy(ft0,chi99,'b-.');
    semilogy(ft0,chi999,'g--','LineWidth',1);
    xlabel('Frequency')
    ylabel('Power')
    xlim([0,fmax])
    smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
    legend('Power',smthwin,'Robust AR(1) median',...
        'Robust AR(1) 90%','Robust AR(1) 95%','Robust AR(1) 99%','Robust AR(1) 99.9%')
    set(gcf,'units','norm') % set location
    set(gcf,'position',[0.0,0.45,0.45,0.45]) % set position
end

% data for output
redconfAR1 = [ft0,pxx0,pxxsmooth0,theored0];
redconfML96 = [ft0,pxx0,theored1,chi90,chi95,chi99,chi999];
