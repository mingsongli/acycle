function [Y, testi] = crp_pdist(x, w, ws, theiler_window, lmin, plotn, threshold, method_use, normFlag, m, tau)

% crp_pdist  Sliding-window DET using ONLY crp_core to build RP.
% DET computation is aligned with crqa.m builtin branch:
%   1) Build RP (X)
%   2) Apply Theiler window (X_theiler)
%   3) Get diagonal line lengths via dl()
%   4) Keep only lengths >= lmin
%   5) DET = (recurrence points in diagonal lines >= lmin) / (all recurrence points after Theiler)

% ---------------- defaults ----------------
if nargin < 11 || isempty(tau), tau = 1; end
if nargin < 10 || isempty(m),   m   = 1; end
if nargin < 9 || isempty(normFlag),        normFlag = 'nonorm'; end
if nargin < 8 || isempty(method_use),      method_use = 'rr'; end
if nargin < 7 || isempty(threshold),       threshold = 0.10; end
if nargin < 6 || isempty(plotn),           plotn = 0; end
if nargin < 5 || isempty(lmin),            lmin = 2; end
if nargin < 4 || isempty(theiler_window),  theiler_window = 1; end
if nargin < 3 || isempty(ws),              ws = 1; end

Nx = size(x,1);
if nargin < 2 || isempty(w)
    w = floor(0.5 * Nx);
end

% ---------------- sanity ----------------
if exist('dl','file') ~= 2
    error('crp_pdist:NoDL', 'dl.m not found on path.');
end
if exist('crp_core','file') ~= 2
    error('crp_pdist:NoCRPCORE', 'crp_core.m not found on path.');
end
if exist('crp_big_core','file') ~= 2
    error('crp_pdist:NoCRPBIGCORE', 'crp_big_core.m not found on path.');
end

% ---------------- time axis for plotting / window centers ----------------
[tAxis, xPlot] = local_time_and_signal(x);   % robust even if x is Nx1
testi  = 1:ws:(Nx - w + 1);
testnn = numel(testi);

Y = nan(testnn,1);

borderline_mode = 'all';

% threshold parsing
info = local_parse_threshold(threshold, method_use);

m   = max(1, round(m));
tau = max(1, round(tau));

for jj = 1:testnn

    i0   = testi(jj);
    xwin = x(i0:i0+w-1, :);
    ywin = xwin; % auto-RP

    NXemb = size(xwin,1) - (m-1)*tau;

    method_call = method_use;   

    X = crp_core(xwin, ywin, m, tau, info.value, method_call, normFlag);

    % -------- Theiler window --------
    if theiler_window > 0
        X_theiler = double(triu(X, theiler_window)) + double(tril(X, -theiler_window));
    else
        X_theiler = double(X);
    end

    % -------- DET computation  --------
    [~, b] = dl(X_theiler, borderline_mode);

    b(b < lmin) = [];
    if isempty(b)
        b = 0;
    end

    if sum(X_theiler(:)) > 0
        DET = sum(b) / sum(X_theiler(:));
    else
        DET = NaN;
    end

    Y(jj) = DET;
end


testi = testi(:);

% ---------------- optional plot ----------------
if plotn == 1
    figure('Color','w');
    subplot(2,1,1);
    plot(tAxis, xPlot, 'k-'); grid on;
    xlim([tAxis(1) tAxis(end)]);
    xlabel('Time'); ylabel('Value');

    subplot(2,1,2);
    tCenter = tAxis(min(Nx, round(testi + w/2)));
    plot(tCenter, Y, 'k-', 'LineWidth', 1.5); grid on;
    xlim([tAxis(1) tAxis(end)]);
    xlabel('Time'); ylabel('DET');
end

end

% ================= helpers =================
function [tAxis, xPlot] = local_time_and_signal(x)
% If x is Nx2+ and first col is monotonic, treat col1 as time and col2 as signal for plot.
% Otherwise, use sample index.
x = double(x);
N = size(x,1);

if size(x,2) >= 2
    tc = x(:,1);
    if all(isfinite(tc)) && all(diff(tc) >= 0)
        tAxis = tc;
        xPlot = x(:,2);
        return;
    end
end

tAxis = (1:N)';
xPlot = x(:, min(size(x,2),1));
end

function info = local_parse_threshold(threshold, method_use)
% OUTPUT fields:
%   info.mode   : 'eps' or 'rr'   (rr means "rate/proportion" modes like rr/fa/in)
%   info.value  : eps (if mode='eps') OR rate in (0,1) (if mode='rr')
%
% Notes:
%   - For ma/eu/mi/nr : ALWAYS eps-mode (even if threshold<=1).
%   - For rr/fa/in    : ALWAYS rr-mode (<=1 is already fraction; <=100 means percent).


if nargin < 2 || isempty(method_use), method_use = 'rr'; end
if nargin < 1 || isempty(threshold) || ~isfinite(threshold) || threshold <= 0
    threshold = 0.10;
end

method_use = lower(string(method_use));

rr_methods  = ["rr","fa","in"];                
eps_methods = ["ma","eu","mi","nr"];            % fixed distance eps modes

info = struct('mode',"eps",'value',double(threshold));

if any(method_use == rr_methods)
    % threshold means RR / proportion
    if threshold <= 1
        rr = threshold;
    elseif threshold <= 100
        rr = threshold/100;
    else
        % rr/fa/in do NOT accept eps in Marwan GUI logic; force to a sensible rate
        rr = 0.10;
    end
    info.mode  = "rr";
    info.value = double(rr);
    return;
end

% default: eps distance (ma/eu/mi/nr etc.)
info.mode  = "eps";
info.value = double(threshold);
end
