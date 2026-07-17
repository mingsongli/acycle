# COCO publication preflight audit (2026-07-13)

## Scope

This audit covers the public confirmatory `cvCOCO` path, the exploratory
`Adaptive COCO` path, their stationary-AR(1) Monte Carlo generators,
preprocessing, target construction, inference reports, plotting, GUI wiring,
and the non-GUI publication runner. It is a software and conditional-inference
audit; it cannot establish unconditional geological causation.

## Primary inferential rules

- Confirmatory result: `p_robust = max(p_A,p_B) < 0.05`. Both directional
  held-out searches must pass. `p_sym` is a secondary paired full-flow test and
  cannot rescue a failed direction.
- Exploratory result: the minimum rate-search-corrected Adaptive global p-value
  is compared with 0.05. Local p-values are descriptive; 0.01 is only a visual
  guide.
- Every Monte Carlo p-value uses the plus-one estimator. Confidence intervals
  are Wilson intervals for the underlying null exceedance probability.
- A positive result with fewer than nine nonzero, frequency-resolved periods is
  explicitly qualified as evidence for a partial target.

## Publication-critical corrections verified

1. Uneven depth data are sorted and de-duplicated; only then are they linearly
   interpolated on the median-spacing grid. Every interpolation and parameter
   is printed in English and saved. `cvCOCO` regularizes A and B independently.
2. Adaptive COCO now compares the data PSD and finite-record target PSD on the
   identical native temporal-frequency grid. The former artificial 1-kyr grid,
   frequency interpolation, and `sr0` branch are absent from inference.
3. The Adaptive target is a phase-averaged, noncoherent orbital target. Search
   bands use a one-orbit assignment rule for overlaps, and unresolved periods
   are excluded and counted.
4. `cvCOCO` trains four group powers (long eccentricity / short eccentricity /
   obliquity / precession), corrects finite-record leakage with an audited 4x4
   nonnegative solve, freezes those weights, and validates the opposite half.
5. A/B use separate plug-in AR(1) coefficients. Every cv Monte Carlo replicate
   repeats both training directions, target freezing, validation-rate search,
   and the paired symmetric statistic. Adaptive Monte Carlo repeats its full
   data-dependent target construction and full rate search.
6. Global p-curves use the maximum over the complete predeclared rate grid;
   local and parametric p-values cannot be promoted to formal results.
7. Constant, affine-only, and numerically unresolved detrended records/slices
   are rejected with a scale-aware residual criterion, including large-offset
   edge cases.
8. Robust-red frequency units were corrected to normalized angular frequency.
   The robust-red grid search was algebraically vectorized without changing its
   candidate grids or results; deterministic baseline output was bitwise equal.
9. SWA model selection now compares all candidates lexicographically on a
   common support (fewest non-decreasing steps, then RMSE), retains metadata for
   the selected candidate, and no longer keeps a rejected smoothing iteration.
10. GUI Adaptive output uses the same strict stored-null audit as the batch
    path; it no longer reconstructs exceedance counts by rounding a p-value.
11. Orbital resources and the language dictionary are resolved relative to the
    installed code rather than the MATLAB current directory.
12. Publication output is checkpointed and records input/code SHA-256 values,
    settings, random seed, MATLAB/git provenance, MAT/XLSX/CSV data, conclusions,
    editable FIG, vector PDF, and 600-dpi PNG artifacts.

## Verification evidence

- MATLAB R2026a publication preflight: 22/22 tests passed.
- MATLAB Code Analyzer on the critical inference, GUI, robust-red, SWA, report,
  plotting, and runner files: 0 warnings.
- Robust-red deterministic comparison: maximum absolute and relative
  differences were both zero for the saved long-spectrum baseline.
- Robust-red performance: 13.63x in the direct background benchmark. On the
  6250-point signal with 121 rates, 99-replicate end-to-end timings improved
  from 75.384 s to 3.180 s for cvCOCO and from 38.649 s to 1.514 s for Adaptive.
- The six-case runner was smoke-tested on all methods; checkpoint recovery,
  MAT/XLSX/CSV/JSON, FIG/PDF/PNG, SHA-256 inventory, and A4 Word generation were
  tested before the 9999-replicate run.

