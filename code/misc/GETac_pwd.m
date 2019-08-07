% CDac_pwd
% change directory to the acycle present working directory

%fileID = fopen('ac_pwd.txt','r');
%formatSpec = '%s';
%ac_pwd = fscanf(fileID,formatSpec);
%fclose(fileID);
%clear fileID formatSpec

ac_pwd = fileread('ac_pwd.txt');