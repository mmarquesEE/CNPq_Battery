function [f,a] = model_cycle_life()

data = csvread("datasheet\Data\cycle_life.csv");

[k,Cc0] = preprocessData(data(:,1),data(:,2),1000);

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
figure;
plot(data(:,1), data(:,2), 'o', MarkerSize=10, DisplayName='Dados Originais');
hold on;

plot(k, CcOut, '-', LineWidth=1.3, DisplayName='Modelo Exponencial');
xlabel('Ciclos de Vida');
ylabel('Capacidade');
grid on;

end