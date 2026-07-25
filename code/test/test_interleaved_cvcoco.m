function tests = test_interleaved_cvcoco
%TEST_INTERLEAVED_CVCOCO Scientific invariants for Interleaved cvCOCO.
%
% These tests keep the new odd/even observation-index split distinct from
% the existing depth-midpoint cvCOCO split.  In particular, interpolation
% must occur independently inside each fold and every Monte Carlo
% realization must use the joint full-record AR(1) null declared by the
% result metadata.

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
rngState = rng;
testCase.addTeardown(@()rng(rngState));

orbit9 = [405.6912;130.6979;123.8532;98.8517;94.8856; ...
    40.9897;23.6820;22.3758;18.9519];

testCase.TestData.data = irregularOrbitalSeries(orbit9);
testCase.TestData.orbit9 = orbit9;
testCase.TestData.pad = 512;
testCase.TestData.rateRange = [3,5,1];
testCase.TestData.maxFrequency = 0.06;
testCase.TestData.seed = 17031;
end

function testWrapperLocksMethodAndReportsInterleavedMetadata(testCase)
r = runInterleaved(testCase,testCase.TestData.data,0,2, ...
    testCase.TestData.seed);

verifyEqual(testCase,r.name,'Interleaved cvCOCO');
verifyEqual(testCase,r.publicName,'Interleaved cvCOCO');
verifyEqual(testCase,r.abbreviation,'I-cvCOCO');
verifyEqual(testCase,r.canonicalEntryPoint,'interleavedcvcoco');
verifyEqual(testCase,r.targetModel,'four-group-coherent-nine');
verifyEqual(testCase,r.splitMode,'interleaved');
verifyTrue(testCase,isnan(r.splitDepth));
verifyEqual(testCase,r.config.splitMode,'interleaved');
verifyTrue(testCase,r.config.jointNull);

labels = lower(string(r.foldLabels(:)));
verifySize(testCase,labels,[2,1]);
verifyTrue(testCase,contains(labels(1),'odd'));
verifyTrue(testCase,contains(labels(2),'even'));

splitRule = lower(string(r.config.splitRule));
verifyTrue(testCase,contains(splitRule,'odd'));
verifyTrue(testCase,contains(splitRule,'even'));
verifyTrue(testCase,contains(splitRule,'row') || ...
    contains(splitRule,'index'));

args = interleavedArguments(testCase,testCase.TestData.data,0);
verifyError(testCase,@()interleavedcvcoco( ...
    args{:},'TargetModel','four-group'), ...
    'interleavedcvcoco:TargetModelFixed');
verifyError(testCase,@()interleavedcvcoco( ...
    args{:},'SplitMode','midpoint'), ...
    'interleavedcvcoco:SplitModeFixed');
end

function testOddEvenIndicesAndInterpolationAreFoldLocal(testCase)
% Reverse the source rows, add a duplicate depth, and include nonfinite
% rows.  Fold parity must be assigned only after finite-sort-deduplicate.
base = testCase.TestData.data;
dirty = [base(end:-1:1,:); ...
    base(77,:)+[0,0.42]; ...
    NaN,1; ...
    base(33,1),NaN];
expectedClean = cleanLikeCvCoco(dirty);

r = runInterleaved(testCase,dirty,0,2,testCase.TestData.seed);
oddIndex = (1:2:size(expectedClean,1))';
evenIndex = (2:2:size(expectedClean,1))';
expectedOdd = expectedClean(oddIndex,:);
expectedEven = expectedClean(evenIndex,:);

verifyEqual(testCase,r.dataClean,expectedClean,'AbsTol',2e-14);
verifyEqual(testCase,r.rawFoldIndexA,oddIndex,'AbsTol',0);
verifyEqual(testCase,r.rawFoldIndexB,evenIndex,'AbsTol',0);
verifyEqual(testCase,r.rawDataA,expectedOdd,'AbsTol',2e-14);
verifyEqual(testCase,r.rawDataB,expectedEven,'AbsTol',2e-14);
verifyEqual(testCase,r.dataA,regularizeExpected(expectedOdd), ...
    'AbsTol',2e-13);
verifyEqual(testCase,r.dataB,regularizeExpected(expectedEven), ...
    'AbsTol',2e-13);
