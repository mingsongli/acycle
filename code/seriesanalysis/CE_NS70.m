function ce = CE_NS70(data, model)
% CE_NS70
% The Nash-Sutcliffe model efficiency coefficient statistic calculated 
% following Nash & Sutcliffe (1970)
% INPUT
%   data: observation; m x n; m is value; n is time
%   model: model, the same size as data
% OUTPUT
%   ce: efficiency coefficient

df = model - data;
numer = df .^ 2;
numer = sum(numer,'omitnan');

df2 = data - mean(data,'omitnan');
denom = df2 .^ 2;
denom = sum(denom,'omitnan');

ce = 1 - numer./denom;