
function result = gammp(a, x)
    % Inputs:
    %   a: double scalar
    %   x: double scalar
    % Output:
    %   result: double scalar

    if x < 0 || a <= 0
        fprintf('*** Bad arguments in GAMMP ***\n');
        return;
    end

    if x < a + 1
        result = gamser(a, x);
    else
        %gcf(a, x, gl);
        [gammcf1 , ~]= gammcf(a, x);
        result = 1.0 - gammcf1;
    end
end
