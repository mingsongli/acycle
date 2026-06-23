function BivLinearRegUI

uiFig1 = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Data Table');
if isempty(uiFig1) || ~isnumeric(uiFig1.UserData) || isempty(uiFig1.UserData)
    warning('The Acycle: Data Table does not exist or no data is selected.');
    return
end

data = uiFig1.UserData;
if size(data,2) ~= 2
    warndlg('Warning: two columns in Data Table must be selected')
    return
end
data = data(all(isfinite(data),2),:);
if size(data,1) < 2
    warndlg('Warning: at least two finite rows are required')
    return
end

x = data(:,1);
y = data(:,2);
p = polyfit(x,y,1);
yfit = polyval(p,x);
res = y - yfit;
ssRes = sum(res.^2);
ssTot = sum((y - mean(y)).^2);
r2 = 1 - ssRes / ssTot;
[R,P] = corrcoef(x,y);
if numel(R) >= 4
    r = R(1,2);
    pval = P(1,2);
else
    r = NaN;
    pval = NaN;
end

stats = {
    'Number (N)', sprintf('%8.0f', numel(x));
    'Intercept', sprintf('%10.6f', p(2));
    'Slope', sprintf('%10.6f', p(1));
    'R squared', sprintf('%10.6f', r2);
    'Pearson r', sprintf('%10.6f', r);
    'Pearson p', sprintf('%10.6f', pval);
    'RMSE', sprintf('%10.6f', sqrt(mean(res.^2)))};

sf = findobj(allchild(groot), 'flat', 'Name', 'Acycle: Linear Regression');
if isempty(sf)
    sf = uifigure('Name', 'Acycle: Linear Regression', ...
        'Position', [100, 100, 760, 420], ...
        'NumberTitle', 'off', 'MenuBar', 'none');
else
    delete(sf);
    sf = uifigure('Name', 'Acycle: Linear Regression', ...
        'Position', [100, 100, 760, 420], ...
        'NumberTitle', 'off', 'MenuBar', 'none');
end

uit = uitable(sf, 'Data', stats, ...
    'Units', 'normalized', ...
    'FontSize', 12, ...
    'Position', [0.03, 0.08, 0.36, 0.84], ...
    'ColumnName', {'Statistic', 'Value'}, ...
    'ColumnWidth', {130,120});

ax = uiaxes(sf, 'Units', 'normalized', 'Position', [0.45, 0.12, 0.52, 0.8]);
scatter(ax,x,y,24,'filled');
hold(ax,'on');
[xs,idx] = sort(x);
plot(ax,xs,yfit(idx),'r-','LineWidth',1.5);
hold(ax,'off');
xlabel(ax,'Column 1');
ylabel(ax,'Column 2');
title(ax,'Linear regression');
grid(ax,'on');

end
