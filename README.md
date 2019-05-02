# mtex-snippets

A collection of scripts and convenience functions I use for processing and analysing orientation data in [MTEX](https://mtex-toolbox.github.io/).

## Contents

### astroebsd2mtex

Write output data from an AstroEBSD .mat-file to a format readable by MTEX.

### sped_calc_gnd

Convenience function for estimating geometrically necessary dislocation (GND) densities from orientation data obtained from (scanning) precession electron diffraction (S)PED patterns. Plots and writes a GND density map and writes the data to a new file.

### ebsd_check_quality

Check quality of indexing of EBSD data.

### ebsd_plot_orientation_maps

Plot orientation maps and/or inverse pole figure density plots from EBSD data and write them to file.

### export2ang

Create a new TSL .ang file from an @EBSD object by copying the original .ang file header and exporting the object's data to the file.
