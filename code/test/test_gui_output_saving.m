function tests = test_gui_output_saving
%TEST_GUI_OUTPUT_SAVING Regression tests for GUI figure/workbook exports.
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

function testTabbedFigureCopiesLegendWithAxes(testCase)
outputFolder = tempname;
mkdir(outputFolder);
testCase.addTeardown(@()removeFolder(outputFolder));
fig = figure('Visible','off','Name','Adaptive COCO diagnostics');
testCase.addTeardown(@()closeIfValid(fig));
tabs = uitabgroup(fig);

firstTab = uitab(tabs,'Title','Correlation and significance');
layout = tiledlayout(firstTab,2,1);
firstAxes = nexttile(layout);
plot(firstAxes,1:4,[1 3 2 4],'DisplayName','Correlation');
legend(firstAxes,'show');
secondAxes = nexttile(layout);
imagesc(secondAxes,peaks(8));
colorbar(secondAxes);

secondTab = uitab(tabs,'Title','Best-rate spectra');
spectrumAxes = axes(secondTab);
plot(spectrumAxes,1:4,[1 4 2 3],1:4,[2 1 4 3]);
legend(spectrumAxes,{'Data spectrum','Target spectrum'});
tabCountBefore = numel(findall(fig,'Type','uitab'));
axesCountBefore = numel(findall(fig,'Type','axes'));

dataFile = fullfile(outputFolder,'sample-Adaptive-COCO-1.xlsx');
saved = saveCocoGuiFigures(fig,dataFile);
verifyNumElements(testCase,saved,1);
verifyTrue(testCase,isgraphics(fig,'figure'));
verifyEqual(testCase,numel(findall(fig,'Type','uitab')),tabCountBefore);
verifyEqual(testCase,numel(findall(fig,'Type','axes')),axesCountBefore);
verifyTrue(testCase,isfile(saved.fig));
verifyTrue(testCase,isfile(saved.pdf));
verifyGreaterThan(testCase,dir(saved.pdf).bytes,0);

reopened = openfig(saved.fig,'invisible');
cleanup = onCleanup(@()closeIfValid(reopened));
verifyNumElements(testCase,findall(reopened,'Type','uitab'),2);
end

function testEcocoGroupedFiguresSaveMainAndRidgeFiles(testCase)
outputFolder = tempname;
mkdir(outputFolder);
testCase.addTeardown(@()removeFolder(outputFolder));
rates = (1:4)';
depths = (10:10:40)';
rho = reshape(linspace(0.1,0.9,16),4,4);
localP = [0.2 0.02 0.009 0.2;0.1 0.009 0.008 0.1; ...
    0.02 0.008 0.007 0.02;0.2 0.03 0.009 0.2];
globalP = [0.2 0.08 0.04 0.2;0.1 0.06 0.035 0.1; ...
    0.06 0.04 0.034 0.06;0.2 0.09 0.045 0.2];
score = reshape(1:16,4,4);
nOrbit = 6+mod(reshape(1:16,4,4),4);
details = struct('method','adaptive','pLocal',localP, ...
    'trackedSedimentationRate',rates);
[~,figures] = ecocoplot(rates,depths,rho,localP,globalP,nan(4), ...
    score,nOrbit,1,details);
testCase.addTeardown(@()closeFigures(figures));

verifyEqual(testCase,figures(1).Position(4),780,'AbsTol',0);
verifyEqual(testCase, ...
    getappdata(figures(1),'eCOCOGroupedContentScale'),0.95,'AbsTol',0);
mainLayout = findall(figures(1),'-isa', ...
    'matlab.graphics.layout.TiledChartLayout');
