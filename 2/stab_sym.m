function stab_sym()
    K_pid = zeros(1, 11);
    K_dmc = zeros(1, 11);
    for i = 1:1:11
        stabilny = true;
        while(stabilny)
            K_pid(i) = K_pid(i)+0.1;
            stabilny = stabilnosc_pid(transmitancja(K_pid(i), i/10.0));
        end;
    end    
    for i = 1:1:11
        display(['DMC', num2str(i)]);
        stabilny = true;
        while(stabilny & K_dmc<300)
            K_dmc(i) = K_dmc(i)+1;
            stabilny = stabilnosc_dmc(transmitancja(K_dmc(i), i/10.0));
        end;
    end
    display(K_pid);
    display(K_dmc);
end

function Gz = transmitancja(K, T)
K0 = 2.9*K;
T0 = 5*T;
T1 = 2.4;
T2 = 5.5;
Tp = 0.5;
s = tf('s');
Gs = K0*exp(-T0*s)/((T1*s+1)*(T2*s+1));
Gz = c2d(Gs, Tp, 'zoh');
end

function ret = stabilnosc_pid(Gz)
    ret = true;
    [Y, T] = pid(Gz);
    for y = Y(numel(Y)-30:numel(Y))
        ret = ret & (y < 1.1 & y > 0.9);
    end
end

function ret = stabilnosc_dmc(Gz)
    ret = true;
    [Y, T] = dmc(Gz);
    for y = Y(numel(Y)-30:numel(Y))
        ret = ret & (y < 1.1 & y > 0.9);
    end
end

function [Y_sim, T_sim]=dmc(Gz)
%%REGULATOR DMC

y_step = 1;
T_sim = 400*2;
D = 60;
N = 60;
Nu = 10;
l = 5;
denominator = Gz.Denominator{1};
numerator = Gz.Numerator{1};
delay = Gz.OutputDelay;
display(delay);
y_k_1 = -denominator(2); %1.725;           %y(k-1)
y_k_2 = -denominator(3); %-0.7414;         %y(k-2)
u_k_11 = numerator(2); %0.0249;         %u(k-11)
u_k_12 = numerator(3); %0.0225;         %u(k-12)

y = zeros(N, 1);
u = ones(N, 1);
y(delay+2)=y_k_1*y(delay+1) + y_k_2*y(delay) + u_k_11;
for k=delay+3:N
   y(k)=y_k_1*y(k-1) + y_k_2*y(k-2) + u_k_11*u(k-delay-1) + u_k_12*u(k-delay-2);
end

yk=0; 
uk=0; 
du_hist = zeros(D-1,1); 


Mp=zeros(N, D-1);
for i=1:N
   for j=1:D-1
      if i+j <= D
         Mp(i,j)=y(i+j)-y(j);
      else
         Mp(i,j)=y(D)-y(j);
      end;      
   end;
end;

M=zeros(N, Nu);
for i=1:N
   for j=1:Nu
      if (i >= j)
         M(i, j)=y(i-j+1);
      end;
   end;
end;

I=eye(Nu);
K=((M'*M+l*I)^(-1))*M';

U = zeros(1, T_sim);
Y = zeros(1, T_sim);

for i=1:T_sim
   
   if i==delay+2
       yk=y_k_1*yk+y_k_2*y(i-2)+u_k_11;
   end
   if i>=delay+3
       yk=y_k_1*Y(i-1)+y_k_2*Y(i-2)+u_k_11*U(i-delay-1)+u_k_12*U(i-delay-2);
   end
   
   du = K(1,:)*(y_step*ones(N,1) - yk*ones(N,1) - Mp*du_hist);
   du_hist = [du; du_hist(1:end-1)];
   uk = uk + du_hist(1);
   
   U(i) = uk;
   Y(i) = yk;
end

Y_sim = [0 y_step*ones(1, T_sim)];
T_sim = 0:T_sim;
end

function [Y, T] = pid(Gz)
    Kk = 0.817;
    Tk = 21;
    Kr = 0.6*Kk; Ti = 0.5*Tk; Td = 0.12*Tk;
    K0 = 2.9;
    T0 = 5;
    T1 = 2.4;
    T2 = 5.5;
    Tp = 0.5;
    r2 = Td;
    r1 = Tp/Ti - Kr - 2*Td;
    r0 = Kr + Td;
    z = tf('z');
    Rz = (r2*z^(-2)+r1*z^(-1)+r0)/(1-z^(-1));
    Guz = feedback(Rz*Gz, 1);
    [Y, T] = step(Guz, 400);
end