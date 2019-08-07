function target = period2spectrum(orbit7,t1,t2,sr,f1,f2,method,pad)
% usging 7 orbit periods to calculate the power spectrum
% INPUT
%   orbit7: e.g., [405 125 95 41 24 22 19]
%   t1: 300000
%   t2: 308000
%   sr: sampling rate of t, e.g., 1
%   f1: frequency, e.g., 0
%   f2: frequency, e.g., 0.06
%   method: 2 = MTM; else = peridogram
%   pad: 5000

B = 0;
Ph = 0;
x = t1:sr:t2;
x = x';
data(:,1) = x;
ono = length(orbit7);
y0 = zeros(length(x),1);
for i = 1: 3
    periodi = orbit7(i);
    y = 1 * sin(2*pi/periodi*x + Ph) + B;
    y0 = y + y0;
end
for i = 4
    periodi = orbit7(i);
    y = .4 * sin(2*pi/periodi*x + Ph) + B;
    y0 = y + y0;
end
for i = 5
    periodi = orbit7(i);
    y = .8 * sin(2*pi/periodi*x + Ph) + B;
    y0 = y + y0;
end
for i = 6:ono
    periodi = orbit7(i);
    y = .6 * sin(2*pi/periodi*x + Ph) + B;
    y0 = y + y0;
end

data(:,2) = y0;

if method == 2
    [p, w] = pmtm(data(:,2),2,pad);
    f = w/(2*pi*sr);
else
    [p,f] = periodogram(data(:,2),[],pad,1/sr);
end
    target1 = [f,p];

[target] = select_interval(target1,f1,f2);