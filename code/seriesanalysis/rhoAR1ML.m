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
% %datax = 1 column array with measures resampled with a constant sampling step.
% datax: if datax is a matrix, estimate rho for each column.
% Outputs :
% rho = lag-1 autocorrelation coefficient.
%
% Dorothée Husson, November 2012
% Mingsong Li, June 2017. Revise for both vector and matrix of datax

function [rho]=rhoAR1ML(datax)

[nrho, ncol] = size(datax);
sommesup = zeros(1,ncol);
sommeinf = zeros(1,ncol);
moy = mean(datax);
datam = datax - repmat(moy,[nrho,1]);
for i=2:nrho
    j=i-1;
    sommesup = sommesup + (datam(i,:) .* datam(j,:));
    sommeinf = sommeinf+((datam(j,:)).^2);
end
rho = sommesup./sommeinf;
end