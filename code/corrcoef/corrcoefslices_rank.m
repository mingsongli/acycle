function [corrCI,corr_h0,corry] = corrcoefslices_rank(dat,target,orbit7,dt,pad,sr1,sr2,srstep,adjust,red,nsim,plotn,slices,method,fmaxdata,main_unit_selection)
% Modify from corrcoefsig.m, but replace display with a function of slices
% INPUT
%   dat: 2 column time series of depth and value. Unit of depth must be m
%           The first column must be evenly spaced
%   target: target series, generated from gentarget.m
%   orbit7: 7 orbital target frequencies
%   dt: sample rates of input series (the dat)
%   pad: zero-padding of periodogram of input series: dat. default = 5000
%   sr1: begining sedimentation rates to be estimated, unit must be cm/kyr
%   sr2: end sedimentation rates to be estimated for correlation and H0,
%           unit must be cm/kyr
%   srstep: step of sedimentation rates. unit must be cm/kyr
%       Note: (sr2-sr1)/srstep may be < 200 for a faster estimation
%   adjust:
%   red: 1 = remove AR1 noise
%   nsim: number of simulation for H0 significant level of correlation coefficient
%   plotn: 1 = plot results. else = no plot
% 
% OUTPUT
%   corrCI:     6-column series; 
%                   c1 = tested sedimentation rates
%                   c2 = correlation coefficient for each sed. rates
%                   c3 = p-value of c2
%                   c4 = lower limit of 95% confidence interval of c2
%                   c5 = upper limit of 95% confidence interval of c2
%                   c6 = nmi
%   corr_h0:    3-column series
%                   c1 = Monte carlo simulation significant level of the null
%                       hypothesis (H0) that there is no orbital forcing
%                       with dat series
%                   c2 = H0 SL X correlation coefficient
%                   c3 = H0 SL X (correlation coefficient - 0.3)
% 
% CALLS FOR
%   targetrebuilt
%   theoredar1ML
%   findpeaks
%   cyclecorr
%   randspec_sin
%   
%   Mingsong Li, June 2017 @ Penn State
%   update Jan 18, 2023 for language plot
%%
if nargin > 16
    error('Too many input arguments')
    return;
end
if nargin < 14
    method = 'Pearson';
    if nargin < 13
        slices = 1;
        if nargin < 12
        plotn = 1;
            if nargin < 11
                nsim = 0;  % no Monte Carlo simulation for confidence level estimation
                if nargin < 10
                    red = 1;
                    if nargin < 9
                        adjust = 1;
                        if nargin < 8
                            srstep = 0.2;  % sedimentation rate is 0.2 cm/kyr
                            if nargin < 7
                                sr2 = 20;   % default sed. rate from 0.1 to 20 cm/kyr
                                if nargin < 6
                                    sr1 = 0.1;  % default sed. rate from 0.1 to 20 cm/kyr
                                    if nargin < 5
                                        pad = 5000; % zero-pading = 5000
                                        if nargin < 4
                                            %dt = dat(2,1)-dat(1,1);
                                            dt = median(diff(dat(:,1)));
                                            if nargin < 3
                                                error('Too few input arguments')
                                                return;
                                            end
                                        end
                                    end
                                end
                            end
                        end    
                    end
                end
            end
        end
    end
end
display = 1;  % show simulation steps

%% Slice
if isreal(slices) && slices > 0 && ~mod(slices,1)
   if slices > 1
       %dat_slice = data_slices(dat,slices);  % remove mean value; cut into slices
       [dat_slice, datanewMean] = data_slices(dat, slices);    % cut into slices; calculate the mean of them
       dat_demean = [dat(:,1),detrend(dat(:,2),0)];
   else
       time = dat(:,1);
       %value = (dat(:,2)-mean(dat(:,2)))/std(dat(:,2));  % standardized
       value = dat(:,2);
       dat_slice = [time,detrend(value,0)];  % subtract mean value
       dat_demean = dat_slice;
       datanewMean = dat_slice;
   end

else
    disp('Error: Number of split slices must be a real, positive AND integer number.')
    return;
end
%% For acycle language version (2.6 and after)
% language
lang_choice = load('ac_lang.txt');
langdict = readtable('langdict.xlsx');
lang_id = langdict.ID;
lang_var = table2cell(langdict(:, 2 + lang_choice));

[~, ec79] = ismember('ec79',lang_id);

