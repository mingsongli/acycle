function report = cocoAdaptivePublicationReport(corrCI,corrH0,details)
%COCOADAPTIVEPUBLICATIONREPORT Audited publication summary for Adaptive COCO.
%
% REPORT = COCOADAPTIVEPUBLICATIONREPORT(CORRCI,CORRH0,DETAILS) extends
% COCOCONCLUSIONREPORT('adaptive',...) with a direct audit of the stored
% maximum-statistic null, its plus-one Monte Carlo p-value, and a Wilson
% interval for the underlying null exceedance probability.

if ~isstruct(details) || ~isscalar(details)
    error('cocoAdaptivePublicationReport:InvalidDetails', ...
        'DETAILS must be the scalar diagnostic structure returned by Adaptive COCO.');
end
required = {'nullMax','nsimValid','nsimRequested','nsimCompleted', ...
    'seed','rhoM','rhoMethod','maxFrequency','slices','pad','red', ...
    'method','targetMode','nullConditioning','targetConstruction', ...
    'bandAssignment'};
missing = required(~cellfun(@(name)isfield(details,name),required));
if ~isempty(missing)
    error('cocoAdaptivePublicationReport:MissingDetails', ...
        'Adaptive diagnostic field(s) missing: %s.',strjoin(missing,', '));
end

targetMode = lower(char(string(details.targetMode)));
if strcmp(targetMode,'adaptive9b')
    validateTargetAmplitudeMode(details,'four-group-area','Adaptive COCO9B');
elseif strcmp(targetMode,'adaptive9a')
    validateTargetAmplitudeMode(details,'adaptive','Adaptive COCO9A');
elseif strcmp(targetMode,'adaptive9') && ...
        isfield(details,'targetAmplitudeMode')
    % The former Adaptive COCO9 token is a compatibility alias for A.
    validateTargetAmplitudeMode(details,'adaptive','Adaptive COCO9A');
end

report = cocoConclusionReport('adaptive',corrCI,corrH0,details);

nullMax = details.nullMax(:);
nValid = details.nsimValid;
if ~isnumeric(nValid) || ~isscalar(nValid) || ~isfinite(nValid) || ...
        nValid < 1 || nValid ~= fix(nValid) || numel(nullMax) ~= nValid || ...
        any(~isfinite(nullMax))
    error('cocoAdaptivePublicationReport:InvalidNullMaximum', ...
        'DETAILS.nullMax must contain exactly nsimValid finite maxima.');
end
observed = report.bestCorrelation;
nExceed = sum(nullMax >= observed);
auditedP = (nExceed+1)/(nValid+1);
tolerance = max(256*eps(max(1,max(abs([auditedP,report.minimumGlobalP])))),1e-12);
if abs(auditedP-report.minimumGlobalP) > tolerance
    error('cocoAdaptivePublicationReport:GlobalPInvariant', ...
        ['The stored Adaptive global p-value does not equal the plus-one ', ...
         'exceedance probability from DETAILS.nullMax.']);
end
ci = wilsonInterval(nExceed,nValid);
alpha = report.alphaGlobal;
thresholdResolved = (report.globalPass && ci(2) < alpha) || ...
    (~report.globalPass && ci(1) >= alpha);
pFloor = 1/(nValid+1);
if isfield(details,'pFloor') && isfinite(details.pFloor) && ...
        abs(details.pFloor-pFloor) > max(256*eps(max(1,pFloor)),1e-12)
    error('cocoAdaptivePublicationReport:PResolutionInvariant', ...
        'DETAILS.pFloor is inconsistent with nsimValid.');
end

if thresholdResolved
    precisionQualification = sprintf([ ...
        'The 95%% Wilson interval [%.4g, %.4g] lies entirely on the ', ...
        'same side of the %.3g global threshold as the point decision.'], ...
        ci(1),ci(2),alpha);
else
    precisionQualification = sprintf([ ...
        'MONTE CARLO PRECISION QUALIFICATION: the 95%% Wilson interval ', ...
        '[%.4g, %.4g] crosses the %.3g global threshold; increase NSIM ', ...
        'before treating the threshold classification as stable.'], ...
        ci(1),ci(2),alpha);
    report.classification = [report.classification, ...
        '; Monte Carlo threshold uncertain'];
    report.conclusion = [report.conclusion,' ',precisionQualification];