verifyEmpty(testCase,mainLayout);
mainAxes = findall(figures(1),'Type','axes');
verifyNumElements(testCase,mainAxes,4);
for axisIndex = 1:numel(mainAxes)
    verifyEqual(testCase,string(mainAxes(axisIndex).Title.Visible),"off");
    verifyEqual(testCase,string(mainAxes(axisIndex).XLabel.Visible),"off");
    originalFontSize = getappdata( ...
        mainAxes(axisIndex),'eCOCOOriginalFontSize');
    verifyEqual(testCase,mainAxes(axisIndex).FontSize, ...
        originalFontSize,'AbsTol',64*eps);
    originalPosition = getappdata( ...
        mainAxes(axisIndex),'eCOCOOriginalPosition');
    verifyEqual(testCase,mainAxes(axisIndex).Position(4), ...
        0.85*originalPosition(4),'AbsTol',64*eps);
    verifyEqual(testCase,sum(mainAxes(axisIndex).Position([2 4])), ...
        sum(originalPosition([2 4])),'AbsTol',64*eps);
end
[~,leftToRight] = sort(arrayfun(@(ax)ax.Position(1),mainAxes));
orderedAxes = mainAxes(leftToRight);
verifyNotEmpty(testCase,orderedAxes(1).YTickLabel);
for axisIndex = 2:numel(orderedAxes)
    verifyEmpty(testCase,orderedAxes(axisIndex).YTickLabel);
    verifyEqual(testCase,string(orderedAxes(axisIndex).YLabel.Visible), ...
        "off");
end
orderedPositions = reshape([orderedAxes.Position],4,[]).';
horizontalGaps = orderedPositions(2:end,1) - ...
    sum(orderedPositions(1:end-1,[1 3]),2);
verifyEqual(testCase,horizontalGaps,0.95*0.035*ones(3,1), ...
    'AbsTol',64*eps);
mainColors = findall(figures(1),'Type','colorbar');
verifyNumElements(testCase,mainColors,4);
for colorIndex = 1:numel(mainColors)
    originalPosition = getappdata( ...
        mainColors(colorIndex),'eCOCOOriginalPosition');
    verifyEqual(testCase,mainColors(colorIndex).Position(3:4), ...
        0.70*originalPosition(3:4),'AbsTol',64*eps);
    expectedColorbarY = originalPosition(2)+ ...
        0.5*(1-0.70)*originalPosition(4)-0.04;
    verifyEqual(testCase,mainColors(colorIndex).Position(2), ...
        expectedColorbarY,'AbsTol',64*eps);
    originalFontSize = getappdata( ...
        mainColors(colorIndex),'eCOCOOriginalFontSize');
    verifyGreaterThan(testCase,originalFontSize,0);
    verifyEqual(testCase,mainColors(colorIndex).FontSize, ...
        mainAxes(1).FontSize,'AbsTol',64*eps);
    verifyEqual(testCase,mainColors(colorIndex).Label.FontSize, ...
        mainAxes(1).FontSize,'AbsTol',64*eps);
    verifyEqual(testCase,string(mainColors(colorIndex).AxisLocation),"out");
end
panelLabels = findall(figures(1),'Type','text', ...
    'Tag','eCOCO-panel-label');
verifyNumElements(testCase,panelLabels,4);
verifyEqual(testCase,sort(string({panelLabels.String})), ...
    ["A","B","C","D"]);
verifyTrue(testCase,all([panelLabels.Position] > -Inf));
sharedXLabel = findall(figures(1),'Tag','eCOCO-shared-x-label');
verifyNumElements(testCase,sharedXLabel,1);
verifyEqual(testCase,string(sharedXLabel.String), ...
    "Sedimentation rate (cm/kyr)");
verifyEqual(testCase,sharedXLabel.Position(2), ...
    0.5+(0.244-0.5)*0.95,'AbsTol',64*eps);
for labelText = ["Global p","Local p"]
    pColor = colorbarWithLabel(testCase,figures(1),labelText);
    verifyGreaterThanOrEqual(testCase, ...
        (pColor.Ticks(end)-pColor.Ticks(end-1))/pColor.Limits(2),0.18);
end
orbitColor = colorbarWithLabel( ...
    testCase,figures(1),"Number of periods");
