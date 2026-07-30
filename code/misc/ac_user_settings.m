function output = ac_user_settings(action,varargin)
%AC_USER_SETTINGS Read and write persistent Acycle interface settings.
%
% Settings are stored in a stable per-user directory so MATLAB source runs
% and compiled standalone builds share the same choices across restarts and
% application upgrades. The distributed ac_lang.txt remains a read-only
% fallback for users who selected a language before this settings file was
% introduced.

fontSizes = [10,11.5,12.5,13.5];
defaults = struct('fontSize',11.5,'languageChoice',0);

if nargin < 1 || ~(ischar(action) || (isstring(action) && isscalar(action)))
    error('Acycle:Settings:InvalidAction','A settings action is required.');
end

action = lower(strtrim(char(action)));
switch action
    case 'load'
        settingsPath = ac_settings_path(varargin{:});
        output = ac_load_settings(settingsPath,defaults,fontSizes);
    case 'getfontsize'
        settingsPath = ac_settings_path(varargin{:});
        settings = ac_load_settings(settingsPath,defaults,fontSizes);
        output = settings.fontSize;
    case 'getlanguage'
        settingsPath = ac_settings_path(varargin{:});
        settings = ac_load_settings(settingsPath,defaults,fontSizes);
        output = settings.languageChoice;
    case 'save'
        if numel(varargin) < 2
            error('Acycle:Settings:MissingValues', ...
                'Font size and language choice are required.');
        end
        [fontSize,fontIsValid] = ac_normalize_font_size( ...
            varargin{1},fontSizes,defaults.fontSize);
        [languageChoice,languageIsValid] = ac_normalize_language( ...
            varargin{2},defaults.languageChoice);
        if ~fontIsValid
            error('Acycle:Settings:InvalidFontSize', ...
                'Font size must be one of: 10, 11.5, 12.5, or 13.5.');
        end
        if ~languageIsValid
            error('Acycle:Settings:InvalidLanguage', ...
                'Language choice must be an integer from 0 through 19.');
        end
        if numel(varargin) >= 3
            settingsPath = ac_settings_path(varargin{3});
        else
            settingsPath = ac_settings_path();
        end
        output = struct('fontSize',fontSize, ...
            'languageChoice',languageChoice);
        ac_save_settings(settingsPath,output);
    case 'fontsizes'
        output = fontSizes;
    case 'defaults'
        output = defaults;
    case 'path'
        output = ac_settings_path(varargin{:});
    case 'normalizefontsize'
        if isempty(varargin)
            candidate = [];
        else
            candidate = varargin{1};
        end
        output = ac_normalize_font_size( ...
            candidate,fontSizes,defaults.fontSize);
    case 'normalizelanguage'
        if isempty(varargin)
            candidate = [];
        else
            candidate = varargin{1};
        end
        output = ac_normalize_language(candidate,defaults.languageChoice);
    otherwise
        error('Acycle:Settings:UnknownAction', ...
            'Unknown settings action: %s',action);
end
end

function settings = ac_load_settings(settingsPath,defaults,fontSizes)
settings = defaults;
loaded = struct();
if exist(settingsPath,'file') == 2
    try
        loaded = load(settingsPath,'fontSize','languageChoice');
    catch
        loaded = struct();
    end
elseif ac_is_default_settings_path(settingsPath)
    loaded.languageChoice = ac_legacy_language_choice();
end

if isfield(loaded,'fontSize')
    settings.fontSize = ac_normalize_font_size( ...
        loaded.fontSize,fontSizes,defaults.fontSize);
end
if isfield(loaded,'languageChoice')
    settings.languageChoice = ac_normalize_language( ...
        loaded.languageChoice,defaults.languageChoice);
end
end

function ac_save_settings(settingsPath,settings)
settingsDirectory = fileparts(settingsPath);
if exist(settingsDirectory,'dir') ~= 7
    [created,message] = mkdir(settingsDirectory);
    if ~created
        error('Acycle:Settings:CreateDirectoryFailed', ...
            'Cannot create the Acycle settings directory: %s',message);
    end
end

temporaryPath = [tempname(settingsDirectory),'.mat'];
temporaryCleanup = onCleanup(@()ac_delete_temporary_file(temporaryPath));
fontSize = settings.fontSize;
languageChoice = settings.languageChoice;
save(temporaryPath,'fontSize','languageChoice','-mat');
[moved,message] = movefile(temporaryPath,settingsPath,'f');
if ~moved
    error('Acycle:Settings:SaveFailed', ...
        'Cannot save Acycle settings: %s',message);
end
clear temporaryCleanup
end

function settingsPath = ac_settings_path(varargin)
if ~isempty(varargin)
    candidate = varargin{1};
    if isstring(candidate) && isscalar(candidate)
        candidate = char(candidate);
    end
    if ~ischar(candidate) || isempty(candidate)
        error('Acycle:Settings:InvalidPath', ...
            'The settings path must be a nonempty character vector.');
    end
    settingsPath = candidate;
    return
end

if ispc
    baseDirectory = getenv('APPDATA');
    if isempty(baseDirectory)
        baseDirectory = getenv('LOCALAPPDATA');
    end
elseif ismac
    baseDirectory = getenv('HOME');
    if ~isempty(baseDirectory)
        baseDirectory = fullfile(baseDirectory,'Library','Application Support');
    end
else
    baseDirectory = getenv('XDG_CONFIG_HOME');
    if isempty(baseDirectory)
        baseDirectory = getenv('HOME');
        if ~isempty(baseDirectory)
            baseDirectory = fullfile(baseDirectory,'.config');
        end
    end
end
if isempty(baseDirectory)
    baseDirectory = prefdir;
end
settingsPath = fullfile(baseDirectory,'Acycle','settings.mat');
end

function tf = ac_is_default_settings_path(settingsPath)
try
    tf = strcmp(settingsPath,ac_settings_path());
catch
    tf = false;
end
end

function languageChoice = ac_legacy_language_choice()
languageChoice = 0;
legacyPath = which('ac_lang.txt');
if isempty(legacyPath)
    sourceDirectory = fileparts(mfilename('fullpath'));
    candidate = fullfile(sourceDirectory,'..','bin','ac_lang.txt');
    if exist(candidate,'file') == 2
        legacyPath = candidate;
    end
end
if isempty(legacyPath)
    return
end
try
    candidate = load(legacyPath);
    languageChoice = ac_normalize_language(candidate,0);
catch
    languageChoice = 0;
end
end

function [fontSize,isValid] = ac_normalize_font_size(candidate,fontSizes,defaultValue)
if ischar(candidate) || (isstring(candidate) && isscalar(candidate))
    candidate = str2double(candidate);
end
isValid = isnumeric(candidate) && isscalar(candidate) && ...
    isreal(candidate) && isfinite(candidate);
if isValid
    [distance,index] = min(abs(double(candidate)-fontSizes));
    isValid = distance <= 1e-9;
end
if isValid
    fontSize = fontSizes(index);
else
    fontSize = defaultValue;
end
end

function [languageChoice,isValid] = ac_normalize_language(candidate,defaultValue)
if ischar(candidate) || (isstring(candidate) && isscalar(candidate))
    candidate = str2double(candidate);
end
isValid = isnumeric(candidate) && isscalar(candidate) && ...
    isreal(candidate) && isfinite(candidate) && ...
    candidate == round(candidate) && candidate >= 0 && candidate <= 19;
if isValid
    languageChoice = double(candidate);
else
    languageChoice = defaultValue;
end
end

function ac_delete_temporary_file(filename)
if exist(filename,'file') == 2
    try
        delete(filename);
    catch
    end
end
end
