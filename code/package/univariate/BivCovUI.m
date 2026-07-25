function BivCovUI

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
        sf = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Covariance');
        % If no such figure exists, create a new one
        if isempty(sf)
            % Create a new figure for statistics
            sf = uifigure('Name', 'Acycle: Covariance', ...
                'Position', [100, 100, 360, 180],...
                'NumberTitle', 'off','MenuBar', 'none');
            set(sf,'units','norm') % set location
            set(sf,'Units','normalized') % set units as normalized

            txt1 = uilabel(sf,...
                'Text','Bootstrap Number',...
                'Position',[20, 125, 140, 30]);

            edit1 = uieditfield(sf,"Value",'10000',...
                'Position',[160 125 80 30]);

            b1 = uibutton(sf, "Text",'OK','Position',[260 125 80 30],...
                "ButtonPushedFcn",@calculateb);
            
            % Create a uitable for statistics
            uit =  uitable(sf, 'Data', stats,...
                     'FontSize', 12,...
                     'Position', [20, 20, 320, 100],...
                     'ColumnEditable', true, ...
                     'ColumnName', {'Statistic', 'Value'},...
                     'ColumnWidth', {120,150});
            
        else
            
            figure(sf)
            stats = calculateStatistics(selectedData);
            uit.Data = stats; 
            
        end
    else
        warning('The original figure does not exist or has not been created yet.');
    end

    function calculateb(~,~)
        stats = calculateStatistics(selectedData);
        uit.Data = stats; 
    end
    
    % Function to calculate statistics
    function stats = calculateStatistics(data)
        % covariance
        c = cov(data); % c
        try
            n_bootstraps = str2double(edit1.Value);
        catch
            n_bootstraps = 10000;
        end
        if n_bootstraps < 100 || isnan(n_bootstraps)
            warndlg('Error: Input is not a valid number or < 100. Now use 10000.')
            n_bootstraps = 10000;
            edit1.Value = '10000';
        end
        alpha = 0.05;
        cov_bootstraps = zeros(n_bootstraps, 1); % pre-allocate for speed
        
        for i = 1:n_bootstraps
            sample_indices = randi([1, size(data, 1)], size(data, 1), 1);
            bootstrap_sample = data(sample_indices, :);
            cov_matrix = cov(bootstrap_sample(:, 1), bootstrap_sample(:, 2));
            cov_bootstraps(i) = cov_matrix(1,2); % store the covariance value, not the matrix
        end
        
        % Calculate confidence interval
        CI_lower = prctile(cov_bootstraps, 100 * (alpha / 2));
        CI_upper = prctile(cov_bootstraps, 100 * (1 - alpha / 2));
        
        CI = [CI_lower, CI_upper]; 

        stats = { 'Number (N)', sprintf('%8.0d', length(data)) ;
                  'Covariance', sprintf('%10.6f', c(1,2));
                  '95% CI', sprintf('[%10.6f  %10.6f]', CI_lower, CI_upper)};
    end
end