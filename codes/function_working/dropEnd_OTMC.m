function [T_CallData] = dropEnd_OTMC(T_CallData, tmpMult)
% "mid" is NOT "S".
if isempty(T_CallData)  % Can be empty for "CallData_2".
    T_CallData=[];
    return;
end

if nargin == 1
	tmpMult = 1;
end

%% drop
% if Kc(end) >>> Kc(end-1), crazy extrapolation results occur.
while length(T_CallData.mid)>2 && ...
        (T_CallData.K(end) > T_CallData.K(end-1) + tmpMult*(T_CallData.K(end-1)-T_CallData.K(end-2)))
%     C = C(1:end-1); Kc = Kc(1:end-1); IV = IV(1:end-1);
	T_CallData = T_CallData(1:end-1,:);
end

%% extrap - deprecated. Below will be covered in dropEnd_OTMC_IV().
% Now has multiple TTMs, which does not work for the below case. should be fixed.
% m = length(T_CallData.K);
% i=m;
% 
% while length(T_CallData.mid)>2 && (T_CallData.mid(i)>=T_CallData.mid(i-1))
%     if (i-1)-max(i-4,1) +1 <= 1 % interp1() needs at least 2 sample points.
%         break;
%     end
%     IV_ = interp1(T_CallData.K(max(i-4,1):i-1), T_CallData.IV(max(i-4,1):i-1), ...
%         T_CallData.K(i), 'nearest', 'extrap'); % pchip,spline yields <0 for some cases.
%     if IV_ <= T_CallData.IV(i-1) && IV_ < T_CallData.IV(i)
%         T_CallData.IV(i) = IV_;
%         T_CallData.mid(i) = myblscall(T_CallData.S(1), T_CallData.K(i), ...
%             T_CallData.r(1), T_CallData.TTM(1), T_CallData.IV(i), T_CallData.q(1));
%         i=i+1;
%         if i>=m
%             break;
%         end
%     else
%         i=i-1;
%     end
% end
