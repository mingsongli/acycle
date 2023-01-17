% wavelet update panel B: wavelet spectrum
%
% Designed for Acycle: wavelet analysis
%
% By Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   acycle.org
%   Nov 11, 2021

if plot_linelog
    if plot_2d == 1
        if plot_log2pow
            if method_sel == 1
                if plot_z
                    contourf(datax,period,log(power)/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    pcolor(datax,period,log(power)/log(plot_base))
                end
            elseif method_sel == 2
                if plot_z
                    H=contourf(datax,period,log(abs(power/sigma2))/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);
                else
                    % Continous Wavelet Transform
                    H=pcolor(datax,period,log(abs(power/sigma2))/log(plot_base));
                end
            elseif method_sel == 3
                if plot_z
                    contourf(datax,period,log(power)/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    pcolor(datax,period,log(power)/log(plot_base))
                end
            end
        else
            if method_sel == 1
                if plot_z
                    contourf(datax,period,power,levels,':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    pcolor(datax,period,power)
                end
            elseif method_sel == 2
                if plot_z
                    H=contourf(datax,period,abs(power/sigma2),levels,':','LineWidth',0.0001);
                else
                    % Continous Wavelet Transform
                    H=pcolor(datax,period,abs(power/sigma2));
                end
            elseif method_sel == 3
                if plot_z
                    contourf(datax,period,power,levels,':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    pcolor(datax,period,power)
                end
            end
        end
    elseif plot_2d == 0
        if plot_log2pow
            if method_sel == 1
                if plot_z
                    contourf(datax,period,log(power)/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    surf(datax,period,log(power)/log(plot_base))
                end
            elseif method_sel == 2
                if plot_z
                    H=contourf(datax,period,log(abs(power/sigma2))/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);
                else
                    % Continous Wavelet Transform
                    H=surf(datax,period,log(abs(power/sigma2))/log(plot_base));
                end
            elseif method_sel == 3
                if plot_z
                    contourf(datax,period,log(power)/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    surf(datax,period,log(power)/log(plot_base))
                end
            end
        else
            if method_sel == 1
                if plot_z
                    contourf(datax,period,power,levels,':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    surf(datax,period,power)
                end
            elseif method_sel == 2
                if plot_z
                    H=contourf(datax,period,abs(power/sigma2),levels,':','LineWidth',0.0001);
                else
                    % Continous Wavelet Transform
                    H=surf(datax,period,abs(power/sigma2));
                end
            elseif method_sel == 3
                if plot_z
                    contourf(datax,period,power,levels,':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    surf(datax,period,power)
                end
            end
        end
    end
    
else
    
    if plot_2d == 1
        if plot_log2pow
            % most useful
            if method_sel == 1
                if plot_z
                    contourf(datax,log2(period),log(power)/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    pcolor(datax,log2(period),log(power)/log(plot_base))
                end
            elseif method_sel == 2
                if plot_z
                    H=contourf(datax,log2(period),log(abs(power/sigma2))/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);
                else
                    % Continous Wavelet Transform
                    H=pcolor(datax,log2(period),log(abs(power/sigma2))/log(plot_base));
                end
            elseif method_sel == 3
                %contourf(datax,log2(period),log2(power),log2(levels),':','LineWidth',0.0001);  %*** or use 'contourfill'
                if plot_z
                    contourf(datax,log2(period),log(power)/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    pcolor(datax,log2(period),log(power)/log(plot_base))
                end
            end
        else
            if method_sel == 1
                if plot_z
                    contourf(datax,log2(period),power,levels,':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    pcolor(datax,log2(period),power)
                end
            elseif method_sel == 2
                if plot_z
                    H=contourf(datax,log2(period),abs(power/sigma2),levels,':','LineWidth',0.0001);
                else
                    % Continous Wavelet Transform
                    H=pcolor(datax,log2(period),abs(power/sigma2));
                end
            elseif method_sel == 3
                if plot_z
                    contourf(datax,log2(period),power,levels,':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    pcolor(datax,log2(period),power)
                end
            end
        end
    elseif plot_2d == 0
        if plot_log2pow
            if method_sel == 1
                if plot_z
                    contourf(datax,log2(period),log(power)/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    surf(datax,log2(period),log(power)/log(plot_base))
                end
            elseif method_sel == 2
                if plot_z
                    H=contourf(datax,log2(period),log(abs(power/sigma2))/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);
                else
                    % Continous Wavelet Transform
                    H=surf(datax,log2(period),log(abs(power/sigma2))/log(plot_base));
                end
            elseif method_sel == 3
                if plot_z
                    contourf(datax,log2(period),log(power)/log(plot_base),log(levels)/log(plot_base),':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    surf(datax,log2(period),log(power)/log(plot_base))
                end
            end
        else
            if method_sel == 1
                if plot_z
                    contourf(datax,log2(period),power,levels,':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    surf(datax,log2(period),power)
                end
            elseif method_sel == 2
                if plot_z
                    H=contourf(datax,log2(period),abs(power/sigma2),levels,':','LineWidth',0.0001);
                else
                    % Continous Wavelet Transform
                    H=surf(datax,log2(period),abs(power/sigma2));
                end
            elseif method_sel == 3
                if plot_z
                    contourf(datax,log2(period),power,levels,':','LineWidth',0.0001);  %*** or use 'contourfill'
                else
                    surf(datax,log2(period),power)
                end
            end
        end
    end
    
end

shading interp
% if method_sel == 1
%     clim=get(gca,'clim'); %center color limits around log2(1)=0
%     clim=[-1 1]*max(clim(2),3);
%     set(gca,'clim',clim)
% end
    
if isempty(plot_colorgrid)
    try
        colormap(plot_colormap)
    catch
        colormap(parula)
    end
else
    try
        colormap([plot_colormap,'(',num2str(plot_colorgrid),')'])
    catch
        try colormap(['parula(',num2str(plot_colorgrid),')'])
        catch
            colormap(parula)
        end
    end
end
%imagesc(time,log2(period),log2(power));  %*** uncomment for 'image' plot

% lang
lang_var = handles.lang_var;

if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
    if handles.unit_type == 0
        xlabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1
        xlabel(['Depth (',handles.unit,')'])
    else
        xlabel(['Time (',handles.unit,')'])
    end
    ylabel(['Period (',handles.unit,')'])
else
    [~, main34] = ismember('main34',handles.lang_id); % Unit
    [~, main23] = ismember('main23',handles.lang_id); % Depth
    [~, main21] = ismember('main21',handles.lang_id); % Time
    [~, main15] = ismember('main15',handles.lang_id); % Period

    if handles.unit_type == 0
        xlabel([lang_var{main34},' (',handles.unit,')'])
    elseif handles.unit_type == 1
        xlabel([lang_var{main23},' (',handles.unit,')'])
    else
        xlabel([lang_var{main21},' (',handles.unit,')'])
    end
    ylabel([lang_var{main15},' (',handles.unit,')'])
end

%title('B) Wavelet Power Spectrum')
set(gca,'XLim',xlim(:))

% 95% significance contour, levels at -99 (fake) and 1 (95% signif)
hold on
if plot_sl
    if plot_linelog
        if plot_2d == 1
            if method_sel == 1
                contour(datax,period,sig95,[-99,1],'k','LineWidth',1);
            elseif method_sel == 3
                contour(datax,period,sig95,[-99,1],'k','LineWidth',1);
            end
        elseif plot_2d == 0
            if method_sel == 1
                contour3(datax,period,sig95,[-99,1],'k','LineWidth',1);
            elseif method_sel == 3
                contour3(datax,period,sig95,[-99,1],'k','LineWidth',1);
            end
        end
    else
        if plot_2d == 1
            % most useful
            if method_sel == 1
                contour(datax,log2(period),sig95,[-99,1],'k','LineWidth',1);
            elseif method_sel == 2
                contour(datax,log2(period),sig95,[1 1],'k','LineWidth',1); %#ok
            elseif method_sel == 3
                contour(datax,log2(period),sig95,[-99,1],'k','LineWidth',1);
            end
        elseif plot_2d == 0
            if method_sel == 1
                contour3(datax,log2(period),sig95,[-99,1],'k','LineWidth',1);
            elseif method_sel == 2
                contour3(datax,log2(period),sig95,[1 1],'k','LineWidth',1); %#ok
            elseif method_sel == 3
                contour3(datax,log2(period),sig95,[-99,1],'k','LineWidth',1);
            end
        end
    end
end
if plot_coi
    
    % cone-of-influence, anything "below" is dubious
    tt=[datax([1 1])-dt*.5;datax;datax([end end])+dt*.5];
    
    if plot_linelog  % linear y axis
        if plot_2d == 1
            %plot(datax,coi,'w','LineWidth',2)
            hcoi=fill(tt,[period([end 1]) coi period([1 end])],'w');
            set(hcoi,'alphadatamapping','direct','facealpha',.4)
        elseif plot_2d == 0
            if plot_log2pow
                plot3(datax,coi,max(log2(power)),'w','LineWidth',2)
            else
                plot3(datax,coi,max(power),'w','LineWidth',2)
            end
        end
    else   % log y axis
        if plot_2d == 1
            %plot(datax,log2(coi),'w','LineWidth',2)
            hcoi=fill(tt,log2([period([end 1]) coi period([1 end])]),'w');
            set(hcoi,'alphadatamapping','direct','facealpha',.4)
        elseif plot_2d == 0
            if plot_log2pow
                plot3(datax,log2(coi),max(log2(power)),'w','LineWidth',2)
            else
                plot3(datax,log2(coi),max(power),'w','LineWidth',2)
            end
        end
    end
    
end

hold off
set(gca,'box','on','layer','top');
if plot_flipx
    set(gca,'Xdir','reverse')
else
    set(gca,'Xdir','normal')
end

if plot_linelog
    set(gca,'YLim',[pt1,pt2])
else
    set(gca,'YLim',log2([pt1,pt2]), ...
        'YDir','normal', ...
        'YTick',log2(Yticks(:)), ...
        'YTickLabel',Yticks)
end

if plot_flipy
   set(gca,'Ydir','reverse')
else
   set(gca,'Ydir','normal')
end

set(gca,'XMinorTick','on')
set(gca,'TickDir','out');