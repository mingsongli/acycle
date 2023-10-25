function UniTwoSampleTestsUI
    % Retrieve the instance of the first figure by its name
    uiFig1 = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');
    
    if ~isempty(uiFig1)
        % Retrieve the data stored in the first figure
        selectedData = uiFig1.UserData;
        try
            if isempty(selectedData) || isnan(selectedData)
                warndlg('Warning: no data in Data Table selected')
                return
            end
        catch
        end
        if length(selectedData(:)) < 3
            return
        end
        
        [~, ncol] =size(selectedData);
        if ncol ~= 2
            warndlg('Warning: two columns in Data Table must be selected')
            return
        end
        
        tabcontent = {
            't test', ...
            'F test', ...
            'Mann-Whitney U test', ...
            'Kolmogorov–Smirnov test', ...
            'Anderson–Darling test '};
        % look for an existing figure with the name 'Acycle: Two Sample Tests'
        fig = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Two Sample Tests');
        % if no such uifigure
        
        if isempty(fig)
            % Create the figure
            fig = uifigure('Name', 'Acycle: Two Sample Tests', 'Position',[100 100 800 400]);

            % Create the tab group
            tabGroup = uitabgroup(fig);
            tabGroup.Position = [20 20 760 370];
            tabGroup.SelectionChangedFcn = @tabChangedCallback;

            % Create tabs
            tabs = gobjects(1, 5);  % Preallocate the array for tabs
            
            for i = 1:5
                tabs(i) = uitab(tabGroup, 'Title', tabcontent{1,i}, 'UserData', i);
            end

            tabChangedCallback;
            
        else
            figure(fig)
        end
    else
        warning('The Acycle: Data Table does not exist or has not been created yet.');
    end
    
end

