%% Main purpose: fix the most endpoint only.
function [T_CallData] = dropEnd_OTMC_IV(T_CallData, tmpMult)
if size(T_CallData, 1) < 2 % Can be empty for "CallData_2".
    return;
end

if nargin == 1
	tmpMult = 1.5;
end

%% drop
% if Kc(end) >>> Kc(end-1), crazy extrapolation results occur.
while length(T_CallData.mid)>2 && ...
        (T_CallData.K(end) > T_CallData.K(end-1) + tmpMult*(T_CallData.K(end-1)-T_CallData.K(end-2)))
%     C = C(1:end-1); Kc = Kc(1:end-1); IV = IV(1:end-1);
	T_CallData = T_CallData(1:end-1,:);
end

%% extrap
m = length(T_CallData.K);
i=m;    % start from the OTM to ITM; from more correct to less correct
while true
    if (i-1)-max(i-4,1) +1 <= 1 % interp1() needs at least 2 sample points.
        break;
    end
    %%
    idx = T_CallData.K == T_CallData.K(i);
    K_tmp = T_CallData.K(~idx);
    IV_tmp = T_CallData.IV(~idx);
    
    IV_ = interp1(K_tmp, IV_tmp, T_CallData.K(i), 'pchip', 'extrap'); 
    
    if ( IV_ >= T_CallData.IV(i-1) && T_CallData.IV(i-1) > T_CallData.IV(i) ) || ...
            (IV_ <= T_CallData.IV(i-1) && T_CallData.IV(i-1) < T_CallData.IV(i) )
        T_CallData.IV(i) = IV_;
        T_CallData.mid(i) = myblscall(T_CallData.S(1), T_CallData.K(i), ...
            T_CallData.r(1), T_CallData.TTM(1), T_CallData.IV(i), T_CallData.q(1));
        i=min(i+1, m);
    else
        i=i-1;
    end
    if i==0
        break;
    end
end


%  i = 1;
% while true
%     if min(i+4, m) - (i+1) + 1 <= 1 % interp1() needs at least 2 sample points.
%         break;
%     end
%     
%     IV_ = interp1(T_CallData.K(i+1:min(i+4, m)), T_CallData.IV(i+1:min(i+4, m)), ...
%         T_CallData.K(i), 'nearest', 'extrap'); % pchip,spline yields <0 for some cases.
%     
%     if ( IV_ >= T_CallData.IV(i+1) && T_CallData.IV(i) < T_CallData.IV(i+1) ) || ...
%             ( IV_ <= T_CallData.IV(i+1) && T_CallData.IV(i) > T_CallData.IV(i+1) )
%         T_CallData.IV(i) = IV_;
%         T_CallData.mid(i) = blsprice(T_CallData.S(i), T_CallData.K(i), T_CallData.r(i), ...
%             T_CallData.TTM(i), T_CallData.IV(i), T_CallData.q(i));
% %         i = max(i-1, 1);
%         i = i+1;
% %     else
% %         i = i+1;
%     end
%     
%     if i>=m
%         break;
%     end
% end
