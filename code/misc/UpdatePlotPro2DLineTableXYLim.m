% update plot pro 2d line PlotAdvSetting database table  for limits only

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
       
        % update x limit 1
        PlotAdvSetting.xlim_low(i) = str2double(get(handles.panel_xyaxis_xlim_low_input,'String'));
        
        % update x limit 2
        PlotAdvSetting.xlim_high(i) = str2double(get(handles.panel_xyaxis_xlim_high_input,'String'));
       
        % update y limit 1
        PlotAdvSetting.ylim_low(i) = str2double(get(handles.panel_xyaxis_ylim_low_input,'String'));
        
        % update y limit 2
        PlotAdvSetting.ylim_high(i) = str2double(get(handles.panel_xyaxis_ylim_high_input,'String'));
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
        %%
        checklegend = and(strcmp(PlotAdvSetting.y_axis_file(i,:), currData{1}),PlotAdvSetting.y_axis_col(i)==str2num(currData{2}));
        if checklegend
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
            % update marker face color
            PlotAdvSetting.marker_face_color{i} = get(handles.panel_mspec_markerfacecolor_input,'BackgroundColor');
            % update marker edge color
            PlotAdvSetting.marker_edge_color{i} = get(handles.panel_mspec_markeredgeshow_input,'BackgroundColor');
        end
    end
end