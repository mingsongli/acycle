data = load('Example-WayaoCarnianGR0.txt');
figure;hold on;
j=0;
for i = 1: 30
    %t1 = i*405; 
    t1 = 20;
    t = data(t1:t1+90,1) - t1;
    x = 5*data(t1:t1+90,2);
    plot(t,x+j,'k-','LineWidth',1.)
    j = j + .1*mean(x);
end
hold off


% load La04.mat
% figure;hold on;
% j=0;
% for i = 1: 120
%     %t1 = i*405;
%     t1 = 300;
%     t = data(t1:t1+300,1) - t1;
%     x = 10*data(t1:t1+300,2);
%     plot(t,x+j,'k-','LineWidth',1.)
%     j = j + .03*mean(x);
% end
% hold off
% xlim([0, t1])
% ylim([0, max(x+j)])

% figure;hold on;
% j=0;
% for i = 1: 100
%     %t1 = round (rand() * 10000);
%     t1 = 1000+i;
%     t = data(t1:t1+50,1) - t1;
%     x = data(t1:t1+50,4);
%     plot(t,x+j,'k-','LineWidth',.2)
%     j = j + mean(x);
%     j = j+0.03;
% end
% hold off

% figure;hold on;
% j=0;
% for i = 1: 100
%     t1 = round (rand() * 10000);
%     t = data(t1:t1+1000,1) - t1;
%     x = data(t1:t1+1000,2);
%     plot(t,x+j,'k-','LineWidth',.5)
%     j = j + 3*mean(x);
% end
% hold off