function SWAgui(varargin)
% Acycle GUI for the Smoothed Window Averages power spectrum
%   Mingsong Li
%   Peking University
%   msli@pku.edu.cn
%   Oct. 5, 2023
%
%%
global freq
%% read data and unit type
MonZoom = 1;  % zoom GUI

%%
f = figure('Position', [100, 100, 600, 400] * MonZoom, 'MenuBar', 'none', 'NumberTitle', 'off', 'Resize', 'on');
handles.f = f;
set(f,'units','norm') % set location
set(0,'Units','normalized') % set units as normalized

%% Read handles
% read data and unit type
handles.data = varargin{1}.current_data;
handles.data_name = varargin{1}.data_name;
handles.unit = varargin{1}.unit;
handles.unit_type = varargin{1}.unit_type;
handles.listbox_acmain = varargin{1}.listbox_acmain;
handles.edit_acfigmain_dir= varargin{1}.edit_acfigmain_dir;
handles.val1 = varargin{1}.val1;
%%
%language
handles.lang_choice = varargin{1}.lang_choice;
handles.lang_id = varargin{1}.lang_id;
handles.lang_var = varargin{1}.lang_var;
lang_id = handles.lang_id;
%if handles.lang_choice > 0
    [~, locb1] = ismember('swa1',lang_id);
    swa1 = handles.lang_var{locb1};
    [~, locb1] = ismember('swa2',lang_id);
    swa2 = handles.lang_var{locb1};
    [~, locb1] = ismember('swa3',lang_id);
    swa3 = handles.lang_var{locb1};
    [~, locb1] = ismember('swa4',lang_id);
    swa4 = handles.lang_var{locb1};
    [~, locb1] = ismember('swa5',lang_id);
    swa5 = handles.lang_var{locb1};
    
    [~, locb1] = ismember('menu03',lang_id); 
    menu03 = handles.lang_var{locb1};  % Plot
    [~, locb1] = ismember('specm05',lang_id);
    specm05 = handles.lang_var{locb1};  % Settings
    [~, locb1] = ismember('main05',lang_id); 
    main05 = handles.lang_var{locb1};  % Minimum
    [~, locb1] = ismember('main06',lang_id); 
    main06 = handles.lang_var{locb1};  % Maximum
    [~, locb1] = ismember('main14',lang_id); 
    main14 = handles.lang_var{locb1};  % Frequency
    [~, locb1] = ismember('spectral15',lang_id); 
    spectral15 = handles.lang_var{locb1};  % Linear Y
    [~, locb1] = ismember('spectral16',lang_id); 
    spectral16 = handles.lang_var{locb1};  % Log Y
    [~, locb1] = ismember('spectral17',lang_id); 
    spectral17 = handles.lang_var{locb1};  % Log(freq)
    [~, locb1] = ismember('spectral18',lang_id); 
    spectral18 = handles.lang_var{locb1};  % X in period
    set(f,'Name',['Acycle: ',swa2,' (SWA)'])
%end
%% 第一个panel: Confidence levels
p1 = uipanel(f, 'Title', swa3, 'Position', [.02 .68 .96 .3]);
checkBoxStrs = {'90% chi2 CL', '95% chi2 CL', '99% chi2 CL', '99.9% chi2 CL', '5% FDR', '1% FDR', '0.1% FDR', '0.01% FDR'};
defaultVal = [0, 1, 1, 0, 1, 1, 0, 0];
for i = 1:8
    checkbox1x(i) = uicontrol(p1, 'Style', 'checkbox', 'String', checkBoxStrs{i}, 'Value', defaultVal(i),...
        'Units', 'normalized', 'Position', [mod(i-1, 4)/4, 1-ceil(i/4)*0.5, 0.24, 0.4],...
        'Callback', @refreshSWAfigure);
end

% 第二个panel: Plot Settings
p2 = uipanel(f, 'Title', [menu03,' ', specm05], 'Position', [.02 .37 .96 .3]);
text1 = uicontrol(p2, 'Style', 'text', 'String', [main05, ' ', main14],...
    'Units', 'normalized', 'Position', [0, 0.5, 0.24, 0.4]);
edit1 = uicontrol(p2, 'Style', 'edit', 'String', '0',...
    'Units', 'normalized', 'Position', [0.25, 0.5, 0.24, 0.4],...
    'Callback', @refreshSWAfigure);
