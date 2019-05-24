# astroebsd2mtex

Write output data from an AstroEBSD MAT-file to a format readable by MTEX.

Running

```matlab
astroebsd2mtex('/path/to/matfile/output/from/astroebsd/matfile.mat');
```

will write sample position (x, y), Euler angles, pattern quality, pattern slope, mean angular error, band number and phase per sample position to a DAT-file which can be read by MTEX.

An example script showing the exporting from AstroEBSD and importing in MTEX is included in `example_usage.m`. The script also shows some simple orientation data processing and visualisation.
