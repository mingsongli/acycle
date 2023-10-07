function [freq, power, swa, alphob, factoball, clfdr, chi2_inv_value] = specswafdr(data_r, plotn, varargin)

% Program for generating a power spectrum of a time_ml series with
%           the spectral background located using smoothed window
%           averages (SWA). Confidence levels use the false_ml Discovery
%           Rate.

% Outline:  The spectrum is derived from a periodogram based on the
%           Lomb-Scargle algorithm - allowing analysis of data with
%           varying sample intervals in time_ml/distance or data with
%           a fixed sample interval but data missing.
%           Weedon et al. (2019) introduced use of SWA as a
%           non-parametric method for locating the spectral background.
%           false_ml Discovery rates (FDR) are designed to control type I
%           errors (false_ml positive detection of significant spectral
%           peaks) while minimizing type II errors (false_ml rejection of
%           spectral peaks as significant).
%           Weedon (2020) illustrated multiple cases from cyclostratigraphy
%           using SWA and FDR. Weedon (2022) investigated the associated
%           false_ml detection rates.

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

% Additional notes: Pre-processing uses linear detrending to ensure there
%           is stationarity in the local (i time_ml/space) mean. It is assumed
%           that the data are approximately stationary in terms of the local
%           variance. A split cosine taper is applied to minimize periodogram
%           leakage. The spectrum is derived from the Lomb-Scargle periodogram
%           using three applications of a Hanning window (leading to eight
%           degrees of freedom).

% Data format:
%           The single data file must be fixed-width column ascii.
%
%           Input files must have no headers with one time_ml step on each line.
%           Column 1 = Time/stratigraphic position, column 2 = Time series
%           value.

% Input:
%           NB: Smoothed window averaging is not appropriate for time_ml series
%           corresponding to white noise (lag1 autocorrrelation = 0.0)
%           or to power law noise (lag1 auotcorrelation = 1.0). It is designed
%           for red noise spectra without high-pass filtering.

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
%           c) Power.
%           d) Smoothed window average background.

% Calls for:
%   rho
%   ctaper
%   period
%   
%
% Created by: Graham P. Weedon, Met Office, UK.
%
% Translate to Matlab: Mingsong Li, Peking University, 2023
% updated Oct. 2023

% INPUT
%   data_r: 2 columns data; 1st: depth/time
%                           2nd: value/measurement
%
% OUTPUT
%   
%%
% clear all; %clear functions;
% 
% global unit2fid;  
% if ~isempty(unit2fid)
%     unit2fid=[]; 
% end
%%
% Display the program info
disp(' ');
disp(' ***       Program specswafdf.m:    ***');
disp(' ***  Lomb-Scargle-derived spectrum  ***');
disp(' ***  with SWA-fitted spectral       ***');
disp(' ***  background and FDR confidence  ***');
disp(' ***  levels.                        ***');
disp(' ');

persistent bw ctlim difft diffx fmt i ii ios j k l lmn ndata nint nirr nmax nmax2 nmaxb nrev nrevint outfile pow1 proc rev1min rev2min slope sum_ml tdif time_ml  x1 xfit xinterc xnyq ; 

format_1=[' NB: Dimensioned for a maximum of','%7d',' time steps'];
format_120=['       Time/strat range = ','%15.7f'];
format_121=['          Rayleigh Freq = ','%15.7f'];
format_122=['           Nyquist Freq = ','%15.7f'];
format_123=['       No. output freqs =      ','%6d'];
format_124=[' No. degrees of freedom =      ','%2d'];
format_18=['  Time(1) = ','%12.7f',' Obs(1) = ','%11.5f'];
format_20=['  Time(N) = ','%12.7f',' Obs(N) = ','%11.5f'];
format_22=['  Number of time steps = ','%7d'];
format_224=['   Final Window width =  ','%2d'];
format_225=['                 RMSE =','%10.6f'];
format_231=['                 RMSE =','%10.6f'];
format_24=[' NB: Dimensioned for a maximum of','%7d',' time steps'];
format_248=[' After smoothing RMSE =','%10.6f'];
format_8=['  *** Error opening ','%c'];
format_80=['  Time step      Line number'];
format_82=['%2x','%12.7f','%4x','%7d'];
format_88=[' *** PROBLEM: There are ','%7d',' equal ***'];
format_90=['   *** spaced values/gaps at ','%7d','      steps. ***'];
format_91=['   *** Minimum interval detected = ','%12.7f','  ***'];
format_92=['   *** Maximum interval detected = ','%12.7f','  ***'];
format_94=[' Maximum time interval = ','%12.7f'];
format_95=[' Minimum time interval = ','%12.7f'];


if isempty(time_ml), time_ml=zeros(1,nmax); end

% Declaring constants
nmax = 300001;
nmaxb = floor(nmax/2);  % Ensure that it is an integer in MATLAB
nmax2 = 1100000;

