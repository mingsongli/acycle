function UniChi2GOFUI()

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
        
        tabcontent = ["Normal", ...
            "Beta", ...
            "Binomial", ...
            "Exponential",...
            "Extreme Value",...
            "Gamma",...
            "Kernel",...
            "Lognormal",...
            "Poisson",...
            "Rayleigh",...
            "Weibull"];
        % look for an existing figure with the name 'Acycle: Two Sample Tests'
        fig = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Two Sample Tests');
        
        % if no such uifigure
        stats = calculateStatistics(selectedData,'Normal');
        
        if isempty(fig)
            % Create the figure
            fig = uifigure('Name', 'Acycle: Two Sample Tests', 'Position',[100 100 400 400]);

            txt1 = uilabel(fig,...
                'Text','Select test distribution',...
                'Position',[20, 360, 160, 30]);
            % Create a uitable for statistics
            uit =  uitable(fig, 'Data', stats,...
                     'FontSize', 12,...
                     'Position', [20, 20, 360, 320],...
                     'ColumnEditable', true, ...
                     'ColumnName', {'Statistic', 'Value'},...
                     'ColumnWidth', {120,190});
            
            % Create the tab group
            uidrop1 = uidropdown(fig);
            uidrop1.Position = [180 360 200 30];
            uidrop1.ValueChangedFcn = @uidropValueChanged;
            uidrop1.Items = tabcontent;
            
        else
            figure(fig)
        end
    else
        warning('The Acycle: Data Table does not exist or has not been created yet.');
    end
    
    function uidropValueChanged(src,event)
        uiFig1 = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');
        data = uiFig1.UserData;
        val = src.Value;
        stats = calculateStatistics(data,val);
        uit.Data = stats;
    end

% Function to calculate statistics
    function stats = calculateStatistics(data,val)
        
        data = data(:);  % force to a vector
        data = data(~isnan(data)); % remove empty cell
        
        assignin('base','data',selectedData);
        if ismember(val, ["Weibull","Lognormal","Binomial"])
            try
                pd = fitdist(data,val);
            catch
                warndlg('Warning: Have to add a constant to make all the data positive')
                data = data + abs(min(data)) + eps;  % ensure data is >= 0
            end
        elseif strcmp(val, "Beta")
            try 
                pd = fitdist(data,val);
            catch
                warndlg('Warning: Have to normalize the data to the [0,1] interval')
                data = (data - min(data)) / (max(data) - min(data));
            end
        elseif ismember(val, ["Exponential", "Gamma", "Poisson"])
            try 
                pd = fitdist(data,val);
            catch
                warndlg('Warning: Have to add a constant to make all the data >= 0')
                data = data + abs(min(data));
            end
        end
        
        if ismember(val, ["Binomial"])
            data_discrete = round(data);
            N = max(data_discrete);
            binomialDist = fitdist(data_discrete, 'Binomial', 'N', N);
            [h,p,st] = chi2gof(data_discrete, 'CDF', binomialDist);
        else
            pd = fitdist(data,val);
            [h,p,st] = chi2gof(data,'CDF',pd);
        end
        
        stats = { 'Number (N)', sprintf('%10.0d',length(data)) ;
                  'Min', sprintf('%10.6f',min(data)) ;
                  'Max', sprintf('%10.6f',max(data));
                  'Mean', sprintf('%10.6f',mean(data));
                  'Median', sprintf('%10.6f',median(data));
                  '',''
                  'Chi2 statistic', sprintf('%10.6f',st.chi2stat);
                  'Degree of freedom',sprintf('%10.0d', st.df);
                  'p value',sprintf('%10.6f',p);
                  'Conclusion',''};
              if h == 0
                  stats{10,2} = ['',val,' distribution'];
              else
                  stats{10,2} = ['Not ',val,' distribution'];
              end
    end
end