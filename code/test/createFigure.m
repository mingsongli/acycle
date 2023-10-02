function createFigure()
    % Create figure and tabs
    fig = figure('Name', 'Acycle: Model Linear');
    tabs = uitabgroup(fig);
    tab1 = uitab(tabs, 'Title', 'Settings');
    tab2 = uitab(tabs, 'Title', 'Statistics');
    tab3 = uitab(tabs, 'Title', 'ANOVA');
    
    % Settings tab
    axesTab1 = axes('Parent', tab1, 'Position', [0.1 0.1 0.4 0.8]);
    x = 1:20;
    x = x';
    rng(0); % Set random seed for reproducibility
    y = rand(20, 1) + 0.05 * x;
    scatter(axesTab1, x, y);
    
    panelSettings = uipanel('Parent', tab1, 'Position', [0.6 0.1 0.35 0.8], 'Title', 'Settings');
    panelMethod = uipanel('Parent', panelSettings, 'Position', [0.1 0.6 0.8 0.3], 'Title', 'Method');
    panelParameters = uipanel('Parent', panelSettings, 'Position', [0.1 0.1 0.8 0.4], 'Title', 'Parameters');
    
    radioOrdinaryLS = uicontrol('Parent', panelMethod, 'Style', 'radiobutton', 'String', 'Ordinary LS', ...
        'Units', 'normalized', 'Position', [0.1 0.6 0.8 0.3], 'Value', 1, 'Callback', @refreshFigure);
    radioRMA = uicontrol('Parent', panelMethod, 'Style', 'radiobutton', 'String', 'RMA', ...
        'Units', 'normalized', 'Position', [0.1 0.3 0.8 0.3], 'Value', 0, 'Callback', @refreshFigure);
    radioMA = uicontrol('Parent', panelMethod, 'Style', 'radiobutton', 'String', 'MA', ...
        'Units', 'normalized', 'Position', [0.1 0.0 0.8 0.3], 'Value', 0, 'Callback', @refreshFigure);
    radioRobust = uicontrol('Parent', panelMethod, 'Style', 'radiobutton', 'String', 'Robust', ...
        'Units', 'normalized', 'Position', [0.1 -0.3 0.8 0.3], 'Value', 0, 'Callback', @refreshFigure);
    
    checkboxRegression = uicontrol('Parent', panelParameters, 'Style', 'checkbox', 'String', '95% regression', ...
        'Units', 'normalized', 'Position', [0.1 0.6 0.8 0.3], 'Value', 1, 'Callback', @refreshFigure);
    checkboxBootstrap = uicontrol('Parent', panelParameters, 'Style', 'checkbox', 'String', '95% bootstrap', ...
        'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.3], 'Value', 1, 'Callback', @refreshFigure);
    
    % Statistics tab
    editStatistics = uicontrol('Parent', tab2, 'Style', 'edit', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
    
    % ANOVA tab
    editANOVA = uicontrol('Parent', tab3, 'Style', 'edit', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
    
    % Refresh figure function
    function refreshFigure(~, ~)
        % Clear axes
        cla(axesTab1);
        
        % Read data
        x = 1:20;
        x = x';
        rng(0); % Set random seed for reproducibility
        y = rand(20, 1) + 0.05 * x;
        
        % Perform linear regression based on selected method
        if get(radioOrdinaryLS, 'Value')
            method = 'Ordinary LS';
            mdl = fitlm(x, y);
        elseif get(radioRMA, 'Value')
            method = 'RMA';
            mdl = fitlm(x, y);
        elseif get(radioMA, 'Value')
            method = 'MA';
            mdl = fitlm(x, y);
        elseif get(radioRobust, 'Value')
            method = 'Robust';
            mdl = fitlm(x, y);
        end
        
        % Perform error estimation
        if get(checkboxRegression, 'Value')
            regressionEst = mdl.coefCI;
        else
            regressionEst = [];
        end
        
        if get(checkboxBootstrap, 'Value')
            bootstrapEst = bootci(2000, @(bootX, bootY) fitlm(bootX, bootY), x, y);
        else
            bootstrapEst = [];
        end
        
        % Plot scatter and fitted line
        scatter(axesTab1, x, y, 'k');
        hold(axesTab1, 'on');
        plot(axesTab1, mdl);
        
        % Plot error lines
        if ~isempty(regressionEst)
            plotErrorLines(axesTab1, mdl, regressionEst, 'r');
        end
        
        if ~isempty(bootstrapEst)
            plotErrorLines(axesTab1, mdl, bootstrapEst, 'r--');
        end
        
        hold(axesTab1, 'off');
        
        % Update statistics tab
        updateStatistics();
        
        % Update ANOVA tab
        updateANOVA();
    end

    % Plot error lines
    function plotErrorLines(axesHandle, mdl, est, lineStyle)
        slope = est(2, :);
        intercept = est(1, :);
        xRange = xlim(axesHandle);
        yRange = intercept + slope * xRange;
        line(axesHandle, xRange, yRange, 'LineStyle', lineStyle, 'Color', 'r');
    end

    % Update statistics tab
    function updateStatistics()
        if get(tab2, 'Value')
            stats = mdl.Coefficients;
            slope = stats.Estimate(2);
            slopeStdErr = stats.SE(2);
            intercept = stats.Estimate(1);
            interceptStdErr = stats.SE(1);
            
            str = sprintf('Slope: %.4f (SE: %.4f)\n', slope, slopeStdErr);
            str = [str sprintf('Intercept: %.4f (SE: %.4f)\n', intercept, interceptStdErr)];
            
            if ~isempty(bootstrapEst)
                str = [str 'Bootstrap confidence intervals:\n'];
                str = [str sprintf('Slope: [%.4f, %.4f]\n', bootstrapEst(2, 1), bootstrapEst(2, 2))];
                str = [str sprintf('Intercept: [%.4f, %.4f]\n', bootstrapEst(1, 1), bootstrapEst(1, 2))];
            end
            
            r = mdl.Rsquared.Ordinary;
            rSquared = r^2;
            t = stats.Coefficients.tStat(2);
            p = stats.Coefficients.pValue(2);
            
            str = [str sprintf('\nCorrelation:\n')];
            str = [str sprintf('R: %.4f\n', r)];
            str = [str sprintf('R^2: %.4f\n', rSquared)];
            str = [str sprintf('t-value: %.4f\n', t)];
            str = [str sprintf('p-value: %.4f\n', p)];
            
            set(editStatistics, 'String', str);
        end
    end

    % Update ANOVA tab
    function updateANOVA()
        if get(tab3, 'Value')
            anova = mdl.anova;
            
            regressionSS = anova.SumSq(2);
            regressionDF = anova.DF(2);
            regressionMS = anova.MeanSq(2);
            regressionF = anova.F(2);
            regressionP = anova.pValue(2);
            
            residualSS = anova.SumSq(3);
            residualDF = anova.DF(3);
            residualMS = anova.MeanSq(3);
            
            totalSS = anova.SumSq(1);
            
            str = sprintf('Regression:\n');
            str = [str sprintf('SS: %.4f\n', regressionSS)];
            str = [str sprintf('DF: %.0f\n', regressionDF)];
            str = [str sprintf('MS: %.4f\n', regressionMS)];
            str = [str sprintf('F: %.4f\n', regressionF)];
            str = [str sprintf('p-value: %.4f\n', regressionP)];
            str = [str sprintf('\nResidual:\n')];
            str = [str sprintf('SS: %.4f\n', residualSS)];
            str = [str sprintf('DF: %.0f\n', residualDF)];
            str = [str sprintf('MS: %.4f\n', residualMS)];
            str = [str sprintf('\nTotal:\n')];
            str = [str sprintf('SS: %.4f\n', totalSS)];
            
            set(editANOVA, 'String', str);
        end
    end

end
