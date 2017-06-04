function stab_sym()
    %% Porównanie PID i DMC

    
    [Y_pid T_pid] = pid(get_gz(1,1)); 
    [Y_dmc T_dmc] = dmc(get_gz(1,1)); 
   
   
    h = figure;
    set(h,'units','points','position',[10,10,800,500]); 
    stairs(0:100,[0 1*ones(1,100)],'r');
    hold on
    stairs(T_dmc,Y_pid,'g');
    hold on
    stairs(T_dmc,Y_dmc,'b');
    legend({'y^{zad}', 'PID', 'DMC'}, ...
    'Location', 'NorthWest')
    
    title('Porównanie DMC i PID');
    saveas(h,'PIDiDMC','png');





    %% stabilność PID
    K_pid = zeros(1, 11);
    T_p = 1:0.1:2; 
    K_dmc = zeros(1, 11);
    
%     for i = 1:1:11
%         K_pid(i) = 1;
%         stable = pid_stability(get_gz(K_pid(i), 1+i/10.0));
%         while(stable)
%             K_pid(i) = K_pid(i)+0.01;
%             stable = pid_stability(get_gz(K_pid(i), 1+i/10.0));
%         end;
%     end   
  
    %% wykres stabilności PID
    
%     h = figure;
%     set(h,'units','points','position',[10,10,800,500]); 
%     plot(T_p,K_pid); 
%     title('Krzywa stabilności regulacji PID');
%     xlabel('T_0/T_0^{nom}')
%     ylabel('K_0/K_0^{nom}')
%     saveas(h,'pid_stability','png');
    
    %% Badanie stabilności DMC
    
%     for i = 1:1:11
%         K_dmc(i) = 1;
%         stable = dmc_stability(get_gz(K_dmc(i), i/10.0));
%         while(stable & K_dmc(i)<100)
%             K_dmc(i) = K_dmc(i)+1;
%             stable = dmc_stability(get_gz(K_dmc(i), i/10.0));
%         end;
%     end
    
    %% wykres stabilności DMC
    
%     h = figure;
%     set(h,'units','points','position',[10,10,800,500]); 
%     plot(T_p,K_dmc); 
%     title('Krzywa stabilności regulacji DMC');
%     xlabel('T_0/T_0^{nom}')
%     ylabel('K_0/K_0^{nom}')
%     saveas(h,'DMC_stability','png');
    
end

%% transmitancja dyskretna układu

function Gz = get_gz(K, T) 
    K0 = 3.5*K;
    T0 = 5*T;
    T1 = 2;
    T2 = 5.02;
    Tp = 0.5;
    s = tf('s');
    Gs = K0*exp(-T0*s)/((T1*s+1)*(T2*s+1));
    Gz = c2d(Gs, Tp, 'zoh');
end

%% odpowiedź skokowa układu z reguatorem dyskretnym PID

function [Y, T] = pid(Gz)
    Kp=0.35;
    Ki=0.035; 
    Kd=0.7;
    Tp = 0.5; 
    r_2=Kd;
    r_1=Ki*Tp-Kp-2*Kd;
    r_0=Kp+Kd;
    z = tf('z');
    Rz = (r_2*z^(-2)+r_1*z^(-1)+r_0)/(1-z^(-1));
    Guz = feedback(Rz*Gz, 1);
    [Y, T] = step(Guz, 0.5:0.5:50);

end

%% badanie stabilności regulacji

function response = pid_stability(Gz)
    response = true;
    [Y, T] = pid(Gz);
    for y = Y(numel(Y)-50:numel(Y))
        response = response & (y < 1.1 & y > 0.9); 
    end
end

%% odpowiedź skokowa układu z reguatorem DMC

function [Y_out, T_out] = dmc(Gz)

    y_step=1;
    T_sim=100; 
    D=60;
    N=60;
    Nu=7;
    l=10;
    
    denominator = Gz.Denominator{1};
    numerator = Gz.Numerator{1};
    delay = Gz.OutputDelay;
    
    display(delay)
    
    y_k_1 = -denominator(2);
    y_k_2 = -denominator(3);
    u_k_11 = numerator(2);
    u_k_12 = numerator(3);

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
    
    Y_out = Y;
    T_out = 1:T_sim;
   
end


%% Badanie stabilności regulatora DMC

function response = dmc_stability(Gz)
    response = true;
    [Y, T] = dmc(Gz);
    for y = Y(numel(Y)-50:numel(Y))
        response = response & (y < 1.1 & y > 0.9);
    end
end


