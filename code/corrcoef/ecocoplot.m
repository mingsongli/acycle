function [prt_sr] = ecocoplot(prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,plotn)
% Plot evolutonary correlation coefficient results
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
if nargin > 9 
    error('Too many input arguments')
end
if nargin < 9
    plotn = 1;
    if nargin < 8
        error('Too few input arguments')
    end
end

%% figure 1 - eCOCO
figure
if abs(plotn) == 1
    subplot(1,3,1)
end
if or((abs(plotn) == 1), (abs(plotn) == 2))
    zlevs = min(min(out_ecc)):.05:max(max(out_ecc));
    [C,h]=contour(prt_sr,out_depth,out_ecc',zlevs);
    h.Fill = 'on';
else
    surf(prt_sr,out_depth,out_ecc')
    view([10,80])
end
colorbar('southoutside')
colormap(jet)
shading interp
ylabel('Depth (m)')
xlabel('Sedimentation rate (cm/kyr)')
zlabel('Correlation coefficient (\rho)')
figurename ='eCOCO';
title(figurename)
if plotn < 0
    set(gca,'Ydir','reverse')
end

%% figure 2 - eH0
if abs(plotn) == 1
    subplot(1,3,2)
end
if abs(plotn) == 2
    figure;
end

PlotPower = 1.12;
out_eci(out_eci>.5) = .5;
z_h0 = PlotPower.^(100*(1-(out_eci')));
z_h0_max = max(max(z_h0));

if or((abs(plotn) == 1), (abs(plotn) == 2))
    
    zlevs = PlotPower.^(50:.2:max(max(100*(1-out_eci'))));
    %[C,h]=contour(prt_sr,out_depth,PlotPower.^(100*(1-(out_eci'))),zlevs);
    [C,h]=contour(prt_sr,out_depth,z_h0/z_h0_max,zlevs/z_h0_max);
    h.ShowText = 'Off';
    h.Fill = 'on';
    h.LevelListMode = 'manual';
else
    figure;
    surf(prt_sr,out_depth,z_h0/z_h0_max)
    view([10,80])
end
%contourcbar
colorbar('southoutside',...
    'Ticks',(PlotPower.^(100-([20,10,5,4,3,2,1,.5,.1])))/z_h0_max,...
    'TickLabels',{'20','10','5','4','3','2','1','.5','.1'})
colormap(jet)
shading interp
xlabel('Sedimentation rate (cm/kyr)')
%ylabel('Depth (m)')
zlabel('H_0 significance level (%)')
figurename ='eH_0 SL (%)';
title(figurename)
if plotn < 0
    set(gca,'Ydir','reverse')
end
%% figure 3 - eNumberOfOrbits
if abs(plotn) == 1
    subplot(1,3,3)
end
if abs(plotn) == 2
    figure;
end
if or((abs(plotn) == 1), (abs(plotn) == 2))
    zlevs = 0:1:7;
    [C,h]=contour(prt_sr,out_depth,out_norbit',zlevs);
    h.Fill = 'on';
else
    figure;
    surf(prt_sr,out_depth,out_norbit')
    view([10,80])
end
colormap(jet)
shading interp
colorbar('southoutside')
xlabel('Sedimentation rate (cm/kyr)')
%ylabel('Depth (m)')
zlabel('#')
figurename ='No. of orbital parameters';
title(figurename)
if plotn < 0
    set(gca,'Ydir','reverse')
end

%% ecocob
if abs(plotn) == 1
    figure;
end
if abs(plotn) == 2
    figure;
end
if or((abs(plotn) == 1), (abs(plotn) == 2))
    %[C,h]=contour(prt_sr,out_depth,out_ecocorb');
    [C,h]=contour(prt_sr,out_depth,out_ecoco');
    h.Fill = 'on';
else
    figure;
    %surf(prt_sr,out_depth,out_ecocorb')
    surf(prt_sr,out_depth,out_ecoco')
    view([10,80])
end
colormap(jet)
shading interp
colorbar('southoutside')
xlabel('Sedimentation rate (cm/kyr)')
ylabel('Depth (m)')
zlabel('CHO')
%figurename ='\rho * H_0 SL * # orbital parameters';
figurename ='\rho * H_0 SL';
title(figurename)
if plotn < 0
    set(gca,'Ydir','reverse')
end