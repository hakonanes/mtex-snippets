# mtex-snippets

A collection of scripts and convenience functions I use for processing and analysing orientation data in [MTEX](https://mtex-toolbox.github.io/).

## Contents

### astroebsd2mtex

Write output data from an AstroEBSD .mat-file to a format readable by MTEX.

### sped_calc_gnd

Convenience function for estimating geometrically necessary dislocation (GND) densities from orientation data obtained from (scanning) precession electron diffraction (S)PED patterns. Plots and writes a GND density map and writes the data to a new file.

### export2ang

Create a new TSL .ang file from an @EBSD object by copying the original .ang file header and exporting the object's data to the file.

### ebsd_check_quality

Check quality of indexing of EBSD data.

### ebsd_plot_orientation_maps

Plot orientation maps and/or inverse pole figure density plots from EBSD data and write them to file.

### ebsd_denoise

Denoise EBSD data following these steps:
  1. Reconstruct grains (including the smallest grains in the bigger grains based upon a given minimum pixel threshold) with a given misorientation angle threshold (mat).
  2. Denoise with a given filter while filling in not indexed pixels.
  3. Reconstruct grains again with a different given mat, still including the smallest grains in the bigger grains. Grains are also smoothed.
  4. Denoise again with the given filter while filling in not indexed pixels.

The script assumes:
  * low quality pixels are removed, for example by calling `ebsd = ebsd(ebsd.fit > 2).phase = -1;`
  * that the EBSD object only has one phase if plotting to assertain quality of denoising is desired.
