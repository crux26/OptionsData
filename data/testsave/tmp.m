% space = char(32);
%% 
clear; clc;
str = {'AB'; 'CD'; 'EF'; 'FA'};

fileID = fopen('str.txt','W');
fprintf(fileID,'%s\n', str{:});
fclose(fileID);

type str.txt

%% fprintf(formatSpec, ...);
i=1;
fileID = fopen('str.txt.', 'r');
while ~feof(fileID)
	A{i} = fgetl(fileID);
%     A{i} = tline;
    i = i+1;
%     fprintf('%s\n', tline);
end
fclose(fileID);

%%
% fileID = fopen('str.txt.', 'r');
% str_ = fgetl(fileID);
% while ischar(tline)
%     str_ = fgets(fileID);
% end
% fclose(fileID);
% disp(str_);

%% works, but returns a cell array
fileID = fopen('str.txt.', 'r');
str_ = textscan(fileID, '%s');
fclose(fileID);
celldisp(str_);

%%
A{1} = 'ab';
