%

        [dat_dir,dat_name,ext] = fileparts(data_name);
        if sum(strcmp(ext,handles.filetype)) > 0
            data = load(data_name);
            time = data(:,1);
            npts = length(time);
            sr_all = diff(time);
            sr_equal = abs((max(sr_all)-min(sr_all))/2);
            if sr_equal > eps('single')
                warndlg({'Data problem detected.';...
                    'Try "Math->Sort&Unique" or "Math->Interpolation" first...'},'Data: Warning');
            end
            % set zeropadding
            if npts <= 2500
                handles.pad = 5000;
            elseif npts <= 5000 && npts > 2500
                handles.pad = 10000;
            else
                handles.pad = fix(npts/5000) * 5000 + 5000;
            end
            if strcmp(handles.unit,'m')
            elseif strcmp(handles.unit, 'unit')
                warndlg({'Unit of the selected data is "unit"'; ...
                    '(see pop-up menu at top right corner of Acycle main window)';...
                    'Acycle assumes the real UNIT is "m"';'If this is not true, please correct.'},'Unit Warning');
            elseif strcmp(handles.unit,'dm')
                warndlg({'Unit of the selected data is "dm"'; ...
                    '(see pop-up menu at top right corner of Acycle main window)';...
                    'Acycle transformed the data, now the unit of "m"'},'Unit transformed');
                data(:,1) = data(:,1) * 0.1; % dm to m
            elseif strcmp(handles.unit,'cm')
                warndlg({'Unit of the selected data is "cm"'; ...
                    '(see pop-up menu at top right corner of Acycle main window)';...
                    'Acycle transformed the data, now the unit of "m"'},'Unit transformed');
                data(:,1) = data(:,1) * 0.01; % cm to m
            elseif strcmp(handles.unit,'mm')
                warndlg({'Unit of the selected data is "mm"'; ...
                    '(see pop-up menu at top right corner of Acycle main window)';...
                    'Acycle transformed the data, now the unit of "m"'},'Unit transformed');
                data(:,1) = data(:,1) * 0.001; % cm to m
            else
                warndlg('UNIT of the data MUST be "m/dm/cm/mm"!.','Unit Error')
            end
            
            prompt = {'DATA: Middle age of the data (Ma)',...
                'TARGET: MAX frequency',...
                'TARGET: Zero padding: (default)',...
                '[Optional] Weight of eccentricity',...
                '[Optional] Weight of obliquity',...
                '[Optional] Weight of precession'};
            dlg_title = 'STEP 1: TARGET: Correlation coefficient';
            num_lines = 1;
            %defaultans = {num2str(handles.t1),num2str(handles.t2),'0','0.06','1','0.6','0.5'};
            defaultans = {num2str(handles.t1),num2str(handles.f2),...
                num2str(handles.pad),...
                '1','0.6','0.5'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
            if ~isempty(answer)
                t1 = 1000 * str2double(answer{1});
                f1 = handles.f1;
                f2 = str2double(answer{2});
                pad = str2double(answer{3});
                p1 = str2double(answer{4});  % power of eccentricity
                p2 = str2double(answer{5});  % power of obliquity
                p3 = str2double(answer{6});  % power of precession
                if t1 < 0
                    errordlg('Error: Age of the data must be no smaller than 0')
                    return;
                elseif t1 == 0 
                    t1 = 1;
                elseif t1 > 4500000
                    errordlg('Error: Age of the data is too large')
                end
                    age = t1;
                    
                if t1 > 249000
                    %%
                    prompt = {'Orbital solutions: Berger89 = 1; La04/La10 = 2; User-defined = 3',...
                        'OR user defined 7 orbital parameters, space delimited',...
                        'Online resource for user-defined parameters'};
                    waltham15 = 'http://nm2.rhul.ac.uk/wp-content/uploads/2015/01/Milankovitch.html';
                    dlg_title = 'STEP 2: t2 >= 249 Ma, choose orbital options';
                    num_lines = 1;
                    defaultans = {'1','405 125 95 ',waltham15};
                    options.Resize='on';
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                    if ~isempty(answer)
                        optionOS = str2double(answer{1});
                        optionUD = str2num(answer{2});
                        if optionOS == 2
                            % Ages for orbit7, equations follow Yao et al., 2015
                            % EPSL and Laskar et al., 2004 A&A                        
                            age_obl = 41 - 0.0332 * age/1000;
                            age_p1 = 22.43 - 0.0108 * age/1000;
                            age_p2 = 23.75 - 0.0121 * age/1000;
                            age_p3 = 19.18 - 0.0079 * age/1000;
                            orbit7 = [405 125 95 age_obl age_p2 age_p1 age_p3];
                            target = period2spectrum(orbit7,t1-1000,t1+1000,1,f1,f2,1,pad);
                        elseif optionOS == 3 || length(optionUD) == 7
                            if length(optionUD) < 4
                                errorlog('Error: too few parameters!')
                            elseif length(optionUD) > 7
                                errorlog('Error: too many parameters!')
                            else
                                orbit7 = optionUD;
                                target = period2spectrum(orbit7,t1-1000,t1+1000,1,f1,f2,1,pad);
                            end
                        else
                            orbit7 = getBerger89Period(age/1000);
                            target = period2spectrumB(orbit7,t1-1000,t1+1000,1,f1,f2,1,pad);
                        end

                    end
                else
                    % Generate target using La2004 solution
                    age_obl = 41 - 0.0332 * age/1000;
                    age_p1 = 22.43 - 0.0108 * age/1000;
                    age_p2 = 23.75 - 0.0121 * age/1000;
                    age_p3 = 19.18 - 0.0079 * age/1000;
                    orbit7 = [405 125 95 age_obl age_p2 age_p1 age_p3];
                    if and(t1 <= 248000,t1 > 1000)
                        target = gentarget(4,t1-1000,t1+1000,f1,f2,p1,p2,p3,pad,1);
                    elseif t1 > 248000
                        target = gentarget(4,247000,249000,f1,f2,p1,p2,p3,pad,1);
                    elseif t1 <= 1000
                        target = gentarget(4,1,2000,f1,f2,p1,p2,p3,pad,1);
                    end
                end
                
                prompt = {'DATA: MIN  sedimentation rate (cm/kyr)',...
                    'DATA: MAX  sedimentation rate (cm/kyr)',...
                    'DATA: STEP sedimentation rate (cm/kyr)',...
                    'Number of simulations (e.g., 200, 600, 2000)',...
                    'Remove red noise: 0 = No, 1 = x/AR(1), 2 = x-AR(1)',...
                    'Split series: 1, 2, 3, ...'};
                if t1 >= 249
                    dlg_title = 'STEP 3: DATA: Correlation coefficient';
                else
                    dlg_title = 'STEP 2: DATA: Correlation coefficient';
                end
                num_lines = 1;
                defaultans = {num2str(handles.sr1),num2str(handles.sr2),num2str(handles.srstep),...
                   num2str(handles.nsim),num2str(handles.red),num2str(handles.slices)};
               
                options.Resize='on';
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                if ~isempty(answer)
                    srm = mean(diff(data(:,1)));
                    pad1 = pad;
                    sr1 = str2double(answer{1});
                    sr2 = str2double(answer{2});
                    srstep = str2double(answer{3});
                    nsim = str2double(answer{4});
                    red = str2double(answer{5});
                    adjust = 0;
                    slices = str2double(answer{6});
                    plotn = 1;
                    %corrmethod = str2double(answer{9});
                    corrmethod = 1;  % 1= 'Pearson'; else = 'Spearman'
                    
                    handles.t1 = t1/1000;
                    handles.f1 = f1;
                    handles.f2 = f2;
                    handles.srm = srm;
                    handles.sr1 = sr1;
                    handles.sr2 = sr2;
                    handles.srstep = srstep;
                    handles.nsim = nsim;
                    handles.red = red;
                    handles.adjust = adjust;
                    handles.slices = slices;
                    handles.pad = pad1;

                    f = figure;
                    ax1 = subplot(2,1,1);   % plot power spectrum of target series
                    % subplot 2 will be spectra of slices see below "corrcoefslices_rank" line
                    plot(ax1,target(:,1),target(:,2),'LineWidth',1)
                    xlim(ax1,[f1 f2])
                    xlabel(ax1,'Frequency (cycle/kyr)')
                    ylabel(ax1,'Power')
                    set(ax1,'XMinorTick','on','YMinorTick','on')
                    title(ax1,'Target power spectrum')
                    assignin('base','target',target)
                    if corrmethod == 1
                        method = 'Pearson';
                    else
                        method = 'Spearman';
                    end
                    disp('>> Wait ...')
                    
                    tic
                    [corrCI,corr_h0,corry] = corrcoefslices_robust(data,target,orbit7,srm,pad1,sr1,sr2,srstep,adjust,red,nsim,plotn,slices,method,linlog);
                    
                    assignin('base','corrCI',corrCI)
                    assignin('base','corr_h0',corr_h0)
                    assignin('base','corry',corry)
                    
                    param0 = ['Target age is ',num2str(t1),' ka. Zero padding is ',num2str(pad), '. Freq. is ',num2str(f1),'-',num2str(f2),' cycles/kyr'];
                    param1 = ['Tested sedimentation rate step is ', num2str(srstep),' cm/kyr from ',num2str(sr1),' to ',num2str(sr2),' cm/kyr'];
                    param2 = ['Data: number of slices is ', num2str(slices),'. Number of simulations is ',num2str(nsim),'. Zero padding is ',num2str(pad1)];
                    if corrmethod == 1
                        param3 = ['Adjust: ', num2str(adjust),'. Remove red: ',num2str(red),'. Correlation method: Pearson'];
                    else
                        param3 = ['Adjust: ', num2str(adjust),'. Remove red: ',num2str(red),'. Correlation method: Spearman'];
                    end
                    param4 = ['Data: ',num2str(data(1,1)),' to ',num2str(data(end,1)),'m. Sampling rate: ', num2str(srm),'. Number of data points: ', num2str(npts)];
                    disp('')
                    disp(' - - - - - - - - - - - - - Summary - - - - - - - - - - - ')
                    disp(data_name);
                    disp(param0);
                    disp('Seven astronomical cycles are:')
                    disp(orbit7);
                    disp(param1);
                    disp(param2);
                    disp(param3);
                    disp(param4);
                    disp(' - - - - - - - - - - - - - - End - - - - - - - - - - - - ')
                    disp('>> Writing log file ...')
                    disp('>> Done')
                    toc
                    CDac_pwd;
                    % Log name
                    log_name = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-COCO-log',ext];
                    log_name_coco = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-COCO.fig'];
                    %log_file_exist = which(log_name); 
                    if exist([pwd,handles.slash_v,log_name]) || exist([pwd,handles.slash_v,log_name_coco])
                        for i = 1:100
                            log_name = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-COCO-log-',num2str(i),ext];
                            log_name_coco = [dat_name,'-',num2str(nsim),'sim-',num2str(slices),'slice-COCO-',num2str(i),'.fig'];
                            if exist([pwd,handles.slash_v,log_name]) || exist([pwd,handles.slash_v,log_name_coco])
                            else
                                break
                            end
                        end
                    end
                    savefig(log_name_coco) % save ac.fig automatically
                    % open and write log into log_name file
                    fileID = fopen(fullfile(dat_dir,log_name),'w+');
                    fprintf(fileID,'%s\n',' - - - - - - - - - - - - - Summary - - - - - - - - - - -');
                    fprintf(fileID,'%s\n',datestr(datetime('now')));
                    fprintf(fileID,'%s\n',log_name);
                    fprintf(fileID,'%s\n',param0);
                    fprintf(fileID,'%s\n','Seven astronomical cycles are:');
                    fprintf(fileID,'%s\n\n',mat2str(orbit7));
                    fprintf(fileID,'%s\n',param1);
                    fprintf(fileID,'%s\n',param2);
                    fprintf(fileID,'%s\n',param3);
                    fprintf(fileID,'%s\n',param4);
                    fprintf(fileID,'%s\n',' - - - - - - - - - - - - - - End - - - - - - - - - - - -');
                    fclose(fileID);
                    
                    d = dir; %get files
                    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
                    refreshcolor;
                    cd(pre_dirML);
                end
            end
        end
    end