clear

rootDir = 'P:\WoodsLab\SMART\Data\ACT_E4';
outDir = fullfile(fileparts(rootDir),'E4_Organized');

if ~exist(outDir,'dir'); mkdir(outDir); end
zipfdr = dir(fullfile(rootDir,'**','*.csv'));

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
    catch
        try
            day = splt{end}; idx = regexp(day,'[_-]');
            day = regexp(day(idx(end)+1:end),'\d','match');
            day = [day{:}];
        catch ME
            missing{i} = zipfdr(i).folder;
            disp([sub ': ' ME.message])
            continue
        end
    end
    
    % Copy files
    if ~exist(fullfile(outDir,['sub-' sub '_ses-' num2str(day,'%2.f') '_' zipfdr(i).name]),'file')
        copyfile(fullfile(zipfdr(i).folder,zipfdr(i).name), ...
            fullfile(outDir, ...
            ['sub-' sub '_ses-' num2str(day,'%2.f') '_' zipfdr(i).name]))
        disp(['Copied sub-' sub '_ses-' num2str(day,'%02.f') '_' zipfdr(i).name ' ...'])
    end
end
toc