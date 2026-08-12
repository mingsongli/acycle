function tests = test_unittest_gui
%TEST_UNITTEST_GUI Regression tests for the one-sample t-test plot.

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
testCase.addTeardown(@()set(groot, ...
    'DefaultFigureVisible',oldVisibility));
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

function testCriticalLinesAreDistinctAndStableAfterButtonClick(testCase)
Unittest((1:10)');

plotFigure = getTTestFigure('Acycle: t test plot');
[upperLine,lowerLine] = getCriticalLines(plotFigure);
initialUpperColor = upperLine.Color;
initialLowerColor = lowerLine.Color;

verifyNotEqual(testCase,initialUpperColor,initialLowerColor);
verifyEqual(testCase,upperLine.LineStyle,'--');
verifyEqual(testCase,lowerLine.LineStyle,'--');

summaryFigure = getTTestFigure('Acycle: t test summary');
pressTTestButton(summaryFigure);

[upperLine,lowerLine] = getCriticalLines(plotFigure);
verifyEqual(testCase,upperLine.Color,initialUpperColor,'AbsTol',0);
verifyEqual(testCase,lowerLine.Color,initialLowerColor,'AbsTol',0);
verifyNotEqual(testCase,upperLine.Color,lowerLine.Color);

legendObject = findobj(plotFigure,'Tag','TTestLegend');
verifyNumElements(testCase,legendObject,1);
verifyNumElements(testCase,legendObject.String,4);
verifyTrue(testCase,any(contains(string(legendObject.String), ...
    "Observed t =")));
end

function testPlotRangeIsInvariantToChangingTheDataOrigin(testCase)
data = [995;1000;1005];
Unittest(data);
summaryFigure = getTTestFigure('Acycle: t test summary');
setGivenMeanAndRun(summaryFigure,1000);
plotFigure = getTTestFigure('Acycle: t test plot');
firstLimits = getTTestAxes(plotFigure).XLim;

Unittest(data+1000);
summaryFigure = getTTestFigure('Acycle: t test summary');
setGivenMeanAndRun(summaryFigure,2000);
plotFigure = getTTestFigure('Acycle: t test plot');
secondLimits = getTTestAxes(plotFigure).XLim;

verifyEqual(testCase,secondLimits,firstLimits,'AbsTol',1e-12);
verifyLessThan(testCase,diff(secondLimits),25);
end

function testExtremeObservedTIsClippedWithoutStretchingAxes(testCase)
data = (99:101)';
Unittest(data);

plotFigure = getTTestFigure('Acycle: t test plot');
axesHandle = getTTestAxes(plotFigure);
observedLine = findobj(plotFigure,'Tag','TTestObserved');

verifyNumElements(testCase,observedLine,1);
verifyGreaterThan(testCase,abs(observedLine.UserData),100);
verifyLessThan(testCase,diff(axesHandle.XLim),25);
verifyLessThan(testCase,abs(observedLine.Value),max(abs(axesHandle.XLim)));

legendObject = findobj(plotFigure,'Tag','TTestLegend');
verifyTrue(testCase,any(contains(string(legendObject.String), ...
    "outside displayed range")));
end

function testLowDegreesOfFreedomKeepsCriticalLinesInRange(testCase)
Unittest([0;1]);

plotFigure = getTTestFigure('Acycle: t test plot');
axesHandle = getTTestAxes(plotFigure);
[upperLine,lowerLine] = getCriticalLines(plotFigure);
distributionLine = findobj(plotFigure,'Tag','TTestDistribution');

verifyGreaterThan(testCase,axesHandle.XLim(2),upperLine.Value);
verifyLessThan(testCase,axesHandle.XLim(1),lowerLine.Value);
verifyEqual(testCase,[min(distributionLine.XData), ...
    max(distributionLine.XData)],axesHandle.XLim,'AbsTol',1e-12);
end

function testInvalidGivenMeanDoesNotReplaceExistingResults(testCase)
Unittest((1:5)');

summaryFigure = getTTestFigure('Acycle: t test summary');
plotFigure = getTTestFigure('Acycle: t test plot');
tableHandle = findobj(summaryFigure,'Tag','TTestSummaryTable');
meanInput = findobj(summaryFigure,'Tag','TTestGivenMean');
initialTableData = tableHandle.Data;
initialDistribution = findobj(plotFigure,'Tag','TTestDistribution');
initialXData = initialDistribution.XData;

set(meanInput,'String','not a number');
pressTTestButton(summaryFigure);

verifyEqual(testCase,tableHandle.Data,initialTableData);
distributionLine = findobj(plotFigure,'Tag','TTestDistribution');
verifyEqual(testCase,distributionLine.XData,initialXData,'AbsTol',0);

dialogHandle = findall(groot,'Type','figure','Name','Invalid given mean');
verifyNumElements(testCase,dialogHandle,1);
delete(dialogHandle);
end

function figureHandle = getTTestFigure(figureName)
figureHandle = findall(groot,'Type','figure','Name',figureName);
assert(isscalar(figureHandle), ...
    'Expected exactly one figure named "%s".',figureName);
end

function axesHandle = getTTestAxes(plotFigure)
axesHandle = findobj(plotFigure,'Type','axes','Tag','TTestAxes');
assert(isscalar(axesHandle),'Expected exactly one t-test axes.');
end

function [upperLine,lowerLine] = getCriticalLines(plotFigure)
upperLine = findobj(plotFigure,'Tag','TTestUpperCritical');
lowerLine = findobj(plotFigure,'Tag','TTestLowerCritical');
assert(isscalar(upperLine),'Expected exactly one upper critical line.');
assert(isscalar(lowerLine),'Expected exactly one lower critical line.');
end

function setGivenMeanAndRun(summaryFigure,givenMean)
meanInput = findobj(summaryFigure,'Tag','TTestGivenMean');
assert(isscalar(meanInput),'Expected exactly one given-mean input.');
set(meanInput,'String',num2str(givenMean));
pressTTestButton(summaryFigure);
end

function pressTTestButton(summaryFigure)
button = findobj(summaryFigure,'Tag','TTestRunButton');
assert(isscalar(button),'Expected exactly one t-test button.');
callback = get(button,'Callback');
callback(button,[]);
drawnow;
end