% Integer variables
i = 0; ii = 0; j = 0; k = 0; l = 0; ctlim = 0; ios = 0; nint = 0;
nrev = 0; nirr = 0; nrevint = 0; ndata = 0; nout = 0; lfit = 0;
status = 0; line1 = 0; ndx = 0; ndt = 0; iyear = 0; al = 0; ndof = 0;
nfix = 0; winwidth = 0; icycle = 0; ncycle = 0; wincentre = 0;
finish = 0; rev1 = 0; rev2 = 0; lim = 0; iwin = 0; iord1 = 0; nest = 0;
nsmth = 0; winfinal = 0; revmin = 0; nlevs = 0; ncorr = 0; maxneg5 = 0;
maxneg1 = 0; maxneg01 = 0; maxneg001 = 0; nneg = 0; sigstop = 0; cout1 = 0;
cout2 = 0; cout3 = 0; cout4 = 0; maxneg10 = 0; cout0 = 0;

% Real and Double Precision variables
diffx = 0; difft = 0; slope = 0; xfit = 0; xinterc = 0; bw = 0;
rev1min = 0; rev2min = 0; sum = 0; sumf = 0; awinwidth = 0;
midw = zeros(floor(nmax/10), 1); freqmid = zeros(floor(nmax/10), 1);
se = 0; rmse = 0; mbe = 0; fitsp1 = zeros(nmaxb, 1); fitsp2 = zeros(nmaxb, 1);
fitsp3 = zeros(nmaxb, 1); diff1 = 0; diff2 = 0; diff = 0; value = 0;
delta = 0; diff0 = 0; rmsel1 = 0; xxp = 0; yyp = 0; swa = zeros(nmaxb, 1);
fitsp = zeros(nmaxb, 1); revp1 = 0; revp2 = 0; rmset = 0; value1 = 0;
value2 = 0; b = zeros(20); c = zeros(20); xp = zeros(20); sump = 0;
rmsef1 = 0; rmsef2 = 0; rmsemin = 0; maxfactob = 0; factob = 0;
sumpower = 0;

% Declaring double precision arrays
xnyq = 0; x1 = zeros(nmax, 1); time = zeros(nmax, 1); tdif = 0;
pow1 = zeros(nmaxb, 1); pow = zeros(nmaxb, 1); posirreg1 = 0; tint = 0;
tint1 = 0; tintmin = 0; tintmax = 0; tintva = 0; tintvb = 0; xfint = 0;
anout = 0; avex = 0; varx = 0; andata = 0; varx1 = 0; xpi = 0;
rho1 = 0; rhox1 = 0; freq = zeros(nmaxb, 1); xpw1 = zeros(nmax, 1);
xndof = 0; xlogp = zeros(nmaxb, 1); psmth = zeros(nmaxb, 1);
xfr = zeros(nmaxb, 1); y = zeros(nmaxb, 1); alphaint = 0; alphap = 0;
alpha = zeros(nmax2, 1); clev = zeros(nmax2, 1); fact = 0;
factor = zeros(nmax2, 1); fdr001 = 0; fdr01 = 0; fdr1 = 0; fdr5 = 0;
fdr5p = 0; fdr1p = 0; fdr01p = 0; fdr001p = 0; alphob = zeros(nmaxb, 1);
alphsort = zeros(nmaxb, 1); cn = 0; aj = 0; ai = 0; jalpha1 = zeros(nmaxb, 1);
jalpha5 = zeros(nmaxb, 1); jalpha01 = zeros(nmaxb, 1); jalpha001 = zeros(nmaxb, 1);
jdiff5 = 0; jdiff1 = 0; jdiff01 = 0; jdiff001 = 0; cl001 = zeros(nmaxb, 1);
cl01 = zeros(nmaxb, 1); cl1 = zeros(nmaxb, 1); cl5 = zeros(nmaxb, 1);
cl10 = zeros(nmaxb, 1); fdr10 = 0; fdr10p = 0; jalpha10 = zeros(nmaxb, 1);
jdiff10 = 0;


%% debug start
%datfile = '607-d18O.txt';
%data_r= load(datfile);

time_ml= data_r(:,1); 
x1     = data_r(:,2); 
ndata=length(x1);
andata=ndata;
% debug end
% Assuming NMAX is defined earlier in the program
fprintf(' NB: Dimensioned for a maximum of %d time steps\n', nmax-1);
%%
% Check for irregularly spaced data. Compare observations/reference times
% for first two points with all others. If variation exceeds +/-5.0%
% then data are considered to be irregularly spaced.
% If identical or reversed time_ml/positions are detected then output list
% to file tsrev.dat and stop program.

line1=0;
tint1=time_ml(1)-time_ml(2);

if tint1 > 0.0
    tdif=time_ml(1)-time_ml(ndata);
    tintmin=tint1;
    tintmax=tint1;
    tintva=tint1.*1.05;
    tintvb=tint1.*0.95;
    
    for  i=2:(ndata-1)
        
        tint=time_ml(i)-time_ml(i+1);
        if(tint <= 0.0)
            nrev=fix(nrev+1);
        end
        if(nrev == 1)
            nrevint=fix(nrevint+1);
            if(nrevint == 1)
                thismlfid=fopen(strtrim('tsrev.dat'),'r+');
                unit2fid=[unit2fid;11,thismlfid];
                [writeErrFlag]=writeFmt(11,[format_80]);
            end
        end
        
        if(tint <= 0.0)
            [writeErrFlag]=writeFmt(11,[format_82],'time_ml(i+1)','i');
        end
        if(tint > tintva)
            nint=nint+1;
            if(line1 == 0)
                line1=i;
                posirreg1=time_ml(i);
            end
            if(tintmax < tint)
                tintmax=tint;
            end
        end
        
        if(tint < tintvb)
            nint=nint+1;
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
                [writeErrFlag]=writeFmt(11,[format_80]);
            end
        end
        
        if(tint <= 0.0)
            [writeErrFlag]=writeFmt(11,[format_82],'time_ml(i+1)','i');
        end
        
        if(tint > tintva)
            nint=nint+1;
            if(line1 == 0)
                line1=i;
                posirreg1=time_ml(i);
            end

            if(tintmax < tint)
                tintmax=tint;
            end
        end
        if(tint < tintvb)
            nint=nint+1;
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

