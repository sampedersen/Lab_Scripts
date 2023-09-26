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
  
  source_dir = Directory to be moved 
  target_dir = Target location to move the directory into 

%}

% Change this to be the directory you want to move 
source_dir = 'P:\WoodsLab\ACT-head_models\';
% Change this to be the directory you want to move folder/files into 
target_dir = 'W:\camctrp\working\';
% If both of the specifies folders/files exist, try to move them 
if exist(source_dir) ~= 0 && exist(target_dir) ~= 0
  try 
    % Move the files 
    movefile(source_dir,target_dir);
    % Display confirmation that files were moved 
    disp('Moved source folder to target directory successfully.');
  catch 
    % Notify of error in case unable to move files 
    disp('Failed to move folder.');
  end
% If both/one of the files/folders DNE, notify of error and double-check inputs. 
else
  disp('Specified target/source directories do not exist as indicated.');
end


