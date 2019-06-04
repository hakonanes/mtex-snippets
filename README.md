# mtex-snippets

A collection of scripts and convenience functions I use for processing and analysing orientation data in [MTEX](https://mtex-toolbox.github.io/).

## Contents

### astroebsd2mtex.m

Write output data from an AstroEBSD .mat-file to a format readable by MTEX.

### sped_calc_gnd.m

Convenience function for estimating geometrically necessary dislocation (GND) densities from orientation data obtained from (scanning) precession electron diffraction (S)PED patterns. Plots and writes a GND density map and writes the data to a new file.

### export2ang.m

Create a new TSL .ang file from an `@EBSD` object by copying the original .ang file header and exporting the object's data to the file.

### ebsd_check_quality.m

Check quality of indexing of EBSD data.

### ebsd_plot_orientation_maps.m

Plot orientation maps and/or inverse pole figure density plots from EBSD data and write them to file.

### ebsd_denoise.m

Denoise EBSD data following these steps:
  1. Reconstruct grains (including the smallest grains in the bigger grains based upon a given minimum pixel threshold) with a given misorientation angle threshold (mat).
  2. Denoise with a given filter while filling in not indexed pixels.
  3. Reconstruct grains again with a different given mat, still including the smallest grains in the bigger grains. Grains are also smoothed.
  4. Denoise again with the given filter while filling in not indexed pixels.

The script assumes that:
  * Low quality pixels are removed, for example by calling `ebsd = ebsd(ebsd.fit > 2).phase = -1;`
  * The EBSD object only has one phase if plotting to assertain quality of denoising is desired.

### ebsd_fraction_hab

Calculate the fraction of each grain's boundary that has a given high angle misorientation to its surrounding grains. Returns a new `@grain2d` object, containing only indexed grains, with a `Xhab` property. Can also plot a map of grains with grain colour corresponding to `Xhab`.

### ebsd_fraction_recrystallised.m

Determine if a grain is recrystallised or not based upon three criteria:
  1. A minimum equivalent circular diameter.
  2. A maximum grain orientation spread.
  3. A minimum fraction of high angle grain boundary.

Returns three new `@grain2d` objects, all containing only indexed grains:
  1. All grains with a boolean recrystallisation property.
  2. All subgrains.
  3. All recrystallised grains.

Can also plot a map of grains with grain colour corresponding to the `RX` property.

The script assumes that the grains object has `grains.ECD` and `grains.Xhab` properties, and if not assigns these to the grains object.

Example usage:

```matlab
[grains, sub, rx] = ebsd_fraction_recrystallised(grains, 'ebsd', ebsd,...
    'overlay_metric', ebsd.fit, 'overlay_cmap', 2);
```

### ebsd_write_data_to_file

A collection of functions writing data (for example grain data) to .csv files.

### indexing_success_rate

Calculate an indexing success rate (ISR) value by comparing a given EBSD scan to a reference scan. An orientation in the comparison scan is compared against any of the orientations in the kernel of neighbouring points in the reference scan. See Wright, Stuart I., Nowell, Matthew M., Lindeman, Scott P., Camus, Patrick P., De Graef, Marc, Jackson, Michael A.: Introduction and comparison of new EBSD post-processing methodologies , Ultramicroscopy 159(P1), Elsevier, 81–94, 2015 for details.
