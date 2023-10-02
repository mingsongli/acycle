function p = invprctile(x,xq,dim,plot_pos)
%INVPRCTILE  Inverse percentiles of a sample.
% Calculates the nonexceedance probability for xq values from
% sample of data x.
%
% USAGE:
%         p = INVPRCTILE(x,xq)
%         p = INVPRCTILE(x,xq,dim)
%         p = INVPRCTILE(x,xq,dim,plot_pos)
%
% INPUT:
%         x - Vector or Matrix of sample data
%         q - Values for non-exceedance probabilities to be computed.
%             q can be scalar or vector
%       dim - Dimension of matrix x from which non-exceedance probabilities
%             are to be calculated
%  plot_pos - plotting positions that determine interpolation method.
%             Options are as follows:
%  Param        Equation            Description
%  'Weibull'    i/(n+1)             Unbiased exceedance probabilities for
%                                   all distributions
%  'Median'     (i-0.3175)/(n+0.365)Median exceedance probabilities for
%                                   all distributions
%  'APL'        (i-0.35)/n          Used with PWMs.
%  'Blom'       (i-0.375)/(n+0.25)  Unbiased normal quantiles
%  'Cunnane'    (i-0.4)/(n+0.2)     Approx. quantile-unbiased
%  'Gringorten' (i-0.44)/(n+0.12)   Optimised for Gumbel distribution
%  'Hazen'      (i-0.5)/n           [Default] a traditional choice
%  [p1 p2]      (i-p1)/(n+p2)       2-element vector defining custom values
%                                   for p1 & p2. p1 & p2 must take values
%                                   between 0 and 1.
% See: Stedinger JR, Vogel RM, Foufoula-Georgiu E (1995) 'Frequency
% Analysis of Extreme Events' in Maidment, D (ed.) Handbook of Hydrology.
% New York: McGraw-Hill.
%
% OUTPUT:
%    p - Non-exceedance probabilities values for q. When x is a vector, p
%        is the same size as xq, and p(i) contains the non-exceedance
%        probability for xq(i) value.  When x is a matrix, the i-th row of
%        p contains the non-exceedance probability for xq(i)-values of each
%        column of x. For N-dimension arrays, INVPRCTILE operates along the
%        first non-singleton dimension.
%
% EXAMPLES:
%    x = rand(100,1);
%    q = [0.1 0.25 0.8];
%    p = invprctile(x,q,1,'Weibull');
%    % Check with prctile to get back the same results
%    qvalues = prctile(x,p)
%
% See also: PRCTILE, WPRCTILE(FLEX)

% HISTORY:
% version 1.0.0, Release 2013/04/04: Initial release
% version 1.0.1, Release 2013/04/05: Bug fixing for not strictly monotonic
%                                    increasing x values
% version 1.0.2, Release 2013/04/05: Added additional plotting position
%                                    options (J. Bennett)
% version 1.1.0, Release 2014/09/03: Fixing behaviour of unique function after MATLAB R2012b,
%            Default behaviour of unique function after MATLAB R2012b
%            is the indices of the first occurance of the repeated values.
%            Prior to  R2012b, unique returns indices of the last
%            occurance of the repeated values

% Author: Durga Lal Shrestha
% CSIRO Land & Water, Highett, Australia
% eMail: durgalal.shrestha@gmail.com
% Website: www.durgalal.co.cc
% Copyright 2013 Durga Lal Shrestha
% $First created: 04-Apr-2013
% $Revision: 1.1.0 $ $Date: 03-Sep-2014 10:21:00 $

% *************************************************************************
%% INPUT ARGUMENTS CHECK
narginchk(2, 4)

if ~isvector(xq) || numel(xq) == 0 || ~isreal(xq)
    error('invprctile:BadInvPercentile','Bad xq value');
end
%% Order inputs/arrays and set parameters

% Figure out which dimension prctile will work along.
sz = size(x);
if nargin < 3
    dim = find(sz ~= 1,1);
    if isempty(dim)
        dim = 1;
    end
    dimArgGiven = false;
else
    % Permute the array so that the requested dimension is the first dim.
    nDimsX = ndims(x);
    perm = [dim:max(nDimsX,dim) 1:dim-1];
    x = permute(x,perm);
    % Pad with ones if dim > ndims.
    if dim > nDimsX
        sz = [sz ones(1,dim-nDimsX)];
    end
    sz = sz(perm);
    dim = 1;
    dimArgGiven = true;
end

% Determine the plotting position and set parameters accordingly
if nargin < 4
    plot_pos = 'Hazen';
end

