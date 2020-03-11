function [lod, doy] = lodla04(T)
% INPUT
%   T: 1xN or Nx1 vector; age, in Gyr. Nagetive = Deep time; positive = future
% OUTPUT
%   lod: length-of-day; same size of T
%   doy: number of days of one year; same size of T
% Ref:
%   Laskar, J., Robutel, P., Joutel, F., Gastineau, M., Correia, A.C.M., 
%   Levrard, B., 2004. A long-term numerical solution for the insolation 
%   quantities of the Earth. Astron Astrophys 428, 261-285.
%
% By
% Mingsong Li (Penn State)
% Mar. 10, 2020
% Coronavirus / COVID-19 time

day0 = 23.934468;
Lyear = 3.15576*10^7;
% coef for past
para1 = 7.432167;
para2 = -0.727046;
para3 = -0.409572;
para4 = -0.0589692;
% coef for future
para5 = 7.444649;
para6 = -0.715049;
para7 = 0.458097;

if max(T) <= 0
    % all past
    lod = day0 + para1*T + para2*T.^2 + para3*T.^3 + para4*T.^4; % hours
elseif min(T) >= 0
    % all future
    lod = day0 + para5*T + para6*T.^2 + para7*T.^3; % hours
else
    [row, ~] = size(T);
    Tp = T(T>0); % future
    Tn = T(T<=0); % past
    lodn = day0 + para1*Tn + para2*Tn.^2 + para3*Tn.^3 + para4*Tn.^4; % hours
    lodp = day0 + para5*Tp + para6*Tp.^2 + para7*Tp.^3; % hours
    if row == 1
        lod = [lodp,lodn];
    else
        lod = [lodp;lodn];
    end
end

doy = Lyear ./ (lod * 3600);% hours to seconds

% figure;
% subplot(2,1,1)
% plot(T,lod,'-ko')
% ylabel('length of day (hours)')
% subplot(2,1,2)
% plot(T,doy,'-ko')
% xlabel('Age (Gyr)')
% ylabel('stellar day of year')