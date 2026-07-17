function rhoM = calculateRhoM(data)
% calculateRhoM Calculate the modified AR(1) coefficient rhoM.
%
%   rhoM = calculateRhoM(data)
%
%   INPUT:
%       data - A two-column time series:
%              data(:,1): time
%              data(:,2): observed values
%
%   OUTPUT:
%       rhoM - Modified AR(1) coefficient estimated by minirhos0
%
%   The following external functions are assumed to be available:
%       moveMedian
%       minirhos0

    % Check the input format
    validateattributes(data, {'numeric'}, ...
        {'2d', 'ncols', 2, 'nonempty', 'real'}, ...
        mfilename, 'data', 1);

    % Remove rows containing NaN or Inf values
    data = data(all(isfinite(data), 2), :);

    if size(data, 1) < 4
        error('calculateRhoM:InsufficientData', ...
            'The input time series must contain at least four valid rows.');
    end

    % Sort the time series in ascending time order
    data = sortrows(data, 1);

    time = data(:, 1);
    values = data(:, 2);

    % Estimate the representative sampling interval
    dt = median(diff(time));

    if ~isfinite(dt) || dt <= 0
        error('calculateRhoM:InvalidTime', ...
            'The time values must be distinct and increase monotonically.');
    end

    %% Determine the valid maximum frequency

    % Calculate the periodogram using normalized angular frequency
    [powerPeriodogram, angularFrequency] = periodogram(values);

    % Convert angular frequency from radians/sample to cycles/time unit
    frequencyPeriodogram = angularFrequency / (2 * pi * dt);

    % Calculate the normalized cumulative spectral power
    cumulativePower = cumsum(powerPeriodogram);
    cumulativePowerPercent = 100 * cumulativePower / cumulativePower(end);

    % Find the frequency below which 99 percent of the power is contained
    index99 = find(cumulativePowerPercent > 99, 1, 'first');

    % Exclude an unreliable high-frequency tail when necessary
    if frequencyPeriodogram(index99) / frequencyPeriodogram(end) <= 0.85
        validNyquistFrequency = frequencyPeriodogram(index99);
    else
        validNyquistFrequency = frequencyPeriodogram(end);
    end

    fmax = validNyquistFrequency;

    %% Calculate and smooth the multitaper power spectrum

    % Nyquist frequency in cycles/time unit
    nyquistFrequency = 1 / (2 * dt);

    % Calculate the multitaper power spectral density
    [pxx, angularFrequencyMTM] = pmtm(values, 2, length(values));

    % Convert MTM angular frequency to cycles/time unit
    frequencyMTM = angularFrequencyMTM / pi * nyquistFrequency;

    % Retain only frequencies within the valid frequency range
    validFrequencyIndex = frequencyMTM <= fmax;
    frequencyMTM = frequencyMTM(validFrequencyIndex);
    pxx = pxx(validFrequencyIndex);

    if isempty(pxx)
        error('calculateRhoM:EmptySpectrum', ...
            'No spectral estimates remain within the valid frequency range.');
    end

    % Smooth the spectrum using a moving median window
    smoothingWindow = max(1, round(0.2 * length(pxx)));
    smoothedPxx = moveMedian(pxx, smoothingWindow);

    % Estimate the mean spectral power
    s0 = mean(smoothedPxx);

    %% Estimate rhoM

    % FMAX only selects the reliable portion of the spectrum to fit.  The
    % AR(1) transfer function itself must retain the physical Nyquist
    % frequency 1/(2*dt); substituting FMAX changes cos(pi*f/f_N) and biases
    % rho whenever the high-frequency tail was truncated.
    [rhoM, ~] = minirhos0( ...
        s0, nyquistFrequency, frequencyMTM, smoothedPxx, 2);

end
