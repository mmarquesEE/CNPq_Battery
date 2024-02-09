clc, close all

data = csvread("Data\Caracteristica_de_descarga_0.2C.csv");

Cc = data(:, 1);
V = data(:, 2);

a = fit(Cc, V, 'smoothingspline');

coef = coeffvalues(a)


%%
figure(1);
plot(Cc, V, 'bo-', 'DisplayName', 'Dados Originais');
hold on;
plot(Cc, CcOut, 'r-', 'LineWidth', 2, 'DisplayName', 'Spline Cúbico');
xlabel('Capacidade de descarga ');
ylabel('Tensão(V)');
title('Modelo - Capacidade de descarga(Ah) (by Taxa 0.2C)');
legend;
grid on;


