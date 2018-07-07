% Author: Soroush Saryazdi
% Date: June 2018

clear all
close all
clc

%% --------------------- INITIALS ------------------------
Y = [20-50i,-10+20i,-10+30i;
     -10+20i,26-52i,-16+32i;
     -10+30i,-16+32i,26-62i];
% Which variables are we trying to calculate? put 1 if trying to calculate:
Known_V = [1,0,1];
Known_A = [1,0,0];
Known_P = [0,1,1];
Known_Q = [0,1,0];

% Initial Values:
V = [1.05,1,1.04]; % p.u.
A = [0,0,0];
P = [0,-4,2]; % p.u.
Q = [0,-2.5,0]; % p.u.
% Convergence epsilon:
epsilon = 0.1;

%% ------------------- CALCULATIONS ---------------------
% Which bus is the slack bus?
Slack_Bus = and(Known_V,Known_A);
PQ_Bus = and(Known_P,Known_Q);
PV_Bus = and(Known_P,Known_V);
Known_V = Known_V-Slack_Bus; % Do not change this.
Known_A = Known_A-Slack_Bus; % Do not change this.

Known_V_index = find(Known_V==1);
Known_A_index = find(Known_A==1);
Known_P_index = find(Known_P==1);
Known_Q_index = find(Known_Q==1);

Missing_V = (1-Known_V)-[1,0,0];
Missing_A = (1-Known_A)-[1,0,0];
Missing_P = (1-Known_P)-[1,0,0];
Missing_Q = (1-Known_Q)-[1,0,0];

Unknown_V_index = find(Missing_V==1);
Unknown_A_index = find(Missing_A==1);
Unknown_P_index = find(Missing_P==1);
Unknown_Q_index = find(Missing_Q==1);



[size1, size2] = size(Y);
Y_zero_diag = Y.*(1-eye(size1));
Y_diag_values = Y.*eye(size1);
Y_diag_values(Y_diag_values==0) = [];

max_err = inf;
k = 0;
tic
while max_err > epsilon
    k = k+1; 
    fprintf('iteration = %d \n', k)
    V_complex = (V.*cos(A))+(V.*sin(A)*i);
    V_Update = (((P-(Q*i))./conj(V_complex))-(V_complex*Y_zero_diag))./Y_diag_values;
    S = conj(V_complex).*((V_complex.*Y_diag_values)+(V_complex*Y_zero_diag));
    P_Update = real(S);
    Q_Update = -1*imag(S);
    V_new = real((V_Update.*Missing_V) + (V.*(1-Missing_V)));
    A_new = imag((V_Update.*Missing_A) + (V.*(1-Missing_A)));
    P_new = P_Update.*Missing_P + (P.*(1-Missing_P));
    Q_new = Q_Update.*Missing_Q + (Q.*(1-Missing_Q));
    err = [V_new;P_new;Q_new]-[V;P;Q];
    max_err = max(abs(err(:)));
    V = V_new;
    A = A_new;
    P = P_new;
    Q = Q_new;
end
time = toc;
% Slack bus P and Q calculation:
V_complex = (V.*cos(A)) + (V.*sin(A))*i;
S = conj(V_complex).*((V_complex.*Y_diag_values)+(V_complex*Y_zero_diag));
P_Update = real(S);
Q_Update = -1*imag(S);
Missing_P = Missing_P + Slack_Bus;
Missing_Q = Missing_Q + Slack_Bus;
P = P_Update.*Missing_P + (P.*(1-Missing_P));
Q = Q_Update.*Missing_Q + (Q.*(1-Missing_Q));
% ------------------ PRINT RESULTS ---------------------
fprintf('------------- \n')
fprintf('Answer achieved on iteration #%d \n', k)
fprintf('Runtime to achieve result: %2.4fs\n', time)
fprintf('------------- \n')
fprintf('Results: \n')
VA_indexes = union(find(Missing_V==1),find(Missing_A==1));
P_indexes = find(Missing_P==1);
Q_indexes = find(Missing_Q==1);
for i = 1:length(VA_indexes);
    abs_V = V(VA_indexes(i));
    phase_V = A(VA_indexes(i));
    real_V = abs_V*cos(phase_V);
    imag_V = abs_V*sin(phase_V);
    fprintf('V%d = %2.4f+j%2.4f = %2.4f * exp(%2.4fj) (p.u.)\n',VA_indexes(i),real_V,imag_V,abs_V,phase_V)
end
for i = 1:length(P_indexes);
    fprintf('P%d = %2.4f (p.u.)\n',P_indexes(i),P(P_indexes(i)))
end
for i = 1:length(Q_indexes);
    fprintf('Q%d = %2.4f (p.u.)\n',Q_indexes(i),Q(Q_indexes(i)))
end