function [freq1,ftest,fsigout,Amp,Faz,Sig,Noi,dof,wt]=ftestmtmML(data,NW,npad,plotn)
% ftestmtmML.m
%
% This script is based on an educational SCILAB script provided by 
% Jeffrey Park (Yale University), who has given permission for its
% adaptation into Matlab for Acycle by:
%
% Linda Hinnov (George Mason University)
% Mingsong Li (Penn State University)
% October 6, 2019
%
% CALLS:
%  mtmdofs.m  - function by L. Hinnov, included below
%  ftestmtm.m - function by L. Hinnov, included below
%  dpss.m - discrete prolate spheroidal sequences, Matlab's Signal Processing Toolbox 
%  fcdf.m - Fisher cumulative distribution, MATLAB Statistics Toolbox
%
% INPUT
%   data: n-by-2 dataset, must be uniformly sampled.
%   NW:   time-bandwidth product to use (e.g. NW=2 for 2pi multitapers)
%   npad: zero pad to npad * length of y (1 for no padding)
%   plotn: 1 for plot, 0 for no plot.
%
% OUTPUT
%	Freq = vector of frequencies
%	ftest = vector with F-ratios
%	fsig = vector of 1-alpha probability for the F-ratios
%   Amp = vector of harmonic amplitude 
%   Faz = vector of harmonic phase (in degrees)
%   Sig = vector of signal (F-ratio nominator)
%   Noi = vector of noise (F-ratio denominator)
%   dof = adaptive weighted dofs (NOTE: input to ftestmtm.m)
%   wt(n,k) = adaptive weights for each of k eigenspectra
%
% EXAMPLE:
% time=0:1:8191;time=time'; % create time scale
% value=randn(8192,1)+sin(2*pi*time/4); %create sine curve+noise
% data=[time,value];plot(data(:,1),data(:,2)); % store in "data" and plot
% [freq,ftest,fsig,Amp,Faz,Sig,Noi,dof,wt]=ftestmtmML(data,2,20,1);
% xlim([0.248, 0.252]); % zoom in on the peak
% This last command might take a few minutes to run.
% A plot of 2pi MTM amplitude and f-test spectra will appear.
% Change NW from 2 to 10 in the last command and run again.    
% Zoom in on the peak and surrounding band and compare.
%
% REFERENCE:
% Thomson, D.J., 1982. Spectrum estimation and harmonic analysis. 
%      Proceedings of the IEEE, 70, 1055-1096.
%
t = data(:,1);
w = data(:,2);
dt = median(diff(t));
% 
% Harmonic analysis of w
%
% Apply mtmdofs.m to analyze adaptive weights wt
% and degrees of freedom dof vs. frequency freq;
% zero pad x 20 (npad=20); remove (mean and) linear trend;
% to use 2pi multitapers, NW=2
%
[~,dof,wt] = mtmdofs(t,detrend(w),NW,npad);
%
% Apply ftestmtm.m to compute Amp, ftest, etc. 
% using output dof from mtmdofs.m with same NW and npad
%
[freq1,ftest,fconf,Amp,Faz,Sig,Noi] = ftestmtm(t,detrend(w),NW,dof,npad);
fnyq = 1/(2*dt);
fsigout = 1-fconf;
if plotn
    figure; 
    subplot(3,1,1)
    plot(freq1, Amp,'color',[0, 0.4470, 0.7410],'LineWidth',1.5)
    xlim([0, fnyq])
    title(['Amplitude, F-test & significance level : ', num2str(NW), '\pi'])
    ylabel('Amplitude')
    
    subplot(3,1,2)
    plot(freq1, ftest,'color','k','LineWidth',1);
    xlim([0, fnyq])
    ylabel('F-ratio')
    
    subplot(3,1,3)
    fsigsh = 0.15;
    fsig1 = fsigout;
    fsig1(fsig1>fsigsh) = fsigsh;
    %yyaxis right
    plot(freq1, fsig1,'color','red','LineWidth',1);
    ylim([0.0, fsigsh])
    xlim([0, fnyq])
    line([0 fnyq],[.10 .10],'Color','k','LineWidth',0.5,'LineStyle',':')
    line([0 fnyq],[.05 .05],'Color','m','LineWidth',0.35,'LineStyle','-.')
    line([0 fnyq],[.01 .01],'Color','r','LineWidth',0.5,'LineStyle','--')
    yticks([0.0 0.01 0.05 0.10 0.15])
    yticklabels({'0','0.01', '0.05', '0.10','0.15'})
    ylabel('F-test significance level')
    xlabel('Frequency')
    set(gca, 'YDir','reverse')
end



