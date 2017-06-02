function [ U ] = ddmc( D, Nu, l  )

y_zad=1;        % wartosc zadana
t_sym=100;       % czas symulacji
%D=60;           % horyzont dynamiki 
N=D;           % horyzont predykcji 
%Nu=7;          % horyzont sterowania
%l=1;           % kara za przyrosty sterowania
y_k=0;          % aktualne wyjscie
u_k=0;          % aktualne sterowanie
y=zeros(N,1);
u=ones(N,1);
d_uh=zeros(D-1,1); 
M=zeros(N,Nu);
U=zeros(1,t_sym);
Y=zeros(1,t_sym);

%% Identyfikacja odpowiedzi skokowej 

y(12)=1.684*y(11)-0.705*y(10)+0.0388; 
for k=13:N
   y(k)=1.684*y(k-1)-0.705*y(k-2)+0.0388*u(k-11)+ 0.0346*u(k-12); 
end

%% macierze i parametry regulatora

for i=1:N
   for j=1:Nu
      if (i>=j)
         M(i,j)=y(i-j+1);
      end
   end
end

for i=1:N
   for j=1:D-1
      if i+j<=D
         Mp(i,j)=y(i+j)-y(j);
      else
         Mp(i,j)=y(D)-y(j);
      end    
   end
end

L=M'*M;
I=eye(Nu);
K=((M'*M+l*I)^(-1))*M';

%% symulacja

for i=1:t_sym
   
   if i==12
       y_k=1.684*y_k-0.705*y(i-2)+0.0388;
   end
   if i>=13
       y_k=1.684*Y(i-1)-0.705*Y(i-2)+0.0388*U(i-11)+0.0346*U(i-12);
   end
   
   du=K(1,:)*(y_zad*ones(N,1)-y_k*ones(N,1)-Mp*d_uh);
   d_uh=[du;d_uh(1:end-1)];
   u_k=u_k+d_uh(1);
   
   U(i)=u_k;
   Y(i)=y_k;
end

end


