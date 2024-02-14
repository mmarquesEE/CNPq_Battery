function [f,a] = model_discharge_characteristics()
close all

data = csvread("datasheet\Data\Caracteristica_de_descarga_1C.csv");

[Cc,VoC0] = preprocessData(data(:,1),data(:,2),1000);

f = @(a,x) a(1)*exp(-x/a(2)) + a(3)*exp(x/a(4)) + a(5);

Ne = 5;
VoC = VoC0;
VoCOut = zeros(length(Cc),1);
a = zeros(Ne,5);

rng(200);
for i = 1:Ne
    a0 = [VoC(1), 1/(1e-3*i), VoC(1), 1/(1e-4*i), 0]; 
    a(i,:) = lsqcurvefit(f, a0, Cc, VoC);
        
    VoC = VoC - f(a(i,:),Cc);
    VoCOut = VoCOut + f(a(i,:),Cc);
end
%%
s = @(a) num2str(a,3);

disp('f = ');
for i = 1:Ne
    disp(['+ ',s(a(i,1)),'*exp(-x/',s(a(i,2)),') + ',...
        s(a(i,3)),'*exp(x/',s(a(i,4)),')'])
end

disp(['+ ',s(sum(a(:,5)))]);

%%
figure;
plot(data(:,1), data(:,2), 'o', MarkerSize=10, DisplayName='Dados Originais');
hold on;

plot(Cc, VoCOut, '-', LineWidth=1.3, DisplayName='Modelo Exponencial');
xlabel('Capacidade de descarga');
ylabel('Tensão da bateria');
grid on;

%%
end