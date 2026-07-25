function result = cvcoco9A(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCO9A cvCOCO9 with method-A per-orbit peak amplitudes.
%
% For every candidate sedimentation rate, CVCOCO9A reads the maximum data
% PSD within plus/minus one Rayleigh of each nominal orbital frequency and
% converts it to a sinusoid amplitude using a matching unit-sine spectral
% calibration. The nine relative amplitudes at the training optimum are
% frozen individually for held-out validation. The nine zero-phase terms
% are summed coherently before power is calculated. The same complete
% train/validate operation is repeated in every Monte Carlo realization.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if (ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName))) && ...
            strcmpi(char(optionName),'TargetModel')
        error('cvcoco9A:TargetModelFixed', ...
            ['cvcoco9A fixes TargetModel to ', ...
             '''rayleigh-peak-coherent-nine''; omit this option.']);
    end
end

result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:},'TargetModel','rayleigh-peak-coherent-nine');
result.name = 'cvCOCO9A';
result.entryPoint = 'cvcoco9A method-A wrapper';
result.canonicalEntryPoint = 'cvcoco9A';
result.compatibilityAlias = false;
result.targetLabel = ...
    'Per-orbit Rayleigh-peak amplitudes in a coherent nine-term target';
result.validationLabel = ...
    'Nine frozen relative orbital amplitudes in a coherent target';
result.engine = 'Rayleigh-peak-trained coherent nine-term held-out engine';
result.variant = 'A';
result.analysisRole = ...
    'Method-A held-out development analysis; not confirmatory Blocked cvCOCO';
end
