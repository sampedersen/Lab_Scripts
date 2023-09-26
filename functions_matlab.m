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

}%

source_dir = 'P:\WoodsLab\ACT-head_models\';
target_dir = 'W:\camctrp\working\';
if exist(source_dir) ~= 0 && exist(target_dir) ~= 0
  try 
    movefile(source_dir,target_dir);
    disp('Moved source folder to target directory successfully.');
  catch 
    disp('Failed to move folder.');
  end
else
  disp('Specified target/source directories do not exist as indicated.');
end


