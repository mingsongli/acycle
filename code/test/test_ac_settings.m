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

function testHelpMenuItemsUseReloadSafeDispatcher(testCase)
[figureHandle,handles] = AC('AC_buildCodeUI');
testCase.addTeardown(@()deleteIfValid(figureHandle));

verifyEqual(testCase,get(handles.menu_settings,'Position'),1);
verifyEqual(testCase,get(handles.menu_settings,'Label'),'Setting...');
menuFields = {'menu_settings','menu_read','menu_manuals', ...
    'menu_findupdates','menu_contact','menu_email'};
callbackNames = {'menu_settings_Callback','menu_read_Callback', ...
    'menu_manuals_Callback','menu_findupdates_Callback', ...
    'menu_contact_Callback','menu_email_Callback'};
expectedLabels = {'Setting...','What''s New','Manual','Find Updates', ...
    'Copyright','Contact'};
for itemIndex = 1:numel(menuFields)
    menuHandle = handles.(menuFields{itemIndex});
    callback = get(menuHandle,'Callback');
    verifyEqual(testCase,get(menuHandle,'Parent'),handles.menu_help);
    verifyEqual(testCase,get(menuHandle,'Position'),itemIndex);
    verifyEqual(testCase,get(menuHandle,'Label'),expectedLabels{itemIndex});
    verifyTrue(testCase,iscell(callback));
    verifyEqual(testCase,callback{1},@ac_gui_dispatch);
    verifyEqual(testCase,callback{2},callbackNames{itemIndex});
end
verifyFalse(testCase,isfield(handles,'menu_lang'));
verifyEmpty(testCase,findall(figureHandle,'Tag','menu_lang'));
end

function testSettingMenuCallbackSurvivesACReload(testCase)
[figureHandle,handles] = AC('AC_buildCodeUI');
testCase.addTeardown(@()deleteIfValid(figureHandle));
guidata(figureHandle,handles);

settingsCallback = get(handles.menu_settings,'Callback');
clear AC
rehash
feval(settingsCallback{1},handles.menu_settings,[], ...
    settingsCallback{2:end});

settingsFigure = findall(groot,'Type','figure', ...
    'Tag','AcycleSettingsFigure');
verifyNumElements(testCase,settingsFigure,1);
end

function testCopyrightMenuCallbackSurvivesACReload(testCase)
[figureHandle,handles] = AC('AC_buildCodeUI');
testCase.addTeardown(@()deleteIfValid(figureHandle));
guidata(figureHandle,handles);

copyrightCallback = get(handles.menu_contact,'Callback');
clear AC
rehash
feval(copyrightCallback{1},handles.menu_contact,[], ...
    copyrightCallback{2:end});

copyrightFigure = findall(groot,'Type','figure', ...
    'Name','Acycle: Copyright');
verifyNumElements(testCase,copyrightFigure,1);
end

function testDocumentHelpCallbacksSurviveACReload(testCase)
[figureHandle,handles] = AC('AC_buildCodeUI');
testCase.addTeardown(@()deleteIfValid(figureHandle));
openedTargets = {};
handles.HelpTargetOpener = @recordOpen;
guidata(figureHandle,handles);
menuFields = {'menu_read','menu_manuals','menu_findupdates','menu_email'};
callbacks = cellfun(@(fieldName)get(handles.(fieldName),'Callback'), ...
    menuFields,'UniformOutput',false);
clear AC
rehash

for itemIndex = 1:numel(menuFields)
    callback = callbacks{itemIndex};
    hgfeval(callback,handles.(menuFields{itemIndex}),[]);
end

verifyEqual(testCase,numel(openedTargets),4);
verifyEqual(testCase,lowerFileName(openedTargets{1}),'updatelog.txt');
verifyEqual(testCase,openedTargets{2},'https://acycle.org/manual/');
verifyEqual(testCase,openedTargets{3},'https://acycle.org/downloads/');
verifyEqual(testCase,openedTargets{4},'https://mingsongli.com/');

    function status = recordOpen(target)
        openedTargets{end+1} = target;
        status = 0;
    end
end

function testWhatsNewResourceIsIndependentOfCurrentDirectory(testCase)
originalDirectory = pwd;
temporaryDirectory = tempname;
mkdir(temporaryDirectory);
testCase.addTeardown(@()cd(originalDirectory));
testCase.addTeardown(@()removeFolder(temporaryDirectory));
cd(temporaryDirectory);

