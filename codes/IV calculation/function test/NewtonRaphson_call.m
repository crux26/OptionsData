function IV = NewtonRaphson_call(S, K, r, tau, price, q, x0, tol)

% volMid = sqrt( abs( log(S/K) + r*tau) * 2/tau);
volMid = x0;
volMid(isnan(volMid))=0.2;
priceMid = myblscall(S,K,r,tau, volMid, q);
vegaMid = myblsvega(S,K,r,tau,volMid,q);
minDiff = abs(price - priceMid);

counter = 0;
while abs(price - priceMid) >= tol && abs(price - priceMid) <= minDiff
    counter = counter+1;
    if counter == 100
        break;
    end
    volMid_new = volMid - (priceMid - price) / vegaMid;
    if volMid < volMid_new - 1
        volMid = volMid + 1;
    elseif volMid > volMid_new + 1
        volMid = volMid - 1;
    else
        volMid = volMid_new;
    end
    priceMid = myblscall(S,K,r,tau,volMid,q);
    vegaMid = myblsvega(S,K,r,tau,volMid,q);
    if vegaMid < 1e-6
        vegaMid = 1e-6; % volMid_new overflow if(vegaMid<eps).
    end
    minDiff = abs(price - priceMid);
end
IV = volMid;
if IV < 0 || IV > 1e+1
    IV = NaN;
end
