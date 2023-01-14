%  Update Plot Pro 2D line GUI

%PlotAdvSetting
assignin('base','tbl',PlotAdvSetting);

[m, ~] = size(PlotAdvSetting);

try
    figure(handles.plotpro2dfig); 
catch
    handles.plotpro2dfig=figure('Name',handles.FigNameText,'NumberTitle','off');
    set(handles.plotpro2dfig,'units','norm') % set location
    set(0,'Units','normalized') % set units as normalized
    set(handles.plotpro2dfig,'position',[0.62,0.2,0.35,0.5],'Color','white') % set position
end
set(gcf,'color','w');

k = 1;   % subplot ID

for j = 1: PlotAdvSetting.panel_nrow(1) * PlotAdvSetting.panel_ncol(1)  % for all panels
    
    subplot(PlotAdvSetting.panel_nrow(1), PlotAdvSetting.panel_ncol(1), k)  % for the k-th panel
    n = 1;  % number of time series in this subplot ID k
    
    for i = 1:m  % search each rows of excel
        
        if PlotAdvSetting.panel_i(i) == k  % if the time series i is for the panel k

            % read y
            data = load(PlotAdvSetting.y_axis_file(i,:));  % load the data for y axis
            y = data(:, PlotAdvSetting.y_axis_col(i));    % read the user-defined column

            if PlotAdvSetting.x_axis_col(i) > 0  % use user-defined column # as the first column (x)
            % read x
                data = load(PlotAdvSetting.x_axis_file(i,:));
                x = data(:, PlotAdvSetting.x_axis_col(i));
            else  % use a datapoint number series as the first column (x)
                x = 1 : length(y);
            end
            % upadate the k-th panel for the first time
            if n > 1
                hold on; 
            end
            %% plot style
            %PlotAdvSetting.line_plot{i}
            if strcmp(PlotAdvSetting.line_plot{i}, 'line')
                % 2d line plot
                plotHd = plot(x, y);
                plotHd.Color=PlotAdvSetting.line_color{i};
            elseif strcmp(PlotAdvSetting.line_plot{i}, 'stairs')
                % extend / pad edge
                if PlotAdvSetting.stairsEdge1(i) < min(x)
                    x = [PlotAdvSetting.stairsEdge1(i); x];
                    y = [y(1); y];
                end
                if PlotAdvSetting.stairsEdge2(i) > max(x)
                    x = [x; PlotAdvSetting.stairsEdge2(i)];
                    y = [y; y(end)];
                end
                % stair plot
                if PlotAdvSetting.stairsDir(i) == 1
                    plotHd = stairs(x, y);
                else
                    plotHd = stairs(flipud(x), flipud(y));
                end
                plotHd.Color=PlotAdvSetting.line_color{i};
            elseif strcmp(PlotAdvSetting.line_plot{i}, 'area')
                % area plot
                plotHd = area(x, y, PlotAdvSetting.area_basevalue(i));
                plotHd.FaceColor = PlotAdvSetting.area_facecolor{i};
                plotHd.EdgeColor = PlotAdvSetting.line_color{i};
                plotHd.FaceAlpha = PlotAdvSetting.marker_alpha(i);
            elseif strcmp(PlotAdvSetting.line_plot{i}, 'errorbar')
                % errorbar
                dat_tmp = nan(length(y),4);
                if PlotAdvSetting.erroryneg(i) > 0
                    data = load(PlotAdvSetting.y_axis_file(i,:));
                    dat_tmp(:,1) = data(:,PlotAdvSetting.erroryneg(i));
                end
                if PlotAdvSetting.errorypos(i) > 0
                    data = load(PlotAdvSetting.y_axis_file(i,:));
                    dat_tmp(:,2) = data(:,PlotAdvSetting.errorypos(i));
                end
                if PlotAdvSetting.errorxneg(i) > 0
                    data = load(PlotAdvSetting.y_axis_file(i,:));
                    dat_tmp(:,3) = data(:,PlotAdvSetting.errorxneg(i));
                end
                if PlotAdvSetting.errorxpos(i) > 0
                    data = load(PlotAdvSetting.y_axis_file(i,:));
                    dat_tmp(:,4) = data(:,PlotAdvSetting.errorxpos(i));
                end
                plotHd = errorbar(x, y,dat_tmp(:,1),dat_tmp(:,2),dat_tmp(:,3),dat_tmp(:,4));
                %axis padded
                plotHd.Color = PlotAdvSetting.line_color{i};

                %plotHd.Color = [PlotAdvSetting.line_color{i}, 0.5];
                plotHd.CapSize = PlotAdvSetting.errorcapsize(i);
                if PlotAdvSetting.errorcapsize(i) > 0
                    set(plotHd.Cap, 'EdgeColorType', 'truecoloralpha', 'EdgeColorData', [plotHd.Cap.EdgeColorData(1:3); 255* PlotAdvSetting.marker_alpha(i)]) % the last is alpha
                end
                %else
                    set([plotHd.Bar, plotHd.Line], 'ColorType', 'truecoloralpha', 'ColorData', [plotHd.Line.ColorData(1:3); 255* PlotAdvSetting.marker_alpha(i) ])
                %end
            end
            
            plotHd.LineStyle=PlotAdvSetting.line_style{i};
            plotHd.LineWidth=PlotAdvSetting.line_width(i);
            
            %% show marker
            if or(PlotAdvSetting.marker_face_show(i) == 1, PlotAdvSetting.marker_edge_show(i) == 1)
                hold on
                scatterHd = scatter(x, y);
                scatterHd.Marker = PlotAdvSetting.marker_style{i};
                scatterHd.SizeData = PlotAdvSetting.marker_size(i);
                if PlotAdvSetting.marker_face_show(i) == 1
                    scatterHd.MarkerFaceColor = PlotAdvSetting.marker_face_color{i};
                else
                    scatterHd.MarkerFaceColor = 'none';
                end
                if PlotAdvSetting.marker_edge_show(i) == 1
                    scatterHd.MarkerEdgeColor = PlotAdvSetting.marker_edge_color{i};
                else
                    scatterHd.MarkerEdgeColor = 'none';
                end
                scatterHd.MarkerFaceAlpha = PlotAdvSetting.marker_alpha(i);
                hold off
            end
            % panel title
            title(PlotAdvSetting.title{i})
            % x label
            xlabel(PlotAdvSetting.xlabel{i})
            % y label
            ylabel(PlotAdvSetting.ylabel{i})
            % x minor tick
            if PlotAdvSetting.xminortick(i) == 1
                set(gca,'XMinorTick','on')
            else
                set(gca,'XMinorTick','off')
            end
            % y minor tick
            if PlotAdvSetting.yminortick(i) == 1
                set(gca,'YMinorTick','on')
            else
                set(gca,'YMinorTick','off')
            end
            % x limit
            xlim([PlotAdvSetting.xlim_low(i), PlotAdvSetting.xlim_high(i)])
            % y limit
            if strcmp(PlotAdvSetting.line_plot{i}, 'area')
                ylim([min(PlotAdvSetting.area_basevalue(i),PlotAdvSetting.ylim_low(i)), PlotAdvSetting.ylim_high(i)])
            else
                ylim([PlotAdvSetting.ylim_low(i), PlotAdvSetting.ylim_high(i)])
            end
            % legend on/off
            if PlotAdvSetting.legend(i) == 1
                legend('show')
            else
                legend('hide')
            end
            % legend text
            plotHd.DisplayName = PlotAdvSetting.legend_text{i};
            if PlotAdvSetting.legend_box(i) == 1
                legend('boxon')
            else
                legend('boxoff')
            end
            % x & y dir
            if PlotAdvSetting.xdir(i) == 1
                set(gca, 'XDir','normal')
            else
                set(gca, 'XDir','reverse')
            end
            if PlotAdvSetting.ydir(i) == 1
                set(gca, 'YDir','normal')
            else
                set(gca, 'YDir','reverse')
            end
            % x & y scale linear vs log
            if PlotAdvSetting.xscale(i) == 1
                set(gca,'xscale','linear')
            else
                set(gca,'xscale','log')
            end
            if PlotAdvSetting.yscale(i) == 1
                set(gca,'yscale','linear')
            else
                set(gca,'yscale','log')
            end
            % x & y grid on / off
            if PlotAdvSetting.grid(i) == 1
                set(gca,'XGrid','on')
                set(gca,'YGrid','on')
            else
                set(gca,'XGrid','off')
                set(gca,'YGrid','off')
            end
            % font
            set(gca,'FontName',PlotAdvSetting.fontname{1})
            % font weight
            if PlotAdvSetting.fontweight(i) == 0 % normal
                set(gca,'FontWeight','normal')
            else
                set(gca,'FontWeight','bold')
            end
            % font size
            set(gca,'FontSize',PlotAdvSetting.fontsize(1))
            if PlotAdvSetting.fontangle(i) == 0 % normal
                set(gca,'FontAngle','normal')
            else
                set(gca,'FontAngle','italic')
            end
            
            % swap
            if PlotAdvSetting.swap_xy(i) == 1
                view([90 -90])
            else
                view([0 90]);
            end
            n = n+1;
        end
    end

    hold off
    k = k + 1;
end
axis tight
figure(handles.h_PlotPro2DLineGUI); 
