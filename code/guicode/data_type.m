classdef data_type < matlab.apps.AppBase
    % App Designer style replacement for legacy GUIDE data_type dialog.

    properties (Access = public)
        UIFigure      matlab.ui.Figure
        MainGrid      matlab.ui.container.GridLayout
        TitleLabel    matlab.ui.control.Label
        BodyTextArea  matlab.ui.control.TextArea
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure( ...
                'Name', 'data_type', ...
                'Position', [180 180 700 420], ...
                'Color', [1 1 1]);

            app.MainGrid = uigridlayout(app.UIFigure, [2 1]);
            app.MainGrid.RowHeight = {'fit', '1x'};
            app.MainGrid.ColumnWidth = {'1x'};
            app.MainGrid.Padding = [26 20 26 20];
            app.MainGrid.RowSpacing = 10;

            app.TitleLabel = uilabel(app.MainGrid, ...
                'Text', 'Warning: no data exist!', ...
                'FontSize', 14, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left');
            app.TitleLabel.Layout.Row = 1;

            bodyLines = {
                'Load a 2-column data in MatLab Workspace';
                'Input data format';
                'Name:    data';
                'Length:  m x 2     % must be a 2-column dataset';
                'Column 1:  time;     unit must be in ka;';
                'Column 2:  value';
                'Notes:';
                '#1: Proxy data is assumed to be sensitive to water-depth related noise.';
                '#2: There is no requirement for interpolation, normalization, or';
                '      pre-Whitening of the dataset.';
                '#3: Extreme values should be removed.';
                '#4: Both increasing-upward and decreasing-upward time series are';
                '      okay for the model.'
                };

            app.BodyTextArea = uitextarea(app.MainGrid, ...
                'Value', bodyLines, ...
                'Editable', 'off', ...
                'FontSize', 12, ...
                'BackgroundColor', [1 1 1]);
            app.BodyTextArea.Layout.Row = 2;
        end
    end

    methods (Access = public)
        function app = data_type(varargin)
            %#ok<INUSD> Keep compatibility with legacy call signatures.
            app.createComponents();
            registerApp(app, app.UIFigure);

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end
end
