function tests = test_ecocoplot_adaptive_graphics
%TEST_ECOCOPLOT_ADAPTIVE_GRAPHICS Regression tests for eCOCO plot semantics.
%
% These tests intentionally inspect graphics objects rather than exported
% pixels.  They protect the scientific mapping (p limits, significance
% boundaries, and score normalization) independently of font rendering or
% operating-system antialiasing.

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
testCase.addTeardown(@()set(groot,'DefaultFigureVisible',oldVisibility));
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

function testAdaptivePScalesAndSignificanceBoundaries(testCase)
fixture = plotFixture();
details = struct('method','adaptive','pLocal',fixture.localP, ...
    'trackedSedimentationRate',fixture.trackedRate);

ecocoplot(fixture.rates,fixture.depths,fixture.rho,fixture.localP, ...
    fixture.globalP,fixture.empty,fixture.score,fixture.nOrbit,1,details);
fig = figureWithPanelTitle(testCase,"Local p");

verifyPanelTitles(testCase,fig,["Correlation coefficient", ...
    "Global p","Local p","Contributing orbital periods"]);
localAxis = axisWithTitle(testCase,fig,"Local p");
globalAxis = axisWithTitle(testCase,fig,"Global p");

verifyEqual(testCase,localAxis.CLim,[0 -log10(0.005)], ...
    'AbsTol',32*eps);
verifyEqual(testCase,globalAxis.CLim,[0 -log10(0.02)], ...
    'AbsTol',32*eps);
verifyTrue(testCase,any(string( ...
    colorbarWithLabel(testCase,fig,"Local p").TickLabels) == "0.005"));
verifyTrue(testCase,any(string( ...
    colorbarWithLabel(testCase,fig,"Global p").TickLabels) == "0.02"));

localBoundary = significanceBoundary(localAxis);
globalBoundary = significanceBoundary(globalAxis);
verifyNumElements(testCase,localBoundary,1, ...
    'Local p must have one black p <= 0.01 boundary.');
verifyNumElements(testCase,globalBoundary,1, ...
    'Global p must have one black p <= 0.05 boundary.');
verifyEqual(testCase,localBoundary.LevelList,-log10(0.01), ...
    'AbsTol',64*eps);
verifyEqual(testCase,globalBoundary.LevelList,-log10(0.05), ...
    'AbsTol',64*eps);
verifyTrue(testCase,isBlack(localBoundary.LineColor));
verifyTrue(testCase,isBlack(globalBoundary.LineColor));
verifyEqual(testCase,localBoundary.LineWidth,0.6,'AbsTol',0);
verifyEqual(testCase,globalBoundary.LineWidth,0.6,'AbsTol',0);
end

function testFinalPanelIsAlwaysPlottedSeparately(testCase)
fixture = plotFixture();
% Old saved results may still contain false; the low-level plotting rule
% must override that stale preference.
details = struct('method','adaptive','pLocal',fixture.localP, ...
    'trackedSedimentationRate',fixture.trackedRate, ...
    'separateFinalPanel',false);

[~,figures] = ecocoplot(fixture.rates,fixture.depths,fixture.rho, ...
    fixture.localP,fixture.globalP,fixture.empty,fixture.score, ...
    fixture.nOrbit,1,details);

verifyNumElements(testCase,figures,2);
verifyPanelTitles(testCase,figures(1),["Correlation coefficient", ...
    "Global p","Local p","Contributing orbital periods"]);
verifyPanelTitles(testCase,figures(2),"Ridge score");
end

function testGroupedReverseDepthAppliesToBothFigures(testCase)
fixture = plotFixture();
details = struct('method','adaptive','pLocal',fixture.localP, ...
    'trackedSedimentationRate',fixture.trackedRate);

[~,figures] = ecocoplot(fixture.rates,fixture.depths,fixture.rho, ...
    fixture.localP,fixture.globalP,fixture.empty,fixture.score, ...
    fixture.nOrbit,-1,details);

verifyNumElements(testCase,figures,2);
for figureIndex = 1:2
    axesHandles = findall(figures(figureIndex),'Type','axes');
    verifyNotEmpty(testCase,axesHandles);
    verifyTrue(testCase,all(string({axesHandles.YDir}) == "reverse"));
end
end

function testThreeDimensionalSignificanceBoundariesUseHalfWidth(testCase)
fixture = plotFixture();
details = struct('method','adaptive','pLocal',fixture.localP, ...
    'trackedSedimentationRate',fixture.trackedRate);

