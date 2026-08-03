function [directory,source] = bispectralAcycleDirectory(context)
%BISPECTRALACYCLEDIRECTORY Resolve the directory shown by Acycle.
%   DIRECTORY = BISPECTRALACYCLEDIRECTORY(CONTEXT) prefers the live main-
%   window address bar. Acycle's saved working directory and MATLAB's current
%   directory are used only when the live control is unavailable or invalid.

if nargin < 1 || ~isstruct(context)
    context = struct();
end

directory = liveBrowserDirectory(context);
source = 'live browser';
if isempty(directory)
    source = 'saved Acycle directory';
    try
        directory = ac_working_directory('get',pwd);
    catch
        directory = '';
    end
end
if isstring(directory) && isscalar(directory)
    directory = char(directory);
end
if ~ischar(directory) || ~isfolder(directory)
    directory = pwd;
    source = 'MATLAB current directory';
end
end

function directory = liveBrowserDirectory(context)
directory = '';
try
    if ~isfield(context,'edit_acfigmain_dir') || ...
            ~isgraphics(context.edit_acfigmain_dir)
        return
    end
    addressControl = context.edit_acfigmain_dir;
    if isprop(addressControl,'String')
        rawDirectory = get(addressControl,'String');
    elseif isprop(addressControl,'Value')
        rawDirectory = addressControl.Value;
    else
        return
    end
    if iscell(rawDirectory) && ~isempty(rawDirectory)
        rawDirectory = rawDirectory{1};
    end
    if isstring(rawDirectory) && isscalar(rawDirectory)
        rawDirectory = char(rawDirectory);
    end
    if ischar(rawDirectory)
        rawDirectory = strtrim(rawDirectory);
        if isfolder(rawDirectory)
            directory = rawDirectory;
        end
    end
catch
    directory = '';
end
end
