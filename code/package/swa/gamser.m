
function gamser = gamser(a, x)
    % Inputs:
    %   a: double scalar
    %   x: double scalar
    % Output:
    %   gamser: double scalar

    itmax = 100;
    eps = 3.0e-7;

    if x <= 0
        if x < 0
            fprintf('*** X < 0 in GSER ***\n');
        end
        gamser = 0.0;
        return;
    end

    gl = gammln(a);
    ap = a;
    sum = 1.0 / a;
    del = sum;
    n = 0;

    for n = 1:itmax
        ap = ap + 1.0;
        del = del * x / ap;
        sum = sum + del;

        if abs(del) < abs(sum) * eps
            break;
        end
    end

    if n > itmax
        fprintf('*** A too large and ITMAX too small in GSER ***\n');
    end

    gamser = sum * exp(-x + a * log(x) - gl);
end
