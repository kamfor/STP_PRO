%% Symulacja ciągłedo regulatora PID
%% inicjalizacja
Kp=0.37884;
Ki=0.03714; 
Kd=0.14856;
T2 = 5.02;
s1 = 10.04; 
s2 = 7.02; 
T0 = 5; 
t_sym = 100; 
%% symulacja regulatora ciaglego
s = tf('s');
G = K*exp(-T0*s)/(s1*s^2+s2*s+s3);
R = Kp+(Ki/s)+Kd*s;
Gu = feedback(R*G,1);

h = figure;
set(h,'units','points','position',[10,10,800,500]); 
y=step(Gu,0:0.1:t_sym);
t=0:0.1:t_sym;
plot(t,y);
title('PID metoda Zieglera-Nocholsa');
saveas(h,'2_1','png');

%% dyskretny regulator PID
r_2=0.14856;
r_1=-0.672246;
r_0=0.5274;
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

