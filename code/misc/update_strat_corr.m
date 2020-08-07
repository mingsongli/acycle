%% update stratigraphic correlation plots

try figure(handles.CorrFig)
    subplot(3,1,1)
    plot(rawref(:,1),rawref(:,2),'r-')
    
    subplot(3,1,2)
    plot(rawser(:,1),rawser(:,2),'b-')
    title('Tunded Series')
    
    subplot(3,1,3)
    plot(rawref(:,1),(rawref(:,2)-mean(rawref(:,2)))/std(rawref(:,2)),'r-')
    hold on
    plot(rawser(:,1),(rawser(:,2)-mean(rawser(:,2)))/std(rawser(:,2)),'b-')
    title('Reference vs. Tuned Series')
catch
end