function [Yp,locat] = eccpeaks(X,ecc,eci,norbit,corrcoef,ci,sh_norb,n,dim,a)

% epeaks: sort X, select n peaks that ci < 5% for each column of data X
% INPUT
%   X: data to be evaluated. A vector or Matrix.
%   ecc: evo corr. coef matrix to be evaluated
%   eci: evo confidence interval matrix to be evaluated
%   n: record n peaks of each row of A.
%   ci: shreshold confidence interval. default = 5  (5%)
%   coco: shreshold correlation coefficient. default = 0.3.
%   dim: dimension. 1 = column; 2 = row;
%   a: new value for new data Yp
% OUTPUT
%   Y: new data show peaks only
%   Mingsong Li, June 2017
%
if nargin > 10
    error('Too many input arguments')
end
if nargin < 10
    a = 0;
    if nargin < 9
        dim =1;
        if nargin < 8
            n = 1;
            if nargin < 7
                sh_norb = 3;
                if nargin < 6
                    ci = 5;
                    if nargin < 5
                        corrcoef = 0.3;
                        if nargin < 4
                            error('Too few input arguments')
                        end
                    end
                end
            end
        end
    end
end

[nrow, ncol] = size(X);
Xs = sort(X,dim,'descend');

Yp = a * ones(nrow,ncol);
locat = a * zeros(n,ncol);

if dim == 1
    Xn = Xs(1:n,:);
    for j = 1:n
        for i = 1:ncol
            Xp = X(:,i);
            if and(ecc(Xp == Xn(j,i),i) >= corrcoef, ...
                    and(eci(Xp == Xn(j,i),i) <= ci, norbit(Xp == Xn(j,i),i) >= sh_norb))

                try
                    locat(j,i) = find(Xp == Xn(j,i));
                    Yp(locat(j,i),i) = Xp(locat(j,i));
                catch
%                     findXp = find(Xp == Xn(j,i));
%                     locat(j,i) = median(findXp);  % median value of the peaks
                end
                
            end
        end
    end
else
    Xn = Xs(:,1:n);
    for j = 1:n
        for i = 1:row
            Xp = X(i,:);
            if and(and(ecc(i,Xp == Xn(i,j)) >= corrcoef, eci(i,Xp == Xn(i,j))<=ci),...
                    norbit(Xp == Xn(j,i),i) >= sh_norb)
                try
                    locat(i,j) = find(Xp == Xn(i,j));
                    Yp(i,locat(i,j)) = Xp(locat(i,j));
                catch
%                     findXp = find(Xp == Xn(i,j));
%                     locat(j,i) = median(findXp);  % Median value of the peaks
                end
            end
        end
    end
end