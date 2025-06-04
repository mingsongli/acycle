function [p_value,cl95,cl90] = surrogate_analysis(data, num_surrogates, rho, ploti)
    data = zscore(data); % zscore
    if nargin < 4; ploti = 0; end
    if nargin < 3
        % 计算原始数据的Lag-1相关系数
        rho = corr(data(1:end-1), data(2:end));
        %rho = 0.981;
    end
    % 计算原始数据的Lyapunov指数
    tau = 1; % 延迟时间
    reconstructed = phase_space_reconstruct(data, 3, tau);  % 假设嵌入维度为 3
    original_lyap = lyapunov_exponent(reconstructed,tau);

    % 生成替代数据并计算它们的Lyapunov指数
    surrogate_lyaps = zeros(num_surrogates, 1);
    for i = 1:num_surrogates
        %surrogate_data = generate_red_noise(length(data), rho);
        surrogate_data = redmark(rho, length(data));
        %surrogate_data = randn(length(data),1);
        reconstructed = phase_space_reconstruct(surrogate_data, 3, tau);  % 假设嵌入维度为 3
        surrogate_lyaps(i) = lyapunov_exponent(reconstructed,tau);
    end

    % 计算显著性
    p_value = sum(surrogate_lyaps >= original_lyap) / num_surrogates;
    % 计算 95% 置信线
    cl95 = quantile(surrogate_lyaps, 0.95);
    cl90 = quantile(surrogate_lyaps, 0.9);
    
    if ploti == 1
        % 输出结果
        fprintf('Original data rho: %f\n', rho);
        fprintf('Original Lyapunov Exponent: %f\n', original_lyap);
        fprintf('P-Value: %f\n', p_value);

        % 生成核密度估计图
        figure; % 创建新图窗口
        [f, xi] = ksdensity(surrogate_lyaps); % 计算核密度
        plot(xi, f, 'LineWidth', 2); % 绘制核密度图
        hold on; % 保持图像，以便添加更多图层
        xline(original_lyap, 'r', 'LineWidth', 2); % 添加表示原始 Lyapunov 指数的竖线
        xline(cl95, 'k-.', 'LineWidth', 1); % 添加表示原始 Lyapunov 指数的竖线
        hold off; % 解除保持状态

        % 添加图形标签
        xlabel('Lyapunov Exponent');
        ylabel('Density');
        title('Kernel Density Estimate of Surrogate Lyapunov Exponents');
        legend('Surrogate Density', 'Original Lyapunov Exponent','95% CL');
    end
end