% Define the tab changed callback function
function tabChangedCallback(src, event)
    
    fig = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Two Sample Tests');
    
    multilineText = {''};
    
    % Create a textarea to display the text
    txt = uitextarea(fig,...
        'Position', [20, 20, 760, 345],... % Position and size of the text area
        'Value', multilineText,...         % Set the multiline text
        'FontSize', 14,...                 % Set font size
        'Editable', 'off',...              % Make it read-only; text can be selected but not changed
        'HorizontalAlignment', 'Left',...  % Optional: Set horizontal alignment
        'BackgroundColor', 'w');  
    txt.Value = {''};
    drawnow;
    try
        % Get the selected tab
        selectedTab = event.NewValue;
        % Retrieve the user data (tab index)
        tabIndex = selectedTab.UserData;
    catch  % default tab index == 1; t test
        tabIndex = 1;
    end
    
    % Display a message in the Command Window (or execute any other commands you need)
    %disp(['Tab ', num2str(tabIndex), ' was selected.']);
    % Here you can add more complex actions that you want to execute when each tab is clicked.
    % Extract the data from each group
    
    uiFig1 = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');
    
    selectedData = uiFig1.UserData;
    group1 = selectedData(:, 1);
    group2 = selectedData(:, 2);
    group1 = group1(~isnan(group1)); % remove empty cell
    group2 = group2(~isnan(group2)); % remove empty cell
    %% tabIndex 1: t test
    if tabIndex == 1
        % Perform the t-test
        [h1, p1, ci1, stats1] = ttest(group1);
        [h2, p2, ci2, stats2] = ttest(group2);
        [h, p, ci, stats] = ttest2(group1, group2);
        
        multilineText = {
            ''
            'T test for equal means'
            ''
            'The first sample A                            The second sample B'
            ['N: ', sprintf('%10.0f', length(group1)),'                                 ',...
             'N: ', sprintf('%10.0f', length(group2))]
            ['Mean: ',sprintf('%10.6f', mean(group1)),'                              ',...
             'Mean: ',sprintf('%10.6f', mean(group2))]
            ['Conf. Interval: [', sprintf('%10.6f', ci1(1)),'  ',sprintf('%10.6f', ci1(2)),']','      ',...
             'Conf. Interval: [', sprintf('%10.6f', ci2(1)),'  ',sprintf('%10.6f', ci2(2)),']']
            ''
            ['Difference in means: ',num2str(mean(group1) - mean(group2))]
            ['Confidence Interval of the difference in means: [', num2str(ci(1)),'  ', num2str(ci(2)),']']
            ''
            ['T-statistic = ', num2str(stats.tstat)]
            ['Degrees of Freedom = ', num2str(stats.df)]
            ['P-value (same mean) = ', num2str(p)]
            ''
            'CONCLUSION:'
            ''
            ''
        }; 
            % Define the text with multiple lines
            if h == 1
                multilineText{18,1} = 'Reject the null hypothesis (equal means) at the 5% significance level.';
            else
                multilineText{18,1} = 'Accept the null hypothesis (equal means) at the 5% significance level.';
            end
    %% tabIndex 2: f test
    elseif tabIndex == 2
        
        for i = 1:2
            if i == 1
                dat1 = group1;
            else 
                dat1 = group2;
            end
            % Sample size
            n = length(dat1);
            % Sample variance
            s2 = var(dat1, 1); % Note: using 1 for the W parameter to get the unbiased estimate
            % Confidence level, typically 0.95 for 95%
            confLevel = 0.95;
            % Calculate the confidence interval for the variance
            alpha = 1 - confLevel;
            chi2_lower = chi2inv(alpha/2, n-1);
            chi2_upper = chi2inv(1 - alpha/2, n-1);
            var_lower = ((n-1) * s2) / chi2_upper;
            var_upper = ((n-1) * s2) / chi2_lower;
            
            var2(i,1) = var_lower;
            var2(i,2) = var_upper;
        end
        
        % test 2 samples
        [h, p, ci, stats] = vartest2(group1, group2);
        
        
        multilineText = {
            ''
            'F test for equal variances'
            ''
            'The first sample A                            The second sample B'
            ['N: ', sprintf('%10.0f', length(group1)),'                                 ',...
             'N: ', sprintf('%10.0f', length(group2))]
            ['Degree of freedom (DOF): ', sprintf('%5.0f', stats.df1),'                ',...
             'DOF: ', sprintf('%8.0f', stats.df2)]
            ['Variance: ',sprintf('%10.6f', var(group1)),'                          ',...
             'Variance: ',sprintf('%10.6f', var(group2))]
            ['Conf. Interval: [', sprintf('%10.6f', var2(1,1)),'  ',sprintf('%10.6f', var2(1,2)),']','      ',...
             'Conf. Interval: [', sprintf('%10.6f', var2(2,1)),'  ',sprintf('%10.6f', var2(2,2)),']']
            ''
            ['Difference in variance: ',num2str(abs(var(group1) - var(group2)))]
            ''
            ['F-statistic = ', num2str(stats.fstat)]
            ['Confidence Interval for the ratio of the variances: [', num2str(ci(1)),'  ', num2str(ci(2)),']']
            ['P-value (same variance) = ', num2str(p)]
            ''
            'CONCLUSION:'
            ''
            ''
        }; 
        % Display the results
        if h == 0
            multilineText{18,1} = 'Do not reject the null hypothesis that the variances are equal at the 5% significance level.';
        else
            multilineText{18,1} = 'Reject the null hypothesis that the variances are equal at the 5% significance level.';
        end
        
    %% tabIndex 3: Mann-Whitney U test
    elseif tabIndex == 3
        % Perform the Mann-Whitney U test
        % a nonparametric test of the null hypothesis that 
        % it is equally likely that a randomly selected value from one population 
        % will be less than or greater than a randomly selected value from a
        % second population. This test does not assume a normal distribution 
        % and is used when comparing two samples that are independent, 
        % but not necessarily of the same size.
        [p, h, stats] = ranksum(group1, group2);
        
        % Pool the data
        pooledData = [group1; group2];

        % Get the ranks of the pooled data
        ranks = tiedrank(pooledData);  % 'tiedrank' handles ties appropriately

        % Determine the ranks for each group
        ranks_group1 = ranks(1:length(group1));
        ranks_group2 = ranks(length(group1)+1:end);

        % Compute the sum of ranks for each group
        sumRanks_group1 = sum(ranks_group1);
        sumRanks_group2 = sum(ranks_group2);

        % Compute the U statistic for each group
        u1 = sumRanks_group1 - (length(group1)*(length(group1)+1))/2;
        u2 = sumRanks_group2 - (length(group2)*(length(group2)+1))/2;

        % The U statistic is the smaller of u1 and u2
        U = min(u1, u2);

        % Compute the median rank for each group
        medianRank_group1 = median(ranks_group1);
        medianRank_group2 = median(ranks_group2);
        
        multilineText = {
            ''
            'Mann-Whitney U test for equal medians'
            ''
            'The first sample A                            The second sample B'
            ['N: ', sprintf('%15.0f', length(group1)),'                            ',...
             'N: ', sprintf('%15.0f', length(group2))]
            ''
            ['Mann-Whitney U: ', sprintf('%10.6f', U)]
            ['             z: ', sprintf('%10.6f', stats.zval)]
            ''
            ['P-value (same variance) = ', num2str(p)]
            ''
            'CONCLUSION:'
            ''
            ''
        }; 
    
        if h == 0
            multilineText{14,1} = 'Do not reject the null hypothesis at the 5% significance level';
        else
            multilineText{14,1} = 'Reject the null hypothesis at the 5% significance level';
        end
    %%  Kolmogorov–Smirnov
    elseif tabIndex == 4
        
        [h,p,ks2stat] = kstest2(group1, group2);
        
        multilineText = {
            ''
            'Two-sample Kolmogorov–Smirnov test for same continuous distribution'
            ''
            'The first sample A                            The second sample B'
            ['N: ', sprintf('%15.0f', length(group1)),'                            ',...
             'N: ', sprintf('%15.0f', length(group2))]
            ''
            ['Kolmogorov–Smirnov statistic: ', sprintf('%10.6f', ks2stat)]
            ''
            ['P-value (same variance) = ', num2str(p)]
            ''
            'CONCLUSION:'
            ''
            ''
        }; 
        
    
        if h == 0
            multilineText{13,1} = 'Do not reject the null hypothesis at the 5% significance level';
        else
            multilineText{13,1} = 'Reject the null hypothesis at the 5% significance level';
        end
    %%  Anderson–Darling test
    elseif tabIndex == 5
        % prepare data
        X1 = [group1, ones(length(group1),1)];  
        X2 = [group2, ones(length(group2),1)*2];
        X = [X1;X2]; 
        AnDarksamtest1 = AnDarksamtest(X);
        alpha = 0.05;
        
        multilineText = {
            ''
            'K-sample Anderson-Darling test for same continuous distribution'
            ''
            'The first sample A                            The second sample B'
            ['N: ', sprintf('%15.0f', length(group1)),'                            ',...
             'N: ', sprintf('%15.0f', length(group2))]
            ['Number of ties (identical values): ', sprintf('%6.0f', AnDarksamtest1.nties)]
            ['Mean of the Anderson-Darling rank statistic: ', sprintf('%10.6f', AnDarksamtest1.meanADRstat)]
            ['Standard deviation of the Anderson-Darling rank statistic: ', sprintf('%10.6f', AnDarksamtest1.stdADRstat)]
            ''
            '- - - - - - - - - - - - - - - - - - - - - '
            'Not adjusted for ties' % line 10
            ['Anderson-Darling rank statistic: ', sprintf('%10.6f', AnDarksamtest1.ADKn)]
            ['Standardized Anderson-Darling rank statistic: ', sprintf('%10.6f', AnDarksamtest1.ADKsn)]
            ['Probability associated to the Anderson-Darling rank statistic = ', sprintf('%10.6f', AnDarksamtest1.Pn)]
            ''
            'CONCLUSION:'
            ['With a given significance p-value = ', sprintf('%3.4f', alpha)]
            ''
            '' 
            ''
            '- - - - - - - - - - - - - - - - - - - - - '
            'Adjusted for ties'
            ['Anderson-Darling rank statistic: ', sprintf('%10.6f', AnDarksamtest1.ADK)]
            ['Standardized Anderson-Darling rank statistic: ', sprintf('%10.6f', AnDarksamtest1.ADKs)]  % line 21
            ['Probability associated to the Anderson-Darling rank statistic = ', sprintf('%10.6f', AnDarksamtest1.P)]
            ''
            'CONCLUSION:'
            ['With a given significance p-value = ', sprintf('%3.4f', alpha)]
            ''
            ''
            ''
        }; 
        
        if AnDarksamtest1.Pn >= alpha
            multilineText{19,1} = 'The populations from which the k-samples of data were drawn are identical:';
            multilineText{20,1} = 'natural groupings have no significant effect (unstructurated).';
        else
            multilineText{19,1} = 'The samples were drawn from different populations: data may be considered'; 
            multilineText{20,1} = 'structurated with respect to the random of fixed effect in question.';
        end
        
        if AnDarksamtest1.P >= alpha
            multilineText{29,1} = 'The populations from which the k-samples of data were drawn are identical:';
            multilineText{30,1} = 'natural groupings have no significant effect (unstructurated).';
        else
            multilineText{29,1} = 'The samples were drawn from different populations: data may be considered'; 
            multilineText{30,1} = 'structurated with respect to the random of fixed effect in question.';
        end
        
    else
        multilineText = {''};
        disp('to be done')
        txt.Value = multilineText;
        
    end
    
    txt.Value = multilineText;
    try 
        txt.FontName = 'Courier'; 
    catch
    end
end
