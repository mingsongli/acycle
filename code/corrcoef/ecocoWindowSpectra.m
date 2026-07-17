function [power,frequency] = ecocoWindowSpectra(values,dt,pad,red)
%ECOCOWINDOWSPECTRA Batched eCOCO periodograms with COCO preprocessing.
%
% VALUES is samples-by-series.  Every column is linearly detrended and
% evaluated on the same PAD-point one-sided periodogram grid.  RED follows
% the public COCO convention: 0 none, 1 classical AR(1), 2 robust AR(1),
% and 3 smoothed-window background removal.

validateattributes(values,{'numeric'},{'2d','real','nonempty'}, ...
    mfilename,'values',1);
validateattributes(dt,{'numeric'},{'scalar','real','finite','positive'}, ...
    mfilename,'dt',2);
validateattributes(pad,{'numeric'},{'scalar','integer','finite','positive'}, ...
    mfilename,'pad',3);
validateattributes(red,{'numeric'},{'scalar','integer','finite','>=',0,'<=',3}, ...
    mfilename,'red',4);
if any(~isfinite(values),'all')
    error('ecocoWindowSpectra:NonfiniteInput', ...
        'Every window value must be finite before spectral analysis.');
end
if pad < size(values,1)
    error('ecocoWindowSpectra:PadTooShort', ...
        'PAD must be at least the number of samples in a window.');
end

values = detrend(values,1);
if any(~isfinite(values),'all')
    error('ecocoWindowSpectra:NonfiniteDetrendedData', ...
        'Linear detrending produced nonfinite values.');
end
[power,frequency] = periodogram(values,[],pad,1/dt);
if isvector(power)
    power = power(:);
end
if any(~isfinite(power),'all')
    error('ecocoWindowSpectra:NonfinitePeriodogram', ...
        'The periodogram produced nonfinite power. Rescale the proxy data.');
end
negativeTolerance = 64*eps(max(1,max(abs(power),[],'all')));
if any(power < -negativeTolerance,'all')
    error('ecocoWindowSpectra:NegativePeriodogram', ...
        'The periodogram produced materially negative power.');
end
power(power < 0) = 0;
if red == 0
    return
end
if red == 3 && size(power,1) < 33
    error('ecocoWindowSpectra:SwaSpectrumTooShort', ...
        'Smoothed-window removal requires at least 33 one-sided bins.');
end

for column = 1:size(power,2)
    p = power(:,column);
    x = values(:,column);
    switch red
        case 1
            background = theoredar1ML(x,frequency,mean(p),dt);
        case 2
            background = redconf_any( ...
                2*pi*frequency*dt,p,dt,0.25,2);
        case 3
            positive = p(isfinite(p) & p > 0);
            if isempty(positive)
                error('ecocoWindowSpectra:SwaNonpositiveSpectrum', ...
                    'SWA removal requires positive spectral power.');
            end
            floorValue = max(realmin(class(p)),max(positive)*eps(class(p)));
            [background,~] = specswa( ...
                frequency,log10(max(p,floorValue)),numel(x),false);
    end
    background = background(:);
    if numel(background) ~= numel(p) || ...
            any(~isfinite(background) | background <= 0)
        error('ecocoWindowSpectra:InvalidBackground', ...
            'The selected background model returned invalid values.');
    end
    p = p-background;
    if any(~isfinite(p))
        error('ecocoWindowSpectra:NonfiniteAdjustedSpectrum', ...
            'Background subtraction produced nonfinite power.');
    end
    p(p < 0) = 0;
    power(:,column) = p;
end
end
