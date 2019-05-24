%% astroebsd2mtex example usage
% Write output data from an AstroEBSD .mat-file to a format readable by
% MTEX and do some simple orientation data processing and visualisation.
%
% MTEX is necessary to run this example script.
% Download: https://mtex-toolbox.github.io/
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no)
% 2019-03-14

astro_file = ['/home/hakon/phd/data/sem/def2_cr90_325c/1000s/2_200/nordif/'...
    'astro_demo/astro_crop2/Pattern.dat_AstroEBSD_2019_03_14_13_07_14.mat'];
[fpath, fname, ~] = fileparts(astro_file);

% Write output data from AstroEBSD to a format readable by MTEX
astroebsd2mtex(astro_file);

% Read orientation data into an MTEX' @EBSD object from the file created above
mtex_file = fullfile(fpath, [fname '_mtex.dat']);
cs = {'notIndexed', crystalSymmetry('m-3m', [4.04 4.04 4.04], 'mineral', 'al')};
columns = {'x' 'y' 'euler1' 'euler2' 'euler3' 'pq' 'ps' 'mae' 'bn' 'phase'};
ebsd = loadEBSD(mtex_file, cs, 'convertEuler2SpatialReferenceFrame',...
    'ColumnNames', columns);

% Tell MTEX which way is up
setMTEXpref('yAxisDirection', 'south');
setMTEXpref('zAxisDirection', 'intoPlane');

% Filter orientation data based on mean angular error (mae)
ebsd_filter = ebsd;
ebsd_filter(ebsd.mae > 3*degree) = [];

% Reconstruct grains
[grains, ebsd_filter.grainId] = calcGrains(ebsd_filter, 'angle', 10*degree);

% Remove smaller grains than 2 pixels
ebsd_filter(grains(grains.grainSize < 2)) = [];

% Reconstruct grains again and the smooth boundaries
[grains, ebsd_filter.grainId] = calcGrains(ebsd_filter, 'angle', 10*degree);
grains = smooth(grains, 1);

% Smooth and fill in filtered out orientations
filter = halfQuadraticFilter;
filter.alpha = 0.005; % Set the smoothing parameter to a low value
ebsd_smooth = smooth(ebsd_filter, filter, 'fill');

% Plot pattern (band) slope with grain boundaries
plot(ebsd, ebsd.ps)
mtexColorMap black2white
mtexColorbar
hold on
plot(grains.boundary, 'linecolor', 'red', 'linewidth', 2)

% Plot mean angular error with grain boundaries
figure
plot(ebsd_filter, ebsd_filter.mae/degree)
mtexColorMap black2white
mtexColorbar
hold on
plot(grains.boundary, 'linecolor', 'red', 'linewidth', 2)

% Plot inverse pole figure map with respect to Y direction, with grain
% boundaries
oM = ipfHSVKey(cs{2});
oM.inversePoleFigureDirection = yvector;
figure
plot(ebsd_smooth('al'), oM.orientation2color(ebsd_smooth('al').orientations));
hold on
plot(grains.boundary, 'linewidth', 2)