[~, ec80] = ismember('ec80',lang_id);
[~, ec81] = ismember('ec81',lang_id);
[~, ec82] = ismember('ec82',lang_id);
[~, ec83] = ismember('ec83',lang_id);
[~, ec84] = ismember('ec84',lang_id);
%% data
dataf =[];
datap =[];
for j = 1: slices
    dat_nyq = 1/(2*dt);   % Nyquist
    dat_ray = 1/(length(dat_slice(:,1)) * dt);  % rayleigh
    [p,f] = periodogram(dat_slice(:,2*j),[],pad,1/dt);  % power of dat
    % remove AR1 noise
    if red == 2
        [theored]=theoredar1ML(dat(:,2),f,mean(p),dt);
        p = p ./ theored;
        p = p - 1;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 1
        [theored]=theoredar1ML(dat(:,2),f,mean(p),dt);
        p = p - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif red == 3
        % robust
        theored = redconf_any(f,p,dt,0.25,2);
        p = p - theored;
        p(p<0) = 0;   % power removing AR(1) noise
    elseif and (red >= 50, red < 100)
        [theored]=theoredar1ML(dat(:,2),f,mean(p),dt);
        facchired = 2*gammaincinv(red/100,2)/(2*2);
        tabtchired = theored * facchired;
        p = p ./ tabtchired;
        p = p - 1;
        p(p<0) = 0;   % power removing AR(1) noise
    end
    dataf(:,j) = f;
    datap(:,j) = p;
end
    data = [f,mean(datap,2)];
% plot power spectra
    if plotn == 1
        ax2 = subplot(2,1,2); 
        plot(ax2,f,data(:,2),'r','LineWidth',1);
        hold on
        if slices > 1
            plot(ax2,f,datap,'LineWidth',.3);
        end
        
        xlim(ax2,[0, fmaxdata])
        
        set(ax2,'XMinorTick','on','YMinorTick','on')
        if or(lang_choice == 0, main_unit_selection == 0)
            xlabel(ax2,'Frequency (cycle/m)');
            ylabel(ax2,'Power');
            title(ax2,'Data power spectrum');
            legend(ax2,'Power spectrum of data series')
        else
            %%
            [~, main14] = ismember('main14',lang_id); % freq
            [~, main46] = ismember('main46',lang_id); % power
            [~, main02] = ismember('main02',lang_id); % data
            [~, menu107] = ismember('menu107',lang_id);

            xlabel(ax2,[lang_var{main14},' (1/m)']);
            ylabel(ax2,lang_var{main46});
            title(ax2,[lang_var{main02},' ',lang_var{menu107}]);
            %legend(ax2,'Power spectrum of data series')
        end
    % save data to workspace
        assignin('base','dataf',dataf)
        assignin('base','datap',datap)
        assignin('base','data',data)
    end
%% target
target_real= target;  % save target frequencies-power series
targetnew = targetrebuilt(target);  % get peaks from given target
targetf = targetnew(:,2);
targetp = targetnew(:,1);
%  Number of peaks in the power spectrum of real data series?
[pks,~] = findpeaks(data(:,2));
npks = length(pks);
assignin('base','targetnew',targetnew)

%% sr0 - a key boundary sedimentary rate
f_nyq_target = target_real(length(target_real(:,1)),1);
sr0 = f_nyq_target * 100/dat_nyq;
assignin('base','sr0',sr0)
%% correlation coefficient and its 95% significant level

[corrxch,corry_rch,corrpych,nmi] = ...
    cyclecorr(data,targetf,targetp,target_real,orbit7,dat_ray,sr1,sr2,srstep,sr0,adjust,method);
corrCI = [corrxch,corry_rch,corrpych,nmi];

%% simulation:  corry (sr x nsim) correlation coefficient
sr_range = sr1:srstep:sr2;
mpts = length(sr_range);
%critical = 100/mpts;% critical significance level by Steve Meyers

