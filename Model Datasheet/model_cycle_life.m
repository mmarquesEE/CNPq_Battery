data = csvread('Cycle Life/cycle_life.csv');

cycleLife = data(:, 1);
capacity = data(:, 2); 

model_exp = @(a, x) a(1) * exp(a(2) * (x - a(3))) + a(4)*exp(a(5)*x) + a(6) ;


x0 = [3300, 1/500 , 0 , 0, -130, 10/500]; 

[x,resnorm,~,exitflag,output] = lsqcurvefit(model_exp, x0, cycleLife, capacity);


figure(1);
plot(cycleLife, capacity, 'bo', 'DisplayName', 'Dados Originais');
hold on;
plot(cycleLife, model_exp(x,cycleLife), 'g-', 'LineWidth', 2, 'DisplayName', 'Modelo Exponencial');
xlabel('Ciclos de Vida');
ylabel('Capacidade');
grid on;


fprintf('a = %.2f, b = %.2f\n, c = %.2f\n, d = %.2f\n, e = %.2f\n, f = %.2f\n', x(1), x(2), x(3), x(4), x(5), x(6));
