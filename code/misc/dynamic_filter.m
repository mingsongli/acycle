function [xdata_filtered,time,freqboundlow,freqboundhigh] = ...
        dynamic_filter(data,window,step,fmin,fmax,unit,norm,padding)
%DYNAMIC_FILTER Legacy interactive compatibility entry point.
%   This historical API still opens the spectrum/control-point GUI through
%   DYNAMIC_FILTER_LANG, but all filtering after point acquisition is now
%   delegated there to ACYCLEDYNAMICFILTER. Noninteractive callers should
%   call ACYCLEDYNAMICFILTER directly with explicit lower and upper
%   control-point matrices.
%
%   Original dynamic-filter workflow by Nicolas Thibault and Giovanni
%   Rizzi (2019); adapted for Acycle Frequency Stabilization by Mingsong Li
%   (June 2020).

narginchk(8,8);
[xdata_filtered,time,freqboundlow,freqboundhigh,cancelled] = ...
    dynamic_filter_lang(data,window,step,fmin,fmax,unit,norm,padding);
if cancelled
    error('Acycle:DynamicFilter:InteractiveSelectionCancelled', ...
        'Interactive dynamic-filter boundary selection was cancelled.');
end
end