if(nint >= 1)
    
    nirr=1;  % flag to show irregularly spaced data; 1 irregularly spaced; 0 = evenly spaced
    
    if(nrev > 0)
        try
            fclose(unit2fid(find(unit2fid(:,1)==11,1,'last'),2));
            unit2fid=unit2fid(find(unit2fid(:,1)~=11),:);
        end
        [writeErrFlag]=writeFmt(1,[]);
        [writeErrFlag]=writeFmt(1,[format_88],'nrev');
        [writeErrFlag]=writeFmt(1,['%c'],''' *** or reversed time_ml/posiion steps !  ***''');
        [writeErrFlag]=writeFmt(1,[]);
        [writeErrFlag]=writeFmt(1,['%c'],''' Consult output file "tsrev.dat" for listing''');
        [writeErrFlag]=writeFmt(1,['%c'],''' of equal or reversed observation times.''');
        [writeErrFlag]=writeFmt(1,['%c'],''' Stopping...''');
        [writeErrFlag]=writeFmt(1,[]);
        %error(['Even though Matlab just threw an error, there may or may not be a problem with this matlab code. This message merely signifies that a stop was encountered at this location in the original fortran code from which this matlab code was transalted. Please check the code to decide whether this is an actual error condition, or (which is often the case) whether this "stop" in fortran merely indicates the end of natural execution of the code.  ',char(10),';']);
    end
    
    [writeErrFlag]=writeFmt(1,[]);
    [writeErrFlag]=writeFmt(1,['%c'],'''  *************************************************''');
    [writeErrFlag]=writeFmt(1,['%c'],'''  *** It appears that the data have irregularly ***''');
    [writeErrFlag]=writeFmt(1,[format_90],'nint');
    [writeErrFlag]=writeFmt(1,[format_91],'tintmin');
    [writeErrFlag]=writeFmt(1,[format_92],'tintmax');
    [writeErrFlag]=writeFmt(1,['%c'],'''  ***                                           ***''');
    [writeErrFlag]=writeFmt(1,['%c'],'''  ***  If the data should be uniformly spaced,  ***''');
    [writeErrFlag]=writeFmt(1,['%c'],'''  ***  check the format, or correct observation ***''');
    [writeErrFlag]=writeFmt(1,['%c'],'''  ***  times before spectral analysis.          ***''');
    [writeErrFlag]=writeFmt(1,['%c'],'''  *************************************************''');
    [writeErrFlag]=writeFmt(1,[]);
    [writeErrFlag]=writeFmt(1,['%c'],''' The first irregularly spaced item occurs at:''');
    [writeErrFlag]=writeFmt(1,[]);
    disp([' Line number = ',num2str(line1),' Time = ', num2str(time_ml(line1))])
  
    if(tintmax./tdif > 0.3)
        [writeErrFlag]=writeFmt(1,[]);
        [writeErrFlag]=writeFmt(1,['%c'],''' *** Largest time_ml step >30% of total interval.***''');
        [writeErrFlag]=writeFmt(1,[]);
        [writeErrFlag]=writeFmt(1,['%c','%g'],'''     Total data interval =''','tdif');
        [writeErrFlag]=writeFmt(1,['%c','%*g'],'''       Largest time_ml step =''','tintmax');
        [writeErrFlag]=writeFmt(1,[]);
        [writeErrFlag]=writeFmt(1,['%c'],''' *** To ensure stationarity analyse the data  ***''');
        [writeErrFlag]=writeFmt(1,['%c'],''' *** in shorter segments.                     ***''');
        [writeErrFlag]=writeFmt(1,['%c'],'''     Stopping....''');
        %error(['Even though Matlab just threw an error, there may or may not be a problem with this matlab code. This message merely signifies that a stop was encountered at this location in the original fortran code from which this matlab code was transalted. Please check the code to decide whether this is an actual error condition, or (which is often the case) whether this "stop" in fortran merely indicates the end of natural execution of the code.  ',char(10),';']);
    end
    
    warndlg('The data are not uniformly spaced')
%     ctlim=0;
    
    % allow users type three times
    
