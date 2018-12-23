%% SAS.date to MATLAB.date
% yyyy-mm-dd not supported.
function datenum_vec = SAS2MAT_DateConversion(yyyymmdd)
yyyy = floor(yyyymmdd/10000);
mmdd = yyyymmdd - yyyy*10000;
mm = floor(mmdd/100);
dd = mmdd - mm*100;
datenum_vec = datenum(yyyy, mm, dd);


% function datenum_vec = SAS2MAT_DateConversion(ddmmyyyy)
% ddmm = floor(ddmmyyyy/10000);
% yyyy = ddmmyyyy - ddmm*10000;
% dd = floor(ddmm/100);
% mm = ddmm - dd*100;
% datenum_vec = datenum(yyyy, mm, dd);
% 
