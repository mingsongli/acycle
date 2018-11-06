function P = partition_fn(Py, k_max, N)
% The Forward Recursion step of the Bayesian Change Point Algorithm. P(k,j) is
% the probability of the data Y_1:j containing k change points.  

P=zeros(k_max,N)-Inf;        % -Inf b/c starts in log form

%k is the number of Change Points
k=1;            % First row is different from the rest, as you add together two homogeneous segments

for j=k+1:N     % Note: Several of these terms will be -INF, due to d_min
    temp=zeros(1,j-1);
    
    for v=1:j-1
        temp(v)= Py(1,v)+Py(v+1,j);     % Changepoints occur at start of new segment, not at end of old one
    end
    
    P(k,j) = log(sum(exp(temp)));       % Equation (3) - Marginalize over all possible placements of the change point.
    %P(k,j)=logsumlog(temp);            % Slower, but potentially more precise way to do above calculation

    %NOTE: TO AVOID UNDERFLOW, USE:
    %{
    M_temp = max(temp);
    if (M_temp>-Inf)
        temp = temp - M_temp;
        P(k,j)=log(sum(exp(temp))) +M_temp;             % Equation (3) - Marginalize over all possible placements of the change point.
    else
        P(k,j) = -Inf;
    end
    %}

end

for k=2:k_max
    for j=(k+1):N  % Note: Several of these terms will be -INF as well

    temp=zeros(1,j-1);
    
    for v=1:j-1         
        temp(v) = P(k-1,v)+Py(v+1,j);
    end
    
    P(k,j) = log(sum(exp(temp)));   % Equation (4) - Marginalize over all possible placements of the change point.
    %P(k,j)=logsumlog(temp);         % Slower, but potentially more precise way to do above calculation
        
    %NOTE: TO AVOID UNDERFLOW, USE:
    %{
    M_temp = max(temp);
    if (M_temp>-Inf)
        temp = temp - M_temp;
        P(k,j)=log(sum(exp(temp))) +M_temp;             % Equation (4) - Marginalize over all possible placements of the change point.
    else
        P(k,j) = -Inf;
    end
    %}
    
    end
    
    
end

end         % of partition_fn function