updateLogPath = AC('AC_resourcePath','UpdateLog.txt');

verifyEqual(testCase,exist(updateLogPath,'file'),2);
verifyEqual(testCase,lowerFileName(updateLogPath),'updatelog.txt');
verifyEqual(testCase,lowerBaseName(fileparts(updateLogPath)),'doc');
end

function testHelpTargetOpenerReportsSuccessAndFailure(testCase)
openedTarget = '';
successOpener = @recordSuccess;
failureOpener = @(~)1;
exceptionOpener = @(~)error('Acycle:Test:OpenFailed','expected');

verifyTrue(testCase,AC('AC_openHelpTarget', ...
    'https://acycle.org/manual/',successOpener));
verifyEqual(testCase,openedTarget,'https://acycle.org/manual/');
verifyFalse(testCase,AC('AC_openHelpTarget','bad-target',failureOpener));
verifyFalse(testCase,AC('AC_openHelpTarget','bad-target',exceptionOpener));

    function status = recordSuccess(target)
        openedTarget = target;
        status = 0;
    end
end

function testCopyrightHeaderUsesCurrentVersion(testCase)
app = copyright(struct());
testCase.addTeardown(@()deleteIfValid(app));

expectedTitle = AC('AC_mainFigureTitle');
headerText = get(app.HeaderLabel,'Text');

verifyTrue(testCase,startsWith(headerText,expectedTitle));
verifyEqual(testCase,get(app.UIFigure,'Name'),'Acycle: Copyright');
end

function testLocalizedCopyrightHeaderUsesCurrentVersion(testCase)
context = struct();
context.lang_choice = 1;
context.lang_id = {'c60';'c61';'c62';'c63';'c64';'c65'};
context.lang_var = {'Localized Copyright';'Acycle v3.0'; ...
    'Localized Time-Series Analysis';'Localized ';'Copyright'; ...
    'Jan 18, 2023'};
app = copyright(context);
testCase.addTeardown(@()deleteIfValid(app));

expectedTitle = AC('AC_mainFigureTitle');
headerText = get(app.HeaderLabel,'Text');
headerLines = regexp(headerText,'\r\n|\n|\r','split');
headerLines(cellfun('isempty',headerLines)) = [];

verifyEqual(testCase,headerLines{1},expectedTitle);
verifySubstring(testCase,headerText,'Localized Time-Series Analysis');
verifySubstring(testCase,headerText,'Localized Copyright');
verifyFalse(testCase,contains(headerText,'Acycle v3.0'));
verifyFalse(testCase,contains(headerText,'Jan 18, 2023'));
verifyEqual(testCase,get(app.UIFigure,'Name'),'Localized Copyright');
end

function testFileMenuHasNoOpenWorkingDirectoryItem(testCase)
[figureHandle,handles] = AC('AC_buildCodeUI');
testCase.addTeardown(@()deleteIfValid(figureHandle));

verifyFalse(testCase,isfield(handles,'menu_open'));
verifyEmpty(testCase,findall(figureHandle,'Tag','menu_open'));
verifyEmpty(testCase,findall(figureHandle,'Type','uimenu', ...
    'Label','Open Working Directory'));
end

function testEmpiricalModeMenuHierarchyAndOrder(testCase)
[figureHandle,handles] = AC('AC_buildCodeUI');
testCase.addTeardown(@()deleteIfValid(figureHandle));

verifyEqual(testCase,get(handles.Menu_EMDmenu,'Parent'),handles.menuac);
verifyEqual(testCase,get(handles.menu_emd,'Parent'), ...
    handles.Menu_EMDmenu);
verifyEqual(testCase,get(handles.menu_eemd,'Parent'), ...
    handles.Menu_EMDmenu);
verifyEqual(testCase,get(handles.menu_emd,'Position'),1);
verifyEqual(testCase,get(handles.menu_eemd,'Position'),2);
verifyEqual(testCase,get(handles.Menu_EMDmenu,'Position')+1, ...
    get(handles.menu_AM,'Position'));
verifyEqual(testCase,get(handles.menu_dynfilter,'Position')+1, ...
    get(handles.Menu_EMDmenu,'Position'));
