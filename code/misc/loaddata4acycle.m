
% INPUT
%   nplot : number of plot
%   plot_selected: selected
%   contents
%
% check
filetype = {'.txt','.csv','','.res','.dat','.out'};
nplot = 1;
for i = 1:nplot
    plot_no = plot_selected(i);
    plot_filter_s = char(contents(plot_no));
    plot_filter_s = strrep2(plot_filter_s, '<HTML><FONT color="blue">', '</FONT></HTML>');
    if isdir(plot_filter_s)
        return
    else
        [~,dat_name,ext] = fileparts(plot_filter_s);
        check = 0;
        if sum(strcmp(ext,filetype)) > 0
            check = 1; % selection can be executed 
        end
    end
end

if check == 1
    for i = 1:nplot
        plot_no = plot_selected(i);
        plot_filter_s1 = char(contents(plot_no));
        GETac_pwd; 
        plot_filter_s = fullfile(ac_pwd,plot_filter_s1);
        [~,plotseries,ext] = fileparts(plot_filter_s);
        try
            data_filterout = load(plot_filter_s); % load data directly
        catch  % if failed
            try
                T = readtable(plot_filter_s); % Adjust the 'HeaderLines' if more than one header line
                if all(varfun(@isnumeric, T, 'OutputFormat', 'uniform'))
                    data_filterout = table2array(T);
                    disp('Load data with header ...')
                else
                    disp('Data contains non-numeric values or multiple data types.');
                end

            catch
    
                fid = fopen(plot_filter_s);
                try data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                    fclose(fid);
                    if iscell(data_ft)
                        try
                            data_filterout = cell2mat(data_ft);
                        catch
                            fid = fopen(plot_filter_s,'at');
                            fprintf(fid,'%d\n',[]);
                            fclose(fid);
                            fid = fopen(plot_filter_s);
                            data_ft = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '},'EmptyValue', Inf);
                            fclose(fid);
                            try
                                data_filterout = cell2mat(data_ft);
                            catch
                                disp(['Data Error! Check data: ', dat_name])
                            end
                        end
                    end
                catch
                    disp('Error! Cannot find the data.')
                end
            end
        end     
    end
end