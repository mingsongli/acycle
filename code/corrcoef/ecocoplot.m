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
%% For acycle language version (2.6 and after)
% language
% lang_choice = 0;  %
% handles.main_unit_selection = 0;
lang_choice = load('ac_lang.txt');
langdict = readtable('langdict.xlsx');
lang_id = langdict.ID;
lang_var = table2cell(langdict(:, 2 + lang_choice));
handles.main_unit_selection = evalin('base','main_unit_selection');
[~, main23] = ismember('main23',lang_id);

[~, ec80] = ismember('ec80',lang_id);
[~, ec81] = ismember('ec81',lang_id);
[~, ec82] = ismember('ec82',lang_id);
[~, ec83] = ismember('ec83',lang_id);
[~, ec84] = ismember('ec84',lang_id);
[~, ec85] = ismember('ec85',lang_id);
[~, ec86] = ismember('ec86',lang_id);
%% figure 1 - eCOCO
figure_eCOCO = figure;
set(gcf,'color','w');
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

hcolorbar = colorbar('southoutside');

colormap('parula')
shading interp
if or(lang_choice == 0, handles.main_unit_selection == 0)
    ylabel('Depth (m)')
    xlabel('Sedimentation rate (cm/kyr)')
    %zlabel('Correlation coefficient (\rho)')
    hcolorbar.Label.String = 'Correlation coefficient (\rho)';
else
    ylabel([lang_var{main23},' (m)'])
    xlabel(lang_var{ec80})
    %zlabel([lang_var{ec81},' (\rho)'])
    hcolorbar.Label.String = [lang_var{ec81},' (\rho)'];
end
figurename ='eCOCO';

title(figurename)

if plotn < 0
    set(gca,'Ydir','reverse')
end
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');

%% figure 2 - eH0
if abs(plotn) == 1
    subplot(1,3,2)
end
if abs(plotn) == 2
    figure;
    set(gcf,'color','w');
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
    set(gcf,'color','w');
    surf(prt_sr,out_depth,z_h0/z_h0_max)
    view([10,80])
end
%contourcbar
hcolorbar = colorbar('southoutside',...
    'Ticks',(PlotPower.^(100-([20,10,5,4,3,2,1,.5,.1])))/z_h0_max,...
    'TickLabels',{'20','10','5','4','3','2','1','.5','.1'});
colormap('parula')
shading interp

if or(lang_choice == 0, handles.main_unit_selection == 0)
    xlabel('Sedimentation rate (cm/kyr)')
    %zlabel('H_0 significance level (%)')
    hcolorbar.Label.String = 'H_0 significance level (%)';
    figurename ='eH_0 SL (%)';
else
    xlabel(lang_var{ec80})
    %zlabel([lang_var{ec82},' (%)'])
    figurename =lang_var{ec86};
    hcolorbar.Label.String = [lang_var{ec82},' (%)'];
end

title(figurename)
if plotn < 0
    set(gca,'Ydir','reverse')
end
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');
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
    set(gcf,'color','w');
    surf(prt_sr,out_depth,out_norbit')
    view([10,80])
end
colormap('parula')
shading interp
hcolorbar = colorbar('southoutside');
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');  

if or(lang_choice == 0, handles.main_unit_selection == 0)
    xlabel('Sedimentation rate (cm/kyr)')
    %zlabel('#')
    figurename ='No. of orbital parameters';
    hcolorbar.Label.String = '#';
else
    xlabel(lang_var{ec80})
    %zlabel('#')
    figurename =lang_var{ec84};
    hcolorbar.Label.String = '#';
end

title(figurename)
if plotn < 0
    set(gca,'Ydir','reverse')
end

%% ecocob
if abs(plotn) == 1
    figure_ecocob = figure;
    set(gcf,'color','w');
end
if abs(plotn) == 2
    figure_ecocob = figure;
    set(gcf,'color','w');
end
if or((abs(plotn) == 1), (abs(plotn) == 2))
    %[C,h]=contour(prt_sr,out_depth,out_ecocorb');
    [C,h]=contour(prt_sr,out_depth,out_ecoco');
    h.Fill = 'on';
else
    figure;
    set(gcf,'color','w');
    %surf(prt_sr,out_depth,out_ecocorb')
    surf(prt_sr,out_depth,out_ecoco')
    view([10,80])
end

colormap('parula')
shading interp
hcolorbar = colorbar('southoutside');

set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');    

if or(lang_choice == 0, handles.main_unit_selection == 0)
    xlabel('Sedimentation rate (cm/kyr)')
    ylabel('Depth (m)')
    %zlabel('CHO')
    hcolorbar.Label.String = 'CHO';
    figurename ='COCO * H_0 SL';
else
    xlabel(lang_var{ec80})
    ylabel([lang_var{main23},' (m)'])
    %zlabel('CHO')
    figurename =[lang_var{ec81},' * ',lang_var{ec82}];
    hcolorbar.Label.String = 'CHO';
end

%figurename ='\rho * H_0 SL * # orbital parameters';

title(figurename)
if plotn < 0
    set(gca,'Ydir','reverse')
end