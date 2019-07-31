function write_orientations_to_ang(angfile, subfix, data)
% WRITE_ORIENTATIONS_TO_ANG Write orientation data from a SPED data set
% to a text file in the ANG format used by NanoMegas' ASTAR and EDAX TSL.
%
% Input
%  angfile - string, name of original ang file to copy header from.
%  subfix - string, subfix of file name to use in addition to original ang
%   file name
%  data - @EBSD object with orientations to write to file
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-07-30

[path, fname, ~] = fileparts(angfile);

% Get header of ANG file
fid = fopen(angfile, 'r');
angHeader = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

% Set up new file
fout = fullfile(path, [fname '_' subfix '.ang']);
fid = fopen(fout, 'w');

% Write ANG header to new file
for i=1:15
    fprintf(fid, '%s\n', char(angHeader{1}(i)));
end

% Write data to new file
fileHeader = ['# phi1\t\tPhi\t\t\tphi2\t\tx\t\ty\t\tind\t\trelpec\t'...
    'phase\trel\r\n'];
fprintf(fid, fileHeader);
dataMat = [...
    data.rotations.phi1,... % phi1
    data.rotations.Phi,...  % Phi
    data.rotations.phi2,... % phi2
    data.x,...              % x
    data.y,...              % y
    data.ind,...            % correlation index
    data.rel ./ 100,...     % reliability in percent
    data.phase,...          % phase
    data.rel];              % reliability

for i=1:length(data)
    fprintf(fid,['%.6f\t%.6f\t%.6f\t%.1f\t%.1f\t\t%.1f\t%.2f\t%i'...
        '\t\t%i\n'],...
        dataMat(i, 1), dataMat(i, 2), dataMat(i, 3), dataMat(i, 4),...
        dataMat(i, 5), dataMat(i, 6), dataMat(i, 7), dataMat(i, 8),...
        dataMat(i, 9));
end

% Close new file
fclose(fid);

end