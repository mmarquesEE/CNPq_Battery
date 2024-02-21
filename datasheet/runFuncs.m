close all

DataDir = "datasheet\Data\";
files = strip(string(ls(DataDir)));
files = files(3:end);

filesTemp = files(endsWith(files,'º.csv'));
[Temp,tempIdx] = parseNumbers(filesTemp);
filesTemp = filesTemp(tempIdx);

filesRate = files(endsWith(files,'C.csv'));
[Rate,rateIdx] = parseNumbers(filesRate);
filesRate = filesRate(rateIdx);

files = {filesTemp, filesRate};
types = {Temp,Rate}; units = {'ºC','C'};
conditions = {' (1C)',' (25ºC)'};
quantities = {'Temperatura','Taxa de descarga'};
%%
a = cell(2,1);
for k = 1:2
    file = files{k}; dtype = types{k};
    dispName = @(n)[num2str(n,2),units{k}];
    titleText = ...
        ['Tensão de saída VS Capacidade de descarga',conditions{k}];

    figure
    p = gobjects(numel(file),1);
    for i = 1:numel(file)
        [~,mData,x,y,dataX,dataY] = ...
            model_discharge_characteristics(DataDir + file(i));
        
        p(i) = plot(x,y,LineWidth=1.3,DisplayName=dispName(dtype(i)));
        c = p(i).Color; hold on;
        
        plot(dataX,dataY,'o',Color=c,MarkerSize=5); grid on;
        title(titleText);
        xlabel('Capacidade de descarga (mAh)');
        ylabel('Tensão de saída (V)');

        a{k}(i,:) = mData.Coeffs;
    end
    legend(p);
end

figure
tiledlayout(2,3);
for i = 1:2
    titles = {'Linear','Exp 1','Exp 2'};
    for j = 1:3
        nexttile
        yyaxis("left");
        plot(types{i},a{i}(:,2*j-1),LineWidth=1.3);
        ylabel("coeff 1");

        hold on; grid on;
        
        yyaxis("right");
        plot(types{i},a{i}(:,2*j),LineWidth=1.3,DisplayName='coeff 2');
        ylabel("coeff 2");

        xlabel([quantities{i},' (',units{i},')']);
        title(titles{j});
    end
end

function [y,idx] = parseNumbers(stringArr)

[y,idx] = sort(cell2mat(cellfun(@(x) str2double(x{1}), ...
    regexp(stringArr,'(-?\d+(\.\d+)?)','match'), 'UniformOutput', false)));

end