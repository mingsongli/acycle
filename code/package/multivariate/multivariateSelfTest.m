function report = multivariateSelfTest()
%MULTIVARIATESELFTEST Deterministic numerical tests for the multivariate package.
%   REPORT = MULTIVARIATESELFTEST runs distance-matrix identities, PCoA
%   reconstruction and eigenvalue checks, ANOSIM/PERMANOVA statistic and
%   permutation-semantics checks, and grouping checks. All expected values
%   were cross-validated against PaleoAST (Python), whose implementations
%   agree with R (vegan::vegdist, vegan::anosim, vegan::adonis2) and
%   scipy. No files are written.

report = struct('passed',0,'failed',0,'failures',{{}});
report.failures = {};

started = tic;
oldRng = rng;
cleanupRng = onCleanup(@()rng(oldRng));
rng(2026,'twister');

% ----------------------------------------------------------------------
% 1. Tied ranks (average ranks, ascending)
% ----------------------------------------------------------------------
ranks = multivariateTiedRank([3 1 2 2]);
require(isequal(ranks,[4;1;2.5;2.5]),'tied ranks: [3 1 2 2] -> [4 1 2.5 2.5]');

ranks = multivariateTiedRank([5 5 5]);
require(isequal(ranks,[2;2;2]),'tied ranks: all-equal vector -> average rank 2');

% ----------------------------------------------------------------------
% 2. Distance matrices (golden values validated against scipy/vegan)
% ----------------------------------------------------------------------
XA = [1.0 2.0 5.0;
      3.0 4.0 2.0;
      5.0 6.0 9.0;
      2.5 3.5 7.0];

D = multivariateDistanceMatrix(XA,'euclidean',false);
require(abs(D(1,2) - 4.1231056256) < 1e-8 && ...
        abs(D(1,4) - 2.9154759474) < 1e-8 && ...
        abs(D(2,3) - 7.5498344353) < 1e-8, ...
    'euclidean distances match scipy.spatial.distance');
require(issymmetric(D) && all(diag(D) == 0), ...
    'euclidean matrix is symmetric with zero diagonal');

D = multivariateDistanceMatrix(XA,'manhattan',false);
require(abs(D(1,2) - 7.0) < 1e-12 && abs(D(2,3) - 11.0) < 1e-12, ...
    'manhattan distances match |dx|+|dy|+|dz|');

XB = [4.0 0.0 2.0 1.0;
      3.0 1.0 0.0 0.0;
      0.0 5.0 1.0 2.0;
      2.0 2.0 2.0 2.0;
      10.0 0.0 0.0 1.0];
D = multivariateDistanceMatrix(XB,'braycurtis',false);
require(abs(D(1,2) - 0.4545454545) < 1e-8 && ...
        abs(D(3,5) - 0.8947368421) < 1e-8 && ...
        abs(D(1,4) - 0.3333333333) < 1e-8, ...
    'bray-curtis distances match vegan::vegdist');
require(all(D(:) >= 0 & D(:) <= 1),'bray-curtis distances stay inside [0, 1]');

XC = [1 1 0 0 1;
      1 1 1 0 0;
      0 0 1 1 0;
      1 0 0 0 0];
D = multivariateDistanceMatrix(XC,'jaccard',false);
require(abs(D(1,2) - 0.5) < 1e-12 && abs(D(2,3) - 0.75) < 1e-12 && ...
        abs(D(1,3) - 1.0) < 1e-12 && abs(D(3,4) - 1.0) < 1e-12, ...
    'jaccard distances match the presence/absence definition');

% Standardization: z-scored columns, then Euclidean, must equal the
% distance computed directly on the z-scores.
Xz = (XA - mean(XA,1)) ./ std(XA,0,1);
D1 = multivariateDistanceMatrix(XA,'euclidean',true);
D2 = multivariateDistanceMatrix(Xz,'euclidean',false);
require(max(abs(D1(:) - D2(:))) < 1e-12, ...
    'standardized euclidean distance equals euclidean distance of z-scores');

% Bray-Curtis must refuse negative data.
negativeThrown = false;
try
    multivariateDistanceMatrix([1 -2; 3 4],'braycurtis',false);
catch ME
    negativeThrown = strcmp(ME.identifier,'Acycle:Multivariate:NegativeData');
end
require(negativeThrown,'bray-curtis rejects negative abundances');

% ----------------------------------------------------------------------
% 3. PCoA
% ----------------------------------------------------------------------
% Euclidean input: the embedding must reproduce the input distances, and
% all eigenvalues must be non-negative.
points = [0.0 0.0; 1.0 2.0; 4.0 1.0; 2.0 5.0];
D = multivariateDistanceMatrix(points,'euclidean',false);
result = multivariatePcoa(D);
require(result.negativeEigenvalueSum >= -1e-10, ...
    'PCoA of euclidean distances has no negative eigenvalues');
