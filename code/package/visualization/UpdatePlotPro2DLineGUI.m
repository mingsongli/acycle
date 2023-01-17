% update plot pro 2d line GUI

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
% set set data list box
SetDataListn = 0;

for i = 1: datan
    % identify the panel
    if PlotAdvSetting.panel_i(i) == panel_i
        %% Set Data Listbox
        SetDataListn = SetDataListn + 1;
        % prepare the set data list for display
        SetDataList{SetDataListn} = strcat(PlotAdvSetting.y_axis_file(i,:),{' '},num2str(PlotAdvSetting.y_axis_col(i)));
        %% set title/lgend/font
        % set title
        set(handles.panel_font_title_input,'String',PlotAdvSetting.title(i,:))
        % identify the data file name and the column
        % set legend
        set(handles.panel_font_legend_input,'Value',PlotAdvSetting.legend(i))
        % set legend box
        set(handles.panel_font_legendbox_input,'Value',PlotAdvSetting.legend_box(i))
        if PlotAdvSetting.legend(i) > 0 % legend on
            set(handles.panel_font_legend_text,'Enable','on')
            set(handles.panel_font_legendbox_input,'Enable','on')
        else  % legend off
            set(handles.panel_font_legend_text,'Enable','off')
            set(handles.panel_font_legendbox_input,'Enable','off')
        end
        % set Font name
        set(handles.panel_font_fontname_input,'Value',find(strcmp(PlotAdvSetting.fontname(i,:), get(handles.panel_font_fontname_input, 'String'))))
        % set font size
        set(handles.panel_font_fontsize_input,'String',num2str(PlotAdvSetting.fontsize(i)))
        
        %% Set X&Y label/ axis/ limit/ scale

        % set x label
        set(handles.panel_xyaxis_xlabel_input,'String',PlotAdvSetting.xlabel(i,:))
        % set y label
        set(handles.panel_xyaxis_ylabel_input,'String',PlotAdvSetting.ylabel(i,:))
        % set x limit 1
        set(handles.panel_xyaxis_xlim_low_input,'String',num2str(PlotAdvSetting.xlim_low(i)))
        % set x limit 2
        set(handles.panel_xyaxis_xlim_high_input,'String',num2str(PlotAdvSetting.xlim_high(i)))
        % set y limit 1
        set(handles.panel_xyaxis_ylim_low_input,'String',num2str(PlotAdvSetting.ylim_low(i)))
        % set y limit 2
        set(handles.panel_xyaxis_ylim_high_input,'String',num2str(PlotAdvSetting.ylim_high(i)))
        
        % set x minor tick
        if PlotAdvSetting.xminortick(i) > 0 % on
            set(handles.panel_xyaxis_xminortick_input1,'Value',1)
            set(handles.panel_xyaxis_xminortick_input2,'Value',0)
        else % off
            set(handles.panel_xyaxis_xminortick_input1,'Value',0)
            set(handles.panel_xyaxis_xminortick_input2,'Value',1)
        end
        % set y minor tick
        if PlotAdvSetting.xminortick(i) > 0 % on
            set(handles.panel_xyaxis_yminortick_input1,'Value',1)
            set(handles.panel_xyaxis_yminortick_input2,'Value',0)
        else % off
            set(handles.panel_xyaxis_yminortick_input1,'Value',0)
            set(handles.panel_xyaxis_yminortick_input2,'Value',1)
        end
        % set x direction
        if PlotAdvSetting.xdir(i) > 0 % normal
            set(handles.panel_xyaxis_xdir_input1,'Value',1)
            set(handles.panel_xyaxis_xdir_input2,'Value',0)
        else % reverse
            set(handles.panel_xyaxis_xdir_input1,'Value',0)
            set(handles.panel_xyaxis_xdir_input2,'Value',1)
        end
        % set y direction
        if PlotAdvSetting.ydir(i) > 0 % normal
            set(handles.panel_xyaxis_ydir_input1,'Value',1)
            set(handles.panel_xyaxis_ydir_input2,'Value',0)
        else % reverse
            set(handles.panel_xyaxis_ydir_input1,'Value',0)
            set(handles.panel_xyaxis_ydir_input2,'Value',1)
        end
        % set x scale
        if PlotAdvSetting.xscale(i) > 0 % linear
            set(handles.panel_xyaxis_xscale_input1,'Value',1)
            set(handles.panel_xyaxis_xscale_input2,'Value',0)
        else % log
            set(handles.panel_xyaxis_xscale_input1,'Value',0)
            set(handles.panel_xyaxis_xscale_input2,'Value',1)
        end
        % set y scale
        if PlotAdvSetting.yscale(i) > 0 % linear
            set(handles.panel_xyaxis_yscale_input1,'Value',1)
            set(handles.panel_xyaxis_yscale_input2,'Value',0)
        else % log
            set(handles.panel_xyaxis_yscale_input1,'Value',0)
            set(handles.panel_xyaxis_yscale_input2,'Value',1)
        end
        
        % set swap xy
        if PlotAdvSetting.swap_xy(i) == 0 % swap
            set(handles.panel_xyaxis_swap1,'Value',1)
            set(handles.panel_xyaxis_swap2,'Value',0)
        else % log
            set(handles.panel_xyaxis_swap1,'Value',0)
            set(handles.panel_xyaxis_swap2,'Value',1)
        end
        
        %% find the selected data and selected column
        checklegend = and(strcmp(PlotAdvSetting.y_axis_file(i,:), currData{1}),PlotAdvSetting.y_axis_col(i)==str2num(currData{2}));
        
        if checklegend
            % get the correct row
            %% Set Title/legend/font
            
            % set legend
            set(handles.panel_font_legend_text,'String',PlotAdvSetting.legend_text(i,:))
            % set Font weight
            if PlotAdvSetting.fontweight(i) == 0 % normal
                set(handles.panel_font_fontwt_input1,'Value',1)
                set(handles.panel_font_fontwt_input2,'Value',0)
            else % bold
                set(handles.panel_font_fontwt_input1,'Value',0)
                set(handles.panel_font_fontwt_input2,'Value',1)
            end
            % set font angle
            if PlotAdvSetting.fontangle(i) == 0 % normal
                set(handles.panel_font_fontangle_input1,'Value',1)
                set(handles.panel_font_fontangle_input2,'Value',0)
            else % italic
                set(handles.panel_font_fontangle_input1,'Value',0)
                set(handles.panel_font_fontangle_input2,'Value',1)
            end
            %% set marker spec
            % set show marker?
            if PlotAdvSetting.marker_face_show(i) > 0 % show
                set(handles.panel_mspec_markershow_input1,'Value',1)
                set(handles.panel_mspec_markershow_input2,'Value',0)
            else % hide
                set(handles.panel_mspec_markershow_input1,'Value',0)
                set(handles.panel_mspec_markershow_input2,'Value',1)
            end
            % set show marker edge
            if PlotAdvSetting.marker_edge_show(i) > 0 % show
                set(handles.panel_mspec_markeredgeshow_input1,'Value',1)
                set(handles.panel_mspec_markeredgeshow_input2,'Value',0)
            else % hide
                set(handles.panel_mspec_markeredgeshow_input1,'Value',0)
                set(handles.panel_mspec_markeredgeshow_input2,'Value',1)
            end
            % enable on/off
            if PlotAdvSetting.marker_face_show(i) + PlotAdvSetting.marker_edge_show(i) > 0 % show
                set(handles.panel_mspec_markerstyle_input,'Enable','on')
                set(handles.panel_mspec_markersize_input,'Enable','on')
                set(handles.panel_mspec_markeralpha_input,'Enable','on')
                set(handles.panel_mspec_markerfacecolor_input,'Enable','on')
                set(handles.panel_mspec_markeredgeshow_input,'Enable','on')
            else  % no marker
                set(handles.panel_mspec_markerstyle_input,'Enable','off')
                set(handles.panel_mspec_markersize_input,'Enable','off')
                set(handles.panel_mspec_markeralpha_input,'Enable','off')
                set(handles.panel_mspec_markerfacecolor_input,'Enable','off')
                set(handles.panel_mspec_markeredgeshow_input,'Enable','off')
            end
            % marker style
            set(handles.panel_mspec_markerstyle_input,'Value',find(strcmp(PlotAdvSetting.marker_style(i), get(handles.panel_mspec_markerstyle_input, 'String'))))
            % marker size
            set(handles.panel_mspec_markeralpha_text,'String',[handles.alphatext,' ',num2str(100*PlotAdvSetting.marker_alpha(i), '%.0f'),'%'])
            set(handles.panel_mspec_markersize_input,'Value',find(strcmp(num2str(PlotAdvSetting.marker_size(i)), get(handles.panel_mspec_markersize_input,'String'))))
            % marker face color
            set(handles.panel_mspec_markerfacecolor_input,'BackgroundColor',PlotAdvSetting.marker_face_color{i})
            % marker edge color
            set(handles.panel_mspec_markeredgeshow_input,'BackgroundColor',PlotAdvSetting.marker_edge_color{i})
            %% set line spec
            % set line plot
            set(handles.panel_lspec_lineplot_input,'Value',find(strcmp(PlotAdvSetting.line_plot(i,:), get(handles.panel_lspec_lineplot_input, 'String'))))
            
            % update for error bar plot
            if strcmp(PlotAdvSetting.line_plot{i}, 'errorbar')
                set(handles.panel_datapanel_xneg_chk,'Visible','on')
                set(handles.panel_datapanel_xneg_input,'Visible','on')
                set(handles.panel_datapanel_xpos_chk,'Visible','on')
                set(handles.panel_datapanel_xpos_input,'Visible','on')
                set(handles.panel_datapanel_yneg_chk,'Visible','on')
                set(handles.panel_datapanel_yneg_input,'Visible','on')
                set(handles.panel_datapanel_ypos_chk,'Visible','on')
                set(handles.panel_datapanel_ypos_input,'Visible','on')
                set(handles.panel_lspec_capsize_text,'Visible','on')
                set(handles.panel_lspec_capsize_input,'Visible','on')
                
                set(handles.panel_datapanel_x_text,'String','x','Position',[0.02 0.12 0.05 0.3])
                set(handles.panel_datapanel_x_input,'Position',[0.07 0.2 0.05 0.3])
                set(handles.panel_datapanel_y_text,'String','y','Position',[0.32 0.12 0.05 0.3])
                set(handles.panel_datapanel_y_input,'Position',[0.37 0.2 0.05 0.3])
                set(handles.panel_datapanel_y_i_text,'Position',[0.62 0.12 0.1 0.3])
                set(handles.panel_datapanel_y_i_input,'Position',[0.72 0.12 0.24 0.3])
                
                set(handles.panel_lspec_linecolor_text,'Position',[0.1 0.01 0.3 0.08])
                set(handles.panel_lspec_linecolor_input,'Position',[0.5 0.01 0.4 0.1])
                
                if PlotAdvSetting.errorxneg(i) == 0  % no error bar for x negative
                    set(handles.panel_datapanel_xneg_chk,'Value',0)
                    set(handles.panel_datapanel_xneg_input,'Enable','off')
                else
                    set(handles.panel_datapanel_xneg_chk,'Value',1)
                    set(handles.panel_datapanel_xneg_input,'Enable','on')
                end
                if PlotAdvSetting.errorxpos(i) == 0  % no error bar for x positive
                    set(handles.panel_datapanel_xpos_chk,'Value',0)
                    set(handles.panel_datapanel_xpos_input,'Enable','off')
                else
                    set(handles.panel_datapanel_xpos_chk,'Value',1)
                    set(handles.panel_datapanel_xpos_input,'Enable','on')
                end
                if PlotAdvSetting.erroryneg(i) == 0  % no error bar for y negative
                    set(handles.panel_datapanel_yneg_chk,'Value',0)
                    set(handles.panel_datapanel_yneg_input,'Enable','off')
                else
                    set(handles.panel_datapanel_yneg_chk,'Value',1)
                    set(handles.panel_datapanel_yneg_input,'Enable','on')
                end
                if PlotAdvSetting.errorypos(i) == 0  % no error bar for y positive
                    set(handles.panel_datapanel_ypos_chk,'Value',0)
                    set(handles.panel_datapanel_ypos_input,'Enable','off')
                else
                    set(handles.panel_datapanel_ypos_chk,'Value',1)
                    set(handles.panel_datapanel_ypos_input,'Enable','on')
                end
            else
                set(handles.panel_datapanel_xneg_chk,'Visible','off')
                set(handles.panel_datapanel_xneg_input,'Visible','off')
                set(handles.panel_datapanel_xpos_chk,'Visible','off')
                set(handles.panel_datapanel_xpos_input,'Visible','off')
                set(handles.panel_datapanel_yneg_chk,'Visible','off')
                set(handles.panel_datapanel_yneg_input,'Visible','off')
                set(handles.panel_datapanel_ypos_chk,'Visible','off')
                set(handles.panel_datapanel_ypos_input,'Visible','off')
                set(handles.panel_lspec_capsize_text,'Visible','off')
                set(handles.panel_lspec_capsize_input,'Visible','off')
                
                set(handles.panel_datapanel_x_text,'String','x','Position',[0.02 0.12 0.1 0.3])
                set(handles.panel_datapanel_x_input,'Position',[0.12 0.2 0.1 0.3])
                set(handles.panel_datapanel_y_text,'String','y','Position',[0.25 0.12 0.1 0.3])
                set(handles.panel_datapanel_y_input,'Position',[0.35 0.2 0.1 0.3])
                set(handles.panel_datapanel_y_i_text,'Position',[0.46 0.12 0.1 0.3])
                set(handles.panel_datapanel_y_i_input,'Position',[0.56 0.12 0.4 0.3])
                
                set(handles.panel_lspec_linecolor_text,'Position',[0.1 0.1 0.3 0.1])
                set(handles.panel_lspec_linecolor_input,'Position',[0.5 0.125 0.4 0.1])
            end
            
            % update for area plot
            if strcmp(PlotAdvSetting.line_plot{i}, 'area')
                set(handles.panel_lspec_basevalue_text,'Visible','on')
                set(handles.panel_lspec_basevalu_input,'Visible','on')
                set(handles.panel_lspec_areaFaceColor_input,'Visible','on')
                set(handles.panel_lspec_linecolor_text,'Visible','off')
                set(handles.panel_lspec_linecolor_input,'Position',[0.6 0.04 0.3 0.1],'String',handles.edgetext)
                set(handles.panel_mspec_markeralpha_input,'Enable','on')
            else
                set(handles.panel_lspec_basevalue_text,'Visible','off')
                set(handles.panel_lspec_basevalu_input,'Visible','off')
                set(handles.panel_lspec_areaFaceColor_input,'Visible','off')
                set(handles.panel_lspec_linecolor_text,'Visible','on')
                if strcmp(PlotAdvSetting.line_plot{i}, 'errorbar')
                    set(handles.panel_lspec_linecolor_input,'String',handles.selecttext)
                else
                    set(handles.panel_lspec_linecolor_input,'Position',[0.5 0.125 0.4 0.1],'String',handles.selecttext)
                end
            end
            
            % update for stairs plot
            if strcmp(PlotAdvSetting.line_plot{i}, 'stairs')
                set(handles.panel_lspec_stairs_extend_text,'Visible','on')
                set(handles.panel_lspec_stairs_extend_text2,'Visible','on')
                set(handles.panel_lspec_stairs_input1,'Visible','on')
                set(handles.panel_lspec_stairs_input2,'Visible','on')
                set(handles.panel_lspec_stairsDir,'Visible','on')
                set(handles.panel_lspec_linecolor_text,'Position',[0.1 0.01 0.3 0.08])
                set(handles.panel_lspec_linecolor_input,'Position',[0.5 0.01 0.4 0.1])
                
            else
                set(handles.panel_lspec_stairs_extend_text,'Visible','off')
                set(handles.panel_lspec_stairs_extend_text2,'Visible','off')
                set(handles.panel_lspec_stairs_input1,'Visible','off')
                set(handles.panel_lspec_stairs_input2,'Visible','off')
                set(handles.panel_lspec_stairsDir,'Visible','off')
                if ~or( strcmp(PlotAdvSetting.line_plot{i}, 'errorbar'), strcmp(PlotAdvSetting.line_plot{i}, 'area'))
                    set(handles.panel_lspec_linecolor_text,'Position',[0.1 0.1 0.3 0.1])
                    set(handles.panel_lspec_linecolor_input,'Position',[0.5 0.125 0.4 0.1])
                end
            end
            % set line style
            set(handles.panel_lspec_linestyle_input,'Value',find(strcmp(PlotAdvSetting.line_style(i,:), get(handles.panel_lspec_linestyle_input, 'String'))))
            % set line width
            set(handles.panel_lspec_linewidth_input,'Value',find(strcmp(num2str(PlotAdvSetting.line_width(i)), get(handles.panel_lspec_linewidth_input,'String'))))
            % set line color
            set(handles.panel_lspec_linecolor_input,'BackgroundColor',str2num(PlotAdvSetting.line_color{i}))
            
        end
    end
end

if SetDataListn == 0
    SetDataList{1}=' ';
    set(handles.panel_datapanel_y_i_input, 'string',SetDataList{1})
else
    if length(SetDataList) == 1
        set(handles.panel_datapanel_y_i_input, 'string',SetDataList{1})
    else
        set(handles.panel_datapanel_y_i_input, 'string',SetDataList)
    end
end
