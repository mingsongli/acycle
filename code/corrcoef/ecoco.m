function [prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,sr_p] = ...
   ecoco(data,~,orbit9,window,dt,step,delinear,red,pad,sr1,sr2,srstep,nsim,adjust,~,plotn,method,fmaxdata,main_unit_selection,calcMode)
% Evolutionary COCO using sliding-window 1-slice COCO.
%
% Each window is evaluated by corrcoefslices_rankNew, so eCOCO uses the
% same target construction, Monte Carlo p-value, and pCOCO definition as
% the upgraded COCO workflow.

if nargin < 20 || isempty(calcMode)
    calcMode = 'accurate';
end
if nargin < 19 || isempty(main_unit_selection)
    main_unit_selection = get_main_unit_selection();
end
if nargin < 18 || isempty(fmaxdata)
    fmaxdata = 1/(2*dt);
end
if nargin < 17 || isempty(method)
    method = 'Spearman';
end
if nargin < 16 || isempty(plotn)
    plotn = 1;
end
calcMode = lower(char(calcMode));
if ~ismember(calcMode,{'fast','accurate'})
    error('calcMode must be either ''fast'' or ''accurate''.');
end

lang_choice = load('ac_lang.txt');
langdict = readtable('langdict.xlsx','VariableNamingRule','preserve');
lang_id = langdict.ID;
lang_var = table2cell(langdict(:, 2 + lang_choice));
[~, ec79] = ismember('ec79',lang_id);
[~, ec85] = ismember('ec85',lang_id);

data = data(all(isfinite(data(:,1:2)),2),1:2);
data = sortrows(data,1);
nrow = size(data,1);
if nrow < 3
    error('eCOCO requires at least three valid data points.');
end

time = data(:,1);
datay = data(:,2);
npts = fix(window/dt);
if npts < 3
    error('eCOCO window is too small for the data sampling interval.');
end
if npts > nrow
    error('eCOCO window is longer than the data series.');
end
if step < 1 || step >= nrow/2
   error('Error: sliding step is too large!');
end

starts = 1:step:(nrow-npts+1);
m3 = numel(starts);
if m3 < 1
    error('No valid eCOCO sliding windows.');
end

sr_range = sr1:srstep:sr2;
nofsr = numel(sr_range);
orbitn = numel(orbit9);

prt_sr = sr_range(:);
out_depth = nan(m3,1);
out_ecc = nan(nofsr,m3);
out_ep = nan(nofsr,m3);
out_eci = nan(nofsr,m3);
out_ecoco = nan(nofsr,m3);
out_ecocorb = nan(nofsr,m3);
out_norbit = nan(nofsr,m3);
sr_p = nan(m3,8);

if lang_choice == 0
    hwaitbar = waitbar(0,'eCOCO processing ... [CTRL + C to quit]', ...
       'WindowStyle','modal');
else
    hwaitbar = waitbar(0,['eCOCO ',lang_var{ec79}], ...
       'WindowStyle','modal');
end
cleanupObj = onCleanup(@()safeClose(hwaitbar));
hwaitbar_find = findobj(hwaitbar,'Type','Patch');
set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0])
setappdata(hwaitbar,'canceling',0)

steps = 50;
nmc_n = max(1,ceil(m3/steps));
waitbarstep = 0;
waitbar(waitbarstep / steps)

if strcmp(calcMode,'fast')
    disp('>> Step 1: prepare sliding windows and run Fast eCOCO');
else
    disp('>> Step 1: prepare sliding windows and run Accurate eCOCO');
end

fastNull = [];
fastFirstCorrCI = [];
if strcmp(calcMode,'fast') && nsim > 0
    datWin0 = [time(starts(1):starts(1)+npts-1), datay(starts(1):starts(1)+npts-1)];
    if delinear == 1
        datWin0(:,2) = detrend(datWin0(:,2),0);
    end
    [fastFirstCorrCI,~,fastNull] = corrcoefslices_rankNew( ...
        datWin0,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,nsim,0,1, ...
        method,fmaxdata,main_unit_selection,true);
end

