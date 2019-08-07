function target = gentarget(laskar,t1,t2,f1,f2,ne,nt,np,pad,method)
% INPUT
%   laskar: laskar solutions. 4 == laskar 2004, otherwise = laskar 2010d
%   t1: Interval begining. t1 > 0 AND t1 < 249000
%   t2: Interval end. t2 > t1 AND t2< 249000
%   f1: cutoff frequency. default = 0;
%   f2: cutoff frequency. f2 = 0.06.
%   ne: normalized power of Eccentricity
%   nt: normalized power of tilt
%   np: normalized power of precession
%   pad: zero-padding. Default is 10000
%   method: 1 = periodogram; 2 = MTM;
% OUTPUT
%   target: 2 column series of target = [f,power] from f1 to f2
%
% Needs 2 files stored in the working folders
%   La04.mat
%   La10d.mat
% EXAMPLE
%
%   laskar = 4;
%   t1=1;
%   t2 = 2000;
%   f1 = 0;
%   f2 = 0.06;
%   ne = 1;
%   nt = .6;
%   np = .5;
%   pad = 10000;
%   method = 1;
%   target = gentarget(laskar,t1,t2,f1,f2,ne,nt,np,pad,method);
%   target = gentarget(4,55000,57000,0,0.06,1,.6,.5,10000,1);
%
% Mingsong Li, June 2017
%

nw = 2;

if laskar == 4
    load La04.mat
else
    load La10d.mat
end

dat = data;  % save Laskar solution to dat
data = dat(t1:t2,:);
dat=[];
data(:,5) = ne * zscore(data(:,2))+ nt * zscore(data(:,3)) - np * zscore(data(:,4));
dat(:,1) = data(:,1);
dat(:,2) = data(:,5);
dtt = dat(2,1) - dat(1,1);

if method == 2
    [p, w] = pmtm(dat(:,2),nw,pad);
    f = w/(2*pi*dtt);
else
    [p,f] = periodogram(dat(:,2),[],pad,1/dtt);
end
    target1 = [f,p];

[target]=select_interval(target1,f1,f2);