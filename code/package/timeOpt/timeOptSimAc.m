function xx = timeOptSimAc(dat,sedrate1,nsim,fit,cormethod,targetE,targetP,fc,fl,fh,roll)

%% timeOptSim script to conduct Monte Carlo simulation of the timeOpt analysis
%
% This script is largely based on: 
%   Steve Meyers's timeOptSim script in astrochron R package, 
%   Steve Meyers's paper (Meyers, 2015, Paleoceanography. doi: 10.1002/2015PA002850), 
%   Linda Hinnov's "TimeSeries" lecture at Geroge Mason University, and 
%   Linda Hinnov's tanerhilbert.m MatLab script in Kodama & Hinnov (2015).
%% Input
% 
%   dat:    data, 2 column depth-domain series. No header. The unit has to be cm
%   sedrate1:  tested sedimentation rate
%   nsim: number of Monte Carlo simulations
%       to generate AR1 surrogates (red noise series) with a rho estimated from "dat" 
%   fit:    Test for (1) precession amplitude modulation or 
%                    (2) short eccentricity amplitude modulation
%                     astrochron notes that the Option #2 is experimental
%                    (default value is 1)
%   cormethod: correlation method.
%           (1 = pearson; 2 = spearman; default = 2)
%   targetE:A vector of eccentricity periods to evaluate (in kyr). 
%           In constract to astrochron, these may not be in order of 
%           decreasing period, with a first value of 405 ka
%   targetP: A vector of precession periods to evaluate (in kyr).
%   fc:     Center frequency for Taner bandpass
%   fl:     Low frequency cut-off for Taner bandpass
%   fh:     High frequency cut-off for Taner bandpass
%
%% Output
%
%   xx: a 3 columns matrix of nsim simulations:
%       1st: r^2_envelope at the corresponding sed. rate
%       2nd: r^2_power at the corresponding sed. rate
%       3rd: r^2_opt at the corresponding sed. rate
%
%% Calls for
%
%   sortrows : MatLab function
%   tanerhilbertML.m : taner hilbert filter
%   fitItls.m :   least square fit
%   harm1ML.m   least squares estimate a and b:  fy = a*cos(w*t) + b*sin(w*t)
%   rhoAR1.m    AR1 rho estimation
%% References: 
%
%   Meyers, S.R., 2015. The evaluation of eccentricity?related 
%       amplitude modulation and bundling in paleoclimate data: 
%       An inverse approach for astrochronologic testing and 
%       time scale optimization. Paleoceanography. doi: 10.1002/2015PA002850
%
%   Meyers, S.R., 2014. astrochron: An R Package for Astrochronology. 
%       http://cran.r-project.org/package=astrochron.
%
%   Kodama, K.P., Hinnov, L., 2015. Rock Magnetic Cyclostratigraphy. Wiley-Blackwell.
%
%% Examples:
%
% #1 generate a 300 random number and run the timeOpt
%   timeOptSimAc();
% #2
%   la04red=load('la04-1-2kRed-new.txt');
%   timeOptSimAc(la04red,2.8,1000);
%
%% By Mingsong Li, Penn State, Jan. 5, 2019
%   mul450@psu.edu; www.mingsongli.com
%
%%
if nargin < 11; roll = 10^12; end
if nargin < 10; fh = 0.065; end
if nargin < 9; fl = 0.035; end
if nargin < 8; fc = (fh+fl)/2; end
if nargin < 7; targetP = [23.62069,22.31868,19.06768,18.91979]; end
if nargin < 6; targetE = [405.6795,130.719,123.839,98.86307,94.87666]; end
if nargin < 5; cormethod = 2; end
if nargin < 4; fit = 1; end
if nargin < 3; nsim = 1000; end
if nargin < 2; sedrate1 = 1; end
if nargin < 1; 
    n = 300; dat(:,1) = (1:n)'; dat(:,2) = filter(1,[1;-0.5],randn(n,1));
end

lsmethod = 1;
n = length(dat(:,1));
rho = rhoAR1(dat(:,2));
yred=filter(1,[1;-rho],randn(n,nsim));
% % precession amplitude modulation
if fit == 1
    targetTot = [targetE,targetP]; 
elseif fit == 2
% short ecc modulation
    targetTot = targetE;
end

xx = nan(nsim,3);

for i = 1:nsim
    x1 = dat(:,1)/sedrate1;
    y = yred(:,i);
    data = [x1,(y-mean(y))/std(y)];
    try [tanhilb,~,~] = tanerhilbertML(data,fc,fl,fh,roll);
        timeSeries(:,1) = tanhilb(:,1);
        timeSeries(:,2) = tanhilb(:,3);
        if fit == 1
            [rsq, ~] = fitItls(timeSeries, sedrate1,targetE, cormethod,lsmethod);
            [rsqpwrOut, ~] = fitItls(data,sedrate1, targetTot, cormethod,lsmethod);
        elseif fit == 2
            [rsq, ~] = fitItls(timeSeries,sedrate1, targetE(1), cormethod,lsmethod);
            [rsqpwrOut, ~] = fitItls(data, sedrate1,targetTot, cormethod,lsmethod);
        end
        
        xx(i,1) = rsq;
        xx(i,2) = rsqpwrOut;
        xx(i,3) = rsq*rsqpwrOut;
    catch
        xx(i,1) = NaN;
        xx(i,2) = NaN;
        xx(i,3) = NaN;
    end
end