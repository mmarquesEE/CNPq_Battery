function [x,y] = preprocessData(dataX,dataY,n,opts)

arguments
    dataX double
    dataY double
    n int64
    opts.PolyOrder = 5;
end

x = linspace(dataX(1),dataX(end),n)';
p = polyfit(dataX,dataY,opts.PolyOrder);
y = polyval(p,x);

end