Drecovered = multivariateDistanceMatrix(result.coordinates,'euclidean',false);
require(max(abs(Drecovered(:) - D(:))) < 1e-8, ...
    'PCoA embedding reproduces euclidean distances (Gower 1966)');

% Collinear samples at 1, 5, 9: eigenvalues [32 0 0], first axis carries
% 100% of the positive part.
D = multivariateDistanceMatrix([1;5;9],'euclidean',false);
result = multivariatePcoa(D);
require(abs(result.allEigenvalues(1) - 32) < 1e-8, ...
    'collinear samples: leading eigenvalue is 32');
require(abs(result.proportionExplained(1) - 100) < 1e-8, ...
    'collinear samples: PC1 explains 100 percent');

% Bray-Curtis input with negative eigenvalues (golden values from PaleoAST
% PCoAAnalyzer, which agrees with R cmdscale):
D = multivariateDistanceMatrix(XB,'braycurtis',false);
result = multivariatePcoa(D,'Correction','cmdscale');
require(abs(result.allEigenvalues(1) - 0.5056774020) < 1e-8 && ...
        abs(result.allEigenvalues(2) - 0.1854150463) < 1e-8 && ...
        abs(result.allEigenvalues(3) - 0.0815216636) < 1e-8, ...
    'PCoA cmdscale eigenvalues match PaleoAST/R');
require(abs(result.negativeEigenvalueSum - (-0.0192543462)) < 1e-8, ...
    'PCoA cmdscale negative eigenvalue sum matches PaleoAST/R');
require(abs(result.proportionExplained(1) - 65.4501897095) < 1e-6 && ...
        abs(result.proportionExplained(2) - 23.9984027544) < 1e-6, ...
    'PCoA proportions use the sum of all positive eigenvalues');

% Lingoes correction must land the most negative eigenvalue on zero.
result = multivariatePcoa(D,'Correction','lingoes');
require(abs(min(result.allEigenvalues)) < 1e-10, ...
    'PCoA lingoes correction zeroes the smallest eigenvalue');

% ----------------------------------------------------------------------
% 4. Group labels from boundaries
% ----------------------------------------------------------------------
axisValues = (1:24)' * 0.5;   % 0.5 .. 12
[groups,groupNames] = multivariateGroupLabels(axisValues,[4 8]);
require(isequal(groups(1:7),ones(7,1)) && isequal(groups(8:15),2*ones(8,1)) && ...
        isequal(groups(16:24),3*ones(9,1)), ...
    'boundaries [4 8] split the axis into G1/G2/G3');
require(isequal(groupNames,{'G1','G2','G3'}),'group names are G1, G2, G3');

[groups,groupNames] = multivariateGroupLabels(axisValues,[]);
require(all(groups == 1) && isequal(groupNames,{'G1'}), ...
    'empty boundaries give a single group');

unsortedThrown = false;
try
    multivariateGroupLabels(axisValues,[8 4]);
catch ME
    unsortedThrown = strcmp(ME.identifier,'Acycle:Multivariate:UnsortedBoundaries');
end
require(unsortedThrown,'unsorted boundaries are rejected');

% ----------------------------------------------------------------------
% 5. ANOSIM
% ----------------------------------------------------------------------
% Fixture cross-validated against PaleoAST/R vegan::anosim (numpy draws,
% values embedded so the test is deterministic in MATLAB):
XD = [0.7739560485559633 0.4388784397520523;
      0.8585979199113825 0.6973680290593639;
      0.0941773478876495 0.9756223516367559;
      0.7611397019903530 0.7860643052769538;
      0.1281136326755459 0.4503859378955671;
      0.3707980242325812 0.9267649888486018;
      1.6438651200806644 1.8227616132708300;
      1.4434141988273312 1.2272387217847769;
      1.5545847870158349 1.0638172561041754;
      1.8276311719925822 1.6316643991220650;
      1.7580877400853738 1.3545259681298685;
      1.9706980243949033 1.8931211213221977];
groupsD = [ones(6,1);2*ones(6,1)];

D = multivariateDistanceMatrix(XD,'euclidean',false);
result = multivariateAnosim(D,groupsD,'Permutations',199,'RandomSeed',123);
require(abs(result.statistic - 0.9722222222) < 1e-8, ...
    sprintf('ANOSIM R matches PaleoAST/vegan (%.10f)',result.statistic));
require(abs(result.rPai - 0.9745370370) < 1e-8, ...
    'ANOSIM PAI correction matches vegan::anosim');
