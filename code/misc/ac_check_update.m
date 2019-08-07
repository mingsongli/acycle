
ac_date_offline = load('ac_date.txt');

fileID = fopen('ac_version.txt','r');
ac_version_offline = fscanf(fileID,'%d');
fclose(fileID);

ac_v_link = 'https://raw.githubusercontent.com/mingsongli/acycle/master/code/bin/ac_date.txt';
ac_date_online_str = webread(ac_v_link);
ac_date_online = str2num(ac_date_online_str);

ac_v_link2 = 'https://raw.githubusercontent.com/mingsongli/acycle/master/code/bin/ac_version.txt';
ac_verion_offline = webread(ac_v_link2);

clear ac_v_link ac_v_link2 fileID formatSpec


if ac_date_online > ac_date_offline
    ACUpdate(ac_version_offline,ac_date_offline,ac_verion_offline,ac_date_online);
end




