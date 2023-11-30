function [swa, winfinal] = specswa(freq, xlogp, ndata)
% Smoothed Window Averages
% INPUT
    %freq: frequency
    %xlogp: spectrum vector in log10 scale
    %ndata: number of data points
% OUTPUT
    %swa: smoothed window averages
    %winfinal: number of windows

nout = length(xlogp);
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
    
    if(revmin <= rev1 && revmin <= rev2) % BUG FIX - HY ZHU, 27 NOV 2023
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

fprintf('\n');  % Displaying an empty line
%try
    fprintf('winfinal = %d\n', winfinal);
    fprintf('rmsemin = %f\n', rmsemin);
%catch
%end
rmsel1 = rmsemin;

fprintf('\n');  % Displaying an empty line
fprintf(' Testing alternative white noise and\n');
fprintf(' quadratic fits to end of spectrum.\n');

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
    fprintf('  Using fixed final power in end window\n');
    fprintf('    rmsel1 = %f\n', rmsel1);
else
    fprintf('  White noise end of log spectrum (FITSP3) : RMSE = %f\n', rmse);
    fprintf('      does not give better fit\n');
end

%% Test whether quadratic fit to the end of the log spectrum gives a better fit. 
% Fitting the latter half of the last averaging window
% plus the remainingfrequencies.
j=1;
% winwidth = 31; finish = 226
xfr = zeros(length(freq)+1, 1); % debug
y   = zeros(length(freq)+1, 1); % debug

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
    fprintf('  Switching to quadratic fit for end window\n');
    fprintf('    rmsel1 = %f\n', rmsel1);
    %[writeErrFlag]=writeFmt(1,['%c'],'''  Switching to quadratic fit for end window''');
    %[writeErrFlag]=writeFmt(1,[format_231],'rmsel1');
else
    fprintf('  Quadratic fit for end window : RMSE = %f\n', rmse);
    fprintf('      does not give better fit\n');
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
