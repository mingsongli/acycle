function n_k = nCk(n, k)
% a function to replace nchoosek when n is very large
n_k = prod(n-k+1:n)/factorial(k);
end