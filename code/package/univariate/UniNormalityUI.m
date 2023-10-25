function UniNormalityUI

    % Retrieve the instance of the first figure by its name
    uiFig1 = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');
    
    
    if ~isempty(uiFig1)
        
        % Retrieve the data stored in the first figure
        selectedData = uiFig1.UserData;
        stats = calculateStatistics(selectedData);
        
        % Look for an existing figure with the name 'sf'
        sf = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Normality Tests');
        % If no such figure exists, create a new one
        if isempty(sf)
            % Create a new figure for statistics
            sf = uifigure('Name', 'Acycle: Normality Tests', ...
                'Position', [100, 100, 330, 660],...
                'NumberTitle', 'off','MenuBar', 'none');
            set(sf,'units','norm') % set location
            set(sf,'Units','normalized') % set units as normalized
            
            % Create a uitable for statistics
            uit =  uitable(sf, 'Data', stats,...
                     'Units', 'normalized','FontSize', 12,...
                     'Position', [0.05, 0.05, 0.9, 0.9],...
                     'ColumnEditable', true, ...
                     'ColumnName', {'Statistic', 'Value'},...
                     'ColumnWidth', {130,120});
        else
            
            figure(sf)
            stats = calculateStatistics(selectedData);
            uit.Data = stats; 
            
        end
    else
        warning('The original figure does not exist or has not been created yet.');
    end
    
    % Function to calculate statistics
    function stats = calculateStatistics(data)
        
        data = data(:);  % force
        data = data(~isnan(data)); % remove empty cell
        alpha = 0.05;
        % Shapiro-Wilk parametric hypothesis test
        [H, pValue, W] = swtest(data, alpha);
        % Lilliefors test
        [h,p,kstat,critval] = lillietest(data);
        % Anderson-Darling Test
        [ha,pa,adstata,cva] = adtest(data);
        % Kolmogorov-Smirnov Test
        % kstest tests for a standard normal distribution by default
        [hk,pk,ksstat,cvk] = kstest(zscore(data));
        
        % Chi-square test
        [hc, pc, statsc] = chi2gof(data);

        stats = { 'Number (N)', sprintf('%5.0d', length(data)) ;
                  'Shapiro-Wilk', sprintf('%10.6f', W) ;
                  'p value', sprintf('%10.6f', pValue);
                  'Conclusion', '';
                  '','';
                  'Lilliefors',sprintf('%10.6f', kstat);
                  'Critical Value',sprintf('%10.6f', critval);
                  'p value', sprintf('%10.6f', p);
                  'Conclusion','';
                  '','';
                  'Anderson-Darling',sprintf('%10.6f', adstata);
                  'Critical Value',sprintf('%10.6f', cva);
                  'p value',sprintf('%10.6f', pa);
                  'Conclusion','';
                  '','';
                  'Kolmogorov-Smirnov',sprintf('%10.6f', ksstat);
                  'Critical Value',sprintf('%10.6f', cvk);
                  'p value',sprintf('%10.6f', pk);
                  'Conclusion','';
                  '','';
                  'Chi-square goodness-of-fit',sprintf('%10.6f', statsc.chi2stat) ;
                  'degree of freedom',sprintf('%10.0d', statsc.df) ;
                  'p value', sprintf('%10.6f', pc);
                  'Conclusion',''};
              
        state1 = 'Normal distribution';
        state0 = 'Not normal';
        if H == 0
            stats{4,2} = state1;
        else
            stats{4,2} = state0;
        end
        if h == 0
            stats{9,2} = state1;
        else
            stats{9,2} = state0;
        end
        if ha == 0
            stats{14,2} = state1;
        else
            stats{14,2} = state0;
        end
        
        if hk == 0
            stats{19,2} = state1;
        else
            stats{19,2} = state0;
        end
        
        if hc == 0
            stats{24,2} = state1;
        else
            stats{24,2} = state0;
        end
    end
end