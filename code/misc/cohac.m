function [Cxy,F1, MSC_critical,significant_freqs,significant_Cxy, phase_diff_deg,F2,phase_uncertainty_deg] ...
    = cohac(x,y,sr,window,winsize,nooverlap,alpha,qplot)
% calculate coherence and phase for x and y
% INPUT
% x: first data vector
% y: second data vector
% sr: sampling rate
% window: window style;
%   'hamming'
%   https://www.mathworks.com/help/signal/ug/windows.html
% nooverlap: number of overlap
% threshold: coherence threshold, must be >= 0 and <= 1;
% qplot: 0 = no; 1 = coherence+phase; 2 = coherence+phase+polarscatter; 
% 
% OUTPUT
%   Cxy: coherence of x and y
%   F1: frequency for Cxy
%   Pxy: phase of x and y
%   F:  frequency for Pxy
% EXAMPLE
%
% Fs = 1000;
% t = 0:1/Fs:1-1/Fs;
% x = cos(2*pi*100*t) + sin(2*pi*200*t) + 0.5*randn(size(t));
% y = 0.5*cos(2*pi*100*t - pi/4) + 0.35*sin(2*pi*200*t - pi/2) + 0.5*randn(size(t));
% cohac(x,y)
% cohac(x,y,1,'hamming',100,80,.2)
%
% Mingsong Li
% Penn State; March 14, 2019
% Peking University, Nov. 2, 2023
% 
%
if nargin < 8; qplot = 2; end
if nargin < 7; alpha = 0.1; end  % 90% confidence level
if nargin < 6; nooverlap = []; end
if nargin < 5; winsize = []; end
if nargin < 4; window = 'hamming'; end
if nargin < 3; sr = 1; end
if nargin < 2; return; end

if window == 'hamming'
    %%
    [Cxy,F1] = mscohere(x,y,hamming(winsize),nooverlap,[],1/sr);
    % Calculate degrees of freedom
    windown = hamming(winsize);
    % Estimate of the number of independent averages
    N = floor((length(x) - nooverlap) / (length(windown) - nooverlap));
    v = 2 * N;  % Degrees of freedom
    % Calculate confidence level
    % Calculate the test statistic
    T = (Cxy ./ (1 - Cxy)) * (v - 2);
    % Critical value from the F-distribution
    F_critical = finv(1 - alpha, 1, v - 2);
    MSC_critical = F_critical / (F_critical + (v - 2));
    % Find frequencies where the coherence is significantly different from zero
    significant_freqs = F1(T > F_critical);
    significant_Cxy = Cxy(T > F_critical);
    
    %% phase
    [Pxy,F2] = cpsd(x,y,hamming(winsize),nooverlap,[],1/sr);
    % Calculate the phase difference
    Pangle = angle(Pxy);
    % Estimate of the number of independent averages
    N = floor((length(x) - nooverlap) / (length(windown) - nooverlap));
    % Calculate the phase uncertainty
    % Note: The uncertainty formula is an approximation and assumes high SNR and Gaussianity.
    phase_uncertainty = sqrt((1 - abs(Pxy).^2) ./ (2 * N * abs(Pxy).^2));
    % Convert phase difference and uncertainty to degrees
    phase_diff_deg = rad2deg(Pangle);
    phase_uncertainty_deg = rad2deg(phase_uncertainty);
end

if qplot > 0
    figure;
    set(gcf,'color','w');
    set(gcf,'Name','Acycle: coherence and phase');
    subplot(2,1,1)
    plot(F1,Cxy,'k','LineWidth',2)
    ylim([0 1])
    xlim([min(F1), max(F1)])
    yline(MSC_critical,'-.b');
    title('Magnitude-Squared Coherence')
    xlabel('Frequency')
    ylabel('Coherence')
    grid on;
    
    subplot(2,1,2)
    %plot(F2,phase,'r','LineWidth',2)
    errorbar(F2, phase_diff_deg, phase_uncertainty_deg);
    ylim([-180 180])
    xlim([min(F2), max(F2)])
    yline(90,'--k');
    yline(45,':k');
    yline(0,'-k');
    yline(-45,':k');
    yline(-90,'--k');
    title('Cross Spectrum Phase Difference and Uncertainty between Signals')
    xlabel('Frequency')
    ylabel(['Phase Difference (',char(176),')'])
end

if qplot > 1

    figure; 
    set(gcf,'color','w');
    set(gcf,'Name','Acycle: coherence and phase');
    polarscatter(Pangle,F2,Cxy.^2*500,'filled','MarkerFaceAlpha',.5)
    rlim([min(F2) max(F2)])
    title(['Phase lag (0-180',char(176),') and lead (180-360',char(176),')'])
end