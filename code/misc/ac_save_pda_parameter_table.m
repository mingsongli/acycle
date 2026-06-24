function ac_save_pda_parameter_table(dat_name,inputFile,outputFile,f3,window,nw,ftmin,fterm,step,pad,padtype)
paramFile = ac_pda_next_indexed_file([dat_name,'-PDA-parameters'],'.xls');
params = repmat({''},17,6);
params(1,2) = {'Detailed Parameters Used in Data Processing by Acycle'};
params(2,2:6) = {'Version','Designed by','Institute','E-mail','Date'};
params(3,2:6) = {'v1.1','Mingsong Li','Peking University','msli@pku.edu.cn',datestr(now,'yyyy-mm-dd HH:MM:SS')};
params(5,2:5) = {'Tools','Items','Parameters','Explanations'};

[~,inputBase,inputExt] = fileparts(inputFile);
params(7,:) = {'','Power decomposition analysis','Input file name',[inputBase,inputExt],'',''};
params(8,:) = {'','','Frequency minimum',min(f3(:)),'',''};
params(9,:) = {'','','Frequency maximum',max(f3(:)),'',''};
params(10,:) = {'','','Window size',window,'',''};
params(11,:) = {'','','Time-bandwidth product',nw,'',''};
params(12,:) = {'','','Lower cutoff frequency',ftmin,'',''};
params(13,:) = {'','','Upper cutoff frequency',fterm,'',''};
params(14,:) = {'','','Step of calculation',step,'',''};
params(15,:) = {'','','Zero-padding number',pad,'',''};
params(16,:) = {'','','Padding depth',ac_pda_padding_depth_name(padtype),'Select no/zero/mirror/mean/random',''};
params(17,:) = {'','','Output file name',outputFile,'',''};

writecell(params,paramFile,'Sheet','COCO');

function s = ac_pda_padding_depth_name(padtype)
switch round(padtype)
    case 0
        s = 'No';
    case 1
        s = 'zero';
    case 2
        s = 'mirror';
    case 3
        s = 'mean';
    case 4
        s = 'random';
    otherwise
        s = num2str(padtype);
end

function filename = ac_pda_next_indexed_file(baseName,ext)
for ii = 1:9999
    filename = sprintf('%s-%d%s',baseName,ii,ext);
    if ~exist(filename,'file')
        return
    end
end
filename = sprintf('%s-%s%s',baseName,datestr(now,'yyyymmddTHHMMSS'),ext);
