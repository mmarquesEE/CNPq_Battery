clear all,clc ,close all

data = csvread("Model Datasheet\Data\cycle_life.csv");

k = data(:, 1);
Cc0 = data(:, 2); 

f = @(a, k) a(1)*exp(-k/a(2)) + a(3);

Ne = 2;
Cc = Cc0;
CcOut = zeros(length(k),1);
a = zeros(Ne,3);

rng(200);
for i = 1:Ne
    a0 = [Cc(1), 500/i, 0]; 
    a(i,:) = lsqcurvefit(f, a0, k, Cc);
        
    Cc = Cc - f(a(i,:),k);
    CcOut = CcOut + f(a(i,:),k);
end
%%
np = 3;
display(['f = ',num2str(a(1,1),np), ...
    '*exp(-k/',num2str(a(1,2),np),') + ',num2str(a(2,1),np), ...
    '*exp(-k/',num2str(a(2,2),np),') + ',num2str(sum(a(:,3)),np)]);

%%
figure(1);
plot(k, Cc0, 'bo', 'DisplayName', 'Dados Originais');
hold on;
%%
plot(k, CcOut, 'g-', 'LineWidth', 2, 'DisplayName', 'Modelo Exponencial');
xlabel('Ciclos de Vida');
ylabel('Capacidade');
grid on;
