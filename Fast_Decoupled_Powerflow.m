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

Unknown_V = (1-Known_V)-[1,0,0];
Unknown_A = (1-Known_A)-[1,0,0];
Unknown_P = (1-Known_P)-[1,0,0];
Unknown_Q = (1-Known_Q)-[1,0,0];

Unknown_V_index = find(Unknown_V==1);
Unknown_A_index = find(Unknown_A==1);
Unknown_P_index = find(Unknown_P==1);
Unknown_Q_index = find(Unknown_Q==1);

[size1, size2] = size(Y);
Y_zero_diag = Y.*(1-eye(size1));
Y_diag_values = Y.*eye(size1);
Y_diag_values(Y_diag_values==0) = [];

B_Prime = imag(Y);
B_Prime(find(Slack_Bus==1),:) = [];
B_Prime(:,find(Slack_Bus==1)) = [];

B_Double_Prime = imag(Y);
Slack_and_PV_index = union(find(Slack_Bus==1),find(PV_Bus==1));
B_Double_Prime(Slack_and_PV_index,:) = [];
B_Double_Prime(:,Slack_and_PV_index) = [];


max_err = inf;
k = 0;
tic
while max_err > epsilon
    k = k+1; 
    fprintf('iteration = %d \n', k)
    
    % Calculate "Estimated P"
    Estimated_P = zeros(1,length(Known_P_index));
    ind = 0;
    for m = Known_P_index;
        ind = ind+1;
        for l = 1:size1;
            Estimated_P(ind) = Estimated_P(ind)+(abs(V(m))*abs(V(l))*abs(Y(m,l))*cos(angle(Y(m,l))+A(l)-A(m)));
        end
    end
    
    % Calculate "Estimated Q"
    Estimated_Q = zeros(1,length(Known_Q_index));
    ind = 0;
    for m = Known_Q_index;
        ind = ind+1;
        for l = 1:size1;
            Estimated_Q(ind) = Estimated_Q(ind)+(-1*abs(V(m))*abs(V(l))*abs(Y(m,l))*sin(angle(Y(m,l))+A(l)-A(m)));
        end
    end
    
    % Calculate "Delta P","Delta Q" and "Max Error"
    Delta_P = P(Known_P_index) - Estimated_P;
    Delta_Q = Q(Known_Q_index) - Estimated_Q;
    Delta_Matrix = [Delta_P';Delta_Q'];
    max_err = max(abs(Delta_Matrix));
    
    % Calculate "Delta V" and "Delta A"
    A_Update = -1*inv(B_Prime)*Delta_P';
    V_Update = -1*inv(B_Double_Prime)*Delta_Q';
    
    % Update V and A
    A(Unknown_A_index) = A(Unknown_A_index)+A_Update';
    V(Unknown_V_index) = V(Unknown_V_index)+V_Update';
end
time = toc;
% Slack bus P and Q calculation:
V_complex = (V.*cos(A)) + (V.*sin(A))*i;
S = conj(V_complex).*((V_complex.*Y_diag_values)+(V_complex*Y_zero_diag));
P_Update = real(S);
Q_Update = -1*imag(S);
Unknown_P = Unknown_P + Slack_Bus;
Unknown_Q = Unknown_Q + Slack_Bus;
P = P_Update.*Unknown_P + (P.*(1-Unknown_P));
Q = Q_Update.*Unknown_Q + (Q.*(1-Unknown_Q));
% ------------------ PRINT RESULTS ---------------------
fprintf('------------- \n')
fprintf('Answer achieved on iteration #%d \n', k)
fprintf('Runtime to achieve result: %2.4fs\n', time)
fprintf('------------- \n')
fprintf('Results: \n')
VA_indexes = union(find(Unknown_V==1),find(Unknown_A==1));
P_indexes = find(Unknown_P==1);
Q_indexes = find(Unknown_Q==1);
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