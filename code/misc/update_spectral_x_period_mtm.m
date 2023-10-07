lang_id = handles.lang_id;
lang_var = handles.lang_var;

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
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        xlabel(['Period (',num2str(unit),')']) 
        title([num2str(nw),'\pi-MTM-Robust-AR(1): \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M)])
        ylabel('Power')
        smthwin = [num2str(smoothwin*100),'%', ' median-smoothed'];
        legend('Power',smthwin,'Robust AR(1) median',...
            'Robust AR(1) 90%','Robust AR(1) 95%','Robust AR(1) 99%','Robust AR(1) 99.9%')
    else
        [~, main15] = ismember('main15',lang_id);
        [~, locb1] = ismember('spectral34',lang_id);
        [~, spectral06] = ismember('spectral06',lang_id);
        xlabel([lang_var{main15},' (',handles.unit,')'])
        title([num2str(nw),'\pi-MTM-',lang_var{spectral06},': \rho = ',num2str(rhoM),'. S0 = ',num2str(s0M),'; ',lang_var{locb1},' = ',num2str(bw)])   
        
        [~, locb] = ismember('spectral30',lang_id);
        ylabel(lang_var{locb})
        [~, locb1] = ismember('spectral31',lang_id);
        smthwin = [num2str(smoothwin*100),'% ', lang_var{locb1}];
        [~, locb6] = ismember('spectral06',lang_id);
        [~, locb1] = ismember('spectral32',lang_id);
        legend(lang_var{locb},smthwin,...
            [lang_var{locb6},lang_var{locb1}],...
            [lang_var{locb6},'90%'],...
            [lang_var{locb6},'95%'],...
            [lang_var{locb6},'99%'])
    end
    
    if fmin <= 0 
        fmin_s = pt(3);
    else
        fmin_s = 1/fmin;
    end
    
    xlim([1/fmax, fmin_s]);
    set(gca, 'XDir','reverse')
    
    set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gcf,'Color', 'white')
    if handles.linlogY == 1
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
    %[fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconftabtchi(datax,nw,dt,nzeropad,2);
    [fd,po,theored,tabtchi90,tabtchi95,tabtchi99,tabtchi999]=redconfchi2(datax,nw,dt,nzeropad,2);
    pt = 1./fd;
    plot(pt,po,'k-','LineWidth',1);
    hold on; 
    plot(pt,theored,'k-','LineWidth',2);
    plot(pt,tabtchi90,'r-','LineWidth',1);
    plot(pt,tabtchi95,'r--','LineWidth',2);
    plot(pt,tabtchi99,'b-.','LineWidth',1);
    plot(pt,tabtchi999,'g--','LineWidth',1);
    
    if fmin <= 0 
        fmin_s = pt(3);
    else
        fmin_s = 1/fmin;
    end
    
    xlim([1/fmax, fmin_s]);
    set(gca, 'XDir','reverse')
    
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        xlabel(['Period (',num2str(unit),')']) 
        ylabel('Power')
        title([num2str(nw),'\pi MTM classic AR1',' ','; Sampling rate = ',num2str(dt),' ', unit])
        legend('Power','AR1','90%','95%','99%','99.9%')
    else
        [~, main15] = ismember('main15',lang_id);
        [~, spectral30] = ismember('spectral30',lang_id);
        xlabel([lang_var{main15},' (',handles.unit,')'])
        ylabel(lang_var{spectral30})
        legend(lang_var{spectral30},'AR1','90%','95%','99%','99.9%')
        [~, locb7] = ismember('spectral07',lang_id);
        [~, spectral37] = ismember('spectral37',lang_id);
        title([num2str(nw),'\pi-MTM-',lang_var{locb7},'; ',lang_var{spectral37},' = ',num2str(dt),' ', handles.unit])
    end
        
    
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
    
        
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        xlabel(['Period (',num2str(unit),')']) 
        ylabel('Power')
        title([num2str(nw),'\pi MTM',' ','; Sampling rate = ',num2str(dt),' ', unit])
    else
        [~, main15] = ismember('main15',lang_id);
        [~, spectral30] = ismember('spectral30',lang_id);
        xlabel([lang_var{main15},' (',handles.unit,')'])
        ylabel(lang_var{spectral30})
        [~, spectral37] = ismember('spectral37',lang_id);
        title([num2str(nw),'\pi MTM','; ',lang_var{spectral37},' = ',num2str(dt),' ', handles.unit])
    end
    
    set(gcf,'Name',[dat_name,ext,' ',num2str(nw),'pi MTM'])
    set(gca,'XMinorTick','on','YMinorTick','on')
    
    if fmin <= 0 
        fmin_s = pt(3);
    else
        fmin_s = 1/fmin;
    end
    
    xlim([1/fmax, fmin_s]);
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
    [freq,ftest,fsigout,Amp,Faz,Sig,Noi,dof,wt]=ftestmtmML(data,nw,padtimes,0);
    pt = 1./freq;
    
    figure;
    
    subplot(3,1,1)
    
    plot(pt, Amp,'color',[0, 0.4470, 0.7410],'LineWidth',1.5)
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        title(['Amplitude, F-test significance level : ', num2str(nw), '\pi'])
        ylabel('Amplitude')
    else
        [~, spectral45] = ismember('spectral45',lang_id);
        [~, spectral46] = ismember('spectral46',lang_id);
        title([lang_var{spectral45},', ',lang_var{spectral46},' : ', num2str(nw), '\pi'])
        ylabel(lang_var{spectral45})
    end
    
    if fmin <= 0 
        fmin_s = pt(3);
    else
        fmin_s = 1/fmin;
    end
    
    xlim([1/fmax, fmin_s]);
    set(gca, 'XDir','reverse')
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    
    subplot(3,1,2)
    plot(pt, ftest,'color','k','LineWidth',1);
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        ylabel('F-ratio')
    else
        [~, spectral47] = ismember('spectral47',lang_id);
        ylabel(lang_var{spectral47})
    end
    if fmin <= 0 
        fmin_s = pt(3);
    else
        fmin_s = 1/fmin;
    end
    
    xlim([1/fmax, fmin_s]);
    set(gca, 'XDir','reverse')
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    
    subplot(3,1,3)
    hold on
    fsigsh = 0.15;
    fsig1 = fsigout;
    fsig1(fsig1>fsigsh) = fsigsh;
    %yyaxis right
    plot(pt, fsig1,'color','red','LineWidth',1);
    ylim([0.0, fsigsh])
    line([pt(2) pt(end)],[.05 .05],'Color','m','LineWidth',0.35,'LineStyle','-.')
    line([pt(2) pt(end)],[.10 .10],'Color','k','LineWidth',0.5,'LineStyle',':')
    line([pt(2) pt(end)],[.01 .01],'Color','r','LineWidth',0.5,'LineStyle','--')
    yticks([0.0 0.01 0.05 0.10 0.15])
    yticklabels({'0','0.01','0.05','0.10','0.15'})
    
    if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
        ylabel('F-test significance level')
        xlabel(['Period (',unit,')'])
    else
        [~, spectral46] = ismember('spectral46',lang_id);
        ylabel(lang_var{spectral46})
        [~, main15] = ismember('main15',lang_id);
        xlabel([lang_var{main15},' (',handles.unit,')'])
    end
    set(gca, 'YDir','reverse')
    if fmin <= 0 
        fmin_s = pt(3);
    else
        fmin_s = 1/fmin;
    end
    
    xlim([1/fmax, fmin_s]);
    set(gca, 'XDir','reverse')
    if handles.logfreq == 1
        set(gca,'xscale','log')
    end
    colordef white;
    set(gcf,'units','norm') % set location
    set(gcf,'position',[0.0,0.05,0.45,0.45])
end

if strcmp(method,'Lomb-Scargle spectrum')
    
end