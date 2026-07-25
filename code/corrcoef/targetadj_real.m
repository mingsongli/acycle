% Adjust target frequency using theored spetrum of data
% INPUT
%   target: 2 columns, target frequencies and their power
%   f:  frequency of data
%   power: power of data
%   sr:  sedimentation rates
% OUTPUT
%   nm: number of Milankovitch forcing not involved.
%   targ: adjusted target frequency using theored spetrum of data
% Mingsong Li @ Penn State June 2017
% Mingsong Li revised July 2017

function [targ] = targetadj_real(target,f,power,orbit7,rayleigh,sr)
%para = .1;  % amplitude of each frequency will be 0.1x previous frequency if it is NaN.
%para = 0.1 * max(power);  % amplitude of each frequency will be para if it is NaN.
para = 0;
orbit5 = [0;2/(orbit7(1)+orbit7(2));2/(orbit7(3)+orbit7(4));2/(orbit7(4)+orbit7(6));0.06];
%  spectrum of tuned series using sr (cm/kyr); f is cycles/m. Thus need a
%  100x
aimarx = f * sr / 100;  % transfer f in cycles/m to cycles/kyr.
aimpower = power(:);

p_orbit4 = zeros(4,1);

for i = 1 : 4
    ext =[];
    ext = find(and(aimarx > orbit5(i), aimarx <= orbit5(i+1)));
    pow = aimpower(ext);
    p_orbit4(i) = mean(pow(pow>=1));
    if isnan(p_orbit4(i))
        p_orbit4(i) = para;
    end
end
targetx = target(:,1);
targetp = target(:,2);
targ1 = zeros(size(targetx));
ext5 = find(targetx <= orbit5(2));  % E
ext6 = find(and(targetx > orbit5(2), targetx <= orbit5(3)));  % e
ext7 = find(and(targetx > orbit5(3), targetx <= orbit5(4)));  % O
ext8 = find(and(targetx > orbit5(4), targetx <= orbit5(5)));  % p
%
targ1 = scaleTargetBand(targ1, targetp, ext5, p_orbit4(1)); % E
targ1 = scaleTargetBand(targ1, targetp, ext6, p_orbit4(2)); % e
targ1 = scaleTargetBand(targ1, targetp, ext7, p_orbit4(3)); % O
targ1 = scaleTargetBand(targ1, targetp, ext8, p_orbit4(4)); % p
targ(:,1) = target(:,1);
targ(:,2) = targ1;

function targ1 = scaleTargetBand(targ1, targetp, idx, bandPower)
if isempty(idx) || ~isfinite(bandPower)
    return
end
denom = max(targetp(idx));
if ~isfinite(denom) || denom <= 0
    return
end
targ1(idx) = bandPower .* targetp(idx) ./ denom;
