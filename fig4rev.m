clear; clc;
addpath P:\WoodsLab\ACT-head_models\FEM\scripts\utility_codes\NIFTI_20110921\
addpath P:\WoodsLab\ACT\toolboxes\spm12\; spm fmri; close all;

rootDir = 'P:\WoodsLab\ACT-head_models\FEM\Ayden\cogstim_FEM\aparc_aseg';
dtype = {'actual','ideal'};
tpm = 'P:\WoodsLab\ACT\toolboxes\spm12\tpm\TPM.nii';
dims = [256,256,256];

subfdr = dir(fullfile(rootDir,'6*'));
subnames = {subfdr.name}';
N = length(subnames);

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

tic
for s = 1 : N
    subDir = fullfile(rootDir,subnames{s});
    T1 = fullfile(subDir,[subnames{s} '.nii']);
    am = load_nii(fullfile(subDir,'aparc+aseg.nii'));
    mlb{1}.spm.spatial.normalise.estwrite.subj(s).vol = {[T1 ',1']};
    for d = 1:length(dtype)
        fileroot = fullfile(subDir,[subnames{s} '_jmap_preseg_' dtype{d}]);
%         if ~exist([fileroot '.nii'],'file')
            load([fileroot '.mat'],'condvol');
            condvol(~am.img) = 0;
            nii = make_nii(condvol); nii.hdr.hist = am.hdr.hist;
            save_nii(nii,[fileroot '.nii']);
            clear condvol
%         end
        mlb{1}.spm.spatial.normalise.estwrite.subj(s).resample{d,:} = [
            fileroot '.nii,1'];
    end
end
spm_jobman('run',mlb)

alldata = nan(length(subnames),prod([182 218 182]),length(dtype));
for s = 1 : N
    for d = 1:length(dtype)
        nii = load_nii(fullfile(rootDir,subnames{s}, ...
        ['w' subnames{s} '_jmap_preseg_' dtype{d} '.nii']));
        alldata(s,:,d) = nii.img(:);
    end
end

% Actual - Ideal
[~,~,~,stats] = ttest(alldata(:,:,1),alldata(:,:,2));

tmap = reshape(stats.tstat,[182 218 182]); tmap(tmap<4.073) = 0;
tn = make_nii(tmap); tn.hdr.hist = nii.hdr.hist; 
save_nii(tn,fullfile(rootDir,'tmap.nii'));

dmap = reshape(mean(alldata(:,:,1)-alldata(:,:,2), ...
1,'omitnan'),[182 218 182]); dmap(tmap<4.073) = 0;
dn = make_nii(dmap); dn.hdr.hist = nii.hdr.hist; 
save_nii(dn,fullfile(rootDir,'dmap.nii'));
toc