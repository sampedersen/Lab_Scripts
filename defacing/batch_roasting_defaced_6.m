%--------------------------------------------------------------------------
% Script: batch_roasting_defaced_6.m
% Author: Sam Pedersen 
% Date: 2023-08-08
%
%
% Description:
% This script will execute ROAST on a specified batch of participants and 
% each participant's batch of de-faced T1 scans. Produces solved FEMs for
% each de-faced version of each participant's T1, composed of 6 tissues.
%
% This script utilizes the ROAST (Realistic vOlumetric Approach to Simulate
% Transcranial electric stimulation) repository authored by Yu (Andy)
% Huang. For further information regarding documentation, copyright, 
% licensing, etc, please refer to the README.md within the github repo: 
% https://github.com/andypotatohy/roast
%
%
% Usage: 
% 1. Make sure that roast-3.0 and its subdirectories are added to the
% MATLAB path 
% 2. Make sure the current folder is also roast-3.0
% 3. Have Fun ;)
%
%--------------------------------------------------------------------------
%% Current montage info  
% -2ma at P3, +2mA at P4
% Pad-shape electrodes sized 70x50x3 mm3
% Format: 
% roast(participant_location,{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]})

%% Directories and constants   

% List of defacing algorithm names; matches the syntax of the participant 
% folders for outputs; also includes original as the non-defaced T1 image 
algorithms = {'original','mri_deface', 'mideface', 'fsl_deface', 'afni_reface', 'afni_deface'};

% List of the syntaxes for T1 files. Each algorithm defaced the T1 and
% modified the naming structure to indicate defacing with slight
% differences. For example, mri_deface produced T1_defaced.ni while
% afni_reface produced T1.reface.nii
t1_names = {'T1.nii', 'T1_defaced.nii', 'T1.reface.nii', 'T1.deface.nii'};

% Base directory where all the participant folders are hosted 
base_dir = 'P:\WoodsLab\ACT-head_models\FEM\Ayden\deface\new_montage\';

% Establish directory and location of .mat file containing conductivity
% values 
% Note: THIS IS HARDCODED! MAKE SURE THE CONDUCTIVITIES ARE HERE!!! 
numTissues = questdlg('How many tissues are you ROASTing?','NumTissues','6','11','6');

% List of participants to process; only includes the 6 digit-identifiers 
participants = [101190];

%% Execute batch ROASTing 

