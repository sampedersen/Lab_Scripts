% Convert Electric Field to Current Density from ROAST
%----------------------------------------
% Created By Alejandro Albizu (aa14av@gmail.com)
% Center for Cognitive Aging and Memory
% University of Florida
% 8/9/2023
%----------------------------------------
% Last Updated: 8/9/2023 by AA

% Input
% resFile (char) : absolute path to *_roastResult.mat file
% condFile (char) : absolute path to .mat file containing conductivities
function ef2j(resFile,condFile)

    if ~contains(resFile,'roastResult') % Only works with this file
        error('Please Supply the *_roastResult.mat File');
    end

    % Load Result File
    load(resFile,'ef_all','ef_mag')

    % Get Result File from ROAST
    [dirname,fullFilename] = fileparts(resFile);
    fparts = regexp(fullFilename,'_','split');
    [baseFilename,uniTag,~,] = deal(fparts{:});

    % Find Head Segmentation
    amfdr = dir(fullfile(dirname,[baseFilename '*_masks.nii']));
    if isempty(amfdr); error(['Could not locate allMask in ' dirname]); end
    template = load_untouch_nii(fullfile(dirname,amfdr.name));
    allMask_d = double(template.img);
    % Load the original MRI to save the results as NIFTI format
    
    % so that display of NIFTI will not alter the data
    template.hdr.dime.datatype = 16;
    template.hdr.dime.bitpix = 32;
    template.hdr.dime.scl_slope = 1; 
    template.hdr.dime.cal_max = 0;
    template.hdr.dime.cal_min = 0;

    % Create Conductivity Masks
    load(condFile,'cond') % Load conductivity values
    allCond=zeros(size(ef_mag,1),size(ef_mag,2),size(ef_mag,3));
    maskName = fieldnames(cond); maskName = maskName(1:end-2);
    numOfTissue = length(maskName);
    for t = 1:numOfTissue
        allCond(allMask_d==t) = cond.(maskName{t});
    end
    
    save([dirname filesep baseFilename '_allCond.mat'],'allCond');
    
    disp('Computing Current Density ...');
    if ~isa(allCond, 'double')
        allCond=double(allCond);
    end
    
    % Ohm's Law: J = E/R
    Jroast = allCond.*ef_mag;
    
    % make J nii
    Jroast(isnan(Jroast))=0;
    Jbrain = zeros(size(Jroast,1),size(Jroast,2),size(Jroast,3));
    Jbrain(allMask_d == 1 | allMask_d == 2) = Jroast(allMask_d == 1 | allMask_d == 2);
   
    % Curren Density Magnitude in Head
    template.img = single(Jroast);
    template.hdr.dime.glmax = max(Jroast(:));
    template.hdr.dime.glmin = min(Jroast(:));
    template.hdr.hist.descrip = 'J Mag in Head';
    template.fileprefix = [dirname filesep baseFilename '_' uniTag '_Jroast'];
    save_untouch_nii(template,[dirname filesep baseFilename '_' uniTag '_Jroast.nii']);
    save([dirname baseFilename '_' uniTag '_Jroast.mat'],'Jroast');

    % Curren Density Magnitude in Brain
    template.img = single(Jbrain);
    template.hdr.dime.glmax = max(Jbrain(:));
    template.hdr.dime.glmin = min(Jbrain(:));
    template.hdr.hist.descrip = 'J Mag in Brain';
    template.fileprefix = [dirname filesep baseFilename '_' uniTag '_Jbrain'];
    save_untouch_nii(template,[dirname filesep baseFilename '_' uniTag '_Jbrain.nii']);
    save([dirname baseFilename '_' uniTag '_Jbrain.mat'],'Jbrain');

    % Electric Field Vector in Head
    template.hdr.dime.dim(1) = 4;
    template.hdr.dime.dim(5) = 3;
    template.img = single(ef_all);
    template.hdr.dime.glmax = max(ef_all(:));
    template.hdr.dime.glmin = min(ef_all(:));
    template.hdr.hist.descrip = 'EF Vector in Head';
    template.fileprefix = [dirname filesep baseFilename '_' uniTag '_e'];
    save_untouch_nii(template,[dirname filesep baseFilename '_' uniTag '_e.nii']);
        
    % Current Density Vector in Brain
    J = zeros(size(ef_all));
    J(repmat(am.img == 1,1,1,1,3)) = ef_all(repmat(am.img == 1,1,1,1,3)) .* 0.126;
    J(repmat(am.img == 2,1,1,1,3)) = ef_all(repmat(am.img == 2,1,1,1,3)) .* 0.276;

    template.hdr.dime.dim(1) = 4;
    template.hdr.dime.dim(5) = 3;
    template.img = single(J);
    template.hdr.dime.glmax = max(J(:));
    template.hdr.dime.glmin = min(J(:));
    template.hdr.hist.descrip = 'J Vector in Brain';
    template.fileprefix = [dirname filesep baseFilename '_' uniTag '_xyzJbrain'];
    save_untouch_nii(template,[dirname filesep baseFilename '_' uniTag '_xyzJbrain.nii']);
    save([dirname baseFilename '_' uniTag '_xyzJbrain.mat'],'J');

    % Plot Results
    disp('Plotting Results ...');
    axi = round(size(Jbrain,3)/1.6); % Axial Slice
    sag = round(size(Jbrain,1)/1.6); % Saggital Slice
    cor = round(size(Jbrain,2)/1.6); % Coronal Slice
    h(1) = subplot(221); imagesc(squeeze(Jbrain(:,cor,:)),[0 0.1]); 
    colormap(h(1),'turbo'); axis(h(1),'off'); axis(h(1),'tight');
    h(2) = subplot(222); imagesc(squeeze(Jbrain(sag,:,:)),[0 0.1]); 
    colormap(h(2),'turbo'); axis(h(2),'off'); axis(h(2),'tight');
    h(3) = subplot(223); imagesc(squeeze(Jbrain(:,:,axi)),[0 0.1]); 
    colormap(h(3),'turbo'); axis(h(3),'off'); axis(h(3),'tight');
    h(4) = subplot(224); axis off; h(5) = colorbar('west');
    set(h(5),'YAxisLocation','right','FontSize',18);
    saveas(gcf,fullfile(dirname,['MultiPlanar_' uniTag '_Jbrain.png']));
    title(h(5), 'Am^{-2}','FontSize',18);