%% Use Tall Arrays on a Parallel Pool
%% Be aware of mapreducer();

% https://kr.mathworks.com/help/distcomp/run-tall-arrays-on-a-parallel-pool.html
ds = datastore('airlinesmall.csv');
varnames = {'ArrDelay', 'DepDelay'};
ds.SelectedVariableNames = varnames;
ds.TreatAsMissing = 'NA';

tt = tall(ds)
a = tt.ArrDelay;

m = mean(a,'omitnan');
s = std(a,'omitnan');
one_sigma_bounds = [m-s m m+s];
sig1 = gather(one_sigma_bounds)

[max_delay, min_delay] = gather(max(a),min(a));

% mapreducer(): Define execution environment for mapreduce or tall arrays

% mapreducer(0): force MATLAB to use the local session
mapreducer(0);

% mapreducer(mr): sets the global execution environment using a previously created MapReducer object, mr.
mapreducer(gcp);
