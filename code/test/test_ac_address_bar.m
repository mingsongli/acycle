function tests = test_ac_address_bar
%TEST_AC_ADDRESS_BAR Regression tests for main-window path editing.
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

function testCommandPasteReplacesAddressAndPreservesUnicode(testCase)
editBox = newAddressBar();
expected = '/tmp/含 中文/space folder';
eventData = struct('Key','v','Modifier',{{'command'}});

handled = AC('AddressBarKeyRelease',editBox,eventData,@()expected);

verifyTrue(testCase,handled);
verifyEqual(testCase,get(editBox,'String'),expected);
end

function testControlPasteRemovesOnlyTrailingLineEndings(testCase)
editBox = newAddressBar();
expected = ' C:\Research Folder\中文 ';
clipboardText = [expected,sprintf('\r\n')];
eventData = struct('Key','v','Modifier',{{'control'}});

handled = AC('AddressBarKeyRelease', ...
    editBox,eventData,@()clipboardText);

verifyTrue(testCase,handled);
verifyEqual(testCase,get(editBox,'String'),expected);
end

function testPasteWithoutShortcutModifierDoesNothing(testCase)
editBox = newAddressBar();
eventData = struct('Key','v','Modifier',{{}});

handled = AC('AddressBarKeyRelease', ...
    editBox,eventData,@()'/tmp/new');

verifyFalse(testCase,handled);
verifyEqual(testCase,get(editBox,'String'),'original');
end

function testFileMenusDoNotCaptureTextClipboardShortcuts(testCase)
[~,handles] = AC('AC_buildCodeUI');

verifyEqual(testCase,get(handles.menu_cut,'Accelerator'),'');
verifyEqual(testCase,get(handles.menu_copy,'Accelerator'),'');
verifyEqual(testCase,get(handles.menu_paste,'Accelerator'),'');
verifyNotEmpty(testCase,get( ...
    handles.edit_acfigmain_dir,'KeyReleaseFcn'));
end

function testPasteMenuUsesClipboardWhenAddressBarHasFocus(testCase)
[fig,handles] = AC('AC_buildCodeUI');
expected = '/tmp/menu paste/中文';
set(fig,'CurrentObject',handles.edit_acfigmain_dir);

handled = AC('AddressBarMenuShortcut', ...
    handles,'v',@()expected);

verifyTrue(testCase,handled);
verifyEqual(testCase, ...
    get(handles.edit_acfigmain_dir,'String'),expected);
end

function editBox = newAddressBar()
fig = figure('Visible','off');
editBox = uicontrol(fig,'Style','edit','String','original');
end