end

report.globalPConfidenceInterval = ci;
report.globalPExceedanceCount = nExceed;
report.monteCarloResolution = pFloor;
report.monteCarloThresholdResolved = thresholdResolved;
report.monteCarloPrecisionQualification = precisionQualification;
report.rho = details.rhoM;
report.rhoEstimator = details.rhoMethod;
report.seed = details.seed;
report.nsimRequested = details.nsimRequested;
report.nsimCompleted = details.nsimCompleted;
report.nsimValid = nValid;
report.maximumFrequency = details.maxFrequency;
report.slices = details.slices;
report.pad = details.pad;
report.red = details.red;
report.correlationMethod = details.method;
report.targetAmplitudeMode = optionalDetail( ...
    details,'targetAmplitudeMode',report.targetAmplitudeMode);
report.summaryRows = [report.summaryRows; {
    'Adaptive AR(1) rho used in the null',details.rhoM;
    'Adaptive AR(1) rho estimator',details.rhoMethod;
    'Adaptive Monte Carlo random seed',details.seed;
    'Adaptive Monte Carlo simulations requested',details.nsimRequested;
    'Adaptive Monte Carlo simulations completed',details.nsimCompleted;
    'Finite null maxima used',nValid;
    'Observed maximum correlation',observed;
    'Null maxima equal to or above observation',nExceed;
    'Minimum resolvable plus-one p',pFloor;
    'Global null-exceedance 95% Wilson interval',mat2str(ci);
    'Monte Carlo threshold classification stable at 0.05', ...
        passFailText(thresholdResolved);
    'Monte Carlo precision qualification',precisionQualification;
    'Maximum temporal frequency used (cycle/kyr)',details.maxFrequency;
    'Adaptive spectrum slices',details.slices;
    'Periodogram NFFT',details.pad;
    'Red-noise option',details.red;
    'Correlation method',details.method;
    'Adaptive target amplitude mode', ...
        optionalDetail(details,'targetAmplitudeMode','adaptive');
    'Adaptive null conditioning',details.nullConditioning;
    'Adaptive target construction',details.targetConstruction;
    'Adaptive overlapping-band rule',details.bandAssignment}];
report.message = sprintf([ ...
    '%s\n\nMonte Carlo audit: N=%d, exceedances=%d, seed=%g, ', ...
    'rho=%.4g, p resolution=%.4g, global null-exceedance ', ...
    '95%% Wilson interval=[%.4g, %.4g].\n%s'], ...
    report.message,nValid,nExceed,details.seed,details.rhoM,pFloor, ...
    ci(1),ci(2),precisionQualification);
end

function validateTargetAmplitudeMode(details,expected,methodName)
if ~isfield(details,'targetAmplitudeMode') || ...
        ~((ischar(details.targetAmplitudeMode) && ...
        isrow(details.targetAmplitudeMode)) || ...
        (isstring(details.targetAmplitudeMode) && ...
        isscalar(details.targetAmplitudeMode))) || ...
        ~strcmpi(char(details.targetAmplitudeMode),expected)
    error('cocoAdaptivePublicationReport:TargetAmplitudeModeMismatch', ...
        '%s requires DETAILS.targetAmplitudeMode=''%s''.', ...
        methodName,expected);
end
end

function value = optionalDetail(details,name,defaultValue)
if isfield(details,name)
    value = details.(name);
else
    value = defaultValue;
end
end

function interval = wilsonInterval(k,n)
% Two-sided 95% Wilson score interval without a Statistics Toolbox dependency.
z = 1.959963984540054;
phat = k/n;
denominator = 1+z^2/n;
center = (phat+z^2/(2*n))/denominator;
halfWidth = z/denominator*sqrt(phat*(1-phat)/n+z^2/(4*n^2));
interval = [max(0,center-halfWidth),min(1,center+halfWidth)];
end

function value = passFailText(tf)
if tf
    value = 'YES';
else
    value = 'NO';
end
end
