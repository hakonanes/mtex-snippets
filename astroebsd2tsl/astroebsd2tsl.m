function dataMat = astroebsd2tsl(MATFilename, varargin)
% ASTROEBSD2TSL Write output data from an AstroEBSD MAT-file to a format
% readable by TSL
%
% Parameters
% MATFilename : file. Full file path of MAT-file output from AstroEBSD
%
% Options
%  fout - string of file name (without extension) of output .ang file
%
% Håkon Wiik Ånes (hakon.w.anes@ntnu.no)
% 2019-04-12

% Check if input file is a MAT-file
[filepath,filename,ext] = fileparts(MATFilename);
if ~strcmp(ext,'.mat')
    error('This is not a MAT file.')
end

if check_option(varargin, 'fout')
    fout = get_option(varargin, 'fout');
else
    [path, fin, ext] = fileparts(MATFilename);
    fout = fullfile(path, [fin '_astro2tsl' ext]);
end

% Create output file
fido = fopen(fout, 'w'); % File id (fid) of output file (o) = fido

% Write header to .ang file
fprintf(fido, '# TEM_PIXperUM\t\t1.000000\n');

% Read data from AstroEBSD MAT-file
data = load(MATFilename);

% Get shape of data
[rows, cols] = size(data.Data_InputMap.XSample);

% Create header and matrix of data
degree = 0.0175;
dataMat = [...
    reshape(data.Data_InputMap.XSample,rows*cols,1)...     % X sample position
    reshape(data.Data_InputMap.YSample,rows*cols,1)...     % Y sample position
    reshape(data.Data_OutputMap.phi1/degree,rows*cols,1)...% phi1
    reshape(data.Data_OutputMap.PHI/degree,rows*cols,1)... % Phi
    reshape(data.Data_OutputMap.phi2/degree,rows*cols,1)...% phi2
    reshape(data.Data_OutputMap.IQ,rows*cols,1)...         % Pattern quality
    reshape(data.Data_OutputMap.BQ,rows*cols,1)...         % Pattern slope
    reshape(data.Data_OutputMap.Err,rows*cols,1)...        % Mean Angular Error
    reshape(data.Data_OutputMap.BandNumber,rows*cols,1)... % Band number
    reshape(data.Data_OutputMap.Phase,rows*cols,1)         % Phase
    ];

% Write header and data matrix to file
for i=1:rows*cols
    fprintf(fido, ['%i\t%i\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f'...
        '\t%i\t%i\n'],...
        dataMat(i, 1), dataMat(i, 2), dataMat(i, 3), dataMat(i, 4),...
        dataMat(i, 5), dataMat(i, 6), dataMat(i, 7), dataMat(i, 8),...
        dataMat(i, 9), dataMat(i, 10));
end
fclose(fid);

end