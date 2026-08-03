function tests = test_ac_main_list
%TEST_AC_MAIN_LIST Regression tests for sorting and scrolling the main list.
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

function testNameAscendingIsCaseInsensitive(testCase)
entries = listingFixture( ...
    {'beta','Alpha','apple','Bravo','aardvark','Aardwolf'},1:6,1:6);

sorted = ac_sort_dir_entries(entries,1);

verifyEqual(testCase,{sorted.name}, ...
    {'aardvark','Aardwolf','Alpha','apple','beta','Bravo'});
end

function testNameDescendingIsCaseInsensitive(testCase)
entries = listingFixture( ...
    {'beta','Alpha','apple','Bravo','aardvark','Aardwolf'},1:6,1:6);

sorted = ac_sort_dir_entries(entries,2);

verifyEqual(testCase,{sorted.name}, ...
    {'Bravo','beta','apple','Alpha','Aardwolf','aardvark'});
end

function testDateModesUseNumericModificationTime(testCase)
entries = listingFixture( ...
    {'latest','oldest','middle'},[30 10 20],1:3);
entries(1).date = '01-Jan-2000';
entries(2).date = '31-Dec-2099';
entries(3).date = '15-Jun-2050';

ascending = ac_sort_dir_entries(entries,3);
descending = ac_sort_dir_entries(entries,4);

verifyEqual(testCase,{ascending.name},{'oldest','middle','latest'});
verifyEqual(testCase,{descending.name},{'latest','middle','oldest'});
end

function testShorterListClearsEveryRowSelectionCache(testCase)
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox','Min',0,'Max',2);
handles = struct('listbox_acmain',listbox,'index_selected',[]);
guidata(fig,handles);

oldNames = arrayfun(@(index)sprintf('old-%02d.txt',index), ...
    1:12,'UniformOutput',false);
ac_update_listbox_acmain(listbox,oldNames,false(size(oldNames)));
seedMainListSelection(fig,listbox,11);

newNames = {'new-a.txt','new-b.txt','new-c.txt'};
ac_update_listbox_acmain(listbox,newNames,false(size(newNames)));

verifyMainListSelectionCleared(testCase,fig,listbox,newNames);
end

function testShorterListRemapsHighSelectionByFilename(testCase)
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox','Min',0,'Max',2);
handles = struct('listbox_acmain',listbox, ...
    'index_selected',[],'plot_selected',[],'nplot',5);
guidata(fig,handles);

oldNames = arrayfun(@(index)sprintf('old-%02d.txt',index), ...
    1:12,'UniformOutput',false);
oldNames{11} = 'selected-input.txt';
ac_update_listbox_acmain(listbox,oldNames,false(size(oldNames)));
seedMainListSelection(fig,listbox,11);
handles = guidata(fig);
handles.nplot = 5;
guidata(fig,handles);

newNames = {'new-output.txt','selected-input.txt','summary.txt'};
ac_update_listbox_acmain( ...
    listbox,newNames,false(size(newNames)),true);

verifyMainListSelection(testCase,fig,listbox,newNames,2);
verifyNativeValueIsInRange(testCase,listbox);
handles = guidata(fig);
verifyEqual(testCase,handles.nplot,5);
end

function testSortRefreshPreservesSelectionByFilename(testCase)
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox');
handles = struct('listbox_acmain',listbox,'index_selected',[]);
guidata(fig,handles);

oldNames = {'charlie.txt','alpha.txt','bravo.txt'};
ac_update_listbox_acmain(listbox,oldNames,false(size(oldNames)));
seedMainListSelection(fig,listbox,2);

entries = listingFixture(oldNames,1:3,1:3);
sorted = ac_sort_dir_entries(entries,1);
sortedNames = {sorted.name};
ac_update_listbox_acmain( ...
    listbox,sortedNames,false(size(sortedNames)),true);

