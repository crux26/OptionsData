%% WARNING: DEPRECATE THIS FOR THE WHOLE INDV. OPTION - DATA TOOOOOO LARGE TO READ.


%% <importOpData_dly.m> -> <importOpData_dly_BSIV.m> -> <importOpData_dly_BSIV_Trim.m>
% goto HigherMoments if needed: -> <OpData_dly_BSIV_Trim.m> -> <OpData_dly_BSIV_Trim_extrap.m>
%% Import the Call 1st & 2nd month data
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
filename = sprintf('%s\\Call_dly.csv', rawData_path);
ds = tabularTextDatastore(filename);
ds.ReadSize = 1e+5; % default: 2e+4

% returns error with ReadSize=1e+5, 2e+4
% --> distributed() works only if I can store the entirety of X in the
% memory;
% Below takes: 101.6s (LAB) <-- even this takes forever.
% tic;
% T = gather(distributed(ds));
% toc;


% Didn't print anything after waiting several hours.. WTF?
% --> B/c too slow. After 6 hours, only processed 107894983,
% which is only about 10%..
% Can't wait for this. Terminated.
% Gotta find another way - using SAS only or python directly.
% i=1278 corresponds to 107894983*26
% T = table();
% while hasdata(ds)
%     T_ = read(ds);
%     T = [T; T_];
%     fprintf('current T.len(): %d \n', size(T,1));
% end

T = table();
n = numpartitions(ds, gcp);
% with n=14 partitions, process about 2~300k (w/ ReadSize=1e+6)
% --> bottleneck from here to there;
% -->? maybe due to memory overflow. Takes many seconds to read anything
% after a while.
parfor ii=1:n
    subds = partition(ds, n, ii);
    while hasdata(subds)
        T_ = read(subds);
        T = [T; T_];
        fprintf('current T.len(): %d \n', size(T_,1));
    end
end

%%
% Below takes 1048s (dorm)
tic;
T.date = SAS2MAT_DateConversion(T.date);        % yyyymmdd to datenum
T.exdate = SAS2MAT_DateConversion(T.exdate);
toc;

T.Properties.VariableNames{'TB_M3'} = 'tb_m3';
T.tb_m3 = T.tb_m3 / DaysPerYear;

CallData = T;

%% Import the Put 1st & 2nd month data
% Below takes: 0.4s (dorm)

filename = sprintf('%s\\SPXPut_dly.csv', rawData_path);
ds = tabularTextDatastore(filename);
ds.ReadSize = 1e+5;

% tic;
% T = gather(distributed(ds));
% toc;
T = table();
while hasdata(ds)
    T_ = read(ds);
    T = [T; T_];
    fprintf('current T.len(): %d \n', size(T,1));
end

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

% Below takes: 30s (dorm)
% tic
% save(sprintf('%s\\rawOpData_dly.mat', genData_path), ...
%     'CallData', 'PutData');
% toc

tic
savefast(sprintf('%s\\rawOpData_dly.mat', genData_path), ...
    'CallData', 'PutData');
toc
