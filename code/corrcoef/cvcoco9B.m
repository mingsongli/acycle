function result = cvcoco9B(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCO9B Internal implementation entry point for Blocked cvCOCO.
%
% Blocked cvCOCO uses leakage-aware four-group union-band energy training,
% bidirectional held-out validation, and complete-pipeline AR(1) Monte
% Carlo. The four fitted amplitudes are expanded to nine orbital terms,
% which are summed coherently before power is calculated.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if (ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName))) && ...
            strcmpi(char(optionName),'TargetModel')
        error('Acycle:BlockedCVCOCO:TargetDesignFixed', ...
            ['Blocked cvCOCO fixes its target design internally; ', ...
             'omit the TargetModel option.']);
    end
end

result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:},'TargetModel','four-group-coherent-nine');
result.name = 'Blocked cvCOCO';
result.publicName = 'Blocked cvCOCO';
result.entryPoint = 'Blocked cvCOCO';
result.canonicalEntryPoint = 'Blocked cvCOCO';
result.compatibilityAlias = false;
result.targetLabel = ...
    'Leakage-aware four-group amplitudes in a coherent nine-term target';
result.validationLabel = ...
    'Four frozen group weights expanded to nine coherent orbital terms';
result.engine = 'four-group-trained coherent nine-term held-out engine';
result.variant = 'Blocked cvCOCO';
result.analysisRole = ...
    'Blocked cvCOCO held-out development analysis; non-confirmatory';
if result.degradedMode
    result.analysisRole = [result.analysisRole, ...
        '; partial-orbit exploratory training'];
end
end
