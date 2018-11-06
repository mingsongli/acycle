%% unfinished
%
%INPUT:
%
%   data: 2 column data
%   
x = data(:,1);
y = data(:,2);
z = linspace(min(x),max(x),5*length(x))';

cov = {@covSum,{@covSEiso,@covNoise}};
mn  = {'meanZero'}; 
lik =  {'likLogistic'};

hyp.cov = [0; 2; -Inf]; % ell,sf,sn
hyp.mean = []; 
hyp.lik = [];

par.sampler = 'hmc'; par.Nsample = 20;

tic
[posts,nlZs,dnlZs] = infMCMC(hyp,mn,cov,lik,x,y,par);
toc

%[m,s2,fmus,fs2s,junk,posts] = gp(hyp,@infMCMC,mn,cov,lik,x,posts,z);
[m, s2,fmus,fs2s,junk,posts] = gp(hyp,@infMCMC,mn,cov,lik,x,posts,z);
% plot
figure;
f = [m+2*sqrt(s2); flip(m-2*sqrt(s2),1)];
%f1 = [m+sqrt(s2); flip(m-sqrt(s2),1)];
fill([z; flip(z,1)], f, [7 7 7]/8)
hold on;
%fill([z; flip(z,1)], f1, [6 6 6]/8)
plot(z, m); plot(x, y, '+');
%plot(z,fmus);