for i = 1:m3
    m1 = starts(i);
    m2 = m1+npts-1;
    datWin = [time(m1:m2), datay(m1:m2)];
    if delinear == 1
        datWin(:,2) = detrend(datWin(:,2),0);
    end
    out_depth(i) = (datWin(1,1) + datWin(end,1))/2;

    if strcmp(calcMode,'fast')
        if i == 1 && ~isempty(fastFirstCorrCI)
            corrCI = fastFirstCorrCI;
        else
            [corrCI,~] = corrcoefslices_rankNew( ...
                datWin,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,0,0,1, ...
                method,fmaxdata,main_unit_selection,false);
        end
        corr_h0 = [];
    else
        [corrCI,corr_h0] = corrcoefslices_rankNew( ...
            datWin,orbit9,dt,pad,sr1,sr2,srstep,adjust,red,nsim,0,1, ...
            method,fmaxdata,main_unit_selection,false);
    end

    if i == 1
        prt_sr = corrCI(:,1);
    end

    out_ecc(:,i) = corrCI(:,2);
    out_ep(:,i) = corrCI(:,3);
    if strcmp(calcMode,'fast') && ~isempty(fastNull)
        out_eci(:,i) = pValuesFromNull(corrCI(:,2),fastNull,nofsr);
    else
        out_eci(:,i) = getPValues(corr_h0,nofsr);
    end
    out_norbit(:,i) = getOrbitCounts(corr_h0,corrCI,orbitn,nofsr);
    out_ecoco(:,i) = pcocoValue(out_ecc(:,i),out_eci(:,i));
    out_ecocorb(:,i) = out_norbit(:,i) ./ orbitn .* out_ecoco(:,i);

    bestIdx = bestFiniteIndex(out_ecocorb(:,i));
    if ~isempty(bestIdx)
        sr_p(i,1) = out_depth(i);
        sr_p(i,2) = prt_sr(bestIdx);
        sr_p(i,3) = out_ecc(bestIdx,i);
        sr_p(i,4) = out_eci(bestIdx,i);
        sr_p(i,5) = out_norbit(bestIdx,i);
        sr_p(i,6) = out_ecocorb(bestIdx,i);

        disp(['-----> Location : ',num2str(out_depth(i)),' m. Iteration : ',num2str(m3),' -> ',num2str(i)])
        disp(['>>  Sedimentation rate = [ ',num2str(sr_p(i,2)), ...
            ' ] cm/kyr. # of orbital cycles involved : ', ...
            num2str(sr_p(i,5)),' of ',num2str(orbitn)]);
        disp(['    Correlation coefficient ',num2str(sr_p(i,3)), ...
            '. p-value ',num2str(sr_p(i,4)), ...
            '. pCOCO ',num2str(out_ecoco(bestIdx,i)), ...
            '. pCOCOxOrbits ',num2str(sr_p(i,6))])
    else
        disp(['-----> Location : ',num2str(out_depth(i)), ...
            ' m. Iteration : ',num2str(m3),' -> ',num2str(i), ...
            '. No finite pCOCO solution.'])
    end

    if rem(i,nmc_n) == 0
        waitbarstep = waitbarstep+1;
        if waitbarstep > steps
            waitbarstep = steps;
        end
        pause(0.001);
        waitbar(waitbarstep / steps)
    end
    if getappdata(hwaitbar,'canceling')
        break
    end
end

sr_p = trackEcocoRidge(out_ecocorb,prt_sr,out_depth,out_ecc,out_eci,out_norbit,out_ecoco,orbitn,sr_p);
printTrackedEcocoResults(sr_p,orbitn);

if abs(plotn) > 0
    if lang_choice == 0
        hwarn = warndlg('Wait, eCOCO plot ...');
    else
        hwarn = warndlg(lang_var{ec85});
    end
    ecocoplot(prt_sr,out_depth,out_ecc,out_ep,out_eci,out_ecoco,out_ecocorb,out_norbit,plotn);
    try
        close(hwarn)
    catch
    end

    hold on
    plot(sr_p(:,2), sr_p(:,1), 'r-o')
end

function pValues = getPValues(corr_h0,nofsr)
pValues = nan(nofsr,1);
if ~isempty(corr_h0)
    pValues(1:min(nofsr,size(corr_h0,1))) = corr_h0(1:min(nofsr,size(corr_h0,1)),1);
end

function pValues = pValuesFromNull(observed,nullCorr,nofsr)
pValues = nan(nofsr,1);
n = min([nofsr,numel(observed),size(nullCorr,1)]);
for ii = 1:n
    sim = nullCorr(ii,:);
    sim = sim(isfinite(sim));
    obs = observed(ii);
    if isempty(sim) || ~isfinite(obs)
        continue
    end
    pValues(ii) = (sum(sim >= obs) + 1) / (numel(sim) + 1);
end

function norbit = getOrbitCounts(corr_h0,corrCI,orbitn,nofsr)
norbit = nan(nofsr,1);
if size(corr_h0,2) >= 2
    norbit(1:min(nofsr,size(corr_h0,1))) = corr_h0(1:min(nofsr,size(corr_h0,1)),2);
else
    norbit(1:min(nofsr,size(corrCI,1))) = orbitn - corrCI(1:min(nofsr,size(corrCI,1)),end);
end

function value = pcocoValue(rho,pValue)
pSafe = pValue;
pSafe(~isfinite(pSafe) | pSafe <= 0) = NaN;
pSafe(pSafe > 1) = 1;
value = rho .* abs(log10(pSafe));

function idx = bestFiniteIndex(values)
idx = [];
valid = find(isfinite(values));
if isempty(valid)
    return
end
[~,loc] = max(values(valid));
idx = valid(loc);

