#Rob's Lair of Preprocessing Scripts

##Maxfilter

Maxfilter is a program Elekta primarily used to clean MEG data using spatio-temporal signal separation methods. It can also apply motion correction, transform to a default headspace & much more.

I generally run Maxfilter through the Matlab command line using the function maxfilter_all.m . Currently this is set up to Maxfilter your data using tSSS with a .9 correlation. For head movement visualisation the above function requires check check_movecomp.m to be in your Matlab path

##General Stages to Processing:

1.  Maxfilter (tSSS with .9 correlation) + movement visualisation (see above)
2.  Load data into Fieldtrip & apply filters
3.  Epoch the data
4.  Visually inspect the data + reject artefactual trials
5.  FASTICA to identify & remove eye and heart artefacts
6.  Save to disk
7.  Have tea
