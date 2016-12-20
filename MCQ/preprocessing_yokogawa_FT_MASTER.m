%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a Matlab script to perform SIMPLE preprocess Yogogawa data in 
% Fieldtrip. This script has been customised for the alien task data.
%
% For more complex datasets please see 
% preprocessing_elektra_FT_perspective_taking_ASD.m
%
% This runs through the common preprocessing, visualisation
% and artefact rejection steps. Any issues with this email me at 
% seymourr@aston.ac.uk. 
%
% Output = variable called data_clean 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Specfiy Subject ID & Condition
% subject = 'XXXX';
% condition = 'visual'; % specific for my data - can easily change
% %% Prerequisites
% % Set your current directory based on condition
% if strcmp(condition,'visual')
%     cd(sprintf('D:\\ASD_Data\\%s\\visual\\',subject))
% end
% if strcmp(condition,'auditory')
%     cd(sprintf('D:\\ASD_Data\\%s\\auditory\\',subject))
% end
% 
% % Specify location of the datafile
% rawfile = sprintf('D:\\ASD_Data\\raw_alien_data\\\\rs_asd_%s_aliens_quat_tsss.fif',lower(subject))


%% Start script from here:
subject = 'GR';
rawfile = '2399_GR_MEABC_2016_12_5_B1.con';

% Creates log file
diary(sprintf('log %s.out',subject));
c = datestr(clock); %time and date
disp(sprintf('Running preprocessing script for subject %s',subject))
disp(c)

%% Epoching & Filtering
% Epoch the whole dataset into one continous dataset and apply
% the appropriate filters
cfg = [];
cfg.headerfile = rawfile; 
cfg.datafile = rawfile;
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials = 1;
cfg = ft_definetrial(cfg)

cfg.continuous = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 250];
cfg.dftfilter = 'yes';
cfg.dftfreq = [50];
alldata = ft_preprocessing(cfg);

% Deal with 50Hz line noise
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [49.5 50.5];
alldata = ft_preprocessing(cfg,alldata);

% Deal with 100Hz line noise
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [99.5 100.5];
alldata = ft_preprocessing(cfg,alldata);

% Create layout file for later + save
cfg             = [];
cfg.grad        = alldata.grad;
lay             = ft_prepare_layout(cfg, alldata);
save lay lay

% Cut out other channels(?)
cfg = [];
cfg.channel = alldata.label(1:160);
alldata = ft_selectdata(cfg,alldata);

% Define trials using custom trialfun
cfg = [];
cfg.dataset                 = rawfile;
cfg.continuous              = 'yes';
cfg.trialdef.prestim = 2.0;         % pre-stimulus interval
cfg.trialdef.poststim = 2.0;        % post-stimulus interval
cfg.trialdef.trigchannel    = '179'; %178 grating 179 clicktrain
cfg.trialfun                = 'mytrialfun';   
data_raw 			    = ft_definetrial(cfg);

cfg = [];
data = ft_redefinetrial(data_raw,alldata); %redefines the filtered data

% Detrend and demean each trial
cfg = [];
cfg.demean = 'yes';
cfg.detrend = 'yes';
data = ft_preprocessing(cfg,data)

%% Reject Trials
% Display visual trial summary to reject deviant trials.
% You need to load the mag + grad separately due to different scales

cfg = []; 
cfg.method = 'summary'; 
cfg.keepchannel = 'yes'; 
data = ft_rejectvisual(cfg, data); 


%% Display Data
% Displaying the (raw) preprocessed MEG data

diary off
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,data)

% Load the summary again so you can manually remove any deviant trials
cfg = []; 
cfg.method = 'summary'; 
cfg.keepchannel = 'yes'; 
data = ft_rejectvisual(cfg, data); 

data_clean_noICA = data
save data_clean_noICA data_clean_noICA
clear data_clean_noICA
close all

%% !!! ICA !!!
% Downsample Data

data_orig = data; %save the original CLEAN data for later use 
cfg = []; 
cfg.resamplefs = 150; %downsample frequency 
cfg.detrend = 'no'; 
disp('Downsampling data');
data = ft_resampledata(cfg, data_orig);

% Run ICA
disp('About to run ICA using the Runica method')
cfg            = [];
cfg.method     = 'fastica';
comp           = ft_componentanalysis(cfg, data);
save('comp.mat','comp','-v7.3')

% Display Components - change layout as needed
cfg = []; 
cfg.viewmode = 'component'; 
ft_databrowser(cfg, comp)

%% Remove components from original data
%% Decompose the original data as it was prior to downsampling 
diary on;
disp('Decomposing the original data as it was prior to downsampling...');
cfg           = [];
cfg.unmixing  = comp.unmixing;
cfg.topolabel = comp.topolabel;
comp_orig     = ft_componentanalysis(cfg, data_orig);

%% The original data can now be reconstructed, excluding specified components
% This asks the user to specify the components to be removed
disp('Enter components in the form [1 2 3]')
comp2remove = input('Which components would you like to remove?\n');
cfg           = [];
cfg.component = [comp2remove]; %these are the components to be removed
data_clean    = ft_rejectcomponent(cfg, comp_orig,data_orig);

%% Save the clean data
disp('Saving data_clean...');
save('data_clean','data_clean','-v7.3')
diary off