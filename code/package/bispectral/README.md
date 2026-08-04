# Acycle Bispectral Analysis

This toolbox estimates the complex bispectrum and normalized bicoherence of
a paleoclimate series. FFT estimation requires regular coordinates. It is opened
from **Timeseries > Bispectral Analysis** after selecting one two-column file
in the Acycle main list.

## Quantities and convention

For each positive-frequency triad, with `f3 = f1 + f2`, Acycle uses

```text
B(f1,f2) = mean[X(f1) X(f2) conj(X(f3))]
```

and the Kim–Powers magnitude-squared normalization

```text
b^2 = |sum(A conj(C))|^2 / (sum|A|^2 sum|C|^2)
A = X(f1)X(f2), C = X(f1+f2).
```

The weighted Cauchy–Schwarz inequality guarantees `0 <= b^2 <= 1`. The
result structure keeps all of the following distinct:

- complex `Bispectrum`, its magnitude, squared magnitude, real and imaginary
  parts;
- `Biphase = angle(Bispectrum)` where the complex bispectrum is nonzero;
  undefined zero-bispectrum or invalid-denominator cells are `NaN`;
- `BicoherenceSquared = b^2`; the redundant square root `b` is not stored.

The GUI deliberately displays only `b^2`, not its redundant square root `b`:
the estimator bounds, surrogate inference, and reported
thresholds are all defined on `b^2`. The GUI summarizes the complex
bispectrum with `|B|` and biphase. `Re(B)` and `Im(B)` remain in the MAT result
for specialist phase-symmetry or direction-reversal studies, but they are not
offered as separate routine figures.

Only the positive, unaliased sum-frequency triangle is calculated:
`f1 > 0`, `f2 > 0`, `f2 <= f1`, and `f1 + f2` below Nyquist. DC, wrapped
negative frequencies, and the exact even-length Nyquist bin are excluded.
This is the domain needed for the displayed positive relation
`f3 = f1 + f2`; it is intentionally smaller than the full 12-fold
discrete-time principal region, whose outer sector wraps `f1 + f2` across
Nyquist to a negative frequency.

## Two estimators

1. **WOSA segmented FFT (recommended).** The series is divided into at least
   three segments, each segment is detrended and tapered, and FFT triads are
   averaged. The GUI default is eight Hann-tapered segments with 50% overlap.
   Overlap improves use of the record but makes analytical degrees of freedom
   approximate.
2. **Frequency-smoothed direct.** A single native-grid FFT is smoothed with a
   complete hexagonal kernel
   `|a| <= h, |b| <= h, |a+b| <= h`. Span 3 (`h=1`) uses seven triads and span
   5 uses nineteen. It never treats zero-padded bins as new realizations.

For short inputs the defaults are data-dependent. If three 32-sample WOSA
segments fit, the requested segment count is reduced to a feasible value;
for 32--63 distinct samples the default switches to the full-record
frequency-smoothed estimator. Inputs with fewer than 32 distinct finite
coordinates are rejected.

