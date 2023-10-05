function [freq, pow2,bayesprob]=specbayes(data_r, plotn, varargin)

% Program for generating Bayesian probability spectrum of a time_ml series.

% Outline:  A re-scaled periodogram based on the Lomb-Scargle algorithm for
%           data transformation is normalised to produce the Bayesian
%           probability that one regular sinusoid is present in the time_ml
%           series.
%           Weedon et al. (2019) introduced use of Bayesian probability
%           spectra to cyclostratigraphy. Weedon (2020) established that
%           pre-whitening is essential to avoid false_ml positives at low
%           frequencies. Weedon (2022) showed that the Bayesian probabilities
%           are consistent with the false_ml positive rates.

% Methodology/Fair use cite:
%       Weedon, G.P., 2022. Problems with the current practice of spectral
%           analysis in cyclostratigraphy: avoiding false_ml detection of regular
%           cyclicity. Earth-Sci. Rev. 235,
%           https://doi.org/10.1016/j.earscirev.2022.104261
%       Weedon, G.P., 2020. Confirmed detection of Palaeogene and Jurassic
%           orbitally-forced sedimentary cycles in the depth domain using
%           false_ml Discovery Rates and Bayesian probability spectra. Boletin
%           Geologico y Minero, 131, 207-230,
%           https://doi.org/10.2170/bolgeomin.131.2.001
%       Weedon, G.P., Page, K.N., and Jenkyns, H.C., 2019. Cyclostratigraphy,
%           stratigraphic gaps and the duration of the Hettangian (Jurassic):
%           insights from the Blue Lias Formation of Southern Britain. Geol.
%           Mag. 156, 1469-1509, https://doi.org/10.1017/S0016756818000808

% Additional notes: The periodogram provides a very crude 'average'
%       estimation of the variance distribution of the full time_ml series by
%       frequency. It is crude because the averaging only has two degrees
%       of freedom so the spectral estimates are scattered round the
%       theoretical expected spectrum. However, the Bayesian probability
%       calculations are designed for Lomb-Scargle periofdograms. Linear
%       detrending is used to ensure stationarity in the local mean. It is
%       assumed that the data are approximately stationary in terms of the
%       local (in time_ml/space) variance.

% Data format:
%           The single data file must be fixed-width column ascii.
%
%           Input files must have no headers with one time_ml step on each line.
%           Column 1 = Time/stratigraphic position, column 2 = Time series
%           value.

% Input:
%           Number of time_ml steps, N, is constrained: 50 > N > 300000.
%           Required for every time_ml step:
%           1) Time stamps:
%           For formatted ascii data provide continuous time_ml position
%              For example if time_ml unit is in years:
%              e.g. Monthly time_ml step:          March 2015 = 2015.20411
%              e.g. Daily time_ml step:        3rd March 2015 = 2015.17123
%              e.g. Hourly time_ml step: 08:00 3rd March 2015 = 2015.168037
%           2) Observed variable value.

% Missing and/or irregularly spaced data:
%           When the data have varying time_ml/depth step lengths the program
%           detects the irregular data spacing and uses the Lomb-Scargle
%           Discrete Fourier Transform (or Lomb-Scargle Transform).
%           IMPORTANT: To avoid bias in the program output:
%           1) Do not 'gap fill' or interpolate the data.
%           2) Do not use missing data flags.
%           3) Only provide data for time_ml steps where are available.

% Output:
%           The output file, in ascii, contains:
%           a) Frequency.
%           b) Period/Wavelength.
%           c) Periodgram Power.
%           d) Bayesian probability.

% Created by: Graham P. Weedon, Met Office, UK.

% MatLab version by
%   Mingsong Li, Peking University, China
%   Oct. 4, 2023

%clear all; %clear functions;

global unit2fid;  
if ~isempty(unit2fid)
    unit2fid=[]; 
end

