function [P,R,t0] = circularspec(data,p1,p2,pn,linlog,plotn)
%CIRCULARSPEC Compatibility wrapper for the reviewed circular spectrum.
%   [P,R,T0] = CIRCULARSPEC(DATA,P1,P2,PN,LINLOG,PLOTN) preserves the
%   historical row-vector outputs and optional plot while delegating all
%   numerical work to ACYCLECIRCULARSPECTRUM. LINLOG is 1 for logarithmic
%   and 2 for linear periods. DATA is sorted for compatibility, but
%   duplicate and nonfinite event coordinates are rejected by the strict
%   core. R is mean resultant vector length, not Fourier power.
%
%   Original Acycle implementation: Mingsong Li (Penn State), Oct. 17,
%   2020; updated by Mingsong Li (Peking University), May 29, 2021.

narginchk(1,6);
if ~isvector(data)
    error('Acycle:CircularSpectrum:InvalidEvents', ...
        'DATA must be one event-coordinate vector.');
end
events = sort(data(:));
if numel(events) < 2
    error('Acycle:CircularSpectrum:TooFewEvents', ...
        'DATA must contain at least two event coordinates.');
end
spacing = diff(events);
span = events(end)-events(1);
if nargin < 2 || isempty(p1)
    p1 = min(spacing)/2;
end
if nargin < 3 || isempty(p2)
    p2 = span/2;
end
if nargin < 4 || isempty(pn)
    pn = 100;
end
if nargin < 5 || isempty(linlog)
    linlog = 2;
end
if nargin < 6 || isempty(plotn)
    plotn = 1;
end
if ~(isnumeric(linlog) && ~islogical(linlog) && isreal(linlog) && ...
        isscalar(linlog) && any(linlog == [1,2]))
    error('Acycle:CircularSpectrum:InvalidLegacyGridMode', ...
        'LINLOG must be 1 for log or 2 for linear periods.');
end
if ~(isnumeric(plotn) || islogical(plotn)) || ~isreal(plotn) || ...
        ~isscalar(plotn) || ~isfinite(plotn) || ...
        ~any(double(plotn) == [0,1])
    error('Acycle:CircularSpectrum:InvalidPlotFlag', ...
        'PLOTN must be logical false/true or numeric 0/1.');
end
if linlog == 1
    gridMode = 'log';
else
    gridMode = 'linear';
end

result = acycleCircularSpectrum(events,p1,p2,pn,gridMode);
P = result(:,1).';
R = result(:,2).';
t0 = result(:,3).';

if logical(plotn)
    figure;
    plot(P,R,'k-','LineWidth',2)
    xlabel('Period')
    ylabel('Mean resultant vector length')
end
end
