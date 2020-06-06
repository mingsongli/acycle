% check ac_opendate.txt
% if acycle not used > 100 days
%   check any update
% check ac_datenow.txt % version date
% if version date is 
format longG
% date today
now_val = round(now);
ac_pwd_str = which('ac_version.txt');
[ac_pwd_dir,~,~] = fileparts(ac_pwd_str);

try
    % if this is not the first time run (i.e., exist ac_opendate.txt)
    fileID = fopen(fullfile(ac_pwd_dir,'ac_opendate.txt'),'r');
    ac_lastopendate = fscanf(fileID,'%d');
    fprintf(fileID,'%d',now_val);
    fclose(fileID);

    if now_val - ac_lastopendate > 100
        
        disp(' Acycle has not been used for 100 days.  Detecting new versions ...')
        fupdate = warndlg('Acycle has not been used for 100 days.','Detecting new version');
        ac_check_update;
        
        fileID = fopen(fullfile(ac_pwd_dir,'ac_opendate.txt'),'w');
        fprintf(fileID,'%d',now_val);
        fclose(fileID);
        
        try
            close(fupdate)
        catch
        end
        
    else
        
        fileID = fopen(fullfile(ac_pwd_dir,'ac_datenow.txt'),'r');
        ac_versiondate = fscanf(fileID,'%d');
        fclose(fileID);
        
        if now_val - ac_versiondate > 365
            disp(' Acycle version has not been detected for 1 yr.  Detecting new versions ...')
            fupdate = warndlg('Acycle has not been updated for 1 yr.','Checking');
            ac_check_update;
            try
                close(fupdate)
            catch
            end
        end
    end
    
catch
    % if this is the first time run (i.e., no ac_opendate.txt file)
    fileID = fopen(fullfile(ac_pwd_dir,'ac_opendate.txt'),'w');
    fprintf(fileID,'%d',now_val);
    fclose(fileID);
end