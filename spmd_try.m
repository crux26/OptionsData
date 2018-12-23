%% parfor slightly faster than spmd.
% Gave up fixing spmd. Duplicate in Composite().
% However, parfor seems not to be desgined for accumulating the dataset.

%% N = 123523 * 10

%%
clear; clc;
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
n = numpartitions(ds, gcp);

data_spmd_ = []; % 0x0 double
% data_spmd_ = table();
% data_spmd_ = cell();
tic;
spmd(0, n)
    subds = partition(ds, n, labindex);
    while hasdata(subds)
        data_spmd = read(subds);
        data_spmd_ = [data_spmd_; data_spmd];
    end
	data_spmd__ = gcat(data_spmd_);
end
toc;
% data_spmd{1}
% data_spmd_{1}

%%
clear; clc;
ds = tabularTextDatastore(repmat({'airlinesmall.csv'}, 1, 2), 'TreatAsMissing', 'NA', 'MissingValue',0);
ds.SelectedVariableNames = {'ArrDelay', 'DepDelay'};
n = numpartitions(ds, gcp);

data_spmd_ = [];

spmd(0, n)
    subds = partition(ds, n, labindex);
    while hasdata(subds)
        data_spmd = read(subds);
        data_spmd_ = [data_spmd_; data_spmd];
    end
    data_spmd__1 = gcat(table2cell(data_spmd));
    data_spmd__2 = gcat(table2cell(data_spmd_)); % duplicate
    
    data_spmd__3 = gop(@vertcat, table2cell(data_spmd));
    data_spmd__4 = gop(@vertcat, table2cell(data_spmd_));
end
% data_spmd__ = gcat(table2cell(data_spmd_));

a1 = data_spmd__1{1};
b1 = data_spmd__1{2};

a2 = data_spmd__2{1};
b2 = data_spmd__2{2};

a3 = data_spmd__3{1};
b3 = data_spmd__3{2};

a4 = data_spmd__4{1};
b4 = data_spmd__4{2};

fprintf('done!\n');


% Should preset the size. This is possible.
% data_spmd__ = [];
% for i = 1 : n
%     data_spmd__ = [data_spmd__; data_spmd_{i}];
% end

% data_spmd_{1};

