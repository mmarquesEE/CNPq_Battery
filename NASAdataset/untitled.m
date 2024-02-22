close all,clear all

files = strip(string(ls("archive\cleaned_dataset\data\")));
files = files(3:end);

a = readtable("archive\cleaned_dataset\data\" + files(2));
b = readtable("archive\cleaned_dataset\metadata.csv");

c = b(string(b.type)=="impedance" & string(b.battery_id) == "B0047",:)