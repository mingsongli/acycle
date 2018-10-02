- - - - - -    READ ME    - - - - - -

Update Log
_____________________________________

Version : ACycle_v0.2.2.20181001
Date    : Oct. 1, 2018; 9:37 pm EST
By      : Mingsong Li (Penn State)

	1. fix a bug for the high pass filter
_____________________________________

Version : ACycle_v0.2.2.20180928
Date    : Sept. 28, 2018; 7:44 pm EST
By      : Mingsong Li (Penn State)

	1. add Approximate Derivative function
    2. Fix filter missed code problem
    3. New Text File: add .txt in filename if users forget to do so.
    4. New Text File: use an alternative name if the file exists.
_____________________________________

Version : ACycle_v0.2.1.20180918
Date    : Sept. 18, 2018; 9:38 pm EST
By      : Mingsong Li (Penn State)

	1. fix a bug in PlotPLUS
    2. Add a new function: remove empty row in data 
        Math --> Sort/Unique/Delete-empty
_____________________________________

Version : ACycle_v0.2.1.20180915
Date    : Sept. 15, 2018; 10:18 pm EST
By      : Mingsong Li (Penn State)

	1. fix a bug in ac.m, save AC.fig automatically after running the eCOCO
    2. evoFFT GUI bug fixed
_____________________________________

