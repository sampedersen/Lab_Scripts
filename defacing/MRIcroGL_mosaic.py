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

# Set source_folder as the path to the directory containing target participants' data 
source_folder = "P:\\WoodsLab\\ACT-head_models\\FEM\\Ayden\\deface\\new_montage\\low_group\\"
# Set output_folder as the path to the directory that images should be exported to 
output_folder = "P:\\WoodsLab\\ACT-head_models\\FEM\\Ayden\\deface\\new_montage\\sample_imgs\\low\\JRoast\\"
# List the participants for whom to generate images; must have at least one participant listed, but can be used for batch processing as well 
# For now, list participants as strings; come back to this 
participants = ['101190']



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
