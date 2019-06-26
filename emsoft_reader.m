function ebsd = emsoft_reader(file, cs, refined)
% EMSOFT_READER Read orientation data from dictionary indexing results in
% the EMsoft HDF5 format into an MTEX @EBSD object.
%
% Only support for single phase results.
%
% Input
%  file - full path to HDF5 file
%  cs - @crystalSymmetry object to pass to the @EBSD object creation
%    function
%  refined - whether HDF5 data set RefinedEulerAngles or EulerAngles should
%    be read
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-06-26

% Setup
dataset = '/Scan 1/EBSD/';
nRows = h5read(file, fullfile(dataset, 'Header/nRows'));
nColumns = h5read(file, fullfile(dataset, 'Header/nColumns'));
nRows = double(nRows);
nColumns = double(nColumns);
stepX = h5read(file, fullfile(dataset, 'Header/Step X'));
stepY = h5read(file, fullfile(dataset, 'Header/Step Y'));

props = struct;

% Create X, Y positions
xLine = linspace(0, stepX * (nColumns - 1), nColumns);
yLine = linspace(0, stepY * (nRows - 1), nRows);
X = repmat(xLine, 1, nRows)';
Y = repmat(yLine, 1, nColumns)';
Y = sort(Y);
props.x = double(X);
props.y = double(Y);

% Get other properties
props.ci = double(h5read(file, fullfile(dataset, 'Data/CI')));
props.iq = double(h5read(file, fullfile(dataset, 'Data/IQ')));
props.ism = double(h5read(file, fullfile(dataset, 'Data/ISM')));
props.osm = double(h5read(file, fullfile(dataset, 'Data/OSM')));
props.osm = props.osm(:);
props.adp = h5read(file, fullfile(dataset, 'Data/AvDotProductMap'));
props.adp = props.adp(:);

% Get Euler angles
if refined
    euler = double(h5read(file, fullfile(dataset, 'Data/RefinedEulerAngles')));
else
    euler = double(h5read(file, fullfile(dataset, 'Data/EulerAngles')));
end
rot = rotation.byEuler(euler(1, :)', euler(2, :)', euler(3, :)');

% Phase
phases = h5read(file, fullfile(dataset, 'Data/Phase'));

% Write to EBSD object
ebsd = EBSD(rot, phases, cs, 'options', props);

end