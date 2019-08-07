% evolutionary rho of AR(1) technique for DNSL model
% INPUT
%   data: a evenly spaced [nx2] matrix; column 1 is time; column 2 is value
%   window:  window for evolutionary spectrum
% OUTPUT
%   rhox: evolutionary rho result
% Call for
%   rhoAR1.m

function [rhox] = erhoAR1(data,window)

dt = data(2,1) - data(1,1);
datax=data(:,2);

[nrow, ~]=size(data);    % size of data
npts=round(window/dt);              % number of data used for one calculation
m=nrow-npts+1;                      % number of rhoAR1 calculations

% Calculate evolutive rho for series of 'data' using given window

for m1=1:m
    m2=npts+m1-1;
    if m2>nrow                      % break in case of reach boundary of moving window
        break
    end
    for mx=m1:m2                    % pick data usging floating npts 
        j=mx-m1+1;                  % j = 1:npts
        x(j)=datax(mx);             %
    end
    x=detrend(x);
    [rho(m1)]=rhoAR1ML(x');
    m1=m1+1;
end    

xgrid=linspace(data(1,1)+window/2,data(nrow,1)-window/2,m);
rhox = [xgrid',rho'];
