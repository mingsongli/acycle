% Return fk, frequency data for the given steps
% INPUT
%   data    1 column data
% OUTPUT
%   fk      2 column frequency data
% Mingsong Li, Penn State
%

x1 = 190;
x2 = 4400;
dx = 2.5;

n = length(data);

to = x1:dx:x2;
to = to';
to1 = [0;to];
ton = length(to1);
fn = zeros(ton,1);

for i = 1:ton
    j = 0;
    for k = 1:n
        if data(k)> 0 && data(k) < to1(i)
            j=j+1;
        end
    end
    fn(i) = j;
end

fk = [to,diff(fn)];


%figure; plot(fk(:,1),fk(:,2))
figure; stairs(fk(1:end-1,1), fk(2:end,2))
xlabel('Age (Ma)')
ylabel('N')