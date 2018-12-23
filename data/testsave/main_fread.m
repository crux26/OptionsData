%% Seems to be impossible to access *.sas7bdat via MATLAB. GOTO python.

%% main_testload: fread() - read *.sas7bdat
fileID = fopen('D:\Dropbox\GitHub\OptionsData\data\a_stock\msenames_0.sas7bdat', 'r');
names0 = fread(fileID, 'float');
fclose(fileID);


%% Not working w/o hex2dec(); "binary" problematic with "char"
str = ['AB'; 'CD'; 'EF'; 'FA'];

fileID = fopen('bcd.bin','w');
fwrite(fileID,hex2dec(str),'ubit8');
fclose(fileID);

fileID = fopen('bcd.bin');
onebyte = fread(fileID, 4,'ubit8');
disp(dec2hex(onebyte))
