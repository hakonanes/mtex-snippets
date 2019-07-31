# mtex-snippets

A collection of scripts and convenience functions I use for processing and analysing orientation data in [MTEX](https://mtex-toolbox.github.io/).

## Contents

### astroebsd2mtex

Write output data from an AstroEBSD .mat-file to a format readable by MTEX.

### distance_from_grain_boundary

Return an @EBSD object with the euclidian distance in pixels of each measurement to a grain boundary as a property. Whether the measurement is a boundary or not is also included as a property to the @EBSD object. Edge boundaries are excluded for the distance calculation.

### export2ang

Create a new TSL .ang file from an @EBSD object by copying the original .ang file header and exporting the object's data to the file.

### ebsd_check_quality

Check quality of indexing of Kikuchi diffraction patterns.

### ebsd_plot_orientation_maps

Plot orientation maps and/or inverse pole figure density plots from EBSD data and write them to file.

### ebsd_fraction_hab

Calculate the fraction of each grain's boundary that has a given high angle misorientation to its surrounding grains.

### ebsd_fraction_recrystallised

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

### emsoft_reader

Read orientation data from dictionary indexing results in the EMsoft HDF5 format into an MTEX @EBSD object. Supports single phase results only.

### write_orientations_to_ang

Write orientation data from a SPED data set to a text file in the ANG format used by NanoMegas' ASTAR and EDAX TSL.
