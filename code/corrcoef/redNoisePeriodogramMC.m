function [f, pMC] = redNoisePeriodogramMC( ...
    data, rhoM, mcn, red, pad, varargin)
% redNoisePeriodogramMC
% Generate Monte Carlo AR(1) red-noise series, calculate their
% periodograms, and remove the corresponding red-noise background.
%
% SYNTAX:
%   [f, pMC] = redNoisePeriodogramMC(data, rhoM, mcn, red, pad)
%
%   [f, pMC] = redNoisePeriodogramMC(data, rhoM, mcn, red, pad, ...
%       'BatchSize', 1000, 'UseParallel', true)
%
% INPUT:
%   data        - Two-column time series:
%                 data(:,1): time
%                 data(:,2): observed values
%
%   rhoM        - Lag-1 autocorrelation coefficient used to generate
%                 stationary AR(1) red noise. abs(rhoM) must be < 1.
%
%   mcn         - Number of Monte Carlo simulations.
%
%   red         - Red-noise treatment:
%                   0       : no red-noise removal
%                   1       : p = p - theoretical red-noise spectrum
%                   2       : p = p/theoretical red-noise spectrum - 1
%                   3       : robust red-noise removal using redconf_any
%                   50-<100 : confidence-level normalization
%
%   pad         - FFT length used by periodogram.
%
% OPTIONAL NAME-VALUE INPUTS:
%   'BatchSize'   - Number of simulations processed in each batch.
%                   Default: min(1000, mcn)
%
%   'UseParallel' - Use PARFOR when processing individual spectra.
%                   Default: false
%
% OUTPUT:
%   f           - Frequency vector, in cycles per time unit.
%
%   pMC         - Processed power spectra. Each column corresponds to
%                 one Monte Carlo red-noise realization:
%
%                     pMC(:,j) = processed spectrum of simulation j
%
% REQUIRED EXTERNAL FUNCTIONS:
%   theoredar1ML
%   redconf_any

    %% Parse optional inputs

    parser = inputParser;

    addParameter(parser, 'BatchSize', min(1000, mcn), ...
        @(x) isnumeric(x) && isscalar(x) && ...
        isfinite(x) && x >= 1 && x == fix(x));

    addParameter(parser, 'UseParallel', false, ...
        @(x) islogical(x) && isscalar(x));

    parse(parser, varargin{:});

    batchSize  = min(parser.Results.BatchSize, mcn);
    useParallel = parser.Results.UseParallel;

    %% Validate main inputs

    validateattributes(data, {'numeric'}, ...
        {'2d', 'ncols', 2, 'nonempty', 'real'}, ...
        mfilename, 'data', 1);

    validateattributes(rhoM, {'numeric'}, ...
        {'scalar', 'real', 'finite', '>', -1, '<', 1}, ...
        mfilename, 'rhoM', 2);

    validateattributes(mcn, {'numeric'}, ...
        {'scalar', 'integer', 'positive', 'finite'}, ...
        mfilename, 'mcn', 3);

    validateattributes(red, {'numeric'}, ...
        {'scalar', 'real', 'finite'}, ...
        mfilename, 'red', 4);

    validateattributes(pad, {'numeric'}, ...
        {'scalar', 'integer', 'positive', 'finite'}, ...
        mfilename, 'pad', 5);

    validRedOption = ismember(red, [0, 1, 2, 3]) || ...
        (red >= 50 && red < 100);

    if ~validRedOption
        error('redNoisePeriodogramMC:InvalidRedOption', ...
            ['red must be 0, 1, 2, 3, or a confidence level ' ...
             'between 50 and 100.']);
    end

    %% Prepare the input time series

    time = data(:,1);
    values = data(:,2);

    if any(~isfinite(time)) || any(~isfinite(values))
        error('redNoisePeriodogramMC:NonfiniteData', ...
            'The input data must not contain NaN or Inf values.');
    end

    n = length(time);

    if n < 4
        error('redNoisePeriodogramMC:InsufficientData', ...
            'The input time series must contain at least four points.');
    end

    timeDifference = diff(time);

    if any(timeDifference <= 0)
        error('redNoisePeriodogramMC:InvalidTime', ...
            'The time values must be strictly increasing.');
    end

    % Representative sampling interval
    dt = median(timeDifference);

    % Sampling frequency
    samplingFrequency = 1 / dt;

    % Standard deviation of the demeaned observed series
    values = values - mean(values);
    dataStd = std(values);

    if ~isfinite(dataStd) || dataStd <= 0
        error('redNoisePeriodogramMC:InvalidVariance', ...
            'data(:,2) must have a finite, nonzero variance.');
    end

    % Nyquist and Rayleigh frequencies
    dat_nyq = 1 / (2 * dt); %#ok<NASGU>
    dat_ray = 1 / (n * dt); %#ok<NASGU>

    %% Initialize outputs

    f = [];
    pMC = [];

    % Innovation standard deviation required for a stationary AR(1)
    % process with unit variance
    innovationStd = sqrt(1 - rhoM^2);

    %% Generate and process the simulations in batches

    for firstSimulation = 1:batchSize:mcn

        lastSimulation = min( ...
            firstSimulation + batchSize - 1, mcn);

        numberInBatch = ...
            lastSimulation - firstSimulation + 1;

        %% Generate stationary AR(1) red-noise series

        % Each column is an independent Monte Carlo realization
        innovations = randn(n, numberInBatch);

        % The first value has unit variance because it is drawn directly
        % from the stationary distribution. Later innovations have
        % variance 1-rhoM^2.
        if n > 1
            innovations(2:end,:) = ...
                innovationStd .* innovations(2:end,:);
        end

        % Apply the AR(1) recursion along the first dimension:
        %
        % y(t) = rhoM*y(t-1) + innovation(t)
        redSeries = filter( ...
            1, [1, -rhoM], innovations, [], 1);

        % Match the expected standard deviation of the observed data
        redSeries = dataStd .* redSeries;

        %% Calculate periodograms for the entire batch

        % MATLAB treats each column as an independent time series
        [pRaw, fBatch] = periodogram( ...
            redSeries, [], pad, samplingFrequency);

        % Allocate the complete output matrix after the frequency
        % dimension is known
        if isempty(f)
            f = fBatch;
            pMC = zeros(length(f), mcn, 'like', pRaw);
        end

        pProcessed = zeros(size(pRaw), 'like', pRaw);

        %% Remove the red-noise background

        if useParallel

            parfor j = 1:numberInBatch
                pProcessed(:,j) = processOneSpectrum( ...
                    redSeries(:,j), pRaw(:,j), ...
                    fBatch, dt, red);
            end

        else

            for j = 1:numberInBatch
                pProcessed(:,j) = processOneSpectrum( ...
                    redSeries(:,j), pRaw(:,j), ...
                    fBatch, dt, red);
            end

        end

        %% Store the processed spectra

        pMC(:,firstSimulation:lastSimulation) = pProcessed;

    end

