
% Function from REDFIT37 (Schulz & Mudelesee) to estimate
% Chi-squared value given dof, uses Function GAMMP.
% Note converted to doubleprecision function.
% Note TOL decreased to 1E-6 and ITMAX increased to 10000.

function chi2 = getchi2(dof, alpha)
    % Inputs:
    %   dof: double scalar
    %   alpha: double scalar
    % Output:
    %   chi2: double scalar

    tol = 1.0e-6;
    itmax = 10000;
    lm = 0.0;
    rm = 1000.0;
    iter = 0;

    if alpha > 0.5
        eps = (1.0 - alpha) * tol;
    else
        eps = alpha * tol;
    end

    while true
        iter = iter + 1;

        if iter > itmax
            disp('*** Error in GETCHI2: ITER > ITMAX ***\n');
            break;
        end

        chi2 = 0.5 * (lm + rm);
        ac = 1.0 - gammp(0.5 * dof, 0.5 * chi2);

        if abs(ac - alpha) < eps
            break;
        end
        
        if ac > alpha
            lm = chi2;
        else
            rm = chi2;
        end
    end
end

