function [mod,cpt,R_2] = bayes_cpt(data,k_max,d_min,k_0,v_0,sig_0,num_samp)
%
% INPUT
%   data:       2 column dataset, time/depth and value
%   k_max       Maximum number of change points, default = 10
%   d_min       Minimum distance between adjacent change points 
%               (twice as many fre parameters in the regression models. 
%               in our case d_min should equal at least 4
%   k_0         Hyperparameter for the prior on the regression coefficients
%   v_0         Hyperparameter for scaled inverse chi-square prior on the variance
%   sig_0       Hyperparameter for scaled inverse chi-square prior on the variance
%   num_samp    Number of sampled solutions
%
% OUTPUT
%   
% Calls for
%   nCk.m       
%   partition_fn.m
%   pick_k1.m
%   
%%
%************************************************************************/
%* The Bayesian Change Point algorithm - A program to caluclate the     */
%* posterior probability of a change point in a time series.            */
%*                                                                      */
%* Please acknowledge the program author on any publication of          */
%* scientific results based in part on use of the program and           */
%* cite the following article in which the program was described.       */
%*                                                                      */
%* E. Ruggieri (2013) "A Bayesian Approach to Detecting Change Points   */
%* in Climatic Records," International Journal of Climatology,          */
%* 33: 520-528. doi: 10.1002/joc.3447                                   */
%*                                                                      */
%* Program Author: Eric Ruggieri                                        */
%* College of the Holy Cross                                            */
%* Worcester, MA 01610                                                  */
%* Email:  eruggier@holycross.edu                                       */
%*                                                                      */
%* Copyright (C) 2012  Duquesne University                              */
%*               2014 College of the Holy Cross                         */
%*                                                                      */
%* The Bayesian Change Point algorithn is free software: you can        */
%* redistribute it and/or modify it under the terms of the GNU General  */
%* Public License as published by the Free Software Foundation, either  */
%* version 3 of the License, or (at your option) any later version.     */
%*                                                                      */
%* The Bayesian Change Point algorithm is distributed in the hope that  */
%* it will be useful, but WITHOUT ANY WARRANTY; without even the        */
%* implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      */
%* PURPOSE.  See the GNU General Public License for more details.       */
%*                                                                      */
%* You should have received a copy of the GNU General Public License    */
%* along with Bayesian Change Point.  If not, see                       */
%* <http://www.gnu.org/licenses/> or write to the                       */
%* Free Software Foundation, Inc.                                       */
%* 51 Franklin Street Fifth Floor                                       */
%* Boston, MA 02110-1301, USA.                                          */
%************************************************************************/

%% Modified by Mingsong Li for acycle (www.mingsongli.com)
%   Nov 2018, Penn State
%   limingsonglms@gmail.com
%

if nargin > 7
    error('Too much input')
end
if nargin < 7
    num_samp = 500;
    if nargin < 6
        sig_0 = var(data(:,2));
    end
end

% Outline of the Bayesian Change Point algorithm:
% 1) Load the Data  
% 2) Define the Parameter Values
% 3) Calculate the Probability Density of the Data for Each Sub-Interval
% 4) Forward Recursion [Dynamic Programming]
% 5) Stochastic Backtrace via Bayes Rule
%       a) Sample a Number of Change Points
%       b) Sample the Location of the Change Points
%       c) Sample the Regression Parameters Between Adjacent Change Points
% 6) Plot the Results
%
% Description of Parameters, input, and output can be found in accompanying 
% ReadMe file
%

%% ************(1)Load the Data*****************************

Y=data(:,2);    % Data set / time series (didn't work well, still doesn't)
x=data(:,1);    % Time points

%% *************(2)Define the Parameter Values**************

N=length(Y);    % Number of data points
% k_max=10;        % Maximum number of change points
% d_min=1;       % Minimum distance between adjacent change points 
% k_0=0.0001;           % Hyperparameter for the prior on the regression coefficients
% v_0=0.01; 
% sig_0=0.001;  % Hyperparameter for scaled inverse chi-square prior on the variance

