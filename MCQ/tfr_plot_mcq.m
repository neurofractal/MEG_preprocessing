%% TFR Plots for Visual Data - MCQ

% Downsample
%% Downsample data
cfg = [];
cfg.resamplefs = 200;
cfg.detrend = 'no';
data_clean_150 = ft_resampledata(cfg,data_clean);

% TF Calculation 
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 1:1:100;
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5;
cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;
cfg.toi = -1.5:0.020:1.5;
disp(sprintf('Time of interest = %s',cfg.toi));
multitaper = ft_freqanalysis(cfg, data_clean_150);
 
load lay lay
save multitaper multitaper

% Whole brain TFR
cfg = [];
cfg.baseline     = [-1.5 -0.0];
cfg.xlim         = [-0.5 1.5];
cfg.ylim         = [30 100];
cfg.baselinetype = 'relative';
%cfg.zlim = 'maxabs';
cfg.showlabels   = 'yes';
cfg.layout       = lay;
figure
figure; ft_multiplotTFR(cfg, multitaper);
title('High Frequencies 35-100Hz')
colormap(jet)

% TopoplotTFR
cfg = [];
cfg.baseline     = [-1.5 -0.0];
cfg.xlim         = [-0.5 1.5];   
%cfg.zlim = 'maxabs';
cfg.ylim         = [35 45];
cfg.layout       = lay;
figure; ft_topoplotTFR(cfg,multitaper); 
title('Topoplot 35-45Hz')
colormap(jet)

% Single
cfg = [];
cfg.channel = {'AG134', 'AG136', 'AG137', 'AG139', 'AG140', 'AG145', 'AG149', 'AG151', 'AG152', 'AG154'}
cfg.baseline     = [-1.5 -0.0];
cfg.xlim         = [-0.5 1.5];   
%cfg.zlim = 'maxabs';
cfg.ylim         = [30 60];
cfg.layout       = lay;
figure; ft_singleplotTFR(cfg,multitaper); 
title('TFR Plot of Several Occipital Channels: 30-60Hz')
colormap(jet)

%% TFR Plots for Auditory Data - MCQ

cfg = [];
cfg.resamplefs = 200;
cfg.detrend = 'no';
data_clean_150 = ft_resampledata(cfg,data_clean);

cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 1:1:100;
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5;
cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;
cfg.toi = -1.5:0.020:1.5;
disp(sprintf('Time of interest = %s',cfg.toi));
multitaper = ft_freqanalysis(cfg, data_clean_150);
 
load lay lay
save multitaper multitaper

% Whole brain TFR
cfg = [];
cfg.baseline     = [-1.5 -0.0];
cfg.xlim         = [-0.5 1.5];
cfg.ylim         = [30 100];
cfg.baselinetype = 'relative';
%cfg.zlim = 'maxabs';
cfg.showlabels   = 'yes';
cfg.layout       = lay;
figure
figure; ft_multiplotTFR(cfg, multitaper);
title('High Frequencies 35-100Hz')
colormap(jet)

% TopoplotTFR
cfg = [];
cfg.baseline     = [-1.5 -0.0];
%cfg.xlim         = [-0.5 1.5];   
%cfg.zlim = 'maxabs';
cfg.ylim         = [35 45];
cfg.layout       = lay;
figure; ft_topoplotTFR(cfg,multitaper); 
title('Topoplot 35-45Hz')
colormap(jet)

% Single
cfg = [];
cfg.channel = {'AG035', 'AG036', 'AG038', 'AG040', 'AG041', 'AG042', 'AG043', 'AG044', 'AG045', 'AG047', 'AG048', 'AG049', 'AG050', 'AG051', 'AG053', 'AG054', 'AG055', 'AG056', 'AG057', 'AG058', 'AG059', 'AG060', 'AG061', 'AG062', 'AG063', 'AG064', 'AG138'}
cfg.baseline     = [-1.5 -0.0];
cfg.xlim         = [-0.5 1.5];   
%cfg.zlim = 'maxabs';
cfg.ylim         = [35 60];
cfg.layout       = lay;
figure; ft_singleplotTFR(cfg,multitaper); 
title('TFR Plot of Several Right Temporal Channels: 35-60Hz')
colormap(jet)