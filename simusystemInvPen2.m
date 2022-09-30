% CONTROL POR MODOS DESLIZANTES BASADO...
% EN UN OBSERVADOR DE PERTURBACIONES
clc
clear all
close all
ti = 0;
T  = 0.01; 
tf = 30;
t = (ti:T:tf)';
x = [0.1 0.3];
z = [0 0];
m = 0.1;
mc = 1;
l  = 0.5;
g  = 9.81;
d  = 0;
xdp = [0; 0];
v   = 0.05;
dh  = -1.0;
alfa = 1;
u = 0;
%z = 0;
for i = 1 : length(t)-1
    [tt,xx,zz] = ode45(@modelsystem3,[t(i) t(i+1)],x(i,:),z(i,:),[],u(i),d(i));
    x(i+1,:) = xx(end,:);
    z(i+1,:) = zz(end,:); 
    %----------------- Superficie de deslizamiento -----------------
    e1 = x(i+1,1)-0; 
    e2 = x(i+1,2)-0;
    C = [1.3 ,2];
    Sigma = C*[e1;e2];
    % ---------------------- PERTURBACION ---------------------------
    d(i+1) = 0.2*sin(x(i+1,1)*x(i+1,2)); 
    %----------------------- OBSERVADOR -----------------------------
    lx = [0 1];
    px(i+1) = x(i+1,2);
    Bx = 1;
    %fx = [x(i+1,2); ((g*sin(x(i+1,1)))- (m*l*x(i+1,2)*x(i+1,2)*cos(x(i+1,1))*sin(x(i+1,1))))/(l*(l*(4/3-(m*cos(x(i+1,1))*cos(x(i+1,1))/(mc+m)))))];
    %g1 = [0; ((cos(x(i+1,1))*sin(x(i+1,1)))/(mc+m))/(l*(4/3-((m*cos(x(i+1,1))*cos(x(i+1,1)))/(mc+m))))];
    fx = [x(i+1,2); (g*sin(x(i+1,1))-(m*l*(x(i+1,2))^2*cos(x(i+1,1))*sin(x(i+1,1)))/(mc+m)) /(l*(4/3-m*cos(x(i+1,1))^2/(mc+m)))];
    g1 = [0; (cos(x(i+1,1))/(mc+m)) / (l*(4/3-m*cos(x(i+1,1))^2/(mc+m)))];
    g2 = [0; 1];
    %z(i+1)=dh(i)-px(i+1);  
    zp(i+1) =-lx*g2*z(i+1)-lx*g2*px(i+1)-lx*fx-lx*g1*u(i);
    %zint(i+1) = (0.01)*(zp(i+1))+zint(i);
    dh(i+1) = z(i+1)+px(i+1);
    %----------Control U con la funcion de saturación
    if (abs(Sigma/v) <= 1) 
        u(i+1) = -inv(C*g1)*(C*fx-C*xdp+C*g2*dh(i+1)+alfa*(Sigma/v)+(abs(Sigma*C*g2)^2)/Bx);
    else
        u(i+1) = -inv(C*g1)*(C*fx-C*xdp+C*g2*dh(i+1)+alfa*sign(Sigma/v)+(abs(Sigma*C*g2)^2)/Bx);
    end 
    
    % Error de estimación de la perturbación
    dtilde(i+1) = d(i+1) - dh(i+1);
    %--------------------- Salida ----------------------------------
    y(i+1) = x(i+1,1);  
end
%Grafica de los estados
figure(1)
plot(t,x(:,1)) 
hold on
plot(t,x(:,2))
hold on
legend('x1[Grados]','x2[Grados/s]')
ylabel('Estados')
xlabel('Tiempo [seg]')
grid
hold off
%Grafica de la perturbación 
figure(2)
plot(t,d) 
legend('d') 
ylabel('Perturbación d')
xlabel('Tiempo [seg]')
grid
%Grafica de la ley de contro U
figure(3)
plot(t,u) 
legend('u [N]')
ylabel('Entrada de control (u)')
xlabel('Tiempo [seg]')
ylim([-3 3])
grid
%Grafica de la ley de contro U
figure(4)
plot(t,dtilde) 
legend('d (tilde) [N]')
ylabel('Error de perturbación')
xlabel('Tiempo [seg]')
grid