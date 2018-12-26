% Copied from /TRP/, but modified significantly. --> DEPRECATED NOW.
function [T_out] = drop_dMidViolate(T_in, diffStepSize)

whileFlag = 1;
while whileFlag
    try
        dMid = diff_central(T_in.mid, T_in.K, diffStepSize);
    catch
        break;
    end
    
    signdMid = ones(length(dMid), 1);
    for i = 2 : length(signdMid) -1
        if dMid(i) < dMid(i-1)
            %             || dMid(i) > dMid(i+1)
            signdMid(i) = -1;
        end
    end
    
    if ~any(signdMid == -1)
        whileFlag = 0;
    end
    
    T_in = T_in(signdMid == 1, :);
end

T_out = T_in;
