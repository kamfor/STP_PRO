%% Symulacja algorytmu DMC (Dynamic Matrix Control)
%% Inicjalizacja 
clear all; 
y_zad=1;    
t_sym=100; 
D=20;       %horyzont dynamiki
N=20;       %horyzont predykcji
Nu=10;      %horyzont sterowania
l=10;       %parametr kary

%% Identyfikacja odpowiedzi skokowej 
y=zeros(N,1); 
u=zeros(N,1); 

y(12)=1.684*y(11)-0.705*y(10)+0.388; 
for k=13:N
   y(k)=1.684*y(k-1)-0.705*y(k-2)+0.388*u(k-11)+ 0.0346*u(k-12); 
end

%% to do edycji 
%% inicjalicaja
yk=0; % aktualne wyjscie
uk=0; % aktualne sterowanie
du_hist = zeros(D-1,1); %przeszle przyrosty

%% macierze i parametry regulatora
M=zeros(N,Nu);
for i=1:N
   for j=1:Nu
      if (i>=j)
         M(i,j)=y(i-j+1);
      end;
   end;
end;

Mp=zeros(N,D-1);
for i=1:N
   for j=1:D-1
      if i+j<=D
         Mp(i,j)=y(i+j)-y(j);
      else
         Mp(i,j)=y(D)-y(j);
      end;      
   end;
end;
L=M'*M;
I=eye(Nu);
K=((M'*M+lambda*I)^(-1))*M';

%% symulacja
U = zeros(1,czas_sym);
Y = zeros(1,czas_sym);

for i=1:czas_sym
   
   if i==12
       yk=1.695*yk-0.7158*y(i-2)+0.05552;
   end
   if i>=13
       yk=1.695*Y(i-1)-0.7158*Y(i-2)+0.05552*U(i-11)+0.04967*U(i-12);
   end
   
   du=K(1,:)*(y_zad*ones(N,1)-yk*ones(N,1)-Mp*du_hist);
   du_hist=[du;du_hist(1:end-1)];
   uk=uk+du_hist(1);
   
   U(i)=uk;
   Y(i)=yk;
end

%% wykresy
figure;
subplot(211)
plot(Y,'b');
hold on;
stairs(0:czas_sym,[0 y_zad*ones(1,czas_sym)],'c:');
ylabel('y, y_{zad}')
xlabel('czas (Tp)');
ylim([0 1.5]); hold on
subplot(212)
stairs(0:czas_sym,[0 U],'m');
xlabel('czas (Tp)');
ylabel('u')
ylim([0 1.5]);
xlim([0 80])