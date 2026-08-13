function tests = test_dynos_gui_migration
%TEST_DYNOS_GUI_MIGRATION Regression tests for the DYNOS GUI migration.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
seriesFolder = fileparts(testFolder);
codeFolder = fileparts(seriesFolder);
oldPath = path;
oldVisibility = get(groot,'DefaultFigureVisible');
addpath(genpath(codeFolder));
set(groot,'DefaultFigureVisible','off');
testCase.TestData.codeFolder = codeFolder;
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

function testEveryConfidenceSelectionHasTrueMedianCenter(testCase)
expectedEndpointPairs = [ ...
    25 75; ...
    15.865 84.135; ...
    10 90; ...
    5 95; ...
    2.5 97.5];

for bitPattern = 0:63
    selection = logical(bitget(bitPattern,1:6));
    plan = dynotPercentilePlan(selection);

    verifyEqual(testCase, ...
        plan.percentiles(plan.medianIndex),50,'AbsTol',0);
    verifyEqual(testCase,plan.intervalCount,nnz(selection(2:end)));
    verifyEqual(testCase,numel(plan.percentiles), ...
        2*plan.intervalCount+1);
    verifyEqual(testCase,plan.medianIndex,plan.intervalCount+1);

    actualPairs = [ ...
        plan.percentiles(1:plan.intervalCount).', ...
        flip(plan.percentiles(plan.medianIndex+1:end)).'];
    expectedPairs = expectedEndpointPairs(selection(2:end),:);
    expectedPairs = sortrows(expectedPairs,1);
    verifyEqual(testCase,actualPairs,expectedPairs,'AbsTol',0, ...
        'A checkbox combination changed its requested CI endpoints.');
end
end

function testInvalidConfidenceSelectionIsRejected(testCase)
verifyError(testCase,@()dynotPercentilePlan([1 1 1]), ...
    'Acycle:DYNOT:InvalidPercentileSelection');
verifyError(testCase,@()dynotPercentilePlan([1 1 1 1 1 2]), ...
    'Acycle:DYNOT:InvalidPercentileSelection');
end

function testCutNormalizesAndPersistsStateAndEditValues(testCase)
x = (0:0.5:20)';
context = struct('current_data',[x,sin(x)],'dat_name','dynot-cut');
guiFigure = DYNOS(context);
testCase.addTeardown(@()closeIfValid(guiFigure));
state = getappdata(guiFigure,'DYNOS_STATE');

state.ECut1.Value = '15';
state.ECut2.Value = '5';
callback = state.BCut.ButtonPushedFcn;
callback(state.BCut,[]);
drawnow;

state = getappdata(guiFigure,'DYNOS_STATE');
verifyEqual(testCase,state.cut1,5,'AbsTol',0);
verifyEqual(testCase,state.cut2,15,'AbsTol',0);
verifyEqual(testCase,str2double(state.ECut1.Value),5,'AbsTol',0);
verifyEqual(testCase,str2double(state.ECut2.Value),15,'AbsTol',0);
verifyEqual(testCase,state.data(1,1),5,'AbsTol',0);
verifyEqual(testCase,state.data(end,1),15,'AbsTol',0);
end

function testSourceRestoresLegacySamplingAndWorkspaceContract(testCase)
source = fileread(fullfile(testCase.TestData.codeFolder, ...
    'guicode','DYNOS.m'));

verifyTrue(testCase,contains(source, ...
    "samplez(samplez<S.sampa) = lowerReplacement;"));
verifyTrue(testCase,contains(source, ...
    "samplez(samplez>S.sampb) = upperReplacement;"));
verifyFalse(testCase,contains(source, ...
    "rand(sum(samplez<S.sampa),1)"));
verifyFalse(testCase,contains(source, ...
    "rand(sum(samplez>S.sampb),1)"));
verifyTrue(testCase,contains(source, ...
    "assignin('base','powyad_p_grid',y_grid_nan);"));
verifyTrue(testCase,contains(source, ...
    "assignin('base','powyad_p',powyad_p_nan);"));
end

function testWaitbarProvidesCancelCallback(testCase)
source = fileread(fullfile(testCase.TestData.codeFolder, ...
    'guicode','DYNOS.m'));

verifyTrue(testCase,contains(source,"'CreateCancelBtn'"));
verifyTrue(testCase,contains(source, ...
    "error('Acycle:DYNOT:Canceled'"));
verifyTrue(testCase,contains(source,'dynotCanceled(hwb)'));
hasProgressUpdate = contains(source, ...
    'updateDynotWaitbar(hwb,completed/nmc') || ...
    contains(source,'reportDynotProgress(hwb,completed,nmc)');
verifyTrue(testCase,hasProgressUpdate);
verifyFalse(testCase,contains(source, ...
    'waitbar(i/nmc,hwb'));
end

function testInputsAreValidatedWithoutSilentMinimumClamps(testCase)
source = fileread(fullfile(testCase.TestData.codeFolder, ...
    'guicode','DYNOS.m'));

verifyFalse(testCase,contains(source, ...
    'S.nmc = max(10,round(str2double(S.ENMC.Value)))'));
verifyFalse(testCase,contains(source, ...
    'S.nout = max(100,round(str2double(S.ENout.Value)))'));
verifyTrue(testCase,contains(source, ...
    "S.nmc = positiveIntegerInput(S.ENMC.Value"));
verifyTrue(testCase,contains(source, ...
    "S.nout = positiveIntegerInput(S.ENout.Value"));
verifyTrue(testCase,contains(source, ...
    "S.itinerary = min(S.itinerary,S.nmc);"));
verifyTrue(testCase,contains(source, ...
    'S.numcore = min(S.numcore,dynotPhysicalCoreCount());'));
end

function testDefaultMonteCarloCountIsSixty(testCase)
x = (0:0.5:20)';
context = struct('current_data',[x,sin(x)],'dat_name','dynot-default-nmc');
guiFigure = DYNOS(context);
testCase.addTeardown(@()closeIfValid(guiFigure));
state = getappdata(guiFigure,'DYNOS_STATE');

verifyEqual(testCase,state.nmc,60,'AbsTol',0);
verifyEqual(testCase,str2double(state.ENMC.Value),60,'AbsTol',0);
end

function testProcessControlsDriveSafeParallelScheduler(testCase)
source = fileread(fullfile(testCase.TestData.codeFolder, ...
    'guicode','DYNOS.m'));

verifyTrue(testCase,contains(source, ...
    'S.numcore > 1 && nmc > 199 && S.itinerary < nmc'));
verifyTrue(testCase,contains(source,'parfeval(pool,@dynotIterationWorker'));
verifyTrue(testCase,contains(source,'fetchNext(futures,0.1)'));
verifyTrue(testCase,contains(source,'cancel(futures)'));
verifyTrue(testCase,contains(source,"pool = gcp('nocreate')"));
verifyTrue(testCase,contains(source,'if ownedPool'));
verifyFalse(testCase,contains(source,'delete(gcp('));
end

function testProcessPanelMatchesSchedulerAndCancelBehavior(testCase)
x = (0:0.5:20)';
context = struct('current_data',[x,sin(x)],'dat_name','dynot-process');
guiFigure = DYNOS(context);
testCase.addTeardown(@()closeIfValid(guiFigure));
state = getappdata(guiFigure,'DYNOS_STATE');

verifyEqual(testCase,state.TCore.Text,'Number of physical cores to use');
verifyEqual(testCase,state.TIt2.Text, ...
    'iterations run serially before parallel work');
tips = lower(strjoin(string(state.TTips.Value)," "));
verifyTrue(testCase,contains(tips,"more than 199 simulations"));
verifyTrue(testCase,contains(tips,"serially"));
verifyTrue(testCase,contains(tips,"selected cores"));
verifyTrue(testCase,contains(tips,"cancel"));
verifyTrue(testCase,contains(tips,"manages its worker pool"));
verifyFalse(testCase,contains(tips,"ctrl"));
verifyFalse(testCase,contains(tips,"delete(gcp"));
end

function testParallelWorkerMatchesDirectPdanCalculation(testCase)
coordinate = (0:0.5:80)';
values = sin(2*pi*coordinate/15)+0.2*cos(2*pi*coordinate/8);
data = [coordinate,values];
yGrid = linspace(coordinate(1),coordinate(end),101)';
sample = 0.5;
window = 30;
nw = 2;
targetBands = [0.04 0.09 0.08 0.14];
options = struct('padwin',0,'ftmin',0.001,'ftmax',1, ...
    'step',2,'pad',128);

[actualColumn,actualMean] = dynotIterationWorker( ...
    data,yGrid,sample,window,nw,targetBands,options);
power = pdan(data,targetBands,window,nw, ...
    options.ftmin,options.ftmax,options.step,options.pad);
expectedColumn = interp1(power(:,1),power(:,2),yGrid);
expectedMean = mean(power(:,2),'omitnan');

verifyEqual(testCase,actualColumn,expectedColumn,'AbsTol',1e-12);
verifyEqual(testCase,actualMean,expectedMean,'AbsTol',1e-12);
end

function closeIfValid(handle)
if ~isempty(handle) && isgraphics(handle)
    delete(handle);
end
end
