%% <importOpData_SPX_dly.m> -> <importOpData_SPX_dly_1shot_dorm.m>
% goto HigherMoments if needed: -> <OpData_dly_BSIV_Trim.m> -> <OpData_dly_BSIV_Trim_extrap.m>
%% Import the SPX Call data
clear;clc;
isDorm = true;
if isDorm == true
    drive = 'E:';
else
    drive = 'E:';
end

homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);
rawData_path = sprintf('%s\\data\\rawdata', homeDirectory);
DaysPerYear = 252;

filename = sprintf('%s\\SPXCall_dly.csv', rawData_path);
ds = tabularTextDatastore(filename);
ds.ReadSize = 1e+5;
dt = distributed(ds);

% Below takes: 33s (DORM)
tic;
T = gather(dt);
toc;

%%
% Below takes .53s (dorm)
tic;
T.date = SAS2MAT_DateConversion(T.date);        % ddmmyyyy to datenum
T.exdate = SAS2MAT_DateConversion(T.exdate);
toc;

T.cpflag = zeros( size(T, 1), 1); % call
T.Properties.VariableNames{'TB_M3'} = 'tb_m3';
T.tb_m3 = T.tb_m3 / 100 ;

CallData = T;

%% Import the SPX Put data
filename = sprintf('%s\\SPXPut_dly.csv', rawData_path);
ds = tabularTextDatastore(filename);
ds.ReadSize = 1e+5;
dt = distributed(ds);

% Below takes: 33s (dorm)
tic;
T = gather(dt);
toc;

%%
% Below takes .53s (dorm)
tic;
T.date = SAS2MAT_DateConversion(T.date);        % ddmmyyyy to datenum
T.exdate = SAS2MAT_DateConversion(T.exdate);
toc;

T.cpflag = ones(size(T, 1), 1); % put
T.Properties.VariableNames{'TB_M3'} = 'tb_m3';
T.tb_m3 = T.tb_m3 / 100 ;

PutData = T;

%% Save call and put data

% Below takes: 30s (dorm) -> 1363s (lab) wtf?? -> 4604s (dorm): ?????????
tic;
save(sprintf('%s\\rawOpData_SPX_dly.mat', genData_path), ...
    'CallData', 'PutData');
toc;

% tic;
% save(sprintf('%s\\rawOpData_SPX_dly.mat', genData_path), ...
%     'CallData', 'PutData', '-v7.3', '-nocompression');
% toc;
% 
% tic;
% save(sprintf('%s\\rawOpData_SPX_dly.mat', genData_path), ...
%     'CallData', 'PutData', '-append', '-nocompression');
% toc;

%% .mat, .txt (save(~, ~, '-ascii'))
% -mat, -ascii,

