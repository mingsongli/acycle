function [] = InsolLatDayGif(II,t,lat,day,unit_t_r,name_insol)
% Calls for
% II,
% lat, 
% day,
%
figure
II = real(II);
Z = II(:,:,1);
[LAT,DAY] = meshgrid(lat,day);
LAT = LAT';
DAY = DAY';
pcolor(DAY,LAT,Z);
colorbar
axis tight manual
ax = gca;
caxis([0 625])
ax.NextPlot = 'replaceChildren';
%grid off
colormap(jet)
shading interp
title(['Age (',unit_t_r,') = ',num2str(t(1))])
ylabel('Latitude')
xlabel('Day')
whitebg('white');

F = getframe(gcf);

[~,~,loops] = size(II);

[im,map] = rgb2ind(F.cdata,256,'nodither');
% size(im)
im(1,1,1,loops) = 0;
%F(loops) = struct('cdata',[],'colormap',[]);
for j = 1:loops
    X = real(II(:,:,j));
    pcolor(DAY,LAT,X)
    title(['Age (',unit_t_r,') = ',num2str(t(j))])
    shading interp
    colorbar
    drawnow
    F = getframe(gcf);
    im(:,:,1,j) = rgb2ind(F.cdata,map,'nodither');
end

imwrite(im,map,[name_insol,'.gif'],'DelayTime',0.0,'LoopCount',inf) 