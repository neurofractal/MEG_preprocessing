**Rob’s Preprocessing Script – Run-Through**

 

This runs through my preprocessing script in Fieldtrip, tailored for Elekta Neuromag data. This flowchart (you’ve got to love a flowchart) outlines the essential stages:

 

 

 

 

 

 

 

 

 

 

 

 

Before proceeding with data analysis in Fieldtrip, I advise cleaning up your data with Maxfilter – preferably tSSS or motion correction. This does "beautify" your data and change it in various ways, but it seems to be an essential step given the noise within most raw data.

**Some useful Maxfilter links:**

[http://imaging.mrc-cbu.cam.ac.uk/meg/Maxfilter](http://imaging.mrc-cbu.cam.ac.uk/meg/Maxfilter)

[http://imaging.mrc-cbu.cam.ac.uk/meg/Maxfilter_V2.2?action=AttachFile&do=get&target=Maxfilter_Manual_v2pt2.pdf](http://imaging.mrc-cbu.cam.ac.uk/meg/Maxfilter_V2.2?action=AttachFile&do=get&target=Maxfilter_Manual_v2pt2.pdf)

 

** **

** **

** **

** **

** **

** **

** **

** **

** **

**Epoching and Preprocessing**

The first step is setting our current directory and location of the ‘raw’ dataset. I also find it useful to create a log-file using the diary function of Matlab.

**This loads ALL your data into one continuous trial and then applies a band-pass filter of 0.5-250Hz as well as a DFT filter. N.B. Filtering on continuous data allows you to avoid edge artefacts, but the Fieldtrip tutorials do not perform pre-processing like this.**

 

 

 

 

 

 

This is a very simple bit of script to epoch your data based on a single trigger. For more complicated experiments you will have to write your own trial definition function (see[ http://www.fieldtriptoolbox.org/example/making_your_own_trialfun_for_conditional_trial_definition](http://www.fieldtriptoolbox.org/example/making_your_own_trialfun_for_conditional_trial_definition))

Here for example:

trigger_val = ‘STI005’ pre_stim = 2.0  	post_stim = 2.0

 

 

Next, I tend to demean and detrend each trial using this simple bit of code.

 

**Trial Rejection**

At this point we can use Fieldtrip’s helpful summary tool to find any deviant trials. It is important to use cfg.keepchannel = ‘yes’ because we load the magnetometers and gradiometers separately.

To remove trials simply draw a box around the dots which show high variance. It can also be useful to click on the zvalue option to display trials which show high zvalues compared with other trials.

If you notice channels with high variance, it can be useful remove and interpolate them using Fieldtrip’s ft_channelrepair function (see[ http://www.fieldtriptoolbox.org/reference/channelrepair)](http://www.fieldtriptoolbox.org/reference/channelrepair))... However I tend to leave them in until source localisation.

 

The next part of the script allows us to visualise the data separately for the magnetometers and gradiometers. With my code only vertical plots are produced, but butterfly plots could also be easily produced by specifying cfg.viewmode = ‘butterfly’. **It can be very useful to visually inspect all of your data**. This way we can note down any trials we think should be outright rejected and we also get a feel for how noisy the data is across participants.

 

 

It can also be useful to focus on a handful of sensors, rather than visualising all 102 magnetometers or 204 gradiometers. To do this click on *channel* and remove the channels you do not want, leaving around 10-20.

To remove artefactual trials I re-load the trial summary and manually enter the trial numbers to be rejected into the ‘Toggle Trial’ field.

At this point I save my data as data_clean_noICA

**ICA**

Reference:[ http://www.fieldtriptoolbox.org/example/use_independent_component_analysis_ica_to_remove_ecg_artifacts](http://www.fieldtriptoolbox.org/example/use_independent_component_analysis_ica_to_remove_ecg_artifacts)

The next step is using ICA to identify physiological artefacts within our data. We first downsample our data to speed up the process of ICA. We then run ICA using the ‘runica’ method or ‘fastica’. Finally we visualise our components.

 

*ICA is a blind separation technique used to separate a complex signal (like MEG) into simpler **independent** components which together make up the data.*

<table>
  <tr>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td></td>
  </tr>
</table>


I find it useful to visualise the results using the magnetometers, simply because localising the components is much easier.

In the plot above we can clearly see a cardiac/ECG artefact. This is identified from the time-course of the component as well as its location around the edge of the head.

 

 

 

 

 

 

 

 

 

Here we can see an EOG artefact. This is characterised by the low frequency rise in the time-course and the location of the component around the participant’s eyes.

*Removing Components*

This bit of script decomposes the data as it was prior to downsampling and then removes components from the original data. I have also added a bit of interactive script so that the user can type in the components to be removed. Please remember to enter these numbers in the form e.g. [19 25]

 

**Saving the Data**

This will save the data and turn off the diary function creating your log file.

 

**Visualising your clean data**