if ischar(plot_pos)
    if strcmpi(plot_pos,'Weibull')
        p1 = 0; p2 = 1;
    elseif strcmpi(plot_pos,'Median')
        p1 = 0.3175; p2 = 0.365;
    elseif strcmpi(plot_pos,'APL')
        p1 = 0.35; p2 = 0;
    elseif strcmpi(plot_pos,'Blom')
        p1 = 0.375; p2 = 0.25;
    elseif strcmpi(plot_pos,'Cunnane')
        p1 = 0.4; p2 = 0.2;
    elseif strcmpi(plot_pos,'Gringorten')
        p1 = 0.44; p2 = 0.12;
    elseif strcmpi(plot_pos,'Hazen')
        p1 = 0.5; p2 = 0;
    else
        error('invprctile:BadPlottingPosition','Plotting position not recognised');
    end
else
    if length(plot_pos)~=2
        error('invprctile:BadPlottingPosition','Plotting position vector does not have 2 elements');
    end
    if max(plot_pos)>1 || min(plot_pos)<0
        error('invprctile:BadPlottingPosition','Plotting position parameters must be between one and zero');
    end
    p1 = plot_pos(1); p2 = plot_pos(2);
end

%% Calculate inverse percentile
% If X is empty, return all NaNs.
if isempty(x)
    if isequal(x,[]) && ~dimArgGiven
        p = nan(size(xq),class(x));
    else
        szout = sz; szout(dim) = numel(xq);
        p = nan(szout,class(x));
    end
    
else
    % Drop X's leading singleton dims, and combine its trailing dims.  This
    % leaves a matrix, and we can work along columns.
    nrows = sz(dim);
    ncols = prod(sz) ./ nrows;
    x = reshape(x, nrows, ncols);
    x = sort(x,1);
    nonnans = ~isnan(x);
    if sum(~nonnans(:))==0;
        vctrse = true;
    else
        vctrse = false;
    end
    
    % For interpolation yi = interp1(x,Y,xi) x must be vector,so work on
    % each column separately.
    extrapvalMin = 0; % extrapolation value for outsite range (lower end)
    extrapvalMax = 1; % extrapolation value for outsite range (upper end)
    
    % Get percentiles of the non-NaN values in each column.
    %p = zeros(numel(xq), ncols).*NaN;
    p = zeros(numel(xq), ncols,class(x)).*NaN;
    if vctrse        
        px =(((1:size(x,1))-p1)./(size(x,1)+p2))';
        for j = 1:ncols
            xx = x(:,j);
            % Bug fixing for not strictly monotonic increasing x values
            % (2013/04/05, version 1.0.1)
            % [xx, ind] = unique(xx); % Release before R2012b
            [xx, ind] = unique(xx,'last','legacy'); % Release after R2012b
            pp = px(ind);
            if length(xx)==1     % if only single xx
                p(:,j)=100;
                ind = xq < xx;   % for xq < xx cdf is zero, for xq >=xx cdf is 100
                p(ind,j)=0;
            else
                p(:,j) = interp1(xx,pp,xq(:)).*100;
                % Perform extrapolation for elements of xq outside the range of xx
                extptids =  xq < xx(1);
                p(extptids,j) = extrapvalMin.*100;
                extptids =  xq > xx(end);
                p(extptids,j) = extrapvalMax.*100;
            end
        end
    else
        for j = 1:ncols
            nj = find(nonnans(:,j),1,'last');
            if nj > 0
                pp =((1:nj)-p1)./(nj+p2)';
                % pp =(((1:nj)-0.5)./nj)';  % Plotting position pp(k) = (k-0.5)/n
                xx = x(1:nj,j);
                % Bug fixing for not strictly monotonic increasing x values
                % (2013/04/05, version 1.0.1)
                %[xx, ind] = unique(xx);  % Release before R2012b
                [xx, ind] = unique(xx,'last','legacy');
                pp = pp(ind);
                if length(xx)==1     % if only single xx
                    p(:,j)=100;
                    ind = xq < xx;   % for xq < xx cdf is zero, for xq >=xx cdf is 100
                    p(ind,j)=0;
                else                    
                    p(:,j) = interp1(xx,pp,xq(:)).*100;                    
                    % Perform extrapolation for elements of xq outside the range of xx
                    extptids =  xq < xx(1);
                    p(extptids,j) = extrapvalMin.*100;
                    extptids =  xq > xx(end);
                    p(extptids,j) = extrapvalMax.*100;
                end
            end
        end
    end
    
    % Reshape p to conform to X's original shape and size.
    szout = sz; szout(dim) = numel(xq);
    p = reshape(p,szout);
end
% undo the DIM permutation
if dimArgGiven
    p = ipermute(p,perm);
end

% If X is a vector, the shape of p should follow that of xq, unless an
% explicit DIM arg was given.
if ~dimArgGiven && isvector(x)
    p = reshape(p,size(xq));
end
