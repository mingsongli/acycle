%INPUT:
%
%   data: 2 column data
%   
x = data(:,1);
y = data(:,2);
z = linspace(min(x),max(x),5*length(x))';
%
meanfunc = {@meanSum, {@meanLinear, @meanConst}}; 
covfunc = @covSEiso;
likfunc = @likGauss;
% hyp
hyp.cov = [0; 0]; 
hyp.mean = [0; 0]; 
hyp.lik = log(0.1);
%hyp = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
hyp = minimize(hyp, @gp, -100, @infEP, meanfunc, covfunc, likfunc, x, y);
% gp
[m s2] = gp(hyp, @infEP, meanfunc, covfunc, likfunc, x, y, z);
%[m s2 fm fs2 lp] = gp(hyp, @infEP, meanfunc, covfunc, likfunc, x, y, z);
% plot
figure;
f = [m+2*sqrt(s2); flip(m-2*sqrt(s2),1)];
f1 = [m+sqrt(s2); flip(m-sqrt(s2),1)];
fill([z; flip(z,1)], f, [7 7 7]/8)
hold on;
fill([z; flip(z,1)], f1, [6 6 6]/8)
plot(z, m); plot(x, y, '+');