function [T_PutData] = dropEnd_OTMP(T_PutData, tmpMult)
% "mid" is NOT "S".
% Copied from TRP, but changed the structure here.
if isempty(T_PutData)   % Can be empty for "PutData_2".
    T_PutData=[];
    return;
end

if nargin == 1
	tmpMult = 1;
end

%% drop
if length(T_PutData.mid)>2 && (T_PutData.K(1) < T_PutData.K(2) - tmpMult*(T_PutData.K(3)-T_PutData.K(2)))
% 	P = P(2:end); Kp = Kp(2:end); IV = IV(2:end);
    T_PutData = T_PutData(2:end,:);
end

%% extrap 
i=1;
m = length(T_PutData.K);
while length(T_PutData.mid)>2 && (T_PutData.mid(i)>=T_PutData.mid(i+1))
    if min(i+4,m)-(i+1) +1 <= 1  % interp1() needs at least 2 sample points.
        break;
    end
    IV_ = interp1(T_PutData.K(i+1:min(i+4,m)), T_PutData.IV(i+1:min(i+4,m)), ...
        T_PutData.K(i), 'nearest', 'extrap');  % pchip, spline can be <0 for some cases.
                                                % P will be near-0 anyway (even if IV>>0)
    if IV_ >= T_PutData.IV(i+1) && IV_ > T_PutData.IV(i)
        T_PutData.IV(i) = IV_;
        T_PutData.mid(i) = myblsput(T_PutData.S(1), T_PutData.K(i), ...
            T_PutData.r(1), T_PutData.TTM(1), IV(i), T_PutData.q(1));
        i=i-1;
    else
        i=i+1;
    end
    if i==0
        break;
    end
end


% while length(T_PutData.mid)>2 && (T_PutData.mid(i)>=T_PutData.mid(i+1))
%     if min(i+4,m)-(i+1) +1 <= 1  % interp1() needs at least 2 sample points.
%         break;
%     end
%     IV_ = interp1(T_PutData.K(i+1:min(i+4,m)), T_PutData.IV(i+1:min(i+4,m)), ...
%         T_PutData.K(i), 'nearest', 'extrap');  % pchip, spline can be <0 for some cases.
%                                                 % P will be near-0 anyway (even if IV>>0)
%     if IV_ >= T_PutData.IV(i+1) && IV_ > T_PutData.IV(i)
%         T_PutData.IV(i) = IV_;
%         T_PutData.mid(i) = myblsput(unique(T_PutData.S), T_PutData.K(i), ...
%             unique(T_PutData.r), unique(T_PutData.TTM), IV(i), unique(T_PutData.q));
%         i=i-1;
%     else
%         i=i+1;
%     end
%     if i==0
%         break;
%     end
% end
