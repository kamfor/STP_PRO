%% inicjalizacja
K = 3.5; 
T0 = 5; 
T1 = 2;
T2 = 5.02;
s1 = 10.04; 
s2 = 7.02; 
s3 = 1; 

%% Obliczenie transmitancji dyskretnej

s = tf('s');
G = K*exp(-T0*s)/(s1*s^2+s2*s*s3);
Gd = c2d(G,0.5,'zoh');
G2 = 1*exp(-5*s)/(100*s+1);
%% odpowiedz skokowa
% y=step(Gd);
% step(Gd) 
% hold on;
figure;
czas_sym=50;
y_zad=1;
% subplot(1,2,2)
% step(G,czas_sym)
% hold on;
% stairs(0:czas_sym,[0 0 0 0 0 y_zad*ones(1,czas_sym-4)],'c:');
% title('b) Obiekt dwuinercyjny');
% subplot(1,2,1)
y=step(G,0:0.5:czas_sym);
t=0:0.5:czas_sym;
plot(t,y)
dy=diff(y')./diff(t);
k=30; % point number 220
tang=(t-t(k))*dy(k)+y(k);
hold on
plot(t,tang)
scatter(t(k),y(k))
hold off
% hold on;
% stairs(0:czas_sym,[0 0 0 0 0 y_zad*ones(1,czas_sym-4)],'c:');
% title('Obiekt jednoinercyjny');
% ylim([-0.2 1.2])
% xlim([0 czas_sym])
%% wspólczynniki wzmocnienia statycznego 
syms s z
k_s = limit(((5*exp(-5*s))/(10.08*s^2+6.74*s+1)),s,0)
k_z = limit((0.05552*z^(-11)+0.04967*z^(-12))/(1-1.695*z^(-1)+0.7158*z^(-2)),z,1)