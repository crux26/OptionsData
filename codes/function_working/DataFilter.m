function [T_out] = DataFilter(T_OpData)
% legacy: function [K, OpPrice] = VIXrawVolCurve(Kp, P_bid, P_ask, Kc, C_bid, C_ask, r, TTM)
% Correct: checked with VIX white paper's sample data
if size(T_OpData, 1) == 1
    warning('size(T_OpData, 1) == 1. Nothing to filter.');
    T_out = T_OpData;
    return;
end

date_ = unique(T_OpData.date);
exdate = unique(T_OpData.exdate);
if length(date_) ~= 1 || length(exdate) ~= 1
    error('length(date_) ~= 1 || length(exdate) ~= 1.');
end

r = unique(T_OpData.r);
TTM = unique(T_OpData.TTM);
if length(r)~=1 || length(TTM)~=1
    error('length(r)~=1 || length(TTM)~=1.');
end

K = T_OpData.K;

fwd = T_OpData.S(1) * exp( (T_OpData.r(1) - T_OpData.q(1)) * T_OpData.TTM(1) );
K0 = K(find(K < fwd, 1, 'last')); % First K below F
try
    if T_OpData.cpflag(1) == 1
        K_nOTM = K(K > K0);
    else
        K_nOTM = K(K < K0);
    end
catch
	K_nOTM = K;
end

%% select OTM options && discard 2 consecutive zero bids
if T_OpData.cpflag(1) == 1
    [K_OTM, Bid_OTM, Ask_OTM] = DelConsecZeroBid_put(K, T_OpData.Bid, T_OpData.Ask, K0);
else
    [K_OTM, Bid_OTM, Ask_OTM] = DelConsecZeroBid_call(K, T_OpData.Bid, T_OpData.Ask, K0);
end

%% Delete zero bids data
if T_OpData.cpflag(1) == 1
    [K_OTM, ~, ~] = DelZeroBid_put(K_OTM, Bid_OTM, Ask_OTM);
else
    [K_OTM, ~, ~] = DelZeroBid_call(K_OTM, Bid_OTM, Ask_OTM);
end

%% Select Kc_OTMC, Kp_OTMP
% K0c == K0p
% 1st month
K = sort(unique([K_OTM; K0; K_nOTM])); 

idx = ismember(T_OpData.K, K, 'rows');
T_out = T_OpData(idx, :);
