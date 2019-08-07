function [prt_sr] = ecocoplots(prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb)

%% Plot results
%   Modified from ecocoplot, no H0-SL input and output
%   Run within ecoco.m
% figure
% surf(out_depth,prt_sr,out_ecoco)
% colormap(jet)
% shading interp
% ylabel('Depth (m)')
% xlabel('Sedimentation Rate (cm/kyr)')
% zlabel('Evolutionary correlation coefficient')
% figurename =['Window = ',num2str(window),'. Adjust ETP = ',num2str(adjust),'. Red = ',num2str(red)];
% title(figurename)
%%
figure
subplot(1,3,1)
%out_ecc(out_ecc<0.3) = NaN;
[C,h]=contour(prt_sr,out_depth,out_ecc');
h.Fill = 'on';
h.TextList = [.3 .5 .7 .9];
h.ShowText = 'On';
colorbar('southoutside')
h.ShowText = 'On';
colormap(jet)
shading interp
ylabel('Depth (m)')
xlabel('Sedimentation rate (cm/kyr)')
figurename ='eCOCO';
title(figurename)
set(gca,'Ydir','reverse')

subplot(1,3,2)
% cl = (1-out_ep);
% cl(cl<.99) = NaN;
cl = -1*log10(out_ep);
[C,h]=contour(prt_sr,out_depth,100*cl');
h.Fill = 'on';
% h.TextList = [.999 1];
% h.ShowText = 'On';
colormap(jet)
shading interp
colorbar('southoutside')
xlabel('Sedimentation rate (cm/kyr)')
figurename =['H_0 significance level (%)'];
title(figurename)
set(gca,'Ydir','reverse')

subplot(1,3,3)
[C,h]=contour(prt_sr,out_depth,out_ecocorb');
h.Fill = 'on';
colormap(jet)
shading interp
colorbar('southoutside')
%ylabel('Depth (m)')
xlabel('Sedimentation rate (cm/kyr)')
figurename ='\rho * # orbital parameters';
title(figurename)
set(gca,'Ydir','reverse')
