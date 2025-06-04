function lambda = lyapunov_exponent(data, tau)
    % data - 重构的相空间数据
    % tau - 数据的延迟时间，用于归一化
    if nargin < 2; tau = 1; end % 延迟时间

    n = size(data, 1);
    eps0 = 1e-5; % 初始邻近点的最小距离
    eps1 = 1;    % 初始邻近点的最大距离
    d = inf(n, 1);
    
    % 查找每个点的最近邻
    for i = 1:n
        if i + tau > n
            continue;
        end
        distances = sqrt(sum((data - data(i, :)).^2, 2));
        distances(i) = inf; % 排除自身
        [d(i), idx] = min(distances);
        
        % 确保不超出索引
        if idx + tau > n
            d(i) = inf;
        end
    end
    
    % 过滤邻近点距离
    valid = d > eps0 & d < eps1;
    d = d(valid);
    k = find(valid);
    
    % 跟踪邻近点的发散
    m = length(d);
    lyap_sum = 0;
    
    for i = 1:m
        % 初始距离
        initial_dist = d(i);
        % 时间演化后的距离
        evolved_dist = sqrt(sum((data(k(i) + tau, :) - data(k(i), :)).^2, 2));
        % 确保演化后的距离大于零
        if evolved_dist <= 0
            continue;
        end
        % 计算局部 Lyapunov 指数
        lyap_sum = lyap_sum + log(evolved_dist / initial_dist);
    end
    
    % 计算全局 Lyapunov 指数
    lambda = lyap_sum / (m * tau);
end