[~,figures] = ecocoplot(fixture.rates,fixture.depths,fixture.rho, ...
    fixture.localP,fixture.globalP,fixture.empty,fixture.score, ...
    fixture.nOrbit,3,details);

verifyNumElements(testCase,figures,5);
localAxis = axisWithTitle(testCase, ...
    figureWithPanelTitle(testCase,"Local p"),"Local p");
globalAxis = axisWithTitle(testCase, ...
    figureWithPanelTitle(testCase,"Global p"),"Global p");
localBoundary = significanceBoundary(localAxis);
globalBoundary = significanceBoundary(globalAxis);
verifyNumElements(testCase,localBoundary,1);
verifyNumElements(testCase,globalBoundary,1);
for boundary = [localBoundary;globalBoundary].'
    verifyEqual(testCase,string(boundary.Tag), ...
        "eCOCO-significance-boundary");
    verifyEqual(testCase,boundary.LineWidth,0.6,'AbsTol',0);
end
end

function testFullySupportedConstantMapUsesVectorPatch(testCase)
fixture = plotFixture();
fixture.nOrbit(:) = 9;
details = struct('method','adaptive','pLocal',fixture.localP, ...
    'trackedSedimentationRate',fixture.trackedRate);

ecocoplot(fixture.rates,fixture.depths,fixture.rho,fixture.localP, ...
    fixture.globalP,fixture.empty,fixture.score,fixture.nOrbit,1,details);
fig = figureWithPanelTitle(testCase,"Contributing orbital periods");
orbitAxis = axisWithTitle(testCase,fig,"Contributing orbital periods");

verifyEmpty(testCase,findall(orbitAxis,'Type','image'), ...
    'A constant data panel must not become a raster image in vector PDF.');
verifyNumElements(testCase,findall(orbitAxis,'Type','patch'),1);
end

function testAdaptiveScoreBackgroundIsNormalizedByWindow(testCase)
fixture = plotFixture();
details = struct('method','adaptive','pLocal',fixture.localP, ...
    'trackedSedimentationRate',fixture.trackedRate);

ecocoplot(fixture.rates,fixture.depths,fixture.rho,fixture.localP, ...
    fixture.globalP,fixture.empty,fixture.score,fixture.nOrbit,1,details);