% For each participant listed in `participants`, perform the following
for p= 1:length(participants)
    
    % Establish the participant number by indexing into list of
    % participants
    participant = participants(p);
    
    % Combine with base_dir to form the full path to the specific 
    % participant's folder 
    folder_location = strcat(base_dir, num2str(participant),'\');
    
    % For this participant, perform the following for each of the 
    % algorithms listed in `algorithms`
    for i = 1:length(algorithms)
        
        % Set up a try block, in case there are errors/exceptions during
        % ROASTING 
        try
        
        % Establish a switch-case statement 
        switch i 
            
            % During the first iteration (i=1), process the original T1
            case 1
                % Specify the abs path into the specific algorithm's folder
                algorithm_folder = strcat(folder_location, algorithms(1), '\');
                % Specify abs path to defaced T1 with algorithm-specific
                % syntax 
                T1 = strcat(algorithm_folder,t1_names(1));
                T1 = T1{1};
                % Display message to indicate which partiicpant and which
                % version of the T1 is being ROASTed
                message = sprintf('ROASTing %d''s %s T1 ...', participant, algorithms{1});
                disp(message);
                % Perform the ROAST 
                roast(T1,{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]});
                % Extract JBrain and JRoast values from roastResult.mat
                % Create a list of files that correspond to naming for
                % roastResult.mat file 
                resfdr = dir(fullfile(algorithm_folder,'*roastResult.mat'));
                % If the created list is empty (ie, roastResult.mat DNE),
                % end the script and print out an error message
                if isempty(resfdr); error(['Cannot Locate ROAST results in ' algorithm_folder]); end
                % If the list is not empty, perform the extraction function
                ef2j(fullfile(algorithm_folder,resfdr.name),numTissues)
                
            % During the second iteration (i=2), process the mri_deface T1
            case 2
                % During the second iteration, when i=2,
                % process the mri_deface T1 
                algorithm_folder = strcat(folder_location, algorithms(2), '\');
                % Specify abs path to defaced T1 with algorithm-specific
                % syntax                 
                T1 = strcat(algorithm_folder,t1_names(2));
                T1 = T1{1};
                % Display message to indicate which partiicpant and which
                % version of the T1 is being ROASTed
                message = sprintf('ROASTing %d''s %s T1 ...', participant, algorithms{2});
                disp(message);
                % Perform the ROAST 
                roast(T1,{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]});
                % Extract JBrain and JRoast values from roastResult.mat
                % Create a list of files that correspond to naming for
                % roastResult.mat file 
                resfdr = dir(fullfile(algorithm_folder,'*roastResult.mat'));
                % If the created list is empty (ie, roastResult.mat DNE),
                % end the script and print out an error message
                if isempty(resfdr); error(['Cannot Locate ROAST results in ' algorithm_folder]); end
                % If the list is not empty, perform the extraction function               
                ef2j(fullfile(algorithm_folder,resfdr.name),numTissues)

            % During the third iteration (i=3), process the mideface T1
            case 3 
                % Third iteration, processing mideface
                algorithm_folder = strcat(folder_location, algorithms(3), '\');
                % Specify abs path to defaced T1 with algorithm-specific
                % syntax                 
                T1 = strcat(algorithm_folder,t1_names(2));
                T1 = T1{1};
                % Display message to indicate which partiicpant and which
                % version of the T1 is being ROASTed
                message = sprintf('ROASTing %d''s %s T1 ...', participant, algorithms{3});
                disp(message);
                % Perform the ROAST 
                roast(T1,{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]});
                % Extract JBrain and JRoast values from roastResult.mat
                % Create a list of files that correspond to naming for
                % roastResult.mat file                 
                resfdr = dir(fullfile(algorithm_folder,'*roastResult.mat'));
                % If the created list is empty (ie, roastResult.mat DNE),
                % end the script and print out an error message                
                if isempty(resfdr); error(['Cannot Locate ROAST results in ' algorithm_folder]); end
                % If the list is not empty, perform the extraction function                
                ef2j(fullfile(algorithm_folder,resfdr.name),numTissues)

            % During the fourth iteration (i=4), process the fsl_deface T1
            case 4
                % Fourth iteration, processing fsl_deface
                algorithm_folder = strcat(folder_location, algorithms(4), '\');
                % Specify abs path to defaced T1 with algorithm-specific
                % syntax                 
                T1 = strcat(algorithm_folder,t1_names(2));
                T1 = T1{1};
                % Display message to indicate which partiicpant and which
                % version of the T1 is being ROASTed
                message = sprintf('ROASTing %d''s %s T1 ...', participant, algorithms{4});
                disp(message);
                % Perform the ROAST 
                roast(T1,{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]});
                % Extract JBrain and JRoast values from roastResult.mat
                % Create a list of files that correspond to naming for
                % roastResult.mat file                 
                resfdr = dir(fullfile(algorithm_folder,'*roastResult.mat'));
                % If the created list is empty (ie, roastResult.mat DNE),
                % end the script and print out an error message                
                if isempty(resfdr); error(['Cannot Locate ROAST results in ' algorithm_folder]); end
                % If the list is not empty, perform the extraction function                
                ef2j(fullfile(algorithm_folder,resfdr.name),numTissues)

            % During the fifth iteration (i=5), process the afni_reface T1
            case 5
                % Fifth iteration, processing afni_reface
                algorithm_folder = strcat(folder_location, algorithms(5), '\');
                % Specify abs path to defaced T1 with algorithm-specific
                % syntax                 
                T1 = strcat(algorithm_folder,t1_names(3));
                T1 = T1{1};
                % Display message to indicate which partiicpant and which
                % version of the T1 is being ROASTed
                message = sprintf('ROASTing %d''s %s T1 ...', participant, algorithms{5});
                disp(message);
                % Perform the ROAST 
                roast(T1,{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]});
                % Extract JBrain and JRoast values from roastResult.mat
                % Create a list of files that correspond to naming for
                % roastResult.mat file                 
                resfdr = dir(fullfile(algorithm_folder,'*roastResult.mat'));
                % If the created list is empty (ie, roastResult.mat DNE),
                % end the script and print out an error message                
                if isempty(resfdr); error(['Cannot Locate ROAST results in ' algorithm_folder]); end
                % If the list is not empty, perform the extraction function                
                ef2j(fullfile(algorithm_folder,resfdr.name),numTissues)

            % During the sixth iteration (i=6), process the afni_deface T1
            case 6
                % Sixth iteratoin, processing afni_deface 
                algorithm_folder = strcat(folder_location, algorithms(6), '\');
                % Specify abs path to defaced T1 with algorithm-specific
                % syntax                 
                T1 = strcat(algorithm_folder,t1_names(4));
                T1 = T1{1};
                % Display message to indicate which partiicpant and which
                % version of the T1 is being ROASTed
                message = sprintf('ROASTing %d''s %s T1 ...', participant, algorithms{6});
                disp(message);
                % Perform the ROAST 
                roast(T1,{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]});
                % Extract JBrain and JRoast values from roastResult.mat
                % Create a list of files that correspond to naming for
                % roastResult.mat file                 
                resfdr = dir(fullfile(algorithm_folder,'*roastResult.mat'));
                % If the created list is empty (ie, roastResult.mat DNE),
                % end the script and print out an error message                
                if isempty(resfdr); error(['Cannot Locate ROAST results in ' algorithm_folder]); end
                % If the list is not empty, perform the extraction function                
                ef2j(fullfile(algorithm_folder,resfdr.name),numTissues)

            % Error message if trying to index outside of established
            % algorithm list 
            otherwise 
                disp(['Cannot ROAST undefined algorithm']);

        end
        
        % Catch block for if try fails; indicates an error during ROASTING
        % process.
        catch exception
            disp(['Error occurred. Unable to process, continuing to next step.']);
        end    
    end
end
