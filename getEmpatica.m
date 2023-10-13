clear

rootDir = 'P:\WoodsLab\SMART\Data\ACT_E4';
outDir = fullfile(rootDir,'Organized');

if ~exist(outDir,'dir'); mkdir(outDir); end
zipfdr = dir(fullfile(rootDir,'**','*.csv'));

tic
parfor i = 1:length(zipfdr)
    % Get File Parts
    splt = strsplit(zipfdr(i).folder,filesep);
    
    % Get Sub
    sub = splt{cellfun(@(x) length(x)==6,regexp(splt,'\d','match'))};
    
    % Get Day
    try
        day = splt{~cellfun(@isempty,regexp(splt,'[Dd][Aa][Yy]','match'))};
        day = regexp(day(regexp(day,'[Dd][Aa][Yy]'):end),'\d','match');
        day = [day{:}];
    catch ME
        disp(ME.message)
        continue
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