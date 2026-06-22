% CDac_pwd
% change directory to the acycle present working directory

pre_dirML = pwd;

ac_pwd = fileread('ac_pwd.txt');

if isdir(ac_pwd)
    cd(ac_pwd)
end
