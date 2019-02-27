function export2ang(ebsd, old_ang, varargin)
% EXPORT2ANG Create a new TSL .ang file from an @EBSD object by copying the
% original .ang file header and exporting the object's data to the file.
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
%
% Created by Håkon W. Ånes (hakon.w.anes@ntnu.no), 2019-02-26

if check_option(varargin, 'fout')
    fout = get_option(varargin, 'fout');
else
    [path, fin, ext] = fileparts(old_ang);
    fout = fullfile(path, [fin '_e2a' ext]);
end

% Create output file
fido = fopen(fout, 'w'); % File id (fid) of output file (o) = fido

% Get header from old .ang file and write to new .ang file
old_ang_content = fileread(old_ang);
key = '#';
cstr = strsplit(old_ang_content, '\n');
match = strncmp(cstr, key, length(key));
cstr = cstr(match);
fprintf(fido, '%s\n', cstr{:});

% Rotate data if necessary
if check_option(varargin,'convertSpatial2EulerReferenceFrame')
    ebsd = rotate(ebsd, rotation.byAxisAngle(xvector + yvector,...
        -180*degree),'keepEuler');
elseif check_option(varargin,'convertEuler2SpatialReferenceFrame')
    ebsd = rotate(ebsd, rotation.byAxisAngle(xvector + yvector,...
        -180*degree), 'keepXY');
end
    
% Check if data set contains not indexed pixels
if ~isempty(ebsd(ebsd.phase == -1))
    notIndexed = ebsd(ebsd.phase == -1);
    notIndexed.rotations = orientation('Euler',12.56637,12.56637,12.56637);
    notIndexed.ci = -1;
    notIndexed.iq = 0;
    notIndexed.fit = 180;
    notIndexed.sem_signal = 0;
    notIndexed.unknown1 = 0;
    notIndexed.unknown2 = 0;
    notIndexed.unknown3 = 0;
    notIndexed.unknown4 = 0;
    ebsd(ebsd.phase == -1) = notIndexed;
end

% Check if data is gridified and unravel the square matrix if it is
new_shape = [size(ebsd, 1)*size(ebsd, 2), 1];
if size(ebsd, 2) > 1
    ebsd.rotations = reshape(ebsd.rotations, new_shape);
    ebsd.x = reshape(ebsd.x, new_shape);
    ebsd.y = reshape(ebsd.y, new_shape);
    ebsd.iq = reshape(ebsd.iq, new_shape);
    ebsd.ci = reshape(ebsd.ci, new_shape);
    ebsd.phase = reshape(ebsd.phase, new_shape);
    ebsd.fit = reshape(ebsd.fit, new_shape);
    ebsd.sem_signal = reshape(ebsd.sem_signal, new_shape);
    ebsd.unknown1 = reshape(ebsd.unknown1, new_shape);
    ebsd.unknown2 = reshape(ebsd.unknown2, new_shape);
    ebsd.unknown3 = reshape(ebsd.unknown3, new_shape);
    ebsd.unknown4 = reshape(ebsd.unknown4, new_shape);
end

% Create matrix with relevant values
m = [ebsd.rotations.phi1'; ebsd.rotations.Phi';...
    ebsd.rotations.phi2';ebsd.x'; ebsd.y'; ebsd.iq'; ebsd.ci';...
    reshape(ebsd.phase, new_shape)';ebsd.sem_signal';ebsd.fit';...
    ebsd.unknown1'; ebsd.unknown2';ebsd.unknown3'; ebsd.unknown4'];

% Write matrix to file
tsl_format = ['  %8.5f   %8.5f   %8.5f   %10.5f   %10.5f   %10.3f   %+4.3f'...
    '   %i   %+i   %7.3f   %7.5f   %7.5f   %7.5f   %7.5f\n'];
fprintf(fido, tsl_format, m);

% Close output file
fclose(fido);

end