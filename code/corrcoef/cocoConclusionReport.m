function report = cocoConclusionReport(mode,varargin)
%COCOCONCLUSIONREPORT Build a decision-oriented COCO result summary.
%
% REPORT = COCOCONCLUSIONREPORT('confirmatory',CV) summarizes the current
% four-group bidirectional held-out cvCOCO result.  The confirmatory gate is
% p_robust = max(min p_A-to-B(r), min p_B-to-A(r)) < 0.05.  p_sym is
% reported as a secondary joint statistic and cannot override failure of
% either directional global-p curve. The report also discloses whether all
% nine periods, or only a resolved subset, participate at each directional
% best validation rate.
%
% REPORT = COCOCONCLUSIONREPORT('adaptive',CORRCI,CORR_H0) summarizes an
% Adaptive COCO result as exploratory.  Its decision is based on the
% rate-search-corrected global p-value, not on local p or pCOCO.

mode = validatestring(mode,{'confirmatory','adaptive'},mfilename,'mode',1);
switch mode
    case 'confirmatory'
        if isempty(varargin)
            error('cocoConclusionReport:MissingCVResult', ...
                'A cvCOCO result structure is required.');
        end
        report = confirmatoryReport(varargin{1});
    case 'adaptive'
        if numel(varargin) < 2
            error('cocoConclusionReport:MissingAdaptiveResult', ...
                'Adaptive COCO corrCI and corr_h0 arrays are required.');
        end
        details = [];
        if numel(varargin) >= 3
            details = varargin{3};
        end
        report = adaptiveReport(varargin{1},varargin{2},details);
end
end

function report = confirmatoryReport(cv)
required = {'srGrid','pCurveAtoB','pCurveBtoA','pA','pB','pSym', ...
    'validateAtoB','validateBtoA','targetModel','groupNames', ...
    'orbitCountA','orbitCountB','resolvableGroupCountA', ...
    'resolvableGroupCountB','pAConfidenceInterval','pBConfidenceInterval', ...
    'pSymConfidenceInterval','rhoMA','rhoMB','rhoMethodA','rhoMethodB', ...
    'scoreSymmetric','nullSymmetric','nullAtoB','nullBtoA', ...
    'nsimCompleted','nsimValid','nsimValidAtoB','nsimValidBtoA'};
required = [required,{'activeOrbitCountAtoB','activeOrbitCountBtoA', ...
    'activeGroupCountAtoB','activeGroupCountBtoA'}];
validateResultFields(cv,required,'confirmatory cvCOCO');
if ~((ischar(cv.targetModel) && isrow(cv.targetModel)) || ...
        (isstring(cv.targetModel) && isscalar(cv.targetModel)))
    error('cocoConclusionReport:InvalidTargetModel', ...
        'targetModel must be a character vector or scalar string.');
end
targetModel = char(cv.targetModel);
if ~strcmp(targetModel,'four-group')
    error('cocoConclusionReport:LegacyTargetNotConfirmatory', ...
        ['A confirmatory report requires targetModel=''four-group''. ', ...
         'Legacy and coherent-nine target variants have separate ', ...
         'analysis roles and must not be presented as the publication-', ...
         'audited confirmatory cvCOCO method.']);
end
groupNames = normalizeGroupNames(cv.groupNames);
groupOrderText = strjoin(groupNames,' / ');
validateRhoField(cv.rhoMA,'rhoMA');
validateRhoField(cv.rhoMB,'rhoMB');

alpha = 0.05;
[pAtoB,~] = minimumFinite(cv.pCurveAtoB);
[pBtoA,~] = minimumFinite(cv.pCurveBtoA);
if ~isfinite(pAtoB) || ~isfinite(pBtoA)
    error('cocoConclusionReport:MissingDirectionalP', ...
        'Both directional global-p curves must contain a finite value.');
end

% A -> B holds Segment B out and is p_B; B -> A holds Segment A out and
% is p_A.  Keep this invariant explicit so future plotting or indexing
% changes cannot silently corrupt the conclusion report.
assertSameP(pAtoB,cv.pB,'A-to-B minimum global p','p_B');
assertSameP(pBtoA,cv.pA,'B-to-A minimum global p','p_A');

sr = cv.srGrid(:);
if numel(sr) ~= numel(cv.pCurveAtoB) || ...
        numel(sr) ~= numel(cv.pCurveBtoA)
    error('cocoConclusionReport:RateCurveSizeMismatch', ...
        'The sedimentation-rate grid and directional p curves must match.');
end
if any(~isfinite(sr)) || any(sr <= 0) || any(diff(sr) <= 0)
    error('cocoConclusionReport:InvalidRateGrid', ...
        'The cvCOCO sedimentation-rate grid must be finite, positive, and increasing.');
end
finiteDirectionalP = [cv.pCurveAtoB(isfinite(cv.pCurveAtoB)); ...
    cv.pCurveBtoA(isfinite(cv.pCurveBtoA))];
