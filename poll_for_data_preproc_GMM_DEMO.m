function poll_for_data_preproc_GMM_DEMO(SubjectID, sessionN, cfg)

% every 2 sec look for a file with a name template in a directory
% send New Data even to the listener
%listener will print got it and the volume number
% SubjectID='Phantom';
% sessionN=3;
ft_defaults
%ft_hastoolbox('spm8', 1);
if nargin <= 2
    cfg = [];
end
% cfg.inputDir='C:\Users\eust_abbondanza\Documents\realtime\20130429_19720216VLRZ\Ser0003\';
% cfg.NrOfVols=50;
% cfg.TimeOut=6.0;
% cfg.output='C:\Documents\realtime\TEST\';
% % % cfg.maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend'
% % % cfg.datapath='C:\Documents\realtime\';
% % % cfg.protocolpath='C:\Users\eust_abbondanza\Documents\MATLAB\';
%cfg.Classifier=2; %1 for SVM from PR tollbox, 2 for EN classifier
%cfg.blockDurVol=8;
%Cfg.name_templates='prepScan_*.nii';
%files = dir(fullfile(Cfg.inputDir,Cfg.name_templates));
%first non-dummy volume
sign_counter=0;
vol_counter=0;
%param = spm_normalise(cfg.mytemplate, cfg.ref_image, cfg.matname, defaults.normalise.estimate.weight,'',defaults.normalise.estimate);
onset=[];
mask1=spm_vol(sprintf('%s%s', cfg.dataPath, cfg.roi{1}));
maskvol1=spm_read_vols(mask1);

mask2=spm_vol(sprintf('%s%s', cfg.dataPath, cfg.roi{2}));
maskvol2=spm_read_vols(mask2);

if ~isfield(cfg, 'numDummy')
    cfg.numDummy = 5;			% number of dummy scans to drop
end

% if ~isfield(cfg, 'NrOfVols')
%     cfg.NrOfVols=220;
% end

if ~isfield(cfg, 'smoothFWHM')
    cfg.smoothFWHM = 0; %8;
end

if ~isfield(cfg, 'correctMotion')
    cfg.correctMotion = 1; %1;
end

if ~isfield(cfg, 'normalize2EPI')
    cfg.normalize2EPI = 0; %1;
end

if ~isfield(cfg, 'correctSliceTime')
    cfg.correctSliceTime = 1; %1;
end

if ~isfield(cfg, 'maskpath')
    cfg.maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend';
end

if ~isfield(cfg, 'Classifier')
    cfg.Classifier=2; %1 for SVM from PR tollbox, 2 for EN classifier
end

if ~isfield(cfg, 'whichEcho')
    cfg.whichEcho = 1;
else
    if cfg.whichEcho < 1
        error '"whichEcho" configuration field must be >= 1';
    end
end

hist_file=fullfile(cfg.output, sprintf('history_%s.mat', SubjectID));
motest_file=fullfile(cfg.output, sprintf('motest_%s.mat', SubjectID));
onsets_file=fullfile(cfg.output, sprintf('onsets_%s.mat', SubjectID));
tc_file=fullfile(cfg.output, sprintf('tc_%s.mat', SubjectID));
    

if ~exist(hist_file, 'file')
    history = struct('S',[], 'RRM', [], 'motion', []);
else
    load(motest_file);
    load(hist_file);
    load(onsets_file);
    load(tc_file);
    tc=tc';
 [MM, clustering]=prepare_tcs_rt(tc, cfg);
end

numTotal=cfg.numDummy+1;
if sessionN ==1
    numTrial = 0;
else
    numTrial =(cfg.NrOfVols1-cfg.numDummy) + (cfg.NrOfVols-cfg.numDummy)*(sessionN-2);
end%numTrial = (cfg.NrOfVols-cfg.numDummy)*(sessionN-1);
numProper = 0;
%motEst = [];
time_diff=0;
signal=0;
%myfile=fullfile(cfg.shared_folder, cfg.tc_file);
%load(cfg.tc_file, 'MM');
clustering_plot=zeros(1, size(motEst, 1));
counter=2;




