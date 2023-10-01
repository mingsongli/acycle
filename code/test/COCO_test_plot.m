        % plot H0 test of Monte carlo simulation
        figure; 
        subplot(3,1,2);
        %semilogy(corrxch,corry_per,'r','LineWidth',1); 
        semilogy(corrxch,max(eps*10^12,corry_per),'r','LineWidth',1); 
        %if or(lang_choice == 0, handles.main_unit_selection == 0)
            xlabel('Sedimentation rate (cm/kyr)')
            ylabel('H_0 significance level')
            title('Null hypothesis')
        %else
        %    xlabel(ax2,lang_var{ec80})
        %    ylabel(ax2,lang_var{ec82})
        %    title(ax2,lang_var{ec83})
        %end
        sr1 = 4.3333;
        sr2 = 43.5391;
        ylim([0.5*min(corry_per) 1])
        line([sr1, sr2],[.10, .10],'LineStyle',':','Color','k')
        line([sr1, sr2],[.05, .05],'LineStyle',':','Color','k')
        line([sr1, sr2],[.01, .01],'LineStyle','--','Color','k')
        line([sr1, sr2],[.001, .001],'LineStyle',':','Color','k')
        set(gca,'Ydir','reverse')
        set(gca,'XMinorTick','on')
        
        
        subplot(3,1,3);
        plot(corrxch,(100-100*corry_per).^2,'r','LineWidth',1); 
        %if or(lang_choice == 0, handles.main_unit_selection == 0)
            xlabel('Sedimentation rate (cm/kyr)')
            ylabel('H_0 significance level')
            title('Null hypothesis')
        %else
        %    xlabel(ax2,lang_var{ec80})
        %    ylabel(ax2,lang_var{ec82})
        %    title(ax2,lang_var{ec83})
        %end
        sr1 = 4.3333;
        sr2 = 43.5391;
        %ylim([0.5*min(corry_per) 1])
        %ylim([85,101])
        line([sr1, sr2],[90, 90],'LineStyle',':','Color','k')
        line([sr1, sr2],[95, 95],'LineStyle',':','Color','k')
        line([sr1, sr2],[99, 99],'LineStyle','--','Color','k')
        line([sr1, sr2],[99.9, 99.9],'LineStyle',':','Color','k')
        %set(gca,'Ydir','reverse')
        set(gca,'XMinorTick','on')