verifyEqual(testCase,sortedNames,{'alpha.txt','bravo.txt','charlie.txt'});
verifyMainListSelection(testCase,fig,listbox,sortedNames,1);
end

function testDirectoryRefreshClearsOldSelection(testCase)
dataFolder = tempname;
mkdir(dataFolder);
folderCleanup = onCleanup(@()removeTestFolder(dataFolder));
createTextFile(fullfile(dataFolder,'beta.txt'));
createTextFile(fullfile(dataFolder,'Alpha.txt'));

environmentCleanup = redirectAcycleSettingsToTemporaryFolder(); %#ok<NASGU>
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox');
address = uicontrol(fig,'Style','edit');
handles = struct( ...
    'listbox_acmain',listbox, ...
    'edit_acfigmain_dir',address, ...
    'val1',1, ...
    'index_selected',[]);
guidata(fig,handles);

oldNames = arrayfun(@(index)sprintf('previous-%02d.txt',index), ...
    1:9,'UniformOutput',false);
ac_update_listbox_acmain(listbox,oldNames,false(size(oldNames)));
seedMainListSelection(fig,listbox,9);

refreshed = ac_refresh_main_list(listbox,dataFolder);

verifyTrue(testCase,refreshed);
verifyMainListSelectionCleared(testCase,fig,listbox, ...
    {'Alpha.txt','beta.txt'});
verifyEqual(testCase,get(address,'String'),dataFolder);
end

function testSameDirectoryRefreshPreservesSelectedFilename(testCase)
dataFolder = tempname;
mkdir(dataFolder);
folderCleanup = onCleanup(@()removeTestFolder(dataFolder));
createTextFile(fullfile(dataFolder,'beta.txt'));
createTextFile(fullfile(dataFolder,'Alpha.txt'));

environmentCleanup = redirectAcycleSettingsToTemporaryFolder(); %#ok<NASGU>
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox','Min',0,'Max',2);
address = uicontrol(fig,'Style','edit','String',dataFolder);
handles = struct( ...
    'listbox_acmain',listbox, ...
    'edit_acfigmain_dir',address, ...
    'val1',1, ...
    'index_selected',[], ...
    'plot_selected',[], ...
    'nplot',7);
guidata(fig,handles);

ac_update_listbox_acmain(listbox, ...
    {'beta.txt','Alpha.txt'},[false false]);
seedMainListSelection(fig,listbox,1);
handles = guidata(fig);
handles.nplot = 7;
guidata(fig,handles);
createTextFile(fullfile(dataFolder,'aardvark.txt'));

refreshed = ac_refresh_main_list(listbox,dataFolder);

verifyTrue(testCase,refreshed);
verifyMainListSelection(testCase,fig,listbox, ...
    {'aardvark.txt','Alpha.txt','beta.txt'},3);
handles = guidata(fig);
verifyEqual(testCase,handles.nplot,7, ...
    'Refreshing the browser must not erase the copy/cut item count.');
end

function testManualRefreshButtonAndMenuClearSelection(testCase)
dataFolder = tempname;
mkdir(dataFolder);
folderCleanup = onCleanup(@()removeTestFolder(dataFolder));
createTextFile(fullfile(dataFolder,'beta.txt'));
createTextFile(fullfile(dataFolder,'Alpha.txt'));

environmentCleanup = redirectAcycleSettingsToTemporaryFolder(); %#ok<NASGU>
previousDirectory = pwd;
directoryCleanup = onCleanup(@()cd(previousDirectory));
verifyTrue(testCase,ac_working_directory('set',dataFolder));

fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox','Min',0,'Max',2);
address = uicontrol(fig,'Style','edit','String',dataFolder);
refreshButton = uicontrol(fig,'Style','pushbutton');
refreshMenu = uimenu(fig,'Label','Refresh');
handles = struct( ...
    'listbox_acmain',listbox, ...
    'edit_acfigmain_dir',address, ...
    'val1',1, ...
    'index_selected',[], ...
    'plot_selected',[], ...
    'nplot',1);
