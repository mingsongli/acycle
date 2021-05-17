
% Circular spectral analysis confidence levels
% INPUT
%   this is not a function
% OUTPUT
%   this is not a function
% Calls for
%   circularspec.m   % circular spectral analysis
%   extinction.mat   % example data
% EXAMPLE
%   see below
%
% Mingsong Li, Penn State
% Oct. 17, 2020
% limingsonglms@gmail.com
%%
% User defined parameters

clmodel = 2;    % 1 = fixed distance
                % 2 = random distance
mcn = 100000;  % monte carlo iterations
p1 = 5;   %   p1  : test period - start
pt = 0.1; %   pt  : test period - step
p2 = 50;  %   p2  : test period - end
data = load('extinction.mat'); % load data
data = data.data; % load data

% User defined parameters

%%
% start
P = p1:pt:p2;
Pn = length(P);
RR = zeros(mcn,Pn);
plotn = 0;  % no plot for the Monte Carlo simulations

% Monte Carlo
if clmodel == 1
    for i = 1:mcn
        t2 = diff(data);
        tn3 = randperm(length(t2));
        tn4= [0;cumsum(t2(tn3))];
        [~,Ri,~] = circularspec(tn4,pt,p1,p2,plotn);
        RR(i,:) = Ri;
    end
elseif clmodel == 2
    a = rand(length(data),mcn)*max(data);
    for i = 1:mcn    
        [~,Ri,~] = circularspec(a(:,i),pt,p1,p2,plotn);
        RR(i,:) = Ri;
    end
end

% percentile
prt = [50,90,95,99,99.5];
Y = prctile(RR,prt,1);

% real power spectrum
[P,R,t0] = circularspec(data,pt,p1,p2,0);

% confidence levels
cl = zeros(1,Pn);
for j = 1: length(cl)
    percj = [RR(:,j);R(j)];
    cl(j) = length(percj(percj<R(j)))/(1+mcn);
end

% plot
plotn = 1;
if plotn
    figure;
    subplot(2,1,1)
    xlabel('period')
    ylabel('power')
    hold on;
    plot(P,Y(5,:),'c-','LineWidth',1)
    plot(P,Y(4,:),'g-','LineWidth',1)
    plot(P,Y(3,:),'r-','LineWidth',3)
    plot(P,Y(2,:),'b-','LineWidth',1)
    plot(P,Y(1,:),'k-','LineWidth',1)
    plot(P,R,'LineWidth',1,'color',[0.9290, 0.6940, 0.1250])
    hold off
    xlim([p1,p2])
    legend('99.9%','99%','95%','90%','50%','power')
    subplot(2,1,2)
    hold on
    plot(P,ones(1,Pn)*95,'r-','LineWidth',3)
    plot(P,ones(1,Pn)*99,'g-','LineWidth',1)
    plot(P,ones(1,Pn)*99.9,'c-','LineWidth',1)
    plot(P,cl*100,'LineWidth',1,'color',[0.9290, 0.6940, 0.1250])
    hold off
    ylim([90,100])
    xlabel('period')
    ylabel('confidence level (%)')
    xlim([p1,p2])
end