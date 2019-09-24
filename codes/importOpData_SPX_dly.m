%% <importOpData_SPX_dly.m> -> <merge_OpDataNzerocd.m> -> <importOpData_SPX_dly_BSIV.m> -> <importOpData_SPX_dly_1shot.m>
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
% dt = distributed(ds);
% 
% % Below takes: 33s (DORM)
% tic;
% T = gather(dt);
% toc;

T = table();
n = numpartitions(ds, gcp);
% with n=14 partitions, process about 2~300k (w/ ReadSize=1e+6)
% --> bottleneck from here to there;
% -->? maybe due to memory overflow. Takes many seconds to read anything
% after a while.

tic;
parfor ii=1:n
    subds = partition(ds, n, ii);
    while hasdata(subds)
        T_ = read(subds);
        T = [T; T_];
        fprintf('current T.len(): %d \n', size(T_,1));
    end
end
toc;

%%
% Below takes .53s (dorm)
tic;
T.date = SAS2MAT_DateConversion(T.date);        % ddmmyyyy to datenum
T.exdate = SAS2MAT_DateConversion(T.exdate);
toc;

T.cpflag = zeros( size(T, 1), 1); % call
T.Properties.VariableNames{'TB_M3'} = 'tb_m3';
T.Properties.VariableDescriptions{'tb_m3'} = 'rf';
T.tb_m3 = T.tb_m3 / 100 ;

CallData = T;

%% Import the SPX Put data
filename = sprintf('%s\\SPXPut_dly.csv', rawData_path);
ds = tabularTextDatastore(filename);
ds.ReadSize = 1e+5;
% dt = distributed(ds);
% 
% % Below takes: 33s (dorm)
% tic;
% T = gather(dt);
% toc;

T = table();
n = numpartitions(ds, gcp);
% with n=14 partitions, process about 2~300k (w/ ReadSize=1e+6)
% --> bottleneck from here to there;
% -->? maybe due to memory overflow. Takes many seconds to read anything
% after a while.
tic;
parfor ii=1:n
    subds = partition(ds, n, ii);
    while hasdata(subds)
        T_ = read(subds);
        T = [T; T_];
        fprintf('current T.len(): %d \n', size(T_,1));
    end
end
toc;

%%
% Below takes .53s (dorm)
tic;
T.date = SAS2MAT_DateConversion(T.date);        % ddmmyyyy to datenum
T.exdate = SAS2MAT_DateConversion(T.exdate);
toc;

T.cpflag = ones(size(T, 1), 1); % put
T.Properties.VariableNames{'TB_M3'} = 'tb_m3';
T.Properties.VariableDescriptions{'tb_m3'} = 'rf';
T.tb_m3 = T.tb_m3 / 100 ;

PutData = T;

%% Sort
CallData = sortrows(CallData, {'date', 'exdate', 'strike_price'});
PutData = sortrows(PutData, {'date', 'exdate', 'strike_price'});


%% Save call and put data
% Below takes: 30s (dorm)
tic;
savefast(sprintf('%s\\rawOpData_SPX_dly.mat', genData_path), ...
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

