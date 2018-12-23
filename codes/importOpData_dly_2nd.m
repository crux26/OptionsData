%% <importOpData_dly.m> -> <importOpData_dly_BSIV.m> -> <importOpData_dly_BSIV_Trim.m>
% goto HigherMoments if needed: -> <OpData_dly_BSIV_Trim.m> -> <OpData_dly_BSIV_Trim_extrap.m>
%% Import the SPX Call 1st & 2nd month data
clear;clc;
homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);
rawData_path = sprintf('%s\\data\\rawdata', homeDirectory);

isDorm = true;
if isDorm == true
    drive = 'E:';
else
    drive = 'E:';
end


DaysPerYear = 252;
% Below takes: 1.8s (DORM PC)
filename = sprintf('%s\\SPXCall_dly.csv', rawData_path);
ds = tabularTextDatastore(filename);
ds.ReadSize = 1e+5;
dt = distributed(ds);

% Below takes: 101.6s (LAB)
tic;
T = gather(dt);
toc;

%%
% Below takes 1048s (dorm)  1766 lab
tic;
T.date = SAS2MAT_DateConversion(T.date);        % ddmmyyyy to datenum
T.exdate = SAS2MAT_DateConversion(T.exdate);
toc;

T.Properties.VariableNames{'TB_M3'} = 'tb_m3';
T.tb_m3 = T.tb_m3 / DaysPerYear;

CallData = T;

%% Import the SPX Put 1st & 2nd month data
% Below takes: 0.4s (dorm)
filename = sprintf('%s\\SPXPut_dly.csv', rawData_path);
ds = tabularTextDatastore(filename);
ds.ReadSize = 1e+5;
dt = distributed(ds);

% Below takes: 98s (dorm)
tic;
T = gather(dt);
toc;

%%
% Below takes 1121s (dorm)
tic;
T.date = SAS2MAT_DateConversion(T.date);        % ddmmyyyy to datenum
T.exdate = SAS2MAT_DateConversion(T.exdate);
toc;

T.Properties.VariableNames{'TB_M3'} = 'tb_m3';
T.tb_m3 = T.tb_m3 / DaysPerYear;

PutData = T;

%% Save call and put data

% Below takes: 30s (dorm) -> 1363s (lab) wtf??
tic;
save(sprintf('%s\\rawOpData_dly.mat', genData_path), ...
    'CallData', 'PutData');
toc;

%%
% [y,Fs] = audioread('E:\Downloads\police.wav');
% player = audioplayer(y, Fs);
% while 1
%     play(player);
% end
% stop(player);

