%% Collect and Visualize the Empatica E4 Data from ACT
% Created by Alejandro Albizu on 10/10/2023
% Last Updated: 10/17/2023 by AA
clear

% Settings
%================
zipDir = 'P:\WoodsLab\SMART\Data\ACT_E4';
rootDir = fullfile(zipDir,'tDCS-Phys');
% positDir = 'P:\WoodsLab\ACT-head_models\FEM\POSIT';
outDir = fullfile(zipDir,'Organized');
%================

outcomes = readtable(fullfile(zipDir,'tDCS-Phys','ACT-Sensation.csv'),'Format',repmat('%s',1,69));
records = readtable(fullfile(zipDir,'tDCS-Phys','ACT-Records.csv'),'Format','%s%d%s');
%% Parse Empatica Info
if ~exist(outDir,'dir'); mkdir(outDir); end
zipfdr = dir(fullfile(zipDir,'**','*.csv'));

tic
missing = cell(length(zipfdr),1);
parfor i = 1:length(zipfdr)
    if strcmp(zipfdr(i).folder,outDir); continue; end
    
    % Get File Parts
    splt = strsplit(zipfdr(i).folder,filesep);
    
    % Get Sub
    try 
        sub = splt{cellfun(@(x) length(x)==6,regexp(splt,'\d','match'))};
    catch ME
        missing{i} = zipfdr(i).folder;
        disp([num2str(i) ': ' ME.message])
        continue
    end
    
    % Get Day
    try
        day = splt{~cellfun(@isempty,regexp(splt,'[Dd][Aa][Yy]','match'))};
        day = regexp(day(regexp(day,'[Dd][Aa][Yy]'):end),'\d','match');
        day = [day{:}];
        
        % Skip Existing
%         if exist(fullfile(outDir,[
%                 'sub-',sub,'_ses-',num2str(day,'%2.f'),...
%                 '_',zipfdr(i).name]),'file'); continue;
%         end
    catch
        try
            day = splt{end}; idx = regexp(day,'[_-]');
            day = regexp(day(idx(end)+1:end),'\d','match');
            day = [day{:}];
            
            % Skip Existing
%             if exist(fullfile(outDir,[
%                     'sub-',sub,'_ses-',num2str(day,'%2.f'),...
%                     '_',zipfdr(i).name]),'file'); continue; 
%             end
        catch ME % Filename is too crazy to parse
            missing{i} = zipfdr(i).folder;
            disp([sub ': ' ME.message])
            continue
        end
    end

    % Copy files
%     copyfile(fullfile(zipfdr(i).folder,zipfdr(i).name), ...
%         fullfile(outDir, ...
%         ['sub-' sub '_ses-' num2str(day,'%2.f') '_' zipfdr(i).name]))
%     disp(['Copied sub-' sub '_ses-' num2str(day,'%02.f') '_' zipfdr(i).name ' ...'])
    
    % Load Cognitive Training
%     positfdr = dir(fullfile(positDir,['FS6.0_sub-' sub '_ses01'],'hist*.csv'));
%     if isempty(positfdr); continue; end
%     posit = readtable(fullfile(positfdr(end).folder,positfdr(end).name));

    % 
    try
        record = records{records{:,2} == str2double(sub),1};
        outcome = sum(str2double(outcomes{strcmp(outcomes{:,1},record) & ...
            strcmp(outcomes{:,4},day),[59 62]})) ...
            -sum(str2double(outcomes{strcmp(outcomes{:,1},record) & ...
            strcmp(outcomes{:,4},day),[20 24]}));
        label(i,:) = [str2double(sub) str2double(day) outcome];
    catch ME
        disp([sub '-' num2str(day) ': ' ME.message]); continue
    end
