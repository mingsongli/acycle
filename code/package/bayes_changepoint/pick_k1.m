function num_chgpts = pick_k1(k)
% Function will sample from any probability distribution, initially created
% to sample a number of change points

r=rand();           % Uniform random number between 0 and 1

S = k(1);
i=1;
while (r>=S && i<length(k))
    i=i+1;          % Sample from cumulative probabilities (CDF)
    S = S + k(i);
end
num_chgpts=i;
       