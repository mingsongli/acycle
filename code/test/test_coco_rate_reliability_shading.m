function tests = test_coco_rate_reliability_shading
%TEST_COCO_RATE_RELIABILITY_SHADING Nyquist/Rayleigh shading invariants.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
oldPath = path;
addpath(genpath(fullfile(repoRoot,'code')));
testCase.addTeardown(@()path(oldPath));

oldVisibility = get(groot,'defaultFigureVisible');
set(groot,'defaultFigureVisible','off');
testCase.addTeardown(@()set(groot,'defaultFigureVisible',oldVisibility));

periods = [405.6912;130.6979;123.8532;98.8517;94.8856; ...
    40.9897;23.6820;22.3758;18.9519];
timeKyr = (0:4:1600)';
trueRate = 9;
depth = timeKyr*trueRate/100;
value = zeros(size(timeKyr));
for periodIndex = 1:numel(periods)
    value = value + (1-0.05*periodIndex)*sin( ...
        2*pi*timeKyr/periods(periodIndex)+0.23*periodIndex);
end
value = value+0.08*sin(2*pi*timeKyr/61)+0.001*depth;

testCase.TestData.periods = periods;
testCase.TestData.data = [depth,value];
testCase.TestData.spacing = median(diff(depth));
testCase.TestData.pad = 1024;
testCase.TestData.rateRange = [1 50 1];
testCase.TestData.maxFrequency = 1.2*max(1./periods);
end

function teardown(testCase) %#ok<INUSD>
close(findall(groot,'Type','figure'));
end

function testAllPeriodRangeUsesExactNyquistAndRayleighBoundaries(testCase)
periods = [405.6912;130.6979;123.8532;98.8517;94.8856; ...
    40.9897;23.6820;22.3758;18.9519];
spacing = 0.2;
sampleCount = 731;

actual = cocoAllPeriodRateRange(periods,spacing,sampleCount);
expected = [200*spacing/min(periods), ...
    100*sampleCount*spacing/max(periods)];
verifyEqual(testCase,actual,expected,'AbsTol',0);

rayleigh = 1/(sampleCount*spacing);
nyquist = 1/(2*spacing);
atLower = 100./(periods*actual(1));
aboveLower = 100./(periods*(actual(1)*(1+1e-10)));
atUpper = 100./(periods*actual(2));
aboveUpper = 100./(periods*(actual(2)*(1+1e-10)));

verifyFalse(testCase,all(atLower >= rayleigh & atLower < nyquist));
verifyTrue(testCase,all(aboveLower >= rayleigh & aboveLower < nyquist));
verifyTrue(testCase,all(atUpper >= rayleigh & atUpper < nyquist));
verifyFalse(testCase,all(aboveUpper >= rayleigh & aboveUpper < nyquist));
end

function testShadingDrawsBothSidesWithoutLegendExplanation(testCase)
fig = figure('Visible','off');
ax = axes(fig);
xlim(ax,[1 50]);
ylim(ax,[0 9.5]);
hold(ax,'on');

patches = cocoShadeOutsideAllPeriodRange(ax,1:50,[3.5 42.25]);
curve = plot(ax,1:50,9*ones(1,50),'b-', ...
    'DisplayName','Resolvable periods');
legend(ax,'show');

verifyNumElements(testCase,patches,2);
left = patches(1);
right = patches(2);
verifyEqual(testCase,left.XData(:),[1;3.5;3.5;1],'AbsTol',0);
verifyEqual(testCase,right.XData(:),[42.25;50;50;42.25],'AbsTol',0);
verifyEqual(testCase,left.YData(:),[0;0;9.5;9.5],'AbsTol',0);
verifyEqual(testCase,right.YData(:),[0;0;9.5;9.5],'AbsTol',0);
verifyEqual(testCase,left.FaceColor,[0.88 0.88 0.88],'AbsTol',0);
verifyEqual(testCase,right.FaceColor,[0.88 0.88 0.88],'AbsTol',0);
verifyEqual(testCase,left.FaceAlpha,0.55,'AbsTol',0);
verifyEqual(testCase,right.FaceAlpha,0.55,'AbsTol',0);
verifyEqual(testCase,left.EdgeColor,'none');
verifyEqual(testCase,right.EdgeColor,'none');
verifyEqual(testCase,left.HandleVisibility,'off');
verifyEqual(testCase,right.HandleVisibility,'off');
verifyEmpty(testCase,left.DisplayName);
verifyEmpty(testCase,right.DisplayName);
verifyEqual(testCase,left.Tag,'COCO-unreliable-rate-shading');
verifyEqual(testCase,right.Tag,'COCO-unreliable-rate-shading');

children = allchild(ax);
curveIndex = find(children == curve,1);
patchIndices = arrayfun(@(h)find(children == h,1),patches);
verifyLessThan(testCase,curveIndex,min(patchIndices));

legendObject = findobj(fig,'Type','legend');
verifyNumElements(testCase,legendObject,1);
verifyEqual(testCase,string(legendObject.String),"Resolvable periods");
end