for vv=1:size(motEst, 1)
    
    
    pause(cfg.TR/2);
        %  notify(H, 'NewData');
        fprintf('\nAvailable volume %i\n', numTotal)
        
        %%%     fname=fullfile(cfg.inputDir,name_template);
        
        fname= cfg.mean_raw;
        vol_hdr=spm_vol(fname);
        %         vol_vol=spm_read_vols(vol_hdr);
        %         dat=vol_vol(maskvol_vol>0);
        dat=spm_read_vols(vol_hdr);
        
        S=[];
        S.TR=cfg.TR;
        S.voxels=vol_hdr.dim;
        S.voxdim=[3.0000 3.0000 3.600]; %vol_hdr.pixdim(1:3)
        S.mat0=vol_hdr.mat;
        S.numEchos=1;
        S.vx=vol_hdr.dim(1);
        S.vy=vol_hdr.dim(2);
        S.vz=vol_hdr.dim(3);
        inds=[(2:2:S.vz) (1:2:S.vz)];
        S.deltaT = (0:(S.vz-1))*S.TR/S.vz;
        S.deltaT(inds) = S.deltaT;
        
        if isempty(S)
            warning('No protocol information found!')
            % restart loop
            pause(0.5);
            continue;
        end
        
         
        % store current info structure in history
        numTrial  = numTrial + 1;
        history(numTrial).S = S;
        %%%  disp(S)
        
                % % %
%        index = (cfg.numDummy + numProper) * S.numEchos + grabEcho;
       % fprintf('\nTrying to read %i. proper scan at sample index %d\n', numProper+1, index);
              
        numProper = numProper + 1;
        
        
        rawScan = single(reshape(dat, S.voxels));
        rawScan=reshape(rawScan, numel(rawScan), 1);
        rand_ind=randi([1 length(rawScan)], [100000, 1]);
        rawScan(rand_ind)=rawScan(rand_ind)/2;
        rawScan = single(reshape(rawScan, S.voxels));
        procScan=flip(rawScan, 2);
        
                    
      
         if vv >=onsets(counter) && vv < onsets(counter+1)
             
                    [MM(counter).Priors, MM(counter).Mu, MM(counter).Sigma, MM(counter).Pix, gmmcluster] = ...
                        EM_update_directMethod_upd(tc(vv), MM(counter-1).Priors, MM(counter-1).Mu, MM(counter-1).Sigma, MM(counter-1).Pix);
                    clustering_plot(vv)=gmmcluster;

    if gmmcluster>clustering_plot(vv-1) && clustering_plot(vv-1)>0
        clustering_plot(vv)=gmmcluster;
        
        counter=counter+1;
    else
        if vv == onsets(counter+1)-1
            counter=counter+1;
      %  clustering_plot(vv)=gmmcluster;
        else 
        clustering_plot(vv)=gmmcluster;
        end
    end
         end
        subplot(5,1,1);
        plot(motEst(1:vv,1:3));
        subplot(5,1,2);
        plot(motEst(1:vv,4:6));
        
        subplot(5,1,3);
        slcImg = reshape(rawScan, [S.vx	S.vy*S.vz]);
        imagesc(slcImg);
        colormap(gray);
        
%         subplot(5,1,4);
%         slcImg = reshape(procScan, [S.vx	S.vy*S.vz]);
%         imagesc(slcImg);
%         colormap(gray);
        
          subplot(5,1,4);
        slcImg = reshape(procScan, [S.vx	S.vy*S.vz]);
        imagesc(slcImg);
        colormap(gray);
        
        
        %   if numProper > cfg.breakPoint
        subplot(5,1,5);
        % plot(tc(1:end));
        plot(clustering_plot(1:vv));
        %  end
        
        % force Matlab to update the figure
        drawnow
        
      
        
    end
end
%toc(ses_start)
