function [sr_sh_5] = OversamplingTest(data,sr1,sr2,raten,nsim)
%
% Test sensitivity of data to interpolation sampling rate
%   sampling rates range from sr1 to sr2, number of tested sampling rates is raten
%   number of simulations: nsim
%
%  Rodionov, 2006, GRL, Use of prewhitening in climate regime shift detection
%
% rhoc = ((m - 1) * rho + 1) / (m - 4)
%
% EXAMPLE:
% [sr_sh_5] = OversamplingTest(data,0.1,0.6,100,1000)
%   tested 100 sampling rates ranging from 0.1 to 0.6
%   1000 simulations, with an output of shreshold


p = [2.5, 16, 50, 84, 97.5];  % percentiles
rate = linspace(sr1, sr2,raten); % tested sampling rates
rho = zeros(nsim,raten);  % save rho
%rhoc = zeros(nsim,raten);  % save rhoc

for j = 1:nsim
    for i = 1:raten
        target1 = interpolate_rand(data,rate(i));
        ty = target1(:,2);
        rho(j,i) = rhoAR1ML(ty);
%        rhoc(j,i)= (rho(j,i)*(length(ty)-1) + 1)/(length(ty)-4); %
    end
    disp(num2str(j))
end
rho_p = prctile(rho,p,1);
%rhoc_p = prctile(rhoc,p,1);

kk = 1;
rho_error = 100*(rho_p(4,:)-rho_p(2,:))./rho_p(3,:)/2;

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
% kk = 1;
% rho_error1 = 100*(rhoc_p(4,:)-rhoc_p(2,:))./rhoc_p(3,:)/2;
% for i = 1:raten
%     if isnan(rho_error1(i)) || rho_error1(i) < 1
%         kk = i+1;
%     else
%         break
%     end
% end
% sr_sh_4 = rate(kk-1);
% 
% figure;
% plot(rate,rhoc_p(1,:),'g--')
% hold on;
% plot(rate,rhoc_p(5,:),'g--')
% plot(rate,rhoc_p(2,:),'b-')
% plot(rate,rhoc_p(4,:),'b-')
% plot(rate,rhoc_p(3,:),'r','LineWidth',2)
% line([sr_sh_4 sr_sh_4],get(gca,'ylim'));
% hold off
% title(['Sampling rate vs. \rho: nsim = ',num2str(nsim)])
% xlabel('Sampling rate')
% ylabel('Autocorrelation coefficient corrected (\rho)')

figure;
subplot(1,2,1)
plot(rate,rho_p(1,:),'g--')
hold on;
plot(rate,rho_p(5,:),'g--')
plot(rate,rho_p(2,:),'b-')
plot(rate,rho_p(4,:),'b-')
plot(rate,rho_p(3,:),'r','LineWidth',2)
line([sr_sh_5 sr_sh_5],get(gca,'ylim'));
hold off
title(['Sampling rate vs. \rho: nsim = ',num2str(nsim)])
xlabel('Sampling rate')
ylabel('Autocorrelation coefficient (\rho)')

subplot(1,2,2)
hold on
plot(rate,rho_error/100,'k','LineWidth',2)
%plot(rate,rho_error1/100,'g')
%plot(rate,(rho_p(4,:)-rho_p(2,:))/2,'k','LineWidth',2);
%legend('\rho (%)','\rho 68%')
ylim([0 .04])
%refline([0 .05])
line([sr_sh_5 sr_sh_5],get(gca,'ylim'));
refline([0 .01])
title(['(16-84% \rho) / 2',' => Threshold sampling rate: ',num2str(sr_sh_5)])
xlabel('Sampling rate')
ylabel('Autocorrelation coefficient (\rho)')