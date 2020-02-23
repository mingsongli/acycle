
if get(handles.checkbox_robust,'value')
    %figure;
    clf;
    set(gcf,'Color', 'white')
    ft0 = redconfAR1(:,1);
    %disp(ft0(1))
    pt0 = 1./ft0;
    pxx0 = redconfAR1(:,2);
    pxxsmooth0 = redconfAR1(:,3);
    ft     = redconfML96(:,1);
    pt     = 1./ft;
    theored1 = redconfML96(:,3);
    chi90  = redconfML96(:,4);
    chi95  = redconfML96(:,5);
    chi99  = redconfML96(:,6);
    chi999 = redconfML96(:,7);

    semilogy(pt0,pxx0,'k')
    hold on; 
    semilogy(pt0,pxxsmooth0,'m-.');
    semilogy(pt,theored1,'k-','LineWidth',2);
    semilogy(pt,chi90,'r-');
    semilogy(pt,chi95,'r--','LineWidth',2);
    semilogy(pt,chi99,'b-.');
    semilogy(pt,chi999,'g--','LineWidth',1);
    hold off
    ylabel('Power')
    smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
    legend('Power',smthwin,'Robust AR(1) median',...
    'Robust AR(1) 90%','Robust AR(1) 95%','Robust AR(1) 99%','Robust AR(1) 99.9%')

    xlim([1/fmax, pt(3)]);
    set(gca, 'XDir','reverse')
    xlabel(['Period (',num2str(unit),')']) 
    title([num2str(nw),'\pi-MTM-Robust-AR(1): \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M)])
    set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gcf,'Color', 'white')
    if handles.linlogY == 1;
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
end

if get(handles.checkbox_ar1_check,'value')
    %figdata = figure;
    clf;
    set(gcf,'Color', 'white')
    [fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconftabtchi(datax,nw,dt,nzeropad,2);
    pt = 1./fd;
    plot(pt,po,'k-','LineWidth',1);
    hold on; 
    plot(pt,theored,'k-','LineWidth',2);
    plot(pt,tabtchi90,'r-','LineWidth',1);
    plot(pt,tabtchi95,'r--','LineWidth',2);
    plot(pt,tabtchi99,'b-.','LineWidth',1);
    plot(pt,tabtchi999,'g--','LineWidth',1);
    xlim([1/fmax, pt(3)]);
    set(gca, 'XDir','reverse')
    title([num2str(nw),'\pi MTM classic AR1',' ','; Sampling rate = ',num2str(dt),' ', unit])
    legend('Power','AR1','90%','95%','99%','99.9%')
    xlabel(['Period (',num2str(unit),')']) 
    ylabel('Power ')
    if handles.linlogY == 1
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
end

if and(get(handles.checkbox_ar1_check,'value') == 0, get(handles.checkbox_robust,'value') == 0)
    %figdata = figure; 
    clf;
    set(gcf,'Color', 'white')
    pt1 = 1./fd1;
    plot(pt1,po,'LineWidth',1); 
    xlabel(['Period (',num2str(unit),')']) 
    ylabel('Power ')
    title([num2str(nw),' \pi MTM method',' ','; Sampling rate = ',num2str(dt),' ', unit])
    set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    xlim([1/fmax, pt1(3)]);
    set(gca, 'XDir','reverse')
    if handles.linlogY == 1
        set(gca, 'YScale', 'log')
    else
        set(gca, 'YScale', 'linear')
    end
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
end

if handles.check_ftest_value
    [freq,ftest,fsig,Amp,Faz,Sig,Noi,dof,wt]=ftestmtmML(data,nw,padtimes,0);
    pt = 1./freq;
    figure;
    subplot(3,1,1)
    
    plot(pt, Amp,'color',[0, 0.4470, 0.7410],'LineWidth',1.5)
    title(['Amplitude, F-test & significance level : ', num2str(nw), '\pi'])
    ylabel('Amplitude')
    xlim([1/fmax, pt(3)]);set(gca, 'XDir','reverse')
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    subplot(3,1,3)
    fsigsh = 0.15;
    fsig1 = fsig;
    fsig1(fsig1>fsigsh) = 0;
    %yyaxis right
    plot(pt, fsig1,'color','red','LineWidth',1);
    ylim([0.0, fsigsh])
    line([pt(1) pt(end)],[.05 .05],'Color','k','LineWidth',0.35,'LineStyle',':')
    line([pt(1) pt(end)],[.10 .10],'Color','r','LineWidth',0.5,'LineStyle','-.')
    line([pt(1) pt(end)],[.14 .14],'Color','m','LineWidth',0.5,'LineStyle','--')
    yticks([0.0 0.05 0.10 0.14 0.15])
    yticklabels({'0.15','0.10', '0.05','0.01','0'})
    ylabel('F-test significance level')
    xlabel('Period')
    xlim([1/fmax, pt(3)]);set(gca, 'XDir','reverse')
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    subplot(3,1,2)
    plot(pt, ftest,'color','k','LineWidth',1);
    ylabel('F-ratio')
    xlim([1/fmax, pt(3)]);set(gca, 'XDir','reverse')
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    colordef white;
    set(gcf,'units','norm') % set location
    set(gcf,'position',[0.0,0.05,0.45,0.45])
end

if strcmp(method,'Lomb-Scargle spectrum')
    
end