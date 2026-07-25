function groups = cocoOrbitGroups(orbitPeriods)
%COCOORBITGROUPS Identify the four physical groups in an ORBIT9 target.
%
% GROUPS = COCOORBITGROUPS(ORBITPERIODS) assigns the nine principal
% astronomical periods to long eccentricity (1 member), short
% eccentricity (4 members), obliquity (1 member), and precession
% (3 members).  The assignment uses descending period rank rather than
% fixed present-day period cutoffs.  This preserves the physical 1/4/1/3
% ORBIT9 identities when obliquity and precession shorten in deep time and
% is invariant to the input order.

validateattributes(orbitPeriods,{'numeric'}, ...
    {'vector','numel',9,'real','finite','positive'},mfilename, ...
    'orbitPeriods',1);

orbitPeriods = orbitPeriods(:);
if numel(unique(orbitPeriods)) ~= 9
    error('cocoOrbitGroups:DuplicateOrbitPeriods', ...
        'The nine ORBIT9 periods must be distinct.');
end

[~,descendingOrder] = sort(orbitPeriods,'descend');
index = zeros(9,1);
index(descendingOrder(1)) = 1;
index(descendingOrder(2:5)) = 2;
index(descendingOrder(6)) = 3;
index(descendingOrder(7:9)) = 4;

groups = struct();
groups.index = index;
groups.counts = [1;4;1;3];
groups.names = {'Long eccentricity';'Short eccentricity'; ...
    'Obliquity';'Precession'};
groups.rule = [ ...
    'descending ORBIT9 period rank: 1 / 2-5 / 6 / 7-9; ', ...
    'no fixed period thresholds'];
end
