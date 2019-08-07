% build a power spectrum with random freq. power and random number of freqs

function randspectrum = randspec_sin(f,n,dat_ray)
% f: frequency range
% n: n number of frequencies
% dat_ray: rayleigh
% dat_nyq: nyquist

nf = length(f);
if n == 0
    p_sim = zeros(nf,1);
else
    
    p_sim = zeros(nf,n);

    for i = 1:n
        p2 = randspec1(f,nf,dat_ray);
        p_sim(:,i) = p2;
    end

    randspectrum = sum(p_sim,2);
end
end

function p2 = randspec1(f,nf,dat_ray)
    df = f(2)-f(1);
    f1 = 0:df:2*dat_ray;
    nf1 = length(f1);
    p1 = sin(2*pi*(0.25/dat_ray)*f1); 
    p1 = p1';
    local = randi([1, nf-nf1],1,1);
    p2 = zeros(nf,1);
    p2(local:local+nf1-1) = rand(1) * p1;
end
