%% Distributing Arrays to Parallel Workers
% https://kr.mathworks.com/help/distcomp/distributing-arrays-to-parallel-workers.html
clear; clc;
% Using Distributed Arrays to Partition Data Across Workers
% Load Distributed Arrays in Parallel Using datastore
files = repmat({'airlinesmall.csv'}, 10, 1);
ds = tabularTextDatastore(files);
ds.SelectedVariableNames = {'DepTime','DepDelay'};
ds.TreatAsMissing = 'NA';
dt = distributed(ds);
% summary(dt) 
% size(dt)
% head(dt)

% spmd: execute code in parallel on workers of parallel pool
spmd
    dt;
end

%% Alternative Methods for Creating Distributed and Codistributed Arrays
% parpool('local',2) % Create pool
W = ones(6,6);
W = distributed(W); % Distribute to the workers
spmd
    T = W*2; % Calculation performed on workers, in parallel.
             % T and W are both codistributed arrays here.
end
T            % View results in client.
whos         % T and W are both distributed arrays here.
% delete(gcp)  % Stop pool

% parpool('local',2) % Create pool
spmd
    codist = codistributor1d(3,[4,12]);
    Z = zeros(3,3,16,codist);
    Z = Z + labindex;
end
Z  % View results in client.
   % Z is a distributed array here.

   % delete(gcp) % Stop pool