verifyTrue(testCase,r.interpolationA.applied);
verifyTrue(testCase,r.interpolationB.applied);

% Changing only even-index observations must leave the raw and regularized
% odd fold bit-for-bit unchanged.  This catches interpolation performed on
% the full record before the split.
changed = expectedClean;
nEven = numel(evenIndex);
changed(evenIndex,2) = changed(evenIndex,2) + ...
    0.31*cos((1:nEven)'*0.37) + 0.17*sin((1:nEven)'*0.11);
rChanged = runInterleaved(testCase,changed,0,2, ...
    testCase.TestData.seed);
verifyEqual(testCase,rChanged.rawDataA,r.rawDataA,'AbsTol',0);
verifyEqual(testCase,rChanged.dataA,r.dataA,'AbsTol',0);
verifyNotEqual(testCase,rChanged.rawDataB,r.rawDataB);
verifyNotEqual(testCase,rChanged.dataB,r.dataB);
end

function testJointNullIsSeededAndBatchInvariant(testCase)
nsim = 7;

% The engine must restore the caller's random-number state.
rng(90817,'twister');
stateBefore = rng;
expectedNext = rand(1,6);
rng(stateBefore);
rBatch1 = runInterleaved(testCase,testCase.TestData.data,nsim,1, ...
    testCase.TestData.seed);
actualNext = rand(1,6);
verifyEqual(testCase,actualNext,expectedNext,'AbsTol',0);

rBatch3 = runInterleaved(testCase,testCase.TestData.data,nsim,3, ...
    testCase.TestData.seed);
verifyTrue(testCase,rBatch1.config.jointNull);
verifyTrue(testCase,rBatch3.config.jointNull);

nullDescription = lower(string(rBatch1.config.nullConditioning));
verifyTrue(testCase,contains(nullDescription,'full') || ...
    contains(nullDescription,'complete'));
verifyTrue(testCase,contains(nullDescription,'ar(1)') || ...
    contains(nullDescription,'ar1'));
verifyTrue(testCase,contains(nullDescription,'odd'));
verifyTrue(testCase,contains(nullDescription,'even'));

floatingFields = {'nullSymmetric','nullAtoB','nullBtoA'};
for fieldIndex = 1:numel(floatingFields)
    field = floatingFields{fieldIndex};
    verifyEqual(testCase,rBatch1.(field),rBatch3.(field), ...
        'AbsTol',2e-13);
end

exactFields = {'nullBestRateAtoB','nullBestRateBtoA','pCurveAtoB', ...
    'pCurveBtoA','pLocalCurveAtoB','pLocalCurveBtoA', ...
    'localExceedanceCountAtoB','localExceedanceCountBtoA', ...
    'localValidCountAtoB','localValidCountBtoA'};
for fieldIndex = 1:numel(exactFields)
    field = exactFields{fieldIndex};
    verifyEqual(testCase,rBatch1.(field),rBatch3.(field),'AbsTol',0);
end
verifyEqual(testCase,rBatch1.pSym,rBatch3.pSym,'AbsTol',0);
verifyEqual(testCase,rBatch1.pAtoB,rBatch3.pAtoB,'AbsTol',0);
verifyEqual(testCase,rBatch1.pBtoA,rBatch3.pBtoA,'AbsTol',0);
verifyEqual(testCase,rBatch1.nsimCompleted,nsim);
verifyEqual(testCase,rBatch3.nsimCompleted,nsim);

expectedAtoB = (1+sum(rBatch1.nullAtoB >= ...
    rBatch1.validateAtoB.score))/(nsim+1);
expectedBtoA = (1+sum(rBatch1.nullBtoA >= ...
    rBatch1.validateBtoA.score))/(nsim+1);
expectedSymmetric = (1+sum(rBatch1.nullSymmetric >= ...
    rBatch1.scoreSymmetric))/(nsim+1);
verifyEqual(testCase,rBatch1.pAtoB,expectedAtoB,'AbsTol',0);
verifyEqual(testCase,rBatch1.pBtoA,expectedBtoA,'AbsTol',0);
verifyEqual(testCase,rBatch1.pSym,expectedSymmetric,'AbsTol',0);

