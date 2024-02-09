clc ,close all

data = csvread("Model Datasheet\Data\Caracteristica_de_descarga_0.2C.csv");

Cc = data(:, 1);
V0 = data(:, 2); 

f = @(a,x) -a(1)*atan(-a(2)*x) + a(3);

a = lsqcurvefit(f, [4/(pi/2),1,1,2], Cc, V0)

%%
figure(1);
plot(Cc, V0, 'bo', 'DisplayName', 'Dados Originais');
hold on;
plot(Cc, f(a,Cc), 'g-', 'LineWidth', 2, 'DisplayName', 'Modelo Logarítmico');
xlabel('Capacidade de descarga');
ylabel('Tensão');
grid on;
