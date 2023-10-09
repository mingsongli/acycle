function [signal,sigo] = DetrendSignalPP(signal,windowsize,fs,Porder)
% DetrendSignalPP - Eliminates the baseline wander (varying 
% DC component) by means of the the polynomial modeling with zeroed pitch 
% frequency.
%
% Please cite:
%
%   Sinnesael, M., Zivanovic, M., De Vleeschouwer, D., Claeys, P. (2018) 
%   Spectral Moments in Cyclostratigraphy: Advantages and Disadvantages 
%   compared to more classic Approaches. Paleoceanography and Paleoclimatology
%   33, 493–510. https://doi.org/10.1029/2017PA003293
%
% Input:

% windowsize            Analysis frame length in samples.
% fs                    Sampling rate in the depth domain.
% Porder                Polynomial degree + 1

duration = length(signal);
inc = 1;

sigo = zeros(duration,1);
ooff = 0;
normo = sigo;
win = hanning(windowsize);

Position = 1:inc:round(length(signal)-windowsize+1);

for i = 1:length(Position)
    seg = signal(Position(i):Position(i) + windowsize - 1);
    
    segEst = LSmodeling(seg,fs,Porder); % polynomial baseline modeling
                
    % Overlap-add frame recombination
    sigo(round(ooff)+windowsize)=0;
    sigo((1:windowsize)+round(ooff)) = sigo((1:windowsize)+round(ooff)) + segEst(1:windowsize).*win;
            
    normo(round(ooff)+windowsize)=0;
    normo((1:windowsize)+round(ooff)) = normo((1:windowsize)+round(ooff)) + win;
    ooff = ooff + inc;
end
sigo = sigo./normo; % Trend
signal = signal - sigo; % Signal without trend

return




function [signal_est] = LSmodeling(signal,fs,Porder)

N = length(signal);
t = (0:N-1)'/fs;

T = zeros(N,Porder);
for i = 1:Porder
    T(:,i) = t.^(i-1);
end

[~,Tc] = size(T);
norms = zeros(Tc,1);
for kk = 1:Tc
    norms(kk) = norm(T(:,kk), 2);
end
Tn = bsxfun(@rdivide, T, norms');

THETA = Tn\signal;
signal_est = Tn*THETA;

return
