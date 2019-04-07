% input
%   datax
%   pad
%   dt
%   nw
% Calls for 
%   rhoAR1
%

function [theored]=theoredar1ML(datax,f,meanp,dt)
nf = length(f);
[rho] = rhoAR1ML(datax);
fnyq = 1/(2*dt);
theored = (1-repmat(rho.^2,[nf,1]))./(1-(cos(pi.*f/fnyq).*2*rho)+repmat(rho.^2,[nf,1]));
% normalization of the spectrum
theoredun=theored(1,:);
theored(1,1:end) = 0;
Art = mean(theored);
theored(1,:) = theoredun;
theored = theored .* repmat((meanp./Art),[nf,1]);