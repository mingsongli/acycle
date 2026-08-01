% refresh add color in the list box
%
d = dir; %get files
if numel(d) >= 2
    d(1:2) = [];
else
    d = [];
end
previousAddress = '';
try
    if isprop(handles.edit_acfigmain_dir,'String')
        previousAddress = get(handles.edit_acfigmain_dir,'String');
    elseif isprop(handles.edit_acfigmain_dir,'Value')
        previousAddress = handles.edit_acfigmain_dir.Value;
    end
    if iscell(previousAddress) && ~isempty(previousAddress)
        previousAddress = previousAddress{1};
    end
    if isstring(previousAddress) && isscalar(previousAddress)
        previousAddress = char(previousAddress);
    end
    if ~ischar(previousAddress)
        previousAddress = '';
    end
    previousAddress = strtrim(previousAddress);
catch
    previousAddress = '';
end

address = pwd;
if ispc
    preserveSelection = strcmpi(previousAddress,address);
else
    preserveSelection = strcmp(previousAddress,address);
end
% A user-triggered Refresh is an explicit selection reset. Automatic
% same-directory refreshes keep their existing by-filename restoration so
% sequential analyses can continue using the selected input conveniently.
if exist('ac_clear_main_list_selection_on_refresh','var') == 1 && ...
        islogical(ac_clear_main_list_selection_on_refresh) && ...
        isscalar(ac_clear_main_list_selection_on_refresh) && ...
        ac_clear_main_list_selection_on_refresh
    preserveSelection = false;
end
if isprop(handles.edit_acfigmain_dir,'String')
    set(handles.edit_acfigmain_dir,'String',address);
elseif isprop(handles.edit_acfigmain_dir,'Value')
    handles.edit_acfigmain_dir.Value = address;
end
% Save pwd outside the packaged CTF cache.
ac_working_directory('set',address);

% A row number is not stable when files are added or the sort order changes.
% Within the same directory the unified updater preserves existing files by
% name and returns their new rows; changing directory clears the selection.

if isempty(d)
    [~,selectedIndices] = ac_update_listbox_acmain( ...
        handles.listbox_acmain,{},false(0,1),preserveSelection);
    handles.index_selected = selectedIndices;
    handles.plot_selected = selectedIndices;
    guidata(handles.listbox_acmain,handles);
    return
end

sd = ac_sort_dir_entries(d,handles.val1);
names = {sd.name};
isDir = [sd.isdir];
[~,selectedIndices] = ac_update_listbox_acmain( ...
    handles.listbox_acmain,names,isDir,preserveSelection);
handles.index_selected = selectedIndices;
handles.plot_selected = selectedIndices;
guidata(handles.listbox_acmain,handles);
