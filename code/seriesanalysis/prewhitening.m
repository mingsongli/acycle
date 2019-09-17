
function datp = prewhitening(data,rho)
% prewhitening function
%  xp(t) = x(t)−ρ1x(t +1), where
%   x(t) represents the time series value at position t 
%   and xp(t) represents the corresponding pre-whitened value
%   in Weedon (2003) page 50.
%
% INPUT
%  data: n by 2 data, uniformly spaced
%  rho:  lag-1 autocorrelation
%
%  By Mingsong Li
%   Penn State, Sept. 17, 2019
%
if nargin < 2
    [rho]=rhoAR1ML(data(:,2));
end
% if or(rho > 1, rho<-1)
%     msgbox('AR1 may be within [-1,1]')
% end
datax = data(:,1);
datay = data(:,2);

datp(:,1) = datax(1: end-1);
datp(:,2) = datay(1:end-1) - rho * datay(2:end);