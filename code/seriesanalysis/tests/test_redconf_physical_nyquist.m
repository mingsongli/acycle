function tests = test_redconf_physical_nyquist
%TEST_REDCONF_PHYSICAL_NYQUIST Regression tests for FMAX/Nyquist separation.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
seriesDirectory = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
addpath(seriesDirectory);
testCase.addTeardown(@()path(oldPath));
end

function testTruncatedFmaxUsesPhysicalNyquistForBothBackgrounds(testCase)
dt = 0.25;
n = 256;
physicalNyquist = 1/(2*dt);
displayMaximum = 0.65*physicalNyquist;
values = correlatedSeries(n,dt);

[rhoM,s0M,conventional,robust] = redconfML( ...
    values,dt,2,n,1,0.2,displayMaximum,0);
[rhoFull,s0Full,conventionalFull,robustFull] = redconfML( ...
    values,dt,2,n,1,0.2,physicalNyquist,0);

verifyEqual(testCase,rhoM,rhoFull,'AbsTol',0);
verifyEqual(testCase,s0M,s0Full,'AbsTol',0);
verifyEqual(testCase,conventional,conventionalFull,'AbsTol',0);
verifyEqual(testCase,robust,robustFull,'AbsTol',0);
verifyEqual(testCase,robust(end,1),physicalNyquist,'AbsTol',0);
expectedRobust = ar1Background( ...
    robust(:,1),s0M,rhoM,physicalNyquist);
wrongRobust = ar1Background( ...
    robust(:,1),s0M,rhoM,displayMaximum);
verifyEqual(testCase,robust(:,3),expectedRobust, ...
    'RelTol',2e-14,'AbsTol',2e-14*max(abs(expectedRobust)));
verifyGreaterThan(testCase,max(abs(robust(:,3)-wrongRobust)),1e-5);

smoothBins = round(0.2*size(robust,1));
fitSmooth = moveMedian(robust(:,2),smoothBins);
conventionalRho = rhoAR1(values);
expectedConventional = ar1Background( ...
    conventional(:,1),mean(fitSmooth),conventionalRho,physicalNyquist);
wrongConventional = ar1Background( ...
    conventional(:,1),mean(fitSmooth),conventionalRho,displayMaximum);
verifyEqual(testCase,conventional(:,4),expectedConventional, ...
    'RelTol',2e-14,'AbsTol',2e-14*max(abs(expectedConventional)));
verifyGreaterThan(testCase, ...
    max(abs(conventional(:,4)-wrongConventional)),1e-5);
end

function testDefaultNyquistKeepsFullOddLengthDftGrid(testCase)
dt = 0.25;
n = 65;
physicalNyquist = 1/(2*dt);
values = correlatedSeries(n,dt);

oldVisibility = get(groot,'defaultFigureVisible');
visibilityCleanup = onCleanup( ...
    @()set(groot,'defaultFigureVisible',oldVisibility));
set(groot,'defaultFigureVisible','off');
figuresBefore = findall(groot,'Type','figure');
[rhoDefault,s0Default,~,defaultResult] = redconfML( ...
    values,dt,2,n,1,0.2);
figuresAfter = findall(groot,'Type','figure');
newFigures = setdiff(figuresAfter,figuresBefore);
delete(newFigures);
clear visibilityCleanup

[rhoExplicit,s0Explicit,~,explicitResult] = redconfML( ...
    values,dt,2,n,1,0.2,physicalNyquist,0);
verifyEqual(testCase,rhoDefault,rhoExplicit,'AbsTol',0);
verifyEqual(testCase,s0Default,s0Explicit,'AbsTol',0);
verifyEqual(testCase,defaultResult,explicitResult,'AbsTol',0);

expectedLastFrequency = floor(n/2)/(n*dt);
verifyEqual(testCase,defaultResult(end,1),expectedLastFrequency, ...
    'AbsTol',4*eps(physicalNyquist));
verifyLessThan(testCase,defaultResult(end,1),physicalNyquist);
expectedBackground = ar1Background( ...
    defaultResult(:,1),s0Default,rhoDefault,physicalNyquist);
verifyEqual(testCase,defaultResult(:,3),expectedBackground, ...
    'RelTol',2e-14,'AbsTol',2e-14*max(abs(expectedBackground)));
