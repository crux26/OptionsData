%% <importOpData_dly_2nd.m> -> <importOpData_dly_2nd_BSIV.m> 
% goto HigherMoments if needed: -> <OpData_dly_2nd_BSIV_Trim.m> -> <OpData_dly_2nd_BSIV_Trim_extrap.m>

%% Records non-sensical IVs.

clear;clc;
DaysPerYear = 252;

isDorm = true;
if isDorm == true
    drive='F:';
else
    drive='D:';
end
homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);

addpath(sprintf('%s\\codes\\IV calculation', homeDirectory));

% load(sprintf('%s\\rawOpData_dly_2nd.mat', genData_path), ...
%     'CallData', 'symbol_C', 'PutData', 'symbol_P', 'CallBidAsk', 'PutBidAsk');


load('rawOpData_dly_2nd.mat', 'CallData', 'PutData');


% [CallnRow,~] = size(CallData);
% [PutnRow,~] = size(PutData);

% CallData = [date, exdate, strike_price, volume, open_interest, impl_volatility, ...
%     delta, gamma, vega, theta, spindx, sprtrn, ...
%     tb_m3, div, spxset, spxset_expiry, moneyness, mid, ...
%     opret, cpflag];


%% CallIV, PutIV: "true" model price.
% IVs from CallData(:,6), PutData(:,6): market price that can go "wrong".

% Volatility = blsimpv(Price, Strike, Rate, Time,...
%     Value, Limit, Yield, Tolerance, Class)

% Below takes: 198.7s (LAB PC)
tic;
TTM_C = yearfrac(CallData(:,1), CallData(:,2), 13);
toc;

% Below takes: 12936s or 3.6h (LAB PC)
tic;
% CallIV = blsimpv(CallData(:,11), CallData(:,3), CallData(:,13) * DaysPerYear , ...
%     TTM_C, CallData(:,18), [], CallData(:,14), [], {'Call'});
toc;

% Below takes: 26.6s (LAB PC): Below can be problematic. Read <NOTE_problemOfmyblsXiv.m>.
tic;
CallIV = myblscalliv(CallData(:,11), CallData(:,3), CallData(:,13) * DaysPerYear, ...
    TTM_C, CallData(:,18), CallData(:,14), CallData(:,6));
toc;

% Below takes: 202.6s (LAB PC)
tic;
TTM_P = yearfrac(PutData(:,1), PutData(:,2), 13);
toc;

%Below takes: 13757s or 3.8h (LAB PC, 1996-2015)
tic;
% PutIV = blsimpv(PutData(:,11), PutData(:,3), PutData(:,13) * DaysPerYear , ...
%     TTM_P, PutData(:,18), [], PutData(:,14), [], {'Put'});
toc;

%Below takes: 22.8s (LAB PC): Below can be problematic. Read <NOTE_problemOfmyblsXiv.m>.
tic;
PutIV = myblsputiv(PutData(:,11), PutData(:,3), PutData(:,13) * DaysPerYear , ...
    TTM_P, PutData(:,18), PutData(:,14), PutData(:,6));
toc;


%% Delete observation where IV deviates from model IV more than 5%.
% This is quite often the case, as the traded price is far from
% % model-derived price.
% 
% [CallnRow,~] = size(CallData);
% [PutnRow,~] = size(PutData);
% 
% %Below took: 0.004s (LAB PC, 1996-2015)
% CallVolDev = zeros(CallnRow,1); % 1 if Vol_true deviates more than 5% from IV_BS.
% idx_CallVolDev = find(CallIV < 0.95*CallData(:,6) | CallIV > 1.05*CallData(:,6));
% CallVolDev(idx_CallVolDev) = 1;
% 
% % Below took: 0.004s (LAB PC, 1996-2015)
% PutVolDev = zeros(PutnRow,1);
% idx_PutVolDev = find(PutIV < 0.95*PutData(:,6) | PutIV > 1.05*PutData(:,6));
% PutVolDev(idx_PutVolDev) = 1;
% 
% tic;
% save(sprintf('%s\\rawOpData_dly_2nd_BSIV.mat', genData_path), ...
%     'CallData', 'CallIV', 'CallVolDev', 'PutData', 'PutIV', 'PutVolDev', ...
%     'symbol_C', 'symbol_P', 'CallBidAsk', 'PutBidAsk', 'TTM_C', 'TTM_P');
% toc;