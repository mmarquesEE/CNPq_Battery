function [x,y] = preprocessData(dataX,dataY,n)

x = linspace(dataX(1),dataX(end),n)';
y = interp1(dataX,dataY,x);

end

