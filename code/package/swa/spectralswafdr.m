
function [outputdata] = spectralswafdr(data, method, nw, padtimes, plotn)
%% Spectral analysis using smoothed window averages method showing FDR
% INPUT
%   data: 2 column, evenly spaced, mean = 0
%   method: spectral analysis method: options are 'mtm', 'lomb'
%   nw: 
%   nzeropad:
%   plotn: plot data = 1; no plot = 0
% OUTPUT
%  outputdata: 13 column data
%       [freq, pxx, swa, specchi2cl, clfdr]
%       where
%       specchi2cl: chi90%, chi95%, chi99%, chi99.9%, chi99.99%
%       clfdr: 10% FDR, 5% FDR, 1% FDR, 0.1% FDR, 0.01% FDR
% By Mingsong Li
%   Peking University
%   Oct. 7, 2023
%%
%nw = 2;
%padtimes = 1;
%plotn = 1;
%method = 'mtm';
%method = 'lomb';
%
%data = load('Example-LateTriassicNewarkDepthRank.txt');
%data(:,2) = data(:,2) - mean(data(:,2)); % remove the mean
%data = load('Example-WayaoCarnianGR0-rsp0.33-linear-80-LOWESS.txt');
%
if nargin < 5; plotn = 0; end
if nargin < 4; padtimes =1; end
if nargin < 3; nw = 2; end
if nargin < 2; method = 'mtm'; end

%% basic parameters
datax = data(:,1);  % depth or time
datay = data(:,2);  % value
dt = mean(diff(datax)); % mean sampling rate
ndata = length(datax); % data length
nzeropad = padtimes * ndata;  % number of padding times 

% DOF
if strcmp(method,'mtm')
    K = 2 * nw -1;   % for 2 pi MTM, nw = 2, K = 3, dof = 6;
    dof = 2*(K);  % dof, swa dof = 8;
elseif strcmp(method,'lomb')
    dof = 2; % 
end

%% power spectral analysis
if strcmp(method,'mtm')
    % Multi-taper method power spectrum
    if nw == 1
        [pxx,w] = pmtm(datay,nw,nzeropad,'DropLastTaper',false);
    else
        [pxx,w] = pmtm(datay,nw,nzeropad);
    end
    % Nyquist frequency
    fn = 1/(2*dt);
    % true frequencies
    freq = w/pi*fn;
elseif strcmp(method,'lomb')
    % Lomb-Scargle
    fmax = 1/(2 * dt);
    datax = datax + abs(min(datax));
    [pxx,freq] = plomb(datay,datax,fmax);
end

% log power values
xlogp = log10(pxx);

%% run spec swa method to get the smoothed window averages
[swa, winfinal] = specswa(freq, xlogp, ndata);
%%
chi2_inv_value = [...
    chi2inv(0.90,dof)/dof, ...
    chi2inv(0.95,dof)/dof,...
    chi2inv(0.99,dof)/dof, ...
    chi2inv(0.999,dof)/dof, ...
    chi2inv(0.9999,dof)/dof];

% Chi-square inversed distribution
chi90 = swa * chi2_inv_value(1);
chi95 = swa * chi2_inv_value(2);
chi99 = swa * chi2_inv_value(3);
chi999 = swa * chi2_inv_value(4);
chi9999 = swa * chi2_inv_value(5);

specchi2cl = [chi90,chi95,chi99,chi999,chi9999];

%%

