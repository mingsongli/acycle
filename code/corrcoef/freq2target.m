function [px] = freq2target(f,p,fx,fray)
%   Reconstruct a series using given fx and rayleigh frequency using target
%   orbital frequencies
%
% INPUT
%   f  1 column; target orbital frequencies
%   p  1 column; target orbital frequencies power
%   fx 1 column; new target series frequencies from 0 to 0.06, n_length = 600
%   fray  1 number. Rayleigh frequency.
% OUTPUT
%   px  1 column; new target series

%   Mingsong Li, June 2017

nf = length(f);
f_sim = repmat(fx,[1,nf]);
% sigma = half of rayleigh
sigma = 1/2*fray;
%
px = zeros(length(fx),1);

for i = 1:nf
    norm1 = normpdf(f_sim(:,i),f(i),sigma);
    norm2 = p(i) * norm1/max(norm1);
    px = px + norm2;
end