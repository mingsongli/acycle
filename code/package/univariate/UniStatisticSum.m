function UniStatisticSum(varargin)

    % Retrieve the instance of the first figure by its name
    uiFig1 = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');
    
    if ~isempty(uiFig1)
        
        % Retrieve the data stored in the first figure
        selectedData = uiFig1.UserData;
        stats = calculateStatistics(selectedData);
        
        % Look for an existing figure with the name 'sf'
        sf = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Statistics Summary');
        % If no such figure exists, create a new one
        if isempty(sf)
            % Create a new figure for statistics
            sf = uifigure('Name', 'Acycle: Statistics Summary', ...
                'Position', [100, 100, 340, 500],...
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
            uit.Data = stats;
            
        end
    else
        warning('The original figure does not exist or has not been created yet.');
    end

    % Function to calculate statistics
    function stats = calculateStatistics(data)
        data = data(:);  % force
        data = data(~isnan(data)); % remove empty cell
        stats = { 'Number (N)', sprintf('%10.0d', length(data)) ;
                  'Min', sprintf('%10.6f', min(data));
                  'Max', sprintf('%10.6f', max(data));
                  'Sum', sprintf('%10.6f', sum(data));
                  'Mean', sprintf('%10.6f', mean(data));
                  'Variance', sprintf('%10.6f', var(data));
                  'Standard Deviation', sprintf('%10.6f', std(data));
                  'Median', sprintf('%10.6f', median(data));
                  ' 2.5th Percentile', sprintf('%10.6f', prctile(data, 2.5));
                  '   5th Percentile', sprintf('%10.6f', prctile(data, 5));
                  '  25th Percentile', sprintf('%10.6f', quantile(data, 0.25));
                  '  75th Percentile', sprintf('%10.6f', quantile(data, 0.75));
                  '  95th Percentile', sprintf('%10.6f', prctile(data, 95));
                  '97.5th Percentile', sprintf('%10.6f', prctile(data, 97.5));
                  'Mode', sprintf('%10.6f', mode(data));
                  'Skewness', sprintf('%10.6f', skewness(data));
                  'Kurtosis', sprintf('%10.6f', kurtosis(data))};
    end
end