## Interpretation limits that remain by design

- Calibration is conditional on a stationary Gaussian AR(1) null, plug-in rho,
  preprocessing, target algorithm, rate grid, Pad, frequency cutoff, and seed.
- Adjacent midpoint halves need not be geologically independent.
- Directional p-values are full-flow tests under the joint AR(1) null for both
  halves; they are not conditional tests allowing an arbitrary fixed signal in
  the training half.
- Interpolation regularizes the frequency axis but cannot restore information
  removed by gaps or irregular preservation.
- Adaptive COCO learns and evaluates on the same record and remains exploratory,
  even though its Monte Carlo reproduces that adaptive algorithm.
- Spectral association consistent with astronomical forcing is not an
  unconditional proof of astronomical causation.

## Formal validation run

The formal six-record run uses Pearson correlation, one spectrum slice,
`MaxFrequency = 1.2 * max(1/orbit9)`, seed 20260713, 9999 simulations for the
primary robust-red (`red=2`) analysis, and an equally sized no-background
(`red=0`) sensitivity analysis. Dataset-specific ages and rate grids are saved
in each case's `parameters.csv` and in the root manifest.

All six inputs were already evenly spaced after sorting and duplicate checks;
no interpolation was applied in this suite.

## Formal primary results (`red=2`, NSIM=9999)

| Case | cvCOCO best rates A->B / B->A | p_A | p_B | p_robust | p_sym | Adaptive best rate | Adaptive global p | Primary interpretation |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Long pure noise | 13.40 / 2.95 | 0.4602 | 0.1437 | 0.4602 | 0.2324 | 15.75 | 0.6540 | Negative control correctly negative |
| Short pure noise | 12.90 / 9.50 | 0.1496 | 0.3803 | 0.3803 | 0.1565 | 31.00 | 0.6620 | Negative control correctly negative |
| Pure 4-to-6 signal | 5.98 / 4.00 | 0.1644 | 0.2207 | 0.2207 | 0.0645 | 5.98 | 0.1973 | Rates recovered, but full-flow significance fails |
| Newark | 14.35 / 14.55 | 0.0009 | 0.0072 | 0.0072 | 0.0004 | 14.15 | 0.0008 | Robust confirmatory positive |
| Site 1262 | 0.96 / 1.19 | 0.4198 | 0.3816 | 0.4198 | 0.2502 | 1.20 | 0.1750 | Rate localized, but global tests negative |
| Givetian DD14 | 8.25 / 10.40 | 0.3175 | 0.0293 | 0.3175 | 0.1077 | 8.00 | 0.2480 | One direction/local diagnostic is positive, but robust/global tests fail |

The 4-to-6 synthetic record is a power/assumption warning rather than a false
rate recovery: the deterministic depth-midpoint split places the true rate
change inside one held-out half, whereas the confirmatory model assumes one
constant rate within each half. Adaptive also assumes one rate for the complete
record. Correct localization therefore does not imply rejection of the full
rate-search AR(1) null.

The red=0 sensitivity results preserve the primary positive/negative decisions
for all six records. Complete values are stored in each `summary.csv` and
method workbook.

## Final artifact audit

- Statistical reload audit: PASS; 6 cases, 24 methods, NSIM=9999 for every
  method, seed 20260713, and every strict saved-null conclusion reproduced.
- Artifact/layout audit: PASS; 6 case reports, 1 combined report, 60 editable
  FIG/vector-PDF/600-dpi-PNG figure sets, 307 SHA-256 inventoried artifacts.
- All Word sections are A4 and every embedded figure is at most 180 mm wide.
- A post-run layout audit caught that macOS `exportgraphics` ignored the PDF
  physical page size. The exporter was corrected to `print -dpdf -vector`, all
  60 PDFs were regenerated from the saved editable FIG files; every PDF
  MediaBox is 179.564 mm wide and therefore strictly satisfies the 180-mm
  limit. This export-only repair did not read or alter numerical results. The
  exact source used for the statistical run is archived as
  `source_snapshot_20260713.tar.gz`; the final exporter/validator source is in
  `source_snapshot_final_20260713.tar.gz`.
