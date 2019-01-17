%% <importOpData_SPX_dly_1shot.m> -> <importOpData_SPX_dly_1shot2.m>
%% Alternative to <importOpData_SPX_dly_1shot.m>

% To be precise, this is somewhat "manipulation", but must be done and is
% not a paper-subject matter. Hence, should be done under ~/OptionsData/.
clear;clc;
DaysPerYear = 252;

isDorm = true;
if isDorm == true
    drive='E:';
else
    drive='E:';
end
homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);

addpath(sprintf('%s\\codes\\IV calculation', homeDirectory));
addpath(sprintf('%s\\codes\\function_working', homeDirectory));

% 300s (lab), 5.5s (dorm)
tic;
load(sprintf('%s\\rawOpData_SPX_dly_BSIV_Trim.mat', genData_path), ...
    'CallData', 'PutData');
toc;

t1 = datetime('now');

%% Drop TTM < 14D_cal (or 10D_bus)
CallData = CallData(CallData.datedif_cal >= 14, :);
PutData = PutData(PutData.datedif_cal >= 14, :);

%% drop isnan(.IV)
CallData = CallData(~isnan(CallData.IV), :);
PutData = PutData(~isnan(PutData.IV), :);

%% Discard ITMC, ITMP --> Not discard it. Even ITMs will be used in HW (2017).
CallData.moneyness = CallData.S .* exp( (CallData.r - CallData.q) .* CallData.TTM ) ./ CallData.K;
PutData.moneyness = PutData.S .* exp( (PutData.r - PutData.q) .* PutData.TTM ) ./ PutData.K;

% CallData = CallData(CallData.moneyness <=1.1, :);
% PutData = PutData(PutData.moneyness >= 0.9, :);

%%
date_intersection = intersect([CallData.date, CallData.exdate], [PutData.date, PutData.exdate], 'rows');
CallData = CallData( ismember([CallData.date, CallData.exdate], date_intersection, 'rows'), :);
PutData = PutData( ismember([PutData.date, PutData.exdate], date_intersection, 'rows'), :);

[DatePair_C, idx_DatePair_C] = unique([CallData.date, CallData.exdate], 'rows');
[DatePair_P, idx_DatePair_P] = unique([PutData.date, PutData.exdate], 'rows');

if ~isequal(DatePair_C, DatePair_P)
    warning('#(DatePair_C) ~= #(DatePair_P). Possibly due to data issue.');
end

%%
idx_DatePair_C = [idx_DatePair_C; size(CallData.date, 1) + 1]; % to include the last index.
idx_DatePair_P = [idx_DatePair_P; size(PutData.date, 1) + 1]; % unique() doesn't return the last index.

idx_DatePair_C_next = idx_DatePair_C(2:end)-1; idx_DatePair_C = idx_DatePair_C(1:end-1);
idx_DatePair_P_next = idx_DatePair_P(2:end)-1; idx_DatePair_P = idx_DatePair_P(1:end-1);


%% dropEnd_OTMC, _OTMP already done in rawOpData_SPX_dly_BSIV_Trim.mat
CallData__ = [];
PutData__ = [];

diffStepSize = 1;
len_C = length(idx_DatePair_C);
tmpMult = 1;
% 94s (dorm)
tic;
parfor i=1:len_C
    idx_C = idx_DatePair_C(i) : idx_DatePair_C_next(i);
    CallData_ = CallData(idx_C, :);
    CallData_ = dropEnd_OTMC_IV(CallData_, tmpMult);
    CallData__ = [CallData__; CallData_];
    if floor(i/1000)*1000 == i
        fprintf('Call. current i: %d / %d\n', i, len_C);
    end
end
toc;

CallData = CallData__;

len_P = length(idx_DatePair_P);
tmpMult = 1;
% (dorm)
tic;
% for i=1:len_P
parfor i=1:len_P
    idx_P = idx_DatePair_P(i) : idx_DatePair_P_next(i);
    PutData_ = PutData(idx_P, :);
    PutData_ = dropEnd_OTMP_IV(PutData_, tmpMult);
    PutData__ = [PutData__; PutData_];
    if floor(i/1000)*1000 == i
        fprintf('Put. current i: %d / %d\n', i, len_C);
    end
end
toc;

PutData = PutData__;

CallData = sortrows(CallData, {'secid', 'date', 'exdate', 'K'});
PutData = sortrows(PutData, {'secid', 'date', 'exdate', 'K'});
%%
% Below takes: 1405s or 0.4h (lab) -> 4584s (dorm): WTF?
tic;
savefast(sprintf('%s\\rawOpData_SPX_dly_BSIV_Trim2.mat', genData_path), ...
    'CallData', 'PutData');
toc;

t2 = datetime('now');
filename = mfilename;
sendEmail(filename, t1, t2);