%  Save chi2 CL
    % 
    date = datestr(now,30);
    %outfile = ['Spectrum-SWA-Chi2CL-',date,'.dat'];
    outfile = ['Spectrum-SWA-Chi2CL.dat'];
    fidout = fopen(outfile, 'w');

    % Write out results
    fprintf(fidout, '%%Data filename = %s\n');
    fprintf(fidout, '%%Multiplication factor for 99.99%% Chi2 CL = %7.5f\n', chi2_inv_value(5));
    fprintf(fidout, '%%Multiplication factor for  99.9%% Chi2 CL = %7.5f\n', chi2_inv_value(4));
    fprintf(fidout, '%%Multiplication factor for   99%% Chi2 CL = %7.5f\n', chi2_inv_value(3));
    fprintf(fidout, '%%Multiplication factor for   95%% Chi2 CL = %7.5f\n', chi2_inv_value(2));
    fprintf(fidout, '%%Multiplication factor for   90%% Chi2 CL = %7.5f\n', chi2_inv_value(1));
    formatspec_410 = '%%     Frequency       Real_Power   SWA_background        90%%Chi2CL        95%%Chi2CL        99%%Chi2CL      99.9%%Chi2CL     99.99%%Chi2CL\n';
    formatspec_420 = '%15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f\n';
    nout = length(swa);
    for i = 1:nout
        if i == 1
            fprintf(fidout, formatspec_410); % Assuming you have format specifiers defined somewhere
        end
        fprintf(fidout, formatspec_420, freq(i), pxx(i), swa(i), swa(i)*chi2_inv_value(1), swa(i)*chi2_inv_value(2), swa(i)*chi2_inv_value(3), ...
            swa(i)*chi2_inv_value(4), swa(i)*chi2_inv_value(5));
    end
    fclose(fidout);
    
%% False Discovery Rate (FDR, Benjamini & Hochberg, 1995) algorithm
% based on Miller et al (2001).
% Obtain variance ratio according to confidence level for
% # degrees of freedom.
nlevs = 1100000;
disp('Setting up probability listing...')  % output here     
alpha1 = 0.000000001 * ones(100001, 1);
alpha1 = cumsum(alpha1);
alpha2 = 0.0000001 * ones(nlevs-100001, 1);
alpha2 = cumsum(alpha2);
alpha = [alpha1; alpha2 + alpha1(end)];
factor = chi2inv(1-alpha, dof)/dof;
clev = (1.0 - alpha)*100.0;
disp('   ... completed') % output here

% find prob level
% debug for find prob. levels
nout = length(freq);
anout = nout;
pow1 = pxx;
tdif = max(datax) - min(datax);
xfint=1/tdif; % Rayleigh frequency (freq spacing)
%%
% Allow for correlation of spectral estimates by setting CN.
% Based on Hopkins et al. (2002) using the resolution bandwidth
% of the spectrum (BW) in place of the width of the point-spread
% function in astronomical images.
% ncorr = bw/xfint;

if strcmp(method,'mtm')
    bw = xfint * nw;  % for pmtm method
elseif strcmp(method,'lomb')
    bw = xfint * 1;  % for plomb method ??? 
end
%% 
% Find probability level (ALPHA) by frequency based on Chi2 
% for DOF from list (FACTOR) by comparing power (POW1) to
% the background spectrum (SWA)
disp(['  Find probability level (ALPHA) by frequency based on chi2 for DOF = ',num2str(dof)])

max_factob  = 0;
alphob = zeros(nout,1);
factoball = zeros(nout,1);

for i = 1:nout
    factob = pow1(i) / swa(i);   % =Variance ratio (since the power is periodogram-based)
    factoball(i) = factob;

    if factor(1) < factob    % if p < 0.000000001 
        alphob(i) = alpha(1);  
    end
    j = find(factor > factob,1,'last');
    
    if j < nlevs
        alphob(i) = alpha(j+1);
    elseif j == nlevs
        alphob(i) = alpha(j);
    end
    
    if alphob(i) == 0   % Indicates FACTOB < min FACTOR
        fprintf('\n *** ALPHOB not determined *** \n');
        fprintf('              I= %d \n', i);
        fprintf('         FACTOB= %f \n', factob);
        fprintf('      FACTOR(I)= %f \n', factor(i));
        fprintf('    FACTOR(I+1)= %f \n', factor(i+1));
        fprintf('\n');
        fprintf(' NOUT= %d,  NLEVS= %d \n', nout, nlevs);
        fprintf('\n');
        fprintf(' Stopping... \n');
        fprintf('\n');
        return;   % Equivalent of STOP in Fortran
    end
