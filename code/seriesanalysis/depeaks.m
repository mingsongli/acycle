%% remove abnormal value
%%
function [depeaksinter]=depeaks(data,ymin_cut,ymax_cut)
datax=data(:,1);
datay=data(:,2);
npts=length(datax);
    depeaks_bottom = ymin_cut;
    depeaks_top = ymax_cut;
%%
for p=1:npts
    if datay(p)<ymin_cut
    datay(p)=ymin_cut;
    end
    if datay(p)>ymax_cut
    datay(p)=ymax_cut;
    end
end
%%
depeaksinter=[datax,datay];