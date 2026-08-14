function dynotCloseProgressWindow(source,cancellationRequested)
%DYNOTCLOSEPROGRESSWINDOW Reliably dispose of the DYNOT waitbar.
%   WAITBAR installs CreateCancelBtn as the figure CloseRequestFcn. Calling
%   CLOSE therefore requests cancellation but does not delete the figure.
%   This helper uses DELETE so both normal completion and the window close
%   button actually dispose of the modal progress window.

if nargin < 2
    cancellationRequested = false;
end

fig = [];
if ~isempty(source) && isgraphics(source)
    if isgraphics(source,'figure')
        fig = source;
    else
        fig = ancestor(source,'figure');
    end
end
if isempty(fig) || ~isgraphics(fig,'figure')
    return
end

if isscalar(cancellationRequested) && logical(cancellationRequested)
    setappdata(fig,'canceling',true);
end
delete(fig);
end
