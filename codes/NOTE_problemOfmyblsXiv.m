%% Problems with myblscalliv / myblsputiv. --> SOLVED!
% For put, date==731779, exdate==731781, K==995.
% blsimpv returns NaN, while myblsputiv returns -1.6952 with initial guess 0.2.
% myblsputiv is ill-posed w.r.t. initial point.
% Need to solve this problem.

%--> filter on price(IV), not IV themselves.

%% example: init_guess=[0.1, 0.2, 0.3] --> IV = [0.047, NaN, 0.0239]
S=981.73; K=995; r=3.4921e-5*252; q=0.01807918; TTM=2/252; price=13;

a=blsimpv(S, K, r-q,TTM,price,[],[],[],{'Put'});
init_guess = 0.1; % try 0.1, 0.2, 0.3
IV=myblsputiv(S, K, r, TTM, price, q, init_guess); 

myblsput(S,K,r,TTM, IV, q)

%%
idx=find(PutData(:,18)==13 & PutData(:,3)==995);

%%

IV = blsimpv(617.7, 610, 2e-4*252-0.0246, yearfrac(729028,729044,13), 10.1875);
myblsprice(617.7, 610, 2e-4*252-0.0246, yearfrac(729028,729044,13), IV );

myblscall(617.7, 610, 2e-4*252, yearfrac(729028,729044,13), 0.0908, 0.0246);


% CallData = [date, exdate, strike_price, volume, open_interest, impl_volatility, ...
%     delta, gamma, vega, theta, spindx, sprtrn, ...
%     tb_m3, div, spxset, spxset_expiry, moneyness, mid, ...
%     opret, cpflag];

%%
load('rawOpData_dly_2nd_BSIV_mine.mat');
CallData_mine = CallData;
PutData_mine = PutData;
load('rawOpData_dly_2nd_BSIV.mat');

%%
% rTol=1e-2;
% idx_C = find(abs( (CallData_mine(:,6)-CallData(:,6))./CallData(:,6) > rTol));
% idx_P = find(abs( (PutData_mine(:,6)-PutData(:,6))./PutData(:,6) > rTol));

CallData_mine_ = CallData_mine(~isnan(CallData_mine(:,6)),:);
CallData_ = CallData(~isnan(CallData(:,6)),:);

PutData_mine_ = PutData_mine(~isnan(PutData_mine(:,6)),:);
PutData_ = PutData(~isnan(PutData(:,6)),:);

%%
idx_C = CallData_mine_(:,6)~=CallData_(:,6);
idx_P = PutData_mine_(:,6)~=PutData_(:,6);

sum(idx_C) % 0
sum(idx_P) % 0
