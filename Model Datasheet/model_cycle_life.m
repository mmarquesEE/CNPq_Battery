clc ,close all

data = csvread("Model Datasheet\Data\cycle_life.csv");

k = data(:, 1);
Cc0 = data(:, 2); 

f = @(n, a, k) a(1)*exp(-n*k/a(2)) + a(3);

Ne = 2;
Cc = Cc0;
CcOut = zeros(length(k),1);
a = zeros(Ne,3);

rng(200);
for i = 1:Ne
    a0 = [Cc(1), 500, 0]; 
    a(i,:) = lsqcurvefit(@(a,k) f(i,a,k), a0, k, Cc);
        
    Cc = Cc - f(i,a(i,:),k);
    CcOut = CcOut + f(i,a(i,:),k);
end
%%

display(['f = ',num2str(a(1,1),2), ...
    '*exp(-k/',num2str(a(1,2),2),') + ',num2str(a(2,1),2), ...
    '*exp(-k/',num2str(a(2,2),2),') + ',num2str(sum(a(:,3)),2)]);

%%
figure(1);
plot(k, Cc0, 'bo', 'DisplayName', 'Dados Originais');
hold on;
plot(k, CcOut, 'g-', 'LineWidth', 2, 'DisplayName', 'Modelo Exponencial');
xlabel('Ciclos de Vida');
ylabel('Capacidade');
grid on;