fig = figureWithPanelTitle(testCase,"Ridge score");
scoreAxis = axisWithTitle(testCase,fig,"Ridge score");
displayedScore = backgroundMatrix(scoreAxis,size(fixture.score.'));

expected = normalizeColumns(fixture.score).';
verifyEqual(testCase,displayedScore,expected,'AbsTol',64*eps);
verifyEqual(testCase,scoreAxis.CLim,[0 1],'AbsTol',0);
for windowIndex = 1:size(expected,1)
    values = expected(windowIndex,isfinite(expected(windowIndex,:)));
    verifyEqual(testCase,min(values),0,'AbsTol',64*eps);
    verifyEqual(testCase,max(values),1,'AbsTol',64*eps);
end
end

function testAdaptiveTrackedRidgeUsesLocalPSignificanceMarkers(testCase)
fixture = plotFixture();
details = struct('method','adaptive','pLocal',fixture.localP, ...
    'trackedSedimentationRate',fixture.trackedRate);

ecocoplot(fixture.rates,fixture.depths,fixture.rho,fixture.localP, ...
    fixture.globalP,fixture.empty,fixture.score,fixture.nOrbit,1,details);
fig = figureWithPanelTitle(testCase,"Ridge score");
scoreAxis = axisWithTitle(testCase,fig,"Ridge score");
ridge = trackedRidge(scoreAxis);

verifyNumElements(testCase,ridge,1);
verifyEqual(testCase,ridge.XData(:),fixture.trackedRate,'AbsTol',0);
verifyEqual(testCase,ridge.YData(:),fixture.depths,'AbsTol',0);
verifyTrue(testCase,isRed(ridge.Color));
verifyEqual(testCase,string(ridge.LineStyle),"-");
verifyEqual(testCase,ridge.LineWidth,1.0,'AbsTol',0);
verifyEqual(testCase,string(ridge.Marker),"none");
verifyRidgeMarkers(testCase,scoreAxis,2,1,1);
end

function testBlockedFivePanelsUseConsensusAndFilledPoints(testCase)
fixture = plotFixture();
details = struct();
details.method = 'crossfit';
details.forward = struct('rho',fixture.rho);
details.backward = struct('rho',flipud(fixture.rho));
consensusRho = min(details.forward.rho,details.backward.rho);
details.consensus = struct('rho',consensusRho, ...
    'pLocal',fixture.localP, ...
    'pGlobal',fixture.globalP, ...
    'nOrbit',fixture.nOrbit,'score',fixture.score);
details.trackedSedimentationRate = fixture.trackedRate;

% Deliberately conflicting OUT_EP verifies that nested consensus Local p
% takes precedence in the Blocked plotting contract.
ecocoplot(fixture.rates,fixture.depths,fixture.rho,0.5*ones(4), ...
    fixture.globalP,fixture.empty,fixture.score,fixture.nOrbit,1,details);
mainFig = figureWithPanelTitle(testCase,"Local p");
scoreFig = figureWithPanelTitle(testCase,"Ridge score");

verifyEqual(testCase,string(mainFig.Name),"Blocked eCOCO");
verifyPanelTitles(testCase,mainFig,["Consensus correlation", ...
    "Global p","Local p", ...
    "Contributing orbital periods"]);
verifyPanelTitles(testCase,scoreFig,"Ridge score");
consensusAxis = axisWithTitle(testCase,mainFig,"Consensus correlation");
localAxis = axisWithTitle(testCase,mainFig,"Local p");
globalAxis = axisWithTitle(testCase,mainFig,"Global p");
scoreAxis = axisWithTitle(testCase,scoreFig,"Ridge score");
verifyEqual(testCase,backgroundMatrix( ...
    consensusAxis,size(consensusRho.')),consensusRho.','AbsTol',64*eps);
verifyEqual(testCase,localAxis.CLim,[0 -log10(0.005)], ...
    'AbsTol',64*eps);
verifyEqual(testCase,globalAxis.CLim,[0 -log10(0.02)], ...
    'AbsTol',64*eps);
localBoundary = significanceBoundary(localAxis);
globalBoundary = significanceBoundary(globalAxis);
verifyNumElements(testCase,localBoundary,1);
verifyNumElements(testCase,globalBoundary,1);
verifyEqual(testCase,localBoundary.LevelList,-log10(0.01), ...
    'AbsTol',64*eps);
verifyEqual(testCase,globalBoundary.LevelList,-log10(0.05), ...
    'AbsTol',64*eps);
verifyEqual(testCase,backgroundMatrix(scoreAxis,size(fixture.score.')), ...
    normalizeColumns(fixture.score).','AbsTol',64*eps);
verifyEqual(testCase,scoreAxis.CLim,[0 1],'AbsTol',0);

ridge = trackedRidge(scoreAxis);
verifyNumElements(testCase,ridge,1);
verifyEqual(testCase,ridge.XData(:),fixture.trackedRate,'AbsTol',0);
verifyEqual(testCase,ridge.YData(:),fixture.depths,'AbsTol',0);
verifyTrue(testCase,isRed(ridge.Color));
verifyEqual(testCase,ridge.LineWidth,1.0,'AbsTol',0);
verifyEqual(testCase,string(ridge.Marker),"none");
verifyRidgeMarkers(testCase,scoreAxis,2,1,1);
end

function testInterleavedUsesOddEvenLabelsAndTwoFigureLayout(testCase)
fixture = plotFixture();
details = struct();
details.method = 'interleaved';
details.forward = struct('rho',fixture.rho);
details.backward = struct('rho',flipud(fixture.rho));
details.oddToEven = details.forward;
details.evenToOdd = details.backward;
consensusRho = min(details.forward.rho,details.backward.rho);
details.consensus = struct('rho',consensusRho, ...
    'pLocal',fixture.localP, ...
    'pGlobal',fixture.globalP,'nOrbit',fixture.nOrbit, ...
    'score',fixture.score);
details.trackedSedimentationRate = fixture.trackedRate;

[~,figures] = ecocoplot(fixture.rates,fixture.depths,fixture.rho, ...
    fixture.localP,fixture.globalP,fixture.empty,fixture.score, ...
    fixture.nOrbit,1,details);

verifyNumElements(testCase,figures,2);
verifyEqual(testCase,string(figures(1).Name),"Interleaved eCOCO");
verifyPanelTitles(testCase,figures(1),["Consensus correlation", ...
    "Global p","Local p", ...
    "Contributing orbital periods"]);
verifyPanelTitles(testCase,figures(2),"Ridge score");
verifyEqual(testCase,backgroundMatrix(axisWithTitle( ...
    testCase,figures(1),"Consensus correlation"), ...
    size(consensusRho.')),consensusRho.','AbsTol',64*eps);
verifyEqual(testCase,significanceBoundary( ...
    axisWithTitle(testCase,figures(1),"Local p")).LineWidth, ...
    0.6,'AbsTol',0);
verifyEqual(testCase,significanceBoundary( ...
    axisWithTitle(testCase,figures(1),"Global p")).LineWidth, ...
    0.6,'AbsTol',0);
end

function testDynamicPScaleRespectsMonteCarloFloor(testCase)
fixture = plotFixture();
localWithZeros = fixture.localP;
localWithZeros(localWithZeros <= 0.01) = 0;
details = struct('method','adaptive','pLocal',localWithZeros, ...
    'pFloor',0.02,'trackedSedimentationRate',fixture.trackedRate);

ecocoplot(fixture.rates,fixture.depths,fixture.rho,localWithZeros, ...
    fixture.globalP,fixture.empty,fixture.score,fixture.nOrbit,1,details);
fig = figureWithPanelTitle(testCase,"Local p");
localAxis = axisWithTitle(testCase,fig,"Local p");
verifyEqual(testCase,localAxis.CLim,[0 -log10(0.02)], ...
    'AbsTol',64*eps);
verifyEmpty(testCase,significanceBoundary(localAxis), ...
    'A raw zero cannot imply p <= 0.01 when MC resolution is p=0.02.');
end

function fixture = plotFixture()
fixture.rates = (1:4)';
fixture.depths = (10:10:40)';
fixture.rho = reshape(linspace(0.1,0.9,16),4,4);
% Both maps cross their requested threshold in two dimensions, ensuring
% MATLAB creates a real contour rather than an empty contour object.
fixture.localP = [ ...
    0.20 0.020 0.009 0.20; ...
    0.10 0.009 0.008 0.10; ...
    0.02 0.008 0.007 0.02; ...
    0.20 0.030 0.009 0.20];
fixture.globalP = [ ...
    0.20 0.080 0.040 0.20; ...
    0.10 0.060 0.035 0.10; ...
    0.06 0.040 0.034 0.06; ...
    0.20 0.090 0.045 0.20];
% Each window deliberately has a different absolute offset and range.
fixture.score = [ ...
    10 400 -3 20; ...
    20 100  0 25; ...
    30 300  9 30; ...
    50 200  3 40];
fixture.nOrbit = [6 7 8 7;7 8 9 8;8 9 8 7;7 8 7 6];
fixture.trackedRate = [1;2;3;4];
fixture.empty = nan(4);
end

function normalized = normalizeColumns(values)
normalized = nan(size(values));
for columnIndex = 1:size(values,2)
    column = values(:,columnIndex);
    valid = isfinite(column);
    lower = min(column(valid));
    upper = max(column(valid));
    normalized(valid,columnIndex) = ...
        (column(valid)-lower)./(upper-lower);
end
end

function fig = figureWithPanelTitle(testCase,titleText)
figures = findall(groot,'Type','figure');
figures = setdiff(figures,testCase.TestData.figuresBefore);
matches = false(size(figures));
for figureIndex = 1:numel(figures)
    axesHandles = findall(figures(figureIndex),'Type','axes');
    for axisIndex = 1:numel(axesHandles)
        if string(axesHandles(axisIndex).Title.String) == titleText
            matches(figureIndex) = true;
            break
        end
    end
end
verifyEqual(testCase,sum(matches),1, ...
    sprintf('Expected exactly one figure containing "%s".',titleText));
fig = figures(matches);
end

function verifyPanelTitles(testCase,fig,expected)
axesHandles = findall(fig,'Type','axes');
actual = strings(numel(axesHandles),1);
for axisIndex = 1:numel(axesHandles)
    actual(axisIndex) = string(axesHandles(axisIndex).Title.String);
end
verifyEqual(testCase,sort(actual),sort(expected(:)));
end

function ax = axisWithTitle(testCase,fig,titleText)
axesHandles = findall(fig,'Type','axes');
matches = false(size(axesHandles));
for axisIndex = 1:numel(axesHandles)
    matches(axisIndex) = ...
        string(axesHandles(axisIndex).Title.String) == titleText;
end
verifyEqual(testCase,sum(matches),1, ...
    sprintf('Expected exactly one "%s" axes.',titleText));
ax = axesHandles(matches);
end

function boundaries = significanceBoundary(ax)
objects = findall(ax);
boundaries = gobjects(0);
for objectIndex = 1:numel(objects)
    object = objects(objectIndex);
    if isprop(object,'LevelList') && isprop(object,'LineColor') && ...
            isprop(object,'LineStyle') && ...
            string(object.LineStyle) ~= "none" && ...
            isBlack(object.LineColor)
        boundaries(end+1,1) = object; %#ok<AGROW>
    end
end
end

function matrix = backgroundMatrix(ax,expectedSize)
objects = findall(ax);
for objectIndex = 1:numel(objects)
    object = objects(objectIndex);
    if isprop(object,'ZData') && isprop(object,'LineStyle') && ...
            string(object.LineStyle) == "none" && ...
            isequal(size(object.ZData),expectedSize)
        matrix = object.ZData;
        return
    end
    if isprop(object,'CData') && isequal(size(object.CData),expectedSize)
        matrix = object.CData;
        return
    end
end
error('test_ecocoplot_adaptive_graphics:NoBackground', ...
    'Unable to locate the plotted background matrix.');
end

function ridge = trackedRidge(ax)
lines = findall(ax,'Type','line');
matches = false(size(lines));
for lineIndex = 1:numel(lines)
    matches(lineIndex) = string(lines(lineIndex).DisplayName) == ...
        "Tracked ridge";
end
ridge = lines(matches);
end

function verifyRidgeMarkers(testCase,ax,nHollow,nLocal,nGlobal)
markers = findall(ax,'Type','scatter');
verifyNumElements(testCase,markers,3);
isSquare = arrayfun(@(h)any(string(h.Marker)==["s","square"]),markers);
square = markers(isSquare);
circles = markers(~isSquare);
isHollow = false(size(circles));
for markerIndex = 1:numel(circles)
    faceColor = circles(markerIndex).MarkerFaceColor;
    isHollow(markerIndex) = (ischar(faceColor) || ...
        (isstring(faceColor) && isscalar(faceColor))) && ...
        string(faceColor) == "none";
end
hollow = circles(isHollow);
filled = setdiff(circles,hollow);
verifyNumElements(testCase,hollow,1);
verifyNumElements(testCase,filled,1);
verifyNumElements(testCase,square,1);
verifyNumElements(testCase,hollow.XData,nHollow);
verifyNumElements(testCase,filled.XData,nLocal);
verifyNumElements(testCase,square.XData,nGlobal);
verifyEqual(testCase,filled.SizeData/hollow.SizeData,1.2^2, ...
    'RelTol',64*eps);
verifyEqual(testCase,square.SizeData/hollow.SizeData,1.2^2, ...
    'RelTol',64*eps);
verifyEqual(testCase,hollow.LineWidth,0.6,'AbsTol',0);
verifyEqual(testCase,filled.LineWidth,0.6,'AbsTol',0);
verifyEqual(testCase,square.LineWidth,0.6,'AbsTol',0);
verifyTrue(testCase,isRed(hollow.MarkerEdgeColor));
verifyTrue(testCase,isRed(filled.MarkerEdgeColor));
verifyTrue(testCase,isRed(square.MarkerEdgeColor));
verifyTrue(testCase,isRed(filled.MarkerFaceColor));
verifyTrue(testCase,isRed(square.MarkerFaceColor));
end

function color = colorbarWithLabel(testCase,fig,labelText)
colors = findall(fig,'Type','colorbar');
matches = false(size(colors));
for colorIndex = 1:numel(colors)
    matches(colorIndex) = string(colors(colorIndex).Label.String) == labelText;
end
verifyEqual(testCase,sum(matches),1, ...
    sprintf('Expected exactly one "%s" colorbar.',labelText));
color = colors(matches);
end

function tf = isBlack(color)
tf = colorMatches(color,[0 0 0],"k");
end

function tf = isRed(color)
tf = colorMatches(color,[1 0 0],"r");
end

function tf = colorMatches(color,rgb,shortName)
if ischar(color) || (isstring(color) && isscalar(color))
    tf = string(color) == shortName;
else
    tf = isnumeric(color) && isequal(size(color),[1 3]) && ...
        all(abs(double(color)-rgb) <= 64*eps);
end
end