verifySubstring(testCase,func2str(get(handles.menu_emd,'Callback')), ...
    'menu_emd_Callback');
verifySubstring(testCase,func2str(get(handles.menu_eemd,'Callback')), ...
    'menu_eemd_Callback');
end

function testEmpiricalModeLoaderRequiresExactlyTwoColumns(testCase)
folder = tempname;
mkdir(folder);
testCase.addTeardown(@()removeFolder(folder));
figureHandle = figure('Visible','off');
testCase.addTeardown(@()deleteIfValid(figureHandle));
address = uicontrol(figureHandle,'Style','edit','String',folder);
handles = struct('edit_acfigmain_dir',address, ...
    'filetype',{{'.txt','.csv'}});
directoryBefore = pwd;

twoColumnPath = fullfile(folder,'two-column.txt');
fileID = fopen(twoColumnPath,'wt');
fileCleanup = onCleanup(@()fclose(fileID));
fprintf(fileID,'%% Coordinate\tValue\n0\t1\n1\t2\n2\t3\n3\t4\n');
clear fileCleanup
[data,dataPath,errorMessage] = AC( ...
    'AC_loadEmpiricalModeSelection',handles,'two-column.txt');
verifyEqual(testCase,data,[0,1;1,2;2,3;3,4],'AbsTol',0);
verifyEqual(testCase,dataPath,twoColumnPath);
verifyEmpty(testCase,errorMessage);
verifyEqual(testCase,pwd,directoryBefore);

threeColumnPath = fullfile(folder,'three-column.txt');
fileID = fopen(threeColumnPath,'wt');
fileCleanup = onCleanup(@()fclose(fileID));
fprintf(fileID,'%% Coordinate\tIMF1\tResidual\n0\t1\t4\n1\t2\t3\n');
clear fileCleanup
[data,~,errorMessage] = AC( ...
    'AC_loadEmpiricalModeSelection',handles,'three-column.txt');
verifyEmpty(testCase,data);
verifySubstring(testCase,errorMessage{2},'exactly two columns');
verifyEqual(testCase,pwd,directoryBefore);
end

function testEmpiricalModeWriterRoundTrip(testCase)
folder = tempname;
mkdir(folder);
testCase.addTeardown(@()removeFolder(folder));
outputPath = fullfile(folder,'emd-result.txt');
inputPath = fullfile(folder,'input.txt');
coordinate = (0:3)';
imfs = [1,0;0.5,0.25;-0.5,-0.25;-1,0];
residual = [0;1;2;3];
result = struct('coordinate',coordinate,'imfs',imfs, ...
    'residual',residual);
componentVariance = var([imfs,residual],0,1);
componentVarianceSum = sum(componentVariance);
meta = struct('method','eemd','sample_interval',1, ...
    'requested_num_imf',2,'actual_num_imf',2, ...
    'raw_standard_deviation',std(sum([imfs,residual],2),0,1), ...
    'raw_variance',var(sum([imfs,residual],2),0,1), ...
    'raw_variance_representable',true, ...
    'component_variance_sum',componentVarianceSum, ...
    'component_variance_sum_representable',true, ...
    'covariance_gap',0,'covariance_gap_defined',true, ...
    'component_variance',componentVariance, ...
    'component_variance_percent', ...
        100*(componentVariance/componentVarianceSum));
directoryBefore = pwd;

AC('AC_writeEmpiricalModeResult',outputPath,result,meta,inputPath);

verifyEqual(testCase,load(outputPath), ...
    [coordinate,imfs,residual],'AbsTol',0);
verifyEqual(testCase,pwd,directoryBefore);
verifyError(testCase,@()AC('AC_writeEmpiricalModeResult', ...
    fullfile(folder,'missing','result.txt'),result,meta,inputPath), ...
    'Acycle:EMD:OutputOpenFailed');
end

function testEmpiricalModePlotsSurviveSuccessfulReturn(testCase)
coordinate = (0:31)';
inputValue = sin(2*pi*coordinate/8)+0.25*cos(2*pi*coordinate/3);
imfs = 0.25*cos(2*pi*coordinate/3);
result = struct('coordinate',coordinate,'input',inputValue, ...
    'imfs',imfs,'residual',inputValue-imfs);
