% CDac_pwd
% change directory to the acycle present working directory

pre_dirML = pwd;

ac_pwd = ac_working_directory('get',pre_dirML);

if isfolder(ac_pwd)
    cd(ac_pwd)
end
