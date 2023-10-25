function ANOVAUI

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
        if ncol < 2
            warndlg('Warning: at least two columns in Data Table must be selected')
            return
        end
        
        tabcontent = {
            'One-way ANOVA', ...
            'Two-way ANOVA', ...
            'N-way ANOVA'};
        nn = 1;
        % look for an existing figure with the name 'Acycle: Two Sample Tests'
        fig = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Analysis of variance (ANOVA) Tests');
        % if no such uifigure
        
        if isempty(fig)
            % Create the figure
            fig = uifigure('Name', 'Acycle: Analysis of variance (ANOVA) Tests', 'Position',[100 100 800 400]);
            
            % Create the tab group
            tabGroup = uitabgroup(fig);
            tabGroup.Position = [20 20 760 370];
            tabGroup.SelectionChangedFcn = @tabChangedCallback;
            
            % Create tabs
            tabs = gobjects(1, nn);  % Preallocate the array for tabs
            
            for i = 1:nn
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
    
    fig = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Analysis of variance (ANOVA) Tests');
    
    multilineText = {''};
    % Create a textarea to display the text
    txt = uitextarea(fig,...
        'Position', [20, 20, 760, 345],... % Position and size of the text area
        'Value', multilineText,...         % Set the multiline text
        'FontSize', 14,...                 % Set font size
        'Editable', 'off',...              % Make it read-only; text can be selected but not changed
        'HorizontalAlignment', 'Left',...  % Optional: Set horizontal alignment
        'BackgroundColor', 'w');  
    
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
    
    %% tabIndex 1: one-way anova
    if tabIndex == 1
        % Perform the ANOVA
        
        [n, m] = size(selectedData);
        dof1 = m-1;
        % mean
        mean_selectedData = mean(selectedData);
        % variance
        v = var(selectedData);
        % lump all the samples
        d13 = selectedData(:);
        % variance of all samples
        d13cv = var(d13);
        % mean of all samples
        d13m = mean(d13);
        % total samples
        N = length(d13);
        dof3 = N - 1;

        % Total sum of squares
        SST = dof3 * d13cv;

        % Sum of squares within
        SSE = sum(v * (n-1));
        dof2 = N - m;
        MSE = SSE/(N-m);

        % Sum of squares among rocks
        l1 = sum(selectedData).^2/n;
        l2 = sum(d13)^2/N;
        SSA = sum(l1)-l2;
        MSA = SSA / (m - 1);

        % table
        Summary = {'among';'within';'total'};
        SumOfSquares = [SSA;SSE;SST];
        dof = [dof1; dof2; dof3];
        variance=[MSA; MSE; d13cv];

        % Create a table
        T = table(Summary,SumOfSquares,dof,variance);

        % F ratio
        F = MSA/MSE;
        % disp(['F value = ', num2str(F)])
        alpha = 0.05;
        p = 1 - alpha;
        % Reference
        X = finv(p,dof1,dof2);   
        %disp(['p = ', num2str(alpha),'; dof1 = ', num2str(dof1),'; dof2 = '...
        %    ,num2str(dof2), '; Reference = ', num2str(X)])
        %disp(' ')
        %
        PF = fcdf(F,dof1,dof2);
        %disp(['Confidence level is ',num2str(PF*100),' %'])
        % display
        if F > X
            h = 1;
            disp('h = 1, rejects the null hypothesis: all the same');
            disp('       accepts the alternative hypothesis: at least one mean is different');
        else
            h = 0;
            disp('h = 0, accepts the null hypothesis: all the same');
            disp('       rejects the alternative hypothesis: at least one mean is different');
        end

        
        multilineText = {
            ''
            'One-way analysis of variance (ANOVA) test for equal means'
            ''
            '                SumOfSquares    DF     Variance         F           pValue'
            '               --------------  ----   ----------       ---         --------'
            [' Between groups: ', sprintf('%10.6f', SSA),' ', ...
                sprintf('%5.0d', dof1),'    ', sprintf('%10.5f', MSA),'    ',  ...
            sprintf('%10.6f', F),'    ',sprintf('%10.6f', PF)]
            ['  Within groups: ', sprintf('%10.6f', SSE),' ', ...
                sprintf('%5.0d', dof2),'    ', sprintf('%10.5f', MSE)]
            ['          Total: ', sprintf('%10.6f', SST),' ', ...
                sprintf('%5.0d', dof3),'    ', sprintf('%10.5f', d13cv)]
            ''
            'CONCLUSION:'
            ''
            ['Critical F ratio (p = 0.05): ', sprintf('%10.5f', X)]
            ['           Confidence level: ', sprintf('%10.5f', PF*100) ,'%']
            ''
            ''
        }; 
            % Define the text with multiple lines
            if h == 1
                multilineText{15,1} = 'Reject the null hypothesis (equal means) at the 5% significance level.';
            else
                multilineText{15,1} = 'Accept the null hypothesis (equal means) at the 5% significance level.';
            end
        
    else
        multilineText = {''};
        disp('to be done')
        txt.Value = multilineText;
        
    end
    
    
    % Create a textarea to display the text
    txt = uitextarea(fig,...
        'Position', [20, 20, 760, 345],... % Position and size of the text area
        'Value', multilineText,...         % Set the multiline text
        'FontSize', 14,...                 % Set font size
        'Editable', 'off',...              % Make it read-only; text can be selected but not changed
        'HorizontalAlignment', 'Left',...  % Optional: Set horizontal alignment
        'BackgroundColor', 'w');  
    try 
        txt.FontName = 'Courier'; 
    catch
    end
end