if any(finiteDirectionalP < 0 | finiteDirectionalP > 1)
    error('cocoConclusionReport:InvalidDirectionalP', ...
        'Directional global p-values must lie between zero and one.');
end
bestRateAtoB = validationBestRate(cv.validateAtoB,'A-to-B');
bestRateBtoA = validationBestRate(cv.validateBtoA,'B-to-A');
bestIndexAtoB = rateIndex(sr,bestRateAtoB,'A-to-B');
bestIndexBtoA = rateIndex(sr,bestRateBtoA,'B-to-A');
assertSameP(cv.pCurveAtoB(bestIndexAtoB),pAtoB, ...
    'A-to-B global p at the maximum-correlation rate', ...
    'minimum A-to-B global p');
assertSameP(cv.pCurveBtoA(bestIndexBtoA),pBtoA, ...
    'B-to-A global p at the maximum-correlation rate', ...
    'minimum B-to-A global p');

% A -> B validates Segment B; B -> A validates Segment A.  Report the
% actual target dimensionality at each selected validation rate because
% validation remains calculable outside the strict all-nine range.
resolvablePeriodCountAtoB = participationCount( ...
    cv.orbitCountB,bestIndexAtoB,numel(sr),'A-to-B');
resolvablePeriodCountBtoA = participationCount( ...
    cv.orbitCountA,bestIndexBtoA,numel(sr),'B-to-A');
resolvableGroupCountsAtoB = participationGroups( ...
    cv.resolvableGroupCountB,bestIndexAtoB,numel(sr),'A-to-B');
resolvableGroupCountsBtoA = participationGroups( ...
    cv.resolvableGroupCountA,bestIndexBtoA,numel(sr),'B-to-A');
if sum(resolvableGroupCountsAtoB) ~= resolvablePeriodCountAtoB || ...
        sum(resolvableGroupCountsBtoA) ~= resolvablePeriodCountBtoA
    error('cocoConclusionReport:ParticipationInvariant', ...
        ['Resolvable group counts do not sum to the corresponding ', ...
         'resolvable-period count.']);
end
periodCountAtoB = participationCount( ...
    cv.activeOrbitCountAtoB,bestIndexAtoB,numel(sr),'A-to-B active');
periodCountBtoA = participationCount( ...
    cv.activeOrbitCountBtoA,bestIndexBtoA,numel(sr),'B-to-A active');
groupCountsAtoB = participationGroups( ...
    cv.activeGroupCountAtoB,bestIndexAtoB,numel(sr),'A-to-B active');
groupCountsBtoA = participationGroups( ...
    cv.activeGroupCountBtoA,bestIndexBtoA,numel(sr),'B-to-A active');
assertAttachedParticipation(cv.validateAtoB,periodCountAtoB, ...
    groupCountsAtoB,'A-to-B');
assertAttachedParticipation(cv.validateBtoA,periodCountBtoA, ...
    groupCountsBtoA,'B-to-A');
if periodCountAtoB > resolvablePeriodCountAtoB || ...
        periodCountBtoA > resolvablePeriodCountBtoA || ...
        any(groupCountsAtoB > resolvableGroupCountsAtoB) || ...
        any(groupCountsBtoA > resolvableGroupCountsBtoA)
    error('cocoConclusionReport:ActiveParticipationInvariant', ...
        'Nonzero-weight participating periods cannot exceed resolvable periods.');
end
allNineAtBothBestRates = periodCountAtoB == 9 && ...
    periodCountBtoA == 9;

pRobust = max(pAtoB,pBtoA);
pSym = scalarFiniteOrNaN(cv.pSym);
if isfinite(pSym) && (pSym < 0 || pSym > 1)
    error('cocoConclusionReport:InvalidSymmetricP', ...
        'The symmetric Monte Carlo p-value must lie between zero and one.');
end
directionalPass = pRobust < alpha;
symmetricPass = isfinite(pSym) && pSym < alpha;
ciA = validateProbabilityInterval(cv.pAConfidenceInterval,'p_A');
ciB = validateProbabilityInterval(cv.pBConfidenceInterval,'p_B');
ciSym = validateProbabilityInterval(cv.pSymConfidenceInterval,'p_sym');
[expectedPB,nAtoB,expectedCIB] = monteCarloAudit( ...
    cv.nullAtoB,cv.validateAtoB.score,'A-to-B');
[expectedPA,nBtoA,expectedCIA] = monteCarloAudit( ...
    cv.nullBtoA,cv.validateBtoA.score,'B-to-A');
[expectedPSym,nSym,expectedCISym] = monteCarloAudit( ...
    cv.nullSymmetric,cv.scoreSymmetric,'symmetric');