text2 = uicontrol(p2, 'Style', 'text', 'String', [main06, ' ', main14],...
    'Units', 'normalized', 'Position', [0.5, 0.5, 0.24, 0.4]);
edit2 = uicontrol(p2, 'Style', 'edit', 'String', '100',...
    'Units', 'normalized', 'Position', [0.75, 0.5, 0.24, 0.4],...
    'Callback', @refreshSWAfigure);

checkbox21 = uicontrol(p2, 'Style', 'checkbox', 'String', spectral15, 'Value', 0,...
    'Units', 'normalized', 'Position', [0, 0, 0.24, 0.4],...
    'Callback', {@checkboxCallback, 2});
checkbox22 = uicontrol(p2, 'Style', 'checkbox', 'String', spectral16, 'Value', 1,...
    'Units', 'normalized', 'Position', [0.25, 0, 0.24, 0.4],...
    'Callback', {@checkboxCallback, 1});
checkbox23 = uicontrol(p2, 'Style', 'checkbox', 'String', spectral17, 'Value', 0,...
    'Units', 'normalized', 'Position', [0.5, 0, 0.24, 0.4],...
    'Callback', @refreshSWAfigure);
checkbox24 = uicontrol(p2, 'Style', 'checkbox', 'String', spectral18, 'Value', 0,...
    'Units', 'normalized', 'Position', [0.75, 0, 0.24, 0.4],...
    'Callback', {@checkboxCallback, 3});

% 第三个panel: Multiple Figures
p3 = uipanel(f, 'Title', [swa4,' ',specm05], 'Position', [.02 .02 .96 .3]);
checkboxStrs = {'1 Figure', '2 Figures', '3 Figures'};
for i = 1:3
    checkbox3x(i) = uicontrol(p3, 'Style', 'checkbox', 'String', checkboxStrs{i}, 'Value', i == 1,...
        'Units', 'normalized', 'Position', [(i-1)*1/3, 0, 1/3, 1],...
        'Callback', {@checkbox3xCallback, i});
end

%% 
data_r = handles.data; % read data
% sort, remove empty
data_r(any(isinf(data_r),2),:) = [];
data_r = sortrows(data_r);
diffx = diff(data_r(:,1));
if any(diffx(:) == 0)
    warndlg(swa5)
end
%%
[~, fName, ext] = fileparts(handles.data_name);
disp(' ********************  ')
disp(' ')
disp(['    ',fName, ext] )
disp (' ')
disp(' ********************  ')
[freq, power, swa, alphob, factoball, clfdr, chi2_inv_value] = specswafdr(data_r, 0); % main function SWA
[freqb, pow2,bayesprob]=specbayes(data_r, 0);  % main function Bays. prob.
set(edit1,'String',min(freq))
set(edit2,'String',max(freq))
%%
% set checkboxes
for i = 1:4
    if ~isnan(clfdr(1,i+1)) % not NaN
        set(checkbox1x(i+4),'Enable', 'on')
    else
        set(checkbox1x(i+4),'Value', 0)
        set(checkbox1x(i+4),'Enable', 'off')
    end
end

% refresh main window
pre_dirML = pwd;
ac_pwd = fileread('ac_pwd.txt');
if isdir(ac_pwd)
    cd(ac_pwd)
end

