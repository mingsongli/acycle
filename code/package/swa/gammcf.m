

function [gammcf1 , gln]= gammcf(a, x)
    % Inputs:
    %   a: double scalar
    %   x: double scalar
    % Output:
    %   gammcf: double scalar

    itmax = 100;
    eps = 3.0e-7;
    fpmin = 1.0e-30;
    
    gln = gammln(a);
    b = x + 1.0 - a;
    c = 1.0 / fpmin;
    d = 1.0 / b;
    h = d;

    for i = 1:itmax
        an = -i * (i - a);
        b = b + 2.0;
        d = an * d + b;
        
        if abs(d) < fpmin
            d = fpmin;
        end
        
        c = b + an / c;
        
        if abs(c) < fpmin
            c = fpmin;
        end
        
        d = 1.0 / d;
        del = d * c;
        h = h * del;
        
        if abs(del - 1.0) < eps
            break;
        end
    end

    if i > itmax
        fprintf('*** A too large and ITMAX too small in GCF ***\n');
    end
    
    gammcf1 = exp(-x + a * log(x) - gln) * h;
end
