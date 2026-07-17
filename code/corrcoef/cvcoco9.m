function result = cvcoco9(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCO9 Compatibility alias for method-B CVCOCO9B.
%
% Existing scripts that call CVCOCO9 retain the original four-group,
% leakage-corrected amplitude estimator. New comparisons should call
% CVCOCO9A or CVCOCO9B explicitly.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if (ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName))) && ...
            strcmpi(char(optionName),'TargetModel')
        error('cvcoco9:TargetModelFixed', ...
            ['cvcoco9 is a compatibility alias for cvcoco9B and fixes ', ...
             'TargetModel to ''four-group-coherent-nine''; omit this option.']);
    end
end

result = cvcoco9B(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:});
result.entryPoint = 'cvcoco9 compatibility alias for cvcoco9B';
result.canonicalEntryPoint = 'cvcoco9B';
result.compatibilityAlias = true;
end
