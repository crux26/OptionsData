% parfor seem to be little faster in this case.

%% Partition a Datastore in Parallel
% https://kr.mathworks.com/help/distcomp/partition-a-datastore-in-parallel.html
clear; clc;
ds = datastore(repmat({'airlinesmall.csv'},5,1),'TreatAsMissing','NA');
ds.SelectedVariableNames = 'ArrDelay';
%%
% reset(ds);
% tic
% [total,count] = sumAndCountArrivalDelay(ds);
% sumtime = toc;
% mean = total/count;

%% 
reset(ds);
tic
[total,count] = spmdSumAndCountArrivalDelay(ds);
spmdtime = toc;
mean = total/count;
% disp(mean);
fprintf('spmdtime: %6.4f\n', spmdtime);

%%
reset(ds);
tic;
[total,count] = parforSumAndCountArrivalDelay(ds);
parfortime = toc;
mean = total/count;
% disp(mean);
fprintf('parfortime: %6.4f\n', parfortime);


%%
function [total,count] = sumAndCountArrivalDelay(ds)
total = 0;
count = 0;
while hasdata(ds)
    data = read(ds);
    total = total + sum(data.ArrDelay,1,'OmitNaN');
    count = count + sum(~isnan(data.ArrDelay));
end
end

% numpartitions(): # of datastore partitions
function [total, count] = parforSumAndCountArrivalDelay(ds)

N = numpartitions(ds,gcp);
total = 0;
count = 0;
parfor ii = 1:N
    % Get partition ii of the datastore.
    subds = partition(ds,N,ii);
    
    [localTotal,localCount] = sumAndCountArrivalDelay(subds);
    total = total + localTotal;
    count = count + localCount;
end
end

% partition(): partition a datastore
function [total,count] = spmdSumAndCountArrivalDelay(ds)

spmd
    subds = partition(ds,numlabs,labindex);
    [total,count] = sumAndCountArrivalDelay(subds);
end

total = sum([total{:}]);
count = sum([count{:}]);
end
