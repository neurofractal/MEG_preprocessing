%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a Matlab script to perform SIMPLE preprocess Elekta data in 
% Fieldtrip. Tutorial = 'Preprocessing rs_script_runthrough.docx'. This
% script has been customised for the alien task data.
%
% For more complex datasets please see 
% preprocessing_elektra_FT_perspective_taking_ASD.m
%
% This runs through the common preprocessing, visualisation
% and artefact rejection steps. Any issues with this email me at 
% seymourr@aston.ac.uk. 
%
% Output = variables called data_clean and data_clean_noICA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Specfiy Subject ID & Condition
subject = 'XXXX';
condition = 'auditory'; % specific for my data - can easily change
%% Prerequisites
% Set your current directory based on condition
if strcmp(condition,'visual')
    cd(sprintf('D:\\ASD_Data\\%s\\visual\\',subject))
end
if strcmp(condition,'auditory')
    cd(sprintf('D:\\ASD_Data\\%s\\auditory\\',subject))
end

% Specify location of the datafile
rawfile = sprintf('D:\\ASD_Data\\raw_alien_data\\\\rs_asd_%s_aliens_quat_tsss.fif',lower(subject))
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
cfg.channel = 'MEG';
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials = 1;
cfg = ft_definetrial(cfg)

cfg.continuous = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 250];
cfg.channel = 'MEG';
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

% Epoch your filtered data based on a specific trigger
cfg = [];
cfg.headerfile = rawfile; 
cfg.datafile = rawfile;
cfg.channel = 'MEG';
if strcmp(condition,'visual')
    cfg.trialdef.eventtype = 'STI005';
    disp('Trigger Value is STI005');
end
if strcmp(condition,'auditory')
    cfg.trialdef.eventtype = 'STI006';
    disp('Trigger Value is STI006');
end
cfg.trialdef.prestim = 2.0;         % pre-stimulus interval
cfg.trialdef.poststim = 2.0;        % post-stimulus interval
cfg = ft_definetrial(cfg);

data = ft_redefinetrial(cfg,alldata); %redefines the filtered data

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
cfg.channel = 'MEGMAG'; 
clean1 = ft_rejectvisual(cfg, data); 
% Now load this
cfg.channel = 'MEGGRAD';
clean2 = ft_rejectvisual(cfg, clean1);
data = clean2; clear clean1 clean2
close all

%% Display Data
% Displaying the (raw) preprocessed MEG data

diary off
cfg = [];
cfg.channel = 'MEGGRAD';
cfg.viewmode = 'vertical';
ft_databrowser(cfg,data)
cfg.channel = 'MEGMAG';
ft_databrowser(cfg,data)

% Load the summary again so you can manually remove any deviant trials
cfg = []; 
cfg.method = 'summary'; 
cfg.keepchannel = 'yes'; 
cfg.channel = 'MEG'; 
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
%cfg.layout = 'neuromag306all.lay';
cfg.layout = 'neuromag306mag.lay';
ft_databrowser(cfg, comp)
cfg.layout = 'neuromag306planar.lay';
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

%% Display clean data
cfg = [];
cfg.channel = 'MEGGRAD';
cfg.viewmode = 'vertical';
ft_databrowser(cfg,data_clean)
cfg.channel = 'MEGMAG';
ft_databrowser(cfg,data_clean)