assertSameP(expectedPA,cv.pA,'p_A recomputed from null maxima','stored p_A');
assertSameP(expectedPB,cv.pB,'p_B recomputed from null maxima','stored p_B');
assertSameP(expectedPSym,pSym, ...
    'p_sym recomputed from the symmetric null','stored p_sym');
assertIntervalSame(expectedCIA,ciA,'p_A');
assertIntervalSame(expectedCIB,ciB,'p_B');
assertIntervalSame(expectedCISym,ciSym,'p_sym');
validateMonteCarloCounts(cv,nSym,nAtoB,nBtoA);
validateSymmetricStatisticAudit(cv);
thresholdResolvedA = (cv.pA < alpha && ciA(2) < alpha) || ...
    (cv.pA >= alpha && ciA(1) >= alpha);
thresholdResolvedB = (cv.pB < alpha && ciB(2) < alpha) || ...
    (cv.pB >= alpha && ciB(1) >= alpha);
monteCarloThresholdResolved = thresholdResolvedA && thresholdResolvedB;
thresholdResolvedSym = (pSym < alpha && ciSym(2) < alpha) || ...
    (pSym >= alpha && ciSym(1) >= alpha);

if directionalPass && symmetricPass
    classification = 'Robust positive';
    conclusion = ['PASS: both directional global-p curves cross 0.05, ', ...
        'and the secondary symmetric joint test is significant.'];
elseif directionalPass
    classification = 'Directional robust; symmetric test not significant';
    conclusion = ['PASS by the directional robustness rule, but the ', ...
        'secondary symmetric joint test is not significant; report this ', ...
        'qualification explicitly.'];
elseif symmetricPass
    classification = 'Joint-only / inconclusive';
    conclusion = ['NOT A ROBUST DETECTION: p_sym is significant, but at ', ...
        'least one directional global-p curve never crosses 0.05.'];
else
    classification = 'Negative';
    conclusion = ['NOT A ROBUST DETECTION: the bidirectional global-p ', ...
        'criterion is not satisfied.'];
end

if allNineAtBothBestRates
    participationQualification = [ ...
        'Both directional best-rate validations include all nine ', ...
        'astronomical periods.'];
else
    participationQualification = sprintf([ ...
        'QUALIFICATION: after applying the frozen nonzero group weights, ', ...
        'the best-rate validation uses %d/9 periods for A-to-B and %d/9 ', ...
        'for B-to-A (frequency-resolvable counts %d/9 and %d/9). The ', ...
        'p_robust decision is ', ...
        'unchanged, but any positive result confirms association with ', ...
        'the resolved partial orbital target, not with all nine periods.'], ...
        periodCountAtoB,periodCountBtoA,resolvablePeriodCountAtoB, ...
        resolvablePeriodCountBtoA);
    if directionalPass
        classification = [classification,'; partial-period target'];
    end
end
conclusion = [conclusion,' ',participationQualification];
if ~monteCarloThresholdResolved
    precisionQualification = [ ...
        'MONTE CARLO PRECISION QUALIFICATION: at least one directional ', ...
        '95% binomial exceedance-probability interval crosses 0.05; ', ...
        'increase NSIM before treating the threshold classification as stable.'];
    conclusion = [conclusion,' ',precisionQualification];
    classification = [classification,'; Monte Carlo threshold uncertain'];
else
    precisionQualification = [ ...
        'Both directional 95% binomial exceedance-probability intervals ', ...
        'lie on the same side of 0.05 as their point decisions.'];
end
if ~thresholdResolvedSym
    symmetricPrecisionQualification = [ ...
        'SECONDARY p_sym PRECISION QUALIFICATION: its 95% binomial ', ...
        'exceedance-probability interval crosses 0.05; the point-based ', ...
        'secondary symmetric label is Monte Carlo-uncertain.'];
    conclusion = [conclusion,' ',symmetricPrecisionQualification];
    classification = [classification,'; p_sym threshold uncertain'];
else
    symmetricPrecisionQualification = [ ...
        'The secondary p_sym 95% binomial exceedance-probability interval ', ...
        'lies on the same side of 0.05 as its point decision.'];
end
directionalPQualification = [ ...
    'INFERENCE SCOPE: p_A and p_B are directional full-pipeline maxima ', ...
    'under the joint null that both segments are AR(1); they are not ', ...
    'conditional tests allowing the opposite training segment to be an ', ...
    'arbitrary fixed signal.'];
conclusion = [conclusion,' ',directionalPQualification];

