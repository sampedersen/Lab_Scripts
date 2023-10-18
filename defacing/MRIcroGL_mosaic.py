""" 
MRIcroGL_mosaic.py
Author: Sam Pedersen 
Date: 2023-10-18

Description: 
    Generate mosaic images of JRoast/JBrain outputs with electrodes overlayed.
    
Usage:
    Indicate if script is to be executed singularly (one participant) or in 
    batch (multiple participants).
    Indicate if JRoast or JBrain should be generated. 
    
"""

# Set these variables

# Set source_folder as the path to the directory containing target participants' data (NOT THE PARTICIPANTS' ACTUAL FOLDER)
source_folder = "P:\\WoodsLab\\ACT-head_models\\FEM\\Ayden\\deface\\new_montage\\low_group\\"
# Set output_folder as the path to the directory that images should be exported to 
output_folder = "P:\\WoodsLab\\ACT-head_models\\FEM\\Ayden\\deface\\new_montage\\sample_imgs\\low\\JRoast\\"
# List the participants for whom to generate images; must have at least one participant listed, but can be used for batch processing as well 
# For now, list participants as strings; come back to this 
participants = ['101190']



""" 
# Identify visualization files 

Indicate with mosaic images to generate. Setting a variable as "True" will generate the images associated. Setting a variable as "False" will skip generating the associated images. 
    Example: 
    visualize_JBrain = "True"   ---> Sample images generated using JBrain data 
    visualize_JRoast = "False"  ---> Skip generating sample images using JRoast data 
Indicate with visualizations should additionally overlay electrodes/gel to the images. "True" will overlay electrodes/gel, "False" will generate images without electrodes/gel. 
    Example: 
    visualize_JRoast = "True"   ---> Sample images will generate using JRoast data
    overlay_elec_JR = "True"    ---> Sample images will additionally have electrodes and gel overlayed to images 
    
"""

# JBrain visualization
visualize_JBrain = "True"      
overlay_elec_JB = "True"

# JRoast visualization 
visualize_JRoast = "True"
overlay_elec_JR = "True" 

# allMasks visualization 
visualize_allMasks = "False"
overlay_elec_AM = "False" 


##############################
# Do not edit 

# File name syntax 
jroast = "_Jroast.nii"
jbrain = "_Jbrain.nii"
all_masks = "_T1orT2_masks.nii"
elec = "_mask_elec.nii"
gel = "_mask_gel.nii"

# Algorithm names 
algorithms = ["original","mri_deface","mideface","fsl_deface","afni_reface","afni_deface"]
# T1 syntax structures 
t1s = ["T1","T1_defaced","T1_defaced","T1_defaced","T1.reface","T1.deface"]
