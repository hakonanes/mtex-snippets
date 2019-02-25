function calc_gnd_sped(file,cs,gnd_range)
% CALC_GND_SPED Convenience function for estimating geometrically necessary
% dislocation (GND) densities from orientation data obtained from (scanning)
% precession electron diffraction (S)PED patterns. Plots and writes a GND
% density map and writes the data to a new file.
%
% Input
%  file - string with full path of input file.
%  cs - cell array with crystal symmetries (default is notIndexed and Al).
%  gnd_range - plotting range for GND densities.
%
% Assumes orientation data is denoised (smoothed) using MTEX' smooth
% function.
%
% Requires the export_fig package to write figures to file
% (https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig).
%
% Created by Håkon W. Ånes (hakon.w.anes@ntnu.no), 2019-02-25

% Crystal and specimen symmetry
if ~exist('cs','var')
    cs = {'notIndexed',crystalSymmetry('m-3m',[4.04 4.04 4.04],'mineral','Al')};
end

% Set GND range if not input
if ~exist('gnd_range','var')
    gnd_range = [1e14,1e16];
end

% Set specimen directions
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');

% To show figures or not
set(0,'DefaultFigureVisible','off')

% Image resolution
res = '-r200';

% Read data from file
[path,fname,~] = fileparts(file);

% Read data
sped = loadEBSD(file,cs,'ColumnNames',...
    {'euler1' 'euler2' 'euler3' 'phase' 'ind' 'rel' 'x' 'y'});

% Calculate (incomplete) curvature tensor
sped = sped.gridify;
sped.scanUnit = 'nm';

% Compute the curvature tensor
fprintf('* Calculate (incomplete) curvature tensor\n')
kappa = sped.curvature;

% Get dislocation system for space group 225
dS = dislocationSystem.fcc(sped.CS,0.3);

% Rotate the dislocation tensors into the specimen reference frame
dSRot = sped.orientations * dS;

% Fit dislocation tensor to the dislocation density tensor in each pixel
[rho,factor] = fitDislocationSystems(kappa,dSRot);

% Total dislocation energy
gnd = factor*sum(abs(rho .* dSRot.u),2);

% Assign GND data to SPED data
sped.prop = setfield(sped.prop,'gnd',gnd);

% Plot dislocation densities
figure
plot(sped,sped.gnd)
mtexColorMap jet
mtexColorbar
set(gca,'ColorScale','log')
set(gca,'CLim',gnd_range);
if saveplot; export_fig(fullfile(path,[fname '_gnd.png']),res); end
close

% Write dislocation densities to file
fid = fopen(fullfile(path,[fname '_gnd.dat']),'w');
fprintf(fid,gnd);
fclose(fid);

end