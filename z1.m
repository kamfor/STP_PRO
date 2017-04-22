%zad1 
Gs = tf([2 22 48],[1 8 -65 -504]);
Gz = c2d(Gs,0.1,'zoh'); 

[l,m] = tfdata(Gz);

z = roots(l{1,1});
b = roots(m{1,1}); 

[A, B, C, D] = tf2ss(l{1,1},m{1,1});

A1 = A.'; 
C1 = B.'; 
B1 = C.'; 
D1 = 0; 

p0 = 0.4; 
p = [p0 p0 p0]; 
K = acker(A1,B1,p); 


%p3 - generowanie wykresu maksymalnego przyrostu sterowania 
i=0; 
for k=0.05:0.05:0.8
    i=i+1; 
    p = [k k k];
    K = acker(A1,B1,p);
    simOutC = sim('obiekt_regulator');  
    w_y = 0; 
    for m = 2:51
       if  reg.signals.values(m)-reg.signals.values(m-1) > w_y
           w_y = reg.signals.values(m)-reg.signals.values(m-1);           
       end
    end
    OUT(1,i) = k; 
    OUT(2,i) = w_y;
end

h = figure;
set(h,'units','points','position',[10,10,1000,800]); 
plot(OUT(1,:),OUT(2,:),'r','LineWidth', 2);
title('Zależność maksymalnego przyrostu sterowania od biegunów');
saveas(h,'3_1','png');

%wykres sterowania dla tych samych biegunów 
p0 = 0.55; 
p = [p0 p0 p0]; 
K = acker(A1,B1,p);
simOutC = sim('obiekt_regulator');
h = figure;
set(h,'units','points','position',[10,10,1000,800]); 
stairs(reg.time,reg.signals.values,'r','LineWidth', 1);
hold on; 
stairs(x1.time,x1.signals.values,'g','LineWidth', 1);
hold on; 
stairs(x2.time,x2.signals.values,'b','LineWidth', 1);
hold on; 
stairs(x3.time,x3.signals.values,'c','LineWidth', 1);
legend({'Sterowanie', 'x1', 'x2', 'x3'}, ...
    'Location', 'NorthEast');
title('Wykres sterowania dla tych samych biegónów');
saveas(h,'3_t','png');

% Biegun dominujący 
p = [0.4 0.4 0.7]; 
K = acker(A1,B1,p); 
simOutC = sim('obiekt_regulator');
h = figure;
set(h,'units','points','position',[10,10,1000,800]); 
stairs(reg.time,reg.signals.values,'r','LineWidth', 1);
hold on; 
stairs(x1.time,x1.signals.values,'g','LineWidth', 1);
hold on; 
stairs(x2.time,x2.signals.values,'b','LineWidth', 1);
hold on; 
stairs(x3.time,x3.signals.values,'c','LineWidth', 1);
legend({'Sterowanie', 'x1', 'x2', 'x3'}, ...
    'Location', 'NorthEast');
title('Wykres sterowania z biegunem dominującym');
saveas(h,'3_d','png');

%Obserwator zredukowanego rzędu 
AL11=A1(1,1);
AL12=A1(1,2:3);
AL21=A1(2:3,1);
AL22=A1(2:3,2:3);

BL1=B1(1,1);
BL2=B1(2:3,1);

%szybki
pl = [0.3 0.3]; 

aL1 = AL22.'; 
aL2 = AL12.';

L = acker(aL1, aL2, pl); 

simOutC = sim('obiekt_obserwator_regulator');
h = figure;
set(h,'units','points','position',[10,10,1000,800]); 
stairs(reg.time,reg.signals.values,'r','LineWidth', 1);
hold on; 
stairs(x1.time,x1.signals.values,'g','LineWidth', 1);
hold on; 
stairs(x2.time,x2.signals.values,'b','LineWidth', 1);
hold on; 
stairs(x3.time,x3.signals.values,'c','LineWidth', 1);
legend({'Sterowanie', 'x1', 'x2', 'x3'}, ...
    'Location', 'NorthEast');
title('Wykres sterowania z obserwatorem szybkim');
saveas(h,'4_b','png');




%wolny
pl = [0.8 0.8]; 

aL1 = AL22.'; 
aL2 = AL12.';

L = acker(aL1, aL2, pl); 

simOutC = sim('obiekt_obserwator_regulator');
h = figure;
set(h,'units','points','position',[10,10,1000,800]); 
stairs(reg.time,reg.signals.values,'r','LineWidth', 1);
hold on; 
stairs(x1.time,x1.signals.values,'g','LineWidth', 1);
hold on; 
stairs(x2.time,x2.signals.values,'b','LineWidth', 1);
hold on; 
stairs(x3.time,x3.signals.values,'c','LineWidth', 1);
legend({'Sterowanie', 'x1', 'x2', 'x3'}, ...
    'Location', 'NorthEast');
title('Wykres sterowania z obserwatorem wolnym');
saveas(h,'4_a','png');