report = struct;
report.mode = 'confirmatory';
report.method = 'cvCOCO (confirmatory)';
report.alphaGlobal = alpha;
report.pGlobalAtoB = pAtoB;
report.pGlobalBtoA = pBtoA;
report.pA = pBtoA;
report.pB = pAtoB;
report.pRobust = pRobust;
report.pSym = pSym;
report.bestRateAtoB = bestRateAtoB;
report.bestRateBtoA = bestRateBtoA;
report.participatingPeriodsAtoB = periodCountAtoB;
report.participatingPeriodsBtoA = periodCountBtoA;
report.resolvablePeriodsAtoB = resolvablePeriodCountAtoB;
report.resolvablePeriodsBtoA = resolvablePeriodCountBtoA;
report.participatingGroupCountsAtoB = groupCountsAtoB;
report.participatingGroupCountsBtoA = groupCountsBtoA;
report.resolvableGroupCountsAtoB = resolvableGroupCountsAtoB;
report.resolvableGroupCountsBtoA = resolvableGroupCountsBtoA;
report.allNineAtBothBestRates = allNineAtBothBestRates;
report.partialPeriodQualification = participationQualification;
report.pAExceedanceProbabilityInterval = ciA;
report.pBExceedanceProbabilityInterval = ciB;
report.pSymExceedanceProbabilityInterval = ciSym;
report.monteCarloThresholdResolved = monteCarloThresholdResolved;
report.monteCarloPrecisionQualification = precisionQualification;
report.pSymMonteCarloThresholdResolved = thresholdResolvedSym;
report.pSymMonteCarloPrecisionQualification = symmetricPrecisionQualification;
report.nullHypothesis = [ ...
    'Each separately regularized segment follows its own fitted ', ...
    'sample-index stationary Gaussian AR(1) null, with A and B simulated ', ...
    'independently; each joint-null simulation repeats bidirectional ', ...
    'training, frozen-target validation, and the sedimentation-rate search.'];
report.directionalPInterpretation = directionalPQualification;
report.rhoA = cv.rhoMA;
report.rhoB = cv.rhoMB;
report.rhoEstimatorA = cv.rhoMethodA;
report.rhoEstimatorB = cv.rhoMethodB;
report.directionalPass = directionalPass;
report.symmetricPass = symmetricPass;
report.pass = directionalPass;
report.classification = classification;
report.conclusion = conclusion;
report.summaryRows = {
    'Conclusion method',report.method;
    'Analysis role','Confirmatory bidirectional held-out validation';
    'Null hypothesis',report.nullHypothesis;
    'Directional p-value interpretation',report.directionalPInterpretation;
    'Global significance threshold',alpha;
    'Minimum global p: A-to-B (Segment B held out; p_B)',pAtoB;
    'Best A-to-B validation rate (cm/kyr)',report.bestRateAtoB;
    'Nonzero-weight participating periods: A-to-B (Segment B held out)',periodCountAtoB;
    'Frequency-resolvable periods: A-to-B',resolvablePeriodCountAtoB;
    ['Participating groups [',groupOrderText,']: A-to-B'], ...
        mat2str(groupCountsAtoB);
    'Minimum global p: B-to-A (Segment A held out; p_A)',pBtoA;
    'Best B-to-A validation rate (cm/kyr)',report.bestRateBtoA;
    'Nonzero-weight participating periods: B-to-A (Segment A held out)',periodCountBtoA;
    'Frequency-resolvable periods: B-to-A',resolvablePeriodCountBtoA;
    ['Participating groups [',groupOrderText,']: B-to-A'], ...
        mat2str(groupCountsBtoA);
    'All nine periods participate at both best rates', ...
        passFail(allNineAtBothBestRates);
    'Participation qualification',participationQualification;
    'p_robust = max(p_A,p_B)',pRobust;
    'p_A null-exceedance 95% Wilson interval',mat2str(ciA);
    'p_B null-exceedance 95% Wilson interval',mat2str(ciB);
    'Monte Carlo threshold classification stable at 0.05', ...
        passFail(monteCarloThresholdResolved);
    'Monte Carlo precision qualification',precisionQualification;
    'Directional global-p robustness criterion',passFail(directionalPass);
    'Secondary symmetric p_sym',pSym;
    'p_sym null-exceedance 95% Wilson interval',mat2str(ciSym);
    'p_sym threshold classification stable at 0.05', ...
        passFail(thresholdResolvedSym);
    'p_sym Monte Carlo precision qualification',symmetricPrecisionQualification;
    'Secondary symmetric criterion',passFail(symmetricPass);
    'Segment A AR(1) rho used in null',cv.rhoMA;
    'Segment A rho estimator',cv.rhoMethodA;
    'Segment B AR(1) rho used in null',cv.rhoMB;
    'Segment B rho estimator',cv.rhoMethodB;
    'Final confirmatory decision',passFail(report.pass);
    'Conclusion classification',classification;
    'Conclusion report',conclusion};
