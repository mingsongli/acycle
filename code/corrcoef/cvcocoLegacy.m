function result = cvcocoLegacy(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCOLEGACY Internal compatibility entry point for Blocked cvCOCO.
%
% This wrapper preserves the old coherent nine-term target engine after
% Blocked cvCOCO adopted its four-group confirmatory target design.
% Compatibility-target results are intentionally rejected by
% COCOCONCLUSIONREPORT('confirmatory',...). New analyses should use
% Blocked cvCOCO through a supported Acycle interface.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if (ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName))) && ...
            strcmpi(char(optionName),'TargetModel')
        error('Acycle:BlockedCVCOCO:TargetDesignFixed', ...
            ['Blocked cvCOCO fixes this compatibility target design; ', ...
             'omit the TargetModel option.']);
    end
end

result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:},'TargetModel','legacy');
result.name = 'Blocked cvCOCO';
result.publicName = 'Blocked cvCOCO';
result.entryPoint = 'Blocked cvCOCO';
result.targetLabel = 'Compatibility coherent adaptive nine-term target';
result.validationLabel = 'Frozen compatibility four-group weights';
end
