function Unittest(varargin)

    selectedData = [];
    if nargin > 0 && isnumeric(varargin{1})
        selectedData = varargin{1};
    else
        % Retrieve the instance of the first figure by its name
        uiFig1 = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');
        if ~isempty(uiFig1)
            selectedData = uiFig1.UserData;
        end
    end

    selectedData = selectedData(:);
    selectedData = selectedData(isfinite(selectedData));

    if length(selectedData) >= 2
        
        % Look for an existing figure with the name 'Acycle: t test summary'
        sf = findobj('Type', 'figure', 'Name', 'Acycle: t test summary');
        if ~isempty(sf)
            delete(sf);
        end

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
                 'Tag', 'TTestSummaryTable',...
                 'ColumnName', {'Statistic', 'Value'},...
                 'ColumnWidth', {120,240},...
                 'RowName', []);


        % Create a button group
        btnGroup = uibuttongroup(sf,'Visible', 'on', 'Position', [0.05 0.75 .9 .1]); 

        radio1(1) = uicontrol(btnGroup,'Style', 'radio', 'FontSize', 12,...
                        'String', '=',...
                        'Tag', 'TTestAlternativeEqual',...
                        'Units', 'normalized', ...
                        'Position', [0.1, 0.03, 0.2, 0.9],...
                        'Value',1);
        radio1(2) = uicontrol(btnGroup,'Style', 'radio', 'FontSize', 12,...
                        'String', '>',...
                        'Tag', 'TTestAlternativeGreater',...
                        'Units', 'normalized', ...
                        'Position', [0.3, 0.03, 0.2, 0.9],...
                        'Value',0);
        radio1(3) = uicontrol(btnGroup,'Style', 'radio', 'FontSize', 12,...
                        'String', '< given mean',...
                        'Tag', 'TTestAlternativeLess',...
                        'Units', 'normalized', ...
                        'Position', [0.5, 0.03, 0.4, 0.9],...
                        'Value',0);


        text1 = uicontrol(sf,'Style', 'text', 'FontSize', 12,...
                        'String', 'Given mean',...
                        'Units', 'normalized', ...
                        'Position', [0.05, 0.88, 0.2, 0.08]);
        edit1 = uicontrol(sf,'Style', 'edit', 'FontSize', 12,...
                        'String', '0',...
                        'Tag', 'TTestGivenMean',...
                        'Units', 'normalized', ...
                        'Position', [0.3, 0.9, 0.2, 0.06]);     

        % Create a "Statistics Summary" button
        btn = uicontrol(sf,'Style', 'pushbutton','FontSize', 12, ...
                        'String', 't test',...
                        'Tag', 'TTestRunButton',...
                        'Units', 'normalized', ...
                        'Position', [0.75, 0.88, 0.21, 0.1],...
                        'Callback', @statSummary);
        
        
        
        % Calculate statistics
        stats = calculateStatistics(selectedData);
        tab1.Data = stats;
        
    else
        
        warning('No data is selected. Select a series in AC or select cells in Acycle: Data Table.');
        
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
        if ~isscalar(miu) || ~isfinite(miu)
            errordlg('Given mean must be a finite numeric value.', ...
                'Invalid given mean');
            stats = tab1.Data;
            return
        end
        
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
        % Plot the t distribution in t-statistic units. The previous range
        % was based on the hypothesized mean (which has the data's units),
        % and an extreme observed t value could also trigger auto-scaling.
        % Both cases made the distribution appear as a narrow spike.
        if option_cal == 1
            criticalValues = [ci_left, t_critical];
        else
            criticalValues = t_critical;
        end
        baseHalfWidth = max(5, 1.2*max(abs(criticalValues)));
        if isfinite(t)
            plotHalfWidth = min(max(baseHalfWidth, 1.1*abs(t)), ...
                2*baseHalfWidth);
        else
            plotHalfWidth = baseHalfWidth;
        end
        x = linspace(-plotHalfWidth, plotHalfWidth, 1001);
        y = tpdf(x,dof);

        clf(fig1)
        ax = axes('Parent',fig1,'Tag','TTestAxes');
        distributionLine = plot(ax,x,y,'k-','LineWidth',1.25, ...
            'Tag','TTestDistribution');
        % The first plot resets axes properties while NextPlot is
        % 'replace', so restore the semantic tag after drawing it.
        set(ax,'Tag','TTestAxes');
        hold(ax,'on')

        % Use stable, distinguishable colors for the two critical limits.
        upperColor = [0, 0.4470, 0.7410];
        lowerColor = [0.8500, 0.3250, 0.0980];
        observedColor = [0.6350, 0.0780, 0.1840];

        legendHandles = gobjects(0);
        legendLabels = {};
        legendHandles(end+1) = distributionLine;
        legendLabels{end+1} = ['t distribution (dof = ',num2str(dof),')'];

        if option_cal == 1
            upperLine = xline(ax,t_critical,'--','Color',upperColor, ...
                'LineWidth',1.5,'Tag','TTestUpperCritical');
            lowerLine = xline(ax,ci_left,'--','Color',lowerColor, ...
                'LineWidth',1.5,'Tag','TTestLowerCritical');
            legendHandles(end+1) = upperLine;
            legendLabels{end+1} = ['Upper critical t = ', ...
                num2str(t_critical),' (95% CI)'];
            legendHandles(end+1) = lowerLine;
            legendLabels{end+1} = ['Lower critical t = ', ...
                num2str(ci_left),' (95% CI)'];
        elseif option_cal == 2
            criticalLine = xline(ax,t_critical,'--','Color',upperColor, ...
                'LineWidth',1.5,'Tag','TTestUpperCritical');
            legendHandles(end+1) = criticalLine;
            legendLabels{end+1} = ['Upper critical t = ', ...
                num2str(t_critical),' (alpha = 0.05)'];
        else
            criticalLine = xline(ax,t_critical,'--','Color',lowerColor, ...
                'LineWidth',1.5,'Tag','TTestLowerCritical');
            legendHandles(end+1) = criticalLine;
            legendLabels{end+1} = ['Lower critical t = ', ...
                num2str(t_critical),' (alpha = 0.05)'];
        end

        if ~isnan(t)
            observedPlotValue = t;
            observedOutsideRange = ~isfinite(t) || abs(t) > plotHalfWidth;
            if observedOutsideRange
                observedPlotValue = sign(t)*0.97*plotHalfWidth;
            end
            observedLine = xline(ax,observedPlotValue,'-','Color', ...
                observedColor,'LineWidth',1.75,'Tag','TTestObserved', ...
                'UserData',t);
            legendHandles(end+1) = observedLine;
            if observedOutsideRange
                legendLabels{end+1} = ['Observed t = ',num2str(t), ...
                    ' @ μ = ',num2str(miu),' (outside displayed range)'];
            else
                legendLabels{end+1} = ['Observed t = ',num2str(t), ...
                    ' @ μ = ',num2str(miu)];
            end
        end

        % Lock a symmetric range after adding reference lines so xline
        % cannot expand the axes and compress the probability density.
        xlim(ax,[-plotHalfWidth, plotHalfWidth])
        xlabel(ax,'t statistic')
        ylabel(ax,'Probability Density')
        legendObject = legend(ax,legendHandles,legendLabels, ...
            'Location','best');
        set(legendObject,'Tag','TTestLegend');
        title(ax,'Testing the mean: Student''s t distribution')
        hold(ax,'off')
    end
end
