function dataMat = astroebsd2mtex(MATFilename)
% astroebsd2mtex Write output data from an AstroEBSD MAT-file to a format
% readable by MTEX
%
% Parameters
% MATFilename : file. Full file path of MAT-file output from AstroEBSD
%
% Returns
% dataMat : array. Matrix of output data
%
% Håkon Wiik Ånes (hakon.w.anes@ntnu.no)
% 2018-11-03

% Check if input file is a MAT-file
[filepath,filename,ext] = fileparts(MATFilename);
if ~strcmp(ext,'.mat')
    error('This is not a MAT file.')
end

% Read data from AstroEBSD MAT-file
data = load(MATFilename);

% Get shape of data
[rows,cols] = size(data.Data_InputMap.XSample);

% Create header and matrix of data
fileHeader = ['x\ty\t\tphi1\t\tPhi\t\t\tphi2\t\tpq\t\t\tps\t\t\tmae\t\tbn'...
    '\tphase\r\n'];
dataMat = [...
    reshape(data.Data_InputMap.XSample,rows*cols,1)...     % X sample position
    reshape(data.Data_InputMap.YSample,rows*cols,1)...     % Y sample position
    reshape(data.Data_OutputMap.phi1,rows*cols,1)...       % phi1
    reshape(data.Data_OutputMap.PHI,rows*cols,1)...        % Phi
    reshape(data.Data_OutputMap.phi2,rows*cols,1)...       % phi2
    reshape(data.Data_OutputMap.IQ,rows*cols,1)...         % Pattern quality
    reshape(data.Data_OutputMap.BQ,rows*cols,1)...         % Pattern slope
    reshape(data.Data_OutputMap.Err,rows*cols,1)...        % Mean Angular Error
    reshape(data.Data_OutputMap.BandNumber,rows*cols,1)... % Band number
    reshape(data.Data_OutputMap.Phase,rows*cols,1)         % Phase
    ];

% Write header and data matrix to file
outputFilename = fullfile(filepath,[filename '_mtex.dat']);
fid = fopen(outputFilename,'w');
fprintf(fid,fileHeader);
for i=1:rows*cols
    fprintf(fid,['%i\t%i\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f'...
        '\t%i\t%i\n'],...
        dataMat(i,1),dataMat(i,2),dataMat(i,3),dataMat(i,4),dataMat(i,5),...
        dataMat(i,6),dataMat(i,7),dataMat(i,8),dataMat(i,9),dataMat(i,10));
end
fclose(fid);

end