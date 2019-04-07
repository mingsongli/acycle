%% Load ETP from input t1 to t2


interv=input('>>      Input time interval from t1 to t2.  e.g.,   [55000 57000]  ->|  ');

t1=min(interv);
t2=max(interv);

disp(['>>  Calculate ETP from ',num2str(t1),' to ',num2str(t2), ' kyr']);
laskar=input('>>  Select:   1 = La04; 2 = La10a; 3 = La10b; 4 = La10c; 5 = La10d |->  ');

    if laskar==1
        load La04.mat
    elseif laskar ==2
        load La10a.mat
    elseif laskar ==3
        load La10b.mat
    elseif laskar ==4
        load La10c.mat
    elseif laskar ==5
        load La10d.mat
    else
        disp('>>  Type a number from 1 to 5. e.g.,    5')
    end

dat=data;  % save Laskar solution to dat
data =[];
data = dat(t1:t2,:);
clear dat;

data(:,5)=zscore(data(:,2))+zscore(data(:,3))-zscore(data(:,4));
dat(:,1)=data(:,1);
dat(:,2)=data(:,5);

clear  t1 t2 laskar;

disp('>>  Data is Laskar solution [time E T P etp]; Dat is ETP series;')