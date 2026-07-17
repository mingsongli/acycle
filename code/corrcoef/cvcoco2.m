function result = cvcoco2(data,orbit9,pad,sr1,sr2,srstep,red,nsim, ...
        method,varargin)
%CVCOCO2 Compatibility wrapper for the four-group cvCOCO method.
%
% RESULT = CVCOCO2(DATA,ORBIT9,PAD,SR1,SR2,SRSTEP,RED,NSIM,METHOD)
% uses the same symmetric two-fold held-out and full-pipeline stationary
% AR(1) Monte Carlo design as CVCOCO. Segment A and Segment B may select
% different sedimentation rates, while each segment is modeled with one
% constant rate.
%
% At each tested mean sedimentation rate, each orbital component is
% represented by the uniform-phase average of its finite-record unit-sine
% and unit-cosine periodograms. Training
% power is integrated once over the union of one-Rayleigh member bands in
% each of four groups: long eccentricity, short eccentricity, obliquity,
% and precession. Group target periodograms add member powers
% noncoherently, and the four trained amplitudes are frozen during
% reciprocal validation.
%
% Additional name-value options are the same as CVCOCO: BatchSize, Seed,
% ProgressFcn, MaxFrequency, and AnalysisName. TargetModel is fixed to
% 'four-group'. New code should call CVCOCO directly; this entry point is
% retained for compatibility with saved scripts.

for optionIndex = 1:2:numel(varargin)
    optionName = varargin{optionIndex};
    if (ischar(optionName) || ...
            (isstring(optionName) && isscalar(optionName))) && ...
            strcmpi(char(optionName),'TargetModel')
        error('cvcoco2:TargetModelFixed', ...
            'cvcoco2 fixes TargetModel to ''four-group''; omit this option.');
    end
end

result = cvcoco(data,orbit9,pad,sr1,sr2,srstep,red,nsim,method, ...
    varargin{:},'TargetModel','four-group');
result.name = 'cvCOCO';
result.entryPoint = 'cvcoco2 compatibility wrapper';
result.targetLabel = 'Phase-averaged four-group piecewise-constant target';
result.validationLabel = 'Frozen phase-averaged noncoherent four-group target';
end