verifyEqual(testCase,orbitColor.Ruler.TickLabelRotation,0,'AbsTol',0);

dataFile = fullfile(outputFolder,'sample-Adaptive-eCOCO-1.xlsx');
% GUI figure discovery can return the most recently created ridge figure
% first. The saver must normalize that order before assigning filenames.
saved = saveCocoGuiFigures(flipud(figures),dataFile);

verifyNumElements(testCase,saved,2);
verifyTrue(testCase,all(isgraphics(figures,'figure')));
verifyEqual(testCase,string(saved(1).fig),string(fullfile( ...
    outputFolder,'sample-Adaptive-eCOCO-1.fig')));
verifyEqual(testCase,string(saved(2).fig),string(fullfile( ...
    outputFolder,'sample-Adaptive-eCOCO-1-Ridge-score.fig')));
for savedIndex = 1:2
    verifyTrue(testCase,isfile(saved(savedIndex).fig));
    verifyTrue(testCase,isfile(saved(savedIndex).pdf));
    verifyGreaterThan(testCase,dir(saved(savedIndex).pdf).bytes,0);
end

main = openfig(saved(1).fig,'invisible');
ridge = openfig(saved(2).fig,'invisible');
cleanup = onCleanup(@()closeFigures([main;ridge]));
verifyEqual(testCase,sort(axisTitles(main)),sort([ ...
    "Correlation coefficient";"Local p";"Global p"; ...
    "Contributing orbital periods"]));
verifyEqual(testCase,axisTitles(ridge),"Ridge score");
end

function testCocoPublicationFigureIsExactHalfColumnAndFinalStyle(testCase)
outputFolder = tempname;
mkdir(outputFolder);
testCase.addTeardown(@()removeFolder(outputFolder));
fig = figure('Visible','off','Name','Blocked cvCOCO diagnostics');
testCase.addTeardown(@()closeIfValid(fig));
tabs = uitabgroup(fig);
tab = uitab(tabs,'Title','Correlation and significance');
layout = tiledlayout(tab,4,1,'TileSpacing','compact','Padding','compact');
rate = 1:4;

ax = nexttile(layout,1);
plot(ax,rate,[0.1 0.4 0.3 0.2],'b-');
hold(ax,'on');
plot(ax,rate,[0.2 0.3 0.5 0.1],'r-');
plot(ax,rate,[0.1 0.3 0.3 0.1],'k-', ...
    'LineWidth',2.4,'Tag','cvCOCO-correlation-consensus', ...
    'DisplayName','Consensus');
plot(ax,3,0.3,'ko','MarkerFaceColor','k','MarkerSize',5, ...
    'Tag','cvCOCO-correlation-consensus-peak');
set(ax,'Tag','cvCOCO-correlation');
title(ax,'Correlation coefficient');

ax = nexttile(layout,2);
plot(ax,rate,1:4,'b-','DisplayName','p_A=0.978');
hold(ax,'on');
plot(ax,rate,4:-1:1,'k-','LineWidth',2.4, ...
    'Tag','cvCOCO-global-p-consensus', ...
    'DisplayName','p_{cons}=0.007996');
set(ax,'Tag','cvCOCO-global-p');
title(ax,'Global p');
legend(ax,'show');

ax = nexttile(layout,3);
plot(ax,rate,1:4,'r-','DisplayName','local p_B=0.0065');
hold(ax,'on');
plot(ax,rate,4:-1:1,'k-','LineWidth',2.4, ...
    'Tag','cvCOCO-local-p-consensus', ...
    'DisplayName','local p_{cons}=0.0004998');
set(ax,'Tag','cvCOCO-local-p');
title(ax,'Local p');
legend(ax,'show');

ax = nexttile(layout,4);
plot(ax,rate,6:9,'b-');
set(ax,'Tag','COCO-orbit-count');
title(ax,'Number of contributing astronomical parameters');
xlabel(ax,'Sedimentation rate (cm/kyr)');

