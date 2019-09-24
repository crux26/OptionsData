%% VRP since 1990, the VIX introduction date
%% Import the data, extracting spreadsheet dates in Excel serial date format
clear; clc;
DaysPerYear = 252;

isDorm = false;
if isDorm == true
    drive = 'E:';
else
    drive = 'E:';
end
homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);
rawData_path = sprintf('%s\\data\\rawdata', homeDirectory);

%%
tic;
fileName = sprintf('%s\\VRP.csv', rawData_path);
ds = tabularTextDatastore(fileName);
toc;

% Below takes: 0.001s (DORM PC)
tic
ds.ReadSize = 15000; % default: file
toc

T = table;
% Below takes: 29.9s (DORM PC)
tic
while hasdata(ds)
    T_ = read(ds);
    T = [T; T_];
end
toc

%%
T.Properties.VariableNames{'Date'} = 'date';

%% Using new "datetime" format instead of datenum
date = T.date; date = datetime(date, 'ConvertFrom', 'yyyymmdd'); 
% T.date = datenum(date);
T.date = date;
T_VRP = T;

%% Clear temporary variables
save(sprintf('%s\\VRP.mat', genData_path), 'T_VRP');