guidata(fig,handles);

ac_update_listbox_acmain(listbox, ...
    {'beta.txt','Alpha.txt'},[false false]);
seedMainListSelection(fig,listbox,1);
createTextFile(fullfile(dataFolder,'aardvark.txt'));

AC('push_refresh_clbk',refreshButton,[]);

expectedNames = {'aardvark.txt','Alpha.txt','beta.txt'};
verifyMainListSelectionCleared( ...
    testCase,fig,listbox,expectedNames);
verifyEqual(testCase,get(address,'String'),dataFolder);
verifyEqual(testCase,pwd,previousDirectory);

seedMainListSelection(fig,listbox,3);
AC('AC_dispatch','menu_refreshlist_Callback',refreshMenu,[]);

verifyMainListSelectionCleared( ...
    testCase,fig,listbox,expectedNames);
verifyEqual(testCase,get(address,'String'),dataFolder);
verifyEqual(testCase,pwd,previousDirectory);
end

function testDeleteDirectoryRestoreFallsBackWhenOriginalWasDeleted(testCase)
originalDirectory = pwd;
testRoot = tempname;
deletedDirectory = fullfile(testRoot,'result-bispectral-1');
mkdir(deletedDirectory);
cleanup = onCleanup(@()cleanupDirectoryRestoreFixture( ...
    originalDirectory,testRoot));

% Reproduce the callback sequence: MATLAB starts inside the selected
% folder, CDac_pwd moves to the Acycle browser parent, and RMDIR removes the
% directory stored in pre_dirML.
cd(deletedDirectory);
preferredDirectory = pwd;
cd(testRoot);
fallbackDirectory = pwd;
[removed,message] = rmdir(deletedDirectory,'s');
verifyTrue(testCase,removed,message);
verifyFalse(testCase,isfolder(preferredDirectory));

restoredDirectory = AC('restoreDirectoryAfterDelete', ...
    preferredDirectory,fallbackDirectory);

verifyEqual(testCase,restoredDirectory,fallbackDirectory);
verifyEqual(testCase,pwd,fallbackDirectory);
end

function testUnifiedUpdaterNeverLeavesValuePastString(testCase)
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox');
handles = struct('listbox_acmain',listbox,'index_selected',[]);
guidata(fig,handles);

oldNames = arrayfun(@(index)sprintf('item-%02d',index), ...
    1:8,'UniformOutput',false);
ac_update_listbox_acmain(listbox,oldNames,false(size(oldNames)));
seedMainListSelection(fig,listbox,8);

replacementNames = {'only-one','only-two'};
ac_update_listbox_acmain(listbox,replacementNames, ...
    false(size(replacementNames)));
verifyNativeValueIsInRange(testCase,listbox);
verifyMainListSelectionCleared(testCase,fig,listbox,replacementNames);

seedMainListSelection(fig,listbox,2);
ac_update_listbox_acmain(listbox,{},false(0,1));
verifyNativeValueIsInRange(testCase,listbox);
verifyMainListSelectionCleared(testCase,fig,listbox,{});
end

function testSelectionMismatchIsRejectedAcrossListRepresentations(testCase)
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox','Min',0,'Max',2);
handles = struct('listbox_acmain',listbox, ...
    'index_selected',1,'plot_selected',1,'nplot',3);
guidata(fig,handles);
ac_update_listbox_acmain(listbox,{'one.txt','two.txt'},[false false]);

set(listbox,'Value',1);
setappdata(listbox,'ACListSelected',2);
handles = guidata(fig);
handles.index_selected = 1;
handles.plot_selected = 1;

[contents,selected,handles,selectionReset] = ...
    AC('getMainListSelection',handles,false);