persistent ctlim difft diffx fmt i ii ios j k l lmn maxprob ndata ...
    nint_ml nirr nmax nmaxb nrev nrevint outfile proc slope tdif ...
    time_ml tsfile x1 xfit xinterc xnyq ; 

% information display
format_1=[' NB: Dimensioned for a maximum of','%7d',' time steps'];
format_120=['       Time/strat range = ','%15.7f'];
format_121=['          Rayleigh Freq = ','%15.7f'];
format_122=['           Nyquist Freq = ','%15.7f'];
format_123=['       No. output freqs =  ','%6d'];
format_124=[' No. degrees of freedom =      ','%2d'];
format_152=['       Max. probability =       ','%5.3f'];
format_153=['              Frequency = ','%15.7f'];
format_154=['      Period/Wavelength = ','%15.7f'];
format_18=['  Time(1) = ','%12.7f',' Obs(1) = ','%11.5f'];
format_20=['  Time(N) = ','%12.7f',' Obs(N) = ','%11.5f'];
format_22=['  Number of time steps = ','%7d'];
format_24=['  *** The number of time steps exceeds ','%7d','***'];
format_281=['%2x','%15.7f','%2x','%15.7f','%2x','%15.7f','%2x','%15.7f'];
format_8=['  *** Error opening ','%c'];
format_80=['  Time step      Line number'];
format_82=['%2x','%12.7f','%4x','%7d'];
format_88=[' *** PROBLEM: There are ','%7d',' equal ***'];
format_90=['   *** spaced values/gaps at ','%7d','      steps. ***'];
format_91=['   *** Minimum interval detected = ','%12.7f','  ***'];
format_92=['   *** Maximum interval detected = ','%12.7f','  ***'];
format_94=[' Maximum time interval = ','%12.7f'];
format_95=[' Minimum time interval = ','%12.7f'];

% Declaring constants
nmax = 300001;
nmaxb = floor(nmax/2);  % Ensure it is an integer in MATLAB

% Integer variables
i = 0; ii = 0; j = 0; k = 0; l = 0; ctlim = 0; ios = 0; nint = 0;
nrev = 0; nirr = 0; nrevint = 0; ndata = 0; nout = 0; lfit = 0;
status = 0; line1 = 0; ndx = 0; ndt = 0; iyear = 0; al = 0; nhuge = 0;
ndof = 0; maxib = 0;

% Real variables
diffx = 0; difft = 0; slope = 0; xfit = 0; xinterc = 0; maxprob = 0;

% Double Precision arrays
xnyq = 0; x1 = zeros(nmax, 1); time = zeros(nmax, 1); tdif = 0;
pow1 = zeros(nmaxb, 1); pow = zeros(nmaxb, 1); posirreg1 = 0; tint = 0;
tint1 = 0; tintmin = 0; tintmax = 0; tintva = 0; tintvb = 0; xfint = 0;
anout = 0; avex = 0; varx = 0; sum = 0; andata = 0; varx1 = 0; rho1 = 0;
rhox1 = 0; freq = zeros(nmaxb, 1); xpw1 = zeros(nmax, 1); sumd2 = 0;
aved2 = 0; bayr = 0; sumbayes = 0; 

% Character variables
tsfile = ''; proc = ''; lmn = ''; fmt = ''; outfile = '';

% Code listed below specBAYES using published algorithms
% as subroutines (references listed at end of file):

[~]=writeFmt(1,[]);
[~]=writeFmt(1,['%c'],''' ***       Program specBayes.f:        ***''');
[~]=writeFmt(1,['%c'],''' ***  Lomb-Scargle derived periodogram ***''');
[~]=writeFmt(1,['%c'],''' ***  used to derive the Bayesian      ***''');
[~]=writeFmt(1,['%c'],''' ***  probability of a single regular  ***''');
[~]=writeFmt(1,['%c'],''' ***  cycle in a time_ml series.          ***''');
[~]=writeFmt(1,[]);
[~]=writeFmt(1,[format_1],'nmax-1');

