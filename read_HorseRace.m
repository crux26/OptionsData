%% horse-race b/w reading methods.
clear;clc;
% Winner: read(tabularTextDatastore()).
% Losers: gather(tall()), readtable(), textscan(), ...
%% read(): read data in datastore
% read data in TabularTextDatastore
ds = tabularTextDatastore('D:\Dropbox\GitHub\HigherMoments\data\rawdata\SPXCall_dly_2nd.csv','TreatAsMissing','NA','MissingValue',0);
% sums = [];
% counts = [];
% sumElapsedTime = 0;

for i =1 : 1
    tic;
    fprintf('tabularTextDatstore():\n');

    while hasdata(ds)
        T1 = read(ds);
        %     sumElapsedTime = sumElapsedTime + sum(T.ActualElapsedTime);
        %     sums(end+1) = sum(T.ArrDelay);
        %     counts(end+1) = length(T.ArrDelay);
    end
    %     avgArrivalDelay = sum(sums)/sum(counts)
    reset(ds);
    toc;
    % sumElapsedTime
    tic;
    fprintf('tall():\n');
    T = gather(tall(ds));
%     T = gather(T);
    reset(ds);
    toc;
end

%% textscan() (csvread(): only for numeric)