verifyEqual(testCase,contents,{'one.txt';'two.txt'});
verifyEmpty(testCase,selected);
verifyTrue(testCase,selectionReset);
verifyEmpty(testCase,handles.index_selected);
verifyEmpty(testCase,handles.plot_selected);
verifyEmpty(testCase,get(listbox,'Value'));
verifyEmpty(testCase,getappdata(listbox,'ACListSelected'));
verifyEqual(testCase,handles.nplot,3);
end

function testDrawnListUsesBlueFolderNames(testCase)
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox');
names = {'doc','Acycle.prj','resources'};
isDir = [true false true];

ac_update_listbox_acmain(listbox,names,isDir);

axesHandle = getappdata(listbox,'ACDrawnListboxAxes');
rowTexts = findall(axesHandle,'Type','text','Tag','ACListRowText');
textNames = get(rowTexts,'String');
textColors = get(rowTexts,'Color');
if ischar(textNames)
    textNames = {textNames};
end
if isnumeric(textColors)
    textColors = {textColors};
end

docColor = textColors{strcmp(textNames,'doc')};
projectColor = textColors{strcmp(textNames,'Acycle.prj')};
resourcesColor = textColors{strcmp(textNames,'resources')};
verifyEqual(testCase,docColor,[0 0 1],'AbsTol',0);
verifyEqual(testCase,resourcesColor,[0 0 1],'AbsTol',0);
verifyEqual(testCase,projectColor,[0 0 0],'AbsTol',0);
end

function testDrawnRowClickSynchronizesGuideSelection(testCase)
fig = figure('Visible','off');
listbox = uicontrol(fig,'Style','listbox','Min',0,'Max',2);
handles = struct('listbox_acmain',listbox, ...
    'index_selected',[],'plot_selected',[]);
guidata(fig,handles);
names = {'alpha.txt','beta.txt','gamma.txt'};

ac_update_listbox_acmain(listbox,names,false(size(names)));
axesHandle = getappdata(listbox,'ACDrawnListboxAxes');
row = findall(axesHandle,'Type','text','String','beta.txt');
verifyNumElements(testCase,row,1);
callback = get(row,'ButtonDownFcn');
callback{1}(row,[],callback{2:end});

verifyEqual(testCase,get(listbox,'Value'),2);
verifyEqual(testCase,getappdata(listbox,'ACListSelected'),2);
handles = guidata(fig);
verifyEqual(testCase,handles.index_selected,2);
verifyEqual(testCase,handles.plot_selected,2);
end

function testDrawnScrollbarTracksTopIndexInScreenDirection(testCase)
fig = figure('Visible','off','Units','pixels', ...
    'Position',[100 100 500 180]);
listbox = uicontrol(fig,'Style','listbox','Units','pixels', ...
    'Position',[10 10 460 100]);
setappdata(listbox,'ACListRowHeight',18);
names = arrayfun(@(index)sprintf('item-%02d',index), ...
    1:20,'UniformOutput',false);

ac_update_listbox_acmain(listbox,names,false(size(names)));

slider = getappdata(listbox,'ACDrawnListboxSlider');
scroll = getappdata(listbox,'ACListScrollFcn');
verifyEqual(testCase,getappdata(listbox,'ACListTopIndex'),1);
verifyEqual(testCase,get(slider,'Value'),get(slider,'Max'),'AbsTol',0);

scroll(1);
verifyEqual(testCase,getappdata(listbox,'ACListTopIndex'),2);
verifyEqual(testCase,get(slider,'Value'),get(slider,'Max')-1, ...
    'AbsTol',0);

set(slider,'Value',get(slider,'Min'));
callback = get(slider,'Callback');
callback(slider,[]);
verifyEqual(testCase,getappdata(listbox,'ACListTopIndex'), ...
    get(slider,'Max'),'AbsTol',0);

set(slider,'Value',get(slider,'Max'));
callback(slider,[]);
verifyEqual(testCase,getappdata(listbox,'ACListTopIndex'),1);