end

max_factob = max(factoball); % find max factob

disp('  Find probability level : completed')

% Step 1 of Miller et al. (2001): Sort probabilities observed
% (smallest to largest alpha).
%alphsort = alphob;
alphsort = [0;alphob];  % debug, add 0
alphsort = hpsort(alphsort);

% Allow for correlation of spectral estimates by setting CN.
% Based on Hopkins et al. (2002) using the resolution bandwidth
% of the spectrum (BW) in place of the width of the point-spread
% function in astronomical images.

% number of correlated values
ncorr = bw/xfint;
cn = 0;

% CN from Hopkins et al. (2002)
for i = 1: ncorr
    ai = i;
    cn = cn +1/ai; 
end

% Step 2 of Miller et al. (2001): Find j_alpha according to
%  probability rank, j.

jalpha10 = zeros(1,nout);
jalpha5 = zeros(1,nout);
jalpha1 = zeros(1,nout);
jalpha01 = zeros(1,nout);
jalpha001 = zeros(1,nout);
for j = 1:nout
    jalpha10(j) = j * 0.1 / (cn * anout);
    jalpha5(j)  = j * 0.05 / (cn * anout);
    jalpha1(j)  = j * 0.01 / (cn * anout);
    jalpha01(j) = j * 0.001 / (cn * anout);
    jalpha001(j)= j * 0.0001 / (cn * anout);
end

% Step 3 of Miller et al. (2001): Find differences between
% observed probabilities and j_alpha.

maxneg10 = -1;
maxneg5 = -1;
maxneg1 = -1;
maxneg01 = -1;
maxneg001 = -1;
for i = 1:nout
    if alphsort(i) > 0
        jdiff10 = alphsort(i) - jalpha10(i);
        jdiff5 = alphsort(i) - jalpha5(i);
        jdiff1 = alphsort(i) - jalpha1(i);
        jdiff01 = alphsort(i) - jalpha01(i);
        jdiff001 = alphsort(i) - jalpha001(i);
        
        if jdiff10 < 0
            maxneg10 = i; 
        end
        if jdiff5 < 0
            maxneg5 = i; 
        end
        if jdiff1 < 0
            maxneg1 = i; 
        end
        if jdiff01 < 0
            maxneg01 = i; 
        end
        if jdiff001 < 0
            maxneg001 = i;
        end
    end
    % debug
%     if i < 21
%         fprintf(' j=%d  asort=%.12f  ja1=%.12f  jd1=%.12f\n', i, alphsort(i), jalpha1(i), jdiff1);
%         fprintf(' j=%d  asort=%.12f  ja5=%.12f  jd1=%.12f\n', i, alphsort(i), jalpha5(i), jdiff5);
%     end

end

% debug
disp(['maxneg 10%, 5%, 1%, 0.1%, 0.01% FDR INDEX = ', num2str(maxneg10),',  ', num2str(maxneg5),',  ',  num2str(maxneg1),',  ',  num2str(maxneg01), ',  ', num2str(maxneg001)])

% Step 4 of Miller et al. (2001): Find probability rank index
% where the diffence is negative.
% Establish factors for FDR confidence levels.
fprintf('\n');
fprintf(' In the spectrum, relative to the SWA\n');
fprintf('                     Max variance ratio = %8.5f\n', max_factob);
fprintf('\n');
%
nneg = 0;

if maxneg001 > 0 && maxneg001 ~= maxneg01
    fdr001p = 100.0 * (1.0 - alphsort(maxneg001));
    for i = 1:nlevs
        if alphsort(maxneg001) == alpha(i)
            fdr001 = factor(i);
        end
    end
    fprintf('                       0.01%% FDR Factor = %8.5f\n', fdr001);
    fprintf(' Chi2 confidence level for 0.01%% FDR CL = %10.7f%%\n', fdr001p);

    nneg = 1;
end

