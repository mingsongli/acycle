# Acycle Multivariate Package — PCoA / ANOSIM / PERMANOVA

Distance-based multivariate analysis for Acycle, ported from **PaleoAST**
(the Paleontological Advanced Statistical Toolkit, MIT licensed), where the
implementations are cross-validated against R (`vegan::vegdist`,
`vegan::anosim`, `vegan::adonis2`) and `scipy` in a live cross-validation
test suite. The MATLAB kernels here reproduce the validated behavior,
including Anderson's (2001) sums-of-squares denominators, Clarke's (1993)
ANOSIM R with the `vegan` PAI correction, average-rank tie handling, and the
(1 + count)/(n + 1) permutation p-value form of Phipson & Smyth (2010).

All numerical code uses base MATLAB only — no toolboxes are required.

## Analyses

| Method | Question it answers | Reference |
|---|---|---|
| **PCoA** (principal coordinate analysis) | Which axes best summarize the dissimilarities between samples? | Gower 1966 |
| **ANOSIM** | Are between-group dissimilarities larger than within-group ones? (rank test, statistic R in [-1, 1]) | Clarke 1993 |
| **PERMANOVA** | Do group centroids differ in multivariate space? (pseudo-F partition of sum of squares) | Anderson 2001 |

## Data model

The dialog follows Acycle's Principal Component convention: **select two or
more equal-length series** in the main window. Each series becomes one
*variable* (column); each aligned row becomes one *sample* (a stratigraphic
horizon). The first series' first column supplies the common depth/time axis.
Series with unequal row counts are refused — interpolate to a common grid
first (Math > Interpolation).

Groups are defined by **ascending boundaries on the depth/time axis**
(e.g. `25 40` splits the record into G1 < 25 <= G2 < 40 <= G3). ANOSIM and
PERMANOVA require at least two groups, at least one group with two or more
samples, and (PERMANOVA) n > G. For PCoA the boundaries are optional and
only color the ordination.

## Distance metrics

- **Euclidean** — continuous proxies; pair with the "standardize (z-score)"
  option when series have different units or magnitudes.
- **Bray-Curtis** — non-negative abundance/compositional data; refuses
  negative values and pairs of all-zero samples.
- **Jaccard** — presence/absence (non-zero = present; magnitudes discarded).
- **Manhattan** — absolute differences.

## Caveats

Samples along a depth/time axis are serially autocorrelated, so permutation
p-values should be treated as exploratory. The negative eigenvalue sum is
reported for non-Euclidean metrics (Bray-Curtis, Jaccard); the `lingoes`
correction shifts squared distances so the smallest eigenvalue becomes zero.

## Files

| File | Purpose |
|---|---|
| `multivariateGUI.m` | Single-file uifigure dialog (method, metric, groups, permutations, plots, export) |
| `multivariateLoadSelection.m` | Loads and stacks the selected main-list series |
| `multivariateDistanceMatrix.m` | Euclidean / Manhattan / Bray-Curtis / Jaccard matrices |
| `multivariatePcoa.m` | Gower double centering, eigendecomposition, cmdscale/lingoes corrections |
| `multivariateAnosim.m` | ANOSIM R + PAI correction + permutation test |
| `multivariatePermanova.m` | Anderson (2001) pseudo-F + permutation test |
| `multivariateGroupLabels.m` | Depth/time boundaries -> group labels |
| `multivariatePermutationPvalue.m` | Shared permutation driver (Phipson & Smyth 2010) |
| `multivariateTiedRank.m` | Average ranks with tie handling (toolbox-free `tiedrank`) |
| `multivariateValidateDistanceMatrix.m` | Shared square/symmetric/finite matrix contract |
| `multivariateSelfTest.m` | Deterministic numerical regression tests (`multivariateSelfTest`) |

## Self test

Run `multivariateSelfTest` in MATLAB. It checks the golden values listed
above against scipy/R-validated constants, PCoA distance-reconstruction
identities, the Lingoes eigenvalue shift, ANOSIM R = 1 for perfectly
separated groups, SS_T = SS_B + SS_W, seed reproducibility of the
permutation p-values, and the refusal paths for degenerate designs.

## Programmatic use

```matlab
D = multivariateDistanceMatrix(data,'braycurtis',false);   % data: n-by-p
groups = multivariateGroupLabels(axis,[4 8]);              % from depth/time
result = multivariatePermanova(D,groups,'Permutations',999,'RandomSeed',42);
disp(result.fStatistic), disp(result.pValue)

result = multivariateAnosim(D,groups);
result = multivariatePcoa(D,'Correction','lingoes');
```

## References

- Gower, J.C., 1966. Some distance properties of latent root and vector
  methods used in multivariate analysis. Biometrika 53, 325-338.
- Clarke, K.R., 1993. Non-parametric multivariate analyses of changes in
  community structure. Australian Journal of Ecology 18, 117-143.
- Anderson, M.J., 2001. A new method for non-parametric multivariate
  analysis of variance. Austral Ecology 26, 32-46.
- Legendre, P., Fortin, M.-J., 1989. Spatial pattern and ecological
  analysis. Vegetatio 80, 107-138.
- Phipson, B., Smyth, G.K., 2010. Permutation p-values should never be zero:
  calculating exact p-values when permutations are randomly drawn.
  Statistical Applications in Genetics and Molecular Biology 9, Article 39.
- Lingoes, J.C., 1971. An IBM 1130 program for Guttman-Lingoes smallest
  space analysis. Behavioral Science 16, 85-90.
