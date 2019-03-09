![logo](https://github.com/mingsongli/acycleFig/blob/master/default_icon_1024-git.gif)

[![](https://img.shields.io/badge/license-GPL-brightgreen.svg)](https://www.gnu.org/licenses/)
[![](https://img.shields.io/badge/platform-Mac_Win-green.svg)]()
[![](https://img.shields.io/badge/version-v1.0-blue.svg)]()
![](https://img.shields.io/badge/language-MatLab-red.svg)
---
`Acycle is a time-series analysis software for paleoclimate research and education`

### Highlights
> * Acycle is signal processing software for paleoclimate research and education
> * Many of the functions are specific to cyclostratigraphy and astrochronology
> * Acycle includes models for sedimentary noise and sedimentation rate
> * A fully implemented graphical user interface facilitates operator use
* [Read More](https://github.com/mingsongli/acycle#abstract)

### Wiki: Table of Content
* [**Getting Started**](https://github.com/mingsongli/acycle/wiki/3.-Getting-Started) <br>
* [Read More](https://github.com/mingsongli/acycle#wiki-table-of-content-1)
    
### What they say
* **Dr. James Ogg** (Professor, Purdue University, USA):
    > His _**Acycle**_ software will become the standard tool for time-scale applications by all international workers."<br>
* [Read More](https://github.com/mingsongli/acycle#what-they-say)
    
### Please cite
> Mingsong Li, Linda A. Hinnov, Lee R. Kump, 2019. _Acycle_: Time-series analysis software for paleoclimate research and education. Computers & Geosciences. https://doi.org/10.1016/j.cageo.2019.02.011.
---
### Contact
Mingsong Li, Penn State. Feb. 26, 2019

E-mail: <i> mul450 {at} psu.edu;</i>

&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <i>limingsonglms {at} gmail.com </i>
<br><br>
Website: www.mingsongli.com/acycle <br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; https://github.com/mingsongli/acycle <br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; https://github.com/mingsongli/acycle/wiki
<br><br>

<b> ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) &nbsp;
`Please give it a "Star" and "Watch" if you like this software. (top right corner of this page)`

<br>

---
### Abstract
* Acycle is a comprehensive, but "user-friendly" software package for analysis of time-series designed for paleoclimate research and education.
* Acycle runs either in the MATLAB environment or as a stand-alone application on macOS and Windows.
* It is an open-source package and is available free of charge.
    * Acycle provides data preparation tools, detrending procedures with multiple options available to track or remove secular trends, and integrates various power spectral analysis approaches for detection and tracking of periodic signals.

    * Acycle also provides a toolbox that evaluates astronomical signals in paleoclimate series, and estimates the most likely sedimentation rate by maximizing the correlation coefficient between power spectra of an astronomical solution and a paleoclimate series.

    * Sedimentary noise models for sea-level variations are also included.

    * Many of the functions are specific to cyclostratigraphy and astrochronology, and are not found in standard, statistical packages.

![gui](https://github.com/mingsongli/acycleFig/blob/master/Fig.1-GUI.jpg)
---
## Wiki: Table of Content

[**1. Copyright**](https://github.com/mingsongli/acycle/wiki/1.--Copyrights) <br>
[**2. References**](https://github.com/mingsongli/acycle/wiki/2.--References) <br>

[**3. Getting Started**](https://github.com/mingsongli/acycle/wiki/3.-Getting-Started) <br>
* [3.1 System requirements](https://github.com/mingsongli/acycle/wiki/3.-Getting-Started#31-system-requirements) <br>
* [3.2 Downloading](https://github.com/mingsongli/acycle/wiki/3.-Getting-Started#32-downloading-the-acycle-software) <br>
* [3.3 MatLab version](https://github.com/mingsongli/acycle/wiki/3.-Getting-Started#33-matlab-version) <br>
* [3.4 Mac version](https://github.com/mingsongli/acycle/wiki/3.-Getting-Started#34-mac-version) <br>
* [3.5 Windows version](https://github.com/mingsongli/acycle/wiki/3.-Getting-Started#35-windows-version) <br>
* [3.6 Data requirement](https://github.com/mingsongli/acycle/wiki/3.-Getting-Started#36-data-requirement) <br>

[**4. Graphical User Interface**](https://github.com/mingsongli/acycle/wiki/4.-Graphical-User-Interface) <br>
* [4.1 Functions and GUI](https://github.com/mingsongli/acycle/wiki/4.-Graphical-User-Interface#41-functions-and-gui) <br>
* [4.2 File](https://github.com/mingsongli/acycle/wiki/4.-Graphical-User-Interface#42-file) <br>
* [4.3 Edit](https://github.com/mingsongli/acycle/wiki/4.-Graphical-User-Interface#43-edit) <br>
* [4.4 Plot](https://github.com/mingsongli/acycle/wiki/4.-Graphical-User-Interface#44-plot) <br>
* [4.5 Basic Series](https://github.com/mingsongli/acycle/wiki/4.5-Basic-Series) <br>
    * [Insolation](https://github.com/mingsongli/acycle/wiki/4.5-Basic-Series#insolation)
    * [Astronomical solution](https://github.com/mingsongli/acycle/wiki/4.5-Basic-Series#astronomical-solution)
    * [LR04 stack](https://github.com/mingsongli/acycle/wiki/4.5-Basic-Series#lr04-stack)
    * [Sine wave](https://github.com/mingsongli/acycle/wiki/4.5-Basic-Series#sine-wave)
    * [White noise](https://github.com/mingsongli/acycle/wiki/4.5-Basic-Series#white-noise)
    * [Red noise](https://github.com/mingsongli/acycle/wiki/4.5-Basic-Series#red-noise)
    * [Examples](https://github.com/mingsongli/acycle/wiki/4.5-Basic-Series#examples)

* [4.6 Math](https://github.com/mingsongli/acycle/wiki/4.6-Math)
    * [Sort/Unique/Delete-empty](https://github.com/mingsongli/acycle/wiki/4.6-Math#sortuniquedelete-empty)
    * [Interpolation](https://github.com/mingsongli/acycle/wiki/4.6-Math#interpolation)
    * [Select Parts](https://github.com/mingsongli/acycle/wiki/4.6-Math#select-parts)
    * [Merge Series](https://github.com/mingsongli/acycle/wiki/4.6-Math#merge-series)
    * [Add Gaps](https://github.com/mingsongli/acycle/wiki/4.6-Math#add-gaps)
    * [Remove Part](https://github.com/mingsongli/acycle/wiki/4.6-Math#remove-parts)
    * [Remove peaks](https://github.com/mingsongli/acycle/wiki/4.6-Math#remove-peaks)
    * [Clipping](https://github.com/mingsongli/acycle/wiki/4.6-Math#clipping)
    * [Smoothing](https://github.com/mingsongli/acycle/wiki/4.6-Math#smoothing)
    * [Changepoint](https://github.com/mingsongli/acycle/wiki/4.6-Math#changepoint)
    * [Standardize](https://github.com/mingsongli/acycle/wiki/4.6-Math#standardize)
    * [Principle Component](https://github.com/mingsongli/acycle/wiki/4.6-Math#principal-component)
    * [Log-transform](https://github.com/mingsongli/acycle/wiki/4.6-Math#log-transform)
    * [Derivative](https://github.com/mingsongli/acycle/wiki/4.6-Math#derivative)
    * [Simple Function](https://github.com/mingsongli/acycle/wiki/4.6-Math#simple-function)
    * [Utilities](https://github.com/mingsongli/acycle/wiki/4.6-Math#utilities)
    * [Image](https://github.com/mingsongli/acycle/wiki/4.6-Math#image)
    * [Plot Digitizer](https://github.com/mingsongli/acycle/wiki/4.6-Math#plot-digitizer)

* [4.7 Time series](https://github.com/mingsongli/acycle/wiki/4.7.1-Detrending)
    * [Detrending](https://github.com/mingsongli/acycle/wiki/4.7.1-Detrending)
    * [Prewhitening](https://github.com/mingsongli/acycle/wiki/4.7.2-Prewhitening)
    * [Spectral analysis](https://github.com/mingsongli/acycle/wiki/4.7.3-Spectral-Analysis)
    * [Evolutionary spectral analysis](https://github.com/mingsongli/acycle/wiki/4.7.4-Evolutionary-Spectral-Analysis)
    * [Wavelet](https://github.com/mingsongli/acycle/wiki/4.7.5-Wavelet-transform)
    * [Filtering](https://github.com/mingsongli/acycle/wiki/4.7.6-Filtering)
    * [Build age model](https://github.com/mingsongli/acycle/wiki/4.7.7-Build-Age-Model)
    * [Age scale](https://github.com/mingsongli/acycle/wiki/4.7.8-Age-Scale)
    * [Sedimentation rate to age model](https://github.com/mingsongli/acycle/wiki/4.7.9-Sedimentary-Rate-to-Age-Model)
    * [Power decomposition analysis](https://github.com/mingsongli/acycle/wiki/4.7.10-Power-Decomposition-Analysis)
    * [Sedimentary noise model](https://github.com/mingsongli/acycle/wiki/4.7.11-Sedimentary-noise-model)
    * [Correlation coefficient (COCO)](https://github.com/mingsongli/acycle/wiki/4.7.12-Correlation-Coefficient-(COCO))
    * [Evolutionary COCO (eCOCO)](https://github.com/mingsongli/acycle/wiki/4.7.13-Evolutionary-Correlation-Coefficient-(eCOCO))
    * [TimeOpt](https://github.com/mingsongli/acycle/wiki/4.7.14-TimeOpt)
    * [eTimeOpt](https://github.com/mingsongli/acycle/wiki/4.7.15-eTimeOpt)

* [4.8 Help](https://github.com/mingsongli/acycle/wiki/4.8-Help)
* [4.9 Mini-robot](https://github.com/mingsongli/acycle/wiki/4.9-Mini-robot)
* [**Examples**](https://github.com/mingsongli/acycle/wiki/Examples) <br>
    * [Insolation](https://github.com/mingsongli/acycle/wiki/Examples#example-1-insolation)
    * [Astronomical solution](https://github.com/mingsongli/acycle/wiki/Examples#example-2-la2004-astronomical-solution-etp)
    * [Wayao Triassic](https://github.com/mingsongli/acycle/wiki/Examples#example-3-carnian-cyclostratigraphy)

## Communication

[**Frequently Asked Questions**](https://github.com/mingsongli/acycle/wiki/Frequently-Asked-Questions) <br>

---
## What they say

* **Dr. James Ogg** (Professor of DEPT. EARTH ,ATMOS. & PLANET. SCI., Purdue University, USA):

    > "Mingsong Li's _**Acycle**_ software enables us to quickly analyze the potential of new outcrops and boreholes, and then to determine the sedimentation rates and elapsed time. His _**Acycle**_ software will become the standard tool for time-scale applications by all international workers."

* **Dr. Paul E. Olsen** (Arthur Storke Memorial Professor of Earth and Environmental Sciences of **Columbia University**; Member, National Academy of Sciences of the USA):

    > Not only is this software powerful and effective, it is also simple to use and therefore benefits researchers and at all levels within the paleoclimatology community, from novices to experts.

* **Dr. Marco Franceschi** (Professor of Department of Geosciences, University of Padova, Italy):

    > Dr. Li’s software is being immensely valuable to my work. Some of the stratigraphic series I am studying display a prominent cyclicity, but were deposited in contexts characterized by relevant changes in sedimentation rates and often lack accurate geochronological constraints. _**Acycle**_ has been designed specifically for dealing with similar cases, by tackling them with a rigorous statistical approach, and therefore is providing an invaluable tool for their investigation.
    
* **Dr. Xu Yao** (Professor of School of Earth Sciences, Lanzhou University, China)
    > I am working on cyclostratigraphy and paleoclimate study of ancient strata and rocks (270 million years ago) with assistance from _**Acycle**_ software. I also introduced this software to my colleagues whose research areas are paleoclimate implications of Quaternary loess (several thousand years ago). My colleagues have given me really good feedbacks about _**Acycle**_ software. 
    
* **Dr. Christian Zeeden** (IMCCE, Observatoire de Paris, France):
    > Dr. Li’s software is novel and valuable in this context, especially because it facilitates the easy application of otherwise complex calculations.
  
* **A professor of University of Zaragoza in Spain**:
    > Thank you very much and congratulations for the _**acycle**_ software. I am using it and it is very very useful
and interesting.

* **A professor of University of Copenhagen in Denmark**:
    > I’ve been playing a lot with the excellent _**Acycle**_ package for Matlab that Mingsong developed. Congratulations, this is a very nice interface that simplifies a lot our work and makes it truly faster to analyse a time-series.
    
---
## Read more
- **Wiki**: https://github.com/mingsongli/acycle/wiki <br>
- or here: https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
- or here:  _Acycle_ "**Help**" menu - "**Manual**",
- or here:

```json
  /doc/AC_Users_Guide.pdf
```

<b> ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) &nbsp;
`Please give it a "Star" and "Watch" if you like this software. (top right corner of this page)`
