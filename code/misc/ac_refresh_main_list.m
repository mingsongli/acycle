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

hasExplicitDirectory = nargin >= 2 && ~isempty(workingDirectory);
if hasExplicitDirectory
    workingDirectory = ac_normalize_refresh_directory(workingDirectory);
    if isempty(workingDirectory) || ~isfolder(workingDirectory)
        warning('Acycle:MainListRefreshInvalidDirectory', ...
            'Unable to refresh Acycle''s main file list: invalid directory.');
        return
    end
else
    % A child GUI may temporarily change MATLAB's pwd while computing or
    % exporting.  The address shown by the main browser is authoritative.
    workingDirectory = ac_main_browser_directory(handles);
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
    refreshcolor;
    if ~ac_main_list_is_consistent(handles.listbox_acmain)
        error('Acycle:MainListRefreshInconsistent', ...
            'The refreshed file list and selection state are inconsistent.');
    end
    drawnow limitrate;
    refreshed = true;
catch refreshError
    refreshed = false;
    warning('Acycle:MainListRefreshFailed', ...
        'Unable to refresh Acycle''s main file list: %s',refreshError.message);
end
end

function workingDirectory = ac_main_browser_directory(handles)
workingDirectory = '';
if ~isfield(handles,'edit_acfigmain_dir') || ...
        ~isgraphics(handles.edit_acfigmain_dir)
    return
end
try
    if isprop(handles.edit_acfigmain_dir,'String')
        rawDirectory = get(handles.edit_acfigmain_dir,'String');
    elseif isprop(handles.edit_acfigmain_dir,'Value')
        rawDirectory = handles.edit_acfigmain_dir.Value;
    else
        rawDirectory = '';
    end
    workingDirectory = ac_normalize_refresh_directory(rawDirectory);
catch
    workingDirectory = '';
end
end

function directory = ac_normalize_refresh_directory(directory)
if iscell(directory) && ~isempty(directory)
    directory = directory{1};
end
if isstring(directory) && isscalar(directory)
    directory = char(directory);
end
if ~ischar(directory)
    directory = '';
    return
end
directory = strtrim(directory);
end

function consistent = ac_main_list_is_consistent(listboxHandle)
consistent = false;
try
    [nativeNames,nativeSelection,nativeIsValid] = ...
        ac_native_refresh_state(listboxHandle);
    if ~nativeIsValid
        return
    end

    userdata = get(listboxHandle,'UserData');
    if ~isstruct(userdata) || ~isfield(userdata,'names')
        return
    end
    storedNames = cellstr(userdata.names);
    if ~isequal(storedNames(:),nativeNames)
        return
    end

    if isappdata(listboxHandle,'ACListNames')
        drawnNames = cellstr(getappdata(listboxHandle,'ACListNames'));
        if ~isequal(drawnNames(:),nativeNames)
            return
        end
        drawnSelection = getappdata(listboxHandle,'ACListSelected');
        if ~ac_valid_refresh_indices(drawnSelection,numel(nativeNames))
            return
        end
        drawnSelection = double(drawnSelection(:)');
        if ~isequal(drawnSelection,nativeSelection)
            return
        end
    end

    mainFigure = ancestor(listboxHandle,'figure');
    liveHandles = guidata(mainFigure);
    if ~isstruct(liveHandles) || ...
            ~isfield(liveHandles,'index_selected') || ...
            ~ac_valid_refresh_indices( ...
                liveHandles.index_selected,numel(nativeNames)) || ...
            ~isequal(double(liveHandles.index_selected(:)'),nativeSelection)
        return
    end
    if isfield(liveHandles,'plot_selected') && ...
            (~ac_valid_refresh_indices( ...
                liveHandles.plot_selected,numel(nativeNames)) || ...
            ~isequal(double(liveHandles.plot_selected(:)'),nativeSelection))
        return
    end
    consistent = true;
catch
    consistent = false;
end
end

function [names,selected,isValid] = ac_native_refresh_state(listboxHandle)
names = {};
selected = [];
isValid = false;
try
    if isprop(listboxHandle,'Items')
        names = ac_refresh_names(listboxHandle.Items);
        rawValue = listboxHandle.Value;
        if isempty(rawValue)
            selected = [];
        else
            valueNames = ac_refresh_names(rawValue);
            [isPresent,selected] = ismember(valueNames,names);
            if ~all(isPresent)
                selected = [];
                return
            end
        end
    else
        names = ac_refresh_names(get(listboxHandle,'String'));
        selected = get(listboxHandle,'Value');
        if ~ac_valid_refresh_indices(selected,numel(names))
            selected = [];
            return
        end
    end
    % Normalize both nonempty and empty selections to the same row shape so
    % consistency checks do not distinguish 0x0 from 1x0 empty arrays.
    selected = double(selected(:)');
    isValid = true;
catch
    names = {};
    selected = [];
    isValid = false;
end
end

function names = ac_refresh_names(value)
if isempty(value)
    names = {};
elseif ischar(value)
    names = cellstr(value);
elseif isstring(value)
    names = cellstr(value(:));
elseif iscell(value)
    names = cellfun(@char,value(:),'UniformOutput',false);
else
    names = cellstr(string(value(:)));
end
names = names(:);
end

function valid = ac_valid_refresh_indices(indices,count)
valid = isnumeric(indices) && isreal(indices);
if valid
    indices = double(indices(:)');
    valid = all(isfinite(indices)) && ...
        all(indices == fix(indices)) && ...
        all(indices >= 1) && all(indices <= count) && ...
        numel(unique(indices)) == numel(indices);
end
end
