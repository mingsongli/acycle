function [A, B, N] = solve(A, B, N, N1, ZERO)
    % Inputs:
    %   A: N1 x N1 matrix
    %   B: N1 x 1 vector
    %   N: integer
    %   N1: integer
    %   ZERO: real number
    % Outputs:
    %   A: N1 x N1 matrix (updated)
    %   B: N1 x 1 vector (updated)

    for I = 1:N
        DIV = A(I, I);
        if abs(DIV) > ZERO
            for J = 1:N
                A(I, J) = A(I, J) / DIV;
            end
            B(I) = B(I) / DIV;
            
            for J = 1:N
                if I ~= J
                    RATIO = A(J, I);
                    for K = 1:N
                        A(J, K) = A(J, K) - RATIO * A(I, K);
                    end
                    B(J) = B(J) - RATIO * B(I);
                end
            end
        else
            fprintf('\n');
            fprintf('Matrix problem during polynomial fit to spectrum\n');
            return; % Exit the function
        end
    end
end
