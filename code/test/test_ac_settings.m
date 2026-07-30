function tests = test_ac_settings
%TEST_AC_SETTINGS Regression tests for Acycle's settings UI and storage.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
oldVisibility = get(groot,'DefaultFigureVisible');
addpath(genpath(fullfile(repoRoot,'code')));
set(groot,'DefaultFigureVisible','off');
testCase.addTeardown(@()path(oldPath));
testCase.addTeardown(@()set( ...
    groot,'DefaultFigureVisible',oldVisibility));
end

function setup(testCase)
testCase.TestData.figuresBefore = findall(groot,'Type','figure');
end

function teardown(testCase)
figuresAfter = findall(groot,'Type','figure');
created = setdiff(figuresAfter,testCase.TestData.figuresBefore);
created = created(isgraphics(created));
if ~isempty(created)
    delete(created);
end
end

function testDefaultsAndAllowedFontSizes(testCase)
settingsPath = temporarySettingsPath(testCase);

settings = ac_user_settings('load',settingsPath);

verifyEqual(testCase,settings.fontSize,11.5);
verifyEqual(testCase,settings.languageChoice,0);
verifyEqual(testCase,ac_user_settings('fontSizes'), ...
    [10,11.5,12.5,13.5]);
end

function testSettingsRoundTrip(testCase)
settingsPath = temporarySettingsPath(testCase);
fontSizes = ac_user_settings('fontSizes');

for index = 1:numel(fontSizes)
    expectedLanguage = index+2;
    ac_user_settings('save',fontSizes(index),expectedLanguage, ...
        settingsPath);
    settings = ac_user_settings('load',settingsPath);
    verifyEqual(testCase,settings.fontSize,fontSizes(index));
    verifyEqual(testCase,settings.languageChoice,expectedLanguage);
end
end

function testInvalidStoredValuesFallBackToNormalEnglish(testCase)
settingsPath = temporarySettingsPath(testCase);
fontSize = 99; %#ok<NASGU>
languageChoice = -4; %#ok<NASGU>
save(settingsPath,'fontSize','languageChoice','-mat');

settings = ac_user_settings('load',settingsPath);

verifyEqual(testCase,settings.fontSize,11.5);
verifyEqual(testCase,settings.languageChoice,0);
end

function testHelpMenuStartsWithSettingAndHasNoOldLanguageMenu(testCase)
[figureHandle,handles] = AC('AC_buildCodeUI');
testCase.addTeardown(@()deleteIfValid(figureHandle));

verifyEqual(testCase,get(handles.menu_settings,'Position'),1);
verifyEqual(testCase,get(handles.menu_settings,'Label'),'Setting...');
verifyFalse(testCase,isfield(handles,'menu_lang'));
verifyEmpty(testCase,findall(figureHandle,'Tag','menu_lang'));
end

function testMainFigureTitleReadsVersionFile(testCase)
versionFolder = tempname;
mkdir(versionFolder);
testCase.addTeardown(@()removeFolder(versionFolder));
versionPath = fullfile(versionFolder,'ac_version.txt');
fileID = fopen(versionPath,'wt');
fileCleanup = onCleanup(@()fclose(fileID));
fprintf(fileID,'%s','9.8.7-test.2');
clear fileCleanup

figureTitle = AC('AC_mainFigureTitle',versionPath);

verifyEqual(testCase,figureTitle,'Acycle v9.8.7-test.2');
end

function testOpeningKeepsVersionTitleFromVersionFile(testCase)
expectedTitle = AC('AC_mainFigureTitle');
figureHandle = AC;
testCase.addTeardown(@()deleteIfValid(figureHandle));

verifyEqual(testCase,get(figureHandle,'Name'),expectedTitle);
end

function testSettingsWindowHasRequestedTabsAndFourFontTicks(testCase)
settingsPath = temporarySettingsPath(testCase);
app = settingsGUI(struct(),settingsPath);
testCase.addTeardown(@()deleteIfValid(app.UIFigure));

verifyEqual(testCase,get(app.UIFigure,'Name'),'Acycle: Setting');
verifyEqual(testCase,{get(app.FontSizeTab,'Title'), ...
    get(app.LanguageTab,'Title')}, ...
    {'Font Size','Language'});
verifyEqual(testCase,[get(app.FontSizeSlider,'Min'), ...
    get(app.FontSizeSlider,'Max')],[1 4]);
verifyEqual(testCase,app.FontSizeTicks,1:4);
verifyEqual(testCase,app.FontSizeTickLabels, ...
    {'Small (10 pt)','Normal (11.5 pt)','Large (12.5 pt)', ...
    'Extra Large (13.5 pt)'});
verifyEqual(testCase,get(app.FontSizeSlider,'Value'),2);
verifyEqual(testCase,get(app.LanguageDropDown,'Value'),1);
verifyEqual(testCase,numel(get(app.LanguageDropDown,'String')),20);
verifyEqual(testCase,get(app.LanguageDropDown,'Enable'),'off');
verifyEqual(testCase,get(app.OKButton,'String'),'OK');

set(app.FontSizeSlider,'Value',3.4);
callback = get(app.FontSizeSlider,'Callback');
callback(app.FontSizeSlider,[]);
verifyEqual(testCase,get(app.FontSizeSlider,'Value'),3);
verifySubstring(testCase,get(app.SelectedFontLabel,'String'),'12.5 pt');

secondApp = settingsGUI(struct(),settingsPath);
verifyEqual(testCase,secondApp.UIFigure,app.UIFigure);
end

function testOKSavesBothTabsAndRequestsRestart(testCase)
settingsPath = temporarySettingsPath(testCase);
[~,restartToken] = fileparts(tempname);
restartKey = ['AcycleSettingsRestart_',restartToken];
setappdata(groot,restartKey,false);
testCase.addTeardown(@()removeRootAppdata(restartKey));
context = struct('SettingsRestartFcn', ...
    @()setappdata(groot,restartKey,true));
app = settingsGUI(context,settingsPath);

set(app.FontSizeSlider,'Value',4);
set(app.LanguageDropDown,'Value',4);
callback = get(app.OKButton,'Callback');
callback(app.OKButton,[]);

settings = ac_user_settings('load',settingsPath);
verifyEqual(testCase,settings.fontSize,13.5);
verifyEqual(testCase,settings.languageChoice,10);
verifyTrue(testCase,getappdata(groot,restartKey));
verifyEmpty(testCase,findall(groot,'Tag','AcycleSettingsFigure'));
end

function settingsPath = temporarySettingsPath(testCase)
settingsFolder = tempname;
mkdir(settingsFolder);
testCase.addTeardown(@()removeFolder(settingsFolder));
settingsPath = fullfile(settingsFolder,'settings.mat');
end

function removeFolder(folder)
if exist(folder,'dir') == 7
    try
        rmdir(folder,'s');
    catch
    end
end
end

function removeRootAppdata(key)
if isappdata(groot,key)
    rmappdata(groot,key);
end
end

function deleteIfValid(value)
try
    if ~isempty(value) && isvalid(value)
        delete(value);
    end
catch
end
end