require(result.pValue > 0 && result.pValue <= 1,'ANOSIM p-value inside (0, 1]');
require(isequal(result.groupCounts,[1 6;2 6]),'ANOSIM group counts are 6 and 6');

result2 = multivariateAnosim(D,groupsD,'Permutations',199,'RandomSeed',123);
require(result2.pValue == result.pValue, ...
    'ANOSIM p-value is reproducible with a fixed seed');

% Perfect separation: R is exactly 1.
Dperfect = [0.0 0.1 0.1 9.0 9.2 9.1;
            0.1 0.0 0.2 9.1 9.0 9.3;
            0.1 0.2 0.0 9.2 9.3 9.0;
            9.0 9.1 9.2 0.0 0.1 0.2;
            9.2 9.0 9.3 0.1 0.0 0.1;
            9.1 9.3 9.0 0.2 0.1 0.0];
result = multivariateAnosim(Dperfect,[ones(3,1);2*ones(3,1)], ...
    'Permutations',99,'RandomSeed',5);
require(abs(result.statistic - 1) < 1e-12,'ANOSIM perfect separation gives R = 1');

% Refusals: one group, no replication.
requireThrows(@()multivariateAnosim(D,ones(12,1)), ...
    'Acycle:Multivariate:NeedTwoGroups','ANOSIM refuses a single group');
requireThrows(@()multivariateAnosim(D,(1:12)'), ...
    'Acycle:Multivariate:NeedReplication','ANOSIM requires within-group pairs');

% ----------------------------------------------------------------------
% 6. PERMANOVA
% ----------------------------------------------------------------------
D = multivariateDistanceMatrix(XD,'euclidean',false);
result = multivariatePermanova(D,groupsD,'Permutations',199,'RandomSeed',123);
require(abs(result.fStatistic - 38.6610023689) < 1e-6, ...
    sprintf('PERMANOVA F matches PaleoAST/adonis2 (%.10f)',result.fStatistic));
require(abs(result.ssTotal - 7.7895922634) < 1e-6 && ...
        abs(result.ssBetween - 6.1888047982) < 1e-6 && ...
        abs(result.ssWithin - 1.6007874651) < 1e-6, ...
    'PERMANOVA sums of squares match Anderson (2001)');
require(result.dfBetween == 1 && result.dfWithin == 10, ...
    'PERMANOVA df are G-1 and n-G');
require(abs(result.ssTotal - (result.ssBetween + result.ssWithin)) < 1e-10, ...
    'SS_T = SS_B + SS_W');
require(result.pValue > 0 && result.pValue <= 1,'PERMANOVA p-value inside (0, 1]');

result2 = multivariatePermanova(D,groupsD,'Permutations',199,'RandomSeed',123);
require(result2.pValue == result.pValue, ...
    'PERMANOVA p-value is reproducible with a fixed seed');

result = multivariatePermanova(Dperfect,[ones(3,1);2*ones(3,1)], ...
    'Permutations',99,'RandomSeed',5);
require(result.fStatistic > 1e4,'PERMANOVA perfect separation gives a huge F');

requireThrows(@()multivariatePermanova(D,ones(12,1)), ...
    'Acycle:Multivariate:NeedTwoGroups','PERMANOVA refuses a single group');

% A design without residual degrees of freedom must refuse the test.
Dsmall = [0 1 2 3; 1 0 1 2; 2 1 0 1; 3 2 1 0];
requireThrows(@()multivariatePermanova(Dsmall,[1 2 3 4]), ...
    'Acycle:Multivariate:NoResidualDf','PERMANOVA refuses n = G designs');

% ----------------------------------------------------------------------
report.durationSeconds = toc(started);
report.summary = sprintf( ...
    'Multivariate self test: %d passed, %d failed (%.2f s)', ...
    report.passed,report.failed,report.durationSeconds);
fprintf('%s\n',report.summary);
if report.failed > 0
    for k = 1:numel(report.failures)
        fprintf('  FAILED: %s\n',report.failures{k});
    end
    error('Acycle:Multivariate:SelfTestFailed', ...
        '%d multivariate self test(s) failed.',report.failed);
end

    function require(condition,message)
        if condition
            report.passed = report.passed + 1;
        else
            report.failed = report.failed + 1;
            report.failures{end+1} = message;
            fprintf('  FAILED: %s\n',message);
        end
    end

    function requireThrows(fn,identifier,message)
        thrown = false;
        caughtId = '';
        try
            fn();
        catch ME
            thrown = true;
            caughtId = ME.identifier;
        end
        require(thrown && strcmp(caughtId,identifier), ...
            sprintf('%s (expected error %s, got %s)',message,identifier,caughtId));
    end
end
