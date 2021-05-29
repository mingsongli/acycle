function [P,R,t0] = circularspec(data,p1,p2,pn,linlog,plotn)
% circular power spectral analysis
% 
% INPUT
%   data:  Nx1 1-column data
%   p1  : test period - start
%   p2  : test period - end
%   pn  : test steps
%   linlog: linear or log steps; 1 = log; 2 = linear
%   plotn: plot figure or not - 1 = yes; 0 = no
%
% OUTPUT
%   P  : period
%   R  : power
%   t0 : phase
%
% Examples
%
% p1 = 0.1;
% p2 = 60;
% pn = 100;
% linlog = 2;
% plotn = 1;
% data = load('extinction.mat');
% data = data.data;
% [P,R,t0] = circularspec(data,p1,p2,pn,linlog,plotn)

% Mingsong Li, Penn State
% Oct. 17, 2020
% limingsonglms@gmail.com
% Updated May 29, 2021
% Mingsong Li, Peking University; msli@pku.edu.cn

if nargin < 1
    errormsg('Too few input arguments');
else
    data = sort(data);
    ddf = diff(data);
    if nargin > 6; warnmsg('Too many input arguments');end
    if nargin < 6; plotn = 1; end
    if nargin < 5; linlog = 2; end
    if nargin < 4; pn = 100; end
    if nargin < 3; p2 = max(ddf)-min(ddf); end
    if nargin < 2; p1 = min(ddf); end
end

% start
c1 = 2*pi*data;
if linlog == 2
    P = linspace(p1,p2,pn);
else
    sedinc = (log10(p2) - log10(p1))/(pn-1);
    P = zeros(1,pn);
    for ii = 1: pn
        P(ii) = 10^(  log10(p1)  +  (ii-1) * sedinc ) ;
    end
end

c2 = c1./P;
% angles
ai = sin(c2);
bi = cos(c2);
% mean
S = mean(ai);
C = mean(bi);
% magnitude or normalized measure of goodness of fit
R = sqrt(S.^2 + C.^2);
% phase
t1 = P/(2*pi) .* atan(S./C); % if C>0
t2 = P/2 + t1;  % if C<0;

t0 = t1;
t0(C<0) = t2(C<0);
% end

% plot
if plotn
    figure;
    plot(P,R,'k-','LineWidth',2)
    xlabel('period')
    ylabel('power')
end