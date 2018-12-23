%% Options: 1) savefast() 2) Try fread().
%% str, which must use cell, works improperly w/ fscanf(). Use fgetl().
%% For num, use fscanf(). fgetl() works weirdly.

%% msenames_0: exchcd, num len 8
%% msenames_1: (exchcd, compno), num len 8
%% msenames_2: (exchcd, cusip), num len 8, char len 8

%%
tic;
save('D:\Dropbox\GitHub\OptionsData\data\testsave\ds1.mat', 'A', '-v7.3', '-nocompression');
toc;

%% no '-nocompression' for this. Uses HD5 format.
tic;
savefast('D:\Dropbox\GitHub\OptionsData\data\testsave\ds2.mat', 'A');
toc;
