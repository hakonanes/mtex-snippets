function [grains_data] = ebsd_write_grains_data(grains, out_file)
% EBSD_WRITE_GRAINS_DATA Write data of indexed grains to a .csv file and return
% the frequency weighted (!) average of all relevant properties.
%
% Input
%  grains - @grains2d object.
%  out_file - file name of output .csv file with full file path.
%
% Returns
%  grains_data - structure array, averages of all relevant properties.
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-05-02.

% Set up file, making sure the ending is correct
[path, fname, ~] = fileparts(out_file);
out_file = fullfile(path, [fname '.csv']);
header = 'area,px,aspectratio,shapefactor,gos';

% Append custom properties to header
props_original = {'GOS', 'meanRotation'};
props_custom = rmfield(grains('indexed').prop, props_original);
props_custom_names = fieldnames(props_custom); % Zero length if no custom props.
for i=1:length(props_custom_names)
    header = [header ',' lower(props_custom_names{i})];
end

% Create data matrix (can be done smarter/less hard-coded I guess)
m = [round(grains('indexed').area, 3)...
    round(grains('indexed').grainSize, 3)...
    round(grains('indexed').aspectRatio, 3)...
    round(grains('indexed').shapeFactor, 3)...
    round(grains('indexed').GOS./degree, 3)];...

% Append custom properties to matrix
props_custom_cell = struct2cell(props_custom);
for i=1:length(props_custom_names)
    m = [m round(props_custom_cell{i}, 3)];
end

% Write to file
fid = fopen(out_file, 'w');
fprintf(fid, '%s\r\n', header);
fclose(fid);
dlmwrite(out_file, m, '-append')

% Calculating average values of relevant properties
grains_data = struct(...
    'area', nanmean(grains('indexed').area),...
    'px', nanmean(grains('indexed').grainSize),...
    'aspectratio', nanmean(grains('indexed').aspectRatio),...
    'shapefactor', nanmean(grains('indexed').shapeFactor),...
    'gos', nanmean(grains('indexed').GOS./degree));

% Append averages of custom properties
for i=1:length(props_custom_names)
    grains_data = setfield(grains_data, lower(props_custom_names{i}),...
        nanmean(props_custom_cell{i}));
end

end