function [tout, ave_t, var_t, var_t_ci, n_t, nsegout] = runavevar(tseg, t, x, alpha)
    % Calculate np as the length of the t array
    np = length(t);
    % Initialize variables
    segcnt = 0;
    start = 0;
    enddat = false;

    % Preallocate arrays
%     tout = zeros(1, np);
%     ave_t = zeros(1, np);
%     var_t = zeros(1, np);
%     var_t_ci = zeros(2, np);
%     n_t = zeros(1, np);

    while true
        start = start + 1;
        segcnt = segcnt + 1;

        % Start time of the segcnt'th segment
        t0 = t(start);
        idx = start;

        % Find end of the segment
        while true
            idx = idx + 1;
            if (t(idx) - t0 >= tseg) || (idx >= np)
                break;
            end
        end

        if idx == np
            enddat = true;
        end

        % Points in the segment
        npseg = idx - start + 1;

        % Copy segment data into temporary workspace
        xwk = x(start:start+npseg-1);
        twk = t(start:start+npseg-1);

        % Average observation interval for the segment -> used for output
        tout(segcnt) = sum(twk) / npseg;

        % Determine mean and variance for the segment
        ave_t(segcnt) = sum(xwk) / npseg;
        var_t(segcnt) = sum((xwk - ave_t(segcnt)).^2.0) / (npseg - 1);
        n_t(segcnt) = npseg;
        
        
        ahi = 1.0 - 0.5 * alpha;
        alo = 0.5 * alpha;
        dof = n_t(segcnt) - 1;
        if dof >= 2.0
            varhi = dof * var_t(segcnt) / chi2inv(ahi, dof);
            varlo = dof * var_t(segcnt) / chi2inv(alo, dof);
        else
            varhi = -99999.0;
            varlo = -99999.0;
        end
        var_t_ci(1,segcnt) = varhi;
        var_t_ci(2,segcnt) = varlo;
        
        if enddat
            break;
        end
    end

    % Set nsegout
    nsegout = segcnt - 1;
end