function testShadingCoversAxesLimitBeyondFinalRateGridPoint(testCase)
fig = figure('Visible','off');
ax = axes(fig);
xlim(ax,[1 50]);
ylim(ax,[0 9.5]);
hold(ax,'on');

% This grid stops at 49 because six does not divide the requested span.
rateGrid = 1:6:50;
verifyEqual(testCase,rateGrid(end),49);
patches = cocoShadeOutsideAllPeriodRange(ax,rateGrid,[3.5 42.25]);

verifyNumElements(testCase,patches,2);
verifyEqual(testCase,patches(1).XData(:),[1;3.5;3.5;1],'AbsTol',0);
verifyEqual(testCase,patches(2).XData(:),[42.25;50;50;42.25], ...
    'AbsTol',0);
end

function testNoOverlapShadesTheWholeDisplayedRateRange(testCase)
fig = figure('Visible','off');
ax = axes(fig);
xlim(ax,[1 50]);
ylim(ax,[0 9.5]);
hold(ax,'on');

patches = cocoShadeOutsideAllPeriodRange(ax,1:50,[12 8]);

verifyNumElements(testCase,patches,1);
verifyEqual(testCase,patches.XData(:),[1;50;50;1],'AbsTol',0);
verifyEqual(testCase,patches.YData(:),[0;0;9.5;9.5],'AbsTol',0);
verifyEqual(testCase,patches.HandleVisibility,'off');
end

function testFullySupportedRangeDrawsNoPatch(testCase)
fig = figure('Visible','off');
ax = axes(fig);
xlim(ax,[1 50]);
ylim(ax,[0 9.5]);
hold(ax,'on');

patches = cocoShadeOutsideAllPeriodRange(ax,1:50,[0.5 60]);

verifyEmpty(testCase,patches);
verifyEmpty(testCase,findall(ax,'Type','patch', ...
    'Tag','COCO-unreliable-rate-shading'));
end

function testHeldOutPlotPathsUseUnlabelledContinuousShading(testCase)
data = testCase.TestData.data;
periods = testCase.TestData.periods;
pad = testCase.TestData.pad;
rate = testCase.TestData.rateRange;
common = {'MaxFrequency',testCase.TestData.maxFrequency, ...
    'Seed',8117,'BatchSize',1,'Verbose',false};

cv = cvcoco9B(data,periods,pad,rate(1),rate(2),rate(3), ...
    0,1,'Pearson',common{:});
cvFigure = plotcvcoco(cv,'ShowSpectra',false,'Tabbed',true);
verifyIntegratedShading(testCase,cvFigure, ...
    cv.allNineRateRangeShared,rate(1),rate(2));
close(cvFigure);

interleaved = interleavedcvcoco( ...
    data,periods,pad,rate(1),rate(2),rate(3), ...
    0,1,'Pearson',common{:});
interleavedFigure = plotcvcoco( ...
    interleaved,'ShowSpectra',false,'Tabbed',true);
verifyIntegratedShading(testCase,interleavedFigure, ...
    interleaved.allNineRateRangeShared,rate(1),rate(2));
close(interleavedFigure);
end

function testAdaptiveAndFixedPlotPathsUseEffectiveRecordShading(testCase)
data = testCase.TestData.data;
periods = testCase.TestData.periods;
spacing = testCase.TestData.spacing;
pad = testCase.TestData.pad;
rate = testCase.TestData.rateRange;
fmaxData = 1/(2*spacing);

for mode = {'adaptive9b','fixed9'}
    figuresBefore = findall(groot,'Type','figure');
    [corrCI,corrH0,~,details] = corrcoefslices_rankNew( ...
        data,periods,spacing,pad,rate(1),rate(2),rate(3), ...
        0,0,1,1,1,'Pearson',fmaxData,0,false,mode{1}, ...
        'MaxFrequency',testCase.TestData.maxFrequency, ...
        'Seed',9131,'ShowPeriodograms',true);
    drawnow;
    figuresAfter = findall(groot,'Type','figure');
    newFigures = figuresAfter(~ismember(figuresAfter,figuresBefore));
    verifyNumElements(testCase,newFigures,1);
    verifyIntegratedShading(testCase,newFigures, ...
        details.allNineRateRange,rate(1),rate(2));
    expectedRange = cocoAllPeriodRateRange( ...
        periods,details.samplingInterval, ...
        details.effectiveSpectrumSampleCount);
    verifyEqual(testCase,details.allNineRateRange,expectedRange,'AbsTol',0);
    verifyEqual(testCase,details.effectiveSpectrumSampleCount, ...
        size(data,1));
    legends = findall(newFigures,'Type','legend');
    verifyNumElements(testCase,legends,1);
    verifyEqual(testCase,legends.NumColumns,1);
    verifyEqual(testCase,legends.Orientation,'vertical');
    verifyFullRecordFourPanelStyle(testCase,newFigures,1,NaN);
    close(newFigures);

    [bestCorrelation,bestIndex] = max(corrCI(:,2),[],'omitnan');
    report = struct('bestRate',corrCI(bestIndex,1), ...
        'bestCorrelation',bestCorrelation, ...
        'minimumGlobalP',min(corrH0(:,1),[],'omitnan'));
    publicationFigures = plotAdaptiveCocoPublication( ...
        corrCI,corrH0,details,report,'Visible','off', ...
        'TitlePrefix',mode{1});
    verifyIntegratedShading(testCase,publicationFigures(1), ...
        details.allNineRateRange,rate(1),rate(2));
    verifyFullRecordFourPanelStyle( ...
        testCase,publicationFigures(1),1.25,2);
    close(publicationFigures);
