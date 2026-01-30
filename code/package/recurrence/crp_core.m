function xout = crp_core(x, y, m, tau, e, method, normFlag)
%CRP_CORE  Cross/Auto Recurrence Plot.
%
%
% Inputs:
%   x,y      : Nx1, NxD, or Nx(D+1) with time column
%   m,tau,e  : embedding dimension, delay, threshold parameter
%   method   : accepts GUI codes {'max','eu','min','nr','rr','fa','in','om','op'}
%              and also legacy codes {'ma','eu','mi','nr','rr','fa','in','om','op'}
%              and full names {'maxnorm','euclidean','minnorm','nrmnorm','fan','inter','omatrix','opattern'}
%   normFlag : 'normalize' (default) or 'nonorm'/'nonormalize'/'narow' => NO normalization
%
% Output:
%   xout : recurrence matrix
%          - for most methods: uint8(0/1)
%          - method='di': double distance matrix
%          - method='om': uint8 order-matrix result (NY x NX x m)

% ---------------- defaults ----------------
if nargin < 7 || isempty(normFlag), normFlag = 'normalize'; end
if nargin < 6 || isempty(method),   method   = 'rr';        end
if nargin < 5 || isempty(e),        e        = 0.1;        end
if nargin < 4 || isempty(tau),      tau      = 1;          end
if nargin < 3 || isempty(m),        m        = 1;          end
if nargin < 2 || isempty(y),        y        = x;          end

m   = max(1, round(m));
tau = max(1, round(tau));

% ---------------- normalize method ----------------
method = lower(string(method));
method = map_method_to_code1(method);     % -> "ma","eu","mi","nr","rr","fa","in","om","op"

% ---------------- reshape ----------------
x = double(x); y = double(y);
if size(x,1) < size(x,2), x = x.'; end
if size(y,1) < size(y,2), y = y.'; end

% ---------------- strip time column  ----------------
xdat = strip_timecol_if_monotonic(x);
ydat = strip_timecol_if_monotonic(y);

% ---------------- remove NaN rows ----------------
xdat = remove_nan_rows(xdat);
ydat = remove_nan_rows(ydat);

% ---------------- normalization ----------------
%   nonorm==1 -> normalize; nonorm==0 -> do NOT normalize
% and 'nonorm' in examples corresponds to NON-normalize => nonorm==0.
% here:
%   normFlag starts with "non" (or your GUI 'narow') => do NOT normalize
%   otherwise => normalize (default)
nf = lower(string(normFlag));
doNoNorm = startsWith(nf,"non") || startsWith(nf,"nar");  % 'nonorm','nonormalize','narow'
if ~doNoNorm
    xdat = zscore_cols_infaware(xdat);
    ydat = zscore_cols_infaware(ydat);
end

% ---------------- embedding vectors (delay embedding) ----------------
x2 = embed_delay(xdat, m, tau);
y2 = embed_delay(ydat, m, tau);

NX = size(x2,1);
NY = size(y2,1);
if NX < 1 || NY < 1
    xout = uint8([]);
    return;
end