%% Specify file name (TSFILE) and open file.
%% Read in data.
%% dubug start
%data_r = load('bcaco3-sue.txt'); 
x1 = data_r(:,2); 
time_ml=data_r(:,1); 
ndata=length(x1); 
andata=ndata;
% plotn
%dubug end
%% Check for variability in both the time_ml/position and data values.
%% Check for irregularly spaced data. Compare observations/reference times
% for first two points with all others. If variation exceeds +/-5.0%
% then data are considered to be irregularly spaced.
% If identical or reversed time_ml/positions are detected then output list
% to file tsrev.dat and stop program.
line1=0;
posirreg1=0.0d0;
nint_ml=0;
nrev=0;
nirr=0;
nrevint=0;
tintmax=0.0d0;
tintmin=0.0d0;
tint1=0.0d0;
tint1=time_ml(1)-time_ml(2);

if(tint1 > 0.0)
    tdif=time_ml(1)-time_ml(ndata);
    tintmin=tint1;
    tintmax=tint1;
    tintva=tint1.*1.05;
    tintvb=tint1.*0.95;
    for  i=2:(ndata-1)
        tint=time_ml(i)-time_ml(i+1);
        if(tint <= 0.0)
            nrev=nrev+1;
        end 
        if(nrev == 1)
            nrevint=nrevint+1;
            if(nrevint == 1)
            	hismlfid=fopen(strtrim('tsrev.dat'),'r+');
                unit2fid=[unit2fid;11,thismlfid];
                [~]=writeFmt(11,[format_80]);
            end 
        end 
        if(tint <= 0.0)
            [~]=writeFmt(11,[format_82],'time_ml(i+1)','i');
        end 
        if(tint > tintva)
            nint_ml=nint_ml+1;
            if(line1 == 0)
                line1=i;
                posirreg1=time_ml(i);
            end 
            if(tintmax < tint)
                tintmax=tint;
            end 
        end 
        if(tint < tintvb)
            nint_ml=(nint_ml+1);
            if(line1 == 0)
                line1=i;
                posirreg1=time_ml(i);
            end 
            if(tintmin > tint)
                tintmin=tint;
            end 
        end 
    end
else
    tdif=time_ml(ndata)-time_ml(1);
    tint1=time_ml(2)-time_ml(1);
    tintmin=tint1;
    tintmax=tint1;
    tintva=tint1.*1.05;
    tintvb=tint1.*0.95;
    for  i=2:(ndata-1)
        tint=time_ml(i+1)-time_ml(i);
        if(tint <= 0.0)
            nrev=nrev+1;
        end 
        if(nrev == 1)
            nrevint=nrevint+1;
            if(nrevint == 1)
                thismlfid=fopen(strtrim('tsrev.dat'),'r+');
                unit2fid=[unit2fid;11,thismlfid];
                [~]=writeFmt(11,[format_80]);
            end 
        end 
        if(tint <= 0.0)
            [~]=writeFmt(11,[format_82],'time_ml(i+1)','i');
        end 
        if(tint > tintva)
            nint_ml=(nint_ml+1);
            if(line1 == 0)
                line1=i;
                posirreg1=time_ml(i);
            end 
            if(tintmax < tint)
                tintmax=tint;
            end 
        end 
        if(tint < tintvb)
            nint_ml=(nint_ml+1);
            if(line1 == 0)
                line1=i;
                posirreg1=time_ml(i);
            end 
            if(tintmin > tint)
                tintmin=tint;
            end 
        end 
    end   
end 

