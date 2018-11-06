% startup script to make Octave/Matlab aware of the GPML package
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch 2018-08-01.

disp ('executing gpml startup script...')
mydir = fileparts (mfilename ('fullpath'));                 % where am I located
addpath (mydir)
dirs = {'cov','doc','inf','lik','mean','prior','util'};           % core folders
for d = dirs, addpath (fullfile (mydir, d{1})), end
dirs = {{'util','minfunc'},{'util','minfunc','compiled'}};     % minfunc folders
for d = dirs, addpath (fullfile (mydir, d{1}{:})), end
addpath([mydir,'/util/sparseinv'])