report.message = sprintf([ ...
    'cvCOCO confirmatory report\n\n', ...
    'A->B minimum global p (p_B): %.4g at %.4g cm/kyr\n', ...
    'B->A minimum global p (p_A): %.4g at %.4g cm/kyr\n', ...
    'Nonzero-weight participating periods (A->B / B->A): %d/9 / %d/9\n', ...
    'Frequency-resolvable periods (A->B / B->A): %d/9 / %d/9\n', ...
    'Group order: %s\nGroup counts A->B: %s; B->A: %s\n', ...
    'p_robust = max(p_A,p_B): %.4g  [%s at alpha=%.2g]\n', ...
    'Secondary p_sym: %.4g  [%s]\n\n%s\n%s'], ...
    pAtoB,report.bestRateAtoB,pBtoA,report.bestRateBtoA, ...
    periodCountAtoB,periodCountBtoA,resolvablePeriodCountAtoB, ...
    resolvablePeriodCountBtoA,groupOrderText, ...
    mat2str(groupCountsAtoB), ...
    mat2str(groupCountsBtoA), ...
    pRobust,passFail(directionalPass),alpha,pSym, ...
    passFail(symmetricPass),classification,conclusion);
end

function names = normalizeGroupNames(values)
try
    names = cellstr(string(values(:)));
catch
    names = {};
end
if numel(names) ~= 4 || any(cellfun(@isempty,names))
    error('cocoConclusionReport:InvalidGroupNames', ...
        'The confirmatory result must define exactly four nonempty group names.');
end
end

function count = participationCount(values,index,nRate,label)
if ~isnumeric(values) || ~isvector(values) || numel(values) ~= nRate
    error('cocoConclusionReport:ParticipationSizeMismatch', ...
        '%s participating-period curve must match the rate grid.',label);
end
count = values(index);
if ~isfinite(count) || count < 0 || count > 9 || count ~= fix(count)
    error('cocoConclusionReport:InvalidParticipationCount', ...
        '%s participating-period count must be an integer from 0 to 9.',label);
end
end

function counts = participationGroups(values,index,nRate,label)
if ~isnumeric(values) || ~isequal(size(values),[nRate,4])
    error('cocoConclusionReport:ParticipationGroupSizeMismatch', ...
        '%s group-count array must be number-of-rates by four.',label);
end
counts = values(index,:);
maximumCounts = [1 4 1 3];
if any(~isfinite(counts)) || any(counts < 0) || ...
        any(counts > maximumCounts) || any(counts ~= fix(counts))
    error('cocoConclusionReport:InvalidParticipationGroupCount', ...
        '%s group counts must be integers within [1 4 1 3].',label);
end
end

function assertAttachedParticipation(validation,count,counts,label)
required = {'participatingPeriodCount','participatingGroupCounts'};
if ~isstruct(validation) || any(~isfield(validation,required))
    error('cocoConclusionReport:MissingActiveParticipation', ...
        '%s validation lacks nonzero-weight participation diagnostics.',label);
end
attachedCount = validation.participatingPeriodCount;
attachedCounts = validation.participatingGroupCounts;
if ~isnumeric(attachedCount) || ~isscalar(attachedCount) || ...
        ~isfinite(attachedCount) || attachedCount ~= count
    error('cocoConclusionReport:InvalidActiveParticipation', ...
        '%s attached active-period diagnostic is stale or invalid.',label);
end
if ~isnumeric(attachedCounts) || numel(attachedCounts) ~= 4
    error('cocoConclusionReport:InvalidActiveParticipation', ...
        '%s active group counts must contain four values.',label);
end
attachedCounts = attachedCounts(:)';
if ~isequal(attachedCounts,counts)
    error('cocoConclusionReport:InvalidActiveParticipation', ...
        '%s attached active-group diagnostic is stale or invalid.',label);
end
end

function validateRhoField(value,label)
if ~isnumeric(value) || ~isscalar(value) || ~isreal(value) || ...
        ~isfinite(value) || value <= -1 || value >= 1
    error('cocoConclusionReport:InvalidRho', ...
        '%s must be one finite stationary AR(1) coefficient in (-1,1).',label);
end
end

function report = adaptiveReport(corrCI,corrH0,details)
validateattributes(corrCI,{'numeric'},{'2d','real','nonempty'}, ...
    mfilename,'corrCI',2);
validateattributes(corrH0,{'numeric'},{'2d','real','nonempty'}, ...
    mfilename,'corr_h0',3);
if size(corrCI,2) < 2 || size(corrH0,2) < 3 || ...
        size(corrCI,1) ~= size(corrH0,1)
    error('cocoConclusionReport:InvalidAdaptiveArrays', ...
        ['Adaptive corrCI must contain rate/correlation columns, and ', ...
         'corr_h0 must contain global-p/orbit-count/local-p columns with ', ...
         'the same number of rows.']);
end

alphaGlobal = 0.05;
alphaLocal = 0.01;
adaptiveVariant = '';
if isstruct(details) && isscalar(details) && isfield(details,'targetMode')
    adaptiveVariant = lower(char(string(details.targetMode)));
end
isAdaptive9A = any(strcmp(adaptiveVariant,{'adaptive9a','adaptive9'}));
isAdaptive9B = strcmp(adaptiveVariant,'adaptive9b');
adaptiveName = 'Adaptive COCO';
amplitudeMode = 'adaptive';
amplitudeMethod = ...
    'Per-orbit maximum PSD in each +/-1-Rayleigh band';
