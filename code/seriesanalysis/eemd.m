function modes = eemd(y,goal,ens,nos)
%EEMD Compatibility wrapper for Acycle's reusable EEMD core.
%   MODES = EEMD(Y,GOAL,ENS,NOS) retains the historical row-oriented output
%   shape: GOAL IMF rows followed by one residual row. NOS is a multiple of
%   the input sample standard deviation. The calculation is deterministic
%   (seed 0), creates no waitbar, prints no progress, writes no files, and
%   does not change the caller's global random-number state.

narginchk(4,4);
if ~((isa(y,'double') || isa(y,'single')) && ~issparse(y) && ...
        isreal(y) && isvector(y))
    error('Acycle:EEMD:InvalidSignal', ...
        'Y must be a full, real SINGLE or DOUBLE vector.');
end
values = double(y(:));
coordinate = (0:numel(values)-1).';
options = struct( ...
    'method','eemd', ...
    'max_num_imf',goal, ...
    'ensemble_count',ens, ...
    'noise_amplitude',nos, ...
    'random_seed',0);
result = acycleEmpiricalModeDecomposition([coordinate,values],options);
modes = [result.imfs,result.residual].';
missingImfs = goal-size(result.imfs,2);
if missingImfs > 0
    modes = [modes(1:end-1,:); ...
        zeros(missingImfs,numel(values));modes(end,:)];
end
end
