%% <importOpData_SPX_dly.m> -> <merge_OpDataNzerocd.m> -> <importOpData_SPX_dly_BSIV.m> -> <importOpData_SPX_dly_1shot.m>
% goto HigherMoments if needed: -> <OpData_dly_BSIV_Trim.m> -> <OpData_dly_BSIV_Trim_extrap.m>

%% Records non-sensical IVs.
clear;clc;
DaysPerYear = 252;
rTol_mid = 5e-2;
rTol_IV = 5e-2;

isDorm = true;
if isDorm == true
    drive='E:';
else
    drive='E:';
end
homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);

addpath(sprintf('%s\\codes\\IV calculation', homeDirectory));

tic;
load(sprintf('%s\\rawOpData_SPXNzerocd_dly.mat', genData_path), ...
    'CallData', 'PutData');
toc;

%% isnan(tb_m3): Already interpolated in SAS.


%% CallIV, PutIV: "true" model price.
% IVs from CallData(:,6), PutData(:,6): market price that can go "wrong".

% Volatility = blsimpv(Price, Strike, Rate, Time,...
%     Value, Limit, Yield, Tolerance, Class)

% Below takes: 12936s or 3.6h (LAB PC)
% tic;
% CallIV = blsimpv(CallData(:,11), CallData(:,3), CallData(:,13) * DaysPerYear , ...
%     TTM_C, CallData(:,18), [], CallData(:,14), [], {'Call'});
% toc;

% Below takes: 147s (dorm): Below can be problematic.
% Read <NOTE_problemOfmyblsXiv.m> --> fixed.
tic;
CallData.IV_ = myblscalliv(CallData.close, CallData.strike_price, CallData.zerocd, ...
    CallData.datedif_bus/DaysPerYear, CallData.mid, CallData.div, CallData.impl_volatility);
toc;

CallData.Properties.VariableDescriptions{'mid_'} = 'myMid';
CallData.Properties.VariableDescriptions{'IV_'} = 'myIV';

%% Through the procedure below, checked that blsimpv().result and myblscall().result are the same for ~isnan(IV).

[CallnRow, ~] = size(CallData);
[PutnRow, ~] = size(PutData);

% Below will throw away non-stable results which should have been discarded.
CallData.mid_ = myblscall(CallData.close, CallData.strike_price, CallData.zerocd, ...
    CallData.datedif_bus/DaysPerYear, CallData.IV_, CallData.div);
% (NaN<3)==0, (NaN>3)==0: So must use find( <rTol) and then exclude those idx.
idx_C = abs( (CallData.mid_ - CallData.mid) ./ CallData.mid) > rTol_mid;
CallData.midDev = zeros(CallnRow, 1); % 1 if Vol_true deviates more than 5% from IV_BS.
CallData.midDev(idx_C) = 1;

% -------------------------------------------------------------------------------------------
%Below takes: 13757s or 3.8h (LAB PC, 1996-2015)
% tic;
% PutIV = blsimpv(PutData(:,11), PutData(:,3), PutData(:,13) * DaysPerYear , ...
%     TTM_P, PutData(:,18), [], PutData(:,14), [], {'Put'});
% toc;

%Below takes: 63s (dorm): Below can be problematic. Read <NOTE_problemOfmyblsXiv.m>.
tic;
PutData.IV_ = myblsputiv(PutData.close, PutData.strike_price, PutData.zerocd, ...
    PutData.datedif_bus/DaysPerYear, PutData.mid, PutData.div, PutData.impl_volatility);
toc;

% Below will throw away non-stable results which should have been discarded.
PutData.mid_ = myblsput(PutData.close, PutData.strike_price, PutData.zerocd, ...
    PutData.datedif_bus/DaysPerYear, PutData.IV_, PutData.div);
idx_P = abs( (PutData.mid_ - PutData.mid) ./ PutData.mid ) > rTol_mid;
PutData.midDev = zeros(PutnRow, 1);
PutData.midDev(idx_P) = 1;

PutData.Properties.VariableDescriptions{'mid_'} = 'myMid';
PutData.Properties.VariableDescriptions{'IV_'} = 'myIV';
%% Record observations whose IV deviates from model IV more than 5%.
% This is quite often the case, as the traded price is far from
% model-derived price.

%Below took: 0.004s (LAB PC, 1996-2015)
CallData.VolDev = zeros(CallnRow, 1); % 1 if Vol_true deviates more than 5% from IV_BS.
% idx_CallVolDev = find(CallData.IV_ < 0.95*CallData.impl_volatility | CallData.IV_ > 1.05*CallData.impl_volatility);
idx_CallVolDev = ( abs(CallData.IV_ - CallData.impl_volatility) ./ CallData.impl_volatility > rTol_IV );
CallData.VolDev(idx_CallVolDev) = 1;

% Below took: 0.004s (LAB PC, 1996-2015)
PutData.VolDev = zeros(PutnRow, 1);
% idx_PutVolDev = find(PutData.IV_ < 0.95*PutData.impl_volatility | PutData.IV_ > 1.05*PutData.impl_volatility);
idx_PutVolDev = ( abs(PutData.IV_ - PutData.impl_volatility) ./ PutData.impl_volatility > rTol_IV );
PutData.VolDev(idx_PutVolDev) = 1;

% Below takes: 26s (dorm)
tic;
savefast(sprintf('%s\\rawOpData_SPX_dly_BSIV.mat', genData_path), ...
    'CallData', 'PutData');
toc;
