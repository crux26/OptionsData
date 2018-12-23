%% Import the data, extracting spreadsheet dates in Excel serial date format
clear; clc;
DaysPerYear = 252;

isDorm = true;
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
fileName = sprintf('%s\\VIXData_dly.csv', rawData_path);
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
caldt = T.caldt; caldt = datetime(caldt, 'ConvertFrom', 'yyyyMMdd'); T.caldt = datenum(caldt);
T.tb_m3 = T.TB_M3 / DaysPerYear;
T.TB_M3 = [];
T.Properties.VariableNames{'rate'} = 'div';

%% 
T_VIX_dly = T;
save(sprintf('%s\\rawData_VIX_dly.mat', genData_path), 'T_VIX_dly');