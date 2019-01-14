%
%smoothwin = .2; % 20% smooth median window
%linlog = 2; % fit to median-smoothing spectrum. Default fits to log S(f)
%           1 = a linear fit to S(f); 2 = a fit to log S(f).
%
% need
%
% clear;clc
% dat=load('Example-WayaoCarnianGR0.txt');
% age= 230000;
% age_obl = 41 - 0.0332 * age/1000;
% age_p1 = 22.43 - 0.0108 * age/1000;
% age_p2 = 23.75 - 0.0121 * age/1000;
% age_p3 = 19.18 - 0.0079 * age/1000;
% orbit7 = [405 125 95 age_obl age_p2 age_p1 age_p3];
% 
% sr1=1;sr2=40;srstep=.2;
% handles.f2=.07; pad=2000;nsim = 1000;
% smoothwin=.2;linlog=2;red=2;slices=1;
% target = gentarget(4,230000,232000,0,.07,1,.6,1,pad,1);

age= 247000;
age_obl = 41 - 0.0332 * age/1000;
age_p1 = 22.43 - 0.0108 * age/1000;
age_p2 = 23.75 - 0.0121 * age/1000;
age_p3 = 19.18 - 0.0079 * age/1000;
orbit7 = [405 125 95 age_obl age_p2 age_p1 age_p3];

sr1=1;sr2=15;srstep=.1;
handles.f2=.07; pad=1500;nsim = 1000;
smoothwin=.2;linlog=2;red=2;slices=1;
target = gentarget(4,246000,248000,0,.07,1,.6,1,pad,1);

% clear;clc
% dat=load('Example-SvalbardPETM-logFe-rsp0.2-31.99-LOWESS.txt');
% age= 55000;
% sr1=1;sr2=40;srstep=.2;
% handles.f2=.06; pad=2000;nsim = 500;
% smoothwin=.2; linlog=2; red=2; slices=1;
% target = gentarget(4,54000,56000,0,.06,1,.5,1,pad,1);
% 
% age_obl = 41 - 0.0332 * age/1000;
% age_p1 = 22.43 - 0.0108 * age/1000;
% age_p2 = 23.75 - 0.0121 * age/1000;
% age_p3 = 19.18 - 0.0079 * age/1000;
% orbit7 = [405 125 95 age_obl age_p2 age_p1 age_p3];
% 

% clear;clc
% dat=load('Example-LateTriassicNewarkDepthRank.txt');
% age= 204000;
% sr1=1;sr2=40;srstep=.2;
% handles.f2=.07; pad=4000;nsim = 1000;
% smoothwin=.2; linlog=2; red=2; slices=1;
% target = gentarget(4,202000,206000,0,.07,1,.5,1,pad,1);
% 
% age_obl = 41 - 0.0332 * age/1000;
% age_p1 = 22.43 - 0.0108 * age/1000;
% age_p2 = 23.75 - 0.0121 * age/1000;
% age_p3 = 19.18 - 0.0079 * age/1000;
% orbit7 = [405 125 95 age_obl age_p2 age_p1 age_p3];


% dat=load('lfall-Linear.txt');
% age=8000;
% age_obl = 41 - 0.0332 * age/1000;
% age_p1 = 22.43 - 0.0108 * age/1000;
% age_p2 = 23.75 - 0.0121 * age/1000;
% age_p3 = 19.18 - 0.0079 * age/1000;
% orbit7 = [405 125 95 age_obl age_p2 age_p1 age_p3];
% sr1=4;sr2=30;srstep=.2;
% handles.f2=.06; pad=2000;nsim = 1000;
% smoothwin=.2;linlog=2;red=2;slices=1;
% target = gentarget(4,6000,9000,0,.06,1,.6,1,pad,1);

% sr1, sr2, srstep, dat, handles.f2, pad, smoothwin, linlog, red,
% handles.f2: testing max freq

