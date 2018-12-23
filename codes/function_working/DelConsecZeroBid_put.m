function [Kp_OTM, P_bid_OTM, P_ask_OTM] = DelConsecZeroBid_put(Kp, P_bid, P_ask, K0)
% K0: First Kp below F. Can be empty. If so, find() returns an error.
if ~isempty(K0)
    idx_OTMP = find(Kp < K0);
else
    idx_OTMP=[];
end
Kp_OTM = Kp(idx_OTMP);
P_bid_OTM = P_bid(idx_OTMP);
P_ask_OTM = P_ask(idx_OTMP);
% P_mid = P_mid(idx_OTMP);

idx_P_zeroBid = find(P_bid_OTM == 0);
idx_P_ConsecZero = find( diff(idx_P_zeroBid)==1, 1, 'last');    % "last" is near-the-money
if ~isempty(idx_P_ConsecZero)
    Kp_OTM = Kp_OTM(idx_P_zeroBid(idx_P_ConsecZero+1)+1 : end);
    P_bid_OTM = P_bid_OTM(idx_P_zeroBid(idx_P_ConsecZero+1)+1 : end);
    P_ask_OTM = P_ask_OTM(idx_P_zeroBid(idx_P_ConsecZero+1)+1 : end);
end