function [swa, winfinal, diagnostics] = specswa(freq, xlogp, ndata, verbose)
% Smoothed Window Averages
% INPUT
    %freq: frequency
    %xlogp: spectrum vector in log10 scale
    %ndata: number of data points
% OUTPUT
    %swa: smoothed window averages
    %winfinal: number of windows
% OPTIONAL
    %verbose: true (default) prints fit diagnostics; false is silent
% DIAGNOSTICS (optional third output)
    % auditable metadata for the selected initial fit and tail/smoothing
    % decisions. NDATA is retained for backward API compatibility; the
    % fitted background is determined by FREQ and XLOGP.

if nargin < 4 || isempty(verbose)
    verbose = true;
end
validateattributes(freq,{'numeric'}, ...
    {'vector','real','finite','nonempty'},mfilename,'freq',1);
validateattributes(xlogp,{'numeric'}, ...
    {'vector','real','finite','nonempty'},mfilename,'xlogp',2);
validateattributes(ndata,{'numeric'}, ...
    {'scalar','integer','positive','finite'},mfilename,'ndata',3);
freq = freq(:);
xlogp = xlogp(:);
if any(diff(freq) <= 0)
    error('specswa:InvalidFrequency', ...
        'FREQ must be strictly increasing.');
end
validateattributes(verbose,{'numeric','logical'}, ...
    {'scalar','real','finite'},mfilename,'verbose',4);
if ~ismember(double(verbose),[0,1])
    error('specswa:InvalidVerbose','VERBOSE must be true or false.');
end
verbose = logical(verbose);

nout = length(xlogp);
if numel(freq) ~= nout || nout < 33
    error('specswa:InsufficientSpectrum', ...
        ['SWA requires matching frequency/log-power vectors with at ', ...
         'least 33 ordinates (three initial 11-bin windows).']);
end
%% Find log spectrum averages in fixed-width windows.
% Test WINWIDTH as an odd integer from 11 to 99.
winwidth=9;
rmsemin=1.0e+20;
revmin=Inf;
selectedFinish=[];
selectedWinwidth=[];
selectedLastMean=[];
selectedVariant=[];
selectedInitialReversalCount=[];
selectedInitialRmse=[];
midw=zeros(nout,1);
fitsp=zeros(nout,1);
fitsp1=zeros(nout,1);
fitsp2=zeros(nout,1);
fitsp3=zeros(nout,1);

% Repeat testing WINWIDTH from here
% Never test a width that leaves fewer than three complete windows.  The
% original loop could continue to ncycle=2 or 0 and then index MIDW(3) or
% MIDW(0), which caused red=3 to fail even for otherwise valid padded COCO
% spectra.
while (winwidth < 99 && floor(nout/(winwidth+2)) >= 3)
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
        for  iwin=1:winwidth
            sump=sump+xlogp(k+iwin);
        end
        % Window index
        j=j+1;
        % Window log power average
        midw(j)=sump./awinwidth;
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
        % Adjacent non-overlapping window centres are exactly WINWIDTH
        % ordinates apart.  Advancing only WINWIDTH-1 positions compressed
        % the fitted spectrum by one bin per window and displaced the
        % high-frequency tail.
        for  j=1:winwidth
            ii=ii+1;
            value=value+diff0;
            fitsp1(ii)=value;
            fitsp2(ii)=value;
        end
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
    for  i=(finish+1):nout
        value1=value1+diff1;
        fitsp1(i)=value1;
        value2=value2+diff0;
        fitsp2(i)=value2;
    end

    % Find RMSE using fitted backgrounds (FITSP1 and FITSP2) and, to
    % ensure smooth fit, minimize the number of fitted slope reversals.
    se=0.0;
    for  i=1:nout
        residualValue=xlogp(i)-fitsp1(i);
        se=se+(residualValue.*residualValue);
    end
    
    anout=nout;
    rmsef1=sqrt(se./(anout-1));

    se=0.0;
    for  i=1:nout
        residualValue=xlogp(i)-fitsp2(i);
        se=se+(residualValue.*residualValue);
    end
    rmsef2=sqrt(se./(anout-1));
    % Every candidate must be scored on the same frequency support.  The
    % former Ncycle*winwidth limit varied with WINWIDTH and could therefore
    % favour a candidate merely because its unscored remainder was longer.
    rev1=nnz(diff(fitsp1(1:nout)) >= 0);
    rev2=nnz(diff(fitsp2(1:nout)) >= 0);
    
    % Lexicographic selection: first minimize the number of non-decreasing
    % fitted steps (spectral reversals), then minimize RMSE only among
    % candidates with the same reversal count.  The former translated
    % logic could replace a smoother fit by one with more reversals and
    % could stop before comparing all zero-reversal candidates.
    if rev1 < revmin || (rev1 == revmin && rmsef1 < rmsemin)
        revmin=rev1;
        rmsemin=rmsef1;
        winfinal=winwidth;
        selectedFinish=finish;
        selectedWinwidth=winwidth;
        selectedLastMean=midw(ncycle);
        selectedVariant=1;
        selectedInitialReversalCount=rev1;
        selectedInitialRmse=rmsef1;
        for  i=1:nout
            fitsp(i)=fitsp1(i);
        end
    end
    
    if rev2 < revmin || (rev2 == revmin && rmsef2 < rmsemin)
        revmin=rev2;
        rmsemin=rmsef2;
        winfinal=winwidth;
        selectedFinish=finish;
        selectedWinwidth=winwidth;
        selectedLastMean=midw(ncycle);
        selectedVariant=2;
        selectedInitialReversalCount=rev2;
        selectedInitialRmse=rmsef2;
        for  i=1:nout
            fitsp(i)=fitsp2(i);
        end
    end
    
