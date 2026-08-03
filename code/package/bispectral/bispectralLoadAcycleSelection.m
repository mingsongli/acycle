function [data,dataPath,errorMessage] = ...
        bispectralLoadAcycleSelection(context,selectedName)
%BISPECTRALLOADACYCLESELECTION Resolve and load one Acycle list selection.
%   This adapter contains the bispectral-specific path, extension, and input
%   validation. The AC menu callback remains responsible only for selection
%   count, user-facing dialogs, and launching BISPECTRALGUI.

data = [];
dataPath = '';
if nargin < 1 || ~isstruct(context)
    context = struct();
end
if isstring(selectedName) && isscalar(selectedName)
    selectedName = char(selectedName);
end
if ~ischar(selectedName) || isempty(selectedName)
    errorMessage = 'The selected main-list entry has an invalid file name.';
    return
end

directory = bispectralAcycleDirectory(context);
dataPath = fullfile(directory,selectedName);
if isfolder(dataPath)
    errorMessage = 'The selected item is a folder, not a data file.';
    return
end
if exist(dataPath,'file') ~= 2
    errorMessage = {'The selected data file no longer exists.';dataPath};
    return
end

[~,~,extension] = fileparts(dataPath);
allowedExtensions = {'.txt','.csv','','.res','.dat','.out','.tab'};
if isfield(context,'filetype') && iscell(context.filetype)
    allowedExtensions = context.filetype;
end
if ~any(strcmpi(extension,allowedExtensions))
    errorMessage = 'Unsupported file type for Bispectral Analysis.';
    return
end

[data,errorMessage] = bispectralReadDataFile(dataPath);
end
