function [select_inter] = select_interval(data,t1,t2)
% INPUT
%   data: n column dataset including depth/time as the first column, n > 2
%   t1: start time of the selected interval
%   t2: end time of the selected interval
%   
% By Mingsong Li of Penn State, 2017
% debug Mingsong Li, Peking University, Oct. 2023

datax=data(:,1);
select_inter = data(datax >= t1 & datax <= t2, :);