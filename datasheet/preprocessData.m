function [x,y] = preprocessData(dataX,dataY,n)

arguments
    dataX double
    dataY double
    n int64
end

[dX,idx,~] = unique(dataX);
dY = dataY(idx);

x = linspace(dX(1),dX(end),n)';
p = polyfit(dX,dY,11);
y = polyval(p,x);

end

