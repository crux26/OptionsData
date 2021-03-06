%% Import the data, extracting spreadsheet dates in Excel serial date format
clear;clc;

isDorm = true;
if isDorm == true
    drive='E:';
else
    drive='E:';
end
homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);

rawData_path = sprintf('%s\\data\\rawdata', homeDirectory);
%%
tic;
fileName = sprintf('%s\\zerocd.csv', rawData_path);
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

T.date = SAS2MAT_DateConversion(T.date);        % ddmmyyyy to datenum
T.Properties.VariableNames('days') = {'datedif_cal'};
zerocd = T;
%%
save(sprintf('%s\\zerocd.mat', genData_path), 'zerocd');