AC('scrollMainList',listbox,1);
verifyGreaterThan(testCase,getappdata(listbox,'ACListTopIndex'),1);
verifyLessThan(testCase,get(slider,'Value'),get(slider,'Max'));
end

function testDrawnListUsesConfiguredFontSizeAndRowHeight(testCase)
fig = figure('Visible','off','Units','pixels', ...
    'Position',[100 100 500 260]);
listbox = uicontrol(fig,'Style','listbox','Units','pixels', ...
    'Position',[10 10 460 180], ...
    'FontUnits','points','FontSize',12.75);
setappdata(listbox,'ACListRowHeight',18);
names = arrayfun(@(index)sprintf('item-%02d',index), ...
    1:20,'UniformOutput',false);

ac_update_listbox_acmain(listbox,names,false(size(names)));

axesHandle = getappdata(listbox,'ACDrawnListboxAxes');
slider = getappdata(listbox,'ACDrawnListboxSlider');
rowTexts = findall(axesHandle,'Type','text','Tag','ACListRowText');
fontSizes = cell2mat(get(rowTexts,'FontSize'));

verifyEqual(testCase,get(axesHandle,'YLim'),[0 10]);
verifyEqual(testCase,get(slider,'Max'),11);
verifyEqual(testCase,numel(rowTexts),10);
verifyEqual(testCase,fontSizes,12.75*ones(size(fontSizes)), ...
    'AbsTol',1e-12);
end

function testUiListboxPreservesSelectionByFilename(testCase)
try
    fig = uifigure('Visible','off');
catch
    assumeTrue(testCase,false, ...
        'UI figures are unavailable in this MATLAB environment.');
end
testCase.addTeardown(@()deleteIfValid(fig));
listbox = uilistbox(fig,'Multiselect','on');
handles = struct('listbox_acmain',listbox, ...
    'index_selected',[],'plot_selected',[],'nplot',4);
guidata(fig,handles);

ac_update_listbox_acmain(listbox,{'beta.txt','alpha.txt'},[false false]);
listbox.Value = {'beta.txt'};
handles = guidata(fig);
handles.index_selected = 1;
handles.plot_selected = 1;
guidata(fig,handles);

[contents,currentSelection,~,selectionReset] = ...
    AC('getMainListSelection',handles,false);
verifyEqual(testCase,contents,{'beta.txt';'alpha.txt'});
verifyEqual(testCase,currentSelection,1);
verifyFalse(testCase,selectionReset);

[updated,selected] = ac_update_listbox_acmain(listbox, ...
    {'alpha.txt','beta.txt','gamma.txt'},false(1,3),true);

verifyTrue(testCase,updated);
verifyEqual(testCase,selected,2);
verifyEqual(testCase,cellstr(listbox.Value),{'beta.txt'});
handles = guidata(fig);
verifyEqual(testCase,handles.index_selected,2);
verifyEqual(testCase,handles.plot_selected,2);
verifyEqual(testCase,handles.nplot,4);
end

function testUiListboxDirectoryRefreshUsesEditFieldValue(testCase)
dataFolder = tempname;
mkdir(dataFolder);
folderCleanup = onCleanup(@()removeTestFolder(dataFolder));
createTextFile(fullfile(dataFolder,'beta.txt'));
createTextFile(fullfile(dataFolder,'Alpha.txt'));
environmentCleanup = redirectAcycleSettingsToTemporaryFolder(); %#ok<NASGU>

try
    fig = uifigure('Visible','off');
catch
    assumeTrue(testCase,false, ...
        'UI figures are unavailable in this MATLAB environment.');
end
testCase.addTeardown(@()deleteIfValid(fig));
address = uieditfield(fig,'text','Value',dataFolder);
listbox = uilistbox(fig,'Multiselect','on');
handles = struct('listbox_acmain',listbox, ...
    'edit_acfigmain_dir',address,'val1',1, ...
    'index_selected',[],'plot_selected',[],'nplot',6);
