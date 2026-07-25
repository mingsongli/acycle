function [f, pMC] = redNoisePeriodogramMC( ...
    data, rhoM, mcn, red, pad, varargin)
%REDNOISEPERIODOGRAMMC Generate processed spectra from stationary AR(1) nulls.
%
%   [F,PMC] = REDNOISEPERIODOGRAMMC(DATA,RHOM,MCN,RED,PAD) generates MCN
%   stationary AR(1) realizations on DATA(:,1), applies the same linear
%   detrending used by Adaptive COCO, and returns one processed periodogram
%   per realization.
%
%   [...] = REDNOISEPERIODOGRAMMC(...,'Slices',N) divides every full null
%   realization into the same equal-duration slices as the observed record.
%   Each slice is standardized and linearly detrended, its periodogram is
%   processed independently, and the N processed periodograms are averaged.
%   This reproduces the observed sliced-spectrum statistic.
%
% RED selects the background treatment:
%   0 - no background removal
%   1 - subtract the classical AR(1) background (theoredar1ML)
%   2 - subtract the robust AR(1) background (redconf_any)
%   3 - subtract the smoothed-window-average background (specswa)
%
% Name-value inputs:
%   BatchSize   positive integer; default min(1000,MCN)
%   UseParallel logical scalar; default false
%   Slices      positive integer; default 1
%
% F is in cycles per DATA time unit. PMC has size floor(PAD/2)+1 by MCN.

validateattributes(data,{'numeric'}, ...
    {'2d','ncols',2,'nonempty','real','finite'},mfilename,'data',1);
validateattributes(rhoM,{'numeric'}, ...
    {'scalar','real','finite','>',-1,'<',1},mfilename,'rhoM',2);
validateattributes(mcn,{'numeric'}, ...
    {'scalar','integer','positive','finite'},mfilename,'mcn',3);
validateattributes(red,{'numeric'}, ...
    {'scalar','integer','finite'},mfilename,'red',4);
validateattributes(pad,{'numeric'}, ...
    {'scalar','integer','positive','finite'},mfilename,'pad',5);
if ~ismember(red,0:3)
    error('redNoisePeriodogramMC:InvalidRedOption', ...
        'RED must be 0, 1, 2, or 3.');
end
if red == 3 && floor(pad/2)+1 < 33
    error('redNoisePeriodogramMC:InsufficientSwaResolution', ...
        'RED=3 requires PAD >= 64 so the SWA fit has at least three windows.');
end
if (floor(pad/2)+1)*mcn > 5e7
    error('redNoisePeriodogramMC:OutputTooLarge', ...
        ['The requested output would exceed 50 million spectral ', ...
         'ordinates. Reduce MCN or PAD, or stream smaller batches.']);
end

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'BatchSize',min(1000,mcn), ...
    @(x) isnumeric(x) && isscalar(x) && isfinite(x) && ...
    x >= 1 && x == fix(x));
addParameter(parser,'UseParallel',false, ...
    @(x) islogical(x) && isscalar(x));
addParameter(parser,'Slices',1, ...
    @(x) isnumeric(x) && isscalar(x) && isfinite(x) && ...
    x >= 1 && x == fix(x));
parse(parser,varargin{:});

batchSize = min(parser.Results.BatchSize,mcn);
useParallel = parser.Results.UseParallel;
slices = parser.Results.Slices;

data = sortrows(data,1);
time = data(:,1);
values = data(:,2);
n = numel(time);
if n < 4
    error('redNoisePeriodogramMC:InsufficientData', ...
        'The input time series must contain at least four points.');
end
nFrequency = floor(pad/2)+1;
temporaryMemoryBudget = 128*1024^2;
bytesPerSimulation = 16*n+32*nFrequency;
memoryLimitedBatchSize = max(1,floor( ...
    temporaryMemoryBudget/max(1,bytesPerSimulation)));
batchSize = min(batchSize,memoryLimitedBatchSize);
timeDifference = diff(time);
if any(timeDifference <= 0)
    error('redNoisePeriodogramMC:InvalidTime', ...
        'DATA(:,1) must be strictly increasing.');
end
dt = median(timeDifference);
spacingTolerance = cocoSamplingTolerance(time,dt);
if any(abs(timeDifference-dt) > spacingTolerance)
    error('redNoisePeriodogramMC:UnevenSampling', ...
        ['DATA(:,1) must be evenly spaced. Sort, de-duplicate, and ', ...
         'interpolate the data before Monte Carlo simulation.']);
end

sliceIndex = equalDurationSliceIndex(time,slices);
sliceLength = cellfun(@numel,sliceIndex);
if any(sliceLength < 4)
    error('redNoisePeriodogramMC:SliceTooShort', ...
        'Every slice must contain at least four observations.');
end
if pad < max(sliceLength)
    error('redNoisePeriodogramMC:PadTooShort', ...
        'PAD must be at least the number of observations in the longest slice.');
end

observedDetrended = detrend(values,1);
[resolvedVariance,dataStd] = cocoResolvedDetrendedVariance( ...
    values,observedDetrended);
