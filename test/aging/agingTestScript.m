%% Run parallel simulations
clc

open_system('agingTest');
load("agingTestConfig.mat");

aging_test.nc = 500;
aging_test.k = (0:aging_test.nc)';

onecol = ones(length(aging_test.k),1);

aging_test.Temp = (20:5:50)';
aging_test.SOC_MIN = [0;20;40;40;0];
aging_test.SOC_MAX = [100;80;60;100;60];

TempLen = length(aging_test.Temp);
SOCLen = length(aging_test.SOC_MIN);

for i = 1:TempLen
    for j = 1:SOCLen
        aging_in(i,j) = Simulink.SimulationInput('agingTest');
        aging_in(i,j) = aging_in(i,j).setExternalInput([ ...
            aging_test.k,...
            aging_test.k,...
            aging_test.Temp(i)*onecol,...
            aging_test.SOC_MAX(j)*onecol, ...
            aging_test.SOC_MIN(j)*onecol...
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
    aging_sturct_name = ['aging_Temp_',num2str(aging_test.Temp(i))];
    assignin('base', aging_sturct_name, aging_out(i,:));
    save('test\aging\agingTestResults',aging_sturct_name,'-append');
end

for i = 1:SOCLen
    aging_sturct_name = ['aging_Temp_',num2str(aging_test.Temp(i))];
    assignin('base',['aging_SOC_', ...
        num2str(aging_test.SOC_MIN(i)),'_',num2str(aging_test.SOC_MAX(i))], ...
        aging_out(:,i));
    save('test\aging\agingTestResults',aging_sturct_name,'-append');
end

