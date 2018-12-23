function [Kp, P_bid, P_ask] = DelZeroBid_put(Kp, P_bid, P_ask)
idx_nonZero = find(P_bid ~= 0);
Kp = Kp(idx_nonZero);
P_bid = P_bid(idx_nonZero);
P_ask = P_ask(idx_nonZero);

