function result = cvcoco9B(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCO9B cvCOCO9 with method-B four-group band-energy amplitudes.
%
% CVCOCO9B is the explicitly named form of the original CVCOCO9 method.
% It retains leakage-aware four-group union-band energy training,
% bidirectional held-out validation, and complete-pipeline AR(1) Monte
% Carlo. The four fitted amplitudes are expanded to nine orbital terms,
% which are summed coherently before power is calculated.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if (ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName))) && ...
            strcmpi(char(optionName),'TargetModel')
        error('cvcoco9B:TargetModelFixed', ...
            ['cvcoco9B fixes TargetModel to ', ...
             '''four-group-coherent-nine''; omit this option.']);
    end
end

result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:},'TargetModel','four-group-coherent-nine');
result.name = 'cvCOCO9B';
result.entryPoint = 'cvcoco9B method-B wrapper';
result.canonicalEntryPoint = 'cvcoco9B';
result.compatibilityAlias = false;
result.targetLabel = ...
    'Leakage-aware four-group amplitudes in a coherent nine-term target';
result.validationLabel = ...
    'Four frozen group weights expanded to nine coherent orbital terms';
result.engine = 'four-group-trained coherent nine-term held-out engine';
result.variant = 'B';
result.analysisRole = ...
    'Method-B held-out development analysis; not confirmatory cvCOCO';
end