if maxneg01 > 0 && maxneg01 ~= maxneg1
    fdr01p = 100.0 * (1.0 - alphsort(maxneg01));
    for i = 1:nlevs
        if alphsort(maxneg01) == alpha(i)
            fdr01 = factor(i);
        end
    end
    fprintf('                        0.1%% FDR Factor = %8.5f\n', fdr01);
    fprintf('  Chi2 confidence level for 0.1%% FDR CL = %10.7f%%\n', fdr01p);

    nneg = 1;
end

if maxneg1 > 0 && maxneg1 ~= maxneg5
    fdr1p = 100.0 * (1.0 - alphsort(maxneg1));
    for i = 1:nlevs
        if alphsort(maxneg1) == alpha(i)
            fdr1 = factor(i);
        end
    end
    fprintf('                          1%% FDR Factor = %8.5f\n', fdr1);
    fprintf('    Chi2 confidence level for 1%% FDR CL = %10.7f%%\n', fdr1p);

    nneg = 1;
end

if maxneg5 > 0
    fdr5p = 100.0 * (1.0 - alphsort(maxneg5));
    for i = 1:nlevs
        if alphsort(maxneg5) == alpha(i)
            fdr5 = factor(i);
        end
    end
    fprintf('                          5%% FDR Factor = %8.5f\n', fdr5);
    fprintf('    Chi2 confidence level for 5%% FDR CL = %10.7f%%\n', fdr5p);

    nneg = 1;
end

if maxneg10 > 0
    fdr10p = 100.0 * (1.0 - alphsort(maxneg10));
    for i = 1:nlevs
        if alphsort(maxneg10) == alpha(i)
            fdr10 = factor(i);
        end
    end
    if maxneg5 == 0
        fprintf('                         10%% FDR Factor = %8.5f\n', fdr10);
        fprintf('   Chi2 confidence level for 10%% FDR CL = %10.7f%%\n', fdr10p);
    end
    nneg = 1;
end

if nneg == 0
    fprintf('\n');
    fprintf('\n');
    fprintf(' *** No spectral peaks exceed the ***\n');
    fprintf(' *** confidence level associated  ***\n');
    fprintf(' *** with the 5% False Discovery  ***\n');
    fprintf(' *** Rate                         ***\n');
else
    fprintf('\n');
    fprintf('\n');
    fprintf(' Significant spectral peak(s):\n');
    fprintf('\n');
    fprintf('       Frequency   Period/Wlength    Rel. Power     CL\n');
end

%%
cl001 = NaN(1, nout);
cl01 = NaN(1, nout);
cl1 = NaN(1, nout);
cl5 = NaN(1, nout);
cl10 = NaN(1, nout);
cout4 = 0;
cout3 = 0;
cout2 = 0;
cout1 = 0;
cout0 = 0;
% Loop through nout-1 elements

% Assuming nout, maxneg001, maxneg01, swa, fdr001, maxneg1, fdr01, maxneg5, fdr5, maxneg10, fdr10, and pow1 are pre-defined

