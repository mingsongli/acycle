% Subroutine HPSORT from Press et al 1992, p329

function arr = hpsort(arr)
    ndata = length(arr);
    l = floor(ndata / 2) + 1;
    ir = ndata;
    
    while true
        if l > 1
            l = l - 1;
            rra = arr(l);
        else
            rra = arr(ir);
            arr(ir) = arr(1);
            ir = ir - 1;
            
            if ir == 1
                arr(1) = rra;
                return;
            end
        end
        
        i = l;
        j = l + l;
        
        while true
            if j <= ir
                if j < ir
                    if arr(j) < arr(j+1)
                        j = j + 1;
                    end
                end
                
                if rra < arr(j)
                    arr(i) = arr(j);
                    i = j;
                    j = j + j;
                    continue;  % This emulates the CYCLE in Fortran
                else
                    j = ir + 1;
                end
            else
                break;  % This emulates the EXIT in Fortran
            end
        end
        
        arr(i) = rra;
    end
end
