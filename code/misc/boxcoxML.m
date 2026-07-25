function y_trans = boxcoxML(y, lambda)
    %BOXCOXML Performs the Box-Cox transformation
    %   y_trans = BOXCOXML(y, lambda) transforms the data in y using
    %   the Box-Cox transformation parameter lambda.
    %
    %   Arguments:
    %   y - A vector of positive values to be transformed
    %   lambda - The Box-Cox transformation parameter
    
    % Check if all elements of y are positive
    if any(y <= 0)
        error('All elements of y must be positive for Box-Cox transformation.');
    end

    % Apply the Box-Cox transformation
    if lambda == 0
        y_trans = log(y);
    else
        y_trans = (y.^lambda - 1) / lambda;
    end
end