%     while ctlim < 3
%         
%         ctlim=fix(ctlim+1);
%         
%         if(ctlim > 5)
%             [writeErrFlag]=writeFmt(1,[]);
%             [writeErrFlag]=writeFmt(1,['%c'],''' *** No response registered ***''');
%             [writeErrFlag]=writeFmt(1,['%c'],'''     Stopping...''');
%         end
%         
%         [writeErrFlag]=writeFmt(1,[]);
%         [writeErrFlag]=writeFmt(1,[format_22],'ndata');
%         [writeErrFlag]=writeFmt(1,[]);
%         [writeErrFlag]=writeFmt(1,['%c'],''' Do you want to stop the program here?''');
%         [writeErrFlag]=writeFmt(1,['%c'],''' (e.g. if the no. of points is incorrect)''');
%         
%         if(nirr == 1)
%             [writeErrFlag]=writeFmt(1,['%c'],''' (or the data are meant to be uniformly spaced)''');
%         end
%         
%         [writeErrFlag]=writeFmt(1,['%c'],''' Proceed          = P''');
%         [writeErrFlag]=writeFmt(1,['%c'],''' Stop the program = S''');
        
        %lmn=strAssign(lmn,[],[],input('','s'))
%         lmn = input('','s');
%         
%         if(strcmp(deblank(lmn),deblank('P')) || strcmp(deblank(lmn),deblank('p')))
%             tempBreak=1;
%             break;
%         end
%         
%         if(strcmp(deblank(lmn),deblank('S'))||strcmp(deblank(lmn),deblank('s')))           
%             return
%         end
%         
%         if(ios ~= 0)
%             
%             [writeErrFlag]=writeFmt(1,[]);
%             [writeErrFlag]=writeFmt(1,['%c'],''' *** Enter P or S ***''');
%             
%         continue;
%         
%         end
%     end
    
else
    
    if(tintmax ~= tintmin)
        
        [writeErrFlag]=writeFmt(1,[]);
        [writeErrFlag]=writeFmt(1,[format_94],'tintmax');
        [writeErrFlag]=writeFmt(1,[format_95],'tintmin');
        [writeErrFlag]=writeFmt(1,[]);
        [writeErrFlag]=writeFmt(1,['%c'],''' Variations in the time_ml intervals are''');
        [writeErrFlag]=writeFmt(1,['%c'],''' within the 5% tolerance (allowing the''');
        [writeErrFlag]=writeFmt(1,['%c'],''' data to be treated as having fixed''');
        [writeErrFlag]=writeFmt(1,['%g'],''' time_ml steps).''');
    end
    
end

%%
% Start of pre-processing.
[writeErrFlag]=writeFmt(1,[]);
[writeErrFlag]=writeFmt(1,['%c'],''' Pre-processing start:''');
[writeErrFlag]=writeFmt(1,['%c'],'''     a) Linear detrending''');
[writeErrFlag]=writeFmt(1,['%c'],'''     b) Data tapering''');
[writeErrFlag]=writeFmt(1,['%c'],'''     c) 3 x Hanning''');
[writeErrFlag]=writeFmt(1,['%c'],'''     d) Spectral characteristics''');

% Get variance and lag-1 autocorrelation (Rho1) for pre-whitening.
% Rho1 calculated directly assuming fixed spacing data. For
% an alternative procedure allowing for data spacing explicitly
% consult Mudelsee (2002).

avex = mean(x1);
varx = var(x1);

%[x1,time_ml,ndata,varx1,rho1]=rho(x1,time_ml,ndata,varx1,rho1);
rho1 = rho(x1, ndata, varx);
rhox1=rho1;

