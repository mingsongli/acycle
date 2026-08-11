function result = cvcoco9A(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCO9A Internal compatibility entry point for Blocked cvCOCO.
%
% This retained implementation reads the maximum data
% PSD within plus/minus one Rayleigh of each nominal orbital frequency and
% converts it to a sinusoid amplitude using a matching unit-sine spectral
% calibration. The nine relative amplitudes at the training optimum are
% frozen individually for held-out validation. The nine zero-phase terms
% are summed coherently before power is calculated. The same complete
% train/validate operation is repeated in every Monte Carlo realization.
% New analyses should select Blocked cvCOCO through a supported Acycle
% interface rather than calling this compatibility entry point directly.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if (ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName))) && ...
            strcmpi(char(optionName),'TargetModel')
        error('Acycle:BlockedCVCOCO:TargetDesignFixed', ...
            ['Blocked cvCOCO fixes this internal target design; ', ...
             'omit the TargetModel option.']);
    end
end

result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:},'TargetModel','rayleigh-peak-coherent-nine');
result.name = 'Blocked cvCOCO';
result.publicName = 'Blocked cvCOCO';
result.entryPoint = 'Blocked cvCOCO';
result.canonicalEntryPoint = 'Blocked cvCOCO';
result.compatibilityAlias = false;
result.targetLabel = ...
    'Per-orbit Rayleigh-peak amplitudes in a coherent nine-term target';
result.validationLabel = ...
    'Nine frozen relative orbital amplitudes in a coherent target';
result.engine = 'Rayleigh-peak-trained coherent nine-term held-out engine';
result.variant = 'Blocked cvCOCO';
result.analysisRole = ...
    ['Blocked cvCOCO internal target-design comparison; ', ...
     'not the published default target design'];
end
