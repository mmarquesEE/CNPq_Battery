%% Run parallel simulations
clc

open_system('diffusionTest');

diff_test.dt = 1e-3;
diff_test.tf = 1000;
diff_test.t = (0:diff_test.dt:diff_test.tf)';

onecols = @(n)ones(length(diff_test.t),n);

diff_test.current = 0*onecols(12);
diff_test.current(:,1:10) = (1:10).*onecols(10);
diff_test.current(:,11) = 0.1*onecols(1);
diff_test.current(:,12) = pulsed_current(diff_test.t, 1, 100,20,80);


[diff_test.k,diff_test.Temp] = meshgrid(0:100:400,[25,35]); 

% Using Discharge capacity for full cycles (dSOC = 100%):
for i=numel(diff_test.k)
    diff_test.Cc(i) = aging_out( ...
        aging_test.Temp == diff_test.Temp(i), ...
        aging_test.SOC_MIN == 0 & ...
        aging_test.SOC_MAX == 100).yout{3}.Values.Data(diff_test.k(i) + 1);
end

%%
CcLen = length(diff_test.Cc);
[~,currentLen] = size(diff_test.current);

for i = 1:CcLen
    for j = 1:currentLen
        diff_in(i,j) = Simulink.SimulationInput('diffusionTest');
        diff_in(i,j) = diff_in(i,j).setExternalInput([ ...
            diff_test.t, ...
            diff_test.current(:,j), ...
            diff_test.Cc(i)*onecols(1)]);
    end
end

%%
diff_out = parsim(diff_in,...
    ShowSimulationManager="on",...
    ShowProgress="on",...
    UseFastRestart="on",...
    TransferBaseWorkspaceVariables="on");

save('test\diffusion\diffusionTestResults',"diff_out");

%% Prepare structures for comparisson

function pc = pulsed_current(t,amp,first,pw,rt)

f = 1/(pw + rt);
c0 = first - pw/2;
cf = t(end) - pw/2;

dc = 100*pw*f;

pc = (t > c0 & t < cf)*amp/2.*(square(2*pi*f*(t - c0), dc) + 1) ;

end