if ~resolvedVariance
    error('redNoisePeriodogramMC:InvalidVariance', ...
        ['The observed values must retain numerically resolved variance ', ...
         'after linear detrending.']);
end

samplingFrequency = 1/dt;
innovationStd = sqrt(1-rhoM^2);
f = [];
pMC = [];

for firstSimulation = 1:batchSize:mcn
    lastSimulation = min(firstSimulation+batchSize-1,mcn);
    numberInBatch = lastSimulation-firstSimulation+1;

    innovations = randn(n,numberInBatch);
    innovations(2:end,:) = innovationStd.*innovations(2:end,:);
    redSeries = filter(1,[1,-rhoM],innovations,[],1);
    redSeries = dataStd.*redSeries;

    [pProcessed,fBatch] = processedSliceAverage( ...
        redSeries,sliceIndex,pad,samplingFrequency,dt,red,useParallel);
    if isempty(f)
        f = fBatch;
        pMC = zeros(numel(f),mcn,'like',pProcessed);
    elseif ~isequal(f,fBatch)
        error('redNoisePeriodogramMC:FrequencyGridChanged', ...
            'Monte Carlo frequency grids changed between batches.');
    end
    pMC(:,firstSimulation:lastSimulation) = pProcessed;
end
end

function sliceIndex = equalDurationSliceIndex(time,slices)
boundaries = linspace(time(1),time(end),slices+1);
sliceIndex = cell(slices,1);
for j = 1:slices
    if j < slices
        sliceIndex{j} = find(time >= boundaries(j) & ...
            time < boundaries(j+1));
    else
        sliceIndex{j} = find(time >= boundaries(j) & ...
            time <= boundaries(j+1));
    end
end
end

function [pAverage,f] = processedSliceAverage( ...
        series,sliceIndex,pad,fs,dt,red,useParallel)
nSimulation = size(series,2);
nFrequency = floor(pad/2)+1;
pSum = zeros(nFrequency,nSimulation,'like',series);
f = [];

for s = 1:numel(sliceIndex)
    x = series(sliceIndex{s},:);
    if numel(sliceIndex) > 1
        sigma = std(x,0,1);
        if any(~isfinite(sigma) | sigma <= 0)
            error('redNoisePeriodogramMC:DegenerateNullSlice', ...
                'A Monte Carlo slice has zero or nonfinite variance.');
        end
        x = (x-mean(x,1))./sigma;
    end
    x = detrend(x,1);
    [pRaw,fSlice] = periodogram(x,[],pad,fs);
    if any(~isfinite(pRaw),'all')
        error('redNoisePeriodogramMC:NonfinitePeriodogram', ...
            'A null periodogram overflowed or returned nonfinite power.');
    end
    if isempty(f)
        f = fSlice;
    elseif ~isequal(f,fSlice)
        error('redNoisePeriodogramMC:SliceFrequencyGridChanged', ...
            'Slice periodograms do not share an identical frequency grid.');
    end

    if red == 0
        pProcessed = pRaw;
    else
        pProcessed = zeros(size(pRaw),'like',pRaw);
        if useParallel
            parfor j = 1:nSimulation
                pProcessed(:,j) = processOneSpectrum( ...
                    x(:,j),pRaw(:,j),fSlice,dt,red);
            end
        else
            for j = 1:nSimulation
                pProcessed(:,j) = processOneSpectrum( ...
                    x(:,j),pRaw(:,j),fSlice,dt,red);
            end
        end
    end
    pSum = pSum+pProcessed;
end
pAverage = pSum./numel(sliceIndex);
end

function p = processOneSpectrum(series,p,f,dt,red)
switch red
    case 0
        return
    case 1
        background = theoredar1ML(series,f,mean(p),dt);
    case 2
        % REDCONF_ANY historically accepts normalized angular frequency,
        % not cycles per time unit. Convert so its internal FT is physical.
        angularFrequency = 2*pi*f*dt;
        background = redconf_any(angularFrequency,p,dt,0.25,2);
    case 3
        % Use a spectrum-scale floor. An exact detrended DC zero must not
        % become an artificial log10(realmin) ~= -308 SWA outlier.
        xlogp = log10(max(p,adaptivePositivePowerFloor(p)));
        [background,~] = specswa(f,xlogp,numel(series),false);
end
background = background(:);
if numel(background) ~= numel(p) || ...
        any(~isfinite(background) | background <= 0)
    error('redNoisePeriodogramMC:InvalidRedNoiseBackground', ...
        ['The selected red-noise method returned a nonpositive, ', ...
         'nonfinite, or size-mismatched spectral background.']);
end
p = p-background;
p(~isfinite(p) | p < 0) = 0;
end

function floorValue = adaptivePositivePowerFloor(p)
positivePower = p(isfinite(p) & p > 0);
if isempty(positivePower)
    scale = 1;
else
    scale = max(positivePower);
end
floorValue = max(realmin(class(p)),scale*eps(class(p)));
end