expectedConsensusCurve = nan(size(rBatch1.validateAtoB.curve));
bothFinite = isfinite(rBatch1.validateAtoB.curve) & ...
    isfinite(rBatch1.validateBtoA.curve);
expectedConsensusCurve(bothFinite) = min( ...
    rBatch1.validateAtoB.curve(bothFinite), ...
    rBatch1.validateBtoA.curve(bothFinite));
verifyEqual(testCase,rBatch1.consensus.curve, ...
    expectedConsensusCurve,'AbsTol',0);
for rateIndex = find(isfinite(expectedConsensusCurve))'
    expectedGlobal = (1+sum(rBatch1.nullConsensus >= ...
        expectedConsensusCurve(rateIndex)))/(nsim+1);
    expectedLocal = (1+ ...
        rBatch1.localExceedanceCountConsensus(rateIndex))/(nsim+1);
    verifyEqual(testCase,rBatch1.pCurveConsensus(rateIndex), ...
        expectedGlobal,'AbsTol',0);
    verifyEqual(testCase,rBatch1.pLocalCurveConsensus(rateIndex), ...
        expectedLocal,'AbsTol',0);
end
finiteP = isfinite(rBatch1.pCurveConsensus) & ...
    isfinite(rBatch1.pLocalCurveConsensus);
verifyGreaterThanOrEqual(testCase,rBatch1.pCurveConsensus(finiteP), ...
    rBatch1.pLocalCurveConsensus(finiteP));
end

function testPlotShowsThickConsensusCurvesAndSingleColumnLegends(testCase)
nsim = 7;
r = runInterleaved(testCase,testCase.TestData.data,nsim,2, ...
    testCase.TestData.seed);
figures = plotcvcoco(r,'ShowSpectra',false);
cleanup = onCleanup(@()closeFigures(figures));
verifyNumElements(testCase,figures,3);

correlationAxis = findobj(figures,'Type','axes', ...
    'Tag','cvCOCO-correlation');
globalAxis = findobj(figures,'Type','axes','Tag','cvCOCO-global-p');
localAxis = findobj(figures,'Type','axes','Tag','cvCOCO-local-p');
orbitAxis = findobj(figures,'Type','axes','Tag','COCO-orbit-count');
verifyNumElements(testCase,correlationAxis,1);
verifyNumElements(testCase,globalAxis,1);
verifyNumElements(testCase,localAxis,1);
verifyNumElements(testCase,orbitAxis,1);
verifyEqual(testCase,correlationAxis.Title.String, ...
    'Correlation coefficient');
verifyEqual(testCase,globalAxis.Title.String,'Global p');
verifyEqual(testCase,localAxis.Title.String,'Local p');
verifyEqual(testCase,orbitAxis.Title.String, ...
    'Number of contributing astronomical parameters');
verifyEqual(testCase,correlationAxis.YLabel.String,'\rho');
verifyEqual(testCase,globalAxis.YLabel.String,'Global p');
verifyEqual(testCase,localAxis.YLabel.String,'Local p');
verifyEqual(testCase,orbitAxis.YLabel.String,'#');
consensusAuditAxis = findall(figures,'Type','axes', ...
    'Tag','cvCOCO-consensus-global-audit');
verifyNumElements(testCase,consensusAuditAxis,1);
verifyTrue(testCase,any(contains( ...
    string(consensusAuditAxis.Title.String),'Consensus global p')));
verifyEqual(testCase,consensusAuditAxis.XLabel.String, ...
    'Null consensus maximum');
consensusHistogram = findall(consensusAuditAxis, ...
    'Type','histogram');
verifyNumElements(testCase,consensusHistogram,1);
verifyEqual(testCase,consensusHistogram.Data(:), ...
    r.nullConsensus(isfinite(r.nullConsensus)),'AbsTol',0);
consensusObserved = findall(consensusAuditAxis,'Type','line', ...
    'Color',[1 0 0]);
verifyNumElements(testCase,consensusObserved,1);
verifyEqual(testCase,consensusObserved.XData, ...
    [r.scoreConsensus r.scoreConsensus],'AbsTol',0);