% if(nint_ml >= 1)
%     nirr=1;
%     if(nrev > 0)
%         try
%             fclose(unit2fid(find(unit2fid(:,1)==11,1,'last'),2));
%             unit2fid=unit2fid(find(unit2fid(:,1)~=11),:);
%         end 
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,[format_88],'nrev');
%         [~]=writeFmt(1,['%c'],''' *** or reversed time_ml/posiion steps !  ***''');
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,['%c'],''' Consult output file "tsrev.dat" for listing''');
%         [~]=writeFmt(1,['%c'],''' of equal or reversed observation times.''');
%         [~]=writeFmt(1,['%c'],''' Stopping...''');
%         [~]=writeFmt(1,[]);
%         %error(['Even though Matlab just threw an error, there may or may not be a problem with this matlab code. This message merely signifies that a stop was encountered at this location in the original fortran code from which this matlab code was transalted. Please check the code to decide whether this is an actual error condition, or (which is often the case) whether this "stop" in fortran merely indicates the end of natural execution of the code.  ',char(10),';']);
%     end 
%     [~]=writeFmt(1,[]);
%     [~]=writeFmt(1,['%c'],'''  *************************************************''');
%     [~]=writeFmt(1,['%c'],'''  *** It appears that the data have irregularly ***''');
%     [~]=writeFmt(1,[format_90],'nint_ml');
%     [~]=writeFmt(1,[format_91],'tintmin');
%     [~]=writeFmt(1,[format_92],'tintmax');
%     [~]=writeFmt(1,['%c'],'''  ***                                           ***''');
%     [~]=writeFmt(1,['%c'],'''  ***  If the data should be uniformly spaced,  ***''');
%     [~]=writeFmt(1,['%c'],'''  ***  check the format, or correct observation ***''');
%     [~]=writeFmt(1,['%c'],'''  ***  times before spectral analysis.          ***''');
%     [~]=writeFmt(1,['%c'],'''  *************************************************''');
%     [~]=writeFmt(1,[]);
%     [~]=writeFmt(1,['%c'],''' The first irregularly spaced item occurs at:''');
%     [~]=writeFmt(1,[]);
%     [~]=writeFmt(1,['%c','%*g','%c','%*g'],''' Line number =''','line1',''' TIME =''','posirreg1');
%     if(tintmax./tdif > 0.3)
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,['%c'],''' *** Largest time_ml step >30% of total interval.***''');
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,['%c','%g'],'''     Total data interval =''','tdif');
%         [~]=writeFmt(1,['%c','%*g'],'''       Largest time_ml step =''','tintmax');
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,['%c'],''' *** To ensure stationarity analyse the data  ***''');
%         [~]=writeFmt(1,['%c'],''' *** in shorter segments.                     ***''');
%         [~]=writeFmt(1,['%c'],'''     Stopping....''');
%         error(['Even though Matlab just threw an error, there may or may not be a problem with this matlab code. This message merely signifies that a stop was encountered at this location in the original fortran code from which this matlab code was transalted. Please check the code to decide whether this is an actual error condition, or (which is often the case) whether this "stop" in fortran merely indicates the end of natural execution of the code.  ',char(10),';']);
%     end 
%     ctlim=0;
%     while 1
%         ctlim=(ctlim+1);
%         if(ctlim > 5)
%             [~]=writeFmt(1,[]);
%             [~]=writeFmt(1,['%c'],''' *** No response registered ***''');
%             [~]=writeFmt(1,['%c'],'''     Stopping...''');
%         end 
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,[format_22],'ndata');
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,['%c'],''' Do you want to stop the program here?''');
%         [~]=writeFmt(1,['%c'],''' (e.g. if the no. of points is incorrect)''');
%         if(nirr == 1)
%             [~]=writeFmt(1,['%c'],''' (or the data are meant to be uniformly spaced)''');
%         end 
%         [~]=writeFmt(1,['%c'],''' Proceed          = P''');
%         [~]=writeFmt(1,['%c'],''' Stop the program = S''');
%         lmn=strAssign(lmn,[],[],input('','s'));
% 
%         if(strcmp(deblank(lmn),deblank('P'))||strcmp(deblank(lmn),deblank('p')))
%             tempBreak=1;
%             break;
%         end 
%         if(strcmp(deblank(lmn),deblank('S'))||strcmp(deblank(lmn),deblank('s')))
%             error(['Even though Matlab just threw an error, there may or may not be a problem with this matlab code. This message merely signifies that a stop was encountered at this location in the original fortran code from which this matlab code was transalted. Please check the code to decide whether this is an actual error condition, or (which is often the case) whether this "stop" in fortran merely indicates the end of natural execution of the code.  ',char(10),';']);
%         end 
%         if(ios ~= 0)
%             [~]=writeFmt(1,[]);
%             [~]=writeFmt(1,['%c'],''' *** Enter P or S ***''');
%             continue;
%         end 
%     end 
% else
%     if(tintmax ~= tintmin)
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,[format_94],'tintmax');
%         [~]=writeFmt(1,[format_95],'tintmin');
%         [~]=writeFmt(1,[]);
%         [~]=writeFmt(1,['%c'],''' Variations in the time_ml intervals are''');
%         [~]=writeFmt(1,['%c'],''' within the 5% tolerance (allowing the''');
%         [~]=writeFmt(1,['%c'],''' data to be treated as having fixed''');
%         [~]=writeFmt(1,['%g'],''' time_ml steps).''');
%     end 
% end 

