close all,clear all,clc

dataDir = "archive\cleaned_dataset\data\";

files = strip(string(ls(dataDir)));
files = files(3:end);

metadata = readtable("archive\cleaned_dataset\metadata.csv");

%% Organize files

% by batteries
batt_ids = unique(string(metadata.battery_id));
batt = cell(length(batt_ids),1);

for i = 1:length(batt_ids)
    batt{i}.id = string(batt_ids(i));

    crr_table = metadata(string(metadata.battery_id) == batt{i}.id,...
        metadata.Properties.VariableNames);

    discharge = crr_table(string(crr_table.type)=="discharge", ...
        {'start_time','ambient_temperature','filename','Capacity'});
    charge = crr_table(string(crr_table.type)=="charge", ...
        {'start_time','ambient_temperature','filename'});
    impedance = crr_table(string(crr_table.type)=="impedance", ...
        {'start_time','ambient_temperature','filename','Re','Rct'});

    batt{i}.discharge = discharge;
    batt{i}.charge = charge;
    batt{i}.impedance = impedance;
end

save("dataStructs.mat","batt");