dataFile = fullfile(outputFolder, ...
    'sample-Blocked_cvCOCO-1.xlsx');
[saved,publication] = saveCocoGuiFigures(fig,dataFile, ...
    'CocoPublicationTitle','Blocked cvCOCO');
verifyNumElements(testCase,saved,1);
verifyTrue(testCase,isfile(saved.fig));
verifyTrue(testCase,isfile(saved.pdf));
verifyEqual(testCase,string(saved.fig),string(fullfile( ...
    outputFolder,'sample-Blocked_cvCOCO-1.fig')));
verifyEqual(testCase,string(saved.pdf),string(fullfile( ...
    outputFolder,'sample-Blocked_cvCOCO-1.pdf')));
verifyEmpty(testCase,publication.fig);
verifyTrue(testCase,isfile(publication.pdf));
verifyEmpty(testCase,publication.png);
verifyEqual(testCase,string(publication.pdf),string(fullfile( ...
    outputFolder,'sample-Blocked_cvCOCO-1-correlation.pdf')));
verifyFalse(testCase,isfile(fullfile(outputFolder, ...
    'sample-Blocked_cvCOCO-1-correlation.fig')));
verifyFalse(testCase,isfile(fullfile(outputFolder, ...
    'sample-Blocked_cvCOCO-1-correlation.png')));
verifyEqual(testCase,publication.widthMillimeters,88,'AbsTol',1e-12);

savedFigure = openfig(saved.fig,'invisible');
savedCleanup = onCleanup(@()closeIfValid(savedFigure));
savedLayout = findall(savedFigure,'-isa', ...
    'matlab.graphics.layout.TiledChartLayout');
verifyNumElements(testCase,savedLayout,1);

verifyGreaterThan(testCase,dir(publication.pdf).bytes,0);
[pdfWidthPoints,pdfHeightPoints] = pdfMediaBoxPoints(publication.pdf);
verifyEqual(testCase,pdfWidthPoints,88*72/25.4,'AbsTol',1e-6);
verifyEqual(testCase,pdfHeightPoints,117.4*72/25.4,'AbsTol',1e-6);
[cropWidthPoints,cropHeightPoints] = ...
    pdfBoxPoints(publication.pdf,'CropBox');
if isfinite(cropWidthPoints)
    verifyEqual(testCase,cropWidthPoints,88*72/25.4,'AbsTol',1e-6);
    verifyEqual(testCase,cropHeightPoints,117.4*72/25.4,'AbsTol',1e-6);
end
graphicsFiles = [dir(fullfile(outputFolder,'*.fig')); ...
    dir(fullfile(outputFolder,'*.pdf')); ...
    dir(fullfile(outputFolder,'*.png'))];
verifyNumElements(testCase,graphicsFiles,3);
end

