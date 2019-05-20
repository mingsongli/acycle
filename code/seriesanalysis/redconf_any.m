
function theored1 = redconf_any(f,pxx,dt,smoothwin,linlog)
%
% theored1 = redconf_any(f,pxx,.25,2)
%
% Nyquist frequency
fn = 1/(2*dt);
% true frequencies
ft = f/pi*fn;
% smoothwin = .25;
% median-smoothing data numbers
smoothn = round(smoothwin * length(pxx));
% median-smoothing
pxxsmooth = moveMedian(pxx,smoothn);

% mean power of spectrum
s0 = mean(pxxsmooth);
% Here we use a naive grid search method.
[rhoM, s0M] = minirhos0(s0,fn,ft,pxxsmooth,linlog);
% median-smoothing reshape significance level
theored1 = s0M * (1-rhoM^2)./(1-(2.*rhoM.*cos(pi.*ft./fn))+rhoM^2);