% update plot pro 2d line PlotAdvSetting database table

figure(handles.h_PlotPro2DLineGUI); 

% read current panel
panel_i = get(handles.panel_datapanel_set_input,'Value');  % get panel id
% read current data
str = get(handles.panel_datapanel_y_i_input,'String');  % get current data list
val = get(handles.panel_datapanel_y_i_input,'Value');  % get current data list
currData = str(val,:);
currData = split(currData,' ');
% how many rows?
[datan, ~] = size(PlotAdvSetting);  % read rows of the setting excel file

for i = 1: datan
    
    % update fontname
    str = get(handles.panel_font_fontname_input,'String');
    val = get(handles.panel_font_fontname_input,'Value');
    PlotAdvSetting.fontname(i,:)=str(val);
    
    % update font size
    PlotAdvSetting.fontsize(i) = str2num(get(handles.panel_font_fontsize_input,'String'));
    
    % identify the panel
    if PlotAdvSetting.panel_i(i) == panel_i
        %% Title/lgend/font
        % update title
        PlotAdvSetting.title(i,:) = string(get(handles.panel_font_title_input,'String'));
        % update legend
        PlotAdvSetting.legend(i)  = get(handles.panel_font_legend_input,'Value');
        % update legend content & legend box
        if get(handles.panel_font_legend_input,'Value')>0
            set(handles.panel_font_legend_text,'Enable','on')
            set(handles.panel_font_legendbox_input,'Enable','on')
            if and(strcmp(PlotAdvSetting.y_axis_file(i,:), currData{1}),PlotAdvSetting.y_axis_col(i)==str2num(currData{2}))
                PlotAdvSetting.legend_text(i,:) = get(handles.panel_font_legend_text,'String');
            end
            PlotAdvSetting.legend_box(i) = get(handles.panel_font_legendbox_input,'Value');
        else % legend off
            set(handles.panel_font_legend_text,'Enable','off')
            set(handles.panel_font_legendbox_input,'Enable','off')
        end
        
        % update font weight
        if get(handles.panel_font_fontwt_input1,'Value') %normal
            PlotAdvSetting.fontweight(i) = 0;
        else % bold
            PlotAdvSetting.fontweight(i) = 1;
        end
        % update font angle
        if get(handles.panel_font_fontangle_input1,'Value') %normal
            PlotAdvSetting.fontangle(i) = 0;
        else % italic
            PlotAdvSetting.fontangle(i) = 1;
        end
        %% X&Y label/axis/limit/scale
        % updata xlabel
        PlotAdvSetting.xlabel{i} = string(get(handles.panel_xyaxis_xlabel_input,'String'));
        % update ylabel
        PlotAdvSetting.ylabel{i} = string(get(handles.panel_xyaxis_ylabel_input,'String'));
        % x column
        if PlotAdvSetting.x_axis_col(i) > 0
            PlotAdvSetting.xlim_low(i) = min(x);
            PlotAdvSetting.xlim_high(i) = max(x);
        else
            x = 1 : length(y);
            PlotAdvSetting.xlim_low(i) = 1;
            PlotAdvSetting.xlim_high(i) = length(x);
        end
        % find real x limit min
        j = 0;
        for m = 1: datan
            if PlotAdvSetting.panel_i(m) == panel_i
                j = j+1;
                k(j) = PlotAdvSetting.xlim_low(m);
            end
        end
        % update x limit 1
        PlotAdvSetting.xlim_low(i) = min(PlotAdvSetting.xlim_low(i), min(str2double(get(handles.panel_xyaxis_xlim_low_input,'String')), min(k)));
        
        %% update limit for x and y
        % find real x limit max
        j = 0;
        for m = 1: datan
            if PlotAdvSetting.panel_i(m) == panel_i
                j = j+1;
                k(j) = PlotAdvSetting.xlim_high(m);
            end
        end
        % update x limit 2
        PlotAdvSetting.xlim_high(i) = max(PlotAdvSetting.xlim_low(i), max(str2double(get(handles.panel_xyaxis_xlim_high_input,'String')), max(k)));
        %PlotAdvSetting.xlim_high(i) = max(str2double(get(handles.panel_xyaxis_xlim_high_input,'String')),max(k));
        % find real y limit min
        j = 0;
        for m = 1: datan
            if PlotAdvSetting.panel_i(m) == panel_i
                j = j+1;
                k(j) = PlotAdvSetting.ylim_low(m);
            end
        end
        
        % update y limit 1
        PlotAdvSetting.ylim_low(i) = min(str2double(get(handles.panel_xyaxis_ylim_low_input,'String')), min(k));
        % find real y limit max
        j = 0;
        for m = 1: datan
            if PlotAdvSetting.panel_i(m) == panel_i
                j = j+1;
                k(j) = PlotAdvSetting.ylim_high(m);
            end
        end
        % update y limit 2
        PlotAdvSetting.ylim_high(i) = max(str2double(get(handles.panel_xyaxis_ylim_high_input,'String')),max(k));
        %%
        % x tick label
        % y tick label
        % update x minor tick
        if get(handles.panel_xyaxis_xminortick_input1,'Value') %on
            PlotAdvSetting.xminortick(i) = 1;
        else % off
            PlotAdvSetting.xminortick(i) = 0;
        end
        % update y minor tick
        if get(handles.panel_xyaxis_yminortick_input1,'Value') %on
            PlotAdvSetting.yminortick(i) = 1;
        else % off
            PlotAdvSetting.yminortick(i) = 0;
        end
        % grid
        if get(handles.panel_xyaxis_grid1,'Value') %on
            PlotAdvSetting.grid(i) = 1;
        else % off
            PlotAdvSetting.grid(i) = 0;
        end
        % update x direction
        if get(handles.panel_xyaxis_xdir_input1,'Value') %normal
            PlotAdvSetting.xdir(i) = 1;
        else % reverse
            PlotAdvSetting.xdir(i) = 0;
        end
        % update y direction
        if get(handles.panel_xyaxis_ydir_input1,'Value') %normal
            PlotAdvSetting.ydir(i) = 1;
        else % reverse
            PlotAdvSetting.ydir(i) = 0;
        end
        % update x scale
        if get(handles.panel_xyaxis_xscale_input1,'Value') %linear
            PlotAdvSetting.xscale(i) = 1;
        else % log
            PlotAdvSetting.xscale(i) = 0;
        end
        % update y scale
        if get(handles.panel_xyaxis_yscale_input1,'Value') %linear
            PlotAdvSetting.yscale(i) = 1;
        else % log
            PlotAdvSetting.yscale(i) = 0;
        end
        % update swap xy
        if get(handles.panel_xyaxis_swap1,'Value') %linear
            PlotAdvSetting.swap_xy(i) = 0;
        else % log
            PlotAdvSetting.swap_xy(i) = 1;
        end
        if get(handles.panel_xyaxis_swap2,'Value') %linear
            PlotAdvSetting.swap_xy(i) = 1;
        else % log
            PlotAdvSetting.swap_xy(i) = 0;
        end
        %% find the data file and columns
        checklegend = and(strcmp(PlotAdvSetting.y_axis_file(i,:), currData{1}),PlotAdvSetting.y_axis_col(i)==str2num(currData{2}));
        if checklegend
            %% error bar
            if get(handles.panel_datapanel_xneg_chk,'Value') == 1
                PlotAdvSetting.errorxneg(i) = -1;
                % read id, get the length
                k = str2num(get(handles.panel_datapanel_xneg_input, 'string'));
                m = length(k);
                if m > 1
                    k = k(1);
                    warning('Warning: only 1 column is allowed')
                    set(handles.panel_datapanel_xneg_input, 'string',num2str(k))
                elseif m == 0
                    set(handles.panel_datapanel_xneg_chk, 'Value',0)
                end
                int_gt_0 = @(n) (rem(n,1) == 0) & (n >= 0);  % 0 or positive interger
                result = int_gt_0(k);
                if result == 1
                    PlotAdvSetting.errorxneg(i) = k;
                end
            else
                PlotAdvSetting.errorxneg(i) = 0;
            end
            % x pos
            if get(handles.panel_datapanel_xpos_chk,'Value') == 1
                PlotAdvSetting.errorxpos(i) = -1;
                % read id, get the length
                k = str2num(get(handles.panel_datapanel_xpos_input, 'string'));
                m = length(k);
                if m > 1
                    k = k(1);
                    warning('Warning: only 1 column is allowed')
                    set(handles.panel_datapanel_xpos_input, 'string',num2str(k))
                elseif m == 0
                    set(handles.panel_datapanel_xpos_chk, 'Value',0)
                end
                int_gt_0 = @(n) (rem(n,1) == 0) & (n >= 0);  % 0 or positive interger
                result = int_gt_0(k);
                if result == 1
                    PlotAdvSetting.errorxpos(i) = k;
                end
            else
                PlotAdvSetting.errorxpos(i) = 0;
            end
            % y neg
            if get(handles.panel_datapanel_yneg_chk,'Value') == 1
                PlotAdvSetting.erroryneg(i) = -1;
                % read id, get the length
                k = str2num(get(handles.panel_datapanel_yneg_input, 'string'));
                m = length(k);
                if m > 1
                    k = k(1);
                    warning('Warning: only 1 column is allowed')
                    set(handles.panel_datapanel_yneg_input, 'string',num2str(k))
                elseif m == 0
                    set(handles.panel_datapanel_yneg_chk, 'Value',0)
                end
                int_gt_0 = @(n) (rem(n,1) == 0) & (n >= 0);  % 0 or positive interger
                result = int_gt_0(k);
                if result == 1
                    PlotAdvSetting.erroryneg(i) = k;
                end
            else
                PlotAdvSetting.erroryneg(i) = 0;
            end
            % y pos
            if get(handles.panel_datapanel_ypos_chk,'Value') == 1
                PlotAdvSetting.errorypos(i) = -1;
                % read id, get the length
                k = str2num(get(handles.panel_datapanel_ypos_input, 'string'));
                m = length(k);
                if m > 1
                    k = k(1);
                    warning('Warning: only 1 column is allowed')
                    set(handles.panel_datapanel_ypos_input, 'string',num2str(k))
                elseif m == 0
                    set(handles.panel_datapanel_ypos_chk, 'Value',0)
                end
                int_gt_0 = @(n) (rem(n,1) == 0) & (n >= 0);  % 0 or positive interger
                result = int_gt_0(k);
                if result == 1
                    PlotAdvSetting.errorypos(i) = k;
                end
            else
                PlotAdvSetting.errorypos(i) = 0;
            end
            %% cap size
            if strcmp(get(handles.panel_lspec_capsize_input,'Visible'),'on')
                PlotAdvSetting.errorcapsize(i) = str2double(get(handles.panel_lspec_capsize_input,'String'));
                if isnan(PlotAdvSetting.errorcapsize(i))
                    PlotAdvSetting.errorcapsize(i) = 0;
                end
                if PlotAdvSetting.errorcapsize(i)< 0
                    PlotAdvSetting.errorcapsize(i) = 0;
                    set(handles.panel_lspec_capsize_input,'String','0')
                end
            end
            %% Line spec
            % update line plot
            str = get(handles.panel_lspec_lineplot_input,'String');
            val = get(handles.panel_lspec_lineplot_input,'Value');
            PlotAdvSetting.line_plot(i,:) = str(val);
            % update line style
            str = get(handles.panel_lspec_linestyle_input,'String');
            val = get(handles.panel_lspec_linestyle_input,'Value');
            PlotAdvSetting.line_style(i,:) = str(val);
            % update line width
            str = get(handles.panel_lspec_linewidth_input,'String');
            val = get(handles.panel_lspec_linewidth_input,'Value');
            PlotAdvSetting.line_width(i) = str2double(str{val});
            % update line color
            PlotAdvSetting.line_color{i} = mat2str(get(handles.panel_lspec_linecolor_input,'BackgroundColor'));
            % area plot base value
            %get(handles.panel_lspec_basevalu_input,'Visible')
            if strcmp(get(handles.panel_lspec_basevalu_input,'Visible'),'on')
                PlotAdvSetting.area_basevalue(i) = str2double(get(handles.panel_lspec_basevalu_input,'String'));
            end
            
            %% Stairs
            
            % show pad edge input box
            if strcmp(PlotAdvSetting.line_plot(i,:),'stairs')
                % min
                if PlotAdvSetting.x_axis_col(i) > 0
                    data = load(fullfile(handles.plot_no_dir,PlotAdvSetting.x_axis_file(i,:)));
                    x = data(:, PlotAdvSetting.x_axis_col(i));
                else
                    x = 1;
                end
                if PlotAdvSetting.stairsEdge1(i) == 1e36 % empty
                    PlotAdvSetting.stairsEdge1(i) = min(x);
                else
                    if str2double(get(handles.panel_lspec_stairs_input1,'String')) > min(x)
                        warning(' must be <= the min of x')
                        PlotAdvSetting.stairsEdge1(i) = min(x);
                    else
                        PlotAdvSetting.stairsEdge1(i) = min(str2double(get(handles.panel_lspec_stairs_input1,'String')), min(x));
                    end
                end
                set(handles.panel_lspec_stairs_input1,'String',num2str(PlotAdvSetting.stairsEdge1(i)))
                % update x limit min
                if PlotAdvSetting.stairsEdge1(i) == 1e36 % empty
                else
                    for m = 1: datan
                        if PlotAdvSetting.panel_i(m) == panel_i
                            if PlotAdvSetting.stairsEdge1(m) < PlotAdvSetting.xlim_low(m)
                                PlotAdvSetting.xlim_low(m) = PlotAdvSetting.stairsEdge1(m);
                                
                            end
                        end
                    end
                end
                % max
                if PlotAdvSetting.x_axis_col(i) <= 0
                    data = load(fullfile(handles.plot_no_dir,PlotAdvSetting.y_axis_file(i,:)));
                    y = data(:, PlotAdvSetting.y_axis_col(i));
                end
                if PlotAdvSetting.stairsEdge2(i) == 1e36 % empty
                    if PlotAdvSetting.x_axis_col(i) > 0
                        PlotAdvSetting.stairsEdge2(i) = max(x);
                    else
                        PlotAdvSetting.stairsEdge2(i) = length(y);
                    end
                else
                    if str2double(get(handles.panel_lspec_stairs_input2,'String')) < max(x)
                        warning(' must be >= the max of x')
                        PlotAdvSetting.stairsEdge2(i) = max(x);
                    else
                        PlotAdvSetting.stairsEdge2(i) = max(str2double(get(handles.panel_lspec_stairs_input2,'String')), max(x));
                    end
                end
                set(handles.panel_lspec_stairs_input2,'String',num2str(PlotAdvSetting.stairsEdge2(i)))
                % update x limit max
                if PlotAdvSetting.stairsEdge1(i) == 1e36 % empty
                else
                    for m = 1: datan
                        if PlotAdvSetting.panel_i(m) == panel_i
                            if PlotAdvSetting.stairsEdge2(m) > PlotAdvSetting.xlim_high(m)
                                PlotAdvSetting.xlim_high(m) = PlotAdvSetting.stairsEdge2(m);
                            end
                        end
                    end
                end
                
                % stairs direction
                if strcmp(get(handles.panel_lspec_stairsDir,'String'),'direction-->')
                    PlotAdvSetting.stairsDir(i) = 1;
                else
                    PlotAdvSetting.stairsDir(i) = 0;
                end
            end
            %% Marker spec
            % update show marker (face)
            if get(handles.panel_mspec_markershow_input1,'Value') %on
                PlotAdvSetting.marker_face_show(i) = 1;
            else % off
                PlotAdvSetting.marker_face_show(i) = 0;
            end
            % update show marker edge
            if get(handles.panel_mspec_markeredgeshow_input1,'Value') %on
                PlotAdvSetting.marker_edge_show(i) = 1;
            else % off
                PlotAdvSetting.marker_edge_show(i) = 0;
            end
            % update marker style
            str = get(handles.panel_mspec_markerstyle_input,'String');
            val = get(handles.panel_mspec_markerstyle_input,'Value');
            PlotAdvSetting.marker_style(i,:) = str(val);
            % update marker size
            PlotAdvSetting.marker_size(i) = str2double(get(handles.panel_mspec_markersize_input,'String'));
            % update marker alpha
            PlotAdvSetting.marker_alpha(i) = get(handles.panel_mspec_markeralpha_input,'Value');
            % update marker face color
            PlotAdvSetting.marker_face_color{i} = get(handles.panel_mspec_markerfacecolor_input,'BackgroundColor');
            % update marker edge color
            PlotAdvSetting.marker_edge_color{i} = get(handles.panel_mspec_markeredgeshow_input,'BackgroundColor');
        end
    end
end