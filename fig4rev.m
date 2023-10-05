% Script to create t-statistic map
% Created by AA on 10/4/2023
clear; clc;
addpath P:\WoodsLab\ACT-head_models\FEM\scripts\utility_codes\NIFTI_20110921\
addpath P:\WoodsLab\ACT\toolboxes\spm12\; spm fmri; close all;

% Settings
rootDir = 'P:\WoodsLab\ACT-head_models\FEM\Ayden\cogstim_FEM\aparc_aseg';
dtype = {'actual','ideal'};
tpm = 'P:\WoodsLab\ACT\toolboxes\spm12\tpm\TPM.nii';
dims = [256,256,256];

% Locate Participants
subfdr = dir(fullfile(rootDir,'6*'));
subnames = {subfdr.name}';
N = length(subnames);

% Default SPM Normalization settings
mlb{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
mlb{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
mlb{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {tpm};
mlb{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
mlb{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
mlb{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
mlb{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
mlb{1}.spm.spatial.normalise.estwrite.woptions.bb = [-90.5 -108.5 -90.5
                                                      89.5 107.5 89.5];
mlb{1}.spm.spatial.normalise.estwrite.woptions.vox = [1 1 1];
mlb{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
mlb{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';

tic % Start Time
for s = 1 : N
    subDir = fullfile(rootDir,subnames{s}); % Current Data Directory
    T1 = fullfile(subDir,[subnames{s} '.nii']); % T1
    am = load_nii(fullfile(subDir,'aparc+aseg.nii')); % Brain Mask
    mlb{1}.spm.spatial.normalise.estwrite.subj(s).vol = {[T1 ',1']};
    for d = 1:length(dtype)
        fileroot = fullfile(subDir,[subnames{s} '_jmap_preseg_' dtype{d}]);
        if ~exist([fileroot '.nii'],'file')
            load([fileroot '.mat'],'condvol'); % Get ROAST output
            condvol(~am.img) = 0; % mask Brain
            nii = make_nii(condvol); % Make NIFTI
            nii.hdr.hist = am.hdr.hist; % Add Image Alignment
            save_nii(nii,[fileroot '.nii']); % Save
            clear condvol
        end
        mlb{1}.spm.spatial.normalise.estwrite.subj(s).resample{d,:} = [
            fileroot '.nii,1']; % Add to Normalization
    end
end
spm_jobman('run',mlb) % Perform Image Normalization on All Images

% Add All Real and Artificial Data to Matrix
alldata = nan(length(subnames),prod([182 218 182]),length(dtype));
for s = 1 : N
    for d = 1:length(dtype)
        nii = load_nii(fullfile(rootDir,subnames{s}, ...
        ['w' subnames{s} '_jmap_preseg_' dtype{d} '.nii']));
        alldata(s,:,d) = nii.img(:);
    end
end

% Actual - Ideal
[~,~,~,stats] = ttest(alldata(:,:,1),alldata(:,:,2)); % Paired T-Test
tmap = reshape(stats.tstat,[182 218 182]); % Make Image
tmap(tmap<4.073) = 0; % Mask Significant Regions
tn = make_nii(tmap); tn.hdr.hist = nii.hdr.hist; % Make NIFTI 
save_nii(tn,fullfile(rootDir,'tmap.nii')); % Save

dmap = reshape(mean(alldata(:,:,1)-alldata(:,:,2), ...
1,'omitnan'),[182 218 182]); dmap(tmap<4.073) = 0; % Make Image and Mask
dn = make_nii(dmap); dn.hdr.hist = nii.hdr.hist; % Make NIFTI
save_nii(dn,fullfile(rootDir,'dmap.nii')); % Save
toc % End Time