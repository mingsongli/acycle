# Acycle v0.2.6

<b>Acycle -- a time-series analysis software for paleoclimate projects and education</b>

Mingsong Li, Penn State. Dec. 25, 2018

Website: www.mingsongli.com/acycle

```diff
+ With redesigned Acycle GUI, NO coding experience is required.
```
Acycle is a comprehensive, but simple-to-use software package for analysis of time-series designed for paleoclimate research and education. Acycle runs either in the MATLAB environment or as a stand-alone application on Macintosh OS X <i>(ready)</i> and Windows  <i>(coming)</i>, and is available free of charge.

<i>Acycle provides prewhitening procedures with multiple options available to track or remove secular trends, and integrates various power spectral analysis approaches for detection and tracking of periodic signals. 
Acycle also provides a toolbox that evaluates astronomical signals in paleoclimate series, and estimates the most likely sedimentation rate by maximizing the correlation coefficient between power spectra of an astronomical solution and a paleoclimate series. Sedimentary noise models for sea-level variations are also included. 
Many of the functions are specific to cyclostratigraphy and astrochronology, and are not found in standard, statistical packages. </i>

Acycle can be downloaded <br />
(GITHUB) here https://github.com/mingsongli/acycle   <br />
(DROPBOX) here https://www.dropbox.com/sh/t53vjs539gmixnm/AAC0BqTR0U5xghKwuVc1Iwbma?dl=0   <br />
or (BAIDU CLOUD) here https://pan.baidu.com/s/1C2ZOUGQl8w9M_eSBzb4NOg   <br />

<br />
A very preliminary User's Guide can be downloaded here https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf.
<br />
<br />
<br />
<b>Installation</b>

[1. MatLab version]: 

Download and unzip the Acyclev software to your root directory.

<br />
<br />
<b>Startup</b>

[1. MatLab version]:

(1) Change the MatLab working directory to the Acycle directory 

(2) Type 
```json
ac
```
in MatLab’s command window, then press the ENTER key.
<br />
<br />
<br />
<b>Data requirement</b>

See example data at https://github.com/mingsongli/acycle/tree/master/data

The input file of data series can be in a variety of formats, including table- or space-delimited text (.txt), and comma-separated values files (.csv) from an Excel-type spreadsheet. The data file must contain two columns of series. The first column must be in depth or time, and the second column should be value in the corresponding depth or time. Unit of the series in depth domain should be in meters. The data can be saved in any directory and is recommended to save in Acycle “data” folder. All data files, plots, and folders are displayed in the GUI list box.
<br />
<br />
<br />
<b>Functions and GUI</b>

The Acycle software contains the following functions.<br /><br />

<b>File</b> (New Folder; New Text File, Save AC.fig; Open *.fig File; Open Working Directory; Extract Data)<br /><br />

<b>Edit</b> (Rename; Cut; Copy; Paste; Delete)<br /><br />

<b>Plot</b> (Plot; Plot PLUS; Plot Standardized; Plot Swap Axis; Stairs; Sampling Rate; Data Distribution; ECOCO Plot)<br /><br />

<b>Basic Series</b> (Insolation; Astronomical Solution; LR04 Stack; Sine Wave; White Noise; Red Noise)<br /><br />

<b>Math</b> (Sort/Unique/Delete-empty; Select Parts; Merge Series; Add Gaps; Remove Parts; Remove Peaks; Clipping, Interpolation; Smoothing[Moving Average, Bootstrap, Gauss Process]; Changepoint; Sampling Rate Sensitivity; Standardize; Principal Component; Log-transform; First Difference; Derivative; Simple Function; Utilities[Find Max/Min]; Image[Show Image, RGB to Grayscale; Image Profile])<br /><br />

<b>Time series</b> (Pre-whitening; Spectral Analysis; Evolutionary Spectral Analysis; Wavelet transform; Filtering; Amplitude Modulation; Build Age Model; Age Scale; Sedimentary Rate to Age Model; Power Decomposition Analysis; DYNOT; ρ1 method; Correlation Coefficient; Evolutionary Correlation Coefficient; Track Sedimentation Rates)<br /><br />

<b>Help</b> (Readme; Manuals; Find Updates; Copyright; Contact)<br /><br />
<br />
<br />
<br />
```json
Read more at /doc/AC_Users_Guide.pdf
```