meta = struct('method','emd','sample_interval',1);
figuresBefore = findall(groot,'Type','figure');

AC('AC_plotEmpiricalModeResult',result,meta,'synthetic.txt');

figuresAfter = findall(groot,'Type','figure');
created = setdiff(figuresAfter,figuresBefore);
verifyNumElements(testCase,created,2);
figureNames = string(get(created,'Name'));
verifyTrue(testCase,any(figureNames == ...
    "EMD decomposition: synthetic.txt"));
verifyTrue(testCase,any(figureNames == ...
    "EMD MTM spectra: synthetic.txt"));
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

function testWorkingDirectoryRoundTripUsesExplicitStateFile(testCase)
stateFolder = tempname;
mkdir(stateFolder);
testCase.addTeardown(@()removeFolder(stateFolder));
statePath = fullfile(stateFolder,'working_directory.txt');

saved = ac_working_directory('set',stateFolder,statePath);
actual = ac_working_directory('get','',statePath);

verifyTrue(testCase,saved);
verifyEqual(testCase,actual,stateFolder);
verifyEqual(testCase,strtrim(fileread(statePath)),stateFolder);
end

function testWorkingDirectoryMissingStateUsesFallback(testCase)
fallbackFolder = tempname;
mkdir(fallbackFolder);
testCase.addTeardown(@()removeFolder(fallbackFolder));
missingState = fullfile(fallbackFolder,'missing','state.txt');

actual = ac_working_directory('get',fallbackFolder,missingState);

verifyEqual(testCase,actual,fallbackFolder);
end

function testInvalidWorkingDirectoryIsNotSaved(testCase)
stateFolder = tempname;
mkdir(stateFolder);
testCase.addTeardown(@()removeFolder(stateFolder));
statePath = fullfile(stateFolder,'working_directory.txt');
missingDirectory = fullfile(stateFolder,'does-not-exist');

saved = ac_working_directory('set',missingDirectory,statePath);

verifyFalse(testCase,saved);
verifyEqual(testCase,exist(statePath,'file'),0);
end

function testDefaultWorkingDirectoryStateLivesInUserSettings(testCase)
[environmentCleanup,settingsRoot] = ...
    redirectAcycleSettingsToTemporaryFolder(); %#ok<NASGU>
workingFolder = tempname;
mkdir(workingFolder);
testCase.addTeardown(@()removeFolder(workingFolder));

statePath = ac_working_directory('path');
saved = ac_working_directory('set',workingFolder);

verifyTrue(testCase,startsWith(statePath,settingsRoot));
verifyFalse(testCase,contains(statePath,fullfile('code','bin')));
verifyTrue(testCase,saved);
verifyEqual(testCase,strtrim(fileread(statePath)),workingFolder);
end

function settingsPath = temporarySettingsPath(testCase)
settingsFolder = tempname;
mkdir(settingsFolder);
testCase.addTeardown(@()removeFolder(settingsFolder));
settingsPath = fullfile(settingsFolder,'settings.mat');
end

function [cleanup,settingsRoot] = ...
        redirectAcycleSettingsToTemporaryFolder()
settingsRoot = tempname;
mkdir(settingsRoot);
if ispc
    variableNames = {'APPDATA','LOCALAPPDATA','USERPROFILE'};
elseif ismac
    variableNames = {'HOME'};
else
    variableNames = {'XDG_CONFIG_HOME','HOME'};
end
oldValues = cellfun(@getenv,variableNames,'UniformOutput',false);
for index = 1:numel(variableNames)
    setenv(variableNames{index},settingsRoot);
end
cleanup = onCleanup(@()restoreTestEnvironment( ...
    variableNames,oldValues,settingsRoot));
end

function restoreTestEnvironment(variableNames,oldValues,settingsRoot)
for index = 1:numel(variableNames)
    setenv(variableNames{index},oldValues{index});
end
removeFolder(settingsRoot);
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

function name = lowerFileName(pathValue)
[~,name,extension] = fileparts(pathValue);
name = lower([name,extension]);
end

function name = lowerBaseName(pathValue)
[~,name] = fileparts(pathValue);
name = lower(name);
end

function deleteIfValid(value)
try
    if ~isempty(value) && isvalid(value)
        delete(value);
    end
catch
end
end