guidata(fig,handles);

ac_update_listbox_acmain(listbox, ...
    {'beta.txt','Alpha.txt'},[false false]);
listbox.Value = {'beta.txt'};
handles = guidata(fig);
handles.index_selected = 1;
handles.plot_selected = 1;
guidata(fig,handles);
createTextFile(fullfile(dataFolder,'aardvark.txt'));

refreshed = ac_refresh_main_list(listbox,dataFolder);

verifyTrue(testCase,refreshed);
verifyEqual(testCase,reshape(cellstr(listbox.Items),1,[]), ...
    {'aardvark.txt','Alpha.txt','beta.txt'});
verifyEqual(testCase,cellstr(listbox.Value),{'beta.txt'});
verifyEqual(testCase,address.Value,dataFolder);
handles = guidata(fig);
verifyEqual(testCase,handles.index_selected,3);
verifyEqual(testCase,handles.plot_selected,3);
verifyEqual(testCase,handles.nplot,6);

listbox.Value = {};
handles.index_selected = [];
handles.plot_selected = [];
guidata(fig,handles);
refreshed = ac_refresh_main_list(listbox,dataFolder);
verifyTrue(testCase,refreshed);
verifyEmpty(testCase,listbox.Value);
handles = guidata(fig);
verifyEmpty(testCase,handles.index_selected);
verifyEmpty(testCase,handles.plot_selected);
end

function testBispectralMenuAndSaveUseLiveBrowserDirectory(testCase)
liveFolder = tempname;
staleFolder = tempname;
mkdir(liveFolder);
mkdir(staleFolder);
liveCleanup = onCleanup(@()removeTestFolder(liveFolder));
staleCleanup = onCleanup(@()removeTestFolder(staleFolder));
environmentCleanup = redirectAcycleSettingsToTemporaryFolder(); %#ok<NASGU>
verifyTrue(testCase,ac_working_directory('set',staleFolder));

t = (0:255)';
liveData = [t,sin(2*pi*0.07*t)+0.4*cos(2*pi*0.13*t)];
staleData = [t,100+zeros(size(t))];
filename = 'SERIES.TXT';
createNumericMatrixFile(fullfile(liveFolder,filename),liveData);
createNumericMatrixFile(fullfile(staleFolder,filename),staleData);

mainFigure = figure('Visible','off');
address = uicontrol(mainFigure,'Style','edit','String',liveFolder);
listbox = uicontrol(mainFigure,'Style','listbox','Min',0,'Max',2);
menu = uimenu(mainFigure,'Label','Bispectral Analysis');
handles = struct('listbox_acmain',listbox, ...
    'edit_acfigmain_dir',address,'index_selected',[], ...
    'plot_selected',[],'nplot',0,'val1',1,'filetype', ...
    {{'.txt','.csv','','.res','.dat','.out','.tab'}}, ...
    'unit','unit');
guidata(mainFigure,handles);
ac_update_listbox_acmain(listbox,{filename},false);
seedMainListSelection(mainFigure,listbox,1);
handles = guidata(mainFigure);

AC('menu_bispectral_Callback',menu,[],handles);
gui = findall(groot,'Type','figure','Tag','bispectralGUI');
verifyNumElements(testCase,gui,1);
controls = getappdata(gui,'BispectralControls');
verifyEqual(testCase,controls.Data,liveData,'AbsTol',1e-12);
verifyEqual(testCase,controls.DataName,fullfile(liveFolder,filename));
verifyTrue(testCase,isa(gui.CloseRequestFcn,'function_handle'));