targetNullRule = [ ...
    'phase-averaged noncoherent adaptive target-amplitude estimation, ', ...
    'unique nearest-orbit assignment of overlapping band bins, and the '];
if isAdaptive9A
    adaptiveName = 'Adaptive COCO9A';
    amplitudeMethod = ...
        'Method A: per-orbit maximum PSD in each +/-1-Rayleigh band';
    targetNullRule = [ ...
        'nine per-orbit +/-1-Rayleigh peak amplitudes with unique ', ...
        'nearest-orbit assignment of overlapping band bins, coherent ', ...
        'nine-term target synthesis, and the '];
elseif isAdaptive9B
    adaptiveName = 'Adaptive COCO9B';
    amplitudeMode = 'four-group-area';
    amplitudeMethod = [ ...
        'Method B: four group-band spectral areas de-mixed by a ', ...
        'finite-record leakage matrix and exact nonnegative least squares'];
    targetNullRule = [ ...
        'four group-band spectral-area amplitudes, 4-by-4 finite-record ', ...
        'leakage correction with exact nonnegative least squares, ', ...
        'expansion to a coherent nine-term target, and the '];
end
rate = corrCI(:,1);
rho = corrCI(:,2);
pGlobal = corrH0(:,1);
if any(~isfinite(rate)) || any(rate <= 0) || any(diff(rate) <= 0)
    error('cocoConclusionReport:InvalidAdaptiveRateGrid', ...
        'The complete Adaptive sedimentation-rate grid must be finite, positive, and increasing.');
end
valid = isfinite(rho) & isfinite(pGlobal);
if ~any(valid)
    error('cocoConclusionReport:MissingAdaptiveP', ...
        'The Adaptive COCO result has no finite global p-value.');
end
if any(rho(valid) < -1-1e-12 | rho(valid) > 1+1e-12) || ...
        any(pGlobal(valid) < 0 | pGlobal(valid) > 1)
    error('cocoConclusionReport:InvalidAdaptiveStatistic', ...
        'Adaptive correlations and global p-values fall outside valid ranges.');
end
validLocal = isfinite(corrH0(:,3));
if any(corrH0(validLocal,3) < 0 | corrH0(validLocal,3) > 1)
    error('cocoConclusionReport:InvalidAdaptiveLocalP', ...
        'Adaptive local p-values must lie between zero and one.');
end
bothP = valid & validLocal;
if any(pGlobal(bothP)+1e-12 < corrH0(bothP,3))
    error('cocoConclusionReport:AdaptivePInvariant', ...
        ['A max-statistic global p-value cannot be smaller than its ', ...
         'same-rate local p-value.']);
end

validIndex = find(valid);
[bestCorrelation,relativeBest] = max(rho(valid));
bestIndex = validIndex(relativeBest);
minimumGlobalP = min(pGlobal(valid));
globalPAtBest = pGlobal(bestIndex);
if abs(globalPAtBest-minimumGlobalP) > pTolerance(globalPAtBest,minimumGlobalP)
    error('cocoConclusionReport:AdaptiveBestMismatch', ...
        ['The maximum-correlation rate does not have the minimum global ', ...
         'p-value. Check the max-statistic p-curve construction.']);
end

localPAtBest = corrH0(bestIndex,3);
periodCountAtBest = corrH0(bestIndex,2);
if ~isfinite(periodCountAtBest) || periodCountAtBest < 0 || ...
        periodCountAtBest > 9 || periodCountAtBest ~= fix(periodCountAtBest)
    error('cocoConclusionReport:InvalidAdaptivePeriodCount', ...
        'The participating-period count at the best rate must be an integer from 0 to 9.');
end
globalPass = minimumGlobalP < alphaGlobal;
localPass = isfinite(localPAtBest) && localPAtBest < alphaLocal;
if globalPass
    classification = 'Exploratory positive';
    conclusion = sprintf([ ...
        'A rate-search-corrected %s association is present, but this ', ...
        'is exploratory and is not held-out confirmation.'],adaptiveName);
else
    classification = 'Exploratory negative';
    conclusion = sprintf([ ...
        'No sedimentation rate passes the %s global p < 0.05 ', ...
        'criterion.'],adaptiveName);
end
if periodCountAtBest < 9
    participationQualification = sprintf([ ...
        'QUALIFICATION: the best exploratory rate uses %d/9 distinct ', ...
        'frequency-resolved orbital periods. Any positive result concerns ', ...
        'that resolved partial target, not the complete nine-period target.'], ...
        periodCountAtBest);
    conclusion = [conclusion,' ',participationQualification];
    classification = [classification,'; partial-period target'];
else
    participationQualification = ...
        'All nine requested orbital periods participate at the best rate.';
end

