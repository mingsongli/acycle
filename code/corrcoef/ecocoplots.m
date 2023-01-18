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
colormap('parula')
shading interp
if or(lang_choice == 0, handles.main_unit_selection == 0)
    ylabel('Depth (m)')
    xlabel('Sedimentation rate (cm/kyr)')
else
    ylabel([lang_var{main23},' (m)'])
    xlabel(lang_var{ec80})
end

figurename ='eCOCO';
title(figurename)
set(gca,'Ydir','reverse')
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');

subplot(1,3,2)
cl = -1*log10(out_ep);
[C,h]=contour(prt_sr,out_depth,100*cl');
h.Fill = 'on';
colormap('parula')
shading interp
colorbar('southoutside')

set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');

if or(lang_choice == 0, handles.main_unit_selection == 0)
    xlabel('Sedimentation rate (cm/kyr)')
    figurename =['H_0 significance level (%)'];
    zlabel('H_0 significance level (%)')
    figurename ='eH_0 SL (%)';
else
    xlabel(lang_var{ec80})
    figurename =[lang_var{ec82},' (%)'];
end

title(figurename)
set(gca,'Ydir','reverse')

subplot(1,3,3)
[C,h]=contour(prt_sr,out_depth,out_ecocorb');
h.Fill = 'on';
colormap('parula')
shading interp
colorbar('southoutside')

if or(lang_choice == 0, handles.main_unit_selection == 0)
    xlabel('Sedimentation rate (cm/kyr)')
    figurename ='\rho * # orbital parameters';
else
    xlabel(lang_var{ec80})
    figurename =['\rho * ',lang_var{ec84}];
end

title(figurename)
set(gca,'Ydir','reverse')
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'TickDir','out');