if nsim > 0
    % Waitbar
    if lang_choice == 0
        hwaitbar = waitbar(0,'Monte Carlo processing ... [CTRL + C to quit]',...    
           'WindowStyle','modal');
    else
        hwaitbar = waitbar(0,lang_var{ec79},...    
           'WindowStyle','modal');
    end
    hwaitbar_find = findobj(hwaitbar,'Type','Patch');
    set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
    setappdata(hwaitbar,'canceling',0)
    steps = 100;
    % step estimation for waitbar
    nmc_n = round(nsim/steps);
    waitbarstep = 1;
    waitbar(waitbarstep / steps)
    %% Monte Carlo simulation
    % use all data, calculate rho of robust AR1
    
    rhoM = calculateRhoM(dat);

    % use the first slice to generate many periodogram power spetra; remove red noise
    % using user-defined methods
    [f, pMC] = redNoisePeriodogramMC( ...
        datanewMean, rhoM, nsim, red, pad, ...
        'BatchSize', 1000, ...
        'UseParallel', false);
    
    corry = zeros(mpts,nsim);
    for i = 1: nsim
        % simplified MC
        %randspectrum = randspec_sin(f,npks,dat_ray);
        %sim_spectum = [f,randspectrum];
        % robust rho
        %[prand,frand] = randpermperiodogram(dat_demean,dt,pad); % Mingsong Li, 20180417
        %sim_spectum = [frand,prand]; % Mingsong Li, 20180417
        
        sim_spectum = [f, pMC(:,i)];
        
        corryi = cyclecorrsig(sim_spectum,targetf,targetp,target_real,orbit7,dat_ray,sr1,sr2,srstep,sr0,adjust,method);
        if display == 1
            if rem(i,20) == 0
                disp(['>> Step 2: Simulation ',num2str(i),' of ',num2str(nsim)])
            end
        end
        corry(:,i) = corryi;

        if rem(i,nmc_n) == 0
            waitbarstep = waitbarstep+1; 
            if waitbarstep > steps; waitbarstep = steps; end
            pause(0.001);%
            waitbar(waitbarstep / steps)
        end
        if getappdata(hwaitbar,'canceling')
            break
            %delete(hwaitbar)
        end
    end
    if ishandle(hwaitbar)
        close(hwaitbar);
    end
    assignin('base','sim_spectum',sim_spectum)
    %% MC results
    
    corry_sim_sort = sort(corry,2);
    corrlength = length(corry_rch);  % number of tested sed. rate
    corry_per = zeros(corrlength,1);
    
    for i = 1: corrlength
        corry_r1 = corry_rch(i);
        corry_sim_sort1 = corry_sim_sort(i,:);
        corry_per(i) = (100 - invprctile(corry_sim_sort1, corry_r1))/100;
    end
    

    %% confidence interval estimation for correlation coefficient
    
    corr_h0 = corry_per;  % percentile of the value
    
    orbitn = length(orbit7);

    corr_h0(:,2) = (orbitn-corrCI(:,end));   % number of orbits involved
    if plotn == 1
        
        figure;
        set(gcf,'color','w');
        
        ax1 = subplot(3,1,1);
        plot(ax1,corrxch,corry_rch,'r','LineWidth',1);
        if or(lang_choice == 0, main_unit_selection == 0)
            xlabel(ax1,'Sedimentation rate (cm/kyr)')
            title(ax1,'Correlation coefficient')
        else
            xlabel(ax1,lang_var{ec80})
            title(ax1,lang_var{ec81})
        end
        ylabel(ax1,'\rho')
        set(ax1,'XMinorTick','on','YMinorTick','on')
        
        % plot H0 test of Monte carlo simulation
        ax2 = subplot(3,1,2);
        corry_per1 = corry_per;
        corry_per1(corry_per1 > 0.15) = 0.15;
        plot(ax2,corrxch,corry_per1,'r','LineWidth',1); 
        if or(lang_choice == 0, main_unit_selection == 0)
            xlabel(ax2,'Sedimentation rate (cm/kyr)')
            ylabel(ax2,'p-value')
            title(ax2,'Null hypothesis')
        else
            xlabel(ax2,lang_var{ec80})
            ylabel(ax2,lang_var{ec82})
            title(ax2,lang_var{ec83})
        end        
        ylim(ax2,[-0.01,0.15])
        line([sr1, sr2],[.10, .10],'LineStyle',':','Color','k')
        line([sr1, sr2],[.05, .05],'LineStyle',':','Color','k')
        line([sr1, sr2],[.01, .01],'LineStyle','--','Color','k')
        line([sr1, sr2],[.001, .001],'LineStyle',':','Color','k')
        set(ax2,'Ydir','reverse')
        set(ax2,'XMinorTick','on','YMinorTick','on')
        
        % Plot number of orbital cycles
        ax3 = subplot(3,1,3);
        plot(ax3,corrxch,corr_h0(:,2),'b','LineWidth',1);
        
        if or(lang_choice == 0, main_unit_selection == 0)
            xlabel(ax3,'Sedimentation rate (cm/kyr)')
            title(ax3,'Number of contributing astronomical parameters')
        else
            xlabel(ax3,lang_var{ec80})
            title(ax3,lang_var{ec84})
        end
        ylabel(ax3,'#')
        ylim(ax3,[0 orbitn+0.5])
        set(ax3,'XMinorTick','on','YMinorTick','on')
    end