for i = 1:nout-1
    sigstop = 0;
    
    % Check condition related to maxneg001
    if maxneg001 > 0 && maxneg001 ~= maxneg01
        cout4 = 1;
        cl001(i) = swa(i) * fdr001;
        cl001(nout) = swa(nout) * fdr001;
        
        if pow1(i) > cl001(i) && i == 1 && pow1(i) > pow1(i+1)
            fprintf('%f %f %f %f\n', freq(i), 1/freq(i), pow1(i), cl001(i));
            sigstop = 1;
        end
        
        if pow1(i) > cl001(i) && i > 1 && pow1(i) > pow1(i-1) && pow1(i) > pow1(i+1)
            fprintf('%f %f %f %f\n', freq(i), 1/freq(i), pow1(i), cl001(i));
            sigstop = 1;
        end
        
        if pow1(nout) > cl001(nout) && i == nout-1 && pow1(nout) > pow1(i)
            fprintf('%f %f %f %f\n', freq(nout), 1/freq(nout), pow1(nout), cl001(nout));
            sigstop = 1;
        end
    end

    % Check condition related to maxneg01
    if maxneg01 > 0 && maxneg01 ~= maxneg1
        cout3 = 1;
        cl01(i) = swa(i) * fdr01;
        cl01(nout) = swa(nout) * fdr01;
        
        if sigstop == 0 && pow1(i) > cl01(i) && i == 1 && pow1(i) > pow1(i+1)
            fprintf('%f %f %f\n', freq(i), 1/freq(i), pow1(i));
            sigstop = 1;
        end
        
        if sigstop == 0 && pow1(i) > cl01(i) && i > 1 && pow1(i) > pow1(i-1) && pow1(i) > pow1(i+1)
            fprintf('%f %f %f\n', freq(i), 1/freq(i), pow1(i));
            sigstop = 1;
        end
        
        if sigstop == 0 && pow1(nout) > cl01(nout) && i == nout-1 && pow1(nout) > pow1(i)
            fprintf('%f %f %f\n', freq(nout), 1/freq(nout), pow1(nout));
            sigstop = 1;
        end
    end
    
    % Check condition related to maxneg1

    if maxneg1 > 0 && maxneg1 ~= maxneg5
        cout2 = 1;
        cl1(i) = swa(i) * fdr1;
        cl1(nout) = swa(nout) * fdr1;

        if sigstop == 0 && pow1(i) > cl1(i) && i == 1 && pow1(i) > pow1(i+1)
            fprintf('%f %f %f\n', freq(i), 1/freq(i), pow1(i));
            sigstop = 1;
        end

        if sigstop == 0 && pow1(i) > cl1(i) && i > 1 && pow1(i) > pow1(i-1) && pow1(i) > pow1(i+1)
            fprintf('%f %f %f\n', freq(i), 1/freq(i), pow1(i));
            sigstop = 1;
        end

        if sigstop == 0 && pow1(nout) > cl1(nout) && i == nout-1 && pow1(nout) > pow1(i)
            fprintf('%f %f %f\n', freq(nout), 1/freq(nout), pow1(nout));
            sigstop = 1;
        end
    end


    % Check condition related to maxneg5
    if maxneg5 > 0
        cout1 = 1;
        cl5(i) = swa(i) * fdr5;
        cl5(nout) = swa(nout) * fdr5;

        if sigstop == 0 && pow1(i) > cl5(i) && i == 1 && pow1(i) > pow1(i+1)
            fprintf('%f %f %f\n', freq(i), 1/freq(i), pow1(i));
            sigstop = 1;
        end

        if sigstop == 0 && pow1(i) > cl5(i) && i > 1 && pow1(i) > pow1(i-1) && pow1(i) > pow1(i+1)
            fprintf('%f %f %f\n', freq(i), 1/freq(i), pow1(i));
        end

        if sigstop == 0 && pow1(nout) > cl5(nout) && i == nout-1 && pow1(nout) > pow1(i)
            fprintf('%f %f %f\n', freq(nout), 1/freq(nout), pow1(nout));
            sigstop = 1;
        end
    end


    % Check condition related to maxneg10
    if maxneg10 > 0 && maxneg10 ~= maxneg5 && maxneg5 == 0
        cout0 = 1;
        cl10(i) = swa(i) * fdr10;
        cl10(nout) = swa(nout) * fdr10;

        if sigstop == 0 && pow1(i) > cl10(i) && i == 1 && pow1(i) > pow1(i+1)
            fprintf('%f %f %f\n', freq(i), 1/freq(i), pow1(i));
            sigstop = 1;
        end

        if sigstop == 0 && pow1(i) > cl10(i) && i > 1 && pow1(i) > pow1(i-1) && pow1(i) > pow1(i+1)
            fprintf('%f %f %f\n', freq(i), 1/freq(i), pow1(i));
        end

        if sigstop == 0 && pow1(nout) > cl10(nout) && i == nout-1 && pow1(nout) > pow1(i)
            fprintf('%f %f %f\n', freq(nout), 1/freq(nout), pow1(nout));
            sigstop = 1;
        end
    end