function testGuiRunFinalizationGuardsDestroyedUiFigure(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
source = fileread(fullfile(repoRoot,'code','guicode','eCOCOGUI.m'));

verifyTrue(testCase,contains(source, ...
    "uiFigureAtStart = app.UIFigure"));
verifyTrue(testCase,contains(source, ...
    "safeStoreAppData(uiFigureAtStart,app)"));
verifyTrue(testCase,contains(source, ...
    "safeUiAlert(uiFigureAtStart"));
verifyTrue(testCase,contains(source, ...
    "restoreRunButton(runButtonAtStart)"));
verifyTrue(testCase,contains(source, ...
    "runFigures,uiFigureAtStart,'stable'"));
end

function testEvofftUsesOneOrderedWorkbook(testCase)
outputFolder = tempname;
mkdir(outputFolder);
testCase.addTeardown(@()removeFolder(outputFolder));
workbook = fullfile(outputFolder,'sample-evofft-1.xlsx');
parameters = {'Parameter','Value';'Method','Evolutionary FFT'};
power = reshape(1:12,3,4);
frequency = [0.1 0.2 0.3 0.4];
time = [10 20 30];
redNoise = [(1:5)',rand(5,6)];

saveEvofftWorkbook(workbook,parameters,power,frequency,time,redNoise);

verifyTrue(testCase,isfile(workbook));
actualSheets = string(sheetnames(workbook));
verifyEqual(testCase,actualSheets(:), ...
    ["Parameters";"Power";"Frequency";"Time";"MTM_Red_Noise"]);
verifyEqual(testCase,readmatrix(workbook,'Sheet','Power'),power);
verifyEqual(testCase,readmatrix(workbook,'Sheet','Frequency'),frequency(:));
verifyEqual(testCase,readmatrix(workbook,'Sheet','Time'),time(:));
verifyEqual(testCase,readmatrix(workbook,'Sheet','MTM_Red_Noise', ...
    'Range','A2:G6'),redNoise);
end

function testGuiDeclaresIndependentInterleavedEcocoRoute(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
source = fileread(fullfile(repoRoot,'code','guicode','eCOCOGUI.m'));

verifyTrue(testCase,contains(source,"app.RInterleaved"));
verifyTrue(testCase,contains(source,"case 3"));
verifyTrue(testCase,contains(source,"'token','interleaved'"));
verifyTrue(testCase,contains(source,"'displayName','Blocked eCOCO'"));
verifyTrue(testCase,contains(source,"'displayName','Interleaved eCOCO'"));
verifyTrue(testCase,contains(source,"'outputLabel','Blocked_eCOCO'"));
verifyTrue(testCase,contains(source,"'outputLabel','Interleaved_eCOCO'"));
verifyTrue(testCase,contains(source,"'Score_definition'"));
verifyTrue(testCase,contains(source,"'Orbit_count_role'"));
verifyTrue(testCase,contains(source, ...
    "{'rho','pLocal','pGlobal','nOrbit','pCOCO','score'}"));
verifyTrue(testCase,contains(source,"dat2 = app.dataRaw"));
verifyTrue(testCase,contains(source, ...
    "interleavedWindowMode = 'physical-depth'"));
verifyTrue(testCase,contains(source, ...
    "interleavedStepDepth = app.step"));
verifyTrue(testCase,contains(source,"app.CPadEdge.Value = false"));
verifyTrue(testCase,contains(source,"app.ecocoCalcMode == 2"));
verifyTrue(testCase,contains(source,"Ieco_WindowP"));
verifyTrue(testCase,contains(source,"Ieco_FoldResolution"));
verifyTrue(testCase,contains(source,"Ieco_WindowGeometry"));
verifyTrue(testCase,contains(source,"CompleteAllNineTrainingRate_"));
verifyTrue(testCase,contains(source,"PartialOrbitOnlyTrainingRate_"));
verifyTrue(testCase,contains(source,"EffectiveActiveLeakageRcond_"));
verifyTrue(testCase,contains(source,"Partial_orbit_training"));
end

function testGuiMapsAllFourCocoMethodsToPublicationExporter(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
source = fileread(fullfile(repoRoot,'code','guicode','eCOCOGUI.m'));

verifyTrue(testCase,contains(source,"'cvCOCO — Blocked'"));
verifyTrue(testCase,contains(source,"'cvCOCO — Interleaved'"));
verifyTrue(testCase,contains(source,"'Blocked cvCOCO'"));
verifyTrue(testCase,contains(source,"'B-cvCOCO'"));
verifyTrue(testCase,contains(source,"'Blocked_cvCOCO'"));
verifyTrue(testCase,contains(source,"'Interleaved_cvCOCO'"));
verifyTrue(testCase,contains(source,"'Adaptive COCO'"));
verifyTrue(testCase,contains(source,"'Fixed-target COCO'"));
verifyTrue(testCase,contains(source, ...
    "saveArguments = {'CocoPublicationTitle'"));
verifyTrue(testCase,contains(source,"selectedCocoMethod(modeName)"));
end

function testGuiCombinesParametersIntoDataWorkbooks(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
source = fileread(fullfile(repoRoot,'code','guicode','eCOCOGUI.m'));

verifyGreaterThanOrEqual(testCase,count(source, ...
    "'Sheet','Parameters'"),3);
verifyTrue(testCase,contains(source, ...
    "saveDir,outputStem,'.xlsx'"));
verifyFalse(testCase,contains(source,"saveRunParameterTable"));
verifyFalse(testCase,contains(source,"-parameters-"));
verifyFalse(testCase,contains(source,"Secondary p_sym"));
verifyFalse(testCase,contains(source,"-COCO-data"));
verifyFalse(testCase,contains(source,"methodStem,'-data"));
verifyFalse(testCase,contains(source,"outputLabel,'-data"));
end

function testCompactCocoPdfFormattingRulesAreDeclared(testCase)
testFolder = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(testFolder));
source = fileread(fullfile(repoRoot,'code','corrcoef', ...
    'saveCocoGuiFigures.m'));

verifyTrue(testCase,contains(source,"FontSize = 0.75*7"));
verifyTrue(testCase,contains(source,"displayName = 'Cons.'"));
verifyTrue(testCase,contains(source,"sprintf('%.4f',value)"));
verifyTrue(testCase,contains(source,"panelLabels = 'ABCD'"));
verifyTrue(testCase,contains(source, ...
    "'Tag','COCO-publication-panel-label'"));
verifyTrue(testCase,contains(source,"layout.Title.Visible = 'off'"));
verifyTrue(testCase,contains(source,"ax.Title.Visible = 'off'"));
verifyTrue(testCase,contains(source,"text(ax,labelX,1.02"));
verifyTrue(testCase,contains(source,"contentScale = 0.95"));
verifyTrue(testCase,contains(source, ...
    "horizontalMarginCm = 0.5*(1-contentScale)*widthCm"));
verifyTrue(testCase,contains(source, ...
    "verticalMarginCm = 0.5*(1-contentScale)*heightCm"));
end

function closeIfValid(fig)
if isgraphics(fig,'figure')
    close(fig);
end
end

function closeFigures(figures)
figures = figures(isgraphics(figures,'figure'));
if ~isempty(figures)
    close(figures);
end
end

function [widthPoints,heightPoints] = pdfMediaBoxPoints(pdfFile)
[widthPoints,heightPoints] = pdfBoxPoints(pdfFile,'MediaBox');
end

function [widthPoints,heightPoints] = pdfBoxPoints(pdfFile,boxName)
fileId = fopen(pdfFile,'r');
cleanup = onCleanup(@()fclose(fileId));
pdfText = char(fread(fileId,Inf,'*uint8')');
numberPattern = '[-+]?(?:\d+\.?\d*|\.\d+)';
pattern = ['/',boxName,'\s*\[\s*',numberPattern,'\s+', ...
    numberPattern,'\s+(',numberPattern,')\s+(',numberPattern,')\s*\]'];
tokens = regexp(pdfText,pattern,'tokens','once');
if isempty(tokens)
    widthPoints = NaN;
    heightPoints = NaN;
    return
end
widthPoints = str2double(tokens{1});
heightPoints = str2double(tokens{2});
end

function titles = axisTitles(fig)
axesHandles = findall(fig,'Type','axes');
titles = strings(numel(axesHandles),1);
for axisIndex = 1:numel(axesHandles)
    titles(axisIndex) = string(axesHandles(axisIndex).Title.String);
end
end

function color = colorbarWithLabel(testCase,fig,labelText)
colors = findall(fig,'Type','colorbar');
matches = false(size(colors));
for colorIndex = 1:numel(colors)
    matches(colorIndex) = ...
        string(colors(colorIndex).Label.String) == labelText;
end
verifyEqual(testCase,sum(matches),1, ...
    sprintf('Expected exactly one "%s" colorbar.',labelText));
color = colors(matches);
end

function removeFolder(folder)
if isfolder(folder)
    rmdir(folder,'s');
end
end
