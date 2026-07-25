function result = cvcocoLegacy(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCOLEGACY Explicit compatibility entry point for the former cvCOCO.
%
% This wrapper preserves the old coherent nine-term target engine after
% the public CVCOCO name was assigned to the four-group confirmatory
% method. Legacy results are intentionally rejected by
% COCOCONCLUSIONREPORT('confirmatory',...). New analyses should use
% CVCOCO without this wrapper.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if (ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName))) && ...
            strcmpi(char(optionName),'TargetModel')
        error('cvcocoLegacy:TargetModelFixed', ...
            'cvcocoLegacy fixes TargetModel to ''legacy''; omit this option.');
    end
end

result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:},'TargetModel','legacy');
result.name = 'legacy cvCOCO';
result.entryPoint = 'cvcocoLegacy compatibility wrapper';
result.targetLabel = 'Legacy coherent adaptive nine-term target';
result.validationLabel = 'Frozen legacy four-group weights';
end
