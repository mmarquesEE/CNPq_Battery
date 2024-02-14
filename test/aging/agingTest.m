function [] = agingTest()

%% Run parallel simulations

open_system('agingTest');
load("agingTestConfig.mat");

nc = 500;
k = (0:nc)';

onecol = ones(length(k),1);

Temp = (20:5:50)';
SOC_MIN = [0;20;40;40;0];
SOC_MAX = [100;80;60;100;60];

TempLen = length(Temp);
SOCLen = length(SOC_MIN);

for i = 1:TempLen
    for j = 1:SOCLen
        aging_in(i,j) = Simulink.SimulationInput('agingTest');
        aging_in(i,j) = aging_in(i,j).setExternalInput([ ...
            k,...
            k,...
            Temp(i)*onecol,...
            SOC_MAX(j)*onecol, ...
            SOC_MIN(j)*onecol...
        ]);
    end
end

%%
aging_out = parsim(aging_in,...
    ShowSimulationManager="on",...
    ShowProgress="on",...
    UseFastRestart="on",...
    TransferBaseWorkspaceVariables="on");

save('test\aging\agingTestResults',"aging_out");

%% Prepare structures for comparisson

load('test\aging\agingTestResults.mat');

for i = 1:TempLen
    aging_sturct_name = ['aging_Temp_',num2str(Temp(i))];
    assignin('base', aging_sturct_name, aging_out(i,:));
    save('test\aging\agingTestResults',aging_sturct_name,'-append');
end

for i = 1:SOCLen
    aging_sturct_name = ['aging_Temp_',num2str(Temp(i))];
    assignin('base',['aging_SOC_', ...
        num2str(SOC_MIN(i)),'_',num2str(SOC_MAX(i))], ...
        aging_out(:,i));
    save('test\aging\agingTestResults',aging_sturct_name,'-append');
end

end
