function [Kc_OTM, C_bid_OTM, C_ask_OTM] = DelConsecZeroBid_call(Kc, C_bid, C_ask, K0)
% K0: First Kc below F. Can be empty. If so, find() returns an error.
if ~isempty(K0)
    idx_OTMC = find(Kc > K0);
else
    idx_OTMC = [];
end
Kc_OTM = Kc(idx_OTMC);
C_bid_OTM = C_bid(idx_OTMC);
C_ask_OTM = C_ask(idx_OTMC);

idx_C_zeroBid = find(C_bid_OTM == 0);
idx_C_ConsecZero = find( diff(idx_C_zeroBid)==1, 1, 'first');   % "first" is near-the-money
if ~isempty(idx_C_ConsecZero)
    Kc_OTM = Kc_OTM(1:idx_C_zeroBid(idx_C_ConsecZero)-1);
    C_bid_OTM = C_bid_OTM(1:idx_C_zeroBid(idx_C_ConsecZero)-1);
    C_ask_OTM = C_ask_OTM(1:idx_C_zeroBid(idx_C_ConsecZero)-1);
end