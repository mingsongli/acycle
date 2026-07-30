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