%% Start of pre-processing.
[~]=writeFmt(1,[]);
[~]=writeFmt(1,['%c'],''' Pre-processing start:''');
[~]=writeFmt(1,['%c'],'''     a) Pre-whitening''');
[~]=writeFmt(1,['%c'],'''     b) Linear detrending''');
[~]=writeFmt(1,['%c'],'''     c) Data tapering''');
[~]=writeFmt(1,['%c'],'''     d) Spectral characteristics''');

% Get variance and lag-1 autocorrelation (Rho1) for pre-whitening.
[x1,ndata,avex,varx]=meanvar(x1,ndata);
varx1=varx;
rho1 = rho(x1, ndata, varx1);
%[x1,time_ml,ndata,varx1,rho1]=rho(x1,time_ml,ndata,varx1);
rhox1=rho1;

% Pre-whiten time_ml series (Weedon (2020) showed this is essential
% to avoid false_ml positive Bayesian probability at low frequencies).
if(rhox1 > 0.0d0)
    xpw1(:)=0.0;
    for  i=1:(ndata-1)
        xpw1(i)=x1(i)-rhox1.*x1(i+1);
    end   
    for i=1:(ndata-1)
    x1(i)=xpw1(i);
    end  
end 

% Linear detrending of time_ml series using least squares line fitting.
%[time_ml,x1,ndata,xinterc,slope]=lfitls(time_ml,x1,ndata,xinterc,slope);
[xinterc,slope]=lfitls(time_ml,x1,ndata);
for  i=1:ndata
    xfit=(slope.*time_ml(i))+xinterc;
    x1(i)=x1(i)-xfit;
end   

% Taper time_ml series (5% Cosine taper both ends minimises periodogram leakage).
[x1,time_ml,ndata,tdif]=ctaper(x1,time_ml,ndata,tdif);

% Get spectral characteristics.
xnyq=0.0d0;
xfint=0.0d0;
% Periodogram not spectrum
ndof=2;
nout=floor(ndata/2);
anout=nout;
% Rayleigh frequency
xfint=1.0d0./tdif;

% Fixed time_ml step/spacing data
if(nirr == 0)
    
    if(tintmax == tintmin)
        tint=time_ml(1)-time_ml(2);
    else
        tint=(time_ml(1)-time_ml(ndata))./(andata-1.0);
    end
    
    if(tint < 0.0d0)
        tint=-1*tint;
    end
    
    % Nyquist frequency
    xnyq=1.0d0./(2.0d0.*tint);
    
    % Number of non-zero spectral estimates
    nout=floor(xnyq/xfint);
    anout=nout;
    
else
    
    % Nyquist frequency for irreg. spacing
    xnyq=xfint.*nout;
end

