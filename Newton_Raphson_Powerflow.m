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

max_err = inf;
k = 0;
tic
while max_err > epsilon
    k = k+1; 
    fprintf('iteration = %d \n', k)
    Estimated_P = zeros(1,length(Known_P_index));
    ind = 0;
    for m = Known_P_index;
        ind = ind+1;
        for l = 1:size1;
            Estimated_P(ind) = Estimated_P(ind)+(abs(V(m))*abs(V(l))*abs(Y(m,l))*cos(angle(Y(m,l))+A(l)-A(m)));
        end
    end
    
    Estimated_Q = zeros(1,length(Known_Q_index));
    ind = 0;
    for m = Known_Q_index;
        ind = ind+1;
        for l = 1:size1;
            Estimated_Q(ind) = Estimated_Q(ind)+(-1*abs(V(m))*abs(V(l))*abs(Y(m,l))*sin(angle(Y(m,l))+A(l)-A(m)));
        end
    end
    Delta_P = P(Known_P_index) - Estimated_P;
    Delta_Q = Q(Known_Q_index) - Estimated_Q;
    
    Delta_Matrix = [Delta_P';Delta_Q'];
    max_err = max(abs(Delta_Matrix));
%     if max_err < epsilon
%         break
%     end
    
    %--------- J1 ----------
    J1 = zeros(length(Known_P_index),length(Known_P_index));
    w = 0;
    x = 0;
    for a = Known_P_index;
        w = w+1;
        for b = Known_P_index;
            x = x+1;
            if a==b
                m=b;
                for l = 1:size1;
                    if m~=l
                        J1(w,x) = J1(w,x)+(abs(V(m))*abs(V(l))*abs(Y(m,l))*sin(angle(Y(m,l))+A(l)-A(m)));
                    end
                end
            else
                J1(w,x) = -1*abs(V(a))*abs(V(b))*abs(Y(a,b))*sin(angle(Y(a,b))+A(b)-A(a));
            end
        end
        x = 0;
    end
    %--------- J3 ----------
    J3 = zeros(length(Known_Q_index),length(Known_P_index));
    w = 0;
    x = 0;
    for a = Known_Q_index;
        w = w+1;
        for b = Known_P_index;
            x = x+1;
            if a==b
                m = b;
                for l = 1:size1;
                    if m~=l
                        J3(w,x) = J3(w,x)+(abs(V(m))*abs(V(l))*abs(Y(m,l))*cos(angle(Y(m,l))+A(l)-A(m)));
                    end
                end
            else
                J3(w,x) = -1*abs(V(a))*abs(V(b))*abs(Y(a,b))*cos(angle(Y(a,b))+A(b)-A(a));
            end
        end
        x = 0;
    end
    
    %--------- J2 ----------
    J2 = zeros(length(Known_P_index), length(Known_Q_index));
    w = 0;
    x = 0;
    for a = Known_P_index;
        w = w+1;
        for b = Known_Q_index;
            x = x+1;
            if a==b
                m = b;
                for l = 1:size1;
                    if m~=l
                        J2(w,x) = J2(w,x)+(abs(V(l))*abs(Y(m,l))*cos(angle(Y(m,l))+A(l)-A(m)));
                    end
                end
                J2(w,x) = (2*abs(V(m))*abs(Y(m,m))*cos(angle(Y(m,m)))) + J2(w,x);
            else
                J2(w,x) = abs(V(a))*abs(Y(a,b))*cos(angle(Y(a,b))+A(b)-A(a));
            end
        end
        x = 0;
    end
    %--------- J4 ----------
    J4 = zeros(length(Known_Q_index), length(Known_Q_index));
    w = 0;
    x = 0;
    for a = Known_Q_index;
        w = w+1;
        for b = Known_Q_index;
            x = x+1;
            if a==b
                m=b;
                for l = 1:size1;
                    if m~=l
                        J4(w,x) = J4(w,x)+(abs(V(l))*abs(Y(m,l))*sin(angle(Y(m,l))+A(l)-A(m)));
                    end
                end
                J4(w,x) = -(2*abs(V(m))*abs(Y(m,m))*sin(angle(Y(m,m)))) - J4(w,x);
            else
                J4(w,x) = -1*abs(V(b))*abs(Y(a,b))*sin(angle(Y(a,b))+A(b)-A(a));
            end
        end
        x = 0;
    end
    
    J = [J1, J2;
         J3, J4];
    J(find(abs(J)<=1e-8)) = 0;
    
    Update = inv(J)*Delta_Matrix;
    
    A_Update = Update(1:sum(Unknown_A));
    A(Unknown_A_index) = A(Unknown_A_index)+A_Update';
    
    V_Update = Update(sum(Unknown_A)+1:end);
    V(Unknown_V_index) = V(Unknown_V_index)+V_Update';
    
    
    S = conj(V).*((V.*Y_diag_values)+(V*Y_zero_diag));
    P_Update = real(S);
    Q_Update = -1*imag(S);
    
    P_new = P_Update.*Unknown_P + (P.*(1-Unknown_P));
    Q_new = Q_Update.*Unknown_Q + (Q.*(1-Unknown_Q));
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