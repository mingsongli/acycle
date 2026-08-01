function cleanup = ac_protect_coco_result_figures(figures)
%AC_PROTECT_COCO_RESULT_FIGURES Block result-window closure during saving.
%
% The original CloseRequestFcn is stored as figure appdata so the figure
% saver can remove this temporary guard from its immutable FIG snapshot.

originalCallbackKey = 'AcycleCOCOSaveOriginalCloseRequestFcn';
protectionKey = 'AcycleCOCOSaveCloseProtected';

figures = figures(:);
figures = figures(isgraphics(figures,'figure'));
protectedFigures = gobjects(0,1);
for figureIndex = 1:numel(figures)
    resultFigure = figures(figureIndex);
    if isappdata(resultFigure,protectionKey)
        continue
    end
    try
        setappdata(resultFigure,originalCallbackKey, ...
            get(resultFigure,'CloseRequestFcn'));
        setappdata(resultFigure,protectionKey,true);
        set(resultFigure,'CloseRequestFcn',@blockCloseRequest);
        protectedFigures(end+1,1) = resultFigure; %#ok<AGROW>
    catch
    end
end

cleanup = onCleanup(@()restoreCloseRequests( ...
    protectedFigures,originalCallbackKey,protectionKey));
end

function blockCloseRequest(~,~)
% The saving progress dialog explains why the close request is deferred.
end

function restoreCloseRequests(figures,originalCallbackKey,protectionKey)
for figureIndex = 1:numel(figures)
    resultFigure = figures(figureIndex);
    if ~isgraphics(resultFigure,'figure')
        continue
    end
    try
        if isappdata(resultFigure,originalCallbackKey)
            originalCallback = getappdata( ...
                resultFigure,originalCallbackKey);
            set(resultFigure,'CloseRequestFcn',originalCallback);
            rmappdata(resultFigure,originalCallbackKey);
        end
        if isappdata(resultFigure,protectionKey)
            rmappdata(resultFigure,protectionKey);
        end
    catch
    end
end
end
