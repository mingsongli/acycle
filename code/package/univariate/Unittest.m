function Unittest(varargin)


    % Retrieve the instance of the first figure by its name
    uiFig1 = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');

    if ~isempty(uiFig1)
        
        % Retrieve the data stored in the first figure
        selectedData = uiFig1.UserData;
        %selectedData = getappdata(fig1, 'SharedData')
        if isnan(selectedData)
            return
        end
        if length(selectedData(:)) < 2
            return
        end
        
        % Look for an existing figure with the name 'Acycle: t test summary'
        sf = findobj('Type', 'figure', 'Name', 'Acycle: t test summary');
        
        % If no such figure exists, create a new one
        if isempty(sf)
            % Create a new figure for statistics
            sf = figure('Name', 'Acycle: t test summary', ...
                'Position', [200, 200, 450, 400],...
                'NumberTitle', 'off');
            
            set(sf,'units','norm') % set location
            set(sf,'Units','normalized') % set units as normalized
            
            % Create a uitable for statistics
            tab1 = uitable(sf, 'FontSize', 12,...
                     'units','normalized',...
                     'Position', [0.05, 0.03, 0.9, 0.65],...
                     'ColumnName', {'Statistic', 'Value'},...
                     'ColumnWidth', {120,240},...
                     'RowName', []);


            % Create a button group
            btnGroup = uibuttongroup('Visible', 'on', 'Position', [0.05 0.75 .9 .1]); 

            radio1(1) = uicontrol(btnGroup,'Style', 'radio', 'FontSize', 12,...
                            'String', '=',...
                            'Units', 'normalized', ...
                            'Position', [0.1, 0.03, 0.2, 0.9],...
                            'Value',1);
            radio1(2) = uicontrol(btnGroup,'Style', 'radio', 'FontSize', 12,...
                            'String', '>',...
                            'Units', 'normalized', ...
                            'Position', [0.3, 0.03, 0.2, 0.9],...
                            'Value',0);
            radio1(3) = uicontrol(btnGroup,'Style', 'radio', 'FontSize', 12,...
                            'String', '< given mean',...
                            'Units', 'normalized', ...
                            'Position', [0.5, 0.03, 0.4, 0.9],...
                            'Value',0);


            text1 = uicontrol('Style', 'text', 'FontSize', 12,...
                            'String', 'Given mean',...
                            'Units', 'normalized', ...
                            'Position', [0.05, 0.88, 0.2, 0.08]);
            edit1 = uicontrol('Style', 'edit', 'FontSize', 12,...
                            'String', '0',...
                            'Units', 'normalized', ...
                            'Position', [0.3, 0.9, 0.2, 0.06]);     

            % Create a "Statistics Summary" button
            btn = uicontrol('Style', 'pushbutton','FontSize', 12, ...
                            'String', 't test',...
                            'Units', 'normalized', ...
                            'Position', [0.75, 0.88, 0.21, 0.1],...
                            'Callback', @statSummary);

        else
            figure(sf); 
        end
        
        
        
        % Calculate statistics
        stats = calculateStatistics(selectedData);
        tab1.Data = stats;
        
    else
        
        warning('The Acycle: Data Table does not exist or has not been created yet.');
        
    end
    
    % Variable to store selected data
    %selectedData = [];
    miu = [];

    % Callback function for button press
    function statSummary(~, ~)
        
        % Calculate statistics
        stats = calculateStatistics(selectedData);
        tab1.Data = stats;

    end
    

    % Function to calculate statistics
    function stats = calculateStatistics(data)
        
        a = data(:);  % force
        miu = str2double(edit1.String);
        
        if radio1(1).Value == 1
            option_cal = 1;
        elseif radio1(2).Value == 1
            option_cal = 2;
        elseif radio1(3).Value == 1
            option_cal = 3;
        end
        
        % mean of a
        a_mean = mean(a);
        % std
        std_dev = std(a);
        % number of data points
        n = length(a);
        % degree of freedom
        dof = n-1;
        
        % t value
        t = (a_mean - miu)/(std_dev * sqrt(1/n));
        
        if option_cal == 1  % compare means = 
            alpha = 0.025;  % (two-tailed)
        elseif option_cal == 2
            alpha = 0.05;  % one tailed
        elseif option_cal == 3
            alpha = 0.05;  % one tailed
        end
        
        % Find the critical t-value (two-tailed)
        t_critical = tinv(1-alpha, dof); % 0.975 because the 2.5% in the upper tail and 2.5% in the lower tail
        
        % Calculate the standard error of the mean
        sem = std_dev / sqrt(n);

        % Calculate the margin of error
        margin_of_error = t_critical * sem;

        % Calculate the confidence intervals
        ci_lower = a_mean - margin_of_error;  
        ci_upper = a_mean + margin_of_error;

        if option_cal == 1  % compare means = 
            % inverse CDF
            ci_left = tinv(0.025,dof);
            p = 2 * (1 - tcdf(abs(t), dof));
            
            if p<=0.05
                stat1 = 'Means are significantly different';
            else
                stat1 = 'Means are not significantly different';
            end
            
            stats = { '                  N:', num2str(length(a));
                      '         Given Mean:', num2str(miu);
                      '        Sample Mean:', num2str(a_mean);
                      ' 95% conf. interval:', [num2str(ci_lower),' - ',num2str(ci_upper)];
                      ' ', '';
                      '         Difference:', num2str(abs(miu - a_mean));
                      ' 95% conf. interval:', [num2str(ci_lower-miu),' - ',num2str(ci_upper-miu)];
                      ' ', '';
                      '                  t:', num2str(t);
                      'p value (same mean):', num2str(p);
                      '','';
                      '         Conclusion:',stat1};
                  
        elseif option_cal == 2  % compare means
            % Find the critical t-value (one-tailed)
            %t = abs(t);
            if t > t_critical
                stat1 = ['Reject H0: u <= ', num2str(miu),'; Accept H1: u > ', num2str(miu)];
            else
                stat1 = ['Accept H0: u <= ', num2str(miu),'; Reject H1: u > ', num2str(miu)];
            end
            % one side, thus p-value = 0.05
            p =  1-tcdf(t, dof);
            
            stats = { '                  N:', num2str(length(a));
                      '         Given Mean:', num2str(miu);
                      '        Sample Mean:', num2str(a_mean);
                      ' 95% conf. interval:', num2str(ci_lower);
                      ' ', '';
                      '         Difference:', num2str(abs(miu - a_mean));
                      ' 95% conf. interval:', num2str(ci_upper-miu);
                      ' ', '';
                      '                  t:', num2str(t);
                      'p value (same mean):', num2str(p);
                      '','';
                      '         Conclusion:',stat1};
                  
        elseif option_cal == 3  % compare means
            % Find the critical t-value (one-tailed)
            t_critical = tinv(0.05, dof);
            if t < t_critical
                stat1 = ['Reject H0: u >= ', num2str(miu),'; Accept H1: u < ', num2str(miu)];
            else
                stat1 = ['Accept H0: u >= ', num2str(miu),'; Reject H1: u < ', num2str(miu)];
            end
            % one side, thus p-value = 0.05
            p =  tcdf(t, dof);
            
            stats = { '                  N:', num2str(length(a));
                      '         Given Mean:', num2str(miu);
                      '        Sample Mean:', num2str(a_mean);
                      ' 95% conf. interval:', num2str(ci_upper);
                      ' ', '';
                      '         Difference:', num2str(abs(miu - a_mean));
                      ' 95% conf. interval:', num2str(ci_lower-miu);
                      ' ', '';
                      '                  t:', num2str(t);
                      'p value (same mean):', num2str(p);
                      '','';
                      '         Conclusion:',stat1};
                  
        end
        
        
        %% Figure
        % Look for an existing figure with the name 'sf'
        fig1 = findobj('Type', 'figure', 'Name', 'Acycle: t test plot');
        % If no such figure exists, create a new one
        if isempty(fig1)
            fig1 = figure('Name', 'Acycle: t test plot','NumberTitle', 'off');
        else
            figure(fig1)
        end
        % PDF
        if miu > 5
            xlim1 = 1.2*miu;
        else
            xlim1 = 5;
        end
        x = -1*xlim1 : .1 : xlim1;
        y = tpdf(x,dof);
        % plot
        plot(x,y,'k-')
        hold on
        xline(t_critical,'k--')
        if option_cal == 1 
            xline(ci_left,'k--')
        end
        xline(t,'r-')
        xlabel('Observation')
        ylabel('Probability Density')
        legend({['dof = ',num2str(dof)],['t = ',num2str(t_critical),' @ 95% CI'],['t = ',num2str(t),'@ μ = ',num2str(miu)]})
        title('Testing the mean: probability of a value ')
        hold off
    end
end
