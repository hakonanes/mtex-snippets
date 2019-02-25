function ebsd_check_quality(file,type,cs)
% EBSD_CHECK_QUALITY Check quality of indexing of Kikuchi diffraction
% patterns.
%
% Input
%  file - string with full path of input file.
%  type - string, {'oim' (default) or 'astroebsd'}.
%  cs - cell array with crystal symmetries (default is notIndexed and Al).
%
% Assumes the indexing data file from AstroEBSD is created with the
% astroebsd2mtex script found here (https://github.com/hwagit/mtex-snippets).
% 
% Assumes the following specimen directions for package types:
%   * astroebsd: Xeuler = image north, Zeuler = into image
%   * oim: Xeuler = image east, Zeuler = out of image
%
% Requires the export_fig package to write figures to file
% (https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig).
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-02-21

if ~exist('type','var'), type = 'oim'; end

% Crystal symmetry
if ~exist('cs','var')
    cs = {'notIndexed',crystalSymmetry('m-3m',[4.04 4.04 4.04],'mineral','Al')};
end

% Set specimen directions
if strcmp(type,'oim')
    setMTEXpref('xAxisDirection','east');
    setMTEXpref('zAxisDirection','outOfPlane');
else % astroebsd
    setMTEXpref('xAxisDirection','north');
    setMTEXpref('zAxisDirection','intoPlane');
end

% To show figures or not
set(0,'DefaultFigureVisible','off')

% Image resolution
res = '-r200';

% Read data from file
[path,~,~] = fileparts(file);

% Read data
if strcmp(type,'oim')
    ebsd = loadEBSD(file,cs,'interface','ang',...
        'convertSpatial2EulerReferenceFrame');
else % astroebsd
    ebsd = loadEBSD(file,cs,'ColumnNames',...
        {'x' 'y' 'euler1' 'euler2' 'euler3' 'pq' 'ps' 'mae' 'bn' 'phase'});
end

% Write mean values for index and reliability to file
fid = fopen(fullfile(path,'ebsd_quality.dat'),'w');
if strcmp(type,'astroebsd')
    fprintf(fid,'pq\t\tps\t\tmae\t\tbn\n%.4f\t%.4f\t%.4f\t%.4f',...
        nanmean(ebsd.pq),nanmean(ebsd.ps),nanmean(ebsd.mae)/degree,...
        nanmean(ebsd.bn));
else % oim
    fprintf(fid,'iq\t\tci\t\tfitn\n%.4f\t%.4f\t%.4f',nanmean(ebsd.iq),...
        nanmean(ebsd.ci),nanmean(ebsd.fit));
end
fclose(fid);

% Plot pattern quality
figure
if strcmp(type,'astroebsd')
    plot(ebsd,ebsd.pq)
    fname = 'quality_pq.png';
else % oim
    plot(ebsd,ebsd.iq)
    fname = 'quality_iq.png';
end
mtexColorMap black2white
mtexColorbar
export_fig(fullfile(path,fname),res);

% Plot confidence index
figure
if strcmp(type,'astroebsd')
    plot(ebsd,ebsd.ps)
    fname = 'quality_ps.png';
else % oim
    plot(ebsd,ebsd.ci)
    fname = 'quality_ci.png';
end
mtexColorMap black2white
mtexColorbar
export_fig(fullfile(path,fname),res);

% Plot pattern fit
figure
if strcmp(type,'astroebsd')
    plot(ebsd,ebsd.mae)
    fname = 'quality_mae.png';
else % oim
    plot(ebsd,ebsd.fit)
    fname = 'quality_fit.png';
end
mtexColorMap white2black
mtexColorbar
export_fig(fullfile(path,fname),res);

% Plot kernel average misorientation
kam = KAM(ebsd,'threshold',2*degree);

figure
plot(ebsd,kam./degree)
mtexColorMap LaboTeX
mtexColorbar
export_fig(fullfile(path,'quality_kam.png'),res);

end