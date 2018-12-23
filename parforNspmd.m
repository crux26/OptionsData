%% parfor slightly faster than spmd.
% Gave up fixing spmd. Duplicate in Composite().
% However, parfor seems not to be desgined for accumulating the dataset.

%% N = 123523 * 10
clear;clc;
ds = tabularTextDatastore(repmat({'airlinesmall.csv'},1,10), 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
n = numpartitions(ds, gcp);
% reads, but does not "concat"
data = table;
tic;
while hasdata(ds)
    data0 = read(ds);
    data = [data; data0];
end
toc;
clear data0;

%% Partition Data in Parallel
% ds = datastore('mapredout.mat');
clear; clc;
ds = tabularTextDatastore(repmat({'airlinesmall.csv'},1,10), 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
n = numpartitions(ds, gcp);

data_parfor_acc = table();
% % reads, but does not "concat"
tic;
parfor ii=1:n
    subds = partition(ds, n, ii);
    while hasdata(subds)
        data_parfor = read(subds);
        data_parfor_acc = [data_parfor_acc; data_parfor];
    end
end
toc;

%% more or less the same as while.
clear;clc;
% ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA', 'MissingValue',0);
% ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
ds = tabularTextDatastore(repmat({'airlinesmall.csv'},1,10), 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
tic;
data_tall = gather(tall(ds));
toc;

%% Easy & fast. slightly slower than spmd <-- Out-Of-Memory.
% Lot faster than just gather(tall()).

% Lot faster than using just read()
% ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA', 'MissingValue',0);
% ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
ds = tabularTextDatastore(repmat({'airlinesmall.csv'},1,10), 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
ds.ReadSize = 5e+4;
dt = distributed(ds);

tic;
data_dt = gather(dt);
toc;

%% 3523: read(ds).size. If accumulated, this becomes 123523
clear; clc;
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
data = table();
while hasdata(ds)
    data0 = read(ds);
    data = [data; data0];
end


%% returns the wrong result: only 3523 rows for each subds
% ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA', 'MissingValue',0);
% ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
clear;clc;
ds = tabularTextDatastore(repmat({'airlinesmall.csv'}, 1, 10), 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};

% data_spmd_acc=table();
n = numpartitions(ds, gcp);
preview(partition(ds, n, 1))
preview(partition(ds, n, 2))
preview(partition(ds, n, 10))
% labindex: index of this worker
tic;
% each data_spmd_acc: 135323 obs
% Here, obs is not stacked through gcat().
spmd(0, n)
    subds = partition(ds, n, labindex);
    while hasdata(subds)
        data_spmd = read(subds);
%         data_spmd_acc = [data_spmd_acc; data_spmd]; % All duplicates
    end
%     data_local = getLocalPart(data_spmd)
%     data_codist = getCodistributor(data_spmd);
%     idx_max = gcat(labindex);
% gcat(X, dim, targetlab)
%     data_spmd_acc = gcat(data_spmd_, 1, 1);
end
toc;
% for ii=1:numel(data_spmd)
%     data_spmd_acc=;
% end
data_spmd_acc = data_spmd{1};

% for i = 2 : max(idx_max{1})
%     data_spmd_acc = [data_spmd_acc; data_spmd{i}];
% end

% a=1; b=2;
% T1 = table(a);
% T2 = table(b);
% T = horzcat(T1, T2);


%%
clear; clc;
ds = tabularTextDatastore(repmat({'airlinesmall.csv'}, 1, 10), 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
n = numpartitions(ds, gcp);
tic;
spmd(0, n)
    subds = partition(ds, n, labindex);
    while hasdata(subds)
        data_spmd = read(subds);
    end
%     disp(labindex);
end
toc;
data_spmd_acc = gcat(data_spmd);

%%
clear; clc;
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
n = numpartitions(ds, gcp);
tic;
spmd(0, n)
    subds = partition(ds, n, labindex);
    while hasdata(subds)
        [data_spmd, info] = read(subds);
        disp(info.NumCharactersRead);
    end
end
toc;
