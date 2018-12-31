%% Another way of filtering.
% Reason) (individual) options far-from-money illiquid, seemingly having wrong IVs.

% VIX uses OTMC, OTMP only.
% However, goal here is to get 1) VolSurf_C, VolSurf_P separately.
% Still, 2) having VIX-like VolSurf, for both C, P can be also meaningful.

clear;clc;
t1 = datetime('now');
isDorm = false;
if isDorm == true
    drive='E:';
else
    drive='E:';
end

homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);
addpath(sprintf('%s\\codes\\IV calculation', homeDirectory));
addpath(sprintf('%s\\codes\\function_working', homeDirectory));

OptionsData_genData_path = sprintf('%s\\Dropbox\\GitHub\\OptionsData\\data\\gen_data', drive);

% Refer to white paper: it seems not to adjust irregular prices at tails.
% load(sprintf('%s\\OpData_dly_2nd_BSIV_near30D_Trim.mat', genData_path));

tic;
load(sprintf('%s\\rawOpData_SPX_dly_BSIV_Trim.mat', genData_path), ...
    'CallData', 'PutData');
toc;

%% Use only the intersection of CallData & PutData.
[DatePair_C, ~] = unique([CallData.date, CallData.exdate], 'rows');
[DatePair_P, ~] = unique([PutData.date, PutData.exdate], 'rows');

DatePair_intxn = intersect(DatePair_C,DatePair_P, 'rows');
idx_C = ismember([CallData.date, CallData.exdate], DatePair_intxn, 'rows');
CallData = CallData(idx_C, :);
idx_P = ismember([PutData.date, PutData.exdate], DatePair_intxn, 'rows');
PutData = PutData(idx_P, :);

%% use only intxn
[DatePair_C, ~, ~] = unique([CallData.date, CallData.exdate], 'rows');
[DatePair_P, ~, ~] = unique([PutData.date, PutData.exdate], 'rows');

DatePair_intxn = intersect(DatePair_C, DatePair_P, 'rows');
idx_C = ismember([CallData.date, CallData.exdate], DatePair_intxn, 'rows');
CallData = CallData(idx_C, :);
idx_P = ismember([PutData.date, PutData.exdate], DatePair_intxn, 'rows');
PutData = PutData(idx_P, :);

%%
[DatePair_C, idx_DatePair_C, ~] = unique([CallData.date, CallData.exdate], 'rows');
[DatePair_P, idx_DatePair_P, ~] = unique([PutData.date, PutData.exdate], 'rows');

idx_DatePair_C = [idx_DatePair_C; length(CallData.exdate)+1];
idx_DatePair_C_next = idx_DatePair_C(2:end)-1; idx_DatePair_C = idx_DatePair_C(1:end-1);

idx_DatePair_P = [idx_DatePair_P; length(PutData.exdate)+1];
idx_DatePair_P_next = idx_DatePair_P(2:end)-1; idx_DatePair_P = idx_DatePair_P(1:end-1);

%% idx_problematic: 
T_CallData = [];
T_PutData = []; 
idx_problematic = [];
% Below takes: <6m (dorm)
tic;
parfor jj=1:length(DatePair_C)
	% 50k ~ 60k should be tested next
	% >60k: no problem
	% 78841~78863: all problematic!!!!
% 	parfor jj=1:length(date_)
    try
        tmpIdx_C = idx_DatePair_C(jj):idx_DatePair_C_next(jj);
        tmpIdx_P = idx_DatePair_P(jj):idx_DatePair_P_next(jj);
        
        T_CallData_ = DataFilter(CallData(tmpIdx_C, :));
        T_PutData_ = DataFilter(PutData(tmpIdx_P, :));

        T_CallData = [T_CallData; T_CallData_];
        T_PutData = [T_PutData; T_PutData_];

    catch
        idx_problematic = [idx_problematic; jj];
    end
    if floor(jj/1000)*1000 == jj
        fprintf('current i: %f out of %f\n', jj, length(DatePair_C));
    end
end
toc;

CallData = T_CallData;
PutData = T_PutData;

%%
% 0.02s (dorm1)
tic;
savefast(sprintf('%s\\rawOpData_SPX_dly_BSIV_Trim_fltr.mat', genData_path), ...
    'CallData', 'PutData');
toc;

filename = mfilename;
t2 = datetime('now');
sendEmail(filename, t1, t2);

fprintf('\n%s.m running done!\n\n', filename);
disp('from'); disp(t1); disp('to'); disp(t2);
%%
% [y, Bs] = audioread('E:\Downloads\police.wav');
% player = audioplayer(y, Bs);
% play(player);
% pause(5);
% stop(player);

%%
rmpath(sprintf('%s\\codes\\IV calculation', homeDirectory));
rmpath(sprintf('%s\\codes\\function_working', homeDirectory));
