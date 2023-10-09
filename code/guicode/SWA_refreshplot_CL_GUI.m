function SWA_refreshplot_CL_GUI(handles)
    % 创建主要GUI界面
    global dat_name ext nw
    outputdata = handles.outputdata;
    
    f = figure('Name', 'FDR & Chi2 CL', 'NumberTitle', 'off', 'Position', [100, 100, 300, 350], 'MenuBar', 'none', 'ToolBar', 'none');

    % 创建并标记checkboxes
    labels = {'0.01% FDR'; '0.1% FDR'; '1% FDR'; '5% FDR'; '10% FDR'; '99.99% Chi2 CL'; '99.9% Chi2 CL'; '99% Chi2 CL'; '95% Chi2 CL'; '90% Chi2 CL'; 'Background'};
    positions = linspace(320, 20, numel(labels));  % 根据您的需要调整位置

    for k = 1:numel(labels)
        handles.checkbox1(k) = uicontrol('Style', 'checkbox', 'String', labels{k}, 'Position', [50, positions(k), 200, 20], 'Callback', @checkbox_callback);
    end
    clfdr = outputdata(:, 9:13);
    
    for k = 5:-1:1
        if isnan(clfdr(1,k)) %  nan value
            set(handles.checkbox1(6-k), 'Enable','Off','Value',0)
        else  % FDR detected
            set(handles.checkbox1(6-k), 'Enable','on','Value',1)
        end
    end
    
    for k = 1:6
        set(handles.checkbox1(5+k), 'Enable','on','Value',1)
    end
    
    setappdata(f, 'Handles', handles);  % 存储handles
end

function checkbox_callback(src, ~)
    handles = getappdata(gcf, 'Handles');  % 获取handles
    refreshSWAplot(handles);
end

function refreshSWAplot(handles)
    % 检查figswaplot是否存在
    data_name = handles.data_name;
    nw = handles.timebandwidth;
    fmax = handles.fmax;
    fmin = handles.fmin;
    xvalue = handles.xvalue; 
    outputdata = handles.outputdata;
    clfdr = outputdata(:, 9:13);
    plot_x_period = handles.plot_x_period;
    %xvalue = outputdata(:,1);
    pxx = outputdata(:,2);
    swa = outputdata(:,3);
    chi90 = outputdata(:,4);
    chi95 = outputdata(:,5);
    chi99 = outputdata(:,6);
    chi999 = outputdata(:,7);
    chi9999 = outputdata(:,8);
    % lang
    lang_id = handles.lang_id;
    lang_var = handles.lang_var;
% 
%     figs = findall(0, 'Type', 'figure');
%     
%     figswaplot = ['Acycle: ',data_name,'-',num2str(nw),'pi MTM SWA'];
%     
%     idx = find(strcmp({figs.Name}, figswaplot));
    
    try figure(handles.fswa)
        hold off
        clf(handles.fswa)
    catch
        handles.fswa = figure('Name',['Acycle: ',data_name,'-',num2str(nw),'pi MTM SWA']);
    end
%     % 如果figswaplot不存在，则创建它
%     if isempty(idx)
%         fig = figure('Name', figswaplot, 'NumberTitle', 'off');
%     else
%         % 如果figswaplot存在，清除其内容
%         fig = figs(idx);
%         hold off
%     end
%     
    set(gcf,'color','white');
    set(gcf,'units','norm') % set location

    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        xlabel(['Frequency (cycles/',num2str(handles.unit),')'])
        ylabel('Power')

        if plot_x_period
            xlabel(['Period (',handles.unit,')']);
        end
        
    else
        [~, locb] = ismember('spectral33',lang_id);
        xlabel([lang_var{locb},num2str(handles.unit),')']) 
         [~, locb1] = ismember('spectral30',lang_id);
        ylabel(lang_var{locb1})

        if plot_x_period
            [~, locb] = ismember('main15',lang_id);
            xlabel([lang_var{locb},' (',num2str(handles.unit),')']) 
        end
    end

    hold on
    % plot FDR
    %if ~isnan(clfdr(1,5))  % 0.01% FDR
    if get(handles.checkbox1(1),'Value') == 1    
        plot(xvalue, clfdr(:,5),'k--','LineWidth',0.5,'DisplayName','0.01% FDR');
    end
    if get(handles.checkbox1(2),'Value') == 1   
        plot(xvalue, clfdr(:,4),'g--','LineWidth',0.5,'DisplayName','0.1% FDR'); % 0.1% FDR
    end
    if get(handles.checkbox1(3),'Value') == 1   
        plot(xvalue, clfdr(:,3),'b--','LineWidth',0.5,'DisplayName','1% FDR'); % 1% FDR
    end
    if get(handles.checkbox1(4),'Value') == 1    % 5% FDR
        plot(xvalue, clfdr(:,2),'r-.','LineWidth',2,'DisplayName','5% FDR'); % 5% FDR
    end
    if get(handles.checkbox1(5),'Value') == 1    % 10% FDR
        plot(xvalue, clfdr(:,1),'m--','LineWidth',0.5,'DisplayName','10% FDR'); % 10% FDR
    end
    if get(handles.checkbox1(6),'Value') == 1   
        plot(xvalue,chi9999,'g-.','LineWidth',0.5,'DisplayName','Chi2 99.99% CL')
    end
    if get(handles.checkbox1(7),'Value') == 1   
        plot(xvalue,chi999,'m-.','LineWidth',0.5,'DisplayName','Chi2 99.9% CL')
    end
    if get(handles.checkbox1(8),'Value') == 1   
        plot(xvalue,chi99,'b-.','LineWidth',0.5,'DisplayName','Chi2 99% CL')
    end
    if get(handles.checkbox1(9),'Value') == 1   
        plot(xvalue,chi95,'r--','LineWidth',1.5,'DisplayName','Chi2 95% CL')
    end
    if get(handles.checkbox1(10),'Value') == 1   
        plot(xvalue,chi90,'r-','LineWidth',0.5,'DisplayName','Chi2 90% CL')
    end
    if get(handles.checkbox1(11),'Value') == 1   
        plot(xvalue,swa,'k-','LineWidth',1.5,'DisplayName','Backgnd')
    end
    plot(xvalue, pxx,'k-','LineWidth',0.5,'DisplayName','Power'); 
    legend
    set(gca,'YScale','log');
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gcf,'Color', 'white')
    xlim([fmin, fmax])
    if handles.plot_x_period == 1
        set(gca, 'XDir','reverse')
    end
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    % 在fig上执行绘图代码
    % 您的绘图代码放在这里
end
