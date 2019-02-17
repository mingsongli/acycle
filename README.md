# Acycle v0.3.2
<br />
<b>Acycle: a time-series analysis software for paleoclimate projects and education</b>
<br />
<br />

<b> Mingsong Li, Penn State. Feb. 18, 2019

<b>E-mail</b>: <i> mul450 {at} psu.edu;</i>

&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <i>limingsonglms {at} gmail.com </i>
<br /><br />

Website: www.mingsongli.com/acycle

&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; https://github.com/mingsongli/acycle

<br />

```diff
+ With redesigned Acycle GUI, NO coding experience is required.
```

```diff
+ With Acycle stand-alone versions, NO Matlab is needed.
```

Acycle is a comprehensive, but "user-friendly" software package for analysis
of time-series designed for paleoclimate research and education.
Acycle runs either in the MATLAB environment or as a stand-alone application
on macOS and Windows, and is available free of charge.

<i>Acycle provides data preparation tools, detrending procedures with multiple options available
 to track or remove secular trends, and integrates various power spectral
 analysis approaches for detection and tracking of periodic signals.

Acycle also provides a toolbox that evaluates astronomical signals in
paleoclimate series, and estimates the most likely sedimentation rate
by maximizing the correlation coefficient between power spectra of
an astronomical solution and a paleoclimate series.

Sedimentary noise models for sea-level variations are also included.

Many of the functions are specific to cyclostratigraphy and astrochronology,
and are not found in standard, statistical packages. </i>
<br />
<br />
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `0. Download`


<b>Matlab version can be downloaded </b><br /><br />
(GITHUB) here https://github.com/mingsongli/acycle   <br /> <br />

<b>Windows and Mac standalone versions can be downloaded </b>
<br />
<br />
(DROPBOX) here https://www.dropbox.com/sh/t53vjs539gmixnm/AAC0BqTR0U5xghKwuVc1Iwbma?dl=0  or <br />
(BAIDU CLOUD) here https://pan.baidu.com/s/1C2ZOUGQl8w9M_eSBzb4NOg   <br />
<br />
<b>A very preliminary User's Guide can be downloaded here </b>:

https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
<br />
<br />
<br />
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `1. MatLab version`
<br />
<br />
For MatLab on either Mac or Windows: MatLab is essential for the Acycle software package.
<br />

1. <b>How to install</b>

- Download and unzip the Acycle software to your root directory. All set.

2. <b>How to startup </b>

- (step 1) Change the MatLab working directory to the Acycle directory

- (step 2) Start-up.
    Option 1: right-click file "ac.m", then choose "Run".
+    Option 2: Type


```json
ac
```
<br />
in MatLab command window, press the ENTER key.
<br />
<br />

