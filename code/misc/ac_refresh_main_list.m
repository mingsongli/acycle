function refreshed = ac_refresh_main_list(listboxHandle,workingDirectory)
%AC_REFRESH_MAIN_LIST Refresh Acycle's main file list from a child GUI.
%
% Child apps do not have a local GUIDE-style "handles" variable, while
% refreshcolor.m is a script that requires one.  Recover the live handles
% from the main figure here and run the single authoritative refresh path.

refreshed = false;
if nargin < 1 || isempty(listboxHandle) || ~isgraphics(listboxHandle)
    return
end

mainFigure = ancestor(listboxHandle,'figure');
if isempty(mainFigure) || ~isgraphics(mainFigure)
    return
end
handles = guidata(mainFigure);
if isempty(handles) || ~isstruct(handles) || ...
        ~isfield(handles,'listbox_acmain') || ...
        ~isgraphics(handles.listbox_acmain)
    return
end

if nargin < 2 || isempty(workingDirectory)
    % Existing child refresh functions use dir/pwd at their call site.
    % Preserve that behavior (notably when Correlation saves beside a
    % target series outside the directory currently shown by AC).
    workingDirectory = pwd;
end
if ~isfolder(workingDirectory)
    workingDirectory = '';
    if isfield(handles,'edit_acfigmain_dir') && ...
            isgraphics(handles.edit_acfigmain_dir)
        try
            workingDirectory = get(handles.edit_acfigmain_dir,'String');
            if iscell(workingDirectory)
                workingDirectory = workingDirectory{1};
            end
            workingDirectory = char(workingDirectory);
        catch
            workingDirectory = '';
        end
    end
end
if isempty(workingDirectory) || ~isfolder(workingDirectory)
    try
        workingDirectory = ac_working_directory('get',pwd);
    catch
        workingDirectory = '';
    end
end
if isempty(workingDirectory) || ~isfolder(workingDirectory)
    return
end

previousDirectory = pwd;
directoryCleanup = onCleanup(@()cd(previousDirectory)); %#ok<NASGU>
try
    cd(workingDirectory);
    refreshed = true;
    refreshcolor;
    drawnow limitrate;
catch refreshError
    refreshed = false;
    warning('Acycle:MainListRefreshFailed', ...
        'Unable to refresh Acycle''s main file list: %s',refreshError.message);
end
end
