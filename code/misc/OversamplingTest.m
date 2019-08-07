function [sr_sh_5] = OversamplingTest(data,sr1,sr2,raten,nsim)
%
% Test sensitivity of data to interpolation sampling rate
%   sampling rates range from sr1 to sr2, number of tested sampling rates is raten
%   number of simulations: nsim
%
% EXAMPLE:
% [sr_sh_5] = OversamplingTest(data,0.1,0.6,100,1000)
%   tested 100 sampling rates ranging from 0.1 to 0.6
%   1000 simulations, with an output of shreshold

p = [2.5, 16, 50, 84, 97.5];  % percentiles
rate = linspace(sr1, sr2,raten); % tested sampling rates
rho = zeros(nsim,raten);  % save rho
%rhoc = zeros(nsim,raten);  % save rhoc
% Waitbar
hwaitbar = waitbar(0,'Monte Carlo. Heavy loads, processing ...',...    
   'WindowStyle','modal');
hwaitbar_find = findobj(hwaitbar,'Type','Patch');
set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
setappdata(hwaitbar,'canceling',0)
steps = 100;
% step estimation for waitbar
nmc_n = round(nsim/steps);
waitbarstep = 1;
waitbar(waitbarstep / steps)
    
for j = 1:nsim
    for i = 1:raten
        target1 = interpolate_rand(data,rate(i));
        ty = target1(:,2);
        rho(j,i) = rhoAR1ML(ty);
%        rhoc(j,i)= (rho(j,i)*(length(ty)-1) + 1)/(length(ty)-4); %
    end
    
    if rem(j,nmc_n) == 0
        waitbarstep = waitbarstep+1; 
        if waitbarstep > steps; waitbarstep = steps; end
        pause(0.001);%
        waitbar(waitbarstep / steps)
    end
    %disp(num2str(j))
end

if ishandle(hwaitbar); 
    close(hwaitbar);
end

rho_p = prctile(rho,p,1);
%rhoc_p = prctile(rhoc,p,1);

kk = 1;
rho_error = 100*(rho_p(4,:)-rho_p(2,:))./rho_p(3,:)/2;
% 3 pts smooth
mvn = 3;
B = 1/mvn*ones(mvn,1);
rho_error = filter(B,1,rho_error);

% find the first sampling rate, at which rho_error reaches 1%
for i = 1:raten
    if isnan(rho_error(i)) || rho_error(i) < 1
        kk = i+1;
    else
        break
    end
end
try
    sr_sh_5 = (rate(kk-1)+rate(kk))/2;
catch
    sr_sh_5 = sr1;
end
% 

% find the first sampling rate, at which rho_error reaches 1%
for i = 1:raten
    if isnan(rho_error(i)) || rho_error(i) < .5
        kk = i+1;
    else
        break
    end
end
try
    sr_sh_05 = (rate(kk-1)+rate(kk))/2;
catch
    sr_sh_05 = sr1;
end

figure;

set(gcf,'Color', 'white')
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
set(gcf,'position',[0.1,0.5,0.7,0.45]) % set position

subplot(1,2,1)
plot(rate,rho_p(1,:),'g--')
hold on;
plot(rate,rho_p(5,:),'g--')
plot(rate,rho_p(2,:),'b-')
plot(rate,rho_p(4,:),'b-')
plot(rate,rho_p(3,:),'r','LineWidth',2)
line([sr_sh_5 sr_sh_5],get(gca,'ylim'));
line([sr_sh_05 sr_sh_05],get(gca,'ylim'));
hold off
title(['Sampling rate vs. \rho: nsim = ',num2str(nsim)])
xlabel('Sampling rate')
ylabel('Autocorrelation coefficient (\rho)')

subplot(1,2,2)
hold on
plot(rate,rho_error/100,'k','LineWidth',2)
ylim([0 .04])
line([sr_sh_5 sr_sh_5],get(gca,'ylim'));
refline([0 .01])
%
line([sr_sh_05 sr_sh_05],get(gca,'ylim'));
refline([0 .005])
title(['(16-84% \rho) / 2',' => Threshold sampling rate: ',num2str(sr_sh_5),'(1%), ',num2str(sr_sh_05),'(0.5%)'])
xlabel('Sampling rate')
ylabel('Autocorrelation coefficient (\rho)')