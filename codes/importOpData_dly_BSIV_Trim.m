%% <importOpData_dly.m> -> <importOpData_dly_BSIV.m> -> <importOpData_dly_BSIV_Trim.m>
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

tic;
load(sprintf('%s\\rawOpData_dly_BSIV.mat', genData_path), ...
    'CallData', 'CallVolDev', 'PutData', 'PutVolDev');
toc;

%% changing multiple variable names only accessible by column number
CallData.Properties.VariableNames{'spindx'} = 'S';
CallData.Properties.VariableNames{'strike_price'} = 'K';
CallData.Properties.VariableNames{'tb_m3'} = 'r';
CallData.Properties.VariableNames{'div'} = 'q';
CallData.Properties.VariableNames{'best_bid'} = 'Bid';
CallData.Properties.VariableNames{'best_offer'} = 'Ask';
CallData.Properties.VariableNames{'datedif_bus'} = 'TTM';

CallData.TTM  = CallData.TTM / DaysPerYear;
CallData.VolDev = CallVolDev.CallVolDev;
CallData.Properties.VariableNames{'IV'} = 'BSIV';
CallData.Properties.VariableNames{'impl_volatility'} = 'IV';
CallData.Properties.VariableNames{'cp_flag'} = 'cpflag';

PutData.Properties.VariableNames{'spindx'} = 'S';
PutData.Properties.VariableNames{'strike_price'} = 'K';
PutData.Properties.VariableNames{'tb_m3'} = 'r';
PutData.Properties.VariableNames{'div'} = 'q';
PutData.Properties.VariableNames{'best_bid'} = 'Bid';
PutData.Properties.VariableNames{'best_offer'} = 'Ask';
PutData.Properties.VariableNames{'datedif_bus'} = 'TTM';
PutData.TTM  = PutData.TTM / DaysPerYear;
PutData.VolDev = PutVolDev.PutVolDev;
PutData.Properties.VariableNames{'IV'} = 'BSIV';
PutData.Properties.VariableNames{'impl_volatility'} = 'IV';
PutData.Properties.VariableNames{'cp_flag'} = 'cpflag';

%%
% CallData = table(CallData(:,1), CallData(:,2), CallData(:,3), CallData(:,4), CallData(:,5), ...
%     CallData(:,6), CallData(:,7), CallData(:,8), CallData(:,9), CallData(:,10), CallData(:,11), CallData(:,12), ...
%     CallData(:,13), CallData(:,14), CallData(:,15), CallData(:,16), CallData(:,17), CallData(:,18), CallData(:,19), ...
%     CallData(:,20), CallData(:,21), CallData(:,22), ...
%     CallBidAsk(:,1), CallBidAsk(:,2), TTM_C, CallVolDev, symbol_C, CallIV, ...
%     'VariableNames', {'date', 'exdate', 'Kc', 'volume', 'open_interest', 'IV', 'delta', 'gamma', 'vega', 'theta', ...
%     'S', 'sprtrn', 'r', 'q', 'spxset', 'spxset_expiry', 'moneyness', 'C', 'opret', 'cpflag', ...
%     'min_datedif', 'min_datedif_2nd', ...
%     'Bid', 'Ask', 'TTM', 'VolDev', 'symbol', 'BSIV'});
%     
% PutData = table(PutData(:,1), PutData(:,2), PutData(:,3), PutData(:,4), PutData(:,5), ...
%     PutData(:,6), PutData(:,7), PutData(:,8), PutData(:,9), PutData(:,10), PutData(:,11), PutData(:,12), ...
%     PutData(:,13), PutData(:,14), PutData(:,15), PutData(:,16), PutData(:,17), PutData(:,18), PutData(:,19), ...
%     PutData(:,20), PutData(:,21), PutData(:,22), ...
%     PutBidAsk(:,1), PutBidAsk(:,2), TTM_P, PutVolDev, symbol_P, PutIV, ...
%     'VariableNames', {'date', 'exdate', 'Kp', 'volume', 'open_interest', 'IV', 'delta', 'gamma', 'vega', 'theta', ...
%     'S', 'sprtrn', 'r', 'q', 'spxset', 'spxset_expiry', 'moneyness', 'P', 'opret', 'cpflag', ...
%     'min_datedif', 'min_datedif_2nd', ...
%     'Bid', 'Ask', 'TTM', 'VolDev', 'symbol', 'BSIV'});
% 
% clearvars -except CallData PutData;
%%
[DatePair_C, idx_DatePair_C, ~] = unique([CallData.date, CallData.exdate], 'rows');
idx_DatePair_C = [idx_DatePair_C; length(CallData.exdate)+1];
idx_DatePair_C_next = idx_DatePair_C(2:end)-1; idx_DatePair_C = idx_DatePair_C(1:end-1);

[DatePair_P, idx_DatePair_P, ~] = unique([PutData.date, PutData.exdate], 'rows');
idx_DatePair_P = [idx_DatePair_P; length(PutData.exdate)+1];
idx_DatePair_P_next = idx_DatePair_P(2:end)-1; idx_DatePair_P = idx_DatePair_P(1:end-1);

%%
CallData__ = cell2table(cell(0, 31), 'VariableNames', CallData.Properties.VariableNames);
PutData__ = cell2table(cell(0, 31), 'VariableNames', PutData.Properties.VariableNames);

%%
% CallData__ = cell2table(cell(0,28), ...
%     'VariableNames', {'date', 'exdate', 'Kc', 'volume', 'open_interest', 'IV', 'delta', 'gamma', 'vega', 'theta', ...
%     'S', 'sprtrn', 'r', 'q', 'spxset', 'spxset_expiry', 'moneyness', 'C', 'opret', 'cpflag', ...
%     'min_datedif', 'min_datedif_2nd', ...
%     'Bid', 'Ask', 'TTM', 'VolDev', 'symbol', 'BSIV'});
% 
% PutData__ = cell2table(cell(0,28), ...
% 	'VariableNames', {'date', 'exdate', 'Kp', 'volume', 'open_interest', 'IV', 'delta', 'gamma', 'vega', 'theta', ...
%     'S', 'sprtrn', 'r', 'q', 'spxset', 'spxset_expiry', 'moneyness', 'P', 'opret', 'cpflag', ...
%     'min_datedif', 'min_datedif_2nd', ...
%     'Bid', 'Ask', 'TTM', 'VolDev', 'symbol', 'BSIV'});

% Below takes: 15502s/4.3h (dorm)
% T.vertcat() (concatenating with []) is far faster than definition & slicing (due to tabular.subsasgnParens()).
% Takes some time somewhere i > 10000; <.3s for each i.
tic;
for i=1:length(idx_DatePair_C)
    idx_C = idx_DatePair_C(i) : idx_DatePair_C_next(i);
    CallData_ = CallData(idx_C, :);
    CallData_ = dropEnd_OTMC(CallData_);
    
    idx_P = idx_DatePair_P(i) : idx_DatePair_P_next(i);
    PutData_ = PutData(idx_P, :);
    PutData_ = dropEnd_OTMP(PutData_);
    
    CallData__ = [CallData__; CallData_];
    PutData__ = [PutData__; PutData_];
    fprintf('current i: %d\n', i);
end
toc;

CallData = CallData__;
PutData = PutData__;

% Below takes: 32.2s (lab)
tic;
save(sprintf('%s\\rawOpData_BSIV_Trim.mat', genData_path), ...
    'CallData', 'PutData');
toc;