```json
Read more tips on the installation at Section 3.3 in /doc/AC_Users_Guide.pdf
```
or here: https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
<br />
<br />
<br />
<br />
![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `2. Mac version`
<br />
<br />
<br />
It was tested in Mac OS Mojave system (macOS 10.14). <br /><br />
If the Mac runs with no MatLab, MatLab runtime 2015b is essential for the Acycle stand-alone software.
<br />
<br />
Two versions are available:
<br />
<br />

- <b>version #1. Acycle0.3.1-Mac-green</b>

1. <b>How to install:

- (Step 1) Download and unzip <b>Acycle0.3.1-Mac-green.zip <br />


- (Step 2) Download MatLab runtime <b>R2015b</b> “MCR_R2015b_maci64_installer.zip” here:
https://www.mathworks.com/products/compiler/matlab-runtime.html

- (Step 3) Install MatLab runtime <b>R2015b</b>. <br /><br />
Right-click "InstallForMacOSX" and select “Show Package Contents”.
In the pop-up folder, double-click “Content/MacOS/InstallForMacOSX” to install runtime <b>R2015b</b>.

- (Step 4) Setup Runtime environment <br /> <br />

    How to set the MatLab Runtime environment variable DYLD_LIBRARY_PATH? <br />
    Below is a nice answer by Walter Roberson on 14 Jan 2016.<br />
https://www.mathworks.com/matlabcentral/answers/263824-mcr-with-mac-and-environment-variable

2. <b>How to startup:

- (Step 1) Drag the <i>Acycle0.3.1</i> file to the <i>"/Applications"</i> folder.<br />

- (Step 2) Go to the <i>“/Applications”</i> folder. Right-click <i>Acyclev0.3.1</i>, choose <i>Show Package Content</i>

- (Step 3) Go to the <i>"Contents/MacOS"</i> folder, drag the <i>applauncher</i> file to dock.

- (Step 4) Click icon of <i>applauncher</i> in the dock to start the Acycle.

```json
Warning: NEVER close the terminal window when using Acycle. This will close Acycle either.

Read more tips on the installation at Section 3.4 in /doc/AC_Users_Guide.pdf
```
- or here: https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
<br />
<br />
<br />

- <b>version #2. Acycle0.3.1-Mac-Installer</b>

1. <b>How to install:

- (Step 1) Download and unzip <b>Acycle0.3.1-Mac-Installer.zip <br />
- (Step 2) Double click to install Acycle and MatLab runtime <b>R2015b</b> simultaneously. <br />
- (Step 3) Setup Runtime environment <br /> <br />

    How to set the MatLab Runtime environment variable DYLD_LIBRARY_PATH?<br />
    Below is a nice answer by Walter Roberson on 14 Jan 2016.<br />
https://www.mathworks.com/matlabcentral/answers/263824-mcr-with-mac-and-environment-variable

- (Step 4) Go to the installation folder (for example: /Applications/Acycle/application)<br />


- Right click “Acycle” file, choose “Show Package Content”<br />
Go to the “Contents/MacOS” folder, drag the <i>applauncher</i> file to dock.

2. <b>How to startup:
- Click icon of <i>applauncher</i> in the dock to start the Acycle software.
<br />


![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `3. Windows version`
</b>

- <b> version #1. Acycle0.3.1-Win-green</b>

 Green version. No installation needed. MatLab Runtime <b>R2017a</b> is essential.
<br />
- (Step 1) Download <b>Acycle0.3.1-Win-green

- (Step 2) Download MatLab runtime <b>R2017a</b> here:
https://www.mathworks.com/products/compiler/matlab-runtime.html

- (Step 3) Install MatLab runtime <b>R2017a</b>.

- (Step 4) Run Acycle: <br /><br />
	You could just double click <b> Acycle.exe </b> to run the software

    <b> However, I strongly recommend the following start-up method,
    which will enable a command window showing a lot of information about many time-consuming steps.
- (Step 4.1) Use “Win + R” short-cut keys to start the “RUN” of Window<br />
Then in the pop-up window, type the following command, and then click OK button.
<br />

    cmd

- (Step 4.2) Type following two lines of command below in the command window to run Acycle. <br />

- <i>For example, my <b>Acycle.exe</b> file is under the directory “ C:\”, so the two lines should be:<br /></i>
<br />

    cd C:\
    Acycle

<br />

    Warning: the first-time start-up can be extremely slow.

    Warning: Never close the command window when Acycle is running.
             The commend window will keep on showing information when it runs time-consuming steps.

<br />

- <b> version #2. Acycle0.3.1-Win-Installer</b>


- (Step 1) Download Acycle0.3.1-Win-Installer
- (Step 2) Installation
<br /><br />
Double click “AcycleInstaller.exe” to install Acycle and MatLab runtime <b>R2017a</b> simultaneously. <br />
Following the instructions, you will get everything set. <br />
Downloading MatLab runtime <b>R2017a</b> can take a lot of time. The runtime needs 1 GB space. <br />
- (Step 3) Start-up <br /><br />
	You could just double click the <b>AC</b> icon on the desktop to run Acycle
	or start from the Windows “All Program” menu like any other software.

    <b> However, I strongly recommend the following start-up method,
    which will enable a command window showing a lot of information about many time-consuming steps.

- (Step 4.1) Use “Win + R” short-cut keys to start the “RUN” of Window<br />
Then in the pop-up window, type the following command, and click <b>OK</b> button.
<br />

    cmd
<br />

- (Step 4.2) Type following two lines of command below in the command window to run Acycle. <br />

- <i>For example, my <b>Acycle</b> software was installed under the directory “ C:\Program Files”, so it should be:<br /></i>
<br />

    cd C:\Program Files\Acycle\application\
    Acycle

<br />

    Warning: the first-time start-up can be extremely slow.

    Warning: Never close the command window when Acycle is running.
             The commend window will keep on showing information when it runs time-consuming steps.

<br />
<br />

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `. Data requirement`

</b>


- See example data at https://github.com/mingsongli/acycle/tree/master/data
<br /><br />
The input file of data series can be in a variety of formats,
including table- or space-delimited text (.txt),
and comma-separated values files (.csv) from an Excel-type spreadsheet.

- The data file must contain two columns of series.

- The first column must be in depth or time, and the second column
should be value in the corresponding depth or time.

- Unit of the series in depth domain should be in meters.

- The data can be saved in any directory.
All data files, plots, and folders are displayed in the GUI list box.

    Still have no idea, don't worry. Try this, you’ll have a perfect example:

    Choose “Basic Series” menu --  select "Insolation" -- Click “OK” button

    Double-click generated file “Insol-t-1-1000ka-day-80-lat-65-meandaily-La04.txt” for details.
    Double-click the "Open Working Folder" icon, you will see this new text file in the working folder.

<br />
<br />

![#f03c15](https://placehold.it/15/f03c15/000000?text=+) `. Functions and GUI`

<br />

- The Acycle software contains the following functions.<br />

- <b>File</b> (New Folder; New Text File, Save AC.fig;
Open Working Directory; Extract Data)<br />

- <b>Edit</b> (Rename; Cut; Copy; Paste; Delete)<br />

- <b>Plot</b> (Plot; Plot PLUS; Plot Standardized; Plot Swap Axis;
Stairs; Sampling Rate; Data Distribution; ECOCO Plot)<br />

- <b>Basic Series</b> (Insolation; Astronomical Solution;
LR04 Stack; Sine Wave; White Noise; Red Noise)<br />

- <b>Math</b> (Sort/Unique/Delete-empty; Select Parts; Merge Series;
Add Gaps; Remove Parts; Remove Peaks; Clipping, Interpolation;
Smoothing (Moving Average, Bootstrap); Changepoint;
Standardize; Principal Component; Log-transform; First Difference;
Derivative; Simple Function; Utilities (Find Max/Min);
Image (Show Image, RGB to Grayscale; Image Profile))<br />

- <b>Time series</b> (Pre-whitening; Spectral Analysis;
Evolutionary Spectral Analysis; Wavelet transform; Filtering;
Amplitude Modulation; Build Age Model; Age Scale;
Sedimentary Rate to Age Model; Power Decomposition Analysis;
DYNOT; rho-1 method; Correlation Coefficient;
Evolutionary Correlation Coefficient; Track Sedimentation Rates)<br />

- <b>Help</b> (Readme; Manuals; Find Updates; Copyright; Contact)<br />

<br />

```json
Read more at /doc/AC_Users_Guide.pdf
```
