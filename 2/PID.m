%% Symulacja ciągłedo regulatora PID
%% inicjalizacja
Kp=0.35;
Ki=0.035; 
Kd=0.7;
K0 = 3.5;
T0 = 5; 
T1 = 2;
T2 = 5.02;
Tp = 0.5;
t_sym = 100; 
%% symulacja regulatora ciaglego
s = tf('s');
G = K0*exp(-T0*s)/((T1*s+1)*(T2*s+1));
R = Kp+(Ki/s)+Kd*s;
Gu = feedback(R*G,1);

h = figure;
set(h,'units','points','position',[10,10,800,500]); 
y=step(Gu,0:0.1:t_sym);
t=0:0.1:t_sym;
plot(t,y);
title('PID metoda Zieglera-Nicholsa poprawiony');
saveas(h,'2_1_1','png');

%% dyskretny regulator PID
r_2=Kd;
r_1=Ki*Tp-Kp-2*Kd;
r_0=Kp+Kd;
z = tf('z');
Gd = c2d(G,0.5,'zoh');
Rd = (r_2*z^(-2)+r_1*z^(-1)+r_0)/(1-z^(-1));
Gu = feedback(Rd*Gd,1);

h = figure;
set(h,'units','points','position',[10,10,800,500]); 
y=step(Gu,0:0.5:t_sym);
t=0:0.5:t_sym;
stairs(t,y);
title('dyskretny regulator PID');
saveas(h,'2_2','png');

