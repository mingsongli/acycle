function output = lyapunov_timeseries(data, tau, window, step_size, num_surrogates, do_plot)
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
        do_plot = false;
    end

    % Ensure do_plot is logical
    do_plot = logical(do_plot);
    
    n = size(data, 1);
    col1 = data(:,1);
    dt = median(diff(col1));
    lyap_values = [];
    times = [];
    window_size = round(window/dt);  % in data points
    
    rho = corr(data(1:end-1,2), data(2:end,2)); % rho of the whole series
    %rho = 0.2;  % !!! parameter for ETP
    %rho = 0.9999;  % !!! parameter for ETP
    ploti = 0; % p值不输出
    p_val = [];
    cl95_val = [];
    cl90_val = [];
    
    % 滑动窗口计算 Lyapunov 指数
    for start = 1:step_size:(n - window_size + 1)
        window_data = data(start:start + window_size - 1, 2);  % 假设我们关注第2列
        window_data=zscore(window_data);
        reconstructed = phase_space_reconstruct(window_data, 3, tau);  % 假设嵌入维度为 3
        lyap = lyapunov_exponent(reconstructed, tau);  % 假设函数
        lyap_values = [lyap_values; lyap];
        times = [times; start];
    end
    
    if num_surrogates > 0
        for start = 1:step_size:(n - window_size + 1)
            window_data = data(start:start + window_size - 1, 2);  % 假设我们关注第2列
            % p value
            [p_value,cl95,cl90]= surrogate_analysis(window_data, num_surrogates, rho, ploti); % p值
            p_val = [p_val; p_value];
            cl95_val = [cl95_val; cl95];
            cl90_val = [cl90_val; cl90];
        end
    end
    %times
    timesr = col1(times) + window/2;

    if do_plot
        % 绘制结果
        if num_surrogates > 0
            subplot(2,1,1)
        end
        
        plot(timesr, lyap_values,'k','LineWidth', 2);
        if num_surrogates > 0
            hold on
            plot(timesr, cl95_val,'r-.','LineWidth', 1);
            plot(timesr, cl90_val,'b-.','LineWidth', 1);
        end
        xlim([min(col1), max(col1)])
        xlabel('Time');
        ylabel('Lyapunov Exponent');
        title('Lyapunov Exponent over Time');
        legend('Lyapunov Exponent','95% CL','90% CL');
        set(gca, 'YDir', 'reverse'); % Reverse the y-axis
        hold off
        
        if num_surrogates > 0
            subplot(2,1,2)
            plot(timesr, p_val,'k','LineWidth', 2);
            yline(0.05, 'r--', 'LineWidth', 2); % 添加表示原始 Lyapunov 指数的竖线
            yline(0.01, 'b-.', 'LineWidth', 1); % 添加表示原始 Lyapunov 指数的竖线
            xlabel('Time');
            ylabel('p-value');
            ylim([0, 0.1])
            xlim([min(col1), max(col1)])
            set(gca, 'YDir', 'reverse'); % Reverse the y-axis
        end
    end
    output = [timesr,lyap_values,p_val, cl95_val,cl90_val];
end