gui.Visible = 'off';
controls.Significance.Value = 'none';
controls.NumSurrogates.Value = 19;
controls.NumSegments.Value = 8;
controls.Overlap.Value = 0;
controls.AnnotatePeaks.Value = false;
controls.PeriodAxes.Value = false;
controls.ColorGrid.Value = -1;
colorGridChanged = controls.ColorGrid.ValueChangedFcn;
colorGridChanged(controls.ColorGrid,[]);
stateBeforeSave = getappdata(gui,'BispectralState');
verifyNumElements(testCase,stateBeforeSave.PendingParameterCorrections,1);
verifyTrue(testCase,contains( ...
    stateBeforeSave.PendingParameterCorrections{1},'Colormap grid #'));
preview = controls.PreviewButton.ButtonPushedFcn;
preview(controls.PreviewButton,[]);
stateAfterPreview = getappdata(gui,'BispectralState');
verifyEqual(testCase,stateAfterPreview.AnalysisCount,1);
verifyNumElements(testCase, ...
    stateAfterPreview.PendingParameterCorrections,1);
runAndSave = controls.SaveButton.ButtonPushedFcn;
runAndSave(controls.SaveButton,[]);

resultFolder = fullfile(liveFolder,'SERIES-bispectral-1');
artifactStem = 'SERIES-bispectral-1';
expected = { ...
    fullfile(resultFolder,[artifactStem,'.pdf']), ...
    fullfile(resultFolder,[artifactStem,'.fig']), ...
    fullfile(resultFolder,[artifactStem,'.mat']), ...
    fullfile(resultFolder,[artifactStem,'-preprocessed.csv']), ...
    fullfile(resultFolder,[artifactStem,'-config.json'])};
verifyTrue(testCase,isfolder(resultFolder));
verifyTrue(testCase,all(cellfun(@(path)exist(path,'file') == 2,expected)));
verifyEmpty(testCase,dir(fullfile(staleFolder,'SERIES-bispectral-*')));
verifyTrue(testCase,contains(controls.Status.Text,liveFolder));
saved = load(expected{3},'result');
verifyNumElements(testCase,saved.result.GUIParameterCorrections,1);
verifyTrue(testCase,contains( ...
    saved.result.GUIParameterCorrections{1},'Colormap grid #'));
configuration = jsondecode(fileread(expected{5}));
verifyNumElements(testCase,configuration.GUIParameterCorrections,1);
verifyTrue(testCase,contains( ...
    configuration.GUIParameterCorrections{1},'Colormap grid #'));
stateAfterSave = getappdata(gui,'BispectralState');
verifyEqual(testCase,stateAfterSave.AnalysisCount,2);
verifyEmpty(testCase,stateAfterSave.PendingParameterCorrections);

close(gui);
verifyFalse(testCase,isvalid(gui));
end

function testBispectralReaderReturnsFriendlyValidationErrors(testCase)
missingPath = fullfile(tempname,'missing.txt');
[data,message] = bispectralReadDataFile(missingPath);
verifyEmpty(testCase,data);
verifyNotEmpty(testCase,message);

