function audit = validateCocoPublicationValidation(outputRoot)
%VALIDATECOCOPUBLICATIONVALIDATION Re-audit saved formal COCO statistics.
%
% This function is read-only. It reloads every saved result, rebuilds the
% strict conclusion report from the stored null statistics, and verifies the
% formal simulation count, seed, method role, and manifest status.

validateattributes(outputRoot,{'char','string'}, ...
    {'scalartext','nonempty'},mfilename,'outputRoot',1);
outputRoot = char(string(outputRoot));
manifestPath = fullfile(outputRoot,'manifest.json');
if ~isfile(manifestPath)
    error('validateCocoPublicationValidation:MissingManifest', ...
        'Missing suite manifest: %s',manifestPath);
end
manifest = jsondecode(fileread(manifestPath));
if ~strcmp(manifest.status,'complete') || numel(manifest.cases) ~= 6
    error('validateCocoPublicationValidation:IncompleteSuite', ...
        'The formal manifest must contain six complete cases.');
end

nMethod = 0;
for caseIndex = 1:numel(manifest.cases)
    caseItem = manifest.cases(caseIndex);
    if ~strcmp(caseItem.status,'complete') || numel(caseItem.methods) ~= 4
        error('validateCocoPublicationValidation:IncompleteCase', ...
            'Case %s is incomplete.',caseItem.id);
    end
    for methodIndex = 1:numel(caseItem.methods)
        item = caseItem.methods(methodIndex);
        if ~strcmp(item.status,'complete') || item.nsim ~= 9999
            error('validateCocoPublicationValidation:IncompleteMethod', ...
                'A method in case %s is incomplete or has the wrong NSIM.', ...
                caseItem.id);
        end
        resultPath = fullfile(outputRoot,item.result_file);
        saved = load(resultPath);
        if strcmp(item.method,'Blocked cvCOCO')
            report = cocoConclusionReport('confirmatory',saved.cv);
            assertSame(report.pA,saved.report.pA,'p_A',caseItem.id);
            assertSame(report.pB,saved.report.pB,'p_B',caseItem.id);
            assertSame(report.pRobust,saved.report.pRobust, ...
                'p_robust',caseItem.id);
            assertSame(report.pSym,saved.report.pSym,'p_sym',caseItem.id);
            if saved.cv.nsimCompleted ~= 9999 || saved.cv.nsimValid ~= 9999 || ...
                    saved.cv.seed ~= 20260713
                error('validateCocoPublicationValidation:CVProvenance', ...
                    'Blocked cvCOCO provenance failed for case %s.', ...
                    caseItem.id);
            end
        elseif strcmp(item.method,'Adaptive COCO')
            adaptive = saved.adaptive;
            report = cocoAdaptivePublicationReport( ...
                adaptive.corrCI,adaptive.corrH0,adaptive.details);
            assertSame(report.minimumGlobalP,saved.report.minimumGlobalP, ...
                'Adaptive global p',caseItem.id);
            if adaptive.details.nsimCompleted ~= 9999 || ...
                    adaptive.details.nsimValid ~= 9999 || ...
                    adaptive.details.seed ~= 20260713
                error('validateCocoPublicationValidation:AdaptiveProvenance', ...
                    'Adaptive COCO provenance failed for case %s.',caseItem.id);
            end
        else
            error('validateCocoPublicationValidation:UnknownMethod', ...
                'Unknown method %s.',item.method);
        end
        nMethod = nMethod+1;
    end
end

audit = struct('status','PASS','caseCount',numel(manifest.cases), ...
    'methodCount',nMethod,'nsimPerMethod',9999,'seed',20260713, ...
    'validatedAt',char(datetime('now','TimeZone','local', ...
    'Format','yyyy-MM-dd''T''HH:mm:ssXXX')));
fprintf('STATISTICAL_AUDIT_PASS cases=%d methods=%d NSIM=%d seed=%d\n', ...
    audit.caseCount,audit.methodCount,audit.nsimPerMethod,audit.seed);
end

function assertSame(actual,expected,label,caseID)
tolerance = max(1e-12,256*eps(max(1,max(abs([actual,expected])))));
if ~isscalar(actual) || ~isscalar(expected) || ...
        ~isfinite(actual) || ~isfinite(expected) || ...
        abs(actual-expected) > tolerance
    error('validateCocoPublicationValidation:ReportMismatch', ...
        '%s does not reproduce for case %s.',label,caseID);
end
end
