function output = lyapunov_timeseries1(data, tau, window, step_size, num_surrogates, do_plot)
% LYAPUNOV_TIMESERIES  Estimate sliding‐window Lyapunov exponent (and optional surrogate analysis)
%
%   output = LYAPUNOV_TIMESERIES(data, tau, window, step_size)
%   output = LYAPUNOV_TIMESERIES(data, tau, window, step_size, num_surrogates)
%   output = LYAPUNOV_TIMESERIES(data, tau, window, step_size, num_surrogates, do_plot)
%
% INPUTS:
%   data           – N×2 matrix of uniformly sampled time series:
%                    column 1 = time, column 2 = observed values
%   tau            – embedding delay (in same time units as data(:,1))
%   window         – sliding window length (in same time units as data(:,1))
%   step_size      – step size between windows (in number of samples)
%   num_surrogates – (optional) number of Monte Carlo surrogates to compute p-values.
%                    Default: 0 (no surrogate analysis).
%   do_plot        – (optional) logical flag: if true, generate plots. 
%                    Default: true.
%
% OUTPUT:
%   output – M×5 matrix, where M = number of windows:
%            column 1 = center time of each window
%            column 2 = estimated Lyapunov exponent
%            column 3 = surrogate‐based p-value (empty if num_surrogates=0)
%            column 4 = 95% surrogate confidence limit
%            column 5 = 90% surrogate confidence limit
%
% The algorithm does the following for each sliding window:
%   1. Extract the windowed segment from data(:,2).
%   2. Standardize (z-score) that segment.
%   3. Reconstruct phase space using embedding dimension = 3 and delay = tau.
%   4. Estimate the Lyapunov exponent via lyapunov_exponent().
%   5. If num_surrogates>0, run surrogate_analysis() to get p-value and confidence intervals.
%   6. Optionally plot the evolving Lyapunov exponent (and p-values) as a function of time.
%
% EXTERNAL FUNCTIONS REQUIRED:
%   - phase_space_reconstruct(x, emb_dim, tau)
%   - lyapunov_exponent(reconstructed_data, tau)
%   - surrogate_analysis(x, num_surrogates, rho, plot_flag)
%
% Example:
%   % Basic call without surrogate analysis, with plotting
%   out = lyapunov_timeseries(data, 10, 100, 20);
%
%   % With 500 surrogates and no plotting
%   out = lyapunov_timeseries(data, 10, 100, 20, 500, false);
%%
% Mingsong Li (Peking University)
% June 4, 2025
%
    % Set defaults for optional arguments
    if nargin < 5
        num_surrogates = 0;
    end
    if nargin < 6
        do_plot = true;
    end

    % Ensure do_plot is logical
    do_plot = logical(do_plot);

    % Number of samples in the time series
    n = size(data, 1);
    t_vec = data(:,1);
    y_all = data(:,2);

    % Determine sampling interval (assumes uniform sampling)
    dt = median(diff(t_vec));

    % Number of data points per window
    window_size = round(window / dt);
    if window_size < 2
        error('Window length must be at least two samples.');
    end

    % Number of sliding windows
    n_windows = n - window_size + 1;
    if n_windows < 1
        output = [];
        return;
    end

    % Preallocate arrays for speed
    lyap_values = nan(n_windows, 1);
    times_idx   = nan(n_windows, 1);
    if num_surrogates > 0
        p_vals    = nan(n_windows, 1);
        cl95_vals = nan(n_windows, 1);
        cl90_vals = nan(n_windows, 1);
    else
        p_vals    = [];
        cl95_vals = [];
        cl90_vals = [];
    end
    
    % (Optional) The correlation parameter for the surrogate test—adjust as needed:
    rho = 0.9999;  % If surrogate_analysis uses this parameter; otherwise remove

    % Loop over each sliding window
    window_buffer = zeros(window_size, 1);
    for k = 1:step_size:n_windows
        % 1. Extract windowed data segment (column 2) and z-score
        window_buffer(:) = y_all(k : k + window_size - 1);
        window_buffer = zscore(window_buffer);

        % 2. Phase-space reconstruction (embedding dimension fixed at 3 here)
        reconstructed = phase_space_reconstruct(window_buffer, 3, tau);

        % 3. Estimate Lyapunov exponent
        lyap_values(k) = lyapunov_exponent(reconstructed, tau);

        % 4. Record center‐index of this window
        times_idx(k) = k + floor(window_size/2);

        % 5. Surrogate analysis (if requested)
        if num_surrogates > 0
            %[p, c95, c90] = surrogate_analysis(window_buffer, num_surrogates, rho, false);
            [p, c95, c90] = surrogate_analysis(window_buffer, num_surrogates);
            p_vals(k)    = p;
            cl95_vals(k) = c95;
            cl90_vals(k) = c90;
        end
    end

    % Build the time vector for the center of each window
    times_center = t_vec(times_idx) + (window/2);

    % Plot results if requested
    if do_plot
        if num_surrogates > 0
            subplot(2,1,1);
        end

        plot(times_center, lyap_values, 'k-', 'LineWidth', 2);
        hold on;
        if num_surrogates > 0
            plot(times_center, cl95_vals, 'r-.', 'LineWidth', 1);
            plot(times_center, cl90_vals, 'b-.', 'LineWidth', 1);
            legend('Lyapunov Exponent', '95% CL', '90% CL', 'Location', 'best');
        else
            legend('Lyapunov Exponent', 'Location', 'best');
        end
        xlabel('Time');
        ylabel('Lyapunov Exponent');
        title('Sliding‐Window Lyapunov Exponent');
        set(gca, 'YDir', 'reverse');  % Reverse y-axis if desired
        xlim([min(t_vec), max(t_vec)]);
        hold off;

        if num_surrogates > 0
            subplot(2,1,2);
            plot(times_center, p_vals, 'k-', 'LineWidth', 2);
            yline(0.05, 'r--', 'LineWidth', 2);
            yline(0.01, 'b-.', 'LineWidth', 1);
            xlabel('Time');
            ylabel('p-value');
            ylim([0, 0.1]);
            xlim([min(t_vec), max(t_vec)]);
            set(gca, 'YDir', 'reverse');
            title('Surrogate‐Based p-values');
        end
    end

    % Assemble output matrix
    if num_surrogates > 0
        output = [times_center, lyap_values, p_vals, cl95_vals, cl90_vals];
    else
        % If no surrogates, return NaNs for columns 3–5
        output = [times_center, lyap_values, ...
                  nan(size(times_center)), ...
                  nan(size(times_center)), ...
                  nan(size(times_center))];
    end
end
