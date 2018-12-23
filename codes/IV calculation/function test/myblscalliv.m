function IV = myblscalliv(S, K, r, tau, price, q, x0)
tol=1e-6;
% IV = arrayfun(@(i) NewtonRaphson_call(S(i), K(i), r(i), tau(i), price(i), q(i), x0(i), 1e-6), 1:numel(price));
% IV = arrayfun(@(i) NewtonRaphson_call_mex(S(i), K(i), r(i), tau(i), real(price(i)), q(i), x0(i), tol), 1:numel(price));
IV = arrayfun(@(i) NewtonRaphson_call(S(i), K(i), r(i), tau(i), real(price(i)), q(i), x0(i), tol), 1:numel(price));
IV = reshape(IV, size(S));