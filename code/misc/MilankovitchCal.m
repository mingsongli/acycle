%% Milankovitch Calculator
%
% Ref:
%   https://davidwaltham.com/wp-content/uploads/2014/01/Milankovitch.html
% Details in:
%   Waltham, D., 2015. Milankovitch Period Uncertainties and Their Impact on Cyclostratigraphy JSR
%   DOI: http://dx.doi.org/10.2110/jsr.2015.66
%
% JaveScript by 
%   DAVID WALTHAM (Royal Holloway, University of London, Egham)
% MatLab translation by
%   Mingsong Li (Peking University)
%   June 10, 2021
%
%%
%
function [daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max, p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max] = MilankovitchCal(age)
%%
% global constants
% age = 300;
f0min = 20.0;
f0max = 22.0;
f4500min = 6.77;
f4500max = 6.93;

[daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max,...
    p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max] = calculate(age, f0min, f0max, f4500min, f4500max);

end

% calculate ranges
function [daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max,...
    p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max] = calculate(age, f0min, f0max, f4500min, f4500max)
    %frange()    % drag factor
    [fmin, fmax] = frange(age, f0min, f0max, f4500min, f4500max);
    
    % arange(); % Earth-Moon distance
    [amin, amax] = arange(age, fmin, fmax);
    
    %obliquity(); % range of obliquities
    [obmin,obmax] = obliquity(amin,amax);

    %dayrange(); % length of Earth day
    [daymin, daymax, omegamin, omegamax] = dayrange(obmin, obmax, amin, amax);
    
    %krange(); % precession frequency
    [kmin, kmax] = krange(amin, amax, obmin, obmax, omegamin, omegamax);

    %obrange(); % obliquity cycle periods
    [o1min, o1max] = obrange(kmin, kmax);

    %cprange(); % climatic precession periods
    [p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max] = cprange(kmin, kmax);

    %writeresults(); % write out results to web page
    writeresults(daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max,...
    p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max)

end



function writeresults(daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max,...
    p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max)

    % write out distance range
    distance = 0.5*( amax + amin );
    distsigma = 0.5*( amax - amin);
    accuracy = decimalPlaces(distsigma);
    disp(['Earth-Moon Distance : ', num2str(distance), ' +/- ', num2str(distsigma),' km'])
    
    % write out day-length range
    day = 0.5*( daymax + daymin );
    daysigma = 0.5*( daymax - daymin );
    accuracy = decimalPlaces(daysigma);
    disp(['Earth Day : ', num2str(day), ' +/- ', num2str(daysigma),' hours'])

    % write out obliquity range
    obliq = 0.5*( obmax + obmin );
    obsigma = 0.5*( obmax - obmin);
    accuracy = decimalPlaces(obsigma);
    disp(['Earth Axis Mean Obliquity : ', num2str(obliq), ' +/- ', num2str(obsigma),' degrees'])
    
    % write out precession range
    kkymin = 360.0*3.6/kmax;
    kkymax = 360.0*3.6/kmin;
    prec = 0.5*( kkymax + kkymin );
    precsigma = 0.5*( kkymax - kkymin);
    accuracy = decimalPlaces(precsigma);
    disp(['Earth Axis Precession Period : ', num2str(prec), ' +/- ', num2str(precsigma),' kyr'])
    
    % write out obliquity cycle periods
    o1 = 0.5*( o1max + o1min );
    o1sigma = 0.5*( o1max - o1min );
    accuracy = decimalPlaces(o1sigma);
    disp('Main Obliquity Period : (kyr)')
    
    disp([num2str(o1), ' +/- ', num2str(o1sigma)])

    % write out climatic precession periods
    p1 = 0.5*( p1max + p1min );
    p1sigma = 0.5*( p1max - p1min );
    accuracy = decimalPlaces(p1sigma);
    disp('Climatic Precession Periods : (kyr)')
    disp([num2str(p1), ' +/- ', num2str(p1sigma)])

    p2 = 0.5*( p2max + p2min );
    p2sigma = 0.5*( p2max - p2min );
    accuracy = decimalPlaces(p2sigma);

    disp([num2str(p2), ' +/- ', num2str(p2sigma)])

    p3 = 0.5*( p3max + p3min );
    p3sigma = 0.5*( p3max - p3min );
    accuracy = decimalPlaces(p3sigma);

    disp([num2str(p3), ' +/- ', num2str(p3sigma)])

    p4 = 0.5*( p4max + p4min );
    p4sigma = 0.5*( p4max - p4min );
    accuracy = decimalPlaces(p4sigma);

    disp([num2str(p4), ' +/- ', num2str(p4sigma)])

end

% calculate how many decimal places to show based upon accuracy of number

function [acc] = decimalPlaces(uncertainty)

    acc = ceil(1 - log10(exp(1)) * log(uncertainty) );

    if acc < 0 

        acc = 0;

    end

    if acc==inf

        acc = 1;

    end

end


%drag factor range

function [fmin, fmax] = frange(age, f0min, f0max, f4500min, f4500max)

    %secularF();
    [fmin, fmax] = secularF(age, f0min, f0max, f4500min, f4500max);
    
    fsecmin = fmin;

    fsecmax = fmax;

    %stochasticF();
    [fmin, fmax] = stochasticF(age, f4500max,f0max);
    
    if fsecmin < fmin
        fmin = fsecmin;
    end
    
    if fsecmax > fmax
        fmax = fsecmax;
    end
    