end
toc
%% Extract Data (Takes a long time ...)
tic
info = unique(label(all(~isnan(label),2),:),'rows'); info(1,:) = [];
info(:,4:5) = nan(length(info),2);
data = cell(length(info),2);
for i = 1:length(info)
    [stime, ttime, etime, tags, bvp_tag, eda_tag, bvp, eda] = deal([]); % Start Fresh
    try
        tags = readmatrix(fullfile(outDir, ...
            ['sub-',num2str(info(i,1)),'_ses-', ...
            num2str(info(i,2)),'_tags.csv'])); % Event Tags
        bvp = readmatrix(fullfile(outDir, ...
            ['sub-',num2str(info(i,1)),'_ses-', ...
            num2str(info(i,2)),'_BVP.csv'])); % Raw Data
        eda = readmatrix(fullfile(outDir, ...
            ['sub-',num2str(info(i,1)),'_ses-', ...
            num2str(info(i,2)),'_EDA.csv'])); % Raw Data
        fclose all;
        if isempty(bvp) || isempty(eda); continue; end
    catch
        continue;
    end
    
    % Session Timimg
    stime = datetime(bvp(1,1),'ConvertFrom','posixtime'); % Start Time
    ttime = datetime(tags,'ConvertFrom','posixtime'); % Tag Time
    etime = stime+seconds((length(bvp)-2)/bvp(2)); % End Time
    ttime = ttime(ttime > stime & ttime < etime & seconds(etime-ttime) > 1800); % Tag > start & < end & > 30 mins
    if isempty(ttime); continue; end % No good Tags
    if length(ttime) > 1; ttime = ttime(1); end % Just get first ?
    
    % Convert Tag for Data Type
    bvp_tag = ceil(seconds(ttime - stime)*bvp(2)); % In seconds from start
    eda_tag = ceil(seconds(ttime - stime)*eda(2)); % In seconds from start
    
    % Get Data
    data{i,1} = bvp(bvp_tag:end); % Get full e4
    data{i,2} = eda(eda_tag:end); % Get full e4
    
    % Get Session Info
    info(i,4:5) = [contains(records{records{:,2} == info(i,1),3},'Cognitive'), ...
        contains(records{records{:,2} == info(i,1),3},'+ tDCS')];
end

% REMOVE MISSING SESSIONS
info = info(all(~cellfun(@isempty,data),2),:);
data = data(all(~cellfun(@isempty,data),2),:); 

% Exactly 40 mins
bvp_mlen = max(cellfun(@length,data(:,1)));
eda_mlen = max(cellfun(@length,data(:,2)));

% Cut to Size
bvp_data = cell2mat(cellfun(@(x) x(1:40*60*bvp(2)), cellfun(@(x) [x;nan(max(40*60*bvp(2)-length(x),0),1)],data(:,1),'uni',0),'uni',0)');
eda_data = cell2mat(cellfun(@(x) x(1:40*60*eda(2)), cellfun(@(x) [x;nan(max(40*60*eda(2)-length(x),0),1)],data(:,2),'uni',0),'uni',0)');

% Save Data
writematrix(bvp_data,fullfile(rootDir,'bvp_data.csv'))
writematrix(eda_data,fullfile(rootDir,'eda_data.csv'))
writematrix(info,fullfile(rootDir,'info.csv'))
toc
%% Check out the Data
clearvars -except bvp_data eda_data info
bvp_data = detrend(bvp_data,5); % Flatten Timeseries
ismax = islocalmax(bvp_data,'MinProminence',1); % Find Peaks

% Compute HR Variability
hrv = nan(size(bvp_data,2),1); 
for i = 1:size(ismax,2)
    hrv(i) = std(diff(find(ismax(:,i))/64));
end

sc = median(eda_data,'omitnan')';

% Average HRV per Group per Session (smoothed)
davg = nan(20,4);
for d = 1:20
    davg(d,1) = smooth(median(hrv(info(:,2) == d & info(:,4) == 1 & info(:,5) == 1),'omitnan'));
    davg(d,2) = smooth(median(hrv(info(:,2) == d & info(:,4) == 0 & info(:,5) == 1),'omitnan'));
    davg(d,3) = smooth(median(hrv(info(:,2) == d & info(:,4) == 1 & info(:,5) == 0),'omitnan'));
    davg(d,4) = smooth(median(hrv(info(:,2) == d & info(:,4) == 0 & info(:,5) == 0),'omitnan'));
end

% Average Skin Conductance per Session (smoothed)
eavg = nan(20,4);
for d = 1:20
    eavg(d,1) = smooth(median(sc(info(:,2) == d & info(:,4) == 1 & info(:,5) == 1),'omitnan'));
    eavg(d,2) = smooth(median(sc(info(:,2) == d & info(:,4) == 0 & info(:,5) == 1),'omitnan'));
    eavg(d,3) = smooth(median(sc(info(:,2) == d & info(:,4) == 1 & info(:,5) == 0),'omitnan'));
    eavg(d,4) = smooth(median(sc(info(:,2) == d & info(:,4) == 0 & info(:,5) == 0),'omitnan'));
end

% Plot
figure;
subplot(221); plot(davg-davg(1,:));
xlabel Session
ylabel HRV
legend({'CT+TDCS','ET+TDCS','CT','ET'})
subplot(222);
gscatter(hrv(info(:,3)~=0),info(info(:,3)~=0,3),...
info(info(:,3)~=0,5)); lsline
ylabel Nervousness
xlabel HRV
subplot(223); plot(eavg-eavg(1,:));
xlabel Session
ylabel EDA
legend({'CT+TDCS','ET+TDCS','CT','ET'})
subplot(224);
gscatter(sc(info(:,3)~=0),info(info(:,3)~=0,3),...
info(info(:,3)~=0,5)); lsline
ylabel Nervousness
xlabel 'Skin Conductance'