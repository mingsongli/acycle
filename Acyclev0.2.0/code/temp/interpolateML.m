function [data_even]=interpolateML(data,interpolate_rate,method)
  
% interpolate data 
% default: 2 column data series with using cubic model
% Output even spaced data
% INPUT
%   data: 2 column data with increasing first column as depth/time
%   interpolate_rate: new sampling rate
%   method: interpolation method: 
%       'linear' (default)
%       'pchip' % cubic
%       'fft'   % must be evenly spaced data series
% OUTPUT
%   data_even: evenly spaced interplated data
% EXAMPLE:
%
%   load('interpolateML_data.mat')
%   [data_even]=interpolateML(data,.1,'fft');
%
% Mingsong Li, 2018 Penn State

if nargin < 3
    method = 'linear';
    if nargin < 2
        error('Error: too few input parameters')
    end
end

[nrow, ncol] = size(data);

if ncol < 2
    error('Error: data must be at least 2 columns')
else
    datax=data(:,1);  
    dataxeven= datax(1):interpolate_rate:datax(nrow);
    dataxeven=dataxeven';
    for i = 2:ncol
 %   datayeven=interp1(datax,datay,dataxeven,'pchip');
        if strcmp(method, 'fft')
            N = length(dataxeven); % number of new data
            datayeven(:,i-1) = interpft(data(:,i),N);
        else
            datayeven(:,i-1) = interp1(datax,data(:,i),dataxeven,method);
        end
    end
    data_even=[dataxeven,datayeven];
end