pCOCOAxis = findobj(figures,'Type','axes','Tag','cvCOCO-pCOCO-axis');
pCOCOLine = findobj(pCOCOAxis,'Type','line','Tag','cvCOCO-pCOCO');
pCOCOPeak = findall(pCOCOAxis,'Type','line','Tag','cvCOCO-pCOCO-peak');
verifyNumElements(testCase,pCOCOAxis,1);
verifyNumElements(testCase,pCOCOLine,1);
verifyNumElements(testCase,pCOCOPeak,1);
expectedPCOCO = r.consensus.curve(:).* ...
    abs(log10(r.pCurveConsensus(:)));
verifyEqual(testCase,r.pCOCO,expectedPCOCO,'AbsTol',0);
verifyEqual(testCase,r.consensus.pCOCO,expectedPCOCO,'AbsTol',0);
verifyEqual(testCase,pCOCOLine.YData(:),expectedPCOCO,'AbsTol',0);
verifyEqual(testCase,pCOCOLine.Color,[1 0 0],'AbsTol',0);
verifyEqual(testCase,pCOCOLine.LineWidth,2,'AbsTol',0);
[expectedBestPCOCO,expectedBestIndex] = max(expectedPCOCO,[],'omitnan');
verifyEqual(testCase,r.bestPCOCO,expectedBestPCOCO,'AbsTol',0);
verifyEqual(testCase,r.bestPCOCORate, ...
    r.srGrid(expectedBestIndex),'AbsTol',0);
verifyEqual(testCase,pCOCOPeak.XData,r.bestPCOCORate,'AbsTol',0);
verifyEqual(testCase,pCOCOPeak.YData,r.bestPCOCO,'AbsTol',0);
verifyEqual(testCase,pCOCOPeak.MarkerSize,4,'AbsTol',0);

correlationConsensus = findobj(correlationAxis,'Type','line', ...
    'Tag','cvCOCO-correlation-consensus');
globalConsensus = findobj(globalAxis,'Type','line', ...
    'Tag','cvCOCO-global-p-consensus');
localConsensus = findobj(localAxis,'Type','line', ...
    'Tag','cvCOCO-local-p-consensus');
verifyNumElements(testCase,correlationConsensus,1);
verifyNumElements(testCase,globalConsensus,1);
verifyNumElements(testCase,localConsensus,1);

pFloor = 1/(r.nsimValidConsensus+1);
verifyEqual(testCase,correlationConsensus.XData(:),r.srGrid(:), ...
    'AbsTol',0);
verifyEqual(testCase,correlationConsensus.YData(:), ...
    r.consensus.curve(:),'AbsTol',0);
verifyEqual(testCase,globalConsensus.XData(:),r.srGrid(:),'AbsTol',0);
verifyEqual(testCase,globalConsensus.YData(:), ...
    -log10(max(r.pCurveConsensus(:),pFloor)),'AbsTol',0);
verifyEqual(testCase,localConsensus.XData(:),r.srGrid(:),'AbsTol',0);
verifyEqual(testCase,localConsensus.YData(:), ...
    -log10(max(r.pLocalCurveConsensus(:),pFloor)),'AbsTol',0);

consensusLines = [correlationConsensus;globalConsensus;localConsensus];
verifyEqual(testCase,vertcat(consensusLines.Color),zeros(3,3), ...
    'AbsTol',0);
verifyEqual(testCase,vertcat(consensusLines.LineWidth), ...
    1.2*ones(3,1),'AbsTol',0);
verifyEqual(testCase,correlationConsensus.DisplayName,'Consensus');
verifyEqual(testCase,globalConsensus.DisplayName, ...
    sprintf('p_{cons}=%s',formatProbability4Expected(r.pConsensus)));
verifyEqual(testCase,localConsensus.DisplayName, ...
    sprintf('p_{cons}=%s', ...
    formatProbability4Expected(r.consensus.pLocalAtBest)));

correlationDirections = findobj(correlationAxis,'Type','line','Tag','');
correlationDirections = correlationDirections(arrayfun(@(line) ...
    ismember(line.Color,[1 0 0;0 0 1],'rows') && ...
    strcmp(line.LineStyle,'-'),correlationDirections));
verifyEqual(testCase,sort(string({correlationDirections.DisplayName})), ...
    ["Even","Odd"]);

