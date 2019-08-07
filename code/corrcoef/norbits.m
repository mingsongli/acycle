% Number of orbits involved
% INPUT
%   target: 2 columns, target frequencies and their power
%   f:  frequency of data
%   power: power of data
%   orbit7: 7 obrits period (kyr)
%   rayleigh: rayleigh frequency
%   sr:  sedimentation rates
% OUTPUT
%   nm: number of Milankovitch forcing not involved.
% Mingsong Li @ Penn State June 2017
% Mingsong Li revised July 2017

function [nm] = norbits(target,f,power,orbit7,rayleigh,sr)
%  spectrum of tuned series using sr (cm/kyr); f is cycles/m. Thus need a
%  100x
nm = 0; % number of Milankovitch forcing not involved.
aimarx = f * sr / 100;  % transfer f in cycles/m to cycles/kyr.
aimpower = power';
%aimpower = zscore(power'); % Normalized and then if the power >= 1, the peaks exists
P_nyquist = 1/aimarx(length(aimarx));
P_dfr = 1/(rayleigh * sr / 100);
% orbit7 shreshold
norbits = length(orbit7);
orbit8 = zeros(norbits+1,1);
p_orbit7 = zeros(norbits,1);
for i = 1: norbits - 1
    orbit8(i+1) = 2/(orbit7(i+1)+orbit7(i));
end
orbit8(norbits+1,1) = target(length(target(:,1)),1);
% find mean of non NaN value of power within 0-0.005 kyr-1 band.
for i = 1 : norbits
    ext =[];
    ext = find(and(aimarx > orbit8(i), aimarx <= orbit8(i+1)));
    pow = aimpower(ext);
    % related to corrcoefslices_rank.m
    %p_orbit7(i) = mean(pow(pow >= 1)); % 1 
    p_orbit7(i) = mean(pow(pow > 0)); % 1 was selected by experience of M. Li
    if isnan(p_orbit7(i)) || P_dfr < orbit7(i) || P_nyquist >= orbit7(i)
        nm = nm + 1;
    end
end