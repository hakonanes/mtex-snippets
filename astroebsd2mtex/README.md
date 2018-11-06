# astroebsd2mtex

Write output data from an AstroEBSD MAT-file to a format readable by MTEX.

Running

```matlab
astroebsd2mtex('/path/to/matfile/output/from/astroebsd/matfile.dat');
```

will write sample position (x, y), Euler angles, pattern quality, pattern slope, mean angular error, band number and phase per sample position to a DAT-file which can be read by MTEX.

To read data from this file into MTEX, run

```matlab

% Crystal symmetry
cs = {'notIndexed',...
    crystalSymmetry('m-3m',[4.04 4.04 4.04],'mineral','Al')};

% Read data from file
pname = ['/path/to/datfile/'];
fname = [pname 'datfile_mtex.dat'];

ebsd = loadEBSD(fname,cs,'convertEuler2SpatialReferenceFrame','ColumnNames',...
    {'x' 'y' 'euler1' 'euler2' 'euler3' 'pq' 'ps' 'mae' 'bn' 'phase'});
```