globalAtoB = findobj(globalAxis,'Type','line', ...
    'Tag','cvCOCO-global-p-AtoB');
globalBtoA = findobj(globalAxis,'Type','line', ...
    'Tag','cvCOCO-global-p-BtoA');
localAtoB = findobj(localAxis,'Type','line', ...
    'Tag','cvCOCO-local-p-AtoB');
localBtoA = findobj(localAxis,'Type','line', ...
    'Tag','cvCOCO-local-p-BtoA');
verifyEqual(testCase,globalAtoB.DisplayName, ...
    sprintf('p_{Even}=%s',formatProbability4Expected(r.pB)));
verifyEqual(testCase,globalBtoA.DisplayName, ...
    sprintf('p_{Odd}=%s',formatProbability4Expected(r.pA)));
verifyEqual(testCase,localAtoB.DisplayName, ...
    sprintf('p_{Even}=%s',formatProbability4Expected( ...
    r.pLocalCurveAtoB(r.validateAtoB.bestIndex))));
verifyEqual(testCase,localBtoA.DisplayName, ...
    sprintf('p_{Odd}=%s',formatProbability4Expected( ...
    r.pLocalCurveBtoA(r.validateBtoA.bestIndex))));
verifyEqual(testCase,[globalAtoB.LineWidth;globalBtoA.LineWidth; ...
    localAtoB.LineWidth;localBtoA.LineWidth], ...
    0.6*ones(4,1),'AbsTol',0);
verifyEqual(testCase,vertcat(correlationDirections.LineWidth), ...
    0.55*ones(2,1),'AbsTol',0);

blueOrbit = findobj(orbitAxis,'Type','line','Color',[0 0 1]);
redOrbit = findobj(orbitAxis,'Type','line','Color',[1 0 0]);
verifyNumElements(testCase,blueOrbit,1);
verifyNumElements(testCase,redOrbit,1);
verifyEqual(testCase,blueOrbit.LineWidth,1,'AbsTol',0);
verifyEqual(testCase,redOrbit.LineWidth,0.5,'AbsTol',0);

coloredPeakTags = { ...
    'cvCOCO-correlation-AtoB-peak'; ...
    'cvCOCO-correlation-BtoA-peak'; ...
    'cvCOCO-global-p-AtoB-peak'; ...
    'cvCOCO-global-p-BtoA-peak'; ...
    'cvCOCO-local-p-AtoB-peak'; ...
    'cvCOCO-local-p-BtoA-peak'};
for peakIndex = 1:numel(coloredPeakTags)
    peak = findall(figures,'Type','line', ...
        'Tag',coloredPeakTags{peakIndex});
    verifyNumElements(testCase,peak,1);
    verifyEqual(testCase,peak.MarkerSize,2.5,'AbsTol',0);
end

blackPeakTags = { ...
    'cvCOCO-correlation-consensus-peak'; ...
    'cvCOCO-global-p-consensus-peak'; ...
    'cvCOCO-local-p-consensus-peak'};
blackPeakY = [r.consensus.bestCorrelation; ...
    -log10(max(r.pCurveConsensus(r.consensus.bestIndex),pFloor)); ...
    -log10(max(r.pLocalCurveConsensus(r.consensus.bestIndex),pFloor))];
for peakIndex = 1:numel(blackPeakTags)
    peak = findall(figures,'Type','line', ...
        'Tag',blackPeakTags{peakIndex});
    verifyNumElements(testCase,peak,1);
    verifyEqual(testCase,peak.XData,r.consensus.bestRate,'AbsTol',0);
    verifyEqual(testCase,peak.YData,blackPeakY(peakIndex),'AbsTol',0);
    verifyEqual(testCase,peak.Color,[0 0 0],'AbsTol',0);
    verifyEqual(testCase,peak.MarkerFaceColor,[0 0 0],'AbsTol',0);
    verifyEqual(testCase,peak.MarkerSize,2.5,'AbsTol',0);
end

verifyDrawnAboveDirections(testCase,correlationAxis, ...
    correlationConsensus);
verifyDrawnAboveDirections(testCase,globalAxis,globalConsensus);
verifyDrawnAboveDirections(testCase,localAxis,localConsensus);

