# Acycle v0.2.6

<b>Acycle -- a time-series analysis software for paleoclimate projects and education</b>

Mingsong Li, Penn State. Dec. 25, 2018

Website: www.mingsongli.com/acycle

![logo](https://github.com/mingsongli/acycle/blob/master/code/icons/acycle_logo.png | width=100)

```diff
+ With redesigned Acycle GUI, NO coding experience is required.
```
```diff
+ With Acycle stand-alone version, NO Matlab is needed.
```
Acycle is a comprehensive, but simple-to-use software package for analysis of time-series designed for paleoclimate research and education. Acycle runs either in the MATLAB environment or as a stand-alone application on Macintosh OS X <i>(ready)</i> and Windows  <i>(coming)</i>, and is available free of charge.

<i>Acycle provides prewhitening procedures with multiple options available to track or remove secular trends, and integrates various power spectral analysis approaches for detection and tracking of periodic signals. 
Acycle also provides a toolbox that evaluates astronomical signals in paleoclimate series, and estimates the most likely sedimentation rate by maximizing the correlation coefficient between power spectra of an astronomical solution and a paleoclimate series. Sedimentary noise models for sea-level variations are also included. 
Many of the functions are specific to cyclostratigraphy and astrochronology, and are not found in standard, statistical packages. </i>

Acycle [Matlab and Mac versions]can be downloaded <br />
(GITHUB) here https://github.com/mingsongli/acycle   <br />
(DROPBOX) here https://www.dropbox.com/sh/t53vjs539gmixnm/AAC0BqTR0U5xghKwuVc1Iwbma?dl=0   <br />
or (BAIDU CLOUD) here https://pan.baidu.com/s/1C2ZOUGQl8w9M_eSBzb4NOg   <br />

<br />
A very preliminary User's Guide can be downloaded here https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf.
<br />
<br />
<br />
<b>MatLab version</b>
<br />
For MatLab on Mac & Windows: Recommended! MatLab is essential for the Acycle software package.
<br />
[1. How to install ]: 
<br />
Download and unzip the Acycle software to your root directory. All set.
<br />
[2. How to startup ]:
<br />
(1) Change the MatLab working directory to the Acycle directory 
<br />
(2) Option 1: right-click file "ac.m", then choose "Run". 
<br />
    Option 2: Type 
```json
ac
```
in MatLab command window, then press the ENTER key.
<br />
<br />
```json
Read more tips on the installation at Section 3.3 in /doc/AC_Users_Guide.pdf
or here: https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
```
<br />
<br />
<b>Mac version</b>
<br />
This software is a stand-alone program. It was tested in Mac OS Mojave system (macOS 10.14). If the Mac runs with no MatLab, MatLab runtime is essential for the Acycle stand-alone software.
<br />
<br />
Two versions are available:
v1. Acycle0.2.6-Mac
<br />
[1. How to install ]: 
No installation needed. Size: 97.0 Mb. If you have Matlab installed. Steps 1-2 can be skipped.
<br />
Step 1: Download runtime. MatLab runtime R2015b is not included in this package and the ?MCR_R2015b_maci64_installer.zip? can be downloaded at: https://www.mathworks.com/products/compiler/matlab-runtime.html 
<br />
Step 2: Install runtime R2015b for mac OS X. Double click the file "InstallForMacOSX". 
Or right-click and select ?Show Package Contents? of "the InstallForMacOSX" file. In the pop-up folder, double click ?InstallForMacOSX?. Then it may ask permission for installation. Follow instructions of the MatLab Runtime installer, you will install Runtime.
<br />
Step 3: Setup Runtime environment 
How to set the MatLab Runtime environment variable DYLD_LIBRARY_PATH?
Here is a nice answer by Walter Roberson on 14 Jan 2016.
https://www.mathworks.com/matlabcentral/answers/263824-mcr-with-mac-and-environment-variable 
<br />
Step 4: Download Acycle0.2.6-Mac
Dropbox at: https://www.dropbox.com/sh/t53vjs539gmixnm/AAC0BqTR0U5xghKwuVc1Iwbma?dl=0 , or 
Baidu Cloud at: https://pan.baidu.com/s/14-xRzV_-BBrE6XfyR_71Nw
<br />
Step 5: Drag the Acycle0.2.6-Mac file to the /Applications folder. Go to the ?/Applications? folder. Right click ?Acyclev0.2.6-Mac? file, choose ?Show Package Content?.
<br />
Step 6: Go to ?/Contents/MacOS? folder, drag the ?AC? file to dock (NOT the ?Acycle? file).
<br />
[2. How to startup ]:
<br />
Step 1: Click icon of ?AC? in the dock above to start the Acycle software.
<br />
v2. Acycle0.2.6-Mac-Installer_w_runtime
<br />
[1. How to install ]: 
Install Acycle and MatLab runtime simultaneously.
Size: 883.2 Mb; MatLab runtime R2015b has been imbedded in this package.
<br />
Step 1: Download Acycle0.2.6-Mac-Installer_w_runtime
Dropbox at: https://www.dropbox.com/sh/t53vjs539gmixnm/AAC0BqTR0U5xghKwuVc1Iwbma?dl=0 , or 
Baidu Cloud at: https://pan.baidu.com/s/14-xRzV_-BBrE6XfyR_71Nw
<br />
Step 2. Installation of Acycle and MatLab runtime simultaneously. Double click ?Acycle0.2.6-Mac-Installer_w_runtime? to start the installation. The admin permission may be required.
<br />
Step 3: Following instructions of Acycle Installer. Choose Acycle installation folder (default folder is /Applications/Acycle).
<br />
Step 4: Choose MATLAB Runtime installation folder (default folder is /Applications/MATLAB/MATLAB_Runtime).
<br />
Step 5: Setup Runtime environment
How to set the MatLab Runtime environment variable DYLD_LIBRARY_PATH?
Here is a nice answer by Walter Roberson on 14 Jan 2016.
https://www.mathworks.com/matlabcentral/answers/263824-mcr-with-mac-and-environment-variable 
<br />
[2. How to startup ]:
<br />
You only need to do Steps 1-3 for the first time. Then only Step 4 below is need.
<br />
Step 1: Go to the installation folder (for example: /Applications/Acycle/application). 
<br />
Step 2: Right click ?Acycle? file, choose ?Show Package Content?
<br />
Step 3: Go to the ?Contents/MacOS? folder, drag the applauncher file to dock. Before that, you may want to change filename of the ?applauncher? to ?AC? or any other name except Acycle.
<br />
Step 4: Click icon of ?applauncher? (or ?AC?) above to start the Acycle software. 
?Warning: NEVER close the terminal window (left panel below)  when using Acycle. This will close Acycle either. To kill Acycle software, press CTRL + C keys?
<br />
```json
Read more tips on the installation at Section 3.4 in /doc/AC_Users_Guide.pdf
or here: https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
```
<br />
<b>Windows version</b>
<br />
Coming
<br />
<b>Data requirement</b>

See example data at https://github.com/mingsongli/acycle/tree/master/data

The input file of data series can be in a variety of formats, including table- or space-delimited text (.txt), and comma-separated values files (.csv) from an Excel-type spreadsheet. The data file must contain two columns of series. The first column must be in depth or time, and the second column should be value in the corresponding depth or time. Unit of the series in depth domain should be in meters. The data can be saved in any directory and is recommended to save in Acycle ???data??? folder. All data files, plots, and folders are displayed in the GUI list box.
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

<b>Time series</b> (Pre-whitening; Spectral Analysis; Evolutionary Spectral Analysis; Wavelet transform; Filtering; Amplitude Modulation; Build Age Model; Age Scale; Sedimentary Rate to Age Model; Power Decomposition Analysis; DYNOT; ??1 method; Correlation Coefficient; Evolutionary Correlation Coefficient; Track Sedimentation Rates)<br /><br />

<b>Help</b> (Readme; Manuals; Find Updates; Copyright; Contact)<br /><br />
<br />
<br />
<br />
```json
Read more at /doc/AC_Users_Guide.pdf
```
