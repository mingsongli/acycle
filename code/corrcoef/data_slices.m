function datanew = data_slices(dat, slices)
if slices <= 1
    return
end

x = dat(:,1);
data_size = size(x);
data_length = data_size(1,1);
t1 = dat(1,1);
tn = dat(data_length,1);
x_length = tn-t1;
slice_length = x_length/slices;
slice(1,1) = t1;

for i = 1: slices
    slice(i+1,1) = slice(i,1) + slice_length;
    [data_int]=select_interval(dat,slice(i,1),slice(i+1,1));
    %
    data_int(:,2) = detrend(data_int(:,2),0);
    datanew(:,(2*i-1):(2*i)) = data_int;
    i
end
end