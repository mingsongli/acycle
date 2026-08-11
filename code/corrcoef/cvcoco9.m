function result = cvcoco9(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCO9 Internal compatibility alias for Blocked cvCOCO.
%
% Existing scripts that call this entry point retain the four-group,
% leakage-corrected amplitude estimator. New analyses should select
% Blocked cvCOCO through a supported Acycle interface.

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

result = cvcoco9B(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:});
result.entryPoint = 'Blocked cvCOCO';
result.canonicalEntryPoint = 'Blocked cvCOCO';
result.compatibilityAlias = true;
end