Version : ACycle_v0.2.1.20180913
Date    : Sept. 13, 2018; 3:18 pm EST
By      : Mingsong Li (Penn State)

	1. refine ac.m, report Path Error
    % errordlg('Directory of the Acycle folder should NOT contain SPACE,
    % non-English or non-numeric characters','Path Error')
    2. Save AC.fig automatically after running the eCOCO

_____________________________________

Version : ACycle_v0.2.1.20180911
Date    : Sept. 11, 2018; 7:38 pm EST
By      : Mingsong Li (Penn State)

	1. Simplify COCO and eCOCO
    2. Automatically set best zero-padding numbers
    3. Set sliding step size
    4. Remove several decided settings
        such as adjust; slice and plot settings for eCOCO

_____________________________________

Version : ACycle_v0.2.0.20180822
Date    : Aug 22, 2018; 3:12 pm EST
By      : Mingsong Li (Penn State)

	1. upload to https://github.com/mingsongli/acycle

_____________________________________

Version : ACycle_v0.1.5.4.20180710
Date    : July 10, 2018; 4:51 pm EST
By      : Mingsong Li (Penn State)

	1. prepare first version for the https://github.com/mingsongli/acycle

_____________________________________

Version : ACycle_v0.1.5.3.20180614
Date    : June 14, 2018; 9:05 am EST
By      : Mingsong Li (Penn State)

	1. enable output of confidence levels of MTM
    
    2. fix bug of BasicSeries-Astronomical Solution

_____________________________________

Version : ACycle_v0.1.5.2.2018050
Date    : May 2, 2018; 4:02 pm EST
By      : Mingsong Li (Penn State)

	1. confidence level of MTM, following Linda Hinnov's code
        George Mason University
    http://mason.gmu.edu/~lhinnov/cyclostratigraphytools.html

_____________________________________

Version : ACycle_v0.1.5.20180409
Date    : April 9, 2018; 4:20 pm EST
By      : Mingsong Li (Penn State)

	1. Fix full path problem
        Changing directory won't lead to error
        apply fullfile function in the AC.m main script
    2. Pre-whitening
        Thanks feedbacks by Chuanyue Wang @ China University of Geosciences (Wuhan)
        Pre-whitening without using interpolation first
    3. Merge Windows and Mac versions of acycle
        guiwin folder: GUI for windows
        gui    folder: GUI for mac

_____________________________________

Version : ACycle_v0.1.4.20180314
Date    : March 18, 2018; 4:33 pm EST
By      : Mingsong Li (Penn State)

	fix cd problems
    Changing dir. in MatLab doesn't affect AC's Current Folder

_____________________________________

Version : ACycle_v0.1.4.20180314
Date    : Mar. 14 2018; 1:34 am EST
By      : Mingsong Li (Penn State)

    Insolation function is available (Basic series)!!!
        
	File menu: Add "save ACYCLE.fig" and "Open *.fig file"
        This will save all handles in the Acycle software as *.ac.fig MatLab fig file.
        This is crucial for the eCOCO function. Users don't have to re-run
        eCOCO if the ac window is closed.
        Just save the fig, and open the figure any time, 
        then one can continue the previous, suspended process.

_____________________________________

Version : ACycle_v0.1.3.20180227
Date    : Feb. 25 2018; 3:33 am EST
By      : Mingsong Li (Penn State)

	fix cd problems
    Changing dir. in AC doesn't affect MatLab's Current Folder
_____________________________________

Version : ACycle_v0.1.3.20180226
Date    : Feb. 25 2018; 3:33 am EST
By      : Mingsong Li (Penn State)

I thank Yang (Wendy) Zhang at Purdue University for her valuable feedback

    1. Fix bugs for evolutionary power spectral analysis
    2. Fix bug for change directory in MatLab Current Folder
        Now, the AC doesn't rely on MatLab's Current Folder
        But Change dir in AC do affect MatLab's Current Folder
_____________________________________

Version : ACycle_v0.1.3.20180225
Date    : Feb. 25 2018; 3:33 am EST
By      : Mingsong Li (Penn State)

    Add Plot Plus function for powerful plots
_____________________________________

Version : ACycle_v0.1.3.20180222
Date    : Feb. 22 2018
By      : Mingsong Li (Penn State)

    Update sampling rate sensitivity test plots
_____________________________________

Version : ACycle_v0.1.3.20180128
Date    : 28 Jan. 2018
By      : Mingsong Li (Penn State)

28 Jan. 2018
    Update Math menu
    For a time series
    1. add gaps
    2. remove sections
_____________________________________

Version : ACycle_v0.1.3.20180123
Date    : 23 Jan. 2018
By      : Mingsong Li (Penn State)

23 Jan. 2018
    Update eCOCO plot fuction
    Add reversed Y axis option for eCOCO
    0 = no plot
    1 = all in one figure
    2 = multiple figures
    3 = 3D plots in multiple figures
    -1, -2, or -3 =
        reversed Y-axis plots
_____________________________________

Version : ACycle_v0.1.3
Date    : 21 Jan. 2018
By      : Mingsong Li (Penn State)

21 Jan. 2018
    ACycle becomes a STAND ALONE program on Mac OS
    Save working the last working directory, which will be a next-run default dirctory
	because a "ac_pwd.txt" file is saved in code/bin directory.
_____________________________________

Version : ACycle_v0.1.2
Date    : 1 Jan. 2018
By      : Mingsong Li (Penn State)

8 Jan. 2018
    Listbox: specify blue color for folders

5 Jan. 2018
    fix a bug of the tested sedimentation rate mismatch

4 Jan. 2018
    Test oversampling of the dataseries using RHO of AR(1)
    Add Plot - Sampling rate to show distribution of series

1 Jan. 2018
    Add missed information of the "Readme.txt" file
    Remove 'temp' folder; move 
    Add a function of "double click" on the listbox1
    Add title of the "plot" function
    Refine ft.fig; fig.m add OK button
    
_____________________________________

Version : ACycle_v0.1.1
Date    : 17 December, 2017
By      : Mingsong Li (Penn State)

29 Dec, 2017
    Update correlation coefficient method
    Add Edit-Copy function
    
24 December, 2017
    Add Zeebe2017 astronomical solutions into the "Basic Series"
    
21 December, 2017
    Update the correlation coefficient method
        Split series into different sections
        Remove the previous adjustment function:
            Adjust power of simulated series to the power of the real data

_____________________________________

Version : ACycle_v0.1.0
Date    : 17 September, 2017
By      : Mingsong Li (Penn State)

Sep. 2017
    Refine many functions
    Add correlaiton coeffcient method to track variable sedimentation rates



_____________________________________
& & & & & & & & & & & & & & & & & & &
_____________________________________
& & & & & & & & & & & & & & & & & & &
_____________________________________ 



Version : AutoCsim
Date    : June, 2017
By      : Mingsong Li (Penn State)

June, 2017
    Completely redesign the GUI
    Move modules of 'Basic Information', 
        'Select Interval',
        'Interpolation', 
        'Smoothing', 
        'Pre-whitening', and 
        'Plot'
        to the MENU

_____________________________________
& & & & & & & & & & & & & & & & & & &
& & & & & & & & & & & & & & & & & & &
& & & & & & & & & & & & & & & & & & &
_____________________________________ 




Version : AutoC
Date    : May, 2017
By      : Mingsong Li (Penn State)

May 2017
    Refine the GUI of the code
    Add the function to generate the red noise and white noise series
    Incorporate DNSL.m function into this software
_____________________________________
Version : AutoC
Date    : Dec., 2016
By      : Mingsong Li (George Mason University)

Dec., 2016
    Refine the GUI version
    Add Laskar et al., 2004, 2010 astronomical solutions

_____________________________________
Version : AutoC
Date    : Jan, 2016
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

Jan., 2016
    The first GUI version

_____________________________________

Version : autoc1.2.7
Date    : Feb, 2016
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

Feb., 2016
    The first GUI version of "autocycle"

^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
_____________________________________
_____________________________________
- - - - - - - - - - - - - - - - - - -

Version : AUTOCYCLE 1.3.0
Date    : April 12, 2015
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

dte.m                 Test agemodel for a better correlation of results
f.m                   Calculate Taner-Hilbert filter using given or selected frequencies
                      modify scripts to save xls data avoid 32-bit problem.
- - - - - - - - - - - - - - - - - - -
Version : AUTOCYCLE 1.2.6  Dec, 2014
Date    :
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

    s3tt                  calculates evolutionary E, O, and P forcing variance automatically
    s1.m                  Add option of type selected_interval. 
    s2.m                  Modify scripts on saveing MTM figure with special filename
- - - - - - - - - - - - - - - - - - -
Version : AUTOCYCLE 1.2.5  14 Dec. 2014
Date    :
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

    gettie.m              Age model derived from Taner-Hilbert filter output
    sf.m                  show age model in the taner-hilbert filter figures
    d2t.m                 call for d2texam.m
    d2texam.m             test age model
- - - - - - - - - - - - - - - - - - -
Version : AUTOCYCLE 1.2.4
Date    :
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

    s3T.m                 calculates individual evolutionary E, O, and P forcing variance
    sf.m                  filter Taner-Hilbert passband.
    datapoints.m          
    thfilter.m            
    tanerhilbert.m        Code by Linda Hinnov
- - - - - - - - - - - - - - - - - - -
Version : AUTOCYCLE 1.2.3
Date    :
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

    Save calculate results in excel file.
    evopmtm.m             evolutionary mtm
    s3.m
- - - - - - - - - - - - - - - - - - -
Version : Autocycle 1.2.2
Date    :
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

    Modify evofft.m
        output S, 
        x_grid, 
        y_grid of the evolutionary fft for special orbital cycles analysis
- - - - - - - - - - - - - - - - - - -
Version : AUTOCYCLE 1.2.1
Date    :
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

    s1.m
    s2.m
    cycloautos2.m
    getpks.m
- - - - - - - - - - - - - - - - - - -
Version : AUTOCYCLE 1.1
Date    :
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

    findduplicate.m       
    getinterval.m
    depthtotime.m          Code shared by Linda Hinnov
    d2t.m
    resample.m
- - - - - - - - - - - - - - - - - - -
Version : AUTOCYCLE 1.0
Date    :
By      : Mingsong Li (China Univ. of Geosciences & Johns Hopkins Univ.)

    basicinput.m 
    curor_info_depth.m
    depeaks.m
    detrend.m
    redconf.m              Code by Husson, 2013; shared by Linda Hinnov
    Rednoise.m             Code by Husson, 2013; shared by Linda Hinnov
    rhoAR1.m               Code by Husson, 2013; shared by Linda Hinnov
    evofft.m               Code shared by Linda Hinnov
- - - - - - - END - - - - - - - - -