leng_x = sr1:srstep:sr2;  % tested sed. rate series
srn = length(leng_x);  % tested sed. rates number
% data in m
depth = dat(:,1);  % frequency of data
value = dat(:,2);  % power of data
dt = median(diff(depth));
display = 1;  % show simulation steps
%% target
lax = target(:,1); % frequency of target
%% sr0 - a key boundary sedimentary rate
dat_nyq = 1/(2*dt);   % Nyquist
f_nyq_target = target(end,1);
sr0 = f_nyq_target * 100/dat_nyq;
%% COCO
if isreal(slices) && slices > 0 && ~mod(slices,1)
    %% slice??
    if slices > 1
        dat_slice = data_slices(dat,slices);  % remove mean value; cut into slices
    else
        dat_slice = [depth,detrend(value,0)];
    end
    rayleigh = 1/(dt*length(dat_slice(:,1)));
    
    corrx = zeros(srn,1);
    corry = zeros(srn,1);
    corrpy = zeros(srn,1);
    corrpks = zeros(srn,1);
    nmi = zeros(srn,1);
    
    %% each sed. rates testing
    for i = 1:srn
        disp(['>> ',num2str(i),' of ',num2str(srn)])
        sri = leng_x(i);
        %%
        dataf =[];
        datap =[];
        
        for j = 1: slices
            
            time = depth * 100 / sri;
            dtime = dt * 100 / sri;
            [p,f] = periodogram(dat_slice(:,2*j),[],pad,1/dtime);
            pxx = p(f<=handles.f2);
            ft = f(f<=handles.f2);
            fn = min(handles.f2,max(ft));

            smoothn = round(smoothwin * length(pxx));
            pxxsmooth = moveMedian(pxx,smoothn);
            rho =rhoAR1(value);
            s0 = mean(pxxsmooth);
            %theored = s0 * (1-rho^2)./(1-(2.*rho.*cos(pi.*ft./fn))+rho^2);
            % Red-noise background fit
            % Get the best fit values of rho and s0 (see eq. (2) in Mann and Lees,
            % 1996).
            % Here we use a naive grid search method.
            [rhoM, s0M] = minirhos0(s0,fn,ft,pxxsmooth,linlog);
            theored1 = s0M * (1-rhoM^2)./(1-(2.*rhoM.*cos(pi.*ft./fn))+rhoM^2);

            % remove AR1 noise
            if red == 1
                if linlog == 2
                    pxx = log(pxx) ./ log(theored1);
                else
                    pxx = pxx ./ theored1;
                end
                pxx = pxx - 1;
                pxx(pxx<0) = 0;   % power removing AR(1) noise
            elseif red == 2
                if linlog == 2
                    pxx = log(pxx) - log(theored1);
                else
                    pxx = pxx - theored1;
                end
                pxx(pxx<0) = 0;   % power removing AR(1) noise
            end
            dataf(:,j) = ft;
            datap(:,j) = pxx;
        end
        
        data = [ft,mean(datap,2)];
        %figure; plot(data(:,1),data(:,2));title('robust periodogram')
        
        %%  Number of peaks in the power spectrum of real data series?
        [pks,~] = findpeaks(data(:,2));
        corrpks(i) = length(pks);

        %%
        % Set empty vector for corry, corrpy, corrlo, corrup, and nmi
        % if test sedimentation rates cover the key sed. rate of sr0
        if sri < sr0
            dat2=data(:,2);
            la = target(:,2);
            nm = norbitsrobust([lax,la],ft,data(:,2),orbit7,rayleigh,sri);
            lai = interp1(lax,la,ft);  %  increase number of freq. from La target
            [r,p] = corrcoef(lai(~isnan(lai)),dat2(~isnan(lai)));
            corry(i)=r(2,1);
            corrpy(i)=p(2,1);
            nmi(i) = nm;
        elseif sri >= sr0
            yi = interp1(ft,data(:,2),lax); % decrease number of freq. of data
            la= (target(:,2)-mean(target(:,2)))/std(target(:,2));
            nm = norbitsrobust([lax,la],ft,data(:,2),orbit7,rayleigh,sri);
            [r,p] = corrcoef(la(~isnan(yi)),yi(~isnan(yi)));
            corry(i)=r(2,1);
            corrpy(i)=p(2,1);
            nmi(i) = nm;
        end
        corrx(i) = sri;
    end
