function [Cxy,F1,Pxy,F2] = cohac(x,y,sr,window,winsize,nooverlap,threshold,qplot)
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
% 
%
if nargin < 8; qplot = 2; end
if nargin < 7; threshold = 0; end
if nargin < 6; nooverlap = []; end
if nargin < 5; winsize = []; end
if nargin < 4; window = 'hamming'; end
if nargin < 3; sr = 1; end
if nargin < 2; return; end

if window == 'hamming'
    [Cxy,F1] = mscohere(x,y,hamming(winsize),nooverlap,[],1/sr);
    [Pxy,F2] = cpsd(x,y,hamming(winsize),nooverlap,[],1/sr);
end

if threshold > 0
   Pxy(Cxy < threshold) = nan;
end

if qplot > 0
    figure;
    set(gcf,'color','w');
    set(gcf,'Name','Acycle: coherence and phase');
    subplot(2,1,1)
    plot(F1,Cxy,'k','LineWidth',2)
    ylim([0 1])
    xlim([min(F1), max(F1)])
    yline(threshold,'-.b');
    title('Magnitude-Squared Coherence')
    xlabel('Frequency')
    ylabel('Coherence')

    subplot(2,1,2)
    plot(F2,angle(Pxy)/pi * 180,'r','LineWidth',2)
    ylim([-180 180])
    xlim([min(F2), max(F2)])
    yline(90,'--k');
    yline(45,':k');
    yline(0,'-k');
    yline(-45,':k');
    yline(-90,'--k');
    title('Cross Spectrum Phase')
    xlabel('Frequency')
    ylabel(['Lag (',char(176),')'])
end
if qplot > 1
    figure; 
    set(gcf,'color','w');
    set(gcf,'Name','Acycle: coherence and phase');
    polarscatter(angle(Pxy),F2,Cxy.^2*500,'filled','MarkerFaceAlpha',.5)
    rlim([min(F2) max(F2)])
    title(['Phase lag (0-180',char(176),') and lead (180-360',char(176),')'])
    %polarscatter(angle(Pxy(2:end)),1./F(2:end),Cxy(2:end).^2*500,'filled','MarkerFaceAlpha',.5)
    %grid
end