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
fileName = sprintf('%s\\tfz_dly_ts2.csv', rawData_path);
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

T.CALDT = char(T.CALDT);
T.CALDT = datenum(T.CALDT);

%%
T_ = T(:, {'KYTREASNOX', 'CALDT', 'RDTREASNO', 'RDCRSPID', 'TDNOMPRC', 'TDYLD', 'TDDURATN'});
% (KY)TREASNO: Treasury record identifier
% (KY)CRSPID: CRSP-assigned unique ID

% RDTREASNO: Daily series of related TREASNOs
% RDCRSPID: Daily series of related CRSPIDs
% TDNOMPRC: daily nominal price
% TDYLD: daily series of promised daily yield
% TDDURATN: daily series of Macaulay's duration

tic;
savefast(sprintf('%s\\raw_tfz_dly_ts2.mat', genData_path), 'T_');
toc;
