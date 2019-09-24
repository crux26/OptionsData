%% <importOpData_SPX_dly.m> -> <merge_OpDataNzerocd.m> -> <importOpData_SPX_dly_BSIV.m> -> <importOpData_SPX_dly_1shot.m>
% goto HigherMoments if needed: -> <OpData_dly_BSIV_Trim.m> -> <OpData_dly_BSIV_Trim_extrap.m>
%% Match zerocd rates for given TTM. No interp here; just closest value.
%% No more "tb_m3"; replaced by zerocd
%% Import the SPX Call data
clear;clc;
isDorm = true;
if isDorm == true
    drive = 'E:';
else
    drive = 'E:';
end

homeDirectory = sprintf('%s\\Dropbox\\GitHub\\OptionsData', drive);
genData_path = sprintf('%s\\data\\gen_data', homeDirectory);
rawData_path = sprintf('%s\\data\\rawdata', homeDirectory);
DaysPerYear = 252;

tic;
load(sprintf('%s\\rawOpData_SPX_dly.mat', genData_path), ...
    'CallData', 'PutData');
load(sprintf('%s\\zerocd.mat', genData_path), 'zerocd');
toc;

CallData.tb_m3 = [];
PutData.tb_m3 = [];

%%
zerocd = sortrows(zerocd, {'date', 'datedif_cal'});
CallData = sortrows(CallData, {'secid', 'date', 'exdate', 'strike_price'});
PutData = sortrows(PutData, {'secid', 'date', 'exdate', 'strike_price'});

[DatePair_C, idx_DatePair_C] = unique(CallData.date, 'rows');
[DatePair_P, idx_DatePair_P] = unique(PutData.date, 'rows');

%%
idx_DatePair_C = [idx_DatePair_C; size(CallData.date, 1) + 1]; % to include the last index.
idx_DatePair_P = [idx_DatePair_P; size(PutData.date, 1) + 1]; % unique() doesn't return the last index.

idx_DatePair_C_next = idx_DatePair_C(2:end)-1; idx_DatePair_C = idx_DatePair_C(1:end-1);
idx_DatePair_P_next = idx_DatePair_P(2:end)-1; idx_DatePair_P = idx_DatePair_P(1:end-1);

%
CallData.zerocd = nan(size(CallData, 1), 1);
CallData_ = [];
%
j=1;

%% Below can be improved, but didn't do it. Wouldn't have to stack CallData_tmp.
% 825s (dorm)
tic;
for j=1:length(DatePair_C)
	tmpIdx = idx_DatePair_C(j):idx_DatePair_C_next(j);
	CallData_tmp = CallData(tmpIdx, :);
	date0 = unique(CallData_tmp.date);
	idx_date = ismember(zerocd.date, date0);
	
	while sum(idx_date) == 0 % if no corresponding zerocd.date, use the most recent date's.
		date0 = busdate(date0, -1);
		idx_date = ismember(zerocd.date, date0);
	end
	zerocd_tmp = zerocd(idx_date, :);
	datedif_cal_ = unique(CallData_tmp.datedif_cal);
	
	for i=1:size(datedif_cal_)
		[~, idx_] = min(abs(datedif_cal_(i) - zerocd_tmp.datedif_cal));
		zerocd_ = zerocd_tmp.rate(idx_);
		idx__ = ismember(CallData_tmp.datedif_cal, datedif_cal_(i));
		CallData_tmp.zerocd(idx__) = zerocd_;
	end
	
	CallData_ = [CallData_; CallData_tmp];
	if floor(j/1000)*1000 == j
		fprintf('i: %d / %d\n', j, length(DatePair_C));
	end
end
toc;

CallData = CallData_;

%%
PutData.zerocd = nan(size(PutData, 1), 1);
PutData_ = [];
%
j=1;
% 68s (dorm): ?????????????
tic;
parfor j=1:length(DatePair_P)
	tmpIdx = idx_DatePair_P(j):idx_DatePair_P_next(j);
	PutData_tmp = PutData(tmpIdx, :);
	date0 = unique(PutData_tmp.date);
	idx_date = ismember(zerocd.date, date0);

	while sum(idx_date) == 0
		date0 = busdate(date0, -1);
		idx_date = ismember(zerocd.date, date0);
	end
	
	zerocd_tmp = zerocd(idx_date, :);
	datedif_cal_ = unique(PutData_tmp.datedif_cal);
	
	for i=1:size(datedif_cal_)
		[~, idx_] = min(abs(datedif_cal_(i) - zerocd_tmp.datedif_cal));
		zerocd_ = zerocd_tmp.rate(idx_);
		idx__ = ismember(PutData_tmp.datedif_cal, datedif_cal_(i));
		PutData_tmp.zerocd(idx__) = zerocd_;
	end
	
	PutData_ = [PutData_; PutData_tmp];
	if floor(j/1000)*1000 == j
		fprintf('i: %d / %d\n', j, length(DatePair_P));
	end
end
toc;

PutData = PutData_;


%% Save call and put data
CallData.Properties.VariableDescriptions{'zerocd'} = 'rf';
PutData.Properties.VariableDescriptions{'zerocd'} = 'rf';

% Below takes: 30s (dorm)
tic;
savefast(sprintf('%s\\rawOpData_SPXNzerocd_dly.mat', genData_path), ...
    'CallData', 'PutData');
toc;