A naive `segment x DPSS taper` average is deliberately not included. A DPSS
eigenvector has an arbitrary sign, while a third-order same-taper product
changes sign if the taper changes sign. A valid multitaper bispectrum needs
three-taper combinations and explicit third-order taper-coupling weights; see
[Birkelund & Hanssen (1999)](https://doi.org/10.1109/HOST.1999.778727).

## Input validation and preprocessing

The core API's `InputPolicy='prepare'` can prepare a regular coordinate grid.
Preprocessing removes
nonfinite rows, sorts coordinates, averages duplicate coordinates, and—when
`Interpolate=auto`—linearly resamples data whose spacing departure exceeds the
chosen tolerance. Large original gaps are recorded in metadata because
interpolation cannot restore missing information. Whole-record and
within-segment detrending are separate controls. Standardization affects raw
bispectrum units but not bicoherence.

A user-specified interval may refine the grid, but it may not be coarser than
the original median spacing. Ordinary interpolation is not an anti-aliasing
filter: to downsample, low-pass filter and resample the record first, then load
the already resampled series. The GUI always uses `InputPolicy='strict'`. It
accepts spacing departures up to 10 parts per million so that a regular grid
saved with limited text precision is not misclassified as uneven, but it does
not alter coordinates or data values. The GUI intentionally has no
preprocessing panel and performs no hidden row removal, sorting, duplicate
merging, interpolation, whole-record detrending, or standardization; prepare
genuinely uneven data with Acycle's dedicated tools first. Within-segment mean
removal remains an explicit estimator setting. Scientific warnings produced
after a run are printed in the MATLAB Command Window instead of opening a
modal warning dialog.

Recoverable GUI control mistakes such as a value outside its allowed range, a
fractional integer control, an incompatible parameter combination, or a guide
outside its theoretical Nyquist frequency/sum limits are consolidated once per operation and
restored to data-aware recommended or last-valid values. They are reported in
the Command Window and, for a visible GUI, in one warning alert. A Run displays
that alert only after computation, rendering or saving has ended and the
controls have been restored; failure of the alert itself is isolated from the
analysis. Corrections made by an edit callback remain pending through Preview
runs until the next successful Run & Save, so the effective values and their
correction audit trail enter the MAT/JSON archive. This recovery never applies
to the input series: nonfinite,
unsorted, duplicate, irregular, or otherwise structurally invalid data still
fail the strict input policy instead of being silently changed.

The zero-padding factor is applied to the actual segment length (factor 1 is
no padding). Zero padding only interpolates the displayed Fourier grid; it does not improve
Rayleigh resolution, create more independent information, or increase
significance degrees of freedom.

## Significance and interpretation

The GUI exposes one formal confidence procedure: **IAAFT surrogate
max-statistic** inference. Every accepted IAAFT surrogate preserves the sample
value distribution and approximates the observed Fourier amplitude within the
configured quality tolerance, reruns the complete estimator, and contributes
its maximum `b^2` over one fixed family: all finite observed triads in the
computed principal domain. A candidate surrogate missing any member of that
family is rejected and replaced. The resulting threshold controls the
family-wise error rate for that finite computed map, conditional on the
chosen IAAFT null, approximate spectrum matching, stationarity, and
exchangeability assumptions, independently of the plotted frequency limit.
Use at least 999 accepted surrogates for a research
run; 199 is the interactive preview. `None` is not a competing inference method:
switching an existing IAAFT result to `None` hides its contour immediately,
while a new Run under `None` skips surrogate inference.

The finite-sample decision uses the plus-one Monte Carlo p-value, not an
interpolated empirical percentile. With `alpha = 1-confidence`, let
`cmax` be the largest integer `c` for which `(1+c)/(M+1) <= alpha`, sort the
`M` surrogate maxima increasingly, and set the critical value to order
`M-cmax`. An observed `b^2` must be **strictly greater** than that value and
have plus-one `p <= alpha`; equality is not significant. Thus a 95% test with
`M=20` uses the largest (20th) surrogate maximum, while `M=999` uses order 950.
If no integer `c >= 0` satisfies the p-value condition, the requested level is
not attainable with that surrogate count.

The core API retains analytical Beta, FT phase-randomized, and pointwise modes
for compatibility and advanced non-GUI work. They are not GUI publication
options or recommended substitutes for the IAAFT maximum-statistic workflow.

`FrequencyMin` and `FrequencyMax` are plot limits only. They never change
computed triads, bicoherence, bispectrum, or the map-wide significance family.
`MaxFrequencyBins`, by contrast, is a calculation control: when it produces
a stride greater than one, the fixed FWER family covers every finite triad on
that sampled computation grid, not the skipped native FFT-bin combinations.
After one GUI Run, changing either limit, Figure, strongest-value fractions,
colormap grid, reference periods, frequency-pair guides, peak annotations, or
the secondary period axis redraws the cached result without repeating
estimation or inference.
Colored maps use
an explicitly refined `meshgrid`, `pcolor` with interpolated shading, and
square 1:1 x/y axes. The complete-map palette is red-white-blue. With a
strongest-value mask below 100%, weak cells are transparent and retained
`|B|`/`b^2` values use a white-to-red subset so low-value blue does not dominate;
biphase keeps the diverging red-white-blue palette. Grid refinement is confined
to rendering and never changes the computed FFT-frequency matrices.
All figure text is normalized to at least 6 pt; primary axes, period labels,
frequency-pair labels, colorbars, and the method caption use larger explicit
point sizes so saved figures do not inherit an unreadable root default.
The Overview places two log-y spectra above the maps: the left is horizontally
aligned with `|B|`, and the right with `b^2`. Both repeat the same mean-removed
processed-series Thomson 2pi MTM spectrum (`NW=2`, `K=3`, `NFFT=5N`) so each
column has an aligned one-dimensional frequency reference. This spectrum is
independent of the selected bispectral estimator. Alignment uses the actual
plot boxes rather than only the outer axes rectangles; the two upper axes have
no redundant x-axis labels. Their log-y limits are determined only from finite,
positive power inside the current plotted frequency range: the visible minimum
lands on the lower limit and the visible maximum occupies 80% of the log-axis
height, leaving 20% above it for later annotation. Each power axis keeps at
least three explicitly labeled y ticks.
`PlotKeepStrongestBispectrumFraction` and
`PlotKeepStrongestBicoherenceFraction` are independent plot-only adaptive
masks, both defaulting to `0.5`. Thus `|B|` and `b^2` each retain their own
highest 50% rather than sharing an invalid cross-quantity cutoff. Biphase uses
the `b^2` strength mask because phase is not reliable where coupling is weak.
PCOLOR first interpolates the complete finite color field; a separate
interpolated alpha mask then makes lower values fully transparent. Set the
relevant fraction to `1` to display its complete map. Older saved results with
one `PlotKeepStrongestFraction` remain readable as a compatibility fallback.
These masks never change saved estimates or significance calculations.
`PlotColorGrid` (GUI: `Colormap grid #`) sets 4--256 shared discrete colors;
the default is 32. Every map also uses five thin value contours on the same
refined mesh. A significant-mask boundary is projected to that display mesh
before drawing the thick black 0.5 contour; significance decisions themselves
remain on the original computed frequency grid.

`PlotReferencePeriods` (GUI: space-separated `Reference periods`) draws thin
dashed guides satisfying `f1+f2=1/period` on every two-dimensional map. Press
Tab or Enter after editing the field. Guide labels contain only the numerical
period value and sit just outside the upper-left start of the corresponding
line to avoid covering the color field. The guides are clipped to the visible
nonredundant principal domain and do not change any numerical result.

`PlotFrequencyPairs` (GUI syntax: `f1 f2; f3,f4`) is also display-only. Each
pair adds a thin dotted vertical line at `f1` and horizontal line at `f2`.
The two outside labels contain only the corresponding periods `1/f1` and
`1/f2`; the top label is horizontally centered on its vertical guide and the
right label is vertically centered on its horizontal guide. Empty input is
stored canonically as a `0-by-2` matrix. These guides,
like reference-period lines, redraw from cache and never change estimation or
inference.

Inference display is also cached. Selecting `None` after an IAAFT Run hides only
that cached significance contour. Selecting the exact inference configuration
used by the latest Run restores it without recomputation; an uncached IAAFT
configuration or changed inference parameter remains pending until Run or Run
& Save. Running while `None` is selected performs no surrogate calculation and
replaces the latest result with a no-inference result.

High, significant bicoherence means repeatable quadratic phase coupling at
`f1`, `f2`, and `f1+f2`. It does **not** by itself prove causality, direction of
energy transfer, or a particular physical mechanism. Non-sinusoidal waveform
shape, harmonics, clipping, proxy transformations, and interpolation can also
produce coupling. The sign of the imaginary bispectrum depends on coordinate
direction; reversing a real series conjugates its bispectrum and changes the
sign of its biphase.

## Files and reproducibility

`Run & Save` creates one uniquely named result folder in the directory shown
in the Acycle main-window address bar. If that folder is named `<stem>`, it
contains `<stem>.pdf`, `<stem>.fig`, `<stem>.mat`,
`<stem>-preprocessed.csv`, and `<stem>-config.json`; no generic `figure.fig`
or similarly ambiguous filename is used. The editable FIG retains the smooth
interactive `pcolor` rendering. For archival PDF output, a private figure copy
converts color fields to discrete vector polygons and is exported with
`ContentType='vector'`, preserving vector text, axes, contours, and fills
without Image XObjects.
No existing folder is overwritten, and the complete folder is committed
transactionally so a failed writer does not leave a partial result set. The
JSON records preprocessing, actual segment
length/overlap, window ENBW, Rayleigh resolution, frequency stride, triad count,
estimator normalization, significance settings, and warnings. Both MAT and
JSON also store `RenderSettings` read from the actual figure, including its
canonical quantity, effective frequency limits, two retain fractions, color
grid, reference periods, frequency pairs, annotations, period axes, actual
2pi-MTM settings, and significance display. Figure titles omit known input
file extensions.
For inference, JSON explicitly records whether map-wide control is
`maximum-statistic family-wise error rate (FWER)`, the fixed finite family
definition and its actual triad count, and that display frequency limits do
not alter it;
`None` is recorded as no multiple-comparison control and no inference family.

The module is regression-tested with MATLAB R2025b and uses current UI and
export APIs.

Run the deterministic and MATLAB unit suites with:

```matlab
report = bispectralSelfTest;
results = runtests('code/package/bispectral/tests');
acResults = runtests('code/test/test_ac_main_list.m');
assert(report.Passed);
assertSuccess(results);
assertSuccess(acResults);
```

The recorded R2025b baseline was 28/28 package tests. Three strict-spacing
regressions extend the current package suite to 31 tests. In MATLAB R2026a,
all eight I/O/spacing tests and the targeted GUI/default checks pass; two
pixel-geometry assertions remain sensitive to `-batch` web-component layout.
MATLAB Code Analyzer reports zero diagnostics for the modified Bispectral
files, and `git diff --check` passes.

It checks a known coupled triad and an uncoupled control, the `[0,1]` bound,
amplitude-cubed scaling, time-reversal conjugacy, zero denominators and zero
bispectra, uneven sampling and anti-aliasing rejection, direct formula
cross-checks for both estimators, a short-record route, IAAFT fidelity, the
hexagonal frequency smoother, and global-surrogate detection. The validation
driver additionally analyzes three real records (Newark, Site 1262, and LR04)
plus synthetic positive and AR(1) negative controls.

### Bundled LR04/CENOGRID sensitivity validation

The repository contains `data/Examples/LR04stack5320ka.txt` and
`data/Examples/Example-cenogrid-d18o.txt`. The LR04 record and the CENOGRID
0--5, 10--15, and 50--55 Ma intervals can be reproduced with:

```matlab
validation = bispectralLocalDataValidation(outputParent, ...
    'NumSurrogates',999,'MaxFrequencyBins',1024);
```

The driver uses the core `prepare` policy and always reconstructs an explicit
median-spacing linear grid, then compares regularized data with a named 800 kyr LOWESS
sensitivity result. LOWESS span, effective support width, endpoint policy, and
regularization metadata—including separate `OriginallyIrregular` and
`RegularGridReconstructed` flags—are stored as `ExternalPreprocessing` in MAT and JSON.
The validation summary also records the actual surrogate type, accepted count,
IAAFT iterations and tolerance, attempted/rejected counts, maximum accepted
spectral error, case-specific random seed, fixed-family definition, and actual
family triad count. It also records the computed
axis-bin count, native frequency-bin stride, Rayleigh resolution, and computed
frequency maximum; refined display meshes are never reported as numerical
resolution. Its formal defaults are 999 accepted IAAFT surrogates and
`MaxFrequencyBins=1024`.
Every raw and primary Overview is checked before saving for two actual,
identical 2pi-MTM curves; recomputation from the processed series; complete
MTM metadata (`NW=2`, `K=3`, `NFFT=5N`, mean removed); exact power titles,
labels and empty lower map titles; actual plot-box and frequency-limit
alignment; two horizontal colorbars between maps and caption; an
extension-free title; and independent `|B|`/`b^2` retain settings whose
recorded fractions and numerical cutoffs match the rendered maps. Each run
receives a strictly unique parent folder.

The formal 2026-08-03 R2025b run used 999 accepted IAAFT surrogates for every
LOWESS-detrended case and is archived at
`/Users/mingsongli/Library/CloudStorage/Dropbox/Acycle/NeedToDo/bispectral/LR04_CENOGRID_validation_20260803_025644_609`.
All four cases completed with zero rejected surrogates, 999 total attempts,
native frequency-bin stride 1, and no MATLAB warning or graphics-scene error.

| Case | FWER threshold | Significant visible triads | Significant computed-domain triads | Power at periods >=800 kyr, raw -> LOWESS |
|---|---:|---:|---:|---:|
| LR04 0--5.32 Ma | 0.841139286963534 | 3 | 7 | 0.7315 -> 0.0022 |
| CENOGRID 0--5 Ma | 0.882428296649124 | 0 | 0 | 0.6396 -> 0.0012 |
| CENOGRID 10--15 Ma | 0.846500330328155 | 0 | 1 | 0.7530 -> 0.0113 |
| CENOGRID 50--55 Ma | 0.850417194695958 | 0 | 11 | 0.3675 -> 0.0199 |

“Visible” refers only to the saved plotting window; the FWER threshold is
calculated over the complete fixed finite computed family and is unaffected
by that display window.

### Five-dataset method validation

The Newark and Site 1262 research records used by the separate five-dataset
method validation are not bundled. Supply their directory explicitly:

```matlab
validation = bispectralValidateExamples(outputDirectory, ...
    'DataDirectory','/path/to/folder/containing/newark-and-site1262-files');
```

## Selected methodological and paleoclimate examples

- Kim, Y. C. & Powers, E. J. (1979), *Digital bispectral analysis and its
  applications to nonlinear wave interactions*, IEEE Transactions on Plasma
  Science. [DOI](https://doi.org/10.1109/TPS.1979.4317207)
- Birkelund, Y. & Hanssen, A. (1999), higher-order spectra conference paper
  on multitaper bispectrum estimation.
  [DOI](https://doi.org/10.1109/HOST.1999.778727)
- Liebrand et al. (2017), PNAS, moving-window bispectral analysis of ODP Site
  1264 benthic oxygen isotopes.
  [DOI](https://doi.org/10.1073/pnas.1615440114)
- Da Silva et al. (2019), Geology, paleoclimate bispectral application and the
  visual reference for the warm triangular maps in this toolbox.
  [DOI](https://doi.org/10.1130/G45511.1)
- Liebrand & de Bakker (2019), Climate of the Past, moving imaginary
  bispectrum of the LR04 stack.
  [DOI](https://doi.org/10.5194/cp-15-1959-2019)
- Sullivan et al. (2023), PNAS, orbital-scale nonlinear coupling analyzed with
  seven segments, 50% overlap, Hann taper, and detrending.
  [Article/SI](https://doi.org/10.1073/pnas.2304152120)
- Acycle software description: Li, Hinnov & Kump (2019), *Computers &
  Geosciences* 127, 12–22. [DOI](https://doi.org/10.1016/j.cageo.2019.02.011)

The plot palette and layout are an original implementation inspired by the
information hierarchy of Da Silva et al. (2019); no published figure artwork
is embedded or copied.
