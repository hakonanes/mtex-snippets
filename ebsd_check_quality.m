function ebsd_check_quality(ebsd, out_path, varargin)
% EBSD_CHECK_QUALITY Check quality of indexing of Kikuchi diffraction
% patterns.
%
% Input
%  ebsd - @EBSD object
%  out_path - path to output directory
%
% Options
%  type - string, {'ang' (default), 'osc' or 'astro'}.
%  to_plot - bool, if 1 (default), show plots and not just save them.
%
% Assumes the indexing data file from AstroEBSD is created with the
% astroebsd2mtex script found here (https://github.com/hwagit/mtex-snippets).
% 
% Assumes the following Euler directions for package types:
%   * ang: Xeuler = image east, Zeuler = into image
%   * osc/astro: Xeuler = image north, Zeuler = into image
%
% Requires the export_fig package to write figures to file
% (https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig).
%
% Created by Håkon Wiik Ånes (hakon.w.anes@ntnu.no), 2019-02-21

% Set default values
type = 'ang';
to_plot = 1;

% Override default values if passed to function
if check_option(varargin, 'type')
    type = get_option(varargin, 'type');
end

% To show figures or not
set(0, 'DefaultFigureVisible', 'on')
if ~to_plot
    set(0, 'DefaultFigureVisible', 'off')
end

% Image resolution
res = '-r200';

% Set specimen directions
if strcmp(type, 'ang') || strcmp(type, 'osc')
    setMTEXpref('xAxisDirection', 'north');
    setMTEXpref('zAxisDirection', 'intoPlane');
else % astro
    setMTEXpref('xAxisDirection', 'north');
    setMTEXpref('zAxisDirection', 'intoPlane');
end

% Write mean values for index and reliability to file
fid = fopen(fullfile(out_path, 'ebsd_quality.dat'), 'w');
if strcmp(type, 'ang')
    fprintf(fid, 'iq\t\tci\t\tfitn\n%.4f\t%.4f\t%.4f', nanmean(ebsd.iq),...
        nanmean(ebsd.ci), nanmean(ebsd.fit));
elseif strcmp(type, 'osc')
    fprintf(fid, 'iq\t\tci\t\tfit\n%.4f\t%.4f\t%.4f',...
        nanmean(ebsd.imagequality), nanmean(ebsd.confidenceindex),...
        nanmean(ebsd.fit));
else % astro
    fprintf(fid, 'pq\t\tps\t\tmae\t\tbn\n%.4f\t%.4f\t%.4f\t%.4f',...
        nanmean(ebsd.pq), nanmean(ebsd.ps), nanmean(ebsd.mae)/degree,...
        nanmean(ebsd.bn));
end
fclose(fid);

% Plot pattern quality
figure
if strcmp(type, 'ang')
    plot(ebsd, ebsd.iq)
    fname = 'quality_iq.png';
elseif strcmp(type, 'osc')
    plot(ebsd, ebsd.imagequality)
    fname = 'quality_iq.png';
else % astro
    plot(ebsd, ebsd.pq)
    fname = 'quality_pq.png';
end
mtexColorMap black2white
mtexColorbar
export_fig(fullfile(out_path, fname), res);

% Plot confidence index
figure
if strcmp(type, 'ang')
    plot(ebsd, ebsd.ci)
    fname = 'quality_ci.png';
elseif strcmp(type, 'osc')
    plot(ebsd, ebsd.confidenceindex)
    fname = 'quality_ci.png';
else % astro
    plot(ebsd, ebsd.ps)
    fname = 'quality_ps.png';
end
mtexColorMap black2white
mtexColorbar
export_fig(fullfile(out_path, fname), res);

% Plot pattern fit
figure
if strcmp(type, 'astro')
    plot(ebsd, ebsd.mae)
    fname = 'quality_mae.png';
else % ang or osc
    plot(ebsd, ebsd.fit)
    fname = 'quality_fit.png';
end
mtexColorMap white2black
mtexColorbar
export_fig(fullfile(out_path, fname), res);

% Plot kernel average misorientation
kam = KAM(ebsd, 'threshold', 2*degree);

figure
plot(ebsd,kam./degree)
mtexColorbar
export_fig(fullfile(out_path, 'quality_kam.png'), res);

end