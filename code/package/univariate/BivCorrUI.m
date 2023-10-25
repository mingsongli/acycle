function BivCorrUI

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
        if length(selectedData(:)) < 5
            return
        end
        
        [~, ncol] =size(selectedData);
        if ncol ~= 2
            warndlg('Warning: two columns in Data Table must be selected')
            return
        end

        stats = calculateStatistics(selectedData);
        
        % Look for an existing figure with the name 'sf'
        sf = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Correlation');
        % If no such figure exists, create a new one
        if isempty(sf)
            % Create a new figure for statistics
            sf = uifigure('Name', 'Acycle: Correlation', ...
                'Position', [100, 100, 360, 380],...
                'NumberTitle', 'off','MenuBar', 'none');
            set(sf,'units','norm') % set location
            set(sf,'Units','normalized') % set units as normalized
            
            % Create a uitable for statistics
            uit =  uitable(sf, 'Data', stats,...
                     'Units', 'normalized','FontSize', 12,...
                     'Position', [0.05, 0.05, 0.9, 0.9],...
                     'ColumnEditable', true, ...
                     'ColumnName', {'Statistic', 'Value'},...
                     'ColumnWidth', {130,140});
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
        % Pearson
        [R, P, RL, RU] = corrcoef(data); % R is the correlation matrix, and P is the matrix of p-values
        % Spearman
        [SpearmanRho, SpearmanPValue] = corr(data(:,1), data(:,2), 'Type', 'Spearman');
        % Kendall Tau
        [KendallTau, KendallPValue] = corr(data(:,1), data(:,2), 'Type', 'Kendall');

        stats = { 'Number (N)', sprintf('%8.0d', length(data)) ;
                  'Pearson r', sprintf('%10.6f', R(1,2));
                  'Pearson r 95% CI', sprintf('[%10.6f  %10.6f]', RL(1,2), RU(1,2));
                  'Pearson p', sprintf('%10.6f', P(1,2));
                  'Conclusion','';
                  '','';
                  'Spearman r',sprintf('%10.6f', SpearmanRho);
                  'Spearman p Value',sprintf('%10.6f', SpearmanPValue);
                  'Conclusion','';
                  '','';
                  'Kendall Tau',sprintf('%10.6f', KendallTau);
                  'Kendall p value',sprintf('%10.6f', KendallPValue);
                  'Conclusion',''};
        state1 = 'Corr. is significant';
        state2 = 'Corr. is not significant';
        if P(1,2) < 0.05
            stats{5,2} = state1;
        else
            stats{5,2} = state2;
        end
        if SpearmanPValue < 0.05
            stats{9,2} = state1;
        else
            stats{9,2} = state2;
        end
        if KendallPValue < 0.05
            stats{13,2} = state1;
        else
            stats{13,2} = state2;
        end
    end
end