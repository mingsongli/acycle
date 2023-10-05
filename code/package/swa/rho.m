% Calculate lag-1 autocorrelation for a time_ml series
% following AUTOCR of Davis (1973). Nb setting L=NDATA-2+1
% and K=J+2-1 (i.e. setting I=2 in AUTOCR) and removed outer
% do loop because only the Lag=1 calculation is relevant here.
% Using doubleprecision for RHOD.
function rho1 = rho(x, nData, varx)
    % Calculate lag-1 autocorrelation for a time series
    % following AUTOCR of Davis (1973). 

    rho1 = -1.0;
    sx = 0.0;
    sy = 0.0;
    sxy = 0.0;
    l = nData - 1;

    for j = 1:l
        k = j + 1;
        sx = sx + x(j);
        sy = sy + x(k);
        sxy = sxy + x(j) * x(k);
    end

    al = double(l);
    rho1 = (al * sxy - sx * sy) / (al * (al - 1.0)) / varx;

    if rho1 < 0.0 || rho1 > 1.0
        fprintf('\n *** Problem within subroutine RHO *** \n');
        fprintf(' ***   RHO < 0.0 or 1.0 < RHO    *** \n');
        fprintf('             RHO= %f \n', rho1);
        error('Exiting due to error in RHO');
    end
end