% Linear detrending of time_ml series using least squares line fitting.
% Prevents spectral leakage from the lowest frequencies (< Rayleigh
% frequency and centres the data.
[time_ml,x1,ndata,xinterc,slope]=lfitls(time_ml,x1,ndata,xinterc,slope);

for  i=1:ndata
    xfit=(slope.*time_ml(i))+xinterc;
    x1(i)=x1(i)-xfit;
end

i=fix(ndata+1);

% Taper time_ml series (5% Cosine taper both ends minimises periodogram leakage).
[x1,time_ml,ndata,tdif]=ctaper(x1,time_ml,ndata,tdif);

% Get the spectral characteristics.
xnyq=0.0d0;
xfint=0.0d0;
ndof=0;

% Number of non-zero freq. Fourier freqs
nout=fix(ndata./2);
anout=nout;

% Rayleigh frequency (freq spacing)
xfint=1.0d0./tdif;
tint = (max(time_ml) - min(time_ml)) / (ndata - 1); 
% if(nirr == 0)
%     tint=time_ml(1)-time_ml(2);
% else
%     % Average sample interval
%     tint=(time_ml(1)-time_ml(ndata))./(andata-1.0);
% end
% 
% if(tint < 0.0d0)
%     tint=-1.0d0.*tint;
% end

% Bandwidth allowing for data taper
bw=1.0./(0.225586.*1.055.*andata.*tint);

% Fixed time_ml step/spacing data:
if(nirr == 0)
    % Nyquist frequency
    xnyq=1.0d0./(2.0d0.*tint);
    % Number of non-zero freq. spectral estimates
    nout=(xnyq./xfint);
    anout=nout;
    % Degrees of freedom
    xndof=(2.0.*andata)./(1.055.*0.225586.*2.0.*anout);
    % allowing for data taper and 3xHanning
    ndof=xndof;
    % Irregularly spaced data:
else
    % Nyquist freq via min. data spacing
    xnyq=1.0d0./(2.0d0.*tintmin);
    nout=tdif./(2.0.*tintmin);
    anout=nout;
    bw=1.0./(0.225586.*1.055.*andata.*tintmin);
    % Degrees of freedom
    xndof=(2.0.*andata)./(1.055.*0.225586.*2.0.*anout);
    % allowing for data taper and 3xHanning
    ndof=xndof+0.5;
    if(ndof <= 7)
        nout=fix(ndata./2);
        anout=nout;
        % Nyquist frequency for irreg. spacing
        xnyq=xfint.*nout;
        % adjusted to ensure NDOF=8
        xndof=8.0d0;
        ndof=8;
        bw=1.0./(0.225586.*1.055.*andata.*tint);
    end
end

[writeErrFlag]=writeFmt(1,[]);
[writeErrFlag]=writeFmt(1,[format_120],'tdif');
[writeErrFlag]=writeFmt(1,[format_121],'xfint');
[writeErrFlag]=writeFmt(1,[format_122],'xnyq');
[writeErrFlag]=writeFmt(1,[format_123],'nout');
[writeErrFlag]=writeFmt(1,[format_124],'ndof');

disp(['              bandwidth =      ',num2str(bw)])

% End of Pre-processing.
[writeErrFlag]=writeFmt(1,[]);
[writeErrFlag]=writeFmt(1,['%c'],''' Pre-processing completed.''');

%%
% Lomb-Scargle Transform from PERIOD of Press et al. (1992) and
% includes setting Fourier frequencies (FREQ). Returns the power
% normalised by the variance (POW1) of the linearly detrended and
% tapered data (VARX1).
[writeErrFlag]=writeFmt(1,[]);
[writeErrFlag]=writeFmt(1,['%c'],''' Lomb-Scargle Transform...''');
avex = mean(x1);
varx = var(x1);

% Calculate the Lomb-Scargle periodogram.
sumpower=0.0;
pow1(i)=0.0d0;
[x1,time_ml,ndata,avex,nout,xfint,pow,freq]=period(x1,time_ml,ndata,avex,nout,xfint,varx);

for  i=1:nout;
    pow1(i)=pow(i);
    sumpower=sumpower+pow1(i);
end 

[writeErrFlag]=writeFmt(1,['%c'],'''       ...completed.''');

% Apply Tukey-Hanning spectral window (obtain spectral estimates
% from periodograms with 8 degrees of freedom).

[pow1,nout]=hanning(pow1,nout);

%%
% Smoothed window averages (SWA) fit. Put Log10(spectrum) into fixed-width
% windows and linearly interpolate averages. Store RMSE versus orignal
% spectrum. Explore range of window widths. Select the WINWIDTH
% giving the minimum number of fitted slope reversals and the smallest
% RMSE and then slightly smooth the result.
if(rhox1 == 0.0d0||rhox1 == 1.0d0)
    [writeErrFlag]=writeFmt(1,[]);
    [writeErrFlag]=writeFmt(1,['%c','%*g'],''' Lag1 autocorrelation = ''','rhox1');
    [writeErrFlag]=writeFmt(1,['%c'],''' *** SWA is not appropriate for time_ml  ***''');
    [writeErrFlag]=writeFmt(1,['%c'],''' *** series with white noise or power ***''');
    [writeErrFlag]=writeFmt(1,['%c'],''' *** law backgrounds                  ***''');
    [writeErrFlag]=writeFmt(1,[]);
    [writeErrFlag]=writeFmt(1,['%c'],''' Stopping...''');
    [writeErrFlag]=writeFmt(1,[]);
    error(['Even though Matlab just threw an error, there may or may not be a problem with this matlab code. This message merely signifies that a stop was encountered at this location in the original fortran code from which this matlab code was transalted. Please check the code to decide whether this is an actual error condition, or (which is often the case) whether this "stop" in fortran merely indicates the end of natural execution of the code.  ',char(10),';']);
end
    [writeErrFlag]=writeFmt(1,[]);
    [writeErrFlag]=writeFmt(1,['%c'],''' Spectral background location using''');
    [writeErrFlag]=writeFmt(1,['%c'],''' smoothed linearly interpolated''');
    [writeErrFlag]=writeFmt(1,['%c'],''' window averages (SWA)''');
    [writeErrFlag]=writeFmt(1,[]);
    
for  i=1:nout
    % Log power values
    xlogp(i)=log10(pow1(i));    
end

%% Find log spectrum averages in fixed-width windows.
% Test WINWIDTH as an odd integer from 11 to 99.
winwidth=9;
rmsemin=1.0e+20;
revmin=ndata;
ncycle=0;
midw(:)=0.0;
freqmid(:)=0.0;
fitsp(:)=0.0;
fitsp1(:)=0.0;
fitsp2(:)=0.0;

% Repeat testing WINWIDTH from here
while (revmin > 0 && winwidth < 99)
    % Increment as odd integer
    winwidth=winwidth+2;
    awinwidth=winwidth;
    wincentre= floor(winwidth./2)+1;
    % Number of averaging windows
    ncycle=floor(nout./winwidth); % debug Mingsong Li, 2023
    j=0;
    k=0;
    for  icycle=1:ncycle
        sump=0.0;
        sumf=0.0;
        for  iwin=1:winwidth
            sump=sump+xlogp(k+iwin);
            sumf=sumf+freq(k+iwin);
        end
        % Window index
        j=j+1;
        % Window log power average
        midw(j)=sump./awinwidth;
        % Window frequency position
        freqmid(j)=sumf./awinwidth;
        % Increment index of log power & freq
        k=k+winwidth;
    end

    % Linearly interpolate between window log power averages.
    % Low frequencies: project the slope of first two window averages
    % back towards the zero frequency (positions 1 to WINCENTRE).
    % Repeat with projecting slope of second two window averages backwards.
    % Slope of first two windows
    
    diff1=(midw(2)-midw(1))./awinwidth;
    diff2=(midw(3)-midw(2))./awinwidth;
    
    % Slope increment
    delta=diff2-diff1;
    diff0=diff1-delta;
    value1=midw(1);
    value2=midw(1);
    
    %for i=floor(wincentre):-1:1   % mingsong li debug 2023
    for i = (wincentre-1):-1:1
        value1=value1-diff1;
        fitsp1(i)=value1;
        value2=value2-diff0;
        fitsp2(i)=value2;
    end
    
    ii=wincentre;
    fitsp1(ii)=midw(1);
    fitsp2(ii)=midw(1);
    
    % Continue with interpolation between log power averages.
    for  k=1:(ncycle-1)
        diff0=(midw(k+1)-midw(k))./awinwidth;
        value=midw(k);
        for  j=1:(winwidth-1)
            ii=ii+1;
            value=value+diff0;
            fitsp1(ii)=value;
            fitsp2(ii)=value;
        end
        fitsp1(ii)=midw(k+1);
        fitsp2(ii)=midw(k+1);
    end

    % High frequencies using slope between last window averages.
    % Slope last two windows
    diff1=(midw(ncycle)-midw(ncycle-1))./awinwidth;
    diff2=(midw(ncycle-1)-midw(ncycle-2))./awinwidth;
    % Slope increment
    delta=diff2-diff1;
    diff0=diff1-delta;
    value1=midw(ncycle);
    value2=midw(ncycle);
    % Freq index within last window
    finish=ii;
    for  i=finish:nout
        value1=value1+diff1;
        fitsp1(i)=value1;
        value2=value2+diff0;
        fitsp2(i)=value2;
    end

    % Find RMSE using fitted backgrounds (FITSP1 and FITSP2) and, to
    % ensure smooth fit, minimize the number of fitted slope reversals.
    se=0.0;
    diff = 0;
    for  i=1:nout
        diff=xlogp(i)-fitsp1(i);
        se=se+(diff.*diff);
    end
    
    anout=nout;
    rmsef1=sqrt(se./(anout-1));

    se=0.0;
    rmsef2=0.0;
    for  i=1:nout
        diff=xlogp(i)-fitsp2(i);
        se=se+(diff.*diff);
    end
    rmsef2=sqrt(se./(anout-1));
    rev1=0;
    rev2=0;
    lim=ncycle.*winwidth;
    for  i=1:(lim-1)
        if(fitsp1(i) <= fitsp1(i+1))
            rev1=rev1+1;
        end
        if(fitsp2(i) <= fitsp2(i+1))
            rev2=rev2+1;
        end
    end
    
    if(revmin > rev1)
        revmin=rev1;
        rmsemin=rmsef1;
        winfinal=winwidth;
        for  i=1:nout
            fitsp(i)=fitsp1(i);
        end
    end
    if(revmin > rev2)
        revmin=rev2;
        rmsemin=rmsef2;
        winfinal=winwidth;
        for  i=1:nout
            fitsp(i)=fitsp2(i);
        end
    end
    
    if(revmin == 0)
        if(rmsemin > rmsef1)
            rmsemin=rmsef1;
            winfinal=winwidth;
            for  i=1:nout
                fitsp(i)=fitsp1(i);
            end
        end
        if(rmsemin > rmsef2)
            rmsemin=rmsef2;
            winfinal=winwidth;
            for  i=1:nout
                fitsp(i)=fitsp2(i);
            end
        end
    end

end

[writeErrFlag]=writeFmt(1,[]);
[writeErrFlag]=writeFmt(1,[format_224],'winfinal');
[writeErrFlag]=writeFmt(1,[format_225],'rmsemin');
rmsel1=rmsemin;
[writeErrFlag]=writeFmt(1,[]);
[writeErrFlag]=writeFmt(1,['%c'],''' Testing alternative white noise and''');
[writeErrFlag]=writeFmt(1,['%c'],''' quadratic fits to end of spectrum.''');

%% Test whether white noise end of log spectrum (FITSP3) gives better fit.
% Up to end of last window
for  i=1:(finish-1)
    % copy FITSP
    fitsp3(i)=fitsp(i);
end
% Remainder of spectrum
for  i=finish:nout
    % Fix as last window average
    fitsp3(i)=midw(ncycle);
    %fitsp3(i)=midw(floor(ncycle)); % mingsong li debug
end
[writeErrFlag]=writeFmt(1,[]);
diff=0.0;
se=0.0;
rmse=0.0;

for  i=1:nout
    diff=xlogp(i)-fitsp3(i);
    se=se+(diff.*diff);
end
anout=nout;
rmse=sqrt(se./(anout-1));
if(rmse < rmsel1)
    for  i=1:nout
        % Select white noise end fit
        fitsp(i)=fitsp3(i);
    end
    rmsel1=rmse;
    [writeErrFlag]=writeFmt(1,['%c'],'''  Using fixed final power in end window''');
end

[writeErrFlag]=writeFmt(1,[format_231],'rmsel1');

%% Test whether quadratic fit to the end of the log spectrum gives a better fit. 
% Fitting the latter half of the last averaging window
% plus the remainingfrequencies.
j=1;
% winwidth = 31; finish = 226

for  i = (finish-floor(winwidth./2)) : nout
    xfr(j)=freq(i);
    y(j)=xlogp(i);
    j=j+1;
end
nest=j;
% Start polynomial (quadratic) fit of smoothed log power
% v frequency. Algorithm of Davis (1973) p213.

iord1=2+1;
for  i=1:iord1
    c(i)=0.0;
    for  j=1:iord1
        b(i,j)=0.0;
    end
end

for  i = 1:nest
    xp(1)=1.0;
    for  j=2:iord1
        %xp(j)=xp(j-1) .* xfr(i);% debug mingsong li
        xp(j)=xp(j-1).*xfr(i+1);
    end
    
    for  j=1:iord1
        for  k=1:iord1
            b(j,k)=b(j,k)+xp(j).*xp(k);
        end
        c(j)=c(j)+xp(j).*y(i);
    end
end

% Solve simultaneous equations.
[b,c,iord1]=solve(b,c,iord1,20,1.0e-06);

% Calculate quadratic fit power (XOUT) as a function of frequency.
ii=finish-20;
for  i=1:(nest-2)
    xxp=1.0;
    yyp=0.0;
    for  j=1:iord1
        yyp=yyp+xxp.*c(j);
        xxp=xxp.*xfr(i+1);
    end
    ii=ii+1;
    fitsp3(ii)=yyp;
end

fitsp3(nout)=(fitsp3(nout)-fitsp3(nout-1))+fitsp3(nout);
for  i=1:(finish-1)
    fitsp3(i)=fitsp(i);
end
diff=0.0;
se=0.0;
rmse=0.0;
for  i=1:nout
    diff=xlogp(i)-fitsp3(i);
    se=se+(diff.*diff);
end
rmse=sqrt(se./(anout-1));
if(rmse < rmsel1)
    for  i=1:nout
        fitsp(i)=fitsp3(i);
    end
    rmsel1=rmse;
    [writeErrFlag]=writeFmt(1,['%c'],'''  Switching to quadratic fit for end window''');
    [writeErrFlag]=writeFmt(1,[format_231],'rmsel1');
end

%% Use Hanning smoothing to create a smoothed linear interpolation.
% optional
% Finish smoothing when RMSE degraded (increased) by 1%.

psmth(:) = 0;
nsmth = 1;

while true
    psmth(1) = (0.5 * fitsp(1)) + (0.5 * fitsp(2));
    psmth(nout) = (0.5 * fitsp(nout-1)) + (0.5 * fitsp(nout));
    
    for i = 2:(nout-1)
        psmth(i) = (0.25 * fitsp(i-1)) + (0.5 * fitsp(i)) + (0.25 * fitsp(i+1));
    end
    
    fitsp = psmth;
    nsmth = nsmth + 1;
    diff = 0.0;
    se = 0.0;
    rmset = 0.0;
    sum = 0.0;
    
    for i = 1:nout
        diff = xlogp(i) - fitsp(i);
        se = se + (diff * diff);
        sum = sum + diff;
    end
    
    rmset = sqrt(se / nout);
    mbe = sum / nout;
    
    if rmset < rmsel1 * 1.01 && nsmth < 100000
        continue; % Repeat Hanning smoothing
    else
        break;
    end
end

fprintf('\n');
fprintf('After smoothing RMSE = %.6f\n', rmset);

%% SWA results

for i = 1:nout
    swa(i) = 10.0 ^ fitsp(i);
end
swa = swa(:); % Ensure swa is a column vector

%% False Discovery Rate (FDR, Benjamini & Hochberg, 1995) algorithm
% based on Miller et al (2001).
 
% Obtain variance ratio according to confidence level for
% 8 degrees of freedom.

% USER: It is more efficient to output ALPHA, CLEV and FACTOR
%       on first use, and then suppress the DO 300 calculations
%       and for subsequent use read in these data.

filename2 = which('Alpha-CLs-DOF-8-gw.mat');
if isfile(filename2)
    % File exists.
     disp('')
     disp('  Read in confidence level data ...')  % output here    
     disp(filename2)
     disp('')
     load(filename2);
     nlevs=length(alpha);
else
    % File does not exist.     
    disp('Setting up probability listing...')  % output here     
    alphaint = 0.000000001;
    alphap = 0.0;
    nlevs = nmax2;
    alpha = zeros(1, nlevs);
    clev  = zeros(1, nlevs);
    factor= zeros(1, nlevs);

    for i=1:100001

        alphap = alphap + alphaint;
        alpha(i) = alphap;
        clev(i) = (1.0-alphap) * 100.0;
        factor(i) = getchi2(8,alphap)/8;

        if mod(i,50000) == 0
            fprintf('   Number of simulations: %d / %d \n', i, nlevs);
        end
    end

    alphaint=0.0000001;
    for i=100002:nlevs

        alphap = alphap + alphaint;
        alpha(i) = alphap;
        factor(i) = getchi2(8, alphap)/8;
        if mod(i,50000) == 0
            %disp(i)
            fprintf('   Number of simulations: %d / %d \n', i, nlevs);
        end
    end

    clev = (1.0 - alpha)*100.0;
    disp('   ... completed') % output here
end

%%
% Find probability level (ALPHA) by frequency based on Chi2 
% for DOF=8 from list (FACTOR) by comparing power (POW1) to
% the background spectrum (SWA)
disp('  Find probability level (ALPHA) by frequency based on chi2 for DOF = 8')
max_factob  = 0;
alphob = zeros(nout,1);
factoball = zeros(nout,1);

for i = 1:nout
    factob = pow1(i) / swa(i);   % =Variance ratio (since the power is periodogram-based)
    factoball(i) = factob;
    %alphob(k) = 0.0;  % debug? Why k is used here??
    
%     for j = 1:nlevs-1
%         if factor(1) < factob
%             alphob(i) = alpha(1);
%             break;  % exit for loop
%         end
% 
%         if factor(j+1) <= factob && factor(j) > factob
%             alphob(i) = alpha(j+1);
%             break;  % exit for loop
%         end
% 
%         if factor(nlevs) > factob
%             alphob(i) = alpha(nlevs);
%         end
%     end

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

chi2_inv_value(1) = getchi2(8, 0.1)/8;  % 90%
chi2_inv_value(2) = getchi2(8, 0.05)/8; % 95%
chi2_inv_value(3) = getchi2(8, 0.01)/8; % 99%
chi2_inv_value(4) = getchi2(8, 0.001)/8; % 99.9%
chi2_inv_value(5) = getchi2(8, 0.0001)/8; % 99.99%
%% output mingsong li
jalpha = [jalpha10',jalpha5',jalpha1',jalpha01',jalpha001'];
assignin('base','freq',freq);
assignin('base','pow',pow);
assignin('base','pow1',pow1(1:nout));
assignin('base','swa',swa(1:nout));
assignin('base','alphob',alphob);
assignin('base','alphsort',alphsort);
assignin('base','VarRatio',factoball);
assignin('base','chi2invalue',chi2_inv_value);
power = pow1(1:nout);
swa = swa(1:nout);
clfdr = [cl10',cl5',cl1',cl01',cl001'];
assignin('base','clfdr',clfdr);
if plotn ==1
    % figure; 
    % subplot(2,1,1); plot(freq, factoball), title('Variance Ratio')
    % subplot(2,1,2); plot(freq, alphob), title('ALPHA')
    % set(gca, 'YDir','reverse')
    figure; 
    hold on
    plot(freq, cl001,'k-.','LineWidth',0.5,'DisplayName','0.01% FDR'); % 99% FDR
    plot(freq, cl01,'g-.','LineWidth',0.5,'DisplayName','0.1% FDR'); % 99% FDR
    plot(freq, cl1,'b--','LineWidth',0.5,'DisplayName','1% FDR'); % 99% FDR
    plot(freq, cl5,'r--','LineWidth',2,'DisplayName','5% FDR'); % 95% FDR
    %plot(freq, cl10,'k--','LineWidth',0.5); % 90% FDR
    plot(freq, swa * chi2_inv_value(3),'b-','LineWidth',0.5,'DisplayName','99% chi^2 CL'); % 99%
    plot(freq, swa * chi2_inv_value(2),'r-','LineWidth',2,'DisplayName','95% chi^2 CL'); % 95%
    plot(freq, swa * chi2_inv_value(1),'k--','LineWidth',0.5,'DisplayName','90% chi^2 CL'); % 90%
    plot(freq, swa,'k-','LineWidth',2,'DisplayName','Background'); % smoothed
    plot(freq, power,'k-','LineWidth',0.5,'DisplayName','Power'); % real power
    set(gca,'YScale','log');
    xlabel('Frequency (cycles/unit)')
    ylabel('Power')
    title('Lomb-Scargle Transform and SWA Confidence Levels')
    legend%({'99% FDR', '5% FDR', '99%','95%','90%','SWA','Power'})
    xlim([0, max(freq)])
end
%%
% 
outfile = 'SWA-Spectrum-background-FDR.dat';
fidout = fopen(outfile, 'w');

% Write out results
%fprintf(fidout, '%%Data filename = %s\n', tsfile);
fprintf(fidout, '%%Data filename = %s\n', ' ');
fprintf(fidout, '%%Sum of power = %15.7f\n', sumpower);

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

%%
function [p,nout]=hanning(p,nout,varargin)
    nout = fix(nout); % Mingsong Li debug
    if isempty(i), i=0; end
    if isempty(k), k=0; end
    
    psmth=zeros(1,nout);
    psmth(:)=0.0d0;
    
    for  k=1:3
        psmth(1)=(0.5.*p(1))+(0.5.*p(2));
        psmth(nout)=(0.5.*p(nout-1))+(0.5.*p(nout));
        for  i=2:nout-1
            psmth(i)=(0.25.*p(i-1))+(0.5.*p(i))+(0.25.*p(i+1));
        end

        for  i=1:nout
            p(i)=psmth(i);
        end

    end

end
end