[~]=writeFmt(1,[]);
[~]=writeFmt(1,[format_120],'tdif');
[~]=writeFmt(1,[format_121],'xfint');
[~]=writeFmt(1,[format_122],'xnyq');
[~]=writeFmt(1,[format_123],'nout');
[~]=writeFmt(1,[format_124],'ndof');
% End of Pre-processing.
[~]=writeFmt(1,[]);
[~]=writeFmt(1,['%c'],''' Pre-processing completed.''');

%% Lomb-Scargle Transform 
% (required for specific calculation of Bayesian probability).
% Uses PERIOD of Press et al. (1992) and includes setting
% Fourier frequencies (FREQ=PNOW).
[~]=writeFmt(1,[]);
[~]=writeFmt(1,['%c'],''' Lomb-Scargle Transform...''');
% Standardize the detrended time_ml series so that the Bayesian
% probability calculation does not divide using a huge value
% of SUMBAYES (do loop 150). (AVEX should be zero already).
[x1,ndata,avex,varx]=meanvar(x1,ndata,avex,varx);
varx1=varx;
for  i=1:ndata
    x1(i)=(x1(i)-avex)./sqrt(varx1);
end   

% Calculate Lomb-Scargle periodogram.
[~,~,avex,varx]=meanvar(x1,ndata,avex,varx);
varx1=varx;
pow1(:)=0;
[x1,time_ml,ndata,avex,nout,xfint,pow,freq]=period(x1,time_ml,ndata,avex,nout,xfint,varx);
for  i=1:nout
    pow1(i)=pow(i);
end

[~]=writeFmt(1,['%c'],''' ...completed.''');

%% Bayesian probability
% Calculate Bayesian probability of a single regular cycle
% from rescaling the Lomb-Scargle periodogram using equations 13.5 and
% 13.22 of Gregory (2005).

% Find average of squared detrended values (d2-bar of equation 13.5).
sumd2=0;
for  i=1:ndata
    sumd2=sumd2+(x1(i)*x1(i));
end

% d2-bar of eqns 13.5 & 13.22
aved2 = sumd2/andata;
% Exponent in eqns 13.5 & 13.22
bayr=(2-andata)/2;

% Estimate unscaled Bayesian probability distribution.
% If time_ml series standardization is missed out (do loop 125) then
% negative BAYESPROB and huge BAYESPROB may be generated.
nhuge=0;
sumbayes=0.0d0;

bayesprob = zeros(nout, 1);    % Initialize array

for  i=1:nout
    
    % eqn 13.5
    bayesprob(i)=(1-((2*pow1(i))/(andata*aved2)))^bayr;
    
    if(bayesprob(i) < 0.0)
        fprintf('\n');
        fprintf(' *** Negative probability ***\n');
        fprintf('           I=%d\n', i);
        fprintf('   BAYESPROB=%.6f\n', bayesprob(i));
        fprintf('       Power=%.6f\n', pow1(i));
        fprintf(' AVED2*NDATA=%.6f\n', ndata * aved2);
        fprintf('        BAYR=%.6f\n', bayr);
        fprintf('\n');
        error('Negative Probability Error');  % Halting execution
    end
    
    if bayesprob(i) > realmax('double')
        nhuge = nhuge + 1;
        fprintf(' Periodogram value > HUGE Bayesian probability\n');
        fprintf('         I=%d\n', i);
        fprintf('      Freq=%.6f\n', freq(i));
        fprintf('     Power=%.6f\n', pow1(i));
        fprintf(' BAYESPROB=%.6f\n', bayesprob(i));
        fprintf('\n');
        error('HUGE Bayesian Probability Error');  % Halting execution
    end
    
    sumbayes=sumbayes+bayesprob(i);
    
end

% Check for huge sumbayes
if sumbayes > realmax('double')
    fprintf('\n');
    fprintf(' *** Warning SUMBAYES is HUGE ***\n');
    fprintf('     SUMBAYES=%.6f\n', sumbayes);
    fprintf(' This will result in an undeflow flag\n');
    fprintf(' following the loop (annoying but\n');
    fprintf(' not fatal)\n');
