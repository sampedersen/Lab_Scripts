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
        outcome = str2double(outcomes{strcmp(outcomes{:,1},record) & strcmp(outcomes{:,4},day),59})-str2double(outcomes{strcmp(outcomes{:,1},record) & strcmp(outcomes{:,4},day),20});
        label(i,:) = [str2double(sub) str2double(day) outcome];
    catch ME
        disp([sub '-' num2str(day) ': ' ME.message]); continue
    end
end
toc
%% Extract Data (Takes a long time ...)
baseFilename = 'BVP.csv';

info = unique(label(all(~isnan(label),2),:),'rows');
info(:,4:5) = nan(length(info),2);
data = cell(length(info),1);
for i = 1:length(info)
    try
        tags = readmatrix(fullfile(outDir, ...
            ['sub-',num2str(info(i,1)),'_ses-', ...
            num2str(info(i,2)),'_tags.csv'])); % Event Tags
        e4 = readmatrix(fullfile(outDir, ...
            ['sub-',num2str(info(i,1)),'_ses-', ...
            num2str(info(i,2)),'_',baseFilename])); % Raw Data
        fclose all;
        if isempty(e4); continue; end
    catch
        continue;
    end
    stime = datetime(e4(1,1),'ConvertFrom','posixtime'); % Start Time
    ttime = datetime(tags,'ConvertFrom','posixtime'); % Tag Time
    etime = stime+seconds((length(e4)-2)/e4(2)); % End Time
    ttime = ttime(ttime > stime & ttime < etime & seconds(etime-ttime) > 1800); % Tag > start & < end & > 30 mins
    if isempty(ttime); continue; end % No good Tags
    if length(ttime) > 1; ttime = ttime(1); end % Just get first ?
    tag = round(seconds(ttime - stime)*e4(2)); % In seconds from start
    data{i} = e4(tag:end); % Get full e4
    info(i,5:6) = [contains(records{records{:,2} == info(i,1),3},'Cognitive'), ...
        contains(records{records{:,2} == info(i,1),3},'+ tDCS')];
    clear stime ttime etime tags tag e4;
end
info = info(~cellfun(@isempty,data),:);
data = data(~cellfun(@isempty,data));

writematrix(alldata,fullfile(rootDir,'data.csv'))
writematrix(info,fullfile(rootDir,'info.csv'))