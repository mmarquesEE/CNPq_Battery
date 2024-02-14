function [] = diffusionTest()

%% Run parallel simulations

open_system('diffusionTest');

dt = 1e-3;
tf = 1000;
t = (0:dt:tf)';

onecols = @(n)ones(length(t),n);

current = 0*onecols(12);
current(:,1:10) = (1:10).*onecols(10);
current(:,11) = 0.1*onecols(1);
current(:,12) = pulsed_current(t, 1, 100,20,80);


[k,Temp] = meshgrid(0:100:400,[25,35]); 

% Using Discharge capacity for full cycles (dSOC = 100%):
for i=numel(k)
    Cc(i) = aging_out( ...
        aging_test.Temp == Temp(i), ...
        aging_test.SOC_MIN == 0 & ...
        aging_test.SOC_MAX == 100).yout{3}.Values.Data(k(i) + 1);
end

%%
CcLen = length(Cc);
[~,currentLen] = size(current);

for i = 1:CcLen
    for j = 1:currentLen
        diff_in(i,j) = Simulink.SimulationInput('diffusionTest');
        diff_in(i,j) = diff_in(i,j).setExternalInput([ ...
            t, ...
            current(:,j), ...
            Cc(i)*onecols(1)]);
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

end