function [Y,testi] = crp_pdist(x,w,ws,theiler_window, lmin, plotn)
% DET of the recurrence plot
% INPUT
% x: series, Nx1
% w: window size
% ws: sliding step
% theiler_window: specifies the Theiler window (default is 1)
% lmin: minimal length of diagonal and vertical line structures (default is 2)
% plotn: plot (1 default) or not (0)
%
% OUTPUT
%  Y
%
%clear;clc;
%
%rng(0)
%x = rand(600,1);
%
% Code borrowed from:
% Norbert Marwan, Potsdam Institute for Climate Impact Research, Germany
% http://www.pik-potsdam.de
% By Mingsong Li (msli@pku.edu.cn)
% Peking University
% Dec. 11, 2022
%
%%
Nx=length(x); % length of x

if nargin < 6, plotn = 1; end
if nargin < 5, lmin = 2; end         % minimal length of diagonal and vertical line structures (default is 2)
if nargin < 4, theiler_window=1; end % TW specifies the Theiler window (default is 1)
if nargin < 3, ws = 1; end           % a window shifting value
if nargin < 2, w = 1/2 * Nx; end     % window size

%%

testi = 1:ws:Nx-w+1;
testnn = length(testi);
jj = 1;
Y = nan(testnn,1);
borderline_corr_n = 1;
borderline_corr_str = {'all';'Censi';'KELO'};

for i = 1:ws:Nx-w+1
    
    xcor = @(x,y) sqrt(sum((repmat(x,size(y,1),1)-y).^2,2));
    x_dist = pdist(x(i:i+w-1,:),xcor);
    X = squareform(x_dist);

    if theiler_window > 0
         X_theiler=double(triu(X,theiler_window))+double(tril(X,-theiler_window));
    else
         X_theiler=X;
    end

    [a, b]=dl(X_theiler,borderline_corr_str{borderline_corr_n});

    b(b<lmin)=[];

    if isempty(b)
        b=0; 
    end
    
    if sum(X_theiler(:)) > 0
       DET=sum(b)/sum(X_theiler(:));
     else
       DET=NaN;
    end

    Y(jj) = DET;
    jj = jj + 1;
end
testi = testi';

% Plot
if plotn == 1
    figure; 
    subplot(2,1,1)
    plot(1:Nx,x);
    xlim([1 Nx])
    xlabel('Time')
    ylabel('Value')
    
    subplot(2,1,2);
    plot(testi + w/2,Y);
    xlim([1 Nx])
    xlabel('Series')
    ylabel('DET')
end