end

% Normalise probability distribution to get actual Bayesian probability.

maxprob=-1.0;
maxib=0;

for  i=1:nout
    % Gregory 2005 Eqn 13.22
    bayesprob(i)=bayesprob(i)/sumbayes;
    if(maxprob < bayesprob(i))
        maxprob=bayesprob(i);
        maxib=i;
    end
end
fprintf('\n');
fprintf('       Max. probability =       %.3f\n', maxprob);
fprintf('              Frequency = %.7f\n', freq(maxib));
fprintf('      Period/Wavelength = %.7f\n', 1/freq(maxib));
fprintf('\n');


%% Write out periodogram and Bayesian probability
outfile = 'SWA-Periodogram-Bayes-prob.dat';
fid = fopen(outfile, 'w');  % Opening the file for writing

% Printing the header to the file
fprintf(fid, '%%       Frequency   Period/Wavelength   Periodogram      Bayes Prob\n');

% Looping through and printing the data
for i = 1:nout
    fprintf(fid, '  %.12f  %.12f  %.12f  %.12f\n', ...
        freq(i), 1/freq(i), pow1(i), bayesprob(i));
end

% Closing the file
fclose(fid);

% Displaying output file name in command window
fprintf('\n');
fprintf(' Output file = %s\n', outfile);
fprintf('\n');

%% dubug start
pow2 = pow1(1:nout);
assignin('base','nout',nout);
assignin('base','freq',freq);
assignin('base','pow1',pow1);
assignin('base','bayesprob',bayesprob);
output1 = [freq'; 1./(freq)'; pow1(1:nout); bayesprob];
assignin('base','PeriodogramBayesProb',output1');

if plotn
    figure; 
    plot(freq, pow2,'DisplayName','Power')
    hold on;
    plot(freq, bayesprob,'DisplayName','Bayesian Probability')
    set(gca,'YScale','log');
    legend;
    xlabel('Frequency (cycles/unit)')
    ylabel('Power')
    title('Bayesian probability spectrum')
    xlim([0, max(freq)])
    ylim([min(bayesprob), max(pow2)*1.5])
end
% % //debug end
end


%%
% Get data variance and mean based on AVEVAR of Press et al (1992).
function [x,ndata,avex,varx]=meanvar(x,ndata,varargin)
persistent an ep i ssdiff sum_ml ; 

 if isempty(i), i=0; end 
 if isempty(sum_ml), sum_ml=0; end 
 if isempty(an), an=0; end 
 if isempty(ep), ep=0; end 
 if isempty(ssdiff), ssdiff=0; end 
sum_ml=0.0d0;
for  i=1:ndata;
sum_ml=sum_ml+x(i);
  end   
  i=fix(ndata+1);
an=ndata;
avex=sum_ml./an;
varx=0.0d0;
ep=0.0d0;
ssdiff=0.0d0;
for  i=1:ndata;
ssdiff=x(i)-avex;
ep=ep+ssdiff;
varx=varx+(ssdiff.*ssdiff);
  end   
  i=fix(ndata+1);
varx=(varx-(ep.*ep)./an)./(an-1.0);
return;
end

%%
% Line fitting using least squares. Based on FIT
% from Press et al (1992). Used to linearly detrend time_ml series
% with or without missing and/or irregularly spaced data.
function [xinterc,slope]=lfitls(time_ml,x,ndata,varargin)

    sx=0.0;
    sy=0.0;
    st2=0.0;
    bb=0.0;
    an=ndata;
    for  i=1:ndata
        sx=sx+time_ml(i);
        sy=sy+x(i);
    end   
    sxoss=sx./an;
    for  i=1:ndata
        tt=time_ml(i)-sxoss;
        st2=st2+(tt.*tt);
        bb=bb+tt.*x(i);
    end   
    bb=bb./st2;
    aa=(sy-(sx.*bb))./an;
    xinterc=aa;
    slope=bb;
end