else
    corr_h0 = zeros(mpts,1);
    corry = [];
end

%%
function [datanew, datanewMean] = data_slices(dat, slices)
% data_slices Divide a time series into equal-duration slices.
%
%   [datanew, datanewMean] = data_slices(dat, slices)
%
% INPUT:
%   dat    - Two-column time series:
%            dat(:,1): time
%            dat(:,2): data values
%
%   slices - Number of equal-duration slices.
%
% OUTPUT:
%   datanew - Matrix containing all processed slices.
%             Each slice occupies two columns:
%
%             datanew(:,2*i-1): original time of slice i
%             datanew(:,2*i)  : standardized and demeaned values
%
%             Shorter slices are padded with NaN.
%
%   datanewMean - Two-column mean series:
%
%             datanewMean(:,1): mean relative time within the slices
%             datanewMean(:,2): row-wise mean of all processed slices
%
%   The averaging is performed according to sample position within each
%   slice. It therefore assumes that all slices have approximately the
%   same sampling interval.

    %% Validate inputs

    validateattributes(dat, {'numeric'}, ...
        {'2d', 'ncols', 2, 'nonempty', 'real'}, ...
        mfilename, 'dat', 1);

    validateattributes(slices, {'numeric'}, ...
        {'scalar', 'integer', 'positive', 'finite'}, ...
        mfilename, 'slices', 2);

    %% Remove invalid rows and sort data by time

    validRows = all(isfinite(dat), 2);
    dat = dat(validRows, :);

    if isempty(dat)
        error('data_slices:NoValidData', ...
            'The input data do not contain valid finite values.');
    end

    dat = sortrows(dat, 1);

    timeAll = dat(:,1);

    if timeAll(end) <= timeAll(1)
        error('data_slices:InvalidTime', ...
            'The time range must be greater than zero.');
    end

    %% Define slice boundaries

    sliceBoundary = linspace( ...
        timeAll(1), timeAll(end), slices + 1);

    sliceData = cell(slices, 1);
    relativeTime = cell(slices, 1);
    sliceLength = zeros(slices, 1);

    %% Extract and process each slice

    for i = 1:slices

        % Use half-open intervals for all slices except the last one.
        % This prevents a boundary point from appearing in two slices.
        if i < slices
            index = timeAll >= sliceBoundary(i) & ...
                    timeAll <  sliceBoundary(i + 1);
        else
            index = timeAll >= sliceBoundary(i) & ...
                    timeAll <= sliceBoundary(i + 1);
        end

        dataInterval = dat(index, :);

        if isempty(dataInterval)
            sliceData{i} = zeros(0, 2);
            relativeTime{i} = zeros(0, 1);
            continue
        end

        time = dataInterval(:,1);
        value = dataInterval(:,2);

        %% Standardize the values within the current slice

        valueStd = std(value);

        if numel(value) > 1 && valueStd > 0
            value = (value - mean(value)) ./ valueStd;
        else
            % A single-point or constant slice has no variability
            value = zeros(size(value));
        end

        % Remove any residual constant offset
        value = detrend(value, 0);

        %% Store the processed slice

        sliceData{i} = [time, value];

        % Relative time is required for aligning different slices
        relativeTime{i} = time - time(1);

        sliceLength(i) = length(time);

    end

    %% Combine all slices into one matrix

    maximumLength = max(sliceLength);

    if maximumLength == 0
        datanew = [];
        datanewMean = [];
        return
    end

    % NaN padding prevents missing values from influencing the mean
    datanew = nan(maximumLength, 2 * slices);
    relativeTimeMatrix = nan(maximumLength, slices);

    for i = 1:slices

        currentLength = sliceLength(i);

        if currentLength == 0
            continue
        end

        datanew(1:currentLength, 2*i-1:2*i) = ...
            sliceData{i};

        relativeTimeMatrix(1:currentLength, i) = ...
            relativeTime{i};

    end

    %% Calculate the mean series

    % Extract the processed value column from every slice
    valueMatrix = datanew(:, 2:2:end);

    % Calculate the mean value at each relative sample position
    meanValue = mean(valueMatrix, 2, 'omitnan');

    % Calculate a representative relative time coordinate
    meanRelativeTime = mean(relativeTimeMatrix, 2, 'omitnan');

    % Remove rows for which no slice contains data
    validMeanRows = any(isfinite(valueMatrix), 2);

    datanewMean = [ ...
        meanRelativeTime(validMeanRows), ...
        meanValue(validMeanRows)];

%end