X = [zeros(N,1)+1 (1:N)'];  % Build the regression model - in this case, a linear model
                            % Column 1 represents the constant term
                            % Column 2 represents the linear trend

[~, m] =size(X);             % r = total # data points (N), m = # regressors
beta0= zeros(m,1);          % Mean of multivariate normal prior on regression coefficients
%num_samp=500;               % Number of sampled solutions

%% ******(3)Calculate the Probability Density of Data for Each Sub-Interval*********

Py=zeros(N,N)-Inf;      % Matrix containing the probability of each substring of the data
I=eye(m);               % cxc identity matrix

for i=1:N
    if N > 200
        disp(['>> ',num2str(i),' / ',num2str(num_samp)])
    end
    
    for j=i+d_min-1:N
        
        %Calculate beta_hat
        XTy=X(i:j,:)'*Y(i:j); 
        J=k_0*I+X(i:j,:)'*X(i:j,:); 
        beta_hat=J\(k_0*beta0+XTy); %inv(J)*(k_0*beta0+XTy)
        
        %Calculate v_n and s_n
        a=j-i+1;    % 'a' is the number of data points.... not the distance between them, 
                    % which becomes relevant if data points are not equally spaced
        v_n=v_0+a;  % a is the number of data points in the segment, see above for definition
        
        s_n = v_0*sig_0 + k_0*(beta0-beta_hat)'*(beta0-beta_hat) + (Y(i:j,:)-X(i:j,:)*beta_hat)'*(Y(i:j,:)-X(i:j,:)*beta_hat);
        
        % Calculate the Probability Density of the Data - Equation (2) - stored in log form 
        Py(i,j) = v_0*log(sig_0*v_0/2)/2 + gammaln(v_n/2) +m*log(k_0)/2  ...
            - log(gamma(v_0/2)) - v_n*log(s_n/2)/2 - a*log(2*pi)/2 - log(det(J))/2 ;
     end
end

%****************(4) Build Partition Function *************************
P = partition_fn(Py, k_max, N);
        
%****************(5) Stochastic Backtrace via Bayes Rule****************

k= P(:,N);
for i=1:k_max                   % Equation (6)
    if(N-(i+1)*d_min+i >= i)    % If a plausible solution exists...
        k(i) = k(i) + log(0.5) - log(k_max) - log(nCk(N-(i+1)*d_min+i,i));
                                                % Above term is N_k
    end
end
k=[Py(1,N)+ log(0.5); k];       % Zero change points

total_k = log(sum(exp(k))); % Adds logarithms and puts answer in log form - Equation (5) 
%total_k=logsumlog(k);      % A slower, but potentially more precise version of above calculation
k(:)=exp(k(:)-total_k);     % Normalize the vector - Equation (7)

% Variables used in sampling procedure:
samp_holder=zeros(num_samp,k_max);  % Contains each of the num_samp change point solutions
chgpt_loc=zeros(1,N);               % The number of times a change point is identified at each data point
BETA = zeros(m,N);                  % Holds the regression coefficients

for i=1:num_samp
    if N > 200
        disp(['>> ',num2str(i),' / ',num2str(num_samp)])
    end
    %******** (5a) Sample a Number of Change Points ***********************
    num_chgpts = pick_k1(k)-1;  % Since we allow for 0 changepoints, function returns the index of the 'k' vector, 
                                % which is offset from the number of change points by 1 
    if(num_chgpts>0)
        
        %******** (5b) Sample the Location of the Change Points ***********
        back=N;
        for kk=num_chgpts:-1:2      % Start at the end of the time series and work backwards
            temp=zeros(1,back-1);
            for v=1:back-1
                temp(v)= P(kk-1,v)+Py(v+1,back);  % Build the vector to sample from
            end
            total = log(sum(exp(temp)));
            %total=logsumlog(temp);      % Slower, but potentially more precise version of above calculation    
            temp(:)=exp(temp(:)-total);  % Normalize the vector
            changepoint=pick_k1(temp);   % Sample the location of the change point
            chgpt_loc(changepoint)= chgpt_loc(changepoint) +1; % Keep track of change point locations
            samp_holder(i,kk)=changepoint;  % Keep track of individual change point solutions
            
            %******** (5c) Sample the Regression Parameters ***********
            % Regression Coefficients (Beta)
            XTy=X(changepoint+1:back,:)'*Y(changepoint+1:back); 
            J=k_0*I+X(changepoint+1:back,:)'*X(changepoint+1:back,:); 
            beta_hat=J\(k_0*beta0+XTy);     %inv(J)*(k_0*beta0+XTy)
            
            for j=1:m
               BETA(j,changepoint+1:back) = BETA(j,changepoint+1:back) +beta_hat(j)*ones(1,back-changepoint);  
            end
            
            back=changepoint;   % Now work with the next segment
        end
        
        % The final changepoint
        %******** (5b) Sample the Location of the Change Points ***********
        kk=1;
        temp=zeros(1,back-1);
        for v=1:back-1
            temp(v)= Py(1,v)+Py(v+1,back); %Build the vector to sample from
        end
        total = log(sum(exp(temp)));
        %total=logsumlog(temp);      % Slower, but potentially more precise version of above calculation    
        temp(:)=exp(temp(:)-total); % Normalize the vector
        changepoint=pick_k1(temp);  % Sample the location of the change point
        chgpt_loc(changepoint)= chgpt_loc(changepoint) +1; % Keep track of change point locations
        samp_holder(i,kk)=changepoint;  % Keep track of individual change point solutions
            
        %******** (5c) Sample the Regression Parameters ***********
        % Regression Coefficients (Beta)
        XTy=X(changepoint+1:back,:)'*Y(changepoint+1:back); 
        J=k_0*I+X(changepoint+1:back,:)'*X(changepoint+1:back,:); 
        beta_hat=J\(k_0*beta0+XTy);     %inv(J)*(k_0*beta0+XTy)
        
        for j=1:m
               BETA(j,changepoint+1:back) = BETA(j,changepoint+1:back) +beta_hat(j)*ones(1,back-changepoint);  
        end
        
        %The final sub-interval
        XTy=X(1:changepoint,:)'*Y(1:changepoint); 
        J=k_0*I+X(1:changepoint,:)'*X(1:changepoint,:); 
        beta_hat=J\(k_0*beta0+XTy);     %inv(J)*(k_0*beta0+XTy)
        
        for j=1:m
               BETA(j,1:changepoint) = BETA(j,1:changepoint) +beta_hat(j)*ones(1,changepoint);  
        end
        
    else    % 0 change points, so a single homogeneous segment
        XTy=X'*Y; 
        J=k_0*I+X'*X; 
        
        %******** (5c) Sample the Regression Parameters ***********
        % Regression Coefficients (Beta)
        beta_hat=J\(k_0*beta0+XTy);     %inv(J)*(k_0*beta0+XTy)
        for j=1:m
               BETA(j,:) = BETA(j,:) +beta_hat(j)*ones(1,N);  
        end
    end
end

BETA=BETA/num_samp;             % Average regression coefficient at each data point.
chgpt_loc=chgpt_loc/num_samp;   % Posterior probability of a change point

%**********(6) Plot the Results ********************************
% Adapt as Necessary

model=zeros(1,N);
for i=1:N
    model(i)=X(i,:)*BETA(:,i);
end
%figure(1);
figure;
plot(x,Y, 'LineWidth', 2); 
hold on
title('Change Points', 'fontsize', 12)

[ax, h1, h2] = plotyy(x,model,x,chgpt_loc, 'plot');
gca=ax(1);
set(gca,'Ycolor', 'k')      % Left Y-axis colored black
set(gca, 'fontsize', 12)    % Default is 10
set(get(ax(1), 'Ylabel'), 'String', 'Proxy', 'fontsize', 12)
set(h1, 'Color', 'g')       % Model plotted in green, default blue
set(h1, 'LineStyle', '--'); % Default is a solid line
set(h1, 'LineWidth', 2)     % Default is 0.5

gca=ax(2);
set(gca, 'Ylim', [0 2])
set(gca, 'Ycolor', 'r')     % Right Y-Axis colored red
set(gca, 'Yticklabel', 0:0.1:1)
set(gca, 'Ytick', 0:0.1:1)
set(gca, 'fontsize', 12)
set(get(ax(2), 'Ylabel'), 'String', 'Posterior Probability', 'fontsize', 12)
set(h2, 'Color', 'r')       % Posterior probabilities plotted in red
set(h2, 'LineWidth', 2)
hold off
% Calculate R^2 value:
r=0; rr=0;
for i=1:N
    r = r+ Y(i)^2;
    rr= rr+ (Y(i)-model(i))^2;
end

R_2 = 1-rr/r;

mod = [x,model'];
cpt = [x,chgpt_loc'];
% Eliminate unnecessary variables
clear i j J XTy beta_hat changepoint a back kk num_chgpts r rr s_n v_n temp total_k v total 
