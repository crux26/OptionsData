function [Kc, C_bid, C_ask] = DelZeroBid_call(Kc, C_bid, C_ask)
idx_nonZero = find(C_bid ~= 0);
Kc = Kc(idx_nonZero);
C_bid = C_bid(idx_nonZero);
C_ask = C_ask(idx_nonZero);