legends = findall(figures,'Type','legend');
verifyNotEmpty(testCase,legends);
verifyEqual(testCase,vertcat(legends.NumColumns), ...
    ones(numel(legends),1));
verifyTrue(testCase,all(strcmp({legends.Orientation},'vertical')));

clear cleanup
closeFigures(figures);
end

function testOldInterleavedResultWithoutConsensusStillPlots(testCase)
r = runInterleaved(testCase,testCase.TestData.data,3,1, ...
    testCase.TestData.seed);
fields = {'consensus','pCurveConsensus','pLocalCurveConsensus', ...
    'pConsensus','nsimValidConsensus'};
legacyResult = rmfield(r,fields);
figures = plotcvcoco(legacyResult,'ShowSpectra',false);
cleanup = onCleanup(@()closeFigures(figures));
verifyNumElements(testCase,figures,2);

verifyEmpty(testCase,findall(figures,'Type','line','-regexp','Tag', ...
    'cvCOCO-.*-consensus'));
verifyNumElements(testCase,findall(figures,'Type','axes', ...
    'Tag','cvCOCO-symmetric-audit'),1);
verifyEmpty(testCase,findall(figures,'Type','axes', ...
    'Tag','cvCOCO-consensus-global-audit'));
verifyEmpty(testCase,findall(figures,'Type','axes', ...
    'Tag','cvCOCO-pCOCO-axis'));
verifyNumElements(testCase,findall(figures,'Type','line', ...
    'Tag','cvCOCO-global-p-AtoB'),1);
verifyNumElements(testCase,findall(figures,'Type','line', ...
    'Tag','cvCOCO-global-p-BtoA'),1);

clear cleanup
closeFigures(figures);
end

function testDefaultCvCocoRemainsDepthMidpoint(testCase)
args = cvArguments(testCase,testCase.TestData.data,0);
defaultResult = cvcoco(args{:}, ...
    'MaxFrequency',testCase.TestData.maxFrequency, ...
    'Seed',testCase.TestData.seed);
explicitResult = cvcoco(args{:}, ...
    'MaxFrequency',testCase.TestData.maxFrequency, ...
    'Seed',testCase.TestData.seed,'SplitMode','midpoint');

verifyEqual(testCase,defaultResult.splitMode,'midpoint');
verifyEqual(testCase,defaultResult.config.splitMode,'midpoint');
verifyTrue(testCase,isfinite(defaultResult.splitDepth));
verifyLessThanOrEqual(testCase,defaultResult.dataA(end,1), ...
    defaultResult.splitDepth);
verifyGreaterThan(testCase,defaultResult.dataB(1,1), ...
    defaultResult.splitDepth);

% An omitted SplitMode must remain numerically identical to an explicitly
% requested midpoint split.
verifyEqual(testCase,defaultResult.dataClean,explicitResult.dataClean, ...
    'AbsTol',0);
verifyEqual(testCase,defaultResult.dataA,explicitResult.dataA,'AbsTol',0);
verifyEqual(testCase,defaultResult.dataB,explicitResult.dataB,'AbsTol',0);
verifyEqual(testCase,defaultResult.trainA.curve, ...
    explicitResult.trainA.curve,'AbsTol',0);
verifyEqual(testCase,defaultResult.trainB.curve, ...
    explicitResult.trainB.curve,'AbsTol',0);
verifyEqual(testCase,defaultResult.validateAtoB.curve, ...
    explicitResult.validateAtoB.curve,'AbsTol',0);
verifyEqual(testCase,defaultResult.validateBtoA.curve, ...
    explicitResult.validateBtoA.curve,'AbsTol',0);
verifyEqual(testCase,defaultResult.scoreSymmetric, ...
    explicitResult.scoreSymmetric,'AbsTol',0);
end

function r = runInterleaved(testCase,data,nsim,batchSize,seed)
args = interleavedArguments(testCase,data,nsim);
r = interleavedcvcoco(args{:}, ...
    'MaxFrequency',testCase.TestData.maxFrequency, ...
    'BatchSize',batchSize,'Seed',seed);
end