end

clfdr = [cl10',cl5',cl1',cl01',cl001'];

%%
% 
outfile = 'SWA-Spectrum-background-FDR.dat';
fidout = fopen(outfile, 'w');

% Write out results
%fprintf(fidout, '%%Data filename = %s\n', tsfile);
fprintf(fidout, '%%Data filename = %s\n', ' ');
%fprintf(fidout, '%%Sum of power = %15.7f\n', sumpower);

if cout4 == 1
    fprintf(fidout, '%%Multiplication factor for 0.01%% FDR = %7.5f Chi2 CL=%11.6f%%\n', fdr001, fdr001p);
end
if cout3 == 1
    fprintf(fidout, '%%Multiplication factor for  0.1%% FDR = %7.5f Chi2 CL=%11.6f%%\n', fdr01, fdr01p);
end
if cout2 == 1
    fprintf(fidout, '%%Multiplication factor for   1%% FDR = %7.5f Chi2 CL=%11.6f%%\n', fdr1, fdr1p);
end
if cout1 == 1
    fprintf(fidout, '%%Multiplication factor for   5%% FDR = %7.5f Chi2 CL=%11.6f%%\n', fdr5, fdr5p);
end
if cout0 == 1 && maxneg10 ~= maxneg5 && maxneg5 == 0
    fprintf(fidout, '%%Multiplication factor for 10%% FDR = %7.5f Chi2 CL=%11.6f%%\n', fdr10, fdr10p);
end

formatspec_410 = '%%     Frequency   Period/Wavelength       Rel. Power   SWA_background\n';
formatspec_420 = '%15.7f  %15.7f  %15.7f  %15.7f\n';

formatspec_411 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background           5%% FDR           1%% FDR         0.1%% FDR       0.01%% FDR\n';
formatspec_421 = '%15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f\n';

formatspec_412 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background           5%% FDR          0.1%% FDR        0.01%% FDR\n';
formatspec_422 = '%15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f\n';

formatspec_413 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background           5%% FDR           1%% FDR         0.01%% FDR\n';
formatspec_414 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background           5%% FDR           1%% FDR         0.1%% FDR\n';

formatspec_415 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background           5%% FDR         0.01%% FDR\n';
formatspec_423 = '%15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f\n';

formatspec_416 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background           5%% FDR          0.1%% FDR\n';
formatspec_417 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background           5%% FDR          1%% FDR\n';

formatspec_418 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background           5%% FDR\n';
formatspec_424 = '%15.7f  %15.7f  %15.7f  %15.7f  %15.7f\n';

formatspec_419 = '%%     Frequency Period/Wavelength       Rel.Power   SWA_background          10%% FDR\n';

for i = 1:nout
    if cout4 == 0 && cout3 == 0 && cout2 == 0 && cout1 == 0
        if i == 1
            fprintf(fidout, formatspec_410); % Assuming you have format specifiers defined somewhere
        end
        fprintf(fidout, formatspec_420, freq(i), 1.0/freq(i), pow1(i), swa(i));
        
    elseif cout4 == 1 && cout3 == 1 && cout2 == 1 && cout1 == 1
        if i == 1
            fprintf(fidout, formatspec_411);
        end
        fprintf(fidout, formatspec_421, freq(i), 1.0/freq(i), pow1(i), swa(i), cl5(i), cl1(i), cl01(i), cl001(i));
        
    elseif cout4 == 1 && cout3 == 1 && cout2 == 0 && cout1 == 1
        if i == 1
            fprintf(fidout, formatspec_412);
        end
        fprintf(fidout, formatspec_422, freq(i), 1.0/freq(i), pow1(i), swa(i), cl5(i), cl01(i), cl001(i));
        
    elseif cout4 == 1 && cout3 == 0 && cout2 == 1 && cout1 == 1
        if i == 1
            fprintf(fidout, formatspec_413);
        end
        fprintf(fidout, formatspec_422, freq(i), 1.0/freq(i), pow1(i), swa(i), cl5(i), cl1(i), cl001(i));
        
    elseif cout4 == 0 && cout3 == 1 && cout2 == 1 && cout1 == 1
        if i == 1
            fprintf(fidout, formatspec_414);
        end
        fprintf(fidout, formatspec_422, freq(i), 1.0/freq(i), pow1(i), swa(i), cl5(i), cl1(i), cl01(i));
        
    elseif cout4 == 1 && cout3 == 0 && cout2 == 0 && cout1 == 1
        if i == 1
            fprintf(fidout, formatspec_415);
        end
        fprintf(fidout, formatspec_423, freq(i), 1.0/freq(i), pow1(i), swa(i), cl5(i), cl001(i));
        
    elseif cout4 == 0 && cout3 == 1 && cout2 == 0 && cout1 == 1
        if i == 1
            fprintf(fidout, formatspec_416);
        end
        fprintf(fidout, formatspec_423, freq(i), 1.0/freq(i), pow1(i), swa(i), cl5(i), cl01(i));
        
    elseif cout4 == 0 && cout3 == 0 && cout2 == 1 && cout1 == 1
        if i == 1
            fprintf(fidout, formatspec_417);
        end
        fprintf(fidout, formatspec_423, freq(i), 1.0/freq(i), pow1(i), swa(i), cl5(i), cl1(i));
        
    elseif cout4 == 0 && cout3 == 0 && cout2 == 0 && cout1 == 1
        if i == 1
            fprintf(fidout, formatspec_418);
        end
        fprintf(fidout, formatspec_424, freq(i), 1.0/freq(i), pow1(i), swa(i), cl5(i));
        
    elseif cout4 == 0 && cout3 == 0 && cout2 == 0 && cout1 == 0 && cout0 == 1
        if i == 1
            fprintf(fidout, formatspec_419);
        end
        fprintf(fidout, formatspec_424, freq(i), 1.0/freq(i), pow1(i), swa(i), cl10(i));
    end
end

fclose(fidout);

% Display output file
disp(' ');
disp(['Output file= ' outfile]);
disp(' ');

outputdata = [freq, pxx, swa, specchi2cl, clfdr];

if plotn == 1 
    figure; 
    hold on
    %% plot FDR
    if ~isnan(clfdr(1,5))  % 0.01% FDR
        plot(freq, clfdr(:,5),'k-.','LineWidth',0.5,'DisplayName','0.01% FDR');
    end
    if ~isnan(clfdr(1,4))  % 0.1% FDR
        plot(freq, clfdr(:,4),'g-.','LineWidth',0.5,'DisplayName','0.1% FDR'); % 0.1% FDR
    end
    if ~isnan(clfdr(1,3))  % 1% FDR
        plot(freq, clfdr(:,3),'b--','LineWidth',0.5,'DisplayName','1% FDR'); % 1% FDR
    end
    if ~isnan(clfdr(1,2))  % 5% FDR
        plot(freq, clfdr(:,2),'r--','LineWidth',2,'DisplayName','5% FDR'); % 5% FDR
    end
    
    plot(freq,chi9999,'g:','LineWidth',0.5,'DisplayName','Chi2 99.99% CL')
    plot(freq,chi999,'m-','LineWidth',0.5,'DisplayName','Chi2 99.9% CL')
    plot(freq,chi99,'b-','LineWidth',0.5,'DisplayName','Chi2 99% CL')
    plot(freq,chi95,'r-','LineWidth',1.5,'DisplayName','Chi2 95% CL')
    plot(freq,chi90,'k--','LineWidth',0.5,'DisplayName','Chi2 90% CL')
    plot(freq,swa,'k-','LineWidth',1.5,'DisplayName','Backgnd')
    plot(freq, pxx,'k-','LineWidth',0.5,'DisplayName','Power'); 
    legend
    set(gca,'YScale','log');
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gcf,'Color', 'white')
    xlabel('Frequency')
    ylabel('Power')
end
