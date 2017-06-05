%% inicjalizacja
clear all; 
K = 3.5; 
T0 = 5; 
T1 = 2;
T2 = 5.02;
s1 = 10.04; 
s2 = 7.02; 
s3 = 1; 
t_sym=50;
y_zad=1;

%% Obliczenie transmitancji dyskretnej
s = tf('s');
G = K*exp(-T0*s)/(s1*s^2+s2*s+s3);
Gd = c2d(G,0.5,'zoh');
%% odpowiedz skokowa
h = figure;
set(h,'units','points','position',[10,10,800,500]); 
y=step(G,0:0.5:t_sym);
y1=step(Gd,0:0.5:t_sym);
t=0:0.5:t_sym;
plot(t,y);
hold on;
stairs(t,y1); 
title('Porównanie transmitancji ciągłej i dyskretnej');
saveas(h,'1_1','png');
%% wspólczynniki wzmocnienia statycznego 
syms s z
k_s = limit(((5*exp(-5*s))/(10.08*s^2+6.74*s+1)),s,0)
k_z = limit((0.05552*z^(-11)+0.04967*z^(-12))/(1-1.695*z^(-1)+0.7158*z^(-2)),z,1)