end

function testFmaxGuardRejectsInvalidOrUnusableSupport(testCase)
dt = 0.25;
n = 64;
values = correlatedSeries(n,dt);
physicalNyquist = 1/(2*dt);

invalid = {0,-1,NaN,Inf,[0.5,1],complex(0.5,0.1)};
for index = 1:numel(invalid)
    verifyError(testCase,@()redconfML( ...
        values,dt,2,n,1,0.2,invalid{index},0), ...
        'Acycle:RedconfML:InvalidFmax');
end
verifyError(testCase,@()redconfML( ...
    values,dt,2,n,1,0.2,physicalNyquist*(1+1e-6),0), ...
    'Acycle:RedconfML:FmaxAbovePhysicalNyquist');
[rhoSmall,s0Small,~,smallDisplay] = redconfML( ...
    values,dt,2,n,1,0.2,0.25/(n*dt),0);
[rhoFull,s0Full,~,fullDisplay] = redconfML( ...
    values,dt,2,n,1,0.2,physicalNyquist,0);
verifyEqual(testCase,rhoSmall,rhoFull,'AbsTol',0);
verifyEqual(testCase,s0Small,s0Full,'AbsTol',0);
verifyEqual(testCase,smallDisplay,fullDisplay,'AbsTol',0);
end

function testLombDisplayLimitDoesNotChangeFitOrBackground(testCase)
n = 96;
baseSpacing = 0.25;
spacing = baseSpacing*(1+0.18*sin((1:n-1)'*0.37));
timex = [0;cumsum(spacing)];
values = correlatedSeriesAtCoordinates(timex);
effectiveSpacing = median(diff(timex));
physicalNyquist = 1/(2*effectiveSpacing);
displayMaximum = 0.6*physicalNyquist;
meanBasedNyquist = 1/(2*mean(diff(timex)));
verifyGreaterThan(testCase,abs(physicalNyquist-meanBasedNyquist),1e-6);

[powerDisplay,frequencyDisplay,thresholdDisplay] = plomb_robustar1( ...
    values,timex,displayMaximum,0.2,0);
[powerFull,frequencyFull,thresholdFull] = plomb_robustar1( ...
    values,timex,physicalNyquist,0.2,0);
verifyEqual(testCase,powerDisplay,powerFull,'AbsTol',0);
verifyEqual(testCase,frequencyDisplay,frequencyFull,'AbsTol',0);
verifyEqual(testCase,thresholdDisplay,thresholdFull,'AbsTol',0);

smoothPower = thresholdDisplay(1,:).';
initial = [mean(powerDisplay),0.5];
physicalCosine = cos(pi*frequencyDisplay/physicalNyquist);
model = @(v,f)v(1)*(1-v(2)^2)./( ...
    1-2*v(2)*physicalCosine+v(2)^2);
fit = lsqcurvefit(model,initial,frequencyDisplay,smoothPower);
expected = ar1Background( ...
    frequencyDisplay,fit(1),fit(2),physicalNyquist);
wrong = ar1Background( ...
    frequencyDisplay,fit(1),fit(2),displayMaximum);
verifyEqual(testCase,thresholdDisplay(2,:).',expected, ...
    'RelTol',3e-13,'AbsTol',3e-13*max(abs(expected)));
verifyGreaterThan(testCase, ...
    max(abs(thresholdDisplay(2,:).'-wrong)),1e-5);
end

function values = correlatedSeries(n,dt)
coordinate = (0:n-1)'*dt;
values = correlatedSeriesAtCoordinates(coordinate);
end

function values = correlatedSeriesAtCoordinates(coordinate)
n = numel(coordinate);
innovation = sin(2*pi*0.035*coordinate) ...
    +0.35*cos(2*pi*0.19*coordinate) ...
    +0.08*sin(2*pi*0.47*coordinate);
values = zeros(n,1);
for index = 2:n
    values(index) = 0.82*values(index-1)+innovation(index);
end
end

function background = ar1Background(frequency,s0,rho,physicalNyquist)
background = s0*(1-rho^2)./(1-2*rho* ...
    cos(pi*frequency/physicalNyquist)+rho^2);
end
