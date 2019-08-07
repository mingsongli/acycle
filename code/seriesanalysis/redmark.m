function yred=redmark(alfa,n)
%
%% Generate red noise using the Markov procedure
% alfa is the lag-1 autocorrelation [0,1]
% n is the number of data
%
% y(n) = alfa*y(n-1) + z(n)
% where z(n) is white noise
%
% Routine uses the in-built filter command
% from the Signal Processing Toolbox:
%
% a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
% - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%
% Thus a=[1;-alfa] and b=1 and x(n)=randn, that needs to be plugged into:
% Y = FILTER(B,A,X)
%
% https://www.mathworks.com/matlabcentral/newsreader/view_thread/37106
%%
randn('state',sum(100*clock)) % set a new seed
yred=filter(1,[1;-alfa],randn(n,1));