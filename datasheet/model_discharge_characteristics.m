function [f,a] = model_discharge_characteristics()
close all

data = csvread("datasheet\Data\Caracteristica_de_descarga_1C.csv");

[x,y0] = preprocessData(data(:,1),data(:,2),1000);

flin = @(a,x) a(1)*x + a(2);
fexp = @(a,x) a(1)*exp(x/a(2)) + a(3);

y = y0;

%% Faixa linear
ktol = 10;
h = mean(diff(x));

a = [1,0];
alin = [];
while a(1) > 1e-3
    dy = gradient(y,h);
        ddy = gradient(dy,h);
    
    minAbs_ddy = min(abs(ddy));
    linIdx = abs(ddy) <= ktol*minAbs_ddy;
    
    xlin = x(linIdx);
    ylin = y(linIdx);
    
    a = lsqcurvefit(flin,[1,0],xlin,ylin);
    alin = [a;alin];
    
    figure(1);
    plot(x,y,x,flin(alin,x))
    y = y - flin(alin,x);
    pause(0.5);
end

%% Faixa exponencial


end