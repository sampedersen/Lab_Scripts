% Copy files from Directory A to Directory B 

%{
This script is currently hardcoded for copying quality-checked and 
finalized tissue masks for ACT AI purposes. If you wish to use this script
for other directories/purposes/etc, 
%}

%% Establish directories
% Source directory: 
dir_A = "P:\WoodsLab\ACT-head_models\FEM\manual_segmentation\allParticipants\PL_v3\";
% Target directory: 
dir_B = "P:\WoodsLab\ACT-head_models\Fang_Lab\Jason_Chen\RF1_ACT\v3";

tissue_list = ["air.raw";"blood.raw";"cancellous.raw";"cortical.raw";"csf.raw";"eyes.raw";"fat.raw";"gm.raw";"muscle.raw";"skin.raw";"wm.raw"];
T1s = ["T1.nii","T1.RAW"];

%% Isolate participant list from files 
% Retrieve contents of overall source directory 
contents = dir(dir_A);
% Pre-allocate array for the size of directory (remove 2 units to account for . and ..) 
names = cell(1,length(contents)-2);
% For each item in the folder (excluding . and .. directory navigators)...
for i = 3:length(contents)
    % Retrieve the nested directory's name  
    fldr_name = contents(i).name;
    % Add the participant's directory name to array of names 
    names{i-2} = fldr_name;
end

%% Isolate individual participant numbers 
% Establish 6-digit pattern
pattern = '\d{6}';
% Pre-allocate for list of participants by number 
participant_numbers = cell(1,length(names));
% For each participant...
for j=1:length(names)
    % Isolate the corresponding participant number
    participant_numbers{j} = regexp(names{j}, pattern, 'match');
end

%% Begin copying files 
% For each participant...
for k = 1:length(participant_numbers)
% for k=1:3
    T1_paths =["T1.raw","T1.nii"];
    current_participant = participant_numbers{k}{1};    
    fprintf('Copying participant %s...\n',current_participant);
    
    %--------------------------- Step 1 -----------------------------------
    % Establish specific paths to different source files/directories 
    % Specify the path to participant's overall folder 
    folder = "FS6.0_sub-"+ participant_numbers{k} +"_ses01"; % Syntax
    participant_folder = fullfile(dir_A,folder); % Path 
    % Specify tissue folder
    tissues = fullfile(participant_folder,"qualityCheck\tissueMasks");
    % Specify T1 file paths 
    for m = 1:length(T1s)
        % Update T1 path names for the specific participant 
        T1_paths(m) = fullfile(participant_folder,T1s(m));
    end 
    
    %--------------------------- Step 2 -----------------------------------
    
    % Check if the participant's folder exists in the target location
    % Specify target folder name 
    new_prtcpnt_folder = fullfile(dir_B,participant_numbers{k});
    % If the directory does not exist 
    if exist(new_prtcpnt_folder,'dir')== 0
        % Make the directory 
        mkdir(new_prtcpnt_folder);
        % Print confirmation
        fprintf('   Created the directory "%s". Continuing to next step.\n',new_prtcpnt_folder);
    else 
        % If directory already exists, print confirmation
        fprintf('   "%s" already exists. Continuing to next step.\n',new_prtcpnt_folder);
    end
    
    %--------------------------- Step 3 -----------------------------------
    
    % Copy the tissues 
    
    % Track which tissue copied 
    tissues_copied = false(11,1);
    
    % Check if the tissue masks have already been copied
    % For each tissue...
    for n = 1:length(tissue_list)
        tissue_file = fullfile(new_prtcpnt_folder,tissue_list(n));
        % If the file DNE in the target location...
        if exist(tissue_file,'file')==0
            % ... Copy it
            % Identify original file 
            original_tissue = fullfile(tissues, tissue_list(n));
            % Copy the file 
            status = copyfile(original_tissue,new_prtcpnt_folder);
            % Update status tracker 
            tissues_copied(n) = status;
        % If it pre-exists in the folder, update the tracking to reflect 
        else
            tissues_copied(n)=true;
        end
    end
    
    %--------------------------- Step 4 -----------------------------------
    % Copy the T1s
    
    % Track which tissue copied 
    t1s_copied = false(2,1);
    
    % Check if the tissue masks have already been copied
    % For each tissue...
    for o = 1:2
        t1_file = fullfile(new_prtcpnt_folder,T1s(o));
        
        % If the file DNE in the target location...
        if exist(t1_file,'file')==0
            % ... Copy it
            % Identify original file 
            original_t1 = T1_paths(o);
            % Copy the file 
            status = copyfile(original_t1,new_prtcpnt_folder);
            % Update status tracker 
            t1s_copied(o) = status;
            
        % If it pre-exists in the folder, update the tracking to reflect 
        else
            t1s_copied(o)=true;
        end
    end
    
    %--------------------------- Step 5 -----------------------------------
    % Summarize actions and print
    
    % Participant number
    number = participant_numbers{k}{1};
    
    % -----------   Check that all tissues were moved    -----------------
    % If one or more tissues are missing in the target directory...
    if sum(tissues_copied)<11
        % Notify of absence
        fprintf('   Not all tissues found/copied for participant %s. Please review:\n',number);
        % Specify which tissues have moved 
        for p=1:11
            % Specify tissue 
            mask = tissue_list{p};
            if exist(fullfile(new_prtcpnt_folder,mask),'file')==0
                fprintf('        %s_%s could not be copied.\n',number,mask)
            else
                fprintf('        %s_%s copied successfully.\n',number,mask)
            end
        end
    % If none of the 11 tissue masks are missing...
    elseif sum(tissues_copied)==11
        % Confirm success and continue
        fprintf('   All 11 tissue masks were located and successfully copied for participant %s.\n',number);
    % If an unexpected sum is produced, advise user to review manually 
    else
        fprintf('   Unexpected actions occurred for participant %s. Please review manually and see below:\n',number);
        % Print out existence status in target directory 
        for p=1:11
            % Specify tissue 
            mask = tissue_list{p};
            if exist(fullfile(new_prtcpnt_folder,mask),'file')==0
                fprintf('        %s_%s could not be copied.\n',number,mask)
            else
                fprintf('        %s_%s copied successfully.\n',number,mask)
            end
        end
    end
    
    % ---------------   Check that T1s were moved    ----------------------
    if sum(t1s_copied)<2
        % Notify of absence
        fprintf('   Not all T1s found/copied for participant %s. Please review:\n',number);
        % Specify which tissues have moved 
        for p=1:2
            % Specify tissue 
            t1_name = T1s{p};
            if exist(fullfile(new_prtcpnt_folder,t1_name),'file')==0
                fprintf('        %s_%s could not be copied.\n',number,t1_name)
            else
                fprintf('        %s_%s copied successfully.\n',number,t1_name)
            end
        end
    % If none of the t1s are missing...
    elseif sum(t1s_copied)==2
        % Confirm success and continue
        fprintf('   Both T1 files were located and successfully copied for participant %s.\n',number);
    % If an unexpected sum is produced, advise user to review manually 
    else
        fprintf('   Unexpected actions occurred for participant %s. Please review manually and see below:\n',number);
        % Print out existence status in target directory 
        for p=1:2
            % Specify tissue 
            t1_name = T1s{p};
            if exist(fullfile(new_prtcpnt_folder,t1_name),'file')==0
                fprintf('        %s_%s could not be copied.\n',number,t1_name)
            else
                fprintf('        %s_%s copied successfully.\n',number,t1_name)
            end
        end
    end
    disp("   Continuing to next participant...");
end
    
    

        

    
    







