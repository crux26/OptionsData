%% If working with str, must use cell arrays.
% str may differ in length. In that case, cell is must.
% If len(str)=const, then vertcat possible. However, (nObs)*(len(str)) char
% variable, NOT a vector. This should be read as var(i, :).

%% textscan: reads as cell
%% fscanf: reads as text
%% fread: read data from binary file

%% write
clear; clc;
str = {'AB'; 'CD'; 'EF'; 'FA'}; %4x1, 464byes cell

fileID = fopen('str.txt','W');
fprintf(fileID,'%s\n', str{:});
fclose(fileID);

type str.txt

%% cell array working improper w/ fscanf
fileID = fopen('str.txt', 'r');
A = fscanf(fileID, '%s \n', [4,1]);
fclose(fileID);
disp(A);
%% read
i=1;
A = cell(4, 1);
fileID = fopen('str.txt', 'r');
while ~feof(fileID)
	A{i} = fgetl(fileID);
    i = i+1;
end
fclose(fileID);
celldisp(A);


%%
A = cell(4, 1);
fileID = fopen('str.txt', 'r');
for i=1:4
	A{i} = fgetl(fileID);
end
fclose(fileID);
celldisp(A);





%% fwrite, fread: binary. same format needed.
rng(0);
x = rand(4);

fileID = fopen('nums2.bin','w');
fwrite(fileID, x, 'float32');
fclose(fileID);

fileID = fopen('nums2.bin','r');
x_ = fread(fileID, 'float32');
fclose(fileID);

x_ = reshape(x_, 4, 4);

%% Not working w/o hex2dec(); "binary" problematic with "char"
str = ['AB'; 'CD'; 'EF'; 'FA'];

fileID = fopen('bcd.bin','w');
fwrite(fileID,hex2dec(str),'ubit8');
fclose(fileID);

fileID = fopen('bcd.bin');
onebyte = fread(fileID, 4,'ubit8');
disp(dec2hex(onebyte))

%% fscanf: can read txt only

x = 100*rand(8,1);
fileID = fopen('nums1.txt','w');
fprintf(fileID,'%4.4f\n',x);
fclose(fileID);

% type nums1.txt
fileID = fopen('nums1.txt','r');
A = fscanf(fileID,'%f'); % returns mat
fclose(fileID);

i=1;
fileID = fopen('nums1.txt','r');
while ~feof(fileID)
    A(i) = fgetl(fileID); % returns num as char
    i=i+1;
end
fclose(fileID);

