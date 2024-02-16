function varargout = model_discharge_characteristics(varargin,opts)

arguments (Repeating)
    varargin
end
arguments
    opts.CloseFigures = false;
    opts.Plot = false;
    opts.difftol = 0.01;
    opts.disttol = 0.01;
    opts.cutoffVoltage = 2.56;
    opts.cutoffDischargeCapacity = 10;
end

narginchk(0,3);
nargoutchk(0,4);

if nargin < 1
    data = csvread("datasheet\Data\Caracteristica_de_descarga_-10º.csv");
elseif nargin < 2
    validateattributes(varargin{1},{'string'},{'scalartext'},...
        'model_discharge_characteristics','',1);
    data = csvread(varargin{1});
else
    for i = 1:2
        validateattributes(varargin{i},{'numeric'},{'column'},...
            'model_discharge_characteristics','',i);    
    end
    data = [varargin{1},varargin{2}];
end

if nargout < 1
    Plot = true;
else
    Plot = opts.Plot;
end

if opts.CloseFigures
    close all
end

dataX = data(:,1);
dataY = data(:,2);

conditions = dataY >= opts.cutoffVoltage & ...
             dataX >= opts.cutoffDischargeCapacity;

dataX = dataX(conditions);
dataY = dataY(conditions);

if nargin > 2
    validateattributes(varargin{3},{'numeric'},...
        {'scalar','integer','positive'});
    n = varargin{3};
else
    n = 200;
end

[x,y0] = preprocessData(dataX,dataY,n);

flinear = @(a,x) a(1)*x + a(2);
fexp    = @(a,x) a(1)*exp(x/a(2));
y = y0;

%% Faixa linear
difftol = opts.difftol;
disttol = opts.disttol;

h = mean(diff(x));

a0 = [1,0];

dy = gradient(y,h);
ddy = gradient(dy,h);

maxAbs_ddy = max(abs(ddy));
linIdx = find(abs(ddy)/maxAbs_ddy <= difftol);

xlin = x(linIdx);
ylin = y(linIdx);

[alinear,resnorm_linear] = lsqcurvefit(flinear,a0,xlin,ylin);
ylout = flinear(alinear,x);

maxAbsD = max(abs(y - ylout));
cutYidx = find(abs(y - ylout)/maxAbsD <= disttol);

if Plot
    figure
    plot(x,y,x(cutYidx),flinear(alinear,x(cutYidx)));
    grid on;
    title('Dados pré-processados e faixa linear');
    xlabel('Capacidade de descarga (mAh)');
    ylabel('Tensão de saída (V)');
    
    figure
    plot(x,ddy); grid on;
    title('Derivada segunda dos dados pré-processados');
end

y = y - ylout;

%% Faixa exponencial

idx = {1:min(cutYidx);max(cutYidx):length(y)};
a = cell(1,2); resnorm_exp = cell(1,2);

if Plot
    figure
end
for i = 1:2
    xx = x(idx{i});
    yy = y(idx{i});
    
    if i == 1
        a0 = [sign(max(abs(yy)))*max(abs(yy)),-(xx(end)-xx(1))];
        x0(1) = xx(abs(yy) == max(abs(yy)));
    else
        a0 = [yy(end),(xx(end)-xx(1))];
        x0(2) = xx(1);
    end
    
    [a{i},resnorm_exp{i}] = lsqcurvefit(fexp,a0,xx-x0(i),yy);
    
    if Plot
        sp = subplot(2,1,i);
        plot(xx,yy,xx,fexp(a{i},xx-x0(i)));
        grid on;
        title(sp,['Modelo exponencial ',num2str(i)]);
        xlabel('Capacidade de descarga (mAh)');
        ylabel('Tensão de saída (V)');
    end
end

fout = @(x) flinear(alinear,x) + fexp(a{1},x-x0(1)) + fexp(a{2},x-x0(2));
yout = fout(x);

if Plot
    figure
    plot(dataX,dataY,'o'); hold on
    plot(x,fout(x),LineWidth=1.5); grid on;
    title('Comparação dos dados originais com o modelo obtido')
    xlabel('Capacidade de descarga (mAh)');
    ylabel('Tensão de saída (V)');

    s = @(n)num2str(n,3);
    funstr = ['$',s(alinear(1)),'x + ',s(alinear(2)),' + (',...
        s(a{1}(1)),')e^{',s(a{1}(2)),'(x - ',s(x0(1)),')} + (',...
        s(a{2}(1)),')e^{',s(a{2}(2)),'(x - ',s(x0(2)),')}$'];
    annotation('textbox',Interpreter='latex',String=funstr,...
        Position=[0.20,0.15,0.6,0.05],FontSize=24,EdgeColor='none');
end

%% Retorno dos resultados

if nargout > 0
    varargout{1} = fout;
end
if nargout > 1
    modelData.Linear.Coeffs = alinear;
    modelData.Linear.Function = flinear;
    modelData.Linear.resnorm = resnorm_linear;
    
    modelData.LowDischargeExp.Coeffs = a{1};
    modelData.LowDischargeExp.Function = fexp;
    modelData.LowDischargeExp.resnorm = resnorm_exp{1};
    
    modelData.HighDischargeExp.Coeffs = a{2};
    modelData.HighDischargeExp.Function = fexp;
    modelData.HighDischargeExp.resnorm = resnorm_exp{2};
    
    varargout{2} = modelData;
end
if nargout > 2
    varargout{3} = x;
end
if nargout > 3
    varargout{4} = yout;
end

end