end
end

function verifyFullRecordFourPanelStyle( ...
        testCase,figureHandle,expectedLineWidth,expectedMarkerSize)
axisTags = {'COCO-correlation','AdaptiveCOCO-global-p', ...
    'AdaptiveCOCO-local-p','COCO-orbit-count'};
titles = {'Correlation coefficient','Global p','Local p', ...
    'Number of contributing astronomical parameters'};
yLabels = {'\rho','Global p','Local p','#'};
colors = {[1 0 0],[1 0 0],[1 0 0],[0 0 1]};
for axisIndex = 1:numel(axisTags)
    ax = findall(figureHandle,'Type','axes','Tag',axisTags{axisIndex});
    verifyNumElements(testCase,ax,1);
    verifyEqual(testCase,ax.Layout.Tile,axisIndex);
    verifyEqual(testCase,ax.Title.String,titles{axisIndex});
    verifyEqual(testCase,ax.YLabel.String,yLabels{axisIndex});
    candidates = findall(ax,'Color',colors{axisIndex});
    candidates = candidates(arrayfun(@(item) ...
        isprop(item,'LineStyle') && strcmp(item.LineStyle,'-') && ...
        isprop(item,'LineWidth'),candidates));
    verifyNumElements(testCase,candidates,1);
    verifyEqual(testCase,candidates.LineWidth, ...
        expectedLineWidth,'AbsTol',0);
end

peak = findall(figureHandle,'Type','line', ...
    'Tag','COCO-correlation-peak');
if isfinite(expectedMarkerSize)
    verifyNumElements(testCase,peak,1);
    verifyEqual(testCase,peak.MarkerSize,expectedMarkerSize,'AbsTol',0);
    verifyEqual(testCase,peak.Color,[1 0 0],'AbsTol',0);
else
    verifyEmpty(testCase,peak);
end
end

function testSlicesUseSliceLengthRatherThanFullRecordLength(testCase)
data = testCase.TestData.data;
periods = testCase.TestData.periods;
spacing = testCase.TestData.spacing;
rate = testCase.TestData.rateRange;
% Equal-duration half-open/closed slicing of this uniform odd-length test
% record gives one extra endpoint to the second (longest) slice.
expectedCount = ceil(size(data,1)/2);

[~,~,~,details] = corrcoefslices_rankNew( ...
    data,periods,spacing,testCase.TestData.pad, ...
    rate(1),rate(2),rate(3),0,0,0,0,2,'Pearson', ...
    1/(2*spacing),0,false,'adaptive9b', ...
    'MaxFrequency',testCase.TestData.maxFrequency, ...
    'Seed',10103,'ShowPeriodograms',false);

verifyEqual(testCase,details.effectiveSpectrumSampleCount,expectedCount);
verifyLessThan(testCase,details.effectiveSpectrumSampleCount,size(data,1));
expectedRange = cocoAllPeriodRateRange( ...
    periods,details.samplingInterval,expectedCount);
verifyEqual(testCase,details.allNineRateRange,expectedRange,'AbsTol',0);
verifyEqual(testCase,details.effectiveSpectrumLength, ...
    expectedCount*details.samplingInterval,'AbsTol',0);
end

function verifyIntegratedShading(testCase,fig,expectedRange,sr1,sr2)
orbitAxes = findall(fig,'Type','axes','Tag','COCO-orbit-count');
verifyNumElements(testCase,orbitAxes,1);
patches = findall(orbitAxes,'Type','patch', ...
    'Tag','COCO-unreliable-rate-shading');
verifyNumElements(testCase,patches,2);

leftEdges = arrayfun(@(h)min(h.XData),patches);
[~,order] = sort(leftEdges);
patches = patches(order);
tolerance = 2e-13*max(1,max(abs(expectedRange)));
verifyEqual(testCase,patches(1).XData(:), ...
    [sr1;expectedRange(1);expectedRange(1);sr1], ...
    'AbsTol',tolerance);
verifyEqual(testCase,patches(2).XData(:), ...
    [expectedRange(2);sr2;sr2;expectedRange(2)], ...
    'AbsTol',tolerance);
verifyEqual(testCase,{patches.HandleVisibility},{'off','off'});
verifyEqual(testCase,{patches.DisplayName},{'',''});

legendObjects = findall(fig,'Type','legend');
for legendIndex = 1:numel(legendObjects)
    text = lower(strjoin(string(legendObjects(legendIndex).String),' '));
    verifyFalse(testCase,contains(text,'outside'));
    verifyFalse(testCase,contains(text,'unreliable'));
    verifyFalse(testCase,contains(text,'period range'));
end
end
