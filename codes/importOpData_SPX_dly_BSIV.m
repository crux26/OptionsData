%% <importOpData_dly.m> -> <importOpData_dly_BSIV.m> -> <importOpData_dly_BSIV_Trim.m>
% goto HigherMoments if needed: -> <OpData_dly_BSIV_Trim.m> -> <OpData_dly_BSIV_Trim_extrap.m>

%% Records non-sensical IVs.
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

load(sprintf('%s\\rawOpData_SPX_dly.mat', genData_path), ...
    'CallData', 'PutData');



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

% Below takes: 61s (dorm): Below can be problematic. Read <NOTE_problemOfmyblsXiv.m>.
tic;
CallData.IV = myblscalliv(CallData.spindx, CallData.strike_price, CallData.tb_m3 * DaysPerYear, ...
    CallData.datedif_bus/DaysPerYear, CallData.mid, CallData.div, CallData.impl_volatility);
toc;

%% Through the procedure below, checked that blsimpv().result and myblscall().result are the same for ~isnan(IV).

% Below will throw away non-stable results which should have been discarded.
Call_ = myblscall(CallData.spindx, CallData.strike_price, CallData.tb_m3 * DaysPerYear, ...
    CallData.datedif_bus/DaysPerYear, CallData.IV, CallData.div);
% (NaN<3)==0, (NaN>3)==0: So must use find( <rTol) and then exclude those idx.
idx_C = abs( (Call_-CallData.mid)./CallData.mid ) < rTol;
CallData.impl_volatility(~idx_C) = NaN;
CallData.IV(~idx_C) = NaN;

% -------------------------------------------------------------------------------------------
%Below takes: 13757s or 3.8h (LAB PC, 1996-2015)
% tic;
% PutIV = blsimpv(PutData(:,11), PutData(:,3), PutData(:,13) * DaysPerYear , ...
%     TTM_P, PutData(:,18), [], PutData(:,14), [], {'Put'});
% toc;

%Below takes: 36s (dorm): Below can be problematic. Read <NOTE_problemOfmyblsXiv.m>.
tic;
PutData.IV = myblsputiv(PutData.spindx, PutData.strike_price, PutData.tb_m3 * DaysPerYear , ...
    PutData.datedif_bus/DaysPerYear, PutData.mid, PutData.div, PutData.impl_volatility);
toc;

% Below will throw away non-stable results which should have been discarded.
Put_ = myblsput(PutData.spindx, PutData.strike_price, PutData.tb_m3 * DaysPerYear, ...
    PutData.datedif_bus/DaysPerYear, PutData.IV, PutData.div);
idx_P = abs( (Put_ - PutData.mid)./PutData.mid ) < rTol;
PutData.impl_volatility(~idx_P) = NaN;
PutData.IV(~idx_P) = NaN;

%% Record observations whose IV deviates from model IV more than 5%.
% This is quite often the case, as the traded price is far from
% model-derived price.

[CallnRow, ~] = size(CallData);
[PutnRow, ~] = size(PutData);

%Below took: 0.004s (LAB PC, 1996-2015)
CallVolDev = zeros(CallnRow, 1); % 1 if Vol_true deviates more than 5% from IV_BS.
idx_CallVolDev = find(CallData.IV < 0.95*CallData.impl_volatility | CallData.IV > 1.05*CallData.impl_volatility);
CallVolDev(idx_CallVolDev) = 1;

% Below took: 0.004s (LAB PC, 1996-2015)
PutVolDev = zeros(PutnRow, 1);
idx_PutVolDev = find(PutData.IV < 0.95*PutData.impl_volatility | PutData.IV > 1.05*PutData.impl_volatility);
PutVolDev(idx_PutVolDev) = 1;

CallVolDev = table(CallVolDev);
PutVolDev = table(PutVolDev);

% Below takes: 32s (dorm)
tic;
save(sprintf('%s\\rawOpData_SPX_dly_BSIV.mat', genData_path), ...
    'CallData', 'CallVolDev', 'PutData', 'PutVolDev');
toc;