report = struct;
if isAdaptive9A
    report.mode = 'adaptive9a';
elseif isAdaptive9B
    report.mode = 'adaptive9b';
else
    report.mode = 'adaptive';
end
report.method = [adaptiveName,' (exploratory)'];
report.targetAmplitudeMode = amplitudeMode;
report.targetAmplitudeMethod = amplitudeMethod;
report.nullHypothesis = [ ...
    'The regularized full record follows the fitted stationary Gaussian ', ...
    'AR(1) null; every surrogate repeats spectral preprocessing, ', ...
    targetNullRule, ...
    'complete sedimentation-rate search.'];
report.alphaGlobal = alphaGlobal;
report.alphaLocal = alphaLocal;
report.minimumGlobalP = minimumGlobalP;
report.bestRate = rate(bestIndex);
report.bestCorrelation = bestCorrelation;
report.globalPAtBest = globalPAtBest;
report.localPAtBest = localPAtBest;
report.periodCountAtBest = periodCountAtBest;
report.allNineAtBestRate = periodCountAtBest == 9;
report.partialPeriodQualification = participationQualification;
report.globalPass = globalPass;
report.localDiagnosticPass = localPass;
report.pass = globalPass;
report.classification = classification;
report.conclusion = conclusion;
report.summaryRows = {
    'Conclusion method',report.method;
    'Analysis role','Exploratory; target amplitudes and test use the full record';
    'Target amplitude mode',amplitudeMode;
    'Target amplitude method',amplitudeMethod;
    'Null hypothesis',report.nullHypothesis;
    'Global significance threshold',alphaGlobal;
    'Minimum rate-search-corrected global p',minimumGlobalP;
    'Best exploratory sedimentation rate (cm/kyr)',report.bestRate;
    'Correlation at best rate',bestCorrelation;
    'Global p at best rate',globalPAtBest;
    'Local p at best rate',localPAtBest;
    'Local diagnostic threshold',alphaLocal;
    'Local diagnostic criterion',passFail(localPass);
    'Participating periods at best rate',periodCountAtBest;
    'Participation qualification',participationQualification;
    'Final exploratory decision',passFail(globalPass);
    'Conclusion classification',classification;
    'Conclusion report',conclusion};
report.message = sprintf([ ...
    '%s exploratory report\n\n', ...
    'Best rate: %.4g cm/kyr\nCorrelation: %.4g\n', ...
    'Minimum global p: %.4g  [%s at alpha=%.2g]\n', ...
    'Local p at best rate: %.4g  [%s at alpha=%.2g]\n\n%s\n%s'], ...
    adaptiveName,report.bestRate,bestCorrelation,minimumGlobalP, ...
    passFail(globalPass),alphaGlobal,localPAtBest, ...
    passFail(localPass),alphaLocal,classification,conclusion);
end

function validateResultFields(result,required,label)
if ~isstruct(result)
    error('cocoConclusionReport:InvalidResult','%s result must be a struct.',label);
end
missing = required(~cellfun(@(name)isfield(result,name),required));
if ~isempty(missing)
    error('cocoConclusionReport:InvalidResult', ...
        '%s result is missing field(s): %s.',label,strjoin(missing,', '));
end
end

function [value,index] = minimumFinite(x)
x = x(:);
valid = find(isfinite(x));
if isempty(valid)
    value = NaN;
    index = NaN;
    return
end
[value,relativeIndex] = min(x(valid));
index = valid(relativeIndex);
end

function assertSameP(a,b,labelA,labelB)
b = scalarFiniteOrNaN(b);
if ~isfinite(a) || ~isfinite(b) || abs(a-b) > pTolerance(a,b)
    error('cocoConclusionReport:DirectionalPInvariant', ...
        '%s (%.17g) does not match %s (%.17g).',labelA,a,labelB,b);
end
end

function rate = validationBestRate(validation,label)
if ~isstruct(validation) || ~isfield(validation,'bestRate') || ...
        ~isnumeric(validation.bestRate) || ~isscalar(validation.bestRate) || ...
        ~isfinite(validation.bestRate)
    error('cocoConclusionReport:MissingBestRate', ...
        '%s validation has no finite scalar bestRate.',label);
end
rate = validation.bestRate;
end

function index = rateIndex(sr,rate,label)
tolerance = 64*eps(max(1,max(abs([sr(:);rate]))));
index = find(abs(sr-rate) <= tolerance,1);
if isempty(index)
    error('cocoConclusionReport:BestRateNotOnGrid', ...
        '%s best rate %.17g is not on the sedimentation-rate grid.', ...
        label,rate);
end
end

function tolerance = pTolerance(a,b)
tolerance = 128*eps(max([1,abs(a),abs(b)]));
end

function interval = validateProbabilityInterval(interval,label)
if ~isnumeric(interval) || numel(interval) ~= 2
    error('cocoConclusionReport:InvalidProbabilityInterval', ...
        '%s confidence interval must contain two numeric values.',label);
