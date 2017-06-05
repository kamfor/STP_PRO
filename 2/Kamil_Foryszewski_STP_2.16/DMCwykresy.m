h = figure;
set(h,'units','points','position',[10,10,800,500]);
DMC
subplot(211)
stairs(0:t_sym,[0 y_zad*ones(1,t_sym)],'r');
hold on
subplot(211)
plot(fdmc(80,80,1),'g');
ylabel('y, y_{zad}')
hold on
subplot(212)
stairs(0:t_sym,[0 ddmc(80,80,1)],'g');
hold on; 
xlabel('czas (Tp)');
ylabel('u')
subplot(211)
plot(fdmc(60,60,1),'b');
hold on
subplot(212)
stairs(0:t_sym,[0 ddmc(60,60,1)],'b');
hold on
subplot(211)
plot(fdmc(40,40,1),'k');
hold on
subplot(212)
stairs(0:t_sym,[0 ddmc(40,40,1)],'k');
hold on
subplot(211)
plot(fdmc(20,20,1),'c');
hold on
subplot(212)
stairs(0:t_sym,[0 ddmc(20,20,1)],'c');
hold on
 