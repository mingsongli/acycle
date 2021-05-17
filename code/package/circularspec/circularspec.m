function [P,R,t0] = circularspec(data,pt,p1,p2,plotn)
% circular power spectral analysis
% 
% INPUT
%   data:  Nx1 1-column data
%   p1  : test period - start
%   p2  : test period - end
%   pt  : test period - step
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
% pt = 0.2;
% p2 = 60;
% data = load('extinction.mat');
% data = data.data;
%
% Mingsong Li, Penn State
% Oct. 17, 2020
% limingsonglms@gmail.com

if nargin < 1
    errormsg('Too few input arguments');
else
    data = sort(data);
    ddf = diff(data);
    if nargin > 5; warnmsg('Too many input arguments');end
    if nargin < 5; plotn = 1; end
    if nargin < 4; p2 = max(ddf); end
    if nargin < 3; p1 = min(ddf); end
    if nargin < 2; pt = (p2-p1)/100; end
end

% start
c1 = 2*pi*data;
P = p1:pt:p2;
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