end
interval = interval(:)';
if any(~isfinite(interval)) || interval(1) < 0 || interval(2) > 1 || ...
        interval(1) > interval(2)
    error('cocoConclusionReport:InvalidProbabilityInterval', ...
        '%s confidence interval must be finite, ordered, and within [0,1].',label);
end
end

function [p,nValid,interval] = monteCarloAudit(nullValues,observed,label)
if ~isnumeric(nullValues) || ~isreal(nullValues) || ...
        ~isvector(nullValues) || isempty(nullValues) || ...
        any(~isfinite(nullValues)) || ~isnumeric(observed) || ...
        ~isscalar(observed) || ~isreal(observed) || ~isfinite(observed)
    error('cocoConclusionReport:InvalidMonteCarloAudit', ...
        ['The %s null distribution and observed statistic must be ', ...
         'nonempty, finite, real numeric values.'],label);
end
nullValues = nullValues(:);
nValid = numel(nullValues);
nExceed = sum(nullValues >= observed);
p = (nExceed+1)/(nValid+1);
interval = reportWilsonInterval(nExceed,nValid);
end

function validateMonteCarloCounts(cv,nSym,nAtoB,nBtoA)
fields = {'nsimCompleted','nsimValid','nsimValidAtoB','nsimValidBtoA'};
values = [cv.nsimCompleted,cv.nsimValid, ...
    cv.nsimValidAtoB,cv.nsimValidBtoA];
expected = [nSym,nSym,nAtoB,nBtoA];
if ~all(cellfun(@(name)isnumeric(cv.(name)) && ...
        isscalar(cv.(name)) && isreal(cv.(name)),fields)) || ...
        any(~isfinite(values)) || any(values ~= fix(values)) || ...
        any(values < 1) || ~isequal(values,expected)
    error('cocoConclusionReport:MonteCarloCountMismatch', ...
        ['Stored Monte Carlo counts [%s] do not match the audited null ', ...
         'distributions.'],strjoin(fields,', '));
end
end

function validateSymmetricStatisticAudit(cv)
scoreAtoB = validationScore(cv.validateAtoB,'A-to-B');
scoreBtoA = validationScore(cv.validateBtoA,'B-to-A');
expectedObserved = min(scoreAtoB,scoreBtoA);
if abs(cv.scoreSymmetric-expectedObserved) > ...
        pTolerance(cv.scoreSymmetric,expectedObserved)
    error('cocoConclusionReport:SymmetricStatisticMismatch', ...
        'scoreSymmetric is not the minimum directional validation maximum.');
end
nullAtoB = cv.nullAtoB(:);
nullBtoA = cv.nullBtoA(:);
nullSymmetric = cv.nullSymmetric(:);
if numel(nullAtoB) ~= numel(nullBtoA) || ...
        numel(nullSymmetric) ~= numel(nullAtoB)
    error('cocoConclusionReport:SymmetricNullMismatch', ...
        'Directional and symmetric null distributions must have equal length.');
end
expectedNull = min(nullAtoB,nullBtoA);
tolerance = 128*eps(max(1,max(abs([expectedNull;nullSymmetric]))));
if any(abs(nullSymmetric-expectedNull) > tolerance)
    error('cocoConclusionReport:SymmetricNullMismatch', ...
        ['The stored symmetric null is not the elementwise minimum of ', ...
         'the paired directional full-pipeline null maxima.']);
end
end

function score = validationScore(validation,label)
if ~isstruct(validation) || ~isfield(validation,'score') || ...
        ~isnumeric(validation.score) || ~isscalar(validation.score) || ...
        ~isreal(validation.score) || ~isfinite(validation.score)
    error('cocoConclusionReport:InvalidValidationScore', ...
        '%s validation score must be one finite real scalar.',label);
end
score = validation.score;
end

function assertIntervalSame(expected,stored,label)
tolerance = 256*eps(max([1,abs(expected),abs(stored)]));
if any(abs(expected-stored) > tolerance)
    error('cocoConclusionReport:MonteCarloIntervalMismatch', ...
        ['The stored %s null-exceedance interval does not match the ', ...
         'audited Monte Carlo counts.'],label);
end
end

function interval = reportWilsonInterval(k,n)
z = 1.95996398454005;
phat = k/n;
denominator = 1+z^2/n;
center = (phat+z^2/(2*n))/denominator;
halfWidth = z/denominator * ...
    sqrt(phat*(1-phat)/n+z^2/(4*n^2));
interval = [max(0,center-halfWidth),min(1,center+halfWidth)];
end

function x = scalarFiniteOrNaN(x)
if ~isnumeric(x) || ~isscalar(x) || ~isfinite(x)
    x = NaN;
end
end

function text = passFail(tf)
if tf
    text = 'PASS';
else
    text = 'FAIL';
end
end
