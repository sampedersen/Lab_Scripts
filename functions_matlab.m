%{
-------------------------------------------------------------------------
Script: functions_matlab.m
Author: Sam Pedersen 
Date: 2023-09-26

Description: 
This script is intended to serve as a collection of useful MATLAB 
functions with relevant comments/structure to support its implementation. 
 

Usage:
Read each function and discern necessary variables needed to be changed. 

-------------------------------------------------------------------------
%}

%% Move directories 
%{
  Move source_dir into target_dir 
  
  source = Directory/file to be moved 
  target_dir = Target location to move the directory into 

%}

% Change this to be the directory/file you want to move 
source = 'P:\WoodsLab\ACT-head_models\';
% Change this to be the directory you want to move the directory/file into 
target_dir = 'W:\camctrp\working\';
% If both of the specified folders/file exist, try to move it 
if exist(source) ~= 0 && exist(target_dir) ~= 0
  try 
    % Move the files 
    movefile(source,target_dir);
    % Display confirmation that files were moved 
    disp('Moved source folder/file to target directory successfully.');
  catch 
    % Notify of error in case unable to move files 
    disp('Failed to move folder/file.');
  end
% If both/one of the files/folders DNE, notify of error and double-check inputs. 
else
  disp('Specified target/source directories/file do not exist as indicated.');
end

% -------------------------------------------------------------------------

%% Get file names from directory 
%{
  Create a cell array containing the file names for a directory's contents. 
  File names will be stored in a cell array titled "names".

  target_dir = The directory to acquire file names from 
  
%}
% Change this to be the directory you want to retrieve file names from 
target_dir = 'P:\WoodsLab\ACT-head_models\FEM\';
% Retrieve all contents and meta data from directory 
contents = dir(target_dir);
% Pre-allocate cell array to size of directory (remove 2 units to account for . and ..) 
names = cell(1,length(contents)-2);
% For each intem in the folder (excluding . and .. directory navigators) 
for i = 3:length(contents)
    % Retrieve the file name 
    file_name = contents(i).name;
    % Add the file name to cell array of names 
    names{i-2} = file_name;
end

% -------------------------------------------------------------------------

%% Extract 6-digit participant number
%{
  Isolate the 6-digit participant number from the overall folder syntax (FS6.0_sub-999999_ses01)
  pattern = Syntax to isolate (6 digits) 
  names = Cell array of participant's full folder names (see get file names function above) 
  participant_numbers = Cell containing isolated identifiers 
%}

% Establish the pattern to isolate for 
pattern = '\d{6}';
% Pre allocate list of participant numbers 
participant_numbers = cell(1,length(names));
for j=1:length(names)
    participant_numbers{j} = regexp(names{j}, pattern, 'match');
end

