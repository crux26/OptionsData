%% Main purpose: fix the most endpoint only.
function [T_PutData] = dropEnd_OTMP_IV(T_PutData, tmpMult)
if size(T_PutData, 1) < 2
    return;
end

if nargin == 1
	tmpMult = 1.5;
end

%% drop
if length(T_PutData.mid)>2 && (T_PutData.K(1) < T_PutData.K(2) - tmpMult*(T_PutData.K(3)-T_PutData.K(2)))
% 	P = P(2:end); Kp = Kp(2:end); IV = IV(2:end);
    T_PutData = T_PutData(2:end,:);
end

%% extrap
m = length(T_PutData.K);
i=1;    % start from the ITM, more likely to be problematic.

while true
    if min(i+4,m)-(i+1) +1 <= 1  % interp1() needs at least 2 sample points.
        break;
    end
    
    %%
    idx = (T_PutData.K == T_PutData.K(i));
    K_tmp = T_PutData.K(~idx);
    IV_tmp = T_PutData.IV(~idx);
        
    IV_ = interp1(K_tmp, IV_tmp, T_PutData.K(i), 'pchip', 'extrap');
    
    %%
    if ( IV_ <= T_PutData.IV(i+1) && T_PutData.IV(i) > T_PutData.IV(i+1) ) || ...
            ( IV_ >= T_PutData.IV(i+1) && T_PutData.IV(i) < T_PutData.IV(i+1) )
        T_PutData.IV(i) = IV_;
        T_PutData.mid(i) = myblsput(T_PutData.S(1), T_PutData.K(i), ...
            T_PutData.r(1), T_PutData.TTM(1), T_PutData.IV(i), T_PutData.q(1));
        i = max(i-1, 1);
    else
        i = i+1;
    end
    if i==m
        break;
    end
end


% i=m;
% while true
%     if (i-1) - max(i-4, 1) + 1 <= 1 % interp1() needs at least 2 sample points.
%         break;
%     end
%     IV_ = interp1(T_PutData.K(max(i-4, 1):i-1), T_PutData.IV(max(i-4, 1):i-1), ...
%         T_PutData.K(i), 'nearest', 'extrap');  % pchip, spline can be <0 for some cases.
% 
%         
%     if ( IV_ >= T_PutData.IV(i-1) && T_PutData.IV(i) < T_PutData.IV(i-1) ) || ...
%             ( IV_ <= T_PutData.IV(i-1) && T_PutData.IV(i) > T_PutData.IV(i-1) )
%         T_PutData.IV(i) = IV_;
%         [~, T_PutData.mid(i)] = blsprice(T_PutData.S(i), T_PutData.K(i), T_PutData.r(i), T_PutData.TTM(i), ...
%             T_PutData.IV(i), T_PutData.q(i));
% %         i = min(i+1, m);
%         i = i-1;
% %     else
% %         i = i-1;
%     end
%     
%     if i==0
%         break;
%     end
% end
