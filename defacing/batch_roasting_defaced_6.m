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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Montage recipe
% -2ma at P3, +2mA at P4
% Pad-shape electrodes sized 70x50x3 mm3
% Format: 
% roast(participant_location,{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Directories and constants 

% Path to conductivity values (HARDCODED; CHANGE IF NEEDED)
cond_dir = '/blue/camctrp/working/aprinda/Sam_hpg/scripts/';
condFile = fullfile(cond_dir,'cond_6tis.mat');


% List of algorithms and corresponding T1 file names 
t1s = ["original","T1.nii";
    "mri_deface","T1_defaced.nii";
    "mideface","T1_defaced.nii";
    "fsl_deface","T1_defaced.nii";
    "afni_reface","T1.reface.nii";
    "afni_deface","T1.deface.nii";];


% Path to directory containing all participant folders 
base_dir = '/blue/camctrp/working/aprinda/Sam_hpg/deface/participant_data/high_25/';

% Simulation tag for current ROAST session (CHANGE IF NEEDED)
uniTag = 'DEFACE_mont2';

% Identify participants to exclude from ROASTING
participants_to_exclude = [];


% Hardcode list of participants 
participants = [101190, 103116, 104503, 115791, 202384, 203395, 203730, 300142, 300609, 300802, 301263, 301293, 301501, 302092, 302558, 302778, 302835, 303182, 303367, 303620];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Batch ROAST the list of participants  
% For each participant listed in `participants`, perform the following

for p= 1:length(participants)
    
    % Establish the participant number
    participant = string(participants(p));
    % Form the full path to the participant's folder 
    folder_location = fullfile(base_dir, participant);


    % Loop through the listed algorithms and perform the following for each
    
    for i = 1:size(t1s,1)
        
        % Set up a try block, in case there are errors
        try
            
            % Pull algorithm name from i row, 1st column of t1s array 
            algorithm_folder = fullfile(folder_location,t1s{i,1});
            % Pull T1 file name from i row, 2nd column of t1s array 
            t1_file = fullfile(algorithm_folder,t1s(i,2));

            % Check if ROAST has already been completed (does Jroast exist)
            roast_dne = isempty(dir(fullfile(algorithm_folder,'*_Jroast.nii')));
                
            if roast_dne == 0
                % ROAST is complete, continue to next algorithm. 
                message = sprintf('ROAST for %d''s %s T1 completed. Continuing to next algorithm.', str2double(participant), t1s{i,1});
                disp(message);

            else 
                % If ROAST has not been completed, ROAST it 
                message = sprintf('ROASTing %d''s %s T1 ...', str2double(participant), t1s(i,1));
                disp(message);
                % Execute ROAST 
                roast(t1_file{1},{'P3',-2,'P4',2},'electype',{'pad','pad'},'elecsize',{[70 50 3],[70 50 3]},'simulationTag',uniTag);
               
                % Extract JBrain and JRoast values from roastResult.mat
                % If the script cannot find the ROAST results file, end
                resfdr = dir(fullfile(algorithm_folder{1},'*roastResult.mat'));
                if isempty(resfdr); error(['Cannot Locate ROAST results in ' algorithm_folder{1}]); end

                % If ROAST results are located, execute ef2j script and
                % convert electric field results to map of J values
                ef2j(fullfile(resfdr.folder,resfdr.name),uniTag,condFile)
            end

        catch exception 
            message = sprintf('Error ROASTING %d''s %s T1. Continuing to next algorithm.',str2double(participant),t1s(i,1));
            disp(message);
        end
    end
end
