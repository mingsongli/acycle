load La04.mat

data = data(55000:57000,:);
dat =[];
data(:,5) = 1 * zscore(data(:,2))+ 1 * zscore(data(:,3)) - 1 * zscore(data(:,4));
dat(:,1) = data(:,1);
dat(:,2) = data(:,5);

t = 55000:1:57000;
data1 = 1 * zscore(redmark(.5,length(t)));
data2 = 1 * randn(length(t),1);
dat(:,2) = dat(:,2)+data1+data2;

%dat = load('la04etp55-57sr4wnoiserandnwred.5.csv');
lax = 0:0.0001:0.06;
%sr0 = 0.06/0.5*100;
[p,f] = periodogram(dat(:,2),[],10000,1/0.04);
%figure;plot(f,p);
sr1 = 1;
sr2 = 30;
srstep = .01;
sr = sr1:srstep:sr2;
srn = length(sr);
px = zeros(srn,length(lax));
for i = 1:srn
    sri = sr(i);
    fi = f * sri/100;
    px(i,:) = interp1(fi,p,lax);
end
figure
pcolor(lax,sr,px)
colormap(jet)
shading interp