% move data file to current working folder
if isfile( which( 'SWA-Periodogram-Bayes-prob.dat'))
    date = datestr(now,30);
    curr_dir_full1 = which( 'SWA-Periodogram-Bayes-prob.dat');
    curr_dir_full2 = which('SWA-Spectrum-background-FDR.dat');
    
    curr_dir1 = fullfile(ac_pwd,[fName,'-Periodogram-Bayes-prob-',date,'.dat']);
    curr_dir2 = fullfile(ac_pwd,[fName,'-Spectrum-SWA-FDR-',date,'-.dat']);

    movefile(curr_dir_full1,curr_dir1);
    movefile(curr_dir_full2,curr_dir2);

    %  Save chi2 CL
    % 
    outfile = [fName,'-Spectrum-SWA-Chi2CL-',date,'.dat'];
    fidout = fopen(outfile, 'w');

    % Write out results
    fprintf(fidout, '%%Data filename = %s\n', [fName, ext]);
    fprintf(fidout, '%%Multiplication factor for 99.99%% Chi2 CL = %7.5f\n', chi2_inv_value(5));
    fprintf(fidout, '%%Multiplication factor for  99.9%% Chi2 CL = %7.5f\n', chi2_inv_value(4));
    fprintf(fidout, '%%Multiplication factor for   99%% Chi2 CL = %7.5f\n', chi2_inv_value(3));
    fprintf(fidout, '%%Multiplication factor for   95%% Chi2 CL = %7.5f\n', chi2_inv_value(2));
    fprintf(fidout, '%%Multiplication factor for   90%% Chi2 CL = %7.5f\n', chi2_inv_value(1));
    formatspec_410 = '%%     Frequency       Real_Power   SWA_background        90%%Chi2CL        95%%Chi2CL        99%%Chi2CL      99.9%%Chi2CL     99.99%%Chi2CL\n';
    formatspec_420 = '%15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f  %15.7f\n';
    nout = length(swa);
    for i = 1:nout
        if i == 1
            fprintf(fidout, formatspec_410); % Assuming you have format specifiers defined somewhere
        end
        fprintf(fidout, formatspec_420, freq(i), power(i), swa(i), swa(i)*chi2_inv_value(1), swa(i)*chi2_inv_value(2), swa(i)*chi2_inv_value(3), ...
            swa(i)*chi2_inv_value(4), swa(i)*chi2_inv_value(5));
    end
    fclose(fidout);

    % refresh main window
    d = dir; %get files
    set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
    % define some nested parameters
    pre  = '<HTML><FONT color="blue">';
    post = '</FONT></HTML>';
    address = pwd;
    d = dir; %get files
    d(1)=[];d(1)=[];
    listboxStr = cell(numel(d),1);
    ac_pwd_str = which('ac_pwd.txt');
    [ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
    fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
    T = struct2table(d);
    sortedT = [];
    sd = [];
    str=[];
    i=[];

    refreshcolor;
    cd(pre_dirML); % return to matlab view folder

else
    disp(['  Warning: no SWA data saved. Rerun the SWA.'])
end
%%
refreshSWAfigure
%%
    function refreshSWAfigure(src, event)%,freq,power,swa,chi2_inv_value,pow2,bayesprob)
        % Define refreshSWAfigure function here
        % define x axis value
        xvalue = freq;
        xvalueb = freqb;  %
        xlabel1 = ['Frequency (cycles/',handles.unit,')'];
        fmin = str2double(edit1.String); % read min and max freq for plot
        fmax = str2double(edit2.String); %
        if checkbox24.Value == 1  % x in period
            xvalue = 1./freq;
            xlabel1 = ['Period (',handles.unit,')'];
            xvalueb = 1./freqb;
            pmin = 1/fmax;
            pmax = 1/fmin;
            fmax = pmax;
            fmin = pmin;
        end
        %
        %for i = 1:3
            figHandle = findobj('Type', 'figure', 'Name', ['Acycle: SWA - ', fName, ext]);
            if isempty(figHandle)
                figHandle = figure('Name', ['Acycle: SWA - ', fName, ext]);
            else
                clf(figHandle);  % Clear figure content
                figure(figHandle); % Bring to focus
            end
            
            if checkbox3x(1).Value   % all in one figure
                subplot(3,1,1)
            end
            hold on
            %% plot FDR
            if checkbox1x(8).Value  % 0.01% FDR
                plot(xvalue, clfdr(:,5),'k-.','LineWidth',0.5,'DisplayName','0.01% FDR');
            end
            if checkbox1x(7).Value  % 0.1% FDR
                plot(xvalue, clfdr(:,4),'g-.','LineWidth',0.5,'DisplayName','0.1% FDR'); % 0.1% FDR
            end
            if checkbox1x(6).Value  % 1% FDR
                plot(xvalue, clfdr(:,3),'b--','LineWidth',0.5,'DisplayName','1% FDR'); % 1% FDR
            end
            if checkbox1x(5).Value  % 5% FDR
                plot(xvalue, clfdr(:,2),'r--','LineWidth',2,'DisplayName','5% FDR'); % 5% FDR
            end
            if checkbox1x(4).Value  % 99.9% chi2 CL
                plot(xvalue, swa * chi2_inv_value(4),'m-','LineWidth',0.5,'DisplayName','99.9% chi^2 CL'); % 99%
            end
            if checkbox1x(3).Value  % 99% chi2 CL
                plot(xvalue, swa * chi2_inv_value(3),'b-','LineWidth',0.5,'DisplayName','99% chi^2 CL'); % 99%
            end
            if checkbox1x(2).Value  % 95% chi2 CL
                plot(xvalue, swa * chi2_inv_value(2),'r-','LineWidth',2,'DisplayName','95% chi^2 CL'); % 95%
            end
            if checkbox1x(1).Value  % 90% chi2 CL
                plot(xvalue, swa * chi2_inv_value(1),'k--','LineWidth',0.5,'DisplayName','90% chi^2 CL'); % 90%
            end
            plot(xvalue, swa,'k-','LineWidth',2,'DisplayName','Background'); % SWA
            plot(xvalue, power,'k-','LineWidth',0.5,'DisplayName','Power'); % real power
            ylabel('Power')
            title('Lomb-Scargle Transform and SWA Confidence Levels')
            
            if checkbox21.Value  % linear Y
                set(gca,'YScale','linear');
            end
            if checkbox22.Value  % log Y
                set(gca,'YScale','log');
            end
            if checkbox23.Value  % linear Y
                set(gca,'XScale','log');
            else
                set(gca,'XScale','linear');
            end
            if checkbox24.Value == 1
                set(gca,'XDir','reverse')
            end
            xlabel(xlabel1)
            xlim([fmin, fmax])
            set(gca,'XMinorTick','on','YMinorTick','on')
            set(gcf,'Color', 'white')
            legend
            %hold off
            
            
            %% SWA
            if checkbox3x(1).Value  % All in 1 figure
                subplot(3,1,2)
            else 
                figHandle2 = findobj('Type', 'figure', 'Name', ['Acycle: SWA Periodogram - ', fName, ext]);
                if isempty(figHandle2)
                    figHandle2 = figure('Name', ['Acycle: SWA Periodogram - ', fName, ext]);
                else
                    clf(figHandle2);  % Clear figure content
                    figure(figHandle2); % Bring to focus
                end
                if checkbox3x(2).Value % in two figures
                    subplot(2,1,1)
                end
            end
            plot(xvalueb, pow2,'k-','DisplayName','Power')
            ylabel('Power')
            
            if checkbox21.Value  % linear Y
                set(gca,'YScale','linear');
            end
            if checkbox22.Value  % log Y
                set(gca,'YScale','log');
            end
            if checkbox23.Value  % linear Y
                set(gca,'XScale','log');
            else
                set(gca,'XScale','linear');
            end
            if checkbox24.Value == 1
                set(gca,'XDir','reverse')
            end
            xlabel(xlabel1)
            xlim([fmin, fmax])
            set(gca,'XMinorTick','on','YMinorTick','on')
            set(gcf,'Color', 'white')
            %% Bayesian Probability
            if checkbox3x(1).Value % All in 1 figure
                subplot(3,1,3)
            else
                if checkbox3x(2).Value % in two figures
                    subplot(2,1,2)
                else  % in three figures
                    figHandle3 = findobj('Type', 'figure', 'Name', ['Acycle: SWA Bayesian Probability - ', fName, ext]);
                    if isempty(figHandle3)
                        figHandle3 = figure('Name', ['Acycle: SWA Bayesian Probability - ', fName, ext]);
                    else
                        clf(figHandle3);  % Clear figure content
                        figure(figHandle3); % Bring to focus
                    end
                end
            end
            plot(xvalueb, bayesprob,'k-','DisplayName','Bayesian Probability')
            ylabel('Bayesian probability')
            ylim([min(bayesprob), 1.1])

            if checkbox21.Value  % linear Y
                set(gca,'YScale','linear');
            end
            if checkbox22.Value  % log Y
                set(gca,'YScale','log');
            end
            if checkbox23.Value  % linear Y
                set(gca,'XScale','log');
            else
                set(gca,'XScale','linear');
            end
            if checkbox24.Value == 1
                set(gca,'XDir','reverse')
            end
            xlabel(xlabel1)
            xlim([fmin, fmax])
            set(gca,'XMinorTick','on','YMinorTick','on')
            set(gcf,'Color', 'white')
            hold off
        %end
    end
%% how many figures
    function checkboxCallback(src, event, id)
        switch id
            case 1
                checkbox21.Value = 0;
                checkbox22.Value = 1;
            case 2
                checkbox21.Value = 1;
                checkbox22.Value = 0;
            case 3
                if checkbox24.Value == 1
                    checkbox23.Value = 1;
                    checkbox24.Value = 1;
                end
        end
        refreshSWAfigure(src, event);
    end
%%
    function checkbox3xCallback(src, event, id)
        set(checkbox3x, 'Value', 0);
        checkbox3x(id).Value = 1;
        refreshSWAfigure(src, event);
    end
end
