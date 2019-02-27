# mtex-snippets

A collection of scripts and convenience functions I use when processing and analysing orientation data in [MTEX](https://mtex-toolbox.github.io/).

## Contents

### astroebsd2mtex

Write output data from an AstroEBSD .mat-file to a format readable by MTEX.

### calc_gnd_sped

Convenience function for estimating geometrically necessary dislocation (GND) densities from orientation data obtained from (scanning) precession electron diffraction (S)PED patterns. Plots and writes a GND density map and writes the data to a new file.

### ebsd_check_quality

Check quality of indexing of electron backscatter diffraction patterns.

### plot_orientation_maps_ebsd

Plot orientation maps and/or inverse pole figure density plots from EBSD data and write them to file.

### export2ang

Create a new TSL .ang file from an @EBSD object by copying the original .ang file header and exporting the object's data to the file.


%
% Input
%  ebsd - @EBSD object
%  old_ang - string of original .ang file to copy header from
%
% Options
%  fout - string of file name (without extension) of output .ang file
%  rotation - {'convertEuler2SpatialReferenceFrame',
%  'convertSpatial2EulerReferenceFrame'}. If orientation data was rotated when
%  imported, by using either of the above options, the data is rotated back
%  before exported if any of the options above are passed.