% ---------------- method branches ----------------
switch method

    %%%%%%%%%%%%%%%%% local CRP, fixed distance (and RR selection)
    case {"ma","eu","mi","rr"}  

        % --- Compute Distance Matrix ---
        switch method
            case {"ma","rr"} % maximum norm / chebychev
                s = pdist2(x2, y2, 'chebychev');
            case "eu"        % euclidean norm
                s = pdist2(x2, y2, 'euclidean');
            case "mi"        % minimum norm 
                s = pdist2(x2, y2, 'cityblock');
        end

        % --- RR: pick epsilon from sorted distances  ---
        if method == "rr"
            ss  = sort(s(:));
            idx = ceil(double(e) * (length(ss) + NX));  
            idx = max(1, min(idx, numel(ss)));
            eRR = ss(idx);
            X2m = (s <= eRR);
        else
            X2m = (s <= double(e));
        end
        
        xout = uint8(X2m)';  

    %%%%%%%%%%%%%%%%% local CRP, normalized distance euclidean norm
    case "nr"
    Dx = sqrt(sum((x2(:,:).^2)'))';
    Dy = sqrt(sum((y2(:,:).^2)'))';

    Dx(~isfinite(Dx) | Dx==0) = 1;
    Dy(~isfinite(Dy) | Dy==0) = 1;

    x2n = x2 ./ repmat(Dx,1,size(x2,2));  
    y2n = y2 ./ repmat(Dy,1,size(y2,2));

    % 2) Euclidean distance between normalized vectors
    s = pdist2(x2n, y2n, 'euclidean');

    % 3) Build CRP matrix using CRP's exact comparison form
    smax = max(s(:));
    if ~isfinite(smax) || smax <= 0
        xout = uint8(zeros(NY, NX));
        return;
    end

    % EXACT: uint8((s/max(s(:))) < (e/max(s(:))))'
    xout = uint8((s./smax) < (double(e)./smax))';


    
    %%%%%%%%%%%%%%%%% fixed amount of nearest neighbours
    case "fa"
        if double(e) >= 1
            e = round(double(e))/100;    
        end

        s = pdist2(x2, y2, 'euclidean');

        mine = round(NY * double(e));
        mine = max(0, min(mine, NY));

        [~, JJ] = sort(s');  
        JJ = JJ';

        X1 = zeros(NX*NY, 1, 'uint8');
        if mine > 0
            base = (0:NY:(NX*NY-1))';
            sel  = JJ(:,1:mine) + repmat(base,1,mine);
            X1(sel(:)) = uint8(1);
        end

        xout = reshape(X1, NY, NX);   

    %%%%%%%%%%%%%%%%% interdependent neighbours 
    case "in"
        if double(e) >= 1
            e = round(double(e))/100;
        end

        px  = permute(x2, [1 3 2]);
        py  = permute(y2, [1 3 2]);
        px2 = permute(x2, [3 1 2]);
        py2 = permute(y2, [3 1 2]);

        sx = pdist2(reshape(px,[],m),  reshape(px2,[],m));
        sy = pdist2(reshape(py,[],m),  reshape(py2,[],m));


        mine = round(min(NX,NY) * double(e));
        mine = max(1, min(mine, min(NX,NY)));

        [SSx, JJx] = sort(sx); %#ok<ASGLU>
        [SSy, JJy] = sort(sy); %#ok<NASGU>

        ey = mean(SSy(mine:mine+1,:), 1);
        % ex = mean(SSx(mine:mine+1,:), 1); 
        X = zeros(min(NX,NY), NX, 'uint8');
        for i = 1:min(NX,NY)
            jj = JJx(1:mine,i);
            jj(jj > min(NX,NY)) = i;
            X(i, jj) = uint8( (sy(i, jj) <= ey(i))' );
        end

        xout = X'; 

    %%%%%%%%%%%%%%%%% order matrix 
    case "om"
        px = permute(x2, [1 3 2]); % NX x 1 x m
        py = permute(y2, [3 1 2]); % 1 x NY x m
        X3 = uint8( px(:,ones(1,NY),:) >= (py(ones(1,NX),:,:) - double(e)) );
        xout = permute(X3, [2 1 3]); 

    %%%%%%%%%%%%%%%%% order patterns recurrence plot
    case "op"
        if m == 1
            m = 2; 
        end

        
        cmdStr = '';
        for i = 2:m
            cmdStr = [cmdStr, ' permX(:,', num2str(i-1) ,') < permX(:,', num2str(i), ') + eps']; %#ok<AGROW>
            if i < m, cmdStr = [cmdStr, ' &']; end %#ok<AGROW>
        end

        pattX = zeros(NX,1);
        pattY = zeros(NY,1);

        for i = 1:NX
            permX = perms(x2(i,1:m));
            orderPattern = find(eval(cmdStr), 1, 'first');
            if isempty(orderPattern), orderPattern = 0; end
            pattX(i) = orderPattern;
        end
        for i = 1:NY
            permX = perms(y2(i,1:m));
            orderPattern = find(eval(cmdStr), 1, 'first');
            if isempty(orderPattern), orderPattern = 0; end
            pattY(i) = orderPattern;
        end

        px = permute(pattX, [1 3 2]); % NX x 1
        py = permute(pattY, [3 1 2]); % 1 x NY
        X2m = uint8( px(:,ones(1,NY),:) == py(ones(1,NX),:,:) );
        xout = uint8(X2m)'; 

end

end

% ===================== helpers =====================

function method = map_method_to_code1(method)
% GUI codes: max, eu, min, nr, rr, fa, in, om, op
if startsWith(method,"max") || method=="max"
    method = "ma"; return;
end
if startsWith(method,"eu") || method=="eu"
    method = "eu"; return;
end
if startsWith(method,"min") || method=="min"
    method = "mi"; return;
end
if startsWith(method,"nr") || startsWith(method,"nrm")
    method = "nr"; return;
end
if startsWith(method,"rr")
    method = "rr"; return;
end
if startsWith(method,"fa") || contains(method,"fan")
    method = "fa"; return;
end
if startsWith(method,"in") || contains(method,"inter")
    method = "in"; return;
end
if startsWith(method,"om") || contains(method,"omatrix")
    method = "om"; return;
end
if startsWith(method,"op") || contains(method,"opattern")
    method = "op"; return;
end

% fall back (assume already code1 short)
method = char(method);
method = string(method);
end

function xdat = strip_timecol_if_monotonic(x)
x = double(x);
if size(x,2) >= 2
    tc = x(:,1);
    if all(isfinite(tc)) && all(diff(tc) >= 0)
        xdat = x(:,2:end);
        return;
    end
end
xdat = x;
end

function A = remove_nan_rows(A)
if isempty(A), return; end
bad = any(isnan(A), 2);
A(bad,:) = [];
end

function A = zscore_cols_infaware(A)
A = double(A);
for k = 1:size(A,2)
    col = A(:,k);
    idx = find(~isinf(col) & isfinite(col));
    if isempty(idx), continue; end
    mu = mean(col(idx));
    sd = std(col(idx));
    if ~isfinite(sd) || sd == 0, sd = 1; end
    A(:,k) = (col - mu) ./ sd;
end
end

function E = embed_delay(x, m, tau)
x = double(x);
N = size(x,1);
d = size(x,2);
L = N - (m-1)*tau;
if L < 1
    E = zeros(0, m*d);
    return;
end
E = zeros(L, m*d);
col = 1;
for k = 0:(m-1)
    rows = (1:L) + k*tau;
    E(:, col:(col+d-1)) = x(rows, :);
    col = col + d;
end
end
