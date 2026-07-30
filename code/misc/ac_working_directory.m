function output = ac_working_directory(action,varargin)
%AC_WORKING_DIRECTORY Persist the main browser folder outside the CTF cache.
%
% output = ac_working_directory('get',fallbackDirectory,statePath)
% saved = ac_working_directory('set',directory,statePath)
% statePath = ac_working_directory('path')

if nargin < 1 || ~(ischar(action) || (isstring(action) && isscalar(action)))
    error('Acycle:WorkingDirectory:InvalidAction', ...
        'A working-directory action is required.');
end

action = lower(strtrim(char(action)));
switch action
    case 'get'
        fallbackDirectory = '';
        if ~isempty(varargin)
            fallbackDirectory = ac_normalize_directory(varargin{1});
        end
        statePath = ac_state_path(varargin,2);
        output = ac_read_saved_directory(statePath);
        hasExplicitStatePath = numel(varargin) >= 2 && ~isempty(varargin{2});
        if isempty(output) && ~isdeployed && ~hasExplicitStatePath
            output = ac_read_legacy_directory();
        end
        if isempty(output)
            output = ac_default_directory(fallbackDirectory);
        end
    case 'set'
        if isempty(varargin)
            error('Acycle:WorkingDirectory:MissingDirectory', ...
                'A directory is required.');
        end
        directory = ac_normalize_directory(varargin{1});
        if isempty(directory) || ~isfolder(directory)
            output = false;
            return
        end
        statePath = ac_state_path(varargin,2);
        output = ac_write_saved_directory(statePath,directory);
    case 'path'
        output = ac_default_state_path();
    otherwise
        error('Acycle:WorkingDirectory:UnknownAction', ...
            'Unknown working-directory action: %s',action);
end
end

function statePath = ac_state_path(arguments,index)
if numel(arguments) >= index && ~isempty(arguments{index})
    statePath = arguments{index};
    if isstring(statePath) && isscalar(statePath)
        statePath = char(statePath);
    end
    if ~ischar(statePath) || isempty(strtrim(statePath))
        error('Acycle:WorkingDirectory:InvalidStatePath', ...
            'The state path must be a nonempty character vector.');
    end
else
    statePath = ac_default_state_path();
end
end

function statePath = ac_default_state_path()
try
    settingsDirectory = fileparts(ac_user_settings('path'));
catch
    settingsDirectory = fullfile(prefdir,'Acycle');
end
statePath = fullfile(settingsDirectory,'ac_pwd.txt');
end

function directory = ac_read_saved_directory(statePath)
directory = '';
if exist(statePath,'file') ~= 2
    return
end
try
    candidate = ac_normalize_directory(fileread(statePath));
    if isfolder(candidate)
        directory = candidate;
    end
catch
end
end

function directory = ac_read_legacy_directory()
directory = '';
legacyPath = which('ac_pwd.txt');
if isempty(legacyPath)
    return
end
try
    candidate = ac_normalize_directory(fileread(legacyPath));
    if isfolder(candidate)
        directory = candidate;
    end
catch
end
end

function directory = ac_default_directory(fallbackDirectory)
candidates = {};
if isdeployed
    userProfile = getenv('USERPROFILE');
    if ~isempty(userProfile)
        candidates{end+1} = fullfile(userProfile,'Documents'); %#ok<AGROW>
        candidates{end+1} = userProfile; %#ok<AGROW>
    end
    candidates{end+1} = ac_userpath_directory(); %#ok<AGROW>
end
candidates{end+1} = fallbackDirectory;
if ~isdeployed
    candidates{end+1} = ac_userpath_directory(); %#ok<AGROW>
end
candidates{end+1} = tempdir;

directory = pwd;
for candidateIndex = 1:numel(candidates)
    candidate = ac_normalize_directory(candidates{candidateIndex});
    if ~isempty(candidate) && isfolder(candidate)
        directory = candidate;
        return
    end
end
end

function directory = ac_userpath_directory()
directory = '';
try
    candidate = userpath;
    if isempty(candidate)
        return
    end
    paths = strsplit(candidate,pathsep);
    if ~isempty(paths)
        directory = paths{1};
    end
catch
end
end

function directory = ac_normalize_directory(candidate)
directory = '';
if isstring(candidate) && isscalar(candidate)
    candidate = char(candidate);
end
if ~ischar(candidate)
    return
end
candidate = strtrim(candidate);
if isempty(candidate)
    return
end
directory = candidate;
end

function saved = ac_write_saved_directory(statePath,directory)
saved = false;
stateDirectory = fileparts(statePath);
try
    if exist(stateDirectory,'dir') ~= 7
        [created,~] = mkdir(stateDirectory);
        if ~created
            return
        end
    end

    temporaryPath = [tempname(stateDirectory),'.txt'];
    cleanup = onCleanup(@()ac_delete_file(temporaryPath));
    [fileID,~] = fopen(temporaryPath,'wt');
    if fileID < 0
        return
    end
    fileCleanup = onCleanup(@()ac_close_file(fileID));
    fprintf(fileID,'%s',directory);
    clear fileCleanup
    [moved,~] = movefile(temporaryPath,statePath,'f');
    if moved
        saved = true;
        clear cleanup
    end
catch
    saved = false;
end
end

function ac_close_file(fileID)
try
    fclose(fileID);
catch
end
end

function ac_delete_file(filename)
if exist(filename,'file') == 2
    try
        delete(filename);
    catch
    end
end
end
