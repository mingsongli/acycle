% rhoAR1 subroutine
%
% this subroutine calculates the lag-1 autocorrelation coefficient 
% for an AR1 autocorrelation of data with fixed sampling step d.

% In case of a constant sampling step, a=rho^(1/d) (with 0<a<1)
%                                  
%                                         _n             _n
% then, according to Mudelsee 2002,  rho= \ (x(i)x(i-1)/ \x(i-1)^2
%                                         /              /
%                                         i=2            i=2
%
%
%
%
% Inputs : 
% datax = 1 column array with measures resampled with a constant sampling step.
%
% Outputs :
% rho = lag-1 autocorrelation coefficient.
%
% Dorothée Husson, November 2012

function [rho]=rhoAR1(datax)

nrho=length(datax);
rho=0;
sommesup=0;
sommeinf=0;
moy=sum(datax)/nrho;
datam=datax-moy;
for i=2:nrho
    j=i-1;
    sommesup=sommesup+(datam(i)*datam(j));
    sommeinf=sommeinf+((datam(j))^2);
end
rho=sommesup/sommeinf;
end