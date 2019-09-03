function BP89PP = getBerger89Period(t)
B89P = load('Berger1989Periods.txt');

if t < 0
    errorlog('Time (t) must be no less than 0 with a unit of Ma!')
end

loc = B89P(:,1);
loci = length(loc(loc<t));

if loci < 6
    p2 = (B89P(loci+1,2)-B89P(loci,2))/(B89P(loci+1,1)-B89P(loci,1))*(t-B89P(loci,1))+B89P(loci,2);
    p1 = (B89P(loci+1,3)-B89P(loci,3))/(B89P(loci+1,1)-B89P(loci,1))*(t-B89P(loci,1))+B89P(loci,3);
    o2 = (B89P(loci+1,4)-B89P(loci,4))/(B89P(loci+1,1)-B89P(loci,1))*(t-B89P(loci,1))+B89P(loci,4);
    o1 = (B89P(loci+1,5)-B89P(loci,5))/(B89P(loci+1,1)-B89P(loci,1))*(t-B89P(loci,1))+B89P(loci,5);
else
    p2 = (B89P(loci,2)-B89P(loci-1,2))/(B89P(loci,1)-B89P(loci-1,1))*(t-B89P(loci,1))+B89P(loci,2);
    p1 = (B89P(loci,3)-B89P(loci-1,3))/(B89P(loci,1)-B89P(loci-1,1))*(t-B89P(loci,1))+B89P(loci,3);
    o2 = (B89P(loci,4)-B89P(loci-1,4))/(B89P(loci,1)-B89P(loci-1,1))*(t-B89P(loci,1))+B89P(loci,4);
    o1 = (B89P(loci,5)-B89P(loci-1,5))/(B89P(loci,1)-B89P(loci-1,1))*(t-B89P(loci,1))+B89P(loci,5);
end
e1 = 413;
e2 = 123;
e3 = 95;
BP89PP = [e1, e2, e3, o1/1000, o2/1000, p1/1000, p2/1000];