function args = interleavedArguments(testCase,data,nsim)
range = testCase.TestData.rateRange;
args = {data,testCase.TestData.orbit9,testCase.TestData.pad, ...
    range(1),range(2),range(3),0,nsim,'Pearson'};
end

function args = cvArguments(testCase,data,nsim)
range = testCase.TestData.rateRange;
args = {data,testCase.TestData.orbit9,testCase.TestData.pad, ...
    range(1),range(2),range(3),0,nsim,'Pearson'};
end

function clean = cleanLikeCvCoco(data)
clean = data(all(isfinite(data),2),:);
clean = sortrows(clean,1);
[depth,~,group] = unique(clean(:,1),'sorted');
value = accumarray(group,clean(:,2),[],@mean);
clean = [depth,value];
end

function out = regularizeExpected(raw)
spacing = diff(raw(:,1));
spacing = spacing(isfinite(spacing) & spacing > 0);
dz = median(spacing);
tolerance = max(64*eps(max(1,max(abs(raw(:,1))))), ...
    1e-8*max(1,abs(dz)));
if max(abs(spacing-dz)) <= tolerance
    out = raw;
    return
end

intervalCountExact = (raw(end,1)-raw(1,1))/dz;
intervalCountRounded = round(intervalCountExact);
countTolerance = 1e-10*max(1,abs(intervalCountExact));
if abs(intervalCountExact-intervalCountRounded) <= countTolerance
    intervalCount = intervalCountRounded;
else
    intervalCount = floor(intervalCountExact);
end
grid = raw(1,1)+(0:intervalCount)'*dz;
endpointTolerance = 16*eps(max(1,max(abs(raw([1,end],1))))) * ...
    max(1,numel(grid));
if abs(grid(end)-raw(end,1)) <= endpointTolerance
    grid(end) = raw(end,1);
end
value = interp1(raw(:,1),raw(:,2),grid,'linear');
ok = isfinite(grid) & isfinite(value);
out = [grid(ok),value(ok)];
end

function verifyDrawnAboveDirections(testCase,ax,consensusLine)
directionLines = findobj(ax,'Type','line','-regexp','Tag', ...
    'cvCOCO-.*-p-[AB]to[AB]');
if strcmp(ax.Tag,'cvCOCO-correlation')
    directionLines = findobj(ax,'Type','line','Tag','');
    directionLines = directionLines(arrayfun(@(line) ...
        ismember(line.Color,[1 0 0;0 0 1],'rows') && ...
        strcmp(line.LineStyle,'-'),directionLines));
end
verifyNumElements(testCase,directionLines,2);
children = allchild(ax);
consensusIndex = find(children == consensusLine,1);
directionIndices = arrayfun(@(line)find(children == line,1), ...
    directionLines);
verifyLessThan(testCase,consensusIndex,min(directionIndices));
end

function closeFigures(figures)
figures = figures(isgraphics(figures,'figure'));
if ~isempty(figures)
    close(figures);
end
end

function textValue = formatProbability4Expected(value)
if value == 0
    textValue = '0.000';
    return
end
exponent = floor(log10(abs(value)));
decimalPlaces = max(0,4-exponent-1);
textValue = sprintf(['%0.',num2str(decimalPlaces),'f'],value);
end

function data = irregularOrbitalSeries(orbit9)
n = 501;
incrementPattern = [0.07;0.11;0.09;0.14;0.08;0.10;0.13];
increments = repmat(incrementPattern,ceil((n-1)/numel(incrementPattern)),1);
depth = [0;cumsum(increments(1:n-1))];
sedimentationRate = 4;
timeKyr = depth*100/sedimentationRate;
amplitude = [1.00;0.82;0.74;0.68;0.61;0.77;0.57;0.51;0.46];
phase = [0.1;0.7;1.4;2.2;2.8;0.4;1.1;1.9;2.5];
value = zeros(size(depth));
for orbitIndex = 1:numel(orbit9)
    value = value+amplitude(orbitIndex)*sin( ...
        2*pi*timeKyr/orbit9(orbitIndex)+phase(orbitIndex));
end
value = value+0.09*cos(2*pi*depth/1.73) + ...
    0.06*sin(2*pi*depth/0.91+0.3) + 0.002*depth;
data = [depth,value];
end