temporaryFolder = tempname;
mkdir(temporaryFolder);
cleanup = onCleanup(@()removeTestFolder(temporaryFolder));
invalidPath = fullfile(temporaryFolder,'one-column.txt');
writematrix((0:3)',invalidPath);
[data,message] = bispectralReadDataFile(invalidPath);
verifyEmpty(testCase,data);
verifyNotEmpty(testCase,message);

validPath = fullfile(temporaryFolder,'two-column.txt');
expected = [(0:3)',[1;3;2;4]];
writematrix(expected,validPath);
[data,message] = bispectralReadDataFile(validPath);
verifyEmpty(testCase,message);
verifyEqual(testCase,data,expected);
end

function entries = listingFixture(names,modificationTimes,bytes)
template = struct('name','','folder','/tmp','date','', ...
    'bytes',0,'isdir',false,'datenum',0);
entries = repmat(template,1,numel(names));
for index = 1:numel(names)
    entries(index).name = names{index};
    entries(index).date = sprintf('date-%d',index);
    entries(index).bytes = bytes(index);
    entries(index).datenum = modificationTimes(index);
end
end

function seedMainListSelection(fig,listbox,index)
set(listbox,'Value',index);
setappdata(listbox,'ACListSelected',index);
setappdata(listbox,'ACListAnchor',index);
setappdata(listbox,'ACListLastClickIndex',index);
setappdata(listbox,'ACListLastClickTic',tic);
handles = guidata(fig);
handles.index_selected = index;
handles.plot_selected = index;
handles.nplot = 1;
guidata(fig,handles);
end

function verifyMainListSelectionCleared(testCase,fig,listbox,expectedNames)
actualNames = reshape(cellstr(get(listbox,'String')),1,[]);
expectedNames = reshape(cellstr(expectedNames),1,[]);
verifyEqual(testCase,actualNames,expectedNames);
verifyEmpty(testCase,get(listbox,'Value'));
verifyEmpty(testCase,getappdata(listbox,'ACListSelected'));
verifyEmpty(testCase,getappdata(listbox,'ACListAnchor'));
verifyEmpty(testCase,getappdata(listbox,'ACListLastClickIndex'));
verifyEmpty(testCase,getappdata(listbox,'ACListLastClickTic'));

userdata = get(listbox,'UserData');
verifyTrue(testCase,isstruct(userdata));
verifyEqual(testCase,reshape(cellstr(userdata.names),1,[]),expectedNames);

handles = guidata(fig);
if isfield(handles,'index_selected')
    verifyEmpty(testCase,handles.index_selected);
end
if isfield(handles,'plot_selected')
    verifyEmpty(testCase,handles.plot_selected);
end
if isfield(handles,'nplot')
    verifyEqual(testCase,handles.nplot,1, ...
        'List refresh must not erase the copy/cut item count.');
end
end

function verifyMainListSelection( ...
        testCase,fig,listbox,expectedNames,expectedSelection)
actualNames = reshape(cellstr(get(listbox,'String')),1,[]);
expectedNames = reshape(cellstr(expectedNames),1,[]);
verifyEqual(testCase,actualNames,expectedNames);
verifyEqual(testCase,get(listbox,'Value'),expectedSelection);
verifyEqual(testCase,getappdata(listbox,'ACListSelected'),expectedSelection);

userdata = get(listbox,'UserData');
verifyEqual(testCase,reshape(cellstr(userdata.names),1,[]),expectedNames);
handles = guidata(fig);
verifyEqual(testCase,handles.index_selected,expectedSelection);
verifyEqual(testCase,handles.plot_selected,expectedSelection);
end

function verifyNativeValueIsInRange(testCase,listbox)
names = cellstr(get(listbox,'String'));
value = get(listbox,'Value');
verifyTrue(testCase,isempty(value) || ...
    all(value >= 1 & value <= numel(names)), ...
    'The native listbox Value must refer to the refreshed String.');
end

function createTextFile(filename)
fileID = fopen(filename,'wt');
assert(fileID >= 0,'Unable to create the directory-refresh fixture.');
fileCleanup = onCleanup(@()fclose(fileID));
fprintf(fileID,'0 0\n');
end

function createNumericMatrixFile(filename,data)
fileID = fopen(filename,'wt');
assert(fileID >= 0,'Unable to create the numeric matrix fixture.');
fileCleanup = onCleanup(@()fclose(fileID));
fprintf(fileID,'%.17g %.17g\n',data.');
end

function cleanup = redirectAcycleSettingsToTemporaryFolder()
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
removeTestFolder(settingsRoot);
end

function removeTestFolder(folder)
if exist(folder,'dir') == 7
    rmdir(folder,'s');
end
end

function cleanupDirectoryRestoreFixture(originalDirectory,testRoot)
if isfolder(originalDirectory)
    cd(originalDirectory);
elseif isfolder(tempdir)
    cd(tempdir);
end
removeTestFolder(testRoot);
end

function deleteIfValid(value)
try
    if ~isempty(value) && isvalid(value)
        delete(value);
    end
catch
end
end