end



function [fmin, fmax] = secularF(age, f0min, f0max, f4500min, f4500max)

    taumin = 100.0;

    taumax = 1000.0;

    %long term means

    alphamin = (taumin/4500.0)*( 1.0 - exp(-4500.0/taumin) );

    alphamax = (taumax/4500.0)*( 1.0 - exp(-4500.0/taumax) );

    fbarmin = ( f4500min - alphamin*f0min ) / ( 1.0 - alphamin );

    fbarmax = ( f4500max - alphamax*f0max ) / ( 1.0 - alphamax );

    %hence f drag range

    fmin = fbarmin + ( taumin/age )*( f0min - fbarmin )*( 1.0 - exp(-age/taumin) );

    fmax = fbarmax + ( taumax/age )*( f0max - fbarmax )*( 1.0 - exp(-age/taumax) );
end


function [fmin, fmax] = stochasticF(age, f4500max,f0max)

    % max f uses maximum time-constant

    taumax = 100.0;

    %true long term mean

    sigma = 1.48;
    ntotal = 4500.0/taumax;
    M = (( 1.0 + ntotal )*f4500max - f0max ) / (ntotal * exp(sigma/sqrt(ntotal)));



    % maximum f
    icount = 1.0 + (age/taumax);
    fmax = ( f0max + icount * M * exp( sigma/sqrt(icount)) ) / (1.0+icount);

    % minimum f uses a functional fit to the observed envelope
    fmin = 5.69 + 1.225 * ( 1.0 - exp(-age/2103) );

end


% distance range

function [amin, amax] = arange(age, fmin, fmax)

    a0 = 384.399*1e6;

    a06p5 = a0^6.5;

    fconst = 3.15576e50;

    power = 1.0/6.5;

    amin = a06p5 - 6.5*fconst * age * fmax;

    if amin<0.0
        amin = 0.0;
    end
    
    amin = 1e-6 * amin^power;

    amax = a06p5 - 6.5 * fconst * age * fmin;

    amax = 1e-6 * amax^power;
end

%  day-length range (NB numerator and denominator both reduced by 10^25 to keep numbers "small")

function [daymin, daymax, omegamin, omegamax] = dayrange(obmin, obmax, amin, amax)

    omega0 = 3.397618e9;

    mred = 7.26061057334;

    mu = 4.0334319e14;

    c = 8.04e12;

    xmax = cos(obmin*3.14159/180);

    xmin = cos(obmax*3.14159/180);

    omegamin = ( omega0 - mred * sqrt(mu*amax) ) / (c*xmin);

    omegamax = ( omega0 - mred * sqrt(mu*amin) ) / (c*xmax);

    daymax = 2.0*pi*( 1.0 + (1.0/365.24) ) / ( omegamin*3600.0 );

    daymin = 2.0*pi*( 1.0 + (1.0/365.24) ) / ( omegamax*3600.0 );
end


% obliquity range in degrees

function [obmin,obmax] = obliquity(amin,amax)
    obmin = 84.23171 - 0.8430214*amin + 0.003838065*amin^2 - 7.656218e-6*amin^3 + 5.991817e-9*amin^4;
    obmax = 84.23171 - 0.8430214*amax + 0.003838065*amax^2 - 7.656218e-6*amax^3 + 5.991817e-9*amax^4;
end


% precession frequency range (NB lunar mass reduced by 10^18 to allow 'a' expressed in 1000km

function [kmin, kmax] = krange(amin, amax, obmin, obmax, omegamin, omegamax)
    k = 3.989917e8;
    m = 73500.0;
    s = 0.000594103125029;
    kmin = k * omegamin * ( (m/(amax^3)) + s ) * cos(obmax*3.14159/180.0);
    kmax = k * omegamax * ( (m/(amin^3)) + s ) * cos(obmin*3.14159/180.0);
end


% obliquity cycle periods
function [o1min, o1max] = obrange(kmin, kmax)
    ob1min = kmin - 18.848 - 0.066;
    ob1max = kmax - 18.848 + 0.066;
    o1max = 360.0*3.6/ob1min;
    o1min = 360.0*3.6/ob1max;
end

% climatic precession cycle periods
function [p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max] = cprange(kmin, kmax)
    cp1min = kmin + 4.257482 - 0.00003;
    cp1max = kmax + 4.257482 + 0.00003;
    cp2min = kmin + 7.453 - 0.019;
    cp2max = kmax + 7.453 + 0.019;
    cp3min = kmin + 17.916 - 0.2;
    cp3max = kmax + 17.916 + 0.2;
    cp4min = kmin + 17.368 - 0.2;
    cp4max = kmax + 17.368 + 0.2;
    p1max = 360.0*3.6/cp1min;
    p1min = 360.0*3.6/cp1max;
    p2max = 360.0*3.6/cp2min;
    p2min = 360.0*3.6/cp2max;
    p3max = 360.0*3.6/cp3min;
    p3min = 360.0*3.6/cp3max;
    p4max = 360.0*3.6/cp4min;
    p4min = 360.0*3.6/cp4max;
end

% recalculate whenever anything changes
function setAge()
    age= 1.0 * document.lunar.age.value;

    if age < 0
        disp("Age < 0 Ma not recommended");
    end

    if age > 4000
        disp("Age > 4000 Ma not recommended");
    end

    calculate();
end