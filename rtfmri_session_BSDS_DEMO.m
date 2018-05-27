%% Preparatory part

clear all
clear classes
cfg=[];
%%%CHANGE
accessN='Sog3'; 
session=1;
disk='H:\RealTime\BSDS\';
addpath('C:\Users\Elena\Documents\MATLAB\fieldtrip-20150318');
addpath('C:\Users\Elena\Documents\MATLAB\full_session_280817');
addpath('C:\Users\Elena\Documents\MATLAB\spm8');
addpath(genpath('C:\Users\Elena\Documents\MATLAB\asfV52\'));

%% Localizer
%%%%%%%%%%%% preprocessing options

cfg.TR=2;
cfg.numDummy=5;
cfg.realtime_on=1;
cfg.smoothFWHM = 0;
cfg.correctMotion = 1;
cfg.normalize2MNI = 1;
cfg.correctSliceTime = 1;
%%%%%%%%%%%
cfg.max_delay=6;
cfg.NrOfVols1=230;
cfg.NrOfVols=220;
cfg.breakPoint=5; %round(cfg.NrOfVols/2);
cfg.TimeOut=15.0;
cfg.TR=2;
cfg.numDummy=5;
cfg.blockDur=10;
cfg.nbStates=5;
%cfg.nbVar=1;
cfg.mytemplate='C:\EXPERIMENTS\Elena\spm8\templates\EPI.nii';
cfg.matname=sprintf('%s%s\\mean_sn.mat', disk, accessN); % %fullfile(cfg.dataPath, 'mean_sn.mat');
cfg.ref_image=sprintf('%s%s\\mean.hdr', disk, accessN); %fullfile(cfg.dataPath, 'mean.hdr');
cfg.roi=    {'newFFA.hdr', 'newPPA.hdr'};

%% Prepare models
clear MM
session=2;
%2, 4, 6
%cfg.tc_file=sprintf('%sPSC_F_%d.mat', cfg.dataPath, session);
%cfg.tc_file_phantom=sprintf('%s%s_%d_tc_phantom.mat', cfg.shared_folder,accessN, session);
%cfg.roi=    {'newFFA_FH.hdr', 'newPPA_HF.hdr'};

cfg.tc_file=sprintf('%s%s_%d_tc.mat', cfg.shared_folder,accessN, session);
prepare_tcs(accessN, session-1, cfg);
%%  Real-time run, Faces, Houses
%3,5, 7
session=7; 

%cfg.roi=    {'newFFA_FH.hdr', 'newPPA_HF.hdr'};
cfg.roi=    {'newFFA.hdr', 'newPPA.hdr'};

%%%%%%%%%%% paths 1st Run rakes from input run 1 puts into data path run 1
cfg.inputDir=sprintf('%s%s\\Ser%04d\', disk, accessN, session) %'C:\Documents\RealTime\201509301130\Ser0001'; %'C:\Documents\RealTime\20150930MCBL\DiCo_1\'% % DISK Z:\
cfg.output=sprintf('%s\\test_%s\\', disk, accessN); %'C:\Documents\RealTime\20150930MCBL\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath=sprintf('%s%s\\', disk, accessN);% DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained
%%%%%%%%%%%%% general session options
cfg.realtime_on=1;
cfg.max_delay=5;
cfg.NrOfVols1=230;
cfg.NrOfVols=220;
cfg.breakPoint=round(cfg.NrOfVols/2);
cfg.TimeOut=60.0;
cfg.TR=2;
cfg.numDummy=5;
cfg.blockDur=10;
cfg.nbStates=6;
%cfg.nbVar=1;
cfg.mytemplate='C:\EXPERIMENTS\Elena\spm8\templates\EPI.nii';
cfg.mean_raw=fullfile(cfg.output, 'Mean_non_preproc.hdr');
cfg.mean_preproc=fullfile(cfg.output, 'Mean_preproc.hdr');
cfg.matname=sprintf('%s%s\\mean_sn.mat', disk, accessN); % %fullfile(cfg.dataPath, 'mean_sn.mat');
cfg.ref_image=sprintf('%s%s\\mean.hdr', disk, accessN);%fullfile(cfg.dataPath, 'mean.hdr');
%%%%%%%%%%%% preprocessing options
cfg.smoothFWHM = 0;
cfg.correctMotion = 1;
cfg.normalize2MNI = 1;
cfg.correctSliceTime = 1;
%%%%%%%%%%%
poll_for_data_preproc_GMM_DEMO(accessN, session, cfg);
%poll_for_data_preproc_GMM_Phantom(accessN, session, cfg);



