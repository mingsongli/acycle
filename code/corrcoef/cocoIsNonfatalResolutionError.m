function [tf,matchedIdentifier] = cocoIsNonfatalResolutionError(exception)
%COCOISNONFATALRESOLUTIONERROR Classify expected COCO geometry failures.
%
% [TF,ID] = COCOISNONFATALRESOLUTIONERROR(EXCEPTION) is used only at GUI
% and batch-orchestration boundaries.  The numerical engines deliberately
% retain their errors because no scientifically valid target/statistic can
% be returned for these configurations.  A caller may, however, warn,
% skip the unsupported method, and continue with later work without a
% blocking error dialog.

validateattributes(exception,{'MException'},{'scalar'},mfilename, ...
    'exception',1);

nonfatalIdentifiers = { ...
    'cvcoco:NoAllNineTrainingRate', ...
    'cvcoco:NoValidSedimentationRate', ...
    'ecocoCrossfitCore:NoTrainingRate', ...
    'ecocoCrossfitCore:NoValidationRate', ...
    'ecocoInterleavedCore:NoResolvableWindows', ...
    'corrcoefslices_rankNew:NoValidObservedStatistic'};

tf = false;
matchedIdentifier = '';
pending = {exception};
while ~isempty(pending)
    current = pending{1};
    pending(1) = [];
    if any(strcmp(current.identifier,nonfatalIdentifiers))
        tf = true;
        matchedIdentifier = current.identifier;
        return
    end
    if ~isempty(current.cause)
        pending = [pending,current.cause(:)']; %#ok<AGROW>
    end
end
end