function printTrackedEcocoResults(sr_p,orbitn)
disp('>> Tracked eCOCO sedimentation-rate path:')
for ii = 1:size(sr_p,1)
    if ~isfinite(sr_p(ii,2))
        continue
    end
    disp(['-----> Location : ',num2str(sr_p(ii,1)), ...
        ' m. Tracked sed. rate = [ ',num2str(sr_p(ii,2)), ...
        ' ] cm/kyr. Local range = [ ',num2str(sr_p(ii,7)), ...
        ', ',num2str(sr_p(ii,8)), ...
        ' ] cm/kyr. # of orbital cycles involved : ', ...
        num2str(sr_p(ii,5)),' of ',num2str(orbitn)]);
    disp(['    Correlation coefficient ',num2str(sr_p(ii,3)), ...
        '. p-value ',num2str(sr_p(ii,4)), ...
        '. pCOCOxOrbits ',num2str(sr_p(ii,6))])
end

function sr_p = trackEcocoRidge(score,prt_sr,out_depth,out_ecc,out_eci,out_norbit,out_ecoco,orbitn,sr_p_fallback)
sr_p = sr_p_fallback;
[nSr,nWin] = size(score);
if nSr == 0 || nWin == 0 || numel(prt_sr) ~= nSr
    return
end

scoreNorm = nan(size(score));
for col = 1:nWin
    colScore = score(:,col);
    ok = isfinite(colScore);
    if ~any(ok)
        continue
    end
    minScore = min(colScore(ok));
    maxScore = max(colScore(ok));
    if maxScore > minScore
        scoreNorm(ok,col) = (colScore(ok) - minScore) ./ (maxScore - minScore);
    else
        scoreNorm(ok,col) = 1;
    end
end

if ~any(isfinite(scoreNorm(:)))
    return
end

srStep = median(abs(diff(prt_sr)));
if ~isfinite(srStep) || srStep <= 0
    srStep = 1;
end
jumpScale = max(2,4*srStep);
jumpPenalty = 0.35;

dp = -inf(nSr,nWin);
back = nan(nSr,nWin);
validFirst = isfinite(scoreNorm(:,1));
dp(validFirst,1) = scoreNorm(validFirst,1);

for col = 2:nWin
    validNow = find(isfinite(scoreNorm(:,col)));
    if isempty(validNow)
        continue
    end
    validPrev = find(isfinite(dp(:,col-1)));
    if isempty(validPrev)
        dp(validNow,col) = scoreNorm(validNow,col);
        continue
    end

    for row = validNow(:)'
        jumps = abs(prt_sr(row) - prt_sr(validPrev)) ./ jumpScale;
        transitionScore = dp(validPrev,col-1) - jumpPenalty .* (jumps .^ 2);
        [bestPrevScore,bestLoc] = max(transitionScore);
        dp(row,col) = scoreNorm(row,col) + bestPrevScore;
        back(row,col) = validPrev(bestLoc);
    end
end

lastCol = find(any(isfinite(dp),1),1,'last');
if isempty(lastCol)
    return
end
[~,row] = max(dp(:,lastCol));
path = nan(1,nWin);
path(lastCol) = row;
for col = lastCol:-1:2
    prev = back(path(col),col);
    if isnan(prev)
        break
    end
    path(col-1) = prev;
end

for col = 1:nWin
    row = path(col);
    if ~isfinite(row)
        continue
    end
    row = round(row);
    sr_p(col,1) = out_depth(col);
    sr_p(col,2) = prt_sr(row);
    sr_p(col,3) = out_ecc(row,col);
    sr_p(col,4) = out_eci(row,col);
    sr_p(col,5) = out_norbit(row,col);
    sr_p(col,6) = out_norbit(row,col) ./ orbitn .* out_ecoco(row,col);
    [sr_p(col,7),sr_p(col,8)] = localSrRange(score(:,col),prt_sr,row,0.9);
end

function [srLow,srHigh] = localSrRange(scoreCol,prt_sr,row,relativeThreshold)
srLow = NaN;
srHigh = NaN;
if row < 1 || row > numel(scoreCol) || ~isfinite(scoreCol(row))
    return
end

threshold = relativeThreshold .* scoreCol(row);
ok = isfinite(scoreCol) & scoreCol >= threshold;
if ~ok(row)
    ok(row) = true;
end

lo = row;
while lo > 1 && ok(lo-1)
    lo = lo - 1;
end

hi = row;
while hi < numel(ok) && ok(hi+1)
    hi = hi + 1;
end

srLow = min(prt_sr([lo,hi]));
srHigh = max(prt_sr([lo,hi]));

function main_unit_selection = get_main_unit_selection()
main_unit_selection = 0;
try
    main_unit_selection = evalin('base','main_unit_selection');
catch
end

function safeClose(h)
try
    if ishandle(h)
        close(h);
    end
catch
end
