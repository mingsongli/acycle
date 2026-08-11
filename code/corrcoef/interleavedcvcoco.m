function result = interleavedcvcoco(data,orbit9,pad,sr1,sr2,srstep, ...
        red,nsim,method,varargin)
%INTERLEAVEDCVCOCO Odd/even Interleaved cvCOCO.
%
% RESULT = INTERLEAVEDCVCOCO(DATA,ORBIT9,PAD,SR1,SR2,SRSTEP,RED,NSIM,
% METHOD) sorts and de-duplicates DATA, assigns its odd-index observations
% to the Odd fold and even-index observations to the Even fold, and linearly regularizes
% each fold independently. It uses the Interleaved cvCOCO
% target: four leakage-corrected group amplitudes expanded to a coherent
% nine-term target for reciprocal frozen-target validation.
%
% Each Monte Carlo realization is one stationary Gaussian AR(1) sequence
% on the complete cleaned raw observation order.  It is then split and
% interpolated exactly like the observed record, preserving null dependence
% between adjacent odd/even observations.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if ~(ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName)))
        continue
    end
    optionName = char(optionName);
    if strcmpi(optionName,'TargetModel')
        error('Acycle:InterleavedCVCOCO:TargetDesignFixed', ...
            ['Interleaved cvCOCO fixes its target design internally; ', ...
             'omit the TargetModel option.']);
    elseif strcmpi(optionName,'SplitMode')
        error('Acycle:InterleavedCVCOCO:SplitDesignFixed', ...
            ['Interleaved cvCOCO fixes its split design internally; ', ...
             'omit the SplitMode option.']);
    end
end

result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:},'TargetModel','four-group-coherent-nine', ...
    'SplitMode','interleaved');
result.name = 'Interleaved cvCOCO';
result.publicName = 'Interleaved cvCOCO';
result.abbreviation = 'Interleaved cvCOCO';
result.entryPoint = 'Interleaved cvCOCO';
result.canonicalEntryPoint = 'Interleaved cvCOCO';
result.compatibilityAlias = false;
result.targetLabel = ...
    'Leakage-aware four-group amplitudes in a coherent nine-term target';
result.validationLabel = [ ...
    'Odd/even reciprocal validation with four frozen group weights ', ...
    'expanded to nine coherent orbital terms'];
result.engine = ...
    'four-group-trained coherent nine-term interleaved held-out engine';
result.variant = 'Interleaved cvCOCO';
result.analysisRole = ...
    'Interleaved cvCOCO odd/even bidirectional held-out analysis';
if result.degradedMode
    result.analysisRole = [result.analysisRole, ...
        '; partial-orbit exploratory training, not complete all-nine ', ...
        'confirmation'];
end
end
