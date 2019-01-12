%% <importOpData_SPX_dly.m> -> <importOpData_SPX_dly_1shot.m>

%% dropEnd_OTMC(), dropEnd_OTMP() should be applied here.
% To be precise, this is somewhat "manipulation", but must be done and is
% not a paper-subject matter. Hence, should be done under ~/OptionsData/.
clear;clc;
DaysPerYear = 252;
rTol = 5e-2;

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

% 300s (lab)
tic;
load(sprintf('%s\\rawOpData_SPX_dly.mat', genData_path), ...
    'CallData', 'PutData');
toc;

t1 = datetime('now');

%% changing multiple variable names only accessible by column number
CallData.Properties.VariableNames{'close'} = 'S';
CallData.Properties.VariableNames{'strike_price'} = 'K';
CallData.Properties.VariableNames{'tb_m3'} = 'r';
CallData.Properties.VariableNames{'div'} = 'q';
CallData.Properties.VariableNames{'best_bid'} = 'Bid';
CallData.Properties.VariableNames{'best_offer'} = 'Ask';
CallData.Properties.VariableNames{'datedif_bus'} = 'TTM';

CallData.TTM  = CallData.TTM / DaysPerYear;
CallData.Properties.VariableNames{'impl_volatility'} = 'IV';

PutData.Properties.VariableNames{'close'} = 'S';
PutData.Properties.VariableNames{'strike_price'} = 'K';
PutData.Properties.VariableNames{'tb_m3'} = 'r';
PutData.Properties.VariableNames{'div'} = 'q';
PutData.Properties.VariableNames{'best_bid'} = 'Bid';
PutData.Properties.VariableNames{'best_offer'} = 'Ask';
PutData.Properties.VariableNames{'datedif_bus'} = 'TTM';
PutData.TTM  = PutData.TTM / DaysPerYear;

PutData.Properties.VariableNames{'impl_volatility'} = 'IV';

[DatePair_C, idx_DatePair_C, ~] = unique([CallData.date, CallData.exdate], 'rows');
idx_DatePair_C = [idx_DatePair_C; length(CallData.exdate)+1];
idx_DatePair_C_next = idx_DatePair_C(2:end)-1; idx_DatePair_C = idx_DatePair_C(1:end-1);

[DatePair_P, idx_DatePair_P, ~] = unique([PutData.date, PutData.exdate], 'rows');
idx_DatePair_P = [idx_DatePair_P; length(PutData.exdate)+1];
idx_DatePair_P_next = idx_DatePair_P(2:end)-1; idx_DatePair_P = idx_DatePair_P(1:end-1);

%%
CallData__ = cell2table(cell(0, size(CallData, 2)), 'VariableNames', CallData.Properties.VariableNames);
PutData__ = cell2table(cell(0, size(PutData, 2)), 'VariableNames', PutData.Properties.VariableNames);


%% error below because DatePair_C ~= DatePair_P
% -> process separately.

%%
% Below takes: 15502s/4.3h (dorm)
% T.vertcat() (concatenating with []) is far faster than definition & slicing (due to tabular.subsasgnParens()).
% Takes some time somewhere i > 10000; <.3s for each i.

% parfor(): explosion in lab. FUCKFUCKFUCKFUCKFUCKFUCKFUCK
% about 28366s or 7.9h (lab)
len_C = length(idx_DatePair_C);
tic;
parfor i=1:len_C
    idx_C = idx_DatePair_C(i) : idx_DatePair_C_next(i);
    CallData_ = CallData(idx_C, :);
    CallData_ = dropEnd_OTMC(CallData_);    
    CallData__ = [CallData__; CallData_];
    if floor(i/1000)*1000 == i
        fprintf('Call. current i: %d / %d\n', i, len_C);
    end
end
toc;

CallData = CallData__;

% 28366s or 7.9h (lab) --> 289s (dorm): through exclusion of string
len_P = length(idx_DatePair_P);
tic;
parfor i=1:len_P
    idx_P = idx_DatePair_P(i) : idx_DatePair_P_next(i);
    PutData_ = PutData(idx_P, :);
    PutData_ = dropEnd_OTMP(PutData_);
    PutData__ = [PutData__; PutData_];
    if floor(i/1000)*1000 == i
        fprintf('Put. current i: %d / %d\n', i, len_P);
    end
end
toc;

PutData = PutData__;

% Below takes: 28s (dorm)
% tic;
% save(sprintf('%s\\rawOpData_SPX_BSIV_Trim.mat', genData_path), ...
%     'CallData', 'PutData', '-v7.3');
% toc;

% Below takes: 1405s or 0.4h (lab) -> 4584s (dorm): WTF?
tic;
savefast(sprintf('%s\\rawOpData_SPX_dly_BSIV_Trim.mat', genData_path), ...
    'CallData', 'PutData');
toc;

t2 = datetime('now');
filename = mfilename;
sendEmail(filename, t1, t2);

% 4901s (dorm): more or less the same
% tic;
% save(sprintf('%s\\rawOpData_SPX_dly_BSIV_Trim_Nofast.mat', genData_path), ...
%     'CallData', 'PutData', '-nocompression');
% toc;