end

%% Plot target and data

%
if nsim == 0
    figure;
    subplot(2,1,1)
    ax1 = plot(corrx,corry,'r','LineWidth',1);
    xlabel('Sedimentation rate (cm/kyr)')
    ylabel('\rho')
    title('Correlation coefficient')
    xlim([sr1 sr2])
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    subplot(2,1,2)
    ax3 = plot(corrx,7-nmi,'b','LineWidth',1);
    xlabel('Sedimentation rate (cm/kyr)')
    ylabel('#')
    title('Number of contributing astronomical parameters')
    ylim([0 7.5]);xlim([sr1 sr2])
    set(gca,'XMinorTick','on','YMinorTick','on')
end

%% simulation
if nsim > 0
    dtMC = 1/handles.f2/length(depth);

    corrMC = zeros(nsim,1);
    corrcl = zeros(srn,1);
    
    for i = 1:srn
        disp(['>> ',num2str(i),' of ',num2str(srn),' tested sedimentation rates'])
        pksn = corrpks(i);
        for k = 1 : nsim;
        % disp(['>> ',num2str(k),' of ',num2str(nsim),' Monte Carlo simulations'])
        % pksn: n peaks at sed. rate i
            y = zeros(length(depth),pksn);
            fp_rand = rand(pksn,2);
            for j = 1 : pksn
                A = fp_rand(j,1);
                T = fp_rand(j,2)/handles.f2;
                y(:,j) = A * sin(2*pi/T*depth);
            end
            ym = mean(y,2);
            %figure; plot(ym)
            [pMC,fMC] = periodogram(ym,[],pad,1);
            fMC = fMC/0.5*handles.f2;
            %figure; plot(fMC,pMC)
            sri = leng_x(i);
            if sri < sr0
                lai = interp1(target(:,1),target(:,2),fMC);  %  increase number of freq.
                [r,~] = corrcoef(lai(~isnan(lai)),pMC(~isnan(lai)));
            elseif sri >= sr0
                yi = interp1(fMC,pMC,target(:,1)); % decrease number of freq. of data
                la= target(:,2);
                [r,~] = corrcoef(la(~isnan(yi)),yi(~isnan(yi)));
            end
            corrMC(k,i)=r(2,1);
        end
    end
% save data
    for i = 1: srn
        corri = corry(i);
        corriMC = corrMC(:,i);
        corrcl(i) = 1-length(corriMC(corriMC<=corri))/nsim;
        if corrcl(i) == 0;
            corrcl(i) = 1/(nsim+1);
        end
    end
end

if nsim > 0
    figure;
    subplot(3,1,1)
    ax1 = plot(corrx,corry,'r','LineWidth',1);
    xlabel('Sedimentation rate (cm/kyr)')
    ylabel('\rho')
    title('Correlation coefficient')
    xlim([sr1 sr2])
    set(gca,'XMinorTick','on','YMinorTick','on')

    subplot(3,1,3)
    ax3 = plot(corrx,7-nmi,'b','LineWidth',1);
    xlabel('Sedimentation rate (cm/kyr)')
    ylabel('#')
    title('Number of contributing astronomical parameters')
    ylim([0 7.5]);xlim([sr1 sr2])
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    subplot(3,1,2)
    ax2 = plot(corrx,corrcl,'r','LineWidth',1);
    xlabel('Sedimentation rate (cm/kyr)')
    ylabel('H_0 significance level')
    title('Null hypothesis')
    set(gca,'Ydir','reverse')
    set(gca, 'YScale', 'log')
    set(gca,'XMinorTick','on','YMinorTick','on')
    line([sr1, sr2],[.10, .10],'LineStyle',':','Color','k')
    line([sr1, sr2],[.05, .05],'LineStyle',':','Color','k')
    line([sr1, sr2],[.01, .01],'LineStyle','--','Color','k')
    line([sr1, sr2],[.001, .001],'LineStyle',':','Color','k')
    ylim([0.5*min(corrcl) 1]);xlim([sr1 sr2])
end