end

if isempty(selectedFinish) || isempty(selectedWinwidth) || ...
        isempty(selectedLastMean)
    error('specswa:NoBackgroundFit', ...
        'SWA could not select a finite background fit.');
end
% FITSP may have been selected at an earlier width than the last width
% tested.  Tail alternatives must use metadata from that same selected fit.
finish = selectedFinish;
winwidth = selectedWinwidth;

if verbose
    fprintf('\n');
    fprintf('winfinal = %d\n',winfinal);
    fprintf('rmsemin = %f\n',rmsemin);
end
rmsel1 = rmsemin;
tailModel = 'extrapolated';

if verbose
    fprintf('\n');
    fprintf(' Testing alternative white noise and\n');
    fprintf(' quadratic fits to end of spectrum.\n');
end

%% Test whether white noise end of log spectrum (FITSP3) gives better fit.
% Up to end of last window
for  i=1:(finish-1)
    % copy FITSP
    fitsp3(i)=fitsp(i);
end
% Remainder of spectrum
for  i=finish:nout
    % Fix as last window average
    fitsp3(i)=selectedLastMean;
    %fitsp3(i)=midw(floor(ncycle)); % mingsong li debug
end
se=0.0;

for  i=1:nout
    residualValue=xlogp(i)-fitsp3(i);
    se=se+(residualValue.*residualValue);
end
anout=nout;
rmse=sqrt(se./(anout-1));
if(rmse < rmsel1)
    for  i=1:nout
        % Select white noise end fit
        fitsp(i)=fitsp3(i);
    end
    rmsel1=rmse;
    tailModel = 'constant';
    if verbose
        fprintf('  Using fixed final power in end window\n');
        fprintf('    rmsel1 = %f\n',rmsel1);
    end
else
    if verbose
        fprintf('  White noise end of log spectrum (FITSP3) : RMSE = %f\n',rmse);
        fprintf('      does not give better fit\n');
    end
end

%% Test whether a quadratic end fit gives a better fit.
% Fit the latter half of the last averaging window plus the remaining
% frequencies.  The former translated implementation skipped the first
% tail frequency, included one uninitialised observation, and wrote the
% fitted values from FINISH-20 regardless of the selected window width.
% POLYFIT performs the same least-squares quadratic fit with explicit,
% auditable indices and centring/scaling for numerical stability.
tailStart = max(1,finish-floor(winwidth/2));
tailIndex = (tailStart:nout)';
xTail = freq(tailIndex);
yTail = xlogp(tailIndex);
fitsp3 = fitsp;
quadraticAvailable = numel(tailIndex) >= 3 && numel(unique(xTail)) >= 3;
if quadraticAvailable
    [quadraticCoefficient,~,quadraticScale] = polyfit(xTail,yTail,2);
    fitsp3(tailIndex) = polyval( ...
        quadraticCoefficient,xTail,[],quadraticScale);
    residual = xlogp-fitsp3(:);
    rmse=sqrt(sum(residual.^2)./(anout-1));
else
    rmse=Inf;
end
if rmse < rmsel1
    fitsp=fitsp3;
    rmsel1=rmse;
    tailModel = 'quadratic';
    if verbose
        fprintf('  Switching to quadratic fit for end window\n');
        fprintf('    rmsel1 = %f\n',rmsel1);
    end
else
    if verbose
        fprintf('  Quadratic fit for end window : RMSE = %f\n',rmse);
        fprintf('      does not give better fit\n');
    end
end

%% Use Hanning smoothing to create a smoothed linear interpolation.
% optional
% Finish smoothing when RMSE degraded (increased) by 1%.

% Keep the last accepted fit.  Previously the first smoothing iteration
% that exceeded the 1%% RMSE allowance was retained before the loop broke.
nsmth = 0;
rmset = rmsel1;
while nsmth < 500
    candidate = zeros(size(fitsp));
    candidate(1) = (0.5 * fitsp(1)) + (0.5 * fitsp(2));
    candidate(nout) = (0.5 * fitsp(nout-1)) + (0.5 * fitsp(nout));
    
    for i = 2:(nout-1)
        candidate(i) = (0.25 * fitsp(i-1)) + ...
            (0.5 * fitsp(i)) + (0.25 * fitsp(i+1));
    end
    candidateResidual = xlogp-candidate(:);
    candidateRmse = sqrt(sum(candidateResidual.^2) / (nout-1));
    if candidateRmse < rmsel1 * 1.01
        fitsp = candidate;
        rmset = candidateRmse;
        nsmth = nsmth + 1;
    else
        break;
    end
end

if verbose
    fprintf('\n');
    fprintf('After smoothing RMSE = %.6f\n',rmset);
end

%% SWA results

swa = 10.0 .^ fitsp(:);
diagnostics = struct( ...
    'initialVariant',selectedVariant, ...
    'initialNondecreasingCount',selectedInitialReversalCount, ...
    'initialRMSE',selectedInitialRmse, ...
    'selectedWindow',winfinal, ...
    'tailModel',tailModel, ...
    'nSmoothing',nsmth, ...
    'finalRMSE',rmset, ...
    'ndataCompatibilityInput',ndata, ...
    'nFrequency',nout);
