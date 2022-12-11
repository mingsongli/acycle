function S = recplot(x,threshold,t,plotn,labelx,labely)
% Recurrence Plot
% x: time series, Nx1
% threshold: threshold
% t: time, Nx1
% plotn: plot or not; 1 = recurrence plot; 2 = recurrence plot + series
% labelx : x label for recurrence plot and time series
% labeiy : y label for the time series only
%
% Reference:
%
% Recurrence plot
% http://www.recurrence-plot.tk/rp-tutorial.php
%
% Example:
% x = randn(300,1);
% threshold = 0.2;
% recplot(x,threshold)
%
% By Mingsong Li (msli@pku.edu.cn)
% Peking University
% Dec. 11, 2022
%
if nargin < 6; labely = 'Value'; end
if nargin < 5; labelx = 'Time'; end
if nargin < 4; plotn = 1; end
if nargin < 3; t = 1:length(x);end
if nargin < 2; threshold = 0.2; end
if nargin < 1; error('Error: no data'); end

N = length(x);
S = zeros(N, N);

% We start with the assumption that the phase space is only 1-dimensional. 
% The calculation of the distances between all points of the phase space 
% trajectory reveals the distance matrix S.

for i = 1:N
    S(:,i) = abs( repmat( x(i), N, 1 ) - x(:) );
end

% Now we plot the distance matrix
% Recurrence plot by applying a threshold of 0.2 to the distance matrix

if plotn == 1
    figure;
    set (gcf,'color','w','Name','Recurrence Plot')
    % imagesc(t, t, S < 0.2);
    imagesc(t, t, S < threshold);

    axis square; 
    colormap([1 1 1;0 0 0]); 
    xlabel(labelx), 
    ylabel(labelx)
    %set (gca, 'xdir', 'reverse' )
    ylabel(labelx)
    
elseif plotn == 2
    
    figure;
    set (gcf,'color','w','Name','Recurrence Plot')
    % R2019a
    try
        % Requires R2019b or later
        paneli = tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact');
        nexttile
        plot(t,x)
        xlim([min(t), max(t)])
        axis square; 
        xlabel(labelx)
        ylabel(labely)
        %set (gca, 'xdir', 'reverse' )
        
        nexttile
        imagesc(t, t, S < threshold);
        axis square; 
        colormap([1 1 1;0 0 0]); 
        xlabel(labelx)
        ylabel(labelx)
        %set (gca, 'xdir', 'reverse' )
        
    catch
        subplot(2,1,1)
        plot(t,x)
        xlim([min(t), max(t)])
        axis square; 
        ylabel(labely)
        %set (gca, 'xdir', 'reverse' )

        subplot(2,1,2)

        imagesc(t, t, S < threshold);
        axis square; 
        colormap([1 1 1;0 0 0]); 
        xlabel(labelx)
        ylabel(labelx)
        %set (gca, 'xdir', 'reverse' )
    end
end
