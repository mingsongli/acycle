function [a,b,amp,pha] = harm1ML(x,y,period)

% harmonic analysis: lease square estimate of amplitude and phase
%
%  y = a * con(wt) + b * sin(wt)
% 
% Lease squares harmonic analysis based on Hinnov & Maurer, unpublished notes.
%
% Input
%   y: a n-by-1 vector
%   dt: sampling rate
%   period: estimated period
%
% Output
%   a: 
%   b: 
%   amp: amplitude value
%   pha: phase value
%
% calls for harm1ML.m
%
% by Mingsong Li, Penn State, Jan 5, 2019

n = length(y);
% x = linspace(0,n*dt,n);
% x = x';

f = 1/period;

cn = cos(2 * pi * x * f);
sn = sin(2 * pi * x * f);

c1 = sum( cn .* cn );
c2 = sum( cn .* sn );
c3 = sum( sn .* sn );
c4 = sum( y  .* cn );
c5 = sum( y  .* sn );

ab = [c1,c2;c2,c3]\[c4;c5];

a  = ab(1);
b  = ab(2);

amp = sqrt(a^2 + b^2);
try pha = atan(b/a);
catch
    pha = NaN;
    error('Error: cannot calculate atan(b/a)')
end

%% show
% yp = a * cn + b * sn;
% figure;
% plot(x,y,'k')
% hold on;
% plot(x,yp,'r')
% legend('raw','harmonic')