end


function p = processOneSpectrum(redSeries, p, f, dt, red)
% processOneSpectrum Remove the selected red-noise background from one
% periodogram.

    switch true

        case red == 0
            % Keep the original periodogram

        case red == 1
            % Subtract the theoretical AR(1) red-noise spectrum
            theored = theoredar1ML( ...
                redSeries, f, mean(p), dt);

            theored = theored(:);

            p = p - theored;

        case red == 2
            % Normalize by the theoretical AR(1) spectrum and subtract 1
            theored = theoredar1ML( ...
                redSeries, f, mean(p), dt);

            theored = theored(:);
            theored = max(theored, realmin('double'));

            p = p ./ theored;
            p = p - 1;

        case red == 3
            % Robust red-noise background estimation
            theored = redconf_any( ...
                f, p, dt, 0.25, 2);

            theored = theored(:);

            p = p - theored;

        case red >= 50 && red < 100
            % Normalize by the selected AR(1) confidence level
            theored = theoredar1ML( ...
                redSeries, f, mean(p), dt);

            theored = theored(:);

            facchired = ...
                2 * gammaincinv(red / 100, 2) / (2 * 2);

            tabtchired = theored .* facchired;
            tabtchired = max(tabtchired, realmin('double'));

            p = p ./ tabtchired;
            p = p - 1;

    end

    % Remove negative and nonfinite residual power
    p(~isfinite(p)) = 0;
    p(p < 0) = 0;

end